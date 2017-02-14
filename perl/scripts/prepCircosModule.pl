#!/usr/bin/perl
use strict;

#
#
my $debugLevel = 1;

sub replaceDot{
    my $text=shift;
    $text =~ s/\./_/g;
    return $text;
}

sub prepCircosMod
{
	# this routine creates configuration and data files for circos
	my($module,$cutoff,$organism,$confDirectory,$dataDirectory,$chromosomeListRef,$tissueString,$genomeVer,$hostname,$dsn,$usr,$passwd)=@_;	
	my @chromosomeList = @{$chromosomeListRef};
	my $numberOfChromosomes = scalar @chromosomeList;
	# if probeChromosome is not in chromosomeList then we don't want to create a links file
	my $oneToCreateLinks = 1;
	
	if ($debugLevel >= 2){
		print " In prepCircos \n";
		print "Module: $module \n";
		print "Cutoff: $cutoff \n";
		print "Organism: $organism \n";
		print "Conf Directory: $confDirectory \n";
		print "Data Directory: $dataDirectory \n";
		print "One to create links: $oneToCreateLinks \n";
		print "Hostname $hostname \n";
		for (my $i = 0; $i < $numberOfChromosomes; $i++){
			print " Chromosome ".$chromosomeList[$i]."\n";
		}
		print " Tissue ".$tissueString."\n";
		
	}
	
	my $genericConfLocation2;
	if($hostname eq 'phenogen' and index($dsn,"test")>0){
		$genericConfLocation2 = '/usr/share/tomcat6/webapps/PhenoGenTEST/tmpData/geneData/';
	}elsif($hostname eq 'phenogen' and index($dsn,"test")==-1){
                $genericConfLocation2 = '/usr/share/tomcat6/webapps/PhenoGen/tmpData/geneData/';
        }
	elsif($hostname eq 'stan.ucdenver.pvt'){
		$genericConfLocation2 = '/Library/Tomcat/webapps/PhenoGen/tmpData/geneData/';
	}
	else{
		die("Unrecognized Hostname:",$hostname,"\n");
	}
        my $genericConfLocation = '/usr/local/circos-0.69-4/etc/';
	my $karyotypeLocation = '/usr/local/circos-0.69-4/data/karyotype/';
	createCircosConfFile($confDirectory,$genericConfLocation,$genericConfLocation2,$karyotypeLocation,$organism,$chromosomeListRef,$oneToCreateLinks,$oneToCreateLinks);
	createCircosIdeogramConfFiles($confDirectory,$organism,$chromosomeListRef);
	createCircosModGenesTextConfFile($dataDirectory,$confDirectory);
	createCircosModGenesTextDataFile($module,$tissueString,$dataDirectory,$organism,$genomeVer,$dsn,$usr,$passwd);
	createCircosPvaluesConfFile($confDirectory,$dataDirectory,$cutoff,$organism,$tissueString);
	my $eqtlAOHRef = readLocusSpecificPvaluesModule($module,$organism,$tissueString,$chromosomeListRef,$genomeVer,$dsn,$usr,$passwd);
	createCircosPvaluesDataFiles($dataDirectory,$module,$organism,$eqtlAOHRef,$chromosomeListRef,$tissueString);
	if($oneToCreateLinks == 1){
		createCircosLinksConfAndData($dataDirectory,$organism,$confDirectory,$eqtlAOHRef,$cutoff,$tissueString,$chromosomeList[0]);	
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
		 print CONFFILE 'karyotype   = '.$karyotypeLocation.'karyotype.mouse.mm10.txt'."\n";
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

	print CONFFILE '<<include '.$confDirectory.'circosModGenesText.conf>>'."\n";


	print CONFFILE '<<include '.$confDirectory.'circosModPValues.conf>>'."\n";

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

sub createCircosModGenesTextConfFile{
	# Create the circos configuration file that allows labeling of the probeset ID	
	my ($dataDirectory,$confDirectory) = @_;	
	if($debugLevel >= 2){
		print " In createCircosProbesetTextConfFile \n";
	}
	my $fileName = $confDirectory.'circosModGenesText.conf';
	open(CONFFILE,'>',$fileName) || die ("Can't open $fileName:!\n");
	print CONFFILE '<plot>'."\n";
	
	print CONFFILE 'type             = text'."\n";
	print CONFFILE 'color            = red'."\n";
	print CONFFILE 'file = '.$dataDirectory.'genes.txt'."\n";
	print CONFFILE 'r0 = 1.07r'."\n";
	print CONFFILE 'r1 = 1.07r+900p'."\n";
	print CONFFILE 'show_links     = no'."\n";
	print CONFFILE 'link_dims      = 0p,0p,20p,0p,5p'."\n";
	print CONFFILE 'link_thickness = 2p'."\n";
	print CONFFILE 'link_color     = red'."\n";
	print CONFFILE 'label_size   = 20p'."\n";
	#print CONFFILE 'label_font=glyph'."\n";
	print CONFFILE 'label_font   = default'."\n";
	print CONFFILE 'padding  = 1p'."\n";
	print CONFFILE 'rpadding = 1p'."\n";
	print CONFFILE 'max_snuggle_distance = 2r'."\n";
	print CONFFILE '<rules>'."\n";
	print CONFFILE '<rule>'."\n";
	print CONFFILE 'condition = 1'."\n";
	print CONFFILE 'value=X'."\n";
        print CONFFILE 'flow = continue # if this rule passes, continue testing'."\n";
	print CONFFILE '</rule>'."\n";
        print CONFFILE '<rule>'."\n";
        print CONFFILE 'condition = var(svgclass)'."\n";
        print CONFFILE 'svgclass  = eval(my $x = var(svgclass); $x =~ s/\./ /g; $x)'."\n";
        print CONFFILE 'flow = continue # if this rule passes, continue testing'."\n";
        print CONFFILE '</rule>'."\n";
        print CONFFILE '<rule>'."\n";
	print CONFFILE 'condition = eval(my $x=index(var(value),"ENS")+1; $x==1)'."\n";
	print CONFFILE 'color = green'."\n";
	print CONFFILE '</rule>'."\n";
	print CONFFILE '</rules>'."\n";
	print CONFFILE '</plot>'."\n";
	close(CONFFILE);
}


sub createCircosModGenesTextDataFile{
	# Create the circos data file that allows labeling of the genes in the module
	my ($module,$tissue,$dataDirectory,$organism,$genomeVer,$dsn,$usr,$passwd)=@_;	
	if($debugLevel >= 2){
		print " In createCircosProbesetTextDataFile \n";
	}
	
	if ($tissue eq "Brain") {
		$tissue="Whole Brain";
	}
	my $sp="mm";
	if ($organism eq "Rn") {
		$sp="rn";
	}
	
	
	my $query="select wi.gene_id,c.name,ae.psstart from wgcna_module_info wi, affy_exon_probeset ae, chromosomes c
			where wi.wdsid in (Select wd.wdsid from wgcna_dataset wd where wd.organism='$organism' and wd.tissue='$tissue' and wd.genome_id='$genomeVer' and wd.visible=1) 
			and wi.module='$module'
			and ae.probeset_id=wi.probeset_id
			and ae.psannotation='probeset'
			and ae.updatedlocation='Y'
			and c.chromosome_id=ae.chromosome_id";
	my $connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");
	my $query_handle = $connect->prepare($query) or die (" Gene Location from module query prepare failed $!");
	$query_handle->execute() or die ( "Location Specific EQTL query execute failed $!");

	# BIND TABLE COLUMNS TO VARIABLES
	my ($geneid, $chr, $location);
	my %geneHOH;
	$query_handle->bind_columns(\$geneid ,\$chr, \$location);
	while($query_handle->fetch()) {
		if (defined $geneHOH{$geneid}) {
			if ($location<$geneHOH{$geneid}{min}) {
				$geneHOH{$geneid}{min}=$location;
			}
			if ($location>$geneHOH{$geneid}{max}) {
				$geneHOH{$geneid}{max}=$location;
			}
		}else{
			$geneHOH{$geneid}{chr}=$chr;
			$geneHOH{$geneid}{min}=$location;
			$geneHOH{$geneid}{max}=$location;
		}
	}
	my $fileName = $dataDirectory.'genes.txt';
	open(DATAFILE,'>',$fileName) || die ("Can't open $fileName:!\n");
	my @list=keys %geneHOH;
	foreach my $gene(@list){
                my $colorGene="193,163,102";
                if(index($gene,"ENS")==-1){
                    $colorGene="96,151,184";
                }
		print DATAFILE $sp.$geneHOH{$gene}{chr}, " ",$geneHOH{$gene}{min}, " ",$geneHOH{$gene}{max}, " ",$gene," svgclass=circosGene.",replaceDot($gene),",color=",$colorGene,",svgid=",replaceDot($gene), "\n";
	}
	close(DATAFILE);
}


sub createCircosPvaluesConfFile{
	# Create the circos configuration file that allows displaying pvalue histograms
	my ($confDirectory,$dataDirectory,$cutoff,$organism,$tissue)=@_;
	my $numberOfTissues = 1;
	if($debugLevel >= 2){
		print " In createCircosPvaluesConfFile \n";
	}
	
	my $fileName = $confDirectory.'circosModPValues.conf';
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
	
        if($debugLevel >= 2){
            foreach my $key (keys(%colorHash)){
                    print " key $key $colorHash{$key} \n";
            }
		}
	my @innerRadiusArray = ('0.85r','0.75r','0.65r','0.55r');
	my @outerRadiusArray = ('0.85r + 100p','0.75r + 100p','0.65r + 100p','0.55r + 100p');

	
	$plotColor = $colorHash{$tissue};
	$plotFileName = $dataDirectory.$filenameHash{$tissue};
	$innerRadius=$innerRadiusArray[0];
	$outerRadius=$outerRadiusArray[0];
	writePlot($PLOTFILEHANDLE,$plotFileName,$plotColor,$innerRadius,$outerRadius,$cutoff);

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
	my ($dataDirectory,$module,$organism, $eqtlAOHRef,$chromosomeListRef,$tissueString) = @_;
	my @chromosomeList = @{$chromosomeListRef};
	my $numberOfChromosomes = scalar @chromosomeList;
	my @eqtlAOH = @{$eqtlAOHRef};
	my $arrayLength = scalar @eqtlAOH;
	my %filenameHash;
	$filenameHash{'Heart'}='circosHeartPValues.txt';
	$filenameHash{'Brain'}='circosBrainPValues.txt';
	$filenameHash{'Liver'}='circosLiverPValues.txt';
	$filenameHash{'BAT'}='circosBATPValues.txt';
	my $brainFileName =  $dataDirectory.$filenameHash{$tissueString};
	open(BRAINFILE,'>',$brainFileName) || die ("Can't open $brainFileName:!\n");

	#my $liverFileName = $dataDirectory.'circosLiverPValues.txt';
	#open(LIVERFILE,'>',$liverFileName) || die ("Can't open $liverFileName:!\n");
			
	#my $heartFileName = $dataDirectory.'circosHeartPValues.txt';
	#open(HEARTFILE,'>',$heartFileName) || die ("Can't open $heartFileName:!\n");

	#my $BATFileName = $dataDirectory.'circosBATPValues.txt';
	#open(BATFILE,'>',$BATFileName) || die ("Can't open $BATFileName:!\n");
	my $sp="mm";
	if ($organism eq "Rn") {
		$sp="rn";
	}

	# Go through the eqtl array of hashes and write data to appropriate files
	my $tissue;
	my $stopLocation;
	my $i;
	for($i=0;$i<$arrayLength;$i++){
		$tissue = $eqtlAOH[$i]{tissue};
		$stopLocation = $eqtlAOH[$i]{location} + 50000*$numberOfChromosomes;
		#if($tissue eq 'Whole Brain'){
			print BRAINFILE $eqtlAOH[$i]{chromosome}." ".$eqtlAOH[$i]{location}." ".$stopLocation." ".$eqtlAOH[$i]{pvalue}."\n";
		#}
		#elsif($tissue eq 'Liver'){
		#	print LIVERFILE $eqtlAOH[$i]{chromosome}." ".$eqtlAOH[$i]{location}." ".$stopLocation." ".$eqtlAOH[$i]{pvalue}."\n";
		#}
		#elsif($tissue eq 'Heart'){
		#	print HEARTFILE $eqtlAOH[$i]{chromosome}." ".$eqtlAOH[$i]{location}." ".$stopLocation." ".$eqtlAOH[$i]{pvalue}."\n";
		#}
		#elsif($tissue eq 'Brown Adipose'){
		#	print BATFILE $eqtlAOH[$i]{chromosome}." ".$eqtlAOH[$i]{location}." ".$stopLocation." ".$eqtlAOH[$i]{pvalue}."\n";
		#}
		#else{
		#	die(" Invalid Tissue in createCircosPvaluesDataFiles.  Organism: $organism  Tissue: $tissue\n");
		#}
	}
	close(BRAINFILE);
	#close(HEARTFILE);
	#close(LIVERFILE);
	#close(BATFILE);
}

sub createCircosLinksConfAndData{
	# Create configuration and data file for circos links
	# This is more complicated since there will be a varying number of data files
	# Therefore, keeping the configuration and data file creation together
	my ($dataDirectory,$organism,$confDirectory,$eqtlAOHRef,$cutoff,$tissue,$firstChr) = @_;
	my $numberOfTissues = 1;
	my @linkAOH; # this is an array of hashes to store required data
	my @eqtlAOH = @{$eqtlAOHRef};
	my $arrayLength = scalar @eqtlAOH;
	my $i;
	my $linkCount = -1;
	my $numberString;
	my $linkColor;
	my $keepLink;
	my $sp="mm";
	if ($organism eq "Rn") {
		$sp="rn";
	}

	for($i=0;$i<$arrayLength;$i++){
		if($eqtlAOH[$i]{pvalue} > $cutoff){
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

                        my $tmpName=$eqtlAOH[$i]{name};
                        $tmpName =~ s/\./_/g;
                        
			$linkAOH[$linkCount]{chromosome} = $eqtlAOH[$i]{chromosome};
			$linkAOH[$linkCount]{location} = $eqtlAOH[$i]{location};
			$linkAOH[$linkCount]{name} = $tmpName;
			$linkAOH[$linkCount]{color}=$linkColor;
			$numberString = sprintf "%05d", $linkCount;
			$linkAOH[$linkCount]{linkname} = "Link_".$tmpName;
			$linkAOH[$linkCount]{linknumber} = $linkCount;
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
		print TOOLTIPFILE $linkAOH[$i]{linkname}."\t".substr($linkAOH[$i]{chromosome},2)."\t".$linkAOH[$i]{location}."\n";
		$linkFileName = $dataDirectory.$linkAOH[$i]{linkname}.".txt";
		open(LINKFILE,'>',$linkFileName) || die ("Can't open $linkFileName:!\n");
		print LINKFILE $linkAOH[$i]{name}." ".$linkAOH[$i]{chromosome}." ".$linkAOH[$i]{location}." ".$linkAOH[$i]{location}." radius1=0.85r\n"; # This is the SNP location
		print LINKFILE $linkAOH[$i]{name}." ".$firstChr." 1 1 radius2=0r\n"; # This is the probeset location
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
		writeLink($CONFFILEHANDLE,$linkFileName,$linkName,$linkColor,$organism,$numberOfTissues,$i);
	}
	close(CONFFILE);
	#print " Finished with createCircosLinksConfAndData \n";
}



sub writeLink{
	my ($FILEHANDLE,$LinkFileName,$linkName,$linkColor,$organism,$numberOfTissues,$i) = @_;
	print $FILEHANDLE "<link ".$linkName.">"."\n";
	print $FILEHANDLE  "z = ".$i."\n";
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
	print $FILEHANDLE  "bezier_radius = 0r"."\n";
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
	print $FILEHANDLE 'condition  = var(value) > '.$cutoff."\n";
	#print $FILEHANDLE 'condition  = _VALUE_ > '.$cutoff."\n";
	print $FILEHANDLE 'fill_color = yellow'."\n";
	print $FILEHANDLE 'color = dyellow'."\n";
	print $FILEHANDLE '</rule>'."\n";
	print $FILEHANDLE '</rules>'."\n";


	print $FILEHANDLE 'file = '.$plotFileName."\n";

	#print $FILEHANDLE 'file = '.$dataDirectory.'circosBrainPValues.txt'."\n";

	print $FILEHANDLE '</plot>'."\n";

}

1;
