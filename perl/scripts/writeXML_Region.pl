#!/usr/bin/perl

#use lib "/opt/ensembl_ucsc/bioperl-live";
#use lib "/opt/ensembl_ucsc/ensembl/modules";

use Bio::EnsEMBL::Registry;
use XML::LibXML;
use XML::Simple;


use strict;
require 'ReadAffyProbesetDataFromDB.pl';
require 'readRNAIsoformDataFromDB.pl';
require 'readQTLDataFromDB.pl';
require 'createTrack.pl';
require 'createPng.pl';


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

sub find
{
    
    my $lookForGene = shift;
    my $list=shift;
    my $ret=0;
    print "Find: $lookForGene\n";
    foreach(my $testName, @$list){
	print "$$testName:$lookForGene ";
	if($$testName eq $lookForGene){
	    print "Found";
	    $ret=1;
	}
	print "\n";
    }

    return $ret;
}


# get Image calls createPNG it should increment the timeout time if the first request fails and try again up to 3 times starting with a 30s timeout +30s/failure.
# it returns the result code allowing the main method to get the result code and url for the last attempt. Either the first successful attempt or last of 3 failed attempts.
sub getImage{
    my ($species,$chr,$minCoord,$maxCoord,$outputFileName,$trackFileName)=@_;
    my $newresultCode=0;
    my $tryCount=0;
    my $resultCode="";
    while($newresultCode!=200 and $tryCount<3){
	eval{
	    $resultCode=createPngRNA($species, "chr$chr:$minCoord-$maxCoord", "chr".$chr, $minCoord, $maxCoord, $outputFileName,$trackFileName,(30+30*$tryCount),950,35,8);
	    print "RESULT CODE2:$resultCode\n";
	    $newresultCode=substr($resultCode,0,index($resultCode,"<>"));
	    1;
	}or do{
	    $newresultCode=0;
	};
	$tryCount=$tryCount+1;
    }
    return $resultCode;
}

sub createXMLFile
{
	#This subroutine reads data from two sources
	#It reads data from ensembl using their perl API
	#It reads data from Affy via downloaded files
	#
	#Inputs:
	# 	Name with path of UCSC bed file.  This file must be in the directory /data/ucsc on Phenogen, or must be moved there.
	#   Name with path of png output file
	#   Name with path of xml output file
	#	Species for example, Rat
	#	Type: for example, 'Core'
	#	The ensembl Gene Names for example 'ENSRNOG00000001285' or 'ENSRNOG00000001285,ENSRNOG00000001286,ENSRNOG00000001287'
	#
	#
	#
	#

	# Read in the arguments for the subroutine	
	my($ucscDir, $outputDir, $folderName,$species,$type,$chromosome,$minCoord,$maxCoord,$arrayTypeID,$rnaDatasetID,$publicID,$dsn,$usr,$passwd,$ensHost,$ensPort,$ensUsr,$ensPasswd)=@_;
	
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
	    print "trying local\n";
	    $dbAdaptorNum =$registry->load_registry_from_db(
		-host => $ensHost, #'ensembldb.ensembl.org', # alternatively 'useastdb.ensembl.org'
		-port => $ensPort,
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
	
	

	print "connected\n";
	my $slice_adaptor = $registry->get_adaptor( $species, $type, 'Slice' );
	
	my @genelist=();
	my @slicelist=();
	
	my $chr = $chromosome;

	
	my $tmpslice = $slice_adaptor->fetch_by_region('chromosome', $chr,$minCoord,$maxCoord);
	my $genes = $tmpslice->get_all_Genes();
	while(my $tmpgene=shift @{$genes}){
	    push(@genelist, $tmpgene);
	    push(@slicelist, $tmpslice);
	    print "gene list:".@genelist."\n";
	}
	
	my ($probesetHOHRef) = readAffyProbesetDataFromDBwoProbes("chr".$chr,$minCoord,$maxCoord,$arrayTypeID,$dsn,$usr,$passwd);
	my @probesetHOH = @$probesetHOHRef;
	
	if($shortSpecies eq 'Rn'){
	    my $isoformHOH = readRNAIsoformDataFromDB($chr,$shortSpecies,$publicID,'BNLX/SHRH',$minCoord,$maxCoord,$dsn,$usr,$passwd,1);
	    my $tmpGeneArray=$$isoformHOH{Gene};
	    #process RNA genes/transcripts and assign probesets.
	    $tmpGeneArray=$$isoformHOH{Gene};
	    foreach my $tmpgene ( @$tmpGeneArray){
		print "gene:".$$tmpgene{ID}."\n";
		$GeneHOH{Gene}[$cntGenes]=$tmpgene;
		$cntGenes++;
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
				if($exonStart<$exonStop){# if gene is in the forward direction
				    if((($probesetHOH[$cntProbesets]{start} >= $exonStart) and ($probesetHOH[$cntProbesets]{start} <= $exonStop) or
					    ($probesetHOH[$cntProbesets]{stop} >= $exonStart) and ($probesetHOH[$cntProbesets]{stop} <= $exonStop))
				       and
					$probesetHOH[$cntProbesets]{strand}==$tmpStrand
				    ){
					    $$tmpexon{ProbesetList}{Probeset}[$cntMatchingProbesets] = $probesetHOH[$cntProbesets];
					    $cntMatchingProbesets=$cntMatchingProbesets+1;
				    }elsif((($probesetHOH[$cntProbesets]{start} >= $intronStart) and ($probesetHOH[$cntProbesets]{start} <= $intronStop) or 
					    ($probesetHOH[$cntProbesets]{stop} >= $intronStart) and ($probesetHOH[$cntProbesets]{stop} <= $intronStop))
					and
					$probesetHOH[$cntProbesets]{strand}==$tmpStrand
				    ){
					    $$tmptranscript{intronList}{intron}[$cntIntron]{ProbesetList}{Probeset}[$cntMatchingIntronProbesets] = 
						    $probesetHOH[$cntProbesets];
					    $cntMatchingIntronProbesets=$cntMatchingIntronProbesets+1;
				    }
				}else{# gene is in reverse direction
				    if((($probesetHOH[$cntProbesets]{start} <= $exonStart) and ($probesetHOH[$cntProbesets]{start} >= $exonStop) or 
				    ($probesetHOH[$cntProbesets]{stop} <= $exonStart) and ($probesetHOH[$cntProbesets]{stop} >= $exonStop))
				    and
					$probesetHOH[$cntProbesets]{strand}==$tmpStrand
				    ){
					    #This is a probeset overlapping the current exon
					    $$tmpexon{ProbesetList}{Probeset}[$cntMatchingProbesets] = $probesetHOH[$cntProbesets];
					    $cntMatchingProbesets=$cntMatchingProbesets+1;
				    }elsif((($probesetHOH[$cntProbesets]{start} <= $intronStart) and ($probesetHOH[$cntProbesets]{start} >= $intronStop) or 
					    ($probesetHOH[$cntProbesets]{stop} <= $intronStart) and ($probesetHOH[$cntProbesets]{stop} >= $intronStop))
					and
					$probesetHOH[$cntProbesets]{strand}==$tmpStrand
				    ){
					    $$tmptranscript{intronList}{intron}[$cntIntron]{ProbesetList}{Probeset}[$cntMatchingIntronProbesets] = 
						    $probesetHOH[$cntProbesets];
					    $cntMatchingIntronProbesets=$cntMatchingIntronProbesets+1;
				    }
				}
				$cntProbesets = $cntProbesets+1;
			} # loop through probesets
			$cntIntron++;
		    }
		}
	    }
	}
	
	my $geneListFile=$outputDir."geneList.txt";
	open GLFILE, ">".$geneListFile;
	
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
		print "adding:$geneName:$geneExternalName\n";
		
		push(@addedGeneList,$geneName);
		$GeneHOH{Gene}[$cntGenes] = {
			start => $geneStart,
			stop => $geneStop,
			ID => $geneName,
			strand=>$geneStrand,
			chromosome=>$geneChrom,
			biotype => $geneBioType,
			geneSymbol => $geneExternalName,
			source => "Ensembl",
			description => $geneDescription
			};
		print GLFILE "$geneName\t$geneExternalName\t$geneStart\t$geneStop\n";

		    #Get the transcripts for this gene
		    print "getting transcripts for ".$geneExternalName."\n";
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
			
			my $tmpStrand=$transcriptStrand;
			
			my $cntExons = 0;
			my $cntIntrons=0;
			
			print "getting exons for $transcriptName\n";
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
					if($exonStart<$exonStop){# if gene is in the forward direction
					    if((($probesetHOH[$cntProbesets]{start} >= $exonStart) and ($probesetHOH[$cntProbesets]{start} <= $exonStop) or 
						($probesetHOH[$cntProbesets]{stop} >= $exonStart) and ($probesetHOH[$cntProbesets]{stop} <= $exonStop))
					       and
					        $probesetHOH[$cntProbesets]{strand}==$tmpStrand
					    ){
						    #This is a probeset overlapping the current exon
						    $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{ProbesetList}{Probeset}[$cntMatchingProbesets] = 
							    $probesetHOH[$cntProbesets];
						    $cntMatchingProbesets=$cntMatchingProbesets+1;
					    }elsif((($probesetHOH[$cntProbesets]{start} >= $intronStart) and ($probesetHOH[$cntProbesets]{start} <= $intronStop) or 
						($probesetHOH[$cntProbesets]{stop} >= $intronStart) and ($probesetHOH[$cntProbesets]{stop} <= $intronStop))
						   and
					        $probesetHOH[$cntProbesets]{strand}==$tmpStrand
					    ){
						    $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{intronList}{intron}[$cntIntrons-1]{ProbesetList}{Probeset}[$cntMatchingIntronProbesets] = 
							    $probesetHOH[$cntProbesets];
						    $cntMatchingIntronProbesets=$cntMatchingIntronProbesets+1;
					    }
					}else{# gene is in reverse direction
					    if((($probesetHOH[$cntProbesets]{start} <= $exonStart) and ($probesetHOH[$cntProbesets]{start} >= $exonStop) or 
					    ($probesetHOH[$cntProbesets]{stop} <= $exonStart) and ($probesetHOH[$cntProbesets]{stop} >= $exonStop))
					       and
					        $probesetHOH[$cntProbesets]{strand}==$tmpStrand
					    ){
						    #This is a probeset overlapping the current exon
						    $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{ProbesetList}{Probeset}[$cntMatchingProbesets] = 
							    $probesetHOH[$cntProbesets];
						    $cntMatchingProbesets=$cntMatchingProbesets+1;
					    }elsif((($probesetHOH[$cntProbesets]{start} <= $intronStart) and ($probesetHOH[$cntProbesets]{start} >= $intronStop) or 
						($probesetHOH[$cntProbesets]{stop} <= $intronStart) and ($probesetHOH[$cntProbesets]{stop} >= $intronStop))
						   and
					        $probesetHOH[$cntProbesets]{strand}==$tmpStrand
					    ){
						    $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{intronList}{intron}[$cntIntrons-1]{ProbesetList}{Probeset}[$cntMatchingIntronProbesets] = 
							    $probesetHOH[$cntProbesets];
						    $cntMatchingIntronProbesets=$cntMatchingIntronProbesets+1;
					    }
					}
					$cntProbesets = $cntProbesets+1;
				} # loop through probesets
				$cntExons=$cntExons+1;
				#print "finished matching probesets\n";
		    } # loop through exons
		    $cntTranscripts = $cntTranscripts+1;
		} # loop through transcripts
		#$GeneHOH{Gene}[$cntGenes]{TranscriptCountEnsembl}=$cntTranscripts;
		$cntGenes=$cntGenes+1;
	    }# if to process only if chromosome is valid
	} # loop through genes
	close GLFILE;
	
	
	my $qtlRef=readQTLDataFromDB($chr,$species,$minCoord,$maxCoord,$dsn,$usr,$passwd);
	my %qtlHOH=%$qtlRef;
	
		#my $newBedOutputFileName = $pngOutputFileName.$GeneHOH{Gene}[$cntGenes]{ID}.".bed";
		# convert to big bed file.  Not sure if this is exactly necessary ...
		#my $bigBedOutputFileName = $bedOutputFileName.$geneNameGlobal."..bb";
		#my $bigBedOutputFileNameNoPath = $$geneNameGlobal."..bb";
		
		#my $twoTrackOutputFileName = $ucscDir.$folderName.".tracks";
		#my $transTrackOutputFileName = $ucscDir.$folderName.".trans.tracks";
		my $twoTrackOutputFileNameNoArray = $ucscDir.$folderName."_noArray.tracks";
		my $transTrackOutputFileNameNoArray = $ucscDir.$folderName."_noArray.trans.tracks";
		#my $twoTrackOutputFileNameHuman = $ucscDir.$folderName."_human.tracks";
		#my $transTrackOutputFileNameHuman = $ucscDir.$folderName."_human.trans.tracks";
		
		#createTrackFileRegion(\%GeneHOH, $twoTrackOutputFileName,  $species,0,1,0,$chr,$minCoord,$maxCoord);
		#createTrackFileRegion(\%GeneHOH, $transTrackOutputFileName,  $species,1,1,0,$chr,$minCoord,$maxCoord);
		createTrackFileRegion(\%GeneHOH,\%qtlHOH, $twoTrackOutputFileNameNoArray,  $species,0,0,0,$chr,$minCoord,$maxCoord);
		createTrackFileRegion(\%GeneHOH,\%qtlHOH, $transTrackOutputFileNameNoArray,  $species,1,0,0,$chr,$minCoord,$maxCoord);
		#createTrackFileRegion(\%GeneHOH, $twoTrackOutputFileNameHuman,  $species,0,0,1,$chr,$minCoord,$maxCoord);
		#createTrackFileRegion(\%GeneHOH, $transTrackOutputFileNameHuman,  $species,1,0,1,$chr,$minCoord,$maxCoord);
		
		my $xml = new XML::Simple (RootName=>'GeneList');
		my $data = $xml->XMLout(\%GeneHOH);
		# open xml file
		my $xmlOutputFileName=">$outputDir/Region.xml";
		open XMLFILE, $xmlOutputFileName or die " Could not open XML file $xmlOutputFileName for writing $!\n\n";
		# write the header 
		print XMLFILE '<?xml version="1.0" encoding="UTF-8"?>';
		print XMLFILE "\n\n";
		# Write the xml data
		print XMLFILE $data;
		close XMLFILE;
		
		#
		# Create the png file for this gene
		
		#my $newPngOutputFileName = $outputDir."region.main.png";
		#my $newFilterPngOutputFileName = $outputDir."region.main.trans.png";
		my $newPngOutputFileNameNoArray = $outputDir."region.main.noArray.png";
		my $newFilterPngOutputFileNameNoArray = $outputDir."region.main.trans.noArray.png";
		#my $newPngOutputFileNameHuman = $outputDir."region.main.human.png";
		#my $newFilterPngOutputFileNameHuman = $outputDir."region.main.trans.human.png";
		my $urlFile=$outputDir."Region.url";
		
		#my $geneStartSmaller = $geneStart-200;
		#my $geneStopBigger = $geneStop+200;
		my $newresultCode=0;
		my $tryCount=0;
		open URLFILE, ">".$urlFile;
		print URLFILE "$chr:$minCoord-$maxCoord\n";
		my $resultCode=getImage($species,$chr,$minCoord,$maxCoord,$newPngOutputFileNameNoArray,$twoTrackOutputFileNameNoArray);
		    my $url=substr($resultCode,index($resultCode,"<>")+2);
		    print "URL:$url\n";
		    print URLFILE "$url\n";
		
		$resultCode=getImage($species,$chr,$minCoord,$maxCoord,$newFilterPngOutputFileNameNoArray,$transTrackOutputFileNameNoArray);
		    my $url=substr($resultCode,index($resultCode,"<>")+2);
		    print "URL:$url\n";
		    print URLFILE "$url\n";
		close URLFILE;
		
		#$resultCode=getImage($species,$chr,$minCoord,$maxCoord,$newPngOutputFileNameNoArray,$twoTrackOutputFileNameNoArray);
		#$resultCode=getImage($species,$chr,$minCoord,$maxCoord,$newFilterPngOutputFileNameNoArray,$transTrackOutputFileNameNoArray);
		
		#$resultCode=getImage($species,$chr,$minCoord,$maxCoord,$newPngOutputFileNameHuman,$twoTrackOutputFileNameHuman);
		#$resultCode=getImage($species,$chr,$minCoord,$maxCoord,$newFilterPngOutputFileNameHuman,$transTrackOutputFileNameHuman);
		
		#while($newresultCode!=200 and $tryCount<3){
		#    my $resultCode=createPngRNA($species, "chr$chr:$minCoord-$maxCoord", "chr".$chr, $minCoord, $maxCoord, $newPngOutputFileName,$twoTrackOutputFileName,(30+30*$tryCount));
		#    print "RESULT CODE:$resultCode\n";
		#    if($tryCount==0){
		#	my $url=substr($resultCode,index($resultCode,"<>")+2);
		#	print "URL:$url\n";
		#	print URLFILE "$url\n";
		#    }
		#    $newresultCode=substr($resultCode,0,index($resultCode,"<>"));
		#    $tryCount=$tryCount+1;
		#}
		##sleep(15);
		#$newresultCode=0;
		#$tryCount=0;
		#while($newresultCode!=200 and $tryCount<3){
		#    my $resultCode=createPngRNA($species, "chr$chr:$minCoord-$maxCoord", "chr".$chr, $minCoord, $maxCoord, $newFilterPngOutputFileName,$transTrackOutputFileName,(30+30*$tryCount));
		#    print "RESULT CODE2:$resultCode\n";
		#    if($tryCount==0){
		#	my $url=substr($resultCode,index($resultCode,"<>")+2);
		#	print "URL:$url\n";
		#	print URLFILE "$url\n";
		#    }
		#    $newresultCode=substr($resultCode,0,index($resultCode,"<>"));
		#    $tryCount=$tryCount+1;
		#}
		#close URLFILE;
		#$newresultCode=0;
		#$tryCount=0;
		#while($newresultCode!=200 and $tryCount<3){
		#    my $resultCode=createPngRNA($species, "chr$chr:$minCoord-$maxCoord", "chr".$chr, $minCoord, $maxCoord, $newPngOutputFileNameNoArray,$twoTrackOutputFileNameNoArray,(30+30*$tryCount));
		#    print "RESULT CODE2:$resultCode\n";
		#    if($tryCount==0){
		#	my $url=substr($resultCode,index($resultCode,"<>")+2);
		#    }
		#    $newresultCode=substr($resultCode,0,index($resultCode,"<>"));
		#    $tryCount=$tryCount+1;
		#}
		#$newresultCode=0;
		#$tryCount=0;
		#while($newresultCode!=200 and $tryCount<3){
		#    my $resultCode=createPngRNA($species, "chr$chr:$minCoord-$maxCoord", "chr".$chr, $minCoord, $maxCoord, $newFilterPngOutputFileNameNoArray,$transTrackOutputFileNameNoArray,(30+30*$tryCount));
		#    print "RESULT CODE2:$resultCode\n";
		#    if($tryCount==0){
		#	my $url=substr($resultCode,index($resultCode,"<>")+2);
		#    }
		#    $newresultCode=substr($resultCode,0,index($resultCode,"<>"));
		#    $tryCount=$tryCount+1;
		#}
		#$newresultCode=0;
		#$tryCount=0;
		#while($newresultCode!=200 and $tryCount<3){
		#    my $resultCode=createPngRNA($species, "chr$chr:$minCoord-$maxCoord", "chr".$chr, $minCoord, $maxCoord, $newPngOutputFileNameHuman,$twoTrackOutputFileNameHuman,(30+30*$tryCount));
		#    print "RESULT CODE2:$resultCode\n";
		#    if($tryCount==0){
		#	my $url=substr($resultCode,index($resultCode,"<>")+2);
		#    }
		#    $newresultCode=substr($resultCode,0,index($resultCode,"<>"));
		#    $tryCount=$tryCount+1;
		#}
		#my $resultCode=getImage($species,$chr,$minCoord,$maxCoord,$newFilterPngOutputFileNameHuman,$transTrackOutputFileNameHuman);
		#print "RESULT CODE MAIN:$resultCode\n";
		#$newresultCode=0;
		#$tryCount=0;
		#while($newresultCode!=200 and $tryCount<3){
		#    my $resultCode=createPngRNA($species, "chr$chr:$minCoord-$maxCoord", "chr".$chr, $minCoord, $maxCoord, $newFilterPngOutputFileNameHuman,$transTrackOutputFileNameHuman,(30+30*$tryCount));
		#    print "RESULT CODE2:$resultCode\n";
		#    if($tryCount==0){
		#	my $url=substr($resultCode,index($resultCode,"<>")+2);
		#    }
		#    $newresultCode=substr($resultCode,0,index($resultCode,"<>"));
		#    $tryCount=$tryCount+1;
		#}
}
#
#	
	my $arg1 = $ARGV[0]; # ucsc file path
	my $arg2 = $ARGV[1]; # output directory path
	my $arg3 = $ARGV[2]; #xml file name
	my $arg4 = $ARGV[3]; #species
	my $arg5 = $ARGV[4]; #annotation level
	my $arg6 = $ARGV[5]; #Gene name list
	my $arg7 = $ARGV[6]; #user name
	my $arg8 = $ARGV[7]; #path to bed files(bedSort,bedToBigBed, and x.chrom.sizes)
	my $arg9= $ARGV[8]; #array type id
	my $arg10=$ARGV[9]; #rnaDatasetID
	my $arg11=$ARGV[10];
	my $arg12=$ARGV[11];
	my $arg13=$ARGV[12];
	my $arg14=$ARGV[13];
	my $arg15=$ARGV[14];
	my $arg16=$ARGV[15];
	my $arg17=$ARGV[16];
	my $arg18=$ARGV[17];
	createXMLFile($arg1, $arg2, $arg3, $arg4, $arg5, $arg6, $arg7, $arg8, $arg9,$arg10,$arg11,$arg12,$arg13,$arg14,$arg15,$arg16,$arg17,$arg18);

	
	# Example call:
	# perl writeXML.pl /Users/clemensl/TestingOutput/ /Users/clemensl/TestingOutput/ /Users/clemensl/TestingOutput/gene.xml Mouse Core ENSMUSG00000029064

