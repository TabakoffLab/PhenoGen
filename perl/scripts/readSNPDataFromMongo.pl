#!/usr/bin/perl
# Subroutine to read information from database



# PERL MODULES WE WILL BE USING
use Bio::SeqIO;
use Text::CSV;
use MongoDB;

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
	my($genomeVer,$geneChrom,$organism,$geneStart,$geneStop,$dsn,$usr,$passwd)=@_;   


	my %snpHOH; # giant array of hashes and arrays containing probeset data
	
	if($organism eq 'Mouse'){
		$organism="Mm";
	}elsif($organism eq 'Rat'){
		$organism="Rn";
	}
        print "dsn:$dsn\n";
        print "usr:$usr\n";
        print "pass:$passwd\n";

	my $client = MongoDB::MongoClient->new(host => $dsn,username => $usr, password => $passwd, db_name=>'admin',  auth_mechanism => 'SCRAM-SHA-1');
	my $database   = $client->get_database( 'SNPS' );
	my $col = $database->get_collection( $genomeVer );
	
	print "opened DB\n";

	$geneChrom=uc($geneChrom);
	$geneStart=$geneStart*1;
	$geneStop=$geneStop*1;
	
	my $rsCursor=$col->query(
							{ 'CHROMOSOME'=>$geneChrom,
								'$or'=> [ {'START'=>{'$gte'=>$geneStart,'$lte'=>$geneStop}}, {'END'=>{'$gte'=>$geneStart,'$lte'=>$geneStop}} ]
							},
							{sort_by => {'START'=>1}}
							);
	print "cursor\n";
	my $listCount=0;
	my %countHash;
	my %strainHOH;
	#print "COUNT:".$rsCursor->count."\n";
	my @list=$rsCursor->all;
	foreach my $obj(@list){
		$snpHOH{Snp}[$listCount] = {
									strain => $obj->{'STRAIN'},
									start=> $obj->{'START'},
									stop => $obj->{'END'},
									refSeq => $obj->{'REF'},
									strainSeq => $obj->{'ALT'},
									type => $obj->{'TYPE'},
									chromosome => $obj->{'CHROMOSOME'}
		};
		if(defined $strainHOH{$obj->{'STRAIN'}}){
			#print "defined $strain : ".$countHash{$strain}."\n";
			my $tmpCount=$countHash{$obj->{'STRAIN'}};
			$strainHOH{$obj->{'STRAIN'}}{Snp}[$tmpCount]=$snpHOH{Snp}[$listCount];
			$countHash{$obj->{'STRAIN'}}=$tmpCount+1;
		}else{

			$strainHOH{$obj->{'STRAIN'}}{Snp}[0]=$snpHOH{Snp}[$listCount];
			$countHash{$obj->{'STRAIN'}}=1;
		}
		
		$listCount++;
	}

	print "SNP Count:".$listCount."\n";

	return (\%strainHOH);
}
1;

