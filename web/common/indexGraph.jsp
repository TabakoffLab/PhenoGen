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

</style>

					<div id="svgAlternate1" class="svgAlternate" style="display:none;color:#FF0000; background-color:#FFFFFF;"><BR />Your browser does not seem to support SVG(Scalable Vector Graphics).  The list below will appear in a graphic when viewed with a browser supporting SVG, as all major current browsers support SVG (PhenoGen supports Chrome 25+, FireFox 20+,  IE 9+, Safari 5+) please install a different browser or update this browser to be able to use PhenoGen.  Some features will not work without SVG and more graphics will be migrating to SVG in the future.  While it is unlikely, please let us know if you receive this message and have a browser that meets the minimum supported version or higher. <BR /><BR /></div>
					<table class="index" cellspacing="0" cellpadding="0">
                    <tr><TD id="imageColumn" class="wide">
                    <div id="svgInst">
                    	<h3>Hover over or click on functions to view additional information.</h3>
                    </div>
                    <div id="svgAlternate2" class="svgAlternate" style="display:none;">
                    	<BR /><BR />
                        <h3>Click on a function in the list below to view additional information.</h3>
                    <H2>What can you do with PhenoGen?</H2>
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
                            <li>Detailed Genome/Transcriptome Information</li>
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
							$('div.svgAlternate').show();
							$('div#svgInst').hide();
							$('ul.sub li').click(function (){
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
						}
						var selectedSection=0;
                    </script>
                	<div id="indexImage" >
                    	<script src="javascript/indexGraph.js">
						</script>
                    </div>
                    
                    </TD>
                    <TD  id="descColumn"  class="narrow">
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

    