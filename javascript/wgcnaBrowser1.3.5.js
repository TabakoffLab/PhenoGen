/*
*	D3js based WGCNA Data Browser
*
* 	Author: Spencer Mahaffey
*	for http://phenogen.ucdenver.edu
*	Tabakoff Lab
* 	University of Colorado Denver AMC
* 	Department of Pharmaceutical Sciences Skaggs School of Pharmacy & Pharmaceutical Sciences
*
*	Builds an interactive view of WGCNA Modules.
*/
$(window).resize(function(){
    if(typeof wgcna !=='undefined'){
        if(typeof wgcna.multiImage !=='undefined'){
            wgcna.multiImage.draw();
        }else if(typeof wgcna.singleImage !=='undefined'){
            wgcna.singleImage.draw();
        }
    }
});

function replaceDot(str){
    return str.replace(/\./g, '_');
}

function replaceUnderscore(str){
    return str.replace(/_/g, '.');
}

function removeColon(str){
    return str.replace(/:/g, '');
}


function WGCNABrowser(id,region,geneList,disptype,viewtype,tissue){
	that={};
	that.singleID=id;
    that.region=region;
	that.dispType=disptype;
	that.viewType=viewtype;
    that.geneList=geneList;
	that.moduleList=[];
    that.moduleGenes={};
	that.modules={};
	that.tissue=tissue;
	that.panel="";
	that.requests=0;
	that.skipGrey=1;
    that.chrLen=19;
    that.selSource="seq";

    if(organism==="Mm"){
            that.panel="ILS/ISS";
            that.wDSID=1;
    }else if(organism==="Rn"){
    	if(genomeVer==="rn5"){
            that.panel="BNLx/SHR";
            that.chrLen=20;
            that.wDSID=2;
        }else{
        	that.panel="BNLx/SHR";
            that.chrLen=20;
            if(that.selSource==="seq"){
            	if(tissue==="Whole Brain"){
	            	that.wDSID=6;
	            }else if(tissue==="Liver"){
					that.wDSID=7;
	            }
            }else{
	            if(tissue==="Whole Brain"){
	            	that.wDSID=3;
	            }else if(tissue==="Heart"){
					that.wDSID=4;
	            }else if(tissue==="Liver"){
					that.wDSID=5;
	            }
        	}
        }
    }
    that.eQTLKey=function(d){return "Link_"+d.Snp;};
    that.mirKey=function(d){return d.ID;};
    that.modKey=function(d){return d.MODULE;};
    that.removeInvalidIDChars=function(id){
    	var newID=id;
    	if(typeof newID!=="undefined"){
	    	if(newID.indexOf("*")>-1){
	    		newID=newID.replace(/\*/g, "star");
	    	}
	    	if(newID.indexOf(" ")>-1){
	    		newID=newID.replace(/\s/g,"_");
	    	}
	    	if(newID.indexOf(".")>-1){
	    		newID=newID.replace(/\./g,"_");
	    	}
    	}
    	return newID;
    }
	that.setup=function(){
		//request Module List
		that.requestModuleList();
		//create Image Controls
		that.createImageControls();
		//create View Controls
		that.createViewControls();
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
        if(ga){
			ga('send','event','setupWGCNA','setupWGCNA');
		}
	};

	that.requestModuleList=function (){
		that.moduleGenes={};
		that.moduleList=[];
		$.ajax({
				url:  pathPrefix +"getWGCNAModules.jsp",
	   			type: 'GET',
	   			async: true,
				data: {source:that.selSource,modFileType:that.viewtype,id:that.singleID,organism:organism,panel:that.panel,tissue:that.tissue,region:that.region,geneList:that.geneList,genomeVer:genomeVer},
				dataType: 'json',
				beforeSend: function(){
					$("#waitCircos").show();
					console.log("request mod list:"+that.wDSID+":"+that.selSource);
				},
	    		success: function(data2){
                                $('#wgcnaGeneImage #message').hide();
                                that.moduleList=[];
                                if(data2.length>0 && !(data2.length===1 && data2[0].ModuleID==="grey")){
                                    for(var i=0;i<data2.length;i++){
                                        if(data2[i].ModuleID!=="grey"){// && data2[i].ModuleID !=="turquoise"){
                                                    that.moduleList.push(data2[i].ModuleID); 
                                                    //var isLast=data2.length-i;
                                                    that.requests++;
                                                    that.requestModule(data2[i].ModuleID);
                                                    if(typeof data2[i].GeneList !=='undefined'){
                                                        that.moduleGenes[data2[i].ModuleID]=data2[i].GeneList;
                                                    }
                                                    //console.log("after calling:"+that.requests+":"+data2[i].ModuleID);
                                        }
                                    }
                                    that.refreshRegion(1000);
                                    setTimeout(function(){
                                    	$('html, body').animate({
											scrollTop: $("#multiWGCNAScroll").offset().top
										}, 100);
                                    },1200);
                                }else if(data2.length===0){
                                    that.displayMessage("There are no transcripts with Affymetrix Probesets that represent this gene.");
                                }else if(data2.length===1 && data2[0].ModuleID==="grey"){
                                    that.displayMessage("Only the Grey module contains transcripts for this gene.  The Grey module contains all transcripts that did not have a high enough correlation with any other transcripts to be included in another module.");
                                }
                                if(ga){
										ga('send','event','requestModuleList','requestModuleList');
								}
	        		//console.log(that.moduleList);
	    		},
	    		error: function(xhr, status, error) {
	        		
	    		}
		});
	};
        
    that.displayMessage=function(message){
        $("#waitCircos").hide();
        $('#wgcnaGeneImage #message').html("<BR><BR><h2>"+message+"</h2><BR><BR>").show();
    };
        
    that.refreshRegion=function(timeout){
        setTimeout(function(){
                //console.log("calling createMultiImage"+file);
                that.createMultiWGCNAImage();
                if(that.requests>0){
                    that.refreshRegion(2000);
                }else if(timeout===1){
                    
                }else{
                    that.refreshRegion(1);
                    $("#waitCircos").hide();
                }
        },timeout);
    };
	that.requestModule=function(file,callBack){
		$.ajax({
				url:  contextRoot+"tmpData/browserCache/"+genomeVer+"/modules/ds"+that.wDSID+"/" +file+".json",
	   			type: 'GET',
	   			async: true,
				data: {},
				dataType: 'json',
	    		success: function(data2){
                                        
                                        setTimeout(function(){
                                            console.log(file);
                                            if(that.singleID.length>0){
                                                that.countGeneInstance(that.singleID,data2);
                                            }else{
                                                var tmp=that.moduleGenes[file].split(",");
                                                data2.GroupedGenes=tmp.length;
                                                that.countGeneInstance(that.moduleGenes[file],data2);
                                            }
                                            that.modules[file]=data2;
                                            that.requests--;
                                            /*if(that.requests===0){
                                                setTimeout(function(){
                                                    //console.log("calling createMultiImage"+file);
                                                    that.createMultiWGCNAImage();
                                                },20);
                                            }*/
                                            if(callBack){
                                            	callBack(file);
                                            }
                                        },20);
                                        if(ga){
											ga('send','event','requestModule',file);
										}
	    		},
	    		error: function(xhr, status, error) {
	        		that.requests--;
	    		}
		});

	};
	that.scanFilter=function(nodes,fctn){
		var toReturn=[];
		if(nodes){
			for(var i=0;i<nodes.length;i++){
				if(fctn(nodes[i])){
					toReturn.append(nodes[i]);
				}
			}
		}
		return toReturn;
	};
	that.countGeneInstance=function(idlist,data){
		var list=data.TCList;
		var count=0;
		data.selectGeneTC={};
		for(var k=0;k<list.length;k++){
                        //console.log(data.ID+":"+list[k].Gene.ID);
			if(idlist.indexOf(list[k].Gene.ID)>-1){
				//data.selectGeneTC[list[k].ID]=1;
				count++;
			}
		}
		data.GeneCount=count;
	};
	that.createImageControls=function(){
		//that.imageBar=d3.select("div#wgcnaImageControls").append("span").style("float","left");
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
									region=new String(that.selectedModule.MOD_NAME);
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
					if(ga){
						ga('send','event','saveWGCNAView','saveWGCNAView');
					}
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

		that.imageBar.append("span").attr("class","reset control").style("display","inline-block")
			.attr("id","wgcnaresetImage")
			.style("cursor","pointer")
			.append("img")//.attr("class","mouseOpt dragzoom")
			.attr("src",contextRoot+"web/images/icons/reset_dark.png")
			.attr("pointer-events","all")
			.attr("cursor","pointer")
			.on("click",function(){
				if(that.singleImage){
	                if(that.viewType==="eqtl"){
	                    that.singleImage.panZoomCircos.reset();
	                }/*else if(that.singleImage==undefined){
						var id=new String($(this).parent().attr("id"));

						var level=id.substr(id.length-1);
						if(level==0){
							$('#geneTxt').val(chr+":"+initMin+"-"+initMax);
						    svgList[0].xScale.domain([initMin,initMax]);
							svgList[0].scaleSVG.select(".x.axis").call(svgList[0].xAxis);
							svgList[0].redraw();
						}else{
						    svgList[level].xScale.domain([svgList[level].initMin,svgList[level].initMax]);
							svgList[level].scaleSVG.select(".x.axis").call(svgList[level].xAxis);
							svgList[level].redraw();
						}
	                }*/else if(typeof that.singleImage !=="undefined"){
	                    that.singleImage.panZoom.reset();
	                }
            	}
            	if(ga){
					ga('send','event','resetWGCNAView','resetWGCNAView');
				}
			})
			.on("mouseover",function(){
				d3.select(this).attr("src",contextRoot+"web/images/icons/reset_white.png");
				$("#wgcnaMouseHelp").html("Click to reset image zoom to initial region.");
			})
			.on("mouseout",function(){
				d3.select(this).attr("src",contextRoot+"web/images/icons/reset_dark.png");
				$("#wgcnaMouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
			});
		that.imageBar.append("span").attr("class","zoomIn control")
			.style("display","inline-block")
			.style("cursor","pointer")
			.style("position","relative")
			.style("top","7px")
			.attr("id","wgcnazoomInImage")
			.append("img")
			.attr("src",contextRoot+"web/images/icons/magPlus_dark_32.png")
			.attr("pointer-events","all")
			.attr("cursor","pointer")
			.style("position","relative")
			.style("top","-5px")
			.on("click",function(){
                            if(that.viewType==="eqtl" && that.singleImage ){
                                that.singleImage.panZoomCircos.zoomIn();
                            }else if(that.singleImage==undefined && that.multiImage){
								that.multiImage.zoomIn();
                            }else if(typeof that.singleImage!=='undefined' && that.singleImage ){
                                that.singleImage.panZoom.zoomIn();
                            }
                            if(ga){
								ga('send','event','zoomInWGCNAView','zoomInWGCNAView');
							}
			})
			.on("mouseover",function(){
				d3.select(this).attr("src",contextRoot+"web/images/icons/magPlus_light_32.png");
				$("#wgcnaMouseHelp").html("Click to zoom in.");
			})
			.on("mouseout",function(){
				d3.select(this).attr("src",contextRoot+"web/images/icons/magPlus_dark_32.png");
				$("#wgcnaMouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
			});
		that.imageBar.append("span").attr("class","zoomOut control")
			.style("display","inline-block")
			.style("cursor","pointer")
			.style("position","relative")
			.style("top","7px")
			.attr("id","wgcnazoomOutImage")
			.append("img")
			.attr("src",contextRoot+"web/images/icons/magMinus_dark_32.png")
			.attr("pointer-events","all")
			.attr("cursor","pointer")
			.style("position","relative")
			.style("top","-5px")
			.on("click",function(){
                            if(that.viewType==="eqtl" && that.singleImage){
                                that.singleImage.panZoomCircos.zoomOut();
                            }else if(that.singleImage==undefined && that.multiImage){
								that.multiImage.zoomOut();
                            }else if(that.singleImage && typeof that.singleImage!=='undefined' && typeof that.singleImage.panZoom !=='undefined' ){
                                that.singleImage.panZoom.zoomOut();
                            }
				if(ga){
						ga('send','event','zoomOutWGCNAView','zoomOutWGCNAView');
				}
			})
			.on("mouseover",function(){
				d3.select(this).attr("src",contextRoot+"web/images/icons/magMinus_light_32.png");
				$("#wgcnaMouseHelp").html("Click to zoom out.");
			})
			.on("mouseout",function(){
				d3.select(this).attr("src",contextRoot+"web/images/icons/magMinus_dark_32.png");
				$("#wgcnaMouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
			});
		that.imageBar.append("span").attr("class","back control")
			.style("display","inline-block")
			.style("cursor","pointer")
			.style("position","relative")
			.style("top","7px")
			.attr("id","backModule")
			.append("img")
			.attr("src",contextRoot+"web/images/icons/back_dark_32.png")
			.attr("pointer-events","all")
			.attr("cursor","pointer")
			.style("position","relative")
			.style("top","-5px")
			.on("click",function(){
				that.multiImage.backModule();
			})
			.on("mouseover",function(){
				d3.select(this).attr("src",contextRoot+"web/images/icons/back_light_32.png");
				$("#wgcnaMouseHelp").html("Click to move to the previous module.");
			})
			.on("mouseout",function(){
				d3.select(this).attr("src",contextRoot+"web/images/icons/back_dark_32.png");
				$("#wgcnaMouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
			});
		that.imageBar.append("span").attr("class","forward control")
			.style("display","inline-block")
			.style("cursor","pointer")
			.style("position","relative")
			.style("top","7px")
			.attr("id","forwardModule")
			.append("img")
			.attr("src",contextRoot+"web/images/icons/forward_dark_32.png")
			.attr("pointer-events","all")
			.attr("cursor","pointer")
			.style("position","relative")
			.style("top","-5px")
			.on("click",function(){
				that.multiImage.forwardModule();
			})
			.on("mouseover",function(){
				d3.select(this).attr("src",contextRoot+"web/images/icons/forward_light_32.png");
				$("#wgcnaMouseHelp").html("Click to move to the next module.");
			})
			.on("mouseout",function(){
				d3.select(this).attr("src",contextRoot+"web/images/icons/forward_dark_32.png");
				$("#wgcnaMouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
			});
	};

	that.createViewControls=function(){
		//that.viewBar=d3.select("div#wgcnaImageControls").append("span").attr("id","wgcnaViewControls").style("float","right").style("margin-left","10px").style("margin-right","5px");
        that.viewBar=d3.select("#viewControl").append("div").attr("id","wgcnaViewControls").style("float","right").style("margin-left","10px").style("margin-right","5px").style("text-align","left");
		that.viewBar.append("text").text("Views:");
        that.viewBar.append("span").attr("id","HelpWGCNAView")
                .append("img").attr("src",contextRoot+"web/images/icons/help.png");
        that.viewBar.append("br");
		that.viewBar.append("input").attr("type","radio").attr("id","wgcnaGeneViewRB").attr("name","wgcnaViewRB").attr("value","gene").attr("checked","checked").style("margin-left","7px").style("margin-right","3px").on("click",function(){
            that.viewType="gene";
            that.createSingleWGCNAImage();
            if(ga){
						ga('send','event','WGCNA','moduleView');
					}
        });;
		that.viewBar.append("text").text("Module");
                that.viewBar.append("span").attr("class","wgcnaControltooltip").attr("title","View transcripts within the selected module and their connectivity based on correlation of expression.<BR><BR>Have a question about this view click the <img src=\""+contextRoot+"web/images/icons/help.png\"> above for a detailed description of each view.").style("margin-left","5px").append("img").attr("src","/web/images/icons/info.gif");
                that.viewBar.append("br");
		that.viewBar.append("input").attr("type","radio").attr("id","wgcnaEQTLViewRB").attr("name","wgcnaViewRB").attr("value","eqtl").style("margin-left","7px").style("margin-right","3px").on("click",function(){
            that.viewType="eqtl";
            that.createSingleWGCNAImage();
            if(ga){
						ga('send','event','WGCNA','eQTLView');
					}
        });
		that.viewBar.append("text").text("Eigengene eQTL");
        that.viewBar.append("span").attr("class","wgcnaControltooltip").attr("title","View Circos plot of the module Eigengene eQTLs.<BR><BR>Have a question about this view click the <img src=\""+contextRoot+"web/images/icons/help.png\"> above for a detailed description of each view.").style("margin-left","5px").append("img").attr("src","/web/images/icons/info.gif");

        that.viewBar.append("br");
        that.viewBar.append("input").attr("type","radio").attr("id","wgcnaGOViewRB").attr("name","wgcnaViewRB").attr("value","go").style("margin-left","7px").style("margin-right","3px")//.attr('disabled',true)
        	.on("click",function(){
	            that.viewType="go";
	            that.createSingleWGCNAImage();
	            if(ga){
							ga('send','event','WGCNA','goView');
				}
	        });
		that.viewBar.append("text").text("Gene Ontology");
        that.viewBar.append("span").attr("class","wgcnaControltooltip").attr("title","TEMPORARILY DISABLED PLEASE CHECK BACK. View a summary of Gene Ontology terms assigned to transcripts in the selected module.<BR><BR>Have a question about this view click the <img src=\""+contextRoot+"web/images/icons/help.png\"> above for a detailed description of each view.").style("margin-left","5px").append("img").attr("src","/web/images/icons/info.gif");
        
        that.viewBar.append("br");
        that.viewBar.append("input").attr("type","radio").attr("id","wgcnaMirViewRB")
                .attr("name","wgcnaViewRB")
                .attr("value","mir")
                .style("margin-left","7px")
                .style("margin-right","3px")
                .on("click",function(){
                    that.viewType="mir";
                    that.createSingleWGCNAImage();
                    if(ga){
						ga('send','event','WGCNA','mirView');
					}
                });
        that.viewBar.append("text").text("miRNA Targets");
        that.viewBar.append("span").attr("class","wgcnaControltooltip").attr("title","View a summary of miRNAs that target genes in this module.<BR><BR>Have a question about this view click the <img src=\""+contextRoot+"web/images/icons/help.png\"> above for a detailed description of each view.").style("margin-left","5px").append("img").attr("src","/web/images/icons/info.gif");
        
        
        that.viewBar.append("br");
        that.viewBar.append("input").attr("type","radio").attr("id","wgcnaMetaViewRB").attr("name","wgcnaViewRB").attr("value","meta").style("margin-left","7px").style("margin-right","3px").on("click",function(){
            that.viewType="meta";
            that.createSingleWGCNAImage();
            if(ga){
						ga('send','event','WGCNA','metaView');
			}
        });
		that.viewBar.append("text").text("Meta Module (nearest neighbors)");
		that.viewBar.append("span").attr("class","wgcnaControltooltip").attr("title","View most closely correlated modules and browse those modules.<BR><BR>Have a question about this view click the <img src=\""+contextRoot+"web/images/icons/help.png\"> above for a detailed description of each view.").style("margin-left","5px").append("img").attr("src","/web/images/icons/info.gif");

        $("#HelpWGCNAView").on('click', function(event){
			var id=$(this).attr('id');
			$('#'+id+'Content').dialog( "option", "position",{ my: "right top", at: "left bottom", of: $(this) });
			$('#'+id+'Content').dialog("open").css({'font-size':12});
			event.stopPropagation();
			//return false;
		});
    };
        
	that.createDataControls=function(){
		//that.dataBar=d3.select("div#wgcnaImageControls").append("span").attr("id","wgcnaDataControls").style("float","right").style("margin-left","10px").style("margin-right","5px")
        that.dataBar=d3.select("#dataControl").append("span").attr("id","wgcnaDataControls").style("margin-left","10px").style("margin-right","5px")
                            .append("table").append("tr");
        var dataSel=that.dataBar.append("td");
        dataSel.append("text").text("Data Source:");
		var sel=dataSel.append("select").attr("id","wgcnaSourceSelect").on("change",function(){
			$("#singleWGCNASVG").hide();
			d3.select("#multiWGCNASVG").remove();
			$("#circosModule").hide();
			$("#wgcnaModuleTable").hide();
			$("#wgcnaMirTable").hide();
			$("#wgcnaMirGeneTable").hide();
			$("#wgcnaGoTable").hide();
			$("#wgcnaEqtlTable").hide();
			that.selSource=$('#wgcnaSourceSelect').val();
			that.tissue=$('#wgcnaTissueSelect').val();
			if(that.selSource==="array"){
				if(that.tissue==="Whole Brain"){
	            	that.wDSID=3;
	            }else if(that.tissue==="Heart"){
					that.wDSID=4;
	            }else if(that.tissue==="Liver"){
					that.wDSID=5;
	            }
	            d3.select("#wgcnaTissueSelect").append("option").attr("value","Heart").text("Heart");
       		}else if(that.selSource==="seq"){
       			if(that.tissue==="Whole Brain"){
	            	that.wDSID=6;
	            }else if(that.tissue==="Liver"){
					that.wDSID=7;
	            }else{
	            	that.wDSID=6;
	            	d3.select("#wgcnaTissueSelect").select("option[value=\"Brain\"]").attr("selected","selected");
	            }
	            d3.select("#wgcnaTissueSelect").select("option[value=\"Heart\"]").remove();
       		}
			that.requestModuleList();
		});
		that.sources=["array"];
		that.dispSources=["Arrays"];
		//We only have brain will need to update later.
        if(organism==="Rn" && genomeVer==="rn6"){
			that.sources=["seq","array"];
			that.dispSources=["RNA-Seq","Arrays"];
		}
		for(var i=0;i<that.sources.length;i++){
			sel.append("option").attr("value",that.sources[i]).text(that.dispSources[i]);
		}
		dataSel.append("br");
        dataSel.append("text").text("Tissue:");
		var sel=dataSel.append("select").attr("id","wgcnaTissueSelect").on("change",function(){
			$("#singleWGCNASVG").hide();
			d3.select("#multiWGCNASVG").remove();
			$("#circosModule").hide();
			$("#wgcnaModuleTable").hide();
			$("#wgcnaMirTable").hide();
			$("#wgcnaMirGeneTable").hide();
			$("#wgcnaGoTable").hide();
			$("#wgcnaEqtlTable").hide();
			that.selSource=$('#wgcnaSourceSelect').val();
			that.tissue=$('#wgcnaTissueSelect').val();
			if(that.selSource==="array"){
				if(that.tissue==="Whole Brain"){
	            	that.wDSID=3;
	            }else if(that.tissue==="Heart"){
					that.wDSID=4;
	            }else if(that.tissue==="Liver"){
					that.wDSID=5;
	            }
       		}else if(that.selSource==="seq"){
       			if(that.tissue==="Whole Brain"){
	            	that.wDSID=6;
	            }else if(that.tissue==="Liver"){
					that.wDSID=7;
	            }
       		}
			that.requestModuleList();
		});
		that.tissues=["Brain"];
		that.dispTissues=["Whole Brain"];
		//We only have brain will need to update later.
        if(organism==="Rn" && genomeVer==="rn6"){
        	if(that.source && that.source==="arrays"){
        		that.tissues=["Whole Brain","Heart","Liver"];
				that.dispTissues=["Whole Brain","Heart","Liver"];
        	}else{
        		that.tissues=["Whole Brain","Liver"];
				that.dispTissues=["Whole Brain","Liver"];
        	}
			
		}
		for(var i=0;i<that.tissues.length;i++){
			sel.append("option").attr("value",that.tissues[i]).text(that.dispTissues[i]);
		}
                
                var go=that.dataBar.append("td").append("div").attr("id","goCtls").attr("class","goCTL").style("display","none").style("margin-left","10px");
                go.append("text").text("GO Domain:");
                sel=go.append("select").attr("id","goDomainSelect").on("change",function(){
                    that.singleImage.goDomain=$("#goDomainSelect").val();
                    that.singleImage.draw();
                    if(ga){
						ga('send','event','WGCNA_go','changeDomain');
					}
                });
                sel.append("option").attr("value","cc").text("Cellular Component");
                sel.append("option").attr("value","bp").text("Biological Process");
                sel.append("option").attr("selected","selected").attr("value","mf").text("Molecular Function");
                go.append("br");
                go.append("text").text("Number of Levels to Display:");
                go.append("input").attr("name","value").attr("id","goSpinner");
                
                $("#goSpinner").spinner({
                    min: 1,
                    max: 100,
                    step: 1,
                    change: function( event, ui ) {
                    	console.log("change");
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
							ga('send','event','WGCNA_go','changeDepth');
						}
                    },
                    spin: function( event, ui ) {
                    	/*console.log("spin"+ui.value+":"+that.singleImage.maxDepth);
                    	if(ui.value<=(that.singleImage.maxDepth+1)){*/
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
							ga('send','event','WGCNA_go','changeDepth');
						}
                    }
                }).val(3);
                
                
                var mir=that.dataBar.append("td").append("div").attr("id","mirCtls").attr("class","mirCTL").style("display","none").style("margin-left","10px");
                var row=mir.append("table").append("tr");
                mir.append("text").style("font-weight","bold").text("Filter miRNAs:");
                mir.append("br");
                mir.append("input").attr("type","checkbox").style("margin-right","5px").attr("id","mirValidatedCBX").on("click",function(){
                    if($(this).is(':checked')){
                        that.singleImage.mirValid=1;
                    }else{
                        that.singleImage.mirValid=0;
                    }
                    that.singleImage.drawMiR();
                    if(ga){
							ga('send','event','WGCNA_mir','changeValidated');
					}
                });
                mir.append("text").text("only miRNAs with Validated Targets");
                mir.append("br");
                mir.append("text").style("margin-right","5px").text("# of targeted Genes: ");
                mir.append("div").attr("id","minMirGeneSlider").style("display","inline-block").style("width","150px");
                mir.append("span").attr("id","minMirGeneLabel").style("margin-left","5px").append("text").text("1");
                mir.append("br");
                mir.append("text").style("margin-right","5px").text("miRNAs targeting gene: ");
                mir.append("input").attr("type","text").attr("id","mirGeneFilterTxt").on("keyup",function(d){
                    that.singleImage.mirTargetID=$(this).val().toLowerCase();
                    that.singleImage.drawMiR();
                    if(ga){
							ga('send','event','WGCNA_mir','geneFilter');
					}
                });
                 mir.append("br");
                mir.append("text").style("margin-right","5px").text("miRNA(ID or Accession): ");
                mir.append("input").attr("type","text").attr("id","mirIDFilterTxt").on("keyup",function(d){
                    that.singleImage.mirID=$(this).val().toLowerCase();
                    that.singleImage.drawMiR();
                    if(ga){
							ga('send','event','WGCNA_mir','geneFilter');
					}
                });
                
                mir=that.dataBar.append("td").append("div").attr("id","mirCtls2").attr("class","mirCTL").style("display","none").style("margin-left","10px");
                mir.append("text").style("font-weight","bold").text("Display Options:");
                
                 mir.append("br");
                mir.append("input").attr("type","checkbox").attr("id","mirSortCBX").style("margin-right","5px").on("click",function(){
                    if($(this).prop('checked')){
                        that.singleImage.sortMir=$("#mirSortSelect").val();
                    }else{
                        that.singleImage.sortMir=0;
                    }
                    //console.log("set:"+that.singleImage.sortMir);
                    that.singleImage.drawMiR();
                    if(ga){
							ga('send','event','WGCNA_mir','mirSort');
					}
                });
                /*mir.append("text").style("margin-right","5px").style("margin-left","5px").text(" sort by # targeted Genes order ");
                sel=mir.append("select").attr("id","mirSortSelect").on("change",function(){
                    if($("#mirSortCBX").prop('checked')){
                        that.singleImage.sortMir=$(this).val();
                        that.singleImage.drawMiR();
                    }
                    if(ga){
							ga('send','event','WGCNA_mir','mirSort');
					}
                });
                sel.append("option").attr("value","1").text("Ascending");
                sel.append("option").attr("value","-1").text("Descending");
                mir.append("br");*/
                mir.append("text").text("Hovering over a node(miR or transcript):");
                mir.append("br");
                mir.append("input").attr("type","checkbox")
                		.attr("id","mirLinkCBX")
                        .attr("checked","checked")
                        .style("margin-left","12px")
                        .style("margin-right","3px")
                        .on("click",function(){
                            if($(this).prop('checked')){
                                that.singleImage.showMirLinks=1;
                            }else{
                                that.singleImage.showMirLinks=0;
                            }
                            //that.singleImage.drawMiR();
                            if(ga){
								ga('send','event','WGCNA_mir','showLinks');
							}
                        });
				mir.append("text").text("Display links between miRNAs and targeted transcripts");
                mir.append("br");
                mir.append("input").attr("type","checkbox")
                		.attr("id","mirgeneLinkCBX")
                        .style("margin-left","12px")
                        .style("margin-right","3px")
                        .on("click",function(){
                            if($(this).prop('checked')){
                                that.singleImage.showLinks=0;
                                $("div#mirLinkColorSelect").show();
                            }else{
                                that.singleImage.showLinks=1;
                                $("div#mirLinkColorSelect").hide();
                            }
                            that.singleImage.setupLegend();
                            //that.singleImage.drawMiR();
                            if(ga){
								ga('send','event','WGCNA_mir','linkColor');
							}
                        });
				mir.append("text").text("Display links between correlated transcripts");
                var colorSel=mir.append("div").attr("id","mirLinkColorSelect").style("display","none");
                colorSel.append("text").style("margin-left","24px").text("Correlation Link Color Options:");
                //colorSel.append("br");
                var selMir=colorSel.append("select").attr("id","mirlinkColor").on("change",function(){
                    that.singleImage.updateColor("mirlinkColor");
                    that.singleImage.setupLegend();
                    if(ga){
						ga('send','event','WGCNA_mir','linkColor');
					}
                });
                selMir.append("option").attr("selected","selected").attr("value","Green_Red").text("Green(+) / Red(-)");
                selMir.append("option").attr("value","Blue_Yellow").text("Blue(+) / Yellow(-)");
                selMir.append("option").attr("value","Red_Green").text("Red(+) / Green(-)");
                colorSel.append("br");
                colorSel.append("input").attr("type","checkbox")
                        .style("margin-left","24px")
                        .style("margin-right","3px")
                        .on("click",function(){
                            if($(this).prop('checked')){
                            	that.singleImage.showAllFromTarget=1;
                            }else{
                            	that.singleImage.showAllFromTarget=0;
                            }
                            if(ga){
								ga('send','event','WGCNA_mir','linkColor');
							}
                        });
                colorSel.append("text").text("Display all cor. transcript links from targeted transcripts.");
                
                $( "#minMirGeneSlider" ).slider({
                    min: 1,
                    max: 100,
                    step: 1,
                    value:1,
                    slide: function( event, ui ) {
                        that.singleImage.mirGeneCutoff=ui.value;
                        $("span#minMirGeneLabel").html(ui.value);
                        //that.singleImage.CorCutoff_max=ui.values[ 1 ];
                        that.singleImage.drawMiR();
                        if(ga){
								ga('send','event','WGCNA_mir','minMir');
							}
                    }
                  });
                
                var links=that.dataBar.append("td").append("div").attr("id","linkCtls").attr("class","linkCTL").style("display","none").style("margin-left","10px");
                links.append("text").text("Link Correlation Values");
                links.append("span").style("cursor","pointer")
                        .on("click",function(){
                            $("#linkSliderMin").slider('value',0.75);
                            that.singleImage.CorCutoff_min=0.75;
                            $("span#minLabel").html(0.75);
                            
                            $("#linkSliderMax").slider('value',1.0);
                            that.singleImage.CorCutoff_max=1.0;
                            $("span#maxLabel").html(1.0);
                            
                            that.singleImage.draw();
                            if(ga){
								ga('send','event','WGCNA_mir','resetCorrelation');
							}
                        })
                        .append("img").attr("src",contextRoot+"/web/images/icons/reset_16.png");
                var table=links.append("table");
                var row=table.append("tr");
                row.append("td").append("text").text("Min:");
                row.append("td").append("div").attr("id","linkSliderMin").style("width","100px");
                row.append("td").append("span").attr("id","minLabel").style("margin-left","5px").append("text").text("0.75");
                row=table.append("tr");
                row.append("td").append("text").text("Max:");
                row.append("td").append("div").attr("id","linkSliderMax").style("width","100px");
                row.append("td").append("span").attr("id","maxLabel").style("margin-left","5px").append("text").text("1");

                links.append("input").attr("type","checkbox").attr("id","hideLinkExceptNode").on("click",function(){
                    that.singleImage.showLinks=!($(this).is(":checked"));
                    that.singleImage.draw();
                    that.singleImage.panZoom = svgPanZoom('#singleWGCNASVG',{
                                            panEnabled: true
                                          , controlIconsEnabled:false
                                          , zoomEnabled: true
                                          , dblClickZoomEnabled: true
                                          , zoomScaleSensitivity: 0.2
                                          , minZoom: 0.1
                                          , maxZoom: 4
                                          , fit: true
                                          , center: true
                                          
                                    });
                });
                links.append("text").text("Hide Links Except Selected Node");
                
                var links2=that.dataBar.append("td").append("div").attr("id","linkCtl2").attr("class","linkCTL").style("display","none").style("margin-left","10px");
                links2.append("text").text("Correlation Link Color Options:");
                links2.append("br");
                var sel1=links2.append("select").attr("id","linkColor").on("change",function(){
                    that.singleImage.draw();
                    that.singleImage.panZoom = svgPanZoom('#singleWGCNASVG',{
                                            panEnabled: true
                                          , controlIconsEnabled:false
                                          , zoomEnabled: true
                                          , dblClickZoomEnabled: true
                                          , zoomScaleSensitivity: 0.2
                                          , minZoom: 0.1
                                          , maxZoom: 4
                                          , fit: true
                                          , center: true
                                          
                                    });
                });
                sel1.append("option").attr("selected","selected").attr("value","Green_Red").text("Green(+) / Red(-)");
                sel1.append("option").attr("value","Blue_Yellow").text("Blue(+) / Yellow(-)");
                sel1.append("option").attr("value","Red_Green").text("Red(+) / Green(-)");
                
                $( "#linkSliderMin" ).slider({
                    
                    min: 0.05,
                    max: 0.95,
                    step: 0.05,
                    value:0.75,
                    slide: function( event, ui ) {
                        that.singleImage.CorCutoff_min=ui.value;
                        $("span#minLabel").html(ui.value);
                        //that.singleImage.CorCutoff_max=ui.values[ 1 ];
                        that.singleImage.draw();
                    }
                  });
                $( "#linkSliderMax" ).slider({
                    min: 0.1,
                    max: 1,
                    step: 0.05,
                    value:1,
                    slide: function( event, ui ) {
                        that.singleImage.CorCutoff_max=ui.value;
                        $("span#maxLabel").html(ui.value);
                        that.singleImage.draw();
                    }
                  });


                var chr=that.dataBar.append("td").append("div").attr("class","eqtlCtls").attr("id","eqtlCtl").style("display","none").style("margin-left","10px");
                chr.append("text").text("Select Chromosomes");
                chr.append("br");
                sel=chr.append("select").attr("id","eqtlChr").attr("multiple","multiple").attr("size","4").style("width","100px");
                for(var i=1;i<=that.chrLen;i++){
                    sel.append("option").attr("selected","selected").attr("value",organism.toLowerCase()+i).text("chr"+i);
				}
                sel.append("option").attr("selected","selected").attr("value",organism.toLowerCase()+"X").text("chrX");
                /*chr.append("text").text("Hold ctl (or command for Macs)");
                chr.append("br");
                chr.append("text").text("while clicking to select multiple.");*/
                
                
                chr=that.dataBar.append("td").append("div").attr("class","eqtlCtls").attr("id","eqtlCtl2").style("display","none").style("margin-left","10px");
                chr.append("text").text("P-value cutoff:");
                sel=chr.append("select").attr("id","eqtlPval");
                sel.append("option").attr("value","1").text("0.1");
                sel.append("option").attr("selected","selected").attr("value","2").text("0.01");
                sel.append("option").attr("value","3").text("0.001");
                sel.append("option").attr("value","4").text("0.0001");
                sel.append("option").attr("value","5").text("0.00001");
                chr.append("br");
                chr.append("br");
                chr.append("br");
                chr.append("br");
                chr.append("input").attr("type","button").attr("value","Apply Selections").on("click",function(){
                var cutoff=$("#eqtlPval").val();
                var list=$("#eqtlChr").val();
                var cList="";
                for(var n=0;n<list.length;n++){
                    cList=cList+list[n]+";";
                }
                $.ajax({
					url:  pathPrefix +"runCircosModule.jsp",
		   			type: 'GET',
		   			async: true,
					data: { cutoffValue:cutoff, organism:organism, module:that.selectedModule.MOD_NAME, modColor:that.selectedModule.ModRGB, chrList:cList,genomeVer:genomeVer,tissue:that.tissue},
					dataType: 'json',
                    beforeSend: function(){
                        //d3.select("#viewGene").remove();
                        //d3.select("#circos").remove();
                        $("#waitCircos").show();
                    },
                    success: function(data2){
                        $("#waitCircos").hide();
                        that.singleImage.update(data2.URL)
                    },
                    error: function(xhr, status, error) {

                    }
                });
            });
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

	//public method to create any type of WGCNA Image
	that.createMultiWGCNAImage=function(){
			that.multiImage=that.multiWGCNAImageGeneView(that.modules);
			that.multiImage.draw();
			that.img=that.multiImage;
	};

	//common prototype to create generic view
	that.multiWGCNAImage=function(){
		var thatimg={};
		thatimg.maxWidth=200;
		thatimg.totalWidth=$(window).width();
		thatimg.modPerLine=Math.floor($(window).width()/thatimg.maxWidth);
		thatimg.calcWidth=Math.floor($(window).width()/thatimg.modPerLine);
		thatimg.data=[];

		//setup image
		if(d3.select("#multiWGCNASVG").size()===0){
			var div=d3.select("#wgcnaGeneImage").append("div").attr("id","multiWGCNAScroll").style("overflow","auto").style("max-height","430px");
			thatimg.svg=div.append("svg").attr("id","multiWGCNASVG").attr("height","430px").attr("width","100%");
			var grad=thatimg.svg.append("linearGradient")
				.attr("id","lgrad")
				.attr("x1","11%")
				.attr("y1","0%")
				.attr("x2","89%")
				.attr("y2","100%");
			grad.append("stop")
				.attr("offset","0%")
				.attr("style","stop-color:rgb(153,218,255);stop-opacity:1");
			grad.append("stop").attr("offset","100%")
				.attr("style","stop-color:rgb(0,128,128);stop-opacity:1");
			var grad=thatimg.svg.append("linearGradient")
				.attr("id","selectGrad")
				.attr("x1","11%")
				.attr("y1","0%")
				.attr("x2","89%")
				.attr("y2","100%");
			
			grad.append("stop").attr("offset","0%")
				.attr("style","stop-color:rgb(0,163,55);stop-opacity:1");
			grad.append("stop").attr("offset","100%")
				.attr("style","stop-color:rgb(0,75,20);stop-opacity:1");
		}else{
			thatimg.svg=d3.select("#multiWGCNASVG");
		}

		thatimg.modKey=function(d){return d.MOD_NAME;};
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

		thatimg.zoomIn=function(){
			if(thatimg.maxWidth<$(window).width()/2){
				thatimg.maxWidth=thatimg.maxWidth*2;
				thatimg.draw();
			}
		}
		thatimg.zoomOut=function(){
			var prev=thatimg.maxWidth;
			thatimg.maxWidth=Math.floor(thatimg.maxWidth/2);
			if(thatimg.maxWidth<25){
				thatimg.maxWidth=prev;
			}else{
				thatimg.draw();
			}
		}

		thatimg.sortTCLenDesc=function(a,b){return b.TCList.length < a.TCList.length ? -1 : b.TCList.length > a.TCList.length ? 1 : 0;};
		thatimg.sortGeneInstanceDesc=function(a,b){return b.GeneCount < a.GeneCount ? -1 : b.GeneCount > a.GeneCount ? 1 : thatimg.sortTCLenDesc(a,b);};

		thatimg.draw=function(){

		};

		thatimg.redraw=function(){

		};

		return thatimg;
	};

	//internal methods to setup each specific type
	that.multiWGCNAImageGeneView=function(){
		var thatimg=that.multiWGCNAImage();
		thatimg.createToolTip=function(d){
			var tt="Module Name: "+d.MOD_NAME+"<BR>Transcript Size: "+d.TCList.length;
                        if(typeof d.GroupedGenes !== 'undefined'){
                            tt=tt+"<BR>Genes in Region/List: "+d.GroupedGenes;
                            tt=tt+"<BR>Transcripts in Region/List: "+d.GeneCount;
                        }else{
                            tt=tt+"<BR>Selected Gene Transcripts in Module: "+d.GeneCount;
                        }
			return tt;
		};
		thatimg.draw=function(){
            if(typeof that.selectedModule !=='undefined'){
                thatimg.maxWidth=85;
            }
            //console.log("multiWGCNAImageGeneView.draw()")
			thatimg.svg.selectAll(".modules").remove();
			thatimg.svg.selectAll(".moduleGradient").remove();
			thatimg.totalWidth=$(window).width();
			thatimg.modPerLine=Math.floor($(window).width()/thatimg.maxWidth);
			thatimg.calcWidth=Math.floor($(window).width()/thatimg.modPerLine);
			var data=[];
			thatimg.dataList={};
			var dataCount=0;
			for(var j=0;j<that.moduleList.length;j++){
				if(that.moduleList[j]!=="grey" || (that.moduleList[j]==="grey" && that.skipGrey===0 )){
                    if(typeof that.modules[that.moduleList[j]] !=='undefined'){
                        data[dataCount]=that.modules[that.moduleList[j]];
                        var rgb=data[dataCount].ModRGB.split(",");
                        var darkRGB="";
                        for(var k=0;k<rgb.length;k++){
                            rgb[k]=rgb[k]-70;
                            if(rgb[k]<0){
                                rgb[k]=0;
                            }
                        }
                        darkRGB=rgb[0]+","+rgb[1]+","+rgb[2];
                        var grad=thatimg.svg.append("linearGradient")
                        	.attr("id","grad"+data[dataCount].MOD_NAME)
                            .attr("class","moduleGradient")
                            .attr("x1","11%")
                            .attr("y1","0%")
                            .attr("x2","89%")
                            .attr("y2","100%");
                        grad.append("stop").attr("offset","0%")
                            .attr("style","stop-color:rgb("+data[dataCount].ModRGB+");stop-opacity:1");
                        
                        grad.append("stop").attr("offset","100%")
                            .attr("style","stop-color:rgb("+darkRGB+");stop-opacity:1");
                        dataCount++;
                    }
				}
			}
			var height=thatimg.maxWidth+15;
			if(data.length>thatimg.modPerLine){
				var lines=Math.floor(data.length/thatimg.modPerLine);
				if(data.length%thatimg.modPerLine>0){
					lines++;
				}
				height=height*lines;
			}
			thatimg.svg.attr("height",height+"px");
			data.sort(thatimg.sortGeneInstanceDesc);
			thatimg.data=data;
			for(var j=0;j<data.length;j++){
					thatimg.dataList[data[j].MOD_NAME]=j;
			}
			var min=d3.min(data,function(d){return d.TCList.length;});
			var max=d3.max(data,function(d){return d.TCList.length;});

			thatimg.size=d3.scaleLinear().
		  		domain([min, max]). 
		  		range([10, thatimg.maxWidth/2]);

			var mod=thatimg.svg.selectAll(".modules")
		   			.data(data,thatimg.modKey)
					.attr("transform",function(d,i){ 
						return "translate("+thatimg.calcX(d,i)+","+thatimg.calcY(d,i)+")";
					});
			//add new
			mod.enter().append("g")
				.attr("class","modules")
				.attr("id",function(d){return d.MOD_NAME;})
				.attr("transform",function(d,i){ 
					return "translate("+thatimg.calcX(d,i)+","+thatimg.calcY(d,i)+")";
				})
				.merge(mod)
				.each(function(d){
					var thisMod=d3.select("g#"+d.MOD_NAME);     
					thisMod.append("circle")
						.attr("cx",thatimg.calcWidth/2)
						.attr("cy",thatimg.maxWidth/2)
						.attr("r",thatimg.sizing)
						.attr("stroke",function(d){var val="#FFFFFF"; if(typeof that.selectedModule !=='undefined' && that.selectedModule===d){val="#000000";}return val;})
	                    .attr("stroke-width",function(d){var val="1px"; if(typeof that.selectedModule !=='undefined' && that.selectedModule===d){val="3px";}return val;})
						.attr("fill",function(d){var val="url(#grad"+d.MOD_NAME+")"; if(typeof that.selectedModule !=='undefined' && that.selectedModule===d){val="url(#selectGrad)"} return val;})
						.on("click",function(){
							thatimg.maxWidth=85;
	                        that.selectedModule=d;
							thatimg.draw();
							d3.select("#multiWGCNAScroll").style("max-height","110px");
							thatimg.svg.select("g#"+d.MOD_NAME).style("background","#CECECE");
							thatimg.svg.select("g#"+d.MOD_NAME).select("circle").attr("fill","url(#selectGrad)").attr("stroke","#000000").attr("stroke-width","3px");
	                        thatimg.svg.select("g#"+d.MOD_NAME).select("text.txtLbl").style("font-weight","bold");
	                        that.selectedGene={};
	                        for(var l=0;l<d.TCList.length;l++){
	                            if(typeof that.selectedGene[d.TCList[l].Gene.ID] !=='undefined'){
	                                that.selectedGene[d.TCList[l].Gene.ID].tcList.push(d.TCList[l]);
	                            }else{
	                                that.selectedGene[d.TCList[l].Gene.ID]={};
	                                that.selectedGene[d.TCList[l].Gene.ID].geneSymbol=d.TCList[l].Gene.geneSymbol;
	                                that.selectedGene[d.TCList[l].Gene.ID].tcList=[];
	                                that.selectedGene[d.TCList[l].Gene.ID].tcList.push(d.TCList[l]);
	                            }
	                        }
							setTimeout(that.createSingleWGCNAImage,20);
							})
						.on("mouseover",function(){
							$("#wgcnaMouseHelp").html("<B>Click</B> to select this module and see additional details.");
							d3.select(this).style("fill","url(#selectGrad)");
					        	//that.gsvg.get('tt').transition()
	                            tt.transition()        
	                                    .duration(200)      
	                                    .style("opacity", 1);      
					        	//that.gsvg.get('tt').html(that.createToolTip(d)) 
	                            tt.html(thatimg.createToolTip(d)) 
	                                .style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
	                                .style("top", function(){return that.positionTTTop(d3.event.pageY);});
							})
						.on("mouseout",function(){
		                        var d=d3.select(this).data()[0];
		                        if( typeof that.selectedModule === 'undefined' || (d.MOD_NAME!==that.selectedModule.MOD_NAME) ){
		                            d3.select(this).style("fill","url(#grad"+d.MOD_NAME+")");
		                        }
								tt.transition()        
						                .duration(500)      
						                .style("opacity", 0);
							});
	                    if(typeof that.selectedModule !=='undefined' && that.selectedModule===d){
                            thisMod.append("text")
                                    .attr("class","txtLbl")
									.attr("y",thatimg.maxWidth+12)
									.attr("x",function(d){
										var len=d.MOD_NAME.length;
										var w=len/2;
										var offset=thatimg.calcWidth/2-(w*6.5);
										return offset;
									})
	                                .style("font-weight","bold")
									.text(replaceUnderscore(d.MOD_NAME));
                        }else if(d.MOD_NAME.length*6.5<thatimg.calcWidth){
							thisMod.append("text")
                                .attr("class","txtLbl")
								.attr("y",thatimg.maxWidth+12)
								.attr("x",function(d){
									var len=d.MOD_NAME.length;
									var w=len/2;
									var offset=thatimg.calcWidth/2-(w*6.5);
									return offset;
								})
								.text(replaceUnderscore(d.MOD_NAME));
						}
						thisMod.append("text")
							.attr("y",thatimg.maxWidth/2+5)
							.attr("x",thatimg.calcWidth/2-3)
							.attr("pointer-events","none")
                            .attr("fill",function(d){
                                    var fill="#000000";
                                    var rgb=d.ModRGB.split(",");
                                    var sum=rgb[0]+rgb[1]+rgb[2];
                                    if(sum<360){
                                        fill="#FFFFFF";
                                    }
                                    return fill;
                            })
							.text(function (d){
                                var val=d.GeneCount;
                                if(typeof d.GroupedGenes !== 'undefined'){
                                    val=d.GroupedGenes;
                                }
                                return val;
                            });
				} );
		};

		thatimg.backModule=function(){
			if(that.selectedModule){
				var ind=thatimg.dataList[that.selectedModule.MOD_NAME];
				if(ind>0){
					var newModule=thatimg.data[ind-1];
	                var prevG=thatimg.svg.select("g#"+that.selectedModule.MOD_NAME);
					prevG.select("circle").attr("fill","url(#grad"+that.selectedModule.MOD_NAME+")").attr("stroke","#FFFFFF").attr("stroke-width","1px");
	                prevG.select("text.txtLbl").style("font-weight","normal");
					that.selectedModule=newModule;
	                var newG=thatimg.svg.select("g#"+newModule.MOD_NAME);
					newG.select("circle").attr("fill","url(#selectGrad)").attr("stroke","#000000").attr("stroke-width","3px");
	                newG.select("text.txtLbl").style("font-weight","bold");
	                setTimeout(that.createSingleWGCNAImage,20);
				}
			}
		};

		thatimg.forwardModule=function(){
			if(that.selectedModule){
				var ind=thatimg.dataList[that.selectedModule.MOD_NAME];
				if(ind<(thatimg.data.length-1)){
					var newModule=thatimg.data[ind+1];
	                var prevG=thatimg.svg.select("g#"+that.selectedModule.MOD_NAME);
					prevG.select("circle").attr("fill","url(#grad"+that.selectedModule.MOD_NAME+")").attr("stroke","#FFFFFF").attr("stroke-width","1px");
	                prevG.select("text.txtLbl").style("font-weight","normal");
					that.selectedModule=newModule;
					var newG=thatimg.svg.select("g#"+newModule.MOD_NAME);
					newG.select("circle").attr("fill","url(#selectGrad)").attr("stroke","#000000").attr("stroke-width","3px");
	                newG.select("text.txtLbl").style("font-weight","bold");
					setTimeout(that.createSingleWGCNAImage,20);
				}
			}
		};

		return thatimg;
	};


	//public method to create any type of WGCNA Image
	that.createSingleWGCNAImage=function(){
            d3.select("#viewGene").remove();
            d3.select("#circos").remove();
            $("#wgcnaresetImage").show();
            $("#wgcnazoomInImage").show();
            $("#wgcnazoomOutImage").show();
            if(that.viewType==="gene"){
            	$("#linkSliderMin").slider('value',0.01);
                $("span#minLabel").html(0.01);
                $("#linkSliderMax").slider('value',1.0);
                $("span#maxLabel").html(1.0);
                $("#hideLinkExceptNode").prop("checked",false);
                setTimeout(function(){
					that.singleImage=that.singleWGCNAImageGeneView(that.modules);
					that.singleImage.draw();
					that.img=that.singleImage;
					that.singleWGCNATableGeneView();
					setTimeout(function(){
						that.singleImage.panZoom = svgPanZoom('#singleWGCNASVG',{
                                            panEnabled: true
                                          , controlIconsEnabled:false
                                          , zoomEnabled: true
                                          , dblClickZoomEnabled: true
                                          , zoomScaleSensitivity: 0.2
                                          , minZoom: 0.1
                                          , maxZoom: 4
                                          , fit: true
                                          , center: true   
                                    });
					},500);
                    
            	},50);
            }else if(that.viewType==="go"){
            	$("#wgcnaresetImage").hide();
	            $("#wgcnazoomInImage").hide();
	            $("#wgcnazoomOutImage").hide();
	            $("#goDomainSelect").val("mf");
	            $("#goSpinner").val(3);
                setTimeout(function(){
					that.singleImage=that.singleWGCNAImageGoView(that.modules);
                    that.singleImage.goDomain=$("#goDomainSelect").val();
					that.singleImage.draw();
					that.img=that.singleImage;
                },50);
            }else if(that.viewType==="eqtl"){
            	$('#eqtlChr option').prop('selected', true);
            	$("#eqtlPval").val(2);
                setTimeout(function(){
					that.singleImage=that.singleWGCNAImageEQTLView(that.modules);
					that.singleImage.displayDefault();
					that.img=that.singleImage;
                },50);
            }else if(that.viewType==="mir"){
            	$("#mirValidatedCBX").prop("checked",false);
            	$("#minMirGeneSlider").slider('value',1);
                $("span#minMirGeneLabel").html(1);
                $("#mirGeneFilterTxt").val("");
                $("#mirIDFilterTxt").val("");
                $("#mirSortCBX").prop("checked",false);
                $("#mirLinkCBX").prop("checked",true);
                $("#mirgeneLinkCBX").prop("checked",false);
                $("div#mirLinkColorSelect").hide();
                setTimeout(function(){
					that.singleImage=that.singleWGCNAImageGeneView(that.modules);
					that.singleImage.draw();
					that.img=that.singleImage;
					setTimeout(function(){
						that.singleImage.panZoom = svgPanZoom('#singleWGCNASVG',{
                                        panEnabled: true
                                      , controlIconsEnabled:false
                                      , zoomEnabled: true
                                      , dblClickZoomEnabled: true
                                      , zoomScaleSensitivity: 0.2
                                      , minZoom: 0.1
                                      , maxZoom: 4
                                      , fit: true
                                      , center: true
                                });
					},500);
                },50);
            }else if(that.viewType==="meta"){
                setTimeout(function(){
					that.singleImage=that.singleWGCNAImageMetaView(that.modules);
					//that.singleImage.draw();
					that.singleImage.requestMeta();
					that.img=that.singleImage;
					setTimeout(function(){
						that.singleImage.panZoom = svgPanZoom('#singleWGCNASVG',{
                                        panEnabled: true
                                      , controlIconsEnabled:false
                                      , zoomEnabled: true
                                      , dblClickZoomEnabled: true
                                      , zoomScaleSensitivity: 0.2
                                      , minZoom: 0.1
                                      , maxZoom: 4
                                      , fit: true
                                      , center: true
                                });
					},500);
                },50);
            }
            if(ga){
				ga('send','event','changedWGCNAView',that.viewType);
			}
	};
	
	//common prototype to create generic view
	that.singleWGCNAImage=function(){
		var thatimg={};
		thatimg.width=$(window).width();
		thatimg.height=Math.floor(window.innerHeight*0.9);
		//console.log("H:"+thatimg.height+"  W:"+thatimg.width);
		if(thatimg.height>thatimg.width){
			//console.log("using width");
			thatimg.r=Math.floor((thatimg.width/2)*0.95);
		}else{
			//console.log("using height");
			thatimg.r=Math.floor((thatimg.height/2)*0.95);
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
        thatimg.linkKey=function(d){return that.removeInvalidIDChars(d.TC1)+that.removeInvalidIDChars(d.TC2);};

                
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
                
        thatimg.colorCircle=function(d){
            var id=d.Gene.ID;
            var color="#DFC184";
            if(id.indexOf("PRN")==0||id.indexOf("PMM")==0||id.indexOf("Unannotated")==0){
            	if(that.tissue==="Whole Brain"){
                	color="#7EB5D6";
            	}else if(that.tissue==="Heart"){
            		color="#DC7252";
            	}else if(that.tissue==="Liver"){
            		color="#bbbedd";
            	}
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
                        if(ga){
                            ga('send','event','wgcna','viewLegend');
                        }
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
                        if(d.PSList && that.selSource==="array"){
	                        tt=tt+"<BR><BR>";
	                        tt=tt+d.PSList.length+" Probe Sets in Transcript<BR>";
                       	}
                        /*for(var l=0;l<d.PSList.length;l++){
                            tt=tt+d.PSList[l].ID+"("+d.PSList[l].Level+")<BR>";
                        }*/
			return tt;
		};

		return thatimg;
	};
	//internal methods to setup each specific type
	that.singleWGCNAImageGeneView=function(){
		var thatimg=that.singleWGCNAImage();
        $(".goCTL").hide();
        $(".eqtlCtls").hide();
        if(that.viewType==='gene'){
            $(".linkCTL").show();
            $(".mirCTL").hide();
            thatimg.showMirLinks=0;
        }else{
            $(".mirCTL").show();
            $(".linkCTL").hide();
            thatimg.showLinks=1;
            thatimg.geneList={};
            thatimg.geneMirList={};
            var tmpDat=that.selectedModule.TCList;
            for(var i=0;i<tmpDat.length;i++){
                thatimg.geneList[that.selectedModule.TCList[i].Gene.ID]=that.selectedModule.TCList[i].Gene.geneSymbol;
            }
            thatimg.showMirLinks=1;
            thatimg.showAllFromTarget=0;
        }
        thatimg.CorCutoff_min=0.75;
        thatimg.CorCutoff_max=1;
        thatimg.type=that.viewType;
        thatimg.truncated=0;
        thatimg.filterOneDB=1;
        thatimg.mirGeneCutoff=1;
        thatimg.mirValid=0;
        thatimg.mirTargetID="";
        thatimg.mirID="";
        thatimg.miRcolor = d3.scaleOrdinal(d3.schemeCategory20b);
        thatimg.sortMir=0;
        thatimg.maxCorWidth=5;
        
        thatimg.drawLinks=function(d){
            //console.log("draw links");
            if(that.viewType==='gene'){
                //console.log("update link color");
                thatimg.updateColor("linkColor");
            }else if(that.viewType==='mir'){
                //console.log("update mir link color");
                thatimg.updateColor("mirlinkColor");
            }
            thatimg.svg.selectAll(".link").remove();
            var links=that.selectedModule.LinkList;
            var filterLinks=[];
            var count=0;
            for(var i=0;i<links.length;i++){
                if(links[i].TC1===d.ID || links[i].TC2===d.ID){
                    if(thatimg.CorCutoff_min<=Math.abs(links[i].Cor) && Math.abs(links[i].Cor)<=thatimg.CorCutoff_max){
                        filterLinks[count]=links[i];
                        count++;
                    }
                }
            }
            links=filterLinks;
            if(links.length<10000){
                var lnk=thatimg.topG.selectAll(".link").data(links,thatimg.linkKey);
                lnk.enter().append("line")
                        .attr("class","link")
                        .attr("pointer-events","none")
                        .attr("id",function(d){return "ln_"+that.removeInvalidIDChars(d.TC1)+that.removeInvalidIDChars(d.TC2);})
                        .attr("x1",function(d){
                            var x=d3.select("#tc_"+that.removeInvalidIDChars(d.TC1)).attr("cx");
                            return x;
                        })
                        .attr("y1",function(d){
                            var y=d3.select("#tc_"+that.removeInvalidIDChars(d.TC1)).attr("cy");
                            return y;
                        })
                        .attr("x2",function(d){
                            var x=d3.select("#tc_"+that.removeInvalidIDChars(d.TC2)).attr("cx");                         
                            return x;
                        })
                        .attr("y2",function(d){
                            var y=d3.select("#tc_"+that.removeInvalidIDChars(d.TC2)).attr("cy");
                            return y;
                        })
                        .attr("stroke",thatimg.colorLink)
                        .attr("stroke-width",function(d){
                            var val=Math.abs(d.Cor)*thatimg.maxCorWidth;
                            return val;
                        }).merge(lnk);
            }
        };
        
        thatimg.drawLinksBetween=function(list){
        	var hash={};
        	for(var v=0;v<list.length;v++){
        		hash[list[v]]=1;
        	}

            //console.log(list);
            if(that.viewType==='gene'){
                //console.log("update link color");
                thatimg.updateColor("linkColor");
            }else if(that.viewType==='mir'){
                //console.log("update mir link color");
                thatimg.updateColor("mirlinkColor");
            }
            thatimg.svg.selectAll(".link").remove();
            var links=that.selectedModule.LinkList;
            var filterLinks=[];
            var count=0;
            for(var i=0;i<links.length;i++){
            	//console.log(links[i].TC1);
                if( (thatimg.showAllFromTarget===0 && typeof hash[links[i].TC1]!=='undefined' && typeof hash[links[i].TC2]!=='undefined') ||
                	(thatimg.showAllFromTarget===1 && (typeof hash[links[i].TC1]!=='undefined' || typeof hash[links[i].TC2]!=='undefined'))
                	){
                    if(thatimg.CorCutoff_min<=Math.abs(links[i].Cor) && Math.abs(links[i].Cor)<=thatimg.CorCutoff_max){
                        filterLinks[count]=links[i];
                        count++;
                    }
                }
            }
            links=filterLinks;
            if(links.length<10000){
                var lnk=thatimg.svg.select("g.svg-pan-zoom_viewport").selectAll(".link").data(links,thatimg.linkKey);
                lnk.enter().append("line")
                        .attr("class","link")
                        .attr("pointer-events","none")
                        .attr("id",function(d){return "ln_"+that.removeInvalidIDChars(d.TC1)+that.removeInvalidIDChars(d.TC2);})
                        .attr("x1",function(d){
                            var x=d3.select("#tc_"+that.removeInvalidIDChars(d.TC1)).attr("cx");
                            //console.log(d.TC1+":x1:"+x);
                            return x;
                        })
                        .attr("y1",function(d){
                            var y=d3.select("#tc_"+that.removeInvalidIDChars(d.TC1)).attr("cy");
                            //console.log(d.TC1+":y1:"+y);
                            return y;
                        })
                        .attr("x2",function(d){
                        	//console.log(d.TC2+":x2:"+x);
                        	//console.log(d3.select("#tc_"+that.removeInvalidIDChars(d.TC2)));
                            var x=d3.select("#tc_"+that.removeInvalidIDChars(d.TC2)).attr("cx");
                            //console.log(d.TC2+":x2:"+x);
                            return x;
                        })
                        .attr("y2",function(d){
                            var y=d3.select("#tc_"+that.removeInvalidIDChars(d.TC2)).attr("cy");
                            //console.log(d.TC2+":y2:"+y);
                            return y;
                        })
                        .attr("stroke",thatimg.colorLink)
                        .attr("stroke-width",function(d){
                            var val=Math.abs(d.Cor)*thatimg.maxCorWidth;
                            /*if(Math.abs(d.Cor)<thatimg.CorCutoff){
                                val=0;
                            }*/
                            return val;
                        }).merge(lnk);
            }
        };

        thatimg.nodeX=function(d,i){
            var ring=50;
            var l=Math.floor(i/thatimg.maxPerLevel)+1;
            if(l>1){
                ring=l*60;
            }
            var ii=i%thatimg.maxPerLevel;
            return thatimg.width/2+(thatimg.r-ring)*(Math.cos(ii*thatimg.angle-1.57079633));
            //return thatimg.width/2+(thatimg.r-ring)*(Math.cos(i*thatimg.angle-1.57079633));
        };

        thatimg.nodeY=function(d,i){
            var ring=50;
            if(i>thatimg.maxPerLevel){
                var l=Math.floor(i/thatimg.maxPerLevel)+1;
                ring=l*60;
            }

            var ii=i%thatimg.maxPerLevel;
            return thatimg.height/2+(thatimg.r-ring)*(Math.sin(ii*thatimg.angle-1.57079633));
            //return thatimg.height/2+(thatimg.r-ring)*(Math.sin(i*thatimg.angle-1.57079633));
        };
        
        thatimg.nodeXLbl=function(d,i){
            var ring=50;
            var l=Math.floor(i/thatimg.maxPerLevel)+1;
            if(l>1){
                ring=l*60;
            }
            var ii=i%thatimg.maxPerLevel;
            var angleRad=ii*thatimg.angle-1.57079633;
            var plusMinus=1;
            if(Math.PI/2<angleRad &&angleRad<Math.PI*1.5){
                var len=0;
                if(typeof d.Gene.geneSymbol !=='undefined'){
                    len=d.Gene.geneSymbol.length;
                }
                plusMinus=plusMinus+len*7.5;
                //console.log("i="+i);
            }
            return thatimg.width/2+(thatimg.r+plusMinus)*(Math.cos(angleRad));
            //return thatimg.width/2+(thatimg.r-ring)*(Math.cos(i*thatimg.angle-1.57079633));
        };

        thatimg.nodeYLbl=function(d,i){
            var ring=50;
            
            if(i>thatimg.maxPerLevel){
                var l=Math.floor(i/thatimg.maxPerLevel)+1;
                ring=l*60;
            }

            var ii=i%thatimg.maxPerLevel;
            var angleRad=ii*thatimg.angle-1.57079633;
            var plusMinus=1;
            if(Math.PI/2<angleRad &&angleRad<Math.PI*1.5){
                var len=0;
                if(typeof d.Gene.geneSymbol !=='undefined'){
                    len=d.Gene.geneSymbol.length;
                }
                plusMinus=plusMinus+len*7.5;
            }
            return thatimg.height/2+(thatimg.r+plusMinus)*(Math.sin(angleRad));
            //return thatimg.height/2+(thatimg.r-ring)*(Math.sin(i*thatimg.angle-1.57079633));
        };
        
        thatimg.drawCorLegend=function(start){
            thatimg.legendDispG.append("text").style("font-size","16").attr("x","35").attr("y",start).text("Positive Correlation");
            thatimg.legendDispG.append("rect").attr("x","0").attr("y",start-10).attr("width", "30").attr("height", "10").style("fill",thatimg.posColor);
            thatimg.legendDispG.append("text").style("font-size","16").attr("x","35").attr("y",start+20).text("Negative Correlation");
            thatimg.legendDispG.append("rect").attr("x","0").attr("y",start+10).attr("width", "30").attr("height","10").style("fill",thatimg.negColor);
            thatimg.legendDispG.append("text").style("font-size","16").attr("x","35").attr("y",start+40).text("Lower Correlation");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+30).attr("x2", "30").attr("y2",start+30).style("stroke","#000000").style("stroke-width","0");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+35).attr("x2", "30").attr("y2",start+35).style("stroke","#000000").style("stroke-width","0.5");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+40).attr("x2", "30").attr("y2",start+40).style("stroke","#000000").style("stroke-width","1");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+45).attr("x2", "30").attr("y2",start+45).style("stroke","#000000").style("stroke-width","2");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+55).attr("x2", "30").attr("y2",start+55).style("stroke","#000000").style("stroke-width","3");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+65).attr("x2", "30").attr("y2",start+65).style("stroke","#000000").style("stroke-width","5");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+75).attr("x2", "30").attr("y2",start+75).style("stroke","#000000").style("stroke-width","7");
            thatimg.legendDispG.append("text").style("font-size","16").attr("x","35").attr("y",start+80).text("Higher Correlation");
        };
        thatimg.drawMirSupportLegend=function(start){
            thatimg.legendDispG.append("text").style("font-size","16").attr("x","35").attr("y",start).text("Validated miRNA Target");
            thatimg.legendDispG.append("rect").attr("x","0").attr("y",start-10).attr("width", "30").attr("height", "10").style("fill",thatimg.mirVal);
            thatimg.legendDispG.append("text").style("font-size","16").attr("x","35").attr("y",start+20).text("Predicted miRNA Target");
            thatimg.legendDispG.append("rect").attr("x","0").attr("y",start+10).attr("width", "30").attr("height", "10").style("fill",thatimg.mirPred);
            thatimg.legendDispG.append("text").style("font-size","16").attr("x","35").attr("y",start+40).text("Lower support of targeting");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+30).attr("x2", "30").attr("y2",start+30).style("stroke","#000000").style("stroke-width","0");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+35).attr("x2", "30").attr("y2",start+35).style("stroke","#000000").style("stroke-width","0.5");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+40).attr("x2", "30").attr("y2",start+40).style("stroke","#000000").style("stroke-width","1");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+45).attr("x2", "30").attr("y2",start+45).style("stroke","#000000").style("stroke-width","2");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+55).attr("x2", "30").attr("y2",start+55).style("stroke","#000000").style("stroke-width","3");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+65).attr("x2", "30").attr("y2",start+65).style("stroke","#000000").style("stroke-width","5");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+75).attr("x2", "30").attr("y2",start+75).style("stroke","#000000").style("stroke-width","7");
            thatimg.legendDispG.append("text").style("font-size","16").attr("x","35").attr("y",start+80).text("Higher support of targeting");
        };
        
        thatimg.drawLegend=function(){
            if(that.viewType==='gene'){
                thatimg.drawCorLegend(20);
            }else{
                thatimg.drawMirSupportLegend(20);
                if(!thatimg.showLinks){
                    thatimg.drawCorLegend(130);
                }
            }
        };

		thatimg.draw=function(){
            if(that.viewType==='mir'){
                thatimg.requestMiR();
                thatimg.updateColor("mirlinkColor");
            }else if(that.viewType==='gene'){
                thatimg.updateColor("linkColor");
            }
            thatimg.width=$(window).width();
            thatimg.height=Math.floor(window.innerHeight*0.9);
            //console.log("H:"+thatimg.height+"  W:"+thatimg.width);
            if(thatimg.height>thatimg.width){
                    //console.log("using width");
                    thatimg.r=Math.floor((thatimg.width/2)*0.95);
            }else{
                    //console.log("using height");
                    thatimg.r=Math.floor((thatimg.height/2)*0.95);
            }
            thatimg.svg.attr("height",thatimg.height+"px");
            thatimg.svg.selectAll("circle").remove();
            thatimg.svg.selectAll("text").remove();
            thatimg.svg.selectAll("line").remove();
            thatimg.svg.selectAll(".geneTC").remove();
            if(typeof thatimg.panZoom !=='undefined'){
                thatimg.panZoom.destroy();
                delete thatimg.panZoom;
            }
            thatimg.svg.selectAll(".svg-pan-zoom_viewport").remove();
            /*thatimg.svg.append("circle")
                            .attr("cx",thatimg.width/2)
                            .attr("cy",thatimg.height/2)
                            .attr("r",thatimg.r)
                            .attr("stroke","#000000")
                            .attr("fill","#FFFFFF");*/
            
            setTimeout(function(){
	            thatimg.svg.append("text")
	                    .style("font-size","20")
	                                    .attr("y",22)
	                                    .attr("x",5)/*function(){
	                                            var len=that.selectedModule.MOD_NAME.length;
	                                            var w=len/2;
	                                            var offset=thatimg.width/2-(w*6.5);
	                                            return offset;
	                                    })*/
	                                    .text(function(){
	                                    	if(that.selectedModule){
	                                    		return replaceUnderscore(that.selectedModule.MOD_NAME);
	                                    	}else{
	                                    		return "";
	                                    	}
	                                	});
	            
	            thatimg.setupLegend();
	            
	            
	            
	            thatimg.data=that.selectedModule.TCList;
	            thatimg.angle=2*Math.PI/thatimg.data.length;
	            thatimg.angleDeg=360/thatimg.data.length;
	            if(thatimg.data.length>thatimg.maxPerLevel){
	                thatimg.angle=2*Math.PI/thatimg.maxPerLevel;
	                thatimg.angleDeg=360/thatimg.maxPerLevel;
	            }
	            thatimg.data.sort(function(a,b){
	                if(a.LinkSum===b.LinkSum){
	                //if(a.LinkCount===b.LinkCount){
	                    return 0;
	                }else if(a.LinkSum>b.LinkSum){
	                //}else if(a.LinkCount>b.LinkCount){
	                    return -1;
	                }
	                return 1;
	            });
	            if(thatimg.data.length>150){
	                thatimg.truncated=1;
	                thatimg.maxNodeR=15;
	                var tmpdata=[];
	                for(var p=0;p<150;p++){
	                    tmpdata[p]=thatimg.data[p];
	                }
	                thatimg.data=tmpdata;
	                thatimg.dataIndex={};
	                for(var p=0;p<thatimg.data.length;p++){
	                    thatimg.dataIndex[thatimg.data[p].ID]=1;
	                }
	                thatimg.CorCutoff_min=0.85;
	                $("#linkSliderMin").slider('value',0.85);
	                $("span#minLabel").html(0.85);

	                thatimg.svg.append("image").attr("x",that.selectedModule.MOD_NAME.length*7.8+20).attr("y",1).attr("width","24px")								
	                    .attr("height","24px")
	                    .attr("xlink:href","data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAACXBIWXMAAAsTAAALEwEAmpwYAAAJ"+
	                            "I0lEQVRIDQEYCef2AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAA/wAAH/gAACcAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/wAADwAAALkCAABoFDEx"+
	                            "0gIzM+/b29v4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGIAAAAvAgAAHDnn54QGBgY3SUlJBwAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAP8AAB0AAAChAAAADAAAAAAU9vYY4RER/ecNDdLZ2dnvAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB5AAAAFgAAAAAA"+
	                            "AAAABv7+BFHZ2UgFAgI4Ozs7DAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/AAAtAAAAmAAAAAQAAAAAAAAAAAAAAAAU9/cM7AoKAOYY"+
	                            "GNTZ2dnqAAAA/wAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAD/AAAFAAAAnQAAACf8AgIAzhgY/uIODv4V9vYBBP//AR3z8xrKHBzjDhwc2uDg4PYAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAASwAAAEUAAAAB+AMD"+
	                            "AJwyMveSODjT9QUF+AAAAAAY9PQOTN3dTxISEipAQEAEAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAA/wAADAAAAIAAAAAEAAAAAAAAAAAC/v7vAv7+tQn7+/IAAAAA"+
	                            "AAAAAT/g4DQd8/NHCgoKFAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAGcAAAAuAAAAAAAAAAAAAAAAAAEB+gP//+QF///7AAAAAAAAAAAQ+voIVtfXUggICDM5"+
	                            "OTkJAAAAAAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAP8AABYAAAB4AAAAAQAAAAAA"+
	                            "AAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAATXm5iYt6+tMExMTHAAAAAEAAAAAAAAAAAAA"+
	                            "AAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB7AAAAEwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAF/v4CVdfXSw0EBDdAQEALAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAA"+
	                            "AAD/AAAzAAAAkwAAAAYAAAAAAAAAAAAAAAAAAQEAAAAA/kDh4QAb8/MpAgAACAAAAAAAAAAAAAAA"+
	                            "ABT29g7vCAgB4RYW1NnZ2eoAAAD/AAAAAAAAAAAAAAAAAAAAAAD/AAAE/wAAtf8AAP//AAD//wAA"+
	                            "//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD/5Q0N7WNKSnFHR0cS"+
	                            "AAAAAAAAAAADAAAAAAAAAAAAAAAAgAAATAAAAHkAAAADAAAAAAAAAAAAAAAAAAAAAPgEBP+XMzP7"+
	                            "xR8f7ivq6gcH/f0CAAAAAAAAAAAAAAAAAAAAAAz6+gj9AgIM2Bsb0QoKCujn5+f+AgAAAAAAAAAA"+
	                            "/wAABwAAAIkAAAAFAAAAAAAAAAAAAAAAAAAAAAAAAAD9AQEA1hUV9MwZGccAAAD2AAAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAABAAABR97eNhb390ceHh4RAAAAAAAAAAAAAAAAAP8AAG//AAD+/wAA//8AAP//"+
	                            "AAD//wAA//8AAP//AAD//gAA/u4ICPvzBQXw/gAA/P8AAP//AAD//wAA//8AAP//AAD//wAA//8A"+
	                            "AP/CHR3SVVBQNgAAAAACAAAAAP8AAAgAAABfAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEA"+
	                            "AAER+PgEDPv7DwEAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMOnpJyHy8icAAAAABAAA"+
	                            "AAABAAD42BMTgdUTE2buCwsz/QICCQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD///8BAAD/AAEB"+
	                            "Af8AAAEAAAAAAAAAAAAAAAAAAAAAAAAAAPEHB/vhEBANAAAAAAQAAAAAAAAAAHU6OrsDAwPnAgIC"+
	                            "IQEBAQUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAAABAQH//f39zgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAs0IPw6I24JoAAAAASUVORK5CYII=")
	                    .attr("pointer-events", "all")
	                    .style("cursor","pointer")
	                    .on("mouseover",function(){
	                            $("#wgcnaMouseHelp").html("Warning: Transcripts displayed are truncated to the top 150 most connected transcripts due to the size of the module.");
	                    })
	                    .on("mouseout",function(){
	                            $("#wgcnaMouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
	                    });
	            }else{
	                thatimg.maxNodeR=28;
	            }
	            
	            thatimg.topG=thatimg.svg.append("g").attr("class","svg-pan-zoom_viewport");
	            if(that.viewType==='gene'){
	                var tc=thatimg.topG.selectAll(".geneTC")
	                                .data(thatimg.data,thatimg.geneKey);
	                //tc.sort();
	                //add new
	                tc.enter().append("circle")
	                                .attr("class","geneTC")
	                                .attr("id",function(d){return "tc_"+that.removeInvalidIDChars(d.ID);})
	                                .attr("cx", thatimg.nodeX)
	                                .attr("cy",thatimg.nodeY)
	                                .attr("r",3)
	                                .attr("stroke","#000000")
	                                .attr("fill","#FF0000").merge(tc);

	                var links=that.selectedModule.LinkList;
	                var filterLinks=[];
	                var count=0;
	                for(var i=0;i<links.length;i++){
	                    if(thatimg.CorCutoff_min<=Math.abs(links[i].Cor) && Math.abs(links[i].Cor)<=thatimg.CorCutoff_max){
	                        if(thatimg.truncated===0 || (typeof thatimg.dataIndex[links[i].TC1]!=='undefined' && typeof thatimg.dataIndex[links[i].TC2]!=='undefined')){
	                            filterLinks[count]=links[i];
	                            count++;
	                        }
	                    }
	                }
	                links=filterLinks;
	                if(thatimg.showLinks && links.length<10000){
	                    var lnk=thatimg.topG.selectAll(".link").data(links,thatimg.linkKey);
	                    lnk.enter().append("line")
	                            .attr("class","link")
	                            .attr("id",function(d){return "ln_"+that.removeInvalidIDChars(d.TC1)+that.removeInvalidIDChars(d.TC2);})
	                            .attr("x1",function(d){
	                                var x=d3.select("#tc_"+that.removeInvalidIDChars(d.TC1)).attr("cx");
	                                //console.log(d.TC1+":x1:"+x);
	                                return x;
	                            })
	                            .attr("y1",function(d){
	                                var y=d3.select("#tc_"+that.removeInvalidIDChars(d.TC1)).attr("cy");
	                                //console.log(d.TC1+":y1:"+y);
	                                return y;
	                            })
	                            .attr("x2",function(d){
	                                var x=d3.select("#tc_"+that.removeInvalidIDChars(d.TC2)).attr("cx");
	                                //console.log(d.TC2+":x2:"+x);
	                                return x;
	                            })
	                            .attr("y2",function(d){
	                                var y=d3.select("#tc_"+that.removeInvalidIDChars(d.TC2)).attr("cy");
	                                //console.log(d.TC2+":y2:"+y);
	                                return y;
	                            })
	                            .attr("stroke",thatimg.colorLink)
	                            .attr("stroke-width",function(d){
	                                var val=Math.abs(d.Cor)*thatimg.maxCorWidth;
	                                /*if(Math.abs(d.Cor)<thatimg.CorCutoff){
	                                    val=0;
	                                }*/
	                                return val;
	                            });
	                }
	            }
	            
	            thatimg.topG.selectAll(".geneTC").remove();

	            var tc=thatimg.topG.selectAll(".geneTC")
	   				.data(thatimg.data,thatimg.geneKey);
	            //tc.sort();
				//add new
	            tc.enter().append("g")
	            		.append("circle")
                		.attr("cx", thatimg.nodeX)
	                    .attr("cy",thatimg.nodeY)
	                    //.attr("r",function(d,i){return 3+d.LinkCount;})
	                    .attr("r",thatimg.nodeRadiusSum)
	                    .attr("stroke","#000000")
	                    .attr("fill",thatimg.colorCircle)
	                    .attr("class",function(d){return "geneTC "+d.Gene.ID;})
	                    .attr("id",function(d){return "tc_"+that.removeInvalidIDChars(d.ID);})
	                    .on("click",function(){

	                    })
	                    .on("mouseover",thatimg.mouseoverGene)
	                    .on("mouseout",thatimg.mouseleaveGene)
	                    .merge(tc)
	                    .each(function(d,i){
			            	d3.select(this.parentNode).append("g").attr("class","label")
			                    .attr("id",function(d){return "txt_"+that.removeInvalidIDChars(d.ID);})
			                    .attr("transform", function(){
				                    var x=thatimg.nodeXLbl(d,i);
				                    var y=thatimg.nodeYLbl(d,i);
				                	return "translate("+x+","+y+")";
			            		})
			            		.append("text")
				                .attr("transform",function(){
				                    var deg=-90;
				                    var ii=i%thatimg.maxPerLevel; 
				                    deg=deg+thatimg.angleDeg*ii;
				                    if(deg>90){
				                        deg=deg-180;
				                    }
				                    return "rotate("+deg+")";
				                })
			                	.text(function(){return d.Gene.geneSymbol;});
	            		});

	            tc.exit().remove();
	        
	            if(that.viewType==='mir'){
	                thatimg.drawMiR();
	            }   
	        },250);
		};

        thatimg.requestMiR=function(){
            $.ajax({
				url:  contextRoot+"tmpData/browserCache/"+genomeVer+"/modules/ds"+that.wDSID+"/" +replaceUnderscore(that.selectedModule.MOD_NAME)+".miR.json",
	   			type: 'GET',
	   			async: true,
				data: {},
				dataType: 'json',
                        success: function(data2){
                            setTimeout(function(){
                                thatimg.mirData=data2;
                                //console.log(thatimg.mirData);
                                thatimg.geneMirList={};
                                for (var w=0;w<thatimg.mirData.MIRList.length;w++){
                                    //console.log("mir:"+w+":"+thatimg.mirData.MIRList[w].ID);
                                    var tmpMir=thatimg.mirData.MIRList[w];
                                    var gl=tmpMir.GeneList;
                                    
                                    for (var v=0;v<gl.length;v++){
                                        //console.log("check:"+gl[v].ID);
                                        if(typeof thatimg.geneMirList[gl[v].ID]==='undefined'){
                                            //console.log("undef");
                                            thatimg.geneMirList[gl[v].ID]=[];
                                            thatimg.geneMirList[gl[v].ID].push(tmpMir);
                                        }else{
                                            //console.log("exists");
                                            var found=0;
                                            for(var u=0;u<thatimg.geneMirList[gl[v].ID].length&&found===0;u++){
                                                if(tmpMir.ID===thatimg.geneMirList[gl[v].ID][u].ID){
                                                    found=1;
                                                }
                                            }
                                            //console.log("found:"+found)
                                            if(found===0){
                                                thatimg.geneMirList[gl[v].ID].push(tmpMir);
                                            }
                                        }
                                    }
                                }
                                //console.log(thatimg.geneMirList);
                                thatimg.drawMiR();
                                that.singleWGCNATableMirView();
                            },50);
                        },
                        error: function(xhr, status, error) {
                            setTimeout(function(){
                                thatimg.requestMiR();
                            },2000);
                        }
            });
        };
        
        thatimg.drawMiR=function(){
            if(typeof thatimg.topG!=='undefined' && typeof thatimg.mirData!=='undefined'){
                thatimg.svg.select("#mirG").remove();
                thatimg.miRdiameter = thatimg.r*1.5;
                thatimg.miRformat = d3.format(",d");
                
                thatimg.miRbubble = d3.pack()
                                    //.sort(thatimg.sortMirFunction)
                                    .size([thatimg.miRdiameter, thatimg.miRdiameter])
                                    .padding(1.5);
                                    //.radius(function(d){return d.value*10;});

                var tmpData=thatimg.runMirFilter(thatimg.mirData.MIRList);

                thatimg.hierarch=d3.hierarchy({children:tmpData}).sum(function(d) { return d.filterGLSize; });
                //var rnodes=hierarch(r);
                
                thatimg.mirNode=thatimg.miRbubble(thatimg.hierarch.sort());

                var mirG=thatimg.topG.append("g")
                        .attr("id","mirG")
                            .attr("transform", function() { 
                                var w=thatimg.width/2-thatimg.miRdiameter/2;
                                var h=thatimg.height/2-thatimg.miRdiameter/2;
                                return "translate(" + w + "," + h + ")"; });
                var node = mirG.selectAll(".node")
                                .data(thatimg.hierarch.leaves(),that.mirKey);

                node.enter().append("g")
                                .attr("class", "node")
                                .attr("id", function(d){return that.removeInvalidIDChars(d.ID);})
                                .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
                                .merge(node)
                                .on("mouseover",thatimg.mouseoverMir)
                                .on("mouseleave",thatimg.mouseleaveMir);
                                /*.each(function(d){
				                    var tmpD=d;
				                    if(d.depth>0){
				                        d3.select(this).append("circle")
				                            
				                            .attr("r", function(d) { return tmpD.r; })
				                            .style("fill", function(d) { return thatimg.miRcolor(tmpD.ID); });
				                        var txt=tmpD.ID.substring(8);
				                        if(txt.length<tmpD.r / 3){
				                            d3.select(this).append("text")
				                                .attr("dy", ".2em")
				                                .attr("pointer-events","none")
				                                .style("text-anchor", "middle")
				                                .style("cursor","pointer")
				                                .append("tspan")
				                                            .attr("x", 0)
				                                            //.attr("y", -10)
				                                            .attr("dy", "-0.5em")
				                                            .text("miR")
				                                .append("tspan")
				                                            .attr("x", 0)
				                                            .attr("dy", "1em")
				                                            .text(txt);
				                                //.text(txt);
				                        }
				                    }
				                });*/
                node.exit().remove();

                d3.selectAll(".node").each(function(d){
				                    var tmpD=d.data;
				                    if(d.depth>0){
				                    	//console.log(d);
				                        d3.select(this).append("circle")
				                            .attr("r", function(d) { return d.r; })
				                            .style("fill", function(d) { return thatimg.miRcolor(tmpD.ID); });
				                        var txt=tmpD.ID.substring(8);
				                        if(txt.length<d.r / 3){
				                            d3.select(this).append("text")
				                                .attr("dy", ".2em")
				                                .attr("pointer-events","none")
				                                .style("text-anchor", "middle")
				                                .style("cursor","pointer")
				                                .append("tspan")
				                                            .attr("x", 0)
				                                            //.attr("y", -10)
				                                            .attr("dy", "-0.5em")
				                                            .text("miR")
				                                .append("tspan")
				                                            .attr("x", 0)
				                                            .attr("dy", "1em")
				                                            .text(txt);
				                                //.text(txt);
				                        }
				                    }
				                })
                /*node.append("title")
                    .text(function(d) { return d.className + ": " + format(d.value); });*/
                /*node.each(function(d){
                    var tmpD=d;
                    if(d.depth>0){
                        d3.select(this).append("circle")
                            
                            .attr("r", function(d) { return tmpD.r; })
                            .style("fill", function(d) { return thatimg.miRcolor(tmpD.ID); });
                        var txt=tmpD.ID.substring(8);
                        if(txt.length<tmpD.r / 3){
                            d3.select(this).append("text")
                                .attr("dy", ".2em")
                                .attr("pointer-events","none")
                                .style("text-anchor", "middle")
                                .style("cursor","pointer")
                                .append("tspan")
                                            .attr("x", 0)
                                            //.attr("y", -10)
                                            .attr("dy", "-0.5em")
                                            .text("miR")
                                .append("tspan")
                                            .attr("x", 0)
                                            .attr("dy", "1em")
                                            .text(txt);
                                //.text(txt);
                        }
                    }
                });*/
                
            }
        };
        
        thatimg.sortMirFunction=function(a,b){
            if(thatimg.sortMir>0 ){
                return a.value - b.value;
            }else if(thatimg.sortMir<0 ){
                return b.value - a.value;
            }else{
                return 0;
            }
        };
        
        thatimg.runMirFilter=function(list){
            var newList=list;
            if( thatimg.filterOneDB===1||thatimg.mirGeneCutoff>1 || thatimg.mirValid===1 || thatimg.mirID.length>0 || thatimg.mirTargetID.length>0){
                var mc=0;
                newList=[];
                for(var z=0;z<list.length;z++){
                    if(thatimg.filterMiR(list[z])){
                        newList[mc]=list[z];
                        mc++;
                    }
                }
            }
            return newList;
        };
        
        thatimg.filterMiR=function(d){
            val=true;
            //console.log(d.ID);
            if(d.GeneList.length<thatimg.mirGeneCutoff){
                val=false;
            }
            if(val && thatimg.mirValid===1 && d.vC===0){
                val=false;
            }
            if(val && thatimg.mirID.length>0){
                if(!(d.ID.toLowerCase().indexOf(thatimg.mirID)>-1||d.ACC.toLowerCase().indexOf(thatimg.mirID)>-1)){
                    val=false;
                }
            }
            if(val && thatimg.mirTargetID.length>0){
                var found=false;
                for(var x=0;x<d.GeneList.length&&!found;x++){
                    if(thatimg.filterOneDB===1){
                        if(	(d.GeneList[x].P>1 || d.GeneList[x].V>0) && 
                            (d.GeneList[x].ID.toLowerCase().indexOf(thatimg.mirTargetID)>-1 || thatimg.geneList[d.GeneList[x].ID].toLowerCase().indexOf(thatimg.mirTargetID)>-1)
                            ){
                            found=true;
                        }
                    }else{
                        if(d.GeneList[x].ID.toLowerCase().indexOf(thatimg.mirTargetID)>-1||thatimg.geneList[d.GeneList[x].ID].toLowerCase().indexOf(thatimg.mirTargetID)>-1){
                            found=true;
                        }
                    }
                }
                if(!found){
                    val=false;
                }
            }
            if(val && thatimg.filterOneDB===1 && typeof d.filterGLSize ==='undefined'){
                var newSize=0;
                for(var x=0;x<d.GeneList.length;x++){
                    if(d.GeneList[x].P>1 || d.GeneList[x].V>0){
                        newSize++;
                    }
                }
                d.filterGLSize=newSize;
                if(d.filterGLSize===0 && d.vC===0){
                    val=false;
                }
            }else if(val && thatimg.filterOneDB===1 && d.filterGLSize===0 && d.vC===0){
                val=false;
            }
            return val;
        };
        
        thatimg.filterRevMiR=function(mirList){
            var newMirList=[];
            if(typeof mirList !=='undefined'){
                if(thatimg.filterOneDB===1){
                    for(var x=0;x<mirList.length;x++){
                        if(mirList[x].filterGLSize>0 || mirList[x].vC>0){
                            newMirList.push(mirList[x]);
                        }
                    }
                }else{
                    newMirList=mirList;
                }
        	}
            return newMirList;
        };
        
        thatimg.filterMiRGenes=function(genes){
            var newGenes=[];
            if(thatimg.filterOneDB===1){
                for(var x=0;x<genes.length;x++){
                    if(genes[x].P>1||genes[x].V>0){
                        newGenes.push(genes[x]);
                    }
                }
            }else{
                newGenes=genes;
            }
            return newGenes;
        };
        
        thatimg.createMirToolTip=function(d){
            var txt="";
            txt="<div id=\"ttSVG\"></div>ID: "+d.ID+"<BR>Accession: "+d.ACC+"<BR><BR>Genes Targeted within Module: "+d.filterGLSize+"<BR>";
            return txt;
        };
        
        thatimg.mouseoverMir=function(){
        	
        	var tmpDDoc=d3.select(this).data()[0];
            var tmpDDat=tmpDDoc.data;
            var genes=tmpDDat.GeneList;
            genes=thatimg.filterMiRGenes(genes);
            d3.select(this).style("opacity","0.3");
            tt.transition()        
                    .duration(200)      
                    .style("opacity", 1);
            tt.html(thatimg.createMirToolTip(tmpDDat))
                    .style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
                    .style("top", function(){return that.positionTTTop(d3.event.pageY);});
            
            var lnk=thatimg.svg.select("g.svg-pan-zoom_viewport")
                    .selectAll(".mirlink")
                    .data(genes,that.mirKey);
            lnk.enter().append("line")
                        .attr("class","mirlink")
                        .attr("pointer-events","none")
                        .attr("id",function(d){return "ln_"+d.ID;})
                        .attr("x1",function(d){
                            var x=tmpDDoc.x+thatimg.width/2-thatimg.miRdiameter/2;
                            return x;
                        })
                        .attr("y1",function(d){
                            var y=tmpDDoc.y+thatimg.height/2-thatimg.miRdiameter/2;
                            return y;
                        })
                        .attr("x2",function(d){
                            var x=tmpDDoc.x+thatimg.width/2-thatimg.miRdiameter/2;
                            if(d3.select("."+d.ID).size()>0){
                            	x=d3.select("."+d.ID).attr("cx");
                        	}
                            return x;
                        })
                        .attr("y2",function(d){
                            var y=tmpDDoc.y+thatimg.height/2-thatimg.miRdiameter/2;
                            if(d3.select("."+d.ID).size()>0){
                            	y=d3.select("."+d.ID).attr("cy");
                        	}
                            return y;
                        })
                        .attr("stroke",function(d){
                            var colr=thatimg.mirPred;
                            if(d.V>0){
                                colr=thatimg.mirVal;
                            }
                            return colr;
                        })
                        .attr("stroke-width",function(d){
                            var val=d.P+3*d.V;
                            return val;
                        }).merge(lnk);

            if(!thatimg.showLinks){
            	var gl=[];
            	for(var w=0;w<genes.length;w++){
            		var nodeL=d3.selectAll("."+genes[w].ID).nodes();
            		for(var x=0;x<nodeL.length;x++){
            			if(typeof nodeL[x]!=='undefined'){
            				gl.push(d3.select(nodeL[x].parentNode).datum().ID);
            			}
            		}
            	}
            	thatimg.drawLinksBetween(gl);
            }
            if(ga){
                ga('send','event','wgcna','mouseOverMir');
            }
        };
        thatimg.mouseleaveMir=function(){
            d3.select(this).style("opacity","1");
            tt.transition()        
                    .duration(200)      
                    .style("opacity", 0);
            thatimg.svg.selectAll(".mirlink").remove();
            thatimg.svg.selectAll(".link").remove();
        };
        thatimg.mouseoverGene=function(){
            $("#wgcnaMouseHelp").html("<B>Click</B> to select this gene cluster and see additional details.");
            d3.select(this).style("fill","url(#selectGrad)");//.attr("stroke","#000000");
            //that.gsvg.get('tt').transition()
            tt.transition()        
                    .duration(200)      
                    .style("opacity", 1);      
                    //that.gsvg.get('tt').html(that.createToolTip(d)) 
            tt.html(thatimg.createToolTip(d3.select(this).data()[0])) 
                    .style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
                                    .style("top", function(){return that.positionTTTop(d3.event.pageY);});
            var d=d3.select(this.parentNode).datum();
            
            if(that.viewType==='mir'){
                thatimg.mirTargetID=d.Gene.ID.toLowerCase();
                //console.log("target:"+thatimg.mirTargetID)
                that.singleImage.drawMiR();
                thatimg.svg.selectAll(".link").remove();
                if(!thatimg.showLinks){
                    thatimg.drawLinks(d);
                }
            }else{
                $("[id^=ln_"+that.removeInvalidIDChars(d.ID)+"]").each(function(){
                    var id=$(this).attr("id");
                    d3.select("line#"+id).attr("stroke",thatimg.colorLinkHighlight);
                });
                $("[id$="+that.removeInvalidIDChars(d.ID)+"]").each(function(){
                    var id=$(this).attr("id");
                    d3.select("line#"+id).attr("stroke",thatimg.colorLinkHighlight);
                });
                if(!thatimg.showLinks){
                    thatimg.drawLinks(d);
                }
            }
            d3.select("#txt_"+that.removeInvalidIDChars(d.ID)).select("text").attr("fill","#00A347");
            var tcList=that.selectedGene[d.Gene.ID].tcList;
            for(var l=0;l<tcList.length;l++){
                d3.select("#tc_"+that.removeInvalidIDChars(tcList[l].ID)).attr("fill","#FEFF49");
            }
            
            if(that.viewType==='mir'  && thatimg.showMirLinks){
                var geneID=d.Gene.ID;
                var mirL=thatimg.geneMirList[d.Gene.ID];
                mirL=thatimg.filterRevMiR(mirL);
                var lnk=thatimg.svg.select("g.svg-pan-zoom_viewport")
                    .selectAll(".mirlink")
                    .data(mirL,that.mirKey);
                lnk.enter().append("line")
                        .attr("class","mirlink")
                        .attr("pointer-events","none")
                        .attr("id",function(d){return "ln_"+d.ID;})
                        .attr("x1",function(d){
                            var x=d3.select("."+geneID).attr("cx");
                            if(d3.select("#"+that.removeInvalidIDChars(d.ID)).size()>0){
                            	x=d3.select("#"+that.removeInvalidIDChars(d.ID))[0][0].__data__.x+thatimg.width/2-thatimg.miRdiameter/2;
                        	}
                            return x;
                        })
                        .attr("y1",function(d){
                            var y=d3.select("."+geneID).attr("cy");
                            if(d3.select("#"+that.removeInvalidIDChars(d.ID)).size()>0){
                            	y=d3.select("#"+that.removeInvalidIDChars(d.ID))[0][0].__data__.y+thatimg.height/2-thatimg.miRdiameter/2;
                        	}
                            return y;
                        })
                        .attr("x2",function(d){
                            var x=d3.select("."+geneID).attr("cx");
                            //console.log(d.TC2+":x2:"+x);
                            return x;
                        })
                        .attr("y2",function(d){
                            var y=d3.select("."+geneID).attr("cy");
                            //console.log(d.TC2+":y2:"+y);
                            return y;
                        })
                        .attr("stroke",function(d){
                            var colr=thatimg.mirPred;
                            if(d.V>0){
                                colr=thatimg.mirVal;
                            }
                            return colr;
                        })
                        .attr("stroke-width",function(d){
                            var val=d.P+3*d.V;
                            return val;
                        }).merge(lnk);
            }
            if(ga){
                ga('send','event','wgcna','mouseOverGene');
            }
        };
        
        thatimg.mouseleaveGene=function(){
            var d=d3.select(this.parentNode).datum();
            $("[id^=ln_"+that.removeInvalidIDChars(d.ID)+"]").each(function(){
                var id=$(this).attr("id");
                d3.select("line#"+id).attr("stroke",thatimg.colorLink);
            });
            $("[id$="+that.removeInvalidIDChars(d.ID)+"]").each(function(){
                var id=$(this).attr("id");
                d3.select("line#"+id).attr("stroke",thatimg.colorLink);
            });
            d3.select(this).style("fill",thatimg.colorCircle);//.attr("stroke","#000000");
            d3.select("#txt_"+that.removeInvalidIDChars(d.ID)).select("text").attr("fill","#000000");
            tt.transition()        
            .duration(500)      
            .style("opacity", 0);
            if(!thatimg.showLinks){
                thatimg.svg.selectAll(".link").remove();
            }
            if(that.viewType==='mir'){
                thatimg.mirTargetID=$("#mirGeneFilterTxt").val().toLowerCase();
                thatimg.svg.selectAll(".mirLink").remove();
                that.singleImage.drawMiR();
            }
        };
                
		return thatimg;
	};

	that.singleWGCNATableGeneView=function(){
		//console.log("generate Table gene view");
        if(typeof that.selectedModule!=='undefined'){
				$('div#waitModuleTable').hide();
                $('div#wgcnaEqtlTable').hide();
                $('div#wgcnaMirTable').hide();
                $('div#wgcnaMirGeneTable').hide();
                $('div#wgcnaGoTable').hide();
                $('div#wgcnaModuleTable').show();
                $('span#modTableName').html(that.selectedModule.MOD_NAME);
                d3.select("div#tableExportCtl").selectAll("span").remove();
                d3.select("div#tableExportCtl").append("span")
                        .attr("class","button")
                        .style("margin-right","10px")
                        .on("click",function(){
                           $('#moduleTable').tableExport({type:'csv',escape:'false'});
                        })
                        .html("Export CSV");
                if($.fn.DataTable.isDataTable( 'table#moduleTable' )){
					$('table#moduleTable').DataTable().destroy();
				}
				d3.select("table#moduleTable").select("tbody").selectAll('tr').remove();
				var tracktbl=d3.select("table#moduleTable").select("tbody").selectAll('tr').data(that.selectedModule.TCList,that.geneKey)
						.enter().append("tr")
						.attr("id",function(d){return "modtrx"+d.ID;})
						.attr("class",function(d,i){var ret="odd";if(i%2===0){ret="even";} return ret;});

				tracktbl.each(function(d,i){
						var tmpI=i;
						d3.select(this).append("td").html(d.Gene.geneSymbol);
						d3.select(this).append("td").html(d.Gene.ID);
						d3.select(this).append("td").html(d.ID);
						if(d.PSList){
							d3.select(this).append("td").html(d.PSList.length);
						}else{
							d3.select(this).append("td").html("0");
						}
						
		                d3.select(this).append("td").html(d.LinkSum.toFixed(2));
		                d3.select(this).append("td").html(function(){return tmpI+1;});
				});
		        $('table#moduleTable').DataTable({
						"bPaginate": false,
						"aaSorting": [[ 4, "desc" ]],
						"sDom": 'fi<t>'
				});
				if(testFireFox){
					/*setTimeout(function(){
						$("div#moduleTable_filter").css("display","inline-block");
						$("div#moduleTable_info").css("display","inline-block").css("float","right");
						//$('.dataTables_filter').style("display","inline-block");
						//$('.dataTables_info').style("display","inline-block");
					},10000);*/
				}
        }else{
                $('div#waitModuleTable').hide();
                $('div#wgcnaEqtlTable').hide();
                $('div#wgcnaModuleTable').hide();
                $('div#wgcnaGoTable').hide();
        }
	};

    that.singleWGCNATableMirView=function(){
        var thattbl={};
        thattbl.orgPref="mmu-";

        thattbl.runMirFilter=function(list){
        	var newList=[];
        	var count=0;
        	for(var i=0;i<list.length;i++){
        		if(list[i].filterGLSize>0 || list[i].vC>0){
        			newList[count]=list[i];
        			count++;
        		}
        	}
        	return newList;
        };

        thattbl.createMirTable = function(){
                $('div#waitMirTable').hide();
                $('div#wgcnaMirGeneTable').hide();
                $('div#wgcnaMirTable').show();
                $('span#mirTableName').html(that.selectedModule.MOD_NAME);

                if($.fn.DataTable.isDataTable( 'table#mirTable' )){
                        $('table#mirTable').DataTable().destroy();
                }
                
                d3.select("table#mirTable").select("tbody").selectAll('tr').remove();

                var tmpData=thattbl.runMirFilter(that.singleImage.mirData.MIRList);
                
                var tracktbl=d3.select("table#mirTable")
                		.select("tbody").selectAll('tr')
                        .data(tmpData,that.mirKey)
                                .enter().append("tr")
                                .attr("id",function(d){return "mirTR"+that.removeInvalidIDChars(d.ID);})
                                .attr("class",function(d,i){var ret="odd";if(i%2===0){ret="even";} return ret;});
                tracktbl.each(function(d,i){
                            var tmpD=d;
                            var tmpI=i;
                            var val=0;
                            var vl=[];
                            var pred=0;
                            var pl=[];
                            var gl=d.GeneList;
                            for(var t=0;t<gl.length;t++){   
                                if(gl[t].V>0){
                                    val++;
                                    vl.push(gl[t]);
                                }else if(gl[t].P>1){
                                    pred++;
                                    pl.push(gl[t]);
                                }  
                            }
                            d3.select(this).append("td").html(d.ID);
                            d3.select(this).append("td").html(d.ACC);
                                //d3.select(this).append("td").html("");
                            d3.select(this).append("td").html(function(){
                                var html="";
                                if(pred>0){
                                    html="<span class=\"triggerpL\" name=\"pl"+tmpI+"\">"+pred+"</span><BR>";
                                    html=html+"<span id=\"pl"+tmpI+"\" style=\"display:none;\" >";
                                    for(var k=0;k<pl.length;k++){
                                        if(k>0){
                                            html=html+", ";
                                        }
                                        var g=pl[k].ID;
                                        if(typeof that.singleImage.geneList[g] !=='undefined'){
                                            g=that.singleImage.geneList[g];
                                        }
                                        html=html+g;
                                    }
                                    html=html+"</span>";
                                }else{
                                    html=pred;
                                }
                                return html;
                            });
                            d3.select(this).append("td").html(function(){
                                var html="";
                                if(val>0){
                                    html="<span class=\"triggervL\" name=\"vl"+tmpI+"\">"+val+"</span><BR>";
                                    html=html+"<span id=\"vl"+tmpI+"\" style=\"display:none;\" >";
                                    for(var k=0;k<vl.length;k++){
                                        if(k>0){
                                            html=html+", ";
                                        }
                                        var g=vl[k].ID;
                                        if(typeof that.singleImage.geneList[g] !=='undefined'){
                                            g=that.singleImage.geneList[g];
                                        }
                                        html=html+g;
                                    }
                                    html=html+"</span>";
                                }else{
                                    html=val;
                                }
                                return html;
                            });
                            d3.select(this).append("td").html(function(){
                                var len=pred+val; 
                                var html="";
                                if(len>0){
                                    html="<span class=\"triggerMiL\" name=\"mil"+tmpI+"\">"+len+"</span><BR>";
                                    html=html+"<span id=\"mil"+tmpI+"\" style=\"display:none;\" >";
                                    if(vl.length>0){
                                        html=html+"Validated: ";
                                        for(var k=0;k<vl.length;k++){
                                            if(k>0){
                                                html=html+", ";
                                            }
                                            var g=vl[k].ID;
                                            if(typeof that.singleImage.geneList[g] !=='undefined'){
                                                g=that.singleImage.geneList[g];
                                            }
                                            html=html+g;
                                        }
                                    }
                                    if(pl.length>0){
                                        if(vl.length>0){
                                            html=html+"<BR><BR>";
                                        }
                                        html=html+"Predicted: ";
                                        for(var k=0;k<pl.length;k++){
                                            if(k>0){
                                                html=html+", ";
                                            }
                                            var g=pl[k].ID;
                                            if(typeof that.singleImage.geneList[g] !=='undefined'){
                                                g=that.singleImage.geneList[g];
                                            }
                                            html=html+g;
                                        }
                                    }
                                    html=html+"</span>";
                                }else{
                                    html=len;
                                }
                                return html;
                            });
                });
                
                $("#mirTable .triggerMiL").on("click",function(event){
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

                $("#mirTable .triggerpL").on("click",function(event){
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
                $("#mirTable .triggervL").on("click",function(event){
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
            
                
                $('table#mirTable').DataTable({
                                "bPaginate": false,
                                /*"bProcessing": true,
                                "bStateSave": false,
                                "bAutoWidth": true,
                                "bDeferRender": true,*/
                                "aaSorting": [[ 4, "desc" ]],
                                "sDom": 'f<"rightTable"i><t>'
                        });
           
        };
        
        thattbl.createMirGeneTable = function(){
            $('div#waitMirGeneTable').hide();
            $('div#wgcnaMirGeneTable').show();
            $('div#wgcnaMirTable').hide();
            $('span#mirGeneTableName').html(that.selectedModule.MOD_NAME);
            d3.select("table#mirGeneTable").select("tbody").selectAll('tr').remove();
			var tracktbl=d3.select("table#mirGeneTable").select("tbody").selectAll('tr').data(that.selectedModule.TCList,that.geneKey)
					.enter().append("tr")
					.attr("id",function(d){return "mirg"+that.removeInvalidIDChars(d.ID);})
					.attr("class",function(d,i){var ret="odd";if(i%2===0){ret="even";} return ret;});
			tracktbl.each(function(d,i){
                    var tmpI=i;
                    var tmpD=d;
                    var miList=that.singleImage.geneMirList[d.Gene.ID];
                    var val=0;
                    var vl=[];
                    var pred=0;
                    var pl=[];
                    if(typeof miList !=='undefined'){
                        for(var t=0;t<miList.length;t++){
                            var gl=miList[t].GeneList;
                            var f=0;
                            for(var u=0;u<gl.length&&f===0;u++){
                                if(gl[u].ID === d.Gene.ID){
                                    if(gl[u].V>0){
                                        val++;
                                        vl.push(miList[t]);
                                    }else if(gl[u].P>1){
                                        pred++;
                                        pl.push(miList[t]);
                                    }
                                    f=1;
                                }
                            }
                        }
                    }
					d3.select(this).append("td").html(d.Gene.geneSymbol);
					d3.select(this).append("td").html(d.Gene.ID);
					d3.select(this).append("td").html(function(d,i){
                        var html="";
                        if(pred>0){
                            html="<span class=\"triggerpL\" name=\"pl"+tmpI+"\">"+pred+"</span><BR>";
                            html=html+"<span id=\"pl"+tmpI+"\" style=\"display:none;\" >";
                                for(var k=0;k<pl.length;k++){
                                    if(k>0){
                                        html=html+", ";
                                    }
                                    var g=pl[k].ID.replace(thattbl.orgPref,"");
                                    html=html+g;
                                }
                            html=html+"</span>";
                        }else{
                            html=pred;
                        }
                        return html;
	                });
                    d3.select(this).append("td").html(function(d,i){
                        var html="";
                        if(val>0){
                            html="<span class=\"triggervL\" name=\"vl"+tmpI+"\">"+val+"</span><BR>";
                            html=html+"<span id=\"vl"+tmpI+"\" style=\"display:none;\" >";
                                for(var k=0;k<vl.length;k++){
                                    if(k>0){
                                        html=html+", ";
                                    }
                                    var g=vl[k].ID.replace(thattbl.orgPref,"");
                                    html=html+g;
                                }
                            html=html+"</span>";
                        }else{
                            html=val;
                        }
                        return html;
                    });
                    d3.select(this).append("td").html(function(d,i){
                        var len=val+pred; 
                        var html="";
                        /*if(typeof miList !=='undefined'){
                            len=miList.length;
                        }*/
                        if(len>0){
                            html="<span class=\"triggerMiL\" name=\"mil"+tmpI+"\">"+len+"</span><BR>";
                            html=html+"<span id=\"mil"+tmpI+"\" style=\"display:none;\" >";
                            if(vl.length>0){
                                html=html+"Validated: ";
                                for(var k=0;k<vl.length;k++){
                                    if(k>0){
                                        html=html+", ";
                                    }
                                    var g=vl[k].ID.replace(thattbl.orgPref,"");
                                    html=html+g;
                                }
                            }
                            if(pl.length>0){
                                if(vl.length>0){
                                    html=html+"<BR><BR>";
                                }
                                html=html+"Predicted: ";
                                for(var k=0;k<pl.length;k++){
                                    if(k>0){
                                        html=html+", ";
                                    }
                                    var g=pl[k].ID.replace(thattbl.orgPref,"");
                                    html=html+g;
                                }
                            }
                            html=html+"</span>";
                        }else{
                            html=len;
                        }
                        return html;
                    });
                            
			});
                
            $("#mirGeneTable .triggerMiL").on("click",function(event){
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
            
            $("#mirGeneTable .triggerpL").on("click",function(event){
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
            $("#mirGeneTable .triggervL").on("click",function(event){
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
                
                
            if($.fn.DataTable.isDataTable( 'table#mirGeneTable' )){
				$('table#mirGeneTable').DataTable().destroy();
			}

            $('table#mirGeneTable').DataTable({
				"bPaginate": false,
				/*"bProcessing": true,
				"bStateSave": false,
				"bAutoWidth": true,
				"bDeferRender": true,*/
				"aaSorting": [[ 4, "desc" ]],
				"sDom": '<"rightTable"i><"leftTable"f><t>'
			});
    	};
        
        if(typeof that.selectedModule!=='undefined'){
            $('div#wgcnaEqtlTable').hide();
            $('div#wgcnaModuleTable').hide();
            $('div#wgcnaGoTable').hide();
            d3.select("div#tableExportCtl").selectAll("span").remove();
            var ctl=d3.select("div#tableExportCtl");
            var view=ctl.append("span").style("display","inline-block").style("text-align","left").style("margin-left","20px").style("margin-right","10px");
            view.append("text").text("View by:");
            view.append("br");
            view.append("input").attr("type","radio").attr("checked","checked").attr("name","wgcnaMirTableRB").on("click",function(){
                thattbl.createMirTable();
            });
            view.append("text").text(" miRNA");
            view.append("br");
            view.append("input").attr("type","radio").attr("name","wgcnaMirTableRB").on("click",function(){
                thattbl.createMirGeneTable();
            });
            view.append("text").text(" Gene");
            ctl.append("span")
                    .attr("class","button")
                    .style("display","inline-block")
                    .style("margin-right","10px")
                    .on("click",function(){
                       $('#moduleTable').tableExport({type:'csv',escape:'false'});
                    })
                    .html("Export CSV");
            
			thattbl.createMirTable();
        }else{
            $('div#waitModuleTable').hide();
            $('div#wgcnaEqtlTable').hide();
            $('div#wgcnaModuleTable').hide();
            $('div#wgcnaMirTable').hide();
            $('div#wgcnaMirGeneTable').hide();
            $('div#wgcnaGoTable').hide();
        }
        return thattbl;
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
            thatimg.width = $(window).width();
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
            	if(typeof that.selectedModule!=='undefined' && typeof that.selectedModule.MOD_NAME !=='undefined'){
	            	$.ajax({
						url:  contextRoot+"tmpData/browserCache/"+genomeVer+"/modules/ds"+that.wDSID+"/"+replaceUnderscore(that.selectedModule.MOD_NAME)+".GO.json",
			   			type: 'GET',
			   			async: true,
						data: {},
						dataType: 'json',
			    		success: function(root){
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
	             
            	}
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
                 

                if( typeof thatimg.data.MOD_NAME ==='undefined' || (typeof that.selectedModule.MOD_NAME !=='undefined' &&  replaceUnderscore(thatimg.data.MOD_NAME) !== replaceUnderscore(that.selectedModule.MOD_NAME)) ) {
                    thatimg.getModuleGOFile(0);
                    thatimg.selectedNode=null;
                }else{

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
        $('span#GoTableName').html(that.selectedModule.MOD_NAME);
        
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
    
	that.singleWGCNAImageEQTLView=function(){
        var thatimg=that.singleWGCNAImage();
            $(".linkCTL").hide();
            $(".mirCTL").hide();
            $(".goCTL").hide();
            $(".eqtlCtls").show();
            
            thatimg.type="eqtl";
            
            thatimg.createToolTip=function(geneID){
                var gene=that.selectedGene[geneID];
                var tt="";
                if(gene.geneSymbol){
                	tt="<BR>Gene: "+gene.geneSymbol+"("+geneID+")";
                }else{
                	tt="<BR>Gene: "+geneID;
                }
			
			return tt;
		};
            thatimg.colorGene=function(geneID){
                var color="#DFC184";
                if(geneID.indexOf("Brain")===0||geneID.indexOf("Unannotated")===0){
                        color="#7EB5D6";
                }
                return color;
            };
            
            thatimg.displayDefault=function(){
                d3.select("#viewGene").remove();
                d3.select("#circos").remove();
                if(that.selectedModule){
                	thatimg.update(contextRoot+"tmpData/browserCache/"+genomeVer+"/circos/ds"+that.wDSID+"/"+replaceUnderscore(that.selectedModule.MOD_NAME)+"/"+replaceUnderscore(that.selectedModule.MOD_NAME)+"_1/svg/circos_new.svg");
                	that.singleWGCNATableEQTLView(); 
                }  
            };
            thatimg.draw=function(){
                
            };
            thatimg.update=function(url){
                $.ajax({
                                url:  url,
	   			type: 'GET',
				data: {},
				dataType: 'html',
                                success: function(data2){
                                    d3.select("#circos").remove();
                                    d3.select("#wgcnaGeneImage").append("div").attr("id","circos");
                                    $("#circos").html(data2);
                                    $("#circosModule").css("width","100%");
                                    $("#circosModule").css("height",Math.floor(window.innerHeight*0.9)+"px");
                                    thatimg.panZoomCircos = svgPanZoom('#circosModule',{
                                            panEnabled: true
                                          , controlIconsEnabled:false
                                          , zoomEnabled: true
                                          , dblClickZoomEnabled: true
                                          , zoomScaleSensitivity: 0.2
                                          , minZoom: 0.1
                                          , maxZoom: 4
                                          , fit: true
                                          , center: true
                                          
                                    });
                                    d3.select("#circosModule").selectAll(".circosGene").style("cursor","pointer")
                                    .on("mouseover",function(){
                                        d3.select(this).style("fill","#000000").attr("font-size","50px");
                                        tt.transition()        
                                            .duration(200)      
                                            .style("opacity", 1);      
                                        //that.gsvg.get('tt').html(that.createToolTip(d)) 
                                        tt.html(thatimg.createToolTip(d3.select(this).attr("id"))) 
                                            .style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
                                            .style("top", function(){return that.positionTTTop(d3.event.pageY);});
                                        if(ga){
					                        ga('send','event','wgcna','mouseOverEQTL');
					                    }
                                    })
                                    .on("mouseout",function(){
                                        var color=thatimg.colorGene(d3.select(this).attr("id"));
                                        d3.select(this).style("fill",color).attr("font-size","26px");
                                        tt.transition()        
                                            .duration(500)      
                                            .style("opacity", 0);
                                    });
                                    that.singleWGCNATableEQTLView();
                                }
                });
            };
            return thatimg;
	};
        
    that.singleWGCNATableEQTLView=function(){
		$('div#waitEqtlTable').hide();
        $('div#wgcnaModuleTable').hide();
        $('div#wgcnaMirTable').hide();
        $('div#wgcnaMirGeneTable').hide();
        $('div#wgcnaGoTable').hide();
        $('div#wgcnaEqtlTable').show();
        $('span#eqtlTableName').html(that.selectedModule.MOD_NAME);
        
        d3.select("div#tableExportCtl").selectAll("span").remove();
        d3.select("div#tableExportCtl").append("span")
                .attr("class","button")
                .style("margin-right","10px")
                .on("click",function(){
                   $('#eqtlTable').tableExport({type:'csv',escape:'false'});
                })
                .html("Export CSV");
        $.ajax({
                url:  contextRoot+"tmpData/browserCache/"+genomeVer+"/modules/ds"+that.wDSID+"/" +replaceUnderscore(that.selectedModule.MOD_NAME)+".eQTL.json",
	   			type: 'GET',
	   			async: true,
				data: {},
				dataType: 'json',
                beforeSend: function(){
                    $('div#waitEqtlTable').show();
                },
	    		success: function(data2){    
                                setTimeout(function(){
                                    //$('table#trkSelList'+that.level).dataTable().destroy();
                                    if($.fn.DataTable.isDataTable( 'table#eqtlTable' )){
                                            $('table#eqtlTable').DataTable().destroy();
                                    }
                                    
                                    
                                    //filter data2
                                    var fData=[];
                                    var cutoff=$('#eqtlPval').val()*1;
                                    var maxSnp="";
                                    var maxVal=0;
                                    for(var p=0;p<data2.length;p++){
                                        if(data2[p].Pval>=cutoff){
                                            if(data2[p].Pval>maxVal){
                                                maxSnp=data2[p].Snp;
                                                maxVal=data2[p].Pval;
                                            }
                                            fData.push(data2[p]);
                                        }
                                    }
                                    
                                    d3.select('#eqtlTable').select('tbody').selectAll('tr').remove();
                                    
                                    //setup table data2
                                    var tracktbl=d3.select("#eqtlTable").select("tbody").selectAll('tr')
                                                    .data(fData,that.eQTLKey)
                                                    .enter().append("tr")
                                                    .attr("id",function(d){return "tblLink_"+d.Snp;})
                                                    .attr("class",function(d,i){var ret="odd";if(i%2===0){ret="even";} return ret;});
                                    tracktbl.each(function(d,i){
                                                var tmp=(d.Start/1000000);
                                                    d3.select(this).append("td").html(d.Chr);
                                                    d3.select(this).append("td").html(tmp.toFixed(1));
                                                    d3.select(this).append("td").html(d.Snp);
                                                    d3.select(this).append("td").html(d.Pval.toFixed(2));
                                    });

                                    
                                    $('#eqtlTable').DataTable({
                                                    "bPaginate": false,
                                                    /*"bProcessing": true,
                                                    "bStateSave": false,
                                                    "bAutoWidth": true,
                                                    "bDeferRender": true,*/
                                                    "aaSorting": [[ 3, "desc" ]],
                                                    "sDom":'fi<t>'
                                            });
                                    //trackDataTable.draw();
                                    $('div#waitEqtlTable').hide();
                                    
                                    d3.select("#circosModule").select("g#Link_"+maxSnp).select("path").style("stroke","#FFF450");
                                },20);
	    		},
	    		error: function(xhr, status, error) {
	    		}
		});
	};
        

	that.singleWGCNAImageMetaView=function(){
		var thatimg=that.singleWGCNAImage();
        $(".goCTL").hide();
        $(".eqtlCtls").hide();
        $(".linkCTL").show();
        
        thatimg.CorCutoff_min=0.75;
        thatimg.CorCutoff_max=1;
        thatimg.type=that.viewType;
        thatimg.truncated=0;
        thatimg.filterOneDB=1;
        thatimg.mirGeneCutoff=1;
        thatimg.mirValid=0;
        thatimg.mirTargetID="";
        thatimg.mirID="";
        thatimg.miRcolor = d3.scaleOrdinal(d3.schemeCategory20b);
        thatimg.sortMir=0;
        thatimg.maxCorWidth=5;
        thatimg.mlinkKey=function(d){return that.removeInvalidIDChars(d.MOD1)+"_"+that.removeInvalidIDChars(d.MOD2);};
        
        thatimg.colorCircle=function(d){
            var color=d.COLOR;
            return color;
        };

        thatimg.colorLink=function(d){
            //var val="#DD0000";
            var val=thatimg.negColor;
            if(d.COR>0){
                //val= "#00DD00"
                val=thatimg.posColor;
            }
            return val;
        };
        thatimg.colorLinkHighlight=function(d){
            //var val="#770000";
            var val=thatimg.negDarkColor;
            if(d.COR>0){
                //val= "#007700"
                val=thatimg.posDarkColor;
            }
            return val;
        };

        thatimg.drawLinks=function(d){
        	thatimg.updateColor("linkColor");
            thatimg.svg.selectAll(".link").remove();
            var links=thatimg.metaData.LINKS;
            var filterLinks=[];
            var count=0;
            for(var i=0;i<links.length;i++){
                if(links[i].MOD1===d.MODULE || links[i].MOD2===d.MODULE){
                    if(thatimg.CorCutoff_min<=Math.abs(links[i].COR) && Math.abs(links[i].COR)<=thatimg.CorCutoff_max){
                        filterLinks[count]=links[i];
                        count++;
                    }
                }
            }
            links=filterLinks;
            if(links.length<10000){
                var lnk=thatimg.topG.selectAll(".link").data(links,thatimg.mlinkKey);
                lnk.enter().append("line")
                        .attr("class","link")
                        .attr("pointer-events","none")
                        .attr("id",function(d){return "ln_"+that.removeInvalidIDChars(d.MOD1)+that.removeInvalidIDChars(d.MOD2);})
                        .attr("x1",function(d){
                            var x=d3.select("#mod_"+that.removeInvalidIDChars(d.MOD1)).attr("cx");
                            return x;
                        })
                        .attr("y1",function(d){
                            var y=d3.select("#mod_"+that.removeInvalidIDChars(d.MOD1)).attr("cy");
                            return y;
                        })
                        .attr("x2",function(d){
                            var x=d3.select("#mod_"+that.removeInvalidIDChars(d.MOD2)).attr("cx");
                            return x;
                        })
                        .attr("y2",function(d){
                            var y=d3.select("#mod_"+that.removeInvalidIDChars(d.MOD2)).attr("cy");
                            return y;
                        })
                        .attr("stroke",thatimg.colorLink)
                        .attr("stroke-width",function(d){
                            var val=Math.abs(d.COR)*thatimg.maxCorWidth;
                            return val;
                        }).merge(lnk);
            }
        };
        
        thatimg.drawLinksBetween=function(list){
        	thatimg.updateColor("linkColor");
        	var hash={};
        	for(var v=0;v<list.length;v++){
        		hash[list[v]]=1;
        	}
            thatimg.svg.selectAll(".link").remove();
            var links=thatimg.metaData.LINKS;
            var filterLinks=[];
            var count=0;
            for(var i=0;i<links.length;i++){
                if( (thatimg.showAllFromTarget===0 && typeof hash[links[i].MOD1]!=='undefined' && typeof hash[links[i].MOD2]!=='undefined') ||
                	(thatimg.showAllFromTarget===1 && (typeof hash[links[i].MOD1]!=='undefined' || typeof hash[links[i].MOD2]!=='undefined'))
                	){
                    if(thatimg.CorCutoff_min<=Math.abs(links[i].COR) && Math.abs(links[i].COR)<=thatimg.CorCutoff_max){
                        filterLinks[count]=links[i];
                        count++;
                    }
                }
            }
            links=filterLinks;
            if(links.length<10000){
                var lnk=thatimg.topG.selectAll(".link").data(links,thatimg.mlinkKey);
                lnk.enter().append("line")
                        .attr("class","link")
                        .attr("pointer-events","none")
                        .attr("id",function(d){return "ln_"+that.removeInvalidIDChars(d.MOD1)+that.removeInvalidIDChars(d.MOD2);})
                        .attr("x1",function(d){
                            var x=d3.select("#mod_"+that.removeInvalidIDChars(d.MOD1)).attr("cx");
                            return x;
                        })
                        .attr("y1",function(d){
                            var y=d3.select("#mod_"+that.removeInvalidIDChars(d.MOD1)).attr("cy");
                            return y;
                        })
                        .attr("x2",function(d){
                            var x=d3.select("#mod_"+that.removeInvalidIDChars(d.MOD2)).attr("cx");
                            return x;
                        })
                        .attr("y2",function(d){
                            var y=d3.select("#mod_"+that.removeInvalidIDChars(d.MOD2)).attr("cy");
                            return y;
                        })
                        .attr("stroke",thatimg.colorLink)
                        .attr("stroke-width",function(d){
                            var val=Math.abs(d.COR)*thatimg.maxCorWidth;
                            
                            return val;
                        }).merge(lnk);
            }
        };

        thatimg.nodeX=function(d,i){
            var ring=50;
            var l=Math.floor(i/thatimg.maxPerLevel)+1;
            if(l>1){
                ring=l*60;
            }
            var ii=i%thatimg.maxPerLevel;
            return thatimg.width/2+(thatimg.r-ring)*(Math.cos(ii*thatimg.angle-1.57079633));
            //return thatimg.width/2+(thatimg.r-ring)*(Math.cos(i*thatimg.angle-1.57079633));
        };

        thatimg.nodeY=function(d,i){
            var ring=50;
            if(i>thatimg.maxPerLevel){
                var l=Math.floor(i/thatimg.maxPerLevel)+1;
                ring=l*60;
            }

            var ii=i%thatimg.maxPerLevel;
            return thatimg.height/2+(thatimg.r-ring)*(Math.sin(ii*thatimg.angle-1.57079633));
            //return thatimg.height/2+(thatimg.r-ring)*(Math.sin(i*thatimg.angle-1.57079633));
        };
        
        thatimg.nodeXLbl=function(d,i){
            var ring=50;
            var l=Math.floor(i/thatimg.maxPerLevel)+1;
            if(l>1){
                ring=l*60;
            }
            var ii=i%thatimg.maxPerLevel;
            var angleRad=ii*thatimg.angle-1.57079633;
            var plusMinus=1;
            if(Math.PI/2<angleRad &&angleRad<Math.PI*1.5){
                var len=0;
                if(typeof d.MODULE !=='undefined'){
                    len=d.MODULE.length;
                }
                plusMinus=plusMinus+len*7.5;
                //console.log("i="+i);
            }
            return thatimg.width/2+(thatimg.r+plusMinus)*(Math.cos(angleRad));
            //return thatimg.width/2+(thatimg.r-ring)*(Math.cos(i*thatimg.angle-1.57079633));
        };

        thatimg.nodeYLbl=function(d,i){
            var ring=50;
            
            if(i>thatimg.maxPerLevel){
                var l=Math.floor(i/thatimg.maxPerLevel)+1;
                ring=l*60;
            }

            var ii=i%thatimg.maxPerLevel;
            var angleRad=ii*thatimg.angle-1.57079633;
            var plusMinus=1;
            if(Math.PI/2<angleRad &&angleRad<Math.PI*1.5){
                var len=0;
                if(typeof d.MODULE !=='undefined'){
                    len=d.MODULE.length;
                }
                plusMinus=plusMinus+len*7.5;
            }
            return thatimg.height/2+(thatimg.r+plusMinus)*(Math.sin(angleRad));
            //return thatimg.height/2+(thatimg.r-ring)*(Math.sin(i*thatimg.angle-1.57079633));
        };
        
        thatimg.drawCorLegend=function(start){
            thatimg.legendDispG.append("text").style("font-size","16").attr("x","35").attr("y",start).text("Positive Correlation");
            thatimg.legendDispG.append("rect").attr("x","0").attr("y",start-10).attr("width", "30").attr("height", "10").style("fill",thatimg.posColor);
            thatimg.legendDispG.append("text").style("font-size","16").attr("x","35").attr("y",start+20).text("Negative Correlation");
            thatimg.legendDispG.append("rect").attr("x","0").attr("y",start+10).attr("width", "30").attr("height","10").style("fill",thatimg.negColor);
            thatimg.legendDispG.append("text").style("font-size","16").attr("x","35").attr("y",start+40).text("Lower Correlation");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+30).attr("x2", "30").attr("y2",start+30).style("stroke","#000000").style("stroke-width","0");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+35).attr("x2", "30").attr("y2",start+35).style("stroke","#000000").style("stroke-width","0.5");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+40).attr("x2", "30").attr("y2",start+40).style("stroke","#000000").style("stroke-width","1");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+45).attr("x2", "30").attr("y2",start+45).style("stroke","#000000").style("stroke-width","2");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+55).attr("x2", "30").attr("y2",start+55).style("stroke","#000000").style("stroke-width","3");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+65).attr("x2", "30").attr("y2",start+65).style("stroke","#000000").style("stroke-width","5");
            thatimg.legendDispG.append("line").attr("x1","0").attr("y1",start+75).attr("x2", "30").attr("y2",start+75).style("stroke","#000000").style("stroke-width","7");
            thatimg.legendDispG.append("text").style("font-size","16").attr("x","35").attr("y",start+80).text("Higher Correlation");
        };
        
        
        thatimg.drawLegend=function(){
            thatimg.drawCorLegend(20);
        };

        thatimg.selectMetaMod=function(moduleName){
        	that.topselectedModule=that.selectedModule;
    		that.selectedModule=that.modules[moduleName];
    		that.topselectedGene=that.selectedGene;
    		that.selectedGene={};
            for(var l=0;l<that.selectedModule.TCList.length;l++){
                if(typeof that.selectedGene[that.selectedModule.TCList[l].Gene.ID] !=='undefined'){
                    that.selectedGene[that.selectedModule.TCList[l].Gene.ID].tcList.push(that.selectedModule.TCList[l]);
                }else{
                    that.selectedGene[that.selectedModule.TCList[l].Gene.ID]={};
                    that.selectedGene[that.selectedModule.TCList[l].Gene.ID].geneSymbol=that.selectedModule.TCList[l].Gene.geneSymbol;
                    that.selectedGene[that.selectedModule.TCList[l].Gene.ID].tcList=[];
                    that.selectedGene[that.selectedModule.TCList[l].Gene.ID].tcList.push(that.selectedModule.TCList[l]);
                }
            }
            that.viewType="gene";
            // NEED TO UPDATE VIEW INTERFACE SELECTION
            d3.select('#wgcnaGeneViewRB').property('checked', true);

			that.createSingleWGCNAImage();
        };

		thatimg.draw=function(){
			//thatimg.requestMeta();
			thatimg.updateColor("linkColor");
            thatimg.width=$(window).width();
            thatimg.height=Math.floor(window.innerHeight*0.9);        
            if(thatimg.height>thatimg.width){                   
                    thatimg.r=Math.floor((thatimg.width/2)*0.95);
            }else{
                    thatimg.r=Math.floor((thatimg.height/2)*0.95);
            }
            thatimg.svg.attr("height",thatimg.height+"px");
            thatimg.svg.selectAll("circle").remove();
            thatimg.svg.selectAll("text").remove();
            thatimg.svg.selectAll("line").remove();
            thatimg.svg.selectAll(".mod").remove();
            if(typeof thatimg.panZoom !=='undefined'){
                thatimg.panZoom.destroy();
                delete thatimg.panZoom;
            }
            thatimg.svg.selectAll(".svg-pan-zoom_viewport").remove();        
            setTimeout(function(){
	            thatimg.svg.append("text")
	                    .style("font-size","20")
	                                    .attr("y",22)
	                                    .attr("x",5)
	                                    .text(function(){
	                                    	if(that.selectedModule){
	                                    		return "Meta Module for "+replaceUnderscore(that.selectedModule.MOD_NAME);
	                                    	}else{
	                                    		return "";
	                                    	}
	                                	});
	            
	            thatimg.setupLegend();
	            
	            
	            
	            thatimg.data=thatimg.metaData.MODULES;
	            thatimg.angle=2*Math.PI/thatimg.data.length;
	            thatimg.angleDeg=360/thatimg.data.length;
	            if(thatimg.data.length>thatimg.maxPerLevel){
	                thatimg.angle=2*Math.PI/thatimg.maxPerLevel;
	                thatimg.angleDeg=360/thatimg.maxPerLevel;
	            }
	            
	            if(thatimg.data.length>150){
	                thatimg.truncated=1;
	                thatimg.maxNodeR=15;
	                var tmpdata=[];
	                for(var p=0;p<150;p++){
	                    tmpdata[p]=thatimg.data[p];
	                }
	                thatimg.data=tmpdata;
	                thatimg.dataIndex={};
	                for(var p=0;p<thatimg.data.length;p++){
	                    thatimg.dataIndex[thatimg.data[p].ID]=1;
	                }
	                thatimg.CorCutoff_min=0.75;
	                $("#linkSliderMin").slider('value',0.75);
	                $("span#minLabel").html(0.75);

	                thatimg.svg.append("image").attr("x",that.selectedModule.MOD_NAME.length*7.8+20).attr("y",1).attr("width","24px")								
	                    .attr("height","24px")
	                    .attr("xlink:href","data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAACXBIWXMAAAsTAAALEwEAmpwYAAAJ"+
	                            "I0lEQVRIDQEYCef2AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAA/wAAH/gAACcAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/wAADwAAALkCAABoFDEx"+
	                            "0gIzM+/b29v4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGIAAAAvAgAAHDnn54QGBgY3SUlJBwAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAP8AAB0AAAChAAAADAAAAAAU9vYY4RER/ecNDdLZ2dnvAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB5AAAAFgAAAAAA"+
	                            "AAAABv7+BFHZ2UgFAgI4Ozs7DAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/AAAtAAAAmAAAAAQAAAAAAAAAAAAAAAAU9/cM7AoKAOYY"+
	                            "GNTZ2dnqAAAA/wAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAD/AAAFAAAAnQAAACf8AgIAzhgY/uIODv4V9vYBBP//AR3z8xrKHBzjDhwc2uDg4PYAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAASwAAAEUAAAAB+AMD"+
	                            "AJwyMveSODjT9QUF+AAAAAAY9PQOTN3dTxISEipAQEAEAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAA/wAADAAAAIAAAAAEAAAAAAAAAAAC/v7vAv7+tQn7+/IAAAAA"+
	                            "AAAAAT/g4DQd8/NHCgoKFAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAGcAAAAuAAAAAAAAAAAAAAAAAAEB+gP//+QF///7AAAAAAAAAAAQ+voIVtfXUggICDM5"+
	                            "OTkJAAAAAAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAP8AABYAAAB4AAAAAQAAAAAA"+
	                            "AAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAATXm5iYt6+tMExMTHAAAAAEAAAAAAAAAAAAA"+
	                            "AAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB7AAAAEwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAF/v4CVdfXSw0EBDdAQEALAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAA"+
	                            "AAD/AAAzAAAAkwAAAAYAAAAAAAAAAAAAAAAAAQEAAAAA/kDh4QAb8/MpAgAACAAAAAAAAAAAAAAA"+
	                            "ABT29g7vCAgB4RYW1NnZ2eoAAAD/AAAAAAAAAAAAAAAAAAAAAAD/AAAE/wAAtf8AAP//AAD//wAA"+
	                            "//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD/5Q0N7WNKSnFHR0cS"+
	                            "AAAAAAAAAAADAAAAAAAAAAAAAAAAgAAATAAAAHkAAAADAAAAAAAAAAAAAAAAAAAAAPgEBP+XMzP7"+
	                            "xR8f7ivq6gcH/f0CAAAAAAAAAAAAAAAAAAAAAAz6+gj9AgIM2Bsb0QoKCujn5+f+AgAAAAAAAAAA"+
	                            "/wAABwAAAIkAAAAFAAAAAAAAAAAAAAAAAAAAAAAAAAD9AQEA1hUV9MwZGccAAAD2AAAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAABAAABR97eNhb390ceHh4RAAAAAAAAAAAAAAAAAP8AAG//AAD+/wAA//8AAP//"+
	                            "AAD//wAA//8AAP//AAD//gAA/u4ICPvzBQXw/gAA/P8AAP//AAD//wAA//8AAP//AAD//wAA//8A"+
	                            "AP/CHR3SVVBQNgAAAAACAAAAAP8AAAgAAABfAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEA"+
	                            "AAER+PgEDPv7DwEAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMOnpJyHy8icAAAAABAAA"+
	                            "AAABAAD42BMTgdUTE2buCwsz/QICCQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD///8BAAD/AAEB"+
	                            "Af8AAAEAAAAAAAAAAAAAAAAAAAAAAAAAAPEHB/vhEBANAAAAAAQAAAAAAAAAAHU6OrsDAwPnAgIC"+
	                            "IQEBAQUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAAABAQH//f39zgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
	                            "AAAAs0IPw6I24JoAAAAASUVORK5CYII=")
	                    .attr("pointer-events", "all")
	                    .style("cursor","pointer")
	                    .on("mouseover",function(){
	                            $("#wgcnaMouseHelp").html("Warning: Modules displayed are truncated to the top 150 most connected modules due to the size of the meta module.");
	                    })
	                    .on("mouseout",function(){
	                            $("#wgcnaMouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
	                    });
	            }else{
	                thatimg.maxNodeR=28;
	            }
	            
	            thatimg.topG=thatimg.svg.append("g").attr("class","svg-pan-zoom_viewport");
	            
                var tc=thatimg.topG.selectAll(".mod")
                                .data(thatimg.data,thatimg.modKey);
                //tc.sort();
                //add new
                tc.enter().append("circle")
                                .attr("class","mod")
                                .attr("id",function(d){return "mod_"+that.removeInvalidIDChars(d.MODULE);})
                                .attr("cx", thatimg.nodeX)
                                .attr("cy",thatimg.nodeY)
                                .attr("r",3)
                                .attr("stroke","#000000")
                                .attr("fill","#FF0000").merge(tc);


                var links=thatimg.metaData.LINKS;
                var filterLinks=[];
                var count=0;
                for(var i=0;i<links.length;i++){
                    if(thatimg.CorCutoff_min<=Math.abs(links[i].COR) && Math.abs(links[i].COR)<=thatimg.CorCutoff_max){
                        if(thatimg.truncated===0 || (typeof thatimg.dataIndex[links[i].MOD1]!=='undefined' && typeof thatimg.dataIndex[links[i].MOD2]!=='undefined')){
                            filterLinks[count]=links[i];
                            count++;
                        }
                    }
                }
                links=filterLinks;
                if(thatimg.showLinks && links.length<10000){
                    var lnk=thatimg.topG.selectAll(".link").data(links,thatimg.mlinkKey);
                    lnk.enter().append("line")
                            .attr("class","link")
                            .attr("id",function(d){return "ln_"+that.removeInvalidIDChars(d.MOD1)+that.removeInvalidIDChars(d.MOD2);})
                            .attr("x1",function(d){
                                var x=d3.select("#mod_"+that.removeInvalidIDChars(d.MOD1)).attr("cx");
                                //console.log(d.TC1+":x1:"+x);
                                return x;
                            })
                            .attr("y1",function(d){
                                var y=d3.select("#mod_"+that.removeInvalidIDChars(d.MOD1)).attr("cy");
                                //console.log(d.TC1+":y1:"+y);
                                return y;
                            })
                            .attr("x2",function(d){
                                var x=d3.select("#mod_"+that.removeInvalidIDChars(d.MOD2)).attr("cx");
                                //console.log(d.TC2+":x2:"+x);
                                return x;
                            })
                            .attr("y2",function(d){
                                var y=d3.select("#mod_"+that.removeInvalidIDChars(d.MOD2)).attr("cy");
                                //console.log(d.TC2+":y2:"+y);
                                return y;
                            })
                            .attr("stroke",thatimg.colorLink)
                            .attr("stroke-width",function(d){
                                var val=Math.abs(d.COR)*thatimg.maxCorWidth;
                                /*if(Math.abs(d.Cor)<thatimg.CorCutoff){
                                    val=0;
                                }*/
                                return val;
                            }).merge(lnk);
             	}
	            
	            
	            thatimg.topG.selectAll(".mod").remove();

	            var tc=thatimg.topG.selectAll(".mod")
	   				.data(thatimg.data,thatimg.geneKey);
	            //tc.sort();
				//add new
	            tc.enter().append("g")
	            		.append("circle")
                		.attr("cx", thatimg.nodeX)
	                    .attr("cy",thatimg.nodeY)
	                    //.attr("r",function(d,i){return 3+d.LinkCount;})
	                    .attr("r",20)
	                    .attr("stroke","#000000")
	                    .attr("fill",thatimg.colorCircle)
	                    .attr("class",function(d){return "mod "+that.removeInvalidIDChars(d.MODULE);})
	                    .attr("id",function(d){return "mod_"+that.removeInvalidIDChars(d.MODULE);})
	                    .on("click", function(d){
                                	console.log("request"+d.MODULE);
                                	if(! that.moduleGenes[d.MODULE]){
                                		that.moduleGenes[d.MODULE]="";
                                		that.requestModule(d.MODULE,thatimg.selectMetaMod);
                                	}
                                	     
                                })
	                    .on("mouseover",thatimg.mouseoverModule)
	                    .on("mouseout",thatimg.mouseleaveModule)
	                    .merge(tc)
	                    .each(function(d,i){
			            	d3.select(this.parentNode).append("g").attr("class","label")
			                    .attr("id",function(d){return "txt_"+that.removeInvalidIDChars(d.MODULE);})
			                    .attr("transform", function(){
				                    var x=thatimg.nodeXLbl(d,i);
				                    var y=thatimg.nodeYLbl(d,i);
				                	return "translate("+x+","+y+")";
			            		})
			            		.append("text")
				                .attr("transform",function(){
				                    var deg=-90;
				                    var ii=i%thatimg.maxPerLevel; 
				                    deg=deg+thatimg.angleDeg*ii;
				                    if(deg>90){
				                        deg=deg-180;
				                    }
				                    return "rotate("+deg+")";
				                })
			                	.text(function(){return d.MODULE;});
	            		});

	            tc.exit().remove();
	        
	           
	        },250);
		};

        thatimg.requestMeta=function(){
            $.ajax({
            	url:  pathPrefix +"getWGCNAMetaModules.jsp",
	   			type: 'GET',
	   			async: true,
				data: {source:that.selSource,id:replaceUnderscore(that.selectedModule.MOD_NAME),organism:organism,panel:that.panel,tissue:that.tissue,region:that.region,geneList:that.geneList,genomeVer:genomeVer},
				dataType: 'json',
                success: function(data2){
                    setTimeout(function(){
                        thatimg.metaData=data2[0];
                        //console.log(thatimg.geneMirList);
                        thatimg.draw();
                    },50);
                },
                error: function(xhr, status, error) {
                    setTimeout(function(){
                        thatimg.requestMeta();
                    },2000);
                }
            });
        };

        thatimg.mouseoverModule=function(){
            $("#wgcnaMouseHelp").html("<B>Click</B> to select this module and see additional details.");
            d3.select(this).style("fill","url(#selectGrad)");//.attr("stroke","#000000");
            //that.gsvg.get('tt').transition()
            tt.transition()        
                    .duration(200)      
                    .style("opacity", 1);      
                    //that.gsvg.get('tt').html(that.createToolTip(d)) 
            tt.html(thatimg.createToolTip(d3.select(this).datum())) 
                    .style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
                                    .style("top", function(){return that.positionTTTop(d3.event.pageY);});
            var d=d3.select(this.parentNode).datum();
            
            
            $("[id^=ln_"+that.removeInvalidIDChars(d.MODULE)+"]").each(function(){
                var id=$(this).attr("id");
                d3.select("line#"+id).attr("stroke",thatimg.colorLinkHighlight);
            });
            $("[id$="+that.removeInvalidIDChars(d.MODULE)+"]").each(function(){
                var id=$(this).attr("id");
                d3.select("line#"+id).attr("stroke",thatimg.colorLinkHighlight);
            });
            if(!thatimg.showLinks){
                thatimg.drawLinks(d);
            }
            
            d3.select("#txt_"+that.removeInvalidIDChars(d.MODULE)).select("text").attr("fill","#00A347");
            /*var tcList=that.selectedGene[d.Gene.ID].tcList;
            for(var l=0;l<tcList.length;l++){
                d3.select("#tc_"+that.removeInvalidIDChars(tcList[l].ID)).attr("fill","#FEFF49");
            }*/
            
           
            if(ga){
                ga('send','event','wgcna','mouseOverModule');
            }
        };
        
        thatimg.mouseleaveModule=function(){
            var d=d3.select(this.parentNode).datum();
            $("[id^=ln_"+that.removeInvalidIDChars(d.MODULE)+"]").each(function(){
                var id=$(this).attr("id");
                d3.select("line#"+id).attr("stroke",thatimg.colorLink);
            });
            $("[id$="+that.removeInvalidIDChars(d.MODULE)+"]").each(function(){
                var id=$(this).attr("id");
                d3.select("line#"+id).attr("stroke",thatimg.colorLink);
            });
            d3.select(this).style("fill",thatimg.colorCircle);//.attr("stroke","#000000");
            d3.select("#txt_"+that.removeInvalidIDChars(d.MODULE)).select("text").attr("fill","#000000");
            tt.transition()        
            .duration(500)      
            .style("opacity", 0);
            if(!thatimg.showLinks){
                thatimg.svg.selectAll(".link").remove();
            }
            if(that.viewType==='mir'){
                thatimg.mirTargetID=$("#mirGeneFilterTxt").val().toLowerCase();
                thatimg.svg.selectAll(".mirLink").remove();
                that.singleImage.drawMiR();
            }
        };

        thatimg.createToolTip=function(d){
			var tt="Module: "+d.MODULE;
			return tt;
		};
                
		return thatimg;
	};

	

  	that.singleWGCNATableMetaView=function(){
  		$('div#wgcnaModuleTable').hide();
        $('div#wgcnaMirTable').hide();
        $('div#wgcnaMirGeneTable').hide();
        $('div#wgcnaGoTable').hide();
        $('div#wgcnaEqtlTable').hide();
  	};
	return that;
}
