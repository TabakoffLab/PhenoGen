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

<%
	extrasList.add("index.css"); %>
<%pageTitle="Definitions";%>

<%@ include file="/web/common/header_noMenu.jsp" %>
<a name="top"></a>
<ul>
    <li><a href="#eQTLs">eQTLs</a></li>
    <li><a href="#bQTLs">bQTLs</a></li>
    <li><a href="#heritability">Heritability</a></li>
    <li><a href="#recInbredPanel">Recombinant Inbred Panel</a></li>
</ul>

<BR /><BR />

<a name="eQTLs"><H2>eQTLs</H2></a>
An eQTL(expression Quantitative Trait Loci) is a region that is correlated with expression of a particular gene(transcript cluster) or probeset.  This can either be in the same region as the gene which is a cis-eQTL or it can be much further away on the same chromosome or a separate chromosome which is a trans-eQTL.  

For the recombinant inbred panels the eQTL is calculated for the gene/probeset across the RI strains.  This results in a region between markers with the same calculated p-values being defined as an eQTL for the gene.  In some instances no markers were close enough to a significant marker so the region is just the single marker, but this indicates we can't define a more exact region not that the SNP is responsible for the eQTL.  There may be multiple locations, in most instances throughout the site you have the option to filter based on the p-value so only the most significant location(s) is shown.  You can view the eQTLs for a specific gene through both the Gene and Region Detailed Transcription Information views.  The gene view will allow you to view just the location of eQTLs for the gene.  The region view will show the most significant eQTL in each tissue, for which data is available, or you may view a circos plot of all the eQTLs below a user set threshold. 
<BR />
<a href="#top">Back to Top</a><BR /><span class="button" onclick="window.close()" style="width:150px;">Close this Window</span><BR />
<a name="bQTLs"><H2>bQTLs</H2></a>
Behavoiral Quantitative Trait Loci are regions that correlate to a continuous phenotype.  This indcates a region that contains a genetic element that may contribute to the phenotype and allows you to narrow your search for the gene(s) responsible for a given trait.

Many of these have been published and can be explored for a region of interest in the Detailed Transcription Information section.  If you have data for strains which we have array data for you may create a login and import the phenotype data and calculate bQTLs and use the Detailed Transcription Information tool to explore expression and control of expression for genes in the region.
<BR />
<a href="#top">Back to Top</a><BR /><span class="button" onclick="window.close()" style="width:150px;">Close this Window</span><BR />
<a name="heritability"><H2>Heritability</H2></a>
Heritability indicates at either the probeset or transcript cluster(Gene) level which of these have a high genetic heritability.  
The lower the heritability value the more environmental influence on expression is high compared to the
strict genetic influence.  This allows sorting and filtering based on heritability to look for probesets and transcript clusters 
with high heritability and thus are more likely controlled by a genetic component, that may reside in an eQTL 
region which you may explore futher in the Detailed Transcription Information section.


How is heritability calculated?
The broad sense heritability is calculated for each probe set/transcript clusters separately using an ANOVA
model.

For analyses on the Affymetrix Mouse 430 version 2 array, the broad sense heritability
has been calculated on the public inbred mouse panel (20 strains) normalized using RMA with poor quality
probes eliminated prior to normalization and the public BXD recombinant inbred mouse panel (32 strains) normalized
using RMA with poor quality probe eliminated prior to normalization.

For analyses on the Affymetrix Mouse Exon array, the broad sense heritability has been calculated on the
core transcript clusters from the public LXS brain recombinant inbred mouse panel normalized using RMA
with poor quality probes eliminated prior to normalization. 

For analyses on the Affymetrix Rat Exon array, the
user must choose the tissue of interest (brain, heart, liver, or brown adipose tissue). The broad sense heritability
has been calculated separately for each tissue on the core transcript clusters from the public
HXB/BXH recombinant inbred rat panel normalized using RMA with poor quality probes eliminated prior to normalization.


<BR />
<a href="#top">Back to Top</a><BR /><span class="button" onclick="window.close()" style="width:150px;">Close this Window</span><BR />
<a name="recInbredPanel"><H2>Recombinant Inbred Panel</H2></a>


<BR />
<a href="#top">Back to Top</a><BR /><span class="button" onclick="window.close()" style="width:150px;">Close this Window</span><BR />
<%@ include file="/web/common/footer.jsp" %>
