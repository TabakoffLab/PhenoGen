#!/usr/bin/perl -w


use lib '/Library/Tomcat/webapps/PhenoGen/perl/lib/ensembl_88/ensembl/modules/';
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
    my $moduleGOHOHARef=shift;
    my $geneNameRef=shift;
    my $term=$$termRef;
    my $gn=$$geneNameRef;
    #print "start getParents(".$term->accession().")\n";

    #my @keyList=keys %moduleGOHOH1;
    #print $term->accession()."before key List:";
    #foreach my $tmpKey(@keyList){
    #    print ",".$tmpKey; 
    #}
    #print "\n";
    my @parents = [];
    if($term->is_root()==0){
        @parents = @{ $term->parents( ) };
        foreach my $par(@parents){
            #print "\t".$term->accession()."->".$par->accession()."|".$par->name()."\t".$par->is_root()."\n";
            getParents(\$par,$moduleGOHOHARef,\$gn);
            #print "after getParents:".$par->accession()."\t:".$moduleGOHOH1{$par->accession()}{ID}.":\n";
            my $found=0;
            DUPLICATE:foreach my $child(@{$moduleGOHOHARef->{$par->accession()}{children}}){
                if($child eq $term->accession()){
                    $found=1;
                    last DUPLICATE;
                }
            }
            if($found==0){
                push(@{$moduleGOHOHARef->{$par->accession()}{children}},$term->accession());
            }
        }
    }
    
    #setup current term before returning
    #print "test if exists:".$term->accession()."\t:".$moduleGOHOH1{$term->accession()}{ID}.":\n";

    my $id=$term->accession();
    if(not (exists $moduleGOHOHARef->{$id}{ID})){
        $moduleGOHOHARef->{$id}{ID}=$term->accession();
        $moduleGOHOHARef->{$id}{name} = $term->name();
        $moduleGOHOHARef->{$id}{definition} = $term->definition();
        $moduleGOHOHARef->{$id}{children} = [];
        $moduleGOHOHARef->{$id}{unique} = [];
        push(@{$moduleGOHOHARef->{$id}{unique}},$gn);
        $moduleGOHOHARef->{$id}{parents} = \@parents;
    }else{
        my $found=0;
        DUPLICATEGENEPARENT:foreach my $child2(@{$moduleGOHOHARef->{$id}{unique}}){
            if($child2 eq $gn){
                $found=1;
                last DUPLICATEGENEPARENT;
            }
        }
        if($found==0){
            push(@{$moduleGOHOHARef->{$id}{unique}},$gn);
        }
    }
}


sub isDuplicated{
    my $childID=shift;
    my $parentID=shift;
    my $goHOHRef=shift;
    my $duplicate=0;
    if(index($childID,"ENS")>-1){
        my @toCheck=@{$goHOHRef->{$parentID}{children}};
        DONECHECK:foreach my $check(@toCheck){
            if(index($check,"ENS")==-1){
                my @uniqueL=@{$goHOHRef->{$check}{unique}};
                foreach my $unique(@uniqueL){
                    if($unique eq $childID){
                        $duplicate=1;
                        last DONECHECK;
                    }
                }
            }
        }
    }
    return $duplicate;
}

sub printGOTermJSON{
    my $fh=shift;
    my $goRef=shift;
    my $term=shift;
    
    if(defined $term and defined $goRef->{$term}{ID}){
        my @list=@{$goRef->{$term}{children}};
        my @uniquelist=@{$goRef->{$term}{unique}};
        my $def=$goRef->{$term}{definition};
        $def=substr($def,0,rindex($def,"\"")+1);
        #print "print:$term:".$goHOH{$term}{ID}."\n";
        print $fh "{\"id\":\"".$goRef->{$term}{ID}."\",";
        print $fh "\"name\":\"".$goRef->{$term}{name}."\",";
        print $fh "\"definition\":".$def.",";
        print $fh "\"uniqueGene\":\"".@uniquelist."\",";
        print $fh "\"uniqueGenes\":[";
        my $uc=0;
        foreach my $val3(@uniquelist){
            if($uc>0){
                print $fh ",";
            }
            print $fh "{\"id\":\"".$val3."\"}";
            $uc++;
        }
        print $fh "],";
        print $fh "\"children\":[";
        #print "Print ID".$goRef->{$term}{ID}."\n\tChildren:";
        my $count=0;
        foreach my $val2(@list){
            #print "\t".$val2."\n";
            if(defined $val2){
                if(isDuplicated($val2,$term,$goRef)==0){
                    if($count>0){
                            print $fh ",";
                    }
                    if(index($val2,"GO")==0){
                        printGOTermJSON($fh,$goRef, $val2 );
                    }else{    
                        print $fh "{\"id\":\"".$val2."\",\"name\":\"".$val2."\",\"size\":1}";
                    }
                    $count++;
                }
            }
        }
        #print "\n";
        print $fh "]}";
    }else{
        print "undefined:".$term;
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
		-host => "phenogen.ucdenver.pvt", #'ensembldb.ensembl.org', # alternatively 'useastdb.ensembl.org'
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
#$query_handle->fetch();
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
        #my $secondPeriod=index( $tc , "." , (index($tc,".")+1) );
        my $thisID=$geneid;
        my $thisCluster="0";
        #if ($secondPeriod>-1) {
        #    $thisID=substr($tc,0,$secondPeriod);
        #    $thisCluster=substr($tc,$secondPeriod+1);
        #}
        


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
                                            getParents(\$term,\%moduleGOHOHA,\$geneName);
                                            my $found=0;
                                            DUPLICATEGENE:foreach my $child2(@{$moduleGOHOHA{$term->accession()}{children}}){
                                                if($child2 eq $geneName){
                                                    $found=1;
                                                    last DUPLICATEGENE;
                                                }
                                            }
                                            if($found==0){
                                                push(@{$moduleGOHOHA{$term->accession()}{children}},$geneName);
                                            }
                                            
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
    
   
    open OFILE, '>', $path.$mod.".GO.json" or die " Could not open two track file $path$mod.json for writing $!\n\n";
    print OFILE "{\"MOD_NAME\":\"$mod\",";
    print OFILE "\"GOList\": [";
    my @r;
    push(@r,"GO:0005575");
    push(@r,"GO:0008150");
    push(@r,"GO:0003674");
    my $tmpCount=0;
    foreach my $val(@r){
        #print "TOP LEVEL\n";
        if($tmpCount>0){
            print OFILE ",\n";
        }
        printGOTermJSON(\*OFILE,\%moduleGOHOHA,$val);
        $tmpCount++;
    }
    print OFILE "\]";
    print OFILE "}";#end module
    close OFILE;

}