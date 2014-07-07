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
                    <div  style="overflow:auto;height:92%;">
                    	<H3>Demo/Screen Shots</H3>
                        <div style="overflow:auto;display:inline-block;height:34%;width:100%;">
                        	<table>
                            <TR>
                            <TD>
                            	
                                <video id="demoVideo" width="210px"  controls="controls">
                                    <source src="web/demo/detailed_transcript_fullv3.webm" type="video/webm">
                                    <source src="web/demo/detailed_transcript_fullv3.mp4" type="video/mp4">
                                  <object data="web/demo/detailed_transcript_fullv3.mp4" width="100%" >
                                  </object>
                                </video>
                                
                                </TD>
                                <TD>
                                <span class="tooltip"  title="An interactive SVG image of the region around the gene entered.  You have the option to zoom in/out, reorder tracks, add/customize tracks, click on features for more detailed data, and view the tables of all the features(see following screen shots).<BR>Click to view a larger image.">
                        		<a class="fancybox" rel="fancybox-thumb" href="web/overview/browseGene.jpg" title="Region View showing the region around the gene entered."><img src="web/overview/browseGene.jpg"  style="width:150px;"/></a>
                            	</span>
                            </TD>
                            <TD>
                            	<span class="tooltip"  title="The lower part of the page when a gene is selected. Zooms in on the gene and shows all transcripts, allows you to add any other tracks including Affymetrix Probesets that can be colored based on data or annotation, and RNA-Seq read counts accross the area covered by the gene.<BR>Click to view a larger image.">
                            	<a class="fancybox" rel="fancybox-thumb" href="web/overview/browseGene2.jpg" title="Gene View showing transcripts for the selected gene, and any other tracks that have been added."><img src="web/overview/browseGene2.jpg"  style="width:150px;"  title="Click to view a larger image"/></a></span>
                      
                            </TD>
                            <TD>
                            <span class="tooltip"  title="eQTL view showing what regions are associated with expression in each available tissue.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/qtlViz.jpg" title="eQTL view showing what regions are associated with expression in each available tissue:"><img src="web/overview/qtlViz.jpg"  style="width:150px;" /></a>
                            </span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="When a gene is selected the multiMiR tab is available which provides a list of validated/predicted miRNAs that target the gene.  You can view additional details on each miRNA/database hit and find all targets of an miRNA.<BR>Click to view a larger image.">
                             <a class="fancybox" rel="fancybox-thumb" href="web/images/multimir.png" title="multiMiR results for a selected gene."><img src="web/images/multimir.png"  style="width:150px;" /></a>
                             </span>
                        	</TD>
                            </TR>
                            </table>
                        </div>
                    	<H3>Feature List</H3>
                        <div>
                        Interactively explore Genomic Data/Transcriptomic Data (including RNA-Seq and Microarray Data) along the genome or around a gene of interest.
                        <ul>
                        	<li>View Rat Brain and Liver Isoforms from RNA-Seq transcriptome reconstruction</li>
                            <li>View Rat SNPs/Short Indels for BN-Lx/CubPrin, SHR/OlaPrin, F344, and SHR/NCrlPrin with more coming soon</li>
                            <li>View Ensembl and RefSeq Isoforms</li>
                            <li>View Affymetrix Microarray Probe set locations</li>
                            <li>View eQTLs for the gene</li>
                            <li>View validated/predicted miRNAs targeting the selected gene. Further you can view additional detail and view all genes targeted by a particular miRNA.</li>
                            <li>Import your own tracks currently support for small &lt;20MB bed files is available.</li>
                            <li>Access detailed Affy Exon 1.0 ST data</li>
                            	<ul>
                                	<li>Parental Strain Differential Expression(BN-Lx/SHR or ILS/ISS)</li>
                                    <li>Probe set Heritability/Detection Above Background across tissues</li>
                                    <li>Probe set Expression across strains and tissues</li>
                                    <li>Exon Correlation</li>
                                </ul>
                        </ul>
                        </div>
                        
             		</div>

						
                    	<script src="javascript/indexGraphAccordion1.0.js">
						</script>