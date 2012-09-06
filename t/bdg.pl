#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use lib '../';
use Presentation::Builder;
use Presentation::Builder::Types;
use Presentation::Builder::Slide;
use Presentation::Builder::Slide::Section;
use Presentation::Builder::Template;

my $pb = Presentation::Builder->new(
	input_file    => "data/test-input.yaml", 
	template_file => "data/index.base.html",
	output_file   => "data/index.html",
#	template_file => 'test-template.html',
);

#print $pb->content();
$pb->generate();
