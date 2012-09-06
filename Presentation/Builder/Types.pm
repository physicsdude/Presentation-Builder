use MooseX::Declare;
use Method::Signatures::Modifiers;
class Presentation::Builder::Types {
	use Moose::Util::TypeConstraints;

	subtype 'File',
	as 'Str',
	where { return 1 if -e $_ };

	subtype 'ConfigFile',
	as 'File',
	where { /\.ya?ml$/i };

	subtype 'TemplateFile',
	as 'File',
	where { /\.html$/i };

	# one of these things is not like the other
	# Don't require this to be a valid image on build
	subtype 'ImageFile',
	as 'Str',
	where { /\.(jpg|png|gif|jpeg)$/i };

	coerce 'File',
	from 'Str',
	via { _coerce_file($_) };

	coerce 'TemplateFile',
	from 'Str',
	via { _coerce_file($_) };

#<snip coerce definition>
	coerce 'ConfigFile',
	from 'Str',
	via { _coerce_file($_) };

	sub _coerce_file {
		my $file_name = shift;
		foreach my $d ( @INC ) {
			my $full_path = "$d/$file_name";
			if ( -e "$d/$file_name" ) {
				return $full_path;
			}
		}
		return $file_name;
	}
#</snip>

#<snip class_type definition>
	class_type 'Mojo::DOM';
#</snip class_type definition>

  no Moose::Util::TypeConstraints;
}
