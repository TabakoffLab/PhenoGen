#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use File::Copy;
use Sys::Hostname;

require 'prepCircosModule.pl';
require 'readModuleData.pl';
require 'postprocessCircosModule.pl';

sub setupDirectories{
	# Check if these directories exist.
	# If they don't exist, create them.
	# To do: handle pre-existing files better
	my($baseDirectory,$confDirectory,$dataDirectory,$svgDirectory)=@_;

	unless(-d $baseDirectory)
	{
		#print " Creating base directory $baseDirectory \n";
		mkdir "$baseDirectory", 0777  || die(" Cannot create directory $baseDirectory $! \n");
	}
	unless(-d $confDirectory)
	{
		#print " Creating conf directory $confDirectory \n"; 
		mkdir "$confDirectory", 0777  || die(" Cannot create directory $confDirectory $! \n");
	}
	unless(-d $dataDirectory)
	{
		#print " Creating data directory $dataDirectory \n"; 
		mkdir "$dataDirectory", 0777  || die(" Cannot create directory $dataDirectory $! \n");
	}
	unless( -d $svgDirectory )
	{
		#print " Creating svg directory $svgDirectory \n"; 
		mkdir "$svgDirectory", 0777 || die(" Cannot create directory $svgDirectory $! \n");
	}
}



sub callCircosMod{
	my($module,$cutoff,$organism,$chromosomeString,$tissueString,$modulePath,$timeStampString,$modColor,$dsn,$usr,$passwd)=@_;
        print "in callCircosMod() path:$modulePath\n";


        print $module."\n".$cutoff."\n".$organism."\n".$chromosomeString."\ntissue:".$tissueString."\n".$modulePath."\ntime:".$timeStampString."\n".$modColor."\ndsn:".$dsn."\n".$usr."\npass:".$passwd."\n";

	#
	# General outline of process:
	# First, prep circos conf and data files
	# Second, call circos
	# Third, massage the svg output file created by circos
	#
	my $hostname = hostname;
	#print " host name $hostname \n";
	#create mainDir
	unless(-d $modulePath)
	{
		#print " Creating base directory $modulePath \n";
		mkdir "$modulePath", 0777  || die(" Cannot create directory $modulePath $! \n");
	}
	
	my $baseDirectory = $modulePath.$module."_".$timeStampString.'/';
	#print " base directory $baseDirectory \n";
	my $dataDirectory = $baseDirectory.'data/';
	my $svgDirectory = $baseDirectory.'svg/';
	my $confDirectory = $baseDirectory.'conf/';
	#print " svg directory $svgDirectory \n";
	
	
	#print "Tissue String $tissueString \n";

	
	#print "Module:$module\n";
	#print "cutoff:$cutoff\n";
	#print "organism:$organism\n";
	#print "chrstr:$chromosomeString\n";
	#print "modulePath:$modulePath\n";
	#print "timestamp:$timeStampString\n";
	#print "tissue:$tissueString\n";
	
	#
	# Create necessary directories if they do not already exist
	#
	setupDirectories($baseDirectory,$dataDirectory,$confDirectory,$svgDirectory);
	my @chromosomeList = split(/;/, $chromosomeString);
	my $chromosomeListRef = (\@chromosomeList);
	print " Ready to call prepCircos \n";
	prepCircosMod($module,$cutoff,$organism,$confDirectory,$dataDirectory,$chromosomeListRef,$tissueString,$hostname,$dsn,$usr,$passwd);
	print " Finished prepCircos \n";	
	

	#
	#-- get current directory
	my $pwd = getcwd();
	#print " Current directory is $pwd \n";
 
	#-- change dir to svg directory
	chdir($svgDirectory);
	my $newpwd = getcwd();
	#print " New directory is $newpwd \n";
	
	
	print " Calling Circos \n";

	my $circosBinary;
	my $perlBinary;
	my $inkscapeBinary;
	my $inkscapeDirectory;

	if($hostname eq 'phenogen'){
		$circosBinary = '/usr/local/circos-0.68/bin/circos';
		$perlBinary = '/usr/bin/perl';
		$inkscapeBinary = '/usr/bin/inkscape';
	}
	elsif($hostname eq 'stan.ucdenver.pvt'){
		$circosBinary = '/usr/local/circos-0.68/bin/circos';
		$perlBinary = '/usr/bin/perl';
		$inkscapeBinary = '/Applications/Inkscape.app/Contents/Resources/bin/inkscape';
	}
	else{
		die("Unrecognized Hostname:",$hostname,"\n");
	}


	
    my @systemArgs = ($perlBinary,$circosBinary,"-silent","-conf", $confDirectory."circos.conf", "-noparanoid");
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
	postprocessCircosMod($module,$cutoff,$organism,$dataDirectory,$svgDirectory,$hostname,$tissueString,$modColor);
	print " Finished with Circos \n";
	

	#-- go back to original directory
	chdir($pwd);
}
#	my $arg1 = $ARGV[0]; # module
#	my $arg2 = $ARGV[1]; # cutoff
#	my $arg3 = $ARGV[2]; # organism
#	my $arg4 = $ARGV[3]; # chromosomes
#	my $arg5 = $ARGV[4]; # tissue
#	my $arg6 = $ARGV[5]; # module path
#	my $arg7 = $ARGV[6]; # timestamp
#	my $arg8 = $ARGV[7]; # module color
#	my $arg9= $ARGV[8]; # dsn
#	my $arg10= $ARGV[9]; # user
#	my $arg11= $ARGV[10]; # password
#	callCircosMod($arg1, $arg2, $arg3, $arg4, $arg5, $arg6, $arg7, $arg8, $arg9, $arg10,$arg11);

1;
