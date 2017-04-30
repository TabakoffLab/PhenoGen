#!/usr/bin/perl
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


sub readLocusSpecificPvaluesModule{


	#INPUT VARIABLES: $probeID, $organism

	# Read inputs
	my($module,$organism,$tissue,$chromosomeListRef,$genomeVer,$dsn,$usr,$passwd,$type)=@_;   
	my @chromosomeList = @{$chromosomeListRef};
	my $numberOfChromosomes = scalar @chromosomeList;
	# $hostname is used to determine the connection to the database.
	my $hostname = hostname;

	
	if ($tissue eq "Brain") {
		$tissue="Whole Brain";
	}
	
	#Initializing Array

	my @eqtlAOH; # array of hashes containing location specific eqtl data
	

	#print "readModuleData.pl:type:$type\n";

	# PERL DBI CONNECT
	my $connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");
	#print "readModuleData.pl:type:$type\n";
	# PREPARE THE QUERY for pvalues
    my $query = "select  s.SNP_NAME, c.name,  s.SNP_START, e.PVALUE
                        from wgcna_location_eqtl e, snps s, chromosomes c
                        where s.organism='$organism'
                        and s.tissue='$tissue'
                        and s.snp_id=e.snp_id
                        and s.genome_id='".$genomeVer."'
                        and s.type='$type'
                        and c.chromosome_id=s.chromosome_id
                        and e.pvalue>=1
                        and e.wdsid in (Select wd.wdsid from wgcna_dataset wd where wd.organism='$organism' and wd.tissue='$tissue' and wd.genome_id='$genomeVer' and wd.visible=1)
                        and e.module_id in 
                            (Select wi.module_id from wgcna_module_info wi where 
                                wi.wdsid in (Select wd.wdsid from wgcna_dataset wd where wd.organism='$organism' and wd.tissue='$tissue' and wd.genome_id='$genomeVer' and wd.visible=1) 
                        and wi.module='$module')
                        order by e.pvalue";
    #print "$query\n";
                      
	my $query_handle = $connect->prepare($query) or die (" Location Specific EQTL query prepare failed $!");

# EXECUTE THE QUERY
	$query_handle->execute() or die ( "Location Specific EQTL query execute failed $!");

# BIND TABLE COLUMNS TO VARIABLES
	my ($dbsnp_name, $dbchrom_name, $dbsnp_location,  $dbpvalue);
	$query_handle->bind_columns(\$dbsnp_name ,\$dbchrom_name, \$dbsnp_location,\$dbpvalue);
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
			$eqtlAOH[$counter]{tissue}=$tissue;
			$eqtlAOH[$counter]{pvalue}=$dbpvalue;
		}
	}
	$query_handle->finish();
	$connect->disconnect();
        
	return (\@eqtlAOH);
}
1;