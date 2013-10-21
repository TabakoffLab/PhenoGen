#!/usr/bin/perl

use XML::LibXML;
use XML::Simple;


use strict;
require 'ReadAffyProbesetDataFromDB.pl';
require 'readRNAIsoformDataFromDB.pl';
require 'readQTLDataFromDB.pl';
require 'readSNPDataFromDB.pl';
require 'readSmallNCDataFromDB.pl';
require 'createXMLTrack.pl';

sub createBinnedData{
	my($refRNA,$bin,$start,$stop)=@_;
	my %fullRNA=%$refRNA;
	my %binHOH;
	my $curStart=$start;
	my $curStop=$bin+$start;
	my $binInd=0;
	my $curIndex=0;
	while($curStart<$stop  and $binInd<2){
		print "binning\t$curStart\t$curStop\t$binInd\n";
		my %countHOH={};
		my $curPos=$curStart;
		my $loopCount=0;
		while($curPos<$curStop and $loopCount<$bin){
			my $segStart=$fullRNA{Count}[$curIndex]{start};
			my $segStop=$fullRNA{Count}[$curIndex]{stop};
			my $segValue=$fullRNA{Count}[$curIndex]{logCount};
			print $segStart."-".$segStop.":".$segValue."\n";
			my $bp=0;
			if($segStart==$curPos){
				if($segStop<=$curStop){
					$bp=$segStop-$segStart+1;
					$curPos=$segStop+1;
				}else{
					$bp=$curStop-$segStart;
					$curPos=$curStop;
					$curIndex--;
				}
			}elsif($segStart>$curPos){
				$bp=$curPos-$segStart;
				if(exists $countHOH{0}){
					$countHOH{0}=$countHOH{0}+$bp;
				}else{
					$countHOH{0}=$bp;
				}
				$curPos=$segStart;
				if($segStop<=$curStop){
					$bp=$segStop-$segStart+1;
					$curPos=$segStop+1;
				}else{
					$bp=$curStop-$segStart;
					$curPos=$curStop;
					$curIndex--;
				}
			}elsif($segStart<$curPos){
				if($segStop<=$curStop){
					$bp=$segStop-$curPos+1;
					$curPos=$segStop+1;
				}else{
					$bp=$curStop-$curPos;
					$curPos=$curStop;
					$curIndex--;
				}
			}
			if(exists $countHOH{$segValue}){
				$countHOH{$segValue}=$countHOH{$segValue}+$bp;
			}else{
				$countHOH{$segValue}=$bp;
			}
			$curIndex++;
			$loopCount++;
		}
		
		#find 90th percentile
		my @valueList=keys %countHOH;
		my @sortVal=sort {$b <=> $a} @valueList;
		my $bp90=$bin-($bin*.9);
		print "bp90:$bp90\n";
		my $curBP=0;
		my $valInd=0;
		while($curBP<$bp90){
			my $bp=$countHOH{$sortVal[$valInd]};
			$curBP=$curBP+$bp;
			print $valInd.":".$sortVal[$valInd].":".$bp."\t total: $curBP\n";
			$valInd++;
		}
		my $binVal=$sortVal[$valInd-1];
		print "$binInd\t$curStart\t$binVal\n";
		$binHOH{Count}[$binInd]{start}=$curStart;
		$binHOH{Count}[$binInd]{logcount}=$binVal;
		
		$binInd++;
		$curStart=$curStop;
		$curStop=$bin+$curStart;
	}
	return \%binHOH;
}

sub createXMLFile
{
	# Read in the arguments for the subroutine	
	my($outputDir,$species,$type,$chromosome,$minCoord,$maxCoord,$publicID,$dsn,$usr,$passwd)=@_;
	
	my $scriptStart=time();
	my $rnaCountStart=time();
	if(index($chromosome,"chr")>-1){
		$chromosome=substr($chromosome,3);
	}
	my $len=$maxCoord-$minCoord;
	my $binSize=0;
	if($len>100000 and $len<=1000000){
		$binSize=100;
	}elsif($len>1000000 and $len<=5000000){
		$binSize=250;
	}elsif($len>5000000 and $len<=10000000){
		$binSize=500;
	}elsif($len>10000000){
		$binSize=1000;
	}
	
	my $roundMin=$minCoord-($minCoord % $binSize);
	my $roundMax=$maxCoord+($binSize-($maxCoord % $binSize));
	print ("min:$minCoord\nmax:$maxCoord\nroundMin:$roundMin\nroundMax:$roundMax\n");
	my $rnaCountRef=readRNACountsDataFromDB($chromosome,$species,$publicID,'BNLX/SHRH',$type,$roundMin,$roundMax,$dsn,$usr,$passwd);
	my %rnaCountHOH=%$rnaCountRef;
	my $rnaCountEnd=time();
	print "RNA Count completed in ".($rnaCountEnd-$rnaCountStart)." sec.\n";	
	my $trackDB="mm9";
	if($species eq 'Rat'){
		$trackDB="rn5";
	}
	if($len>100000){
		my $ref=createBinnedData(\%rnaCountHOH,$binSize,$roundMin,$roundMax);
		my %rnaBinned=%$ref;
		createRNACountXMLTrack(\%rnaBinned,$outputDir."bincount".$type.".xml");
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

