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
                    <div  style="overflow:auto;height:92%;width:100%;">
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
                        <BR /><BR />
                        <div >
                        	<H3 style="font-weight:bold;font-size:16px;">Try the genome browser:</H3>
                            <div style=" border:thin; border-color:#999999; border-style:solid; border-width:2px;margin-left:5px;margin-right:5px;">
                                <form method="post" action="gene.jsp" enctype="application/x-www-form-urlencoded"name="geneCentricForm" id="geneCentricForm">
                
                                    <label>Gene Identifier or Region:
                                        <input type="text" name="geneTxt" id="geneTxt" size="15" value=""><span class="tooltip2"  title="1. Enter a gene identifier(e.g. gene symbol, probe set ID, ensembl ID, etc.) in the gene field.<BR />or<BR />Enter a region such as<div style=&quot;padding-left:20px;&quot;>
                    &quot;chr1:1-50000&quot; which would be Chromosome 1 @ bp 1-50,000.<BR />
                    &quot;chr1:5000+-2000&quot; which would be Chromosome 1 @ bp 3,000-7,000.<BR />
                    &quot;chr1:5000+2000&quot; which would be Chromosome 1 @ bp 5,000-7,000.<BR />
                    </div>or<BR />Click on the Translate Region to Mouse/Rat to find regions on the Mouse/Rat genome that correspond to a region of interest in the Human/Mouse/Rat genome.<BR />
                2. Choose a species.<BR />
                3. Click Get Transcription Details."><img src="<%=imagesDir%>icons/info.gif"></span>
                                        </label>
                                        
                
               
                                  <label>Species:
                                  <select name="speciesCB" id="speciesCB">
                                    <option value="Mm" >Mus musculus</option>
                                    <option value="Rn" >Rattus norvegicus</option>
                                  </select>
                                  <span class="tooltip2"  title="Select the organism to view.  We currently support Rat(rn5) and Mouse(mm10)"><img src="<%=imagesDir%>icons/info.gif"></span>
                                  </label>
                                  <BR />
                                  <label>Initial View:
                                  <select name="defaultView" id="defaultView">
                                    <option value="viewGenome" >Genome</option>
                                    <option value="viewTrxome" >Transcriptome</option>
                                    <option value="viewAll" >Both</option>
                                  </select>
                                  <span class="tooltip2"  title="Select the types of feature/tracks to display.  You can customize the tracks after the region/gene opens, but this allows you to select where to start from."><img src="<%=imagesDir%>icons/info.gif"></span>
                                </label>
                                <BR />
                                	<input type="hidden" id="auto" value="Y" />
                                    <input type="hidden" name="action" id="action" value="Get Transcription Details" />
                                <span style="padding-left:10px;"> <input type="submit" name="goBTN" id="goBTN" value="Go" ></span>
         
                                </form>
                            </div>
                        </div>
                        <BR /><BR />
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
                        
                        <script type="text/javascript">
							$(".tooltip2").tooltipster({
								position: 'top-right',
								maxWidth: 350,
								offsetX: 5,
								offsetY: 5,
								contentAsHTML:true,
								//arrow: false,
								interactive: true,
								interactiveTolerance: 550
							});
                        </script>