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

    my @parents = [];
    if($term->is_root()==0){
        @parents = @{ $term->parents( ) };
        foreach my $par(@parents){
            getParents(\$par,$moduleGOHOHARef,\$gn);
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
        my $count=0;
        foreach my $val2(@list){
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
        print $fh "]}";
    }else{
        print "undefined:".$term;
    }
}

sub getGO{

    my ($org,$workingDir,$inputFile,$outputFile,$host,$user,$passwd)=@_;

    my $longOrg="Mouse";
    if($org eq "Rn"){
        $longOrg="Rat";
    }

    my $registry = 'Bio::EnsEMBL::Registry';
    my $dbAdaptorNum =$registry->load_registry_from_db( 
    		-host => $host, #'ensembldb.ensembl.org', # alternatively 'useastdb.ensembl.org'
    		-port => "3306",
    		-user => $user,
    		-pass => $passwd
    	    );

    my $mca =$registry->get_adaptor( $longOrg, 'Core',"MetaContainer" );

    my $database_version = 0;
    if ( defined($mca) ) {
            $database_version = $mca->get_schema_version();
    }
    open VER, ">",$workingDir."ver.txt";
    print VER $database_version."\n";
    close VER;

    my $slice_adaptor = $registry->get_adaptor( $longOrg, 'Core', 'Slice' );
    my $go_adaptor = $registry->get_adaptor( 'Multi', 'Ontology', 'OntologyTerm' );

    #read in input file
    my @geneList;
    my %geneGOHOHA;

    open IFILE,"<",$workingDir.$inputFile;

    while(<IFILE>){
        my $line=$_;
        $line=trim($line);
        if($line eq ""){

        }else{
            push(@geneList,$line);
        }
    }


    foreach my $geneID(@geneList) {
        my $tmpslice = $slice_adaptor->fetch_by_gene_stable_id( $geneID, 0 );
        my $genes = $tmpslice->get_all_Genes();
        while(my $gene=shift @{$genes}){
            my $geneName  = $gene->stable_id();
            if ($geneName eq $geneID) {
                my $transcripts = $gene->get_all_Transcripts();
                my $cntTranscripts = 0;
                while ( my $transcript = shift @{$transcripts} ) {
                    my @xrefs = @{ $transcript->get_all_xrefs("GO%") };
                    foreach my $xref(@xrefs){
                            my $primid = $xref->primary_id();
                            my $dispid = $xref->display_id();
                            my $db = $xref->dbname;
                            if(defined $dispid){
                                my $term = $go_adaptor->fetch_by_accession($dispid);
                                if(defined $term){
                                    getParents(\$term,\%geneGOHOHA,\$geneName);
                                    my $found=0;
                                    DUPLICATEGENE:foreach my $child2(@{$geneGOHOHA{$term->accession()}{children}}){
                                        if($child2 eq $geneName){
                                            $found=1;
                                            last DUPLICATEGENE;
                                        }
                                    }
                                    if($found==0){
                                        push(@{$geneGOHOHA{$term->accession()}{children}},$geneName);
                                    }
                                    
                                }

                            }
                    }
                    $cntTranscripts = $cntTranscripts+1;
                } # loop through transcripts   
            }
        }         
    }
    
   
    open OFILE, '>', $workingDir.$outputFile or die " Could not open two track file $path$mod.json for writing $!\n\n";
    print OFILE "{\"MOD_NAME\":\"GeneList\",";
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
        printGOTermJSON(\*OFILE,\%geneGOHOHA,$val);
        $tmpCount++;
    }
    print OFILE "\]";
    print OFILE "}";#end module
    close OFILE;

}

my $arg1=$ARGV[0];
my $arg2=$ARGV[1];
my $arg3=$ARGV[2];
my $arg4=$ARGV[3];
my $arg5=$ARGV[4];
my $arg6=$ARGV[5];
my $arg7=$ARGV[6];


getGO($arg1,$arg2,$arg3,$arg4,$arg5,$arg6,$arg7);

exit 0;

