#!/usr/bin/perl
use Modern::Perl;
use Test::More;
use Test::Exception;
use Data::Dumper qw/Dumper/;
use lib '../';

use_ok('Presentation::Builder');
use_ok('Presentation::Builder::Types');
use_ok('Presentation::Builder::Slide');
use_ok('Presentation::Builder::Slide::Section');
use_ok('Presentation::Builder::Template');
use_ok('Presentation::Builder::Sources');

my $pbs;
lives_ok(
	sub { $pbs = Presentation::Builder::Sources->new(
			directories => ['../Presentation/'],
	) },
	"Can create new sources object"
);

ok(%{$pbs->snippets},"Got snippets");
 
foreach my $s ( keys %{$pbs->snippets} ) {
	diag($s);
}

ok(%{$pbs->files},"Got files");

ok($pbs->snippets->{'coerce definition'},"A snippet exists");

dies_ok(
	sub { Presentation::Builder->new(input_file => 'thisshouldfailsldkfjkdjf.yaml'); },
	"Calling with non-existent file fails"
);
dies_ok(
	sub { Presentation::Builder->new(input_file => $0); },
	"Calling with existing but non-yaml file fails"
);

my %pb_args = (
			input_file    => 'data/test-input.yaml', 
			template_file => 'data/index.base.html',
			output_file   => 'data/index.html',

);
my $pb;
lives_ok(
	sub { $pb = Presentation::Builder->new(
			%pb_args
	) },
	"Can call with input yaml file and template file"
);

lives_ok(sub { $pb->dom }, "Can call pb->dom, delegation works");

is($pb->data->{slides}[0]{title},'Dr. Strange... Moose',"First title matches");
is($pb->data->{slides}[1]{title},'WTF',"Second title matches");

is($pb->dom->at('html title')->text,'Test Title',"Got the original template title, we'll overwrite this");

lives_ok(sub { $pb->slides->collect() }, "Can call pb->slides->collect to collect presentation/slides");

lives_ok(sub { $pb->slides->add(title => 'test add slide externally') }, "Can add a slide externally");

is($pb->slides->list->[0]{title},'Dr. Strange... Moose',"First title matches");
is($pb->slides->list->[1]{title},'WTF',"Second title matches");
is($pb->slides->list->[-1]{title},'test add slide externally',"Last title matches");

my $slide_content;
lives_ok(sub { $slide_content = $pb->slides->list->[0]->content() }, "Can get a slide's content");
ok($slide_content,"Got first slide's content");
my $slide_content_again;
lives_ok(sub { $slide_content_again = $pb->slides->list->[0]->content() }, "Can get a slide's content again");
ok($slide_content_again,"Got first slide's content again");
is($slide_content, $slide_content_again,"Slide content remained the same on duplicate calls");

#diag($slide_content);

my $content;
lives_ok(sub { $content = $pb->slides->content() }, "Can get all slide content (the main presentation html)");
ok($content,"Got all slide content");

my $content_again;
lives_ok(sub { $content_again = $pb->slides->content() }, "Can get all slide content (the main presentation html, again)");
is($content,$content_again,"Slide content stays the same (no dupes created)");
#diag($content);
#diag(Dumper($pb->slides->list));

unlink $pb_args{output_file};
lives_ok(sub { $pb->generate() }, "Can generate the html");
ok(-e $pb_args{output_file},"The output file exists");

done_testing();
