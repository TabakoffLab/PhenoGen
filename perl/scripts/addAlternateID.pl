#!/usr/bin/perl

# PERL MODULES WE WILL BE USING
#use Data::Dumper qw(Dumper); # for testing to dump out the big hash
use Data::Dumper;
use Text::CSV;
use Math::Round;
use strict;




sub addAlternateID{
	# INPUT VARIABLES
	# Reference to Gene Hash of Hash used to create xml file in routine writeXML.pl
	# Counter for which gene we are on.
	# Name of bed file to create
	
	my $debugging = 0; # Set this variable to 1 or 2 to print out debugging information

	# Read inputs
	my($GeneHOHRef, $cntGenes, $bedOutputFileName, $twoTrackOutputFileName, $bigBedOutputFileName,$species) = @_; 
	# Dereference the hash and array
	my %GeneHOH = %$GeneHOHRef;
	
	
	# Make an array of hashes for exons corresponding to the current gene.
	
	my @exonHOH;
	
	# Define some arrays
	my @exonArray;
	my $exonArrayRef;
	# There is one transcript array corresponding to the current gene.
	my $transcriptArrayRef = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript};
	my @transcriptArray = @$transcriptArrayRef;
	if($debugging >= 1){
		print " Number of Transcripts ";
		print scalar @transcriptArray;
		print "\n";
	}
	# loop through GeneHOH to get information about all exons associated with this gene
	my $currentExonID;
	my $cntHOHExons = 0;
	my $cnt;
	my $cntExons;
	my $alreadyIncluded = 0;
	
	my $cntTranscripts = 0;
	foreach(@transcriptArray){
		$exonArrayRef = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon};
		@exonArray = @$exonArrayRef;
		$cntExons = 0;
		foreach(@exonArray){
			$currentExonID = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{ID};
			# find out if this exon is already in exonHOH
			$alreadyIncluded = 0;
			for($cnt=0; $cnt < $cntHOHExons; $cnt++){
				if($exonHOH[$cnt]{ID} eq $currentExonID){
					$alreadyIncluded = 1;
				}
			}
			if($alreadyIncluded == 0){
				# Add this exon to the exonHOH
				$exonHOH[$cntHOHExons]{ID} = $currentExonID;
				$exonHOH[$cntHOHExons]{start} =  $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{start};
				$exonHOH[$cntHOHExons]{stop} =  $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{stop};
				$exonHOH[$cntHOHExons]{coding_start} =  $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{coding_start};
				$exonHOH[$cntHOHExons]{coding_stop} =  $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{coding_stop};
				$exonHOH[$cntHOHExons]{strand} =  $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{strand};
				$exonHOH[$cntHOHExons]{chromosome} =  $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{chromosome};
				$cntHOHExons = $cntHOHExons + 1;
			}
			$cntExons = $cntExons + 1;
		}
		$cntTranscripts = $cntTranscripts + 1;
	}
	
	if($debugging >= 1){
		print "Length of unsorted exon HOH \n";
		print scalar(@exonHOH);
		print "\n";
	}
	if($debugging == 2){
		print "dumping data in exon array \n";
		print Dumper(\@exonHOH);
		print "end of dumping data in exon array \n"
	}
	# sort the exonHOH by the start location
	my @sortedExonHOH;
	@sortedExonHOH = sort { $a->{start} <=> $b->{start} } @exonHOH;
	if($debugging >= 1){
		print "Length of sorted exon HOH \n";
		print scalar(@sortedExonHOH);
		print "\n";
	}
	
	
	# define an array of exons with an initial definition for alternateID
	# The first definition does not take into account whether exons overlap
	my $cntExons = 0;
	foreach(@sortedExonHOH){
		$sortedExonHOH[$cntExons]{alternateID1} = $cntExons + 1;
		$cntExons = $cntExons + 1;
	}

	# Now take overlapping into consideration...
	# Exons should have the same number if they overlap
	my $totalExons = scalar @sortedExonHOH;
	my $cnt1;
	my $cnt2;
	for ($cnt1 = 0; $cnt1 < $totalExons; $cnt1++){
		# set alternateID2 equal to alternateID1
		$sortedExonHOH[$cnt1]{alternateID2} = $sortedExonHOH[$cnt1]{alternateID1};
	}
	if($debugging == 2){
		print "dumping data in exon array \n";
		print Dumper(\@sortedExonHOH);
		print "end of dumping data in exon array \n"
	}
	for ($cnt1=0; $cnt1 < $totalExons; $cnt1++){
		$sortedExonHOH[$cnt1]{overlaps} = 0;
		for($cnt2=$cnt1+1; $cnt2 < $totalExons; $cnt2++){
			if($sortedExonHOH[$cnt1]{start} > $sortedExonHOH[$cnt2]{start}){
				# This shouldn't happen since sortedExonHOH is sorted by the start value
				print " Something is wrong \n";
			}
			if($sortedExonHOH[$cnt1]{stop} >= $sortedExonHOH[$cnt2]{start}){
				# These two exons overlap
				if ($sortedExonHOH[$cnt1]{alternateID1} < $sortedExonHOH[$cnt2]{alternateID2}){
					$sortedExonHOH[$cnt2]{alternateID2} = $sortedExonHOH[$cnt1]{alternateID1};
				}
			}
		}
	}
	# Shift alternateID2 if there are gaps
	my $gapLevel = 0;
	my $previousAlternateID2 = 0;
	for ($cnt1=0; $cnt1 < $totalExons; $cnt1++){
		$gapLevel = $sortedExonHOH[$cnt1]{alternateID2} - $previousAlternateID2;
		if($gapLevel >= 2){
			# Shift
			for($cnt2=$cnt1; $cnt2 < $totalExons; $cnt2++){
				$sortedExonHOH[$cnt2]{alternateID2} = $sortedExonHOH[$cnt2]{alternateID2} - $gapLevel + 1;
				$sortedExonHOH[$cnt2]{alternateID1} = $sortedExonHOH[$cnt2]{alternateID1} - $gapLevel + 1;
			}
		} # end if
		$previousAlternateID2 = $sortedExonHOH[$cnt1]{alternateID2};
	}
	# Count Overlaps
	for ($cnt1=0; $cnt1 < $totalExons; $cnt1++){
		for($cnt2=0; $cnt2 < $totalExons; $cnt2++){
			if($sortedExonHOH[$cnt1]{alternateID2} == $sortedExonHOH[$cnt2]{alternateID2}){
				$sortedExonHOH[$cnt1]{overlaps} = $sortedExonHOH[$cnt1]{overlaps} + 1
			}
		}
	}
	# Modify alternate ID2
	
	my $tmpdiff;
	for ($cnt1 = 0; $cnt1 < $totalExons; $cnt1++){
		$tmpdiff = $sortedExonHOH[$cnt1]{alternateID1} - $sortedExonHOH[$cnt1]{alternateID2};
		if($sortedExonHOH[$cnt1]{overlaps} > 1){
			$sortedExonHOH[$cnt1]{alternateID2} = $sortedExonHOH[$cnt1]{alternateID2} . chr($tmpdiff + 97);
		}
	}
	# Write out the Bed file
	my $newBedOutputFileName = '>'.$bedOutputFileName;
	if($debugging >= 1){
		print $newBedOutputFileName;
		print "\n";
	}
	open BEDFILE, $newBedOutputFileName or die " Could not open BED file $bedOutputFileName for writing $!\n\n";
	# write the browser information
	my $geneStartSmaller = $GeneHOH{Gene}[$cntGenes]{start}-200;
	my $geneStopBigger = $GeneHOH{Gene}[$cntGenes]{stop}+200;
	my $writeHeader = 0; # since we are creating a separate file with tracks we don't need the header here.
	if($writeHeader == 1){
		print BEDFILE 'browser position '.$GeneHOH{Gene}[$cntGenes]{chromosome}.':'.$geneStartSmaller.'-'.$geneStopBigger;
		print BEDFILE "\n";
		print BEDFILE 'browser hide all';
		print BEDFILE "\n";
		# write the track information
		print BEDFILE 'track name=Exon_'.$GeneHOH{Gene}[$cntGenes]{ID}.' description="Exons for Gene '.$GeneHOH{Gene}[$cntGenes]{ID}.'" visibility=2 itemRbg=On';
		print BEDFILE "\n";
	}
	# loop through exons writing a line for each exon
	for($cnt = 0; $cnt < $totalExons; $cnt++){
		print BEDFILE $sortedExonHOH[$cnt]{chromosome}."\t";
		print BEDFILE $sortedExonHOH[$cnt]{start}."\t";
		print BEDFILE $sortedExonHOH[$cnt]{stop}."\t";
		print BEDFILE $sortedExonHOH[$cnt]{alternateID2}."\t";
		if($sortedExonHOH[$cnt]{strand} == 1){
			print BEDFILE "0\t+\t";
		}
		else{
			print BEDFILE "0\t-\t ";
		}
		print BEDFILE $sortedExonHOH[$cnt]{start}."\t";
		print BEDFILE $sortedExonHOH[$cnt]{stop}."\t";	
		print BEDFILE "255,0,0";
		print BEDFILE "\n";
	}
	close BEDFILE;	
	# Write out file with 2 tracks
	my $newTwoTrackOutputFileName = '>'.$twoTrackOutputFileName;
	open TWOFILE, $newTwoTrackOutputFileName or die " Could not open two track file $newTwoTrackOutputFileName for writing $!\n\n";
	print TWOFILE "browser hide all\n";	
	print TWOFILE "browser pack ensGene knownGene\n";
	if($species eq 'Mouse'){
		print TWOFILE 'track db=mm9 type=bigBed name="AffyMouseProbesets" ';
		print TWOFILE 'description="Affy Mouse Exon Probesets: Red=Core Blue=Extended Green=Full" ';
		print TWOFILE 'visibility=3 itemRgb=On bigDataUrl=http://ucsc:JU7etr5t@phenogen.ucdenver.edu/ucsc/mouseBigBed.bb'."\n";
		print TWOFILE 'track db=mm9 type=bigBed name="Exons_';
		print TWOFILE $GeneHOH{Gene}[$cntGenes]{ID}.'" ';
		print TWOFILE 'description="Exons For Gene '.$GeneHOH{Gene}[$cntGenes]{ID}.'" visibility=3 itemRgb=On bigDataUrl=';
		print TWOFILE 'http://ucsc:JU7etr5t@phenogen.ucdenver.edu/ucsc/'.$bigBedOutputFileName;
		
	}
	elsif($species eq 'Rat'){
		
		print TWOFILE 'track db=rn4 type=bigBed name="AffyRatProbesets" ';
		print TWOFILE 'description="Affy Rat Exon Probesets: Red=Core Green=Full Blue=Extended" ';
		print TWOFILE 'visibility=3 itemRgb=On bigDataUrl=http://ucsc:JU7etr5t@phenogen.ucdenver.edu/ucsc/ratBigBed.bb'."\n";
		print TWOFILE 'track db=rn4 type=bigBed name="Exons_';
		print TWOFILE $GeneHOH{Gene}[$cntGenes]{ID}.'" ';
		print TWOFILE 'description="Exons For Gene '.$GeneHOH{Gene}[$cntGenes]{ID}.'" visibility=3 itemRgb=On bigDataUrl=';
		print TWOFILE 'http://ucsc:JU7etr5t@phenogen.ucdenver.edu/ucsc/'.$bigBedOutputFileName;
	}
	close TWOFILE;
	# Now we have to put these IDs into the gene hash

	# Define some counters
	my $cntTranscripts2 = 0;
	my $cntExons2 = 0;
	my $cntSortedExons = 0;

	my $tmpExonID;
	
	$cntTranscripts2 = 0;
	foreach(@transcriptArray){
		$exonArrayRef = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts2]{exonList}{exon};
		@exonArray = @$exonArrayRef;
		$cntExons2 = 0;
		foreach(@exonArray){
			# Try to match this exon with an exon in the array @sortedExonHOH				
			$tmpExonID = $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts2]{exonList}{exon}[$cntExons2]{ID};
			$cntSortedExons = 0;
			foreach(@sortedExonHOH){
				if($tmpExonID eq $sortedExonHOH[$cntSortedExons]{ID}){
					$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts2]{exonList}{exon}[$cntExons2]{alternateID1} = 
					$sortedExonHOH[$cntSortedExons]{alternateID1};
					$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts2]{exonList}{exon}[$cntExons2]{alternateID2} = 
					$sortedExonHOH[$cntSortedExons]{alternateID2};
				} # end if -- exon ID's match
				$cntSortedExons = $cntSortedExons + 1;
			} # end loop over sorted exons
			if($debugging >= 1){
				print 	$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts2]{exonList}{exon}[$cntExons2]{ID};
				print " ";
				print 	$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts2]{exonList}{exon}[$cntExons2]{start};
				print " ";
				print 	$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts2]{exonList}{exon}[$cntExons2]{stop};
				print " ";
				print 	$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts2]{exonList}{exon}[$cntExons2]{overlaps};
				print " ";
				print 	$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts2]{exonList}{exon}[$cntExons2]{alternateID1};
				print " ";
				print 	$GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts2]{exonList}{exon}[$cntExons2]{alternateID2};
				print "\n";
			} # end if -- debugging >= 1
			$cntExons2 = $cntExons2 + 1;
		} # Loop over Exons
		$cntTranscripts2 = $cntTranscripts2 + 1;
	} # Loop over transcripts

	return (\%GeneHOH);
	
} # End of addAlternateID


sub addAlternateID_RNA{
	# INPUT VARIABLES
	# Reference to Gene Hash of Hash used to create xml file in routine writeXML.pl
	# Counter for which gene we are on.
	# Name of bed file to create
	
	my $debugging = 2; # Set this variable to 1 or 2 to print out debugging information

	# Read inputs
	my($GeneHOHRef, $bedOutputFileName, $twoTrackOutputFileName, $filterTrackOutputFileName,$bigBedOutputFileName,$species,$minCoord,$maxCoord,$tissueProbesRef) = @_; 
	# Dereference the hash and array
	my %GeneHOH = %$GeneHOHRef;
	my %tissueProbes=%$tissueProbesRef;
	
	# Make an array of hashes for exons corresponding to the genes on current strand
	
	my @exonHOHplus;
	my @exonHOHminus;
	my @exonHOHunkw;
	my $cntHOHExonsPlus = 0;
	my $cntHOHExonsMinus = 0;
	my $cntHOHExonsUnkw = 0;
	
	# Define some arrays
	my @exonArray;
	my $exonArrayRef;
	
	my $cntGene=0;
	my $geneArrayRef = $GeneHOH{Gene};
	my @geneArray = @$geneArrayRef;
	my $chr=$GeneHOH{Gene}[0]{chromosome};
	
	if(index($chr,"chr")>-1){
		$chr=substr($chr,3);
	}
	
	print " Number of Genes ";
	print scalar @geneArray;
	print "\n";
	
	my @genesProcessed=();
	
	foreach(@geneArray){
		$genesProcessed[$cntGene]=0;
		$cntGene++;
	}
	my $allGenesProcessed=0;
	while($allGenesProcessed==0){
		$allGenesProcessed=1;
		$cntGene=0;
		my $curGeneStrand="";
		my $curStart=0;
		my $curStop=0;
		my @exonHOH;
		my $cntHOHExons = 0;
		# loop through GeneHOH to get information about all exons associated with genes on strand
		foreach(@geneArray){
			print "process gene id:".$GeneHOH{Gene}[$cntGene]{ID}." strand:".$GeneHOH{Gene}[$cntGene]{strand}." ".$GeneHOH{Gene}[$cntGene]{start}."-".$GeneHOH{Gene}[$cntGene]{stop}."\n";
			if($genesProcessed[$cntGene]==0){
				$allGenesProcessed=0;
				my $include=0;
				my $currentGeneStrand=$GeneHOH{Gene}[$cntGene]{strand};
				my $currentStart=$GeneHOH{Gene}[$cntGene]{start};
				my $currentStop=$GeneHOH{Gene}[$cntGene]{stop};
				if($curGeneStrand eq ""){
					print "include gene id:".$GeneHOH{Gene}[$cntGene]{ID}."\nstrand:".$GeneHOH{Gene}[$cntGene]{strand}."\n".$GeneHOH{Gene}[$cntGene]{start}."-".$GeneHOH{Gene}[$cntGene]{stop}."\n";
					$include=1;
					$curGeneStrand=$currentGeneStrand;
					$curStart=$currentStart;
					$curStop=$currentStop;
				}else{
					if(($curGeneStrand eq $currentGeneStrand)&&
					   (($currentStart>=$curStart&&$currentStart<=$curStop)||
					    ($currentStop>=$curStart&&$currentStop<=$curStop))){
						print "include gene id:".$GeneHOH{Gene}[$cntGene]{ID}."\nstrand:".$GeneHOH{Gene}[$cntGene]{strand}."\n".$GeneHOH{Gene}[$cntGene]{start}."-".$GeneHOH{Gene}[$cntGene]{stop}."\n";
						$include=1;
					}else{
						print "exclude gene id:".$GeneHOH{Gene}[$cntGene]{ID}."\nstrand:".$GeneHOH{Gene}[$cntGene]{strand}."\n".$GeneHOH{Gene}[$cntGene]{start}."-".$GeneHOH{Gene}[$cntGene]{stop}."\n";
					}
				}
				
				if($include==1){
					$genesProcessed[$cntGene]=1;
					print "gene id:".$GeneHOH{Gene}[$cntGene]{ID}."\nstrand:".$GeneHOH{Gene}[$cntGene]{strand}."\n";
					if($GeneHOH{Gene}[$cntGene]{ID} eq ""){
						
					}else{
						# There is one transcript array corresponding to the current gene.
						my $transcriptArrayRef = $GeneHOH{Gene}[$cntGene]{TranscriptList}{Transcript};
						my @transcriptArray = @$transcriptArrayRef;
						#if($debugging >= 1){
						#	print " Number of Transcripts ";
						#	print scalar @transcriptArray;
						#	print "\n";
						#}
						
						my $currentExonStart;
						my $currentExonStop;
						
						
						my $cnt;
						my $cntExons;
						my $alreadyIncluded = 0;
						
						my $cntTranscripts = 0;
						foreach(@transcriptArray){
							$exonArrayRef = $GeneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon};
							@exonArray = @$exonArrayRef;
							$cntExons = 0;
							foreach(@exonArray){
								$currentExonStart = $GeneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{start};
								$currentExonStop = $GeneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{stop};
								# find out if this exon is already in exonHOH
								$alreadyIncluded = 0;
								for($cnt=0; $cnt < $cntHOHExons; $cnt++){
									if($exonHOH[$cnt]{start} == $currentExonStart && $exonHOH[$cnt]{stop} == $currentExonStop ){
										$alreadyIncluded = 1;
									}
								}	
								
								#print 	$GeneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{ID}." include $alreadyIncluded\n";
								if($alreadyIncluded == 0){
									# Add this exon to the exonHOH
									$exonHOH[$cntHOHExons]{ID} = $GeneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{ID};
									$exonHOH[$cntHOHExons]{start} =  $GeneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{start};
									$exonHOH[$cntHOHExons]{stop} =  $GeneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{stop};
									$exonHOH[$cntHOHExons]{coding_start} =  $GeneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{coding_start};
									$exonHOH[$cntHOHExons]{coding_stop} =  $GeneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{coding_stop};
									$exonHOH[$cntHOHExons]{strand} =  $GeneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{strand};
									$exonHOH[$cntHOHExons]{chromosome} =  $GeneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{chromosome};
									$cntHOHExons++;
								}
								$cntExons++;
							}
							$cntTranscripts++;
						}
					}
				}
			}
			$cntGene++;
		}
		my @sortedExonHOH;
		if($curGeneStrand ==-1){
			@sortedExonHOH = sort { $b->{start} <=> $a->{start} || $a->{stop} <=> $b->{stop}} @exonHOH;
		}else{
			@sortedExonHOH = sort { $a->{start} <=> $b->{start} || $a->{stop} <=> $b->{stop}} @exonHOH;
		}
		my $curExonMin=0;
		my $curExonMax=0;
		my $curExonNum=0;
		my $curExonLetter=chr(ord('a'));
		my $curIndex=0;
		
		foreach(@sortedExonHOH){
			my $changePrev=-1;
			my $changeTo="";
			print "process exon ".$sortedExonHOH[$curIndex]{start}."-".$sortedExonHOH[$curIndex]{stop}.":";
			if($curIndex>0){
				my $tmpExonMin=$sortedExonHOH[$curIndex]{start};
				my $tmpExonMax=$sortedExonHOH[$curIndex]{stop};
				if(($tmpExonMin>=$curExonMin && $tmpExonMin<=$curExonMax) ||
				   ($tmpExonMax>=$curExonMin && $tmpExonMax<=$curExonMax)){
					if($curExonLetter eq 'a'){
						print "changing ".$sortedExonHOH[$curIndex-1]{alternateID2}." to ";
						$sortedExonHOH[$curIndex-1]{alternateID2}=$curExonNum.$curExonLetter;
						$changePrev=1;
						$changeTo=$curExonNum.$curExonLetter;
						#print $sortedExonHOH[$curIndex-1]{alternateID2}."\n";
						$curExonLetter=chr(ord($curExonLetter)+1);
						if($tmpExonMin<$curExonMin){
							$curExonMin=$tmpExonMin;
						}
						if($tmpExonMax>$curExonMax){
							$curExonMax=$tmpExonMax;
						}
						$sortedExonHOH[$curIndex]{alternateID2}=$curExonNum.$curExonLetter;
						print $curExonNum.$curExonLetter."\n";
						$curExonLetter=chr(ord($curExonLetter)+1);
					}else{
						if($tmpExonMin<$curExonMin){
							$curExonMin=$tmpExonMin;
						}
						if($tmpExonMax>$curExonMax){
							$curExonMax=$tmpExonMax;
						}
						$sortedExonHOH[$curIndex]{alternateID2}=$curExonNum.$curExonLetter;
						print $curExonNum.$curExonLetter."\n";
						$curExonLetter=chr(ord($curExonLetter)+1);
					}
				}else{
					$curExonMin=$sortedExonHOH[$curIndex]{start};
					$curExonMax=$sortedExonHOH[$curIndex]{stop};
					$curExonNum++;
					$curExonLetter=chr(ord('a'));
					$sortedExonHOH[$curIndex]{alternateID2}=$curExonNum;
					print $curExonNum."\n";
				}
			}else{
				$curExonMin=$sortedExonHOH[$curIndex]{start};
				$curExonMax=$sortedExonHOH[$curIndex]{stop};
				$curExonNum++;
				$sortedExonHOH[$curIndex]{alternateID2}=$curExonNum;
				print $curExonNum."\n";
			}
			#Add to appropriate plus or minus strand
			if($curGeneStrand==1){
				$exonHOHplus[$cntHOHExonsPlus]{ID} = $sortedExonHOH[$curIndex]{ID};
				$exonHOHplus[$cntHOHExonsPlus]{start} =  $sortedExonHOH[$curIndex]{start};
				$exonHOHplus[$cntHOHExonsPlus]{stop} =  $sortedExonHOH[$curIndex]{stop};
				$exonHOHplus[$cntHOHExonsPlus]{coding_start} =  $sortedExonHOH[$curIndex]{coding_start};
				$exonHOHplus[$cntHOHExonsPlus]{coding_stop} =  $sortedExonHOH[$curIndex]{coding_stop};
				$exonHOHplus[$cntHOHExonsPlus]{strand} =  $sortedExonHOH[$curIndex]{strand};
				$exonHOHplus[$cntHOHExonsPlus]{chromosome} =  $sortedExonHOH[$curIndex]{chromosome};
				$exonHOHplus[$cntHOHExonsPlus]{alternateID2} =$sortedExonHOH[$curIndex]{alternateID2};
				if($changePrev>-1){
					$exonHOHplus[$cntHOHExonsPlus-1]{alternateID2} =$changeTo;
				}
				$cntHOHExonsPlus++;
			}elsif($curGeneStrand==-1){
				$exonHOHminus[$cntHOHExonsMinus]{ID} = $sortedExonHOH[$curIndex]{ID};
				$exonHOHminus[$cntHOHExonsMinus]{start} =  $sortedExonHOH[$curIndex]{start};
				$exonHOHminus[$cntHOHExonsMinus]{stop} =  $sortedExonHOH[$curIndex]{stop};
				$exonHOHminus[$cntHOHExonsMinus]{coding_start} =  $sortedExonHOH[$curIndex]{coding_start};
				$exonHOHminus[$cntHOHExonsMinus]{coding_stop} =  $sortedExonHOH[$curIndex]{coding_stop};
				$exonHOHminus[$cntHOHExonsMinus]{strand} =  $sortedExonHOH[$curIndex]{strand};
				$exonHOHminus[$cntHOHExonsMinus]{chromosome} =  $sortedExonHOH[$curIndex]{chromosome};
				$exonHOHminus[$cntHOHExonsMinus]{alternateID2} =$sortedExonHOH[$curIndex]{alternateID2};
				if($changePrev>-1){
					$exonHOHminus[$cntHOHExonsMinus-1]{alternateID2} =$changeTo;
				}
				$cntHOHExonsMinus++;
			}else{
				$exonHOHunkw[$cntHOHExonsUnkw]{ID} = $sortedExonHOH[$curIndex]{ID};
				$exonHOHunkw[$cntHOHExonsUnkw]{start} =  $sortedExonHOH[$curIndex]{start};
				$exonHOHunkw[$cntHOHExonsUnkw]{stop} =  $sortedExonHOH[$curIndex]{stop};
				$exonHOHunkw[$cntHOHExonsUnkw]{coding_start} =  $sortedExonHOH[$curIndex]{coding_start};
				$exonHOHunkw[$cntHOHExonsUnkw]{coding_stop} =  $sortedExonHOH[$curIndex]{coding_stop};
				$exonHOHunkw[$cntHOHExonsUnkw]{strand} =  $sortedExonHOH[$curIndex]{strand};
				$exonHOHunkw[$cntHOHExonsUnkw]{chromosome} =  $sortedExonHOH[$curIndex]{chromosome};
				$exonHOHunkw[$cntHOHExonsUnkw]{alternateID2} =$sortedExonHOH[$curIndex]{alternateID2};
				if($changePrev>-1){
					$exonHOHunkw[$cntHOHExonsUnkw-1]{alternateID2} =$changeTo;
				}
				$cntHOHExonsUnkw++;
			}
			$curIndex++;
		}
		
	}
	# sort the exonHOH by the start location
	my @sortedExonHOHplus;
	@sortedExonHOHplus = sort { $a->{start} <=> $b->{start} || $a->{stop} <=> $b->{stop}} @exonHOHplus;
	my @sortedExonHOHunkw;
	@sortedExonHOHunkw = sort { $a->{start} <=> $b->{start} || $a->{stop} <=> $b->{stop}} @exonHOHunkw;
	my @sortedExonHOHminus;
	@sortedExonHOHminus = sort { $a->{start} <=> $b->{start} || $a->{stop} <=> $b->{stop}} @exonHOHminus;
	
	# write the browser information
	my $geneStartSmaller = $minCoord;
	my $geneStopBigger = $maxCoord;
	
	my $trackDB="mm9";
	my $orgBB="mouseBigBed.bb";
	
	if($species eq 'Rat'){
		$trackDB="rn4";
		$orgBB="ratBigBed.bb"
	}
	
	# Write out file with 2 tracks
	my $newTwoTrackOutputFileName = '>'.$twoTrackOutputFileName;
	my $newfilterTrackOutputFileName = '>'.$filterTrackOutputFileName;
	open TWOFILE, $newTwoTrackOutputFileName or die " Could not open two track file $newTwoTrackOutputFileName for writing $!\n\n";
	open FILTERFILE, $newfilterTrackOutputFileName or die " Could not open two track file $newTwoTrackOutputFileName for writing $!\n\n";
	print TWOFILE "browser hide all\n";	
	print TWOFILE "browser pack ensGene refGene\n";
	print FILTERFILE "browser hide all\n";	
	print FILTERFILE "browser pack ensGene refGene\n";
	
		print TWOFILE "track db=$trackDB type=bigBed priority=1 name='Affy".$species."Probesets' ";
		print TWOFILE 'description="Probesets from Affymetrix Exon 1.0 ST Array: Red=Core Green=Full Blue=Extended" ';
		print TWOFILE 'visibility=3 itemRgb=On bigDataUrl=http://ucsc:JU7etr5t@phenogen.ucdenver.edu/ucsc/'.$orgBB."\n";
		if($species eq 'Rat'){
			print TWOFILE 'track db='.$trackDB.' type=bigBed group=ensGene priority=2 name="RNA Assembled Isoforms" ';
			print TWOFILE 'description="Transcriptome reconstruction from brain RNA-Seq data" ';
			print TWOFILE 'visibility=2 colorByStrand="255,0,0 0,0,255" bigDataUrl=http://ucsc:JU7etr5t@phenogen.ucdenver.edu/ucsc/transcripts.allSamples.5.bb'."\n";
		}
		if(@sortedExonHOHplus>0){
			print TWOFILE 'track db='.$trackDB.' group=ensGene priority=1 name="+ Strand Exons" ';
			print TWOFILE 'description="Numbered Exons for the + Strand Transcripts" ';
			print TWOFILE 'visibility=3 colorByStrand="255,0,0 0,0,255"'."\n";
			my $curIndex=0;
			foreach(@sortedExonHOHplus){
				my $start=$sortedExonHOHplus[$curIndex]{start};
				my $stop=$sortedExonHOHplus[$curIndex]{stop};
				my $strand=$sortedExonHOHplus[$curIndex]{strand};
				my $name=$sortedExonHOHplus[$curIndex]{alternateID2};
				print TWOFILE "chr$chr\t$start\t$stop\t$name\t0\t+\n";	
				$curIndex++;
			}
		}
		if(@sortedExonHOHminus>0){
			print TWOFILE 'track db='.$trackDB.' group=ensGene priority=3 name="- Strand Exons" ';
			print TWOFILE 'description="Numbered Exons for the - Strand Transcripts" ';
			print TWOFILE 'visibility=3 colorByStrand="255,0,0 0,0,255"'."\n";
			my $curIndex=0;
			foreach(@sortedExonHOHminus){
				my $start=$sortedExonHOHminus[$curIndex]{start};
				my $stop=$sortedExonHOHminus[$curIndex]{stop};
				my $strand=$sortedExonHOHminus[$curIndex]{strand};
				my $name=$sortedExonHOHminus[$curIndex]{alternateID2};
				print TWOFILE "chr$chr\t$start\t$stop\t$name\t0\t-\n";	
				$curIndex++;
			}
		}
		if(@sortedExonHOHunkw>0){
			print TWOFILE 'track db='.$trackDB.' group=ensGene priority=4 name="Unknown Strand Exons" ';
			print TWOFILE 'description="Numbered Exons for the Unknown Strand Transcripts" ';
			print TWOFILE 'visibility=3 colorByStrand="255,0,0 0,0,255"'."\n";
			my $curIndex=0;
			foreach(@sortedExonHOHunkw){
				my $start=$sortedExonHOHunkw[$curIndex]{start};
				my $stop=$sortedExonHOHunkw[$curIndex]{stop};
				my $strand=$sortedExonHOHunkw[$curIndex]{strand};
				my $name=$sortedExonHOHunkw[$curIndex]{alternateID2};
				print TWOFILE "chr$chr\t$start\t$stop\t$name\t0\t.\n";	
				$curIndex++;
			}
		}
		
		if($species eq 'Rat'){
			print FILTERFILE 'track db='.$trackDB.' type=bigBed group=ensGene priority=2 name="RNA Assembled Isoforms" ';
			print FILTERFILE 'description="Isoforms Constructed From RNA Seq" ';
			print FILTERFILE 'visibility=2 colorByStrand="255,0,0 0,0,255" bigDataUrl=http://ucsc:JU7etr5t@phenogen.ucdenver.edu/ucsc/transcripts.allSamples.5.bb'."\n";
		}
		if(@sortedExonHOHplus>0){
			print FILTERFILE 'track db='.$trackDB.' group=ensGene priority=1 name="+ Strand Exons" ';
			print FILTERFILE 'description="Numbered Exons for the + Strand Transcripts" ';
			print FILTERFILE 'visibility=3 colorByStrand="255,0,0 0,0,255"'."\n";
			my $curIndex=0;
			foreach(@sortedExonHOHplus){
				my $start=$sortedExonHOHplus[$curIndex]{start};
				my $stop=$sortedExonHOHplus[$curIndex]{stop};
				my $strand=$sortedExonHOHplus[$curIndex]{strand};
				my $name=$sortedExonHOHplus[$curIndex]{alternateID2};
				print FILTERFILE "chr$chr\t$start\t$stop\t$name\t0\t+\n";	
				$curIndex++;
			}
		}
		if(@sortedExonHOHminus>0){
			print FILTERFILE 'track db='.$trackDB.' group=ensGene priority=3 name="- Strand Exons" ';
			print FILTERFILE 'description="Numbered Exons for the - Strand Transcripts" ';
			print FILTERFILE 'visibility=3 colorByStrand="255,0,0 0,0,255"'."\n";
			my $curIndex=0;
			foreach(@sortedExonHOHminus){
				my $start=$sortedExonHOHminus[$curIndex]{start};
				my $stop=$sortedExonHOHminus[$curIndex]{stop};
				my $strand=$sortedExonHOHminus[$curIndex]{strand};
				my $name=$sortedExonHOHminus[$curIndex]{alternateID2};
				print FILTERFILE "chr$chr\t$start\t$stop\t$name\t0\t-\n";	
				$curIndex++;
			}
		}
		if(@sortedExonHOHunkw){
			print FILTERFILE 'track db='.$trackDB.' group=ensGene priority=4 name="Unknown Strand Exons" ';
			print FILTERFILE 'description="Numbered Exons for the Unknown Strand Transcripts" ';
			print FILTERFILE 'visibility=3 colorByStrand="255,0,0 0,0,255"'."\n";
			my $curIndex=0;
			foreach(@sortedExonHOHunkw){
				my $start=$sortedExonHOHunkw[$curIndex]{start};
				my $stop=$sortedExonHOHunkw[$curIndex]{stop};
				my $strand=$sortedExonHOHunkw[$curIndex]{strand};
				my $name=$sortedExonHOHunkw[$curIndex]{alternateID2};
				print FILTERFILE "chr$chr\t$start\t$stop\t$name\t0\t.\n";	
				$curIndex++;
			}
		}
		#my @tissueColor=("255,0,0","0,100,0","157,17,0","0,0,255");
		my $coreColor="255,0,0";
		my $fullColor="0,100,0";
		my $extendedColor="0,0,255";
		my $cntColor=0;
		foreach my $key (keys %tissueProbes){
			print FILTERFILE 'track db='.$trackDB." name=\"Probesets above background in $key\" ";
			print FILTERFILE "description=\"Affy Exon Probesets detected above background in $key: Red=Core Blue=Extended Green=Full\" ";
			print FILTERFILE 'visibility=3 itemRgb=On'."\n"; #removed useScore=1
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
				print FILTERFILE "chr$chr\t".$tissueProbes{$key}{pslist}[$curInd]{start}."\t".$tissueProbes{$key}{pslist}[$curInd]{stop}."\t".$tissueProbes{$key}{pslist}[$curInd]{ID}."\t$score\t$strand\t".$tissueProbes{$key}{pslist}[$curInd]{start}."\t".$tissueProbes{$key}{pslist}[$curInd]{stop}."\t".$color."\n";
				$curInd++;
			}
			$cntColor++;
		}
	
	close TWOFILE;
	close FILTERFILE;
	# Now we have to put these IDs into the gene hash
	
	$cntGene=0;
	
	foreach(@geneArray){
		my $currentGeneStrand=$GeneHOH{Gene}[$cntGene]{strand};
		print "gene id:".$GeneHOH{Gene}[$cntGene]{ID}."\nstrand:".$GeneHOH{Gene}[$cntGene]{strand}."\n";
		if($GeneHOH{Gene}[$cntGene]{ID} eq ""){
			
		}else{
			# There is one transcript array corresponding to the current gene.
			my $transcriptArrayRef = $GeneHOH{Gene}[$cntGene]{TranscriptList}{Transcript};
			my @transcriptArray = @$transcriptArrayRef;
			if($debugging >= 1){
				print " Number of Transcripts ";
				print scalar @transcriptArray;
				print "\n";
			}
			
			my $currentExonStart;
			my $currentExonStop;
			
			
			my $cnt;
			my $cntExons;
			my $alreadyIncluded = 0;
			
			my $cntTranscripts = 0;
			foreach(@transcriptArray){
				$exonArrayRef = $GeneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon};
				@exonArray = @$exonArrayRef;
				$cntExons = 0;
				foreach(@exonArray){
					$currentExonStart = $GeneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{start};
					$currentExonStop = $GeneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{stop};
					# find out if this exon is already in exonHOH
					$alreadyIncluded = 0;
					if($currentGeneStrand ==1){
						for($cnt=0; $cnt < $cntHOHExonsPlus; $cnt++){
							if($sortedExonHOHplus[$cnt]{start} == $currentExonStart && $sortedExonHOHplus[$cnt]{stop} == $currentExonStop ){
								$GeneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{alternateID2}=$sortedExonHOHplus[$cnt]{alternateID2};
							}
						}
					}elsif($currentGeneStrand ==-1){
						for($cnt=0; $cnt < $cntHOHExonsMinus; $cnt++){
							if($sortedExonHOHminus[$cnt]{start} == $currentExonStart && $sortedExonHOHminus[$cnt]{stop} == $currentExonStop ){
								$GeneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{alternateID2}=$sortedExonHOHminus[$cnt]{alternateID2};
							}
						}
					}else{
						for($cnt=0; $cnt < $cntHOHExonsUnkw; $cnt++){
							if($sortedExonHOHunkw[$cnt]{start} == $currentExonStart && $sortedExonHOHunkw[$cnt]{stop} == $currentExonStop ){
								$GeneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{alternateID2}=$sortedExonHOHunkw[$cnt]{alternateID2};
							}
						}
					}
					$cntExons++;
				}
				$cntTranscripts++;
			}
		}
		$cntGene++;
	}
	
	return (\%GeneHOH);
	
} # End of addAlternateID_RNA

1;
