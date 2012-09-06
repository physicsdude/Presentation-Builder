use MooseX::Declare;
use Method::Signatures::Modifiers;
class Presentation::Builder::Slide::Section {
	use Presentation::Builder::Types;
	has 'type' => (
		isa      => 'Str',
		is       => 'ro',
		required => 1,
	);
	has 'location' => (
		isa      => 'Str',
		is       => 'ro',
		default  => 'slide_left',
	);
	has 'html' => (
		isa      => 'Str',
		is       => 'rw',
	);
	method content {
		return "<div class='section ".$self->location."'>\n".$self->html."\n</div>";
	}
}

class Presentation::Builder::Slide::Section::Raw 
	extends Presentation::Builder::Slide::Section {
		# just pass html: in your yaml
}

class Presentation::Builder::Slide::Section::List 
	extends Presentation::Builder::Slide::Section {
	has 'points' => (
		isa => 'ArrayRef|Undef',
		is  => 'ro',
	);
#<snip override>
	override content {
		$self->html("<ul>\n\t<li>".join("</li>\n\t<li>",@{$self->points})."</li>\n</ul>");
		return super();
	}
#</snip>
}

#<snip snippet class>
class Presentation::Builder::Slide::Section::Snippet 
	extends Presentation::Builder::Slide::Section {
		use Text::VimColor;
		override content {
			my $syntax = Text::VimColor->new(
   			string => $self->html,
   			filetype => 'perl',
			);
			$self->html("<div class='snippet'><pre>".$syntax->html."</pre></div>");
			return super();
		}
}
#</snip snippet class>
