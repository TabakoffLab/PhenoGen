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

<% 	extrasList.add("normalize.css");
	extrasList.add("index.css");
	extrasList.add("overview.js"); %>

<%pageTitle="Overview Genome/Transcriptome Data Browser";
pageDescription="Overview of features and data available in the new Genome/Transcriptome Browser";%>

<%@ include file="/web/common/basicHeader.jsp" %>

        <div id="welcome" style="height:575px; width:980px; overflow:auto;">
            <h2>Genome/Transcriptome Data Browser</h2>
            <div id="overview-wrap" >
                	<div id="overview-content-wide">
                        <p>This tool provides a way to explore various data for transcripts of a specific gene or data for a region of a genome.  
                        You may use the Genome/Transcriptome Data Browser to:
                        <ul>
                        	<li>View a region of the mouse or rat genomes that includes information on array expression data and for rats transcripts expressed in brain identified in PhenoGen RNA-Seq data:
<BR />
                            	Data Availalbe:<BR />
                                	<ul >
                                        <li><div class="clicker" name="branch1">View an image of region  &nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch1">
                                        	The image shows genes in the region, bQTLs, strain variants(SNPs/Short Indels for BN-Lx, SHR, F344, SHRJ).  Optionally you may view additional information such as Ensembl transcripts and RNA-Seq transcripts(Rat only).
                                        </span>
                                        <li><div  class="clicker" name="branch2">For Rat RNA-Seq transcripts from Brain are included<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch2">
                                        	RNA-Seq data(Available in the downloads section) was used to create a reconstructed transcriptome.  Those transcripts can be displayed and the number of transcripts found can be compared to the Ensembl transcript annotations.  When viewing Detailed Transcription Information at the gene level more information is available.
                                        </span>
                                        <li><div  class="clicker" name="branch3">View Heritability and Detection Above Background across tissues availble for genes in the region&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch3">
                                        	We have exon array data for 2 recombinant inbred panels and various tissues (ILSXISS Mice(Whole Brain) and HXB/BXH Rats(Whole Brain, Heart, Liver, Brown Adipose).  These data are summarized for each region to include the # and average heritability of probesets with a significant heritability and # and average percentage of samples where probesets were detected above background.  These are summarized for each gene in each tissue.                                         </span>
                                        <li><div  class="clicker" name="branch4">View eQTLs for genes in the region&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch4">
                                        	For genes in this region, the location of the gene’s eQTL with the smallest p-value is reported.  All possible eQTL across multiple tissues are visualized in a Circos plot.

                                        </span>
                                        <li><div  class="clicker" name="branch5">View bQTLs overlapping the region&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch5">
                                            All public bQTLs from MGI and RGD with a defined location that overlaps the current region are displayed in summary table that also links to the associated databases.
                                        </span>
                                        <li><div  class="clicker" name="branch6">View genes controlled from the region&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch6">
                                        	eQTLs are calculated for the recombinant inbred panels at the Gene level(Affy Exon Transcript Clusters having a core annotation).  This is used to return a list of genes that have a core transcript cluster and an eQTL that overlaps the region.
                                        </span>
                                         <li><div  class="clicker" name="branch7">View SNPs and short indels across the region&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch7">
                                        	SNPs and short indels have been identified by genomic sequencing of 4 rat strains.  More will be available soon.
                                        </span>
                                     </ul>
                             </li><BR />
                            <li>Translate a region from Human/Mouse/Rat to Mouse/Rat and view the new regions(using UCSC liftOver)</li><BR />
                            <li>When you select a specific gene you can view anything listed above as well as:<BR />
                            	Data Availabe:<BR />
                                    <ul >
                                        <li><div class="clicker" name="branch20">View Parental Strain Differential Expression  &nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch20">
                                       		We have Affy Exon array data for the parental strains of the recombinant inbred panels.  This data is displayed in the first tab of the gene level view.  You have the option to filter on a number of parameters and view the data as a heat map of expression values or as fold differences between strains.
                                        </span>
                                        <li><div  class="clicker" name="branch21">View Parental Strain(Rat) Transcriptome Reconstruction&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch21">
                                        	The rat brain RNA-Seq data were used to reconstruct the rat brain transcriptome using CuffLinks.  These transcipts are shown with the Ensembl transcripts for comparison and you can use these transcripts to filter probesets or view exon-exon correlations on these transcripts.
                                        </span>
                                        <li><div  class="clicker" name="branch22">View Panel Heritability accross tissues&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch22">
                                        	The second tab contains graphs of the heritability of displayed probesets.  You can filter on a number of parameters to view only probesets of interest.
                                        </span>
                                        <li><div  class="clicker" name="branch23">View Panel Expression accross tissues&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch23">
                                        	You can also view the normalized expression of individual probesets across recombinant inbred strains and across tissues.
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
                
                <div class="demoVideo" style="display:inline-block;float:right;position:relative;top:-600px; padding-right:10px;">
                			<span style="text-align:center;"><h3>New! Browser Navigation Demo</h3></span>
                        	<video id="demoVid1" width="375"  controls="controls" poster="<%=contextRoot%>web/demo/BrowserNavDemo_350.png" preload="none">
                                <source src="<%=contextRoot%>web/demo/BrowserNavDemo.mp4" type="video/mp4">
                                <source src="<%=contextRoot%>web/demo/BrowserNavDemo.webm" type="video/webm">
                            
                              	<object data="<%=contextRoot%>web/demo/BrowserNavDemo.mp4" width="375" >
                              	</object>
                        	</video><BR />
                            <div id="showOpenLargeVideo" style="display:none;text-align:center; width:100%;"><a href="<%=contextRoot%>web/demo/largerDemo.jsp?demoPath=web/demo/BrowserNavDemo" class="button" style="width:180px;" target="_blank" >View larger version</a></div>
                            <span style="text-align:center;"><h3>New! Custom Track/View Demo</h3></span>
                        	<video id="demoVid1" width="375"  controls="controls" poster="<%=contextRoot%>web/demo/customTrackDemo_350.png" preload="none">
                                <source src="<%=contextRoot%>web/demo/customTrackDemo.mp4" type="video/mp4">
                                <source src="<%=contextRoot%>web/demo/customTrackDemo.webm" type="video/webm">
                            
                              	<object data="<%=contextRoot%>web/demo/customTrackDemo.mp4" width="375" >
                              	</object>
                        	</video><BR />
                            <div id="showOpenLargeVideo" style="display:none;text-align:center; width:100%;"><a href="<%=contextRoot%>web/demo/largerDemo.jsp?demoPath=web/demo/customTrackDemo" class="button" style="width:180px;" target="_blank" >View larger version</a></div>
                        	<span style="text-align:center;"><h3>Previous overview of tools available<BR />(all the tools are available navigation to them has changed,<BR /> an update will be available soon)</h3></span>
                        	<video id="demoVid" width="375"  controls="controls" poster="<%=contextRoot%>web/demo/detailed_transcript_fullv3_350.png" preload="none">
                                <source src="<%=contextRoot%>web/demo/detailed_transcript_fullv3.mp4" type="video/mp4">
                                <source src="<%=contextRoot%>web/demo/detailed_transcript_fullv3.webm" type="video/webm">
                            
                              	<object data="<%=contextRoot%>web/demo/detailed_transcript_fullv3.mp4" width="375">
                              	</object>
                        	</video><BR />
                            <div id="showOpenLargeVideo" style="display:none;text-align:center; width:100%;"><a href="<%=contextRoot%>web/demo/largerDemo.jsp?demoPath=web/demo/detailed_transcript_fullv3" class="button" style="width:180px;" target="_blank" >View larger version</a></div>
                            <!--<H3><a href="<%=contextRoot%>web/demo/mainDemo.jsp?file=<%=contextRoot%>web/demo/test." target="_blank">Open in a new Window</a></H3><BR />
                            <H3><a href="<%=contextRoot%>web/demo/mainDemo.jsp" target="_blank">View other demo videos</a></H3> -->
                        </div>
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
					
				//if we are in IE need to offer a way to view a larger video.  Other browsers support fullscreen but not IE9 or lower.
				//alert(navigator.userAgent);
				if (/Firefox[\/\s](\d+\.\d+)/.test(navigator.userAgent)){ //test for Firefox/x.x or Firefox x.x (ignoring remaining digits);
 					var ffversion=new Number(RegExp.$1) // capture x.x portion and store as a number
 					if (ffversion<11)
						$('#showOpenLargeVideo').show();
				}else if (/Safari[\/\s](\d+\.\d+)/.test(navigator.userAgent)){ //test for Safari/x.x or Safari x.x (ignoring remaining digits);
					/Version[\/\s](\d+\.\d+)/.test(navigator.userAgent);
 					var sfversion=new Number(RegExp.$1) // capture x.x portion and store as a number
 					if (sfversion<5)
						$('#showOpenLargeVideo').show();
				}else if (/Chrome[\/\s](\d+\.\d+)/.test(navigator.userAgent)){ //test for Chrome/x.x or Chrome x.x (ignoring remaining digits);
 					var cversion=new Number(RegExp.$1) // capture x.x portion and store as a number
 					if (cversion<21)
						$('#showOpenLargeVideo').show();
				}else if (/MSIE (\d+\.\d+);/.test(navigator.userAgent)){ //test for MSIE x.x;
 					var ieversion=new Number(RegExp.$1) // capture x.x portion and store as a number
					 if (ieversion<10)
					  	$('#showOpenLargeVideo').show();
				}else if (/Opera[\/\s](\d+\.\d+)/.test(navigator.userAgent)){ //test for Opera/x.x or Opera x.x (ignoring remaining decimal places);
 					var oprversion=new Number(RegExp.$1) // capture x.x portion and store as a number
					$('#showOpenLargeVideo').show();
				}
					
        	});
		
	</script>
	
<%@ include file="/web/common/footer.jsp" %>
