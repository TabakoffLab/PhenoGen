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

    
                	<H2>Browse Region</H2>
                    <div  style="overflow:auto;height:92%;">
                    	<H3>Demo/Screen Shots</H3>
                        <div style="overflow:auto;display:inline-block;height:34%;width:100%; max-width:660px;">
                        	<table>
                            <TR>
                            <TD>
                            		General Overview of Tools
                                    <video id="demoVideo" width="210px"  controls="controls" poster="<%=contextRoot%>web/demo/detailed_transcript_fullv3.png">
                                        <source src="web/demo/detailed_transcript_fullv3.webm" type="video/webm">
                                        <source src="web/demo/detailed_transcript_fullv3.mp4" type="video/mp4">
                                      <object data="web/demo/detailed_transcript_fullv3.mp4" width="100%" >
                                      </object>
                                    </video>
                                
                                </TD>
                                <TD>
                                	Basic Browser Navigation
                                <video width="210px" controls="controls" poster="<%=contextRoot%>web/demo/BrowserNavDemo.png">
                                    <source src="web/demo/BrowserNavDemo.mp4" type="video/mp4">
                                    <source src="web/demo/BrowserNavDemo.webm" type="video/webm">
                                    <object data="web/demo/BrowserNavDemo.mp4" width="100%" >
                                                  </object>
                                </video>
                                </TD>
                                <TD>
                                	Setting up Custom Tracks/Views
                                <video width="210px" controls="controls" poster="<%=contextRoot%>web/demo/customTrackDemo.png">
                                    <source src="web/demo/customTrackDemo.mp4" type="video/mp4">
                                    <source src="<%=contextRoot%>web/demo/customTrackDemo.webm" type="video/webm">
                                  <object data="<%=contextRoot%>web/demo/customTrackDemo.mp4" width="100%" >
                                  </object>
                                </video>
                                </TD>
                            <TD>
                            <span class="tooltip"  title="An interactive SVG image of the region entered.  You have the option to zoom in/out, reorder tracks, add/customize tracks, click on features for more detailed data, and view the tables of all the features(see following screen shots).<BR>Click to view a larger image.">
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/browseRegion1.jpg" title="A interactive SVG image that includes the tracks selected below."><img src="web/overview/browseRegion1.jpg"  style="width:150px;" /></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="Another view of the interactive SVG image of the region entered.  You have the option to zoom in/out, reorder tracks, add/customize tracks, click on features for more detailed data, and view the tables of all the features(see following screen shots).<BR>Click to view a larger image.">
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/browser_region.jpg" title="A interactive SVG image that includes the tracks selected below."><img src="web/overview/browser_region.jpg"  style="width:150px;" /></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="The far left side of the table of features in the region.  This includes any annotation available from ensembl, and links to various databases for the given gene.  For rats this also includes any RNA-Seq reconstructed transcripts along with a description of how closely they match an Ensembl annotated transcript.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/browseRegion2.jpg" title="The far left side of the table of features in the region.  This includes any annotation available from ensembl, and links to various databases for the given gene.  For rats this also includes any RNA-Seq reconstructed transcripts along with a description of how closely they match an Ensembl annotated transcript."><img src="web/overview/browseRegion2.jpg"  style="width:150px;" /></a></span>
                            </TD>
                            <TD>
                            	<span class="tooltip"  title="The second half of the table above, which shows information about the gene's location.  In rats it includes information about Exonic SNPs and Indels.  It also briefly summarizes expression data by providing the total # of probe sets that cover both exons and introns, and then the number of probe sets detected above background and the number with a more interesting level of heritability across the Recombinant Inbred Panel(BXH/HXB for rats or ILS/ISS for mice).<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/browseRegion3.jpg" title="The second half of the table above, which shows information about the gene's location.  In rats it includes information about Exonic SNPs and Indels.  It also breifly summarizes expression data by providing the total # of probesets that cover both exons and introns, and then the number of probesets detected above background and the number with a more interesting level of heritability across the Recombinant Inbred Panel(BXH/HXB for rats or ILS/ISS for mice)."><img src="web/overview/browseRegion3.jpg"  style="width:150px;" /></a></span>
                            </TD>
                            <TD>
                             <span class="tooltip"  title="The default view for behavioral Quantitative Trait Loci(bQTL).  Showing information about the trait, linking to publications, and linking to candidate genes or the entire region for the bQTL.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/browseRegion4.jpg" title="The default view for behavioral Quantitative Trait Loci(bQTL).  Showing information about the trait, linking to publications, and linking to candidate genes or the entire region for the bQTL."><img src="web/overview/browseRegion4.jpg"  style="width:150px;"/></a></span>
                            </TD>
                            <TD>
                            	<span class="tooltip"  title="A Circos plot that shows the locations of the genes with an eQTL in the region.  Below this image a table summarizes the data available for each gene.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/browseRegion5.jpg" title="A Circos plot that shows the locations of the genes with an eQTL in the region.  Below this image a table sumarizes the data available for each gene."><img src="web/overview/browseRegion5.jpg"  style="width:150px;" /></a></span>
                            </TD>
                            <TD>
                            	<span class="tooltip"  title="Image showing an overview of the basic controls.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/GeneCentric/help1.jpg" title="Image showing an overview of the basic controls."><img src="web/GeneCentric/help1.jpg"  style="width:150px;" /></a></span>
                            </TD>
                            <TD>
                            	<span class="tooltip"  title="Image showing an overview of the controls for selecting and editing views.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/GeneCentric/help2.jpg" title="Image showing an overview of the controls for selecting and editing views."><img src="web/GeneCentric/help2.jpg"  style="width:150px;" /></a></span>
                            </TD>
                            <TD>
                            	<span class="tooltip"  title="Image showing an overview of the controls for selecting and editing tracks.  <BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/GeneCentric/help3.jpg" title="Image showing an overview of the controls for selecting and editing tracks."><img src="web/GeneCentric/help3.jpg"  style="width:150px;" /></a></span>
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
                        Interactively explore Genomic Data/Transcriptomic Data (including RNA-Seq and Microarray Data) along a region of the genome.
                        <ul>
                        	<li>View Rat Brain Isoforms from RNA-Seq transcriptome reconstruction</li>
                            <li>View Rat SNPs/Short Indels for BN-Lx/CubPrin, SHR/OlaPrin, F344, and SHR/NCrlPrin with more coming soon</li>
                            <li>View Ensembl Isoforms</li>
                            <li>View Affymetrix Exon 1.0 ST Microarray Probe set locations</li>
                            <li>View bQTLs</li>
                            <li>View eQTLs for the genes in the region</li>
                            <li>View genes with an eQTL in the region</li>
                            
                            
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