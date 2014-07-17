#!/usr/bin/perl

use strict;

use Math::Round;



sub createQTLXMLTrack{
	my($qtlHOHRef, $outputFile,$trackDB,$chr) = @_; 
	my %qtlHOH = %$qtlHOHRef;
	open OFILE, '>'.$outputFile or die " Could not open two track file $outputFile for writing $!\n\n";
	my $xml = new XML::Simple (RootName=>'QTLList');
	my $data = $xml->XMLout(\%qtlHOH);
	print OFILE $data;
	close OFILE;
	return 1;
} # End of 


sub createSNPXMLTrack{
	my($snpHOHRef, $outputDir, $trackDB) = @_; 
	# Dereference the hash and array
	my %snpHOH = %$snpHOHRef;
	
	my @snpStrainList=keys %snpHOH;
	#my @snpList=();
	#eval{
	#	@snpList=@$snpStrainListRef;
	#	print "SNP LIST LEN".@snpList."\n";
	#}or do{
	#	@snpList=();
	#	print "EMPTY SNP LIST\n";
	#};
	if(!(defined $snpHOH{"BNLX"}) and ($trackDB eq "rn5")){
		push(@snpStrainList,"BNLX");
		$snpHOH{"BNLX"}={};
	}
	if(!(defined $snpHOH{"SHRH"}) and ($trackDB eq "rn5")){
		push(@snpStrainList,"SHRH");
		$snpHOH{"SHRH"}={};
	}
	if(!(defined $snpHOH{"SHRJ"}) and ($trackDB eq "rn5")){
		push(@snpStrainList,"SHRJ");
		$snpHOH{"SHRJ"}={};
	}
	if(!(defined $snpHOH{"F344"}) and ($trackDB eq "rn5")){
		push(@snpStrainList,"F344");
		$snpHOH{"F344"}={};
	}
	foreach my $strain(@snpStrainList){
			print "Strain SNPS:$strain\n";
			my %tmp;
			my $ref=$snpHOH{$strain};
			%tmp=%$ref;
			open OFILE, ">".$outputDir."snp".$strain.".xml" or die " Could not open two track file $outputDir for writing $!\n\n";
			my $xml = new XML::Simple (RootName=>'SNPList');
			my $data = $xml->XMLout(\%tmp);
			print OFILE $data;
			close OFILE;
	}
} # End of



sub createProteinCodingXMLTrack{
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
	
	my %outGeneHOH;
	my $outCount=0;
	
	open OFILE, ">".$outputFile or die " Could not open two track file $outputFile for writing $!\n\n";
		if(@geneList>0){
			my $cntGenes=0;
			foreach my $tmpGene (@geneList){
				my $biotype=$GeneHOH{Gene}[$cntGenes]{biotype};
				my $gLen=$GeneHOH{Gene}[$cntGenes]{stop}-$GeneHOH{Gene}[$cntGenes]{start};
				$gLen=abs($gLen);
				#print "::$biotype::\n";
				if(($biotype eq "protein_coding" and $proteinCoding==1 and $gLen>=200) or ($biotype ne "protein_coding" and $proteinCoding==0 and $gLen>=200)){
					$outGeneHOH{Gene}[$outCount]=$GeneHOH{Gene}[$cntGenes];
					$outCount++;
				}
				$cntGenes=$cntGenes+1;
			}
		}
	my $xml = new XML::Simple (RootName=>'GeneList');
	my $data = $xml->XMLout(\%outGeneHOH);
	print OFILE $data;
	close OFILE;
		return 1;
} # End of


sub createSmallNonCodingXML{
	my($smncHOHRef,$geneHOHRef, $combinedoutputFile,$smncoutputFile,$ensoutputFile,$trackDB,$chr) = @_; 
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
	
	my %outGeneHOH;
	my %ensHOH;
	my $ensCount=0;
	my $outCount=0;
	
	
	if(@smncList>0){
		my $cntSmnc=0;
		foreach my $tmpSmnc (@smncList){
			$outGeneHOH{smnc}[$outCount]=$smncHOH{smnc}[$cntSmnc];
			$outCount++;
			$cntSmnc++;
		}
	}
	if(@geneList>0){
		my $cntGenes=0;
		foreach my $tmpGene (@geneList){
			my $gLen=$geneHOH{Gene}[$cntGenes]{stop}-$geneHOH{Gene}[$cntGenes]{start};
			$gLen=abs($gLen);
			
			if($gLen<200){
				$ensHOH{smnc}[$ensCount]=$geneHOH{Gene}[$cntGenes];
				$ensCount++;
				$outGeneHOH{smnc}[$outCount]=$geneHOH{Gene}[$cntGenes];
				$outCount++;
			}
			$cntGenes=$cntGenes+1;
		}
	}
	
	my $outListRef=$outGeneHOH{smnc};
	my @outList=();
	eval{
		@outList=@$outListRef;
	}or do{
		@outList=();
	};
	
	my @sortedlist = sort { $a->{start} <=> $b->{start} } @outList;
	$outGeneHOH{smnc}=\@sortedlist;
	
	open OFILE, '>'.$combinedoutputFile or die " Could not open two track file $combinedoutputFile for writing $!\n\n";
	my $xml = new XML::Simple (RootName=>'smallRNAList');
	my $data = $xml->XMLout(\%outGeneHOH);
	print OFILE $data;
	close OFILE;
	
	$outListRef=$smncHOH{smnc};
	@outList=();
	eval{
		@outList=@$outListRef;
	}or do{
		@outList=();
	};
	
	@sortedlist = sort { $a->{start} <=> $b->{start} } @outList;
	my %outsmncHOH;
	$outsmncHOH{smnc}=\@sortedlist;
	
	open OFILE, '>'.$smncoutputFile or die " Could not open two track file $smncoutputFile for writing $!\n\n";
	$xml = new XML::Simple (RootName=>'smallRNAList');
	$data = $xml->XMLout(\%outsmncHOH);
	print OFILE $data;
	close OFILE;
	
	$outListRef=$ensHOH{smnc};
	@outList=();
	eval{
		@outList=@$outListRef;
	}or do{
		@outList=();
	};
	
	@sortedlist = sort { $a->{start} <=> $b->{start} } @outList;
	my %outensHOH;
	$outensHOH{smnc}=\@sortedlist;
	
	open OFILE, '>'.$ensoutputFile or die " Could not open two track file $ensoutputFile for writing $!\n\n";
	$xml = new XML::Simple (RootName=>'smallRNAList');
	$data = $xml->XMLout(\%outensHOH);
	print OFILE $data;
	close OFILE;
	
	
	return 1;
}

sub createFilteredProbesetTrackXML{
	my($tissueProbesRef, $outputFile,$trackDB,$chr) = @_; 
	my %tissueProbes=%$tissueProbesRef;
	open OFILE, '>'.$outputFile or die " Could not open two track file $outputFile for writing $!\n\n";
	
	my $coreColor="255,0,0";
	my $fullColor="0,100,0";
	my $extendedColor="0,0,255";
	my $ambiguousColor="0,0,0";
	my $cntColor=0;
	foreach my $key (keys %tissueProbes){
		print OFILE 'track db='.$trackDB." name=\"Probesets above background in $key\" ";
		print OFILE "description=\"Probe sets from Affymetrix Exon Array 1.0 ST detected above background in $key: Red=Core Blue=Extended Green=Full Black=Ambiguous\" ";
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
			}elsif($tissueProbes{$key}{pslist}[$curInd]{level} eq 'full'){
				$color=$fullColor;
			}else{
				$color=$ambiguousColor;
			}
			print OFILE "chr$chr\t".$tissueProbes{$key}{pslist}[$curInd]{start}."\t".$tissueProbes{$key}{pslist}[$curInd]{stop}."\t".$tissueProbes{$key}{pslist}[$curInd]{ID}."\t$score\t$strand\t".$tissueProbes{$key}{pslist}[$curInd]{start}."\t".$tissueProbes{$key}{pslist}[$curInd]{stop}."\t".$color."\n";
			$curInd++;
		}
		$cntColor++;
	}
	close OFILE;
	
}

sub createProbesetXMLTrack{
	my($nonMaskedProbesRef, $outputFile) = @_; 
	my @nonMaskedProbes=@$nonMaskedProbesRef;
	open OFILE, '>'.$outputFile or die " Could not open two track file $outputFile for writing $!\n\n";
	my %outGeneHOH;
	my $outCount=0;
	if(@nonMaskedProbes>0){
		foreach my $tmpProbe (@nonMaskedProbes){
			$outGeneHOH{probe}[$outCount]=$tmpProbe;
			$outCount++;
		}
		my $outListRef=$outGeneHOH{probe};
		my @outList=();
		eval{
			@outList=@$outListRef;
		}or do{
			@outList=();
		};
	
		my @sortedlist = sort { $a->{start} <=> $b->{start} } @outList;
		#print "sorted List:".@sortedlist."\n";
		$outGeneHOH{probe}=\@sortedlist;
		
		my $xml = new XML::Simple (RootName=>'probeList');
		my $data = $xml->XMLout(\%outGeneHOH);
		print OFILE $data;
	}
	
	close OFILE;
	
}


sub createNumberedExonXMLTrack{
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
sub createStrandedCodingXMLTrack{
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
			my $biotype=$GeneHOH{Gene}[$cntGenes]{biotype};
			if($strand==$curStrand and $biotype eq "protein_coding"){
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
				if($GeneHOH{Gene}[$cntGenes]{source} eq "Ensembl"){
					$color="223,193,132";
				}else{
					$color="126,181,214";
				}
				#if($strand==-1){
				#	$color="0,0,255";
				#}elsif($strand==0){
				#	$color="0,0,0";
				#}
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
sub createRNACountXMLTrack{
	my($helicosHOHRef, $outputFile) = @_; 
	my %helicosHOH = %$helicosHOHRef;
	open OFILE, '>'.$outputFile or die " Could not open two track file $outputFile for writing $!\n\n";
	my $xml = new XML::Simple (RootName=>'RNACountList');
	my $data = $xml->XMLout(\%helicosHOH);
	print OFILE $data;
	close OFILE;
	return 1;
}
sub createRefSeqXMLTrack{
	my($refSeqHOHRef, $outputFile) = @_; 
	my %refSeqHOH = %$refSeqHOHRef;
	open OFILE, '>'.$outputFile or die " Could not open two track file $outputFile for writing $!\n\n";
	my $xml = new XML::Simple (RootName=>'GeneList');
	my $data = $xml->XMLout(\%refSeqHOH);
	print OFILE $data;
	close OFILE;
	return 1;
}
sub createGenericXMLTrack{
	my($trackHOHRef, $outputFile) = @_; 
	my %trackHOH = %$trackHOHRef;
	open OFILE, '>'.$outputFile or die " Could not open xml file $outputFile for writing $!\n\n";
	my $xml = new XML::Simple (RootName=>'FeatureList');
	my $data = $xml->XMLout(\%trackHOH);
	print OFILE $data;
	close OFILE;
	return 1;
}

sub createLiverTotalXMLTrack{
	my($GeneHOHRef, $outputFile) = @_; 
	# Dereference the hash and array
	my %GeneHOH = %$GeneHOHRef;
	open OFILE, ">".$outputFile or die " Could not open two track file $outputFile for writing $!\n\n";
	my $xml = new XML::Simple (RootName=>'GeneList');
	my $data = $xml->XMLout(\%GeneHOH);
	print OFILE $data;
	close OFILE;
		return 1;
} # End of

1;