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

    
	<H2>Create QTL Lists</H2>
                     <div  style="overflow:auto;height:92%;">
                    	<H3>Demo/Screen Shots</H3>
                        <div style="overflow:auto;display:inline-block;height:33%;width:100%;">
                        	<table>
                            <TR>
                            <TD>
                            <span class="tooltip"  title="Screen Shot of the form for entering a list of bQTLs or eQTLs.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/qtlList.jpg" title=""><img src="web/overview/qtlList.jpg"  style="width:100%;" title="Click to view a larger image"/></a></span>
                            </TD>
                            </TR>
                            </table>
                            </div>
                    	<H3>Feature List</H3>
                        <div>
                        <ul>
                        	<li>Create a list of QTLs(either bQTLs or eQTLs).</li>
                            <li>Use the list to limit the location view of a gene list to only genes or eQTLs that fall within the regions in the list.</li>
                            <li>Use the list for the filtering step of an analysis to remove probe sets outside of the defined regions.</li>
                            
                        </ul>
                        </div>
						<BR /><BR />
                        <div style="text-align:center;width:100%;">
                        	<a href="<%=accessDir%>checkLogin.jsp?url=<%=qtlsDir%>defineQTL.jsp?fromMain=Y&fromQTL=Y" class="button" style="width:170px;color:#666666;">Login to Define QTLs</a>
                            <BR />or<BR />
                            <a href="<%=accessDir%>registration.jsp" class="button" style="width:140px;color:#666666;">Register Here</a>
                        </div>
                   </div>

<script src="javascript/indexGraphAccordion1.0.js">
						</script>