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
                        

                        //Fix for IE9  which is missing this function used by D3
                        if (/MSIE[\/\s](\d+[_\.]\d+)/.test(navigator.userAgent)){
                                if (typeof Range.prototype.createContextualFragment == "undefined") {
                                    Range.prototype.createContextualFragment = function(html) {
                                        var startNode = this.startContainer;
                                        var doc = startNode.nodeType == 9 ? startNode : startNode.ownerDocument;
                                        var container = doc.createElement("div");
                                        container.innerHTML = html;
                                        var frag = doc.createDocumentFragment(), n;
                                        while ( (n = container.firstChild) ) {
                                            frag.appendChild(n);
                                        }
                                        return frag;
                                    };
                                }
                        }



                        function showDiv(jspPage){
                                //$('#announcement').hide();
                                //$('#announcementSmall').show();
                                selectedSection= $( "#accordion" ).accordion( "option", "active" );
                                $('#indexDesc').slideUp("250");
                                $('div#indexDescContent').html("<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Loading...</span>");
                                $.ajax({
                                    url:  "web/overview/"+jspPage,
                                    type: 'GET',
                                    async: true,
                                    cache: true,
                                    data: {},
                                    success: function(htmlPage){
                                        $('div#indexDescContent').html(htmlPage);
                                    },
                                    error: function(xhr, status, error) {
                                        $('div#indexDescContent').html("<H2>ERROR</H2><BR><BR><span style=\"text-align:center;width:100%;color:#FF0000;\">An error has occured please view another node and try this node again.</span>"+error);
                                    }                
                                });
                                $('#indexDesc').slideDown("250");
                        }

                        function hideDiv(){
                                $('#indexImage svg').attr("width","660px");
                                width=660;
                                $('div#indexDesc').hide();
                        }

                        function setXSpacing(newSpace){
                                xSpacing=newSpace;
                                if(xSpacing<=200){
                                        xLevel[0]=-radius*1.3;
                                        xLevel[1]=radius;
                                        xLevel[2]=xLevel[1]+xSpacing;
                                }else{
                                        xLevel[0]=radius*1.3;
                                        xLevel[1]=xLevel[0]+xSpacing;
                                        xLevel[2]=xLevel[1]+xSpacing;
                                }
                        }


                        var width = 660,
                            height = 1100,
                            //height = 925,
                                radius = 50;
                        var charWidth=7.5;
                        var xSpacing=240;
                        var ySpacing = 115;
                        var displayClassStr="";
                        var curSelectedID="";
                        var descLineX=0;
                        var descLineY=0;

                        var displayOverride=0;

                        var xLevel=new Array();
                        xLevel[0]=radius*1.3;
                        xLevel[1]=xLevel[0]+xSpacing;
                        xLevel[2]=xLevel[1]+xSpacing;

                        var yPos=new Array();

                        var middle=height/2-50;

                        var mouseEnter=NaN;

                        var graphData;
                        var touchEventTimer=new Date().getTime();



                        var color = d3.scale.category20();



                        var svg = d3.select("div#indexImage").append("svg")
                            .attr("width", width)
                            .attr("height", height)
                                .style("background-color",d3.rgb("#1F344F"));

                        var boxLineTop=svg.append("line").attr("x1", 0)
                                .attr("y1", 0)
                                .attr("x2", 0)
                                .attr("y2", 0).style("stroke-width",2).attr("class","desclink");
                        var boxLineBottom=svg.append("line").attr("x1", 0)
                                .attr("y1", 0)
                                .attr("x2", 0)
                                .attr("y2", 0).style("stroke-width",2).attr("class","desclink");	
                        d3.json("top.json", function(error, graph) {
                                graphData=graph;
                          var link = svg.selectAll(".link")
                              .data(graph.links)
                            .enter().append("line")
                              .attr("class", function(d){
                                                                                  var classStr="link";
                                                                                  if(d.target>0){
                                                                                          //classStr="secondLink";
                                                                                          classStr=graph.nodes[d.target].groupName+" link detail";
                                                                                  }
                                                                                  return classStr;
                                                                                  })
                              .style("stroke-width", function(d) { 
                                                                                                                var stroke=2;
                                                                                                                if(d.target>0){
                                                                                                                        stroke=0;
                                                                                                                }
                                                                                                  return stroke; 
                                                                                                });

                          var inst=svg.append("g").attr("transform","translate(5,5)").attr("id","instructBox");
                          inst.append("rect")
                                                                .attr("width",250).attr("height",160)
                                                                .attr("rx",5).attr("ry",5)
                                                                .style("fill","#FFFFFF");

                            inst.append("text").style("color","#000000").style("font-size","18px")
                                                                .attr("x",10).attr("y",20)
                                                                .text("Hover over or click on nodes");

                            inst.append("text").style("color","#000000").style("font-size","18px")
                                                                .attr("x",10).attr("y",40)
                                                                .text("in the graph below to see the");
                            inst.append("text").style("color","#000000")
                                                                .attr("x",10).attr("y",60).style("font-size","18px")
                                                                .text("tools/data available on the");
                            inst.append("text").style("color","#000000")
                                                                .attr("x",10).attr("y",80).style("font-size","18px")
                                                                .text("site.");
                            inst.append("text").style("stroke","#2d7a32")
                                                                .attr("x",10).attr("y",100).style("font-size","18px")
                                                                .text("Green no login required.");
                            inst.append("text").style("stroke","#3e698c")
                                                                .attr("x",10).attr("y",120).style("font-size","18px")
                                                                .text("Blue sections require a login.");
                            inst.append("text").style("stroke","#688eb3").style("fill","#688eb3").style("text-decoration","underline").style("cursor","pointer")
                                                                .attr("x",10).attr("y",140).style("font-size","18px")
                                                                .attr("id","pauseTxt")
                                                                .on("click",animationToggle)
                                                                .text("Pause");


                          var node = svg.selectAll(".node")
                              .data(graph.nodes)
                            .enter().append("g")
                            .attr("transform", function(d){
                                var x=0;
                                var y=350;
                                x=xLevel[d.level];
                                if( yPos[d.level]==undefined){
                                                yPos[d.level]=0;
                                }
                                var tmp=0;
                                if(d.level<2){
                                        yPos[d.level]++;
                                        tmp=Math.floor(yPos[d.level]/2);
                                        tmp=tmp*ySpacing;
                                        if(yPos[d.level]%2==1){
                                                tmp=tmp*-1;
                                        }
                                }else{
                                        tmp=-radius-middle-200;
                                    }
                                y=middle+tmp;
                                var ret="translate("+x+","+y+")";
                                d.x=x;
                                d.y=y;
                                return ret;
                            })
                                .style("opacity", function (d){ var op=1;
                                                                                          if(d.level>1){
                                                                                                  op=0;
                                                                                          }
                                                                                          return op;
                                                                                          })
                                .style("cursor","pointer")
                                .attr("id",function(d){return "d"+d.id})
                                .attr("class", function(d,i){
                                                                                        var classStr="mainFeature";
                                                                                if(i==0){
                                                                                        classStr="centerNode";
                                                                                }else if(d.level>1){
                                                                                                  classStr=d.groupName+" detail";
                                                                                }
                                                                                return classStr;
                                                                                })
                                .on("mouseenter",function(d){
                                                                                  mouseEnter=new Date().getTime();
                                                                                  })
                                .on("mouseexit",function(d){
                                                                                 mouseEnter=NaN;
                                                                                 })
                                .on("touchstart",function(d){
                                        d3.event.preventDefault();
                                        mouseEnter=new Date().getTime()-100;
                                        animationStop();
                                        displayOverride=1;
                                        hoverClickNode(d);
                                        mouseEnter=NaN;
                                })
                                .on("mouseover",hoverClickNode)
                                .on("click",hoverClickNode);
                                /*.on("touchstart",function(d){
                                        alert(touchEventTimer);
                                        animationStop();
                                        displayOverride=1;
                                        hoverClickNode(d);
                                });*/

                                node.append("circle")
                              .attr("r",function(d,i) { var r=radius; if(i==0){r=r*1.3;} return r; })
                              .style("fill", function(d) {
                                        var col=color(d.group);
                                        if(d.group==2 || d.group==3 || d.group==6 || d.group==7){ 
                                                col=d3.rgb("#2d7a32");
                                        }else if(d.group>3){
                                                col=d3.rgb("#3e698c");
                                        }
                                        return col; 
                              })
                                  .style("stroke",d3.rgb("#999999"));

                                node.each( function(d,i){
                                                                          var txt=d3.select(this).append("text").style("fill",d3.rgb("#FFFFFF"))
                                                                                                .style("font-size", "14px")
                                                                                                .attr("x",function(d) { return (radius*-1)+3;})
                                                                                                .attr("y",0);
                                                                                var lines2=wordWrap(d);
                                                                                txt.append("tspan").text(lines2[0])
                                                                                                .attr("x",function(d) { var len=new String(lines2[0]).length;
                                                                                                                                                var x=0;
                                                                                                                                                x=x-(len*charWidth/2);
                                                                                                                                                return x;})
                                                                                                .attr("y",function(d){
                                                                                                                                   var y=0;

                                                                                                                                        y=7-((lines2.length-1)*8);

                                                                                                                                   return y;
                                                                                                                                   });
                                                                                for(var i=1;i<lines2.length;i++){
                                                                                        txt.append("tspan").text(lines2[i])
                                                                                                .attr("x",function(d) {var len=new String(lines2[i]).length;
                                                                                                                                                var x=0;
                                                                                                                                                x=x-(len*charWidth/2);
                                                                                                                                                return x;})
                                                                                                .attr("dy",15);
                                                                                }
                                                                          });
                                  link.each(function(d){
                                                d3.select(this).attr("x1", function(d) { return graph.nodes[d.source].x; })
                                .attr("y1", function(d) { return graph.nodes[d.source].y; })
                                .attr("x2", function(d) { return graph.nodes[d.target].x; })
                                .attr("y2", function(d) { return graph.nodes[d.target].y; })
                                  });



                        });


                        function hoverClickNode(d){
                                var curTime=new Date().getTime();
                                if( (displayOverride==1 && d.level==1) //For programatic click through
                                        || (mouseEnter!=NaN && (curTime-mouseEnter>40 && d.level==1)) ){//for user interaction
                                                 showDetailNodes(d);
                                                if(displayOverride!=1){
                                                        animationStop();
                                                }
                                                if(ga){
                                                    var cat='indexClickCategory';
                                                    if(displayOverride!==1){
                                                        cat='indexAutoCategory';
                                                    }
                                                    ga('send','event',cat,d.groupName);
                                                }
                                }
                                if(d.level==2){
                                         if(displayOverride==1 || (mouseEnter!=NaN && curTime-mouseEnter>60)){
                                                 if(displayOverride==1 || d3.select(this).style("opacity")==1){
                                                        if(displayOverride==1 || d.id!=curSelectedID){
                                                                boxLineTop.transition().duration(250)
                                                                                        .attr("x2", descLineX+radius).attr("y2", descLineY);
                                                                boxLineBottom.transition().duration(250)
                                                                                        .attr("x2", descLineX+radius).attr("y2", descLineY);
                                                                d3.selectAll("circle").style("stroke",d3.rgb("#999999")).style("stroke-width","1px");
                                                                d3.select("g#d"+d.id).select("circle").transition().duration(350).style("stroke",d3.rgb("#FFFF66")).style("stroke-width","4px");
                                                                showDiv(d.descPage);
                                                                var tmpX=d.x;
                                                                var tmpY=d.y;
                                                                descLineX=tmpX;
                                                                descLineY=tmpY;
                                                                boxLineTop.transition().delay(250).duration(5).attr("x1", tmpX+radius).attr("y1", tmpY)
                                                                                        .attr("x2", tmpX+radius).attr("y2", tmpY);
                                                                boxLineBottom.transition().delay(250).duration(5).attr("x1", tmpX+radius).attr("y1", tmpY)
                                                                                        .attr("x2", tmpX+radius).attr("y2", tmpY);
                                                                boxLineTop.transition().delay(500).duration(250)
                                                                                                .attr("x1", tmpX+radius)
                                                                                          .attr("y1", tmpY)
                                                                                          .attr("x2", width).attr("y2", 175).style("stroke-width",2);
                                                                boxLineBottom.transition().delay(500).duration(250)
                                                                                                .attr("x1", tmpX+radius).attr("y1", tmpY)
                                                                                          .attr("x2", width).attr("y2",height-175).style("stroke-width",2);
                                                                curSelectedID=d.id;
                                                                if(displayOverride!==1){
                                                                        animationStop();
                                                                }
                                                                if(ga){
                                                                    var cat='indexClickDetail';
                                                                    if(displayOverride!==1){
                                                                        cat='indexAutoDetail';
                                                                    }
                                                                    ga('send','event',cat,d.descPage);
                                                                }
                                                        }
                                                 }
                                         }
                                }else if((displayOverride==1 && d.level==0) || (d.level==0 && curTime-mouseEnter>80)){
                                         hideDiv();
                                         boxLineTop.transition().duration(5).style("stroke-width",0);
                                         boxLineBottom.transition().duration(5).style("stroke-width",0);
                                }
                        }

                        function showDetailNodes(d){
                                var classStr=d.groupName;
                                 if(displayClassStr!=classStr){
                                         yPos=new Array();
                                         if(displayClassStr!=""){
                                                 d3.selectAll("g."+displayClassStr).transition().duration(350).style("opacity",0)
                                                        .attr("transform", function(d){
                                                                var x=xLevel[d.level];
                                                                var y=-300;
                                                                var ret="translate("+x+","+y+")";
                                                        d.x=x;
                                                        d.y=y;
                                                        //graphData.nodes[d.id].x=x;
                                                        //graphData.nodes[d.id].y=y;
                                                        return ret;
                                                        });
                                                 d3.selectAll("line."+displayClassStr).transition().duration(350).style("stroke-width",0)
                                                                .attr("x1", function(d) { return graphData.nodes[d.source].x; })
                                                        .attr("y1", function(d) { return graphData.nodes[d.source].y; })
                                                        .attr("x2", function(d) { return graphData.nodes[d.target].x; })
                                                        .attr("y2", function(d) { return graphData.nodes[d.target].y; });
                                                 d3.selectAll("line.desclink").transition().duration(350).style("stroke-width",0).attr("y2",-250);
                                                 $("#indexDesc").slideUp("350");

                                         }
                                         d3.selectAll("g."+classStr).transition().duration(350).style("opacity",1.0)
                                                .attr("transform", function(d){
                                                var x=0;
                                                var y=350;
                                                x=xLevel[d.level];
                                                if( yPos[d.level]==undefined){
                                                                yPos[d.level]=0;
                                                }

                                                yPos[d.level]++;
                                                tmp=Math.floor(yPos[d.level]/2);
                                                tmp=tmp*ySpacing;
                                                    if(yPos[d.level]%2==1){
                                                                tmp=tmp*-1;
                                                    }
                                                y=middle+tmp;
                                                var ret="translate("+x+","+y+")";
                                                d.x=x;
                                                d.y=y;
                                                //graphData.nodes[d.id].x=x;
                                                    //graphData.nodes[d.id].y=y;
                                                return ret;
                                            });
                                        d3.selectAll("line."+classStr).transition().duration(350).style("stroke-width",2.0)
                                                        .attr("x1", function(d) { return graphData.nodes[d.source].x; })
                                                .attr("y1", function(d) { return graphData.nodes[d.source].y; })
                                                .attr("x2", function(d) { return graphData.nodes[d.target].x; })
                                                .attr("y2", function(d) { return graphData.nodes[d.target].y; });
                                        displayClassStr=classStr;
                                }
                        }

                        function redraw(){
                                d3.selectAll("g")
                            .attr("transform", function(d){
                                var x=5;
                                var y=5;
                                if(d!=undefined){
                                        x=xLevel[d.level];
                                        y=d.y;
                                        d.x=x;
                                }
                                var ret="translate("+x+","+y+")";
                                return ret;
                            });
                            d3.selectAll(".link").each(function(d){
                                        var sourceInd=d.source;
                                        var targetInd=d.target;
                                                d3.select(this).attr("x1", graphData.nodes[sourceInd].x)
                                .attr("y1", graphData.nodes[sourceInd].y)
                                .attr("x2", graphData.nodes[targetInd].x)
                                .attr("y2", graphData.nodes[targetInd].y)
                                  });
                            var x1=xLevel[2]+radius;
                            var x2=width;
                            boxLineBottom.attr("x1", x1).attr("x2", width);
                            boxLineTop.attr("x1", x1).attr("x2", width);
                        }

                        function wordWrap(d){
                        var words = d.name.split(' ');
                        var lines = new Array();
                        var length = 0;
                        var width = 2*radius -20;
                        var height = 2*radius-20;


                        var word;
                        do {
                           word = words.shift();
                           var wordStr=new String(word);
                           var linesStr=new String(lines[length]);
                           if(linesStr == "undefined"){
                                                        lines[length]=word;
                                }else{
                                        if((linesStr.length+wordStr.length+1)*charWidth<width){
                                                                lines[length]=lines[length]+" "+word;

                                        }else{
                                                        lines[length+1]=word;
                                                        length++;
                                        }
                                }

                          } while (words.length);
                          return lines;
                        } 


                        function animationToggle(){
                                if(timeoutHandle!=-1){
                                        animationStop();
                                }else{
                                        animationStart();
                                }
                        }

                        function animationStop(){
                                d3.select("#pauseTxt").text("Run");
                                stopRunningSelection();
                        }

                        function animationStart(){
                                d3.select("#pauseTxt").text("Pause");
                                startRunningSelection(0);
                        }


                        function setupDisplay(){
                                console.log("setupDisplay");
                                var mn=svg.selectAll('g#d28')[0];
                                if(mn[0]!=undefined && mn[0].__data__!=undefined){
                                                displayOverride=1;
                                                //set selected node to announcements
                                                var d=mn[0].__data__;
                                                hoverClickNode(d);
                                                var dn=svg.selectAll('g#d31')[0];
                                                //console.log(dn);
                                                var d2=dn[0].__data__;
                                                hoverClickNode(d2);
                                                displayOverride=0;
                                }else{
                                        setTimeout(setupDisplay,50);
                                }
                        }
                        setupDisplay();
                        //start rotating through.
                        var mainCount=Math.floor((Math.random() * 5));;
                        var featCount=0;
                        var mainNode;
                        var updatedCount=0;
                        var timeoutHandle=-1;

                        //start automatic scrolling of features
                        startRunningSelection(15000);
                        function startRunningSelection(delay){
                                if(timeoutHandle==-1 ){
                                        runSelection(delay);
                                        updatedCount=0;
                                }
                        }

                        function runSelection(delay){
                                timeoutHandle=setTimeout(function(){
                                                displayOverride=1;
                                                var mainNode=svg.selectAll('.mainFeature')[0];
                                                if(mainCount>=mainNode.length){
                                                        mainCount=0;
                                                }
                                                var d=mainNode[mainCount].__data__;
                                                hoverClickNode(d);

                                                var detailNode=svg.selectAll('g.detail.'+d.groupName)[0];
                                                if(featCount>=detailNode.length){
                                                        featCount=0;
                                                }
                                                var d2=detailNode[featCount].__data__;
                                                hoverClickNode(d2);

                                                featCount++;
                                                if(featCount>=detailNode.length){
                                                        featCount=0;
                                                        mainCount++;
                                                }
                                                displayOverride=0;
                                                updatedCount++;
                                                if(updatedCount<150){
                                                    runSelection(10000);
                                                }/*else{
                                                    location.reload();
                                                }*/
                                        },delay);
                        }

                        function stopRunningSelection(){

                                if(timeoutHandle!=-1){
                                        clearTimeout(timeoutHandle);
                                }
                                timeoutHandle=-1;
                        }
                        
                        
                        
                        
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
                                                        if(ga){
                                                            ga('send','event','index','expandDetail');
                                                        }
						});
                    </script>

    