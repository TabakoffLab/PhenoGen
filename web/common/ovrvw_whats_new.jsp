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

<%	pageTitle="Overview What's New";
	pageDescription="Description of new features on PhenoGen";
%>

<%@ include file="/web/common/basicHeader.jsp" %>

        <div id="welcome" style="height:575px; width:980px; overflow:auto;">
		
	<h2>What's New</h2>
    <div id="overview-wrap"  >
    <div><img src="<%=webDir%>overview/browseRegion1.jpg" alt="Detailed Region Example" style="display:inline-block;width:45%;float:right;">
                	<div id="overview-content-wide" style="display:inline-block;top:-440px; position:relative;">
                    
            			<%@ include file="/web/common/whats_new_content.jsp" %>
                        </div>
                        
</div>
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
