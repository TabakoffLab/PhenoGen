#!/usr/bin/perl -w


use lib '/usr/share/tomcat/webapps/PhenoGen/perl/lib/ensembl_ucsc/ensembl/modules/';
#use lib '/usr/share/tomcat/webapps/PhenoGen/perl/lib/ensembl_ucsc/ensembl-funcgen/modules/';


#/usr/share/tomcat/webapps/PhenoGen/tmpData/modules/ 1 Mm "dbi:Oracle:dev.ucdenver.pvt" User Passwd

#params
#0-outputPath
#1-WGCNA Dataset ID
#2-RNA Dataset ID
#3-Organism (Mm or Rn)
#4-dsn
#5-user
#6-password


use DBI;
use Bio::EnsEMBL::Registry;


sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}


my $wgcnaDataset=$ARGV[1];

my $path=$ARGV[0]."ds".$wgcnaDataset."/";

my $rnaDS=$ARGV[2];
my $org=$ARGV[3];

my $dsn=$ARGV[4];
my $user=$ARGV[5];
my $passwd=$ARGV[6];

my $longOrg="Mouse";
my $mmOrg="mmu";
if($org eq "Rn"){
    $longOrg="Rat";
    $mmOrg="rno";
}

my $registry = 'Bio::EnsEMBL::Registry';
my $dbAdaptorNum =$registry->load_registry_from_db( 
		-host => "140.226.114.31",
		-port => "3306",
		-user => "ensembl",
		-pass => "INIA_ensembl1"
	    );
my $slice_adaptor = $registry->get_adaptor( $longOrg, 'Core', 'Slice' );
my @adaps = @{Bio::EnsEMBL::Registry->get_all_adaptors()};
my $go_adaptor = $registry->get_adaptor( 'Multi', 'Ontology', 'OntologyTerm' );

my $connect = DBI->connect($dsn, $user, $passwd) or die ($DBI::errstr ."\n");
my $mcache=$path."cache/";
mkdir($path);
mkdir($mcache);
my @moduleList=();
my $query="select unique wmi.module from wgcna_module_info wmi where wmi.wdsid=".$wgcnaDataset." order by module";

my $query_handle = $connect->prepare($query) or die ("Module query prepare failed \n");
$query_handle->execute() or die ( "Module query execute failed \n");
my $moduleName;
$query_handle->bind_columns(\$moduleName);
#$query_handle->fetch();
while($query_handle->fetch()) {
        push(@moduleList,$moduleName);
}
$query_handle->finish();


print "Module List: ".@moduleList."\n";




foreach my $mod(@moduleList){
    my %moduleHOH;
    print "processing $mod\n";
    my $query2="select wmi.gene_id from wgcna_module_info wmi where wdsid=".$wgcnaDataset." and wmi.module='".$mod."'";
    my $query_handle2 = $connect->prepare($query2) or die ("Module query prepare failed \n");
    $query_handle2->execute() or die ( "Module query execute failed \n");
    my $psid;
    my $tc;
    my $geneid;
    my $tcCount=0;
    my $modID;
    
    
    $query_handle2->bind_columns(\$geneid);
    while($query_handle2->fetch()) {
        if(index($geneid,"ENS") ==0){
            #if a ensembl Gene multiMir File exist
            my $geneCache=$mcache.$geneid."/";
            if(-e $geneCache){

            }else{
                mkdir $geneCache;
                #create R call
                open OFILE,">",$geneCache."callR";
                print OFILE "source('/usr/share/tomcat/webapps/PhenoGen/R_src/multiMiR.getMiRTargetingGene.R')\n";
                print OFILE "multiMiR.getMiRTargetingGene(geneID='".$geneid."',organism='".$mmOrg."',outputDir='".$geneCache."',outputPrefix='".$geneid."',tbl='all',cutoffType='p',cutoff=20)\n";            
                close OFILE;

                #call R
                #my @systemArgs = ("R","CMD", "BATCH", "--no-save", "--no-restore",$geneCache."callR",">",$geneCache."Rout.txt");
                #print " System call with these arguments: R CMD BATCH --no-save --no-restore $geneCache"."callR > $geneCache"."Rout.txt \n";
                system("R CMD BATCH --no-save --no-restore $geneCache"."callR > $geneCache"."Rout.txt");
                if ( $? == -1 )
                {
                            print "System Call failed: $!\n";
                }
                elsif ($?>0)
                {
                            printf "System Call exited with value %d", $? >> 8;
                }
                #read output

            }
            
        }
    }
    $query_handle2->finish();
    
   
    #open OFILE, '>', $path.$mod.".miR.json" or die " Could not open two track file $path$mod.json for writing $!\n\n";
    #print OFILE "{\n\t\"MOD_NAME\":\"$mod\",\n";
    #print OFILE "\t\"MIRList\": [\n";
    
    #print OFILE "\t\]\n";
    #print OFILE "}";#end module
    #close OFILE;

}