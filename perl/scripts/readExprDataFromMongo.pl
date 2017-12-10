#!/usr/bin/perl
# Subroutine to read information from database



# PERL MODULES WE WILL BE USING
use Bio::SeqIO;
use Text::CSV;
use MongoDB;

#use strict; Fix this
sub readExprDataFromDB{


	#INPUT VARIABLES
	# Chromosome for example chr12
	# Start position on the chromosome
	# Stop position on the chromosome

	# Read inputs
	my($dsid,$geneList,$heritFile,$dsn,$usr,$passwd)=@_;   

	my %exprHOH; # giant array of hashes and arrays containing gene/trx expr data

	my $client = MongoDB::MongoClient->new(host => $dsn,username => $usr, password => $passwd, db_name=>'admin',  auth_mechanism => 'SCRAM-SHA-1');
	my $database   = $client->get_database( 'RNASEQ_EXPR' );
	my %herit;

	# read heritability from file easier/faster than doing search for all matching gene 
	# transcript IDs since java code will have done it, can just outupt a file.
	open my $INPUTFH,'<',$heritFile || die ("Can't open $heritFile:!\n");
	while(<$INPUTFH>){
		my $line=$_;
		my @col=split("\t",$line);
		$col[1] =~ s/\s+$//;
		$herit{$col[0]}=$col[1];
		#print "{".$col[0]."}=".$col[1]."\n";
	}

	# get a list of strains from the data
	my $colKey = $database->get_collection( "strain_means_".$dsid."_keys" );
	my $cursor=$colKey->query( {},{});
	my @keys;
	my @klist=$cursor->all;
	foreach my $obj(@klist){
		my $tmpID=$obj->{'_id'};
		if($tmpID ne "GENEID" and $tmpID ne "TRXID" and $tmpID ne "_id"){
			push(@keys,$tmpID);
		}
	}
	print "connect  strain_means_".$dsid."\n";
	my $col = $database->get_collection( "strain_means_".$dsid );
	my @glist=split(",",$geneList);
	my @updatedList=[];
	foreach my $g(@glist){
		push(@updatedList,"$g");
	}
	print "initial:".$geneList."\n";
	print "list:".@glist."\n";
	my $rsCursor;
	if(@glist>1){
		$rsCursor=$col->find( { 'GENEID' => { '$in' => \@updatedList  } } )->result;
	}else{
		$rsCursor=$col->find( { 'GENEID' => "$geneList"} )->result;
	}
	my $listCount=0;
	my @list=$rsCursor->all;
	print "result list:".@list."\n";
	foreach my $obj(@list){
		if( defined $exprHOH{$obj->{'GENEID'}} ){

		}else{
			$exprHOH{$obj->{'GENEID'}}{GENE}={};
			
			$exprHOH{$obj->{'GENEID'}}{TRXLIST}=[];
		}

		my %tmpH={};
		$tmpH{GENEID}=$obj->{'GENEID'};
		$tmpH{TRXID}=$obj->{'TRXID'};
		#print $obj->{'TRXID'}.":".$herit{$obj->{'TRXID'}}."\n";
		$tmpH{HERIT}=$herit{$obj->{'TRXID'}};
		my @tmpArr;
		foreach my $valKey(@keys){
			my %val;
			$val{STRAIN}=$valKey;
			$val{CPM}=$obj->{$valKey};			
			push(@tmpArr,\%val);
		}
		$tmpH{VALUES}=\@tmpArr;

		if( $obj->{'TRXID'} == "" || $obj->{'GENEID'} eq $obj->{'TRXID'}){
			$exprHOH{$obj->{'GENEID'}}{GENE}=\%tmpH;
		}else{
			#my $ref=$exprHOH{$obj->{'GENEID'}}{TRXLIST};
			#print "tx list:".$ref."\n";
			#my @tmp=@$ref;
			#print "Adding Trx:".@{$exprHOH{$obj->{'GENEID'}}{TRXLIST}}."\n";
			push(@{$exprHOH{$obj->{'GENEID'}}{TRXLIST}},\%tmpH);
			#print "after Adding Trx ".@{$exprHOH{$obj->{'GENEID'}}{TRXLIST}}."\n";
		}
		$listCount++;
	}

	print "Gene/Trx Count:".$listCount."\n";

	return (\%exprHOH);
}

sub writeExprDataJSON {
	
	my($hashRef,$outFile)=@_;

	open my $OUT,">",$outFile;
	print $OUT "{\"GENELIST\":[\n";
	my %h=%$hashRef;
	my @geneIDList=keys %h;
	my $lc=0;
	foreach my $geneID(@geneIDList){
		#my %tmpGene=$h{$geneID};
		if($lc>0){
			print $OUT ",";
		}
		my $tmpHerit=$h{$geneID}{GENE}{HERIT};
		if(! defined $h{$geneID}{GENE}{HERIT}){
			$tmpHerit=0;
		}
		print $OUT "{\"GENEID\":\"".$geneID."\",\"HERIT\":".$tmpHerit.",";
		print $OUT "\"VALUES\":[";
		my $valRef=$h{$geneID}{GENE}{VALUES};
		my @tmpValues=@$valRef;
		my $vc=0;
		foreach my $curVal(@tmpValues){
			if($vc>0){
				print $OUT ",";
			}
			my %tmpH=%$curVal;
			print $OUT "{ \"Strain\":\"".$tmpH{STRAIN}."\",\"CPM\":".$tmpH{CPM}."}";
			$vc++;
		}
		print $OUT "],\"TRXLIST\":[";
		my $trc=0;
		foreach my $trRef(@{$h{$geneID}{TRXLIST}}){
			my %trHOH=%$trRef;
			if($trc>0){
				print $OUT ",";
			}
			$tmpHerit=$trHOH{HERIT};
			if(! defined $trHOH{HERIT}){
				$tmpHerit=0;
			}
			print $OUT "{\"TRXID\":\"".$trHOH{"TRXID"}."\",\"HERIT\":".$tmpHerit.",";
			print $OUT "\"VALUES\":[";
			my $vc=0;
			foreach my $curVal(@{$trHOH{VALUES}}){
				if($vc>0){
					print $OUT ",";
				}
				my %tmpH=%$curVal;
				print $OUT "{ \"Strain\":\"".$tmpH{STRAIN}."\",\"CPM\":".$tmpH{CPM}."}";
				
				$vc++;
			}
			print $OUT "]}";
			$trc++;
		}
		print $OUT "]}\n";
		$lc++;
	}
	print $OUT "]}";
	close $OUT;
	return 0;
}
1;

my $arg1 = $ARGV[0]; # output file
my $arg2 = $ARGV[1]; # dsid
my $arg3 = $ARGV[2]; # geneList
my $arg4 = $ARGV[3]; # heritFile
my $arg5 = $ARGV[4]; # dsn
my $arg6 = $ARGV[5]; #usr
my $arg7 = $ARGV[6]; #password

my $ref=readExprDataFromDB( $arg2, $arg3, $arg4, $arg5, $arg6, $arg7);
my %exprData=%$ref;

writeExprDataJSON(\%exprData,$arg1);

exit 0;

