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
#s+ The (Str :$title) above is an example of a method signature
#s+ The : means that you can call this like $pb->slides->add(title => $some_title);
#s+ use Method::Signatures::Modifiers; - slight speed boost + better error messages
#s+ If you mean to do Str :$title above, and forget the :, here's the error you get with MSM
#s   if you call it like $pb->slides->add(title => 'Flouridated water, communists and YOU!');
#s+ In call to Presentation::Builder::Slides::add(), was given too many arguments, it expects 1 at bdg.pl line 14.
#</snip colon method signatures>
#<snip colon method signatures 2>
#s+ BUT if you don't use MSM, here's the error you get when you call $pb->slides->add(title => 'foo');
#s Validation failed for 'Tuple[Tuple[Object,Str],Dict[]]' with value "[ [ Presentation::Builder::Slides=HASH(0x7ff8e10289b0), "title", "foo" ], {  } ], Internal Validation Error is: \n [+] Validation failed for 'Tuple[Object,Str]' with value "[ Presentation::Builder::Slides{ type: "S5" }, "title", "foo" ]"\n  [+] More values than Type Constraints!" at /Library/Perl/5.12/MooseX/Method/Signatures/Meta/Method.pm line 435.
#s MooseX::Method::Signatures::Meta::Method::validate('MooseX::Method::Signatures::Meta::Method=HASH(0x7ff8e2a27b78)', 'ARRAY(0x7ff8e289f388)') called at /Library/Perl/5.12/MooseX/Method/Signatures/Meta/Method.pm line 151
#s Presentation::Builder::Slides::add('Presentation::Builder::Slides=HASH(0x7ff8e10289b0)', 'title', 'foo') called at bdg.pl line 14
#s+ Make sure to RTFM, not exactly the same as MooseX::Method::Signatures (but you probably don't care)
#s+ It uses Data::Accessor, which uses XS (and didn't want to install on my system)
#</snip colon method signatures 2>
#<snip Moose::Autobox>
				my $s_pkg  = "Presentation::Builder::Slide::".$self->type;
				$self->list->push($s_pkg->new(title => $title, sections => $sections, background => $background));
#s+ Thanks to Moose::Autobox, you can do things like this
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
