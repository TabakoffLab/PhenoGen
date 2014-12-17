#!/usr/bin/perl
use strict;
use warnings;


require 'callCircosModule.pl';


	my $arg1 = $ARGV[0]; # module
	my $arg2 = $ARGV[1]; # cutoff
	my $arg3 = $ARGV[2]; # organism
	my $arg4 = $ARGV[3]; # chromosomes
	my $arg5 = $ARGV[4]; # tissue
	my $arg6 = $ARGV[5]; # module path
	my $arg7 = $ARGV[6]; # timestamp
	my $arg8 = $ARGV[7]; # module color
	my $arg9= $ARGV[8]; # dsn
	my $arg10= $ARGV[9]; # user
	my $arg11= $ARGV[10]; # password
	callCircosMod($arg1, $arg2, $arg3, $arg4, $arg5, $arg6, $arg7, $arg8, $arg9, $arg10,$arg11);

1;
