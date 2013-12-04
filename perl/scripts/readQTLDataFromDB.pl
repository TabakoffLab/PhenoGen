#!/usr/bin/perl
# Subroutine to read information from database



# PERL MODULES WE WILL BE USING
use Bio::SeqIO;

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


sub readQTLDataFromDB{


	#INPUT VARIABLES
	# Chromosome for example chr12
	# Start position on the chromosome
	# Stop position on the chromosome

	# Read inputs
	my($geneChrom,$organism,$geneStart,$geneStop,$dsn,$usr,$passwd)=@_;   
	
	
	#Initializing Arrays

	my %qtlHOH; # giant array of hashes and arrays containing QTL data
	
	
	if($organism eq 'Mouse'){
		$organism="Mm";
	}elsif($organism eq 'Rat'){
		$organism="Rn";
	}
	
	# PERL DBI CONNECT
	$connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");
	
	
	# PREPARE THE QUERY for probesets
	# There's got to be a better way to handle the chromosome...
	#if(length($geneChrom) == 1){
		$query ="Select pq.QTL_NAME,c.NAME,pq.QTL_START,pq.QTL_END,pq.RGD_ID,pq.TRAIT_NAME,pq.PHENOTYPE,pq.CANDIDATE_GENE_SYMBOLS
			from public_qtls pq,chromosomes c 
			where 
			c.chromosome_id=pq.chromosome 
			and c.name =  '".uc($geneChrom)."' "."
			and pq.organism = '".$organism."' "."
			and ((pq.QTL_START>=$geneStart and pq.QTL_START<=$geneStop) OR (pq.QTL_END>=$geneStart and pq.QTL_END<=$geneStop) OR (pq.QTL_START<=$geneStart and pq.QTL_END>=$geneStop))
			order by pq.QTL_NAME";
	#}
	#elsif(length($geneChrom) == 2) {
	#	$query ="Select pq.QTL_NAME,c.NAME,pq.QTL_START,pq.QTL_END
	#		from public_qtls pq,chromosomes c 
	#		where 
	#		c.chromosome_id=pq.chromosome 
	#		and substr(c.name,1,2) =  '".$geneChrom."' "."
	#		and pq.organism = '".$organism."' "."
	#		and ((pq.QTL_START>=$geneStart and pq.QTL_START<=$geneStop) OR (pq.QTL_END>=$geneStart and pq.QTL_END<=$geneStop) OR (pq.QTL_START<=$geneStart and pq.QTL_END>=$geneStop))
	#		order by pq.QTL_NAME";
	#}
	#else{
	#	die "Something is wrong with the bQTL query \n";
	#}
	print "QTL Query:".$query."\n";
	$query_handle = $connect->prepare($query) or die (" bQTL query prepare failed \n");

# EXECUTE THE QUERY
	$query_handle->execute() or die ( "bQTL query execute failed \n");

# BIND TABLE COLUMNS TO VARIABLES

	$query_handle->bind_columns(\$qtl_name,\$qtl_chrom,\$qtl_start,\$qtl_stop,\$rgd_id,\$trait,\$phenotype,\$candid_gene);
# Loop through results, adding to array of hashes.
	my $cntQTL=0;
	
	
	while($query_handle->fetch()) {
		#print "processing:QTL:$qtl_name\n";
		$qtlHOH{QTL}[$cntQTL] = {
			name => $qtl_name,
			chromosome => $qtl_chrom,
			start=> $qtl_start,
			stop => $qtl_stop,
			ID=> $rgd_id,
			trait=> $trait,
			phenotype=> $phenotype,
			candidate=> $candid_gene
		};
		$cntQTL++;
	}
	$query_handle->finish();
	$connect->disconnect();
	#close PSFILE;
	
	#print "Gene".scalar(keys %geneHOH)."\n";
	#print "gene name".$geneHOH{Gene}[0]{ID}."\n";
	return (\%qtlHOH);
}
1;

