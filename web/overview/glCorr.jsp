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

                	<H2>Exon-Exon Correlation</H2>
                    <div id="accordion" style="height:100%;">
                    	<H3>Feature List</H3>
                        <div>
                        	<ul>
                            	<li>View a heat map of probe set to probe set expression correlation aligned with exons of specific transcripts.</li>
                                <li>Side-by-side comparisons of different transcripts.</li>
                                <li>View heatmaps for multiple tissues to compare correlations of exons or parts of exons in different tissues.</li>
                                <li>Filter probe sets by other data(Detection Above Background or Heritability)</li>
                                
                            </ul>
                        </div>
                        <h3>Sample Screen Shots</h3>
                        <div style="text-align:center">
                        	The initial form to calculate exon-exon correlations for a tissue:
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/glCorr_form.jpg" title="Form to calculate exon-exon correlations for a tissue:"><img src="web/overview/glCorr_form.jpg"  style="width:100%;" title="Click to view a larger image"/></a>
                   			Example default view of a gene:
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/glCorr_gene.jpg" title="Example default view of a gene:"><img src="web/overview/glCorr_gene.jpg"  style="width:100%;" title="Click to view a larger image"/></a>
                            Example of comparing two different transcripts side by side
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/glCorr_sidebyside.jpg" title="Example of comparing two different transcripts side by side"><img src="web/overview/glCorr_sidebyside.jpg"  style="width:100%;" title="Click to view a larger image"/></a>
                            Example of correlations in different tissues Heart(left), Brown Adipose(right).  Possibly indicating different isoforms in each tissue.<BR />
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/glCorr_gene.jpg" title="Example different corelations in different tissues Heart"><img src="web/overview/glCorr_gene.jpg"  style="width:49%;" title="Click to view a larger image"/></a>
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/glCorr_bat.jpg" title="Example different corelations in different tissues Brown Adipose"><img src="web/overview/glCorr_bat.jpg"  style="width:49%;" title="Click to view a larger image"/></a>
                        </div>
                    </div>
    
    <script src="javascript/indexGraphAccordion.js">
						</script>
						

    