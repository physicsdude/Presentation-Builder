#!/usr/bin/perl
use Modern::Perl;
use lib '../';
<snip how to use presentation builder>
use Presentation::Builder;
my $pb = Presentation::Builder->new(
	input_file    => "data/test-input.yaml", 
	template_file => "data/index.base.html",
	output_file   => "data/index.html",
);
$pb->generate();
</snip>
