#!/usr/bin/perl -w
use strict;


#params
#0-outputPath
#1-WGCNA Dataset ID
#

use DBI;
use Bio::EnsEMBL::Registry;

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

my $registry = 'Bio::EnsEMBL::Registry';
$dbAdaptorNum =$registry->load_registry_from_db(
		-host => "140.226.114.31", #'ensembldb.ensembl.org', # alternatively 'useastdb.ensembl.org'
		-port => "3306",
		-user => "ensembl",
		-pass => "INIA_ensembl1"
	    );
my $slice_adaptor = $registry->get_adaptor( $species, $type, 'Slice' );

my $connect = DBI->connect("dbi:Oracle:dev.ucdenver.pvt", "INIA", "INIA_dev") or die ($DBI::errstr ."\n");

my $path=$ARGV[0];
my $wgcnaDataset=$ARGV[1];
my @moduleList=();
my $query="select unique module from wgcna_module_info where wdsid=".$wgcnaDataset;

my $query_handle = $connect->prepare($query) or die ("Module query prepare failed \n");
$query_handle->execute() or die ( "Module query execute failed \n");
my $moduleName;
$query_handle->bind_columns(\$moduleName);
while($query_handle->fetch()) {
    push(@moduleList,$moduleName);
}
$query_handle->finish();

foreach my $mod(@moduleList){
    my %moduleHOH;
    my $query2="select probeset_id,transcript_clust_id,gene_id from wgcna_module_info where wdsid=".$wgcnaDataset." and module='".$mod."'";
    my $query_handle2 = $connect->prepare($query2) or die ("Module query prepare failed \n");
    $query_handle2->execute() or die ( "Module query execute failed \n");
    my $psid;
    my $tc;
    my $geneid;
    $query_handle2->bind_columns(\$psid,\$tc,\$geneid);
    while($query_handle2->fetch()) {
        my $secondPeriod=index( $tc , "." , (index($tc,".")+1) );
        my $thisID=$tc;
        my $thisCluster="0";
        if ($secondPeriod>-1) {
            $thisID=substr($tc,0,$secondPeriod);
            $thisCluster=substr($tc,$secondPeriod+1);
        }
        if (index($geneid,"ENS")==0 and defined $moduleHOH{TCList}{$tc}) {
            #get ensembl gene/transcripts
            my $tmpslice = $slice_adaptor->fetch_by_gene_stable_id( $geneid, 0 );
	    my $genes = $tmpslice->get_all_Genes();
            
            #get rna-seq transcripts
            
        }elsif(index($geneid,"Brain")==0 or index($geneid,"Liver")==0 or index($geneid,"Heart")==0) {
            #get rna-seq transcripts
            
        }else{
            print "$mod\tNO GENE ID:\t$psid\t$tc\n";
        }
    }
    $query_handle2->finish();
    open OFILE, '>', $path.$mod.".json" or die " Could not open two track file $path$mod.json for writing $!\n\n";
    
    close OFILE;
}