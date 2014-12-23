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
	that.img.draw();
});

function replaceDot(str){
    return str.replace(/\./g, '_');
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
        if(organism==="Mm"){
            that.panel="ILS/ISS";
            that.wDSID=1;
        }else{
            that.panel="BNLx/SHR";
            that.chrLen=20;
            that.wDSID=2;
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
	};

	that.requestModuleList=function (){
		$.ajax({
				url:  pathPrefix +"getWGCNAModules.jsp",
	   			type: 'GET',
	   			async: true,
				data: {modFileType:that.viewtype,id:that.singleID,organism:organism,panel:that.panel,tissue:that.tissue,region:that.region,geneList:that.geneList},
				dataType: 'json',
	    		success: function(data2){
	        		for(var i=0;i<data2.length;i++){
                                    if(data2[i].ModuleID!=="grey" && data2[i].ModuleID !=="turquoise"){
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
	        		//console.log(that.moduleList);
	    		},
	    		error: function(xhr, status, error) {
	        		
	    		}
		});
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
	that.requestModule=function(file){
		$.ajax({
				url:  contextRoot+"tmpData/modules/ds"+that.wDSID+"/" +file+".json",
	   			type: 'GET',
	   			async: true,
				data: {},
				dataType: 'json',
	    		success: function(data2){
                                        
                                        setTimeout(function(){
                                            
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
                                        },20);
	    		},
	    		error: function(xhr, status, error) {
	        		that.requests--;
	    		}
		});

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
			.attr("id","saveLevel"+that.levelNumber)
			.style("cursor","pointer")
			.append("img")//.attr("class","mouseOpt dragzoom")
			.attr("src","/web/images/icons/savePic_dark.png")
			.attr("pointer-events","all")
			.attr("cursor","pointer")
			.on("click",function(){
				var content="";
                                console.log(that.viewType);
                                console.log(that.singleImage.type);
                                if(that.viewType==="eqtl" && that.singleImage.type==="eqtl"){
                                    content=$("div#circos").html();
                                }else if(that.viewType==="gene" && that.singleImage.type==="gene"){
                                    //console.log("viewGene")
                                    content=$("div#viewGene").html();
                                    //console.log(content);
                                }//else if(that.singleImage===undefined){
                                    
                                //}
                                
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
							var url="http://"+urlprefix+"/tmpData/download/"+data2.imageFile;
							var region=new String(that.selectedModule.MOD_NAME);
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
								    	//console.log("xhr status:"+status);
								        //alert("AJAX: server status " + status);
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
									delete a;
								    return true;
								}
							  
		    			},
		    			error: function(xhr, status, error) {
		        			console.log(error);
		    			}
					});
				})
			.on("mouseover",function(){
				d3.select(this).attr("src","/web/images/icons/savePic_white.png");
				d3.select("span#savePic"+that.levelNumber).style("background","#DCDCDC");
				//$(this).css("background","#989898").html("<img src=\"/web/images/icons/savePic_white.png\">");
				$("#wgcnaMouseHelp").html("Click to download a PNG image of the current view.");
			})
			.on("mouseout",function(){
				d3.select(this).attr("src","/web/images/icons/savePic_dark.png");
				d3.select("span#savePic"+that.levelNumber).style("background","#989898");
				//$(this).css("background","#DCDCDC").html("<img src=\"/web/images/icons/savePic_dark.png\">");
				$("#wgcnaMouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
			});

		that.imageBar.append("span").attr("class","reset control").style("display","inline-block")
			.attr("id","resetImage"+that.levelNumber)
			.style("cursor","pointer")
			.append("img")//.attr("class","mouseOpt dragzoom")
			.attr("src","/web/images/icons/reset_dark.png")
			.attr("pointer-events","all")
			.attr("cursor","pointer")
			.on("click",function(){
                            if(that.viewType==="eqtl"){
                                that.singleImage.panZoomCircos.reset();
                            }else if(that.singleImage==undefined){
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
                            }
			})
			.on("mouseover",function(){
				d3.select(this).attr("src","/web/images/icons/reset_white.png");
				d3.select("span#reset"+that.levelNumber).style("background","#DCDCDC");
				$("#wgcnaMouseHelp").html("Click to reset image zoom to initial region.");
			})
			.on("mouseout",function(){
				d3.select(this).attr("src","/web/images/icons/reset_dark.png");
				d3.select("span#reset"+that.levelNumber).style("background","#989898");
				$("#wgcnaMouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
			});
		that.imageBar.append("span").attr("class","zoomIn control")
			.style({
				"display":"inline-block",
				"cursor":"pointer",
				"position":"relative",
				"top":"7px"
			})
			.attr("id","zoomInImage")
			.append("img")
			.attr({
				"src":"/web/images/icons/magPlus_dark_32.png",
				"pointer-events":"all",
				"cursor":"pointer"
			})
			.style({
				"position":"relative",
				"top":"-5px"
			})
			.on("click",function(){
                            if(that.viewType==="eqtl"){
                                that.singleImage.panZoomCircos.zoomIn();
                            }else if(that.singleImage==undefined){
				that.multiImage.zoomIn();
                            }
			})
			.on("mouseover",function(){
				d3.select(this).attr("src","/web/images/icons/magPlus_light_32.png");
				d3.select("span#reset"+that.levelNumber).style("background","#DCDCDC");
				$("#wgcnaMouseHelp").html("Click to zoom in.");
			})
			.on("mouseout",function(){
				d3.select(this).attr("src","/web/images/icons/magPlus_dark_32.png");
				d3.select("span#reset"+that.levelNumber).style("background","#989898");
				$("#wgcnaMouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
			});
		that.imageBar.append("span").attr("class","zoomOut control")
			.style({
				"display":"inline-block",
				"cursor":"pointer",
				"position":"relative",
				"top":"7px"
			})
			.attr("id","zoomOutImage")
			.append("img")
			.attr("src","/web/images/icons/magMinus_dark_32.png")
			.attr("pointer-events","all")
			.attr("cursor","pointer")
			.style({
				"position":"relative",
				"top":"-5px"
			})
			.on("click",function(){
                            if(that.viewType==="eqtl"){
                                that.singleImage.panZoomCircos.zoomOut();
                            }else if(that.singleImage==undefined){
				that.multiImage.zoomOut();
                            }
				
			})
			.on("mouseover",function(){
				d3.select(this).attr("src","/web/images/icons/magMinus_light_32.png");
				d3.select("span#reset"+that.levelNumber).style("background","#DCDCDC");
				$("#wgcnaMouseHelp").html("Click to zoom out.");
			})
			.on("mouseout",function(){
				d3.select(this).attr("src","/web/images/icons/magMinus_dark_32.png");
				d3.select("span#reset"+that.levelNumber).style("background","#989898");
				$("#wgcnaMouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
			});
		that.imageBar.append("span").attr("class","back control")
			.style({
				"display":"inline-block",
				"cursor":"pointer",
				"position":"relative",
				"top":"7px"
			})
			.attr("id","backModule")
			.append("img")
			.attr({
				"src":"/web/images/icons/back_dark_32.png",
				"pointer-events":"all",
				"cursor":"pointer"
			})
			.style({
				"position":"relative",
				"top":"-5px"
			})
			.on("click",function(){
				that.multiImage.backModule();
			})
			.on("mouseover",function(){
				d3.select(this).attr("src","/web/images/icons/back_light_32.png");
				d3.select("span#reset"+that.levelNumber).style("background","#DCDCDC");
				$("#wgcnaMouseHelp").html("Click to move to the previous module.");
			})
			.on("mouseout",function(){
				d3.select(this).attr("src","/web/images/icons/back_dark_32.png");
				d3.select("span#reset"+that.levelNumber).style("background","#989898");
				$("#wgcnaMouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
			});
		that.imageBar.append("span").attr("class","forward control")
			.style({
				"display":"inline-block",
				"cursor":"pointer",
				"position":"relative",
				"top":"7px"
			})
			.attr("id","forwardModule")
			.append("img")
			.attr("src","/web/images/icons/forward_dark_32.png")
			.attr("pointer-events","all")
			.attr("cursor","pointer")
			.style({
				"position":"relative",
				"top":"-5px"
			})
			.on("click",function(){
				that.multiImage.forwardModule();
			})
			.on("mouseover",function(){
				d3.select(this).attr("src","/web/images/icons/forward_light_32.png");
				d3.select("span#reset"+that.levelNumber).style("background","#DCDCDC");
				$("#wgcnaMouseHelp").html("Click to move to the next module.");
			})
			.on("mouseout",function(){
				d3.select(this).attr("src","/web/images/icons/forward_dark_32.png");
				d3.select("span#reset"+that.levelNumber).style("background","#989898");
				$("#wgcnaMouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
			});
	};

	that.createViewControls=function(){
		//that.viewBar=d3.select("div#wgcnaImageControls").append("span").attr("id","wgcnaViewControls").style("float","right").style("margin-left","10px").style("margin-right","5px");
                that.viewBar=d3.select("#viewControl").append("div").attr("id","wgcnaViewControls").style("float","right").style("margin-left","10px").style("margin-right","5px").style("text-align","left");
		that.viewBar.append("text").text("Views:");
                that.viewBar.append("br");
		that.viewBar.append("input").attr("type","radio").attr("name","wgcnaViewRB").attr("value","gene").attr("checked","checked").style("margin-left","7px").style("margin-right","3px").on("click",function(){
                    that.viewType="gene";
                    //$("#linkCtls").show();
                    //$("#eqtlCtls").hide();
                    that.createSingleWGCNAImage();
                });;
		that.viewBar.append("text").text("Module");
                that.viewBar.append("span").attr("class","wgcnaControltooltip").attr("title","View transcripts within the selected module and their connectivity based on correlation of expression.").style("margin-left","5px").append("img").attr("src","/web/images/icons/info.gif");
                that.viewBar.append("br");
		/*that.viewBar.append("input").attr("type","radio").attr("name","wgcnaViewRB").attr("value","go").style("margin-left","7px").style("margin-right","3px");
		that.viewBar.append("text").text("GO");
		that.viewBar.append("input").attr("type","radio").attr("name","wgcnaViewRB").attr("value","mir").style("margin-left","7px").style("margin-right","3px");
		that.viewBar.append("text").text("miRNA(multiMiR)");*/
		that.viewBar.append("input").attr("type","radio").attr("name","wgcnaViewRB").attr("value","eqtl").style("margin-left","7px").style("margin-right","3px").on("click",function(){
                    that.viewType="eqtl";
                    //$("#linkCtls").hide();
                    //$("#eqtlCtls").show();
                    that.createSingleWGCNAImage();
                });
		that.viewBar.append("text").text("eQTL");
                that.viewBar.append("span").attr("class","wgcnaControltooltip").attr("title","View Circos plof of eQTLs for the selected module.").style("margin-left","5px").append("img").attr("src","/web/images/icons/info.gif");
	};

	that.createDataControls=function(){
		//that.dataBar=d3.select("div#wgcnaImageControls").append("span").attr("id","wgcnaDataControls").style("float","right").style("margin-left","10px").style("margin-right","5px")
                that.dataBar=d3.select("#dataControl").append("span").attr("id","wgcnaDataControls").style("margin-left","10px").style("margin-right","5px")
                            .append("table").append("tr");
		var tissue=that.dataBar.append("td");
                tissue.append("text").text("Tissue:");
		var sel=tissue.append("select").attr("id","wgcnaTissueSelect");
		that.tissues=["Brain"];
		that.dispTissues=["Whole Brain"];
		//We only have brain will need to update later.
                /*if(organism=="Rn"){
			that.tissues=["Brain","Heart","Liver"
                        ];
			that.dispTissues=["Whole Brain","Heart","Liver"];
		}*/
		for(var i=0;i<that.tissues.length;i++){
			sel.append("option").attr("value",that.tissues[i]).text(that.dispTissues[i]);
		}
               
                var links=that.dataBar.append("td").append("div").attr("id","linkCtls").style("display","none").style("margin-left","10px");
                links.append("text").text("Link Correlation Values");
                var table=links.append("table");
                var row=table.append("tr");
                row.append("td").append("text").text("Min:");
                row.append("td").append("div").attr("id","linkSliderMin").style("width","100px");
                row.append("td").append("span").attr("id","minLabel").style("margin-left","5px").append("text").text("0.01");
                row=table.append("tr");
                row.append("td").append("text").text("Max:");
                row.append("td").append("div").attr("id","linkSliderMax").style("width","100px");
                row.append("td").append("span").attr("id","maxLabel").style("margin-left","5px").append("text").text("1");

                links.append("input").attr("type","checkbox").attr("id","hideLinkExceptNode").on("click",function(){
                    that.singleImage.showLinks=!($(this).is(":checked"));
                    that.singleImage.draw();
                });
                links.append("text").text("Hide Links Except Selected Node");
                
                $( "#linkSliderMin" ).slider({
                    
                    min: 0.001,
                    max: 0.2,
                    step: 0.001,
                    value:0.01,
                    slide: function( event, ui ) {
                        console.log(ui.value);
                        that.singleImage.CorCutoff_min=ui.value;
                        $("span#minLabel").html(ui.value);
                        //that.singleImage.CorCutoff_max=ui.values[ 1 ];
                        that.singleImage.draw();
                    }
                  });
                $( "#linkSliderMax" ).slider({
                    min: 0.01,
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
                chr.append("input").attr({"type":"button","value":"Apply Selections"}).on("click",function(){
                    var cutoff=$("eqtlPval").val();
                    var list=$("#eqtlChr").val();
                    var cList="";
                    for(var n=0;n<list.length;n++){
                        cList=cList+list[n]+";";
                    }
                    console.log(list);
                    $.ajax({
				url:  pathPrefix +"runCircosModule.jsp",
	   			type: 'GET',
	   			async: true,
				data: {cutoffValue:cutoff, organism:organism, module:that.selectedModule.MOD_NAME, modColor:that.selectedModule.ModRGB, chrList:cList},
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
		if(that.viewType==="gene"){
			that.multiImage=that.multiWGCNAImageGeneView(that.modules);
			that.multiImage.draw();
			that.img=that.multiImage;
		}else if(that.viewType==="go"){
			that.multiImage=that.multiWGCNAImageGoView(that.modules);
			that.multiImage.draw();
			that.img=that.multiImage;
		}
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
			var grad=thatimg.svg.append("linearGradient").attr({
					"id":"lgrad",
					"x1":"11%",
					"y1":"0%",
					"x2":"89%",
					"y2":"100%"
			});
			grad.append("stop").attr({
					"offset":"0%",
					"style":"stop-color:rgb(153,218,255);stop-opacity:1"
				});
			grad.append("stop").attr({
					"offset":"100%",
					"style":"stop-color:rgb(0,128,128);stop-opacity:1"
				});
			var grad=thatimg.svg.append("linearGradient").attr({
					"id":"selectGrad",
					"x1":"11%",
					"y1":"0%",
					"x2":"89%",
					"y2":"100%"
			});
			grad.append("stop").attr({
					"offset":"0%",
					"style":"stop-color:rgb(0,163,55);stop-opacity:1"
				});
			grad.append("stop").attr({
					"offset":"100%",
					"style":"stop-color:rgb(0,75,20);stop-opacity:1"
				});
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
                    //console.log("multiWGCNAImageGeneView.draw()")
			thatimg.svg.selectAll(".modules").remove();
			thatimg.totalWidth=$(window).width();
			thatimg.modPerLine=Math.floor($(window).width()/thatimg.maxWidth);
			thatimg.calcWidth=Math.floor($(window).width()/thatimg.modPerLine);
			var data=[];
			thatimg.dataList={};
			var dataCount=0;
			for(var j=0;j<that.moduleList.length;j++){
				if(that.moduleList[j]!=="grey" || (that.moduleList[j]==="grey" && that.skipGrey===0 )){
                                        //console.log(that.moduleList[j]);
                                        //console.log(that.modules[that.moduleList[j]]);
                                        if(typeof that.modules[that.moduleList[j]] !=='undefined'){
                                            data[dataCount]=that.modules[that.moduleList[j]];
                                            //console.log(data[dataCount]);
                                            var rgb=data[dataCount].ModRGB.split(",");
                                            var darkRGB="";
                                            for(var k=0;k<rgb.length;k++){
                                                rgb[k]=rgb[k]-70;
                                                if(rgb[k]<0){
                                                    rgb[k]=0;
                                                }
                                            }
                                            darkRGB=rgb[0]+","+rgb[1]+","+rgb[2];
                                            var grad=thatimg.svg.append("linearGradient").attr({
                                                    "id":"grad"+data[dataCount].MOD_NAME,
                                                    "x1":"11%",
                                                    "y1":"0%",
                                                    "x2":"89%",
                                                    "y2":"100%"
                                                });
                                            grad.append("stop").attr({
                                                                "offset":"0%",
                                                                "style":"stop-color:rgb("+data[dataCount].ModRGB+");stop-opacity:1"
                                                        });
                                            grad.append("stop").attr({
                                                                "offset":"100%",
                                                                "style":"stop-color:rgb("+darkRGB+");stop-opacity:1"
                                                        });
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

			thatimg.size=d3.scale.linear().
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
					});


			mod.each(function(d){
				var thisMod=d3.select("g#"+d.MOD_NAME);
                                
                                
				thisMod.append("circle")
					.attr("cx",thatimg.calcWidth/2)
					.attr("cy",thatimg.maxWidth/2)
					.attr("r",thatimg.sizing)
					.attr("stroke","#FFFFFF")
					.attr("fill","url(#grad"+d.MOD_NAME+")")
					.on("click",function(){
						thatimg.maxWidth=50;
						thatimg.draw();
						d3.select("#multiWGCNAScroll").style("max-height","70px");
						thatimg.svg.select("g#"+d.MOD_NAME).style("background","#CECECE");
						thatimg.svg.select("g#"+d.MOD_NAME).select("circle").attr("fill","url(#selectGrad)");
						that.selectedModule=d;
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
						that.createSingleWGCNAImage();
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
				if(d.MOD_NAME.length*6.5<thatimg.calcWidth){
					thisMod.append("text")
						.attr("y",thatimg.maxWidth+12)
						.attr("x",function(d){
							var len=d.MOD_NAME.length;
							var w=len/2;
							var offset=thatimg.calcWidth/2-(w*6.5);
							return offset;
						})
						.text(d.MOD_NAME);
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
			});
		};

		thatimg.backModule=function(){
			var ind=thatimg.dataList[that.selectedModule.MOD_NAME];
			if(ind>0){
				var newModule=thatimg.data[ind-1];
				thatimg.svg.select("g#"+that.selectedModule.MOD_NAME).style("background","#FFFFFF");
				thatimg.svg.select("g#"+that.selectedModule.MOD_NAME).select("circle").attr("fill","url(#lgrad)");
				that.selectedModule=newModule;
				thatimg.svg.select("g#"+that.selectedModule.MOD_NAME).style("background","#CECECE");
				thatimg.svg.select("g#"+that.selectedModule.MOD_NAME).select("circle").attr("fill","url(#selectGrad)");
				that.createSingleWGCNAImage();
			}
		};

		thatimg.forwardModule=function(){
			var ind=thatimg.dataList[that.selectedModule.MOD_NAME];
			if(ind<(thatimg.data.length-1)){
				var newModule=thatimg.data[ind+1];
				thatimg.svg.select("g#"+that.selectedModule.MOD_NAME).style("background","#FFFFFF");
				thatimg.svg.select("g#"+that.selectedModule.MOD_NAME).select("circle").attr("fill","url(#lgrad)");
				that.selectedModule=newModule;
				thatimg.svg.select("g#"+that.selectedModule.MOD_NAME).style("background","#CECECE");
				thatimg.svg.select("g#"+that.selectedModule.MOD_NAME).select("circle").attr("fill","url(#selectGrad)");
				that.createSingleWGCNAImage();
			}
		};

		return thatimg;
	};

	/*that.multiWGCNAImageGoView=function(){
		var thatimg=that.multiWGCNAImage();
		
		return thatimg;
	};*/
	/*that.multiWGCNAImageMultiMiRView=function(){
		thatimg=that.multiWGCNAImage();
		
		return thatimg;
	};

	that.multiWGCNAImageEQTLView=function(){
		thatimg=that.multiWGCNAImage();
		
		return thatimg;
	};*/

	//public method to create any type of WGCNA Image
	that.createSingleWGCNAImage=function(){
        d3.select("#viewGene").remove();
        d3.select("#circos").remove();
		if(that.viewType==="gene"){
            setTimeout(function(){
			that.singleImage=that.singleWGCNAImageGeneView(that.modules);
			that.singleImage.draw();
			that.img=that.singleImage;
			that.singleWGCNATableGeneView();
            },50);
		}/*else if(that.viewType==="go"){
                    setTimeout(function(){
			that.singleImage=that.singleWGCNAImageGoView(that.modules);
			that.singleImage.draw();
			that.img=that.singleImage;
                    },50);
		}*/else if(that.viewType==="eqtl"){
                    setTimeout(function(){
			that.singleImage=that.singleWGCNAImageEQTLView(that.modules);
			that.singleImage.displayDefault();
			that.img=that.singleImage;
                    },50);
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
                thatimg.CorCutoff_min=0.025;
                thatimg.CorCutoff_max=1.0;
                thatimg.showLinks=true;
		thatimg.data=[];
                
                thatimg.maxNodeR=28;
         
                
                

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
                
                thatimg.colorCircle=function(d){
                    var id=d.Gene.ID;
                    var color="#DFC184";
                    if(id.indexOf("Brain")==0||id.indexOf("Unannotated")==0){
                        color="#7EB5D6";
                    }
                    return color;
                };
                
                thatimg.colorLink=function(d){
                    var val="#DD0000";
                    if(d.Cor>0){
                        val= "#00DD00"
                    }
                    return val;
                };
                
                thatimg.colorLinkHighlight=function(d){
                    var val="#770000";
                    if(d.Cor>0){
                        val= "#007700"
                    }
                    return val;
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
	//internal methods to setup each specific type
	that.singleWGCNAImageGeneView=function(){
		var thatimg=that.singleWGCNAImage();
                $("#linkCtls").show();
                $(".eqtlCtls").hide();
                thatimg.type="gene";
                thatimg.truncated=0;

                /* thatimg.panZoomCircos = svgPanZoom('#singleWGCNASVG',{
                                            panEnabled: true
                                          , controlIconsEnabled:false
                                          , zoomEnabled: true
                                          , dblClickZoomEnabled: true
                                          , zoomScaleSensitivity: 0.2
                                          , minZoom: 0.1
                                          , maxZoom: 4
                                          , fit: true
                                          , center: true
                                          
                                    });*/
                
                thatimg.drawLinks=function(d){
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
                        var lnk=thatimg.svg.selectAll(".link").data(links,thatimg.linkKey);
                        lnk.enter().append("line")
                                .attr("class","link")
                                .attr("pointer-events","none")
                                .attr("id",function(d){return "ln_"+replaceDot(d.TC1)+replaceDot(d.TC2);})
                                .attr("x1",function(d){
                                    var x=d3.select("#tc_"+replaceDot(d.TC1)).attr("cx");
                                    //console.log(d.TC1+":x1:"+x);
                                    return x;
                                })
                                .attr("y1",function(d){
                                    var y=d3.select("#tc_"+replaceDot(d.TC1)).attr("cy");
                                    //console.log(d.TC1+":y1:"+y);
                                    return y;
                                })
                                .attr("x2",function(d){
                                    var x=d3.select("#tc_"+replaceDot(d.TC2)).attr("cx");
                                    //console.log(d.TC2+":x2:"+x);
                                    return x;
                                })
                                .attr("y2",function(d){
                                    var y=d3.select("#tc_"+replaceDot(d.TC2)).attr("cy");
                                    //console.log(d.TC2+":y2:"+y);
                                    return y;
                                })
                                .attr("stroke",thatimg.colorLink)
                                .attr("stroke-width",function(d){
                                    var val=Math.abs(d.Cor)*20;
                                    /*if(Math.abs(d.Cor)<thatimg.CorCutoff){
                                        val=0;
                                    }*/
                                    return val;
                                });
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

		thatimg.draw=function(){
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

                    /*thatimg.svg.append("circle")
                                    .attr("cx",thatimg.width/2)
                                    .attr("cy",thatimg.height/2)
                                    .attr("r",thatimg.r)
                                    .attr("stroke","#000000")
                                    .attr("fill","#FFFFFF");*/
                    thatimg.svg.append("text")
                            .attr("font-size","18")
                                            .attr("y",22)
                                            .attr("x",5)/*function(){
                                                    var len=that.selectedModule.MOD_NAME.length;
                                                    var w=len/2;
                                                    var offset=thatimg.width/2-(w*6.5);
                                                    return offset;
                                            })*/
                                            .text(that.selectedModule.MOD_NAME);
                    
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
                        thatimg.CorCutoff_min=0.3;
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
                    var tc=thatimg.svg.selectAll(".geneTC")
                                    .data(thatimg.data,thatimg.geneKey);
                    //tc.sort();
                    //add new
                    tc.enter().append("circle")
                                    .attr("class","geneTC")
                                    .attr("id",function(d){return "tc_"+replaceDot(d.ID);})
                                    .attr("cx", thatimg.nodeX)
                                    .attr("cy",thatimg.nodeY)
                                    .attr("r",3)
                                    .attr("stroke","#000000")
                                    .attr("fill","#FF0000");
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
                        var lnk=thatimg.svg.selectAll(".link").data(links,thatimg.linkKey);
                        lnk.enter().append("line")
                                .attr("class","link")
                                .attr("id",function(d){return "ln_"+replaceDot(d.TC1)+replaceDot(d.TC2);})
                                .attr("x1",function(d){
                                    var x=d3.select("#tc_"+replaceDot(d.TC1)).attr("cx");
                                    //console.log(d.TC1+":x1:"+x);
                                    return x;
                                })
                                .attr("y1",function(d){
                                    var y=d3.select("#tc_"+replaceDot(d.TC1)).attr("cy");
                                    //console.log(d.TC1+":y1:"+y);
                                    return y;
                                })
                                .attr("x2",function(d){
                                    var x=d3.select("#tc_"+replaceDot(d.TC2)).attr("cx");
                                    //console.log(d.TC2+":x2:"+x);
                                    return x;
                                })
                                .attr("y2",function(d){
                                    var y=d3.select("#tc_"+replaceDot(d.TC2)).attr("cy");
                                    //console.log(d.TC2+":y2:"+y);
                                    return y;
                                })
                                .attr("stroke",thatimg.colorLink)
                                .attr("stroke-width",function(d){
                                    var val=Math.abs(d.Cor)*20;
                                    /*if(Math.abs(d.Cor)<thatimg.CorCutoff){
                                        val=0;
                                    }*/
                                    return val;
                                });
                    }
                    
                    thatimg.svg.selectAll(".geneTC").remove();
                    var tc=thatimg.svg.selectAll(".geneTC")
		   			.data(thatimg.data,thatimg.geneKey);
                        //tc.sort();
			//add new
                    tc.enter().append("g")
                            .append("circle")
                            .attr("class","geneTC")
                            .attr("id",function(d){return "tc_"+replaceDot(d.ID);})
                            .attr("cx", thatimg.nodeX)
                            .attr("cy",thatimg.nodeY)
                            //.attr("r",function(d,i){return 3+d.LinkCount;})
                            .attr("r",thatimg.nodeRadiusSum)
                            .attr("stroke","#000000")
                            .attr("fill",thatimg.colorCircle)
                            .on("click",function(){

                            })
                            .on("mouseover",function(){
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
                                    var d=d3.select(this).data()[0];
                                    $("[id^=ln_"+replaceDot(d.ID)+"]").each(function(){
                                        var id=$(this).attr("id");
                                        d3.select("line#"+id).attr("stroke",thatimg.colorLinkHighlight);
                                    });
                                    $("[id$="+replaceDot(d.ID)+"]").each(function(){
                                        var id=$(this).attr("id");
                                        d3.select("line#"+id).attr("stroke",thatimg.colorLinkHighlight);
                                    });
                                    if(!thatimg.showLinks){
                                        thatimg.drawLinks(d);
                                    }
                                    d3.select("#txt_"+replaceDot(d.ID)).select("text").attr("fill","#00A347");
                                    var tcList=that.selectedGene[d.Gene.ID].tcList;
                                    for(var l=0;l<tcList.length;l++){
                                        d3.select("#tc_"+replaceDot(tcList[l].ID)).attr("fill","#FEFF49");
                                    }
                                    
                            })
                            .on("mouseout",function(){
                                    var d=d3.select(this).data()[0];
                                    $("[id^=ln_"+replaceDot(d.ID)+"]").each(function(){
                                        var id=$(this).attr("id");
                                        d3.select("line#"+id).attr("stroke",thatimg.colorLink);
                                    });
                                    $("[id$="+replaceDot(d.ID)+"]").each(function(){
                                        var id=$(this).attr("id");
                                        d3.select("line#"+id).attr("stroke",thatimg.colorLink);
                                    });
                                    d3.select(this).style("fill",thatimg.colorCircle);//.attr("stroke","#000000");
                                    d3.select("#txt_"+replaceDot(d.ID)).select("text").attr("fill","#000000");
                                    tt.transition()        
                                    .duration(500)      
                                    .style("opacity", 0);
                                    if(!thatimg.showLinks){
                                        thatimg.svg.selectAll(".link").remove();
                                    }
                            });
                    var lbl=tc.append("g").attr("class","label")
                            .attr("id",function(d){return "txt_"+replaceDot(d.ID);})
                            .attr("transform", function(d,i){
                            var x=thatimg.nodeXLbl(d,i);//+Math.cos(thatimg.nodeRadiusSum(d,i)+20);
                            var y=thatimg.nodeYLbl(d,i);//+Math.sin(thatimg.nodeRadiusSum(d,i)+20);
                        return "translate("+x+","+y+")";
                    });
                    /*var arc = d3.svg.arc()
                                .innerRadius(function(d,i){return thatimg.nodeRadiusSum(d,i)+25;})
                                .outerRadius(function(d,i){return thatimg.nodeRadiusSum(d,i)+25;})
                                .startAngle(function(d,i){
                                    var ii=i%thatimg.maxPerLevel; 
                                    return (ii*thatimg.angle)-(Math.PI*0.9); 
                                    //return 0;
                                })
                                .endAngle(function(d,i){
                                    var ii=i%thatimg.maxPerLevel; 
                                    return (ii*thatimg.angle)-(Math.PI*0.9)+(Math.PI*1.25); 
                                    //return 0;
                                });
                    lbl.append("path").attr("fill","white")
                        .attr("id", function(d,i){return "lbl"+i;})
                        .attr("d",arc);*/
                    lbl.append("text")
                        /*.append("textPath")
                        .attr("textLength",function(d,i){return 90-i*5 ;})
                        .attr("xlink:href",function(d,i){return "#lbl"+i;})
                        .attr("startOffset",function(d,i){return 3/20;})
                        .attr("dy","-1em")*/
                        .attr("transform",function(d,i){
                            var deg=-90;
                            var ii=i%thatimg.maxPerLevel; 
                            deg=deg+thatimg.angleDeg*ii;
                            if(deg>90){
                                deg=deg-180;
                            }
                            return "rotate("+deg+")";
                        })
                        .text(function(d){return d.Gene.geneSymbol;});
                       
		};
		
		return thatimg;
	};

	that.singleWGCNATableGeneView=function(){
		$('div#waitModuleTable').hide();
                $('div#wgcnaModuleTable').show();
                $('span#modTableName').html(that.selectedModule.MOD_NAME);
		d3.select("table#moduleTable").select("tbody").selectAll('tr').remove();
		var tracktbl=d3.select("table#moduleTable").select("tbody").selectAll('tr').data(that.selectedModule.TCList,that.geneKey)
				.enter().append("tr")
				.attr("id",function(d){return "modtrx"+d.ID;})
				.attr("class",function(d,i){var ret="odd";if(i%2===0){ret="even";} return ret;});
		tracktbl.each(function(d,i){
				d3.select(this).append("td").html(d.Gene.geneSymbol);
				d3.select(this).append("td").html(d.Gene.ID);
				d3.select(this).append("td").html(d.ID);
				d3.select(this).append("td").html(d.PSList.length);
                                d3.select(this).append("td").html(d.LinkSum.toFixed(2));
		});
		
		//$('table#trkSelList'+that.level).dataTable().destroy();
		if($.fn.DataTable.isDataTable( 'table#moduleTable' )){
			$('table#moduleTable').DataTable().destroy();
		}
                $('table#moduleTable').DataTable({
				"bPaginate": false,
				/*"bProcessing": true,
				"bStateSave": false,
				"bAutoWidth": true,
				"bDeferRender": true,*/
				"aaSorting": [[ 4, "desc" ]],
				"sDom": '<"rightTable"i><"leftTable"f><t>'
			});
		//trackDataTable.draw();
	};

	/*that.singleWGCNAImageGoView=function(){

	};
	that.singleWGCNAImageMultiMiRView=function(){

	};*/
	that.singleWGCNAImageEQTLView=function(){
        var thatimg=that.singleWGCNAImage();
            $("#linkCtls").hide();
            $(".eqtlCtls").show();
            
            thatimg.type="eqtl";
            
            thatimg.createToolTip=function(geneID){
                        var gene=that.selectedGene[geneID];
			var tt="<BR>Gene: "+gene.geneSymbol+"("+geneID+")";
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
                thatimg.update(contextRoot+"tmpData/modules/ds"+that.wDSID+"/"+that.selectedModule.MOD_NAME+"/"+that.selectedModule.MOD_NAME+"_1/svg/circos_new.svg");
                /*d3.select("#wgcnaGeneImage").append("iframe")
                        .attr("width","100%")
                        .attr("height",function(){return Math.floor(window.innerHeight*0.9);})
                        .attr("id","circosIFrame")
                        .attr("scrolling","no")
                        .attr("src","tmpData/modules/ds1/"+that.selectedModule.MOD_NAME+"/"+that.selectedModule.MOD_NAME+"_1/svg/circos_new.svg")
                    .style({
                        "border-width":"0px"
                    });*/
               
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
                                    })
                                    .on("mouseout",function(){
                                        var color=thatimg.colorGene(d3.select(this).attr("id"));
                                        d3.select(this).style("fill",color).attr("font-size","26px");
                                        tt.transition()        
                                            .duration(500)      
                                            .style("opacity", 0);
                                    });
                                }
                });
            };
            return thatimg;
	};

	return that;
}