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

require 'callCircosModule.pl';

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
    my %moduleGOList1=%$moduleGOListRef;
    my %moduleGOHOH1=%$moduleGOHOHRef;

    if(not (defined $moduleGOListRef->{$term->accession()})){
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
    }
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
my $adjPath=$ARGV[7];

my $adjCutoff=0.01;

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
    #if(index($moduleName,"white")==0 or index($moduleName,"yellow")==0){
        push(@moduleList,$moduleName);
    #}
}
$query_handle->finish();


#my %colorHash;
#open COL,'<','/usr/local/circos-0.67-2/etc/colors.unix.txt' || die ("Can't open $toolTipFileName:$!");
#while(<COL>){
#    my $line=$_;
#    print $line;
#    my @cols=split("=",$line);
#    $cols[0]=trim($cols[0]);
#    $cols[1]=trim($cols[1]);
#    $colorHash{$cols[0]}=$cols[1];
#}
#close(COL);


print "Module List: ".@moduleList."\n";

foreach my $mod(@moduleList){
    my %moduleHOH;
    my %moduleGOHOH;
    my %moduleGOList;
    #$moduleGOHOH{"GO:0005575"}={};
    #$moduleGOHOH{"GO:0008150"}={};
    #$moduleGOHOH{"GO:0003674"}={};
    
    print "processing $mod\n";
    my %adjHOH;

    #GET LINKS FROM ADJ MATRIX
    #print "OPEN ADJ:".$adjPath."/".$mod.".adjMat\n";
    open ADJ, "<",$adjPath."/".$mod.".adjMat";
    my $header=<ADJ>;
    my @adjTC=split("\t",$header);
    for(my $row=0;$row<@adjTC;$row++){
        $adjTC[$row]=trim(substr($adjTC[$row],length($mod)+1));
        $adjTC[$row]=~ s/^total\./Brain_C/;
        $adjTC[$row]=~ s/^XLOC_0+/Brain_C/;
        $adjTC[$row]=~ s/clust//;
        #print "tcName:".$adjTC[$row]."\n";
    }
    my $linkCount=0;
    for(my $row=0;$row<@adjTC;$row++){
        my $line=<ADJ>;
        my @columns=split("\t",$line);
        for(my $col=0;$col<$row;$col++){#only read first part up to the 1 since its symmetrical
            $adjHOH{$adjTC[$row]}{$adjTC[$col]}=$columns[$col];
            $moduleHOH{LinkList}[$linkCount]={
                                                TC1=>$adjTC[$row],
                                                TC2=>$adjTC[$col],
                                                cor=>$columns[$col]
                                            };
            $linkCount++;
        }
    }
    close ADJ;
    my $query2="select wmi.probeset_id,wmi.transcript_clust_id,wmi.gene_id,wmi.module_id,wmc.rgb,wmc.hex from wgcna_module_info wmi, wgcna_module_colors wmc where wdsid=".$wgcnaDataset." and wmi.module='".$mod."' and wmc.module=wmi.module  order by transcript_clust_id";
    my $query_handle2 = $connect->prepare($query2) or die ("Module query prepare failed \n");
    $query_handle2->execute() or die ( "Module query execute failed \n");
    my $psid;
    my $tc;
    my $geneid;
    my $tcCount=0;
    my $modID;
    my $modRGB;
    my $modHex;
    $query_handle2->bind_columns(\$psid,\$tc,\$geneid,\$modID,\$modRGB,\$modHex);
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
        $moduleHOH{TCList}{$tc}{PSList}{$psid}{ID}=$psid;
        my $query3="select a.strand,c.name,a.psstart,a.psstop,a.pslevel from Affy_exon_probeset a, chromosomes c where c.chromosome_id=a.chromosome_id
                        and a.probeset_id=".$psid." and a.updatedlocation= 'Y'";
        my $query_handle3 = $connect->prepare($query3) or die ("Module query prepare failed \n");
        $query_handle3->execute() or die ( "Module query execute failed \n");
        my $psstrand;
        my $psstart;
        my $psstop;
        my $pslevel;
        my $pschr;
        $query_handle3->bind_columns(\$psstrand,\$pschr,\$psstart,\$psstop,\$pslevel);
        if ($query_handle3->fetch()) { 
            $moduleHOH{TCList}{$tc}{PSList}{$psid}{Strand}=$psstrand;
            $moduleHOH{TCList}{$tc}{PSList}{$psid}{Start}=$psstart;
            $moduleHOH{TCList}{$tc}{PSList}{$psid}{Stop}=$psstop;
            $moduleHOH{TCList}{$tc}{PSList}{$psid}{Level}=$pslevel;
            $moduleHOH{TCList}{$tc}{PSList}{$psid}{Chr}=$pschr;
        }
        $query_handle3->finish();
        
        my $hohRef=$adjHOH{$tc};
        my @linkTCList=keys %$hohRef;
        my $linkSum=0;
        my $linkCount=0;

        foreach my $dest(@linkTCList){
            $linkSum=$linkSum+abs($adjHOH{$tc}{$dest});
            if(abs($adjHOH{$tc}{$dest})>$adjCutoff){
                $linkCount++;
            }
        }
        $moduleHOH{TCList}{$tc}{linkSum}=$linkSum;
        $moduleHOH{TCList}{$tc}{linkCount}=$linkCount;


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
                            $moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript}[$cntTranscripts]{start} = $transcriptStart;
                            $moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript}[$cntTranscripts]{stop} = $transcriptStop;
                            $moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript}[$cntTranscripts]{ID} = $transcriptName;
                            $moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript}[$cntTranscripts]{strand} = $transcriptStrand;
                            $moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript}[$cntTranscripts]{chromosome} = $transcriptChrom;
                            $moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript}[$cntTranscripts]{cdsStart} = $trcoding_region_start;
                            $moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript}[$cntTranscripts]{cdsStop} = $trcoding_region_stop;
                            my $tmpStrand=$transcriptStrand;
                            
                            my $cntExons = 0;
                            my $cntIntrons=0;
                            
                            # On to the exons
                            #sort first so introns can be created as we go
                            my @tmpExons= @{ $transcript->get_all_Exons() };
                            my @sortedExons = sort { $a->seq_region_start() <=> $b->seq_region_start() } @tmpExons;
                            
                            foreach my $exon ( @sortedExons ) {
                                    my $exonName  = $exon->stable_id();
                                    my $exonRegion = $exon->slice->seq_region_name();
                                    my $exonStart      = $exon->seq_region_start();
                                    my $exonStop        = $exon->seq_region_end();
                                    my $exonStrand     = $exon->seq_region_strand();
                        
                                    #print "get Exons\n";
                                    my $exonChrom = "chr$exonRegion";
                                    # have to offset the stop and start by the slice start
                                    my $coding_region_start = $exonStart;
                                    my $coding_region_stop = $exonStop;
                                    if (defined $exon->coding_region_end($transcript) and defined $exon->coding_region_start($transcript)) {
                                        $coding_region_stop = $exon->coding_region_end($transcript) + $tmpslice->start() - 1;
                                        $coding_region_start = $exon->coding_region_start($transcript) + $tmpslice->start() - 1;
                                    }
                                    
                                    $moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{start} = $exonStart;
                                    $moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{stop} = $exonStop;
                                    $moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{ID} = $exonName;
                                    $moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{strand} = $exonStrand;
                                    $moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{chromosome} = $exonChrom;
                                    $moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{coding_start} = $coding_region_start;
                                    $moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{coding_stop} = $coding_region_stop;
                                    #print "added exon $exonName\n";
                                    my $intronStart=-1;
                                    my $intronStop=-1;
                                    #create intronList
                                    if($cntExons>0){
                                        $intronStart=$moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons-1]{stop}+1;
                                        $intronStop=$moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript}[$cntTranscripts]{exonList}{exon}[$cntExons]{start}-1;
                                        
                                        $moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript}[$cntTranscripts]{intronList}{intron}[$cntIntrons]{start} = $intronStart;
                                        $moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript}[$cntTranscripts]{intronList}{intron}[$cntIntrons]{stop} = $intronStop;
                                        $moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript}[$cntTranscripts]{intronList}{intron}[$cntIntrons]{ID} = $cntIntrons+1;
                                        $cntIntrons=$cntIntrons+1;
                                    }
                                    $cntExons=$cntExons+1;
                                    #print "finished matching probesets\n";
                            } # loop through exons
                        
                            #my @xrefs = @{ $transcript->get_all_xrefs("GO%") };
                            #foreach my $xref(@xrefs){
                            #    my $primid = $xref->primary_id();
                            #    my $dispid = $xref->display_id();
                            #    my $db = $xref->dbname;
                            #    if(defined $dispid){
                            #        my $term = $go_adaptor->fetch_by_accession($dispid);
                            #        if(not (defined $moduleHOH{TCList}{$tc}{Gene}{GOList}{$dispid}) && defined $term){
                            #            
                            #            $moduleHOH{TCList}{$tc}{Gene}{GOList}{$dispid}={
                            #                                ID => $dispid,
                            #                                name => $term->name(),
                            #                                root => $term->namespace(),
                            #                                definition => $term->definition()
                            #                    };
                            #        }
                                    #print $dispid."\n";
                                    #if(not (defined $moduleGOList{$dispid})){
                                    #    #print $dispid."\n";
                                    #    #get parents and add to moduleGO
                                    #    getParents(\$term,\%moduleGOList,\%moduleGOHOH,$geneName);
                                    #    $moduleGOList{$term->accession()}{genes}{$geneName}=1;    
                                    #    #print "end\n";
                                    #}else{
                                    #    #add gene to GO
                                    #}
                            #    }
                            #}
                            $cntTranscripts = $cntTranscripts+1;
                        } # loop through transcripts
                        
                    }
                }
                
            }else{
                #get rna-seq transcripts
                my $trxQ="select c.name,rt.source,rt.trstart,rt.trstop,rt.strand,rt.category from rna_transcripts rt, chromosomes c 
                         where c.chromosome_id=rt.chromosome_id and rt.gene_id='".$geneid."' and rt.rna_dataset_id=".$rnaDS." order by rt.trstart,rt.trstop";
                #print $trxQ."\n";
                my $qh = $connect->prepare($trxQ) or die ("RNA_Transcript query prepare failed \n");
                $qh->execute() or die ( "RNA_Transcript query execute failed \n");
                my $gMax=-1;
                my $gMin=999999999;
                my $fStrand=0;
                my $fSource="";
                my $fCat="";
                my $fChr="";

                my $gChr;
                my $gSource;
                my $gStart;
                my $gStop;
                my $gStrand;
                my $gCat;
                
                $qh->bind_columns(\$gChr,\$gSource,\$gStart,\$gStop,\$gStrand,\$gCat);
                while($qh->fetch()) {
                    if($gStart<$gMin){
                        $gMin=$gStart;
                    }
                    if($gMax<$gStop){
                        $gMax=$gStop;
                    }
                    $fStrand=$gStrand;
                    $fSource=$gSource;
                    $fCat=$gCat;
                    $fChr=$gChr;
                }
                $qh->finish();
                $moduleHOH{TCList}{$tc}{Gene} = {
                                                            start => $gMin,
                                                            stop => $gMax,
                                                            ID => $geneid,
                                                            strand=>$fStrand,
                                                            chromosome=>$fChr,
                                                            biotype => $fCat,
                                                            #geneSymbol => $geneExternalName,
                                                            source => $fSource,
                                                            #description => $geneDescription,
                                                            #extStart => $geneStart ,
                                                            #extStop => $geneStop
                                                        };
            }
        }
    }
    $query_handle2->finish();
    

    
    
    
    open OFILE, '>', $path.$mod.".json" or die " Could not open two track file $path$mod.json for writing $!\n\n";
    my $tmpMod=$mod;
    $tmpMod =~ s/\./_/g;
    print OFILE "{\n\t\"MOD_NAME\":\"$tmpMod\",\n";
    print OFILE "\t\"ModID\":".$modID.",\n";
    print OFILE "\t\"ModRGB\":\"".$modRGB."\",\n";
    print OFILE "\t\"ModHex\":\"".$modHex."\",\n";
    print OFILE "\t\"TCList\": [\n";
    #my $tcRef=$moduleHOH{TCList};
    #my %tcHOH=%{$tcRef};
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
            print OFILE " \"source\":\"".$moduleHOH{TCList}{$tc}{Gene}{source}."\"";
            if(index($moduleHOH{TCList}{$tc}{Gene}{ID},"ENS")==0){
                print OFILE ", \"geneSymbol\":\"".$moduleHOH{TCList}{$tc}{Gene}{geneSymbol}."\",";
                if (defined $moduleHOH{TCList}{$tc}{Gene}{description}) {
                    my $tmpDesc=$moduleHOH{TCList}{$tc}{Gene}{description};
                    $tmpDesc=substr($tmpDesc,0,index($tmpDesc,"[")-1);
                    print OFILE " \"description\":\"".$tmpDesc."\",";
                }else{
                    print OFILE " \"description\":\"\",";
                }
                print OFILE " \"extStart\":".$moduleHOH{TCList}{$tc}{Gene}{extStart}.",";
                print OFILE " \"extStop\":".$moduleHOH{TCList}{$tc}{Gene}{extStop}."";
            }
#            print OFILE "\n\t\t\t\t\"TranscriptList\":[\n";
#            my $trxSizeRef=$moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript};
#            my @trxList=@$trxSizeRef;
#            my $trxcount=0;
#            foreach my $trxRef(@trxList){
#                my %trxHOH=%$trxRef;
#                if ($trxcount>0) {
#                    print OFILE ",\n";
#                }
#                print OFILE "\t\t\t\t\t{ \"start\":".$trxHOH{start}.",";
#                print OFILE " \"stop\":".$trxHOH{stop}.",";
#                print OFILE " \"ID\":\"".$trxHOH{ID}."\",";
#                print OFILE " \"strand\":\"".$trxHOH{strand}."\",";
#                print OFILE " \"cdsStart\":\"".$trxHOH{cdsStart}."\",";
#                print OFILE " \"cdsStop\":\"".$trxHOH{cdsStop}."\",";
#                print OFILE " \n\t\t\t\t\t\t\"exonList\":[\n";
#                my $exSizeRef=$trxHOH{exonList}{exon};
#                my @exList=@$exSizeRef;
#                my $excount=0;
#                foreach my $exRef(@exList){
#                    my %exHOH=%$exRef;
#                    if ($excount>0) {
#                        print OFILE ",\n";
#                    }
#                    print OFILE "\t\t\t\t\t\t\t{ ";
#                    print OFILE " \"ID\":\"".$exHOH{ID}."\",";
#                    print OFILE " \"start\":".$exHOH{start}.",";
#                    print OFILE " \"stop\":".$exHOH{stop}.",";
#                    print OFILE " \"cdsStart\":\"".$trxHOH{cdsStart}."\",";
#                    print OFILE " \"cdsStop\":\"".$trxHOH{cdsStop}."\"";
#                    print OFILE "}";#end exon Object
#                    $excount++;
#                }
#                print OFILE "\n\t\t\t\t\t\t],\n";
#                print OFILE "\n\t\t\t\t\t\t\"intronList\":[\n";
#                my $intSizeRef=$trxHOH{intronList}{intron};
#                if (defined $intSizeRef) {
#                    my @intList=@$intSizeRef;
#                    my $intcount=0;
#                    foreach my $intRef(@intList){
#                        my %intHOH=%$intRef;
#                        if ($intcount>0) {
#                            print OFILE ",\n";
#                        }
#                        print OFILE "\t\t\t\t\t\t\t{ ";
#                        print OFILE " \"ID\":\"".$intHOH{ID}."\",";
#                        print OFILE " \"start\":".$intHOH{start}.",";
#                        print OFILE " \"stop\":".$intHOH{stop};
#                        print OFILE "}";#end exon Object
#                        $intcount++;
#                    }
#                }

#                print OFILE "\n\t\t\t\t\t\t]\n";
#                print OFILE "\t\t\t\t\t}";#end Transcript Object
#                $trxcount++;
#            }
#            print OFILE "\n\t\t\t\t],\n";#end Transcript List
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

       print OFILE "\t\t\t},\n";#end Gene
       print OFILE "\t\t\t\"PSList\":[\n";
       my @psKey=keys $moduleHOH{TCList}{$tc}{PSList};
       my $pscount=0;
       foreach my $ps(@psKey){
            if ($pscount>0) {
                print OFILE ",\n";
            }
            print OFILE "\t\t\t\t{ \"ID\":\"$ps\",";
            print OFILE "\"Strand\":\"".$moduleHOH{TCList}{$tc}{PSList}{$ps}{Strand}."\",";
            print OFILE "\"Start\":".$moduleHOH{TCList}{$tc}{PSList}{$ps}{Start}.",";
            print OFILE "\"Stop\":".$moduleHOH{TCList}{$tc}{PSList}{$ps}{Stop}.",";
            print OFILE "\"Chr\":\"".$moduleHOH{TCList}{$tc}{PSList}{$ps}{Chr}."\",";
            print OFILE "\"Level\":\"".$moduleHOH{TCList}{$tc}{PSList}{$ps}{Level}."\"";
            print OFILE "}";
            $pscount++;
       }
       print OFILE "\n\t\t\t]\n";
       print OFILE "\t\t}";
       $tcCount++;
    }
    print OFILE "\n\t],\n";#end TCList
    print OFILE "\t\"LinkList\": [\n";
    my $linklistRef=$moduleHOH{LinkList};
    my @linklist=@$linklistRef;
    print "output data struct size:".@linklist."\n";
    for(my $link=0;$link<@linklist;$link++){
        if($link>0){
            print OFILE "\t\t,\n";
        }
        print OFILE "\t\t\t{\n";
        print OFILE "\t\t\t\t\"TC1\":\"".$moduleHOH{LinkList}[$link]{TC1}."\",\n";
        print OFILE "\t\t\t\t\"TC2\":\"".$moduleHOH{LinkList}[$link]{TC2}."\",\n";
        print OFILE "\t\t\t\t\"Cor\":".$moduleHOH{LinkList}[$link]{cor}."\n";
        print OFILE "\t\t\t}";
    }
    print OFILE "\n\t]\n";#end LinkList
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

    my $chrString="mm1;mm2;mm3;mm4;mm5;mm6;mm7;mm8;mm9;mm10;mm11;mm12;mm13;mm14;mm15;mm16;mm17;mm18;mm19;mmX;";
    if($org eq "Rn"){   
        $chrString="rn1;rn2;rn3;rn4;rn5;rn6;rn7;rn8;rn9;rn10;rn11;rn12;rn13;rn14;rn15;rn16;rn17;rn18;rn19;rn20;rnX;";
    }
    my $tmpPath=$path.$mod."/";
    my $cutoff=2;
    
    callCircosMod($mod,$cutoff,$org,$chrString,"Brain",$tmpPath,"1",$modRGB,$dsn,$user, $passwd);
}