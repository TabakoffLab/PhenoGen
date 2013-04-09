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

<div id="HelpProbeHeritContent" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>Heritablity</H3>
For each probe set on the Affymetrix Rat Exon 1.0 ST Array, we calculated a broad-sense heritability using an ANOVA model and expression data from the HXB/BXH panel.  The heritability threshold of 0.33 was chosen arbitrarily to represent an expression estimate with at least modest heritability. We include the number of probesets at least modestly heritable in the four available tissues (brain, heart, liver, and brown adipose).   Higher heritability indicates that expression of a probe set is influenced more by genetics than unknown environmental factors.
</div></div>

<div id="HelpProbeDABGContent" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>Detection Above Background(DABG)</H3>
For each probe set on the Affymetrix Rat Exon 1.0 ST Array and each sample, we calculated a p-value associated with the expression of the probe set above background (DABG – detection above background).  Using a p-value threshold of 0.0001, we calculated the proportion of samples from the HXB/BXH panel that had expression values significantly different from background for a given probeset.  In the table, we report the number of probesets whose expression values were detected above background in more than 1% of samples and the average percentage of samples where the probesets were detected above background.
</div></div>

<div id="HelpeQTLAffyContent" class="inpageHelpContent" title="<center>Help-Affy Exon Data</center>"><div class="help-content">
<H3>Affy Exon Data-eQTLs</H3>
The Affy Exon PhenoGen data displays data calculated from public datasets.  Data is from four datasets(one per tissue)Public HXB/BXH RI Rats (Tissue, Exon Arrays).
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