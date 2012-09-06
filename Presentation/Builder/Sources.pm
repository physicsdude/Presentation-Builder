use MooseX::Declare;
use Method::Signatures::Modifiers;
use Modern::Perl;
use Moose::Autobox;
class Presentation::Builder::Sources {
	use Presentation::Builder::Types;
	use File::Slurp;
	use File::Find;

	has 'directories' => (
		isa      => 'ArrayRef',
		is       => 'ro',
		required => 1,
	);
	has 'input' => (
		isa      => 'HashRef',
		is       => 'rw',
	);
	has 'files' => (
		isa      => 'HashRef',
		is       => 'rw',
		default  => sub {{}},
	);
	has 'snippets' => (
		isa      => 'HashRef',
		is       => 'rw',
		lazy_build => 1,
	);
	method _build_snippets {
		my $ret = {};
		find(sub {
				return unless /\.p\w+?$/;
				my $file = $_;
				$self->files->{$file} = 1;
				my $c = File::Slurp::read_file($file);
				while ( $c =~ m{<snip\s+([^>]+?)>(.*?)(?:</snip([^>]*?)>)}gs ) {
					my ($name,$snippet) = ($1,$2);
					$ret->{$name} = $snippet;
				}
		}
		, @{$self->directories});
		return $ret;
	}

	has 'snipified' => (
		isa      => 'HashRef',
		is       => 'rw',
		lazy_build => 1,
	);
	method _build_snipified {
		my $input = $self->input;
		my $snips = $self->snippets;
		foreach my $slide (@{ $input->{slides} }) {
			foreach my $sec (@{ $slide->{sections} }) {
				if ($sec->{type} eq 'snippet') {
					die "Missing snippet $sec->{name}" if not $snips->{$sec->{name}};
					$sec->{html} = $snips->{$sec->{name}};
				}
			}
		}
		return $input;
	}
	
}
