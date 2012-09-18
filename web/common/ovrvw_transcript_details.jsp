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

<%@ include file="/web/common/basicHeader.jsp" %>

        <div id="welcome" style="height:575px; width:980px; overflow:auto;">
            <h2>Detailed Transcription Information</h2>
            <div id="overview-wrap" >
                	<div id="overview-content">
                        <p>This tool provides a way to explore various data for transcripts of a specific gene.  You may use the Trascript Detail Tool to:
                	<ul >
                    	<li><div class="clicker" name="branch1">View Parental Strain(Rat) Differential Expression  &nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                        <span class="branch" id="branch1"></span>
                        <li><div  class="clicker" name="branch2">View Parental Strain(Rat) Transcriptome Reconstruction&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                        <span class="branch" id="branch2"></span>
                        <li><div  class="clicker" name="branch3">View Panel Heritability/Detection Above Background accross tissues&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                        <span class="branch" id="branch3"></span>
                        <li><div  class="clicker" name="branch4">View Panel Expression accross tissues&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                        <span class="branch" id="branch6"></span>
                        <li><div  class="clicker" name="branch5">View Exon Correlation Tool&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                        	<span class="branch" id="branch5">
                        	<ul style="padding-left:80px;">
                                <li>Identify exons within a gene that are not expressed</li>
                                <li>Identify exons within a gene with low heritability</li>
                                <li>Use correlation patterns among exons to identify expressed isoforms.</li>
                            </ul>
                            </span>
                        <li><div  class="clicker" name="branch6">View eQTL information&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                        <span class="branch" id="branch6"></span>
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
