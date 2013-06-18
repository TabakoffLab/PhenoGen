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
                    <div id="accordion" style="height:100%;">
                    	<H3>Feature List</H3>
                        <div>
                        	Available only for gene lists created from analysis of arrays on PhenoGen and only where there were exactly 2 groups to compare.
                            <BR /><BR />
                            <ul>
                            	<li>Run <a href="http://www.bioconductor.org/packages/2.12/bioc/html/SPIA.html" target="_blank">SPIA</a> from Bioconductor</li>
                            	<li>List all pathways represented in the list</li>
                                <li>List genes in each pathway represented in the list</li>
                                <li>Gives an indication of status of the pathway(Activated/Inhibited)</li>
                                <li>Links to <a href="http://www.genome.jp/kegg/" target="_blank">KEGG</a> for an image and more information about the pathway.</li>
                            </ul>
                        </div>
                        <h3>Sample Screen Shots</h3>
                        <div style="text-align:center">
                   			Example result list that allows you to load results or start a new analysis.
                            <img src="web/overview/glPathway_list.jpg"  style="width:100%;"/>
                            Table listing pathways found to be represented in  the gene list.
                            <img src="web/overview/glPathway_table.jpg"  style="width:100%;"/>
                            Image of pathway linked from the table above.
                            <img src="web/overview/glPathway_pathway.jpg"  style="width:100%;"/>
                        </div>
                    </div>
    
    <script src="javascript/indexGraphAccordion.js">
						</script>