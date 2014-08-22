#!/usr/bin/perl

use XML::LibXML;
use XML::Simple;

use strict;
require 'createXMLTrack.pl';


sub bed2XML
{
	#Reads a bed formatted file and outputs an xml file for the GenomeDataBrowser
	#Can read extended bed files will output extended fields to xml to be handled by javascript
	#

	# Read in the arguments for the subroutine	
	my($inputFile,$outputFile,$regionStart,$regionStop,$regionChr)=@_;
	
	my %featureHOH;
	
	open IN,"<",$inputFile;
	my $count=0;
	while(<IN>){
	    my $line=$_;
	    #print $line;
	    my @col=split(/\s+/,$line);
	    my $colSize=3;
	    my $chr=$col[0];
	    my $start=$col[1];
	    my $end=$col[2];
	    if(($regionStart==-1 and $regionStop==-1) or
	       ($chr eq $regionChr and (
					($regionStart<=$start and $start<=$regionStop ) or
					($regionStart<=$end and $end<=$regionStop ) or
					($start<=$regionStart and $regionStart<=$end)
					)
		)
	       ){#don't filter if regionStart or regionStop are not set otherwise check chr,start,stop
		
		my $id=$chr."_".$start."_".$end;
		if(index($chr,"chr")>-1){
		    $chr=substr($chr,3);
		}
		
		$featureHOH{Feature}[$count]={
						chromosome=>$chr,
						start=>$start,
						stop=>$end,
						ID=>$id
					      };
		
		my $name="";
		my $score=0;
		my $strand=".";
		my $thickStart=0;
		my $thickEnd=0;
		my $color="0,0,0";
		my $blockCount=0;
		my $blockSizes="";
		my $blockStarts="";
		
		if(@col>3){
		    $name=$col[3];
		    $featureHOH{Feature}[$count]{name}=$name;
		    $colSize=4;
		}
		if(@col>4){
		    $score=$col[4];
		    $featureHOH{Feature}[$count]{score}=$score;
		    $colSize=5;
		}
		if(@col>5){
		    $strand=$col[5];
		    if($strand eq "+"){
			$strand="1";
		    }elsif($strand eq "-"){
			$strand="-1";
		    }elsif($strand eq "."){
			$strand="0";
		    }
		    $featureHOH{Feature}[$count]{strand}=$strand;
		    $colSize=6;
		}
		if(@col>6){
		    $thickStart=$col[6];
		    if($thickStart<$start or $thickStart>$end){
			$thickStart=$start;
		    }
		    $featureHOH{Feature}[$count]{thickStart}=$thickStart;
		    $colSize=7;
		}
		if(@col>7){
		    $thickEnd=$col[7];
		    if($thickEnd<$start or $thickEnd>$end){
			$thickEnd=$end;
		    }
		    $featureHOH{Feature}[$count]{thickEnd}=$thickEnd;
		    $colSize=8;
		}
		if(@col>8){
		    $color=$col[8];
		    $featureHOH{Feature}[$count]{color}=$color;
		    $colSize=9;
		}
		if(@col>10){
		    $blockCount=$col[9];
		    $blockSizes=$col[10];
		    $blockStarts=$col[11];
		    $colSize=12;
		    my @sizes=split(/,/,$blockSizes);
		    my @starts=split(/,/,$blockStarts);
		    for(my $i=0;$i<@sizes;$i++){
			$featureHOH{Feature}[$count]{blockList}{block}[$i]{start}=$start+$starts[$i];
			$featureHOH{Feature}[$count]{blockList}{block}[$i]{stop}=$start+$starts[$i]+$sizes[$i];
		    }
		}else{
		    $featureHOH{Feature}[$count]{blockList}{block}[0]{start}=$start;
		    $featureHOH{Feature}[$count]{blockList}{block}[0]{stop}=$end;
		}
		$count++;
	    }
	}
	close IN;
	
	##output XML file
	my $xmlOutputFileName=">$outputFile";
	createGenericXMLTrack(\%featureHOH,$xmlOutputFileName);
}
#
#	
	my $arg1 = $ARGV[0]; # input file
	my $arg2 = $ARGV[1]; # output file
	my $arg3 = -1;
	my $arg4 = -1;
	my $arg5 = "chr*";
	if(@ARGV>4){
	    $arg3=$ARGV[2];
	    $arg4=$ARGV[3];
	    $arg5=$ARGV[4];
	}
	bed2XML($arg1, $arg2,$arg3,$arg4,$arg5);

1;