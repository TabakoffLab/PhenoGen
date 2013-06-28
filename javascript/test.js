var svgList=new Array();
//Setup some global listners
d3.select('html')
      .on("mousemove", mmove)
	  .on("mouseup", mup);


function mup() {
	for (var i=0; i<svgList.length; i++){
        svgList[i].downx = Math.NaN;
		svgList[i].downPanx = Math.NaN;
	}
}
function mmove(){
	//console.log("list"+svgList);
	for (var i=0; i<svgList.length; i++){
		//console.log(i+": downPanx:"+svgList[i].downPanx);
		if (!isNaN(svgList[i].downx)) {
          var p = d3.mouse(svgList[i].vis[0][0]), rupx = p[0];
          //console.log(p);
          //console.log(rupx);
          if (rupx != 0) {
		  		var minx=svgList[i].downscalex.domain()[0];
		  		var maxx= svgList[i].mw * (svgList[i].downx - svgList[i].downscalex.domain()[0]) / rupx + svgList[i].downscalex.domain()[0];
				if(maxx<=svgList[i].xMax && minx>=1){
            		svgList[i].xScale.domain([minx,maxx]);
					svgList[i].scaleSVG.select(".x.axis").call(svgList[i].xAxis);
					svgList[i].redraw();
				}
          }
        }else if(!isNaN(svgList[i].downPanx)){
			var p = d3.mouse(svgList[i].vis[0][0]), rupx = p[0];
			  if (rupx != 0) {
					var dist=svgList[i].downPanx-rupx;
					var scaleDist=(svgList[i].downscalex.domain()[1]-svgList[i].downscalex.domain()[0])/svgList[i].mw;
					var minx=svgList[i].downscalex.domain()[0]+dist*scaleDist;
					var maxx=dist*scaleDist + svgList[i].downscalex.domain()[1];
					//console.log("before if"+minx+":"+maxx+"  <"+svgList[i].xMax);
					if(maxx<=svgList[i].xMax && minx>=1){
						//console.log("after if");
						svgList[i].xScale.domain([minx,maxx]);
						svgList[i].scaleSVG.select(".x.axis").call(svgList[i].xAxis);
						svgList[i].redraw();
						svgList[i].downPanx=p[0];
					}
				
			  }
		}
	}
}

function createNewLevel(){

}

registerKeyboardHandler = function(callback) {
  var callback = callback;
  d3.select(window).on("keydown", callback);  
};

//Helper functions

function getAllChildrenByName(parentNode,name){
	var listInit=parentNode.childNodes;
	var list=[];
	var listCount=0;
	for(var k=0;k<listInit.length;k++){
		//console.log(txListInit.item(k).nodeName);
		if(listInit.item(k).nodeName==name){
			list[listCount]=listInit.item(k);
			listCount++;
		}
	}
	return list;
}

function getFirstChildByName(parentNode,name){
	var listInit=parentNode.childNodes;
	var node=null;
	var found=false;
	for(var k=0;k<listInit.length&&!found;k++){
		if(listInit.item(k).nodeName==name){
			node=listInit.item(k);
			found=true;
		}
	}
	return node;
}



//D3 helper functions
function key(d) {return d.getAttribute("ID");};
function keyName(d) {return d.getAttribute("name");};




//SVG functions
function GenomeSVG(div,imageWidth,minCoord,maxCoord,levelNumber){
	GenomeSVG.prototype.get=function(attr){return this[attr];}.bind(this);
	GenomeSVG.prototype.addTrack=function (track,density){
		var newTrack=null;
		var par=this;
		if(track=="coding"){
			d3.xml("tmpData/regionData/"+folderName+"/coding.xml",function (d){
				var data=d.documentElement.getElementsByTagName("Gene");
				var newTrack=new GeneTrack(par,data,track,"Protein Coding / PolyA+");
				par.addTrackList(newTrack);
			});
		}else if(track=="noncoding"){
			d3.xml("tmpData/regionData/"+folderName+"/noncoding.xml",function (d){
				var data=d.documentElement.getElementsByTagName("Gene");
				var newTrack=new GeneTrack(par,data,track,"Long Non-Coding / Non-PolyA+");
				par.addTrackList(newTrack);
			});
		}else if(track=="smallnc"){
			d3.xml("tmpData/regionData/"+folderName+"/smallnc.xml",function (d){
				var data=d.documentElement.getElementsByTagName("smnc");
				var newTrack=new GeneTrack(par,data,track,"Small RNA (<200 bp)");
				par.addTrackList(newTrack);
			});
		}else if(track=="snp"){
			d3.xml("tmpData/regionData/"+folderName+"/snp.xml",function (d){
				var snp=d.documentElement.getElementsByTagName("Snp");
				var newTrack=new SNPTrack(par,snp,track,density);
				par.addTrackList(newTrack);
			});
			//setupSNP(level,density);
		}else if(track=="qtl"){
			d3.xml("tmpData/regionData/"+folderName+"/qtl.xml",function (d){
				var qtl=d.documentElement.getElementsByTagName("QTL");
				var newTrack=new QTLTrack(par,qtl,track,density);
				par.addTrackList(newTrack);
			});
		}/*else if(track=="probe"){
			d3.xml("tmpData/regionData/"+folderName+"/probe.xml",function (d){
				var probe=d.documentElement.getElementsByTagName("probe");
				//console.log(probe);
				//setupProbeset(probe,levelDiv,level,levelScale,density);
				var newTrack=new ProbeTrack(par,data,track,"Small RNA (<200 bp)");
				par.addTrackList(newTrack);
			});
		}*/
	}.bind(this);
	GenomeSVG.prototype.addTrackList= function (newTrack){
		if(newTrack!=null){
				this.trackList[this.trackCount]=newTrack;
				this.trackCount++;
		}
	}.bind(this);
	GenomeSVG.prototype.changeTrackHeight = function (level,val){
			if(val>0){
				d3.select("#"+level+"Scroll").style("max-height",val+"px");
			}else{
				d3.select("#"+level+"Scroll").style("max-height","none");
			}
		}.bind(this);

	GenomeSVG.prototype.removeTrack=function (track){
			d3.select("#Level"+this.levelNumber+track).remove();
		}.bind(this);

	GenomeSVG.prototype.redraw=function (){
		for(var i=0;i<this.trackList.length;i++){
			console.log("redraw track:"+i);
			console.log(this.trackList[i]);
			this.trackList[i].redraw();
		}
	}.bind(this);

	GenomeSVG.prototype.mdown=function() {
			//console.log(this.vis);
	        var p = d3.mouse(this.vis[0][0]);
	        this.downx = this.xScale.invert(p[0]);
	        this.downscalex = this.xScale;
		}.bind(this);

	this.margin=0;
	this.halfWindowWidth = 0;
	//this.mw=this.width-this.margin;
	this.mh=400;

	//vars for manipulation
	this.downx = Math.NaN;
	this.downscalex;
	this.downPanx=Math.NaN;


	this.xMax=290000000;
	this.xMin=1;

	this.y=0;

	this.xScale = null;
	this.xAxis = null;
	this.vis=null;
	this.level=null;

	this.svg = null;
		

	this.txType=null;
	this.txList=null;
		
	this.tt=null;

	this.trackList=new Array();
	this.trackCount=0;

	this.levelNumber=levelNumber;

	//setup code
	this.width=imageWidth;
	this.mw=this.width-this.margin;
	if($(window).width()>1000){
		this.halfWindowWidth=($(window).width()-1000)/2;
	}
	this.vis=d3.select(div);
	this.topDiv=this.vis.append("div").attr("id","Level"+levelNumber).style("text-align","left");
	
	
	this.xScale = d3.scale.linear().
  		domain([minCoord, maxCoord]). 
  		range([0, this.width]);
		
	this.xAxis = d3.svg.axis()
    .scale(this.xScale)
    .orient("top")
	.ticks(6)
	.tickSize(8)
    .tickPadding(10);
	
	this.scaleSVG = this.topDiv.append("svg:svg")
    .attr("width", this.width)
    .attr("height", 60)
	.attr("pointer-events", "all")
    .attr("class", "scale")
	.attr("pointer-events", "all")
	.on("mousedown", this.mdown)
	.style("cursor", "ew-resize");
	
	this.scaleSVG.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0,55)")
      .call(this.xAxis);
	  
	d3.select(".x.axis").append("text").text(chr).attr("x", ((this.width-(this.margin*2))/2)).attr("y",-40);
	this.topLevel=this.topDiv.append("div").attr("id","ScrollLevel"+levelNumber).style("max-height","350px").style("overflow","auto").append("ul").attr("class","sortable");
	
	
	this.tt=d3.select("body").append("div")   
    .attr("class", "testToolTip")               
    .style("opacity", 0);
	svgList.push(this);
	
	  
}




function Track(gsvgP,dataP,trackClassP,labelP){
	Track.prototype.panDown=function(){
		var p = d3.mouse(this.svg[0][0]);
        this.gsvg.downPanx = p[0];
        this.gsvg.downscalex = this.xScale;
	}.bind(this);

	this.zoomToFeature= function(d){
					var len=d.getAttribute("stop")-d.getAttribute("start");
					len=len*0.25;
					var minx=d.getAttribute("start")-len;
					var maxx=(d.getAttribute("stop")*1)+len;
					if(maxx<=this.gsvg.xMax && minx>=1){
				            		this.xScale.domain([minx,maxx]);
									this.scaleSVG.select(".x.axis").call(this.xAxis);
									this.gsvg.redraw();
					}
	}.bind(this);

	this.colorStroke = function (d){
			var colorRet="black";
			if(this.xScale(d.getAttribute("stop"))-this.xScale(d.getAttribute("start"))<3){
				colorRet=this.color(d);
			}
			return colorRet;
	}.bind(this);

	this.calcY = function (start,end){
		var tmpY=-299999999;
		var found=false;
		for (var iy=0;iy<this.yArr.length&&!found;iy++){
				if((this.yArr[iy]+10)<this.xScale(start)){
					found=true;
					tmpY=(iy+1)*15;
					if(this.xScale(end)>this.yArr[iy]){
						this.yArr[iy]=this.xScale(end);
					}
				}
		}
		return tmpY;
	}.bind(this);


	this.gsvg=gsvgP;
	this.data=dataP;
	this.label=labelP;
	this.yArr=new Array();
	this.trackClass=trackClassP;
	this.topLevel=this.gsvg.get('topLevel');
	this.xScale=this.gsvg.get('xScale');
	this.scaleSVG=this.gsvg.get('scaleSVG');
	this.xAxis=this.gsvg.get('xAxis');
	for(var j=0;j<100;j++){
			this.yArr[j]=-299999999;
	}
	this.svg=d3.select("#Level"+this.gsvg.get('levelNumber')+this.trackClass);
	if(this.svg[0][0]==null){
			var dragDiv=this.topLevel.append("li");
			this.svg = dragDiv.append("svg:svg")
			.attr("width", this.gsvg.get('width'))
			.attr("height", 800)
			.attr("class", "track draggable")
			.attr("id","Level"+this.gsvg.levelNumber+this.trackClass)
			.attr("pointer-events", "all")
			.style("cursor", "move")
			.on("mousedown", this.panDown);
			this.svg.append("text").text(this.label).attr("x",this.gsvg.width/2-20).attr("y",12);
	}

	
	
	/*Track.prototype.redraw=function(){
	}.bind(this);*/

	

}


function GeneTrack(gsvg,data,trackClass,label){
	var that=new Track(gsvg,data,trackClass,label);

	that.color =function(d){
		var color=d3.rgb("#000000");
		if(d.getAttribute("biotype")=="protein_coding" && (d.getAttribute("stop")-d.getAttribute("start"))>=200){
			if((new String(d.getAttribute("ID"))).indexOf("ENS")>-1){
				color=d3.rgb("#DFC184");
			}else{
				color=d3.rgb("#7EB5D6");
			}
		}else if(d.getAttribute("biotype")!="protein_coding" && (d.getAttribute("stop")-d.getAttribute("start"))>=200){
			if((new String(d.getAttribute("ID"))).indexOf("ENS")>-1){
				color=d3.rgb("#B58AA5");
			}else{
				color=d3.rgb("#CECFCE");
			}
		}else if((d.getAttribute("stop")-d.getAttribute("start"))<200){
			if((new String(d.getAttribute("ID"))).indexOf("ENS")>-1){
				color=d3.rgb("#FFCC00");
			}else{
				color=d3.rgb("#99CC99");
			}
		}
		return color;
	}.bind(that);

	that.createToolTip=function(d){
		var tooltip="";
		var txListStr="";
		if((d.getAttribute("stop")-d.getAttribute("start"))<200){
			var prefix="smRNA_";
			var rnaSeqData="<BR>Total Reads: "+d.getAttribute("reads")+"<BR>Reference Sequence:<BR>"+d.getAttribute("refseq");
			if(new String(d.getAttribute("ID")).indexOf("ENS")>-1){
				prefix="";
				rnaSeqData="";
			}
			tooltip="ID: "+prefix+d.getAttribute("ID")+"<BR>Length:"+(d.getAttribute("stop")-d.getAttribute("start"))+"<BR>Location: "+d.getAttribute("chromosome")+":"+d.getAttribute("start")+"-"+d.getAttribute("stop")+"<BR>Strand: "+d.getAttribute("strand")+rnaSeqData;
																																																													  
		}else{
			var txList=getAllChildrenByName(getFirstChildByName(d,"TranscriptList"),"Transcript");
			for(var m=0;m<txList.length;m++){
				txListStr+="<B>"+txList[m].getAttribute("ID")+"</B>";
				if(new String(txList[m].getAttribute("ID")).indexOf("ENS")==-1){
					var annot=getFirstChildByName(getFirstChildByName(txList[m],"annotationList"),"annotation");
					if(annot!=null){
						txListStr+=" - "+annot.getAttribute("reason");
					}
				}
				txListStr+="<br>";
			}
			tooltip="ID: "+d.getAttribute("ID")+"<BR>Gene Symbol:"+d.getAttribute("geneSymbol")+"<BR>Location:"+d.getAttribute("chromosome")+":"+d.getAttribute("start")+"-"+d.getAttribute("stop")+"<BR>Strand:"+d.getAttribute("strand")+"<BR>Transcripts:<BR>"+txListStr;
		}
		return tooltip;
	}.bind(that);

	that.redraw=function(){
		if(that.svg[0][0]!=null){
			//console.log(svg);
			for(var j=0;j<that.yArr.length;j++){
				that.yArr[j]=-299999999;
			}
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene").attr("transform",function (d){
						var st=that.xScale(d.getAttribute("start"));
						return "translate("+st+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"))+")";
				});
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene rect").attr("width",function(d) {
						var wX=1;
						if(that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"))>1){
							wX=that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"));
						}
						return wX;
				})
				.attr("stroke",that.colorStroke);
			var tmpYMax=-1;
			for(var j=0;j<that.yArr.length&&tmpYMax==-1;j++){
				if(that.yArr[j]==-299999999){
					d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).attr("height", (j+1)*15);
					tmpYMax=j;
				}
			}
		}
	}.bind(that);


	var gene=that.svg.selectAll(".gene")
	   			.data(data,key)
				.attr("transform",function(d){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"))+")";});
		//add new
		gene.enter().append("g")
				.attr("class","gene")
				.attr("transform",function(d){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"))+")";})
				.append("rect")
	    	.attr("height",10)
			.attr("rx",1)
			.attr("ry",1)
			.attr("width",function(d) { return that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start")); })
			.attr("title",function (d){return d.getAttribute("ID");})
			.attr("stroke",that.colorStroke)
			.attr("stroke-width","1")
			.attr("id",function(d){return d.getAttribute("ID");})
			.style("fill",that.color)
			.style("cursor", "pointer")
			//.on("click", that.setupTranscripts)
			.on("dblclick", that.zoomToFeature)
			.on("mouseover", function(d) { 
				d3.select(this).style("fill","green");
		         that.gsvg.get('tt').transition()        
		                .duration(200)      
		                .style("opacity", .95);      
		         that.gsvg.get('tt').html(that.createToolTip(d))  
		                .style("left", ((d3.event.pageX-gsvg.get('halfWindowWidth')) + "px") )  
		                .style("top", (d3.event.pageY + 20) + "px");  
	            })
			.on("mouseout", function(d) {  
				d3.select(this).style("fill",that.color);
	            that.gsvg.get('tt').transition()
					 .delay(500)       
	                .duration(200)      
	                .style("opacity", 0);  
	        });
		
		gene.exit().remove();
		
		var tmpYMax=-1;
		for(var j=0;j<100&&tmpYMax==-1;j++){
			if(that.yArr[j]==-299999999){
				that.svg.attr("height", (j+1)*15);
				tmpYMax=j;
			}
		}
	return that;
}

function ProbeTrack(gsvg,data,trackClass,label){
	var that=new Track(gsvg,data,trackClass,label);
	that.color =function(d){
		var color=d3.rgb("#000000");
		if(d.getAttribute("type")=="core"){
				color=d3.rgb(255,0,0);
		}else if(d.getAttribute("type")=="extended"){
				color=d3.rgb(0,0,255);
		}else if(d.getAttribute("type")=="full"){
				color=d3.rgb(0,100,0);
		}else if(d.getAttribute("type")=="ambiguous"){
				color=d3.rgb(0,0,0);
		}
		return color;
	}.bind(that);
	that.createToolTip=function(d){
		return d.id;
	}.bind(that);

	that.redraw=function(){
		var density=$("#probeSelect").val();
		
		var tmpYArr=new Array();
		for(var j=0;j<100;j++){
			tmpYArr[j]=-299999999;
		}
		
		d3.select("#"+level+"probe").selectAll("g.probe").attr("transform",function (d,i){
															   var st=levelScale(d.getAttribute("start"));
																return "translate("+st+","+calcYTrack(d.getAttribute("start"),d.getAttribute("stop"),tmpYArr,density,i,2)+")";
															});
		d3.select("#"+level+"probe").selectAll("g.probe rect").attr("width",function(d) {
								   var wX=1;
								   if(levelScale(d.getAttribute("stop"))-levelScale(d.getAttribute("start"))>1){
									   wX=levelScale(d.getAttribute("stop"))-levelScale(d.getAttribute("start"));
								   }
								   return wX;
								   }
									);
		if(density==1){
			probeSvg.attr("height", 30);
		}else if(density==2){
			probeSvg.attr("height", (d3.select("#"+level+"snp").selectAll("g.snp").length+1)*15);
		}else if(density==3){
			var tmpYMax=-1;
			for(var j=0;j<tmpYArr.length&&tmpYMax==-1;j++){
				if(tmpYArr[j]==-299999999){
					d3.select("#"+level+"probe").attr("height", j*15);
					tmpYMax=j;
				}
			}
		}
	}.bind(that);

	that.calcY=function (start,end,tmpYArr,density,i,spacing){
		var tmpY=-299999999;
		var found=false;
		if(density==1){
			tmpY=15;
		}else if(density==2){
			tmpY=(i+1)*15;
		}else{
			var found=false;
			var count=0;
			var startAt=0;
			while(!found && count<3){
				for (var iy=startAt;iy<tmpYArr.length&&!found;iy++){
						if((tmpYArr[iy]+spacing)<xScale(start)){
							found=true;
							tmpY=(iy+1)*15;
							if(xScale(end)>tmpYArr[iy]){
								tmpYArr[iy]=xScale(end);
								found=true;
							}
						}
				}
				if(!found){
					count++;
					startAt=tmpYArr.length;
					for(var n=0;n<50;n++){
						tmpYArr.push(-299999999);
					}
				}
			}
			if(!found){
				tmpY=(tmpYArr.length+1)*15;
			}
		}
		return tmpY;
	}.bind(that);


	/*var probeSvg = levelDiv.append("svg:svg")
			.attr("width", width)
			.attr("height", 100)
			.attr("id",level+"probe")
			.attr("class","track draggable")
			.attr("pointer-events", "all")
			.on("mousedown", that.Pandown)
			.style("cursor", "move");
	probeSvg.append("text").text("Affymetrix Exon 1.0 ST Probesets (All Non-masked)").attr("x",width/2-20).attr("y",12);
	var tmpYArr=new Array();
	for(var j=0;j<100;j++){
		tmpYArr[j]=-299999999;
	}*/
	//update
	var probes=that.svg.selectAll(".probe")
   			.data(probe,key)
			.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),tmpYArr,density,i,5)+")";});
			
  	
			
	//add new
	probes.enter().append("g")
			.attr("class","probe")
			.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),tmpYArr,density,i,5)+")";})
			.append("rect")
    	.attr("height",10)
		.attr("rx",1)
		.attr("ry",1)
		.attr("width",function(d) {
							   var wX=1;
							   if(that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"))>1){
								   wX=that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"));
							   }
							   return wX;
							   })
		.attr("id",function(d){return d.getAttribute("ID");})
		.style("fill",that.color)
		.style("cursor", "pointer")
		.on("mouseover", function(d) { 
			d3.select(this).style("fill","green");
            that.gsvg.get('tt').transition()        
                .duration(200)      
                .style("opacity", .95);      
            that.gsvg.get('tt').html(createToolTipProbe(d))  
                .style("left", (d3.event.pageX-halfWindowWidth) + "px")     
                .style("top", (d3.event.pageY + 20) + "px");  
            })
		.on("mouseout", function(d) {  
			d3.select(this).style("fill",colorSNP);
            that.gsvg.get('tt').transition()
				 .delay(500)       
                .duration(200)      
                .style("opacity", 0);  
        });
		
	
	probes.exit().remove();
	if(density==1){
		probeSvg.attr("height", 30);
	}else if(density==2){
		probeSvg.attr("height", (snps.length+1)*15);
	}else if(density==3){
		var tmpYMax=-1;
		for(var j=0;j<100&&tmpYMax==-1;j++){
			if(tmpYArr[j]==-299999999){
				probeSvg.attr("height", (j)*15);
				tmpYMax=j;
			}
		}
	}
}

function SNPTrack(gsvg,data,trackClass,density){
	var that=new Track(gsvg,data,trackClass,"SNPs/Indels");
	
	that.redraw=function (){
		that.density=$("#snp"+that.gsvg.levelNumber+"Select").val();
		if(that.density==null || that.density==undefined){
			that.density=1;
		}
		for(var j=0;j<this.yArr.length;j++){
			this.yArr[j]=-299999999;
		}
		d3.select("#Level"+this.gsvg.levelNumber+this.trackClass).selectAll("g.snp")
				.attr("transform",function (d,i){
										var st=that.xScale(d.getAttribute("start"));
										return "translate("+st+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i,2)+")";
										});
		d3.select("#Level"+this.gsvg.levelNumber+this.trackClass).selectAll("g.snp rect")
								.attr("width",function(d) {
								   var wX=1;
								   if(that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"))>1){
									   wX=that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"));
								   }
								   return wX;
								 });
		if(that.density==1){
			this.svg.attr("height", 30);
		}else if(that.density==2){
			this.svg.attr("height", (d3.select("#Level"+this.gsvg.levelNumber+this.trackClass).selectAll("g.snp").length+1)*15);
		}else if(that.density==3){
			var tmpYMax=-1;
			for(var j=0;j<this.yArr.length&&tmpYMax==-1;j++){
				if(this.yArr[j]==-299999999){
					this.svg.attr("height", (j+1)*15);
					tmpYMax=j;
				}
			}
		}
	}.bind(that);

	that.calcY=function (start,end,i,spacing){
		var tmpY=-299999999;
		var found=false;
		if(this.density==1){
			tmpY=15;
		}else if(this.density==2){
			tmpY=(i+1)*15;
		}else{
			var found=false;
			var count=0;
			var startAt=0;
			while(!found && count<3){
				for (var iy=startAt;iy<this.yArr.length&&!found;iy++){
						if((this.yArr[iy]+spacing)<this.xScale(start)){
							found=true;
							tmpY=(iy+1)*15;
							if(this.xScale(end)>this.yArr[iy]){
								this.yArr[iy]=this.xScale(end);
								found=true;
							}
						}
				}
				if(!found){
					count++;
					startAt=this.yArr.length;
					for(var n=0;n<50;n++){
						this.yArr.push(-299999999);
					}
				}
			}
			if(!found){
				tmpY=(this.YArr.length+1)*15;
			}
		}
		return tmpY;
	}.bind(that);

	that.color=function (d){
		var color=d3.rgb("#000000");
		if(d.getAttribute("type")=="SNP"){
			if(d.getAttribute("strain")=="BNLX"){
				color=d3.rgb(0,0,255);
			}else if(d.getAttribute("strain")=="SHRH"){
				color=d3.rgb(255,0,0);
			}else{
				color=d3.rgb(100,100,100);
			}
		}else{
			if(d.getAttribute("strain")=="BNLX"){
				color=d3.rgb(0,0,150);
			}else if(d.getAttribute("strain")=="SHRH"){
				color=d3.rgb(150,0,0);
			}else{
				color=d3.rgb(50,50,50);
			}
		}
		return color;
	}.bind(that);

	that.createToolTip=function (d){
		var tooltip="";
		tooltip="Type: "+d.getAttribute("type")+"<BR>Strain: "+d.getAttribute("strain")+"<BR>Sequence: "+d.getAttribute("refSeq")+"->"+d.getAttribute("strainSeq")+"<BR>Location: "+d.getAttribute("chromosome")+":"+d.getAttribute("start")+"-"+d.getAttribute("stop");
		return tooltip;
	}.bind(that);
	
	that.density=density;
	//update
	var snps=that.svg.selectAll(".snp")
   			.data(data,key)
			.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i,2)+")";});
			
  	
			
	//add new
	snps.enter().append("g")
			.attr("class","snp")
			.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i,2)+")";})
			.append("rect")
    	.attr("height",10)
		.attr("rx",1)
		.attr("ry",1)
		.attr("width",function(d) {
							   var wX=1;
							   if(that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"))>1){
								   wX=that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"));
							   }
							   return wX;
							   })
		.attr("id",function(d){return d.getAttribute("ID");})
		.style("fill",that.color)
		.style("cursor", "pointer")
		//.on("mousedown", setupTranscripts)
		.on("mouseover", function(d) { 
			d3.select(this).style("fill","green");
            that.gsvg.get('tt').transition()        
                .duration(200)      
                .style("opacity", .95);      
            that.gsvg.get('tt').html(that.createToolTip(d))  
                .style("left", (d3.event.pageX-that.gsvg.get('halfWindowWidth')) + "px")     
                .style("top", (d3.event.pageY + 20) + "px");  
            })
		.on("mouseout", function(d) {  
			d3.select(this).style("fill",that.color);
            that.gsvg.get('tt').transition()
				 .delay(500)       
                .duration(200)      
                .style("opacity", 0);  
        });
		
	
	snps.exit().remove();
	if(that.density==1){
		that.svg.attr("height", 30);
	}else if(that.density==2){
		that.svg.attr("height", (data.length+1)*15);
	}else if(that.density==3){
		var tmpYMax=-1;
		for(var j=0;j<that.yArr.length&&tmpYMax==-1;j++){
			if(that.yArr[j]==-299999999){
				svg.attr("height", (j+1)*15);
				tmpYMax=j;
			}
		}
	}
	return that;
}

function QTLTrack(gsvg,data,trackClass,density){
	var that=new Track(gsvg,data,trackClass,"QTLs");
	
	that.color= function (){
		return "blue";
	}.bind(that);

	that.redraw= function (){
		//var qtlSvg=d3.select("#"+level+"qtl");
		var density=2;
		
		//var tmpYArr=new Array();
		
		var qtls=this.svg//d3.select("#"+level+"qtl")
						.selectAll("g.qtl")
						.attr("transform",function (d,i){
								var st=that.xScale(d.getAttribute("start"));
								return "translate("+st+","+(i+1)*15+")";
						});
		d3.select("#Level"+this.gsvg.levelNumber+this.trackClass).selectAll("g.qtl rect")
						.attr("width",function(d) {
								var wX=1;
								if(that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"))>1){
									wX=that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"));
								}
								return wX;
						});
		
	}.bind(that);

	that.createToolTip=function (d){
		var tooltip="";
		tooltip="Name: "+d.getAttribute("name")+"<BR>Location: "+d.getAttribute("chromosome")+":"+d.getAttribute("start")+"-"+d.getAttribute("stop")+"<BR>Trait:<BR>"+d.getAttribute("trait")+"<BR><BR>Phenotype:<BR>"+d.getAttribute("phenotype")+"<BR><BR>Candidate Genes:<BR>"+d.getAttribute("candidate");
		return tooltip;
	}.bind(that);

	//update
	var qtls=that.svg.selectAll(".qtl")
   			.data(data,key)
			.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+(i+1)*15+")";});
			
  	
			
	//add new
	qtls.enter().append("g")
			.attr("class","qtl")
			.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+(i+1)*15+")";})
			.append("rect")
    	.attr("height",10)
		.attr("rx",1)
		.attr("ry",1)
		.attr("width",function(d) {
							   var wX=1;
							   if(that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"))>1){
								   wX=that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"));
							   }
							   return wX;
							   })
		.attr("id",function(d){return d.getAttribute("Name");})
		.style("fill","blue")
		.style("cursor", "pointer")
		//.on("mouseover", that.onMouseOver)
		//.on("mouseout", that.onMouseOut);
		//.on("mousedown", setupTranscripts)
		.on("mouseover", function(d) { 
			d3.select(this).style("fill","green");
            that.gsvg.get('tt').transition()        
                .duration(200)      
                .style("opacity", .95);      
            that.gsvg.get('tt').html(that.createToolTip(d))  
                .style("left", (d3.event.pageX-that.gsvg.halfWindowWidth) + "px")     
                .style("top", (d3.event.pageY + 20) + "px");  
            })
		.on("mouseout", function(d) {  
			d3.select(this).style("fill","blue");
            that.gsvg.tt.transition()
				 .delay(500)       
                .duration(200)      
                .style("opacity", 0);  
        });
		

	
	qtls.exit().remove();
	
	that.svg.attr("height", (data.length+1)*15);
	return that;
}


function drawTrx(d,i){
	//console.log(d);
	
	//add new
	var txG=txSvg.select("#"+d.getAttribute("ID"));
	
	exList=getAllChildrenByName(getFirstChildByName(d,"exonList"),"exon");
	//console.log(exList);
	for(var m=0;m<exList.length;m++){
		txG.append("rect")
		.attr("x",function(d){ return txXScale(exList[m].getAttribute("start")); })
		.attr("rx",1)
		.attr("ry",1)
    	.attr("height",10)
		.attr("width",function(d){ return txXScale(exList[m].getAttribute("stop")) - txXScale(exList[m].getAttribute("start")); })
		.attr("title",function(d){ return exList[m].getAttribute("ID");})
		//.attr("stroke","black")
		//.attr("stroke-width","1")
		.attr("id",function(d){return "Ex"+exList[m].getAttribute("ID");})
		.style("fill",colorTx)
		.style("cursor", "pointer")
		if(m>0){
			txG.append("line")
			.attr("x1",function(d){ return txXScale(exList[m-1].getAttribute("stop")); })
			.attr("x2",function(d){ return txXScale(exList[m].getAttribute("start")); })
			.attr("y1",5)
			.attr("y2",5)
		.attr("id",function(d){ return "Int"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID");})
		.attr("stroke",colorTx)
		.attr("stroke-width","2")
		}
	}
	
}

function setupTranscripts(d){

	var e = jQuery.Event("keyup");
	e.which = 32; // # Some key code value
	//filter table
	$('#tblGenes_filter input').val(d.getAttribute("ID")).trigger(e);

	txType="none";
	if(d.getAttribute("biotype")=="protein_coding" && (d.getAttribute("stop")-d.getAttribute("start"))>=200){
		txType="protein";
	}else if(d.getAttribute("biotype")!="protein_coding" && (d.getAttribute("stop")-d.getAttribute("start"))>=200){
		txType="long";
	}else if((d.getAttribute("stop")-d.getAttribute("start"))<200){
		txType="small";
	}
	if(txSvg==null){
		if(txLevel==null){
			txLevel=vis.append("div").attr("id","txLevel");
			txLevel.append("span").attr("class","settings").attr("id","settingstxLevel").style("position","relative").style("top","-43px").style("left","932px").append("img").attr("src","web/images/icons/gear.png");
		}
		txXScale = d3.scale.linear().
  			domain([d.getAttribute("extStart"),d.getAttribute("extStop")]). // your data minimum and maximum
  			range([0, width]); // the pixels to map to, e.g., the width of the diagram.
 		txXAxis = d3.svg.axis()
			.scale(txXScale)
			.orient("top")
			.ticks(6)
			.tickSize(8)
			.tickPadding(10);
		txScale = txLevel.append("svg:svg")
			.attr("width", width)
			.attr("height", 60)
			.attr("class", "txscale")
			.attr("pointer-events", "all")
			.on("mousedown", mTxdown)
			.style("cursor", "ew-resize")
			.style("opacity", 0);
		txSvg = txLevel.append("svg:svg")
			.attr("width", width)
			.attr("height", 800)
			.attr("class", "txtrack")
			.attr("id","txsvg1")
			.attr("pointer-events", "all")
			.on("mousedown", mTxPandown)
			.style("cursor", "move")
			.style("opacity", 0);
		txScale.append("g")
      		.attr("class", "tr x axis")
      		.attr("transform", "translate(0,55)")
      		.call(txXAxis);
		var closeBtn=txScale.append("g")
			.attr("class","close")
			.attr("transform", "translate(944,0)")
			.attr("cursor","default")
			.on("mouseover", function(d) { 
				d3.select(this).select("rect").style("fill","#789abd");
            })
			.on("mouseout", function(d) {  
			  	d3.select(this).select("rect").style("fill","#98badd");
        	})
			.on("mousedown", function(d) {
				d3.select(".txscale").remove();
				d3.select(".txtrack").remove();
				$('#tblGenes_filter input').val("").trigger(e);
				txSvg=null;
			});
			closeBtn.append("rect")
				.attr("rx",3)
				.attr("ry",3)
    			.attr("height",16)
				.attr("width",16)
				.attr("fill","#98badd")
				.attr("stroke","#789abd")
				.attr("stroke-width",1);
				//.attr("fill",function(d){return d3.rgb("#98badd");});
			closeBtn.append("line")
					.attr("x1",3)
					.attr("x2",13)
					.attr("y1",3)
					.attr("y2",13)
					.attr("stroke","white")
					.attr("stroke-width",2);
			closeBtn.append("line")
					.attr("x1",13)
					.attr("x2",3)
					.attr("y1",3)
					.attr("y2",13)
					.attr("stroke","white")
					.attr("stroke-width",2);
	  
		d3.select(".tr.x.axis").append("text").text(d.getAttribute("ID")).attr("x", ((width-(margin*2))/2)).attr("y",-40).attr("class","axisLbl");
	}else{
		txScale.transition()        
				.duration(300)      
				.style("opacity", 0);
		txSvg.transition()        
				.duration(300)      
				.style("opacity", 0);
		txXScale.domain([d.getAttribute("extStart"),d.getAttribute("extStop")]);
		txScale.select(".x.axis").call(txXAxis);
		d3.select(".axisLbl").text(d.getAttribute("ID")).attr("x", ((width-(margin*2))/2)).attr("y",-40);
	}
	txMin=d.getAttribute("extStart");
	txMax=d.getAttribute("extStop");
	var txList=getAllChildrenByName(getFirstChildByName(d,"TranscriptList"),"Transcript");
	
	txSvg.attr("height", (1+txList.length)*15);
	console.log(txList);
	txSvg.selectAll(".trx").remove();
	var tx=txSvg.selectAll(".trx")
   			.data(txList,key)
			.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";});
			
  	tx.enter().append("g")
			.attr("class","trx")
			//.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
			.attr("transform",function(d,i){ return "translate(0,"+i*15+")";})
			.attr("id",function(d){return d.getAttribute("ID");})
			.attr("pointer-events", "all")
			.style("cursor", "pointer")
			.on("mouseover", function(d) { 
						d3.select(this).selectAll("line").style("stroke","green");
						d3.select(this).selectAll("rect").style("fill","green");
            			tt.transition()        
							.duration(200)      
							.style("opacity", .95);      
						tt.html(createToolTipTx(d))  
							.style("left", (d3.event.pageX-halfWindowWidth) + "px")     
							.style("top", (d3.event.pageY +5) + "px");  
            	})
			.on("mouseout", function(d) {
					d3.select(this).selectAll("line").style("stroke",colorTx);
					d3.select(this).selectAll("rect").style("fill",colorTx);  
					//d3.select(this).style("fill",color);
					tt.transition()
						 .delay(500)       
						.duration(200)      
						.style("opacity", 0);  
        		})
			.each(drawTrx);
	
	
	 tx.exit().remove();
	 txScale.transition()        
				.duration(300)      
				.style("opacity", 1);
		txSvg.transition()        
				.duration(300)      
				.style("opacity", 1);
	redraw("txLevel");
}

function redrawTrx(){
	var txG=txSvg.selectAll("g");
	
	txG//.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
		.each(function(d,i){
		exList=getAllChildrenByName(getFirstChildByName(d,"exonList"),"exon");
		//console.log("redraw"+i);
		//console.log(exList);
		for(var m=0;m<exList.length;m++){
			d3.select("g#"+d.getAttribute("ID")+" rect#Ex"+exList[m].getAttribute("ID"))
				.attr("x",function(d){ return txXScale(exList[m].getAttribute("start")); })
				.attr("width",function(d){ return txXScale(exList[m].getAttribute("stop")) - txXScale(exList[m].getAttribute("start")); });
			if(m>0){
				d3.select("g#"+d.getAttribute("ID")+" line#Int"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID"))
					.attr("x1",function(d){ return txXScale(exList[m-1].getAttribute("stop")); })
					.attr("x2",function(d){ return txXScale(exList[m].getAttribute("start")); })
			}
		}
	});
}

