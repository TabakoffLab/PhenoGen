<%@ include file="/web/common/headerOverview.jsp" %>
<%--
 *  Author: Spencer Mahaffey
 *  Created: May, 2013
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

    		<style>
				.branch{
					color:#555555;
				}
				span.highlight-dark{
					color:#444444;
				}
			</style>

                	
                   <H2>What's New</H2>
                    <div  style="overflow: auto;height:92%;">
                    	<%@ include file="/web/common/whats_new_content.jsp" %>
                        
             	    </div>

						
<%@ include file="/web/overview/ovrvw_js.jsp" %>
<script type="text/javascript">
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
</script>