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
                        <H2>Workshop Video/Slides 4/16/2015</H2>
                        <div style="margin-left:5px;text-align: center;">
                            Watch the workshop:<BR><BR>
                            <video id="demoVideo" width="250px"  controls="controls" poster="<%=webDir%>overview/slides2_150.png" preload="none">
                                    	<source src="<%=webDir%>demo/workshop.mp4" type="video/mp4">
                                        <source src="<%=webDir%>demo/workshop.webm" type="video/webm">
                                          <object data="<%=webDir%>demo/workshop.mp4" width="100%" >
                                          </object>
                                          Your browser is not likely to work with the Genome Browser if you are seeing this message.  Please see <a href="<%=commonDir%>siteRequirements.jsp">Browser Support/Site Requirements</a>
                                    </video>
                            <!--<a href="<%=webDir%>overview/PhenoGen.workshop.16Apr15.pdf"><img src="<%=webDir%>overview/slides_150.png" /></a>--><BR>
                                          OR<BR>
                            Download the slides from the Informatics Workshop <a href="<%=webDir%>overview/PhenoGen.workshop.16Apr15.pdf">here</A>.
                        </div>
                        <H2>v2.15 of PhenoGen 3/7/2015</H2>
                        <div style="margin-left:5px;">
                                <img src="<%=webDir%>overview/browseWGCNA_mir_150.png" /><img src="<%=webDir%>overview/browseWGCNA_go_150.png" /><BR />
                        	We've added GO term summary and miRNA targeting views to the Weighted Gene Co-expression Network Analysis.  Look at what's new for a summary of changes.
                        </div>
                        <H2>HTTPS support 2/9/2015</H2>
                        <div style="margin-left:5px;">
                        <%if(request.getServerPort()==80){%>
                        
                            We now support https to keep your connections more secure.  We will eventually redirect all traffic to the secure site, 
                            but for now feel free to try it out here: <a href="https://phenogen.ucdenver.edu/PhenoGen/"> https://phenogen.ucdenver.edu/PhenoGen/</a>
                        
                        <%}else{%>
                            
                            Thank you for trying the secure site.  You can always switch back to the regular site: <a href="http://phenogen.ucdenver.edu/PhenoGen/"> http://phenogen.ucdenver.edu/PhenoGen/</a>
                        
                        <%}%>
                        </div>
                        <H2>v2.14 of PhenoGen 1/10/2015</H2>
                        <div style="margin-left:5px;">
                                <img src="<%=webDir%>overview/browseWGCNA_150.png" /><img src="<%=webDir%>overview/browseWGCNA_eQTL_150.png"/><BR />
                        	We've added Weighted Gene Co-expression Network Analysis.  Look at what's new for a summary of changes.
                        </div>
                    	<H2>v2.13 of PhenoGen 9/27/2014</H2>
                        <div style="margin-left:5px;">
                        	We've updated PhenoGen.  Look at what's new for a summary of changes.
                        </div>
                    	<H2>Added multiMiR</H2>
                        <div style=" margin-left:5px;">
                        	<img src="<%=imagesDir%>multimir_300.png"/><BR />
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
                        <a href="web/graphics/genome.jsp"><img src="<%=imagesDir%>rnaseq_genome_100.gif" /></a>
                        <a href="web/graphics/transcriptome.jsp"><img src="<%=imagesDir%>rnaseq_transcriptome_100.gif" /></a>
                        </div><BR />
                        Reconstructed transcripts from this RNA-Seq data are still combined with PhenoGen array data in <a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=accessDir%>createAnnonymousSession.jsp?url=<%=contextRoot%>gene.jsp">Genome/Transcriptome Data Browser</a>.
                        </div>
                        
                   </div>
                                       
                    <script type="text/javascript">
                                  (function() {
                                        var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
                                        po.src = 'https://apis.google.com/js/platform.js';
                                        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
                                  })();
                    </script>
                    <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>

<%@ include file="/web/overview/ovrvw_js.jsp" %>