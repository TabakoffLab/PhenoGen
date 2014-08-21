#!/usr/bin/perl

use XML::LibXML;
use XML::Simple;

use strict;
require 'createXMLTrack.pl';


sub bedGraph2XML
{
	#Reads a bed formatted file and outputs an xml file for the GenomeDataBrowser
	#Can read extended bed files will output extended fields to xml to be handled by javascript
	#

	# Read in the arguments for the subroutine	
	my($inputFile,$outputFile,$regionStart,$regionStop,$regionChr)=@_;
	
	my %countHOH;
	
	open IN,"<",$inputFile;
	my $counter=0;
	while(<IN>){
	    my $line=$_;
	    #print $line;
	    my @col=split(/\s+/,$line);
	    my $chr=$col[0];
	    my $start=$col[1];
	    my $end=$col[2];
	    my $count=$col[3];
	    if(($regionStart==-1 and $regionStop==-1) or
	       ($chr eq $regionChr and (
					($regionStart<=$start and $start<=$regionStop ) or
					($regionStart<=$end and $end<=$regionStop ) or
					($start<=$regionStart and $regionStart<=$end)
					)
		)
	       ){#don't filter if regionStart or regionStop are not set otherwise check chr,start,stop
		
		if($counter==0 or ($counter>0 and $countHOH{Count}[$counter-1]{stop}==($start-1))){
			$countHOH{Count}[$counter]{start}=$start;
			$countHOH{Count}[$counter]{stop}=$end;
			$countHOH{Count}[$counter]{count}=$count;
		}else{
			if($counter>0 and $countHOH{Count}[$counter-1]{stop}<($start-1)){
				$countHOH{Count}[$counter]{start}=$countHOH{Count}[$counter-1]{stop}+1;
				$countHOH{Count}[$counter]{stop}=$start-1;
				$countHOH{Count}[$counter]{count}=0;
				$counter++;
			}
			$countHOH{Count}[$counter]{start}=$start;
			$countHOH{Count}[$counter]{stop}=$end;
			$countHOH{Count}[$counter]{count}=$count;
		}
		$counter++;
	    }
	}
	close IN;
	
	##output XML file
	my $xmlOutputFileName=">$outputFile";
	createGenericXMLTrack(\%countHOH,$xmlOutputFileName);
	
}
1;
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
	bedGraph2XML($arg1, $arg2,$arg3,$arg4,$arg5);

1;