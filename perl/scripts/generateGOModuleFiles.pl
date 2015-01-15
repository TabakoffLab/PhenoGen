#!/usr/bin/perl -w


use lib '/usr/share/tomcat/webapps/PhenoGen/perl/lib/ensembl_ucsc/ensembl/modules/';
#use lib '/usr/share/tomcat/webapps/PhenoGen/perl/lib/ensembl_ucsc/ensembl-funcgen/modules/';


#/usr/share/tomcat/webapps/PhenoGen/tmpData/modules/ 1 Mm "dbi:Oracle:dev.ucdenver.pvt" INIA INIA_dev

#params
#0-outputPath
#1-WGCNA Dataset ID
#2-RNA Dataset ID
#3-Organism (Mm or Rn)
#4-dsn
#5-user
#6-password
#7-path to adjMatrix files

use DBI;
use Bio::EnsEMBL::Registry;


sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub getParents{
    my $termRef=shift;
    my $moduleGOListRef=shift;
    my $moduleGOHOHRef=shift;
    my $geneID=shift;
    
    my $term=$$termRef;
    #my %moduleGOList1=%$moduleGOListRef;
    #my %moduleGOHOH1=%$moduleGOHOHRef;

    #if(not (defined $moduleGOListRef->{$term->accession()})){
        my @parents = @{ $term->parents( ) };
            my %tmp;
            $tmp{ID}=$term->accession();
            $tmp{name} = $term->name();
            $tmp{definition} = $term->definition();
        foreach my $par(@parents){
            #print "\t".$term->accession()."->".$par->accession()."|".$par->name()."\t".$par->is_root()."\n";
            if(defined $moduleGOHOHRef->{$par->accession()}{ID}){
            }else{
                if($par->is_root()==0){
                    getParents(\$par,\%moduleGOList1,\%moduleGOHOH1,"");
                }
                $moduleGOHOHRef->{$par->accession()}{ID}=$par->accession();
                $moduleGOHOHRef->{$par->accession()}{name} = $par->name();
                $moduleGOHOHRef->{$par->accession()}{definition} = $par->definition();
            }
            push(@{$moduleGOHOHRef->{$par->accession()}{children}},\%tmp);
            $moduleGOListRef->{$par->accession()}{ID}=$par->accession();
        }
        $moduleGOListRef->{$term->accession()}{ID}=$term->accession();
        $moduleGOHOHRef->{$term->accession()}{ID}=$term->accession();
        $moduleGOHOHRef->{$term->accession()}{name} = $term->name();
        $moduleGOHOHRef->{$term->accession()}{definition} = $term->definition();
    #}
}

sub printGOTermJSON{
    my $fh=shift;
    my $goRef=shift;
    my $term=shift;
    #my $term=$termRef;
    my %goHOH=%$goRef;
    if(defined $term and defined $goHOH{$term}{ID}){
        my @list=$goHOH{$term}{children};
        #print "print:$term:".$goHOH{$term}{ID}."\n";
        print $fh "{\"ID\":\"".$goHOH{$term}{ID}."\",";
        print $fh "\t\"Name\":\"".$goHOH{$term}{name}."\",";
        print $fh "\t\"children\":[\n";
        foreach my $val2(@list){
            #print "val2:\t".$val2."\n";
            if(defined $val2){
                foreach my $val3(@$val2){
                    #print "first val3:\t".$val3."\n";
                    my %tmp=%$val3;
                    #print "val3:\t".$tmp{ID}."\n";
                    printGOTermJSON($fh,\%goHOH, $tmp{ID} );
                    #print $fh "{\"ID\":\"$val2\"}\n";
                }
            }
        }
        print $fh "]\n}\n";
    }else{
        print "undefined:$term\n";
    }
}

my $wgcnaDataset=$ARGV[1];

my $path=$ARGV[0]."ds".$wgcnaDataset."/";

my $rnaDS=$ARGV[2];
my $org=$ARGV[3];

my $dsn=$ARGV[4];
my $user=$ARGV[5];
my $passwd=$ARGV[6];

my $longOrg="Mouse";
if($org eq "Rn"){
    $longOrg="Rat";
}

my $registry = 'Bio::EnsEMBL::Registry';
my $dbAdaptorNum =$registry->load_registry_from_db( 
        #-host => 'useastdb.ensembl.org', #'ensembldb.ensembl.org', # alternatively 'useastdb.ensembl.org'
        #-port => 5306,
	#-user => 'anonymous',
        #-verbose => '1'
		-host => "140.226.114.31", #'ensembldb.ensembl.org', # alternatively 'useastdb.ensembl.org'
		-port => "3306",
		-user => "ensembl",
		-pass => "INIA_ensembl1"
	    );
my $slice_adaptor = $registry->get_adaptor( $longOrg, 'Core', 'Slice' );
my @adaps = @{Bio::EnsEMBL::Registry->get_all_adaptors()};
my $go_adaptor = $registry->get_adaptor( 'Multi', 'Ontology', 'OntologyTerm' );

my $connect = DBI->connect($dsn, $user, $passwd) or die ($DBI::errstr ."\n");




mkdir($path);
my @moduleList=();
my $query="select unique wmi.module from wgcna_module_info wmi where wmi.wdsid=".$wgcnaDataset." order by module";

my $query_handle = $connect->prepare($query) or die ("Module query prepare failed \n");
$query_handle->execute() or die ( "Module query execute failed \n");
my $moduleName;
$query_handle->bind_columns(\$moduleName);
while($query_handle->fetch()) {
        push(@moduleList,$moduleName);
}
$query_handle->finish();


print "Module List: ".@moduleList."\n";

foreach my $mod(@moduleList){
    my %moduleHOH;
    my %moduleGOHOHA;
    #my %moduleGOList;
    #$moduleGOHOH{"GO:0005575"}={};
    #$moduleGOHOH{"GO:0008150"}={};
    #$moduleGOHOH{"GO:0003674"}={};
    
    print "processing $mod\n";
    my %adjHOH;
    my $query2="select wmi.probeset_id,wmi.transcript_clust_id,wmi.gene_id,wmi.module_id from wgcna_module_info wmi where wdsid=".$wgcnaDataset." and wmi.module='".$mod."' order by transcript_clust_id";
    my $query_handle2 = $connect->prepare($query2) or die ("Module query prepare failed \n");
    $query_handle2->execute() or die ( "Module query execute failed \n");
    my $psid;
    my $tc;
    my $geneid;
    my $tcCount=0;
    my $modID;

    $query_handle2->bind_columns(\$psid,\$tc,\$geneid,\$modID);
    while($query_handle2->fetch()) {
        $tcCount++;
        
        #print "$psid\t$tc\t$geneid\n";
        my $secondPeriod=index( $tc , "." , (index($tc,".")+1) );
        my $thisID=$tc;
        my $thisCluster="0";
        if ($secondPeriod>-1) {
            $thisID=substr($tc,0,$secondPeriod);
            $thisCluster=substr($tc,$secondPeriod+1);
        }
        


        if (not defined $moduleHOH{TCList}{$tc}{Gene}) {
            if (index($geneid,"ENS")==0) {
                #get ensembl gene/transcripts
                my $tmpslice = $slice_adaptor->fetch_by_gene_stable_id( $geneid, 0 );
                my $genes = $tmpslice->get_all_Genes();
                while(my $gene=shift @{$genes}){
                    my $geneName  = $gene->stable_id();
                    if ($geneName eq $geneid) {
                        my $geneChrom = $gene->slice->seq_region_name();
                        my $geneStart      = $gene->seq_region_start();
                        my $geneStop        = $gene->seq_region_end();
                        my $geneStrand     = $gene->seq_region_strand();
                        my $geneBioType = $gene->biotype();
                        my $geneExternalName = $gene->external_name();
                        my $geneDescription = $gene->description();
                        
                        
                        # "adding:$geneName:$geneExternalName\n";
                        $moduleHOH{TCList}{$tc}{Gene} = {
                                                            start => $geneStart,
                                                            stop => $geneStop,
                                                            ID => $geneName,
                                                            strand=>$geneStrand,
                                                            chromosome=>$geneChrom,
                                                            biotype => $geneBioType,
                                                            geneSymbol => $geneExternalName,
                                                            source => "Ensembl",
                                                            description => $geneDescription,
                                                            extStart => $geneStart ,
                                                            extStop => $geneStop
                                                        };
    
                        #Get the transcripts for this gene
                        #print "getting transcripts for ".$geneExternalName."\n";
                        my $transcripts = $gene->get_all_Transcripts();
                        my $cntTranscripts = 0;
                        while ( my $transcript = shift @{$transcripts} ) {
                            my $transcriptName  = $transcript->stable_id();
                            my $transcriptRegion = $transcript->slice->seq_region_name();
                            my $transcriptStart      = $transcript->seq_region_start();
                            my $transcriptStop        = $transcript->seq_region_end();
                            my $transcriptStrand     = $transcript->seq_region_strand();
                            my $transcriptChrom = "chr$transcriptRegion";
                            my $trcoding_region_start = $transcriptStart;
                            my $trcoding_region_stop = $transcriptStop;
                            if (defined $transcript->coding_region_start() and defined $transcript->coding_region_end()) {
                                $trcoding_region_stop = $transcript->coding_region_end() + $tmpslice->start() - 1;
                                $trcoding_region_start = $transcript->coding_region_start() + $tmpslice->start() - 1;
                            }
                            
                        
                            my @xrefs = @{ $transcript->get_all_xrefs("GO%") };
                            foreach my $xref(@xrefs){
                                my $primid = $xref->primary_id();
                                my $dispid = $xref->display_id();
                                my $db = $xref->dbname;
                                if(defined $dispid){
                                    my $term = $go_adaptor->fetch_by_accession($dispid);
                                    if(defined $term){
                                        getParents(\$term,\%moduleGOHOHA);
                                        my $lRef=$moduleGOHOHA{$term}{children};
                                        my @children=@$lRef;
                                        push(@children,$geneName);
                                    }
                                    
                                }
                            }
                            $cntTranscripts = $cntTranscripts+1;
                        } # loop through transcripts
                        
                    }
                }
                
            }else{
                
            }
        }
    }
    $query_handle2->finish();
    
   
    
    open OFILE, '>', $path.$mod.".json" or die " Could not open two track file $path$mod.json for writing $!\n\n";
    my $tmpMod=$mod;
    $tmpMod =~ s/\./_/g;
    print OFILE "{\n\t\"MOD_NAME\":\"$tmpMod\",\n";
    print OFILE "\t\"ModID\":".$modID.",\n";
    print OFILE "\t\"TCList\": [\n";

    my @tcKey=keys $moduleHOH{TCList};
    $tcCount=0;
    foreach my $tc(@tcKey){
        if ($tcCount>0) {
                print OFILE ",\n";
        }
        print OFILE "\t\t{\n\t\t\t\"ID\":\"$tc\",\n";
        print OFILE "\t\t\t\"LinkSum\":".$moduleHOH{TCList}{$tc}{linkSum}.",\n";
        print OFILE "\t\t\t\"LinkCount\":".$moduleHOH{TCList}{$tc}{linkCount}.",\n";
        print OFILE " \t\t\t\"Gene\":{";
        if (defined $moduleHOH{TCList}{$tc}{Gene}{ID}) {
            print OFILE " \"start\":".$moduleHOH{TCList}{$tc}{Gene}{start}.",";
            print OFILE " \"stop\":".$moduleHOH{TCList}{$tc}{Gene}{stop}.",";
            print OFILE " \"ID\":\"".$moduleHOH{TCList}{$tc}{Gene}{ID}."\",";
            print OFILE " \"strand\":\"".$moduleHOH{TCList}{$tc}{Gene}{strand}."\",";
            print OFILE " \"chromosome\":\"".$moduleHOH{TCList}{$tc}{Gene}{chromosome}."\",";
            print OFILE " \"biotype\":\"".$moduleHOH{TCList}{$tc}{Gene}{biotype}."\",";
            print OFILE " \"source\":\"".$moduleHOH{TCList}{$tc}{Gene}{source}."\",";
            print OFILE " \"geneSymbol\":\"".$moduleHOH{TCList}{$tc}{Gene}{geneSymbol}."\"";
            if(index($moduleHOH{TCList}{$tc}{Gene}{ID},"ENS")==0){
                
                if (defined $moduleHOH{TCList}{$tc}{Gene}{description}) {
                    my $tmpDesc=$moduleHOH{TCList}{$tc}{Gene}{description};
                    $tmpDesc=substr($tmpDesc,0,index($tmpDesc,"[")-1);
                    print OFILE ", \"description\":\"".$tmpDesc."\",";
                }else{
                    print OFILE ", \"description\":\"\",";
                }
                print OFILE " \"extStart\":".$moduleHOH{TCList}{$tc}{Gene}{extStart}.",";
                print OFILE " \"extStop\":".$moduleHOH{TCList}{$tc}{Gene}{extStop}."";
            }

            #if(defined $moduleHOH{TCList}{$tc}{Gene}{GOList}){
            #    print OFILE "\n\t\t\t\t\"GOList\":[\n";
            #    my @goKey=keys $moduleHOH{TCList}{$tc}{Gene}{GOList};
            #    my $goCount=0;
            #    foreach my $go(@goKey){
            #        if ($goCount>0) {
            #                print OFILE ",\n";
            #        }
                    #my $def=$moduleHOH{TCList}{$tc}{Gene}{GOList}{$go}{definition};
                    #my $ind=index($def,"\"",1);
                    #$def=substr($def,0,$ind+1);
            #        print OFILE "{\"ID\":\"".$moduleHOH{TCList}{$tc}{Gene}{GOList}{$go}{ID}."\",";
                    #print OFILE "\"Definition\":".$def.",";
            #        print OFILE "\"Name\":\"".$moduleHOH{TCList}{$tc}{Gene}{GOList}{$go}{name}."\",";
            #        print OFILE "\"domain\":\"".$moduleHOH{TCList}{$tc}{Gene}{GOList}{$go}{root}."\"";
            #        print OFILE "}";
            #        $goCount++;
            #    }
            #    print OFILE "\n\t\t\t\t]\n";#end GO List
            #}
        }else{
            print OFILE " \t\t\t\t\"ID\":\"Unannotated\"";
        }

       print OFILE "\t\t\t}\n";#end Gene
       print OFILE "\t\t}";
       $tcCount++;
    }
    print OFILE "\n\t]\n";#end TCList
    print OFILE "}";#end module
    close OFILE;

    #open OFILE, '>', $path.$mod.".GO.json" or die " Could not open two track file $path$mod.json for writing $!\n\n";
    #print OFILE "{\n\t\"MOD_NAME\":\"$tmpMod\",\n";
    #print OFILE "\t\"GOList\": [\n";
    #my @r;
    #push(@r,"GO:0005575");
    #push(@r,"GO:0008150");
    #push(@r,"GO:0003674");
    #foreach my $val(@r){
    #    print "TOP LEVEL\n";
    #    printGOTermJSON(\*OFILE,\%moduleGOHOH,$val);
    #    
    #}
    #print OFILE "\t\]\n";
    #print OFILE "}";#end module
    #close OFILE;

    open OFILE, '>', $path.$mod.".eQTL.json" or die " Could not open two track file $path$mod.eQTL.json for writing $!\n\n";
        print OFILE "[\n";
        for(my $i=0;$i<@eqtlAOH;$i++){
            if($i>0){
                print OFILE ",";
            }
            print OFILE "{ \"Chr\":\"chr".substr($eqtlAOH[$i]{chromosome},2)."\", \"Start\":".$eqtlAOH[$i]{location}.", \"Snp\":\"".$eqtlAOH[$i]{name}."\", \"Pval\":".$eqtlAOH[$i]{pvalue}."}\n";
        }
        print OFILE "]";
    close OFILE;

    my $chrString="mm1;mm2;mm3;mm4;mm5;mm6;mm7;mm8;mm9;mm10;mm11;mm12;mm13;mm14;mm15;mm16;mm17;mm18;mm19;mmX;";
    if($org eq "Rn"){   
        $chrString="rn1;rn2;rn3;rn4;rn5;rn6;rn7;rn8;rn9;rn10;rn11;rn12;rn13;rn14;rn15;rn16;rn17;rn18;rn19;rn20;rnX;";
    }
    my $tmpP=substr($path,0,index($path,"tmpData")+7);
    my $dsNum=substr($path,index($path,"/ds")+1,index($path,"/",index($path,"/ds")+1)-1);
    my $tmpPath=$tmpP."/circos/".$dsNum.$mod."/";
    print "Circos Path:".$tmpPath."\n";
    my $cutoff=2;
    
    callCircosMod($mod,$cutoff,$org,$chrString,"Brain",$tmpPath,"1",$modRGB,$dsn,$user, $passwd);
}