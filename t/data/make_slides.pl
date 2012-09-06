#!/usr/bin/perl
use warnings;
use strict;

while (<>) {
	chomp;
	my $image = $_;
	my $name = $image;
	$name =~ s/image\///;
	$name =~ s/[^A-Za-z0-9]/ /;
	print 
	 "\t- title: $name\n"
	."\t\tbackground: $image\n"
	."\t\tsections:\n"
	."\t\t\t- type: list\n"
	."\t\t\t\tpoints:\n"
	."\t\t\t\t\t- .\n";

}
