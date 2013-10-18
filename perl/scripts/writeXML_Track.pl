#!/usr/bin/perl

use XML::LibXML;
use XML::Simple;
use DBI;

use strict;
require 'ReadAffyProbesetDataFromDB.pl';
require 'readRNAIsoformDataFromDB.pl';
require 'readQTLDataFromDB.pl';
require 'readSNPDataFromDB.pl';
require 'readSmallNCDataFromDB.pl';
require 'createXMLTrack.pl';



sub createXMLFile
{
	# Read in the arguments for the subroutine	
	my($outputDir,$species,$type,$chromosome,$minCoord,$maxCoord,$publicID,$dsn,$usr,$passwd)=@_;
	
	my $scriptStart=time();
	my $rnaCountStart=time();
	if(index($chromosome,"chr")>-1){
		$chromosome=substr($chromosome,3);
	}
	my $rnaCountRef=readRNACountsDataFromDB($chromosome,$species,$publicID,'BNLX/SHRH',$type,$minCoord,$maxCoord,$dsn,$usr,$passwd);
	my %rnaCountHOH=%$rnaCountRef;
	my $rnaCountEnd=time();
	print "RNA Count completed in ".($rnaCountEnd-$rnaCountStart)." sec.\n";	
	my $trackDB="mm9";
	if($species eq 'Rat'){
		$trackDB="rn5";
	}
	createRNACountXMLTrack(\%rnaCountHOH,$outputDir."count".$type.".xml");
	my $scriptEnd=time();
	print " script completed in ".($scriptEnd-$scriptStart)." sec.\n";
}
#
#	
	my $arg1 = $ARGV[0]; # output directory path
	my $arg2 = $ARGV[1]; #species
	my $arg3 = $ARGV[2]; 
	my $arg4 = $ARGV[3]; 
	my $arg5 = $ARGV[4]; 
	my $arg6 = $ARGV[5]; 
	my $arg7 = $ARGV[6]; 
	my $arg8 = $ARGV[7]; 
	my $arg9= $ARGV[8]; 
	my $arg10=$ARGV[9];
	createXMLFile($arg1, $arg2, $arg3, $arg4, $arg5, $arg6, $arg7, $arg8, $arg9,$arg10);

