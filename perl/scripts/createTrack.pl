#!/usr/bin/perl

# PERL MODULES WE WILL BE USIN
use strict;




sub createTrackFile{
	# INPUT VARIABLES
	# Reference to Gene Hash of Hash used to create xml file in routine writeXML.pl
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
		$trackDB="rn4";
		$orgBB="ratBigBed.bb";
	}
	
	# Write out file with tracks
	my $newTwoTrackOutputFileName = '>'.$twoTrackOutputFileName;
	open TWOFILE, $newTwoTrackOutputFileName or die " Could not open two track file $newTwoTrackOutputFileName for writing $!\n\n";
	
	print TWOFILE "browser hide all\n";
	print TWOFILE "track db=$trackDB type=bigBed priority=1 name='Affy".$species."Probesets' ";
	print TWOFILE 'description="Probesets from Affymetrix Exon 1.0 ST Array: Red=Core Green=Full Blue=Extended" ';
	print TWOFILE 'visibility=3 itemRgb=On bigDataUrl=http://ucsc:JU7etr5t@phenogen.ucdenver.edu/ucsc/'.$orgBB."\n";
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
	my($GeneHOHRef,  $twoTrackOutputFileName, $species, $includeTranscripts, $includeArray, $chr, $minCoord, $maxCoord) = @_; 
	# Dereference the hash and array
	my %GeneHOH = %$GeneHOHRef;
	my $geneListRef=$GeneHOH{Gene};
	my @geneList=@$geneListRef;
	
	my $trackDB="mm9";
	my $qtlTrack="";
	
	if($species eq 'Rat'){
		$trackDB="rn4";
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
	if($includeArray==1){
		print TWOFILE "browser pack affyExonTissues $qtlTrack\n";
	}else{
		print TWOFILE "browser pack $qtlTrack\n";
	}
	close TWOFILE;
	
	
	return 1;
	
} # End of 

return 1;