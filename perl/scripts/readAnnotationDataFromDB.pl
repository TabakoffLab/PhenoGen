#!/usr/bin/perl
# Subroutine to read information from database



# PERL MODULES WE WILL BE USING
use Bio::SeqIO;
use Text::CSV;
#use strict;

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


sub readTranscriptAnnotationDataFromDB{


	#INPUT VARIABLES
	# Chromosome for example chr12
	# Start position on the chromosome
	# Stop position on the chromosome

	# Read inputs
	my($geneChrom,$organism,$publicUserID,$panel,$geneStart,$geneStop,$dsn,$usr,$passwd,$shortName,$type)=@_;   
	
	#open PSFILE, $psOutputFileName;//Added to output for R but now not needed.  R will read in XML file
	#print "read probesets chr:$geneChrom\n";
	#Initializing Arrays

	my %annotHOH; # giant array of hashes and arrays containing annotation data
	
	
	# DATA SOURCE NAME
	#$dsn = "dbi:$platform:$service_name";
	
	# PERL DBI CONNECT
	my $connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");
	
	my $query="";
	
	#my $geneChromNumber = addChr($geneChrom,"subtract");
	
	
	# PREPARE THE QUERY for probesets
	# There's got to be a better way to handle the chromosome...
	#if(length($geneChrom) == 1){
		$query ="select rta.rna_transcript_id, rta.annotation, ras.shrt_name,rta.match_reason
		from rna_transcripts_annot rta, rna_annot_src ras
		where rta.source_id=ras.rna_annot_src_id
		and rta.rna_transcript_id in
		(Select rt.rna_transcript_id
			from rna_dataset rd, rna_transcripts rt, rna_exons re,chromosomes c 
			where 
			c.chromosome_id=rt.chromosome_id 
			and c.name =  '".uc($geneChrom)."' "."
			and re.rna_transcript_id=rt.rna_transcript_id 
			and rt.rna_dataset_id=rd.rna_dataset_id 
			and rd.organism = '".$organism."' "."
			and rd.user_id= $publicUserID  
			and rd.visible=1 
			and rd.strain_panel like '".$panel."' "."
			and ((trstart>=$geneStart and trstart<=$geneStop) OR (trstop>=$geneStart and trstop<=$geneStop) OR (trstart<=$geneStart and trstop>=$geneStop)))
		order by rta.rna_transcript_id";
	#}
	#elsif(length($geneChrom) == 2) {
	#	$query ="select rta.rna_transcript_id, rta.annotation, ras.shrt_name,rta.match_reason
	#	from rna_transcripts_annot rta, rna_annot_src ras
	#	where rta.source_id=ras.rna_annot_src_id
	#	and rta.rna_transcript_id in
	#	(Select rt.rna_transcript_id
	#		from rna_dataset rd, rna_transcripts rt, rna_exons re,chromosomes c 
	#		where 
	#		c.chromosome_id=rt.chromosome_id 
	#		and substr(c.name,1,2) =  '".$geneChrom."' "."
	#		and re.rna_transcript_id=rt.rna_transcript_id 
	#		and rt.rna_dataset_id=rd.rna_dataset_id 
	#		and rd.organism = '".$organism."' "."
	#		and rd.user_id= $publicUserID  
	#		and rd.visible=1 
	#		and rd.strain_panel like '".$panel."' "."
	#		and ((trstart>=$geneStart and trstart<=$geneStop) OR (trstop>=$geneStart and trstop<=$geneStop) OR (trstart<=$geneStart and trstop>=$geneStop)))
	#	order by rta.rna_transcript_id";
	#}
	#else{
	#	die "Something is wrong with the annotation query \nChromosome#:$geneChrom\n";
	#}
	#print $query."\n";
	my $query_handle = $connect->prepare($query) or die (" RNA annotation query prepare failed \n");

# EXECUTE THE QUERY
	$query_handle->execute() or die ( "RNA annotation query execute failed \n");

# BIND TABLE COLUMNS TO VARIABLES

	my $trID;
	my $annotation;
	my $src_name;
	my $reason;
	my $curCount=0;
	my $previousID="";


	$query_handle->bind_columns(\$trID,\$annotation,\$src_name,\$reason);
# Loop through results, adding to array of hashes.
	
	while($query_handle->fetch()) {
		if($trID eq $previousID){
			$annotHOH{$trID}[$curCount]= {
					source => $src_name,
					annot_value=> $annotation,
					reason => $reason
				};
		}else{
			$curCount=0;
			$annotHOH{$trID}[$curCount]= {
					source => $src_name,
					annot_value=> $annotation,
					reason => $reason
				};
			$previousID=$trID;
		}
		$curCount++;
	}
	$query_handle->finish();
	$connect->disconnect();
	
	return (\%annotHOH);
}

sub readSmallNCAnnotationDataFromDB{


	#INPUT VARIABLES
	# Chromosome for example chr12
	# Start position on the chromosome
	# Stop position on the chromosome

	# Read inputs
	my($geneChrom,$organism,$publicUserID,$panel,$geneStart,$geneStop,$dsn,$usr,$passwd)=@_;   
	
	#open PSFILE, $psOutputFileName;//Added to output for R but now not needed.  R will read in XML file
	#print "read probesets chr:$geneChrom\n";
	#Initializing Arrays

	my %annotHOH; # giant array of hashes and arrays containing annotation data
	
	
	# DATA SOURCE NAME
	#$dsn = "dbi:$platform:$service_name";
	
	# PERL DBI CONNECT
	my $connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");
	
	my $query="";
	
	#my $geneChromNumber = addChr($geneChrom,"subtract");
	
	
	# PREPARE THE QUERY for probesets
	# There's got to be a better way to handle the chromosome...
	#if(length($geneChrom) == 1){
		$query ="select rsa.rna_smnc_id,rsa.rna_smnc_annot_id, rsa.annotation, ras.shrt_name
		from rna_smnc_annot rsa, rna_annot_src ras
		where rsa.source_id=ras.rna_annot_src_id
		and rsa.rna_smnc_id in
		(Select rs.rna_smnc_id
			from rna_dataset rd, rna_sm_noncoding rs, chromosomes c 
			where 
			c.chromosome_id=rs.chromosome_id 
			and c.name =  '".uc($geneChrom)."' "."
			and rs.rna_dataset_id=rd.rna_dataset_id 
			and rd.organism = '".$organism."' "."
			and rd.user_id= $publicUserID  
			and rd.visible=1 
			and rd.strain_panel like '".$panel."' "."
			and ((rs.feature_start>=$geneStart and rs.feature_start<=$geneStop) OR (rs.feature_stop>=$geneStart and rs.feature_stop<=$geneStop) OR (rs.feature_start<=$geneStart and rs.feature_stop>=$geneStop)))
		order by rsa.rna_smnc_id";
	#}
	#elsif(length($geneChrom) == 2) {
	#	$query ="select rsa.rna_smnc_id,rsa.rna_smnc_annot_id, rsa.annotation, ras.shrt_name
	#	from rna_smnc_annot rsa, rna_annot_src ras
	#	where rsa.source_id=ras.rna_annot_src_id
	#	and rsa.rna_smnc_id in
	#	(Select rs.rna_smnc_id
	#		from rna_dataset rd, rna_sm_noncoding rs, chromosomes c 
	#		where 
	#		c.chromosome_id=rs.chromosome_id 
	#		and c.name =  '".$geneChrom."' "."
	#		and rs.rna_dataset_id=rd.rna_dataset_id 
	#		and rd.organism = '".$organism."' "."
	#		and rd.user_id= $publicUserID  
	#		and rd.visible=1 
	#		and rd.strain_panel like '".$panel."' "."
	#		and ((rs.feature_start>=$geneStart and rs.feature_start<=$geneStop) OR (rs.feature_stop>=$geneStart and rs.feature_stop<=$geneStop) OR (rs.feature_start<=$geneStart and rs.feature_stop>=$geneStop)))
	#	order by rsa.rna_smnc_id";
	#}
	#else{
	#	die "Something is wrong with the annotation query \nChromosome#:$geneChrom\n";
	#}
	#print $query."\n";
	my $query_handle = $connect->prepare($query) or die (" RNA annotation query prepare failed \n");

# EXECUTE THE QUERY
	$query_handle->execute() or die ( "RNA annotation query execute failed \n");

# BIND TABLE COLUMNS TO VARIABLES

	my $smncID;
	my $smncAnnotID;
	my $annotation;
	my $src_name;
	my $curCount=0;
	my $previousID="";


	$query_handle->bind_columns(\$smncID,\$smncAnnotID,\$annotation,\$src_name);
	# Loop through results, adding to array of hashes.
	
	while($query_handle->fetch()) {
		if($smncID eq $previousID){
			$annotHOH{$smncID}[$curCount]= {
					source => $src_name,
					annot_id => $smncAnnotID,
					annot_value=> $annotation
				};
		}else{
			$curCount=0;
			$annotHOH{$smncID}[$curCount]= {
					source => $src_name,
					annot_id => $smncAnnotID,
					annot_value=> $annotation
				};
			$previousID=$smncID;
		}
		$curCount++;
	}
	$query_handle->finish();
	$connect->disconnect();
	
	return (\%annotHOH);
}


1;

