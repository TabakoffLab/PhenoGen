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

<% 	
	extrasList.add("fancyBox/jquery.fancybox.js");
	extrasList.add("fancyBox/helpers/jquery.fancybox-thumbs.js");
	extrasList.add("jquery.fancybox.css");
	extrasList.add("jquery.fancybox-thumbs.css");
	extrasList.add("normalize.css");
	extrasList.add("index.css"); %>

<%	pageTitle="Overview What's New";
	pageDescription="Description of new features on PhenoGen";
%>

<%@ include file="/web/common/basicHeader.jsp" %>

        <div id="welcome" style="height:575px; width:980px; overflow:auto;">
		
                <h2>What's New</h2>
                <div id="overview-wrap"  >
                		<div id="overview-content-wide" style="display:inline-block;">
                                    
                                        <%@ include file="/web/common/whats_new_content.jsp" %>
                        </div>
                    <div style="display:inline-block;width:42%;float:right;">
                        Example WGCNA Module View:
                        <a class="fancybox" rel="fancybox-thumb" href="<%=webDir%>overview/browseWGCNA.png" title="Example WGCNA Module View">
                      		<img src="<%=webDir%>overview/browseWGCNA.png" alt="Example WGCNA Module View"  style="width:95%;">
                        </a>
                      <BR /><BR />
                      
                        Example WGCNA eQTL Module View:
                        <a class="fancybox" rel="fancybox-thumb" href="<%=webDir%>overview/browseWGCNA_eQTL.png" title="Example WGCNA eQTL Module View">
                      		<img src="<%=webDir%>overview/browseWGCNA_eQTL.png" alt="Example WGCNA eQTL Module View"  style="width:95%;">
                        </a>
                      <BR /><BR />
                      
                    	Example Region View:
                        <a class="fancybox" rel="fancybox-thumb" href="<%=webDir%>overview/browser_region.jpg" title="Example Region View">
                      		<img src="<%=webDir%>overview/browser_region.jpg" alt="Detailed Region Example"  style="width:95%;">
                        </a>
                      <BR /><BR />
                      	Example Tissue View showing Array and RNA-Seq Data and a zoomed in view from holding the mouse over a region:
                        <a class="fancybox" rel="fancybox-thumb" href="<%=webDir%>overview/browser_ttRNACount.jpg" title="Example Tissue View with liver, showing Affymetrix Probe Set Array Data and RNA-Seq Data and the tool tip view showing a zoomed in view from holding the mouse over a region of the RNA-Seq Read Depth track.">
                      		<img src="<%=webDir%>overview/browser_ttRNACount.jpg" alt="Detailed Region Example" style="width:95%;">
                      	</a>
                                    
                                        
                    </div>
            	</div> <!-- // end overview-wrap -->
	</div><!-- // end welcome -->
    
    <script type="text/javascript">
        	$(document).ready(function(){	
			
			
				$('.fancybox').fancybox({
						helpers : {
										title: {
											type: 'inside',
											position: 'top'
										},
										thumbs	: {
												width	: 200,
												height	: 100
											}
									},
						nextEffect: 'fade',
						prevEffect: 'fade'
				});


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
