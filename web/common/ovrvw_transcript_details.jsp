<%--
 *  Author: Spencer Mahaffey
 *  Created: August, 2012
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/access/include/login_vars.jsp" %>

<% extrasList.add("index.css"); %>
<% extrasList.add("overview.js"); %>

<%pageTitle="Overview Detailed Transcription Information";%>

<%@ include file="/web/common/basicHeader.jsp" %>

        <div id="welcome" style="height:575px; width:980px; overflow:auto;">
            <h2>Detailed Transcription Information</h2>
            <div id="overview-wrap" >
                	<div id="overview-content-wide">
                        <p>This tool provides a way to explore various data for transcripts of a specific gene or data for a region of a genome.  
                        You may use the Trascript Detail Tool to:
                        <ul>
                        	<li>View a region of a Mouse or Rat genome with array expression data and for Rat RNA-Seq transcripts:<BR />
                            	Data Availalbe:<BR />
                                	<ul >
                                        <li><div class="clicker" name="branch1">View UCSC Image of region  &nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch1">
                                        	The image shows genes in the region and bQTLs.  Optionally you may view additional information such as Ensembl transcripts and RNA-Seq transcripts(Rat only), UCSC/Affymetrix exon expression data, and homologus human chromosome regions and proteins.
                                        </span>
                                        <li><div  class="clicker" name="branch2">For Rat RNA-Seq transcripts from Brain are included<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch2">
                                        	RNA-Seq data(Available in the downloads section) was used to create a reconstructed transcriptome.  Those transcripts can be displayed and the number of transcripts found can be compared to the Ensembl transcript annotations.  When viewing Detailed Transcription Information at the gene level more information is available.
                                        </span>
                                        <li><div  class="clicker" name="branch3">View Heritability and Detection Above Background across tissues availble for genes in the region&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch3">
                                        	We have exon array data for 2 recombinant inbred panels and various tissues (ILSXISS Mice(Whole Brain) and HXB/BXH Rats(Whole Brain, Heart, Liver, Brown Adipose).  This data is summarized for each region to include the # and avgerage heritability of probesets with a significant heritability and # and average percentage of samples where probesets were detected above background.  These are summarized for each gene in each tissue.                                         </span>
                                        <li><div  class="clicker" name="branch4">View eQTLs for genes in the region&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch4">
                                        	For genes in the region eQTL with the minimum P-value and its location is summarized across tissues.  All locations and tissues can be summarized in a circos plot.
                                        </span>
                                        <li><div  class="clicker" name="branch5">View bQTLs overlapping the region&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch5">
                                            All public bQTLs from MGI and RGD with a defined location that overlaps the current region are displayed in summary table that also links to the associated databases.
                                        </span>
                                        <li><div  class="clicker" name="branch6">View genes controlled from the region&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch6">
                                        	eQTLs are calculated for the recombinant inbred panels at the Gene level(Affy Exon Transcript Clusters having a core annotation)).  This is used to return a list of genes that have a core transcript cluster and an eQTL that overlaps the region.
                                        </span>
                                     </ul>
                             </li><BR />
                            <li>Translate a region from Human/Mouse/Rat to Mouse/Rat and view the new regions(using UCSC liftOver)</li><BR />
                            <li>View a specific gene:<BR />
                            	Data Availabe:<BR />
                                    <ul >
                                        <li><div class="clicker" name="branch20">View Parental Strain(Rat) Differential Expression  &nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch20">
                                       		We have Affy Exon array data for the parental strains of the recombinant inbred panels.  This data is displayed in the first tab of the gene level view.  You have the option to filter on a number of parameters and view the data as a heat map of expression values or as fold differences between strains.
                                        </span>
                                        <li><div  class="clicker" name="branch21">View Parental Strain(Rat) Transcriptome Reconstruction&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch21">
                                        	For the Rat RNA-Sequencing was performed on the Parental Strains in Whole Brain.  The transcriptome was reconstructed from this data using CuffLinks.  These transcipts are shown with the Ensembl transcripts for comparison and you can use these transcripts to filter probesets or view exon-exon correlations on these transcripts.
                                        </span>
                                        <li><div  class="clicker" name="branch22">View Panel Heritability accross tissues&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch22">
                                        	The second tab contains graphs of the heritability of displayed probesets.  You can filter on a number of parameters to view only probesets of interest.  But you can use this to look for possible probesets and exons where expression may be correlated with the strain.
                                        </span>
                                        <li><div  class="clicker" name="branch23">View Panel Expression accross tissues&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch23">
                                        	You can also view individual probeset normalized expression acrosss strains and tissues.
                                        </span>
                                        <li><div  class="clicker" name="branch24">View Exon Correlation Tool&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                            <span class="branch" id="branch24">
                                            <ul>
                                                <li>Identify exons within a gene that are not expressed</li>
                                                <li>Identify exons within a gene with low heritability</li>
                                                <li>Use correlation patterns among exons to identify expressed isoforms.</li>
                                            </ul>
                                            </span>
                                        <li><div  class="clicker" name="branch25">View eQTL information&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch25">
                                        	This generates a Circos Plot that summazizes all of the eQTLs for a transcript cluster(Gene) across all the chromosomes and tissues.  You can customize the image to include just tissues and chromosomes of interest or change the P-value cut-off.  Once the image is generates you can zoom in/out and manipulate the image to look at areas of interest.
                                        </span>
                                    </ul>
                               </li>
                        </ul>
                    <BR />
                    <BR />
                    <a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=contextRoot%>gene.jsp" class="button" style="margin: 0 0 0 40px;">Try it out</a>
			</div> <!-- // end overview-content -->
            	</div> <!-- // end overview-wrap -->
        </div> <!-- // end welcome-->
	
    
    <script type="text/javascript">
        	$(document).ready(function(){	
            		$("div.clicker").click(function(){
                		var thisHidden = $( "span#" + $(this).attr("name") ).is(":hidden");
                		var tabTriggers = $(this).parents("ul").find("span.branch").hide();
                		var baseName = $(this).attr("name");
				$("span#" + baseName).removeClass("clickerLess");
                		if ( thisHidden ) {
					$("span#" + baseName).show().addClass("clickerLess");
				}
				$("div."+baseName).removeClass("clicker");
				$("div."+baseName).addClass("clickerLess");
            		});
					
        	});
		
	</script>
	
<%@ include file="/web/common/footer.jsp" %>
