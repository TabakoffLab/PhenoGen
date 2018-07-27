var tt=d3.select("body").append("div")   
	    	.attr("class", "testToolTip")
	    	.style("z-index",1001) 
	    	.attr("pointer-events", "all")              
	    	.style("opacity", 0);

function removeColon(str){
    return str.replace(/:/g, '');
}

$(window).resize(function(){
	if(goBrwsr!==0){
		goBrwsr.singleImage.resize();
		goBrwsr.singleImage.draw();
	}
});

function GOBrowser(path,fileName){
	that={};
	that.path=path;
	that.fileName=fileName;

	that.setup=function(){
		console.log("setup");
		//create Image Controls
		that.createImageControls();
		//create Data Controls
		that.createDataControls();   
        $(".wgcnaControltooltip").tooltipster({
            position: 'top-right',
            maxWidth: 250,
            offsetX: 5,
            offsetY: 5,
            contentAsHTML:true,
            //arrow: false,
            interactive: true,
            interactiveTolerance: 350
        });
        setTimeout(function(){
        		console.log("start settimeout setup");
					that.singleImage=that.singleWGCNAImageGoView();
                    that.singleImage.goDomain=$("#goDomainSelect").val();
					that.singleImage.draw();
					that.img=that.singleImage;
					console.log("end settimeout setup");
                },100);
	};

	that.positionTTLeft = function(pageX){
		var x=pageX+20;
    	if(x>($(window).width()/2)){
    		x=x-250;
    	}
    	var xPos=x+"px";
    	return xPos;
	};

	that.positionTTTop = function(pageY){
		var topPos=(pageY) + "px";
		if(d3.event.clientY>(window.innerHeight*0.6)){
			topPos=(d3.event.pageY - ($(".testToolTip").height()*2.2)) + "px";
		}
		return topPos;
	};

	that.createImageControls=function(){
        that.imageBar=d3.select("#imageControl").append("span").style("float","left");
		that.imageBar.append("span").attr("class","saveImage control").style("display","inline-block")
			.attr("id","saveImage")
			.style("cursor","pointer")
			.append("img")//.attr("class","mouseOpt dragzoom")
			.attr("src",contextRoot+"web/images/icons/savePic_dark.png")
			.attr("pointer-events","all")
			.attr("cursor","pointer")
			.on("click",function(){
				var content="";
				if(that.singleImage){
	                if(that.viewType==="eqtl" && that.singleImage.type==="eqtl"){
	                    content=$("div#circos").html();
	                }else if(that.viewType==="gene" && that.singleImage.type==="gene"){
	                    //console.log("viewGene")
	                    content=$("div#viewGene").html();
	                    //console.log(content);
	                }else if(that.viewType==="mir" && that.singleImage.type==="mir"){
	                    //console.log("viewGene")
	                    content=$("div#viewGene").html();
	                    //console.log(content);
	                }else if(that.viewType==="go" && that.singleImage.type==="go"){
	                    //console.log("saveGO");
	                    content=$("div#viewGene").html();
	                    
	                }
	                var w=$(window).width();
	                content=content.replace("width=\"100%\"","width=\""+w+"px\"");
					content=content+"\n";
					$.ajax({
							url: pathPrefix+"saveBrowserImage.jsp",
			   				type: 'POST',
							contentType: 'text/html',
							data: content,
							processData: false,
							dataType: 'json',
			    			success: function(data2){ 
			        			var d=new Date();
			        			var datePart=(d.getMonth()+1)+"_"+d.getDate()+"_"+d.getFullYear();
	                            var http="http://";
	                            if (location.protocol === 'https:') {
	                                http="https://";
	                            }
								var url=http+urlprefix+"/tmpData/download/"+data2.imageFile;
								var region="";
								if(that.selectedModule){
									//*****************************CHANGE
									//region=new String(that.selectedModule.MOD_NAME);
								}
	                            region=region+"_"+that.viewType;
								var filename = region+"_"+datePart+".png";
								var xhr = new XMLHttpRequest(); 
							  	xhr.open('GET', url);
							  	xhr.responseType = 'blob';
							  	xhr.send();
							  	xhr.onreadystatechange = function(){
								    //ready?
								    if (xhr.readyState != 4)
								        return false;
								    //get status:
								    var status = xhr.status;
								    //maybe not successful?
								    if (status != 200) {
								        return false;
								    }
								    var a = document.createElement('a');
									a.href = window.URL.createObjectURL(xhr.response); // xhr.response is a blob
									a.download = filename; // Set the file name.
									a.style.display = 'none';
									document.body.appendChild(a);
									try{
										a.click();
									}catch(error){
										//$("#"+id).append("<span style='color:#FF0000;'>Your browser will not save the image directly. Image will open in a popup, in the new window right click to save image.</span>");
										$("#wgcnaMouseHelp").html("<span style='color:#FF0000;'>Your browser will not save the image directly. Image will open in a popup, in the new window right click to save image.</span>");
										window.open(url);
									}	
									//delete a;
								    return true;
								}
			    			},
			    			error: function(xhr, status, error) {
			        			console.log(error);
			    			}
					});
				}
			})
			.on("mouseover",function(){
				d3.select(this).attr("src",contextRoot+"web/images/icons/savePic_white.png");
				$("#wgcnaMouseHelp").html("Click to download a PNG image of the current view.");
			})
			.on("mouseout",function(){
				d3.select(this).attr("src",contextRoot+"web/images/icons/savePic_dark.png");
				$("#wgcnaMouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
			});
	};

	that.createDataControls=function(){
		//that.dataBar=d3.select("div#wgcnaImageControls").append("span").attr("id","wgcnaDataControls").style("float","right").style("margin-left","10px").style("margin-right","5px")
        that.dataBar=d3.select("#dataControl").append("span").attr("id","wgcnaDataControls").style("margin-left","10px").style("margin-right","5px")
                            .append("table").append("tr");
                var go=that.dataBar.append("td").append("div").attr("id","goCtls").attr("class","goCTL").style("display","none").style("margin-left","10px");
                go.append("text").text("GO Domain:");
                sel=go.append("select").attr("id","goDomainSelect").on("change",function(){
                    that.singleImage.goDomain=$("#goDomainSelect").val();
                    that.singleImage.draw();
                });
                sel.append("option").attr("value","cc").text("Cellular Component");
                sel.append("option").attr("value","bp").text("Biological Process");
                sel.append("option").attr("selected","selected").attr("value","mf").text("Molecular Function");
                //go.append("br");
                go.append("text").style("padding-left","15px").text("Number of Levels to Display:");
                go.append("input").attr("name","value").attr("id","goSpinner");
                
                $("#goSpinner").spinner({
                    min: 1,
                    max: 100,
                    step: 1,
                    change: function( event, ui ) {
                    	//if(ui.value<=(that.singleImage.maxDepth+1)){
	                        that.singleImage.displayDepth=ui.value;
	                        if(that.singleImage.selectedNode !==that.singleImage.data.GOList[0] &&
	                                that.singleImage.selectedNode !==that.singleImage.data.GOList[1] &&
	                                that.singleImage.selectedNode !==that.singleImage.data.GOList[2]){
	                            that.singleImage.redraw();
	                        }else{
	                            that.singleImage.draw();
	                        }
                    	/*}else{
                    		event.preventDefault();
                    	}*/
                    	if(ga){
							ga('send','event','gl_WGCNA_go','changeDepth');
						}
                    },
                    spin: function( event, ui ) {
                    	//if(ui.value<=(that.singleImage.maxDepth+1)){
	                        that.singleImage.displayDepth=ui.value;
	                        if(that.singleImage.selectedNode !==that.singleImage.data.GOList[0] &&
	                                that.singleImage.selectedNode !==that.singleImage.data.GOList[1] &&
	                                that.singleImage.selectedNode !==that.singleImage.data.GOList[2] 
	                                ){
	                            that.singleImage.redraw();
	                        }else{
	                            that.singleImage.draw();
	                        }
                    	/*}else{
                    		event.preventDefault();
                    	}*/
                    	if(ga){
							ga('send','event','gl_WGCNA_go','changeDepth');
						}
                    }
                }).val(3);
	};

	//common prototype to create generic view
	that.singleWGCNAImage=function(){
		var thatimg={};
		var adjust=0;
		if($(window).width()>1000){
			adjust=400;
		}
		thatimg.width=$(window).width()-adjust;
		thatimg.height=Math.floor(window.innerHeight*0.9);
		//console.log("H:"+thatimg.height+"  W:"+thatimg.width);
		if(thatimg.height>thatimg.width){
			//console.log("using width");
			thatimg.r=Math.floor((thatimg.width/2));
		}else{
			//console.log("using height");
			thatimg.r=Math.floor((thatimg.height/2));
		}
		//console.log("r:"+thatimg.r);
		
                thatimg.maxPerLevel=150;
                thatimg.CorCutoff_min=0.75;
                thatimg.CorCutoff_max=1.0;
                thatimg.showLinks=true;
		thatimg.data=[];
                
                thatimg.maxNodeR=28;
         
                thatimg.negColor="#DD0000";
                thatimg.negDarkColor="#770000";
                thatimg.posColor="#00DD00";
                thatimg.posDarkColor="#007700";
                
                thatimg.mirVal="#FFFF00";
                thatimg.mirPred="#0000CC";
                

		//setup image
		if(d3.select("#singleWGCNASVG").size()===0){
			thatimg.svg=d3.select("#wgcnaGeneImage").append("div").attr("id","viewGene").append("svg").attr("id","singleWGCNASVG").attr("height",thatimg.height+"px").attr("width","100%");
		}else{
			thatimg.svg=d3.select("#singleWGCNASVG");
		}

		thatimg.geneKey=function(d){return d.ID;};
                thatimg.linkKey=function(d){return d.TC1+"_"+d.TC2;};
                
		thatimg.calcX=function(d,i){
			var tmp=i%thatimg.modPerLine;
			var ret=tmp*thatimg.calcWidth;
			return ret;
		};
		thatimg.calcY=function(d,i){
			var tmp=Math.floor(i/thatimg.modPerLine);
			var ret=tmp*thatimg.maxWidth;
			return ret;
		};

		thatimg.sizing=function(d){
			var r=thatimg.size(d.TCList.length);
			if(r>thatimg.maxWidth/2){
				r=thatimg.maxWidth/2;
			}
			return r;
		};

		thatimg.resize=function(){
			var adjust=0;
			if($(window).width()>1000){
				adjust=400;
			}
			thatimg.width=$(window).width()-adjust;
			thatimg.height=Math.floor(window.innerHeight*0.9);
			//console.log("H:"+thatimg.height+"  W:"+thatimg.width);
			if(thatimg.height>thatimg.width){
				//console.log("using width");
				thatimg.r=Math.floor((thatimg.width/2));
			}else{
				//console.log("using height");
				thatimg.r=Math.floor((thatimg.height/2));
			}
		};
                
                thatimg.colorCircle=function(d){
                    var id=d.Gene.ID;
                    var color="#DFC184";
                    if(id.indexOf("Brain")==0||id.indexOf("Unannotated")==0){
                        color="#7EB5D6";
                    }
                    return color;
                };
                
                thatimg.colorLink=function(d){
                    //var val="#DD0000";
                    var val=thatimg.negColor;
                    if(d.Cor>0){
                        //val= "#00DD00"
                        val=thatimg.posColor;
                    }
                    return val;
                };
                
                thatimg.colorLinkHighlight=function(d){
                    //var val="#770000";
                    var val=thatimg.negDarkColor;
                    if(d.Cor>0){
                        //val= "#007700"
                        val=thatimg.posDarkColor;
                    }
                    return val;
                };
                thatimg.updateColor=function(selector){
                    var colorOpt=$("#"+selector).val();
                    //console.log("update color:"+colorOpt);
                    if(colorOpt==="Red_Green"){
                        thatimg.posColor="#DD0000";
                        thatimg.posDarkColor="#770000";
                        thatimg.negColor="#00DD00";
                        thatimg.negDarkColor="#007700";
                        thatimg.mirVal="#FFFF00";
                        thatimg.mirPred="#0000CC";
                    }else if(colorOpt==="Blue_Yellow"){
                        thatimg.posColor="#0000DD";
                        thatimg.posDarkColor="#000077";
                        thatimg.negColor="#ffef16";
                        thatimg.negDarkColor="#b7ae2a";
                        thatimg.mirVal="#FF9C2A";
                        thatimg.mirPred="#BA49FF";
                    }else{
                        thatimg.negColor="#DD0000";
                        thatimg.negDarkColor="#770000";
                        thatimg.posColor="#00DD00";
                        thatimg.posDarkColor="#007700";
                        thatimg.mirVal="#FFFF00";
                        thatimg.mirPred="#0000CC";
                    }
                };
                thatimg.nodeRadiusSum=function(d,i){
                    var r=3+20*d.LinkSum;
                    if(r>thatimg.maxNodeR){
                        r=thatimg.maxNodeR;
                    }
                    return r;
                };
		thatimg.zoomIn=function(){
			if(thatimg.maxWidth<$(window).width()/2){
				thatimg.maxWidth=thatimg.maxWidth*2;
				thatimg.draw();
			}
		};
		thatimg.zoomOut=function(){
			var prev=thatimg.maxWidth;
			thatimg.maxWidth=Math.floor(thatimg.maxWidth/2);
			if(thatimg.maxWidth<25){
				thatimg.maxWidth=prev;
			}else{
				thatimg.draw();
			}
		};

		thatimg.draw=function(){

		};

		thatimg.redraw=function(){

		};

                thatimg.setupLegend=function(){
                    thatimg.svg.select("#legend").remove();
                    thatimg.svg.select("#legendDisp").remove();
                    
                    thatimg.legendG=thatimg.svg.append("g")
                            .attr("id","legend")
                            .attr("transform","translate(10,60)")
                            .style("cursor","pointer")
                            .on("mouseover",function(){
                                thatimg.legendDispG.transition()        
                                    .duration(300)
                                    .style("opacity",1);
                            })
                            .on("mouseleave",function(){
                                thatimg.legendDispG.transition()        
                                    .duration(300)
                                    .style("opacity",0);
                            });
                    thatimg.legendG.append("image")
                            .attr("x",0)
                            .attr("y",-20)
                            .attr("width","24px")								
                            .attr("height","24px")
                            .attr("xlink:href","data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAACXBIWXMAAAsTAAALEwEAmpwYAAAJ"+
                                                        "I0lEQVRIDQEYCef2AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAEAAAABVVVVAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAAAAAAq6ur/wAAAP4AAAAAAQAAAAAAAAAAAAAAAFtynWv/AgFSAP//BAEBAgAAAP8B"+
                                                        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP/95/Plx4sH"+
                                                        "/fPbq6ur8QQAAAAAAAAAAEBAQAT/AgOLAQEACQABAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAgAJDRgG/O7xiAAAAMkEAAAAAAAAAADz"+
                                                        "8/MB/vv1pgMEBVb///4JAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAAAAAAAAD//Pb+/fLiJgAAAB8AAADJBAAAAAAAAAAADQ0N//nivJACAgLfAQEBOwEB"+
                                                        "ARH///8BAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "/gAAAOoAAADxAAAAAAQAAAAAAAAAAMDAwPxAQEDkEhISuv///9wCAgIN////AQAAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP////4AAADxAAAA2AAAAAAEAAAA"+
                                                        "AAAAAAAAAAAAFS1XJgQDAk4B//wK/gD9BQIAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAAAAAAAAAAAAAAAAD//fro+OXExvj4+O8AAAAABAAAAAAAAAAAAFVVAwUHCLcBAQES"+
                                                        "AAAHAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAP8A/wYTKxsC79eVAAAA1QIAAAAAAAAAADPe3gIA//3Z///+/AD//v7//v7///7+///+/v//"+
                                                        "/v7///7+///+/v///v7///7+///+/v///v7///7+///+/v///v7///7+/wH++v/+9+k6////JgAA"+
                                                        "AAAEAAAAAAAAAAANDQ3/9+LCcwMIDGEB/vs1AAD/DgIBAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD+/fn9//v18wAAAAAAAAAABAAAAAAAAAAAwMDA/UZG"+
                                                        "Rt0N/g2q/wAA0gEBAQ39AAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAA/////gAAAPD////YAAAAAAQAAAAAAAAAAAAAAP8LIkUAAwT9AwD8+uoCAP/x////"+
                                                        "AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP779vD+8d3a"+
                                                        "/f395QAAAAAEAAAAAAAAAAAAAAABCQwVtQEBADQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP/4+gABewTw260AAADzAgAAAAAAAAAA"+
                                                        "M2ZmBAEA/xsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAAAAAAAAAA//8BBwD++FYBAQErAAAAAAQAAAAAAAAAAADNzQD5MRBsAwIIagD++igA"+
                                                        "AP4K////AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH7"+
                                                        "+PwA9+gIAAAADAAAAAAEAAAAAAAAAADNzc39FxcXzQYGBqACAgIwAgICDv///wIAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEBAf/////+AAAA7gICAuAAAAAABAAA"+
                                                        "AAAAAAAAAAAA/uHh4ecfHx+8AwMDzAYGBgb+/v4BAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAAAAAAAAAAAAAAAAAA/f39/wMDA/j29vboAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAIAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAAAAD/AAAA/gAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                                                        "AAAApkUqF3zKmm8AAAAASUVORK5CYII=");
                    thatimg.legendG.append("text").attr("x","25").style("font-size","18").text("Legend");
                    thatimg.legendDispG=thatimg.svg.append("g")
                            .attr("id","legendDisp")
                            .attr("transform","translate(10,70)")
                            .style("opacity",1);
                    thatimg.drawLegend();
                    setTimeout(function(){
                         thatimg.legendDispG.transition()        
                            .duration(750)
                            .style("opacity",0);
                    },8000);
                };

                thatimg.drawLegend= function(){
                    
                };

		thatimg.createToolTip=function(d){
			var tt="Gene: "+d.Gene.geneSymbol+" ("+d.Gene.ID+")<BR><BR>Transcript:"+d.ID+"<BR>";
                        tt=tt+"<BR>Link Count:"+d.LinkCount;
                        tt=tt+"<BR>Link Sum:"+d.LinkSum.toFixed(2);
                        var tcList=that.selectedGene[d.Gene.ID].tcList;
                        if(tcList.length>1){
                            "<BR><BR>Additional Transcripts in this Module:<BR>";
                            var tcList=that.selectedGene[d.Gene.ID].tcList;
                            for(var l=0;l<tcList.length;l++){
                                if(tcList[l].ID!==d.ID){
                                    tt=tt+tcList[l].ID+"<BR>";
                                }
                            }
                        }
                        tt=tt+"<BR><BR>";
                        tt=tt+d.PSList.length+" Probe Sets in Transcript<BR>";
                        /*for(var l=0;l<d.PSList.length;l++){
                            tt=tt+d.PSList[l].ID+"("+d.PSList[l].Level+")<BR>";
                        }*/
			return tt;
		};

		return thatimg;
	};

	that.singleWGCNAImageGoView=function(){
            var thatimg=that.singleWGCNAImage();
            $(".goCTL").show();
            $(".linkCTL").hide();
            $(".mirCTL").hide();
            $(".eqtlCtls").hide();
            thatimg.type=that.viewType;
            thatimg.goDomain="mf";
            thatimg.lastDrawn="mf";
            thatimg.selectedNode;
            thatimg.displayedLevel="d1";
            var adjust=0;
			if($(window).width()>1000){
				adjust=400;
			}
			thatimg.width=$(window).width()-adjust;
            thatimg.height = Math.floor(window.innerHeight*0.92);
            thatimg.padding = 5;
            thatimg.radius = (Math.min(thatimg.width, thatimg.height) - 2 * thatimg.padding)/ 2;
            thatimg.duration = 1000;
            thatimg.xScale = d3.scaleLinear().range([0, 2 * Math.PI]);
            thatimg.yScale = d3.scalePow().exponent(1.3).domain([0, 1]).range([0, thatimg.radius]);
            thatimg.colorGO=d3.scaleOrdinal(d3.schemeCategory20);
            thatimg.displayDepth=3;
            thatimg.geneList={};
            var tmpDat=[];
            if(that.selectedModule){
	            tmpDat=that.selectedModule.TCList;
	            for(var i=0;i<tmpDat.length;i++){
	                thatimg.geneList[that.selectedModule.TCList[i].Gene.ID]=that.selectedModule.TCList[i].Gene.geneSymbol;
	            }
        	}

            thatimg.pathColor=function(d){
            	if(d && d.data){
                              if(d.data.name && d.data.name.indexOf("ENS")==0){
                              	return "#DFC184";
                              }else if(d.data.name){
                              	return thatimg.colorGO(d.data.name);
                              }else{
                              	return "#000000";
                              }
                }else{
                	if(d && d.name && d.name.indexOf("ENS")==0){
                      	return "#DFC184";
                    }else if(d && d.name){
                      	return thatimg.colorGO(d.name);
                    }else{
                      	return "#000000";
                    }
	            }
            };

            thatimg.addLabels=function(tmpD,tmpI,startA,midA,endA,curDepth,tmpDisplayDepth){
            	var oR=tmpD.depth*(thatimg.radius/(tmpDisplayDepth+1))+(thatimg.radius/(tmpDisplayDepth+1))-12;
            	var iR=tmpD.depth*(thatimg.radius/(tmpDisplayDepth+1));
            	var oCirc=(Math.PI*2*oR*((endA-startA)/360));
            	var iCirc=(Math.PI*2*iR*((endA-startA)/360));
            	var max=Math.floor(oCirc/7.0)-1;
            	var jMax=Math.floor((oR-iR)/12);
            	var init=tmpD.data.name;
                if(tmpD.data.name.indexOf("ENS")===0 && typeof thatimg.geneList[init]!=='undefined'){
                    init=thatimg.geneList[init];
                    if((endA-startA)>25){
                        init=init+ " ("+tmpD.data.name+")";
                    }
                }
                var first=init.split(" ")[0].split("-")[0];
            	
            	if(first.length<=max ||(tmpD.data.name.indexOf("ENS")===-1 && (first.length/2)<=max && (endA-startA)>10) ){ 
                    //construct lines                           
                    //var max=(endA-startA)/(2.2-(curDepth*0.13));
                    var lines=[];
                    var curLine=0;
                    if(init.length>max){
                    	var left=init;
                    	while(left.length>0){
                    		var fbreak=left.indexOf(" ");
                    		if(fbreak===-1){
                    			if(left.length>max){
                    				lines[curLine]=left.substr(0,max);
		                    		curLine++;
		                    		left=left.substr(max);
                    			}else{
                    				lines[curLine]=left;
                    				curLine++;
                    				left="";
                    			}
                    		}else{
	                    		var stopLoop=0;
	                    		while(fbreak<max && stopLoop<1){
	                    			var next=left.indexOf(" ",fbreak+1);
	                    			if(next !==-1 && next<=max){
	                    				fbreak=next;
	                    			}else{
	                    				stopLoop=1;
	                    			}
	                    		}
	                    		if(fbreak>max){
	                    			if(left.indexOf("-")>-1 &&left.indexOf("-")<max){
	                    				fbreak=left.indexOf("-");
										lines[curLine]=left.substr(0,fbreak+1);
		                    			curLine++;
		                    			left=left.substr(fbreak+1);
	                    			}else{
	                    				lines[curLine]=left.substr(0,max);
		                    			curLine++;
		                    			left=left.substr(max);
	                    			}
	                    		}else{
	                    			lines[curLine]=left.substr(0,fbreak);
	                    			curLine++;
	                    			left=left.substr(fbreak+1);
	                    		}
                    		}
                    	}
                    }else{
                        lines[curLine]=init;
                    }
                    //console.log(lines);
                    var tmpText=thatimg.topG.append("text")
                                .style("fill-opacity", 1)
                                .style("fill", "#000")
                                .attr("pointer-events","none")
                                .attr("class","txt"+removeColon(tmpD.data.id))
                                .attr("text-anchor", function(d) {
                                    return "start";
                                })
                                .attr("dy", "1em")
                                .style("opacity",function(d){
                                    return 1;
                                })
                                .append("textPath")
                                .attr("xlink:href",function(d){return "#ap"+tmpI;})
                                .attr("startOffset",function(d){
                                    if(startA===0&&endA===360){
                                        return 90;
                                    }
                                    return 5 ;
                                });
                    for (var j=0;j<lines.length && j<jMax;j++){
                        if(j<jMax){
                            if(j===(jMax-1)&&lines.length>jMax){
                                lines[j]+="...";
                                if(lines[j].length>max){
                                    lines[j]=lines[j].substr(0,max-4)+"...";
                                }
                            }
                            tmpText.append("tspan")
                                .attr("x", 0)
                                .attr("dy", "1em")
                                .text(lines[j]);
                        }
                    }
                }else if(iCirc>=12 && tmpD.data.name.indexOf("ENS")===0){
                            var tmpText=thatimg.topG.append("text")
                                  	.style("fill-opacity", 1)
                                  	.style("fill", "#000")
                                  	.attr("pointer-events","none")
                                  	.attr("class","txt"+removeColon(tmpD.data.id))
                                	.attr("text-anchor", function(d) {
                                    	var anch="start";
                                    	if(endA>=180){
                                        	anch="end";
                                    	}
                                    	return anch;
                                  	})
                                  	.attr("dy", ".2em")
                                  	.attr("transform", function(d) {
                                    	var angle = midA-2.5;
                                    	//var translate = Math.max(0, tmpD.y);
                                    	var translate = iR;
                                    	if(startA===0&&endA===360){translate=20;}
                                    	if(endA>=180){angle=midA+2.5;}
                                    	var rotate = angle-90;
                                    	return "rotate(" + rotate + ")translate(" + translate + ")rotate(" + (angle > 180 ? -180 : 0) + ")";
                                  	}).style("opacity",function(d){
                                      return 1;
                                  	});
                            var init=tmpD.data.name;
                            if(tmpD.data.name.indexOf("ENS")===0 && typeof thatimg.geneList[init]!=='undefined'){
                                    init=thatimg.geneList[init];
                            }
                            var tmpName=init.split(" ");

                            for (var j=0;j<tmpName.length;j++){
                              tmpText.append("tspan")
                                  .attr("x", 0)
                                  .attr("dy", "1em")
                                  .text(tmpName[j]);
                            }
                        }
            };

            thatimg.redraw=function(){
            	thatimg.svg.selectAll("path").remove();
                thatimg.svg.select("#center").remove();
                
      			var nodes = thatimg.partition(thatimg.rootN)
	                				.descendants()
      								.filter(thatimg.filterNodes);

                var tmpDisplayDepth=thatimg.displayDepth;

                thatimg.arc = d3.arc()
                    .startAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, d.x0)); })
                    .endAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, d.x1)); })
                    .innerRadius(function(d) { 
                            if(d===thatimg.selectedNode && (thatimg.selectedNode!==thatimg.data.GOList[0]&&thatimg.selectedNode!==thatimg.data.GOList[1]&&thatimg.selectedNode!==thatimg.data.GOList[2])){
                                return 20;
                            }else{
                                return Math.max(0, (d.depth-thatimg.rootN.depth)*(thatimg.radius/(tmpDisplayDepth+1))); 
                            }
                    })
                    
                    .outerRadius(function(d) { return Math.max(0, (d.depth-thatimg.rootN.depth)*(thatimg.radius/(tmpDisplayDepth+1))+(thatimg.radius/(tmpDisplayDepth+1))); });
                        

               /*setTimeout(function(){
                        that.singleWGCNATableGoView();
                },50);*/
                thatimg.topG.selectAll("path").remove();
                thatimg.topG.selectAll("text").remove();
                var radToDeg=180/Math.PI;
                var degToRad=Math.PI/180;
                thatimg.path = thatimg.topG.selectAll("path").data(nodes);
                thatimg.path.enter().append("path").merge(thatimg.path)
                          .attr("d", thatimg.arc)
                          .attr("id",function(d,i){return "ap"+i;})
                          .attr("class",function(d,i){return removeColon(d.data.id);})
                          .attr("fill-rule", "evenodd")
                          .attr("fill",thatimg.pathColor)
                          .attr("pointer-events","all")
                          .on("mouseover", thatimg.mouseover)
                          .on("click", thatimg.click)
                          .each(function(d,i){
			                	if(d.depth<(thatimg.rootN.depth+thatimg.displayDepth)){
				                    var tmpD=d;
				                    var tmpI=i;
				                    var startA=Math.max(0, Math.min(2 * Math.PI, d.x0))*radToDeg;
				                    var endA=Math.max(0, Math.min(2 * Math.PI, d.x1))*radToDeg;
				                    var midA=startA+((endA-startA)/2);
				                    if(startA===0&&endA===360){
				                        midA=90;
				                    }
				                    var curDepth=(tmpD.depth-thatimg.rootN.depth);
				                    //if(d.data!==thatimg.selectedNode){
				                        thatimg.addLabels(tmpD,tmpI,startA,midA,endA,curDepth,tmpDisplayDepth);
				                    //}
			                    }
                          
                			});
                //Draw a special center node for browsing back up the tree
                if(thatimg.selectedNode!==thatimg.data.GOList[0]&&thatimg.selectedNode!==thatimg.data.GOList[1]&&thatimg.selectedNode!==thatimg.data.GOList[2]){
                    thatimg.svg.append("circle").attr("id","center").attr("cx",thatimg.width/2 + thatimg.padding).attr("cy",thatimg.height/2 + thatimg.padding).attr("r","20")
                        .attr("fill-rule", "evenodd")
                        .attr("fill",function(){return thatimg.pathColor(thatimg.rootN.parent);})
                        .attr("pointer-events","all")
                        .on("click",function(){
                        	if(thatimg.rootN.parent.data===thatimg.data.GOList[0]||thatimg.rootN.parent.data===thatimg.data.GOList[1]||thatimg.rootN.parent.data===thatimg.data.GOList[2]){
                        		thatimg.selectedNode=null;
                        		thatimg.draw();
                        	}else{
	                            if(thatimg.rootN.parent.data!==thatimg.data.GOList[0]&&thatimg.rootN.parent.data!==thatimg.data.GOList[1]&&thatimg.rootN.parent.data!==thatimg.data.GOList[2]){
	                                thatimg.selectedNode=thatimg.rootN.parent.data;
	                                thatimg.rootN=thatimg.rootN.parent;
	                                thatimg.mouseover(thatimg.rootN.parent);
	                            }else{
	                                var goRoot=thatimg.data.GOList[0];
	                                if(thatimg.goDomain === "mf"){
	                                    goRoot=thatimg.data.GOList[2];
	                                }else if(thatimg.goDomain === "bp"){
	                                    goRoot=thatimg.data.GOList[1];
	                                }
	                                thatimg.selectedNode=goRoot;
			                    }
			                    thatimg.redraw();
			                    d3.event.stopPropagation();
			                    if(ga){
			                        ga('send','event','wgcna','mouseClickGO');
			                    }
		                	}
                        })
                        .on("mouseover",function(d){
                            if(typeof thatimg.selectedNode!=='undefined' && (thatimg.selectedNode.parent!==thatimg.data.GOList[0]&&thatimg.selectedNode.parent!==thatimg.data.GOList[1]&&thatimg.selectedNode.parent!==thatimg.data.GOList[2])){
                                thatimg.mouseover(thatimg.selectedNode.parent);
                            }else{
                                var goRoot=thatimg.data.GOList[0];
                                if(thatimg.goDomain === "mf"){
                                    goRoot=thatimg.data.GOList[2];
                                }else if(thatimg.goDomain === "bp"){
                                    goRoot=thatimg.data.GOList[1];
                                }
                                tt.transition()        
		                            .duration(200)      
		                            .style("opacity", 1);
		                		tt.html(thatimg.createToolTip(thatimg.selectedNode))
		                            .style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
		                            .style("top", function(){return that.positionTTTop(d3.event.pageY);});
                                //thatimg.mouseover(goRoot);
                                 
                            }
                            d3.event.stopPropagation();
                            if(ga){
		                        ga('send','event','wgcna','mouseOverGO');
		                    }
                        })
						.on("mouseleave",function(d){
							tt.transition()        
		                        .duration(200)      
		                        .style("opacity", 0);
						});
                }
            };
            
            
            thatimg.getModuleGOFile=function (retry){
            	$.ajax({
					url:  that.path+that.fileName,
		   			type: 'GET',
		   			async: true,
					data: {},
					dataType: 'json',
		    		success: function(root){
		    			$("#waitCircos").hide();
		    			thatimg.data=root;
		    			console.log(thatimg.data);
		    			console.log(thatimg.data.GOList[0]);
	                    var nodes =thatimg.data.GOList[0];
	                    var uniqueID=0;
	                    for(var z=0;z<nodes.length;z++){
	                    	nodes[z].UnqID=uniqueID;
	                    	console.log(nodes[z]);
	                    	uniqueID++;
	                    }
	                    nodes = thatimg.data.GOList[1];
	                    for(var z=0;z<nodes.length;z++){
	                    	nodes[z].UnqID=uniqueID;
	                    	uniqueID++;
	                    }
	                     nodes = thatimg.data.GOList[2];
	                    for(var z=0;z<nodes.length;z++){
	                    	nodes[z].UnqID=uniqueID;
	                    	uniqueID++;
	                    }
	                    thatimg.resize();
	                    thatimg.draw();
		    		},
		    		error: function(xhr, status, error){
		    			console.log(error);
		    			if(retry<25){
                			setTimeout(function(){
                				thatimg.getModuleGOFile(retry+1);
                			},1000);
                		}
		    		}
		    	});
            };
            
            
            thatimg.draw=function(){
                thatimg.svg.attr("width", thatimg.width)
                            .attr("height", thatimg.height);
                thatimg.initializeBreadcrumbTrail();
                thatimg.topG=thatimg.svg.append("g")
                        .attr("transform", "translate(" + [thatimg.width/2 + thatimg.padding, thatimg.height/2 + thatimg.padding] + ")");

                thatimg.partition = d3.partition()
              		.size([2 * Math.PI, thatimg.radius]);
                    //.value(function(d){if(d.name.indexOf("ENS")>-1){return 1;}else{return d.uniqueGene;}});
                 

                if(thatimg.data.GOList){

                    if(thatimg.goDomain!==thatimg.lastDrawn || typeof thatimg.selectedNode==='undefined' || thatimg.selectedNode===null){
                        var goRoot=thatimg.data.GOList[0];
                        if(thatimg.goDomain === "mf"){
                            goRoot=thatimg.data.GOList[2];
                        }else if(thatimg.goDomain === "bp"){
                            goRoot=thatimg.data.GOList[1];
                        }
                        thatimg.selectedNode=goRoot;
                        thatimg.rootN=d3.hierarchy(goRoot)
                        		.sum(function(d){
                						if(d && d.name && d.name.indexOf("ENS")>-1){return 1;}else{return d.uniqueGene;}
                					})
                        		.sort(function(a, b) { return b.value - a.value; });
                        /*thatimg.rootN = thatimg.stratify(goRoot)
				      		.sum(function(d) { if(d.name.indexOf("ENS")>-1){return 1;}else{return d.uniqueGene;} })
				      		.sort(function(a, b) { return b.height - a.height || b.value - a.value; });*/
                    }
	                var nodes = thatimg.partition(thatimg.rootN)
	                				.descendants()
      								.filter(thatimg.filterNodes);
                    thatimg.lastDrawn=thatimg.goDomain;
                    if(thatimg.selectedNode===thatimg.data.GOList[0] || thatimg.selectedNode===thatimg.data.GOList[1]||thatimg.selectedNode===thatimg.data.GOList[2]){
                    	thatimg.totalSize=thatimg.selectedNode.uniqueGene;
                    }
                    //var nodes = thatimg.selectedNode;
                    /*thatimg.maxDepth=d3.max(thatimg.rootN,function(d){return d.depth;});
                    console.log(thatimg.maxDepth);*/
                    //nodes=that.scanFilter(nodes,thatimg.filterNodes);
                    //console.log(nodes);
                    var tmpDisplayDepth=thatimg.displayDepth;
	                /*if(thatimg.displayDepth>thatimg.maxDepth){
	                	tmpDisplayDepth=thatimg.maxDepth;
	                }*/
	                thatimg.arc = d3.arc()
                                .startAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, d.x0)); })
                                .endAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, d.x1)); })
                                .innerRadius(function(d) { return Math.max(0, d.depth*(thatimg.radius/(tmpDisplayDepth+1))); })
                                .outerRadius(function(d) { return Math.max(0, d.depth*(thatimg.radius/(tmpDisplayDepth+1))+(thatimg.radius/(tmpDisplayDepth+1))); });


                    setTimeout(function(){
                        that.singleWGCNATableGoView();
                    },50);
                    thatimg.vis=thatimg.topG.append("svg:circle")
                        .attr("r", thatimg.radius+30)
                        .style("opacity", 0)
                        .on("mouseover",thatimg.mouseleave);
                    var radToDeg=180/Math.PI;
                    var degToRad=Math.PI/180;

                    thatimg.path = thatimg.topG.selectAll("path").data(nodes);
                    
                    thatimg.path.enter().append("path")
                          .attr("d", thatimg.arc)
                          .attr("id",function(d,i){return "ap"+i;})
                          .attr("fill-rule", "evenodd")
                          .attr("fill",thatimg.pathColor)
                          .attr("pointer-events","all")
                          
                          .on("mouseover", thatimg.mouseover)
                          .on("click", thatimg.click)
                          .each(function(d,i){
                    	
		                        var tmpD=d;
		                        var tmpI=i;
		                        var startA=Math.max(0, Math.min(2 * Math.PI, d.x0))*radToDeg;
		                        var endA=Math.max(0, Math.min(2 * Math.PI, d.x1))*radToDeg;
		                        var midA=startA+((endA-startA)/2);
		                        if(startA===0&&endA===360){
		                            midA=90;
		                        }
		                        var curDepth=(tmpD.depth-thatimg.rootN.depth);

		                        /*if(d!==thatimg.rootN.parent){
		                        	thatimg.addLabels(tmpD,tmpI,startA,midA,endA,curDepth,tmpDisplayDepth);
		                        }*/
	                    		thatimg.addLabels(tmpD,tmpI,startA,midA,endA,curDepth,tmpDisplayDepth);
	                    });//.merge(thatimg.path);
                    
                    //thatimg.path
                    thatimg.path.exit().remove();

                    thatimg.svg.append("g")
                            .attr("transform","translate(0,15)")
                            .append("text")
                            .style("fill-opacity", 1)
                            .style("fill", "#000")
                            .attr("pointer-events","none")
                            .attr("text-anchor", "start")
                            .style("opacity",function(d){
                                return 1;
                            })
                            .text(thatimg.selectedNode.uniqueGene+" genes in module with GO annotation");    

                    //thatimg.totalSize = thatimg.path.node().__data__.value;
                }else{
                	thatimg.getModuleGOFile();
                }
            };
            thatimg.filterNodes = function(d,i){
                if(d.depth<(thatimg.rootN.depth+thatimg.displayDepth)){
                    return true;
                }else{
                    return false;
                }
            };
            thatimg.click=function(d){
             	thatimg.selectedNode=d.data;
             	thatimg.rootN=d;
             	//thatimg.selectedNodeParent=d.parent;
              	if(d.data!==thatimg.data.GOList[0] && d.data!==thatimg.data.GOList[1] && d.data!==thatimg.data.GOList[2]){
              		thatimg.redraw();
          		}else{
          			thatimg.draw();
          		}
          		d3.event.stopPropagation();
            };
            
            thatimg.mouseover=function(d){
                if(typeof d !=='undefined' && d !==null){
	                var goRoot=thatimg.data.GOList[0];
	                if(thatimg.goDomain === "mf"){
	                        goRoot=thatimg.data.GOList[2];
	                }else if(thatimg.goDomain === "bp"){
	                        goRoot=thatimg.data.GOList[1];
	                }
	                var percentage =0;
	                if(typeof d !=='undefined'  && typeof d.data.value !=='undefined'){
	                    percentage = (100 * d.data.value / goRoot.uniqueGene).toPrecision(3);
	                }else if(typeof d !=='undefined'){
	                    percentage = (100 * d.data.uniqueGene / goRoot.uniqueGene).toPrecision(3);
	                }else{
	                	percentage= 100;
	                }
	                var percentageString = percentage + "%";
	                if (percentage < 0.1) {
	                  percentageString = "< 0.1%";
	                }
	                if(typeof d.data.name !=='undefined' && d.data.name.indexOf("ENS")===-1){
	                    percentageString= d.data.uniqueGene +" genes ("+percentageString+")";
	                }

	                d3.select("#percentage")
	                    .text(percentageString);

	                d3.select("#explanation")
	                    .style("visibility", "");

	                var sequenceArray = thatimg.getAncestors(d);
	                thatimg.updateBreadcrumbs(sequenceArray, percentageString);

	                // Fade all the segments.
	                d3.selectAll("path")
	                    .style("opacity", 0.3);
	                thatimg.topG.selectAll("text")
	                    .style("opacity", 0.3);

	                // Then highlight only those that are an ancestor of the current segment.
	                thatimg.topG.selectAll("path")
	                    .filter(function(node) {
	                              return (sequenceArray.indexOf(node) >= 0);
	                            })
	                    .style("opacity", 1)
	                    .each(function(d){
	                        thatimg.topG.selectAll(".txt"+removeColon(d.data.id)).style("opacity",1);
	                            });


	                thatimg.topG.selectAll("."+removeColon(d.data.id)).style("opacity",1);
	                
	                tt.transition()        
	                            .duration(200)      
	                            .style("opacity", 1);
	                tt.html(thatimg.createToolTip(d))
	                            .style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
	                            .style("top", function(){return that.positionTTTop(d3.event.pageY);});
	            }
                
                d3.event.stopPropagation();
            };
            
            thatimg.createToolTip=function(d){
               var text="";
               if(d.data){
               		d=d.data
               }
               text="Name:"+d.name+" ("+d.id+")<BR><BR>Definition: "+d.definition+"<BR><BR>Unique Genes in this module with this term: "+d.uniqueGene+"<BR>";
               if(d.uniqueGene>0){
                   for(var k=0;k<d.uniqueGenes.length;k++){
                        if(k>0){
                            text=text+", ";
                        }
                        var g=d.uniqueGenes[k].id;
                        if(typeof thatimg.geneList[g] !=='undefined'){
                                g=thatimg.geneList[g];
                        }
                        text=text+g;
                    }
               }
               return text;
            };
            
            thatimg.mouseleave=function(d) {

                // Hide the breadcrumb trail
                d3.select("#trail")
                    .style("visibility", "hidden");

                d3.selectAll("text")
                    .style("opacity", 1);
                // Deactivate all segments during transition.
                //d3.selectAll("path").on("mouseover", null);

                // Transition each segment to full opacity and then reactivate it.
                d3.selectAll("path")
                    .transition()
                    .duration(500)
                    .style("opacity", 1);
                    /*.each("end", function() {
                            d3.select(this).on("mouseover", thatimg.mouseover);
                          });*/

                d3.select("#explanation")
                    .style("visibility", "hidden");
            
                tt.transition()        
                            .duration(200)      
                            .style("opacity", 0);
            };
            
            // Given a node in a partition layout, return an array of all of its ancestor
            // nodes, highest first, but excluding the root.
            thatimg.getAncestors=function (node) {
                var path = [];
                var current = node;
                while (current.parent) {
                  path.unshift(current);
                  current = current.parent;
                }
                return path;
            };
            
            thatimg.isParentOf=function(p, c) {
                if (p === c) return true;
                if (p.children) {
                  return p.children.some(function(d) {
                    return thatimg.isParentOf(d, c);
                  });
                }
                return false;
            };
            
            // Breadcrumb dimensions: width, height, spacing, width of tip/tail.
            thatimg.b = {
              w: 250, h: 30, s: 3, t: 10,runW:0, runH:0
            };
            
            thatimg.initializeBreadcrumbTrail=function () {
                // Add the svg area.
                d3.select("#singleWGCNASVG").remove();
                d3.select("#trail").remove();
                var trail = d3.select("#viewGene").append("svg:svg")
                    .attr("width", thatimg.width)
                    .attr("height", 68)
                    .attr("id", "trail");
                // Add the label at the end, for the percentage.
                trail.append("svg:text")
                  .attr("id", "endlabel")
                  .style("fill", "#000");
                thatimg.svg=d3.select("#viewGene").append("svg").attr("id","singleWGCNASVG").attr("height",thatimg.height+"px").attr("width","100%");
              };

            // Generate a string that describes the points of a breadcrumb polygon.
            thatimg.breadcrumbPoints=function (d, i) {
              var charNum=d.data.name.length;
              var charWidth=charNum*7.5;
              var curW=charWidth+25;
              var points = [];
              points.push("0,0");
              points.push(curW + ",0");
              points.push(curW + thatimg.b.t + "," + (thatimg.b.h / 2));
              points.push(curW + "," + thatimg.b.h);
              points.push("0," + thatimg.b.h);
              if (i > 0) { // Leftmost breadcrumb; don't include 6th vertex.
                points.push(thatimg.b.t + "," + (thatimg.b.h / 2));
              }
              return points.join(" ");
            };

            // Update the breadcrumb trail to show the current sequence and percentage.
            thatimg.updateBreadcrumbs=function (nodeArray, percentageString) {
                  
                  // Data join; key function combines name and depth (= position in sequence).
                  var g = d3.select("#trail")
                      .selectAll("g")
                      .data(nodeArray, function(d) { return d.data.name + d.depth; });

                  
                  // Remove exiting nodes.
                  g.exit().remove();

                  thatimg.b.runW=0;
                  thatimg.b.runH=0;
                  // Add breadcrumb and label for entering nodes.
                  var entering = g.enter().append("svg:g")
                  	.merge(g).attr("transform", function(d, i) {
	                    var charNum=d.data.name.length;
	                    var charWidth=charNum*7.5;
	                    var curW=charWidth+25;
	                    var toUse=thatimg.b.runW;
	                    if((toUse+curW)>thatimg.width){
	                        toUse=0;
	                        thatimg.b.runH=thatimg.b.runH+thatimg.b.h+thatimg.b.s;
	                        thatimg.b.runW=0;
	                    }
	                    thatimg.b.runW=thatimg.b.runW+curW+thatimg.b.s;
	                    return "translate(" + toUse + ", "+thatimg.b.runH+")";
	                  });

                  entering.append("svg:polygon")
                      .attr("points", thatimg.breadcrumbPoints)
                      .style("fill", thatimg.pathColor);

                  entering.append("svg:text")
                      .attr("x", function(d){
                           var charNum=d.data.name.length;
                            var charWidth=charNum*7.5;
                            var curW=charWidth+25;
                            return (curW + thatimg.b.t) / 2;})
                      .attr("y", thatimg.b.h / 2)
                      .attr("dy", "0.35em")
                      .attr("text-anchor", "middle")
                      .text(function(d) { 
                                var tmpName=d.data.name;
                                if(tmpName.indexOf("ENS")===0){
                                    if(typeof thatimg.geneList[tmpName]!=='undefined'){
                                        tmpName=thatimg.geneList[tmpName];
                                    }
                                }
                                return tmpName; 
                        });
                  

                  // Now move and update the percentage at the end.
                  d3.select("#trail").select("#endlabel")
                      .attr("x", thatimg.b.runW +15)
                      .attr("y", thatimg.b.h / 2+thatimg.b.runH)
                      .attr("dy", "0.35em")
                      .attr("text-anchor", "start")
                      .text(percentageString);

                  // Make the breadcrumb trail visible, if it's hidden.
                  d3.select("#trail")
                      .attr("height",function(){var tmpH=thatimg.b.runH+thatimg.b.h+5; if(tmpH<68){tmpH=68;}return tmpH;})
                      .style("visibility", "");
            };
             
            return thatimg;
	};
    that.flattenTree=function(nodeList,treeNode){
    	//treeNode.depth=depth;
    	if(treeNode.data.name.indexOf("ENS")===-1){
    		nodeList.push(treeNode);
    	}
    	if(treeNode.children){
	    	for(var i=0;i<treeNode.children.length;i++){
	    		that.flattenTree(nodeList,treeNode.children[i]);
	    	}
    	}
    };
    that.singleWGCNATableGoView=function(){
        $('div#waitGoTable').hide();
        $('div#wgcnaModuleTable').hide();
        $('div#wgcnaMirTable').hide();
        $('div#wgcnaMirGeneTable').hide();
        $('div#wgcnaEqtlTable').hide();
        $('div#wgcnaGoTable').show();
        //$('span#GoTableName').html(that.selectedModule.MOD_NAME);
        
        d3.select("div#tableExportCtl").selectAll("span").remove();
        d3.select("div#tableExportCtl").append("span")
                    .attr("class","button")
                    .style("margin-right","10px")
                    .on("click",function(){
                       $('#GoTable').tableExport({type:'csv',escape:'false'});
                    })
                    .html("Export CSV");
        
        if($.fn.DataTable.isDataTable( 'table#GoTable' )){
                $('table#GoTable').DataTable().destroy();
        }
        
        d3.select('#GoTable').select('tbody').selectAll('tr').remove();

        //var root=that.singleImage.selectedNode;
        var nodes=[];
        var tree=that.singleImage.rootN;
        that.flattenTree(nodes,tree);
        //var nodes=that.singleImage.rootN;
        /*var nodes=that.singleImage.partition(root);
        nodes=nodes.filter(function(d,i){
            if(d.name.indexOf("ENS")===0){
                return false;
            }else{
                return true;
            }
        });*/

        //setup table data2
        var tracktbl=d3.select("#GoTable").select("tbody").selectAll('tr')
                        .data(nodes,function(d,i){return i;});
        tracktbl.exit().remove();
        tracktbl.enter().append("tr")
                        
                        .style("background-color",that.singleImage.pathColor)
                        .style("display",function(d){
                            var val="none"; 
                            if(d.depth<=that.singleImage.rootN.depth){
                                val="";
                            }else if(d.depth===that.singleImage.rootN.depth+1){
                                val="";
                            }
                            return val;
                        })
                        .style("cursor","pointer")
                        .merge(tracktbl)
                        .attr("id",function(d){return d.id;})
                        .attr("class",function(d){return " d"+d.depth;})
                        .on("mouseover",function(d){
                        	d3.select(this).style("background-color","#FFFFFF");
                        	if(ga){
		                        ga('send','event','wgcna','mouseOverGOTbl');
		                    }
                        })
                        .on("mouseleave",function(d){
                        	d3.select(this).style("background-color",that.singleImage.pathColor(d));
                        })
                        .on("click",function(d){
                        	that.singleImage.selectedNode=d.data;
                        	that.singleImage.rootN=d;
                        	$('span[name=d'+d.depth+']').addClass("less");
                			$("tr.d"+d.depth).show();
                        	that.singleImage.redraw();
                        	if(ga){
		                        ga('send','event','wgcna','mouseClickGOTbl');
		                    }
                        }).each(function(d,i){
			                var tmpI=i;
			                var tmpD=d;
			                var row=d3.select(this);
			                row.append("td")
                                .style("padding-left",function(){return tmpD.depth*20+"px";})
                                .html(function(){
                                    var col=tmpD.data.name+" ("+tmpD.data.id+")";
                                    if(tmpD.data.name.indexOf("ENS")>-1){
                                        col=that.singleImage.geneList[tmpD.data.name]+" ("+tmpD.data.id+")";
                                    }
                                    var html=col;
                                    if(typeof tmpD.children !=='undefined'&& tmpD.children.length>0){
                                        var trState="";
                                        if(tmpD.depth<=that.singleImage.rootN.depth){
                                            trState=" less";
                                        }
                                        var found=0;
                                        for(var v=0;v<tmpD.children.length&&found===0;v++){
                                        	if(tmpD.children[v].data.name.indexOf("ENS")===-1){
                                        		found=1;
                                        	}
                                        }
                                        if(found===1){
                                        	html="<span class=\"trigger"+trState+"\" name=\"d"+(tmpD.depth+1)+"\">"+col+"</span>";
                                    	}else{
                                    		html=col;
                                    	}
                                    }
                                    return html;
                                });
			                row.append("td").html(d.data.definition);
			               	row.append("td").html(function(){
	                            var html="";
	                            if(tmpD.data.uniqueGene>0){
	                                html="<span class=\"triggerGL\" name=\"gl"+tmpI+"\">"+tmpD.data.uniqueGene+"</span><BR>";
	                                html=html+"<span id=\"gl"+tmpI+"\" style=\"display:none;\" >";
	                                for(var k=0;k<tmpD.data.uniqueGenes.length;k++){
	                                    if(k>0){
	                                        html=html+", ";
	                                    }
	                                    var g=tmpD.data.uniqueGenes[k].id;
	                                    if(typeof that.singleImage.geneList[g] !=='undefined'){
	                                            g=that.singleImage.geneList[g];
	                                    }
	                                    html=html+g;
	                                }
	                                html=html+"</span>";
	                            }else{
	                                html="0";
	                            }
	                            return html;
	                        });
        				});
        $("#GoTable .trigger").on("click",function(event){
            var level=this.getAttribute("name");
            if($("."+level).is(":hidden")){
                $('span[name='+level+']').addClass("less");
                $("tr."+level).show();
            }else{
                var num=parseInt(level.substr(1));
                while( $("tr.d"+num).length > 0 ){
                	$('span[name=d'+num+']').removeClass("less");
                	$("tr.d"+num).hide();
                	num++;
                }
            }
            event.stopPropagation();
        });
        
        $("#GoTable .triggerGL").on("click",function(event){
            var id=this.getAttribute("name");
            if($("#"+id).is(":hidden")){
                $(this).addClass("less");
                $("span#"+id).show();
            }else{
                $(this).removeClass("less");
                $("span#"+id).hide();
            }
            event.stopPropagation();
        });
        
        $('#GoTable').DataTable({
                        "bPaginate": false,
                        "bSort": false,
                        "asStripClasses":[],
                        /*"bProcessing": true,
                        "bStateSave": false,
                        "bAutoWidth": true,
                        "bDeferRender": true,
                        "aaSorting": [[ 3, "desc" ]],*/
        
                        "sDom": 'f<t>'
                });
        
        
        
    };

	return that;
};