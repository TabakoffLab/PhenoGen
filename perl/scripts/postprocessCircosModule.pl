#!/usr/bin/perl
use strict;
#
# This routine reads in the svg file produced by circos and modifies the file
#
sub postprocessCircosMod{


	my($module,$cutoff,$organism,$dataDirectory,$svgDirectory,$hostname, $tissue,$modColor)=@_;
	# Open the file that has tooltip information for links
        
       

	my $numberOfTissues = 1;
	my $toolTipFileName = $dataDirectory."LinkToolTips.txt";
	my %toolTipHash;
	my @tipArray;
	my $toolTipHashKey;
	my $toolTipHashValue;
	my $mbString;
	open my $TOOLTIPSFILEHANDLE,'<',$toolTipFileName || die ("Can't open $toolTipFileName:$!");
	while(<$TOOLTIPSFILEHANDLE>){
		@tipArray = split("\t", $_);
		$toolTipHashKey = $tipArray[0];
		chomp $toolTipHashKey;
		$toolTipHashValue = "Chr ".$tipArray[1].':';
		$mbString = sprintf "%.1f", $tipArray[2]/1000000;
		$toolTipHashValue = $toolTipHashValue .$mbString." mb";
		chomp $toolTipHashValue;
		$toolTipHash{$toolTipHashKey}=$toolTipHashValue;
	}
	close($TOOLTIPSFILEHANDLE);

	my $modifiedLine;
	my $modifiedTissue;
	# Open the current and new circos svg file
	my $fileName = $svgDirectory."circos.svg";
	my $newFileName = $svgDirectory."circos_new.svg";
	
	open my $SVGFILEHANDLE,'<',$fileName || die ("Can't open $fileName:$!");
	open my $NEWSVGFILEHANDLE,'>',$newFileName || die ("Can't open $newFileName:$!");
	
	my $countFileLines = 0;
	my $nextLineIsLinkPath = 0;
	while(<$SVGFILEHANDLE>){
		$countFileLines++;
		chomp $_;
		#Read in the first 3 lines, but write out a new version of the top of the file
		# The new version contains css and scripts
		if($countFileLines < 3){
			next;
		}
		elsif($countFileLines == 3){
			writeTopLines($NEWSVGFILEHANDLE,$hostname);
		}
		else{
			if($nextLineIsLinkPath == 1){
                            my $startEnd=index($_,"L")+1;
                            my $start=substr($_,0,$startEnd);
                            my $endStart=index($_,"1500.0,1500.0");
                            my $end=substr($_,$endStart);
                            my $modifiedLine = $start." ".$end."\n";
                            print $NEWSVGFILEHANDLE $modifiedLine;#."\n";
			#	# Modify the Link Path line
			#	# Get rid of, at the end, for example:  style="stroke-opacity: 1.000000; stroke-width: 5.0; stroke: rgb(116,196,118); fill: none" 
			#	if($_ =~ m/style=\"stroke-opacity: 1.000000; stroke-width: 5.0; stroke: (.+)\/>$/){
			#		$modifiedLine = $_;
			#		$modifiedLine =~ s/style="stroke-opacity: 1.000000; stroke-width: 5.0; stroke: (.+)\/>$/\/>/;
			#		#print " Modified Path: ".$modifiedLine."\n";
			#		print $NEWSVGFILEHANDLE $modifiedLine;#."\n";
			#	}
				$nextLineIsLinkPath = 0;
			}
			elsif($_ =~ m/Link/){
                                $nextLineIsLinkPath = 1;	
                                print $NEWSVGFILEHANDLE $_;#."\n";
			}
			elsif($_ =~ m/^<\/svg>$/){
                        #if($_ =~ m/^<\/svg>$/){
				#Look for the bottom of the file: </svg>
				#Add two lines before the last line
				#print " Found Last Line \n";
				#print $_."\n";
				# lines for tool tips
				
				print $NEWSVGFILEHANDLE '</g>';#."\n";
				print $NEWSVGFILEHANDLE '  <circle cx="1500" cy="1500" r="100" fill="rgb('.$modColor.')" stroke="#000000" />';#."\n";
				print $NEWSVGFILEHANDLE '<rect class="tooltip_bg" id="tooltip_bg" x="0" y="0" rx="4" ry="4" width="60" height="60" visibility="hidden"/>';#."\n";
				print $NEWSVGFILEHANDLE '<text class="tooltip" id="tooltip" x="0" y="0" visibility="hidden">Tooltip</text>';#."\n";
				print $NEWSVGFILEHANDLE '</g>';#."\n";
				
				# New lines for controls

				print $NEWSVGFILEHANDLE '				<g>';#."\n";
				print $NEWSVGFILEHANDLE '<rect class="help" id="help" x="250" y="250" width="500" height="500" visibility="hidden"/>';#."\n";
				print $NEWSVGFILEHANDLE '<line id="closeHelpLine1" class="closeHelpLine" x1="725" y1="260" x2="740" y2="275" onclick="HideHelp(evt)" visibility="hidden" />';#."\n";
				print $NEWSVGFILEHANDLE '<line id="closeHelpLine2"  class="closeHelpLine" x1="725" y1="275" x2="740" y2="260" onclick="HideHelp(evt)" visibility="hidden"/>';#."\n";
				print $NEWSVGFILEHANDLE '<text class="helpText" id="helpText" visibility="hidden" x="275" y="290"></text>';#."\n";
                print $NEWSVGFILEHANDLE '<text x="480" y="40" font-size="18px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(0,0,0)" >Module</text>'."\n";
                                print $NEWSVGFILEHANDLE '<text x="480" y="60" font-size="18px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(0,0,0)" >Genes</text>'."\n";
                                print $NEWSVGFILEHANDLE '<text x="480" y="150" font-size="18px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(0,0,0)" >'.$tissue.'</text>'."\n";

                                print $NEWSVGFILEHANDLE '<text x="480" y="95" font-size="18px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(0,0,0)" >Megabases</text>'."\n";
				print $NEWSVGFILEHANDLE '<text x="1100" y="900" font-size="20px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(0,0,0)" >Yellow plot means</text>'."\n";
				print $NEWSVGFILEHANDLE '<text x="1100" y="920" font-size="20px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(0,0,0)" >-log(p-value) >= '.$cutoff.'</text>'."\n";

				print $NEWSVGFILEHANDLE '</g>';#."\n";
				print $NEWSVGFILEHANDLE $_;#."\n";

			}
			elsif($_ =~ m/^ENS|^Brain/){
				#print " Found Probe ID Text Line \n";
				#print $_."\n";	
				#Look for the probe id text, for example: <text x="574.2" y="2446.5" font-size="32.5px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(0,0,0)" transform="rotate(-45.1,574.2,2446.5)">7102228</text>
				#Add lines for Tissue Labels and what yellow means
				print $NEWSVGFILEHANDLE $_;#."\n";
				my %colorHash;
				$colorHash{'Brain'} = 'rgb(107,154,200)';
				$colorHash{'Heart'} = 'rgb(251,106,74)';
				$colorHash{'Liver'} = 'rgb(116,196,118)';
				$colorHash{'BAT'} = 'rgb(158,154,200)';
				my @yArray;
				$yArray[0] = '450.0';
				$yArray[1] = '575.0';
				$yArray[2] = '700.0';
				$yArray[3] = '825.0';		
				
				#for(my $i = 0; $i < $numberOfTissues ; $i ++){
					print $NEWSVGFILEHANDLE '<text x="1475.0" y="',$yArray[0],'" font-size="64px" font-family="CMUBright-Roman" style="text-anchor:end;fill:',$colorHash{$tissue},'" >',$tissue,'</text>';#."\n";
				#}
				#print $NEWSVGFILEHANDLE '<text x="1475.0" y="450.0" font-size="64px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(107,154,200)" >Brain</text>'."\n";
				#if($organism eq "Rn"){
					#print $NEWSVGFILEHANDLE '<text x="1475.0" y="575.0" font-size="64px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(251,106,74)" >Heart</text>'."\n";
					#print $NEWSVGFILEHANDLE '<text x="1475.0" y="700.0" font-size="64px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(116,196,118)" >Liver</text>'."\n";
					#print $NEWSVGFILEHANDLE '<text x="1475.0" y="825.0" font-size="64px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(158,154,200)" >BAT</text>'."\n";
				#}
				print $NEWSVGFILEHANDLE '<text x="1475.0" y="255.0" font-size="40px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(0,0,0)" >Megabases</text>';#."\n";
				print $NEWSVGFILEHANDLE '<text x="2680.0" y="2650.0" font-size="32px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(0,0,0)" >Yellow means</text>';#."\n";
				print $NEWSVGFILEHANDLE '<text x="2750.0" y="2680.0" font-size="32px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(0,0,0)" >negative log p-value > '.$cutoff.'</text>';#."\n";
			}
			else{
				print $NEWSVGFILEHANDLE $_;#."\n";
			}
		}
	} # While loop reading through current svg file
	close($NEWSVGFILEHANDLE);
	close($SVGFILEHANDLE);
}
1;

sub writeTopLines{
	my ($FILEHANDLE,$hostname) = @_;
	print $FILEHANDLE '<?xml version="1.0" standalone="no"?>';#."\n";
	print $FILEHANDLE '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">';#."\n";
	print $FILEHANDLE '<svg id="circosModule" width="3000px" height="3000px" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" cursor="move">';#."\n";
	
 	print $FILEHANDLE '<style type="text/css"> ';#."\n";
	print $FILEHANDLE '.Heart';#."\n";
	print $FILEHANDLE '{';#."\n";
	print $FILEHANDLE '	stroke-opacity: 1.000000; ';#."\n";
	print $FILEHANDLE '	stroke-width: 5.0; ';#."\n";
	print $FILEHANDLE '	stroke: rgb(251,106,74); ';#."\n";
	print $FILEHANDLE '	fill: none';#."\n";
	print $FILEHANDLE '}';#."\n";
	print $FILEHANDLE '.Liver';#."\n";
	print $FILEHANDLE '{';#."\n";
	print $FILEHANDLE '	stroke-opacity: 1.000000; ';#."\n";
	print $FILEHANDLE '	stroke-width: 5.0; ';#."\n";
	print $FILEHANDLE '	stroke: rgb(116,196,118); ';#."\n";
	print $FILEHANDLE '	fill: none';#."\n";
	print $FILEHANDLE '}';#."\n";
	print $FILEHANDLE '.Brain';#."\n";
	print $FILEHANDLE '{';#."\n";
	print $FILEHANDLE '	stroke-opacity: 1.000000; ';#."\n";
	print $FILEHANDLE '	stroke-width: 5.0; ';#."\n";
	print $FILEHANDLE '	stroke: rgb(107,174,214); ';#."\n";
	print $FILEHANDLE '	fill: none';#."\n";
	print $FILEHANDLE '}	';#."\n";
	print $FILEHANDLE '.BAT';#."\n";
	print $FILEHANDLE '	{';#."\n";
	print $FILEHANDLE '	stroke-opacity: 1.000000; ';#."\n";
	print $FILEHANDLE '	stroke-width: 5.0; ';#."\n";
	print $FILEHANDLE '	stroke: rgb(158,154,200);';#."\n"; 
	print $FILEHANDLE '	fill: none';#."\n";
	print $FILEHANDLE '}	';#."\n";
	print $FILEHANDLE '.tooltip{';#."\n";
    print $FILEHANDLE '	font-size: 28px;';#."\n";
  	print $FILEHANDLE '}';#."\n";
    print $FILEHANDLE '.caption{';#."\n";
	print $FILEHANDLE '	font-size: 14px;';#."\n";
	print $FILEHANDLE '	font-family: Georgia, serif;';#."\n";
    print $FILEHANDLE '}';#."\n";
    print $FILEHANDLE '.tooltip_bg{';#."\n";
    print $FILEHANDLE '	fill: white;';#."\n";
    print $FILEHANDLE '	stroke: black;';#."\n";
    print $FILEHANDLE '	stroke-width: 5;';#."\n";
    print $FILEHANDLE '	opacity: 0.85;';#."\n";
    print $FILEHANDLE '}';#."\n";
    print $FILEHANDLE '.Heart:hover{';#."\n";
    print $FILEHANDLE '	opacity: 0.5;';#."\n";
    print $FILEHANDLE '}';#."\n";
    print $FILEHANDLE '.Brain:hover{';#."\n";
    print $FILEHANDLE '	opacity: 0.5;';#."\n";
    print $FILEHANDLE '}';#."\n";
    print $FILEHANDLE '.Liver:hover{';#."\n";
    print $FILEHANDLE '	opacity: 0.5;';#."\n";
    print $FILEHANDLE '}';#."\n";
    print $FILEHANDLE '.BAT:hover{';#."\n";
    print $FILEHANDLE '	opacity: 0.5;';#."\n";
    print $FILEHANDLE '}';#."\n";    
    print $FILEHANDLE '    .compass{';#."\n";
    print $FILEHANDLE '  			fill:			#fff;';#."\n";
    print $FILEHANDLE '  			stroke:			#000;';#."\n";
    print $FILEHANDLE '  			stroke-width:	1.5;';#."\n";
    print $FILEHANDLE '	}';#."\n";
    print $FILEHANDLE '	.button{';#."\n";
    print $FILEHANDLE '		    fill:           	#000;';#."\n";
    print $FILEHANDLE '			stroke:   			#000;';#."\n";
    print $FILEHANDLE '			stroke-miterlimit:	6;';#."\n";
    print $FILEHANDLE '			stroke-linecap:		round;';#."\n";
    print $FILEHANDLE '	}';#."\n";
    print $FILEHANDLE '	.button:hover{';#."\n";
    print $FILEHANDLE '			stroke-width:   	2;';#."\n";
    print $FILEHANDLE '	}';#."\n";
    print $FILEHANDLE '	.plus-minus{';#."\n";
    print $FILEHANDLE '			fill:	#fff;';#."\n";
    print $FILEHANDLE '			pointer-events: none;';#."\n";
    print $FILEHANDLE '	}';#."\n";
    print $FILEHANDLE '    .questionMark{';#."\n";
    print $FILEHANDLE '			fill:	#fff;';#."\n";
    print $FILEHANDLE '			pointer-events: none;';#."\n";
    print $FILEHANDLE '			font-size: 24px;';#."\n";
    print $FILEHANDLE '			font-family: Georgia, serif;';#."\n";
    print $FILEHANDLE '}';#."\n";
    print $FILEHANDLE '	.controls{';#."\n";
    print $FILEHANDLE '		   stroke: #000;';#."\n";
    print $FILEHANDLE '		   fill: #fff;';#."\n";
    print $FILEHANDLE '	}';#."\n";
    print $FILEHANDLE '	.controlText{';#."\n";
    print $FILEHANDLE '		font-size: 18px;';#."\n";
    print $FILEHANDLE '		font-family: Georgia, serif;';#."\n";
    print $FILEHANDLE '	}';#."\n";  
    print $FILEHANDLE '    .help{';#."\n";
    print $FILEHANDLE '		   stroke: #000;';#."\n";
    print $FILEHANDLE '		   fill: #fff;';#."\n";
    print $FILEHANDLE '}';#."\n";
    print $FILEHANDLE '.helpText{';#."\n";
    print $FILEHANDLE '	font-size: 18px;';#."\n";
    print $FILEHANDLE '	font-family: Georgia, serif;';#."\n";
    print $FILEHANDLE '}';#."\n";
    print $FILEHANDLE '.closeHelp{';#."\n";
    print $FILEHANDLE '		   stroke: #000;';#."\n";
    print $FILEHANDLE '		   fill: #fff;';#."\n";
    print $FILEHANDLE '}';#."\n";
    print $FILEHANDLE '.closeHelpLine{';#."\n";
    print $FILEHANDLE '		   stroke: #000;';#."\n";
    print $FILEHANDLE '		   fill: #fff;';#."\n";
    print $FILEHANDLE '		   stroke-width: 4;';#."\n";
    print $FILEHANDLE '}';#."\n";
    print $FILEHANDLE '.closeHelpLine:hover{';#."\n";
    print $FILEHANDLE '	opacity: 0.5;';#."\n";
    print $FILEHANDLE '}';#."\n";   
    print $FILEHANDLE '</style>';#."\n";
    print $FILEHANDLE ' ';#."\n";
    print $FILEHANDLE ' <g id="viewport" transform = "scale(.330)">';#."\n";
    print $FILEHANDLE ' <g id="notooltips">';#."\n";
}
1;
