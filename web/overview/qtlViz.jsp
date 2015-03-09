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

    
<H2>Visualize eQTLs</H2>
                    <div  style="overflow:auto;height:92%;">
                    	<H3>Demo/Screen Shots</H3>
                        <div style="overflow:auto;display:inline-block;height:33%;width:100%;">
                        	<table>
                            <TR>
                            <TD>
                            <span class="tooltip"  title="Example gene Circos plots showing all eQTLs for a gene below a threshold.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/qtlViz.jpg" title="Example gene Circos plots showing all eQTLs for a gene below a threshold.">
                                <img src="web/overview/qtlViz_200.jpg"  title="Click to view a larger image"/></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="Example region Circos plot showing all the genes(and locations) that have an eQTL in the region being viewed.(Chr 1 220mb-228mb in this case)<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/qtlViz_region.jpg" title="Example region Circos plot showing all the genes that have an eQTL in the region being viewed.">
                                <img src="web/overview/qtlViz_region_200.jpg"   title="Click to view a larger image"/></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="Example view of gene locations with associated eQTLs from genes in a gene list.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/qtlViz_list.jpg" title="Example view of gene locations with associated eQTLs from genes in a gene list.">
                                <img src="web/overview/qtlViz_list_200.jpg"   title="Click to view a larger image"/></a></span>
                            </TD>
                            </TR>
                            </table>
                            </div>
                    	<H3>Feature List</H3>
                        <div>
                        <ul>
                        	<li>View eQTLs associated with a gene in a Circos Plot(Detailed Genome/Transcriptome Information select eQTL Tab for a specific gene)</li>
                            <li>View genes with an eQTL in a region in a Circos Plot(Detailed Genome/Transcriptome Information select Genes Controlled from Region Tab while viewing a Region)</li>
                            <li>View genes locations across the genome with associated eQTLs.(View a Gene List and select the Location Tab)</li>
                        </ul>
                        </div>
                    	<BR /><BR />
                        <div style="text-align:center;width:100%;">
                       		<a href="<%=contextRoot%>gene.jsp" class="button" style="width:240px;color:#666666;">View eQTLs for a Gene or Region</a>
                            <BR />or<BR />
                        	<a href="<%=accessDir%>checkLogin.jsp?url=<%=qtlsDir%>defineQTL.jsp?fromMain=Y&fromQTL=Y" class="button" style="width:200px;color:#666666;">Login to View Gene List QTLs</a>
                            <BR />or<BR />
                            <a href="<%=accessDir%>registration.jsp" class="button" style="width:140px;color:#666666;">Register Here</a>
                        </div>
                        
                   </div>

<%@ include file="/web/overview/ovrvw_js.jsp" %>