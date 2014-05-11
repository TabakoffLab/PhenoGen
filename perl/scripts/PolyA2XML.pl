#!/usr/bin/perl


use XML::LibXML;
use XML::Simple;

use strict;
require 'createXMLTrack.pl';

sub readPredictedPolyADataFromDB{


	#INPUT VARIABLES
	# Chromosome for example chr12
	# Start position on the chromosome
	# Stop position on the chromosome

	# Read inputs
	my($geneChrom,$organism,$geneStart,$geneStop,$dsn,$usr,$passwd)=@_;   


	my %polyaHOH; # giant array of hashes and arrays containing probeset data
	
	if($organism eq 'Mouse'){
		$organism="Mm";
	}elsif($organism eq 'Rat'){
		$organism="Rn";
	}
	
	# PERL DBI CONNECT
	my $connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");
	
	# PREPARE THE QUERY for probesets
	my $query ="Select p.pp_id,p.site_start,p.site_stop,p.motif,p.strand,p.pvalue,p.chromosome
			from predicted_polya p
			where p.chromosome =  '".uc($geneChrom)."' "."
			and p.organism = '".$organism."' "."
			and ((p.site_start>=$geneStart and p.site_start<=$geneStop) OR (p.site_stop>=$geneStart and p.site_stop<=$geneStop) OR (p.site_start<=$geneStart and p.site_stop>=$geneStop))
			order by p.site_start";
	print $query."\n";
	my $query_handle = $connect->prepare($query) or die (" predicted polya query prepare failed \n");

# EXECUTE THE QUERY
	$query_handle->execute() or die ( "RNA Isoform query execute failed \n");
	
	my $id;
	my $start;
	my $stop;
	my $name;
	my $strand;
	my $pval;
	my $chr;

# BIND TABLE COLUMNS TO VARIABLES
	$query_handle->bind_columns(\$id,\$start,\$stop,\$name,\$strand,\$pval,\$chr);
# Loop through results, adding to array of hashes.
	my $cntPoly=0;
	while($query_handle->fetch()) {
		#print "SETUP\t$id\t$strain\t$start\t$ref_seq\n";
		my $color="0,0,0";
		if($strand==1){
			$color="255,128,0";
		}elsif($strand==-1){
			$color="51,5,112";
		}

		$polyaHOH{Feature}[$cntPoly] = {
					ID => $id,
					motif => $name,
					start=> $start,
					stop => $stop,
					strand => $strand,
					pvalue => $pval,
					chromosome => $chr,
					color => $color
		};
		$polyaHOH{Feature}[$cntPoly]{blockList}{block}[0]{start}=$start;
		$polyaHOH{Feature}[$cntPoly]{blockList}{block}[0]{stop}=$stop;
		$cntPoly++;
	}
	print "PolyA Count:".$cntPoly."\n";
	$query_handle->finish();
	$connect->disconnect();
	return (\%polyaHOH);
}

sub PolyA2XML
{
	#Reads a bed formatted file and outputs an xml file for the GenomeDataBrowser
	#Can read extended bed files will output extended fields to xml to be handled by javascript
	#

	# Read in the arguments for the subroutine	
	my($outputFile,$regionStart,$regionStop,$regionChr,$organism,$dsn,$usr,$passwd)=@_;
	
	my %featureHOH;

	my $refFeature=readPredictedPolyADataFromDB($regionChr,$organism,$regionStart,$regionStop,$dsn,$usr,$passwd);
	%featureHOH=%$refFeature;
	
	##output XML file
	my $xmlOutputFileName=">$outputFile";
	createGenericXMLTrack(\%featureHOH,$xmlOutputFileName);
}
1;