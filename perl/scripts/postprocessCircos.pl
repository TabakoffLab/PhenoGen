#!/usr/bin/perl
use strict;
#
# This routine reads in the svg file produced by circos and modifies the file
#
sub postprocessCircos{


	my($geneName,$geneSymbol,$probeID,$psLevel,$probeChromosome,$probeStart,$probeStop,$cutoff,$organism,$dataDirectory,$svgDirectory)=@_;
	# Open the file that has tooltip information for links
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
	# Open the current and new circos svg file
	my $fileName = $svgDirectory."circos.svg";
	my $newFileName = $svgDirectory."circos_new.svg";
	
	open my $SVGFILEHANDLE,'<',$fileName || die ("Can't open $fileName:$!");
	open my $NEWSVGFILEHANDLE,'>',$newFileName || die ("Can't open $newFileName:$!");
	my $probeIDMatchString = $geneSymbol.'</text>$';
	#my $probeIDMatchString = $probeID.'</text>$';
	print "probe ID Match String ".$probeIDMatchString."\n";
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
			writeTopLines($NEWSVGFILEHANDLE);
		}
		else{
			if($nextLineIsLinkPath == 1){
				# Modify the Link Path line
				# Get rid of, at the end, for example:  style="stroke-opacity: 1.000000; stroke-width: 5.0; stroke: rgb(116,196,118); fill: none" 
				if($_ =~ m/style=\"stroke-opacity: 1.000000; stroke-width: 5.0; stroke: (.+)\/>$/){
					$modifiedLine = $_;
					$modifiedLine =~ s/style="stroke-opacity: 1.000000; stroke-width: 5.0; stroke: (.+)\/>$/\/>/;
					#print " Modified Path: ".$modifiedLine."\n";
					print $NEWSVGFILEHANDLE $modifiedLine."\n";
				}
				$nextLineIsLinkPath = 0;
			}
			elsif($_ =~ m/^<g id=\"Link_(.+)_(.+)\">/){	
				#Look for links, for example: <g id="Link_Brain_00001" 
				#Replace the links lines with modifications that give tool tips
				$toolTipHashKey = "Link_".$1."_".$2;
				if (exists $toolTipHash{$toolTipHashKey})
				{
					$toolTipHashValue = $toolTipHash{$toolTipHashKey};
					# Modified line should look like this: <g id="Link_Brain_00001" onmousemove="ShowTooltip(evt,'Link_Brain_00001')" onmouseout="HideTooltip(evt)" class="Brain">
					$modifiedLine = '<g id="'.$toolTipHashKey;
					$modifiedLine = $modifiedLine .'" onmousemove="ShowTooltip(evt,';
					$modifiedLine = $modifiedLine ."\'".$toolTipHashValue."\'";
					$modifiedLine = $modifiedLine.','."'".$1."'".')" onmouseout="HideTooltip(evt)" class="'.$1.'">';
					print " Modified Link: ".$modifiedLine."\n";
					print $NEWSVGFILEHANDLE $modifiedLine."\n";
					$nextLineIsLinkPath = 1;
				}
				else
				{
					die( " Found Link but not in hash ".$1."\n");
				}
			}
			elsif($_ =~ m/^<\/svg>$/){
				#Look for the bottom of the file: </svg>
				#Add two lines before the last line
				#print " Found Last Line \n";
				#print $_."\n";
				print $NEWSVGFILEHANDLE '<rect class="tooltip_bg" id="tooltip_bg" x="0" y="0" rx="4" ry="4" width="60" height="60" visibility="hidden"/>'."\n";
				print $NEWSVGFILEHANDLE '<text class="tooltip" id="tooltip" x="0" y="0" visibility="hidden">Tooltip</text>'."\n";
				print $NEWSVGFILEHANDLE '</g>';
				print $NEWSVGFILEHANDLE $_."\n";

			}
			elsif($_ =~ m/$probeIDMatchString/){
				#print " Found Probe ID Text Line \n";
				#print $_."\n";	
				#Look for the probe id text, for example: <text x="574.2" y="2446.5" font-size="32.5px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(0,0,0)" transform="rotate(-45.1,574.2,2446.5)">7102228</text>
				#Add lines for Tissue Labels and what yellow means
				print $NEWSVGFILEHANDLE $_."\n";
				print $NEWSVGFILEHANDLE '<text x="1475.0" y="450.0" font-size="64px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(107,154,200)" >Brain</text>'."\n";
				if($organism eq "Rn"){
					print $NEWSVGFILEHANDLE '<text x="1475.0" y="575.0" font-size="64px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(251,106,74)" >Heart</text>'."\n";
					print $NEWSVGFILEHANDLE '<text x="1475.0" y="700.0" font-size="64px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(116,196,118)" >Liver</text>'."\n";
					print $NEWSVGFILEHANDLE '<text x="1475.0" y="825.0" font-size="64px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(158,154,200)" >BAT</text>'."\n";
				}
				print $NEWSVGFILEHANDLE '<text x="1475.0" y="255.0" font-size="40px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(0,0,0)" >Megabases</text>'."\n";
				print $NEWSVGFILEHANDLE '<text x="2680.0" y="2650.0" font-size="32px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(0,0,0)" >Yellow means</text>'."\n";
				print $NEWSVGFILEHANDLE '<text x="2750.0" y="2680.0" font-size="32px" font-family="CMUBright-Roman" style="text-anchor:end;fill:rgb(0,0,0)" >negative log p-value > '.$cutoff.'</text>'."\n";
			}
			else{
				print $NEWSVGFILEHANDLE $_."\n";
			}
		}
	} # While loop reading through current svg file
	close($NEWSVGFILEHANDLE);
	close($SVGFILEHANDLE);
}
1;

sub writeTopLines{
	my ($FILEHANDLE) = @_;
	print $FILEHANDLE '<?xml version="1.0" standalone="no"?>'."\n";
	print $FILEHANDLE '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">'."\n";
	print $FILEHANDLE '<svg width="3000px" height="3000px" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" onload="init(evt)">'."\n";
	print $FILEHANDLE '<script xlink:href="/PhenoGenTEST/javascript/SVGPan.js"/>'."\n";
 	print $FILEHANDLE '<style type="text/css"> '."\n";
	print $FILEHANDLE '.Heart'."\n";
	print $FILEHANDLE '{'."\n";
	print $FILEHANDLE '	stroke-opacity: 1.000000; '."\n";
	print $FILEHANDLE '	stroke-width: 5.0; '."\n";
	print $FILEHANDLE '	stroke: rgb(251,106,74); '."\n";
	print $FILEHANDLE '	fill: none'."\n";
	print $FILEHANDLE '}'."\n";
	print $FILEHANDLE '.Liver'."\n";
	print $FILEHANDLE '{'."\n";
	print $FILEHANDLE '	stroke-opacity: 1.000000; '."\n";
	print $FILEHANDLE '	stroke-width: 5.0; '."\n";
	print $FILEHANDLE '	stroke: rgb(116,196,118); '."\n";
	print $FILEHANDLE '	fill: none'."\n";
	print $FILEHANDLE '}'."\n";
	print $FILEHANDLE '.Brain'."\n";
	print $FILEHANDLE '{'."\n";
	print $FILEHANDLE '	stroke-opacity: 1.000000; '."\n";
	print $FILEHANDLE '	stroke-width: 5.0; '."\n";
	print $FILEHANDLE '	stroke: rgb(107,174,214); '."\n";
	print $FILEHANDLE '	fill: none'."\n";
	print $FILEHANDLE '}	'."\n";
	print $FILEHANDLE '.BAT'."\n";
	print $FILEHANDLE '	{'."\n";
	print $FILEHANDLE '	stroke-opacity: 1.000000; '."\n";
	print $FILEHANDLE '	stroke-width: 5.0; '."\n";
	print $FILEHANDLE '	stroke: rgb(158,154,200);'."\n"; 
	print $FILEHANDLE '	fill: none'."\n";
	print $FILEHANDLE '}	'."\n";
	print $FILEHANDLE '.tooltip{'."\n";
    print $FILEHANDLE '	font-size: 28px;'."\n";
  	print $FILEHANDLE '}'."\n";
    print $FILEHANDLE '.caption{'."\n";
	print $FILEHANDLE '	font-size: 14px;'."\n";
	print $FILEHANDLE '	font-family: Georgia, serif;'."\n";
    print $FILEHANDLE '}'."\n";
    print $FILEHANDLE '.tooltip_bg{'."\n";
    print $FILEHANDLE '	fill: white;'."\n";
    print $FILEHANDLE '	stroke: black;'."\n";
    print $FILEHANDLE '	stroke-width: 5;'."\n";
    print $FILEHANDLE '	opacity: 0.85;'."\n";
    print $FILEHANDLE '}'."\n";
    print $FILEHANDLE '.Heart:hover{'."\n";
    print $FILEHANDLE '	opacity: 0.5;'."\n";
    print $FILEHANDLE '}'."\n";
    print $FILEHANDLE '.Brain:hover{'."\n";
    print $FILEHANDLE '	opacity: 0.5;'."\n";
    print $FILEHANDLE '}'."\n";
    print $FILEHANDLE '.Liver:hover{'."\n";
    print $FILEHANDLE '	opacity: 0.5;'."\n";
    print $FILEHANDLE '}'."\n";
    print $FILEHANDLE '.BAT:hover{'."\n";
    print $FILEHANDLE '	opacity: 0.5;'."\n";
    print $FILEHANDLE '}'."\n";
    print $FILEHANDLE '</style>'."\n";
    print $FILEHANDLE ' '."\n";
    print $FILEHANDLE '<script type="text/ecmascript">'."\n";
    print $FILEHANDLE '<![CDATA['."\n";
    print $FILEHANDLE ' '."\n";
    print $FILEHANDLE '	function init(evt)'."\n";
    print $FILEHANDLE '	{'."\n";
	print $FILEHANDLE '    if ( window.svgDocument == null )'."\n";
    print $FILEHANDLE '	    {'."\n";
    print $FILEHANDLE '		svgDocument = evt.target.ownerDocument;'."\n";
    print $FILEHANDLE '	    }'."\n";
    print $FILEHANDLE ' '."\n";
    print $FILEHANDLE '	    tooltip = svgDocument.getElementById(\'tooltip\');'."\n";
    print $FILEHANDLE '	    tooltip_bg = svgDocument.getElementById(\'tooltip_bg\');'."\n";
    print $FILEHANDLE ' '."\n";
    print $FILEHANDLE '	}'."\n";
    print $FILEHANDLE ' '."\n";
    print $FILEHANDLE '        	function newGetEventPoint(evt,xval,yval){'."\n";
    print $FILEHANDLE ' 		var p = root.createSVGPoint();'."\n";
    print $FILEHANDLE '		p.x = evt.pageX+xval;'."\n";
    print $FILEHANDLE '		p.y = evt.pageY+yval;'."\n";
    print $FILEHANDLE '		return p;'."\n";
    print $FILEHANDLE ' 	}'."\n";  	
    print $FILEHANDLE '	function ShowTooltip(evt, mouseovertext, tissue)'."\n";
    print $FILEHANDLE '	{'."\n";
    print $FILEHANDLE '		var g = getRoot(svgDocument);'."\n";
    print $FILEHANDLE '		var k = g.getCTM();'."\n";
    #print $FILEHANDLE '		console.log(" y matrix value ");'."\n";
    #print $FILEHANDLE '		console.log(k.d);'."\n";
    #print $FILEHANDLE '		console.log(" x matrix value ");'."\n";
    #print $FILEHANDLE '		console.log(k.a);'."\n";
    print $FILEHANDLE '		var pToolTip = newGetEventPoint(evt,11,55*k.d).matrixTransform(g.getCTM().inverse());'."\n";
    print $FILEHANDLE '		var pToolTipBG = newGetEventPoint(evt,8,14*k.d).matrixTransform(g.getCTM().inverse());'."\n";		
    #print $FILEHANDLE '		console.log(" points ");'."\n";
    #print $FILEHANDLE '		console.log(pToolTip.x - pToolTipBG.x);'."\n";
    #print $FILEHANDLE '		console.log(pToolTip.y - pToolTipBG.y);'."\n";
    print $FILEHANDLE '	    tooltip.setAttributeNS(null,"x",pToolTip.x);'."\n";
    print $FILEHANDLE '	    tooltip.setAttributeNS(null,"y",pToolTip.y);'."\n";
    print $FILEHANDLE '	    tooltip.firstChild.data = mouseovertext;'."\n";
    print $FILEHANDLE '	    tooltip.setAttributeNS(null,"visibility","visible");'."\n";
    print $FILEHANDLE '	    length = tooltip.getComputedTextLength();'."\n";
    print $FILEHANDLE '	    tooltip_bg.setAttributeNS(null,"width",length+8);'."\n";
    print $FILEHANDLE '	    tooltip_bg.setAttributeNS(null,"x",pToolTipBG.x);'."\n";
    print $FILEHANDLE '	    tooltip_bg.setAttributeNS(null,"y",pToolTipBG.y);'."\n";
    print $FILEHANDLE '	    tooltip_bg.setAttributeNS(null,"visibility","visibile");'."\n";
    print $FILEHANDLE '         switch(tissue)'."\n";
    print $FILEHANDLE '         {'."\n";
    print $FILEHANDLE '              case "Brain":'."\n";
    print $FILEHANDLE '                   tooltip_bg.setAttributeNS(null,"style","stroke: rgb(107,174,214);");'."\n";
    print $FILEHANDLE '                break;'."\n";
    print $FILEHANDLE '              case "Liver":'."\n";
    print $FILEHANDLE '                   tooltip_bg.setAttributeNS(null,"style","stroke: rgb(116,196,118);")'."\n";
    print $FILEHANDLE '                break;'."\n";
    print $FILEHANDLE '              case "Heart":'."\n";
    print $FILEHANDLE '                   tooltip_bg.setAttributeNS(null,"style","stroke: rgb(251,106,74);");'."\n";
    print $FILEHANDLE '                break;'."\n";
    print $FILEHANDLE '              case "BAT":'."\n";
    print $FILEHANDLE '                   tooltip_bg.setAttributeNS(null,"style","stroke: rgb(158,154,200);")'."\n";
    print $FILEHANDLE '                   break;'."\n";
    print $FILEHANDLE '              default:'."\n";
    print $FILEHANDLE '                   tooltip_bg.setAttributeNS(null,"visibility","visible");'."\n";
    print $FILEHANDLE '                break;'."\n";
    print $FILEHANDLE '         }'."\n";
    print $FILEHANDLE '	}'."\n";
    print $FILEHANDLE ' '."\n";
    print $FILEHANDLE '	function HideTooltip(evt)'."\n";
    print $FILEHANDLE '	{'."\n";
    print $FILEHANDLE '	    tooltip.setAttributeNS(null,"visibility","hidden");'."\n";
    print $FILEHANDLE '	    tooltip_bg.setAttributeNS(null,"visibility","hidden");'."\n";
    print $FILEHANDLE '	}'."\n";
    print $FILEHANDLE ' '."\n";
    print $FILEHANDLE '    ]]>'."\n";
    print $FILEHANDLE '  </script>'."\n";
    print $FILEHANDLE ' <g id="viewport" transform = "scale(.333)">';
}
1;
