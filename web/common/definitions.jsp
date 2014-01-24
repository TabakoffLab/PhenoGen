<%--
 *  Author: Spencer Mahaffey
 *  Created: November, 2012
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/access/include/login_vars.jsp" %>

<%	extrasList.add("normalize.css");
	extrasList.add("index.css"); %>
<%pageTitle="Definitions";%>

<%@ include file="/web/common/header_noMenu.jsp" %>
<a name="top"></a>
<H2>Overviews of concepts</H2>
<ul style="padding-left:20px; list-style-type:disc;">
    <li><a href="#eQTLs">eQTLs</a></li>
    <li><a href="#bQTLs">bQTLs</a></li>
    <li><a href="#heritability">Heritability</a></li>
    <li><a href="#recInbredPanel">Recombinant Inbred Panel</a></li>
</ul>

<BR /><BR />
<span class="button" onclick="window.close()" style="width:150px;">Close this Window</span><BR /><BR />

<a name="eQTLs"><H2>eQTLs</H2></a>
<div style="padding-left:20px; margin-left:10px;">
An eQTL(expression Quantitative Trait Loci) is a region that is correlated with expression of a particular gene(transcript cluster) or probe set.  This can either be in the same region as the gene, which is a cis-eQTL or it can be much further away on the same chromosome or a separate chromosome, which is a trans-eQTL.  
For the recombinant inbred panels the eQTL is calculated for the gene/probe set across the RI strains.  This results in a region between markers with the same calculated p-values being defined as an eQTL for the gene.  In some instances no markers were close enough to a significant marker so the region is just the single marker, but this indicates we can't define a more exact region not that the SNP is responsible for the eQTL.  There may be multiple locations, in most instances throughout the site you have the option to filter based on the p-value so only the most significant location(s) is shown.  You can view the eQTLs for a specific gene through both the Gene and Region Detailed Transcription Information views.  The gene view will allow you to view just the location of eQTLs for the gene.  The region view will show the most significant eQTL in each tissue, for which data is available, or you may view a circos plot of all the eQTLs below a user set threshold.
<BR /><BR />
<a href="#top">Back to Top</a><BR /><BR />
<span class="button" onclick="window.close()" style="width:150px;">Close this Window</span><BR /><BR /><BR />
</div>

<a name="bQTLs"><H2>bQTLs</H2></a>
<div style="padding-left:20px; margin-left:10px;">
Behavoiral Quantitative Trait Loci are regions that correlate to a continuous phenotype.  A bQTL indicates a region that contains a genetic element that may contribute to the phenotype and allows you to narrow your search for the gene(s) responsible for a given trait.
Many of these have been published and can be explored for a region of interest in the Detailed Transcription Information section.  If you have data for strains, which we have array data for you may create a login and import the phenotype data and calculate bQTLs and use the Detailed Transcription Information tool to explore expression and control of expression for genes in the region.
<BR /><BR />
<a href="#top">Back to Top</a><BR /><BR />
<span class="button" onclick="window.close()" style="width:150px;">Close this Window</span><BR /><BR /><BR />
</div>
<a name="heritability"><H2>Heritability</H2></a>
<div style="padding-left:20px; margin-left:10px;">
Heritability indicates at either the probe set or transcript cluster (Gene) level which of these have a high genetic heritability.  
The lower the heritability value the more environmental influence on expression is high compared to the
strict genetic influence.  This allows sorting and filtering based on heritability to look for probe sets and transcript clusters 
with high heritability and thus are more likely controlled by a genetic component, that may reside in an eQTL 
region which you may explore further in the Detailed Transcription Information section.<BR /><BR />

How is heritability calculated?<BR />
The broad sense heritability is calculated for each probe set/transcript clusters separately using an ANOVA
model.
<BR /><BR />
For analyses on the Affymetrix Mouse 430 version 2 array, the broad sense heritability
has been calculated on the public inbred mouse panel (20 strains) normalized using RMA with poor quality
probes eliminated prior to normalization and the public BXD recombinant inbred mouse panel (32 strains) normalized
using RMA with poor quality probe eliminated prior to normalization.
<BR /><BR />
For analyses on the Affymetrix Mouse Exon array, the broad sense heritability has been calculated on the
core transcript clusters from the public LXS brain recombinant inbred mouse panel normalized using RMA
with poor quality probes eliminated prior to normalization. 
<BR /><BR />
For analyses on the Affymetrix Rat Exon array, the
user must choose the tissue of interest (brain, heart, liver, or brown adipose tissue). The broad sense heritability
has been calculated separately for each tissue on the core transcript clusters from the public
HXB/BXH recombinant inbred rat panel normalized using RMA with poor quality probes eliminated prior to normalization.


<BR /><BR />
<a href="#top">Back to Top</a><BR /><BR />
<span class="button" onclick="window.close()" style="width:150px;">Close this Window</span><BR /><BR /><BR />
</div>
<a name="recInbredPanel"><H2>Recombinant Inbred Panel</H2></a>

<div>
    <table >
    	<tr>
        	<TD style="color: #666666;font-family: Arial,Verdana,sans-serif;font-size: 14px;">
        How are recombinant inbred panels generated?
        <BR /><BR />
            <div style="padding-left:20px; margin-left:10px;">
            The panels are started by crossing two inbred strains.  Then crossing the siblings(F1) to create a population of heterozygous animals(F2).  By continuously breeding(20+ generations) the siblings for each branch of the F2 generation you can get multiple strains of homozygous animals.  This results in a panel of homozygous animals with different genomes(some combination of the parental strains) as a result of different recombination events in the previous generations.  For many of the panels SNPs associated with each parent have been identified and each strain has been genotyped to provide information about what sections of their genome correspond to which parent.  This information can then be correlated with phenotypes to provide insight into regions of the genome that contribute to a particular trait(behavioral(bQTLs) or expression of a gene or probe set (eQTLs).  This is primarily what PhenoGen can be used to investigate using Arrays and for some organisms/datasets RNA-Sequencing.
            </div>
        <BR /><BR />
        What is the benefit?
            <div style="padding-left:20px; margin-left:10px;">
            These strains are available so phenotypic or behavioral data collected elsewhere may be correlated to data on PhenoGen.  For example the BXH/HXB panels and ILSXISS panels have different alcohol consumption preferences.  If you collected your own data on these strains you can import the mean and variance for each strain and calculate bQTLs, which would indicate regions of the genome correlated with a preference or aversion to alcohol consumption.  You can also investigate regions that are correlated with expression of a gene or probe set, which can let you look for elements that control expression or even alternate splicing(when looking at control at the probe set level).
            </div>
        <BR /><BR />
        How can you use data from these panels on PhenoGen?
        <BR /><BR />
            <div style="padding-left:20px; margin-left:10px;">
            Phenogen includes a number of tools to let you take advantage of data collected on recombinant inbred panels.
            
            Calculate regions associated with a phenotype (find regions/genes that may be responsible for a particular phenotype)
            Calculate regions responsible for control of expression(find regions/genes/elements that may be responsible for expression at the gene or probe set level)
            Analyze Expression (look at gene expression in different tissues and variance across multiple strains)
            </div>
    	</TD>
        <TD>	
    		<img src="<%=imagesDir%>ripanel.jpg" style="display:inline-block;"/>
       </TD>
       </tr>
       </table>

</div>
<BR /><BR />
Additional Resources:<BR />
<a href="http://www.jax.org/smsr/ristrain.html">Jackson Lab-http://www.jax.org/smsr/ristrain.html</a><BR />
<a href="http://en.wikipedia.org/wiki/Recombinant_inbred_strain">Wikipedia-http://en.wikipedia.org/wiki/Recombinant_inbred_strain</a><BR />
<a href="http://www.ncbi.nlm.nih.gov/pubmed/17698925">Pubmed-"Recombinant inbred strain panels: a tool for systems genetics", Curchill GA, Physiol Genomics. 2007 Oct 22;31(2):174-5.</a><BR />
 


<BR /><BR />
<a href="#top">Back to Top</a><BR /><BR />
<span class="button" onclick="window.close()" style="width:150px;">Close this Window</span><BR /><BR /><BR />
<%@ include file="/web/common/footer.jsp" %>
