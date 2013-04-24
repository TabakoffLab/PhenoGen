#!/usr/bin/perl
# Subroutine to read information from database



# PERL MODULES WE WILL BE USING
use Bio::SeqIO;
use Text::CSV;

require "readAnnotationDataFromDB.pl";
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


sub readSmallNoncodingDataFromDB{


	#INPUT VARIABLES
	# Chromosome for example chr12
	# Start position on the chromosome
	# Stop position on the chromosome

	# Read inputs
	my($geneChrom,$organism,$publicUserID,$panel,$geneStart,$geneStop,$dsn,$usr,$passwd)=@_;   


	my %smncHOH; # giant array of hashes and arrays containing probeset data
	
	#my $snmcAnnotRef=readSmallNCAnnotationDataFromDB($geneChrom,$organism,$publicUserID,$panel,$geneStart,$geneStop,$dsn,$usr,$passwd);
	#my %smncAnnot=%$smncAnnotRef;
	
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
		$query ="Select rsn.rna_smnc_id,rsn.feature_start,rsn.feature_stop,rsn.total_reads,rsn.strand,rsn.reference_seq,c.name as \"chromosome\"
			from rna_sm_noncoding rsn, rna_dataset rd, chromosomes c 
			where 
			c.chromosome_id=rsn.chromosome_id 
			and c.name =  '".$geneChrom."' "."
			and rd.organism = '".$organism."' "."
			and rd.user_id= $publicUserID  
			and rd.visible=1 
			and rd.strain_panel like '".$panel."' "."
			and rsn.rna_dataset_id=rd.rna_dataset_id
			and ((rsn.feature_start>=$geneStart and rsn.feature_start<=$geneStop) OR (rsn.feature_stop>=$geneStart and rsn.feature_stop<=$geneStop) OR (rsn.feature_start<=$geneStart and rsn.feature_stop>=$geneStop))
			order by rsn.rna_smnc_id";
	#}
	#elsif(length($geneChrom) == 2) {
	#	$query ="Select rsn.rna_smnc_id,rsn.feature_start,rsn.feature_stop,rsn.total_reads,rsn.strand,rsn.reference_seq,c.name as \"chromosome\"
	#		from rna_sm_noncoding rsn, rna_dataset rd, chromosomes c 
	#		where 
	#		c.chromosome_id=rsn.chromosome_id 
	#		and substr(c.name,1,2) =  '".$geneChrom."' "."
	#		and rd.organism = '".$organism."' "."
	#		and rd.user_id= $publicUserID  
	#		and rd.visible=1 
	#		and rd.strain_panel like '".$panel."' "."
	#		and rsn.rna_dataset_id=rd.rna_dataset_id
	#		and ((rsn.feature_start>=$geneStart and rsn.feature_start<=$geneStop) OR (rsn.feature_stop>=$geneStart and rsn.feature_stop<=$geneStop) OR (rsn.feature_start<=$geneStart and rsn.feature_stop>=$geneStop))
	#		order by rsn.rna_smnc_id";
	#}
	#else{
	#	die "Something is wrong with the RNA Isoform query \nChromosome#:$geneChrom\n";
	#}
	print $query."\n";
	$query_handle = $connect->prepare($query) or die (" RNA Isoform query prepare failed \n");

# EXECUTE THE QUERY
	$query_handle->execute() or die ( "RNA Isoform query execute failed \n");

# BIND TABLE COLUMNS TO VARIABLES

	$query_handle->bind_columns(\$id,\$start ,\$stop,\$reads,\$strand,\$seq,\$chr);
# Loop through results, adding to array of hashes.
	
	my $cntSmnc=0;
	while($query_handle->fetch()) {
		#print "SMNC SETUP\t$id\t$start\t$seq\n";
		$smncHOH{smnc}[$cntSmnc] = {
			ID => $id,
			start => $start,
			stop=> $stop,
			reads => $reads,
			strand => $strand,
			refseq => $seq,
			chromosome => $chr
		};
		$cntSmnc++;
	}
	$query_handle->finish();
	$connect->disconnect();
	return (\%smncHOH);
}
1;

