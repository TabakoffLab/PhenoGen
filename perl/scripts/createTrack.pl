#!/usr/bin/perl

use strict;

use Math::Round;



sub createTrackFile{
	# INPUT VARIABLES
	# Reference to Gene Hash of Hash used to create xml file in routine writeXML_region.pl
	# Counter for which gene we are on.
	# Name of bed file to create
	
	

	# Read inputs
	my($GeneHOHRef, $cntGenes,  $twoTrackOutputFileName, $species) = @_; 
	# Dereference the hash and array
	my %GeneHOH = %$GeneHOHRef;

	my $geneName=$GeneHOH{Gene}[$cntGenes]{ID};
	my $trackDB="mm9";
	my $orgBB="mouseBigBed.bb";
	
	if($species eq 'Rat'){
		$trackDB="rn5";
		$orgBB="none";
	}
	
	# Write out file with tracks
	my $newTwoTrackOutputFileName = '>'.$twoTrackOutputFileName;
	open TWOFILE, $newTwoTrackOutputFileName or die " Could not open two track file $newTwoTrackOutputFileName for writing $!\n\n";
	
	print TWOFILE "browser hide all\n";
	if($orgBB eq "mouseBigBed.bb"){
		print TWOFILE "track db=$trackDB type=bigBed priority=1 name='Affy".$species."Probesets' ";
		print TWOFILE 'description="Probesets from Affymetrix Exon 1.0 ST Array: Red=Core Green=Full Blue=Extended" ';
		print TWOFILE 'visibility=3 itemRgb=On bigDataUrl=http://ucsc:JU7etr5t@phenogen.ucdenver.edu/ucsc/'.$orgBB."\n";
	}else{
		##########TODO:add probesets from DB
	}
	print TWOFILE "track db=$trackDB priority=2 name='".$geneName." Transcripts' ";
	print TWOFILE 'description="Transcripts for Gene:'.$geneName.'" ';
	print TWOFILE "visibility=3 itemRgb=Off \n";
	
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
		}
		my $trname=$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{ID};
		$trname  =~ s/ /_/g;
		print TWOFILE "chr$chr\t$trstart\t$trstop\t$trname\t0\t$convStrand\t$trstart\t$trstop\t0,0,0\t";
		my $tmpLens="";
		my $tmpStarts="";
		foreach(@exonArray){
			my $currentExonStart = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{start};
			my $currentExonStop = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{stop};
			# find out if this exon is already in exonHOH
			my $relStart=$currentExonStart-$trstart;
			
			my $tmpLen=$currentExonStop-$currentExonStart;
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
		print TWOFILE "$cntExons\t$tmpLens\t$tmpStarts\n";
		$cntTranscripts++;
	}
	
	
	
	my @sortedExonHOH;
	if($strand ==-1){
		@sortedExonHOH = sort { $b->{start} <=> $a->{start} || $a->{stop} <=> $b->{stop}} @exonHOH;
	}else{
		@sortedExonHOH = sort { $a->{start} <=> $b->{start} || $a->{stop} <=> $b->{stop}} @exonHOH;
	}
	if(@sortedExonHOH>0){
			print TWOFILE 'track db='.$trackDB.' priority=1 name="Numbered Exons" ';
			print TWOFILE 'description="Numbered Exons for the Transcripts" ';
			print TWOFILE 'visibility=3 colorByStrand="255,0,0 0,0,255"'."\n";
			my $curIndex=0;
			foreach(@sortedExonHOH){
				my $start=$sortedExonHOH[$curIndex]{start};
				my $stop=$sortedExonHOH[$curIndex]{stop};
				my $name=$sortedExonHOH[$curIndex]{alternateID2};
				print TWOFILE "chr$chr\t$start\t$stop\t$name\t0\t$convStrand\n";	
				$curIndex++;
			}
	}	
	
	close TWOFILE;
	
	
	return 1;
	
} # End of 

sub createTrackFileRegion{
	# INPUT VARIABLES
	# Reference to Gene Hash of Hash used to create xml file in routine writeXML.pl
	# Counter for which gene we are on.
	# Name of bed file to create
	
	

	# Read inputs
	my($GeneHOHRef, $qtlHOHRef, $twoTrackOutputFileName, $species, $includeTranscripts, $includeArray, $includeHuman, $chr, $minCoord, $maxCoord) = @_; 
	# Dereference the hash and array
	my %GeneHOH = %$GeneHOHRef;
	my $geneListRef=$GeneHOH{Gene};
	my %qtlHOH = %$qtlHOHRef;
	my $qtlListRef=$qtlHOH{QTL};
	
	my @geneList=();
	eval{
		@geneList=@$geneListRef;
	}or do{
		@geneList=();
	};
	
	my @qtlList=();
	eval{
		@qtlList=@$qtlListRef;
	}or do{
		@qtlList=();
	};
	
	my $trackDB="mm9";
	my $qtlTrack="jaxQtl";
	
	if($species eq 'Rat'){
		$trackDB="rn5";
		$qtlTrack="rgdQtl";
	}
	
	# Write out file with tracks
	my $newTwoTrackOutputFileName = '>'.$twoTrackOutputFileName;
	open TWOFILE, $newTwoTrackOutputFileName or die " Could not open two track file $newTwoTrackOutputFileName for writing $!\n\n";
	print TWOFILE 'browser position chr'.$chr.':'.$minCoord.'-'.$maxCoord."\n";
	print TWOFILE "browser hide all\n";
	print TWOFILE "browser pack refGene\n";
	
	if($includeTranscripts==1){
		print TWOFILE "track db=$trackDB priority=2 name='Transcripts' ";
		print TWOFILE 'description="Transcripts"';
		print TWOFILE "visibility=3 itemRgb=On group='genes' \n";
		if(@geneList>0){
			my $cntGenes=0;
			foreach my $tmpGene (@geneList){
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
					$color="157,17,0";
				}else{
					$color="0,0,255";
				}
				
				foreach(@transcriptArray){
					my $exonArrayRef = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon};
					my @exonArray = @$exonArrayRef;
					my $cntExons = 0;
					if(@exonArray==1){
						$color="0,0,0";
					}
					my $trstart=$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{start};
					my $trstop=$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{stop};
					my $trstrand=$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{strand};
					if($trstrand==1){
						$convStrand="+";
					}elsif($trstrand==-1){
						$convStrand="-";
					}
					my $trname=$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{ID};
					$trname  =~ s/ /_/g;
					my $fulltrname=$geneID.".".$trname;
					if($GeneHOH{Gene}[$cntGenes]{source} eq "Ensembl"){
						$fulltrname=$trname;
					}
					print TWOFILE "chr$chr\t$trstart\t$trstop\t$fulltrname\t0\t$convStrand\t$trstart\t$trstop\t$color\t";
					my $tmpLens="";
					my $tmpStarts="";
					foreach(@exonArray){
						my $currentExonStart = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{start};
						my $currentExonStop = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{stop};
						# find out if this exon is already in exonHOH
						my $relStart=$currentExonStart-$trstart;
						
						my $tmpLen=$currentExonStop-$currentExonStart;
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
					print TWOFILE "$cntExons\t$tmpLens\t$tmpStarts\n";
					$cntTranscripts++;
				}
				$cntGenes=$cntGenes+1;
			}
		}
	}
	
	## These tracks are not available in Rn5.  We'll remove them for now.
	
	
	if($species eq 'Rat'){
		print TWOFILE "track db=$trackDB priority=3 name='bQTLs' ";
		print TWOFILE 'description="bQTLs"';
		print TWOFILE "visibility=3 \n";
		if(@qtlList>0){
			my $cntQTL=0;
			foreach my $tmpQTL (@qtlList){
				my $qtlName=$qtlHOH{QTL}[$cntQTL]{name};
				my $qtlStart=$qtlHOH{QTL}[$cntQTL]{start};
				my $qtlStop=$qtlHOH{QTL}[$cntQTL]{stop};
				print TWOFILE "chr$chr\t$qtlStart\t$qtlStop\t$qtlName\t0\t.\n";
				$cntQTL++;
			}
		}
	}else{
		print TWOFILE "browser pack $qtlTrack\n";
	}
	
	#if($includeArray==1){
		#	print TWOFILE "browser pack affyExonTissues $qtlTrack\n";
	#}else{
	#	print TWOFILE "browser pack $qtlTrack\n";
	#}
	#if($includeHuman==1){
	#	print TWOFILE "browser dense chainNetHg19\n";
	#	print TWOFILE "browser pack blastHg18KG\n";
		#print TWOFILE "browser pack transMapAlnRefSeq\n";
	#}
	close TWOFILE;
	
	
	return 1;
	
} # End of 

sub createTrackFileRegionView{
	# INPUT VARIABLES
	# Reference to Gene Hash of Hash used to create xml file in routine writeXML.pl
	# Counter for which gene we are on.
	# Name of bed file to create
	
	

	# Read inputs
	my($GeneHOHRef,  $twoTrackOutputFileName, $species,$includeProbes,$filterProbes, $chr, $minCoord, $maxCoord,$tissueProbesRef) = @_; 
	# Dereference the hash and array
	my %GeneHOH = %$GeneHOHRef;
	my $geneListRef=$GeneHOH{Gene};
	my %tissueProbes=%$tissueProbesRef;
	
	my @geneList=();
	eval{
		@geneList=@$geneListRef;
	}or do{
		@geneList=();
	};
	
	my $trackDB="mm9";
	my $qtlTrack="jaxQtl";
	my $orgBB="mouseBigBed.bb";
	
	if($species eq 'Rat'){
		$trackDB="rn4";
		$qtlTrack="rgdQtl";
		$orgBB="ratBigBed.bb";
	}
	
	# Write out file with tracks
	my $newTwoTrackOutputFileName = '>'.$twoTrackOutputFileName;
	open TWOFILE, $newTwoTrackOutputFileName or die " Could not open two track file $newTwoTrackOutputFileName for writing $!\n\n";
	print TWOFILE 'browser position chr'.$chr.':'.$minCoord.'-'.$maxCoord."\n";
	print TWOFILE "browser hide all\n";
	print TWOFILE "browser pack refGene\n";
	if($includeProbes==1){
		if($filterProbes==0){
			print TWOFILE "track db=$trackDB type=bigBed priority=1 name='Affy".$species."Probesets' ";
			print TWOFILE 'description="Probesets from Affymetrix Exon 1.0 ST Array: Red=Core Green=Full Blue=Extended" ';
			print TWOFILE 'visibility=3 itemRgb=On bigDataUrl=http://ucsc:JU7etr5t@phenogen.ucdenver.edu/ucsc/'.$orgBB."\n";
		}else{
			my $coreColor="255,0,0";
			my $fullColor="0,100,0";
			my $extendedColor="0,0,255";
			my $cntColor=0;
			foreach my $key (keys %tissueProbes){
				print TWOFILE 'track db='.$trackDB." name=\"Probesets above background in $key\" ";
				print TWOFILE "description=\"Affy Exon Probesets detected above background in $key: Red=Core Blue=Extended Green=Full\" ";
				print TWOFILE 'visibility=3 itemRgb=On'."\n"; #removed useScore=1
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
					print TWOFILE "chr$chr\t".$tissueProbes{$key}{pslist}[$curInd]{start}."\t".$tissueProbes{$key}{pslist}[$curInd]{stop}."\t".$tissueProbes{$key}{pslist}[$curInd]{ID}."\t$score\t$strand\t".$tissueProbes{$key}{pslist}[$curInd]{start}."\t".$tissueProbes{$key}{pslist}[$curInd]{stop}."\t".$color."\n";
					$curInd++;
				}
				$cntColor++;
			}
		}
	}
		print TWOFILE "track db=$trackDB priority=2 name='Transcripts' ";
		print TWOFILE 'description="Transcripts"';
		print TWOFILE "visibility=3 itemRgb=On group='genes' \n";
		if(@geneList>0){
			my $cntGenes=0;
			foreach my $tmpGene (@geneList){
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
					$color="157,17,0";
				}else{
					$color="0,0,255";
				}
				
				foreach(@transcriptArray){
					my $exonArrayRef = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon};
					my @exonArray = @$exonArrayRef;
					my $cntExons = 0;
					if(@exonArray==1){
						$color="0,0,0";
					}
					my $trstart=$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{start};
					my $trstop=$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{stop};
					my $trstrand=$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{strand};
					if($trstrand==1){
						$convStrand="+";
					}elsif($trstrand==-1){
						$convStrand="-";
					}
					my $trname=$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{ID};
					$trname  =~ s/ /_/g;
					my $fulltrname=$geneID.".".$trname;
					if($GeneHOH{Gene}[$cntGenes]{source} eq "Ensembl"){
						$fulltrname=$trname;
					}
					print TWOFILE "chr$chr\t$trstart\t$trstop\t$fulltrname\t0\t$convStrand\t$trstart\t$trstop\t$color\t";
					my $tmpLens="";
					my $tmpStarts="";
					foreach(@exonArray){
						my $currentExonStart = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{start};
						my $currentExonStop = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{stop};
						# find out if this exon is already in exonHOH
						my $relStart=$currentExonStart-$trstart;
						
						my $tmpLen=$currentExonStop-$currentExonStart;
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
					print TWOFILE "$cntExons\t$tmpLens\t$tmpStarts\n";
					$cntTranscripts++;
				}
				$cntGenes=$cntGenes+1;
			}
		}
	close TWOFILE;
	
	
	return 1;
	
} # End of 

return 1;