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


sub readSpliceJunctFromDB{
	my($geneChrom,$organism,$geneStart,$geneStop,$publicUserID,$panel,$dsn,$usr,$passwd)=@_;   


	my %spliceHOH; # giant array of hashes and arrays containing probeset data
	if($organism eq 'Mouse'){
		$organism="Mm";
	}elsif($organism eq 'Rat'){
		$organism="Rn";
	}
	# PERL DBI CONNECT
	$connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");

	$query ="Select sj.RNA_junction_id,sj.exon1_start,sj.exon1_stop,sj.exon2_start,sj.exon2_stop,sj.JNCT_NAME,sj.READ_COUNT,sj.Sample_count,sj.strand,c.name as \"chromosome\"
			from rna_splice_junction sj,rna_dataset rd, chromosomes c 
			where 
			c.chromosome_id=sj.chromosome_id
			and rd.user_id=$publicUserID  
			and rd.visible=1 
			and rd.strain_panel like '".$panel."'
			and sj.rna_dataset_id=rd.rna_dataset_id
			and c.name =  '".uc($geneChrom)."' "."
			and rd.organism = '".$organism."' "."
			and ((sj.exon1_start>=$geneStart and sj.exon1_start<=$geneStop) OR (sj.exon1_Stop>=$geneStart and sj.exon1_Stop<=$geneStop) OR (sj.exon1_Start<=$geneStart and sj.exon1_Stop>=$geneStop)
				OR (sj.exon2_start>=$geneStart and sj.exon2_start<=$geneStop) OR (sj.exon2_Stop>=$geneStart and sj.exon2_Stop<=$geneStop) OR (sj.exon2_Start<=$geneStart and sj.exon2_Stop>=$geneStop)
				OR  (sj.exon1_Stop<=$geneStart and sj.exon2_Start>=$geneStop))
			order by sj.READ_COUNT DESC,sj.exon1_start,sj.exon2_start";
			
			

	print $query."\n";
	$query_handle = $connect->prepare($query) or die (" RNA Isoform query prepare failed \n");

# EXECUTE THE QUERY
	$query_handle->execute() or die ( "RNA Isoform query execute failed \n");

# BIND TABLE COLUMNS TO VARIABLES

	$query_handle->bind_columns(\$id,\$ex1Start,\$ex1Stop,\$ex2Start,\$ex2Stop,\$name,\$reads,\$sample,\$strand,\$chr);
# Loop through results, adding to array of hashes.
	
	my $cntSplice=0;
	my %countHash;
	my %spliceHOH;
	
	while($query_handle->fetch()) {
		#print "SETUP\t$id\t$strain\t$start\t$ref_seq\n";
		$spliceHOH{Feature}[$cntSplice] = {
					ID => $id,
					strand => $strand,
					start => $ex1Start,
					stop => $ex2Stop,
					name => $name,
					readCount => $reads,
					sampleCount => $sample,
					chromosome => $chr,
					};
		$spliceHOH{Feature}[$cntSplice]{blockList}{block}[0]={
									start =>$ex1Start,
									stop => $ex1Stop
									};
		$spliceHOH{Feature}[$cntSplice]{blockList}{block}[1]={
									start =>$ex2Start,
									stop => $ex2Stop
									};
		#			blockList => [
		#					block =>{
		#						start =>$ex1Start,
		#						stop => $ex1Stop
		#						},
		#					block =>{
		#						start =>$ex2Start,
		#						stop => $ex2Stop
		#						}
		#					}
		#};
		$cntSplice++;
	}
	print "Splice Count:".$cntSplice."\n";
	$query_handle->finish();
	$connect->disconnect();
	return (\%spliceHOH);
}
1;

