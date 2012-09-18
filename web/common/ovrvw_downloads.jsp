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

<%@ include file="/web/common/basicHeader.jsp" %>

        <div id="welcome" style="height:575px; width:980px; overflow:auto;">

	<h2>Downloadable Resources</h2>
    
    <div id="overview-wrap">
                	<div id="overview-content">
				<p> Although we provide many integrated tools to analyze our public data sets, we realize that 
                you may prefer to conduct your analyses offline.  Many of our data sets are available on the website and 
                can easily be downloaded in a raw or processed format.  You can:
				</p>
				<ul>
				<li> <div class="clicker" name="branch15"> Download expression data from our public data sets 
						&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"> </div> 
					<span class="branch" id="branch15">
					Expression data for the public data sets is available in bulk download in either their raw format (e.g., CEL files for Affymetrix arrays) or as normalized data.
					</span>
				<li> <div class="clicker" name="branch16"> Download expression quantitative trait loci information (eQTL) and expression heritability estimate
						&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"> </div> 
					<span class="branch" id="branch16">
					Download information on the major eQTL or the heritability estimate for each transcript/probe set in the 		recombinant inbred public data sets: Brain in BXD or LXS mice or HXB/BXH rats; liver, heart, or brown adipose tissue in HXB/BXH rats.
					</span>
                    <li> <div class="clicker" name="branch17"> Download recently generated RNA-Seq data
						&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"> </div> 
					<span class="branch" id="branch17">
					RNA-Seq data from whole brain of three biological replicates of two inbred rat strains (BN-Lx/CubPrin and SHR/OlaPrin, the progenitors of the HXB/BXH panel) was generated from polyA+ RNA sequencing on the Illumina HiSeq2000 sequencer in 100X100 paired end reads and from total RNA (after reduction of ribosomal RNA) on the Helicos Heliscope Single Molecule sequencer.
					</span>

				</ul>
				<br/>
				<BR />
                    <BR />
                    <a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=sysBioDir%>resources.jsp" class="button" style="margin: 0 0 0 40px; width:150px;">View Downloads</a>

                	</div> <!-- // end overview-content -->
            	</div> <!-- // end overview-wrap -->
                
                </div> <!-- // end welcome -->
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
