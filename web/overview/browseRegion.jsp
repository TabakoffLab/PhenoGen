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
                        <div style="overflow:auto;display:inline-block;height:34%;width:100%;">
                        	<table>
                            <TR>
                            <TD>
                            	<video id="demoVideo" width="210px" controls="controls">
                                <source src="web/demo/detailed_transcript_fullv3.webm" type="video/webm">
                                <source src="web/demo/detailed_transcript_fullv3.mp4" type="video/mp4">
                              <object data="web/demo/detailed_transcript_fullv3.mp4" width="100%">
                              </object>
                            </video>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="An interactive SVG image of the region entered.  You have the option to zoom in/out, reorder tracks, add/customize tracks, click on features for more detailed data, and view the tables of all the features(see following screen shots).<BR>Click to view a larger image.">
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/browseRegion1.jpg" title="A UCSC Genome Browser image that includes the tracks selected below."><img src="web/overview/browseRegion1.jpg"  style="width:150px;" /></a></span>
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
                            </TR>
                            </table>
                        </div>
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
    