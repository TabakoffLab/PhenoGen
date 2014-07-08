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

    
	<H2>Upload Private Data</H2>
                     <div  style="overflow:auto;height:92%;">
                    	<H3>Demo/Screen Shots</H3>
                        <div style="overflow:auto;display:inline-block;height:22%;width:100%;">
                        	<table>
                            <TR>
                            <TD>
                            <span class="tooltip"  title="Steps for uploading data<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/microUpload_steps.jpg" title="Steps for uploading data"><img src="web/overview/microUpload_steps.jpg" width="100%" title="Click to view a larger image" /></a></span>
                            </TD>
                            </TR>
                            </table>
                            </div>
                    	<H3>Feature List</H3>
                        <div>
                        	A number of steps are involved to collect information about the arrays and experimental design.  The screen shot shows an overview of the steps required.
                              <ul>
                        	<li>Upload any of the supported array types for private data analysis</li>
                            <li>Minimum Information About a Microarray Experiment(MAIME) compliant.  You will be prompted to provide this information prior to uploading data.</li> 
                            <li>Don't see support for arrays you have contact us we will look into adding support.</li>
                            <li>You always have the option later to share arrays or gene lists with other users if you choose to.</li>
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