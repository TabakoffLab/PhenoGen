
    
<%if(myOrganism.equals("Mm")){%>
	<%@ include file="resultsHelpMm.jsp" %>
<%}else if(myOrganism.equals("Rn")){%>
	<%@ include file="resultsHelpRn.jsp" %>
<%}%>
    


<div id="HelpUCSCImageContent" class="inpageHelpContent" title="Help-UCSC Image"><div class="help-content">
<H3>UCSC Genome Browser Image</H3>
The image displayed below is generated by the UCSC Genome Browser with a mix of data aggregated from PhenoGen, UCSC Genome Browser, and Ensembl.<BR /><BR />
You may add tracks using the controls below.  All of the tracks are color coded based on their source and track or on the data itself.  Please see detailed descriptions of each track below or the legend for further details on the color coding and data contained in each track.
<BR />

</div></div>


<div id="HelpUCSCImageControlContent" class="inpageHelpContent" title="Help-Image Controls"><div class="help-content">
<H3>UCSC Image Controls</H3>
The controls in this section determine what information is included in the image above and tables below.
<BR /><BR />
Each track includes information about it.  Hold your mouse over the <img src="<%=imagesDir%>icons/info.gif"> icon to display additional information.
<BR /><BR />
Check the box next to the track you would like to include in the image.  The image should then be generated and appear shortly.  For some tracks, you may control the way the track is displayed.  You can change this by selecting the option next to the track.(ex.
             <select name="example" id="example">
            	<option value="1" selected="selected">Dense</option>
                <option value="3" >Pack</option>
                <option value="2" >Full</option>
            </select> )
<BR /><BR />
Dense-This is the most compressed view.  Generally with no labels for features and all features compressed into a single line of the display. <BR />
Pack-Fits multiple features per line such that features and their labels do not overlap.  <BR />
Full-Each entry in the track has a dedicated line of the display.  The label for each entry can be found at the far left.  Entries will be order from top to bottom in order of their occurrence from left to right.
<BR /><BR />
The best option depends on what you are looking for so try them and find what will work for you.
</div></div>


<div id="HelpeQTLContent" class="inpageHelpContent" title="Help-eQTLs"><div class="help-content">
<H3>eQTLs</H3>
<a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> are calculated for transcript clusters, which are approximately equivalent to a gene-level estimate of expression by combining multiple probesets that target the same gene.  The combination of probesets for each transcript cluster is defined by Affymetrix to include probesets that target regions that are included in all transcripts of a gene.
<BR /><BR />

Columns:<BR />
	Transcript Cluster ID- The unique ID assigned by Affymetrix.  <BR />
	Location-The chromosomes and base-pair coordinates where the gene is located. <BR />
	Annotation level- Related to the confidence in the gene.  Core is the highest confidence.  This level tends to correspond very closely with the Ensembl gene annotation. Extended is lower confidence and may include additional regions outside of the Ensembl annotated exons.  Full is even lower confidence and includes additional regions beyond the Ensembl annotations.<BR />
	Genome Wide Associations- A way to view all the locations with a P-value below the cutoff selected.  Circos is used to create a plot of each region in each tissue associated with expression of the gene selected.<BR />
<BR />
Tissue Columns<BR />
	These columns summarize the data for each tissue.<BR />
	Total # of locations with a P-value < (Selected Cutoff)- The number of locations associated with expression below a cutoff selected in the Filter List section above the table.<BR />
	Minimum P-Value Location- The P-value and location of the minimum P-Value for the given tissue.  P-Value is in black, above the location in blue.  Click the location to open a Detailed Transcription Information window for that location.<BR />

</div></div>

<div id="HelpbQTLInRegionContent" class="inpageHelpContent" title="Help-bQTL Tab"><div class="help-content">
<H3><a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTL</a> Tab</H3>
	The <a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTL</a> tab allows you to view <a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTLs</a> that overlap with the region.  <BR /><BR />
What is a bQTL?(<a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">View detailed bQTL information</a>) 
	A Behavioral Quantitative Trait Loci or bQTL is a region that is associated with a particular phenotype or behavior (thus <a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTL</a>).  <BR /><BR />
How is it calculated?
	<a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTLs</a> can be found for Recombinant Inbred Panels by measuring a trait/behavior across strains in the panel and then correlating the values to the genotype of each strain between markers.  Based on that correlation regions can be found that are correlated with a particular phenotype.  These are the regions listed in the table under this tab.  They may indicate that a gene or other feature is somehow influencing the phenotype.

</div></div>


<div id="HelpeQTLTabContent" class="inpageHelpContent" title="Help"><div class="help-content">
<H3>eQTL Tab</H3>
This tab shows the genes that might be controlled by a feature in the chosen region.  There is at least an <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> with a P-value below the cutoff in the highlighted(Blue) for the selected region in one or more tissues.  However, the actual region may just overlap with the current region, so the <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> region associated with the P-value may be a different than the current region. 
<BR />
The Circos plot shows where the genes with <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> in this region are physically located.  
<BR />
The table below the Circos plot lists all the genes and <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> for each gene in each tissue.  Use the View Location Plot link to view all the <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> for a gene in a Circos plot that shows each <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> for the selected gene.
<BR />
Finally, to view detailed transcript and probe set data, click on a Gene Symbol to display a summary specific to that gene.
<BR /><BR />
What is an eQTL? (<a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">View detailed eQTL information</a>)   
An eQTL is a region that is correlated across recombinant inbred strains to expression of a gene(or in the case of our Affy data displayed, Transcript Cluster) or probe set.  This may indicate some feature in this region is influencing expression of the gene with a significant <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> in the region.
<BR /><BR />
How is it calculated? 
<a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> can be found for Recombinant Inbred Panels by measuring expression across strains in the panel and then correlating the values to the genotype of each strain between markers.  Based on that correlation, regions can be found that are correlated with expression.   In the table, the region overlaps with one of the regions that is assigned a P-value below the cutoff you selected.  This may indicate that a gene or other feature in this region, or one of the other regions with a significant P-value, is somehow influencing the expression of the gene.
<BR /><BR />
What does an <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> for a transcript cluster mean? 
At the transcript cluster level, this is an <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> for a gene and not individual probe sets.  For now, this is the only level available.

</div></div>

<div id="HelpForwardeQTLTabContent" class="inpageHelpContent" title="Help"><div class="help-content">
<H3>eQTL Tab</H3>
This tab shows a Circos Plot of the <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> associated with the selected Transcript Cluster(Gene).  The lines connect from the location of the gene to the region/SNP associated with expression of the gene.  Each tissue contains yellow/black lines that indicate the P-value of that association.  Yellow indicates the P-value is below the selected threshold.  The controls available under this tab let you select the p-value, chromosomes, and tissues(if applicable) to include in the image.
</div></div>


<div id="HelpRevCircosContent" class="inpageHelpContent" title="Help-Circos eQTL Plot"><div class="help-content">
<H3>Circos Plot eQTL Gene Locations</H3>
This plot shows all of the genes that have an <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> in the region entered.  These genes correspond to the genes listed in the table below.  If a higher number of genes are located in nearly the same region only the first 2-3 may be displayed.
<BR /><BR />
The plot can be hidden using the +/- button.  The size of the plot can also be controlled using the Adjust Vertical Viewable Size drop down list.
<BR /><BR />
When your mouse is inside the border below, you can zoom in/out on the plot.  When your mouse is outside the border you can scroll normally.  The controls inside the image can be used to zoom in and out and reset the image.  You can also click-and-drag to reposition the image.
<BR /><BR />
You can download a PDF of the image by clicking on the download icon(<img src="web/images/icons/download_g.png">).
</div></div>


<div id="HelpDAVIDContent" class="inpageHelpContent" title="Help">
<div class="help-content">
<H3>DAVID</H3>
A list of genes can be imported into the <a href="http://david.abcc.ncifcrf.gov/" target="_blank">DAVID web site</a> for additional information about function and also to look for a significant enrichment in pathways, which might imply some biological meaning.  The link, when available, will open the summary page where you can explore the different DAVID tools.
<BR /><BR />
Currently only lists of 300 genes are less are supported.  This is a limit of the method used to submit genes to the DAVID web site.  We will either be replacing the site or supporting a different method to allow longer lists.  If you perform filtering to get the list below 300 you will be able to click a link and immediately analyze data on the site, Otherwise you can copy one of the ID columns such as Gene IDs(Ensembl IDs) and submit them on your own.
</div>
</div>



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
The Probe set IDs along the left side are color coded to match the UCSC genome browser graphic above.<BR /><BR />

</div></div>
<div id="Help5Content" class="inpageHelpContent" title="Help"><div class="help-content">
<H3>Heritability</H3>
Heritability is calculated from individual expression values in the panel of recombinant inbred rodents. The broad sense heritability is calculated from a 1-way ANOVA model comparing the within-strain variance to the between-strain variance. A higher heritability indicates more of the variance in expression and is determined by genetic factors rather than non-genetic factors in this particular RI panel. This tab allows you to view the heritability of unambiguous probe sets.  For Affymetrix exon arrays, a probe set typically consist of 4 unique probes.  Prior to analysis, we eliminated (masked) individual probes if their sequence did not align uniquely to the genome or if the probe targeted a region of the genome that harbored a known single nucleotide polymorphism (SNP) between the two parental strains of the RI panel.  Entire probe sets were eliminated if less than three probes within the probe set remained after masking.   Probes that target a region with a known SNP may indicate dramatic differences in expression when expression levels are similar but hybridization efficiency differ.
<BR /><BR />
If a probe set of interest is missing, adjust the filtering to allow additional probes (allow introns, opposite strand, make sure all other filters are unchecked, etc.) If it still does not display, it means that the probe set was masked and there is no heritability data because the probe set data would be inaccurate.

</div>
</div>

<div id="Help6Content" class="inpageHelpContent" title="Help"><div class="help-content">
<H3>Panel Expression</H3>
These are the normalized log transformed expression values.  This tab shows expression values for each probe set across all strains in the panel.  Note: Because of the normalization, do not compare normalized values between different probe sets, but you can compare them across strains.  <BR /><BR />

There are three ways to view the data.  The default produces a separate graph for each probe set.  Notice the range and size varies with each probe set.  The size varies directly with the range of values so you can quickly scan for more variable or consistent probe sets. <BR /><BR />

The next method, if you view probe sets grouped into one graph by tissue, shows the variability by strain in a single graph.  This allows you to look for probe sets that vary significantly between strains.   Do not compare expression between probe sets along the X-axis because the normalization does not allow comparison of expression values between probe sets.  <BR /><BR />

The last method displays probe sets in a series across strains.  Again, it is important that you do not use this to compare expression values between probe sets.  The best way to compare expression is to use the Exon Correlation Tab.<BR /><BR />

Masking: Probe sets have been masked because the sequence for the probe set does not match the strain of mice or rats and as a result, the data from the probe set would be misleading or inaccurate.  If a probe set of interest is missing, adjust the filtering to allow additional probes(allow introns, opposite strand, make sure all other filters are unchecked, etc.) If it still does not display it means that the probe set was masked and there is no heritability data because the probe set data would be inaccurate.

</div>
</div>
<div id="Help7Content" class="inpageHelpContent" title="Help"><div class="help-content">
<H3>Exon Correlation</H3>
This tab allows you to compare probe set expression, which should not be done directly in the expression tab.  This heatmap shows a selected transcript across the top and draws exons that are represented by probe sets along the top of the heatmap.  Exons that are excluded are color-coded to match the legend at the bottom of the page that shows why the exon was excluded from the heatmap.  Some exons may have multiple probe sets representing them.<BR /><BR />

The heatmap is colored according to the correlation of one probe set to another across the strains in the panel.
</div>
</div>


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