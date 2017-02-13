#!/usr/bin/perl -w


use lib '/Library/Tomcat/webapps/PhenoGen/perl/lib/ensembl_84/ensembl/modules';
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
		-host => "phenogen.ucdenver.pvt",
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
    $moduleHOH{id}=$mod;
    $moduleHOH{miRNA}={};
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
                open GENE,"<",$geneCache.$geneid.".summary.txt";
                my $header=<GENE>;
                my @cols=split('\t',trim($header));
                my %columnHash;
                my $count=0;
                foreach my $col(@cols){
                    $columnHash{$col}=$count;
                    $count++;
                }
                while (<GENE>){
                    my @columns=split('\t',$_);
                    my $miID="";
                    my $miACC="";
                    my $pred=0;
                    my $val=0;
                    
                    if(exists $columnHash{"mature_mirna_acc"}){
                        $miACC=trim($columns[$columnHash{"mature_mirna_acc"}]);
                    }	
                    if(exists $columnHash{"mature_mirna_id"}){
                        $miID=trim($columns[$columnHash{"mature_mirna_id"}]);
                    }
                    if(exists $columnHash{"predicted.sum"}){
                        $pred=trim($columns[$columnHash{"predicted.sum"}]);
                    }
                    if(exists $columnHash{"validated.sum"}){
                        $val=trim($columns[$columnHash{"validated.sum"}]);
                    }	
                    $sum=$pred+$val;
                    if(exists $moduleHOH{miRNA}{$miACC}){
                        $moduleHOH{miRNA}{$miACC}{gene}{$geneid}={
                                                ID => $geneid,
                                                Predicted => $pred,
                                                Validated => $val,
                                                Sum => $sum
                        };
                    }else{
                        $moduleHOH{miRNA}{$miACC}{ID}=$miID;
                        $moduleHOH{miRNA}{$miACC}{ACC}=$miACC;
                        $moduleHOH{miRNA}{$miACC}{gene}{$geneid}={
                                                ID => $geneid,
                                                Predicted => $pred,
                                                Validated => $val,
                                                Sum => $sum
                        };
                    }
                }
                close GENE;
            }else{
                mkdir $geneCache;
                #create R call
                open OFILE,">",$geneCache."callR";
                print OFILE "source('/Library/Tomcat/webapps/PhenoGen/R_src/multiMiR.getMiRTargetingGene.R')\n";
                print OFILE "multiMiR.getMiRTargetingGene(geneID='".$geneid."',organism='".$mmOrg."',outputDir='".$geneCache."',outputPrefix='".$geneid."',tbl='all',cutoffType='p',cutoff=10)\n";            
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
                #open GENE,"<",$geneCache.$geneid.".summary.txt";
                #my $header=<GENE>;
                #my @cols=split('\t',trim($header));
                #my %columnHash;
                #my $count=0;
                #foreach my $col(@cols){
                #    $columnHash{$col}=$count;
                #    $count++;
                #}
                #while (<GENE>){
                #    my @columns=split('\t',$_);
                #    my $miID="";
                #    my $miACC="";
                #    my $pred=0;
                #    my $val=0;
                    
                #    if(exists $columnHash{"mature_mirna_acc"}){
                #        $miACC=trim($columns[$columnHash{"mature_mirna_acc"}]);
                #    }	
                #    if(exists $columnHash{"mature_mirna_id"}){
                #        $miID=trim($columns[$columnHash{"mature_mirna_id"}]);
                #    }
                #    if(exists $columnHash{"predicted.sum"}){
                #        $pred=trim($columns[$columnHash{"predicted.sum"}]);
                #    }
                #    if(exists $columnHash{"validated.sum"}){
                #        $val=trim($columns[$columnHash{"validated.sum"}]);
                #    }	
                #    $sum=$pred+$val;
                #    if(exists $moduleHOH{miRNA}{$miACC}){
                #        $moduleHOH{miRNA}{$miACC}{gene}{$geneid}={
                #                                ID => $geneid,
                #                                Predicted => $pred,
                #                                Validated => $val,
                #                                Sum => $sum
                #        };
                #    }else{
                #        $moduleHOH{miRNA}{$miACC}{ID}=$miID;
                #        $moduleHOH{miRNA}{$miACC}{ACC}=$miACC;
                #        $moduleHOH{miRNA}{$miACC}{gene}{$geneid}={
                #                                ID => $geneid,
                #                                Predicted => $pred,
                #                                Validated => $val,
                #                                Sum => $sum
                #        };
                #    }
                #}
                #close GENE;
            }
            
        }
    }
    $query_handle2->finish();
    
   
    open OFILE, '>', $path.$mod.".miR.json" or die " Could not open two track file $path$mod.json for writing $!\n\n";
    print OFILE "{\"MOD_NAME\":\"$mod\",";
    print OFILE "\"MIRList\": [\n";
    my $mirKey=keys $moduleHOH{miRNA};
    $mirCount=0;
    foreach my $mir(@mirKey){
        my @geneKey=keys $moduleHOH{miRNA}{$mir}{gene};
        if ($mirCount>0) {
                print OFILE ",\n";
        }
        print OFILE "{ \"ID\":\"".$moduleHOH{miRNA}{$mir}{ID}."\",";
        print OFILE "\"name\":\"".$moduleHOH{miRNA}{$mir}{ID}."\",";
        print OFILE "\"value\":".@geneKey.",";
        print OFILE "\"ACC\":\"".$moduleHOH{miRNA}{$mir}{ACC}."\",";
        print OFILE "\"GeneList\": [";
        
        my $geneCount=0;
        my $validCount=0;
        foreach my $gene(@geneKey){
            if ($geneCount>0) {
                    print OFILE ",";
            }
            print OFILE "{ \"ID\":\"".$moduleHOH{miRNA}{$mir}{gene}{$gene}{ID}."\",";
            print OFILE "\"P\":".$moduleHOH{miRNA}{$mir}{gene}{$gene}{Predicted}.",";
            print OFILE "\"V\":".$moduleHOH{miRNA}{$mir}{gene}{$gene}{Validated}.",";
            print OFILE "\"S\":".$moduleHOH{miRNA}{$mir}{gene}{$gene}{Sum}."}";
            if($moduleHOH{miRNA}{$mir}{gene}{$gene}{Validated}>0){
                $validCount++;
            }
            $geneCount++;
        }
        print OFILE "],\"vC\":".$validCount;
        print OFILE "}";
        $mirCount++;
    }
    print OFILE "]";
    print OFILE "}";#end module
    close OFILE;

}