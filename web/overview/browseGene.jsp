<%@ include file="/web/access/include/headerOverview.jsp" %>
<%--
 *  Author: Spencer Mahaffey
 *  Created: May, 2013
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

    

                	<H2>Browse Gene</H2>
                    <div id="accordion">
                    	<H3>Feature List</H3>
                        <div>
                        <ul>
                        	<li>View Rat Brain Isoforms from RNA-Seq transcriptome reconstruction</li>
                            <li>View Rat SNPs/Short Indels for BN-Lx and SHR with more coming soon</li>
                            <li>View Ensembl Isoforms</li>
                            <li>View Affymetrix Microarray Probeset locations</li>
                            <li>View bQTLs</li>
                            <li>View eQTLs for the gene</li>
                            <li>Access detailed Affy Exon 1.0 ST data</li>
                            	<ul>
                                	<li>Parental Strian Differential Expression(BN-Lx/SHR or ILS/ISS)</li>
                                    <li>Probeset Heritability/Detection Above Background across tissues</li>
                                    <li>Probeset Expression accross strains and tissues</li>
                                    <li>Exon Correlation</li>
                                </ul>
                        </ul>
                        </div>
                        <h3>Sample Screen Shots</h3>
                        <div style="text-align:center">
                        Gene View showing the gene image, table of features in the region:
                        <a class="fancybox" rel="fancybox-thumb" href="web/overview/browseGene.jpg" title="Gene View showing the gene image, table of features in the region:"><img src="web/overview/browseGene.jpg"  style="width:100%;"  title="Click to view a larger image"/></a>
                        eQTL view showing what regions are associated with expression in each available tissue:
                        <a class="fancybox" rel="fancybox-thumb" href="web/overview/qtlViz.jpg" title="eQTL view showing what regions are associated with expression in each available tissue:"><img src="web/overview/qtlViz.jpg"  style="width:100%;" title="Click to view a larger image"/></a>
                        </div>
                        <H3>Demonstration Video</H3>
                        <div class="demo" style="text-align:center;">
                            <video id="demoVideo" width="260px"  controls="controls">
                                <source src="web/demo/detailed_transcript_fullv3.webm" type="video/webm">
                                <source src="web/demo/detailed_transcript_fullv3.mp4" type="video/mp4">
                              <object data="web/demo/detailed_transcript_fullv3.mp4" width="100%" >
                              </object>
                            </video>
                        </div>
             		</div>

						
                    	<script src="javascript/indexGraphAccordion.js">
						</script>