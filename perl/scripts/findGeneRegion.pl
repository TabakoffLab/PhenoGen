#!/usr/bin/perl

use POSIX qw(floor);
use Bio::EnsEMBL::Registry;
use XML::LibXML;
use XML::Simple;

require 'readRNAIsoformDataFromMongo.pl';

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
	print "aka match".$rnaGenes{Gene}[$rnaCount]{ID}."\t".$ens."\n";
	if(defined $hm{$ens}){
	    print "defined\n";
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
	    print "before mainLen:".$tmpCount." txAdd:".@trxList."\n";
	    my $extStart=$mainGenes{Gene}[$tmpGeneIndex]{start};
	    my $extStop=$mainGenes{Gene}[$tmpGeneIndex]{stop};
	    foreach(@trxList){
		print "loop:$trxCount\n";
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
	my( $outputDir,$species,$type,$geneNames,$publicID,$dsn,$usr,$passwd,$ensHost,$ensPort,$ensUsr,$ensPasswd)=@_;
	
	my @geneNamesList=split(/,/,$geneNames);
	my $geneNameGlobal=$geneNamesList[0];
	my $shortSpecies="";
	if($species eq "Rat"){
	    $shortSpecies="Rn";
	}else{
	    $shortSpecies="Mm";
	}
	my $tissue="Brain";
	
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
	    print "try local\n";
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
	    print "try main\n";
	    # Enable this option if problems occur connecting the above option is faster, but only has current and previous versions of data
	    $dbAdaptorNum=$registry->load_registry_from_db(
		-host => 'ensembldb.ensembl.org', 
		-user => 'anonymous'
	    );
	    print "main finished:$dbAdaptorNum\n";
	}
	
	

	#print "connected\n";
	my $slice_adaptor = $registry->get_adaptor( $species, $type, 'Slice' );
	
	my @genelist=();
	my @slicelist=();
	
	
	my $prevMin=999999999999;
	my $prevMax=0;
	my $minCoord=999999999999;
	my $maxCoord=0;
	my $chr = "";
	my $firstGeneSymbol="";
	
	#print "gene list size:".@geneNamesList."\n";
	#my $geneName = shift @geneNamesList;
	
	
	#fill genelist and slicelist for each Ensembl gene found and determine the min and max coordinates to find overlapping RNA isoforms.
	while ( my $geneName1 = shift @geneNamesList ) {
	    if(index($geneName1,"XLOC")==-1){
		#print "Get:$geneName1\n";
		my $tmpslice = $slice_adaptor->fetch_by_gene_stable_id( $geneName1, 50 ); # the 50 just returns a little more on the chromosome. shortened from 5000 since this returns too much.
		# Get all the genes.  Theoretically there should only be one, but possibly there might be more????
		my $genes = $tmpslice->get_all_Genes();
		while(my $tmpgene=shift @{$genes}){
		    my $curstart = $tmpgene->seq_region_start();
		    my $curstop = $tmpgene->seq_region_end();
		    if($firstGeneSymbol eq ""){
			    $firstGeneSymbol = $tmpgene->external_name();
		    }
		    $chr=$tmpgene->slice->seq_region_name();
		    print "on chromosome:".$chr."\n";
		    if($curstart<=$curstop){
			if($curstart<$minCoord){
			    $minCoord=$curstart;
			}
			if($curstop>$maxCoord){
			    $maxCoord=$curstop;
			}
		    }else{
			if($curstop<$minCoord){
			    $minCoord=$curstop;
			}
			if($curstart>$maxCoord){
			    $maxCoord=$curstart;
			}
		    }
		    push(@genelist, $tmpgene);
		    push(@slicelist, $tmpslice);
		}
		#print "gene size found:".@{$genes}."\n";
		print "gene list:".@genelist."\n";
	    }else{
		
	    }
	}
	
	#get RNA isoform Gene list
	
	#my $diff=$maxCoord-$minCoord;
	#$diff=$diff*0.03;
	#$diff=POSIX::floor($diff);
	
	#$minCoord=$minCoord-$diff;
	#$maxCoord=$maxCoord+$diff;
	#read SNPs/Indels
	
	if($shortSpecies eq 'Rn'){
	    #get expanded min max
	    if($prevMin!=$minCoord||$prevMax!=$maxCoord){
	        $isoformHOH = readRNAIsoformDataFromDB($chr,$shortSpecies,$publicID,'BNLX/SHRH',$minCoord,$maxCoord,$dsn,$usr,$passwd,1,"Any",$tissue,0);
		my $tmpGeneArray=$$isoformHOH{Gene};
		foreach my $tmpgene ( @$tmpGeneArray){
		    print "gene:".$$tmpgene{ID}."\n";
		    my $tmpTransArray=$$tmpgene{TranscriptList}{Transcript};
		    foreach my $tmptranscript (@$tmpTransArray){
			print $$tmptranscript{ID}."\n";
			if($$tmptranscript{start}<$minCoord){
			    $minCoord=$$tmptranscript{start};
			}elsif($$tmptranscript{start}>$maxCoord){
			    $maxCoord=$$tmptranscript{start};
			}
			if($$tmptranscript{stop}<$minCoord){
			    $minCoord=$$tmptranscript{stop};
			}elsif($$tmptranscript{stop}>$maxCoord){
			    $maxCoord=$$tmptranscript{stop};
			}
		    }
		}
		#extend global Min Max by 1000bp
		#$minCoord=$minCoord-1000;
		#$maxCoord=$maxCoord+1000;
		#my $diff=$maxCoord-$minCoord;
		#$diff=$diff*0.03;
		#$diff=POSIX::floor($diff);
		
		#$minCoord=$minCoord-$diff;
		#$maxCoord=$maxCoord+$diff;
	    }
	}
	
	
	
	#process RNA genes/transcripts and assign probesets.
	$tmpGeneArray=$$isoformHOH{Gene};
	foreach my $tmpgene ( @$tmpGeneArray){
	    print "gene:".$$tmpgene{ID}."\n";
	    $GeneHOH{Gene}[$cntGenes]=$tmpgene;
	    $cntGenes++;
	    my $tmpTransArray=$$tmpgene{TranscriptList}{Transcript};
	    foreach my $tmptranscript (@$tmpTransArray){
		my $tmpExonArray=$$tmptranscript{exonList}{exon};
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
		    $cntIntron++;
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
		my $geneBioType = $gene->biotype();
		my $geneExternalName = $gene->external_name();
		my $found=0;
		print "Find: $geneName\n";
		foreach $testName (@addedGeneList){
		    print "$testName:$geneName ";
		    if($testName eq $geneName){
			print "Found";
			$found=1;
		    }else{
			print "Not found";
		    }
		    print "\n";
		}

	    if(length($geneRegion)<3&&$found==0){
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
			source => "Ensembl"
			};
		print GLFILE "$geneName\t$geneExternalName\t$geneStart\t$geneStop\t$geneStrand\n";
		    
		    
		
		
		$cntGenes=$cntGenes+1;
	    }# if to process only if chromosome is valid
	} # loop through genes
	
	close GLFILE;
		
		open LOCFILE,">".$outputDir."location.txt";
		print LOCFILE "chr$chr\n$minCoord\n$maxCoord\n";
		close LOCFILE;
		
		
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
	createXMLFile($arg1, $arg2, $arg3, $arg4, $arg5, $arg6, $arg7, $arg8, $arg9,$arg10,$arg11,$arg12);

	
	# Example call:
	# perl writeXML.pl /Users/clemensl/TestingOutput/ /Users/clemensl/TestingOutput/ /Users/clemensl/TestingOutput/gene.xml Mouse Core ENSMUSG00000029064

1;