use MooseX::Declare;
use Method::Signatures::Modifiers;
use Moose::Autobox;
use Modern::Perl;
class Presentation::Builder::Slides {
	use Presentation::Builder::Slide;
#<snip advanced isa>
	has 'list' => (
		isa => 'ArrayRef[Presentation::Builder::Slide]',
		is  => 'rw',
		default => sub { [] },
	);
#</snip advanced isa>
	has 'type' => (
		isa      => 'Str',
		is       => 'ro',
	);
	has 'data' => (
		isa        => 'HashRef',
		is         => 'ro',
		required   => 1,
	);
	has 'html' => (
		isa        => 'Str',
		is         => 'rw',
	);

	# Todo: support inserting in different locations, etc
#<snip colon method signatures>
	method add (Str :$title, ArrayRef :$sections, ImageFile :$background) {
#</snip colon method signatures>
#<snip Moose::Autobox>
				my $s_pkg  = "Presentation::Builder::Slide::".$self->type;
				$self->list->push($s_pkg->new(title => $title, sections => $sections, background => $background));
#</snip Moose::Autobox>
	}

	method collect {
		return if @{$self->list} > 0;
		foreach my $slide_in (@{ $self->data->{slides} }) {
			$self->add(%$slide_in);
		}
	}

	method content {
		return $self->html if $self->html;
		return $self->html(do{
			$self->collect();
			my $ret = "<div class='presentation'>\n";
			foreach my $s (@{$self->list}) {
				$ret .= $s->content()."\n";
			}
			$ret .= "\n</div>";
			$ret;
		});
	}
}
