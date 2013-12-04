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

    

                	<H2>Browse Gene</H2>
                    <div id="accordion">
                    	<H3>Feature List</H3>
                        <div>
                        Interactively explore Genomic Data/Transcriptomic Data (including RNA-Seq and Microarray Data) along the genome around a gene of interest.
                        <ul>
                        	<li>View Rat Brain Isoforms from RNA-Seq transcriptome reconstruction</li>
                            <li>View Rat SNPs/Short Indels for BN-Lx/CubPrin, SHR/OlaPrin, F344, and SHR/NCrlPrin with more coming soon</li>
                            <li>View Ensembl Isoforms</li>
                            <li>View Affymetrix Microarray Probe set locations</li>
                            <li>View eQTLs for the gene</li>
                            <li>Access detailed Affy Exon 1.0 ST data</li>
                            	<ul>
                                	<li>Parental Strain Differential Expression(BN-Lx/SHR or ILS/ISS)</li>
                                    <li>Probe set Heritability/Detection Above Background across tissues</li>
                                    <li>Probe set Expression across strains and tissues</li>
                                    <li>Exon Correlation</li>
                                </ul>
                        </ul>
                        </div>
                        <h3>Sample Screen Shots</h3>
                        <div style="text-align:center">
                        An interactive SVG image of the region around the gene entered.  You have the option to zoom in/out, reorder tracks, add/customize tracks, click on features for more detailed data, and view the tables of all the features(see following screen shots).
                        <a class="fancybox" rel="fancybox-thumb" href="web/overview/browseGene.jpg" title="Region View showing the region around the gene entered."><img src="web/overview/browseGene.jpg"  style="width:100%;"  title="Click to view a larger image"/></a>
                        The lower part of the page when a gene is selected. Zooms in on the gene and shows all transcripts, allows you to add any other tracks including Affymetrix Probesets that can be colored based on data or annotation, and RNA-Seq read counts accross the area covered by the gene.
                        <a class="fancybox" rel="fancybox-thumb" href="web/overview/browseGene2.jpg" title="Gene View showing transcripts for the selected gene, and any other tracks that have been added."><img src="web/overview/browseGene2.jpg"  style="width:100%;"  title="Click to view a larger image"/></a>
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