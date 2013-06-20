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
                    <div id="accordion" style="height:100%;">
                    	<H3>Feature List</H3>
                        <div>
                        <ul>
                        	<li>View eQTLs associated with a gene in a Circos Plot(Detailed Genome/Transcriptome Information select eQTL Tab for a specific gene)</li>
                            <li>View genes with an eQTL in a region in a Circos Plot(Detailed Genome/Transcriptome Information select Genes Controlled from Region Tab while viewing a Region)</li>
                            <li>View genes locations across the genome with associated eQTLs.(View a Gene List and select the Location Tab)</li>
                        </ul>
                        </div>
                    	<h3>Sample Screen Shots</h3>
                        <div style="text-align:center">
                        	Example gene Circos plots showing all eQTLs for a gene below a threshold.
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/qtlViz.jpg" title="Example gene Circos plots showing all eQTLs for a gene below a threshold."><img src="web/overview/qtlViz.jpg"  style="width:100%;" title="Click to view a larger image"/></a>
                            Example region Circos plot showing all the genes(and locations) that have an eQTL in the region being viewed.(Chr 1 220mb-228mb in this case)
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/qtlViz_region.jpg" title="Example region Circos plot showing all the genes that have an eQTL in the region being viewed."><img src="web/overview/qtlViz_region.jpg"  style="width:100%;" title="Click to view a larger image"/></a>
                            Example view of gene locations with associated eQTLs from genes in a gene list.
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/qtlViz_list.jpg" title="Example view of gene locations with associated eQTLs from genes in a gene list."><img src="web/overview/qtlViz_list.jpg"  style="width:100%;" title="Click to view a larger image"/></a>
                        </div>
                        
                   </div>

<script src="javascript/indexGraphAccordion.js">
						</script>