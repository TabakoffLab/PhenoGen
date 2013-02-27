#!/usr/bin/perl
use strict;

#
#
my $debugLevel = 2;
sub prepCircos
{
	# this routine creates configuration and data files for circos
	my($geneName,$geneSymbol,$probeID,$psLevel,$probeChromosome,$probeStart,$probeStop,$cutoff,$organism,$confDirectory,$dataDirectory,$chromosomeListRef,$tissueListRef,$dsn,$usr,$passwd,$hostname)=@_;	
	my @chromosomeList = @{$chromosomeListRef};
	my @tissueList = @{$tissueListRef};
	my $numberOfChromosomes = scalar @chromosomeList;
	my $numberOfTissues = scalar @tissueList;
	# if probeChromosome is not in chromosomeList then we don't want to create a links file
	my $oneToCreateLinks = 0;
	for (my $i = 0 ; $i < $numberOfChromosomes; $i++){
		if ($probeChromosome eq $chromosomeList[$i]) {
			$oneToCreateLinks = 1;
		}
	}
	if ($debugLevel >= 2){
		print " In prepCircos \n";
		print "Gene Name: $geneName \n";
		print "Gene Symbol: $geneSymbol \n";
		print "Probe ID: $probeID \n";
		print "PS Level: $psLevel \n";
		print "Chromosome: $probeChromosome \n";
		print "Probe Start: $probeStart \n";
		print "Probe Stop: $probeStop \n";
		print "Cutoff: $cutoff \n";
		print "Organism: $organism \n";
		print "Conf Directory: $confDirectory \n";
		print "Data Directory: $dataDirectory \n";
		print "One to create links: $oneToCreateLinks \n";
		print "Hostname $hostname \n";
		for (my $i = 0; $i < $numberOfChromosomes; $i++){
			print " Chromosome ".$chromosomeList[$i]."\n";
		}
		for (my $i = 0; $i < $numberOfTissues; $i++){
			print " Tissue ".$tissueList[$i]."\n";
		}
	}
	my $genericConfLocation = '/usr/local/circos-0.62-1/etc/';
	my $genericConfLocation2;
	if($hostname eq 'amc-kenny.ucdenver.pvt'){
		$genericConfLocation2 = '/usr/share/tomcat/webapps/PhenoGen/tmpData/geneData/';
	}
	elsif($hostname eq 'compbio.ucdenver.edu'){
		$genericConfLocation2 = '/usr/share/tomcat6/webapps/PhenoGenTEST/tmpData/geneData/';
	}
	elsif($hostname eq 'phenogen.ucdenver.edu'){
		$genericConfLocation2 = '/usr/share/tomcat6/webapps/PhenoGen/tmpData/geneData/';
	}
	elsif($hostname eq 'stan.ucdenver.pvt'){
		$genericConfLocation2 = '/usr/share/tomcat/webapps/PhenoGen/tmpData/geneData/';
	}
	else{
		die("Unrecognized Hostname:",$hostname,"\n");
	}
	my $karyotypeLocation = '/usr/local/circos-0.62-1/data/karyotype/';
	createCircosConfFile($confDirectory,$genericConfLocation,$genericConfLocation2,$karyotypeLocation,$organism,$chromosomeListRef,$oneToCreateLinks,$oneToCreateLinks);
	createCircosIdeogramConfFiles($confDirectory,$organism,$chromosomeListRef);
	createCircosProbesetTextConfFile($dataDirectory,$confDirectory);
	createCircosProbesetTextDataFile($dataDirectory,$geneName,$geneSymbol,$probeID,$psLevel,$probeChromosome,$probeStart,$probeStop,$organism);
	createCircosPvaluesConfFile($confDirectory,$dataDirectory,$cutoff,$organism,$tissueListRef);
	my $eqtlAOHRef = readLocusSpecificPvalues($probeID,$organism,$chromosomeListRef,$dsn,$usr,$passwd);	
	createCircosPvaluesDataFiles($dataDirectory,$probeID,$organism,$eqtlAOHRef,$chromosomeListRef);
	if($oneToCreateLinks == 1){
		createCircosLinksConfAndData($dataDirectory,$organism,$confDirectory,$eqtlAOHRef,$probeChromosome,$probeStart,$probeStop,$cutoff,$tissueListRef);	
	}
}


sub createCircosConfFile{
	# Create main circos configuration file
	my ($confDirectory,$genericConfLocation,$genericConfLocation2,$karyotypeLocation,$organism,$chromosomeListRef,$oneToCreateLinks) = @_;
	my @chromosomeList = @{$chromosomeListRef};
	my $numberOfChromosomes = scalar @chromosomeList;
	if($debugLevel >= 2){
		print " In createCircosConfFile \n";
	}
	my $fileName = $confDirectory.'circos.conf';
	open(CONFFILE,'>',$fileName) || die ("Can't open $fileName:$!");

	print CONFFILE '<<include '.$genericConfLocation.'colors_fonts_patterns.conf>>'."\n";

	print CONFFILE '<<include '.$confDirectory.'ideogram.conf>>'."\n";
	print CONFFILE '<<include '.$genericConfLocation2.'ticks.conf>>'."\n";

	if($organism eq 'Rn'){
		print CONFFILE 'karyotype   = '.$karyotypeLocation.'karyotype.rat.rn5.txt'."\n";
	}
	elsif($organism eq 'Mm'){
		 print CONFFILE 'karyotype   = '.$karyotypeLocation.'karyotype.mouse.mm9.txt'."\n";
	}
	else{
		die (" Organism is neither mouse nor rat :!\n");
	}

	print CONFFILE '<image>'."\n";
	print CONFFILE '<<include '.$genericConfLocation.'image.conf>>'."\n";
	print CONFFILE '</image>'."\n";

	print CONFFILE 'chromosomes_units = 1000000'."\n";

	print CONFFILE 'chromosomes = ';
	for(my $i = 0; $i < $numberOfChromosomes-1; $i++){
		print CONFFILE $chromosomeList[$i].';';
	}
	print CONFFILE $chromosomeList[$numberOfChromosomes-1]."\n";
	print CONFFILE 'chromosomes_display_default = no'."\n";

	print CONFFILE '<plots>'."\n";

	print CONFFILE '<<include '.$confDirectory.'circosProbesetText.conf>>'."\n";


	print CONFFILE '<<include '.$confDirectory.'circosPValues.conf>>'."\n";

	print CONFFILE '</plots>'."\n";

	if($oneToCreateLinks == 1){
		print CONFFILE '<links>'."\n";

		print CONFFILE '<<include '.$confDirectory.'circosLinks.conf>>'."\n";

		print CONFFILE '</links>'."\n";
	}
	print CONFFILE '<<include '.$genericConfLocation.'housekeeping.conf>>'."\n";
	close(CONFFILE);

}


sub createCircosIdeogramConfFiles{
	my ($confDirectory,$organism,$chromosomeListRef) = @_;
	# This routine will create the ideogram.conf file in the $confDirectory location
	my @chromosomeList = @{$chromosomeListRef};
	my $numberOfChromosomes = scalar @chromosomeList;
	my $fileName = $confDirectory.'ideogram.conf';
	open(CONFFILE,'>',$fileName) || die ("Can't open $fileName:$!");
	print CONFFILE '<ideogram>'."\n";
	print CONFFILE '<spacing>'."\n";
	print CONFFILE 'default = 0.01r'."\n";
	print CONFFILE 'break   = 0.25r'."\n";
	print CONFFILE '<pairwise '.$chromosomeList[0].','.$chromosomeList[$numberOfChromosomes-1].'>'."\n";
	print CONFFILE 'spacing = 5.0r'."\n";
	print CONFFILE '</pairwise>'."\n";
	print CONFFILE '</spacing>'."\n";
	print CONFFILE '# Position'."\n";
	print CONFFILE 'radius           = 0.775r'."\n";
	print CONFFILE 'thickness        = 30p'."\n";
	print CONFFILE 'fill             = yes'."\n";
	print CONFFILE 'fill_color       = black'."\n";
	print CONFFILE 'stroke_thickness = 2'."\n";
	print CONFFILE 'stroke_color     = black'."\n";
	print CONFFILE '# Label'."\n";
	print CONFFILE 'show_label       = yes'."\n";
	print CONFFILE 'label_font       = default'."\n";	
	print CONFFILE 'label_radius = dims(ideogram,radius_inner) - 75p'."\n";
	print CONFFILE 'label_size       = 60'."\n";
	print CONFFILE 'label_parallel   = yes'."\n";
	print CONFFILE 'label_case       = upper'."\n";
	print CONFFILE '# Bands'."\n";
	print CONFFILE 'show_bands            = yes'."\n";
	print CONFFILE 'fill_bands            = yes'."\n";
	print CONFFILE 'band_stroke_thickness = 2'."\n";
	print CONFFILE 'band_stroke_color     = white'."\n";
	print CONFFILE 'band_transparency     = 0'."\n";
	print CONFFILE 'radius*       = 0.825r'."\n";
	print CONFFILE '</ideogram>'."\n";
	close(CONFFILE);
}

sub createCircosProbesetTextConfFile{
	# Create the circos configuration file that allows labeling of the probeset ID	
	my ($dataDirectory,$confDirectory) = @_;	
	if($debugLevel >= 2){
		print " In createCircosProbesetTextConfFile \n";
	}
	my $fileName = $confDirectory.'circosProbesetText.conf';
	open(CONFFILE,'>',$fileName) || die ("Can't open $fileName:!\n");
	print CONFFILE '<plot>'."\n";
	print CONFFILE 'type             = text'."\n";
	print CONFFILE 'color            = black'."\n";
	print CONFFILE 'file = '.$dataDirectory.'probesets.txt'."\n";
	print CONFFILE 'r0 = 1.07r'."\n";
	print CONFFILE 'r1 = 1.07r+500p'."\n";
	print CONFFILE 'show_links     = yes'."\n";
	print CONFFILE 'link_dims      = 0p,0p,70p,0p,10p'."\n";
	print CONFFILE 'link_thickness = 5p'."\n";
	print CONFFILE 'link_color     = red'."\n";
	print CONFFILE 'label_size   = 50p'."\n";
	print CONFFILE 'label_font   = default'."\n";
	print CONFFILE 'padding  = 0p'."\n";
	print CONFFILE 'rpadding = 0p'."\n";
	print CONFFILE '</plot>'."\n";
	close(CONFFILE);
}


sub createCircosProbesetTextDataFile{
	# Create the circos data file that allows labeling of the probeset ID
	my ($dataDirectory,$geneName,$geneSymbol,$probeID,$psLevel,$probeChromosome,$probeStart,$probeStop,$organism)=@_;	
	if($debugLevel >= 2){
		print " In createCircosProbesetTextDataFile \n";
	}
	my $fileName = $dataDirectory.'probesets.txt';
	open(DATAFILE,'>',$fileName) || die ("Can't open $fileName:!\n");
	# Example of data in this file:  rn12	34947771	34947875	P2rx4-5731411
	# Probably do away with the P2rx4- since that information will appear elsewhere on the page??
	#print DATAFILE $probeChromosome, " ",$probeStart, " ",$probeStop, " ",$probeID, "\n";
	print DATAFILE $probeChromosome, " ",$probeStart, " ",$probeStop, " ",$geneSymbol, "\n";
	close(DATAFILE);
}


sub createCircosPvaluesConfFile{
	# Create the circos configuration file that allows displaying pvalue histograms
	my ($confDirectory,$dataDirectory,$cutoff,$organism,$tissueListRef)=@_;
	my @tissueList = @{$tissueListRef};
	my $numberOfTissues = scalar @tissueList;
	if($debugLevel >= 2){
		print " In createCircosPvaluesConfFile \n";
	}
	
	my $fileName = $confDirectory.'circosPValues.conf';
	#open(CONFFILE,'>',$fileName) || die ("Can't open $fileName:!\n");
	

	open my $PLOTFILEHANDLE,'>',$fileName || die ("Can't open $fileName:!\n");
	
	
	print $PLOTFILEHANDLE 'extend_bin = no'."\n";
	print $PLOTFILEHANDLE 'fill_under = yes'."\n";
	print $PLOTFILEHANDLE 'stroke_thickness = 1p'."\n";
	

	my $plotColor;
	my $innerRadius;
	my $outerRadius;
	my $plotFileName;
	my %colorHash;
	
	$colorHash{'Heart'}='red';
	$colorHash{'Brain'}='blue';
	$colorHash{'Liver'}='green';
	$colorHash{'BAT'}='purple';
	my %filenameHash;
	
	$filenameHash{'Heart'}='circosHeartPValues.txt';
	$filenameHash{'Brain'}='circosBrainPValues.txt';
	$filenameHash{'Liver'}='circosLiverPValues.txt';
	$filenameHash{'BAT'}='circosBATPValues.txt';	
	
	foreach my $key (keys(%colorHash)){
	
		print " key $key $colorHash{$key} \n";
	
	}
	
	my @innerRadiusArray = ('0.85r','0.75r','0.65r','0.55r');
	my @outerRadiusArray = ('0.85r + 100p','0.75r + 100p','0.65r + 100p','0.55r + 100p');

	for(my $i=0; $i<$numberOfTissues; $i++){
		$plotColor = $colorHash{$tissueList[$i]};
		$plotFileName = $dataDirectory.$filenameHash{$tissueList[$i]};
		$innerRadius=$innerRadiusArray[$i];
		$outerRadius=$outerRadiusArray[$i];
		
		writePlot($PLOTFILEHANDLE,$plotFileName,$plotColor,$innerRadius,$outerRadius,$cutoff);
	}

	close($PLOTFILEHANDLE);	
}


sub createCircosPvaluesDataFiles{
	# Create data files for pvalues
	# The number of data files will depend on the species and the variable "tissue"
	# If species is rat and tissue is "all" then
	# To simplify, create all 4 data files in all cases
	# TBD fix this later.
	# the configuration file will tell which of the data files to use
	# The data looks like this:
	# rn1 15538471 20538471 0.646468441
	# The 2nd column is the location of the SNP 
	# The 3rd column has been modified so the histogram shows up better.
	# The 3rd column might be modified by adding 5000000
	my ($dataDirectory,$probeID,$organism, $eqtlAOHRef,$chromosomeListRef) = @_;
	my @chromosomeList = @{$chromosomeListRef};
	my $numberOfChromosomes = scalar @chromosomeList;
	if($debugLevel >= 2){
		print " In createCircosPvaluesDataFiles \n";
	}
	my @eqtlAOH = @{$eqtlAOHRef};
	my $arrayLength = scalar @eqtlAOH;
	if($debugLevel >= 2){
		print " Length of array $arrayLength \n";
	}
	my $brainFileName = $dataDirectory.'circosBrainPValues.txt';
	open(BRAINFILE,'>',$brainFileName) || die ("Can't open $brainFileName:!\n");

	my $liverFileName = $dataDirectory.'circosLiverPValues.txt';
	open(LIVERFILE,'>',$liverFileName) || die ("Can't open $liverFileName:!\n");
			
	my $heartFileName = $dataDirectory.'circosHeartPValues.txt';
	open(HEARTFILE,'>',$heartFileName) || die ("Can't open $heartFileName:!\n");

	my $BATFileName = $dataDirectory.'circosBATPValues.txt';
	open(BATFILE,'>',$BATFileName) || die ("Can't open $BATFileName:!\n");


	# Go through the eqtl array of hashes and write data to appropriate files
	my $tissue;
	my $stopLocation;
	my $i;
	for($i=0;$i<$arrayLength;$i++){
		$tissue = $eqtlAOH[$i]{tissue};
		$stopLocation = $eqtlAOH[$i]{location} + 50000*$numberOfChromosomes;
		if($tissue eq 'Whole Brain'){
			print BRAINFILE $eqtlAOH[$i]{chromosome}." ".$eqtlAOH[$i]{location}." ".$stopLocation." ".$eqtlAOH[$i]{pvalue}."\n";
		}
		elsif($tissue eq 'Liver'){
			print LIVERFILE $eqtlAOH[$i]{chromosome}." ".$eqtlAOH[$i]{location}." ".$stopLocation." ".$eqtlAOH[$i]{pvalue}."\n";
		}
		elsif($tissue eq 'Heart'){
			print HEARTFILE $eqtlAOH[$i]{chromosome}." ".$eqtlAOH[$i]{location}." ".$stopLocation." ".$eqtlAOH[$i]{pvalue}."\n";
		}
		elsif($tissue eq 'Brown Adipose'){
			print BATFILE $eqtlAOH[$i]{chromosome}." ".$eqtlAOH[$i]{location}." ".$stopLocation." ".$eqtlAOH[$i]{pvalue}."\n";
		}
		else{
			die(" Invalid Tissue in createCircosPvaluesDataFiles.  Organism: $organism  Tissue: $tissue\n");
		}
	}
	close(BRAINFILE);
	close(HEARTFILE);
	close(LIVERFILE);
	close(BATFILE);
}

sub createCircosLinksConfAndData{
	# Create configuration and data file for circos links
	# This is more complicated since there will be a varying number of data files
	# Therefore, keeping the configuration and data file creation together
	my ($dataDirectory,$organism,$confDirectory,$eqtlAOHRef,$probeChromosome,$probeStart,$probeStop,$cutoff,$tissueListRef) = @_;
	my @tissueList = @{$tissueListRef};
	my $numberOfTissues = scalar @tissueList;
	if($debugLevel >= 2){
		print " In createCircosLinksConfAndData \n";
	}
	my @linkAOH; # this is an array of hashes to store required data
	my @eqtlAOH = @{$eqtlAOHRef};
	my $arrayLength = scalar @eqtlAOH;
	my $i;
	my $linkCount = -1;
	my $numberString;
	my $tissue;
	my $linkColor;
	my $keepLink;

	for($i=0;$i<$arrayLength;$i++){
		if($eqtlAOH[$i]{pvalue} > $cutoff){
			# Check whether we want this type of link
			$tissue = $eqtlAOH[$i]{tissue};
			if($tissue eq "Whole Brain"){
				$tissue = "Brain";
			}
			elsif($tissue eq "Brown Adipose"){
				$tissue = "BAT";
			}
			$keepLink = 0;
			if($organism eq 'Rn'){
				for(my $j=0; $j< $numberOfTissues; $j++){
					if($tissue eq $tissueList[$j]){
						$keepLink = 1;
					}
				}
			}
			elsif($organism eq 'Mm'){
				# We don't allow them to really choose tissues for mouse, so this will always be 1.
				$keepLink = 1;
			}
			if($keepLink == 1){
				$linkCount++;
				# We want a link here between the probeset and this SNP.
				$linkAOH[$linkCount]{tissue}=$tissue;
				if($tissue eq "Brain"){
					$linkColor = 'blue';
				}
				elsif($tissue eq "Liver"){
					$linkColor = 'green';
				}
				elsif($tissue eq "Heart"){
					$linkColor = 'red';
				}
				elsif($tissue eq "BAT"){
					$linkColor = 'purple';
				}
				$linkAOH[$linkCount]{chromosome} = $eqtlAOH[$i]{chromosome};
				$linkAOH[$linkCount]{location} = $eqtlAOH[$i]{location};
				$linkAOH[$linkCount]{name} = $eqtlAOH[$i]{name};
				$linkAOH[$linkCount]{color}=$linkColor;
				$numberString = sprintf "%05d", $linkCount;
				$linkAOH[$linkCount]{linkname} = "Link_".$tissue."_".$numberString;
				$linkAOH[$linkCount]{linknumber} = $linkCount;
			}
		}
	}
	my $totalLinks = scalar @linkAOH;
	if($debugLevel >= 2){
		print "Total Links: $totalLinks \n";
	}
	# Now create data files
	# Also create tool tip file
	my $toolTipFileName = $dataDirectory."LinkToolTips.txt";
	open(TOOLTIPFILE,'>',$toolTipFileName) || die ("Can't open $toolTipFileName:!\n");
	my $linkFileName;
	my $linkName;
	for($i=0;$i<$totalLinks;$i++){
		if($debugLevel >= 3){
			print " i $i \n";
			print " Link number: $linkAOH[$i]{linknumber} \n";
			print " Link Name: $linkAOH[$i]{linkname} \n";
			print " Tissue: $linkAOH[$i]{tissue} \n";
			print " Chromosome: $linkAOH[$i]{chromosome} \n";
			print " Location: $linkAOH[$i]{location} \n";
			print " SNP Name: $linkAOH[$i]{name} \n";
			print " Link Color: $linkAOH[$i]{color} \n";
			print "\n";
		}
		print TOOLTIPFILE $linkAOH[$i]{linkname}."\t".substr($linkAOH[$i]{chromosome},2)."\t".$linkAOH[$i]{location}."\n";
		$linkFileName = $dataDirectory.$linkAOH[$i]{linkname}.".txt";
		open(LINKFILE,'>',$linkFileName) || die ("Can't open $linkFileName:!\n");
		print LINKFILE $linkAOH[$i]{name}." ".$linkAOH[$i]{chromosome}." ".$linkAOH[$i]{location}." ".$linkAOH[$i]{location}."\n"; # This is the SNP location
		print LINKFILE $linkAOH[$i]{name}." ".$probeChromosome." ".$probeStart." ".$probeStop."\n"; # This is the probeset location
		close(LINKFILE);		
	}
	close(TOOLTIPFILE);
	# Now create the conf file
	my $confFileName = $confDirectory."circosLinks.conf";
	open my $CONFFILEHANDLE,'>',$confFileName || die ("Can't open $confFileName:!\n");
	
	for($i=0;$i<$totalLinks;$i++){
		$linkFileName = $dataDirectory.$linkAOH[$i]{linkname}.".txt";
		$linkName = $linkAOH[$i]{linkname};
		$linkColor = $linkAOH[$i]{color};
		writeLink($CONFFILEHANDLE,$linkFileName,$linkName,$linkColor,$organism,$numberOfTissues);
	}
	close(CONFFILE);
	print " Finished with createCircosLinksConfAndData \n";
}



sub writeLink{
	my ($FILEHANDLE,$LinkFileName,$linkName,$linkColor,$organism,$numberOfTissues) = @_;
	print $FILEHANDLE "<link ".$linkName.">"."\n";
	print $FILEHANDLE  "z = 0"."\n";
	if($numberOfTissues == 4){
		print $FILEHANDLE  "radius = 0.55r"."\n";
	}
	elsif($numberOfTissues == 3){
		print $FILEHANDLE  "radius = 0.65r"."\n";	
	}
	elsif($numberOfTissues == 2){
		print $FILEHANDLE  "radius = 0.75r"."\n";
	}
	else{
		print $FILEHANDLE "radius = 0.85r"."\n";
	}
	print $FILEHANDLE  "bezier_radius = .1r"."\n";
	print $FILEHANDLE  "show = yes"."\n";
	print $FILEHANDLE  "color = ".$linkColor."\n";
	print $FILEHANDLE  "thickness = 5"."\n";
	print $FILEHANDLE  "file = ".$LinkFileName."\n";
	print $FILEHANDLE  "</link>"."\n";
}

sub writePlot{
	my ($FILEHANDLE,$plotFileName,$plotColor,$innerRadius,$outerRadius,$cutoff) = @_;
	print $FILEHANDLE '<plot>'."\n";
	print $FILEHANDLE 'show = yes'."\n";
	print $FILEHANDLE 'type = histogram'."\n";
	print $FILEHANDLE 'stroke_color = '.$plotColor."\n";
	print $FILEHANDLE 'fill_color = '.$plotColor."\n";
	print $FILEHANDLE 'min = 0'."\n";
	print $FILEHANDLE 'max = 5'."\n";
	
	#print $FILEHANDLE 'r0 = 0.85r'."\n";
	#print $FILEHANDLE 'r1 = 0.85r +100p'."\n";
	
	
	print $FILEHANDLE 'r0 = '.$innerRadius."\n";
	print $FILEHANDLE 'r1 = '.$outerRadius."\n";
	print $FILEHANDLE '<axes>'."\n";
	print $FILEHANDLE '<axis>'."\n";
	print $FILEHANDLE 'thickness = 1'."\n";
	print $FILEHANDLE 'spacing = 0.2r'."\n";
	#print $FILEHANDLE 'spacing = 1.0r'."\n";
	print $FILEHANDLE 'color = black'."\n";
	#print $FILEHANDLE 'axis           = yes'."\n";
	#print $FILEHANDLE 'axis_color     = black'."\n";
	#print $FILEHANDLE 'axis_thickness = 1'."\n";
	#print $FILEHANDLE 'axis_spacing   = 1.0'."\n";
	print $FILEHANDLE '</axis>'."\n";
	print $FILEHANDLE '</axes>'."\n";
	

	print $FILEHANDLE '<backgrounds>'."\n";
	print $FILEHANDLE '<background>'."\n";
	print $FILEHANDLE 'color = l'.$plotColor."\n";
	#print $FILEHANDLE 'background       = yes'."\n";
	#print $FILEHANDLE 'background_color = l'.$plotColor."\n";
	#print $FILEHANDLE 'background_stroke_color = black'."\n";
	#print $FILEHANDLE 'background_stroke_thickness = 2'."\n";
	print $FILEHANDLE '</background>'."\n";
	print $FILEHANDLE '</backgrounds>'."\n";


	print $FILEHANDLE '<rules>'."\n";
	print $FILEHANDLE '<rule>'."\n";
	print $FILEHANDLE 'importance = 100'."\n";
	print $FILEHANDLE 'condition  = _VALUE_ > '.$cutoff."\n";
	print $FILEHANDLE 'fill_color = yellow'."\n";
	print $FILEHANDLE 'color = dyellow'."\n";
	print $FILEHANDLE '</rule>'."\n";
	print $FILEHANDLE '</rules>'."\n";


	print $FILEHANDLE 'file = '.$plotFileName."\n";

	#print $FILEHANDLE 'file = '.$dataDirectory.'circosBrainPValues.txt'."\n";

	print $FILEHANDLE '</plot>'."\n";

}

1;
