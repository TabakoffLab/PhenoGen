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
my $dbAdaptorNum =$registry->load_registry_from_db(
		-host => "140.226.114.31", #'ensembldb.ensembl.org', # alternatively 'useastdb.ensembl.org'
		-port => "3306",
		-user => "ensembl",
		-pass => "INIA_ensembl1"
	    );
my $slice_adaptor = $registry->get_adaptor( 'Mouse', 'Core', 'Slice' );

my $connect = DBI->connect("dbi:Oracle:dev.ucdenver.pvt", "INIA", "INIA_dev") or die ($DBI::errstr ."\n");


my $wgcnaDataset=$ARGV[1];
my $path=$ARGV[0]."ds".$wgcnaDataset."/";
mkdir($path);
my @moduleList=();
my $query="select unique module from wgcna_module_info where wdsid=".$wgcnaDataset." order by module";

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
    print "processing $mod\n";
    my $query2="select probeset_id,transcript_clust_id,gene_id from wgcna_module_info where wdsid=".$wgcnaDataset." and module='".$mod."' order by transcript_clust_id";
    my $query_handle2 = $connect->prepare($query2) or die ("Module query prepare failed \n");
    $query_handle2->execute() or die ( "Module query execute failed \n");
    my $psid;
    my $tc;
    my $geneid;
    my $tcCount=0;
    $query_handle2->bind_columns(\$psid,\$tc,\$geneid);
    while($query_handle2->fetch()) {
        $tcCount++;
        #if ($tcCount%200==0) {
        #    print "...$tcCount\n";
        #}
        
        #print "$psid\t$tc\t$geneid\n";
        my $secondPeriod=index( $tc , "." , (index($tc,".")+1) );
        my $thisID=$tc;
        my $thisCluster="0";
        if ($secondPeriod>-1) {
            $thisID=substr($tc,0,$secondPeriod);
            $thisCluster=substr($tc,$secondPeriod+1);
        }
        #if (defined $moduleHOH{TCList}{$tc}) {
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
        #}elsif (index($geneid,"ENS")==0) {
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
                        $cntTranscripts = $cntTranscripts+1;
                        } # loop through transcripts
                    }
                }
            }
            #get rna-seq transcripts
        }
    }
    $query_handle2->finish();
    open OFILE, '>', $path.$mod.".json" or die " Could not open two track file $path$mod.json for writing $!\n\n";
    my $tmpMod=$mod;
    $tmpMod =~ s/\./_/g;
    print OFILE "{\n\t\"MOD_NAME\":\"$tmpMod\",\n";
    print OFILE "\t\"TCList\": [\n";
        my @tcKey=keys $moduleHOH{TCList};
        $tcCount=0;
        foreach my $tc(@tcKey){
            if ($tcCount>0) {
                    print OFILE ",\n";
            }
            print OFILE "\t\t{\n\t\t\t\"ID\":\"$tc\",\n";
            print OFILE " \t\t\t\"Gene\":{";
            if (defined $moduleHOH{TCList}{$tc}{Gene}{ID}) {
                print OFILE " \"start\":".$moduleHOH{TCList}{$tc}{Gene}{start}.",";
                print OFILE " \"stop\":".$moduleHOH{TCList}{$tc}{Gene}{stop}.",";
                print OFILE " \"ID\":\"".$moduleHOH{TCList}{$tc}{Gene}{ID}."\",";
                print OFILE " \"strand\":\"".$moduleHOH{TCList}{$tc}{Gene}{strand}."\",";
                print OFILE " \"chromosome\":\"".$moduleHOH{TCList}{$tc}{Gene}{chromosome}."\",";
                print OFILE " \"biotype\":\"".$moduleHOH{TCList}{$tc}{Gene}{biotype}."\",";
                print OFILE " \"geneSymbol\":\"".$moduleHOH{TCList}{$tc}{Gene}{geneSymbol}."\",";
                print OFILE " \"source\":\"".$moduleHOH{TCList}{$tc}{Gene}{source}."\",";
                if (defined $moduleHOH{TCList}{$tc}{Gene}{description}) {
                    print OFILE " \"description\":\"".$moduleHOH{TCList}{$tc}{Gene}{description}."\",";
                }else{
                    print OFILE " \"description\":\"\",";
                }
                print OFILE " \"extStart\":".$moduleHOH{TCList}{$tc}{Gene}{extStart}.",";
                print OFILE " \"extStop\":".$moduleHOH{TCList}{$tc}{Gene}{extStop}.",";
                print OFILE "\n\t\t\t\t\"TranscriptList\":[\n";
                my $trxSizeRef=$moduleHOH{TCList}{$tc}{Gene}{TranscriptList}{Transcript};
                my @trxList=@$trxSizeRef;
                my $trxcount=0;
                foreach my $trxRef(@trxList){
                    my %trxHOH=%$trxRef;
                    if ($trxcount>0) {
                        print OFILE ",\n";
                    }
                    print OFILE "\t\t\t\t\t{ \"start\":".$trxHOH{start}.",";
                    print OFILE " \"stop\":".$trxHOH{stop}.",";
                    print OFILE " \"ID\":\"".$trxHOH{ID}."\",";
                    print OFILE " \"strand\":\"".$trxHOH{strand}."\",";
                    print OFILE " \"cdsStart\":\"".$trxHOH{cdsStart}."\",";
                    print OFILE " \"cdsStop\":\"".$trxHOH{cdsStop}."\",";
                    print OFILE " \n\t\t\t\t\t\t\"exonList\":[\n";
                    my $exSizeRef=$trxHOH{exonList}{exon};
                    my @exList=@$exSizeRef;
                    my $excount=0;
                    foreach my $exRef(@exList){
                        my %exHOH=%$exRef;
                        if ($excount>0) {
                            print OFILE ",\n";
                        }
                        print OFILE "\t\t\t\t\t\t\t{ ";
                        print OFILE " \"ID\":\"".$exHOH{ID}."\",";
                        print OFILE " \"start\":".$exHOH{start}.",";
                        print OFILE " \"stop\":".$exHOH{stop}.",";
                        print OFILE " \"cdsStart\":\"".$trxHOH{cdsStart}."\",";
                        print OFILE " \"cdsStop\":\"".$trxHOH{cdsStop}."\"";
                        print OFILE "}";#end exon Object
                        $excount++;
                    }
                    print OFILE "\n\t\t\t\t\t\t],\n";
                    print OFILE "\n\t\t\t\t\t\t\"intronList\":[\n";
                    my $intSizeRef=$trxHOH{intronList}{intron};
                    if (defined $intSizeRef) {
                        my @intList=@$intSizeRef;
                        my $intcount=0;
                        foreach my $intRef(@intList){
                            my %intHOH=%$intRef;
                            if ($intcount>0) {
                                print OFILE ",\n";
                            }
                            print OFILE "\t\t\t\t\t\t\t{ ";
                            print OFILE " \"ID\":\"".$intHOH{ID}."\",";
                            print OFILE " \"start\":".$intHOH{start}.",";
                            print OFILE " \"stop\":".$intHOH{stop};
                            print OFILE "}";#end exon Object
                            $intcount++;
                        }
                    }
                    
                    print OFILE "\n\t\t\t\t\t\t]\n";
                    print OFILE "\t\t\t\t\t}";#end Transcript Object
                    $trxcount++;
                }
                print OFILE "\n\t\t\t\t]\n";#end Transcript List
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
    print OFILE "\n\t]\n";#end TCList
    print OFILE "}";#end module
    close OFILE;
}