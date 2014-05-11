#!/usr/bin/perl

use XML::LibXML;
use XML::Simple;
use Math::Round qw(:all);
use DBI;

use strict;
require 'ReadAffyProbesetDataFromDB.pl';
require 'readRNAIsoformDataFromDB.pl';
require 'readQTLDataFromDB.pl';
require 'readSNPDataFromDB.pl';
require 'readSpliceJunctFromDB.pl';
require 'readSmallNCDataFromDB.pl';
require 'readRefSeqDataFromDB.pl';
require 'readEnsemblSeqFromDB.pl';
require 'createXMLTrack.pl';

sub createBinnedData{
	my($refRNA,$bin,$start,$stop)=@_;
	print "Bin Data:$bin\n";
	print "Start:$start\tStop:$stop\n";
	my %fullRNA=%$refRNA;
	my %binHOH;
	my $curStart=$start;
	my $curStop=$bin+$start;
	my $binInd=0;
	my $curIndex=0;
	my $bp90=$bin-($bin*.9);
	while($curStart<$stop){
		#print "binning\t$curStart\t$curStop\t$binInd\n";
		my %countHOH;
		my $curPos=$curStart;
		my $loopCount=0;
		while($curPos<$curStop and $loopCount<$bin){
			my $segStart=$fullRNA{Count}[$curIndex]{start};
			my $segStop=$fullRNA{Count}[$curIndex]{stop};
			my $segValue=nearest(.01,$fullRNA{Count}[$curIndex]{logcount});
			#print $segStart."-".$segStop.":".$segValue."\n";
			my $bp=0;
			my $skipCur=0;
			if($segStart==$curPos){
				#print "seg == curPos\n";
				if($segStop<=$curStop){
					$bp=$segStop-$segStart+1;
					$curPos=$segStop+1;
				}else{
					$bp=$curStop-$segStart;
					$curPos=$curStop;
					$curIndex--;
					$skipCur=1;
				}
			}elsif($segStart>$curPos){
				#print "seg >curPos\n";
				if($segStart<$curStop){
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
				}else{
					$bp=$curStop-$curPos;
					if(exists $countHOH{0}){
						$countHOH{0}=$countHOH{0}+$bp;
					}else{
						$countHOH{0}=$bp;
					}
					$curPos=$curStop;
					$curIndex--;
					$skipCur=1;
				}
			}elsif($segStart<$curPos){
				#print "seg < curPos\n";
				if($segStop<=$curStop){
					$bp=$segStop-$curPos+1;
					$curPos=$segStop+1;
				}else{
					$bp=$curStop-$curPos;
					$curPos=$curStop;
					$curIndex--;
				}
			}
			if($skipCur==0){
				if(exists $countHOH{$segValue}){
					$countHOH{$segValue}=$countHOH{$segValue}+$bp;
				}else{
					$countHOH{$segValue}=$bp;
				}
			}
			$curIndex++;
			$loopCount++;
		}
		
		#find 90th percentile
		my @valueList=keys %countHOH;
		my @sortVal=sort {$b <=> $a} @valueList;
		#foreach my $tmpVal(@sortVal){
		#	print "Vallist:$tmpVal\n";
		#}
		my $curBP=0;
		my $valInd=0;
		while($valInd<@sortVal and $curBP<$bp90){
			my $bp=$countHOH{$sortVal[$valInd]};
			$curBP=$curBP+$bp;
			#print "comp90\t val[$valInd]=".$sortVal[$valInd]."\t current bp=".$bp."\t total bp=$curBP\n";
			$valInd++;
		}
		my $binVal=$sortVal[$valInd-1];
		#print "$binInd\t$curStart\t$binVal\n";
		if($binInd>0 and $binHOH{Count}[$binInd-1]{logcount}==$binVal){
			#skip since its the same value.
			$binHOH{Count}[$binInd-1]{start}=$binHOH{Count}[$binInd-1]{start}+$bin;
		}else{
			$binHOH{Count}[$binInd]{start}=$curStart;
			$binHOH{Count}[$binInd]{logcount}=$binVal;
			$binInd++;
			$binHOH{Count}[$binInd]{start}=$curStart+$bin-1;
			$binHOH{Count}[$binInd]{logcount}=$binVal;
			$binInd++;
		}
		$curStart=$curStop;
		$curStop=$bin+$curStart;
	}
	#fill in
	
	return \%binHOH;
}

sub createXMLFile
{
	# Read in the arguments for the subroutine	
	my($outputDir,$species,$type,$chromosome,$minCoord,$maxCoord,$publicID,$binSize,$tissue,$dsn,$usr,$passwd,$ensDsn,$ensUsr,$ensPasswd)=@_;
	
	my $scriptStart=time();
	if(index($type,"illumina")>-1 or index($type,"helicos")>-1 ){
		unlink $outputDir."bincount.".$binSize.".".$type.".xml";
		my $rnaCountStart=time();
		if(index($chromosome,"chr")>-1){
			$chromosome=substr($chromosome,3);
		}
		my $roundMin=$minCoord;
		my $roundMax=$maxCoord;
		if($binSize>0){
			$roundMin=$minCoord-($minCoord % $binSize);
			$roundMax=$maxCoord+($binSize-($maxCoord % $binSize));
		}
		#print ("min:$minCoord\nmax:$maxCoord\nroundMin:$roundMin\nroundMax:$roundMax\n");
		my $rnaCountRef=readRNACountsDataFromDB($chromosome,$species,$publicID,'BNLX/SHRH',$type,$roundMin,$roundMax,$dsn,$usr,$passwd);
		my %rnaCountHOH=%$rnaCountRef;
		my $rnaCountEnd=time();
		print "RNA Count completed in ".($rnaCountEnd-$rnaCountStart)." sec.\n";	
		my $trackDB="mm10";
		if($species eq 'Rat'){
			$trackDB="rn5";
		}
		if($binSize>0){
			my $ref=createBinnedData(\%rnaCountHOH,$binSize,$roundMin,$roundMax);
			my %rnaBinned=%$ref;
			createRNACountXMLTrack(\%rnaBinned,$outputDir."bincount.".$binSize.".".$type.".xml");
		}
		createRNACountXMLTrack(\%rnaCountHOH,$outputDir."count".$type.".xml");
	}elsif(index($type,"snp")>-1){
		my $rnaCountStart=time();
		if(index($chromosome,"chr")>-1){
			$chromosome=substr($chromosome,3);
		}
		my $rnaCountRef=readSNPDataFromDB($chromosome,$species,$minCoord,$maxCoord,$dsn,$usr,$passwd);
		my %rnaCountHOH=%$rnaCountRef;
		my $rnaCountEnd=time();
		print "RNA Count completed in ".($rnaCountEnd-$rnaCountStart)." sec.\n";	
		my $trackDB="mm10";
		if($species eq 'Rat'){
			$trackDB="rn5";
		}
		#print "track:".$outputDir;
		#my $output=$outputDir.$type.".xml";
		createSNPXMLTrack(\%rnaCountHOH,$outputDir,$trackDB);
	}elsif(index($type,"refSeq")>-1){
		my $rnaCountStart=time();
		if(index($chromosome,"chr")>-1){
			$chromosome=substr($chromosome,3);
		}
		my $refSeqRef=readRefSeqDataFromDB($chromosome,$species,$minCoord,$maxCoord,$ensDsn,$ensUsr,$ensPasswd);
		my %refSeqHOH=%$refSeqRef;
		my $rnaCountEnd=time();
		print "Ref Seq completed in ".($rnaCountEnd-$rnaCountStart)." sec.\n";	
		my $trackDB="mm10";
		if($species eq 'Rat'){
			$trackDB="rn5";
		}
		createRefSeqXMLTrack(\%refSeqHOH,$outputDir.$type.".xml",$trackDB);
	}elsif(index($type,"genomeSeq")>-1){
		my $rnaCountStart=time();
		if(index($chromosome,"chr")>-1){
			$chromosome=substr($chromosome,3);
		}
		my $seq=readEnsemblSeqFromDB($chromosome,$species,$minCoord,$maxCoord,$ensDsn,$ensUsr,$ensPasswd);
		open OUT,">".$outputDir.$minCoord."_".$maxCoord.".seq";
		print OUT $seq;
		close OUT;
	}elsif(index($type,"spliceJnct")>-1){
		my $rnaCountStart=time();
		if(index($chromosome,"chr")>-1){
			$chromosome=substr($chromosome,3);
		}
		my $spliceRef=readSpliceJunctFromDB($chromosome,$species,$minCoord,$maxCoord,$publicID,'BNLX/SHRH',$tissue,$dsn,$usr,$passwd);
		my %spliceHOH=%$spliceRef;
		my $rnaCountEnd=time();
		print "Splice Junction completed in ".($rnaCountEnd-$rnaCountStart)." sec.\n";	
		my $trackDB="mm10";
		if($species eq 'Rat'){
			$trackDB="rn5";
		}
		createGenericXMLTrack(\%spliceHOH,$outputDir.$type.".xml");
	}
	my $scriptEnd=time();
	print " script completed in ".($scriptEnd-$scriptStart)." sec.\n";
	return 1;
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
	my $arg11=$ARGV[10];
	my $arg12=$ARGV[11];
	my $arg13=$ARGV[12];
	my $arg14=$ARGV[13];
	my $arg15=$ARGV[14];

	createXMLFile($arg1, $arg2, $arg3, $arg4, $arg5, $arg6, $arg7, $arg8, $arg9,$arg10,$arg11,$arg12,$arg13,$arg14,$arg15);

1;