#!/usr/bin/perl

use XML::LibXML;
use XML::Simple;
use Math::Round qw(:all);
use DBI;

use strict;
require 'ReadAffyProbesetDataFromDB.pl';
require 'readRNAIsoformDataFromMongo.pl';
require 'readQTLDataFromDB.pl';
require 'readSNPDataFromMongo.pl';
require 'readSpliceJunctFromDB.pl';
require 'readSmallNCDataFromDB.pl';
require 'readRefSeqDataFromDB.pl';
require 'readEnsemblSeqFromDB.pl';
require 'createXMLTrack.pl';
require 'readRepeatMaskFromDB.pl';

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
			
			#my $segValue=nearest(.01,$fullRNA{Count}[$curIndex]{logcount});
			my $segValue=$fullRNA{Count}[$curIndex]{count};
			
			
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
		if ($binVal eq "") {
			$binVal=0;
		}
		
		#print "$binInd\t$curStart\t$binVal\n";
		if($binInd>0 and $binHOH{Count}[$binInd-1]{count}==$binVal){
			#skip since its the same value.
			$binHOH{Count}[$binInd-1]{start}=$binHOH{Count}[$binInd-1]{start}+$bin;
			$binHOH{Count}[$binInd-2]{stop}=$curStart+$bin-1;
			$binHOH{Count}[$binInd-1]{stop}=$curStart+$bin-1;
		}else{
			$binHOH{Count}[$binInd]{start}=$curStart;
			$binHOH{Count}[$binInd]{count}=$binVal;
			$binHOH{Count}[$binInd]{stop}=$curStart+$bin-1;
			$binInd++;
			$binHOH{Count}[$binInd]{start}=$curStart+$bin-1;
			$binHOH{Count}[$binInd]{count}=$binVal;
			$binHOH{Count}[$binInd]{stop}=$curStart+$bin-1;
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
	my($outputDir,$species,$type,$chromosome,$minCoord,$maxCoord,$publicID,$binSize,$tissue,$dsn,$usr,$passwd,$ensDsn,$ensUsr,$ensPasswd,$ucscDsn,$ucscUsr,$ucscPasswd,$mongoDsn,$mongoUser,$mongoPasswd)=@_;
	
	my $scriptStart=time();
	
	my $panel="ILS/ISS";
	if($species eq 'Rat' or $species eq 'Rn' ){
		$panel="BNLX/SHRH";
	}
	
	if(index($type,"illumina")>-1 or index($type,"helicos")>-1 ){
		unlink $outputDir."bincount.".$binSize.".".$type.".xml";
		my $rnaCountStart=time();
		if(index($chromosome,"chr")>-1){
			$chromosome=substr($chromosome,3);
		}
		my $roundMin=$minCoord;
		my $roundMax=$maxCoord;
		#if($binSize>0){
		#	$roundMin=$minCoord-($minCoord % $binSize);
		#	$roundMax=$maxCoord+($binSize-($maxCoord % $binSize));
		#}
		#print ("min:$minCoord\nmax:$maxCoord\nroundMin:$roundMin\nroundMax:$roundMax\n");
		
		my $rnaCountRef;

                $rnaCountRef=readRNACountsDataFromMongo($chromosome,$species,$publicID,$panel,$type,$roundMin,$roundMax,$dsn,$usr,$passwd,$mongoDsn,$mongoUser,$mongoPasswd);
		
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
			if(-d $outputDir."tmp"){
				
			}else{
				mkdir $outputDir."tmp";
			}
			createRNACountXMLTrack(\%rnaBinned,$outputDir."tmp/".$roundMin."_".$roundMax.".bincount.".$binSize.".".$type.".xml");
		}else{
                    if(-d $outputDir."tmp"){
				
                    }else{
                            mkdir $outputDir."tmp";
                    }
                    createRNAFullCountXMLTrack(\%rnaCountHOH,$outputDir."tmp/".$roundMin."_".$roundMax.".count.".$type.".xml");
                }
		#createRNACountXMLTrack(\%rnaCountHOH,$outputDir."count".$type.".xml");
	}elsif(index($type,"snp")>-1){
		my $rnaCountStart=time();
		if(index($chromosome,"chr")>-1){
			$chromosome=substr($chromosome,3);
		}
		my $rnaCountRef=readSNPDataFromDB('rn5',$chromosome,$species,$minCoord,$maxCoord,$dsn,$usr,$passwd);
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
		my $refSeqRef=readRefSeqDataFromDB($chromosome,$species,$minCoord,$maxCoord,$ucscDsn,$ucscUsr,$ucscPasswd);
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
                open OUT,">".$outputDir.$minCoord."_".$maxCoord.".seq";
		my $seq=readEnsemblSeqFromDB($chromosome,$species,$minCoord,$maxCoord,$ensDsn,$ensUsr,$ensPasswd);
		print OUT $seq;
		close OUT;
	}elsif(index($type,"spliceJnct")>-1){
		my $rnaCountStart=time();
		if(index($chromosome,"chr")>-1){
			$chromosome=substr($chromosome,3);
		}
		
		my $spliceRef=readSpliceJunctFromDB($chromosome,$species,$minCoord,$maxCoord,$publicID,$panel,$tissue,$dsn,$usr,$passwd);
		my %spliceHOH=%$spliceRef;
		my $rnaCountEnd=time();
		print "Splice Junction completed in ".($rnaCountEnd-$rnaCountStart)." sec.\n";	
		my $trackDB="mm10";
		if($species eq 'Rat'){
			$trackDB="rn5";
		}
		createGenericXMLTrack(\%spliceHOH,$outputDir.$type.".xml");
	}elsif(index($type,"repeatMask")>-1){
                my $rnaCountStart=time();
		if(index($chromosome,"chr")>-1){
			$chromosome=substr($chromosome,3);
		}
		my $repeatMaskRef=readRepeatMaskFromDB($chromosome,$species,$minCoord,$maxCoord,$ucscDsn,$ucscUsr,$ucscPasswd);
		my %repeatMaskHOH=%$repeatMaskRef;
		my $rnaCountEnd=time();
		print "RepeatMask completed in ".($rnaCountEnd-$rnaCountStart)." sec.\n";
        createGenericXMLTrack(\%repeatMaskHOH,$outputDir.$type.".xml");
    }elsif(index($type,"chainNet")>-1){

    }elsif(index($type,"liverTotal")>-1 or index($type,"heartTotal")>-1 or index($type,"braincoding")>-1 or index($type,"brainnoncoding")>-1){
                my $ver=substr($type,index($type,"_")+1);
                print "Type:$type\n";
                print "Ver:$ver\n";

		my $rnaCountStart=time();
		if(index($chromosome,"chr")>-1){
			$chromosome=substr($chromosome,3);
		}
                my ($probesetHOHRef) = readAffyProbesetDataFromDBwoProbes("chr".$chromosome,$minCoord,$maxCoord,22,$dsn,$usr,$passwd);
                my @probesetHOH = @$probesetHOHRef;

                my $snpRef=readSNPDataFromDB('rn5',$chromosome,$species,$minCoord,$maxCoord,$dsn,$usr,$passwd);
                my %snpHOH=%$snpRef;
                my @snpStrain=("BNLX","SHRH","SHRJ","F344");
                my $rnaType="totalRNA";
                if(index($type,"braincoding")>-1){
                    $rnaType="PolyA+";
                }elsif(index($type,"brainnoncoding")>-1){
                    $rnaType="NonPolyA+";
                }
		my $isoformHOH = readRNAIsoformDataFromDB($chromosome,$species,$publicID,'BNLX/SHRH',$minCoord,$maxCoord,$dsn,$usr,$passwd,1,$rnaType,$tissue,$ver);
                
                my %brainHOH=%$isoformHOH;
                my $regionSize=$maxCoord-$minCoord;

                my $cntProbesets=0;
                my $cntMatchingProbesets=0;

                #process RNA genes/transcripts and assign probesets.
                my $tmpGeneArray=$$isoformHOH{Gene};
                foreach my $tmpgene ( @$tmpGeneArray){
                    # "gene:".$$tmpgene{ID}."\n";
                    #$GeneHOH{Gene}[$cntGenes]=$tmpgene;
                    #$GeneHOH{Gene}[$cntGenes]{extStart}=$GeneHOH{Gene}[$cntGenes]{start};
                    #$GeneHOH{Gene}[$cntGenes]{extStop}=$GeneHOH{Gene}[$cntGenes]{stop};
                    #$cntGenes++;
                    my $tmpTransArray=$$tmpgene{TranscriptList}{Transcript};
                    foreach my $tmptranscript (@$tmpTransArray){
                        my $tmpExonArray=$$tmptranscript{exonList}{exon};
                        my $tmpStrand=$$tmptranscript{strand};
                        my $cntIntron=-1;
                        foreach my $tmpexon (@$tmpExonArray){
                            my $exonStart=$$tmpexon{start};
                            my $exonStop=$$tmpexon{stop};
                            $$tmpexon{coding_start}=$exonStart;
                            $$tmpexon{coding_stop}=$exonStop;
                            my $intronStart=-1;
                            my $intronStop=-1;
                            if($cntIntron>-1){
                                $intronStart=$$tmptranscript{intronList}{intron}[$cntIntron]{start};
                                $intronStop=$$tmptranscript{intronList}{intron}[$cntIntron]{stop};
                            }
                            $cntProbesets=0;
                            my $cntMatchingProbesets=0;
                            my $cntMatchingIntronProbesets=0;
                            foreach(@probesetHOH){				
                                        if((($probesetHOH[$cntProbesets]{start} >= $exonStart) and ($probesetHOH[$cntProbesets]{start} <= $exonStop) or
                                                ($probesetHOH[$cntProbesets]{stop} >= $exonStart) and ($probesetHOH[$cntProbesets]{stop} <= $exonStop))
                                           and
                                            $probesetHOH[$cntProbesets]{strand}==$tmpStrand
                                        ){
                                                delete $probesetHOH[$cntProbesets]{herit};
                                                delete $probesetHOH[$cntProbesets]{dabg};
                                                $$tmpexon{ProbesetList}{Probeset}[$cntMatchingProbesets] = $probesetHOH[$cntProbesets];
                                                $cntMatchingProbesets=$cntMatchingProbesets+1;
                                        }elsif((($probesetHOH[$cntProbesets]{start} >= $intronStart) and ($probesetHOH[$cntProbesets]{start} <= $intronStop) or 
                                                ($probesetHOH[$cntProbesets]{stop} >= $intronStart) and ($probesetHOH[$cntProbesets]{stop} <= $intronStop))
                                            and
                                            $probesetHOH[$cntProbesets]{strand}==$tmpStrand
                                        ){
                                                delete $probesetHOH[$cntProbesets]{herit};
                                                delete $probesetHOH[$cntProbesets]{dabg};
                                                $$tmptranscript{intronList}{intron}[$cntIntron]{ProbesetList}{Probeset}[$cntMatchingIntronProbesets] = 
                                                        $probesetHOH[$cntProbesets];
                                                $cntMatchingIntronProbesets=$cntMatchingIntronProbesets+1;
                                        }
                                    $cntProbesets = $cntProbesets+1;
                            } # loop through probesets

                            if($regionSize<5000000){
                                foreach my $strain(@snpStrain){
                                    #print "match snp strains:".$strain;
                                    my @snpList;
                                    my $snpListRef=$snpHOH{$strain}{Snp};
                                    eval{
                                        @snpList=@$snpListRef;
                                    }or do{
                                        @snpList=();
                                    };
                                    #match snps/indels to exons
                                    my $cntSnps=0;
                                    my $cntMatchingSnps=0;
                                    foreach(@snpList){
                                                if((($snpHOH{$strain}{Snp}[$cntSnps]{start} >= $exonStart) and ($snpHOH{$strain}{Snp}[$cntSnps]{start} <= $exonStop) or
                                                    ($snpHOH{$strain}{Snp}[$cntSnps]{stop} >= $exonStart) and ($snpHOH{$strain}{Snp}[$cntSnps]{stop} <= $exonStop))
                                                ){
                                                        $$tmpexon{VariantList}{Variant}[$cntMatchingSnps] = $snpHOH{$strain}{Snp}[$cntSnps];
                                                        $cntMatchingSnps++;
                                                }
                                            $cntSnps++;
                                    } # loop through snps/indels
                                }
                            }
                            $cntIntron++;
                        }
                    }
                }
                my $trackDB="rn5";
                if($type eq 'braincoding'){
                    createProteinCodingXMLTrack(\%brainHOH,$outputDir.$type.".xml",$trackDB,1);
                }elsif($type eq 'brainnoncoding'){
                    createProteinCodingXMLTrack(\%brainHOH,$outputDir.$type.".xml",$trackDB,0);
                }else{
                    createLiverTotalXMLTrack(\%brainHOH,$outputDir.$type.".xml");
                }
		
		my $rnaCountEnd=time();
		print "Track version completed in ".($rnaCountEnd-$rnaCountStart)." sec.\n";	
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
	my $arg9 = $ARGV[8]; 
	my $arg10= $ARGV[9];
	my $arg11=$ARGV[10];
	my $arg12=$ARGV[11];
	my $arg13=$ARGV[12];
	my $arg14=$ARGV[13];
	my $arg15=$ARGV[14];
        my $arg16=$ARGV[15];
        my $arg17=$ARGV[16];
        my $arg18=$ARGV[17];
        my $arg19=$ARGV[18];
        my $arg20=$ARGV[19];
        my $arg21=$ARGV[20];


	createXMLFile($arg1, $arg2, $arg3, $arg4, $arg5, $arg6, $arg7, $arg8, $arg9,$arg10,$arg11,$arg12,$arg13,$arg14,$arg15,$arg16,$arg17,$arg18,$arg19,$arg20,$arg21);

exit 0;