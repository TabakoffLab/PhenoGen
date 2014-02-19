#!/usr/bin/perl


use Bio::EnsEMBL::Registry;
use XML::LibXML;
use XML::Simple;



use strict;
require 'ReadAffyProbesetDataFromDB.pl';
require 'readRNAIsoformDataFromDB.pl';
require 'readQTLDataFromDB.pl';
require 'readSNPDataFromDB.pl';
require 'readSmallNCDataFromDB.pl';
require 'createBED.pl';
require 'createXMLTrack.pl';


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
    #print "Find: $lookForGene\n";
    foreach(my $testName, @$list){
	#print "$$testName:$lookForGene ";
	if($$testName eq $lookForGene){
	    #print "Found";
	    $ret=1;
	}
	#print "\n";
    }

    return $ret;
}


sub findEnsembl{
    my $annotRef=shift;
    my $curCount=shift;
    my $ens="";

	my %rnaHOH=%$annotRef;
	my $annotListRef=$rnaHOH{Gene}[$curCount]{TranscriptList}{Transcript}[0]{annotationList}{annotation};
	my @annotArr=();
	eval{
		    @annotArr=@$annotListRef;
	    }or do{
		    @annotArr=();
	    };
	
	my $count=0;
	foreach(@annotArr){
	    my $source=$rnaHOH{Gene}[$curCount]{TranscriptList}{Transcript}[0]{annotationList}{annotation}[$count]{source};
	    #print "checking source:".$source."\n";
	    if($source eq "AKA"){
		$ens=$rnaHOH{Gene}[$curCount]{TranscriptList}{Transcript}[0]{annotationList}{annotation}[$count]{annot_value};
		$ens=substr($ens,0,index($ens,":"));
		#print "Found:$ens\n";
		last;
	    }
	}
    return $ens;
}

sub mergeByAnnotation{
    #print "CALLED MERGE ANNOTATION\n";
    my $geneHOHRef=shift;
    
    my %geneHOH=%$geneHOHRef;
    my $geneListRef=$geneHOH{Gene};
    my @geneList=();
	eval{
		@geneList=@$geneListRef;
	}or do{
		@geneList=();
	};
    my %mainGenes;
    my %rnaGenes;
    my %hm;
    
    my $geneCount=0;
    my $mainCount=0;
    my $rnaCount=0;
    foreach(@geneList){
	if($geneHOH{Gene}[$geneCount]{source} eq ("Ensembl")){
	    $mainGenes{Gene}[$mainCount]=$geneHOH{Gene}[$geneCount];
	    $hm{$geneHOH{Gene}[$geneCount]{ID}}=$mainCount;
	    $mainCount++;
	    
	}else{
	    $rnaGenes{Gene}[$rnaCount]=$geneHOH{Gene}[$geneCount];
	    $rnaCount++;
	}
	$geneCount++;
    }
    
    my @rnaList=();
    my $rnaGeneRef=$rnaGenes{Gene};
    eval{
	    @rnaList=@$rnaGeneRef;
    }or do{
	    @rnaList=();
    };

    $rnaCount=0;
    foreach(@rnaList){
	my $ens=findEnsembl(\%rnaGenes,$rnaCount);
	#print "aka match".$rnaGenes{Gene}[$rnaCount]{ID}."\t".$ens."\n";
	if(defined $hm{$ens}){
	    #print "defined\n";
	    my $tmpGeneIndex=$hm{$ens};
	    my $tmpGeneArrRef=$mainGenes{Gene}[$tmpGeneIndex]{TranscriptList}{Transcript};
	    my @tmpGeneTxArr=@$tmpGeneArrRef;
	    my $tmpCount=@tmpGeneTxArr;
	    my @trxList=();
	    my $trxListRef=$rnaGenes{Gene}[$rnaCount]{TranscriptList}{Transcript};
	    eval{
		@trxList=@$trxListRef;
	    }or do{
		@trxList=();
	    };
	    my $trxCount=0;
	    #print "before mainLen:".$tmpCount." txAdd:".@trxList."\n";
	    my $extStart=$mainGenes{Gene}[$tmpGeneIndex]{start};
	    my $extStop=$mainGenes{Gene}[$tmpGeneIndex]{stop};
	    foreach(@trxList){
		#print "loop:$trxCount\n";
		$mainGenes{Gene}[$tmpGeneIndex]{TranscriptList}{Transcript}[$tmpCount]=$rnaGenes{Gene}[$rnaCount]{TranscriptList}{Transcript}[$trxCount];
		if($rnaGenes{Gene}[$rnaCount]{TranscriptList}{Transcript}[$trxCount]{start}<$extStart){
		    $extStart=$rnaGenes{Gene}[$rnaCount]{TranscriptList}{Transcript}[$trxCount]{start};
		    $mainGenes{Gene}[$tmpGeneIndex]{extStart}=$extStart;
		}
		if($rnaGenes{Gene}[$rnaCount]{TranscriptList}{Transcript}[$trxCount]{stop}>$extStop){
		    $extStop=$rnaGenes{Gene}[$rnaCount]{TranscriptList}{Transcript}[$trxCount]{stop};
		    $mainGenes{Gene}[$tmpGeneIndex]{extStop}=$extStop;
		}
		$tmpCount++;
		$trxCount++;
	    }
	}else{
	    $mainGenes{Gene}[$mainCount]=$rnaGenes{Gene}[$rnaCount];
	    $mainCount++;
	}
	$rnaCount++;
    }
    
    return \%mainGenes;
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
	
	my $scriptStart=time();
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
	    #print "gene list:".@genelist."\n";
	}
	
	#read Probests
	my $psTimeStart=time();
	my ($probesetHOHRef) = readAffyProbesetDataFromDBwoProbes("chr".$chr,$minCoord,$maxCoord,$arrayTypeID,$dsn,$usr,$passwd);
	my @probesetHOH = @$probesetHOHRef;
	my $psTimeEnd=time();
	createProbesetXMLTrack(\@probesetHOH,$outputDir."probe.xml");
	print "Probeset Time=".($psTimeEnd-$psTimeStart)."sec\n";
	#read SNPs/Indels
	
	my %snpHOH;
	my @snpList=();
	my @snpStrain=();
	
	if($shortSpecies eq 'Rn'){
	    my $sTimeStart=time();
	    my $snpRef=readSNPDataFromDB($chr,$species,$minCoord,$maxCoord,$dsn,$usr,$passwd);
	    %snpHOH=%$snpRef;
	    @snpStrain=("BNLX","SHRH","SHRJ","F344");
	    my $sTimeEnd=time();
	    print "SNP Time=".($sTimeEnd-$sTimeStart)."sec\n";
	    my $iTimeStart=time();
	    my $isoformHOH = readRNAIsoformDataFromDB($chr,$shortSpecies,$publicID,'BNLX/SHRH',$minCoord,$maxCoord,$dsn,$usr,$passwd,1);
	    my $tmpGeneArray=$$isoformHOH{Gene};
	    my $iTimeEnd=time();
	    print "Isoform Time=".($iTimeEnd-$iTimeStart)."sec\n";
	    
	    #process RNA genes/transcripts and assign probesets.
	    $tmpGeneArray=$$isoformHOH{Gene};
	    foreach my $tmpgene ( @$tmpGeneArray){
		# "gene:".$$tmpgene{ID}."\n";
		$GeneHOH{Gene}[$cntGenes]=$tmpgene;
		$GeneHOH{Gene}[$cntGenes]{extStart}=$GeneHOH{Gene}[$cntGenes]{start};
		$GeneHOH{Gene}[$cntGenes]{extStop}=$GeneHOH{Gene}[$cntGenes]{stop};
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
			
			foreach my $strain(@snpStrain){
			    print "match snp strains:".$strain;
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
			$cntIntron++;
		    }
		}
	    }
	}
	
	#my $geneListFile=$outputDir."geneList.txt";
	#open GLFILE, ">".$geneListFile;
	
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
		$GeneHOH{Gene}[$cntGenes] = {
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
					#if($exonStart<$exonStop){# if gene is in the forward direction
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
					#}else{# gene is in reverse direction
					#    if((($probesetHOH[$cntProbesets]{start} <= $exonStart) and ($probesetHOH[$cntProbesets]{start} >= $exonStop) or 
					#    ($probesetHOH[$cntProbesets]{stop} <= $exonStart) and ($probesetHOH[$cntProbesets]{stop} >= $exonStop))
					#       and
					#        $probesetHOH[$cntProbesets]{strand}==$tmpStrand
					#    ){
					#	    #This is a probeset overlapping the current exon
					#	    $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{ProbesetList}{Probeset}[$cntMatchingProbesets] = 
					#		    $probesetHOH[$cntProbesets];
					#	    $cntMatchingProbesets=$cntMatchingProbesets+1;
					#    }elsif((($probesetHOH[$cntProbesets]{start} <= $intronStart) and ($probesetHOH[$cntProbesets]{start} >= $intronStop) or 
					#	($probesetHOH[$cntProbesets]{stop} <= $intronStart) and ($probesetHOH[$cntProbesets]{stop} >= $intronStop))
					#	   and
					#        $probesetHOH[$cntProbesets]{strand}==$tmpStrand
					#    ){
					#	    $GeneHOH{Gene}[$cntGenes]{TranscriptList}{Transcript}[$cntTranscripts]{intronList}{intron}[$cntIntrons-1]{ProbesetList}{Probeset}[$cntMatchingIntronProbesets] = 
					#		    $probesetHOH[$cntProbesets];
					#	    $cntMatchingIntronProbesets=$cntMatchingIntronProbesets+1;
					#    }
					#}
					$cntProbesets = $cntProbesets+1;
				} # loop through probesets
				
				
				
				foreach my $strain(@snpStrain){
				    print "match snp strains:".$strain;
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
				
				$cntExons=$cntExons+1;
				#print "finished matching probesets\n";
		    } # loop through exons
		    $cntTranscripts = $cntTranscripts+1;
		} # loop through transcripts
		#$GeneHOH{Gene}[$cntGenes]{TranscriptCountEnsembl}=$cntTranscripts;
		$cntGenes=$cntGenes+1;
	    }# if to process only if chromosome is valid
	} # loop through genes
	#close GLFILE;
	
	my $geneHOHRef=mergeByAnnotation(\%GeneHOH);
	my %tmpGeneHOH=%$geneHOHRef;
	
	my $geneListRef=$tmpGeneHOH{Gene};
	my @geneList=();
	eval{
		@geneList=@$geneListRef;
	}or do{
		@geneList=();
	};
	
	#print "list before sort:".@geneList."\n";
	my @sortedlist = sort { $a->{start} <=> $b->{start} } @geneList;
	#print "sorted List:".@sortedlist."\n";
	$GeneHOH{Gene}=\@sortedlist;
	
	##output XML file
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
	
	#read QTLs
	my $qStart=time();
	my $qtlRef=readQTLDataFromDB($chr,$species,$minCoord,$maxCoord,$dsn,$usr,$passwd);
	my %qtlHOH=%$qtlRef;
	my $qEnd=time();
	print "QTLs completed in ".($qEnd-$qStart)." sec.\n";
	
	my $smStart=time();
	my $smncRef=readSmallNoncodingDataFromDB($chr,$species,$publicID,'BNLX/SHRH',$minCoord,$maxCoord,$dsn,$usr,$passwd);
	my %smncHOH=%$smncRef;
	my $smEnd=time();
	print "Small RNA completed in ".($smEnd-$smStart)." sec.\n";
	
	#my $rnaCountStart=time();
	#my $rnaCountRef=readRNACountsDataFromDB($chr,$species,$publicID,'BNLX/SHRH',$minCoord,$maxCoord,$dsn,$usr,$passwd);
	#my %rnaCountHOH=%$rnaCountRef;
	#my $rnaCountEnd=time();
	#print "RNA Count completed in ".($rnaCountEnd-$rnaCountStart)." sec.\n";
	
	my $trackDB="mm10";
	if($species eq 'Rat'){
		$trackDB="rn5";
	}
	
	#create bed files in region folder
	createQTLXMLTrack(\%qtlHOH,$outputDir."qtl.xml",$trackDB,$chr);
	
	
	createSNPXMLTrack(\%snpHOH,$outputDir,$trackDB);
	createProteinCodingXMLTrack(\%GeneHOH,$outputDir."coding.xml",$trackDB,1);
	createProteinCodingXMLTrack(\%GeneHOH,$outputDir."noncoding.xml",$trackDB,0);
	createSmallNonCodingXML(\%smncHOH,\%GeneHOH,$outputDir."smallnc.xml",$trackDB,$chr);
	#createRNACountXMLTrack(\%rnaCountHOH,$outputDir."helicos.xml");
	my $scriptEnd=time();
	print " script completed in ".($scriptEnd-$scriptStart)." sec.\n";
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

1;