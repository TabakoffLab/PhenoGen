#!/usr/bin/perl
use File::Basename qw(fileparse);
use WWW::Mechanize;
use strict;
my $m = WWW::Mechanize->new();


sub createPng{


	#INPUT VARIABLES
	# species for example Mouse or Rat
	# Chromosome for example chr12
	# Start position on the chromosome
	# Stop position on the chromosome
	# Name for png file, including path
	# Name for two track file, including path
	# timeout in seconds initially can be short and increase on retries if needed

	# Read inputs

	my($species, $geneName, $geneChrom,$geneStart,$geneStop,$pngFileName,$twoTrackFileName,$timeOut)=@_;
		$m = WWW::Mechanize->new(
					 timeout => $timeOut
					 );
	#
	# Set up some conversions
	#
	my $quoteString = '%22';
	my $spaceString = '%20';
	my $atString = '@'; # documentation said to replace @ with %40 but that does not seem necessary.
	my $FFString = '%0C';
	my $CRString = '%0D';
	my $LFString = '%0A';

	my $urlNewLine = $FFString.$CRString;

	my $debugging = 1;


	#
	# Set up the URL 
	#
	my $urlbeginning = 'http://genome.ucsc.edu/cgi-bin/hgTracks';
	my $urldb;
	if($species eq 'Rat') {
		$urldb = '?db=rn5';
	}
	else{
		$urldb = '?db=mm9';
	}
	my $urlchrom = '&position='.$geneChrom.':';
	my $urlstart = $geneStart.'-';
	my $urlstop = $geneStop;
	my $urlcustomtext = '&hgt.customText=';

	my $urlname = $spaceString.'name=Probesets';
	my $urldescription = $spaceString.'description='.$quoteString.'Exons'.$spaceString.'and'.$spaceString.'Probesets'.$spaceString.'For'
	                    .$spaceString.'Gene'.$spaceString.$geneName.$quoteString.$spaceString;

	my $urlbigdata;

	my ($twoTrackFilenameOnly,$twoTrackPath) = fileparse($twoTrackFileName);
	if($debugging >= 1){
		print " two Track file name only \n";
		print $twoTrackFilenameOnly;
		print "\n";
	}
	$urlbigdata = 'http://ucsc:JU7etr5t'.$atString.'phenogen.ucdenver.edu/ucsc/'.$twoTrackFilenameOnly;
	my $url = $urlbeginning.$urldb.$urlchrom.$urlstart.$urlstop.$urlcustomtext;
	$url = $url.$urlbigdata;


	if($debugging >= 1){
		print " Here is the URL for the UCSC ".$species." Genome with probesets for Affy Exons\n\n";
		print " This is for gene $geneName \n\n";
		print " $url \n\n\n\n";
	}
	$m->get($url);
	my $pageContent =  $m->content();
	#
	# find the hgsid
	# This is not recommended for a long time - but maybe okay in the short term??
	#
	#
	# First get the form
	#
	my $formID = 'TrackHeaderForm';
	$m->form_id($formID);
	#
	# Now get the value for hgsid
	#
	my $hgsidString = 'hgsid';
	my $currentHgsid = $m->value($hgsidString);
	if($debugging >= 1){
		print " Current HGSID: $currentHgsid \n\n";
	}
	my $pngUrl = 'http://www.genome.ucsc.edu/cgi-bin/hgRenderTracks?hgt.internal=1&hgsid='.$currentHgsid;
	if($debugging >= 1){
		print " Here is the URL to get the png file\n\n";
		print " For gene $geneName \n\n";
		print "$pngUrl \n\n";
	}
	$m->get($pngUrl,":content_file" => $pngFileName);
	
	return $m->status();
}

sub createPngRNA{


	#INPUT VARIABLES
	# species for example Mouse or Rat
	# Chromosome for example chr12
	# Start position on the chromosome
	# Stop position on the chromosome
	# Name for png file, including path
	# Name for two track file, including path
	# timeout in seconds initially can be short and increase on retries if needed

	# Read inputs

	my($species, $geneName, $geneChrom,$geneStart,$geneStop,$pngFileName,$twoTrackFileName,$timeOut,$imageWidth,$labelWidth,$textSize)=@_;
		$m = WWW::Mechanize->new(
					 timeout => $timeOut
					 );
	#
	# Set up some conversions
	#
	my $quoteString = '%22';
	my $spaceString = '%20';
	my $atString = '@'; # documentation said to replace @ with %40 but that does not seem necessary.
	my $FFString = '%0C';
	my $CRString = '%0D';
	my $LFString = '%0A';

	my $urlNewLine = $FFString.$CRString;

	my $debugging = 1;


	#
	# Set up the URL 
	#
	my $urlbeginning = 'http://genome.ucsc.edu/cgi-bin/hgTracks';
	my $urldb;
	if($species eq 'Rat') {
		$urldb = '?db=rn5';
	}
	else{
		$urldb = '?db=mm9';
	}
	my $urlchrom = '&position='.$geneChrom.':';
	my $urlstart = $geneStart.'-';
	my $urlstop = $geneStop;
	my $urlcustomtext = '&hgt.customText=';

	my $urlname = $spaceString.'name=Probesets';
	my $urldescription = $spaceString.'description='.$quoteString.'Exons'.$spaceString.'and'.$spaceString.'Probesets'.$spaceString.'For'
	                    .$spaceString.'Gene'.$spaceString.$geneName.$quoteString.$spaceString;

	my $urlbigdata;

	my ($twoTrackFilenameOnly,$twoTrackPath) = fileparse($twoTrackFileName);
	
	my $last=rindex($twoTrackFileName,"/");
	my $next=rindex($twoTrackFileName,"/",$last-2);
	my $twoTrackFilePlusDir=substr($twoTrackFileName,$next+1);
	if($debugging >= 1){
		print " two Track file name only \n";
		print $twoTrackFilenameOnly;
		print "\n";
	}
	$urlbigdata = 'http://ucsc:JU7etr5t'.$atString.'phenogen.ucdenver.edu/ucsc/'.$twoTrackFilePlusDir;
	my $url = $urlbeginning.$urldb.$urlchrom.$urlstart.$urlstop.$urlcustomtext;
	$url = $url.$urlbigdata;


	if($debugging >= 1){
		print " Here is the URL for the UCSC ".$species." Genome with probesets for Affy Exons\n\n";
		print " This is for gene $geneName \n\n";
		print " $url \n\n\n\n";
	}
	$m->get($url);
	my $pageContent =  $m->content();
	#
	# find the hgsid
	# This is not recommended for a long time - but maybe okay in the short term??
	#
	#
	# First get the form
	#
	my $formID = 'TrackHeaderForm';
	$m->form_id($formID);
	#
	# Now get the value for hgsid
	#
	my $hgsidString = 'hgsid';
	my $currentHgsid = $m->value($hgsidString);
	if($debugging >= 1){
		print " Current HGSID: $currentHgsid \n\n";
	}
	my $pngUrl = 'http://www.genome.ucsc.edu/cgi-bin/hgRenderTracks?pix='.$imageWidth.'&hgt.labelWidth='.$labelWidth.'&textSize='.$textSize.'&hgt.internal=1&hgsid='.$currentHgsid;
	if($debugging >= 1){
		print " Here is the URL to get the png file\n\n";
		print " For gene $geneName \n\n";
		print "$pngUrl \n\n";
	}
	$m->get($pngUrl,":content_file" => $pngFileName);
	
	my $retString=$m->status()."<>".$url;
	
	return $retString;
}

return 1;





