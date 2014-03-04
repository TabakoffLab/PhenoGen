#!/usr/bin/perl
# Subroutine to read information from database



# PERL MODULES WE WILL BE USING
use Bio::SeqIO;
use Data::Dumper qw(Dumper);


use Text::CSV;

#use strict; Fix this

sub readRefSeqDataFromDB{


	#INPUT VARIABLES
	# Chromosome for example chr12
	# Start position on the chromosome
	# Stop position on the chromosome

	# Read inputs
	my($geneChrom,$organism,$geneStart,$geneStop,$dsn,$usr,$passwd)=@_;   
	
	#Initializing Arrays

	my %geneHOH; # giant array of hashes and arrays containing transcript data
	
	
	# DATA SOURCE NAME
	#$dsn = "dbi:$platform:$service_name";
	if(index($geneChrom,"chr")==-1){
		$geneChrom="chr".$geneChrom;
	}
	
	my $shortOrg="Mm";
	if($organism eq 'Rat'){
		$shortOrg="Rn";
	}
	
	# PERL DBI CONNECT
	$connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");
	
		$query ="SELECT g.name,g.chrom,g.strand,g.txStart,g.txEnd,g.cdsStart,g.cdsEnd,g.exonStarts,g.exonEnds,g.name2,s.status
			FROM ".$shortOrg."_refseq_2.refGene g, ".$shortOrg."_refseq_2.refSeqStatus s
			where g.chrom='".$geneChrom."'
			and ((".$geneStart."<=g.txStart and g.txStart<=".$geneStop.") or (".$geneStart."<=g.txEnd and g.txEnd<=".$geneStop.") or (g.txStart<=".$geneStart." and ".$geneStop."<=g.txEnd))
			and g.name=s.mrnaAcc
			order by g.txStart,g.name2;";
	
	print "Updated\n$shortOrg\n".$organism."\n".$query."\n";
	$query_handle = $connect->prepare($query) or die (" RNA Isoform query prepare failed \n");

# EXECUTE THE QUERY
	$query_handle->execute() or die ( "RefSeq query execute failed \n");

# BIND TABLE COLUMNS TO VARIABLES

	$query_handle->bind_columns(\$txID ,\$chrom,\$strand,\$txStart,\$txStop,\$cdsStart,\$cdsStop,\$exonStarts,\$exonStops,\$geneSym,\$status);
# Loop through results, adding to array of hashes.
	my $continue=1;
	
	my $cntGene=0;
	my $cntTranscript=0;
	my $cntExon=0;
	my $cntIntron=0;
	my $geneMin=-1;
	my $geneMax=-1;
	my $previousGeneSym="";

	
	while($query_handle->fetch()) {
		#print "$txID\n$exonStarts\n";
		if($geneSym eq $previousGeneSym){		
			$geneHOH{Gene}[$cntGene-1]{TranscriptList}{Transcript}[$cntTranscript] = {
					ID => $txID,
					geneSymbol=>$geneSym,
					start=> $txStart,
					stop => $txStop,
					cdsStart=>$cdsStart,
					cdsStop=>$cdsStop,
					source => "RefSeq",
					strand => $strand,
					category => $status,
					chromosome => $chrom
				};
			my @exonStartList=split(/,/,$exonStarts);
			my @exonStopList=split(/,/,$exonStops);
			my @startList=sort {$a <=> $b} @exonStartList;
			my @stopList=sort {$a <=> $b} @exonStopList;
			my $cntIntron=0;
			for(my $i=0;$i<@startList;$i++){
				$geneHOH{Gene}[$cntGene-1]{TranscriptList}{Transcript}[$cntTranscript]{exonList}{exon}[$i]{ID}=$i+1;
				$geneHOH{Gene}[$cntGene-1]{TranscriptList}{Transcript}[$cntTranscript]{exonList}{exon}[$i]{start}=$startList[$i];
				$geneHOH{Gene}[$cntGene-1]{TranscriptList}{Transcript}[$cntTranscript]{exonList}{exon}[$i]{stop}=$stopList[$i];
				if($i>0){
					my $intStart=$geneHOH{Gene}[$cntGene-1]{TranscriptList}{Transcript}[$cntTranscript]{exonList}{exon}[$i-1]{stop}+1;
					my $intStop=$geneHOH{Gene}[$cntGene-1]{TranscriptList}{Transcript}[$cntTranscript]{exonList}{exon}[$i]{start}-1;
					$geneHOH{Gene}[$cntGene-1]{TranscriptList}{Transcript}[$cntTranscript]{intronList}{intron}[$cntIntron]{ID}=$cntIntron+1;
					$geneHOH{Gene}[$cntGene-1]{TranscriptList}{Transcript}[$cntTranscript]{intronList}{intron}[$cntIntron]{start}=$intStart;
					$geneHOH{Gene}[$cntGene-1]{TranscriptList}{Transcript}[$cntTranscript]{intronList}{intron}[$cntIntron]{stop}=$intStop;
					$cntIntron++;
				}
			}
			$cntTranscript++;
				
			#set gene min max
			if($geneMin==-1||$txStart<$geneMin){
				$geneMin=$txStart;
			}
			if($geneMax==-1||$txStop<$geneMax){
				$geneMax=$txStop;
			}		
		}else{	
			if($cntGene>0){
				$geneHOH{Gene}[$cntGene-1]{start}=$geneMin;
				$geneHOH{Gene}[$cntGene-1]{stop}=$geneMax;
			}
			#create next gene
			$geneHOH{Gene}[$cntGene] = {
				start => 0,
				stop => 0,
				ID => $cntGene+1,
				strand=>$strand,
				chromosome=>$chrom,
				biotype => "protein_coding",
				geneSymbol => $geneSym,
				source => "RefSeq"
				};
			
			$cntTranscript=0;
			$geneMin=-1;
			$geneMax=-1;
			
			$geneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscript] = {
					ID => $txID,
					geneSymbol=>$geneSym,
					start=> $txStart,
					stop => $txStop,
					cdsStart=>$cdsStart,
					cdsStop=>$cdsStop,
					source => "RefSeq",
					strand => $strand,
					category => $status,
					chromosome => $chrom
				};
			my @exonStartList=split(/,/,$exonStarts);
			my @exonStopList=split(/,/,$exonStops);
			my @startList=sort {$a <=> $b} @exonStartList;
			my @stopList=sort {$a <=> $b} @exonStopList;
			my $cntIntron=0;
			for(my $i=0;$i<@startList;$i++){
				$geneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscript]{exonList}{exon}[$i]{ID}=$i+1;
				$geneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscript]{exonList}{exon}[$i]{start}=$startList[$i];
				$geneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscript]{exonList}{exon}[$i]{stop}=$stopList[$i];
				if($i>0){
					my $intStart=$geneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscript]{exonList}{exon}[$i-1]{stop}+1;
					my $intStop=$geneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscript]{exonList}{exon}[$i]{start}-1;
					$geneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscript]{intronList}{intron}[$cntIntron]{ID}=$cntIntron+1;
					$geneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscript]{intronList}{intron}[$cntIntron]{start}=$intStart;
					$geneHOH{Gene}[$cntGene]{TranscriptList}{Transcript}[$cntTranscript]{intronList}{intron}[$cntIntron]{stop}=$intStop;
					$cntIntron++;
				}
			}
			$cntTranscript++;
				
			#set gene min max
			if($geneMin==-1||$txStart<$geneMin){
				$geneMin=$txStart;
			}
			if($geneMax==-1||$txStop<$geneMax){
				$geneMax=$txStop;
			}
			$previousGeneSym=$geneSym;
			$cntGene++;	
		}
	}
	$query_handle->finish();
	$connect->disconnect();
	
	if($cntGene>0){
		$geneHOH{Gene}[$cntGene-1]{start}=$geneMin;
		$geneHOH{Gene}[$cntGene-1]{stop}=$geneMax;
	}
	
	return (\%geneHOH);
}

1;

