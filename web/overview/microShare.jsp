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

    
	<H2>Share Data</H2>
                   <div  style="overflow:auto;height:92%;">
                    	<H3>Demo/Screen Shots</H3>
                        <div style="overflow:auto;display:inline-block;height:22%;width:100%;">
                        	<table>
                            <TR>
                            <TD>
                            <span class="tooltip"  title="The approve array request link displayed to principal investigators so that you may approve requests to access private data.<BR>Click to view a larger image.">
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/microShare_approveLink.jpg" title="The approve array request link displayed to PIs so that you may approve requests to access private data."><img src="web/overview/microShare_approveLink.jpg"  style="width:200px;" title="Click to view a larger image"/></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="The screen used to approve or deny requests.  All current requests are displayed to allow you to quickly approve or deny them.<BR>Click to view a larger image.">
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/microShare_request.jpg" title="The screen used to approve or deny requests.  All current requests are displayed to allow you to quickly approve or deny them."><img src="web/overview/microShare_request.jpg"  style="width:200px;" title="Click to view a larger image"/></a></span>
                            </TD>
                            </TR>
                            </table>
                            </div>
                    	<H3>Feature List</H3>
                        <div>
                        You have two options for your data when you upload array files.  You can either choose to make them public or private.
                        <ul>
                        
                        	<li>Public arrays allow any PhenoGen user to copy the original array file and use it in their dataset.</li>
                            
                            <li>Private arrays will show up in search results, but users have to request access to the arrays at which point you will be notified and can login to either allow or deny the request.</li>
                        </ul>
                        </div>
                    	<BR /><BR />
                        <div style="text-align:center;width:100%;">
                        	
                        	<a href="<%=accessDir%>checkLogin.jsp?url=<%=experimentsDir%>listExperiments.jsp" class="button" style="width:200px;color:#666666;">Login to Upload Data</a>
                            <BR />or<BR />
                            <a href="<%=accessDir%>checkLogin.jsp?url=<%=datasetsDir%>basicQuery.jsp" class="button" style="width:200px;color:#666666;">Login to Create a Dataset</a>
                            <BR />or<BR />
                            <a href="<%=accessDir%>registration.jsp" class="button" style="width:140px;color:#666666;">Register Here</a>
                        </div>
                        
                   </div>

<script src="javascript/indexGraphAccordion1.0.js">
						</script>