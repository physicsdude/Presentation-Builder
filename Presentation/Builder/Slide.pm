use MooseX::Declare;
use Method::Signatures::Modifiers;
class Presentation::Builder::Slide {
	use Presentation::Builder::Slide::Section;
	use Presentation::Builder::Types;
#<snip coercions and type constraints for objects>
	use Moose::Util::TypeConstraints;
	subtype 'MySections',
	as 'ArrayRef[Presentation::Builder::Slide::Section]';
	coerce 'MySections',
	from 'ArrayRef',
	via { _coerce_mysections($_) };
	sub _coerce_mysections {
		return [ map {
				my $s_pkg = "Presentation::Builder::Slide::Section::" . ucfirst($_->{type}); 
				$s_pkg->new($_);
			} @{$_} ];
	}
	has 'sections' => (
		isa      => 'Undef|MySections', is       => 'rw',
		default  => sub { [] },   coerce   => 1,
	);
#</snip coercions and type constraints for objects>

	has 'title' => (
		isa      => 'Str',
		is       => 'rw',
		required => 1,
	);
	has 'background' => (
		isa      => 'Undef|ImageFile',
		is       => 'rw',
	);
	has 'dom' => (
		isa      => 'Mojo::DOM',
		is       => 'rw',
		lazy_build => 1,
	);
	method _build_dom {
		return Mojo::DOM->new();
	}
#<snip class_type usage>
	method add_html(Str :$html) {
		$self->dom->append_content($html);
	}
#</snip class_type usage>

	has 'content' => (
		isa      => 'Str',
		is       => 'rw',
		lazy_build => 1,
	);
	method _build_content {
		if ($self->sections) {
			foreach my $s ( @{$self->sections} ) {
				$self->add_html(html => $s->content);
			}
		}
		return "<h1>".$self->title."</h1>\n"
						.$self->dom();
	}
}

class Presentation::Builder::Slide::S5 
	extends Presentation::Builder::Slide {
	has 'handout' => (
		isa      => 'Str',
		is       => 'rw',
	);
#<snip around>
	around content {
		my $str;
		$str .= "\n<div class='slide'>\n";
		# This is a hack to make S5 see the slide title, the h1 has to be first apparently
		if ( $self->background ) {
			$str .= "<h1 style='display: none'>".$self->title."</h1>";
			$str .= "<div style='float: right;'><img class='slide_background_img' src='".$self->background."'></div>";
		}
		$str .= $self->$orig(@_);
		$str .= "\n</div>\n";
		return $str;
	}
#</snip around>
}
