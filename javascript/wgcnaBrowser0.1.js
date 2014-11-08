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

function WGCNABrowser(id,disptype,viewtype,tissue){
	that={};
	that.singleID=id;
	that.dispType=disptype;
	that.viewType=viewtype;
	that.moduleList=[];
	that.modules={};
	that.tissue=tissue;
	that.panel="";
	that.requests=0;
	that.skipGrey=1;


	that.setup=function(){
		//request Module List
		that.requestModuleList();
		//create Image Controls
		that.createImageControls();
		//create View Controls
		that.createViewControls();
		//create Data Controls
		that.createDataControls();
	};

	that.requestModuleList=function (){
		$.ajax({
				url:  pathPrefix +"getWGCNAModules.jsp",
	   			type: 'GET',
	   			async: true,
				data: {modFileType:that.viewtype,id:that.singleID,organism:organism,panel:that.panel,tissue:that.tissue},
				dataType: 'json',
	    		success: function(data2){
	        		for(var i=0;i<data2.length;i++){
	        				that.moduleList.push(data2[i].ModuleID); 
	        				//var isLast=data2.length-i;
	        				that.requests++;
	        				that.requestModule(data2[i].ModuleID);
	        				console.log("after calling:"+that.requests);
	        		}
	        		console.log(that.moduleList);
	    		},
	    		error: function(xhr, status, error) {
	        		
	    		}
		});
	};
	that.requestModule=function(file){
		$.ajax({
				url:  "../../tmpData/modules/ds1/" +file+".json",
	   			type: 'GET',
	   			async: true,
				data: {},
				dataType: 'json',
	    		success: function(data2){
	    				that.requests--;
	        			that.modules[file]=data2;
	        			that.countGeneInstance(that.singleID,data2);
	        			if(that.requests===0){
	        				that.createMultiWGCNAImage();
	        			}
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
			if(list[k].Gene.ID===idlist){
				data.selectGeneTC[list[k].ID]=1;
				count++;
			}
		}
		data.GeneCount=count;
	};
	that.createImageControls=function(){
		that.imageBar=d3.select("div#wgcnaImageControls").append("span").style("float","left");
		that.imageBar.append("span").attr("class","saveImage control").style("display","inline-block")
			.attr("id","saveLevel"+that.levelNumber)
			.style("cursor","pointer")
			.append("img")//.attr("class","mouseOpt dragzoom")
			.attr("src","/web/images/icons/savePic_dark.png")
			.attr("pointer-events","all")
			.attr("cursor","pointer")
			.on("click",function(){
				var id=$(this).parent().attr("id");
				var levelID=(new String(id)).substr(9);
				//console.log("Level #:"+levelID);
				var content=$("div#Level"+levelID).html();
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
							var region=new String($('#geneTxt').val());
							region=region.replace(/:/g,"_");
							region=region.replace(/-/g,"_");
							region=region.replace(/,/g,"");
							if(levelID=="Level1"){
								region=svgList[1].selectedData.getAttribute("geneSymbol");
							}
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
										$("#mouseHelp").html("<span style='color:#FF0000;'>Your browser will not save the image directly. Image will open in a popup, in the new window right click to save image.</span>");
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
				that.multiImage.zoomIn();
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
				that.multiImage.zoomOut();
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
		that.viewBar=d3.select("div#wgcnaImageControls").append("span").attr("id","wgcnaViewControls").style("float","right").style("margin-left","10px").style("margin-right","5px");
		that.viewBar.append("text").text("View:");
		that.viewBar.append("input").attr("type","radio").attr("name","wgcnaViewRB").attr("value","gene").attr("checked","checked").style("margin-left","7px").style("margin-right","3px");
		that.viewBar.append("text").text("Gene");
		that.viewBar.append("input").attr("type","radio").attr("name","wgcnaViewRB").attr("value","go").style("margin-left","7px").style("margin-right","3px");
		that.viewBar.append("text").text("GO");
		/*that.viewBar.append("input").attr("type","radio").attr("name","wgcnaViewRB").attr("value","mir").style("margin-left","7px").style("margin-right","3px");
		that.viewBar.append("text").text("miRNA(multiMiR)");
		that.viewBar.append("input").attr("type","radio").attr("name","wgcnaViewRB").attr("value","eqtl").style("margin-left","7px").style("margin-right","3px");
		that.viewBar.append("text").text("eQTL");*/
	};

	that.createDataControls=function(){
		that.dataBar=d3.select("div#wgcnaImageControls").append("span").attr("id","wgcnaDataControls").style("float","right").style("margin-left","10px").style("margin-right","5px");
		that.dataBar.append("text").text("Tissue:");
		var sel=that.dataBar.append("select").attr("id","wgcnaTissueSelect");
		that.tissues=["Brain"];
		that.dispTissues=["Whole Brain"];
		if(organism=="Rn"){
			that.tissues=["Brain","Heart","Liver"];
			that.dispTissues=["Whole Brain","Heart","Liver"];
		}
		for(var i=0;i<that.tissues.length;i++){
			sel.append("option").attr("value",that.tissues[i]).text(that.dispTissues[i]);
		}

	};
	that.positionTTLeft = function(pageX){
		var x=pageX+20;
    	if(x>($(window).width()/2)){
    		x=x-490;
    	}
    	var xPos=x+"px";
    	return xPos;
	};

	that.positionTTTop = function(pageY){
		var topPos=(pageY + 5) + "px";
		if(d3.event.clientY>(window.innerHeight*0.6)){
			topPos=(d3.event.pageY - ($(".testToolTip").height()*2.2)) + "px";
		}
		return topPos;
	};

	//public method to create any type of WGCNA Image
	that.createMultiWGCNAImage=function(){
		console.log("createIMAGE");
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
			var tt="Module Name: "+d.MOD_NAME+"<BR>Size: "+d.TCList.length;
			return tt;
		};
		thatimg.draw=function(){
			thatimg.svg.selectAll(".modules").remove();
			thatimg.totalWidth=$(window).width();
			thatimg.modPerLine=Math.floor($(window).width()/thatimg.maxWidth);
			thatimg.calcWidth=Math.floor($(window).width()/thatimg.modPerLine);
			var data=[];
			thatimg.dataList={};
			var dataCount=0;
			for(var j=0;j<that.moduleList.length;j++){
				if(that.moduleList[j]!=="grey" || (that.moduleList[j]==="grey" && that.skipGrey===0 )){
					data[dataCount]=that.modules[that.moduleList[j]];
					//thatimg.dataList[that.moduleList[j]]=dataCount;
					dataCount++;
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
					.attr("fill","url(#lgrad)")
					.on("click",function(){
						thatimg.maxWidth=50;
						thatimg.draw();
						d3.select("#multiWGCNAScroll").style("max-height","70px");
						thatimg.svg.select("g#"+d.MOD_NAME).style("background","#CECECE");
						thatimg.svg.select("g#"+d.MOD_NAME).select("circle").attr("fill","url(#selectGrad)");
						that.selectedModule=d;
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
						d3.select(this).style("fill","url(#lgrad)");
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
					.text(d.GeneCount);
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

	that.multiWGCNAImageGoView=function(){
		var thatimg=that.multiWGCNAImage();
		
		return thatimg;
	};
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
		if(that.viewType==="gene"){
			that.singleImage=that.singleWGCNAImageGeneView(that.modules);
			that.singleImage.draw();
			that.img=that.singleImage;
		}else if(that.viewType==="go"){
			that.singleImage=that.singleWGCNAImageGoView(that.modules);
			that.singleImage.draw();
			that.img=that.singleImage;
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
		
		thatimg.data=[];

		//setup image
		if(d3.select("#singleWGCNASVG").size()===0){
			thatimg.svg=d3.select("#wgcnaGeneImage").append("svg").attr("id","singleWGCNASVG").attr("height",thatimg.height+"px").attr("width","100%");
		}else{
			thatimg.svg=d3.select("#singleWGCNASVG");
		}

		thatimg.geneKey=function(d){return d.ID;};
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

		thatimg.draw=function(){

		};

		thatimg.redraw=function(){

		};

		thatimg.createToolTip=function(d){
			var tt="Gene Cluster ID:"+d.ID+"<BR>Gene: "+d.Gene.ID;
			return tt;
		};

		return thatimg;
	};
	//internal methods to setup each specific type
	that.singleWGCNAImageGeneView=function(){
		var thatimg=that.singleWGCNAImage();

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
			thatimg.svg.selectAll(".geneTC").remove();

			thatimg.svg.append("circle")
					.attr("cx",thatimg.width/2)
					.attr("cy",thatimg.height/2)
					.attr("r",thatimg.r)
					.attr("stroke","#000000")
					.attr("fill","#FFFFFF");
			thatimg.svg.append("text")
						.attr("y",12)
						.attr("x",function(){
							var len=that.selectedModule.MOD_NAME.length;
							var w=len/2;
							var offset=thatimg.width/2-(w*6.5);
							return offset;
						})
						.text(that.selectedModule.MOD_NAME);
			thatimg.data=that.selectedModule.TCList;
			thatimg.angle=2*Math.PI/thatimg.data.length;
			var tc=thatimg.svg.selectAll(".geneTC")
		   			.data(thatimg.data,thatimg.geneKey);
			//add new
			tc.enter().append("circle")
					.attr("class","geneTC")
					.attr("cx", function(d,i){return thatimg.width/2+(thatimg.r-30)*Math.cos(i*thatimg.angle);})
					.attr("cy",function(d,i){return thatimg.height/2+(thatimg.r-30)*Math.sin(i*thatimg.angle);})
					.attr("r",10)
					.attr("stroke","#000000")
					.attr("fill","#FF0000")
					.on("click",function(){

					})
					.on("mouseover",function(){
						$("#wgcnaMouseHelp").html("<B>Click</B> to select this gene cluster and see additional details.");
						d3.select(this).style("fill","url(#selectGrad)");
				        	//that.gsvg.get('tt').transition()
				        tt.transition()        
				                .duration(200)      
				                .style("opacity", 1);      
				        	//that.gsvg.get('tt').html(that.createToolTip(d)) 
				        tt.html(thatimg.createToolTip(d3.select(this).data()[0])) 
				                .style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
								.style("top", function(){return that.positionTTTop(d3.event.pageY);});
					})
					.on("mouseout",function(){
						d3.select(this).style("fill","#FF0000");
						tt.transition()        
				                .duration(500)      
				                .style("opacity", 0);
					});
		};
		
		return thatimg;
	};
	that.singleWGCNAImageGoView=function(){

	};
	/*that.singleWGCNAImageMultiMiRView=function(){

	};
	that.singleWGCNAImageEQTLView=function(){

	};*/

	return that;
}