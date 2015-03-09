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

    

                	<H2>multiMiR</H2>
                   <div  style="overflow:auto;height:92%;">
                    	<H3>Demo/Screen Shots</H3>
                        <div style="overflow:auto;display:inline-block;height:30%;width:100%;">
                        	<table>
                            <TR>
                            <TD>
                            <span class="tooltip"  title="The muliMiR tab showing how you can start a new multiMiR Analysis.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/glmultimir_new.jpg" title="The muliMiR tab showing how you can start a new multiMiR Analysis.">
                                <img src="web/overview/glmultimir_new_200.jpg"  title="Click to view a larger image"/></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="The multiMiR tab with a table of the previously run analyses and the summary table.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/glmultimir_sum.jpg" title="The multiMiR tab with a table of the previously run analyses and the summary table.">
                                <img src="web/overview/glmultimir_sum_200.jpg"   title="Click to view a larger image"/></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="The multiMiR tab with a table of the previously run analyses and the table with a breakdown of each gene and database.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/glmultimir_sumdetail.jpg" title="The multiMiR tab with a table of the previously run analyses and the table with a breakdown of each gene and database.">
                                <img src="web/overview/glmultimir_sumdetail_200.jpg"   title="Click to view a larger image"/></a></span>
                            </TD>
                            </TR>
                            </table>
                            </div>
                    	<H3>Feature List</H3>
                        <div>
                        	multiMiR(an R package available <a href="" target="_blank">here</a>) is available as a tab under a selected gene list.  Use multiMiR to summarize validated and predicted targets of miRNA from 14 databases.  After selecting a mouse Gene List (support for Rat will be available in the future), you will see multiMiR as one of the available tabs.  After clicking the tab you may run a new analysis or select a previous saved analysis.
                            Results include:
                           	<ul>
                            	<li>A table sumarizing the number of validated/predicted genes targeted by each miRNA with a hit in this gene list</li>
                                <li>A table with further detail about all the validated/predicted genes targets</li>
                                <li>A link to view additional details includeding specific database hit details and links to gene and miRNA databases as well as pubmed for references</li>
                            </ul>
                        </div>
                        <BR /><BR />
                        <div style="text-align:center;width:100%;">
                        	<a href="<%=accessDir%>checkLogin.jsp?url=<%=geneListsDir%>listGeneLists.jsp" class="button" style="width:170px;color:#666666;">Login to View Gene Lists</a><BR />or<BR /><a href="<%=accessDir%>registration.jsp" class="button" style="width:140px;color:#666666;">Register Here</a>
                        </div>
                        
                    </div>

    
<%@ include file="/web/overview/ovrvw_js.jsp" %>