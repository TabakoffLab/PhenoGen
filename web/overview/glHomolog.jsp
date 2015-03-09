<%@ include file="/web/access/include/login_vars.jsp" %>
<%--
 *  Author: Spencer Mahaffey
 *  Created: May, 2013
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

                	<H2>Homologs</H2>
                    <div  style="overflow:auto;height:92%;">
                    	<H3>Demo/Screen Shots</H3>
                        <div style="overflow:auto;display:inline-block;height:34%;width:100%;">
                        	<table>
                            <TR>
                            <TD>
                            <span class="tooltip"  title="Example of available information on homologous genes in other species.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/glHomolog.jpg" title="Example of available information on homologous genes in other species.">
                                <img src="web/overview/glHomolog_300.jpg"  title="Click to view a larger image"/></a></span>
                            </TD>
                            </TR>
                            </table>
                            </div>
                    	<H3>Feature List</H3>
                        <div>
                        	<ul>
                        		<li>Browse homologous genes in Mouse, Rat, Human, or Drosophila.</li>
                            	<li>Provides links to NCBI/Homologene.</li>
                            	<li>Provides links to the organism specific NCBI gene.</li>
                            	<li>Provides Gene Symbol and location for each organism.</li>
                            </ul>
                        </div>
                        
                        <BR /><BR />
                        <div style="text-align:center;width:100%;">
                        	<a href="<%=accessDir%>checkLogin.jsp?url=<%=geneListsDir%>listGeneLists.jsp" class="button" style="width:170px;color:#666666;">Login to View Gene Lists</a><BR />or<BR /><a href="<%=accessDir%>registration.jsp" class="button" style="width:140px;color:#666666;">Register Here</a>
                        </div>
                        
                    </div>
    
<%@ include file="/web/overview/ovrvw_js.jsp" %>