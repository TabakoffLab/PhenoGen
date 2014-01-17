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
	extrasList.add("index.css"); %>
<%pageTitle="Overview Gene List Analaysis Tools";
pageDescription="Overview of available Gene List Analysis Tools";%>
<%@ include file="/web/common/basicHeader.jsp" %>

        <div id="welcome" style="height:575px; width:980px; overflow:auto;">

	<h2>Gene Analysis Tools</h2>
    
    <div id="overview-wrap" >
                	<div id="overview-content">
				<p> After you have created a list of candidate genes in our Analyze Microarray 
				Data section or even if you already have a list of genes, we 
				offer a collection of tools for researching these genes all in one place.  
				Using our tools, you can:  </p>
				<ul>
				<li> <div class="clicker" name="branch1"> View multiple sources of annotation 
						&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"> </div> 
					<span class="branch" id="branch1">
					Get as much information as possible about each gene in your list, no matter 
					what type of identifier you started with.
					</span>
				<li> <div class="clicker" name="branch2"> Perform a literature search 
						&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"> </div> 
					<span class="branch" id="branch2">
					Look for all your genes simultaneously in PubMed and highlight publications that contain more than 
					one gene in your list.
					</span>
				<li> <div class="clicker" name="branch3"> Analyze promoter sequences 
						&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"> </div> 
					<span class="branch" id="branch3">
					Perform a MEME analysis, an oPOSSUM analysis, or simply retrieve the upstream sequences 
					for your genes in FASTA format.
					</span>
				<li> <div class="clicker" name="branch11"> Compare gene lists
						&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"> </div> 
					<span class="branch" id="branch11">
					Use our tools to find genes that are common to more than one of your 
					candidate gene lists or find those genes that are unique to a particular list. 
					</span>
				<li> <div class="clicker" name="branch4"> View the location of your genes 
						&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"> </div> 
					<span class="branch" id="branch4">
					Display your genes on our downloadable and zoomable chromosome map. You can even limit 
					your genes by regions of the genome.
					</span>
				</ul>
				<br/>
				<BR />
                    <BR />
                    <a href="<%=accessDir%>checkLogin.jsp?url=<%=datasetsDir%>listGeneLists.jsp" class="button" style="margin: 0 0 0 40px; width:150px;">Get Started</a>
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
