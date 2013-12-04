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


sub readSNPDataFromDB{


	#INPUT VARIABLES
	# Chromosome for example chr12
	# Start position on the chromosome
	# Stop position on the chromosome

	# Read inputs
	my($geneChrom,$organism,$geneStart,$geneStop,$dsn,$usr,$passwd)=@_;   


	my %snpHOH; # giant array of hashes and arrays containing probeset data
	
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
		$query ="Select snp.dna_var_id,snp.strain,snp.ref_Seq,snp.strain_seq,snp.var_start,snp.var_stop,snp.type,c.name as \"chromosome\"
			from DNA_VARIANT snp, chromosomes c 
			where 
			c.chromosome_id=snp.chromosome_id 
			and c.name =  '".uc($geneChrom)."' "."
			and snp.organism = '".$organism."' "."
			and ((snp.Var_Start>=$geneStart and snp.Var_Start<=$geneStop) OR (snp.Var_Stop>=$geneStart and snp.Var_Stop<=$geneStop) OR (snp.Var_Start<=$geneStart and snp.Var_Stop>=$geneStop))
			order by snp.Var_Start";
	#}
	#elsif(length($geneChrom) == 2) {
	#	$query ="Select snp.dna_var_id,snp.strain,snp.ref_Seq,snp.strain_seq,snp.var_start,snp.var_stop,snp.type,c.name as \"chromosome\"
	#		from DNA_VARIANT snp, chromosomes c 
	#		where 
	#		c.chromosome_id=snp.chromosome_id 
	#		and substr(c.name,1,2) =  '".$geneChrom."' "."
	#		and snp.organism = '".$organism."' "."
	#		and ((snp.Var_Start>=$geneStart and snp.Var_Start<=$geneStop) OR (snp.Var_Stop>=$geneStart and snp.Var_Stop<=$geneStop) OR (snp.Var_Start<=$geneStart and snp.Var_Stop>=$geneStop))
	#		order by snp.Var_Start";
	#}
	#else{
	#	die "Something is wrong with the RNA Isoform query \nChromosome#:$geneChrom\n";
	#}
	print $query."\n";
	$query_handle = $connect->prepare($query) or die (" RNA Isoform query prepare failed \n");

# EXECUTE THE QUERY
	$query_handle->execute() or die ( "RNA Isoform query execute failed \n");

# BIND TABLE COLUMNS TO VARIABLES

	$query_handle->bind_columns(\$id,\$strain ,\$ref_seq,\$strain_seq,\$start,\$stop,\$type,\$chr);
# Loop through results, adding to array of hashes.
	
	my $cntSnp=0;
	my %countHash;
	my %strainHOH;
	
	while($query_handle->fetch()) {
		#print "SETUP\t$id\t$strain\t$start\t$ref_seq\n";
		$snpHOH{Snp}[$cntSnp] = {
					ID => $id,
					strain => $strain,
					start=> $start,
					stop => $stop,
					refSeq => $ref_seq,
					strainSeq => $strain_seq,
					type => $type,
					chromosome => $chr
		};
		
		if(defined $strainHOH{$strain}){
			#print "defined $strain : ".$countHash{$strain}."\n";
			my $tmpCount=$countHash{$strain};
			$strainHOH{$strain}{Snp}[$tmpCount]=$snpHOH{Snp}[$cntSnp];
			$countHash{$strain}=$tmpCount+1;
		}else{
			#print "NOT DEFINED:$strain\n";
			$strainHOH{$strain}{Snp}[0]=$snpHOH{Snp}[$cntSnp];
			$countHash{$strain}=1;
		}
		$cntSnp++;
	}
	print "SNP Count:".$cntSnp."\n";
	$query_handle->finish();
	$connect->disconnect();
	return (\%strainHOH);
}
1;

