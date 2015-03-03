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

    
					<H2>Announcements</H2>
                    <div  style="overflow:auto;height:92%;">
                        <H2>v2.15 of PhenoGen 3/7/2015</H2>
                        <div style="margin-left:5px;">
                                <img src="<%=webDir%>overview/browseWGCNA_mir.png" width="150px"/><img src="<%=webDir%>overview/browseWGCNA_go.png" width="150px"/><BR />
                        	We've added GO term summary and miRNA targeting views to the Weighted Gene Co-expression Network Analysis.  Look at what's new for a summary of changes.
                        </div>
                        <H2>HTTPS support 2/9/2015</H2>
                        <div style="margin-left:5px;">
                        <%if(request.getServerPort()==80){%>
                        
                            We now support https to keep your connections more secure.  We will eventually redirect traffic all to the secure site, 
                            but for now feel free to try it out here: <a href="https://phenogen.ucdenver.edu/PhenoGen/"> https://phenogen.ucdenver.edu/PhenoGen/</a>
                        
                        <%}else{%>
                            
                            Thank you for trying the secure site.  You can always switch back to the regular site: <a href="http://phenogen.ucdenver.edu/PhenoGen/"> http://phenogen.ucdenver.edu/PhenoGen/</a>
                        
                        <%}%>
                        </div>
                        <H2>v2.14 of PhenoGen 1/10/2015</H2>
                        <div style="margin-left:5px;">
                                <img src="<%=webDir%>overview/browseWGCNA.png" width="150px"/><img src="<%=webDir%>overview/browseWGCNA_eQTL.png" width="150px"/><BR />
                        	We've added Weighted Gene Co-expression Network Analysis.  Look at what's new for a summary of changes.
                        </div>
                    	<H2>v2.13 of PhenoGen 9/27/2014</H2>
                        <div style="margin-left:5px;">
                        	We've updated PhenoGen.  Look at what's new for a summary of changes.
                        </div>
                    	<H2>Added multiMiR</H2>
                        <div style=" margin-left:5px;">
                        	<img src="<%=imagesDir%>multimir.png" width="300px"/><BR />
                        	Using multiMiR(an R package available <a href="http://multimir.ucdenver.edu/" target="_blank">here</a>) you can view validated and predicted miRNAs that target specific genes.  You can also select a miRNA and view all genes targeted by the miRNA.  multiMiR is avaialble as a new tab for a selected gene in the Genome/Transcriptome Data Browser and in Gene Lists after selecting a list. It is currently available only for mouse genes, but will be available in rat soon.
                        </div>
                        <H2>Added Rat Liver Transcriptome</H2>
                        <div style=" margin-left:5px;">
                        	We've added rat liver tracks including, a transcriptome reconstructiong track, splice junction track, and stranded read depth count tracks.  Available in the Genome/Transcriptome Browser.
                        </div>
                    	<H2>Follow on Facebook/Google+/Twitter</H2>
                        <div style=" margin-left:5px;">
                        	Follow PhenoGen to keep up with new features, demonstrations, and help by providing feedback to direct future updates.<BR />
                           	<div style="float:left;display:inline-block;position:relative;top:0px;padding-right:5px;">  	
                                <div class="fb-follow" data-href="https://www.facebook.com/phenogen" data-width="50px" data-height="16px" data-colorscheme="dark" data-layout="button" data-show-faces="true"></div>
                           	</div>
                            <div style="float:left;display:inline-block;">
                            <div class="g-follow" data-annotation="none" data-height="20" data-href="https://plus.google.com/104166350576727657445" data-rel="publisher"></div>
                            	<a href="https://twitter.com/phenogen" class="twitter-follow-button" data-show-count="false" data-show-screen-name="false" data-lang="en" style="margin-top:5px;"></a>
                          	</div>
                           
                            <BR /><BR />
                        </div>
                    	<H2>RNA-Seq Data Summary Graphics</H2>
                        <div style=" margin-left:5px;">
                    	Rat Brain RNA-Seq data summary graphics are now available. Click below to browse the RNA-Seq data summary:<BR />
                        <div style="text-align:center;">
                        <ul>
                        <li><a href="web/graphics/genome.jsp">View Genome Coverage</a></li>
                        <li><a href="web/graphics/transcriptome.jsp">View Reconstructed Long RNA Genes(Rat Brain Transcriptome)</a></li>
                        </ul>
                        <a href="web/graphics/genome.jsp"><img src="<%=imagesDir%>rnaseq_genome.gif" width="100px"/></a>
                        <a href="web/graphics/transcriptome.jsp"><img src="<%=imagesDir%>rnaseq_transcriptome.gif" width="100px"/></a>
                        </div><BR />
                        Reconstructed transcripts from this RNA-Seq data are still combined with PhenoGen array data in <a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=accessDir%>createAnnonymousSession.jsp?url=<%=contextRoot%>gene.jsp">Genome/Transcriptome Data Browser</a>.
                        </div>
                        
                   </div>

<script src="javascript/indexGraphAccordion1.0.js">
						</script>