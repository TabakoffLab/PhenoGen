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

                	<H2>Annotations</H2>
                    <div  style="overflow:auto;height:92%;">
                    	<H3>Demo/Screen Shots</H3>
                        <div style="overflow:auto;display:inline-block;height:20%;width:100%;">
                        	<table>
                            <TR>
                            <TD>
                            <span class="tooltip"  title="Annotation Table for a rat gene list.<BR>Click to view a larger image.">
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/glAnnot_rat.jpg" title="Annotation Table for a rat gene list"><img src="web/overview/glAnnot_rat.jpg"  style="width:150px;" title="Click to view a larger image"/></a>
                            </span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="Annotation Table for a mouse gene list.<BR>Click to view a larger image.">
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/glAnnot_mouse.jpg" title="Annotation Table for a mouse gene list"><img src="web/overview/glAnnot_mouse.jpg"  style="width:150px;" title="Click to view a larger image"/></a>
                            </span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="Annotation options for a longer gene list.<BR>Click to view a larger image.">
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/glAnnot_list.jpg" title="Annotation options for a longer gene list"><img src="web/overview/glAnnot_list.jpg"  style="width:150px;" title="Click to view a larger image"/></a>
                            </span>
                            </TD>
                            </TR>
                            </table>
                        </div>
                    	<H3>Feature List</H3>
                        <div>
                        	However your gene list was created, we link supported identifiers to other database identifiers and provide links to the other databases with further information about each gene.
                            <BR /><BR />
                            The annotation page will link to the following sources for short lists(< 200) for larger lists you can export associated IDs.
                            <BR /><BR />
                           	Links:
                            <ul>
                            	<li>NCBI</li>
                                <li>Ensembl</li>
                                <li>RGD</li>
                                <li>MGI</li>
                                <li>Jackson Laboratories</li>
                                <li>UCSC Genome Browser</li>
                                <li>Allen Brain Atlas</li>
                            </ul>
                        </div>
                       <BR /><BR />
                        <div style="text-align:center;width:100%;">
                        	<a href="<%=accessDir%>checkLogin.jsp?url=<%=geneListsDir%>listGeneLists.jsp" class="button" style="width:170px;color:#666666;">Login to View Gene Lists</a><BR />or<BR /><a href="<%=accessDir%>registration.jsp" class="button" style="width:140px;color:#666666;">Register Here</a>
                        </div>
                        
                    </div>
    
    <script src="javascript/indexGraphAccordion1.0.js">
	</script>
    