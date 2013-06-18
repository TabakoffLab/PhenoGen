#!/usr/bin/perl
# script to convert bed file to bigbed file

use strict;

sub convertBedToBigBed{
	# Read inputs
	my($species,$bedOutputFileName, $bigBedOutputFileName,$bedFileFolder,$sortBefore)=@_; 
	# $bedOutputFileName is the name of the input bed file
	# $species is either Rat or Mouse
	# $bigBedOutputFileName is the name of the bigBed output file
	# $sortBefore indicates whether we need to sort the Bed file before converting
	# 1 means sort
	
	# This subroutine calls the executable bedToBigbed in order to convert a bed file to 
	# a big bed file
	# Download bedToBigbed from ucsc at http://hgdownload.cse.ucsc.edu/admin/exe/
	# We require several files for this procedure to work
	#		1. The bedToBigbed executable
	#		2. For Mice, the file mm9.chrom.sizes
	#		3. For Rats, the file rn4.chrom.sizes
	#		4. If we want to sort beforehand, we need the executable bedSort
	my $rn5ChromSizeFile = $bedFileFolder.'rn5.chrom.sizes';
	my $mm9ChromSizeFile = $bedFileFolder.'mm9.chrom.sizes';
	my $bedSortFile = $bedFileFolder.'bedSort';
	my $bedToBigBedFile = $bedFileFolder.'bedToBigBed';
	
	my @args;
	if ($sortBefore == 1){
		@args = ($bedSortFile, $bedOutputFileName, $bigBedOutputFileName);
    	system(@args) == 0
    	or die "system @args\n failed: $?"
	}
	if($species eq 'Mouse'){
		@args = ($bedToBigBedFile,$bedOutputFileName, $mm9ChromSizeFile, $bigBedOutputFileName);
		system(@args) == 0
    	or die "system @args\n failed: $?"
	}
	elsif($species eq 'Rat'){
		@args = ($bedToBigBedFile,$bedOutputFileName, $rn5ChromSizeFile, $bigBedOutputFileName);
		system(@args) == 0
    	or die "system @args\n failed: $?"
	}
	else{
		die "Incorrect value for species: ".$species."\n";
	}
}
1;

# sample call: convertBedToBigBed('Mouse','/Users/clemensl/TestingOutput/ENSMUSG00000029064.bed','/Users/clemensl/TestingOutput/ENSMUSG00000029064.bb',1);

