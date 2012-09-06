use MooseX::Declare;
use Method::Signatures::Modifiers;
class Presentation::Builder::Template 
	{
	use File::Slurp;
	use Mojo::DOM;
	has 'template_file' => (
		isa      => 'TemplateFile',
		is       => 'ro',
		required => 1,
	);
	has 'dom' => (
		isa      => 'Mojo::DOM',
		is       => 'rw',
	);
}

class Presentation::Builder::Template::S5
	extends Presentation::Builder::Template {
	has 'dom' => (
		isa      => 'Mojo::DOM',
		is       => 'rw',
		lazy_build => 1,
	);
	method _build_dom {
		Mojo::DOM->new(scalar 
			File::Slurp::read_file($self->template_file));
	}
}

# Don't try to parse existing slides for now
#	has 'slides' => (
#		is => 'rw',
#		lazy_build => 1,
#	);
#	method _build_slides {
#		tie(my %slides, 'Tie::IxHash');
#		for my $e ($self->dom->find('div[class=slide]')->each) {
#			$slides{$e->find('h1')->first->text} = $e;
#		}
#		return \%slides;
#	}
