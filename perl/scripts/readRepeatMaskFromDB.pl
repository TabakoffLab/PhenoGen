#!/usr/bin/perl
# Subroutine to read information from database


#use strict; Fix this

sub readRepeatMaskFromDB{


	#INPUT VARIABLES
	# Chromosome for example chr12
	# Start position on the chromosome
	# Stop position on the chromosome

	# Read inputs
	my($geneChrom,$organism,$geneStart,$geneStop,$dsn,$usr,$passwd)=@_;   
	
	#reading from UCSC database so need to convert 1 based coordinates to 0 based
        $geneStart--;
        $geneStop--;


	my %repeatHOH; # giant array of hashes and arrays containing transcript data
	
	
	# DATA SOURCE NAME
	#$dsn = "dbi:$platform:$service_name";
	if(index($geneChrom,"chr")==-1){
		$geneChrom="chr".$geneChrom;
	}
	
	my $shortOrg="mm10";
	if($organism eq 'Rat'){
		$shortOrg="rn5";
	}
	
	# PERL DBI CONNECT
	$connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");
	
		$query ="SELECT m.milliDiv,m.milliDel,m.milliIns,m.genoName,m.genoStart,m.genoEnd,m.repName,m.repClass,m.repFamily
			FROM rmsk m
			where m.genoName='".$geneChrom."'
			and ((".$geneStart."<=m.genoStart and m.genoStart<=".$geneStop.") or (".$geneStart."<=m.genoEnd and m.genoEnd<=".$geneStop.") or (m.genoStart<=".$geneStart." and ".$geneStop."<=m.genoEnd))
			order by m.genoStart,m.repName";
	
	
	$query_handle = $connect->prepare($query) or die (" read Repeat Mask query prepare failed \n");

# EXECUTE THE QUERY
	$query_handle->execute() or die ( "RefSeq query execute failed \n");

# BIND TABLE COLUMNS TO VARIABLES

	$query_handle->bind_columns(\$mismatch ,\$deletion,\$insertion,\$chr,\$start,\$stop,\$name,\$class,\$family);
# Loop through results, adding to array of hashes.

        my $cntRepeat=0;
	
	while($query_handle->fetch()) {
			$repeatHOH{Feature}[$cntRepeat] = {
				start => $start,
				stop => $stop,
				ID => $cntRepeat+1,
				chromosome=>$chr,
				name => $name,
				class => $class,
				family => $family,
                                mis => $mismatch,
                                ins => $insertion,
                                del => $deletion
				};
                        $repeatHOH{Feature}[$cntRepeat]{BlockList}{Block}[0] ={
                                                                        start => $start,
                                                                        stop => $stop
                                                                    };
                        $cntRepeat++;
	}
	$query_handle->finish();
	$connect->disconnect();
	
	return (\%repeatHOH);
}

1;

