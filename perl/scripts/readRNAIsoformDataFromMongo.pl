#!/usr/bin/perl
# Subroutine to read information from database



# PERL MODULES WE WILL BE USING
use Bio::SeqIO;
use Data::Dumper qw(Dumper);
use MongoDB;


use Text::CSV;

require 'readAnnotationDataFromDB.pl';
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

sub getRNADatasetFromDB{
    my($organism,$publicUserID,$panel,$tissue,$dsn,$usr,$passwd,$version)=@_;
    my $ret=0;
    if($organism eq "Rat"){
        $organism="Rn";
    }elsif($organism eq "Mouse"){
        $organism="Mm";
    }
    my $connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");
    my $query="select rd2.rna_dataset_id,rd2.build_version from rna_dataset rd2 where
				rd2.organism = '".$organism."' "."
                                and rd2.trx_recon=1
				and rd2.user_id= $publicUserID
                                and rd2.tissue = '".$tissue."' 
                                and rd2.strain_panel like '".$panel."'";
    if($$version==0){
            $query=$query." and rd2.visible=1 and rd2.previous=0";
    }else{
            $query=$query." and rd2.build_version='".$$version."'";
    }

    print $query."\n";
    $query_handle = $connect->prepare($query) or die (" RNA Isoform query prepare failed \n");

    # EXECUTE THE QUERY
    $query_handle->execute() or die ( "RNA Isoform query execute failed \n");
    my $dsid;
    my $ver;
    # BIND TABLE COLUMNS TO VARIABLES
    $query_handle->bind_columns(\$dsid,\$ver);
    if($query_handle->fetch()){
        print "DatasetID=$dsid\nver=$ver\n";
        $ret=$dsid;
        $$version=$ver;
    }
    return $ret;
}
1;

sub readRNAIsoformDataFromDB{


	#INPUT VARIABLES
	# Chromosome for example chr12
	# Start position on the chromosome
	# Stop position on the chromosome

	# Read inputs
	my($geneChrom,$organism,$publicUserID,$panel,$geneStart,$geneStop,$dsn,$usr,$passwd,$shortName, $tmpType,$tissue,$version)=@_;   
	

        my $dsid=getRNADatasetFromDB($organism,$publicUserID,$panel,$tissue,$dsn,$usr,$passwd,\$version);

	#open PSFILE, $psOutputFileName;//Added to output for R but now not needed.  R will read in XML file
	#print "read probesets chr:$geneChrom\n";
	#Initializing Arrays

	my %geneHOH; # giant array of hashes and arrays containing probeset data
	
	
	# DATA SOURCE NAME
	#$dsn = "dbi:$platform:$service_name";
	
	
	# PERL DBI CONNECT
	$connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");
	
	my $type="Any";
	if(defined $tmpType){
		$type=$tmpType;
	}
	
	#my $geneChromNumber = addChr($geneChrom,"subtract");
	
	my $ref=readTranscriptAnnotationDataFromDB($geneChrom,$geneStart,$geneStop,$dsid,$type,$dsn,$usr,$passwd);
	my %annotHOH=%$ref;
	
	

		$query ="Select rd.tissue,rt.gene_id,rt.isoform_id,rt.source,rt.trstart,rt.trstop,rt.strand,rt.category,rt.strain,c.name as \"chromosome\",
			re.enumber,re.estart,re.estop ,rt.rna_transcript_id 
			from rna_dataset rd, rna_transcripts rt, rna_exons re,chromosomes c 
			where 
			c.chromosome_id=rt.chromosome_id 
			and c.name =  '".uc($geneChrom)."' "."
			and re.rna_transcript_id=rt.rna_transcript_id
			and ((trstart>=$geneStart and trstart<=$geneStop) OR (trstop>=$geneStart and trstop<=$geneStop) OR (trstart<=$geneStart and trstop>=$geneStop))
			
			and rt.rna_dataset_id=".$dsid."
			and rt.rna_dataset_id=rd.rna_dataset_id ";
			if($type ne "Any"){
				if(index($type," in (")>-1){
					$query=$query." and rt.category".$type;
				}else{
					$query=$query." and rt.category='".$type."'";
				}
			}
			$query=$query." order by rt.trstart,rt.gene_id,rt.isoform_id,re.estart";
	
	print $query."\n";
	$query_handle = $connect->prepare($query) or die (" RNA Isoform query prepare failed \n");

# EXECUTE THE QUERY
	$query_handle->execute() or die ( "RNA Isoform query execute failed \n");

# BIND TABLE COLUMNS TO VARIABLES

	$query_handle->bind_columns(\$tissue ,\$gene_id,\$isoform_id,\$source,\$trstart,\$trstop,\$trstrand,\$trcategory,\$trstrain,\$chr,\$enumber,\$estart,\$estop,\$trID);
# Loop through results, adding to array of hashes.
	my $continue=1;
	my @tmpArr=();
	my @intronArray = @tmpArr ;
	my @tmpArr2=();
	my @exonArray= @tmpArr2;
	my $cntGene=0;
	my $cntTranscript=0;
	my $cntExon=0;
	my $cntIntron=0;
	my $geneMin=0;
	my $geneMax=0;
	my $previousGeneName="";
	my $previousTranscript=0;
	
	my $trtmp_id="";
	my $trtmp_start=0;
	my $trtmp_stop=0;
	my $trtmp_strand=0;
	my $trtmp_chromosome=0;
	my $trtmp_category="";
        my $trtmp_strain="";
	my $trtmp_trid=0;
	my $genetmp_tissue="";
	my $genetmp_id="";
	my $genetmp_strand="";
	my $genetmp_chr="";
	my $genetmp_start=-1;
	my $genetmp_stop=-1;
	
	while($query_handle->fetch()) {
		if($gene_id eq $previousGeneName){
			#print "\nchecking:$isoform_id\t:$previousTranscript:\n";
			if($isoform_id eq $previousTranscript){
				#print "adding exon $enumber\n";
				$$exonArray[$cntExon]{ID}=$enumber;
				$$exonArray[$cntExon]{start}=$estart;
				#if($estart==$estop){
				#	$$exonArray[$cntExon]{stop}=$estop+1;
				#}else{
					$$exonArray[$cntExon]{stop}=$estop;
				#}
				my $intStart=$$exonArray[$cntExon-1]{stop}+1;
				my $intStop=$$exonArray[$cntExon]{start}-1;
				if($$exonArray[$cntExon]{start}>$$exonArray[$cntExon]{stop}){
					$intStart=$$exonArray[$cntExon-1]{stop}-1;
					$intStop=$$exonArray[$cntExon]{start}+1;
				}
				#print "intron start:$intStart - $intStop\n";
				$$intronArray[$cntIntron]{ID}=$cntIntron+1;
				$$intronArray[$cntIntron]{start}=$intStart;
				$$intronArray[$cntIntron]{stop}=$intStop;
				$cntIntron++;
				$cntExon++;
			}else{
				#print "Adding transcript $trtmp_id::$cntTranscript\n";
				
				$geneHOH{Gene}[$cntGene-1]{TranscriptList}{Transcript}[$cntTranscript] = {
					ID => $trtmp_id,
					start=> $trtmp_start,
					stop => $trtmp_stop,
					source => $trtmp_source,
					strand => $trtmp_strand,
					category => $trtmp_category,
                                        strain => $trtmp_strain,
					chromosome => $trtmp_chromosome,
					exonList => {exon => \@$exonArray},
					intronList => {intron => \@$intronArray}
				};
				my $reftmp=$annotHOH{$trtmp_trid};
				my @tmp=@$reftmp;
				if(@tmp>0){
					$geneHOH{Gene}[$cntGene-1]{TranscriptList}{Transcript}[$cntTranscript]{annotationList}={annotation => \@tmp};
				}
				$cntTranscript++;
				#print "adding transcript $isoform_id\n";
				if($shortName==0){
					$trtmp_id=$tissue." Isoform ".$isoform_id;
				}else{
					$trtmp_id=$isoform_id;
				}
				$trtmp_start=$trstart;
				$trtmp_stop=$trstop;
				$trtmp_source=$source;
				$trtmp_strand=$trstrand;
				$trtmp_chromosome=$chr;
				$trtmp_category=$trcategory;
                                $trtmp_strain=$trstrain;
				$trtmp_trid=$trID;
				
				#set gene min max
				
				if($genetmp_start==-1||$genetmp_start>$trtmp_start){
					$genetmp_start=$trtmp_start;
				}
				if($genetmp_stop==-1||$genetmp_stop<$trtmp_stop){
					$genetmp_stop=$trtmp_stop;
				}
				
				$previousTranscript=$isoform_id;
				
				#reset exons
				my @tmpArray=();
				$exonArray=\@tmpArray;
				$cntExon=0;
				my @tmpArray2=();
				$intronArray=\@tmpArray2;
				$cntIntron=0;
				
				#print "adding exon $enumber\n";
				$$exonArray[$cntExon]{ID}=$enumber;
				$$exonArray[$cntExon]{start}=$estart;
				$$exonArray[$cntExon]{stop}=$estop;
				$cntExon++;
			}
		}else{	
			if($cntGene>0){
				#print "adding transcript".$trtmp_id."\n";
				$geneHOH{Gene}[$cntGene-1]{start}=$genetmp_start;
				$geneHOH{Gene}[$cntGene-1]{stop}=$genetmp_stop;
				$geneHOH{Gene}[$cntGene-1]{TranscriptList}{Transcript}[$cntTranscript] = {
					ID => $trtmp_id,
					start=> $trtmp_start,
					stop => $trtmp_stop,
					source => $trtmp_source,
					strand => $trtmp_strand,
					category => $trtmp_category,
                                        strain => $trtmp_strain,
					chromosome => $trtmp_chromosome,
					exonList => {exon => \@$exonArray},
					intronList => {intron => \@$intronArray}
				};
				my $reftmp=$annotHOH{$trtmp_trid};
				my @tmp=@$reftmp;
				if(@tmp>0){
					$geneHOH{Gene}[$cntGene-1]{TranscriptList}{Transcript}[$cntTranscript]{annotationList}={annotation => \@tmp};
				}
				$cntTranscript++;
			}
			#print "adding gene $gene_id\n";
			my $tmpGeneID=$gene_id;
			if($shortName==1){
				my $shortGID=substr($gene_id,index($gene_id,"_")+1);
				$tmpGeneID=$tissue."_".$shortGID;
			}
			my $bioType="protein_coding";
			if($trcategory ne "PolyA+"){
				$bioType="Long Non-Coding RNA";
			}
			#create next gene
			$geneHOH{Gene}[$cntGene] = {
				start => 0,
				stop => 0,
				ID => $tmpGeneID,
				strand=>$trstrand,
				chromosome=>$chr,
				biotype => $bioType,
				geneSymbol => "",   ####NEED TO FILL THIS IN WITH AKA ANNOTATION
				source => "RNA Seq"
				};
			$cntGene++;
			#print "adding transcript $isoform_id\n";
			#reset variables
			if($shortName==0){
				$trtmp_id=$tissue." Isoform ".$isoform_id;
			}else{
				$trtmp_id=$isoform_id;
			}
			$trtmp_start=$trstart;
			$trtmp_stop=$trstop;
			$trtmp_source=$source;
			$trtmp_strand=$trstrand;
			$trtmp_chromosome=$chr;
			$trtmp_category=$trcategory;
                        $trtmp_strain=$trstrain;
			$trtmp_trid=$trID;

			$genetmp_start=$trtmp_start;
			$genetmp_stop=$trtmp_stop;
			
			$cntTranscript=0;
			
			my @tmpArray2=();
			$exonArray=\@tmpArray2;
			$cntExon=0;
			
			my @tmpArray=();
			$intronArray=\@tmpArray;
			$cntIntron=0;
			
			#print "adding exon $enumber\n";	
			$$exonArray[$cntExon]{ID}=$enumber;
			$$exonArray[$cntExon]{start}=$estart;
			$$exonArray[$cntExon]{stop}=$estop;
			$cntExon++;
			
			$geneMin=0;
			$geneMax=0;
			
			$previousGeneName=$gene_id;
			$previousTranscript=$isoform_id;
		}
	}
	$query_handle->finish();
	$connect->disconnect();
	
	if($cntGene>0){
		$geneHOH{Gene}[$cntGene-1]{start}=$genetmp_start;
		$geneHOH{Gene}[$cntGene-1]{stop}=$genetmp_stop;
		$geneHOH{Gene}[$cntGene-1]{TranscriptList}{Transcript}[$cntTranscript] = {
						ID => $trtmp_id,
						start=> $trtmp_start,
						stop => $trtmp_stop,
						source => $trtmp_source,
						strand => $trtmp_strand,
						category => $trtmp_category,
                                                strain => $trtmp_strain,
						chromosome => $trtmp_chromosome,
						exonList => {exon => \@$exonArray},
						intronList => {intron => \@$intronArray}
		};
		my $reftmp=$annotHOH{$trtmp_trid};
		my @tmp=@$reftmp;
		if(@tmp>0){
			$geneHOH{Gene}[$cntGene-1]{TranscriptList}{Transcript}[$cntTranscript]{annotationList}={annotation => \@tmp};
		}
	}
	#close PSFILE;
	$geneHOH{ver}=$version;
	#print "Gene".scalar(keys %geneHOH)."\n";
	#print "gene name".$geneHOH{Gene}[0]{ID}."\n";
	return (\%geneHOH);
}





sub readRNACountsDataFromMongo{
	my($geneChrom,$organism,$publicUserID,$panel,$type,$geneStart,$geneStop,$dsn,$usr,$passwd)=@_;
	
	my $org="Mm";
	if($organism eq "Rat"){
		$org="Rn";
	}
	
	# PERL DBI CONNECT
	$connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");
	
	$geneChrom=uc($geneChrom);
	
	$query ="Select rd.shared_id from rna_dataset rd
			where 
			rd.organism = '".$org."' "."
			and rd.user_id= $publicUserID  
			and rd.visible=0
			and rd.description = '".$type."'
			and rd.strain_panel like '".$panel."' ";
	
	
	print $query."\n";		
	$query_handle = $connect->prepare($query) or die (" RNA Dataset Shared ID query prepare failed \n");

        # EXECUTE THE QUERY
	$query_handle->execute() or die ( "RNA Dataset Shared ID query execute failed \n");

        # BIND TABLE COLUMNS TO VARIABLES

	$query_handle->bind_columns(\$sharedID);
	my $listCount=0;
	$query_handle->fetch();
	
	my $dsid=$sharedID;
	
	my %countHOH;
	my $client     = MongoDB::Connection->new(host => 'mongodb://phenogen.ucdenver.edu:27017');
	my $database   = $client->get_database( 'shared' );
	my $col = $database->get_collection( 'RNA_COUNTS_'.$dsid );
	
	print "RNA_COUNTS_$dsid\n";
	
	$geneChrom=uc($geneChrom);
	$geneStart=$geneStart*1;
	$geneStop=$geneStop*1;
	
	my $rsCursor=$col->query(
							{'CHROMOSOME'=>"$geneChrom",
							'CHR_START'=>
								{'$gte'=>$geneStart,
								'$lte'=>$geneStop
								}
							},
							{sort_by => {'CHR_START'=>1}}
							);
	
	my $listCount=0;
	#print "COUNT:".$rsCursor->count."\n";
	my @list=$rsCursor->all;
	foreach my $obj(@list){
		if($listCount==0 or ($listCount>0 and $countHOH{Count}[$listCount-1]{stop}==($obj->{'CHR_START'}-1))){
			$countHOH{Count}[$listCount]{start}=$obj->{'CHR_START'};
			$countHOH{Count}[$listCount]{stop}=$obj->{'CHR_END'};
			$countHOH{Count}[$listCount]{count}=$obj->{'COUNT'};
		}else{
			if($listCount>0 and $countHOH{Count}[$listCount-1]{stop}<($obj->{'CHR_START'}-1)){
				$countHOH{Count}[$listCount]{start}=$countHOH{Count}[$listCount-1]{stop};
				$countHOH{Count}[$listCount]{stop}=$obj->{'CHR_START'};
				$countHOH{Count}[$listCount]{count}=0;
				$listCount++;
			}
			$countHOH{Count}[$listCount]{start}=$obj->{'CHR_START'};
			$countHOH{Count}[$listCount]{stop}=$obj->{'CHR_END'};
			$countHOH{Count}[$listCount]{count}=$obj->{'COUNT'};
		}
		$listCount++;
	}
        if($listCount==0){
            $countHOH{Count}[$listCount]{start}=$geneStart;
            $countHOH{Count}[$listCount]{stop}=$geneStop;
            $countHOH{Count}[$listCount]{count}=0;
        }
	return (\%countHOH);
}


sub readRNACountsDataFromDB{
	my($geneChrom,$organism,$publicUserID,$panel,$type,$geneStart,$geneStop,$dsn,$usr,$passwd)=@_;
	my %countHOH;
	
	my $org="Mm";
	if($organism eq "Rat"){
		$org="Rn";
	}
	# PERL DBI CONNECT
	$connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");
	
	$geneChrom=uc($geneChrom);
	
	$query ="Select rc.* from rna_counts rc, rna_dataset rd
			where 
			rd.organism = '".$org."' "."
			and rd.user_id= $publicUserID  
			and rd.visible=0 
			and rd.description = '".$type."'
			and rd.strain_panel like '".$panel."' "."
			and rc.rna_dataset_id= rd.rna_dataset_id
			and rc.chromosome = '".$geneChrom."'
			and (rc.chr_start>=$geneStart and rc.chr_start<=$geneStop)";
			$query=$query." order by rc.chr_start";
	
	
	print $query."\n";		
	$query_handle = $connect->prepare($query) or die (" RNA Isoform query prepare failed \n");

# EXECUTE THE QUERY
	$query_handle->execute() or die ( "RNA Isoform query execute failed \n");

# BIND TABLE COLUMNS TO VARIABLES

	$query_handle->bind_columns(\$dsid ,\$chromosome,\$start,\$end,\$count,\$trCount);
	my $listCount=0;
	while($query_handle->fetch()) {
		if($listCount==0 or ($listCount>0 and $countHOH{Count}[$listCount-1]{stop}==($start-1))){
			$countHOH{Count}[$listCount]{start}=$start;
			$countHOH{Count}[$listCount]{stop}=$end;
			$countHOH{Count}[$listCount]{count}=$count;
			$countHOH{Count}[$listCount]{logcount}=$trCount;
		}else{
			if($listCount>0 and $countHOH{Count}[$listCount-1]{stop}<($start-1)){
				$countHOH{Count}[$listCount]{start}=$countHOH{Count}[$listCount-1]{stop}+1;
				$countHOH{Count}[$listCount]{stop}=$start-1;
				$countHOH{Count}[$listCount]{count}=0;
				$countHOH{Count}[$listCount]{logcount}=0;
				$listCount++;
			}
			$countHOH{Count}[$listCount]{start}=$start;
			$countHOH{Count}[$listCount]{stop}=$end;
			$countHOH{Count}[$listCount]{count}=$count;
			$countHOH{Count}[$listCount]{logcount}=$trCount;
		}
		$listCount++;
	}
	return (\%countHOH);
}

1;

