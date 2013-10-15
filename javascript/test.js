//global varaiable to store a list of GenomeSVG images representing each level.
var svgList=new Array();
var processAjax=0;
var ajaxList=new Array();
var selectedGeneSymbol="";
var selectedID="";
var viewName="genome";

var mmVer="mm9 Strain:";
var rnVer="rn5 Strain:BN";
var siteVer="PhenoGen v2.10:12/1/2013";

//setup event handlers

$(document).on("click",".closeBtn",function(){
					var setting=new String($(this).attr("id"));
					setting=setting.substr(6);
					if($("."+setting).is(":visible")){
						$("."+setting).fadeOut("fast");
					}
					return false;
				});

$(document).on("click",".settings",function(){
					var setting=$(this).attr("id");
					if(!$("."+setting).is(":visible")){
						var p=$(this).position();
						$("."+setting).css("top",p.top-3).css("left",p.left-277);
						$("."+setting).fadeIn("fast");
						//console.log("after fade in");
					}else{
						$("."+setting).fadeOut("fast");
					}
					return false;
				});
			
$(document).on("change","input[name='trackcbx']",function(){
	 			var type=$(this).val();
				var typeStr=new String(type);
				var idStr=new String($(this).attr("id"));
				var prefix=idStr.substr(0,idStr.length-3);
				var level=typeStr.substr(typeStr.length-1);
				if($(this).is(":checked")){
					svgList[level].addTrack(prefix,$("#"+prefix+"Dense"+level+"Select").val());
					//addTrack(prefix, type,$("#"+prefix+"Select").val());
				}else{
					removeTrack(level,prefix);
				}
	 		});
$(document).on("change","select[name='trackSelect']",function(){
				var idStr=new String($(this).attr("id"));
				var level=idStr.substr(idStr.length-7,1);
				if(idStr.indexOf("Dense")>0){
					svgList[level].redraw();
				}else if(idStr.indexOf("snp")==0){
					svgList[level].updateData();
				}
				
	 		});

$(document).on("change","select[name='displaySelect']", function(){
	 			changeTrackHeight($(this).attr("id"),$(this).val());
	 		});



//Setup some global functions
d3.select('html')
      .on("mousemove", mmove)
	  .on("mouseup", mup);


function mup() {
	for (var i=0; i<svgList.length; i++){
		if(svgList[i]!=null){
			if(!isNaN(svgList[i].downx)|| !isNaN(svgList[i].downPanx)){
				if(i==0){
					updatePage(svgList[i]);
					DisplayRegionReport();
				}
        		svgList[i].downx = Math.NaN;
				svgList[i].downPanx = Math.NaN;
			}
		}
	}
}
function mmove(){
	for (var i=0; i<svgList.length; i++){
		if(svgList[i]!=null){
			if (!isNaN(svgList[i].downx)) {
	          var p = d3.mouse(svgList[i].vis[0][0]), rupx = p[0];
	          if (rupx != 0) {
			  		var minx=Math.round(svgList[i].downscalex.domain()[0]);
			  		var maxx=Math.round(svgList[i].mw * (svgList[i].downx - svgList[i].downscalex.domain()[0]) / rupx + svgList[i].downscalex.domain()[0]);

					if(maxx<=svgList[i].xMax && minx>=svgList[i].xMin){
						if(i==0){
							$('#geneTxt').val(chr+":"+minx+"-"+maxx);
						}
	            		svgList[i].xScale.domain([minx,maxx]);
						svgList[i].scaleSVG.select(".x.axis").call(svgList[i].xAxis);
						//console.log("call redraw"+i);
						svgList[i].redraw();
					}
	          }
	        }else if(!isNaN(svgList[i].downPanx)){
				var p = d3.mouse(svgList[i].vis[0][0]), rupx = p[0];
				  if (rupx != 0) {
						var dist=svgList[i].downPanx-rupx;
						var scaleDist=(svgList[i].downscalex.domain()[1]-svgList[i].downscalex.domain()[0])/svgList[i].mw;
						var minx=Math.round(svgList[i].downscalex.domain()[0]+dist*scaleDist);
						var maxx=Math.round(dist*scaleDist + svgList[i].downscalex.domain()[1]);
						//console.log("before if"+minx+":"+maxx+"  <"+svgList[i].xMax);
						if(maxx<=svgList[i].xMax && minx>=svgList[i].xMin){
							if(i==0){
								$('#geneTxt').val(chr+":"+minx+"-"+maxx);
							}
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
}

function updatePage(topSVG){
	var min=topSVG.xScale.domain()[0];
	var max=topSVG.xScale.domain()[1];
	//console.log("new:"+min+"-"+max);
	if((min<topSVG.prevMinCoord||max>topSVG.prevMaxCoord)&&(min<topSVG.dataMinCoord||max>topSVG.dataMaxCoord)){
		processAjax=1;
		var tmpMin=min;
		var tmpMax=max;
		if(min>=topSVG.dataMinCoord&& max>topSVG.dataMaxCoord){
			tmpMin=topSVG.dataMaxCoord+1;
		}else if(min<topSVG.dataMinCoord && max<=topSVG.dataMaxCoord){
			tmpMax=topSVG.dataMinCoord-1;
		}
		topSVG.setLoading();
		$.ajax({
				url: "web/GeneCentric/updateRegion.jsp",
   				type: 'GET',
				data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,fullminCoord:min,fullmaxCoord:max,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrgansim: organism},
				dataType: 'json',
    			success: function(data2){ 
        			//console.log(data2);
        			topSVG.prevMinCoord=min;
        			topSVG.prevMaxCoord=max;
        			if(min<topSVG.dataMinCoord){
        				topSVG.dataMinCoord=min;
        			}
        			if(max>topSVG.dataMaxCoord){
        				topSVG.dataMaxCoord=max;
        			}
        			folderName=data2.folderName;
        			topSVG.updateData();
        			processAjax=0;
    			},
    			error: function(xhr, status, error) {
        			console.log(error);
    			}
			});
	}
}

function removeTrack(level,track){
	svgList[level].removeTrack(track);
}

function changeTrackHeight(id,val){
	if(val>0){
		var size=val+"px";
		$("#Scroll"+id).css({"max-height":size,"overflow":"auto"});
	}else{
		$("#Scroll"+id).css({"max-height":'',"overflow":"none"});
	}

}

registerKeyboardHandler = function(callback) {
  var callback = callback;
  d3.select(window).on("keydown", callback);  
};

//Helper functions

function getAllChildrenByName(parentNode,name){
	var list=[];
	var listCount=0;
	if(parentNode!=undefined && parentNode.childNodes!=undefined){
		var listInit=parentNode.childNodes;
		for(var k=0;k<listInit.length;k++){
			//console.log(txListInit.item(k).nodeName);
			if(listInit.item(k).nodeName==name){
				list[listCount]=listInit.item(k);
				listCount++;
			}
		}
	}
	return list;
}

function getFirstChildByName(parentNode,name){
	var node=null;
	if(parentNode!=undefined && parentNode.childNodes!=undefined){
		var listInit=parentNode.childNodes;
		var found=false;
		for(var k=0;k<listInit.length&&!found;k++){
			if(listInit.item(k).nodeName==name){
				node=listInit.item(k);
				found=true;
			}
		}
	}
	return node;
}

function getAddMenuDiv(level,type){
	$.ajax({
				url: contextPath + "/web/GeneCentric/settingsMenu.jsp",
   				type: 'GET',
				data: {level: level, organism: organism,type: type},
				dataType: 'html',
    			success: function(data2){
    				$(".settingsLevel"+level).remove();
    				var prev=$("#imageMenu").html();
    				//console.log(prev);
        			$("#imageMenu").html(prev+data2);
        			//console.log($("#imageMenu").html());
    			},
    			error: function(xhr, status, error) {
        			$('#imageMenu').append("<div class=\"settingsLevel"+level+"\">An error occurred generating this menu.  Please try back later.</div>");
    			}
			});
}

function loadSavedConfigTracks(levelInd){
	if($.cookie("state"+viewName)!=null){
		svgList[levelInd].addTrack("coding",3);
    	svgList[levelInd].addTrack("noncoding",3);
    	svgList[levelInd].addTrack("smallnc",3);
	}else{
		svgList[levelInd].addTrack("coding",3);
    	svgList[levelInd].addTrack("noncoding",3);
    	svgList[levelInd].addTrack("smallnc",3);
    	$.cookie("state"+viewName,
    	{
    		trackList:"coding;noncoding;smallnc;"
    	},
    	{ expires: 7 }
    	);
	}
}




//D3 helper functions
function key(d) {return d.getAttribute("ID");};
function keyName(d) {return d.getAttribute("name");};
function keyStart(d) {return d.getAttribute("start");};

//SVG functions
function GenomeSVG(div,imageWidth,minCoord,maxCoord,levelNumber,title,type){
	this.get=function(attr){return this[attr];}.bind(this);
	/*this.addTrack=function(track,density){
		$.ajax({
				url: "web/GeneCentric/getFullPath.jsp",
   				type: 'GET',
   				async: false,
				data: {chromosome: chr,minCoord:this.xScale.domain()[0],maxCoord:this.xScale.domain()[1],panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrgansim: organism},
				dataType: 'json',
    			success: function(data2){ 
        			console.log(data2);
        			folderName=data2.folderName;
        			console.log("foldername:"+folderName);
        			this.addTrackPart2(track,density);
    			}.bind(this),
    			error: function(xhr, status, error) {
        			console.log(error);
    			}
			});
	}.bind(this);*/
	this.addTrack=function (track,density){
		var folderStr=new String(folderName);
		if(folderStr.indexOf("_"+this.xScale.domain()[0]+"_")<0 || folderStr.indexOf("_"+this.xScale.domain()[1]+"_")<0){
			//update folderName because it doesn't match the current range.  This folder should exist, but getFullPath.jsp will call methods to generate if needed
			$.ajax({
					url: "web/GeneCentric/getFullPath.jsp",
	   				type: 'GET',
	   				async: false,
					data: {chromosome: chr,minCoord:this.xScale.domain()[0],maxCoord:this.xScale.domain()[1],panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrgansim: organism},
					dataType: 'json',
	    			success: function(data2){ 
	        			//console.log(data2);
	        			folderName=data2.folderName;
	        			//console.log("foldername:"+folderName);
	        			//this.addTrackPart2(track,density);
	    			}.bind(this),
	    			error: function(xhr, status, error) {
	        			console.log(error);
	    			}
				});
		}
		var newTrack=null;
		var par=this;
		var tmpvis=d3.select("#Level"+this.levelNumber+track);
		if(tmpvis[0][0]==null){
				var dragDiv=this.topLevel.append("li");
				var svg = dragDiv.append("svg:svg")
				.attr("width", this.get('width'))
				.attr("height", 800)
				.attr("class", "track draggable"+this.levelNumber)
				.attr("id","Level"+this.levelNumber+track)
				.attr("pointer-events", "all")
				.style("cursor", "move")
				.on("mousedown", this.panDown);
				//this.svg.append("text").text(this.label).attr("x",this.gsvg.width/2-20).attr("y",12);
				var lblStr=new String("Loading...");
				svg.append("text").text(lblStr).attr("x",this.width/2-(lblStr.length/2)*7.5).attr("y",12).attr("id","trkLbl");
		}
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
		}else if(track.indexOf("snp")==0){
			var include=$("#"+track+this.levelNumber+"Select").val();
			d3.xml("tmpData/regionData/"+folderName+"/"+track+".xml",function (d){
				var snp=d.documentElement.getElementsByTagName("Snp");
				var newTrack=new SNPTrack(par,snp,track,density,include);
				par.addTrackList(newTrack);
			});
			//setupSNP(level,density);
		}else if(track=="qtl"){
			d3.xml("tmpData/regionData/"+folderName+"/qtl.xml",function (d){
				var qtl=d.documentElement.getElementsByTagName("QTL");
				var newTrack=new QTLTrack(par,qtl,track,density);
				par.addTrackList(newTrack);
			});
		}else if(track=="trx"){
			var txList=getAllChildrenByName(getFirstChildByName(this.selectedData,"TranscriptList"),"Transcript");
			var newTrack=new TranscriptTrack(par,txList,track,density);
			par.addTrackList(newTrack);

		}else if(track=="probe"){
			d3.xml("tmpData/regionData/"+folderName+"/probe.xml",function (d){
				var probe=d.documentElement.getElementsByTagName("probe");
				var newTrack=new ProbeTrack(par,probe,track,"Affy Exon 1.0 ST Probe Sets",density);
				par.addTrackList(newTrack);
			});
		}else if(track=="helicos"){
			d3.xml("tmpData/regionData/"+folderName+"/helicos.xml",function (d){
				var data=d.documentElement.getElementsByTagName("Count");
				var newTrack=new HelicosTrack(par,data,track,1);
				par.addTrackList(newTrack);
			});
		}
	}.bind(this);
	this.addTrackList= function (newTrack){
		if(newTrack!=null){
				this.trackList[this.trackCount]=newTrack;
				this.trackCount++;
				DisplayRegionReport();
		}
	}.bind(this);
	this.changeTrackHeight = function (level,val){
			if(val>0){
				d3.select("#"+level+"Scroll").style("max-height",val+"px");
			}else{
				d3.select("#"+level+"Scroll").style("max-height","none");
			}
		}.bind(this);

	this.removeTrack=function (track){
			d3.select("#Level"+this.levelNumber+track).remove();
			for(var l=0;l<this.trackList.length;l++){
				if(this.trackList[l].trackClass==track){
					this.trackList.splice(l,1);
				}
			}
			DisplayRegionReport();
	}.bind(this);

	this.redraw=function (){
		for(var l=0;l<this.trackList.length;l++){
			if(this.trackList[l]!=undefined && this.trackList[l].redraw!=undefined){
				this.trackList[l].redraw();
			}
		}
		//DisplayRegionReport();
	}.bind(this);

	this.update=function (){
		for(var i=0;i<this.trackList.length;i++){
			if(this.trackList[i].update!=undefined){
				this.trackList[i].update();
			}
		}
		DisplayRegionReport();
	}.bind(this);

	this.updateData=function (){
		for(var i=0;i<this.trackList.length;i++){
			if(this.trackList[i]!=undefined && this.trackList[i].updateData!=undefined){
				this.trackList[i].updateData();
			}
		}
		DisplayRegionReport();
	}.bind(this);

	this.setLoading=function (){
		for(var i=0;i<this.trackList.length;i++){
			//console.log(this.trackList[i].update);
			if(this.trackList[i].updateData!=undefined){
				//console.log("not undef");
				this.trackList[i].showLoading();
			}
		}
	}.bind(this);

	this.mdown=function() {
			//console.log(this.vis);
			if(processAjax==0){
				this.prevMinCoord=this.xScale.domain()[0];
				this.prevMaxCoord=this.xScale.domain()[1];
		        var p = d3.mouse(this.vis[0][0]);
		        this.downx = this.xScale.invert(p[0]);
		        this.downscalex = this.xScale;
	    	}
		}.bind(this);


	this.type=type;
	this.div=div;
	this.margin=0;
	this.halfWindowWidth = $(window).width()/2;
	//this.mw=this.width-this.margin;
	this.mh=400;

	//vars for manipulation
	this.downx = Math.NaN;
	this.downscalex;
	this.downPanx=Math.NaN;


	this.xMax=290000000;
	this.xMin=1;

	this.prevMinCoord=minCoord;
	this.prevMaxCoord=maxCoord;
	
	this.dataMinCoord=minCoord;
	this.dataMaxCoord=maxCoord;

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
	this.selectedData=null;
	this.txType=null;
	//setup code
	this.width=imageWidth;
	this.mw=this.width-this.margin;
	if($(window).width()>1000){
		this.halfWindowWidth=($(window).width()-1000)/2;
	}
	this.vis=d3.select(div);
	//this.vis.append("span").attr("class","settings").attr("id","settingsLevel"+this.levelNumber).style("position","relative").style("top","15px").style("left","486px").append("img").attr("src","web/images/icons/gear.png");
	this.vis.append("span").attr("class","settings button").attr("id","settingsLevel"+this.levelNumber).style("position","relative").style("top","15px").style("left","436px").style("width","118px").text("Settings/Tracks");
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
	.on("mouseup",mup)
	.style("cursor", "ew-resize");
	
	this.scaleSVG.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0,55)")
      .attr("shape-rendering","crispEdges")
      .call(this.xAxis);
	
	d3.select("#Level"+this.levelNumber).select(".x.axis")
					.append("text")
					.text(title)
					.attr("x", ((this.width-(this.margin*2))/2))
					.attr("y",-40)
					.attr("class","axisLbl");
	
	this.topLevel=this.topDiv.append("div")
					.attr("id","ScrollLevel"+levelNumber)
					.style("max-height","350px")
					.style("overflow","auto")
					.append("ul")
					.attr("class","sortable"+levelNumber);
	
	
	this.tt=d3.select("body").append("div")   
    .attr("class", "testToolTip")               
    .style("opacity", 0);
    getAddMenuDiv(levelNumber,this.type);
	svgList.push(this);
	
	 $( ".sortable"+levelNumber ).sortable({
      revert: true,
	  axis: "y"
    });
    $( ".draggable"+levelNumber ).draggable({
      connectToSortable: ".sortable"+levelNumber,
      scroll: true,
      helper: "clone",
      revert: "invalid",
	  axis: "y"
    });

    var orgVer=mmVer;
    if(organism=="Rn"){
    	orgVer=rnVer;
    }
    var header=d3.select("div#imageHeader").html("Organism: "+orgVer+"&nbsp&nbsp&nbsp&nbsp"+siteVer);
}



//Track Functions
function Track(gsvgP,dataP,trackClassP,labelP){
	this.panDown=function(){
		if(processAjax==0){
			var p = d3.mouse(this.gsvg.vis[0][0]);
        	this.gsvg.downPanx = p[0];
        	this.gsvg.downscalex = this.xScale;
    	}
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
		if((start>=this.xScale.domain()[0]&&start<=this.xScale.domain()[1])||
			(end>=this.xScale.domain()[0]&&end<=this.xScale.domain()[1])){
			var pStart=Math.round(this.xScale(start));
			if(pStart<0){
				pStart=0;
			}
			var pEnd=Math.round(this.xScale(end));
			if(pEnd>=this.gsvg.width){
				pEnd=this.gsvg.width-1;
			}
			var pixStart=pStart-2;
			if(pixStart<0){
				pixStart=0;
			}
			var pixEnd=pEnd+2;
			if(pixEnd>=this.gsvg.width){
				pixEnd=this.gsvg.width-1;
			}
			var yMax=0;
			for(var pix=pixStart;pix<=pixEnd;pix++){
				if(this.yArr[pix]>yMax){
					yMax=this.yArr[pix];
				}
			}
			yMax++;
			if(yMax>this.trackYMax){
				this.trackYMax=yMax;
			}
			for(var pix=pStart;pix<=pEnd;pix++){
				this.yArr[pix]=yMax;
			}
			tmpY=yMax*15;
		}else{
			tmpY=15;
		}
		return tmpY;
		/*var tmpY=-299999999;
		var found=false;
		if((start>=this.xScale.domain()[0]&&start<=this.xScale.domain()[1])||
			(end>=this.xScale.domain()[0]&&end<=this.xScale.domain()[1])){
			for (var iy=0;iy<this.yArr.length&&!found;iy++){
					if((this.yArr[iy]+10)<this.xScale(start)){
						found=true;
						tmpY=(iy+1)*15;
						if(this.xScale(end)>this.yArr[iy]){
							this.yArr[iy]=this.xScale(end);
						}
					}
			}
		}else{
			tmpY=15;
		}
		return tmpY;*/
	}.bind(this);

	this.drawLegend = function (legendList){
		var lblStr=new String(this.label);
		var x=this.gsvg.width/2+(lblStr.length/2)*7.5+16;
		d3.select("#Level"+this.gsvg.levelNumber+this.trackClass).selectAll(".legend").remove();
		for(var i=0;i<legendList.length;i++){
			this.svg.append("rect")
				.attr("class","legend")
				.attr("x",x)
				.attr("y",0)
				.attr("rx",3)
				.attr("ry",3)
		    	.attr("height",12)
				.attr("width",16)
				.attr("fill",legendList[i].color)
				.attr("stroke",legendList[i].color);
			lblStr=new String(legendList[i].label);
			this.svg.append("text").text(lblStr).attr("class","legend").attr("x",x+18).attr("y",12);
			x=x+25+lblStr.length*8;
		}
	}.bind(this);

	this.showLoading = function (){
		this.loading=this.svg.append("g");
		this.loading.append("rect")
						.attr("x",0)
						.attr("y",0)
		    			.attr("height",this.svg.attr("height"))
						.attr("width",this.gsvg.width)
						.attr("fill","#CECECE")
						.attr("opacity",0.6);
		this.loading.append("text").text("Loading...")
					.attr("x",this.gsvg.width/2-5*7.5)
					.attr("y",this.svg.attr("height")/2);
	}.bind(this);

	this.hideLoading = function (){
		if(this.loading!=undefined){
			this.loading.remove();
		}
	}.bind(this);

	this.displayBreakDown=function(divSelector){
		//console.log("displayBreakDown");
		var tmpW= 300,tmpH = 300,radius = Math.min(tmpW, tmpH) / 2;
		var winWidth=$(window).width()/2;
		if($(window).width()>1000){
			winWidth=($(window).width()-1000)/2;
		}

		var arc = d3.svg.arc()
    		.outerRadius(radius - 10)
    		.innerRadius(0);

		var pie = d3.layout.pie()
    		//.sort(null)
    		.value(function(d) { return d.value; });

    	var svg = d3.select(divSelector).append("svg")
    		.attr("width", tmpW)
    		.attr("height", tmpH)
  			.append("g")
    		.attr("transform", "translate(" + tmpW / 2 + "," + tmpH / 2 + ")");

    	var g = svg.selectAll(".arc")
      		.data(pie(this.counts))
    		.enter().append("g")
      		.attr("class", "arc");
      	g.append("path")
      		.attr("d", arc)
      		.attr("fill", this.pieColor)
	      	.on("mouseover",function (d){
	      		d3.select('.testToolTip').transition()        
		                .duration(200)      
		                .style("opacity", .95);      
		        d3.select('.testToolTip').html("Name: "+d.data.names+"<BR>Count: "+d.data.value)  
		                .style("left", (d3.event.pageX-winWidth) + "px" )  
		                .style("top", (d3.event.pageY + 20) + "px");
		        var e = jQuery.Event("keyup");
				e.which = 32; // # Some key code value
				$('#tblBQTL_filter input').val(d.data.names).trigger(e);
	      		})
	      	.on("mouseout", function(d){
	      		d3.select('.testToolTip').transition()
					 .delay(500)       
	                .duration(200)      
	                .style("opacity", 0);
	            var e = jQuery.Event("keyup");
				e.which = 32; // # Some key code value
	            $('#tblBQTL_filter input').val("").trigger(e);
	      	});
      	g.append("text")
      		.attr("transform", function(d) { return "translate(" + arc.centroid(d) + ")"; })
      		.attr("dy", ".35em")
      		.style("text-anchor", "middle")
      		.text(function(d) { 
      				//console.log(d);
      				//return d.data.names+": "+d.value; 
      				return d.value;
      	});
		
	}.bind(this);

	this.updateLabel= function (label){
		this.label=label;
		var lblStr=new String(this.label);
		d3.select("#Level"+this.gsvg.levelNumber+this.trackClass).select("#trkLbl").attr("x",this.gsvg.width/2-(lblStr.length/2)*7.5).text(lblStr);
	}.bind(this);
	this.gsvg=gsvgP;
	this.data=dataP;
	this.label=labelP;
	this.yArr=new Array();
	this.loading;
	this.trackYMax=0;
	this.trackClass=trackClassP;
	this.topLevel=this.gsvg.get('topLevel');
	this.xScale=this.gsvg.get('xScale');
	this.scaleSVG=this.gsvg.get('scaleSVG');
	this.xAxis=this.gsvg.get('xAxis');
	for(var j=0;j<this.gsvg.width;j++){
				this.yArr[j]=0;
	}
	/*this.vis=d3.select("#Level"+this.gsvg.levelNumber+this.trackClass);
	if(this.vis[0][0]==null){
			var dragDiv=this.topLevel.append("li");
			this.svg = dragDiv.append("svg:svg")
			.attr("width", this.gsvg.get('width'))
			.attr("height", 800)
			.attr("class", "track draggable"+this.gsvg.levelNumber)
			.attr("id","Level"+this.gsvg.levelNumber+this.trackClass)
			.attr("pointer-events", "all")
			.style("cursor", "move")
			.on("mousedown", this.panDown);
			//this.svg.append("text").text(this.label).attr("x",this.gsvg.width/2-20).attr("y",12);
			var lblStr=new String(this.label);
			this.svg.append("text").text(lblStr).attr("x",this.gsvg.width/2-(lblStr.length/2)*7.5).attr("y",12);
	}else{
		this.svg=this.vis[0][0];
	}*/
	this.vis=d3.select("#Level"+this.gsvg.levelNumber+this.trackClass);
	//console.log(this.vis);
	//this.svg=this.vis[0][0];
	this.svg=d3.select("svg#Level"+this.gsvg.levelNumber+this.trackClass);
	//console.log(this.svg);
	this.updateLabel(this.label);
	//var lblStr=new String(this.label);
	//d3.select("#Level"+this.gsvg.levelNumber+this.trackClass).select("#trkLbl").attr("x",this.gsvg.width/2-(lblStr.length/2)*7.5).text(lblStr);
}


function GeneTrack(gsvg,data,trackClass,label){
	var that=new Track(gsvg,data,trackClass,label);
	that.counts=[{value:0,names:"Ensembl"},{value:0,names:"RNA-Seq"}];
	that.color =function(d){
		var color=d3.rgb("#000000");
		if(that.trackClass=="coding"){
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

	that.pieColor =function(d,i){
		var color=d3.rgb("#000000");
		if(that.trackClass=="coding"){
			if(i==0){
				color=d3.rgb("#DFC184");
			}else{
				color=d3.rgb("#7EB5D6");
			}
		}else if(that.trackClass=="noncoding"){
			if(i==0){
				color=d3.rgb("#B58AA5");
			}else{
				color=d3.rgb("#CECFCE");
			}
		}else if(that.trackClass=="smallnc"){
			if(i==0){
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
			for(var j=0;j<that.gsvg.width;j++){
				that.yArr[j]=0;
			}
			this.trackYMax=0;
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
			that.svg.attr("height", (this.trackYMax+1)*15);
		}
	}.bind(that);

	that.setupDetailedView=function(d){
			var e = jQuery.Event("keyup");
			e.which = 32; // # Some key code value
			var newLevel=this.gsvg.levelNumber+1;
			if(!$('div#collapsableReport').is(':hidden')){
				$('div#collapsableReport').hide();
				$("span[name='collapsableReport']").removeClass("less");
			}
			if($('div#selectedDetailHeader').is(':hidden')){
				$('div#selectedDetailHeader').show();
			}
			if($('div#selectedDetail').is(':hidden')){
				$('div#selectedDetail').show();
			}
			var localTxType="none";
			if(d.getAttribute("biotype")=="protein_coding" && (d.getAttribute("stop")-d.getAttribute("start"))>=200){
				localTxType="protein";
			}else if(d.getAttribute("biotype")!="protein_coding" && (d.getAttribute("stop")-d.getAttribute("start"))>=200){
				localTxType="long";
			}else if((d.getAttribute("stop")-d.getAttribute("start"))<200){
				localTxType="small";
			}
			if(localTxType=="protein"||localTxType=="long"){
				if(svgList[newLevel]==null){
					var newSvg=new GenomeSVG("div#selectedImage",this.gsvg.width,d.getAttribute("extStart"),d.getAttribute("extStop"),this.gsvg.levelNumber+1,d.getAttribute("ID"),"transcript");
					newSvg.xMin=d.getAttribute("extStart")-(d.getAttribute("extStop")-d.getAttribute("extStart"))*0.05;
					newSvg.xMax=d.getAttribute("extStop")+(d.getAttribute("extStop")-d.getAttribute("extStart"))*0.05;
					svgList[newLevel]=newSvg;
					svgList[newLevel].txType=localTxType;
					svgList[newLevel].selectedData=d;
					svgList[newLevel].addTrack("trx",2);
				}else{
					svgList[newLevel].xScale.domain([d.getAttribute("extStart"),d.getAttribute("extStop")]);
					svgList[newLevel].xMin=d.getAttribute("extStart")-(d.getAttribute("extStop")-d.getAttribute("extStart"))*0.05;
					svgList[newLevel].xMax=d.getAttribute("extStop")+(d.getAttribute("extStop")-d.getAttribute("extStart"))*0.05;
					svgList[newLevel].scaleSVG.select(".x.axis").call(svgList[newLevel].xAxis);
					d3.select("#Level"+newLevel).select(".axisLbl").text(d.getAttribute("ID")).attr("x", ((this.gsvg.width-(this.gsvg.margin*2))/2)).attr("y",-40);
					svgList[newLevel].txType=localTxType;
					svgList[newLevel].selectedData=d;

					svgList[newLevel].update();
				}
				selectedGeneSymbol=d.getAttribute("geneSymbol");
				selectedID=d.getAttribute("ID");
				$('div#selectedReport').show();
				$('div#selectedImage').show();
				var jspPage="web/GeneCentric/geneReport.jsp";
				var params={id:selectedID,geneSymbol:selectedGeneSymbol,chromosome:chr};
				DisplaySelectedDetailReport(jspPage,params)
			}else if(localTxType=="small"){
				if(new String(d.getAttribute("ID")).indexOf("ENS")==-1){
					$('div#selectedImage').hide();
					$('div#selectedReport').show();
					//Add SVG graphic later
					//For now processing.js graphic is in jsp page of the detail report
					var jspPage="web/GeneCentric/viewSmallNonCoding.jsp";
					var params={id: d.getAttribute("ID"),name: "smRNA_"+d.getAttribute("ID")};
					DisplaySelectedDetailReport(jspPage,params);
				}
			}
			
	}.bind(that);

	that.getDisplayedData= function (){
		var dataElem=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene");
		that.counts=[{value:0,names:"Ensembl"},{value:0,names:"RNA-Seq"}];
		var tmpDat=dataElem[0];
		//console.log(dataElem);
		var dispData=new Array();
		var dispDataCount=0;
		for(var l=0;l<tmpDat.length;l++){
			var start=that.xScale(tmpDat[l].__data__.getAttribute("start"));
			var stop=that.xScale(tmpDat[l].__data__.getAttribute("stop"));
			//console.log("start:"+start+":"+stop);
			if((0<=start && start<=that.gsvg.width)||(0<=stop &&stop<=that.gsvg.width)){
				if((new String(tmpDat[l].childNodes[0].id)).indexOf("ENS")>-1){
					this.counts[0].value++;
				}else{
					this.counts[1].value++;
				}
				dispData[dispDataCount]=tmpDat[l].__data__;
				dispDataCount++;
			}
		}
		return dispData;
	}.bind(that);

	that.updateData=function(){
		var tag="Gene";
		var path="tmpData/regionData/"+folderName+"/coding.xml";
		if(this.trackClass=="noncoding"){
			path="tmpData/regionData/"+folderName+"/noncoding.xml";
		}else if(this.trackClass=="smallnc"){
			path="tmpData/regionData/"+folderName+"/smallnc.xml";
			tag="smnc";
		}
		d3.xml(path,function (d){
				var data=d.documentElement.getElementsByTagName(tag);
				that.draw(data);
				that.hideLoading();
				
			});
	}.bind(that);

	that.draw=function (data){
		for(var j=0;j<that.gsvg.width;j++){
				that.yArr[j]=0;
		}
		//this.trackYMax=0;
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
			.on("click", that.setupDetailedView)
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
		
		//gene.exit().remove();
		

		that.svg.attr("height", (this.trackYMax+1)*15);
		/*var tmpYMax=-1;
		for(var j=0;j<100&&tmpYMax==-1;j++){
			if(that.yArr[j]==-299999999){
				that.svg.attr("height", (j+1)*15);
				tmpYMax=j;
			}
		}*/
	}.bind(that);

	/*that.displayBreakDown=function(divSelector){
		var tmpW= 300,tmpH = 300,radius = Math.min(tmpW, tmpH) / 2;

		var arc = d3.svg.arc()
    		.outerRadius(radius - 10)
    		.innerRadius(0);

		var pie = d3.layout.pie()
    		.sort(null)
    		.value(function(d) { return d.value; });

    	var svg = d3.select(divSelector).append("svg")
		//var svg = d3.select("div#collaspableReport").select("div#content").append("svg")
    		.attr("width", tmpW)
    		.attr("height", tmpH)
  			.append("g")
    		.attr("transform", "translate(" + tmpW / 2 + "," + tmpH / 2 + ")");

    	var g = svg.selectAll(".arc")
      		.data(pie(this.counts))
    		.enter().append("g")
      		.attr("class", "arc");
      	g.append("path")
      		.attr("d", arc)
      		.style("fill", that.pieColor);
      	g.append("text")
      		.attr("transform", function(d) { return "translate(" + arc.centroid(d) + ")"; })
      		.attr("dy", ".35em")
      		.style("text-anchor", "middle")
      		.text(function(d) { 
      				//console.log(d);
      				//return d.data.names+": "+d.value; 
      				return d.value;
      	});
		
	}.bind(that);*/

	var legend=[];
	if(trackClass == "coding"){
		legend=[{color:"#DFC184",label:"Ensembl"},{color:"#7EB5D6",label:"RNA-Seq"}];
	}else if(trackClass == "noncoding"){
		legend=[{color:"#B58AA5",label:"Ensembl"},{color:"#CECFCE",label:"RNA-Seq"}];
	}else if(trackClass == "smallnc"){
		legend=[{color:"#FFCC00",label:"Ensembl"},{color:"#99CC99",label:"RNA-Seq"}];
	}
	that.drawLegend(legend);
	that.draw(data);
	
	return that;
}

function ProbeTrack(gsvg,data,trackClass,label,density){
	var that=new Track(gsvg,data,trackClass,label);
	that.density=density;
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
		var strand=".";
		if(d.getAttribute("strand") == 1){
			strand="+";
		}else if(d.getAttribute("strand")==-1){
			strand="-";
		}
		var len=d.getAttribute("stop")-d.getAttribute("start");
		var tooltiptext="Affy Probe Set ID: "+d.getAttribute("ID")+"<BR>Strand: "+strand+"<BR>Location: "+d.getAttribute("chromosome")+":"+d.getAttribute("start")+"-"+d.getAttribute("stop")+" ("+len+"bp)<BR>";
		tooltiptext=tooltiptext+"Type: "+d.getAttribute("type");
		return tooltiptext;
	}.bind(that);

	that.redraw=function(){

		that.density=$("#probe"+that.gsvg.levelNumber+"Select").val();
		
		that.yArr=new Array();
		for(var j=0;j<100;j++){
			that.yArr[j]=-299999999;
		}
		
		d3.select("#Level"+this.gsvg.levelNumber+this.trackClass).selectAll("g.probe").attr("transform",function (d,i){
															   var st=that.xScale(d.getAttribute("start"));
																return "translate("+st+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),that.density,i,2)+")";
															});
		d3.select("#Level"+this.gsvg.levelNumber+this.trackClass).selectAll("g.probe rect").attr("width",function(d) {
								   var wX=1;
								   if(that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"))>1){
									   wX=that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"));
								   }
								   return wX;
								   }
									);
		if(that.density==1){
			that.svg.attr("height", 30);
		}else if(this.density==2){
			that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+"probe").selectAll("g.probe").length+1)*15);
		}else if(this.density==3){
			var tmpYMax=-1;
			for(var j=0;j<that.yArr.length&&tmpYMax==-1;j++){
				if(that.yArr[j]==-299999999){
					that.svg.attr("height", j*15);
					tmpYMax=j;
				}
			}
		}
	}.bind(that);

	that.calcY=function (start,end,density,i,spacing){
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
				tmpY=(this.yArr.length+1)*15;
			}
		}
		return tmpY;
	}.bind(that);

	that.update=function (d){
		that.redraw();
	}.bind(that);

	that.draw= function (data){
		//update
		var probes=that.svg.selectAll(".probe")
   			.data(data,key)
			.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),density,i,5)+")";});
			
  	
			
	//add new
	probes.enter().append("g")
			.attr("class","probe")
			.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),density,i,5)+")";})
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
		.style("opacity", function(d){
					var op=1;
					if(d.getAttribute("strand")==that.gsvg.selectedData.getAttribute("strand")){

					}else{
						op=0;
					}
					return op;
			})
		.on("mouseover", function(d) {
			var thisD3=d3.select(this); 
			if(thisD3.style("opacity")>0){
				thisD3.style("fill","green");
            	that.gsvg.get('tt').transition()        
                	.duration(200)      
                	.style("opacity", .95);      
            	that.gsvg.get('tt').html(that.createToolTip(d))  
                	.style("left", (d3.event.pageX-that.gsvg.get('halfWindowWidth')) + "px")     
                	.style("top", (d3.event.pageY + 20) + "px");  
            }
            })
		.on("mouseout", function(d) {
			var thisD3=d3.select(this); 
			if(thisD3.style("opacity")>0){  
			thisD3.style("fill",that.color);
            that.gsvg.get('tt').transition()
				 .delay(500)       
                .duration(200)      
                .style("opacity", 0); 
            } 
        });
		
	
	//probes.exit().remove();
		if(density==1){
			that.svg.attr("height", 30);
		}else if(density==2){
			that.svg.attr("height", (data.length+1)*15);
		}else if(density==3){
			var tmpYMax=-1;
			for(var j=0;j<100&&tmpYMax==-1;j++){
				if(that.yArr[j]==-299999999){
					that.svg.attr("height", (j+1)*15);
					tmpYMax=j;
				}
			}
		}
	}.bind(that);

	var legend=[{color:"#FF0000",label:"Core"},{color:"#0000FF",label:"Extended"},{color:"#006400",label:"Full"},{color:"#000000",label:"Ambiguous"}];
	that.drawLegend(legend);
	that.draw(data);

	
	return that;
}

function SNPTrack(gsvg,data,trackClass,density,include){
	var that=new Track(gsvg,data,trackClass,lbl);
	var strain=(new String(trackClass)).substr(3);
	var lbl=strain;
	if(lbl=="SHRH"){
		lbl="SHR";
	}else if(lbl=="BNLX"){
		lbl="BN-Lx";
	}
	that.displayStrain=lbl;
	if(include==1){
		lbl=lbl+" SNPs";
	}else if(include==2){
		lbl=lbl+" Insertions";
	}else if(include==3){
		lbl=lbl+" Deletions";
	}else if(include==4){
		lbl=lbl+" SNPs/Indels";
	}
	that.counts=[{value:0,perc:0,names:"SNP "+that.displayStrain},{value:0,perc:0,names:"Insertion "+that.displayStrain},{value:0,perc:0,names:"Deletion "+that.displayStrain}];
	that.strain=strain;
	that.redraw=function (){
		that.density=$("#snp"+strain+"Dense"+that.gsvg.levelNumber+"Select").val();
		that.include=$("#snp"+strain+that.gsvg.levelNumber+"Select").val();
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
			}else if(d.getAttribute("strain")=="SHRJ"){
				color=d3.rgb("#00FF00");
			}else if(d.getAttribute("strain")=="F344"){
				color=d3.rgb("#00FFFF");
			}else{
				color=d3.rgb(100,100,100);
			}
		}else{
			if(d.getAttribute("strain")=="BNLX"){
				color=d3.rgb(0,0,150);
			}else if(d.getAttribute("strain")=="SHRH"){
				color=d3.rgb(150,0,0);
			}else if(d.getAttribute("strain")=="SHRJ"){
				color=d3.rgb("#009600");
			}else if(d.getAttribute("strain")=="F344"){
				color=d3.rgb("#009696");
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

	that.update=function (d){
		that.redraw();
	}.bind(that);
	
	that.updateData = function(){
		var tag="Snp";
		var path="tmpData/regionData/"+folderName+"/snp"+that.strain+".xml";
		that.include=$("#"+that.trackClass+that.gsvg.levelNumber+"Select").val();
		that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").val();
		d3.xml(path,function (d){
				var data=d.documentElement.getElementsByTagName(tag);
				that.draw(data);
				that.hideLoading();
			});
	}.bind(that);

	that.getDisplayedData= function (){
		//console.log("getDisplayedData");
		var dataElem=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".snp");
		that.counts=[{value:0,perc:0,names:"SNP "+that.displayStrain},{value:0,perc:0,names:"Insertion "+that.displayStrain},{value:0,perc:0,names:"Deletion "+that.displayStrain}];
		var tmpDat=dataElem[0];
		var dispData=new Array();
		var dispDataCount=0;
		var total=0;
		for(var l=0;l<tmpDat.length;l++){
			var start=that.xScale(tmpDat[l].__data__.getAttribute("start"));
			var stop=that.xScale(tmpDat[l].__data__.getAttribute("stop"));
			if((0<=start && start<=that.gsvg.width)||(0<=stop &&stop<=that.gsvg.width)){
				var ind=0;
				if(tmpDat[l].__data__.getAttribute("type")=="Insertion"){
					ind++;
				}else if(tmpDat[l].__data__.getAttribute("type")=="Deletion"){
					ind=ind+2;
				}
				that.counts[ind].value++;
				dispData[dispDataCount]=tmpDat[l].__data__;
				dispDataCount++;
				total++;
			}
		}
		/*for(var l=0;l<that.counts.length;l++){
			that.counts[l].perc=Math.round(that.counts[l].value/total*100);
		}*/
		//console.log(that.counts);
		return dispData;
	}.bind(that);

	that.draw= function (data){
		for(var j=0;j<that.yArr.length;j++){
				that.yArr[j]=-299999999;
		}

		var lbl=that.strain;
		if(lbl=="SHRH"){
			lbl="SHR";
		}else if(lbl=="BNLX"){
			lbl="BN-Lx";
		}
		if(that.include==1){
			lbl=lbl+" SNPs";
		}else if(that.include==2){
			lbl=lbl+" Insertions";
		}else if(that.include==3){
			lbl=lbl+" Deletions";
		}else if(that.include==4){
			lbl=lbl+" SNPs/Indels";
		}
		that.updateLabel(lbl);
		that.redrawLegend();
		if(that.include<4){
			var newData=[];
			var newCount=0;
			for(var l=0;l<data.length;l++){
				if(data[l]!=undefined ){
					if(that.include==1 && data[l].getAttribute("type")=="SNP"){
						newData[newCount]=data[l];
						newCount++;
					}else if(that.include==2 && data[l].getAttribute("type")=="Insertion"){
						newData[newCount]=data[l];
						newCount++;
					}else if(that.include==3 && data[l].getAttribute("type")=="Deletion"){
						newData[newCount]=data[l];
						newCount++;
					}
				}
			}
			data=newData;
		}
		that.svg.selectAll(".snp").remove();
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
			//snps.exit().remove();
			if(that.density==1){
				that.svg.attr("height", 30);
			}else if(that.density==2){
				that.svg.attr("height", (data.length+1)*15);
			}else if(that.density==3){
				var tmpYMax=-1;
				for(var j=0;j<that.yArr.length&&tmpYMax==-1;j++){
					if(that.yArr[j]==-299999999){
						that.svg.attr("height", (j+1)*15);
						tmpYMax=j;
					}
				}
			};
		snps.exit().remove();
	}.bind(that);

	that.pieColor =function(d,i){
		var color=d3.rgb("#000000");
		var tmpName=new String(d.data.names);
		//console.log(d.data.names);
		//console.log(tmpName);
		if(tmpName.indexOf("BN-Lx")>-1){
			if(tmpName.indexOf("SNP")>-1){
				color=d3.rgb(0,0,255);
			}else if(tmpName.indexOf("Insertion")>-1){
				color=d3.rgb(0,0,175);
			}else{
				color=d3.rgb(0,0,125);
			}
		}else if(tmpName.indexOf("SHRJ")>-1){
			if(tmpName.indexOf("SNP")>-1){
				color=d3.rgb(0,255,0);
			}else if(tmpName.indexOf("Insertion")>-1){
				color=d3.rgb(0,175,00);
			}else{
				color=d3.rgb(0,125,00);
			}
		}else if(tmpName.indexOf("F344")>-1){
			if(tmpName.indexOf("SNP")>-1){
				color=d3.rgb(0,255,255);
			}else if(tmpName.indexOf("Insertion")>-1){
				color=d3.rgb(0,175,175);
			}else{
				color=d3.rgb(0,125,125);
			}
		}else if(tmpName.indexOf("SHR")>-1){
			if(tmpName.indexOf("SNP")>-1){
				color=d3.rgb(255,0,0);
			}else if(tmpName.indexOf("Insertion")>-1){
				color=d3.rgb(175,0,0);
			}else{
				color=d3.rgb(125,0,0);
			}
		}
		//console.log(color);
		return color;
	}.bind(that);


	that.redrawLegend=function (){
		var legend=[];
		if(that.include==4){
			if(that.strain=="BNLX"){
				legend=[{color:"#0000FF",label:"SNP BN-Lx"},{color:"#000096",label:"Indel BN-Lx"}];
			}else if(that.strain=="SHRH"){
				legend=[{color:"#FF0000",label:"SNP SHR"},{color:"#960000",label:"Indel SHR"}];
			}else if(that.strain=="SHRJ"){
				legend=[{color:"#00FF00",label:"SNP SHRJ"},{color:"#009600",label:"Indel SHRJ"}];
			}else if(that.strain=="F344"){
				legend=[{color:"#00FFFF",label:"SNP F344"},{color:"#009696",label:"Indel F344"}];
			}else{
				legend=[{color:"#DEDEDE",label:"SNP"},{color:"#969696",label:"Indel"}];
			}
		}else if(that.include==3 || that.include==2){
			if(that.strain=="BNLX"){
				legend=[{color:"#000096",label:"Indel BN-Lx"}];
			}else if(that.strain=="SHRH"){
				legend=[{color:"#960000",label:"Indel SHR"}];
			}else if(that.strain=="SHRJ"){
				legend=[{color:"#009600",label:"Indel SHRJ"}];
			}else if(that.strain=="F344"){
				legend=[{color:"#009696",label:"Indel F344"}];
			}else{
				legend=[{color:"#969696",label:"Indel"}];
			}
		}else if(that.include==1){
			if(that.strain=="BNLX"){
				legend=[{color:"#0000FF",label:"SNP BN-Lx"}];
			}else if(that.strain=="SHRH"){
				legend=[{color:"#FF0000",label:"SNP SHR"}];
			}else if(that.strain=="SHRJ"){
				legend=[{color:"#00FF00",label:"SNP SHRJ"}];
			}else if(that.strain=="F344"){
				legend=[{color:"#00FFFF",label:"SNP F344"}];
			}else{
				legend=[{color:"#DEDEDE",label:"SNP"}];
			}
		}
		that.drawLegend(legend);
	}.bind(that);

	that.strain=strain;
	that.include=include;
	that.density=density;
	/*var legend=[];
	if(include==4){
		if(strain=="BNLX"){
			legend=[{color:"#0000FF",label:"SNP BN-Lx"},{color:"#000096",label:"Indel BN-Lx"}];
		}else if(strain=="SHRH"){
			legend=[{color:"#FF0000",label:"SNP SHR"},{color:"#960000",label:"Indel SHR"}];
		}else if(strain=="SHRJ"){
			legend=[{color:"#00FF00",label:"SNP SHRJ"},{color:"#009600",label:"Indel SHRJ"}];
		}else if(strain=="F344"){
			legend=[{color:"#00FFFF",label:"SNP F344"},{color:"#009696",label:"Indel F344"}];
		}else{
			legend=[{color:"#DEDEDE",label:"SNP"},{color:"#969696",label:"Indel"}];
		}
	}else if(include==3 || include==2){
		if(strain=="BNLX"){
			legend=[{color:"#000096",label:"Indel BN-Lx"}];
		}else if(strain=="SHRH"){
			legend=[{color:"#960000",label:"Indel SHR"}];
		}else if(strain=="SHRJ"){
			legend=[{color:"#009600",label:"Indel SHRJ"}];
		}else if(strain=="F344"){
			legend=[{color:"#009696",label:"Indel F344"}];
		}else{
			legend=[{color:"#969696",label:"Indel"}];
		}
	}else if(include==1){
		if(strain=="BNLX"){
			legend=[{color:"#0000FF",label:"SNP BN-Lx"}];
		}else if(strain=="SHRH"){
			legend=[{color:"#FF0000",label:"SNP SHR"}];
		}else if(strain=="SHRJ"){
			legend=[{color:"#00FF00",label:"SNP SHRJ"}];
		}else if(strain=="F344"){
			legend=[{color:"#00FFFF",label:"SNP F344"}];
		}else{
			legend=[{color:"#DEDEDE",label:"SNP"}];
		}
	}
  	//var legend=[{color:"#0000FF",label:"SNP BN-Lx"},{color:"#FF0000",label:"SNP SHR"},{color:"#000096",label:"Indel BN-Lx"},{color:"#960000",label:"Indel SHR"}];
	that.drawLegend(legend);*/
	that.redrawLegend();
	that.draw(data);	
	
	return that;
}

function QTLTrack(gsvg,data,trackClass,density){
	var that=new Track(gsvg,data,trackClass,"QTLs");
	
	that.color= function (name){
		return that.pieColorPalette(name);
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

		/*var qtl=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass)
										.selectAll(".qtl");*/
		qtls[0].forEach(function(d){
				var nameStr=d.__data__.getAttribute("name");
				var end=nameStr.indexOf("QTL")-1;
				var name=nameStr.substr(0,end);
				d3.select(d).select("rect").style("fill",that.color(name));
		});
		that.svg.attr("height", (qtls[0].length+1)*15);
	}.bind(that);

	that.createToolTip=function (d){
		var tooltip="";
		tooltip="Name: "+d.getAttribute("name")+"<BR>Location: "+d.getAttribute("chromosome")+":"+d.getAttribute("start")+"-"+d.getAttribute("stop")+"<BR>Trait:<BR>"+d.getAttribute("trait")+"<BR><BR>Phenotype:<BR>"+d.getAttribute("phenotype")+"<BR><BR>Candidate Genes:<BR>"+d.getAttribute("candidate");
		return tooltip;
	}.bind(that);

	that.pieColorPalette=d3.scale.category20();

	//For Reports and Pie Chart
	that.pieColor=function (d){
		return that.pieColorPalette(d.data.names);
	}.bind(that);
	
	that.getDisplayedData= function (){
		var dataElem=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".qtl");
		that.counts=new Array();
		var countsInd=0;
		var tmpDat=dataElem[0];
		var dispData=new Array();
		var dispDataCount=0;
		var total=0;
		for(var l=0;l<tmpDat.length;l++){
			var start=that.xScale(tmpDat[l].__data__.getAttribute("start"));
			var stop=that.xScale(tmpDat[l].__data__.getAttribute("stop"));
			if((0<=start && start<=that.gsvg.width)||(0<=stop &&stop<=that.gsvg.width)||(start<=0&&stop>=that.gsvg.width)){
				var nameStr=new String(tmpDat[l].__data__.getAttribute("name"));
				var end=nameStr.indexOf("QTL")-1;
				var name=nameStr.substr(0,end);
				if(that.counts[name]==undefined){
					that.counts[name]=new Object();
					that.counts[countsInd]=that.counts[name];
					countsInd++;
					that.counts[name].value=1;
					that.counts[name].names=name;
				}else{
					that.counts[name].value++;
				}
				dispData[dispDataCount]=tmpDat[l].__data__;
				dispDataCount++;
				total++;
			}
		}
		return dispData;
	}.bind(that);

	that.setupDetailedView=function(d){
			if(!$('div#collapsableReport').is(':hidden')){
				$('div#collapsableReport').hide();
				$("span[name='collapsableReport']").removeClass("less");
			}
			if($('div#selectedDetailHeader').is(':hidden')){
				$('div#selectedDetailHeader').show();
			}
			if($('div#selectedDetail').is(':hidden')){
				$('div#selectedDetail').show();
			}
			
			//No SVG to add so Hide Image and Show report
			$('div#selectedImage').hide();
			$('div#selectedReport').show();
				var jspPage="web/GeneCentric/bQTLReport.jsp";
				var params={id: d.getAttribute("ID"),species: organism};
				DisplaySelectedDetailReport(jspPage,params);
			
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
		.on("click", that.setupDetailedView)
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
			var nameStr=d.getAttribute("name");
			var end=nameStr.indexOf("QTL")-1;
			var name=nameStr.substr(0,end);  
			d3.select(this).style("fill",that.color(name));
            that.gsvg.tt.transition()
				 .delay(500)       
                .duration(200)      
                .style("opacity", 0);  
        });

	qtls.exit().remove();
	that.svg.attr("height", (data.length+1)*15);
	that.getDisplayedData();
	that.redraw();
	return that;
}



function TranscriptTrack(gsvg,data,trackClass,density){
	that=new Track(gsvg,data,trackClass,"Transcripts");

	that.createToolTip= function(d){
		var tooltip="";
		var strand=".";
		if(d.getAttribute("strand") == 1){
			strand="+";
		}else if(d.getAttribute("strand")==-1){
			strand="-";
		}
		tooltip="ID: "+d.getAttribute("ID")+"<BR>Location:"+d.getAttribute("chromosome")+":"+d.getAttribute("start")+"-"+d.getAttribute("stop")+"<BR>Strand: "+strand;
		if(new String(d.getAttribute("ID")).indexOf("ENS")==-1){
				var annot=getFirstChildByName(getFirstChildByName(d,"annotationList"),"annotation");
				if(annot!=null){
					tooltip+="<BR>Matching: "+annot.getAttribute("reason");
				}
		}
		return tooltip;
	}.bind(that);

	that.color= function (d){
		var color=d3.rgb("#000000");
		if(this.gsvg.txType=="protein"){
			if((new String(d.getAttribute("ID"))).indexOf("ENS")>-1){
				color=d3.rgb("#DFC184");
			}else{
				color=d3.rgb("#7EB5D6");
			}
		}else if(this.gsvg.txType=="long"){
			if((new String(d.getAttribute("ID"))).indexOf("ENS")>-1){
				color=d3.rgb("#B58AA5");
			}else{
				color=d3.rgb("#CECFCE");
			}
		}else if(this.gsvg.txType=="small"){
			if((new String(d.getAttribute("ID"))).indexOf("ENS")>-1){
				color=d3.rgb("#FFCC00");
			}else{
				color=d3.rgb("#99CC99");
			}
		}
		return color;
	}.bind(that);

	that.drawTrx=function (d,i){
		var txG=this.svg.select("#"+d.getAttribute("ID"));
		exList=getAllChildrenByName(getFirstChildByName(d,"exonList"),"exon");
		for(var m=0;m<exList.length;m++){
			txG.append("rect")
			.attr("x",function(d){ return that.xScale(exList[m].getAttribute("start")); })
			.attr("rx",1)
			.attr("ry",1)
	    	.attr("height",10)
			.attr("width",function(d){ return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start")); })
			.attr("title",function(d){ return exList[m].getAttribute("ID");})
			.attr("id",function(d){return "Ex"+exList[m].getAttribute("ID");})
			.style("fill",that.color)
			.style("cursor", "pointer")
			if(m>0){
				txG.append("line")
				.attr("x1",function(d){ return that.xScale(exList[m-1].getAttribute("stop")); })
				.attr("x2",function(d){ return that.xScale(exList[m].getAttribute("start")); })
				.attr("y1",5)
				.attr("y2",5)
			.attr("id",function(d){ return "Int"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID");})
			.attr("stroke",that.color)
			.attr("stroke-width","2")
			}
		}
		
	}.bind(that);

	that.redraw = function (){
		var txG=this.svg.selectAll("g");
		
		txG//.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
			.each(function(d,i){
				exList=getAllChildrenByName(getFirstChildByName(d,"exonList"),"exon");
				for(var m=0;m<exList.length;m++){
					d3.select("g#"+d.getAttribute("ID")+" rect#Ex"+exList[m].getAttribute("ID"))
						.attr("x",function(d){ return that.xScale(exList[m].getAttribute("start")); })
						.attr("width",function(d){ return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start")); });
					if(m>0){
						d3.select("g#"+d.getAttribute("ID")+" line#Int"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID"))
							.attr("x1",function(d){ return that.xScale(exList[m-1].getAttribute("stop")); })
							.attr("x2",function(d){ return that.xScale(exList[m].getAttribute("start")); })
					}
				}
			});
	}.bind(that);

	that.update = function(){
		var txList=getAllChildrenByName(getFirstChildByName(that.gsvg.selectedData,"TranscriptList"),"Transcript");
		that.txMin=that.gsvg.selectedData.getAttribute("extStart");
		that.txMax=that.gsvg.selectedData.getAttribute("extStop");
		that.svg.attr("height", (1+txList.length)*15);
		that.svg.selectAll(".trx").remove();
		var tx=that.svg.selectAll(".trx")
	   			.data(txList,key)
				.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d,i)+")";});
				
	  	tx.enter().append("g")
				.attr("class","trx")
				//.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
				.attr("transform",function(d,i){ return "translate(0,"+that.calcY(d,i)+")";})
				.attr("id",function(d){return d.getAttribute("ID");})
				.attr("pointer-events", "all")
				.style("cursor", "pointer")
				.on("mouseover", function(d) { 
							d3.select(this).selectAll("line").style("stroke","green");
							d3.select(this).selectAll("rect").style("fill","green");
	            			that.gsvg.tt.transition()        
								.duration(200)      
								.style("opacity", .95);      
							that.gsvg.tt.html(that.createToolTip(d))  
								.style("left", (d3.event.pageX-that.gsvg.halfWindowWidth) + "px")     
								.style("top", (d3.event.pageY +5) + "px");  
	            	})
				.on("mouseout", function(d) {
						d3.select(this).selectAll("line").style("stroke",that.color);
						d3.select(this).selectAll("rect").style("fill",that.color);  
						that.gsvg.tt.transition()
							 .delay(500)       
							.duration(200)      
							.style("opacity", 0);  
	        		})
				.each(that.drawTrx);
		
		
		 tx.exit().remove();
		 that.svg.selectAll(".legend").remove();
		 var legend=[];
		if(that.gsvg.txType=="protein"){
			legend=[{color:"#DFC184",label:"Ensembl"},{color:"#7EB5D6",label:"RNA-Seq"}];
		}else if(that.gsvg.txType=="long"){
			legend=[{color:"#B58AA5",label:"Ensembl"},{color:"#CECFCE",label:"RNA-Seq"}];
		}else if(that.gsvg.txType=="small"){
			legend=[{color:"#FFCC00",label:"Ensembl"},{color:"#99CC99",label:"RNA-Seq"}];
		}
		that.drawLegend(legend);
	}.bind(that);

	that.calcY=function(d,i){
		return (i+1)*15;
	}

	

	that.txMin=that.gsvg.selectedData.getAttribute("extStart");
	that.txMax=that.gsvg.selectedData.getAttribute("extStop");
	that.svg.attr("height", (1+data.length)*15);
	that.svg.selectAll(".trx").remove();
	var tx=that.svg.selectAll(".trx")
   			.data(data,key)
			.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d,i)+")";});
			
  	tx.enter().append("g")
			.attr("class","trx")
			//.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
			.attr("transform",function(d,i){ return "translate(0,"+that.calcY(d,i)+")";})
			.attr("id",function(d){return d.getAttribute("ID");})
			.attr("pointer-events", "all")
			.style("cursor", "pointer")
			.on("mouseover", function(d) { 
						d3.select(this).selectAll("line").style("stroke","green");
						d3.select(this).selectAll("rect").style("fill","green");
            			that.gsvg.tt.transition()        
							.duration(200)      
							.style("opacity", .95);      
						that.gsvg.tt.html(that.createToolTip(d))  
							.style("left", (d3.event.pageX-that.gsvg.halfWindowWidth) + "px")     
							.style("top", (d3.event.pageY +5) + "px");  
            	})
			.on("mouseout", function(d) {
					d3.select(this).selectAll("line").style("stroke",that.color);
					d3.select(this).selectAll("rect").style("fill",that.color);  
					that.gsvg.tt.transition()
						 .delay(500)       
						.duration(200)      
						.style("opacity", 0);  
        		})
			.each(that.drawTrx);
	
	
	 tx.exit().remove();
	 var legend=[];
	if(that.gsvg.txType=="protein"){
		legend=[{color:"#DFC184",label:"Ensembl"},{color:"#7EB5D6",label:"RNA-Seq"}];
	}else if(that.gsvg.txType=="long"){
		legend=[{color:"#B58AA5",label:"Ensembl"},{color:"#CECFCE",label:"RNA-Seq"}];
	}else if(that.gsvg.txType=="small"){
		legend=[{color:"#FFCC00",label:"Ensembl"},{color:"#99CC99",label:"RNA-Seq"}];
	}
	that.drawLegend(legend);
	 that.scaleSVG.transition()        
				.duration(300)      
				.style("opacity", 1);
	 that.svg.transition()        
				.duration(300)      
				.style("opacity", 1);
	that.redraw();
	return that;
}


function HelicosTrack(gsvg,data,trackClass,density){
	var that=new Track(gsvg,data,trackClass,"Helicos Read Counts");
	that.density=density;
	that.data=data;
	that.prevDensity=density;
	that.color= function (d){		
		return d3.rgb(that.colorScale(d.getAttribute("logcount")));

	}.bind(that);

	that.redraw= function (){
		that.density=$("#helicos"+that.gsvg.levelNumber+"Select").val();
		if(that.density==1){
			if(that.density!=that.prevDensity){
				that.prevDensity=that.density;
			}
			that.svg.selectAll(".helicos").attr("x",function(d){return that.xScale(d.getAttribute("start"));})
				.attr("width",function(d) {
								   var wX=1;
								   if(that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"))>1){
									   wX=that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"));
								   }
								   return wX;
								   });
			that.svg.attr("height", 30);
		}else{
			if(that.density!=that.prevDensity){
				that.prevDensity=that.density;
				that.svg.selectAll(".helicos").remove();
				that.svg.append("path")
			      	.datum(data)
			      	.attr("class", "area")
			      	.attr("fill","steelblue")
			      	.attr("d", that.area);

			    that.svg.append("g")
			      .attr("class", "y axis")
			      .call(that.yAxis)
			      .append("text")
			      .attr("transform", "rotate(-90)")
			      .attr("y", 6)
			      .attr("dy", ".5em")
			      .style("text-anchor", "end")
			      .text("log10(reads)");
			}
			
			that.area = d3.svg.area()
    				.x(function(d) { return that.xScale(d.getAttribute("start")); })
				    .y0(100)
				    .y1(function(d) { return that.y(d.getAttribute("logcount")); });
			that.y.domain([0, d3.max(data, function(d) { return d.getAttribute("logcount"); })]);
			that.svg.select('path').datum(data).attr("d",that.area);
			that.svg.attr("height", 100);
		}
	}.bind(that);

	that.createToolTip=function (d){
		var tooltip="";
		//tooltip="";
		return tooltip;
	}.bind(that);

	that.update=function (d){
		that.redraw();
	}.bind(that);

	that.updateData = function(){
		var tag="Count";
		var path="tmpData/regionData/"+folderName+"/helicos.xml";
		d3.xml(path,function (d){
				var data=d.documentElement.getElementsByTagName(tag);
				that.draw(data);
				that.hideLoading();
			});
	}.bind(that);

	that.draw=function(data){
		if(density==1){
	    	var points=that.svg.selectAll(".helicos")
	   			.data(data,keyStart)
	    	points.enter()
					.append("rect")
					.attr("x",function(d){return that.xScale(d.getAttribute("start"));})
					.attr("y",15)
					.attr("class", "helicos")
		    		.attr("height",10)
					.attr("width",function(d) {
									   var wX=1;
									   if(that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"))>1){
										   wX=that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"));
									   }
									   return wX;
									   })
					.attr("fill",that.color);
			that.svg.attr("height", 30);
	    }else{
		    that.svg.append("path")
		      	.datum(data)
		      	.attr("class", "area")
		      	.attr("fill","steelblue")
		      	.attr("d", that.area);

		    that.svg.append("g")
		      .attr("class", "y axis")
		      .call(that.yAxis)
		    .append("text")
		      .attr("transform", "rotate(-90)")
		      .attr("y", 6)
		      .attr("dy", ".5em")
		      .style("text-anchor", "end")
		      .text("log10(reads)");

			that.svg.attr("height", 100);
		}
	}.bind(that);

	that.y = d3.scale.linear()
    	.range([100, 0])
    	.nice(4);

   	that.colorScale= d3.scale.threshold()
   						.domain([0.5,1,1.5,2,2.5,3,3.5,4])
   						.range(["#FFFFFF","#CCCCCC","#AAAAAA","#888888","#666666","#444444","#222222","#000000"]);

    that.yAxis = d3.svg.axis()
    				.scale(that.y)
    				.orient("left");

    that.area = d3.svg.area()
    				.x(function(d) { return that.xScale(d.getAttribute("start")); })
				    .y0(100)
				    .y1(function(d) { return that.y(d.getAttribute("logcount")); });

    that.y.domain([0, d3.max(data, function(d) { return d.getAttribute("logcount"); })]);

    that.draw(data);
	return that;
}

