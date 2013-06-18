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
                            	<li>View a heatmap of Probeset to Probeset Expression Correlation aligned with Exons of specific transcripts.</li>
                                <li>Side-by-side comparisons of different transcripts.</li>
                                <li>View heatmaps for multiple tissues to compare correlations of exons or parts of exons in different tissues.</li>
                                <li>Filter probesets by other data(Detection Above Background or Heritability)</li>
                                
                            </ul>
                        </div>
                        <h3>Sample Screen Shots</h3>
                        <div style="text-align:center">
                        	Form to calculate exon-exon correlations for a tissue:
                            <img src="web/overview/glCorr_form.jpg"  style="width:100%;"/>
                   			Example default view of a gene:
                        	<img src="web/overview/glCorr_gene.jpg"  style="width:100%;"/>
                            Example of comparing two different transcripts side by side
                        	<img src="web/overview/glCorr_sidebyside.jpg"  style="width:100%;"/>
                            Example different corelations in different tissues Heart(left), Brown Adipose(right).  Possibly indicating different isoforms in each tissue.<BR />
                        	<img src="web/overview/glCorr_gene.jpg"  style="width:49%;"/>
                            <img src="web/overview/glCorr_bat.jpg"  style="width:49%;"/>
                        </div>
                    </div>
    
    <script src="javascript/indexGraphAccordion.js">
						</script>
						

    