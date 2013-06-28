

registerKeyboardHandler = function(callback) {
  var callback = callback;
  d3.select(window).on("keydown", callback);  
};




function key(d) {return d.getAttribute("ID")};
function keyName(d) {return d.getAttribute("name")};

/*
*	Provides functionality to completely setup an SVG Genome Image with scales, tracks, settings menu
*	adds events to compontents to make them responsive.
*/
function GenomeSVG(div,imageWidth,minCoord,maxCoord,levelNumber){
	//Variables
	//this.yArr=new Array();
	//this.width=960;
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

	this.scale = null;
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
	
	  d3.select('html')
      .on("mousemove", this.mmove)
	  .on("mouseup", this.mup);

	this.addTrack=function (track,density){
		var newTrack=null;
		if(track=="snp"){
			d3.xml("tmpData/regionData/"+folderName+"/snp.xml",function (d){
				var snp=d.documentElement.getElementsByTagName("Snp");
				//console.log(snp);
				this.setupSNP(snp,density);
			});
			//setupSNP(level,density);
		}else if(track=="qtl"){
			d3.xml("tmpData/regionData/"+folderName+"/qtl.xml",function (d){
				var qtl=d.documentElement.getElementsByTagName("QTL");
				//console.log(qtl);
				this.setupQTL(qtl);
			});
		}else if(track=="coding"){
			d3.xml("tmpData/regionData/"+folderName+"/coding.xml",function (d){
			var data=d.documentElement.getElementsByTagName("Gene");
			newTrack=new GeneTrack(this,data,track,"Protein Coding / PolyA+");
		});
		}else if(track=="noncoding"){
			d3.xml("tmpData/regionData/"+folderName+"/noncoding.xml",function (d){
			var data=d.documentElement.getElementsByTagName("Gene");
			//console.log(data);
			setupGeneTrack(data,track,"Long Non-Coding / Non-PolyA+");
			});
		}else if(track=="smallnc"){
			d3.xml("tmpData/regionData/"+folderName+"/smallnc.xml",function (d){
			var data=d.documentElement.getElementsByTagName("smnc");
			//console.log(data);
			setupGeneTrack(data,track,"Small RNA (<200 bp)");
			});
		}else if(track=="probe"){
			d3.xml("tmpData/regionData/"+folderName+"/probe.xml",function (d){
				var probe=d.documentElement.getElementsByTagName("probe");
				console.log(probe);
				setupProbeset(probe,levelDiv,level,levelScale,density);
			});
		}

		if(newTrack!=null){
			this.trackList[this.trackCount]=this.newTrack;
			this.trackCount++;
		}
	
	}

	this.removeTrack=function (track,level){
		d3.select("#"+level+track).remove();
	}

	this.changeTrackHeight = function (level,val){
		//console.log("change track");
		//console.log(level);
		//console.log(val);
		if(val>0){
			d3.select("#"+level+"Scroll").style("max-height",val+"px");
		}else{
			d3.select("#"+level+"Scroll").style("max-height","none");
		}
	}
	//Tool Tips

	this.createToolTip=function (d){
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
	}

	this.createToolTipTx=function (d){
		var tooltip="";
		tooltip="ID: "+d.getAttribute("ID")+"<BR>Location:"+d.getAttribute("chromosome")+":"+d.getAttribute("start")+"-"+d.getAttribute("stop")+"<BR>Strand:"+d.getAttribute("strand");
		if(new String(d.getAttribute("ID")).indexOf("ENS")==-1){
				var annot=getFirstChildByName(getFirstChildByName(d,"annotationList"),"annotation");
				if(annot!=null){
					tooltip+="<BR>Matching: "+annot.getAttribute("reason");
				}
		}
		return tooltip;
	}


	this.createToolTipSNP=function(d){
		var tooltip="";
		tooltip="Type: "+d.getAttribute("type")+"<BR>Strain: "+d.getAttribute("strain")+"<BR>Sequence: "+d.getAttribute("refSeq")+"->"+d.getAttribute("strainSeq")+"<BR>Location: "+d.getAttribute("chromosome")+":"+d.getAttribute("start")+"-"+d.getAttribute("stop");
		return tooltip;
	}

	this.createToolTipQTL=function (d){
		var tooltip="";
		tooltip="Name: "+d.getAttribute("name")+"<BR>Location: "+d.getAttribute("chromosome")+":"+d.getAttribute("start")+"-"+d.getAttribute("stop")+"<BR>Trait:<BR>"+d.getAttribute("trait")+"<BR><BR>Phenotype:<BR>"+d.getAttribute("phenotype")+"<BR><BR>Candidate Genes:<BR>"+d.getAttribute("candidate");
		return tooltip;
	}


	//Colors
	this.color=function(d){
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
	}

	this.colorTx = function(d){
		var color=d3.rgb("#000000");
		if(txType=="protein"){
			if((new String(d.getAttribute("ID"))).indexOf("ENS")>-1){
				color=d3.rgb("#DFC184");
			}else{
				color=d3.rgb("#7EB5D6");
			}
		}else if(txType=="long"){
			if((new String(d.getAttribute("ID"))).indexOf("ENS")>-1){
				color=d3.rgb("#B58AA5");
			}else{
				color=d3.rgb("#CECFCE");
			}
		}else if(txType=="small"){
			if((new String(d.getAttribute("ID"))).indexOf("ENS")>-1){
				color=d3.rgb("#FFCC00");
			}else{
				color=d3.rgb("#99CC99");
			}
		}
		return color;
	}

	this.colorSNP = function(d){
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
	}

	this.colorProbe = function (d){
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
	}

	/*this.colorStroke = function (d){
		var colorRet="black";
		if(xScale(d.getAttribute("stop"))-xScale(d.getAttribute("start"))<3){
			colorRet=color(d);
		}
		return colorRet;
	}*/

	//Utility Functions
	

	this.calcY = function (start,end){
		var tmpY=-299999999;
		var found=false;
		for (var iy=0;iy<yArr.length&&!found;iy++){
				if((yArr[iy]+10)<xScale(start)){
					found=true;
					tmpY=(iy+1)*15;
					if(xScale(end)>yArr[iy]){
						yArr[iy]=xScale(end);
					}
				}
		}
		return tmpY;
	}

	this.calcYTrack = function (start,end,tmpYArr,density,i,spacing){
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
	}

	this.mdown=function () {
        var p = d3.mouse(vis[0][0]);
        this.downx = this.xScale.invert(p[0]);
        this.downscalex = this.xScale;
	}

	
	this.mPandown=function () {
	        var p = d3.mouse(vis[0][0]);
	        this.downPanx = p[0];
	        this.downscalex = this.xScale;
	}


	this.mup=function () {
	        this.downx = Math.NaN;
			this.downPanx = Math.NaN;
	}
	
	

}
GenomeSVG.prototype.getAttr=function (attr){return this[attr];};



function Track(genomeSvg,data,trackClass,label){
	console.log(genomeSvg);
	this.genomeSvg=genomeSvg;
	this.data=data;
	this.label=label;
	this.yArr=new Array();
	this.trackClass=trackClass;
	this.topLevel=this.genomeSvg.getAttr('topLevel');
	this.xScale=this.genomeSvg.getAttr('xScale');
	for(var j=0;j<100;j++){
			this.yArr[j]=-299999999;
	}
	this.svg=d3.select("#Level"+this.genomeSvg.getAttr('levelNumber')+this.trackClass);
	if(this.svg[0][0]==null){
			var dragDiv=this.topLevel.append("li");
			this.svg = dragDiv.append("svg:svg")
			.attr("width", this.genomeSvg.getAttr('width'))
			.attr("height", 800)
			.attr("class", "track draggable")
			.attr("id","Level"+this.genomeSvg.getAttr('levelNumber')+trackclass)
			.attr("pointer-events", "all")
			.style("cursor", "move")
			.on("mousedown", this.genomeSvg.getAttr('mPandown'));
			this.svg.append("text").text(this.label).attr("x",this.genomeSvg.get('width')/2-20).attr("y",12);
	}
	
	this.colorStroke = function (d){
		var colorRet="black";
		if(xScale(d.getAttribute("stop"))-xScale(d.getAttribute("start"))<3){
			colorRet=color(d);
		}
		return colorRet;
	}
}


function GeneTrack(genomeSvg,data,trackClass,label){
	console.log("geneTrack");
	console.log(genomeSvg);
	var track= new Track(genomeSvg,data,trackClass,label);
	console.log(track.svg);
		
	//update
	var gene=track.svg.selectAll(".gene")
	   			.data(data,key)
				.attr("transform",function(d){ return "translate("+this.xScale(d.getAttribute("start"))+","+this.calcY(d.getAttribute("start"),d.getAttribute("stop"))+")";});
		//add new
		gene.enter().append("g")
				.attr("class","gene")
				.attr("transform",function(d){ return "translate("+this.xScale(d.getAttribute("start"))+","+this.calcY(d.getAttribute("start"),d.getAttribute("stop"))+")";})
				.append("rect")
	    	.attr("height",10)
			.attr("rx",1)
			.attr("ry",1)
			.attr("width",function(d) { return this.xScale(d.getAttribute("stop"))-this.xScale(d.getAttribute("start")); })
			.attr("title",function (d){return d.getAttribute("ID");})
			.attr("stroke",this.colorStroke)
			.attr("stroke-width","1")
			.attr("id",function(d){return d.getAttribute("ID");})
		//.attr("title",function(d){return d.html;})
			//.style("fill",function(d) { var color=d3.rgb("#000000"); if((new String(d.getAttribute("ID"))).indexOf("ENS")>-1){color=d3.rgb("#DFC184");}else{color=d3.rgb("#7EB5D6");} return color;})
			.style("fill",this.color)
			.style("cursor", "pointer")
			.on("click", setupTranscripts)
			.on("dblclick", zoomToGene)
			.on("mouseover", function(d) { 
				d3.select(this).style("fill","green");
	            tt.transition()        
	                .duration(200)      
	                .style("opacity", .95);      
	            tt.html(createToolTip(d))  
	                .style("left", (d3.event.pageX-halfWindowWidth) + "px")     
	                .style("top", (d3.event.pageY + 20) + "px");  
	            })
			.on("mouseout", function(d) {  
				d3.select(this).style("fill",color);
	            tt.transition()
					 .delay(500)       
	                .duration(200)      
	                .style("opacity", 0);  
	        });
			
		//var rect=svg.selectAll("rect").attr("width",function(d) { return xScale(d.getAttribute("stop"))-xScale(d.getAttribute("start")); });
		//rect.attr("stroke",colorStroke);
		
		gene.exit().remove();
		
		var tmpYMax=-1;
		for(var j=0;j<100&&tmpYMax==-1;j++){
			if(yArr[j]==-299999999){
				svg.attr("height", (j+1)*15);
				tmpYMax=j;
			}
		}
		
	this.calcY = function (start,end){
		var tmpY=-299999999;
		var found=false;
		for (var iy=0;iy<yArr.length&&!found;iy++){
				if((yArr[iy]+10)<xScale(start)){
					found=true;
					tmpY=(iy+1)*15;
					if(xScale(end)>yArr[iy]){
						yArr[iy]=xScale(end);
					}
				}
		}
		return tmpY;
	}
	
	this.color=function(d){
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
	}

	this.redrawGene=function(trackClass){
		//console.log("#topLevel"+trackClass);
		var svg=d3.select("#topLevel"+trackClass);
		if(svg[0][0]!=null){
			//console.log(svg);
			for(var j=0;j<100;j++){
				yArr[j]=-299999999;
			}
			d3.select("#topLevel"+trackClass).selectAll("g.gene").attr("transform",function (d){
																   var st=xScale(d.getAttribute("start"));
																	return "translate("+st+","+calcY(d.getAttribute("start"),d.getAttribute("stop"))+")";
																});
			d3.select("#topLevel"+trackClass).selectAll("g.gene rect").attr("width",function(d) {
									   var wX=1;
									   if(xScale(d.getAttribute("stop"))-xScale(d.getAttribute("start"))>1){
										   wX=xScale(d.getAttribute("stop"))-xScale(d.getAttribute("start"));
									   }
									   return wX;
									   }
										)
						.attr("stroke",colorStroke);
			var tmpYMax=-1;
			for(var j=0;j<100&&tmpYMax==-1;j++){
				if(yArr[j]==-299999999){
					d3.select("#topLevel"+trackClass).attr("height", (j+1)*15);
					tmpYMax=j;
				}
			}
		}
	}
}




//Helpers
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