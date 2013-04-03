<div id="HelpAffyExonContent" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>Affy Exon Data Columns</H3>
The Affy Exon PhenoGen data displays data calculated from public datasets. Data is from 4 datasets(one per tissue)Public HXB/BXH RI Rats (Tissue, Exon Arrays)<BR /><BR />

These datasets are available for analysis or downloading.  To perform an analysis on PhenoGen go to Mircoarray Analysis Tools -> Analyze precompiled datasets. A free login is required, which allows you to save your progress and come back after lengthy processing steps.  <BR /><BR />

Columns:<BR />
<ul style="padding-left:25px; list-style-type:square;">
	<li>Total number of non-masked probe sets</li><BR /> 
	<li>Number with a heritability of >0.33 (Avg heritability for probesets >0.33)</li><BR />
	<li>Number detected above background (DABG) (Avg % of samples DABG)</li><BR />
	<li>Transcript Cluster ID corresponding to the gene with Annotation level</li><BR />
	<li>Circos Plot to show all <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> across tissues.</li><BR />
	<li>eQTL for the transcript cluster in each tissue</li>
    	<ul style="padding-left:35px; list-style-type:disc;">
    	<li>minimum P-value and location</li>
		<li>total locations with a P-value < cut-off</li>
        </ul>
        </li>
</ul>

</div></div>

<div id="HelpGenesInRegionContent" class="inpageHelpContent" title="<center>Help-Gene in Region Tab</center>"><div class="help-content">
<H3>Features Physically Located in Region Tab</H3>
This tab will display all the Ensembl features located in the chosen region, as well as any RNA-Seq features that do not correspond to an Ensembl gene.<BR /><BR />

Data Summary:<BR /><BR />
<ol style=" list-style-type:decimal; padding-left:25px;">

<li>Gene Information(Ensembl ID, Gene Symbol, Location, description, # transcripts, # transcripts from RNA-Seq, links to databases)</li>
<li>A description of how RNA-Seq transcripts match to annotated transcripts.</li>
<li>SNPs/Indels present in the recombinant inbred panel parental strains that fall in an exon of at least one annotated transcript exon or a generated(RNA-Seq) exon.</li>   
<li>Probe Set detail (# Probe Sets, # whose expression is heritable(allows you to focus on expression differences controlled by genetics),# detected above background(DABG),(Avg % of samples DABG).</li>
<li>Transcript Cluster Expression Quantitative Trait Loci (at the gene level)\   At the gene level, this indicates regions of the genome that are statistically associated with expression of the gene.  The table displays the p-value and location with the minimum p-value for each tissue available.  Click the view location plot link to view all of the locations across tissues.
</li>
</ol>
</div></div>







<div id="Help5cContent" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>Heritablity</H3>
For each probe set on the Affymetrix Exon 1.0 ST Array (mouse or rat), we calculated a broad-sense heritability using an ANOVA model and expression data from the ILSXISS panel (mouse) or the HXB/BXH panel (rat).  The heritability threshold of 0.33 was chosen arbitrarily to represent an expression estimate with at least modest heritability. In the rat, we include the number of probesets at least modestly heritable in the four available tissues (brain, heart, liver, and brown adipose).   Higher heritability indicates that expression of a probe set is influenced more by genetics than unknown environmental factors.
</div></div>

<div id="Help5dContent" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>Detection Above Background(DABG)</H3>
For each probe set on the Affymetrix Exon 1.0 ST Array (mouse or rat) and each sample, we calculated a p-value associated with the expression of the probe set above background (DABG – detection above background).  Using a p-value threshold of 0.0001, we calculated the proportion of samples from the ILSXISS panel (mouse) or HXB/BXH panel (rat) that had expression values significantly different from background for a given probeset.  In the table, we report the number of probesets whose expression values were detected above background in more than 1% of samples and the average percentage of samples where the probesets were detected above background.
</div></div>

<div id="Help5eContent" class="inpageHelpContent" title="<center>Help-eQTLs</center>"><div class="help-content">
<H3>eQTLs</H3>
The eQTL columns provide a general idea of where a gene, in the region you have entered, is controlled from.  Currently, <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> are currently only available at the gene (transcript cluster) level instead of the probe set level, which means the first columns give you information about the transcript cluster.  <BR /><BR />

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


<div id="Help6Content" class="inpageHelpContent" title="<center>Help-Filter/Display-bQTLs</center>"><div class="help-content">
<H3>Filter List/View Columns</H3>
For this section you may only filter based on text in the table.  To search for a keyword, start typing, and results are filtered based on your entry.<BR />
For the View Columns section you may choose which columns are displayed.<BR /><BR />The options to view/hide are:<BR />
<ul style=" padding-left:25px; list-style-type:square;">
	<li><a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTL</a> Symbol-Looks much like a gene symbol, but has been assigned to a bQTL by RGD or MGI.</li>
	<li>Trait Method-A description of the method used to measure a particular phenotype.</li>
	<li>Phenotype- A description or phrase to describe the characteristics measured.</li>
	<li>Diseases-Diseases associated with the phenotype.</li>
	<li>References-Both Pubmed and RGD/MGI-curated references related to the <a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTL</a>.</li>
	<li>Associated bQTLs-<a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTLs</a> that are related to the displayed <a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTL</a>.</li>
	<li>Location Method-A brief description of the method used to determine the location of the <a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTL</a>.</li>
    	<ul style="padding-left:35px; list-style-type:disc;">
			<li> by peak only</li>
			<li> by peak w adj size</li>
			<li> by one flank and peak markers</li>
			<li> by one flank marker only</li>
			<li> by flanking markers</li>
			<li> imported from external source</li>
        </ul>
    </li>
	<li>LOD Score/P-value-When available(many are not reported directly by RGD/MGI) indicates the level of confidence the region contributes to the Phenotype.  Higher LOD Scores/Lower P-values indicate higher confidence in the association.</li>
</ul>

</div></div>

<div id="Help7Content" class="inpageHelpContent" title="<center>Help-bQTL Tab</center>"><div class="help-content">
<H3><a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTL</a> Tab</H3>
	The <a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTL</a> tab allows you to view <a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTLs</a> that overlap with the region.  <BR /><BR />
What is a bQTL?(<a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">View detailed bQTL information</a>) 
	A Behavioral Quantitative Trait Loci or bQTL is a region that is associated with a particular phenotype or behavior (thus <a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTL</a>).  <BR /><BR />
How is it calculated?
	<a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTLs</a> can be found for Recombinant Inbred Panels by measuring a trait/behavior across strains in the panel and then correlating the values to the genotype of each strain between markers.  Based on that correlation regions can be found that are correlated with a particular phenotype.  These are the regions listed in the table under this tab.  They may indicate that a gene or other feature is somehow influencing the phenotype.

</div></div>

<div id="Help8Content" class="inpageHelpContent" title="<center>Help-Region Determination Method</center>"><div class="help-content">
<H3>Region Determination Method</H3>
This column is the method used to determine the location.<BR />
	- by peak only<BR />
	- by peak w adj size<BR />
	- by one flank and peak markers<BR />
	- by one flank marker only<BR />
	- by flanking markers<BR />
	- imported from external source<BR />
</div></div>

<div id="Help9Content" class="inpageHelpContent" title="<center>Help-Filter/View Columns-eQTLs</center>"><div class="help-content">
<H3>Filter Circos Plot and Table/View Columns</H3><BR />
Filter Circos Plot/Table<BR />
You may filter the Ciros plot and table by tissues, <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> P-value, and chromosome.  Change the parameters by which you want to filter and click Run Filter.<BR />
<ul style=" padding-left:25px; list-style-type:square;">
	<li>eQTL P-value- The cutoff to limit genes displayed to those that have a P-value for the selected region less than, or equal to, the cutoff.</li>
	<li>Tissues(Rat Only)- Move tissues to the excluded column to keep only genes that have significant <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> in one of the included tissues.</li>
	<li>Chromosomes- Move chromosomes to exclude into the Exclude column to filter out genes that are located on that chromosome.</li>
</ul>
<BR /><BR />
View Columns<BR />
Use the checkboxes below View Columns to show and hide columns.<br />
<ul style="padding-left:25px; list-style-type:square;">
	<li>Gene ID- The Ensembl gene ID that links directly to Ensembl.</li>
	<li>Description- The Ensembl description of the gene.</li>
	<li>Transcript ID and Annot.- The Transcript Cluster ID and Annotation Level, which is the Affymetrix transcript cluster that corresponds to the gene and the level of confidence.</li>.
	<li>All Tissues P-values- Controls the P-values from the region column, across tissues.</li>
	<li>All Tissues # Locations- Controls the # other locations column across all tissues.</li>
	<li>Specific Tissues- Controls both columns for a specific tissue.</li>
</ul>

</div></div>

<div id="Help10Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>eQTL Tab</H3>
This tab shows the genes that might be controlled by a feature in the choosen region.  There is at least an <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> with a P-value below the cutoff in the highlighted(Blue) for the selected region in one or more tissues.  However, the actual region may just overlap with the current region, so the <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> region associated with the P-value may be a different than the current region. 
<BR />
The Circos plot shows where the genes with <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> in this region are physically located.  
<BR />
The table below the Circos plot lists all the genes and <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> for each gene in each tissue.  Use the View Location Plot link to view all the <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> for a gene in a Circos plot that shows each <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> for the selected gene.
<BR />
Finally, to view detailed transcript and probe set data, click on a Gene Symbol to display a summary specific to that gene.
<BR /><BR />
What is an eQTL? (<a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">View detailed eQTL information</a>)   
An eQTL is a region that is correlated across recombinant inbred strains to expression of a gene(or in the case of our Affy data displayed, Transcript Cluster) or probeset.  This may indicate some feature in this region is influencing expression of the gene with a significant <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> in the region.
<BR /><BR />
How is it calculated? 
<a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> can be found for Recombinant Inbred Panels by measuring expression across strains in the panel and then correlating the values to the genotype of each strain between markers.  Based on that correlation, regions can be found that are correlated with expression.   In the table, the region overlaps with one of the regions that is assigned a P-value below the cutoff you selected.  This may indicate that a gene or other feature in this region, or one of the other regions with a significant P-value, is somehow influencing the expression of the gene.
<BR /><BR />
What does an <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> for a transcript cluster mean? 
At the transcript cluster level, this is an <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> for a gene and not individual probe sets.  For now, this is the only level available.

</div></div>

<div id="Help11Content" class="inpageHelpContent" title="<center>Help-Circos eQTL Plot</center>"><div class="help-content">
<H3>Circos Plot eQTL Gene Locations</H3>
This plot shows all of the genes that have an <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> in the region entered.  These genes correspond to the genes listed in the table below.  If a higher number of genes are located in nearly the same region only the first 2-3 may be displayed.
<BR /><BR />
The plot can be hidden using the +/- button.  The size of the plot can also be controlled using the button next to the directions.
<BR /><BR />
When your mouse is inside the border below, you can zoom in/out on the plot.  When your mouse is outside the border you can scroll normally.  The controls inside the image can be used to zoom in and out and reset the image.  You can also click-and-drag to reposition the image.
<BR /><BR />
You can download a PDF of the image by clicking on the download icon(<img src="web/images/icons/download_g.png">).
<BR /><BR />
You can reduce or restore the verticle space used for the graphic by clicking on the <img src="web/images/icons/circos_min.jpg"> or <img src="web/images/icons/circos_max.jpg"> icons.
</div></div>

<div id="Help12aContent" class="inpageHelpContent" title="<center>Help-Transcript Cluster ID</center>"><div class="help-content">
<H3>Transcript Cluster ID</H3>
Transcript Cluster ID- The unique ID assigned by Affymetrix.  <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> are calculated for this annotation at the gene level by combining probe set data across the gene.
</div></div>


<div id="Help12bContent" class="inpageHelpContent" title="<center>Help-Annotation Level</center>"><div class="help-content">
<H3>Annotation level</H3>
Annotation level- Related to the confidence in the gene.  Core is the highest confidence and tends to correspond very closely with the Ensembl gene annotation. Extended is lower confidence and may include additional regions outside of the Ensembl annotated exons.  Full is even lower and includes additional regions beyond the Ensembl annotations.
</div></div>

<div id="Help12cContent" class="inpageHelpContent" title="<center>Help-Affy Exon Data</center>"><div class="help-content">
<H3>Affy Exon Data-eQTLs</H3>
The Affy Exon PhenoGen data displays data calculated from public datasets.  For mouse, data is from the Public ILSXISS RI Mice
For rat, data is from four datasets(one per tissue)Public HXB/BXH RI Rats (Tissue, Exon Arrays).
<BR /><BR />
These datasets are available for analysis or downloading.  To perform an analysis on PhenoGen go to Mircoarray Analysis Tools -> Analyze precompiled datasets.  A free login is required, which allows you to save your progress and come back after lengthy processing steps.  
<BR /><BR />
Columns:<BR />
<ul style="list-style-type:square; padding-left:25px;">
	<li>Transcript Cluster ID- The unique Affymetrix-assigned id that corresponds to a gene. </li>
	<li>Annotation Level- Confidence in the transcript cluster annotation</li>
	<li>Circos Plot- Shows all <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> for a specific gene across tissues.</li>
	<li><a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> for the transcript cluster in each tissue</li>
		<ul style="list-style-type:disc; padding-left:35px;">
		<li>P-value from this region</li>
		<li>total other locations with a P-value < cut-off</li>
        </ul>
</ul>
</div></div>

<div id="Help13Content" class="inpageHelpContent" title="<center>Help</center>">
<div class="help-content">
<H3>Human Chromosome Color Key</H3>
The human/Net and Human/Chain tracks displayed indicate which chromosome in Humans maps to a particular colored region in the image.  This will only help to identify the chromosome where a gene that aligns to a particular color might reside.  In Mouse this also adds Human proteins that are homologous to the proteins in this region and by comparing the human homologs to the alignment track it is possible to see the chromosome that gene is on.  To better be able to zoom and manipulate the image you may always click on the image to open the UCSC Genome Browser which will enable you to zoom in/out and shift the region more easily to look at a gene/region of interest.
</div></div>

<div id="Help14Content" class="inpageHelpContent" title="<center>Help</center>">
<div class="help-content">
<H3>DAVID</H3>
A list of genes can be imported into the DAVID website for additional information about function and also to look for a significant enrichment in pathways, which might imply some biological meaning.  The link, when available, will open the summany page where you can explore the different DAVID tools.
<BR /><BR />
Currently only lists of 300 genes are less are supported.  This is a limit of the method used to submit genes to the DAVID website.  We will either be replacing the site or supporting a different method to allow longer lists.  If you perform filtering to get the list below 300 you will be able to click a link and immediately analyze data on the site, Otherwise you can copy one of the ID columns such as Gene IDs(Ensembl IDs) and submit them on your own.
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