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

<%pageTitle="Overview QTL Tools";%>

<%@ include file="/web/common/basicHeader.jsp" %>

        <div id="welcome" style="height:575px; width:980px; overflow:auto;">

	<h2>Quantitative Trait Locus(QTL) Tools</h2>
		<div id="overview-wrap">
                	<div id="overview-content">
				<p> Our interactive chromosome map can simultaneously display the location of your genes, the location 
					of their transcription control,  and any regions of interest or phenotypic QTL.  
					You can:
				</p>
				<ul>
				<!-- Comment this out for now, then put back into ul tag 
				<li><div class="clicker" name="branch12"> Identify genes that are physically located within your phenotypic QTL 
						&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"> </div> 
					<span class="branch" id="branch12">
					Find out which genes are physically located within the boundaries of your pQTL.
					</span>
				-->

				<li> <div class="clicker" name="branch8"> Find locations of transcription control (eQTL) for your candidate genes 
						&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"> </div> 
					<span class="branch" id="branch8">
					Use our brain eQTL data for both mice (BXD and LXS) and rats (HXB/BXH) and our liver/heart/brown adipose tissue eQTL data for rats(HXB/BXH) to see where in the genome the transcription of your candidate genes are controlled.
					</span>
				<li> <div class="clicker" name="branch9"> Identify candidate genes with an eQTL that overlaps your pQTL
						&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"> </div> 
					<span class="branch" id="branch9">
					Reduce your list of candidate genes by requiring that their expression is associated 
					with your phenotype, and that their expression is controlled in the same 
					region of the genome that has been shown to control the phenotype.
					</span>

				</ul>
				<br/>
                <BR />
                    <BR />
                    <a href="<%=accessDir%>checkLogin.jsp?url=<%=datasetsDir%>qtlMain.jsp" class="button" style="margin: 0 0 0 40px; width:150px;">Get Started</a>
				

                	</div> <!-- // end overview-content -->
            	</div> <!-- // end overview-wrap -->
	</div><!-- // end welcome -->
    
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
