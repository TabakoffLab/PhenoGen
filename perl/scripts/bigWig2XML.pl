#!/usr/bin/perl

use strict;
require 'bedGraph2XML.pl';



sub bigWig2XML
{
	#Reads a bed formatted file and outputs an xml file for the GenomeDataBrowser
	#Can read extended bed files will output extended fields to xml to be handled by javascript
	#

	# Read in the arguments for the subroutine	
	my($inputURL,$outputFile,$regionStart,$regionStop,$regionChr,$binSize)=@_;
        
        my $tempOutputFile="../../tmpData/tmpDownload/";
        
        my @systemArgs = ("../../bedFiles/bigWigToBedGraph","-chrom=$regionChr", "-start=$regionStart","-end=$regionStop", $inputURL,$tempOutputFile);
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
        
        bedGraph2XML($tempOutputFile,$outputFile,-1,-1,"chr*",$binSize);
        
}

	my $arg1 = $ARGV[0]; # input file
	my $arg2 = $ARGV[1]; # output file
	my $arg3 = -1;
	my $arg4 = -1;
	my $arg5 = "chr*";
	my $arg6 = 0;
	if(@ARGV>5){
	    $arg3=$ARGV[2];
	    $arg4=$ARGV[3];
	    $arg5=$ARGV[4];
	    $arg6=$ARGV[5];
	}
	bigWig2XML($arg1, $arg2,$arg3,$arg4,$arg5,$arg6);

1;