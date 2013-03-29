#!/usr/bin/perl

use strict;

use Math::Round;



sub createQTLTrack{
	my($qtlHOHRef, $outputFile,$trackDB,$chr) = @_; 
	my %qtlHOH = %$qtlHOHRef;
	my $qtlListRef=$qtlHOH{QTL};
	my @qtlList=();
	eval{
		@qtlList=@$qtlListRef;
	}or do{
		@qtlList=();
	};
	open OFILE, '>'.$outputFile or die " Could not open two track file $outputFile for writing $!\n\n";
	print OFILE "track db=$trackDB name='bQTLs' ";
	print OFILE 'description="bQTLs" ';
	print OFILE "visibility=2 centerLabelsDense=\"on\" \n";
	if(@qtlList>0){
		my $cntQTL=0;
		foreach my $tmpQTL (@qtlList){
			my $qtlName=$qtlHOH{QTL}[$cntQTL]{name};
			my $qtlStart=$qtlHOH{QTL}[$cntQTL]{start};
			my $qtlStop=$qtlHOH{QTL}[$cntQTL]{stop};
			$qtlName =~ s/ /_/g;
			print OFILE "chr$chr\t$qtlStart\t$qtlStop\t$qtlName\t0\t.\n";
			$cntQTL++;
		}
	}
	close OFILE;
	return 1;
} # End of 

sub createSNPTrack{
	my($snpHOHRef, $outputFile, $trackDB) = @_; 
	# Dereference the hash and array
	my %snpHOH = %$snpHOHRef;
	my $snpListRef=$snpHOH{Snp};
	my @snpList=();
	eval{
		@snpList=@$snpListRef;
	}or do{
		@snpList=();
	};
	
	
	open OFILE, ">".$outputFile or die " Could not open two track file $outputFile for writing $!\n\n";
	
	print OFILE "track db=$trackDB name='BNLX/SHRH SNPs and Indels' ";
	print OFILE "description='BNLX/SHRH DNA SNPs and Indels  BNLX-Blue SHRH-Red SNP-Brighter Indel-Darker' ";
	print OFILE "visibility=3 itemRgb=On \n";
	if(@snpList>0){
		my $cntSnp=0;
		foreach my $tmpSnp (@snpList){
			my $chr=$snpHOH{Snp}[$cntSnp]{chromosome};
			my $strain=$snpHOH{Snp}[$cntSnp]{strain};
			my $refSeq=$snpHOH{Snp}[$cntSnp]{refSeq};
			my $strainSeq=$snpHOH{Snp}[$cntSnp]{strainSeq};
			my $start=$snpHOH{Snp}[$cntSnp]{start};
			my $stop=$snpHOH{Snp}[$cntSnp]{stop};
			my $type=$snpHOH{Snp}[$cntSnp]{type};
			my $name=$refSeq.":".$strainSeq;
			my $color="0,0,0";
			if($type eq "SNP"){
				if($strain eq "BNLX"){
					$color="0,0,255";
				}elsif($strain eq "SHRH"){
					$color="255,0,0";
				}else{
					$color="50,50,50";
				}
			}else{
				if($strain eq "BNLX"){
					$color="0,0,150";
				}elsif($strain eq "SHRH"){
					$color="150,0,0";
				}else{
					$color="100,100,100";
				}
			}
			print OFILE "chr$chr\t$start\t$stop\t$name\t0\t.\t$start\t$stop\t$color\n";
			$cntSnp++;
		}
	}
	close OFILE;
} # End of



sub createProteinCodingTrack{
	my($GeneHOHRef, $outputFile, $trackDB, $proteinCoding) = @_; 
	# Dereference the hash and array
	my %GeneHOH = %$GeneHOHRef;
	my $geneListRef=$GeneHOH{Gene};
	my @geneList=();
	eval{
		@geneList=@$geneListRef;
	}or do{
		@geneList=();
	};
	
	my $trackDesc="Ensembl Protein Coding / RNA-Seq PolyA+";
	if($proteinCoding==0){
		$trackDesc="Long Ensembl Non-Coding / RNA-Seq Non-PolyA+ (>=350bp)";
	}
	
	open OFILE, ">".$outputFile or die " Could not open two track file $outputFile for writing $!\n\n";
	
	print OFILE "track db=$trackDB name='$trackDesc' ";
		print OFILE "description='$trackDesc'";
		print OFILE "visibility=3 itemRgb=On \n";
		if(@geneList>0){
			my $cntGenes=0;
			foreach my $tmpGene (@geneList){
				my $biotype=$GeneHOH{Gene}[$cntGenes]{biotype};
				my $gLen=$GeneHOH{Gene}[$cntGenes]{stop}-$GeneHOH{Gene}[$cntGenes]{start};
				$gLen=abs($gLen);
				#print "::$biotype::\n";
				if(($biotype eq "protein_coding" and $proteinCoding==1) or ($biotype ne "protein_coding" and $proteinCoding==0 and $gLen>=350)){
					my $geneID=$GeneHOH{Gene}[$cntGenes]{ID};
					my $transcriptArrayRef = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript};
					my $chr=$GeneHOH{Gene}[$cntGenes]{chromosome};
					
					if(index($chr,"chr")>-1){
						$chr=substr($chr,3);
					}
					
					my $strand=$GeneHOH{Gene}[$cntGenes]{strand};
					
					my @transcriptArray = @$transcriptArrayRef;
					
					my @exonHOH;
					my $cntHOHExons=0;
					my $convStrand=".";
					my $cntTranscripts = 0;
					
					my $color="0,0,0";
					if($GeneHOH{Gene}[$cntGenes]{source} eq "Ensembl"){
						if($proteinCoding==1){
							$color="223,193,132";
						}else{
							$color="181,138,165";
						}
					}else{
						if($proteinCoding==1){
							$color="126,181,214";
						}else{
							$color="206,207,206";
						}
					}
					
					foreach(@transcriptArray){
						my $exonArrayRef = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon};
						my @exonArray = @$exonArrayRef;
						my $cntExons = 0;
						#if(@exonArray==1){
						#	$color="0,0,0";
						#}
						my $trstart=$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{start};
						my $trstop=$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{stop};
						my $trstrand=$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{strand};
						if($trstrand==1){
							$convStrand="+";
						}elsif($trstrand==-1){
							$convStrand="-";
						}
						my $trname=$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{ID};
						#$trname  =~ s/ /_/g;
						my $genePart=substr($geneID,0,index($geneID,"."));
						my $fulltrname=$genePart;
						if($GeneHOH{Gene}[$cntGenes]{source} eq "Ensembl"){
							$fulltrname=$trname;
						}else{
							my $trPart=substr($trname,index($trname,"_")+1);
							$trPart =~ s/^\s+//g;
							$trPart =~ s/^0*//;
							$fulltrname=$fulltrname.".".$trPart;
						}
						
						my $tmpLens="";
						my $tmpStarts="";
						foreach(@exonArray){
							my $currentExonStart = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{start};
							my $currentExonStop = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{stop};
							# find out if this exon is already in exonHOH
							my $relStart=$currentExonStart-$trstart;
							
							my $tmpLen=$currentExonStop-$currentExonStart;
							if($tmpLen==0){
								$tmpLen=1;
							}
							if(($trstart+$relStart+$tmpLen)>$trstop){
								$trstop=$trstop+$tmpLen;
							}
							
							if($tmpLens eq ""){
								$tmpLens="".$tmpLen;
								$tmpStarts="".$relStart;
							}else{
								$tmpLens=$tmpLens.",".$tmpLen;
								$tmpStarts=$tmpStarts.",".$relStart;
							}
							
							
							$cntExons++;
						}
						print OFILE "chr$chr\t$trstart\t$trstop\t$fulltrname\t0\t$convStrand\t$trstart\t$trstop\t$color\t";
						print OFILE "$cntExons\t$tmpLens\t$tmpStarts\n";
						$cntTranscripts++;
					}
				}
				$cntGenes=$cntGenes+1;
			}
		}
		close OFILE;
		return 1;
} # End of


sub createSmallNonCoding{
	my($smncHOHRef,$geneHOHRef, $outputFile,$trackDB,$chr) = @_; 
	my %smncHOH = %$smncHOHRef;
	my %geneHOH=%$geneHOHRef;
	
	my $smncListRef=$smncHOH{smnc};
	my @smncList=();
	eval{
		@smncList=@$smncListRef;
	}or do{
		@smncList=();
	};
	
	my $geneListRef=$geneHOH{Gene};
	my @geneList=();
	eval{
		@geneList=@$geneListRef;
	}or do{
		@geneList=();
	};
	
	open OFILE, '>'.$outputFile or die " Could not open two track file $outputFile for writing $!\n\n";
	print OFILE "track db=$trackDB name='Small RNA' ";
	print OFILE 'description="Small RNA <350bp" ';
	print OFILE "visibility=3 itemRgb=On \n";
	if(@smncList>0){
		my $cntSmnc=0;
		foreach my $tmpSmnc (@smncList){
			my $smncID=$smncHOH{smnc}[$cntSmnc]{ID};
			my $smncStart=$smncHOH{smnc}[$cntSmnc]{start};
			my $smncStop=$smncHOH{smnc}[$cntSmnc]{stop};
			my $smncStrand=$smncHOH{smnc}[$cntSmnc]{strand};
			my $strand=".";
			if($smncStrand==1){
				$strand="+";
			}elsif($smncStrand==-1){
				$strand="-";
			}
			print OFILE "chr$chr\t$smncStart\t$smncStop\tsmRNA_$smncID\t0\t$strand\t$smncStart\t$smncStop\t153,204,153\n";
			$cntSmnc++;
		}
	}
	if(@geneList>0){
		my $cntGenes=0;
		foreach my $tmpGene (@geneList){
			my $biotype=$geneHOH{Gene}[$cntGenes]{biotype};
			my $gLen=$geneHOH{Gene}[$cntGenes]{stop}-$geneHOH{Gene}[$cntGenes]{start};
			$gLen=abs($gLen);
			if($biotype ne "protein_coding"  and $gLen<350){
				my $geneID=$geneHOH{Gene}[$cntGenes]{ID};
				my $transcriptArrayRef = $geneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript};
				my $strand=$geneHOH{Gene}[$cntGenes]{strand};
				my @transcriptArray = @$transcriptArrayRef;
				my @exonHOH;
				my $cntHOHExons=0;
				my $convStrand=".";
				my $cntTranscripts = 0;
				my $color="0,0,0";
				if($geneHOH{Gene}[$cntGenes]{source} eq "Ensembl"){
					$color="255,204,0";
				}else{
					$color="153,204,153";
				}
				foreach(@transcriptArray){
					my $trstart=$geneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{start};
					my $trstop=$geneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{stop};
					my $trstrand=$geneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{strand};
					if($trstrand==1){
						$convStrand="+";
					}elsif($trstrand==-1){
						$convStrand="-";
					}
					my $trname=$geneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{ID};
					my $genePart=substr($geneID,0,index($geneID,"."));
					my $fulltrname=$genePart;
					if($geneHOH{Gene}[$cntGenes]{source} eq "Ensembl"){
						$fulltrname=$trname;
					}else{
						my $trPart=substr($trname,index($trname,"_")+1);
						$trPart =~ s/^\s+//g;
						$trPart =~ s/^0*//;
						$fulltrname=$fulltrname.".".$trPart;
					}
					print OFILE "chr$chr\t$trstart\t$trstop\t$fulltrname\t0\t$convStrand\t$trstart\t$trstop\t$color\n";
					$cntTranscripts++;
				}
			}
			$cntGenes=$cntGenes+1;
		}
	}
	
	close OFILE;
	return 1;
}

sub createFilteredProbesetTrack{
	my($tissueProbesRef, $outputFile,$trackDB,$chr) = @_; 
	my %tissueProbes=%$tissueProbesRef;
	open OFILE, '>'.$outputFile or die " Could not open two track file $outputFile for writing $!\n\n";
	
	my $coreColor="255,0,0";
	my $fullColor="0,100,0";
	my $extendedColor="0,0,255";
	my $cntColor=0;
	foreach my $key (keys %tissueProbes){
		print OFILE 'track db='.$trackDB." name=\"Probesets above background in $key\" ";
		print OFILE "description=\"Affy Exon Probesets detected above background in $key: Red=Core Blue=Extended Green=Full\" ";
		print OFILE 'visibility=3 itemRgb=On'."\n"; #removed useScore=1
		my $probeRef=$tissueProbes{$key}{pslist};
		my @probeset=@$probeRef;
		my $curInd=0;
		foreach(@probeset){
			my $score=round($tissueProbes{$key}{pslist}[$curInd]{dabg}*10);
			my $color=$fullColor;
			my $strand=".";
			if($tissueProbes{$key}{pslist}[$curInd]{strand}==-1){
				$strand="-";
			}elsif($tissueProbes{$key}{pslist}[$curInd]{strand}==1){
				$strand="+";
			}
		
			if($tissueProbes{$key}{pslist}[$curInd]{level} eq 'core'){
				$color=$coreColor;
			}elsif($tissueProbes{$key}{pslist}[$curInd]{level} eq 'extended'){
				$color=$extendedColor;
			}
			print OFILE "chr$chr\t".$tissueProbes{$key}{pslist}[$curInd]{start}."\t".$tissueProbes{$key}{pslist}[$curInd]{stop}."\t".$tissueProbes{$key}{pslist}[$curInd]{ID}."\t$score\t$strand\t".$tissueProbes{$key}{pslist}[$curInd]{start}."\t".$tissueProbes{$key}{pslist}[$curInd]{stop}."\t".$color."\n";
			$curInd++;
		}
		$cntColor++;
	}
	close OFILE;
	
}

sub createProbesetTrack{
	my($nonMaskedProbesRef, $outputFile,$trackDB,$chr) = @_; 
	my @nonMaskedProbes=@$nonMaskedProbesRef;
	open OFILE, '>'.$outputFile or die " Could not open two track file $outputFile for writing $!\n\n";
	if($trackDB eq 'rn5'){
		my $coreColor="255,0,0";
		my $fullColor="0,100,0";
		my $extendedColor="0,0,255";
		my $cntColor=0;
		print OFILE 'track db='.$trackDB." name=\"All Probesets\" ";
		print OFILE "description=\"All Probesets: Red=Core Blue=Extended Green=Full\" ";
		print OFILE 'visibility=3 itemRgb=On'."\n"; #removed useScore=1
		my $curInd=0;
		foreach(@nonMaskedProbes){
			my $strand=".";
			if($nonMaskedProbes[$curInd]{strand}==-1){
				$strand="-";
			}elsif($nonMaskedProbes[$curInd]{strand}==1){
				$strand="+";
			}
			my $color=$fullColor;
			if($nonMaskedProbes[$curInd]{type} eq 'core'){
				$color=$coreColor;
			}elsif($nonMaskedProbes[$curInd]{type} eq 'extended'){
				$color=$extendedColor;
			}
			if($nonMaskedProbes[$curInd]{start}>0&&$nonMaskedProbes[$curInd]{stop}>0){
				print OFILE "chr$chr\t".$nonMaskedProbes[$curInd]{start}."\t".$nonMaskedProbes[$curInd]{stop}."\t".$nonMaskedProbes[$curInd]{ID}."\t0\t$strand\t".$nonMaskedProbes[$curInd]{start}."\t".$nonMaskedProbes[$curInd]{stop}."\t".$color."\n";
			}
			$curInd++;
		}
		$cntColor++;
	}else{
		print OFILE "track db=$trackDB type=bigBed  name='Affy Mouse Probesets' ";
		print OFILE 'description="Probesets from Affymetrix Exon 1.0 ST Array: Red=Core Green=Full Blue=Extended" ';
		print OFILE "visibility=3 itemRgb=On bigDataUrl=http://ucsc:JU7etr5t\@phenogen.ucdenver.edu/ucsc/mouseBigBed.bb\n";
	}
	close OFILE;
	
}


sub createNumberedExonTrack{
	my($sortedExonRef, $outputFile,$trackDB,$strand,$chr) = @_;
	my @sortedExon=@$sortedExonRef;
	my $fullStrand="+";
	my $shortStrand="+";
	if($strand==-1){
		$fullStrand="-";
		$shortStrand="-";
	}elsif($strand==0){
		$fullStrand="Unknown";
		$shortStrand=".";
	}
	open OFILE, '>'.$outputFile or die " Could not open two track file $outputFile for writing $!\n\n";
	print OFILE 'track db='.$trackDB.' name="'.$fullStrand.' Strand Exons" ';
	print OFILE 'description="Numbered Exons for the '.$fullStrand.' Strand Transcripts" ';
	print OFILE 'visibility=3 colorByStrand="255,0,0 0,0,255"'."\n";
	my $curIndex=0;
	foreach(@sortedExon){
		my $start=$sortedExon[$curIndex]{start};
		my $stop=$sortedExon[$curIndex]{stop};
		my $strand=$sortedExon[$curIndex]{strand};
		my $name=$sortedExon[$curIndex]{alternateID2};
		print OFILE "chr$chr\t$start\t$stop\t$name\t0\t$shortStrand\n";
		$curIndex++;
	}
	close OFILE;
}
sub createStrandedCodingTrack{
	my($GeneHOHRef, $outputFile,$trackDB,$curStrand,$chr) = @_;
	my %GeneHOH = %$GeneHOHRef;
	my $geneListRef=$GeneHOH{Gene};
	my @geneList=();
	eval{
		@geneList=@$geneListRef;
	}or do{
		@geneList=();
	};
	my $fullStrand="+";
	my $shortStrand="+";
	if($curStrand==-1){
		$fullStrand="-";
		$shortStrand="-";
	}elsif($curStrand==0){
		$fullStrand="Unknown";
		$shortStrand=".";
	}
	open OFILE, '>>'.$outputFile or die " Could not open two track file $outputFile for writing $!\n\n";
	print OFILE "track db=$trackDB name='".$fullStrand." Strand Transcripts' ";
	print OFILE 'description="'.$fullStrand.' Strand Transcripts"';
	print OFILE "visibility=3 itemRgb=On \n";
	if(@geneList>0){
		my $cntGenes=0;
		foreach my $tmpGene (@geneList){
			my $geneID=$GeneHOH{Gene}[$cntGenes]{ID};
			my $strand=$GeneHOH{Gene}[$cntGenes]{strand};
			if($strand==$curStrand){
				my $transcriptArrayRef = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript};
				my $chr=$GeneHOH{Gene}[$cntGenes]{chromosome};
				
				if(index($chr,"chr")>-1){
					$chr=substr($chr,3);
				}
				
				my @transcriptArray = @$transcriptArrayRef;
				
				my @exonHOH;
				my $cntHOHExons=0;
				my $convStrand=".";
				my $cntTranscripts = 0;
				
				my $color="255,0,0";
				if($strand==-1){
					$color="0,0,255";
				}elsif($strand==0){
					$color="0,0,0";
				}
				#if($GeneHOH{Gene}[$cntGenes]{source} eq "Ensembl"){
				#	$color="197,17,0";
				#}
				
				foreach(@transcriptArray){
					my $exonArrayRef = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon};
					my @exonArray = @$exonArrayRef;
					my $cntExons = 0;
					
					my $trstart=$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{start};
					my $trstop=$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{stop};
					my $trstrand=$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{strand};
					if($trstrand==1){
						$convStrand="+";
					}elsif($trstrand==-1){
						$convStrand="-";
					}elsif($trstrand==0){
						$convStrand=".";
					}
					my $trname=$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{ID};
					#$trname  =~ s/ /_/g;
					my $genePart=substr($geneID,0,index($geneID,"."));
					my $fulltrname=$genePart;
					if($GeneHOH{Gene}[$cntGenes]{source} eq "Ensembl"){
						$fulltrname=$trname;
					}else{
						my $trPart=substr($trname,index($trname,"_")+1);
						$trPart =~ s/^\s+//g;
						$trPart =~ s/^0*//;
						$fulltrname=$fulltrname.".".$trPart;
					}
					
					my $tmpLens="";
					my $tmpStarts="";
					foreach(@exonArray){
						my $currentExonStart = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{start};
						my $currentExonStop = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{stop};
						# find out if this exon is already in exonHOH
						my $relStart=$currentExonStart-$trstart;
						
						my $tmpLen=$currentExonStop-$currentExonStart;
						if($tmpLen==0){
								$tmpLen=1;
						}
						if(($trstart+$relStart+$tmpLen)>$trstop){
								$trstop=$trstop+$tmpLen;
						}
						if($tmpLens eq ""){
							$tmpLens="".$tmpLen;
							$tmpStarts="".$relStart;
						}else{
							$tmpLens=$tmpLens.",".$tmpLen;
							$tmpStarts=$tmpStarts.",".$relStart;
						}
						
						my $alreadyIncluded = 0;
						for(my $cnt=0; $cnt < $cntHOHExons; $cnt++){
							if($exonHOH[$cnt]{start} == $currentExonStart && $exonHOH[$cnt]{stop} == $currentExonStop ){
								$alreadyIncluded = 1;
							}
						}	
						
						#print 	$GeneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{ID}." include $alreadyIncluded\n";
						if($alreadyIncluded == 0){
							# Add this exon to the exonHOH
							$exonHOH[$cntHOHExons]{ID} = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{ID};
							$exonHOH[$cntHOHExons]{start} =  $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{start};
							$exonHOH[$cntHOHExons]{stop} =  $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{stop};
							$exonHOH[$cntHOHExons]{coding_start} =  $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{coding_start};
							$exonHOH[$cntHOHExons]{coding_stop} =  $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{coding_stop};
							$exonHOH[$cntHOHExons]{strand} =  $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{strand};
							$exonHOH[$cntHOHExons]{chromosome} =  $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{chromosome};
							$exonHOH[$cntHOHExons]{alternateID2} =$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{alternateID2};
							$cntHOHExons++;
						}
						$cntExons++;
					}
					print OFILE "chr$chr\t$trstart\t$trstop\t$fulltrname\t0\t$convStrand\t$trstart\t$trstop\t$color\t";
					print OFILE "$cntExons\t$tmpLens\t$tmpStarts\n";
					$cntTranscripts++;
				}
			}
			$cntGenes=$cntGenes+1;
		}
	}
	close OFILE;
}
return 1;