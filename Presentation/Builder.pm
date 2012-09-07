#<snip intro>
use MooseX::Declare;
use Method::Signatures::Modifiers;
use Modern::Perl;
#</snip intro>
class Presentation::Builder {
	use YAML;
	use File::Slurp;
	use Presentation::Builder::Types;
	use Presentation::Builder::Template;
	use Presentation::Builder::Slides;
	use Presentation::Builder::Sources;
	has 'type' => (
		isa      => 'Str',
		is       => 'ro',
		default  => 'S5',
	);
#<snip coerce usage>
	has 'input_file' => (
		isa      => 'ConfigFile',
		is       => 'ro',
		coerce   => 1,
		required => 1,
	);
#</snip coerce usage>
#<snip lazy_build>
	has 'data' => (
		isa        => 'HashRef',
		is         => 'ro',
		lazy_build => 1
	);
	method _build_data {
		my $ret = Load(scalar 
			File::Slurp::read_file($self->input_file));
#</snip lazy_build>
		return Presentation::Builder::Sources->new(directories => $ret->{sources}, input => $ret)->snipified();
	}
	has 'template_file' => (
		isa      => 'TemplateFile',
		is       => 'ro',
		required => 1,
	);
#<snip handles>
	has 'template' => (
		isa      => 'Presentation::Builder::Template',
		is       => 'rw',
		handles  => ['dom'],
		lazy_build => 1,
	);
	method _build_template {
		my $t_pkg = "Presentation::Builder::Template::".$self->type;
		return $t_pkg->new(template_file => $self->template_file);
	}
#</snip>

	has 'slides' => (
		isa     => 'Presentation::Builder::Slides',
		is      => 'rw',
		lazy    => 1,
		default => sub { Presentation::Builder::Slides->new(type => $_[0]->type, data => $_[0]->data) },
	);

	has 'template_mode' => (
		isa      => 'Str',
		is       => 'rw',
		default  => 'replace',
	);
	has 'html' => (
		isa      => 'Str',
		is       => 'rw',
	);

	method content {
		return $self->html if $self->html;
		my $data = $self->data;
		$self->dom->at('html title')->replace_content($data->{title});
		my $footer = $data->{footer};
		if ( !$footer ) {
			$footer   .= "<h3>$data->{author} ~ $data->{affiliation} ~ ".localtime." ~ Powered by ".$self->type." and Presentation::Builder</h3>";
			$footer   .= "<h3>$data->{title}</h3>";
		}
		$self->dom->at('#footer')->replace_content($footer);

		if ( $self->template_mode eq 'replace' ) {
			$self->dom->at('.presentation')->replace(
				$self->slides->content()
			);
		}
		else {
			$self->dom->at('.presentation')->append_content(
				$self->slides->content()
			);
		}
		$self->html("".$self->dom());
		return $self->html;
	}

	has 'output_file' => ( isa => 'Str', is => 'ro', required => 0 );

	method generate {
		die "Need an output file" if not $self->output_file;
		die "No content!" if not $self->content();
		open my $fh, '>', $self->output_file;
		print $fh $self->content();
		close $fh;
	}
}
