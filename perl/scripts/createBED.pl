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
	print OFILE "visibility=3 centerLabelsDense=\"on\" \n";
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
	print OFILE "description='BNLX/SHRH DNA SNPs and Indels  BNLX-Blue SHRH-Red' ";
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
			my $name=$strain."_".$refSeq.":".$strainSeq;
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
	
	my $trackDesc="Protein Coding / PolyA+(RNA-Seq)";
	if($proteinCoding==0){
		$trackDesc="Non-Coding / Non-PolyA+(RNA-Seq)";
	}
	
	open OFILE, ">".$outputFile or die " Could not open two track file $outputFile for writing $!\n\n";
	
	print OFILE "track db=$trackDB name='$trackDesc' ";
		print OFILE "description='$trackDesc'";
		print OFILE "visibility=3 itemRgb=On \n";
		if(@geneList>0){
			my $cntGenes=0;
			foreach my $tmpGene (@geneList){
				my $biotype=$GeneHOH{Gene}[$cntGenes]{biotype};
				print "::$biotype::\n";
				if(($biotype eq "protein_coding" and $proteinCoding==1) or ($biotype ne "protein_coding" and $proteinCoding==0)){
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
							$color="143,96,72";
						}else{
							$color="223,193,132";
						}
					}else{
						if($proteinCoding==1){
							$color="42,117,169";
						}else{
							$color="126,181,214";
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
	my($smncHOHRef, $outputFile,$trackDB,$chr) = @_; 
	my %smncHOH = %$smncHOHRef;
	my $smncListRef=$smncHOH{smnc};
	my @smncList=();
	eval{
		@smncList=@$smncListRef;
	}or do{
		@smncList=();
	};
	open OFILE, '>'.$outputFile or die " Could not open two track file $outputFile for writing $!\n\n";
	print OFILE "track db=$trackDB name='Small Non-Coding' ";
	print OFILE 'description="Small Non-Coding Features" ';
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
			print OFILE "chr$chr\t$smncStart\t$smncStop\tsmRNA_$smncID\t0\t$strand\t$smncStart\t$smncStop\t98,139,97\n";
			$cntSmnc++;
		}
	}
	close OFILE;
	return 1;
}
return 1;