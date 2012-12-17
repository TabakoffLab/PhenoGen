#!/usr/bin/perl
# Subroutine to read information from database



# PERL MODULES WE WILL BE USING
use Bio::SeqIO;
use Data::Dumper qw(Dumper);

use Text::CSV;
#use strict; Fix this

sub addChr{


	#Second input variable should be "add" or "subtract".  Default is "add"
	# if second input variable is "add" then add the letters "chr"
	# if the second input variable is "subtract", take away the letters "chr"

	my ($chromosomeNumber,$addOrSubtract)=@_;
	if ($addOrSubtract eq "subtract"){
		my $newChrom = substr($chromosomeNumber,3,length($chromosomeNumber));
		# get rid of first 3 characters
		return $newChrom;
	}
	else {
		# add chr
		my $newChrom = "chr$chromosomeNumber";
		return $newChrom;
	}
}
1;


sub readRNAIsoformDataFromDB{


	#INPUT VARIABLES
	# Chromosome for example chr12
	# Start position on the chromosome
	# Stop position on the chromosome

	# Read inputs
	my($geneChrom,$organism,$publicUserID,$panel,$geneStart,$geneStop,$dsn,$usr,$passwd,$shortName)=@_;   
	
	#open PSFILE, $psOutputFileName;//Added to output for R but now not needed.  R will read in XML file
	#print "read probesets chr:$geneChrom\n";
	#Initializing Arrays

	my %geneHOH; # giant array of hashes and arrays containing probeset data
	
	
	# DATA SOURCE NAME
	#$dsn = "dbi:$platform:$service_name";
	
	
	# PERL DBI CONNECT
	$connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");
	
	
	
	#my $geneChromNumber = addChr($geneChrom,"subtract");
	
	
	# PREPARE THE QUERY for probesets
	# There's got to be a better way to handle the chromosome...
	if(length($geneChrom) == 1){
		$query ="Select rd.tissue,rt.gene_id,rt.isoform_id,rt.source,rt.trstart,rt.trstop,rt.score,rt.strand,rt.fpkm,rt.frac,rt.conf_lo,rt.conf_hi,rt.cov,c.name as \"chromosome\",
			re.enumber,re.escore,re.estart,re.estop,re.fpkm as \"efpkm\",re.frac as \"efrac\",re.conf_lo as \"econf_lo\",re.conf_hi as \"econf_hi\", re.cov as \"ecov\" 
			from rna_dataset rd, rna_transcripts rt, rna_exons re,chromosomes c 
			where 
			c.chromosome_id=rt.chromosome_id 
			and substr(c.name,1,1) =  '".$geneChrom."' "."
			and re.rna_transcript_id=rt.rna_transcript_id 
			and rt.rna_dataset_id=rd.rna_dataset_id 
			and rd.organism = '".$organism."' "."
			and rd.user_id= $publicUserID  
			and rd.visible=1 
			and rd.strain_panel like '".$panel."' "."
			and ((trstart>=$geneStart and trstart<=$geneStop) OR (trstop>=$geneStart and trstop<=$geneStop) OR (trstart<=$geneStart and trstop>=$geneStop))
			order by rt.trstart,rt.gene_id,rt.isoform_id,re.enumber";
	}
	elsif(length($geneChrom) == 2) {
		$query ="Select rd.tissue,rt.gene_id,rt.isoform_id,rt.source,rt.trstart,rt.trstop,rt.score,rt.strand,rt.fpkm,rt.frac,rt.conf_lo,rt.conf_hi,rt.cov,c.name as \"chromosome\",
			re.enumber,re.escore,re.estart,re.estop,re.fpkm as \"efpkm\",re.frac as \"efrac\",re.conf_lo as \"econf_lo\",re.conf_hi as \"econf_hi\", re.cov as \"ecov\" 
			from rna_dataset rd, rna_transcripts rt, rna_exons re,chromosomes c 
			where 
			c.chromosome_id=rt.chromosome_id 
			and substr(c.name,1,2) =  '".$geneChrom."' "."
			and re.rna_transcript_id=rt.rna_transcript_id 
			and rt.rna_dataset_id=rd.rna_dataset_id 
			and rd.organism = '".$organism."' "."
			and rd.user_id= $publicUserID  
			and rd.visible=1 
			and rd.strain_panel like '".$panel."' "."
			and ((trstart>=$geneStart and trstart<=$geneStop) OR (trstop>=$geneStart and trstop<=$geneStop) OR (trstart<=$geneStart and trstop>=$geneStop))
			order by rt.trstart,rt.gene_id,rt.isoform_id,re.enumber";
	}
	else{
		die "Something is wrong with the RNA Isoform query \nChromosome#:$geneChromNumber\n";
	}
	#print $query."\n";
	$query_handle = $connect->prepare($query) or die (" RNA Isoform query prepare failed \n");

# EXECUTE THE QUERY
	$query_handle->execute() or die ( "RNA Isoform query execute failed \n");

# BIND TABLE COLUMNS TO VARIABLES

	$query_handle->bind_columns(\$tissue ,\$gene_id,\$isoform_id,\$source,\$trstart,\$trstop,\$trscore,\$trstrand,\$fpkm,\$frac,\$conf_lo,\$conf_hi,\$cov,\$chr,\$enumber,\$escore,\$estart,\$estop,\$efpkm,\$efrac,\$econf_lo,\$econf_hi,\$ecov);
# Loop through results, adding to array of hashes.
	my $continue=1;
	my @tmpArr=();
	my @intronArray = @tmpArr ;
	my @tmpArr2=();
	my @exonArray= @tmpArr2;
	my $cntGene=0;
	my $cntTranscript=0;
	my $cntExon=0;
	my $cntIntron=0;
	my $geneMin=0;
	my $geneMax=0;
	my $previousGeneName="";
	my $previousTranscript=0;
	
	my $trtmp_id="";
	my $trtmp_score=0;
	my $trtmp_start=0;
	my $trtmp_stop=0;
	my $trtmp_fpkm=0;
	my $trtmp_frac=0;
	my $trtmp_conf_lo=0;
	my $trtmp_conf_hi=0;
	my $trtmp_cov=0;
	my $trtmp_strand=0;
	my $trtmp_chromosome=0;
	my $genetmp_tissue="";
	my $genetmp_id="";
	my $genetmp_strand="";
	my $genetmp_chr="";
	my $genetmp_start=-1;
	my $genetmp_stop=-1;
	
	while($query_handle->fetch()) {
		if($gene_id eq $previousGeneName){
			if($isoform_id==$previousTranscript){
				#print "adding exon $enumber\n";
				$$exonArray[$cntExon]{ID}=$enumber;
				$$exonArray[$cntExon]{score}=$escore;
				$$exonArray[$cntExon]{start}=$estart;
				$$exonArray[$cntExon]{stop}=$estop;
				$$exonArray[$cntExon]{fpkm}=$efpkm;
				$$exonArray[$cntExon]{frac}=$efrac;
				$$exonArray[$cntExon]{conf_lo}=$econf_lo;
				$$exonArray[$cntExon]{conf_hi}=$econf_hi;
				$$exonArray[$cntExon]{cov}=$ecov;
				my $intStart=$$exonArray[$cntExon-1]{stop}+1;
				my $intStop=$$exonArray[$cntExon]{start}-1;
				if($$exonArray[$cntExon]{start}>$$exonArray[$cntExon]{stop}){
					$intStart=$$exonArray[$cntExon-1]{stop}-1;
					$intStop=$$exonArray[$cntExon]{start}+1;
				}
				#print "intron start:$intStart - $intStop\n";
				$$intronArray[$cntIntron]{ID}=$cntIntron+1;
				$$intronArray[$cntIntron]{start}=$intStart;
				$$intronArray[$cntIntron]{stop}=$intStop;
				$cntIntron++;
				$cntExon++;
			}else{
				#print "Adding transcript $trtmp_id::$cntTranscript\n";
				
				$geneHOH{Gene}[$cntGene-1]{TranscriptList}{Transcript}[$cntTranscript] = {
					ID => $trtmp_id,
					score => $trtmp_score,
					start=> $trtmp_start,
					stop => $trtmp_stop,
					fpkm => $trtmp_fpkm,
					frac => $trtmp_frac,
					conf_lo => $trtmp_conf_lo,
					conf_hi => $trtmp_conf_hi,
					cov => $trtmp_cov,
					source => $trtmp_source,
					strand => $trtmp_strand,
					chromosome => $trtmp_chromosome,
					exonList => {exon => \@$exonArray},
					intronList => {intron => \@$intronArray}
				};
				$cntTranscript++;
				#print "adding transcript $isoform_id\n";
				if($shortName==0){
					$trtmp_id=$tissue." Isoform ".$isoform_id;
				}else{
					$trtmp_id=$isoform_id;
				}
				$trtmp_score=$trscore;
				$trtmp_start=$trstart;
				$trtmp_stop=$trstop;
				$trtmp_fpkm=$fpkm;
				$trtmp_frac=$frac;
				$trtmp_conf_lo=$conf_lo;
				$trtmp_conf_hi=$conf_hi;
				$trtmp_cov=$cov;
				$trtmp_source=$source;
				$trtmp_strand=$trstrand;
				$trtmp_chromosome=$chr;
				
				#set gene min max
				
				if($genetmp_start==-1||$genetmp_start>$trtmp_start){
					$genetmp_start=$trtmp_start;
				}
				if($genetmp_stop==-1||$genetmp_stop<$trtmp_stop){
					$genetmp_stop=$trtmp_stop;
				}
				
				$previousTranscript=$isoform_id;
				
				#reset exons
				my @tmpArray=();
				$exonArray=\@tmpArray;
				$cntExon=0;
				my @tmpArray2=();
				$intronArray=\@tmpArray2;
				$cntIntron=0;
				
				#print "adding exon $enumber\n";
				$$exonArray[$cntExon]{ID}=$enumber;
				$$exonArray[$cntExon]{score}=$escore;
				$$exonArray[$cntExon]{start}=$estart;
				$$exonArray[$cntExon]{stop}=$estop;
				$$exonArray[$cntExon]{fpkm}=$efpkm;
				$$exonArray[$cntExon]{frac}=$efrac;
				$$exonArray[$cntExon]{conf_lo}=$econf_lo;
				$$exonArray[$cntExon]{conf_hi}=$econf_hi;
				$$exonArray[$cntExon]{cov}=$ecov;
				$cntExon++;
			}
			#print Data::Dumper->Dump(\@probeArray);
		}else{	
			
			#print " Number of probes $cntProbes \n";
			#print Data::Dumper->Dump(\@$probeArray);
			if($cntGene>0){
				#print "adding transcript".$trtmp_id."\n";
				$geneHOH{Gene}[$cntGene-1]{start}=$genetmp_start;
				$geneHOH{Gene}[$cntGene-1]{stop}=$genetmp_stop;
				$geneHOH{Gene}[$cntGene-1]{TranscriptList}{Transcript}[$cntTranscript] = {
					ID => $trtmp_id,
					score => $trtmp_score,
					start=> $trtmp_start,
					stop => $trtmp_stop,
					fpkm => $trtmp_fpkm,
					frac => $trtmp_frac,
					conf_lo => $trtmp_conf_lo,
					conf_hi => $trtmp_conf_hi,
					cov => $trtmp_cov,
					source => $trtmp_source,
					strand => $trtmp_strand,
					chromosome => $trtmp_chromosome,
					exonList => {exon => \@$exonArray},
					intronList => {intron => \@$intronArray}
				};
				$cntTranscript++;
			}
			#print "adding gene $gene_id\n";
			my $tmpGeneID=$tissue.".".$gene_id;
			if($shortName==1){
				my $shortGID=substr($gene_id,index($gene_id,".")+1);
				$tmpGeneID=$tissue.".".$shortGID;
			}
			
			#create next gene
			$geneHOH{Gene}[$cntGene] = {
				start => 0,
				stop => 0,
				ID => $tmpGeneID,
				strand=>$trstrand,
				chromosome=>$chr,
				biotype => "protein coding",
				geneSymbol => "",
				source => "RNA Seq"
				};
			$cntGene++;
			#print "adding transcript $isoform_id\n";
			#reset variables
			if($shortName==0){
				$trtmp_id=$tissue." Isoform ".$isoform_id;
			}else{
				$trtmp_id=$isoform_id;
			}
			$trtmp_score=$trscore;
			$trtmp_start=$trstart;
			$trtmp_stop=$trstop;
			$trtmp_fpkm=$fpkm;
			$trtmp_frac=$frac;
			$trtmp_conf_lo=$conf_lo;
			$trtmp_conf_hi=$conf_hi;
			$trtmp_cov=$cov;
			$trtmp_source=$source;
			$trtmp_strand=$trstrand;
			$trtmp_chromosome=$chr;
			

			$genetmp_start=$trtmp_start;
			$genetmp_stop=$trtmp_stop;
			
			$cntTranscript=0;
			
			my @tmpArray2=();
			$exonArray=\@tmpArray2;
			$cntExon=0;
			
			my @tmpArray=();
			$intronArray=\@tmpArray;
			$cntIntron=0;
			
			#print "adding exon $enumber\n";	
			$$exonArray[$cntExon]{ID}=$enumber;
			$$exonArray[$cntExon]{score}=$escore;
			$$exonArray[$cntExon]{start}=$estart;
			$$exonArray[$cntExon]{stop}=$estop;
			$$exonArray[$cntExon]{fpkm}=$efpkm;
			$$exonArray[$cntExon]{frac}=$efrac;
			$$exonArray[$cntExon]{conf_lo}=$econf_lo;
			$$exonArray[$cntExon]{conf_hi}=$econf_hi;
			$$exonArray[$cntExon]{cov}=$ecov;
			$cntExon++;
			
			$geneMin=0;
			$geneMax=0;
			
			$previousGeneName=$gene_id;
			$previousTranscript=$isoform_id;
		}
	}
	$query_handle->finish();
	$connect->disconnect();
	
	if($cntGene>0){
		$geneHOH{Gene}[$cntGene-1]{start}=$genetmp_start;
		$geneHOH{Gene}[$cntGene-1]{stop}=$genetmp_stop;
		$geneHOH{Gene}[$cntGene-1]{TranscriptList}{Transcript}[$cntTranscript] = {
						ID => $trtmp_id,
						score => $trtmp_score,
						start=> $trtmp_start,
						stop => $trtmp_stop,
						fpkm => $trtmp_fpkm,
						frac => $trtmp_frac,
						conf_lo => $trtmp_conf_lo,
						conf_hi => $trtmp_conf_hi,
						cov => $trtmp_cov,
						source => $trtmp_source,
						strand => $trtmp_strand,
						chromosome => $trtmp_chromosome,
						exonList => {exon => \@$exonArray},
						intronList => {intron => \@$intronArray}
		};
	}
	#close PSFILE;
	
	#print "Gene".scalar(keys %geneHOH)."\n";
	#print "gene name".$geneHOH{Gene}[0]{ID}."\n";
	return (\%geneHOH);
}
1;

