<%--
 *  Author: Spencer Mahaffey
 *  Created: August, 2012
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<style>

.node circle {
  stroke: #fff;
  stroke-width: 1.5px;
}

.link, .desclink {
  stroke: #999;
  stroke-opacity: .6;
}

div.svgAlternate ul {
	color:#FFFFFF;
	margin-left:25px;
}

div.svgAlternate ul.sub li {
	cursor:pointer;
	text-decoration:underline;
}

div#announcement a:hover, div#announcementSmall a:hover {
	color:#547BA1;
}

</style>

					
                    <div id="announcementSmall" style="display:none;background-color:#FFFFFF; width:100%;min-height:20px; max-height:150px; position:relative;color:#000000; font-weight:bold;">
                    	NEW! RNA-Seq data summary graphics available. Click one 
                        <a href="web/graphics/genome.jsp">Genome</a>
                        <a href="web/graphics/transcriptome.jsp">Transcriptome</a>
    				</div>
					<table class="index" cellspacing="0" cellpadding="0">
                    <tr><TD id="imageColumn" class="wide">
                    <div id="svgInst" style="display:none;">
                    	<h3 title="If you do not see a graph below please go to Help->Browser Support.">Hover over or click on nodes in the graph below to see the tools/data available on the site.</h3>
                    </div>
                    <div id="svgAlternate1" class="svgAlternate" style="color:#FF0000; background-color:#FFFFFF;"><BR />Your browser does not seem to support SVG(Scalable Vector Graphics).  The list below will appear in a graphic when viewed with a browser supporting SVG, as all major current browsers support SVG (PhenoGen supports Chrome 25+, FireFox 23+,  IE 10+, Safari 6+) please install a different browser or update this browser to be able to use PhenoGen.  Some features will not work without SVG and more graphics will be migrating to SVG in the future.  While it is unlikely, please let us know if you receive this message and have a browser that meets the minimum supported version or higher. <BR /><BR /></div>
                    <div id="svgAlternate2" class="svgAlternate" >
                    	<BR /><BR />
                        <h3>Click on a function in the list below to view additional information.</h3>
                    <H2>What can you do with PhenoGen?</H2>
                    	 <div id="svgAlternate3" class="svgAlternate" style="color:#FF0000;">JavaScript is disabled.  Please enable JavaScript for this site.  The links below will not work until JavaScript is enabled.</div>
                    	<ul>
                        	<li>Gene List Analysis</li>
                            	<UL class="sub">
                                	<li id="glPathway">Pathway Analysis</li>
                                    <li id="glValues">Statistics/Expression Values</li>
                                    <li id="glCorr">Exon Expression Correlations</li>
                                    <li id="glAnnot">Annotations</li>
                                    <li id="glPromoter">Promoter Analysis</li>
                                    <li id="glShare">Compare/Share</li>
                                    <li id="glHomolog">Homologs</li>
                                </UL>
                            <li>Microarray Analysis</li>
                            	<UL class="sub">
                                	<li id="microAnalysis">Normalize->Statistics->GeneLists</li>
                                    <li id="microUpload">Upload Private Data</li>
                                    <li id="microShare">Share Data</li>
                                    <li id="microPublic">Access Public Data</li>
                                </UL>
                            <li>Genome/Transcriptome Data Browser</li>
                            	<UL class="sub">
                                	<li id="browseGene">Browse a Region</li>
                                    <li id="browseRegion">Browse by a Gene</li>
                                    <li id="browseTranslate">Translate regions from one organism to another</li>
                                </UL>
                            <li>Download Data</li>
                            	<UL class="sub">
                                	<li id="downloadMarker">Genomic Marker Files</li>
                                    <li id="downloadHumanSNP">Human Whole Genome SNP Data</li>
                                    <li id="downloadMicroarray">Microarray Data</li>
                                    <li id="downloadRNASeq">RNA-Seq Data</li>
                                    <li id="downloadGenome">Strain Specific Genomes</li>
                                </UL>
                            <li>QTL Analysis</li>
                            	<UL class="sub">
                                	<li id="qtlViz">Visualize eQTLs</li>
                                    <li id="qtlCalc">Calculate bQTLs</li>
                                    <li id="qtlList">Create eQTL Lists</li>
                                </UL>
                        </ul>
                     </div><!-- Alternate to SVG -->
                    <script type="text/javascript">
						if(!document.implementation.hasFeature("http://www.w3.org/TR/SVG11/feature#BasicStructure", "1.1")){
							$('ul.sub li').click(function (){
										$('#announcement').hide();
										$('#announcementSmall').show();
										var jspPage=$(this).attr("id")+".jsp";
										selectedSection= $( "#accordion" ).accordion( "option", "active" );
										$('#indexDesc').slideUp("250");
										$('div#indexDescContent').html("<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Laoding...</span>");
										$.ajax({
													url: "web/overview/"+jspPage,
   													type: 'GET',
													dataType: 'html',
													success: function(data2){ 
														$('div#indexDescContent').html(data2);
													},
													error: function(xhr, status, error) {
														$('div#indexDescContent').html("<H2>ERROR</H2><BR><BR><span style=\"text-align:center;width:100%;color:#FF0000;\">An error has occured please view another node and try this node again.</span>"+error);
													}
										});
										/*d3.html("web/overview/"+jspPage,function(error,html){
																 if(error==null){
																	 $('div#indexDescContent').html(html);
																	 //$('div#indexDesc').show();
																 }else{
																	 $('div#indexDescContent').html("<H2>ERROR</H2><BR><BR><span style=\"text-align:center;width:100%;color:#FF0000;\">An error has occured please view another node and try this node again.</span>"+error);
																 }
																 });*/
										$('#indexDesc').slideDown("250");
								});
						}else{
							$('div.svgAlternate').hide();
							$('div#svgInst').show();
						}
						var selectedSection=0;
                    </script>
                	<div id="indexImage" >
                    <script src="javascript/indexGraph.js">
					</script>
                    </div>
                    
                    </TD>
                    <TD  id="descColumn"  class="narrow">
                    
                    <div id="announcement" style="background-color:#FFFFFF; width:100%;min-height:300px; max-height:650px; position:relative;color:#000000; overflow:auto; ">
                    	<H2>Added multiMiR</H2>
                        <div style=" margin-left:5px;">
                        	<img src="<%=imagesDir%>multimir.png" width="300px"/><BR />
                        	Using multiMiR(an R package available <a href="http://multimir.ucdenver.edu/" target="_blank">here</a>) you can view validated and predicted miRNAs that target specific genes.  You can also select a miRNA and view all genes targeted by the miRNA.  multiMiR is avaialble as a new tab for a selected gene in the Genome/Transcriptome Data Browser. It is currently available only for mouse genes, but will be available in rat soon.
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
                    <div id="indexDesc" style="display:none;border-color:#000000; border-style:solid; border-width:1px; background-color:#FFFFFF; color:#000000;">
                            <span id="expandBTN" class="expandSect" style=" float:left; position:relative; top:9px; cursor:pointer;"><img src="web/images/icons/expand_section.jpg"></span>
                            <div id="indexDescContent" style="height:650px;">
                            </div>
                            
        			</div>
                    </TD>
                    </tr>
                    </table>
                    
                    <script type="text/javascript">
						$('#expandBTN').click( function () {
							if($(this).attr("class")=="expandSect"){
								$(this).removeClass("expandSect").addClass("minSect");
								$('#indexImage svg').attr("width","335px");
								$('#imageColumn').removeClass("wide").addClass("narrow");
								$('#descColumn').removeClass("narrow").addClass("wide");
								$('#expandBTN img').attr("src","web/images/icons/minimize_section.jpg");
								$('#demoVideo').attr("width","580px");
								//shiftLeft();
								width=335;
								setXSpacing(180);
								redraw();
								
							}else{
								$(this).removeClass("minSect").addClass("expandSect");
								$('#descColumn').removeClass("wide").addClass("narrow");
								$('#imageColumn').removeClass("narrow").addClass("wide");
								$('#indexImage svg').attr("width","660px");
								$('#expandBTN img').attr("src","web/images/icons/expand_section.jpg");
								$('#demoVideo').attr("width","260px");
								//shiftRight();
								width=660;
								setXSpacing(240);
								redraw();
							}
						});
                    </script>

    