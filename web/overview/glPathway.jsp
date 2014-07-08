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
                	<H2>Pathway Analysis</H2>
                    <div  style="overflow:auto;height:92%;">
                    	<H3>Demo/Screen Shots</H3>
                        <div style="overflow:auto;display:inline-block;height:25%;width:100%;">
                        	<table>
                            <TR>
                            <TD>
                             <span class="tooltip"  title="Example result list that allows you to load results or start a new analysis.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/glPathway_list.jpg" title="Example result list that allows you to load results or start a new analysis."><img src="web/overview/glPathway_list.jpg"  style="width:200px;" title="Click to view a larger image"/></a></span>
                            </TD>
                            <TD>
                               <span class="tooltip"  title="Table listing pathways found to be represented in  the gene list.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/glPathway_table.jpg" title="Table listing pathways found to be represented in  the gene list."><img src="web/overview/glPathway_table.jpg"  style="width:200px;" title="Click to view a larger image"/></a></span>
                            </TD>
                            <TD>
                             <span class="tooltip"  title="Image of pathway linked from the table above.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/glPathway_pathway.jpg" title="Image of pathway linked from the table above."><img src="web/overview/glPathway_pathway.jpg"  style="width:200px;" title="Click to view a larger image"/></a></span>
                            </TD>
                            </TR>
                            </table>
                        </div>
                    	<H3>Feature List</H3>
                        <div>
                        	Available only for gene lists created from a correlation or differential expression analysis of arrays on PhenoGen and only where there were exactly 2 groups to compare and less than 1,000 genes.
                            <BR /><BR />
                            <ul>
                            	<li>Run <a href="http://www.bioconductor.org/packages/2.12/bioc/html/SPIA.html" target="_blank">SPIA</a> from Bioconductor</li>
                            	<li>List all pathways represented in the list</li>
                                <li>List genes in each pathway represented in the list</li>
                                <li>Gives an indication of status of the pathway (Activated / Inhibited)</li>
                                <li>Links to <a href="http://www.genome.jp/kegg/" target="_blank">KEGG</a> for an image and more information about the pathway.</li>
                            </ul>
                        </div>
                        <BR /><BR />
                        <div style="text-align:center;width:100%;">
                        	<a href="<%=accessDir%>checkLogin.jsp?url=<%=geneListsDir%>listGeneLists.jsp" class="button" style="width:170px;color:#666666;">Login to View Gene Lists</a><BR />or<BR /><a href="<%=accessDir%>registration.jsp" class="button" style="width:140px;color:#666666;">Register Here</a>
                        </div>
                        
                    </div>
    
    <script src="javascript/indexGraphAccordion1.0.js">
						</script>