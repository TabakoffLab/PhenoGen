<div id="HelpAffyExonContent" class="inpageHelpContent" title="Help"><div class="help-content">
<H3>Affy Exon Data Columns</H3>
The Affy Exon PhenoGen data displays data calculated from public datasets.  Data is from the Public ILSXISS RI Mice.<BR /><BR />

This dataset is available for analysis or downloading.  To perform an analysis on PhenoGen go to Microarray Analysis Tools -> Analyze precompiled datasets. A free login is required, which allows you to save your progress and come back after lengthy processing steps.  <BR /><BR />

Columns:<BR />
<ul style="padding-left:25px; list-style-type:square;">
	<li>Total number of non-masked probe sets</li><BR /> 
	<li>Number with a heritability of >0.33 (Avg heritability for probe sets >0.33)</li><BR />
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


<div id="HelpGenesInRegionContent" class="inpageHelpContent" title="Help-Gene in Region Tab"><div class="help-content">
<H3>Features Physically Located in Region Tab</H3>
This tab will display all the Ensembl features located in the chosen region.<BR /><BR />

Data Summary:<BR /><BR />
<ol style=" list-style-type:decimal; padding-left:25px;">

<li>Gene Information(Ensembl ID, Gene Symbol, Location, description, # transcripts, links to databases)</li> 
<li>Probe Set detail (# Probe Sets, # whose expression is heritable(allows you to focus on expression differences controlled by genetics),# detected above background(DABG),(Avg % of samples DABG).</li>
<li>Transcript Cluster Expression Quantitative Trait Loci (at the gene level)\   At the gene level, this indicates regions of the genome that are statistically associated with expression of the gene.  The table displays the p-value and location with the minimum p-value for each tissue available.  Click the view location plot link to view all of the locations across tissues.
</li>
</ol>
</div></div>


<div id="HelpProbeHeritContent" class="inpageHelpContent" title="Help"><div class="help-content">
<H3>Heritability</H3>
For each probe set on the Affymetrix Mouse Exon 1.0 ST Array, we calculated a broad-sense heritability using an ANOVA model and expression data from the ILSXISS panel.  The heritability threshold of 0.33 was chosen arbitrarily to represent an expression estimate with at least modest heritability.  Higher heritability indicates that expression of a probe set is influenced more by genetics than unknown environmental factors.
</div></div>

<div id="HelpProbeDABGContent" class="inpageHelpContent" title="Help"><div class="help-content">
<H3>Detection Above Background(DABG)</H3>
For each probe set on the Affymetrix Mouse Exon 1.0 ST Array and each sample, we calculated a p-value associated with the expression of the probe set above background (DABG – detection above background).  Using a p-value threshold of 0.0001, we calculated the proportion of samples from the ILSXISS panel that had expression values significantly different from background for a given probe set.  In the table, we report the number of probe sets whose expression values were detected above background in more than 1% of samples and the average percentage of samples where the probe sets were detected above background.
</div>
</div>


<div id="HelpeQTLAffyContent" class="inpageHelpContent" title="Help-Affy Exon Data"><div class="help-content">
<H3>Affy Exon Data-eQTLs</H3>
The Affy Exon PhenoGen data displays data calculated from public datasets.  Data is from the Public ILSXISS RI Mice
<BR /><BR />
These datasets are available for analysis or downloading.  To perform an analysis on PhenoGen go to Microarray Analysis Tools -> Analyze precompiled datasets.  A free login is required, which allows you to save your progress and come back after lengthy processing steps.  
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


<div id="HelpAffyJavaDataContent" class="inpageHelpContent" title="Help-Affy Exon Data"><div class="help-content">
<H3>Affy Exon Data-eQTLs</H3>

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