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
	    				console.log(data2);
	    				console.log("after success:"+data2.MOD_NAME+":"+that.requests);
	        			that.modules[file]=data2;
	        			if(that.requests===0){
	        				that.createMultiWGCNAImage();
	        			}
	    		},
	    		error: function(xhr, status, error) {
	        		that.requests--;
	    		}
		});

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
	};

	that.createViewControls=function(){
		that.viewBar=d3.select("div#wgcnaImageControls").append("span").attr("id","wgcnaViewControls").style("float","right").style("margin-left","10px").style("margin-right","5px");
		that.viewBar.append("text").text("View:");
		that.viewBar.append("input").attr("type","radio").attr("name","wgcnaViewRB").attr("value","gene").attr("checked","checked").style("margin-left","7px").style("margin-right","3px");
		that.viewBar.append("text").text("Gene");
		that.viewBar.append("input").attr("type","radio").attr("name","wgcnaViewRB").attr("value","go").style("margin-left","7px").style("margin-right","3px");
		that.viewBar.append("text").text("GO");
		that.viewBar.append("input").attr("type","radio").attr("name","wgcnaViewRB").attr("value","mir").style("margin-left","7px").style("margin-right","3px");
		that.viewBar.append("text").text("miRNA(multiMiR)");
		that.viewBar.append("input").attr("type","radio").attr("name","wgcnaViewRB").attr("value","eqtl").style("margin-left","7px").style("margin-right","3px");
		that.viewBar.append("text").text("eQTL");
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

	//public method to create any type of WGCNA Image
	that.createMultiWGCNAImage=function(){
		console.log("createIMAGE");
		if(that.viewType==="gene"){
			that.multiImage=that.multiWGCNAImageGeneView(that.modules);
			that.multiImage.draw();
		}else if(that.viewType==="go"){
			that.multiImage=that.multiWGCNAImageGoView(that.modules);
			that.multiImage.draw();
		}
	};

	//common prototype to create generic view
	that.multiWGCNAImage=function(){
		thatimg={};
		thatimg.maxWidth=200;
		thatimg.totalWidth=$(window).width();
		thatimg.modPerLine=Math.floor($(window).width()/thatimg.maxWidth);
		thatimg.calcWidth=Math.floor($(window).width()/thatimg.modPerLine);

		//setup image
		if(d3.select("#multiWGCNASVG").size()===0){
			console.log("append");
			thatimg.svg=d3.select("#wgcnaGeneImage").append("svg").attr("id","multiWGCNASVG").attr("height","430px").attr("width",function(){return ($(window).width()-10)+"px";});
		}else{
			console.log("select");
			thatimg.svg=d3.select("#multiWGCNASVG");
		}
		console.log(thatimg.svg);

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

		thatimg.draw=function(){

		};

		thatimg.redraw=function(){

		};

		return thatimg;
	};

	//internal methods to setup each specific type
	that.multiWGCNAImageGeneView=function(){
		thatimg=that.multiWGCNAImage();
		thatimg.draw=function(){
			var data=[];
			for(var j=0;j<that.moduleList.length;j++){
				data[j]=that.modules[that.moduleList[j]];
			}
			console.log("Draw");
			console.log(data);
			var min=d3.min(data,function(d){return d.TCList.length;});
			var max=d3.max(data,function(d){return d.TCList.length;});
			if(max>1000){
				max=1000;
			}
			console.log(min+"_"+max);
			thatimg.size=d3.scale.linear().
		  		domain([min, max]). 
		  		range([5, thatimg.maxWidth/2]);
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
					.attr("stroke","#000000")
					.attr("fill","#00FF00");
				thisMod.append("text").attr("y",thatimg.maxWidth+12).attr("x","5").text(d.MOD_NAME);
			});
		}
		return thatimg;
	};

	that.multiWGCNAImageGoView=function(){
		thatimg=that.multiWGCNAImage();
		
		return thatimg;
	};
	that.multiWGCNAImageMultiMiRView=function(){
		thatimg=that.multiWGCNAImage();
		
		return thatimg;
	};

	that.multiWGCNAImageEQTLView=function(){
		thatimg=that.multiWGCNAImage();
		
		return thatimg;
	};

	//public method to create any type of WGCNA Image
	that.createSingleWGCNAImage=function(){

	};
	
	//common prototype to create generic view
	that.singleWGCNAImage=function(){

	};
	//internal methods to setup each specific type
	that.singleWGCNAImageGeneView=function(){

	};
	that.singleWGCNAImageGoView=function(){

	};
	that.singleWGCNAImageMultiMiRView=function(){

	};
	that.singleWGCNAImageEQTLView=function(){

	};

	return that;
}