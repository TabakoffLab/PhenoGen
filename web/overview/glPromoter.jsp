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
                	<H2>Promoter Analysis</H2>
                    <div  style="overflow:auto;height:92%;">
                    	<H3>Demo/Screen Shots</H3>
                        <div style="overflow:auto;display:inline-block;height:25%;width:100%;">
                        	<table>
                            <TR>
                            <TD>
                            <span class="tooltip"  title="Overview of promoter page.<BR>Click to view a larger image.">
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/glPromoter_ovrvw.jpg" title="Overview of promotor page">
                                    <img src="web/overview/glPromoter_ovrvw_150.jpg"   title="Click to view a larger image"/></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="Example of oPOSSUM output.<BR>Click to view a larger image.">
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/glPromoter_opossum.jpg" title="Example of oPOSSUM output">
                                    <img src="web/overview/glPromoter_opossum_150.jpg" title="Click to view a larger image"/></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="Example of MEME output.<BR>Click to view a larger image.">
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/glPromoter_meme.jpg" title="Example of MEME output">
                                    <img src="web/overview/glPromoter_meme_150.jpg"  title="Click to view a larger image"/></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="Example of upstream extraction output.<BR>Click to view a larger image.">
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/glPromoter_upstream.jpg" title="Example of upstream extraction output">
                                    <img src="web/overview/glPromoter_upstream_150.jpg" title="Click to view a larger image"/></a></span>
                            </TD>
                            </TR>
                            </table>
                            </div>
                    	<H3>Feature List</H3>
                        <div>
                        	Analyze promoters for all the genes in a gene list. PhenoGen supports the following 3 methods for promoter analysis.
                              <ul>
                            	<li><a href="http://burgundy.cmmt.ubc.ca/oPOSSUM/" target="_blank">oPOSSUM v2</a> (Mouse Only)</li>
                                <li><a href="http://meme.nbcr.net/meme/cgi-bin/meme.cgi" target="_blank">MEME v4.9 patch 2</a></li>
                                <li>upstream sequence extraction to a downloadable .fasta file for your own analysis</li>
                           </ul>
                            
                             
                        </div>
                       <BR /><BR />
                        <div style="text-align:center;width:100%;">
                        	<a href="<%=accessDir%>checkLogin.jsp?url=<%=geneListsDir%>listGeneLists.jsp" class="button" style="width:170px;color:#666666;">Login to View Gene Lists</a><BR />or<BR /><a href="<%=accessDir%>registration.jsp" class="button" style="width:140px;color:#666666;">Register Here</a>
                        </div>
                    </div>
    
<%@ include file="/web/overview/ovrvw_js.jsp" %>