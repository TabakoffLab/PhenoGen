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

    
	<H2>Access Public Data</H2>
                   <div  style="overflow:auto;height:92%;">
                    	<H3>Demo/Screen Shots</H3>
                        <div style="overflow:auto;display:inline-block;height:27%;width:100%;">
                        	<table>
                            <TR>
                            <TD>
                            <span class="tooltip"  title="Basic Array Search<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/microPublic_basic.jpg" title="Basic Array Search"><img src="web/overview/microPublic_basic.jpg"  style="width:200px;"/></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="Advanced Array Search<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/microPublic_advanced.jpg" title="Advanced Array Search" ><img src="web/overview/microPublic_advanced.jpg"  style="width:200px;" /></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="Example Results for Affy Rat Exon 1.0 ST Arrays<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/microPublic_results.jpg" title="Example Results for Affy Rat Exon 1.0 ST Arrays" ><img src="web/overview/microPublic_results.jpg"  style="width:200px;" /></a></span>
                            </TD>
                            </TR>
                            </table>
                            </div>
                    	<H3>Feature List</H3>
                        <div>
                        <ul>
                        	<li>Most arrays are publicly available.</li>
                            <li>All of the arrays for public datasets are available to use in your own dataset which can be combined with your own private data if desired.</li>
                            <li>When creating a dataset and searching for arrays to include a column indicates if data is public or private.  Private data can be added to a dataset, however you will not be able to proceed until your request is approved to access the data.</li>
                            <li>You also have the option to create a dataset and download the data to use in your own analysis.</li>
                            
                        </ul>
                        </div>
                    	<BR /><BR />
                        <div style="text-align:center;width:100%;">
                        	<a href="<%=accessDir%>checkLogin.jsp?url=<%=datasetsDir%>basicQuery.jsp" class="button" style="width:200px;color:#666666;">Login to Create a Dataset</a>
                        	
                            <BR />or<BR />
                            <a href="<%=accessDir%>checkLogin.jsp?url=<%=datasetsDir%>listDatasets.jsp" class="button" style="width:200px;color:#666666;">Login to Start an Analysis</a>
                            <BR />or<BR />
                            <a href="<%=accessDir%>registration.jsp" class="button" style="width:140px;color:#666666;">Register Here</a>
                        </div>
                        
                   </div>

<script src="javascript/indexGraphAccordion1.0.js">
						</script>

    