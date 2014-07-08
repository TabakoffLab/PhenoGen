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

                	<H2>Exon Expression Correlation</H2>
                    <div  style="overflow:auto;height:92%;">
                    	<H3>Demo/Screen Shots</H3>
                        <div style="overflow:auto;display:inline-block;height:34%;width:100%;">
                        	<table>
                            <TR>
                            <TD>
                            <span class="tooltip"  title="The initial form to calculate exon-exon correlations for a tissue.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/glCorr_form.jpg" title="Form to calculate exon-exon correlations for a tissue:"><img src="web/overview/glCorr_form.jpg"  style="width:150px;" title="Click to view a larger image"/></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="Example default view of a gene.<BR>Click to view a larger image.">
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/glCorr_gene.jpg" title="Example default view of a gene:"><img src="web/overview/glCorr_gene.jpg"  style="width:150px;" title="Click to view a larger image"/></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="Example of comparing two different transcripts side by side.<BR>Click to view a larger image.">
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/glCorr_sidebyside.jpg" title="Example of comparing two different transcripts side by side"><img src="web/overview/glCorr_sidebyside.jpg"  style="width:150px;" title="Click to view a larger image"/></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="Example of correlations in different tissues Heart(this image), Brown Adipose(next image).  Possibly indicating different isoforms in each tissue.<BR>Click to view a larger image.">
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/glCorr_gene.jpg" title="Example different corelations in different tissues Heart"><img src="web/overview/glCorr_gene.jpg"  style="width:150px;" title="Click to view a larger image"/></a></span>
                            </TD>
                            <TD>
                             <span class="tooltip"  title="Example of correlations in different tissues Heart(previous image), Brown Adipose(this image).  Possibly indicating different isoforms in each tissue.<BR>Click to view a larger image.">
                             <a class="fancybox" rel="fancybox-thumb" href="web/overview/glCorr_bat.jpg" title="Example different corelations in different tissues Brown Adipose"><img src="web/overview/glCorr_bat.jpg"  style="width:150px;" title="Click to view a larger image"/></a></span>
                            </TD>
                            </TR>
                            </table>
                        </div>
                    	<H3>Feature List</H3>
                        <div>
                        	<ul>
                            	<li>View a heat map of probe set to probe set expression correlation aligned with exons of specific transcripts.</li>
                                <li>Side-by-side comparisons of different transcripts.</li>
                                <li>View heatmaps for multiple tissues to compare correlations of exons or parts of exons in different tissues.</li>
                                <li>Filter probe sets by other data(Detection Above Background or Heritability)</li>
                                
                            </ul>
                        </div>
                        <BR /><BR />
                        <div style="text-align:center;width:100%;">
                        	<a href="<%=accessDir%>checkLogin.jsp?url=<%=geneListsDir%>listGeneLists.jsp" class="button" style="width:170px;color:#666666;">Login to View Gene Lists</a><BR />or<BR /><a href="<%=accessDir%>registration.jsp" class="button" style="width:140px;color:#666666;">Register Here</a>
                        </div>
                    </div>
    
    <script src="javascript/indexGraphAccordion1.0.js">
						</script>
						

    