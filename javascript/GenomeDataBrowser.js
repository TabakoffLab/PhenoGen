//Variables

var yArr=new Array();
var width=960;
var margin=0;
var halfWindowWidth = 0;
var mw=width-margin;
var mh=400;

//vars for manipulation
var downx = Math.NaN;
var downscalex;
var downPanx=Math.NaN;
var txdownx = Math.NaN;
var txdownscalex;
var txdownPanx=Math.NaN;

var chrMax=290000000;
var txMin=1;
var txMax=chrMax;

registerKeyboardHandler = function(callback) {
  var callback = callback;
  d3.select(window).on("keydown", callback);  
};

var y=0;

var xScale = null;
var xAxis = null;
var vis=null;
var topLevel=null;
var txLevel=null;
var scale = null;
var svg = null;
	
var txScale=null;	
var txSvg=null;
var txXAxis=null;
var txXScale=null;
var txType=null;
var txList=null;
	
var tt=null;

	



function setupGenomeDataBrowser(div,imageWidth){
	width=imageWidth;
	mw=width-margin;
	if($(window).width()>1000){
		halfWindowWidth=($(window).width()-1000)/2;
	}
	vis=d3.select(div);
	var topDiv=vis.append("div").attr("id","topLevel").style("max-height","350px").style("overflow","auto");
	
	
	xScale = d3.scale.linear().
  		domain([minCoord, maxCoord]). // your data minimum and maximum
  		range([0, width]);
		
	xAxis = d3.svg.axis()
    .scale(xScale)
    .orient("top")
	.ticks(6)
	.tickSize(8)
    .tickPadding(10);
	
	scale = topDiv.append("svg:svg")
    .attr("width", width)
    .attr("height", 60)
	.attr("pointer-events", "all")
    .attr("class", "scale")
	.attr("pointer-events", "all")
	.on("mousedown", mdown)
	.style("cursor", "ew-resize");
	
	scale.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0,55)")
      .call(xAxis);
	  
	d3.select(".x.axis").append("text").text(chr).attr("x", ((width-(margin*2))/2)).attr("y",-40);
	topLevel=topDiv.append("ul").attr("class","sortable");
	
	
	tt=d3.select("body").append("div")   
    .attr("class", "testToolTip")               
    .style("opacity", 0);
	
	  d3.select('html')
      .on("mousemove", mmove)
	  .on("mouseup", mup);

}

function addTrack(track,level,density){
	var levelDiv=d3.select("#"+level);
	if(level=="topLevel"){
		levelDiv=levelDiv.select("ul").append("li");
	}
	if(track=="snp"){
		d3.xml("tmpData/regionData/"+folderName+"/snp.xml",function (d){
			var snp=d.documentElement.getElementsByTagName("Snp");
			console.log(snp);
			setupSNP(snp,levelDiv,density)
		});
		//setupSNP(level,density);
	}else if(track=="qtl"){
		d3.xml("tmpData/regionData/"+folderName+"/qtl.xml",function (d){
			var qtl=d.documentElement.getElementsByTagName("QTL");
			console.log(qtl);
			setupQTL(qtl,levelDiv)
		});
	}else if(track=="coding"){
		d3.xml("tmpData/regionData/"+folderName+"/coding.xml",function (d){
		var data=d.documentElement.getElementsByTagName("Gene");
		console.log(data);
		setupGeneTrack(data,track,"Protein Coding / PolyA+");
	});
	}else if(track=="noncoding"){
		d3.xml("tmpData/regionData/"+folderName+"/noncoding.xml",function (d){
		var data=d.documentElement.getElementsByTagName("Gene");
		console.log(data);
		setupGeneTrack(data,track,"Long Non-Coding / Non-PolyA+");
		});
	}else if(track=="smallnc"){
		d3.xml("tmpData/regionData/"+folderName+"/smallnc.xml",function (d){
		var data=d.documentElement.getElementsByTagName("smnc");
		console.log(data);
		setupGeneTrack(data,track,"Small RNA (<200 bp)");
		});
	}
	
}

function removeTrack(track,level){
	d3.select("#"+level+track).remove();
}









	
	/*d3.json("web/GeneCentric/tracks/geneTrack.jsp?folderName="+folderName,function (d){
		data=d;
		drawGenes();
	});*/
	
	


//Tool Tips

function createToolTip(d){
	var tooltip="";
	var txListStr="";
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
	return tooltip;
}

function createToolTipTx(d){
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


function createToolTipSNP(d){
	var tooltip="";
	tooltip="Type: "+d.getAttribute("type")+"<BR>Strain: "+d.getAttribute("strain")+"<BR>Sequence: "+d.getAttribute("refSeq")+"->"+d.getAttribute("strainSeq")+"<BR>Location: "+d.getAttribute("chromosome")+":"+d.getAttribute("start")+"-"+d.getAttribute("stop");
	return tooltip;
}

function createToolTipQTL(d){
	var tooltip="";
	tooltip="Name: "+d.getAttribute("name")+"<BR>Location: "+d.getAttribute("chromosome")+":"+d.getAttribute("start")+"-"+d.getAttribute("stop")+"<BR>Trait:<BR>"+d.getAttribute("trait")+"<BR><BR>Phenotype:<BR>"+d.getAttribute("phenotype")+"<BR><BR>Candidate Genes:<BR>"+d.getAttribute("candidate");
	return tooltip;
}


//Colors
function color(d){
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

function colorTx(d){
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

function colorSNP(d){
	var color=d3.rgb("#000000");
	if(d.getAttribute("type")=="SNP"){
		if(d.getAttribute("strain")=="BNLX"){
			color=d3.rgb(0,0,255);
		}else if(d.getAttribute("strain")=="SHRH"){
			color=d3.rgb(255,0,0);
		}else{
			color=d3.rgd(100,100,100);
		}
	}else{
		if(d.getAttribute("strain")=="BNLX"){
			color=d3.rgb(0,0,150);
		}else if(d.getAttribute("strain")=="SHRH"){
			color=d3.rgb(150,0,0);
		}else{
			color=d3.rgd(50,50,50);
		}
	}
	return color;
}

function colorStroke(d){
	var colorRet="black";
	if(xScale(d.getAttribute("stop"))-xScale(d.getAttribute("start"))<3){
		colorRet=color(d);
	}
	return colorRet;
}

//Utility Functions
function key(d) {return d.getAttribute("ID")};
function keyName(d) {return d.getAttribute("name")};

function calcY(start,end){
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

function calcYTrack(start,end,tmpYArr,density,i,spacing){
	var tmpY=-299999999;
	var found=false;
	if(density==1){
		tmpY=15;
	}else if(density==2){
		tmpY=(i+1)*15;
	}else{
		for (var iy=0;iy<tmpYArr.length&&!found;iy++){
				if((tmpYArr[iy]+spacing)<xScale(start)){
					found=true;
					tmpY=(iy+1)*15;
					if(xScale(end)>tmpYArr[iy]){
						tmpYArr[iy]=xScale(end);
					}
				}
		}
	}
	return tmpY;
}

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


//Drawing Functions
function setupGeneTrack(data,trackclass,label){
	var svg=d3.select("#topLevel"+trackclass);
	console.log(svg);
	if(svg[0][0]==null){
		var dragDiv=topLevel.append("li");
		svg = dragDiv.append("svg:svg")
		.attr("width", width)
		.attr("height", 800)
		.attr("class", "track draggable")
		.attr("id","topLevel"+trackclass)
		.attr("pointer-events", "all")
		.style("cursor", "move")
		.on("mousedown", mPandown);
		svg.append("text").text(label).attr("x",width/2-20).attr("y",12);
	}
	
	for(var j=0;j<100;j++){
		yArr[j]=-299999999;
	}
	//update
	var gene=svg.selectAll(".gene")
   			.data(data,key)
			.attr("transform",function(d){ return "translate("+xScale(d.getAttribute("start"))+","+calcY(d.getAttribute("start"),d.getAttribute("stop"))+")";});
			
  	
			
	//add new
	gene.enter().append("g")
			.attr("class","gene")
			.attr("transform",function(d){ return "translate("+xScale(d.getAttribute("start"))+","+calcY(d.getAttribute("start"),d.getAttribute("stop"))+")";})
			.append("rect")
    	.attr("height",10)
		.attr("rx",1)
		.attr("ry",1)
		.attr("width",function(d) { return xScale(d.getAttribute("stop"))-xScale(d.getAttribute("start")); })
		.attr("title",function (d){return d.getAttribute("ID");})
		.attr("stroke",colorStroke)
		.attr("stroke-width","1")
		.attr("id",function(d){return d.getAttribute("ID");})
	//.attr("title",function(d){return d.html;})
		//.style("fill",function(d) { var color=d3.rgb("#000000"); if((new String(d.getAttribute("ID"))).indexOf("ENS")>-1){color=d3.rgb("#DFC184");}else{color=d3.rgb("#7EB5D6");} return color;})
		.style("fill",color)
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
	
}

function redrawGene(trackClass){
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

function setupSNP(snp,level,density){

	snpSvg = level.append("svg:svg")
			.attr("width", width)
			.attr("height", 100)
			.attr("id",level.attr("id")+"snp")
			.attr("class","track draggable")
			.attr("pointer-events", "all")
			.on("mousedown", mPandown)
			.style("cursor", "move");
	snpSvg.append("text").text("SNPs").attr("x",width/2-20).attr("y",12);
	var tmpYArr=new Array();
	for(var j=0;j<100;j++){
		tmpYArr[j]=-299999999;
	}
	
	//update
	var snps=snpSvg.selectAll(".snp")
   			.data(snp,key)
			.attr("transform",function(d,i){ return "translate("+xScale(d.getAttribute("start"))+","+calcYTrack(d.getAttribute("start"),d.getAttribute("stop"),tmpYArr,density,i,2)+")";});
			
  	
			
	//add new
	snps.enter().append("g")
			.attr("class","snp")
			.attr("transform",function(d,i){ return "translate("+xScale(d.getAttribute("start"))+","+calcYTrack(d.getAttribute("start"),d.getAttribute("stop"),tmpYArr,density,i,2)+")";})
			.append("rect")
    	.attr("height",10)
		.attr("rx",1)
		.attr("ry",1)
		.attr("width",function(d) {
							   var wX=1;
							   if(xScale(d.getAttribute("stop"))-xScale(d.getAttribute("start"))>1){
								   wX=xScale(d.getAttribute("stop"))-xScale(d.getAttribute("start"));
							   }
							   return wX;
							   })
		.attr("id",function(d){return d.getAttribute("ID");})
		.style("fill",colorSNP)
		.style("cursor", "pointer")
		//.on("mousedown", setupTranscripts)
		.on("mouseover", function(d) { 
			d3.select(this).style("fill","green");
            tt.transition()        
                .duration(200)      
                .style("opacity", .95);      
            tt.html(createToolTipSNP(d))  
                .style("left", (d3.event.pageX-halfWindowWidth) + "px")     
                .style("top", (d3.event.pageY + 20) + "px");  
            })
		.on("mouseout", function(d) {  
			d3.select(this).style("fill",colorSNP);
            tt.transition()
				 .delay(500)       
                .duration(200)      
                .style("opacity", 0);  
        });
		
	/*var rect=snpSvg.selectAll("rect").attr("width",function(d) { 
															var wX=1;
														   if(xScale(d.getAttribute("stop"))-xScale(d.getAttribute("start"))>1){
															   wX=xScale(d.getAttribute("stop"))-xScale(d.getAttribute("start"));
														   }
														   return wX;
													});*/
	//rect.attr("stroke",colorStroke);
	
	snps.exit().remove();
	if(density==1){
		snpSvg.attr("height", 30);
	}else if(density==2){
		snpSvg.attr("height", (snps.length+1)*15);
	}else if(density==3){
		var tmpYMax=-1;
		for(var j=0;j<100&&tmpYMax==-1;j++){
			if(tmpYArr[j]==-299999999){
				snpSvg.attr("height", (j+1)*15);
				tmpYMax=j;
			}
		}
	}
}



function redrawSnp(level){
	var snpSvg=d3.select("#"+level+"snp");
	var density=$("#snpSelect").val();
	
	var tmpYArr=new Array();
	for(var j=0;j<100;j++){
		tmpYArr[j]=-299999999;
	}
	
	d3.select("#"+level+"snp").selectAll("g.snp").attr("transform",function (d,i){
														   var st=xScale(d.getAttribute("start"));
															return "translate("+st+","+calcYTrack(d.getAttribute("start"),d.getAttribute("stop"),tmpYArr,density,i,2)+")";
														});
	d3.select("#"+level+"snp").selectAll("g.snp rect").attr("width",function(d) {
							   var wX=1;
							   if(xScale(d.getAttribute("stop"))-xScale(d.getAttribute("start"))>1){
								   wX=xScale(d.getAttribute("stop"))-xScale(d.getAttribute("start"));
							   }
							   return wX;
							   }
								);
	if(density==1){
		snpSvg.attr("height", 30);
	}else if(density==2){
		snpSvg.attr("height", (snps.length+1)*15);
	}else if(density==3){
		var tmpYMax=-1;
		for(var j=0;j<100&&tmpYMax==-1;j++){
			if(tmpYArr[j]==-299999999){
				snpSvg.attr("height", (j+1)*15);
				tmpYMax=j;
			}
		}
	}
}

function setupQTL(qtl,level,density){
	console.log(qtl);
	qtlSvg = level.append("svg:svg")
			.attr("width", width)
			.attr("height", 100)
			.attr("id",level.attr("id")+"qtl")
			.attr("class","track draggable")
			.attr("pointer-events", "all")
			.on("mousedown", mPandown)
			.style("cursor", "move");
	qtlSvg.append("text").text("bQTLs").attr("x",width/2-20).attr("y",12);
	var tmpYArr=new Array();
	
	//update
	var qtls=qtlSvg.selectAll(".qtl")
   			.data(qtl,key)
			.attr("transform",function(d,i){ return "translate("+xScale(d.getAttribute("start"))+","+(i+1)*15+")";});
			
  	
			
	//add new
	qtls.enter().append("g")
			.attr("class","qtl")
			.attr("transform",function(d,i){ return "translate("+xScale(d.getAttribute("start"))+","+(i+1)*15+")";})
			.append("rect")
    	.attr("height",10)
		.attr("rx",1)
		.attr("ry",1)
		.attr("width",function(d) {
							   var wX=1;
							   if(xScale(d.getAttribute("stop"))-xScale(d.getAttribute("start"))>1){
								   wX=xScale(d.getAttribute("stop"))-xScale(d.getAttribute("start"));
							   }
							   return wX;
							   })
		.attr("id",function(d){return d.getAttribute("Name");})
		.style("fill","blue")
		.style("cursor", "pointer")
		//.on("mousedown", setupTranscripts)
		.on("mouseover", function(d) { 
			d3.select(this).style("fill","green");
            tt.transition()        
                .duration(200)      
                .style("opacity", .95);      
            tt.html(createToolTipQTL(d))  
                .style("left", (d3.event.pageX-halfWindowWidth) + "px")     
                .style("top", (d3.event.pageY + 20) + "px");  
            })
		.on("mouseout", function(d) {  
			d3.select(this).style("fill","blue");
            tt.transition()
				 .delay(500)       
                .duration(200)      
                .style("opacity", 0);  
        });
		
	/*var rect=snpSvg.selectAll("rect").attr("width",function(d) { 
															var wX=1;
														   if(xScale(d.getAttribute("stop"))-xScale(d.getAttribute("start"))>1){
															   wX=xScale(d.getAttribute("stop"))-xScale(d.getAttribute("start"));
														   }
														   return wX;
													});*/
	//rect.attr("stroke",colorStroke);
	
	qtls.exit().remove();
	
	qtlSvg.attr("height", (qtl.length+1)*15);
	
}



function redrawQTL(level){
	var qtlSvg=d3.select("#"+level+"qtl");
	var density=2;
	
	var tmpYArr=new Array();
	
	var qtls=d3.select("#"+level+"qtl").selectAll("g.qtl").attr("transform",function (d,i){
														   var st=xScale(d.getAttribute("start"));
															return "translate("+st+","+(i+1)*15+")";
														});
	d3.select("#"+level+"qtl").selectAll("g.qtl rect").attr("width",function(d) {
							   var wX=1;
							   if(xScale(d.getAttribute("stop"))-xScale(d.getAttribute("start"))>1){
								   wX=xScale(d.getAttribute("stop"))-xScale(d.getAttribute("start"));
							   }
							   return wX;
							   }
								);
	
}


function redraw(level){
	if(level=="topLevel"){
		redrawGene("coding");
		redrawGene("noncoding");
		redrawGene("smallnc");
		redrawSnp(level);
		redrawQTL(level);
	}else{
		
	}
}


//eventHandler Functions
function mmove(){
        if (!isNaN(downx)) {
          var p = d3.mouse(vis[0][0]), rupx = p[0];
          if (rupx != 0) {
		  		var minx=downscalex.domain()[0];
		  		var maxx= mw * (downx - downscalex.domain()[0]) / rupx + downscalex.domain()[0];
				if(maxx<=chrMax && minx>=1){
            		xScale.domain([minx,maxx]);
					scale.select(".x.axis").call(xAxis);
					redraw("topLevel");
					//drawGenes();
				}
          }
		  //drawGenes();
          //redrawAxis();
        }else if(!isNaN(downPanx)){
			var p = d3.mouse(vis[0][0]), rupx = p[0];
			  if (rupx != 0) {
					var dist=downPanx-rupx;
					var scaleDist=(downscalex.domain()[1]-downscalex.domain()[0])/mw;
					
					var minx=downscalex.domain()[0]+dist*scaleDist;
					var maxx=dist*scaleDist + downscalex.domain()[1];
					if(maxx<=chrMax && minx>=1){
						xScale.domain([minx,maxx]);
						scale.select(".x.axis").call(xAxis);
						redraw("topLevel");
						//drawGenes();
						downPanx=p[0];
					}
				
			  }
		}else if(!isNaN(txdownx)) {
          var p = d3.mouse(vis[0][0]), rupx = p[0];
          if (rupx != 0) {
		  		var minx=txdownscalex.domain()[0];
		  		var maxx= mw * (txdownx - txdownscalex.domain()[0]) / rupx + txdownscalex.domain()[0];
				if(maxx<=txMax && minx>=txMin){
            		txXScale.domain([minx,maxx]);
					txScale.select(".x.axis").call(txXAxis);
					redrawTrx();
				}
			}
         }else if(!isNaN(txdownPanx)){
			var p = d3.mouse(vis[0][0]), rupx = p[0];
			  if (rupx != 0) {
					var dist=txdownPanx-rupx;
					var scaleDist=(txdownscalex.domain()[1]-txdownscalex.domain()[0])/mw;
					
					var minx=txdownscalex.domain()[0]+dist*scaleDist;
					var maxx=dist*scaleDist + txdownscalex.domain()[1];
					if(maxx<=txMax && minx>=txMin){
						txXScale.domain([minx,maxx]);
						txScale.select(".x.axis").call(txXAxis);
						redrawTrx();
						txdownPanx=p[0];
					}
				
			  }
		}
		  //drawGenes();
          //redrawAxis();
        
}
function mdown() {
        var p = d3.mouse(vis[0][0]);
        downx = xScale.invert(p[0]);
        downscalex = xScale;
}

function mTxdown() {
        var p = d3.mouse(vis[0][0]);
        txdownx = txXScale.invert(p[0]);
        txdownscalex = txXScale;
}

function mPandown() {
        var p = d3.mouse(vis[0][0]);
        downPanx = p[0];
        downscalex = xScale;
}

function mTxPandown() {
        var p = d3.mouse(vis[0][0]);
        txdownPanx = p[0];
        txdownscalex = txXScale;
}


function mup() {
        downx = Math.NaN;
		txdownx = Math.NaN;
		downPanx = Math.NaN;
		txdownPanx = Math.NaN;
}


function zoomToGene(d){
	
	var len=d.getAttribute("stop")-d.getAttribute("start");
	len=len*0.25;
	var minx=d.getAttribute("start")-len;
	var maxx=(d.getAttribute("stop")*1)+len;
	//console.log(minx+"-"+maxx)
	if(maxx<=chrMax && minx>=1){
            		xScale.domain([minx,maxx]);
					scale.select(".x.axis").call(xAxis);
					redraw("topLevel");
	}
}


