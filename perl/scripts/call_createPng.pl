#!/usr/bin/perl
use File::Basename qw(fileparse);
use WWW::Mechanize;
use strict;
my $m = WWW::Mechanize->new();

require 'createPng.pl';

# get Image calls createPNG it should increment the timeout time if the first request fails and try again up to 3 times starting with a 30s timeout +30s/failure.
# it returns the result code allowing the main method to get the result code and url for the last attempt. Either the first successful attempt or last of 3 failed attempts.
sub getImage{
    my ($species,$chr,$minCoord,$maxCoord,$outputFileName,$trackFileName,$lblWidth,$urlFile)=@_;
    my $newresultCode=0;
    my $tryCount=0;
    my $resultCode="";
    while($newresultCode!=200 and $tryCount<3){
	eval{
	    $resultCode=createPngRNA($species, "chr".uc($chr).":$minCoord-$maxCoord", "chr".uc($chr), $minCoord, $maxCoord, $outputFileName,$trackFileName,(30+30*$tryCount),950,$lblWidth,8);
	    print "RESULT CODE2:$resultCode\n";
	    $newresultCode=substr($resultCode,0,index($resultCode,"<>"));
	    1;
	}or do{
	    $newresultCode=0;
	};
	$tryCount=$tryCount+1;
    }
    open URLFILE, ">".$urlFile;
    print URLFILE "$chr:$minCoord-$maxCoord\n";
    my $url=substr($resultCode,index($resultCode,"<>")+2);
    print URLFILE "$url\n";
    close URLFILE;
    return $resultCode;
}


	my $species = $ARGV[0]; # ucsc file path
	my $chr = $ARGV[1]; # output directory path
	my $minCoord = $ARGV[2]; #xml file name
	my $maxCoord = $ARGV[3]; #species
	my $pngFile = $ARGV[4]; #annotation level
	my $trackFile = $ARGV[5]; #Gene name list
	my $lblWidth=$ARGV[6];
	my $urlFile=$ARGV[7];
	getImage($species,$chr,$minCoord,$maxCoord,$pngFile,$trackFile,$lblWidth,$urlFile);
1;
