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

sub createBinnedMaxData{
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
		my $binMax=0;
		while($curPos<$curStop and $loopCount<$bin){
			my $segStart=$fullRNA{Count}[$curIndex]{start};
			my $segStop=$fullRNA{Count}[$curIndex]{stop};
			my $segValue=$fullRNA{Count}[$curIndex]{count};
			$curPos=$segStop;
			if($segValue>$binMax){
				$binMax=$segValue;
			}
			
			$curIndex++;
			$loopCount++;
		}
		
		
		#print "$binInd\t$curStart\t$binVal\n";
		if($binInd>0 and $binHOH{Count}[$binInd-1]{count}==$binMax){
			#skip since its the same value.
			$binHOH{Count}[$binInd-1]{start}=$binHOH{Count}[$binInd-1]{start}+$bin;
			$binHOH{Count}[$binInd-2]{stop}=$curStart+$bin-1;
			$binHOH{Count}[$binInd-1]{stop}=$curStart+$bin-1;
		}else{
			$binHOH{Count}[$binInd]{start}=$curStart;
			$binHOH{Count}[$binInd]{count}=$binMax;
			$binHOH{Count}[$binInd]{stop}=$curStart+$bin-1;
			$binInd++;
			$binHOH{Count}[$binInd]{start}=$curStart+$bin-1;
			$binHOH{Count}[$binInd]{count}=$binMax;
			$binHOH{Count}[$binInd]{stop}=$curStart+$bin-1;
			$binInd++;
		}
		$curStart=$curStop;
		$curStop=$bin+$curStart;
	}
	
	return \%binHOH;
}

sub getFeatureInfo
{
	# Routine to get 
    my $feature = shift;

    my $stable_id  = $feature->stable_id();
    my $seq_region = $feature->slice->seq_region_name();
    my $start      = $feature->seq_region_start();
    my $stop        = $feature->seq_region_end();
    my $strand     = $feature->seq_region_strand();
    
    
    #print "$stanble_id::$seq_region::$start::$stop::$strand\n";

    return ($stable_id, $seq_region, $start, $stop, $strand );
}

sub createXMLFile
{
	# Read in the arguments for the subroutine	
	my($outputDir,$species,$type,$panel,$chromosome,$minCoord,$maxCoord,$publicID,$binSize,$tissue,$genomeVer,$dsn,$usr,$passwd,$ensDsn,$ensUsr,$ensPasswd,$ucscDsn,$ucscUsr,$ucscPasswd,$mongoDsn,$mongoUser,$mongoPasswd)=@_;
	
	my $scriptStart=time();
	
	#my $panel="ILS/ISS";
	my $arrayTypeID=21;
	if($species eq 'Rat' or $species eq 'Rn' ){
		#$panel="BNLX/SHRH";
		$arrayTypeID=22;
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

        $rnaCountRef=readRNACountsDataFromMongo($chromosome,$species,$publicID,$panel,$type,$roundMin,$roundMax,$genomeVer,$dsn,$usr,$passwd,$mongoDsn,$mongoUser,$mongoPasswd);
		
		my %rnaCountHOH=%$rnaCountRef;
		my $rnaCountEnd=time();
		print "RNA Count completed in ".($rnaCountEnd-$rnaCountStart)." sec.\n";	
		
		if($binSize>0){

			my $ref;
			#if(index($type,"small")>0){
			#	$ref=createBinnedMaxData(\%rnaCountHOH,$binSize,$roundMin,$roundMax);
			#}else{
			$ref=createBinnedData(\%rnaCountHOH,$binSize,$roundMin,$roundMax);
			#}
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
		my $rnaCountRef=readSNPDataFromDB($genomeVer,$chromosome,$species,$minCoord,$maxCoord,$mongoDsn,$mongoUser,$mongoPasswd);
		my %rnaCountHOH=%$rnaCountRef;
		my $rnaCountEnd=time();
		print "RNA Count completed in ".($rnaCountEnd-$rnaCountStart)." sec.\n";	

		#print "track:".$outputDir;
		#my $output=$outputDir.$type.".xml";
		createSNPXMLTrack(\%rnaCountHOH,$outputDir);
	}elsif(index($type,"refSeq")>-1){
		my $rnaCountStart=time();
		if(index($chromosome,"chr")>-1){
			$chromosome=substr($chromosome,3);
		}
		my $refSeqRef=readRefSeqDataFromDB($chromosome,$species,$minCoord,$maxCoord,$ucscDsn,$ucscUsr,$ucscPasswd);
		my %refSeqHOH=%$refSeqRef;
		my $rnaCountEnd=time();
		print "Ref Seq completed in ".($rnaCountEnd-$rnaCountStart)." sec.\n";	
		
		createRefSeqXMLTrack(\%refSeqHOH,$outputDir.$type.".xml");
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
		
		my $spliceRef=readSpliceJunctFromDB($chromosome,$species,$minCoord,$maxCoord,$publicID,$panel,$tissue,$genomeVer,$dsn,$usr,$passwd);
		my %spliceHOH=%$spliceRef;
		my $rnaCountEnd=time();
		print "Splice Junction completed in ".($rnaCountEnd-$rnaCountStart)." sec.\n";	
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

    }elsif(index($type,"brainTotal")>-1 or index($type,"liverTotal")>-1 or index($type,"heartTotal")>-1 or index($type,"braincoding")>-1 or index($type,"mergedTotal")>-1 or index($type,"brainnoncoding")>-1){
        my $ver=substr($type,index($type,"_")+1);
        print "Type:$type\n";
        print "Ver:$ver\n";

		my $rnaCountStart=time();
		if(index($chromosome,"chr")>-1){
			$chromosome=substr($chromosome,3);
		}
                my ($probesetHOHRef) = readAffyProbesetDataFromDBwoProbes("chr".$chromosome,$minCoord,$maxCoord,$arrayTypeID,$genomeVer,$dsn,$usr,$passwd);
                my @probesetHOH = @$probesetHOHRef;

                my $snpRef=readSNPDataFromDB($genomeVer,$chromosome,$species,$minCoord,$maxCoord,$mongoDsn,$mongoUser,$mongoPasswd);
                my %snpHOH=%$snpRef;
                my @snpStrain=("BNLX","SHRH","SHRJ","F344");
                my $rnaType="totalRNA";
                if(index($type,"braincoding")>-1){
                    $rnaType="PolyA+";
                }elsif(index($type,"brainnoncoding")>-1){
                    $rnaType="NonPolyA+";
                }
		my $isoformHOH = readRNAIsoformDataFromDB($chromosome,$species,$publicID,$panel,$minCoord,$maxCoord,$dsn,$usr,$passwd,1,$rnaType,$tissue,$ver,$genomeVer);
                
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
                if($type eq 'braincoding'){
                    createProteinCodingXMLTrack(\%brainHOH,$outputDir.$type.".xml",1);
                }elsif($type eq 'brainnoncoding'){
                    createProteinCodingXMLTrack(\%brainHOH,$outputDir.$type.".xml",0);
                }else{
                    createLiverTotalXMLTrack(\%brainHOH,$outputDir.$type.".xml");
                }
		
		my $rnaCountEnd=time();
		print "Track version completed in ".($rnaCountEnd-$rnaCountStart)." sec.\n";	
	}elsif(index($type,"smallnc")>-1){
		if($type ne "ensemblsmallnc"){
	        my $ver=substr($type,index($type,"_")+1);
	        print "Type:$type\n";
	        print "Ver:$ver\n";

			my $rnaCountStart=time();
			if(index($chromosome,"chr")>-1){
				$chromosome=substr($chromosome,3);
			}
	        my ($probesetHOHRef) = readAffyProbesetDataFromDBwoProbes("chr".$chromosome,$minCoord,$maxCoord,$arrayTypeID,$genomeVer,$dsn,$usr,$passwd);
	        my @probesetHOH = @$probesetHOHRef;

	        my $snpRef=readSNPDataFromDB($genomeVer,$chromosome,$species,$minCoord,$maxCoord,$mongoDsn,$mongoUser,$mongoPasswd);
	        my %snpHOH=%$snpRef;
	        my @snpStrain=("BNLX","SHRH","SHRJ","F344");
	        my $rnaType="Any";
		my $isoformHOH = readSmallRNADataFromDB($chromosome,$species,$publicID,$panel,$minCoord,$maxCoord,$dsn,$usr,$passwd,1,$rnaType,$tissue,$ver,$genomeVer);
	                
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
	        
	        createLiverTotalXMLTrack(\%brainHOH,$outputDir.$type.".xml",1);
	        
			
			my $rnaCountEnd=time();
			print "Track version completed in ".($rnaCountEnd-$rnaCountStart)." sec.\n";	
		}else {
			my $shortSpecies="";
			if($species eq "Rat"){
			    $shortSpecies="Rn";
			}else{
			    $shortSpecies="Mm";
			}
			
			
			#
			# Zero a bunch of counters
			#
			my $cntTranscripts=0;
			my $cntProbesets=0;
			my $cntExons=0;
			my $cntGenes=0;
			my $cntMatchingProbesets=0;
			my $sliceStart;
			my %GeneHOH; # This is the big data structure to hold information about genes, transcripts, exons, probesets
			my $GeneHOHRef;
			#
			# Using perl API to read data from ensembl
			#
			#
			
			my $registry = 'Bio::EnsEMBL::Registry';

			my $dbAdaptorNum=-1;
			my $ranEast=0;
	
			eval{
			    print "trying local\n$ensDsn\n";
			    my $tmpInd=index($ensDsn,"host=")+5;
			    my $host=substr($ensDsn,$tmpInd,index($ensDsn,";",$tmpInd)-$tmpInd);
			    print "$host\n";
			    $dbAdaptorNum =$registry->load_registry_from_db(
				-host => $host, #'ensembldb.ensembl.org', # alternatively 'useastdb.ensembl.org'
				-port => 3306,
				-user => $ensUsr,
				-pass => $ensPasswd
			    );
			    print "local finished:$dbAdaptorNum\n";
			    1;
			}or do{
			    print "local ensembl DB is unavailable\n";
			    $dbAdaptorNum=-1;
			};
			if($dbAdaptorNum==-1){
			    print "trying useastdb\n";
			    $ranEast=1;
			    eval{
				    $dbAdaptorNum=$registry->load_registry_from_db(
					-host => 'useastdb.ensembl.org', #'ensembldb.ensembl.org', # alternatively 'useastdb.ensembl.org'
					-port => 5306,
					-user => 'anonymous'
				    );
				    print "east mirror finished:$dbAdaptorNum\n";
				    1;
			    }or do{
				print "ensembl east DB is unavailable\n";
				$dbAdaptorNum=-1;
			    };
			}
			if($ranEast==1 && $dbAdaptorNum<1){
			    print "trying ensembldb\n";
			    # Enable this option if problems occur connecting the above option is faster, but only has current and previous versions of data
			    $dbAdaptorNum=$registry->load_registry_from_db(
				-host => 'ensembldb.ensembl.org', 
				-user => 'anonymous'
			    );
			    print "main finished:$dbAdaptorNum\n";
			}

			print "connected\n$chromosome\n";
			my $slice_adaptor = $registry->get_adaptor( $species, 'Core', 'Slice' );
			
			my @genelist=();
			my @slicelist=();
			
			my $chr = $chromosome;
			if(index($chromosome,"chr")>-1){
				$chr=substr($chromosome,3);
			}
			print "$chr\n$minCoord\n$maxCoord\n";

			my $regionSize=$maxCoord-$minCoord;
			
			my $tmpslice = $slice_adaptor->fetch_by_region('chromosome', $chr,$minCoord,$maxCoord);
			my $genes = $tmpslice->get_all_Genes();
			while(my $tmpgene=shift @{$genes}){
			    push(@genelist, $tmpgene);
			    push(@slicelist, $tmpslice);
			    #print "gene list:".@genelist."\n";
			}
	
			#read Probests
			my $psTimeStart=time();
			my ($probesetHOHRef) = readAffyProbesetDataFromDBwoProbes("chr".$chr,$minCoord,$maxCoord,$arrayTypeID,$genomeVer,$dsn,$usr,$passwd);
			my @probesetHOH = @$probesetHOHRef;
			my $psTimeEnd=time();
			createProbesetXMLTrack(\@probesetHOH,$outputDir."probe.xml");
			print "Probeset Time=".($psTimeEnd-$psTimeStart)."sec\n";
	
			my %ensemblHOH;
			
			
			my %snpHOH;
			my @snpList=();
			my @snpStrain=();
		
			if($shortSpecies eq 'Rn'){
			    #read SNPs/Indels
			    my $sTimeStart=time();
			    my $snpRef=readSNPDataFromDB($genomeVer,$chr,$species,$minCoord,$maxCoord,$mongoDsn,$mongoUser,$mongoPasswd);
			    %snpHOH=%$snpRef;
			    @snpStrain=("BNLX","SHRH","SHRJ","F344");
			    my $sTimeEnd=time();
			    print "SNP Time=".($sTimeEnd-$sTimeStart)."sec\n";
			}
			my $ensemblCount=0;
			# Loop through  Ensembl Genes
			my @addedGeneList=();
			while ( my $gene = shift @genelist ) {
				my $slice=shift @slicelist;
				my ($geneName, $geneRegion, $geneStart, $geneStop,$geneStrand) = getFeatureInfo($gene);
				my $geneChrom = "chr$geneRegion";
				my $found=0;
				#print "Find: $geneName\n";
				foreach my $testName (@addedGeneList){
				    #print "$testName:$geneName ";
				    if($testName eq $geneName){
					#print "Found";
					$found=1;
				    }else{
					#print "Not found";
				    }
				    #print "\n";
				}

			    if(length($geneRegion)<3&&$found==0){
				my $geneBioType    = $gene->biotype();
				my $geneExternalName    =$gene->external_name();
				my $geneDescription      =$gene->description();
				# "adding:$geneName:$geneExternalName\n";
				
				push(@addedGeneList,$geneName);
				$ensemblHOH{Gene}[$ensemblCount] = {
					start => $geneStart,
					stop => $geneStop,
					ID => $geneName,
					strand=>$geneStrand,
					chromosome=>$geneChrom,
					biotype => $geneBioType,
					geneSymbol => $geneExternalName,
					source => "Ensembl",
					description => $geneDescription,
					extStart => $geneStart ,
					extStop => $geneStop
					};
				$GeneHOH{Gene}[$cntGenes]=$ensemblHOH{Gene}[$ensemblCount];
				$ensemblCount++;
				#print GLFILE "$geneName\t$geneExternalName\t$geneStart\t$geneStop\n";

				    #Get the transcripts for this gene
				    #print "getting transcripts for ".$geneExternalName."\n";
				    my $transcripts = $gene->get_all_Transcripts();

				    $cntTranscripts = 0;
				    while ( my $transcript = shift @{$transcripts} ) {
					my ($transcriptName, $transcriptRegion, $transcriptStart, $transcriptStop,$transcriptStrand) = getFeatureInfo($transcript);
					my $transcriptChrom = "chr$transcriptRegion";

					$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{start} = $transcriptStart;
					$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{stop} = $transcriptStop;
					$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{ID} = $transcriptName;
					$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{strand} = $transcriptStrand;
					$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{chromosome} = $transcriptChrom;
					$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{cdsStart} = $transcript->coding_region_start()+ $slice->start() - 1;
					$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{cdsStop} = $transcript->coding_region_end()+ $slice->start() - 1;
					my $tmpStrand=$transcriptStrand;
					
					my $cntExons = 0;
					my $cntIntrons=0;
					
					#print "getting exons for $transcriptName\n";
					# On to the exons
					#sort first so introns can be created as we go
					my @tmpExons= @{ $transcript->get_all_Exons() };
					my @sortedExons = sort { $a->seq_region_start() <=> $b->seq_region_start() } @tmpExons;
					
				    foreach my $exon ( @sortedExons ) {
						my ($exonName, $exonRegion, $exonStart, $exonStop,$exonStrand) = getFeatureInfo($exon);
						#print "get Exons\n";
						my $exonChrom = "chr$exonRegion";
						# have to offset the stop and start by the slice start
						#print "test1".$exon->coding_region_end($transcript)."\n";
						#print "test2".$slice->start()."\n";
						
						my $coding_region_stop = $exon->coding_region_end($transcript) + $slice->start() - 1;
						my $coding_region_start = $exon->coding_region_start($transcript) + $slice->start() - 1;
						$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{start} = $exonStart;
						$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{stop} = $exonStop;
						$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{ID} = $exonName;
						$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{strand} = $exonStrand;
						$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{chromosome} = $exonChrom;
						$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{coding_start} = $coding_region_start;
						$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{coding_stop} = $coding_region_stop;
						#print "added exon $exonName\n";
						my $intronStart=-1;
						my $intronStop=-1;
						#create intronList
						if($cntExons>0){
						    $intronStart=$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons-1]{stop}+1;
						    $intronStop=$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{start}-1;
						    
						    $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{intronList}{intron}[$cntIntrons]{start} = $intronStart;
						    $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{intronList}{intron}[$cntIntrons]{stop} = $intronStop;
						    $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{intronList}{intron}[$cntIntrons]{ID} = $cntIntrons+1;
						    $cntIntrons=$cntIntrons+1;
						}
						#Now find which probesets are associated with each exon	and intron
						#Check if the probeset location overlaps the exon location
						#if it is not over an exon check to see if it is over an intron
						#print "starting to match probesets\n";
						my $cntProbesets=0;
						my $cntMatchingProbesets=0;
						my $cntMatchingIntronProbesets=0;
						foreach(@probesetHOH){
							    if((($probesetHOH[$cntProbesets]{start} >= $exonStart) and ($probesetHOH[$cntProbesets]{start} <= $exonStop) or 
								($probesetHOH[$cntProbesets]{stop} >= $exonStart) and ($probesetHOH[$cntProbesets]{stop} <= $exonStop))
							       and
							        $probesetHOH[$cntProbesets]{strand}==$tmpStrand
							    ){
								    #This is a probeset overlapping the current exon
								    delete $probesetHOH[$cntProbesets]{herit};
								    delete $probesetHOH[$cntProbesets]{dabg};
								    $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{ProbesetList}{Probeset}[$cntMatchingProbesets] = 
									    $probesetHOH[$cntProbesets];
								    $cntMatchingProbesets=$cntMatchingProbesets+1;
							    }elsif((($probesetHOH[$cntProbesets]{start} >= $intronStart) and ($probesetHOH[$cntProbesets]{start} <= $intronStop) or 
								($probesetHOH[$cntProbesets]{stop} >= $intronStart) and ($probesetHOH[$cntProbesets]{stop} <= $intronStop))
								   and
							        $probesetHOH[$cntProbesets]{strand}==$tmpStrand
							    ){
								    delete $probesetHOH[$cntProbesets]{herit};
								    delete $probesetHOH[$cntProbesets]{dabg};
								    $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{intronList}{intron}[$cntIntrons-1]{ProbesetList}{Probeset}[$cntMatchingIntronProbesets] = 
									    $probesetHOH[$cntProbesets];
								    $cntMatchingIntronProbesets=$cntMatchingIntronProbesets+1;
							    }
							$cntProbesets = $cntProbesets+1;
						} # loop through probesets
						
						
						if($regionSize<5000000){
		                                    my $cntMatchingSnps=0;
						    foreach my $strain(@snpStrain){
							#print "match snp strains:".$strain;
							my $snpListRef=$snpHOH{$strain}{Snp};
							eval{
							    @snpList=@$snpListRef;
							}or do{
							    @snpList=();
							};
							    #match snps/indels to exons
							    my $cntSnps=0;
							    foreach(@snpList){
								#print "check snp".$snpHOH{Snp}[$cntSnps]{start}."-".$snpHOH{Snp}[$cntSnps]{stop};
								    #if($exonStart<$exonStop){# if gene is in the forward direction
									if((($snpHOH{$strain}{Snp}[$cntSnps]{start} >= $exonStart) and ($snpHOH{$strain}{Snp}[$cntSnps]{start} <= $exonStop) or
									    ($snpHOH{$strain}{Snp}[$cntSnps]{stop} >= $exonStart) and ($snpHOH{$strain}{Snp}[$cntSnps]{stop} <= $exonStop))
									){
										$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{VariantList}{Variant}[$cntMatchingSnps] = $snpHOH{$strain}{Snp}[$cntSnps];
										$cntMatchingSnps++;
										#print "Exon Variant";
									}
								    $cntSnps++;
							    } # loop through snps/indels
						    }
						}
						
						$cntExons=$cntExons+1;
						#print "finished matching probesets\n";
				    } # loop through exons
				    $cntTranscripts = $cntTranscripts+1;
				} # loop through transcripts
				#$GeneHOH{Gene}[$cntGenes]{TranscriptCountEnsembl}=$cntTranscripts;
				$cntGenes=$cntGenes+1;
			    }# if to process only if chromosome is valid
			}
			my %smncHOH={};
			$smncHOH{smnc}=[];
			createSmallNonCodingXML(\%smncHOH,\%GeneHOH,"","",$outputDir."ensemblsmallnc.xml",$chromosome);
		}
		
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
    my $arg22=$ARGV[21];
    my $arg23=$ARGV[22];

	createXMLFile($arg1, $arg2, $arg3, $arg4, $arg5, $arg6, $arg7, $arg8, $arg9,$arg10,$arg11,$arg12,$arg13,$arg14,$arg15,$arg16,$arg17,$arg18,$arg19,$arg20,$arg21,$arg22,$arg23);

exit 0;