#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use File::Copy;
use Sys::Hostname;

require 'prepCircos.pl';
require 'readLocusSpecificPvalues.pl';
require 'postprocessCircos.pl';

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



sub callCircos{
	my($geneName,$geneSymbol,$probeID,$psLevel,$probeChromosome,$probeStart,$probeStop,$cutoff,$organism,$chromosomeString,$geneCentricPath,$timeStampString,$tissueString,$dsn,$usr,$passwd)=@_;
	#
	# General outline of process:
	# First, prep circos conf and data files
	# Second, call circos
	# Third, massage the svg output file created by circos
	#
	my $hostname = hostname;
	print " host name $hostname \n";
	my $baseDirectory = $geneCentricPath.$probeID."_".$timeStampString.'/';
	print " base directory $baseDirectory \n";
	my $dataDirectory = $baseDirectory.'data/';
	my $svgDirectory = $baseDirectory.'svg/';
	my $confDirectory = $baseDirectory.'conf/';
	print " svg directory $svgDirectory \n";
	print "Tissue String $tissueString \n";

	#
	# Create necessary directories if they do not already exist
	#
	setupDirectories($baseDirectory,$dataDirectory,$confDirectory,$svgDirectory);
	my @chromosomeList = split(/;/, $chromosomeString);
	my $chromosomeListRef = (\@chromosomeList);
	my @tissueList = split(/;/, $tissueString);
	my $tissueListRef = (\@tissueList);
	print " Ready to call prepCircos \n";
	prepCircos($geneName, $geneSymbol,$probeID, $psLevel,$probeChromosome,$probeStart,$probeStop,$cutoff,$organism,$confDirectory,$dataDirectory,$chromosomeListRef,$tissueListRef,$dsn,$usr,$passwd,$hostname);
	print " Finished prepCircos \n";	
	

	#
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
	my $inkscapeBinary;
	my $inkscapeDirectory;

	#if($hostname eq 'amc-kenny.ucdenver.pvt'){
	#	$circosBinary = '/usr/local/circos-0.62-1/bin/circos';
	#	$perlBinary = '/usr/bin/perl';
	#	$inkscapeBinary = '/Applications/Inkscape.app/Contents/Resources/bin/inkscape';
	#}
	#elsif($hostname eq 'compbio.ucdenver.edu'){
	#	$circosBinary = '/usr/local/circos-0.62-1/bin/circos';
	#	$perlBinary = '/usr/local/bin/perl';
	#	$inkscapeBinary = '/usr/bin/inkscape';
	#}
	#
        if($hostname eq 'phenogen'){
		$circosBinary = '/usr/local/circos-0.67-5/bin/circos';
		$perlBinary = '/usr/bin/perl';
		$inkscapeBinary = '/usr/bin/inkscape';
	}
	elsif($hostname eq 'stan.ucdenver.pvt'){
		$circosBinary = '/usr/local/circos-0.67-5/bin/circos';
		$perlBinary = '/usr/bin/perl';
		$inkscapeBinary = '/Applications/Inkscape.app/Contents/Resources/bin/inkscape';
	}
	else{
		die("Unrecognized Hostname:",$hostname,"\n");
	}


	
    my @systemArgs = ($perlBinary,$circosBinary, "-conf", $confDirectory."circos.conf", "-noparanoid");
    print " System call with these arguments: @systemArgs \n";
    system(@systemArgs);
    if ( $? == -1 )
	{
  		print "System Call failed: $!\n";
	}
	else
	{
                my $exitVal=$?;
                print "exited with $exitVal\n";
  		printf "System Call exited with value %d", $? >> 8;
                exit($exitVal);
	}

	#-- go back to original directory
	chdir($pwd);
	
	print " Finished running Circos \n";
	print " Ready to call postprocessCircos \n";
	postprocessCircos($geneName,$geneSymbol,$probeID,$psLevel,$probeChromosome,$probeStart,$probeStop,$cutoff,$organism,$dataDirectory,$svgDirectory,$hostname,$tissueListRef);
	print " Finished with Circos \n";
	
	#
	# Now convert circos_new.svg to circos_new.pdf
	#

	
	@systemArgs=($inkscapeBinary,'-z','-f',$svgDirectory."circos_new.svg",'-A',$svgDirectory."circos_new.pdf",'-b','rgb(255,255,255)','-i','notooltips','-j','-C');
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
        }
	my $arg1 = $ARGV[0]; # Ensembl Gene Name
	my $arg2 = $ARGV[1]; # Gene Symbol
	my $arg3 = $ARGV[2]; # Transcript Cluster ID
	my $arg4 = $ARGV[3]; # PS level - transcript or probeset
	my $arg5 = $ARGV[4]; # Transcript Cluster ID Chromosome
	my $arg6 = $ARGV[5]; # Transcript Cluster ID Start
	my $arg7 = $ARGV[6]; # Transcript Cluster ID Stop
	my $arg8 = $ARGV[7]; #	Cutoff
	my $arg9= $ARGV[8]; # Species
	my $arg10= $ARGV[9]; # Chromosome String
	my $arg11= $ARGV[10]; # geneCentricPath
	my $arg12=$ARGV[11]; #time stamp string 
	my $arg13=$ARGV[12]; #selected Tissue String
	my $arg14=$ARGV[13]; #dsn
	my $arg15=$ARGV[14]; #user
	my $arg16=$ARGV[15]; #password
	callCircos($arg1, $arg2, $arg3, $arg4, $arg5, $arg6, $arg7, $arg8, $arg9, $arg10, $arg11,$arg12,$arg13,$arg14,$arg15,$arg16);

1;