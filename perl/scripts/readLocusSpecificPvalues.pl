#!/usr/bin/perl
# Subroutine to read information from pre-loaded database files
# This routine reads from LOCUS_SPECIFIC_EQTL CHROMOSOMES and SNPS
# 


# PERL MODULES WE WILL BE USING


use strict; 
use DBI;
use Sys::Hostname;
use List::Util qw[min max];


sub renameChromosome{
	# For circos, the chromosome number or letter (1,2,X,Y etc.) needs to be preceeded by 'mm' or 'rn'
	# depending on the species
	my ($chromosomeNumber,$organism)=@_;
	my $newChrom = lc($organism).$chromosomeNumber;
	return $newChrom;
}
1;


sub readLocusSpecificPvalues{


	#INPUT VARIABLES: $probeID, $organism

	# Read inputs
	my($probeID,$organism,$chromosomeListRef,$dsn,$usr,$passwd)=@_;   
	my @chromosomeList = @{$chromosomeListRef};
	my $numberOfChromosomes = scalar @chromosomeList;
	# $hostname is used to determine the connection to the database.
	#my $hostname = hostname;

	my $debugLevel = 2;
	if($debugLevel >= 1){
		print " In readLocusSpecificPvalues \n";
		print "Probe ID: ".$probeID."\n";
		print "Organism: ".$organism."\n";
		print "Number of Chromosomes for running Circos ".$numberOfChromosomes."\n";
		print "first chromosome ".$chromosomeList[0]."\n";
	}
	#Initializing Array

	my @eqtlAOH; # array of hashes containing location specific eqtl data
		
	#Set up to read the Locus Specific Pvalue information from three tables in the database.
	

	my $locationSpecificEQTLTablename = 'Location_Specific_EQTL';
	my $snpTablename = 'SNPS';
	my $chromosomeTablename = 'Chromosomes';
	
	# DATA SOURCE NAME
	#my $dsn = "dbi:$platform:$service_name";
	if($debugLevel >= 1){
		print "dsn: $dsn \n";
		#print "usr: $usr \n";
		#print "passwd: $passwd \n";
	}
	
	# PERL DBI CONNECT
	my $connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");

	# PREPARE THE QUERY for pvalues

	my $query = "select s.SNP_NAME, c.NAME, s.SNP_LOCATION, e.TISSUE, e.PVALUE
		      from $snpTablename s, $chromosomeTablename c, $locationSpecificEQTLTablename e
		      where
		      e.PROBE_ID = $probeID
		      and e.organism = '$organism'
		      and s.chromosome_id = c.chromosome_id
		      and e.SNP_ID = s.SNP_ID";
		      
	if ($debugLevel >= 2){
		print $query."\n";
	}
	my $query_handle = $connect->prepare($query) or die (" Location Specific EQTL query prepare failed $!");

# EXECUTE THE QUERY
	$query_handle->execute() or die ( "Location Specific EQTL query execute failed $!");


# BIND TABLE COLUMNS TO VARIABLES
	my ($dbsnp_name, $dbchrom_name, $dbsnp_location, $dbtissue, $dbpvalue);
	$query_handle->bind_columns(\$dbsnp_name ,\$dbchrom_name, \$dbsnp_location,\$dbtissue, \$dbpvalue);
	my $counter = -1;
	my $currentChromosome;
	my $keepThisChromosome;
# Loop through results, adding to array of hashes.	
	while($query_handle->fetch()) {
		#Only populate hash for chromosomes in the chromosome list
		$currentChromosome = renameChromosome($dbchrom_name,$organism);
		$keepThisChromosome = 0;
		for(my $i=0;$i<$numberOfChromosomes;$i++){
			if($currentChromosome eq $chromosomeList[$i]){
				$keepThisChromosome = 1;
			}
		}
		if( $keepThisChromosome == 1 ){
			$counter++;
			$eqtlAOH[$counter]{name}=$dbsnp_name;
			$eqtlAOH[$counter]{chromosome}=renameChromosome($dbchrom_name,$organism);
			$eqtlAOH[$counter]{location}=$dbsnp_location;
			$eqtlAOH[$counter]{tissue}=$dbtissue;
			$eqtlAOH[$counter]{pvalue}=$dbpvalue;
		}
	}
	$query_handle->finish();
	$connect->disconnect();
	if($debugLevel >= 2){
		print " Finished loading array \n";
		print " Total in Array ".$counter."\n";
	}
	if($debugLevel >= 3){
		my $i;
		for ($i = 0; $i < min(10,$counter);$i++){
			print " i: ",$i,"\n";
			print " Name: ".$eqtlAOH[$i]{name}."\n";
			print " Chromosome: ".$eqtlAOH[$i]{chromosome}."\n";
			print " Location: ".$eqtlAOH[$i]{location}."\n";
			print " Tissue: ".$eqtlAOH[$i]{tissue}."\n";
			print " PValue: ".$eqtlAOH[$i]{pvalue}."\n";
		}
	}
	return (\@eqtlAOH);
}
1;

# Sample call: readLocusSpecificPvalues(7024599,'Rn');
