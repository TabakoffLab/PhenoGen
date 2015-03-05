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

<table class="index" cellspacing="0" cellpadding="0">
    <tr><TD id="imageColumn" class="wide">
                    
                    	<div class="javascriptAlt">
                       		 <div style="color:#FF0000;">JavaScript is disabled.  Please enable JavaScript for this site.</div>
                             <BR /><BR />
                        	<h3>Click on a function in the list below to view additional information.</h3>
                    		<div style="width:100%;color:#FFFFFF;margin-left:20px;">
                            <H2>What can you do with PhenoGen?</H2>
                            
                            <ul style="color:#FFFFFF;">
                                <li>Gene List Analysis</li>
                                    <UL class="sub" style="margin-left:40px;">
                                        <li><a href="web/overview/glPathway.jsp">Pathway Analysis</a></li>
                                        <li><a href="web/overview/glValues.jsp">Statistics/Expression Values</a></li>
                                        <li><a href="web/overview/glCorr.jsp">Exon Expression Correlations</a></li>
                                        <li><a href="web/overview/glAnnot.jsp">Annotations</a></li>
                                        <li><a href="web/overview/glPromoter.jsp">Promoter Analysis</a></li>
                                        <li><a href="web/overview/glShare.jsp">Compare/Share</a></li>
                                        <li><a href="web/overview/glHomolog.jsp">Homologs</a></li>
                                        <li><a href="web/overview/glMultiMiR.jsp">multiMiR</a></li>
                                    </UL>
                                <li>Microarray Analysis</li>
                                    <UL class="sub" style="margin-left:40px;">
                                        <li><a href="web/overview/microAnalysis.jsp">Normalize->Statistics->GeneLists</a></li>
                                        <li ><a href="web/overview/microUpload.jsp">Upload Private Data</a></li>
                                        <li ><a href="web/overview/microShare.jsp">Share Data</a></li>
                                        <li ><a href="web/overview/microPublic.jsp">Access Public Data</a></li>
                                    </UL>
                                <li>Genome/Transcriptome Data Browser</li>
                                    <UL class="sub" style="margin-left:40px;">
                                        <li><a href="web/overview/browseGene.jsp">Browse a Region</a></li>
                                        <li><a href="web/overview/browseRegion.jsp">Browse by a Gene</a></li>
                                        <li><a href="web/overview/browseTranslate.jsp">Translate regions from one organism to another</a></li>
                                    </UL>
                                <li>Download Data</li>
                                    <UL class="sub" style="margin-left:40px;">
                                        <li><a href="web/overview/downloadMarker.jsp">Genomic Marker Files</a></li>
                                        <li><a href="web/overview/downloadHumanSNP.jsp">Human Whole Genome SNP Data</a></li>
                                        <li><a href="web/overview/downloadMicroarray.jsp">Microarray Data</a></li>
                                        <li><a href="web/overview/downloadRNASeq.jsp">RNA-Seq Data</a></li>
                                        <li ><a href="web/overview/downloadGenome.jsp">Strain Specific Genomes</a></li>
                                    </UL>
                                <li>QTL Analysis</li>
                                    <UL class="sub" style="margin-left:40px;">
                                        <li><a href="web/overview/qtlViz.jsp">Visualize eQTLs</a></li>
                                        <li><a href="web/overview/qtlCalc.jsp">Calculate bQTLs</a></li>
                                        <li><a href="web/overview/qtlList.jsp">Create eQTL Lists</a></li>
                                    </UL>
                                 <li>General Information</li>
                                    <UL class="sub" style="margin-left:40px;">
                                        <li><a href="web/overview/announce.jsp">Announcements</a></li>
                                        <li><a href="web/overview/curVer.jsp">What's New</a></li>
                                        <li><a href="web/overview/whats_new.jsp">Version Information</a></li>
                                    </UL>
                            </ul>
                            </div>
                     </div><!-- Alternate to javascript -->

                    <div id="svgAlternate1" class="svgAlternate" style="color:#FF0000; background-color:#FFFFFF;display:none;"><BR />Your browser does not seem to support SVG(Scalable Vector Graphics).  The list below will appear in a graphic when viewed with a browser supporting SVG, as all major current browsers support SVG (PhenoGen supports Chrome 25+, FireFox 23+,  IE 10+, Safari 6+) please install a different browser or update this browser to be able to use PhenoGen.  Some features will not work without SVG and more graphics will be migrating to SVG in the future.  While it is unlikely, please let us know if you receive this message and have a browser that meets the minimum supported version or higher. <BR /><BR /></div>
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
						$('div.javascriptAlt').hide();
						if(!document.implementation.hasFeature("http://www.w3.org/TR/SVG11/feature#BasicStructure", "1.1")){
							$('div.svgAlternate').show();
							$('ul.sub li').click(function (){
										$('#announcement').hide();
										//$('#announcementSmall').show();
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
							
							//$('div.svgAlternate').hide();
							//$('div#svgInst').show();
						}
						var selectedSection=0;
                    </script>
                <div id="indexImage" >
                    <script src="javascript/indexGraph1.2.3.js"></script>
                </div>
                    
                    </TD>
                    <TD  id="descColumn"  class="narrow">
                    
                    
                    <div id="indexDesc" style="display:none;border-color:#000000; border-style:solid; border-width:1px; background-color:#FFFFFF; color:#000000;">
                            <span id="expandBTN" class="expandSect" style=" float:left; position:relative; top:9px; cursor:pointer;"><img src="web/images/icons/expand_section.jpg"></span>
                            <div id="indexDescContent" style="height:750px;width:335px;">
                            </div>
                            
        			</div>
                    </TD>
                    </tr>
                    </table>
                    
                    <script type="text/javascript">
						var contentWidth="335px";
						$('#expandBTN').click( function () {
							if($(this).attr("class")=="expandSect"){
								$(this).removeClass("expandSect").addClass("minSect");
								$('#indexImage svg').attr("width","335px");
								$('#imageColumn').removeClass("wide").addClass("narrow");
								$('#descColumn').removeClass("narrow").addClass("wide");
								$('#expandBTN img').attr("src","web/images/icons/minimize_section.jpg");
								//$('#demoVideo').attr("width","580px");
								//shiftLeft();
								width=335;
								contentWidth="660px";
								setXSpacing(180);
								redraw();
								
							}else{
								$(this).removeClass("minSect").addClass("expandSect");
								$('#descColumn').removeClass("wide").addClass("narrow");
								$('#imageColumn').removeClass("narrow").addClass("wide");
								$('#indexImage svg').attr("width","660px");
								$('#expandBTN img').attr("src","web/images/icons/expand_section.jpg");
								//$('#demoVideo').attr("width","260px");
								//shiftRight();
								width=660;
								contentWidth="335px";
								setXSpacing(240);
								redraw();
							}
							$('#indexDescContent').css("width",contentWidth);
						});
                    </script>

    