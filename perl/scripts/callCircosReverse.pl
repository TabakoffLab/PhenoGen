#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use File::Copy;
use Sys::Hostname;

require 'prepCircosReverse.pl';
require 'postprocessCircosReverse.pl';



sub setupDirectories{
	# Check if these directories exist.
	# If they don't exist, create them.
	# To do: handle pre-existing files better
	my($baseDirectory,$confDirectory,$dataDirectory,$svgDirectory)=@_;

	unless(-d $baseDirectory)
	{
		print " Creating base directory $baseDirectory \n";
		mkdir "$baseDirectory", 0777  || die(" Cannot create directory $baseDirectory $! \n");
	}
	unless(-d $confDirectory)
	{
		print " Creating conf directory $confDirectory \n"; 
		mkdir "$confDirectory", 0777  || die(" Cannot create directory $confDirectory $! \n");
	}
	unless(-d $dataDirectory)
	{
		print " Creating data directory $dataDirectory \n"; 
		mkdir "$dataDirectory", 0777  || die(" Cannot create directory $dataDirectory $! \n");
	}
	unless( -d $svgDirectory )
	{
		print " Creating svg directory $svgDirectory \n"; 
		mkdir "$svgDirectory", 0777 || die(" Cannot create directory $svgDirectory $! \n");
	}
}



sub callCircosReverse{
	my($cutoff,$organism,$geneCentricPath)=@_;
	#
	# General outline of process:
	# First, prep circos conf and data files
	# Second, call circos
	# Third, massage the svg output file created by circos
	#
	my $cutoffString = sprintf "%d", $cutoff*10;
	my $baseDirectory = $geneCentricPath.'/circos'.$cutoffString.'/';
	my $inputFileName = $geneCentricPath.'/TranscriptClusterDetails.txt';
	print " base directory $baseDirectory \n";
	my $dataDirectory = $baseDirectory.'data/';
	print " data directory $dataDirectory \n";
	my $svgDirectory = $baseDirectory.'svg/';
	print " svg directory $svgDirectory \n";
	my $confDirectory = $baseDirectory.'conf/';
	print " conf directory $confDirectory \n";

	my $chromosomeString;
	if($organism eq 'Rn'){
		$chromosomeString = "rn1;rn2;rn3;rn4;rn5;rn6;rn7;rn8;rn9;rn10;rn11;rn12;rn13;rn14;rn15;rn16;rn17;rn18;rn19;rn20;rnX";
	}
	else
	{
		$chromosomeString = "mm1;mm2;mm3;mm4;mm5;mm6;mm7;mm8;mm9;mm10;mm11;mm12;mm13;mm14;mm15;mm16;mm17;mm18;mm19;mmX";
	}
	my $tissue='All';
	#
	# Create necessary directories if they do not already exist
	#	
	setupDirectories($baseDirectory,$dataDirectory,$confDirectory,$svgDirectory);
	my @chromosomeList = split(/;/, $chromosomeString);
	my $chromosomeListRef = (\@chromosomeList);
	my $hostname = hostname;
	print " Ready to call prepCircos \n";
	prepCircosReverse($inputFileName,$cutoff,$organism,$confDirectory,$dataDirectory,$chromosomeListRef,$tissue,$hostname);
	print " Finished prepCircos \n";	

	#-- get current directory
	my $pwd = getcwd();
	print " Current directory is $pwd \n";
 
	#-- change dir to svg directory
	chdir($svgDirectory);
	my $newpwd = getcwd();
	print " New directory is $newpwd \n";
	
	print " Calling Circos \n";

	my $circosBinary;
	my $perlBinary;

	if($hostname eq 'amc-kenny.ucdenver.pvt'){
		$circosBinary = '/usr/local/circos-0.62-1/bin/circos';
		$perlBinary = '/usr/bin/perl';
	}
	elsif($hostname eq 'compbio.ucdenver.edu'){
		$circosBinary = '/usr/local/circos-0.62-1/bin/circos';
		$perlBinary = '/usr/local/bin/perl';
	}
	elsif($hostname eq 'phenogen.ucdenver.edu'){
		$circosBinary = '/usr/local/circos-0.62-1/bin/circos';
		$perlBinary = '/usr/local/bin/perl';
	}
	elsif($hostname eq 'stan.ucdenver.pvt'){
		$circosBinary = '/usr/local/circos-0.62-1/bin/circos';
		$perlBinary = '/usr/local/bin/perl';
	}
	else{
		die("Unrecognized Hostname:",$hostname,"\n");
	}
	
    my @systemArgs = ($perlBinary,$circosBinary, "-conf", $confDirectory."circos.conf");

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

	#-- go back to original directory
	chdir($pwd);

	print " Finished running Circos \n";
	
	

	print " Ready to call postprocessCircos \n";
	postprocessCircosReverse($cutoff,$organism,$dataDirectory,$svgDirectory,$hostname);
	print " Finished with Circos \n";
}

	my $arg1 = $ARGV[0]; # Cutoff
	my $arg2 = $ARGV[1]; # Organism
	my $arg3 = $ARGV[2]; #	Region Centric Path

	callCircosReverse($arg1, $arg2, $arg3);



1;


