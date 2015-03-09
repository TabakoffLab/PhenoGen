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

                	<H2>Compare/Share</H2>
                    <div  style="overflow:auto;height:92%;">
                    	<H3>Demo/Screen Shots</H3>
                        <div style="overflow:auto;display:inline-block;height:34%;width:100%;">
                        	<table>
                            <TR>
                            <TD>
                            <span class="tooltip"  title="An example of how you can compare lists and save the comparison to a new list.<BR>Click to view a larger image.">
                   			<a class="fancybox" rel="fancybox-thumb" href="web/overview/glShare_compare.jpg" title="An example of how you can compare lists and save the comparison to a new list.">
                                            <img src="web/overview/glShare_compare_300.jpg"   title="Click to view a larger image"/></a></span>
                            </TD>
                            </TR>
                            </table>
                            </div>
                    	<H3>Feature List</H3>
                        <div>
                        	<ul>
                        		<li>Share lists with any other registered user.</li>
                            	<li>Compare lists with any other accessible gene lists.</li>
                                <ul>
                            		<li>Look for any of your lists that also contain genes from a selected list</li>
                                	<li>Find the intersection, union, or subtract one list from another </li>
                                </ul>
                            </ul>
                        </div>
                         <BR /><BR />
                        <div style="text-align:center;width:100%;">
                        	<a href="<%=accessDir%>checkLogin.jsp?url=<%=geneListsDir%>listGeneLists.jsp" class="button" style="width:170px;color:#666666;">Login to View Gene Lists</a><BR />or<BR /><a href="<%=accessDir%>registration.jsp" class="button" style="width:140px;color:#666666;">Register Here</a>
                        </div>
                    </div>
    
<%@ include file="/web/overview/ovrvw_js.jsp" %>