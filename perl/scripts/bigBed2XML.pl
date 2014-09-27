#!/usr/bin/perl

use strict;
use Time::HiRes;
require 'bed2XML.pl';

sub bigBed2XML
{
	#Reads a bed formatted file and outputs an xml file for the GenomeDataBrowser
	#Can read extended bed files will output extended fields to xml to be handled by javascript
	#

	# Read in the arguments for the subroutine	
	my($inputURL,$outputFile,$regionStart,$regionStop,$regionChr)=@_;
        
	print "$inputURL\n$outputFile\n$regionStart\n$regionStop\n$regionChr\n";
	my $track=substr($outputFile,rindex($outputFile,"/")+1);
        my $tempOutputFile="../../tmpData/tmpDownload/".time()."_".$track;
        print "\n\n$tempOutputFile\n\n";
        my @systemArgs = ("../../bedFiles/bigBedToBed","-chrom=$regionChr", "-start=$regionStart","-end=$regionStop", $inputURL,$tempOutputFile);
        print " System call with these arguments: @systemArgs \n";
        system(@systemArgs);
        if ( $? == -1 )
	{
  		print "System Call failed: $!\n";
	}
	else
	{
  		printf "System Call exited with value %d", $? >> 8;
	}
        
        bed2XML($tempOutputFile,$outputFile,-1,-1,"");
        
}

	my $arg1 = $ARGV[0]; # input file
	my $arg2 = $ARGV[1];# output file
	my $arg3 = -1;
	my $arg4 = -1;
	my $arg5 = "chr*";
	if(@ARGV>4){
	    $arg3=$ARGV[2];
	    $arg4=$ARGV[3];
	    $arg5=$ARGV[4];
	}
	bigBed2XML($arg1, $arg2,$arg3,$arg4,$arg5);

1;