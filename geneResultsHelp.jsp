



<div id="Help3Content" class="inpageHelpContent" title="Help"><div class="help-content">
<H3>Filter/Display Controls</H3>
The filters allow you to control the probe sets that are displayed.  Check the box next to the filter you want to apply.  The filter is immediately applied, unless input is required, and then it is applied after you input a value.<BR /><BR />
The display controls allow you to choose how the data is displayed.  Any selections are immediately applied.<BR /><BR />
The Filter and Display controls will have different options as you navigate through different tabs.  However, any selections you make on a tab will be preserved when you navigate back to a tab.
</div></div>
<div id="Help4Content" class="inpageHelpContent" title="Help"><div class="help-content">
<H3>Parental Expression</H3>
This tab has heat maps for the expression and fold difference between the Parental Strains(Rat BN-Lx/SHR or Mouse ILS/ISS).  To switch between the two heatmaps use the Display: Mean Values and Fold Difference options.<BR /><BR />
Use the buttons at the top left to control the size of the rows and columns.<BR /><BR />
The legend can be found next to the column and row size buttons and provides a reference for the range of the values displayed.<BR /><BR />
The Probeset IDs along the left side are color coded to match the UCSC genome browser graphic above.<BR /><BR />

</div></div>
<div id="Help5Content" class="inpageHelpContent" title="Help"><div class="help-content">
<H3>Heritability</H3>
Heritability is calculated from individual expression values in the panel of recombinant inbred rodents. The broad sense heritability is calculated from a 1-way ANOVA model comparing the within-strain variance to the between-strain variance. A higher heritability indicates more of the variance in expression and is determined by genetic factors rather than non-genetic factors in this particular RI panel. This tab allows you to view the heritability of unambiguous probesets.  For Affymetrix exon arrays, a probeset typically consist of 4 unique probes.  Prior to analysis, we eliminated (masked) individual probes if their sequence did not align uniquely to the genome or if the probe targeted a region of the genome that harbored a known single nucleotide polymorphism (SNP) between the two parental strains of the RI panel.  Entire probesets were eliminated if less than three probes within the probeset remained after masking.   Probes that target a region with a known SNP may indicate dramatic differences in expression when expression levels are similar but hybridization efficiency differ.
<BR /><BR />
If a probeset of interest is missing, adjust the filtering to allow additional probes (allow introns, opposite strand, make sure all other filters are unchecked, etc.) If it still does not display, it means that the probeset was masked and there is no heritability data because the probeset data would be inaccurate.

</div></div>

<div id="Help6Content" class="inpageHelpContent" title="Help"><div class="help-content">
<H3>Panel Expression</H3>
These are the normalized log transformed expression values.  This tab shows expression values for each probeset accross all strains in the panel.  Note: Because of the normalization, do not compare normalized values between different probesets, but you can compare them accross strains.  <BR /><BR />

There are three ways to view the data.  The default produces a separate graph for each probeset.  Notice the range and size varies with each probeset.  The size varies directly with the range of values so you can quickly scan for more variable or consistent probesets. <BR /><BR />

The next method, if you view probesets grouped into one graph by tissue, shows the variability by strain in a single graph.  This allows you to look for probesets that vary significantly between strains.   Do not compare expression between probesets along the X-axis because the normalization does not allow comparison of expression values between probesets.  <BR /><BR />

The last method displays probesets in a series accross strains.  Again, it is important that you do not use this to compare expression values between probesets.  The best way to compare expression is to use the Exon Correlation Tab.<BR /><BR />

Masking: Probesets have been masked because the sequence for the probe set does not match the strain of mice or rats and as a result, the data from the probe set would be misleading or inaccurate.  If a probeset of interest is missing, adjust the filtering to allow additional probes(allow introns, opposite strand, make sure all other filters are unchecked, etc.) If it still does not display it means that the probeset was masked and there is no heritability data because the probeset data would be inaccurate.

</div></div>
<div id="Help7Content" class="inpageHelpContent" title="Help"><div class="help-content">
<H3>Exon Correlation</H3>
This tab allows you to compare probeset expression, which should not be done directly in the expression tab.  This heatmap shows a selected transcript accross the top and draws exons that are represented by probesets along the top of the heatmap.  Exons that are excluded are color-coded to match the legend at the bottom of the page that shows why the exon was excluded from the heatmap.  Some exons may have multiple probesets representing them.<BR /><BR />

The heatmap is colored according to the correlation of one probeset to another across the strains in the panel.
</div></div>

<script type="text/javascript">
//Setup Help links
	$('.inpageHelpContent').hide();
	
	$('.inpageHelpContent').dialog({ 
  		autoOpen: false,
		dialogClass: "helpDialog",
		width: 400,
		maxHeight: 500,
		zIndex: 9999
	});

</script>




