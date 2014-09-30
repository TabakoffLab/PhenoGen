/*
*	D3js based Genome Data Browser
*
* 	Author: Spencer Mahaffey
*	for http://phenogen.ucdenver.edu
*	Tabakoff Lab
* 	University of Colorado Denver AMC
* 	Department of Pharmaceutical Sciences Skaggs School of Pharmacy & Pharmaceutical Sciences
*
*	Builds an interactive multilevel view of the rat/mouse genome.
*/

$.cookie.defaults.expires=365;

//global varaiable to store a list of GenomeSVG images representing each level.
var svgList=[];
var svgViewIDList=[];
var processAjax=0;
var ajaxList=[];
var trackInfo=[];
var selectedGeneSymbol="";
var selectedID="";
var trackSettings=[];
var overSelectable=0;

var ratOnly=[];
var mouseOnly=[];
var history=[];
history[0]=[];
history[1]=[];

var customTrackCount=0;

var testChrome=/chrom(e|ium)/.test(navigator.userAgent.toLowerCase());
var testSafari=/safari/.test(navigator.userAgent.toLowerCase());
var testFireFox=/firefox/.test(navigator.userAgent.toLowerCase());
var testIE=/(wow|.net)/.test(navigator.userAgent.toLowerCase());

//var defaultMouseFunct="pan";

ratOnly.snpSHRJ=1;
ratOnly.snpF344=1;
ratOnly.snpSHRH=1;
ratOnly.snpBNLX=1;
ratOnly.helicos=1;
ratOnly.spliceJnct=1;
ratOnly.illuminaTotal=1;
ratOnly.illuminaSmall=1;
ratOnly.illuminaPolyA=1;
ratOnly.liverTotal=1;
ratOnly.liverspliceJnct=1;
ratOnly.liverilluminaTotalPlus=1;
ratOnly.liverilluminaTotalMinus=1;
ratOnly.polyASite=1;
ratOnly.braincoding=1;
ratOnly.brainnoncoding=1;
ratOnly.brainsmallnc=1;
ratOnly.heartTotal=1;
ratOnly.heartilluminaTotalPlus=1;
ratOnly.heartilluminaTotalMinus=1;

mouseOnly.brainTotal=1;
mouseOnly.brainilluminaTotalPlus=1;
mouseOnly.brainilluminaTotalMinus=1;
mouseOnly.brainspliceJnct=1;



var mmVer="Mouse(mm10) Strain:C57BL/6J";
var rnVer="Rat(rn5) Strain:BN";
var siteVer="PhenoGen v2.13.0(9/27/2014)";

var trackBinCutoff=10000;
var customTrackLevel=-1;
var mouseTTOver=0;
var ttHideHandle=0;


//setup tooltip text div
var tt=d3.select("body").append("div")   
	    	.attr("class", "testToolTip")
	    	.style("z-index",1001) 
	    	.attr("pointer-events", "all")              
	    	.style("opacity", 0);
	    	/*.on("mouseover",function(){
	    			console.log("MOUSE IS OVER:"+$(this).css("opacity"))
	    			if($(this).css("opacity")>0){
					    		console.log("Mouse OVER TT");
					    		mouseTTOver=1;
					    		if(ttHideHandle!=0){
					    			clearTimeout(ttHideHandle);
					    			ttHideHandle=0;
					    		}
					}
				})
	    	.on("mouseout",function(){
	    		console.log("Mouse OUT TT");
	    		if($(this).css("opacity")>0){
		    		mouseTTOver=0;
		    		ttHideHandle=setTimeout(function(){
		    						if(mouseTTOver==0){
						    			console.log("Mouse still out hiding tt.")
						    			tt.transition()
												.delay(200)       
								                .duration(200)      
								                .style("opacity", 0);
							        }
					      
					},3000);
	    		}
			    
	    	});*/


var tsDialog=d3.select("body").append("div")   
	    	.attr("class", "trackSetting")
	    	.attr("id","trackSettingDialog")
		    .style("z-index",1001)            
	    	.style("margin-left","15px")
	    	.style("margin-right","15px");
tsDialog.append("div").attr("id","trackSettingContent").append("table").attr("cellpadding","0").attr("cellspacing","0").append("tbody");



function updatePage(topSVG){
	'use strict';
	var min=Math.round(topSVG.xScale.domain()[0]),max=Math.round(topSVG.xScale.domain()[1]),tmpMin,tmpMax;
	if((min<topSVG.prevMinCoord||max>topSVG.prevMaxCoord)&&(min<topSVG.dataMinCoord||max>topSVG.dataMaxCoord)){
		processAjax=1;
		tmpMin=min;
		tmpMax=max;
		if(min>=topSVG.dataMinCoord&& max>topSVG.dataMaxCoord){
			tmpMin=topSVG.dataMaxCoord+1;
		}else if(min<topSVG.dataMinCoord && max<=topSVG.dataMaxCoord){
			tmpMax=topSVG.dataMinCoord-1;
		}
		topSVG.setLoading();
		$.ajax({
				url: pathPrefix+"updateRegion.jsp",
   				type: 'GET',
				data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,fullminCoord:min,fullmaxCoord:max,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism},
				dataType: 'json',
    			success: function(data2){ 
        			topSVG.prevMinCoord=min;
        			topSVG.prevMaxCoord=max;
        			if(min<topSVG.dataMinCoord){
        				topSVG.dataMinCoord=min;
        			}
        			if(max>topSVG.dataMaxCoord){
        				topSVG.dataMaxCoord=max;
        			}
        			//regionfolderName=data2.folderName;
        			topSVG.folderName=data2.folderName;
        			topSVG.updateData();
        			processAjax=0;
    			},
    			error: function(xhr, status, error) {
        			console.log(error);
    			}
			});
	}
	
}

function back(level){
	var tmp={};
	if(history[level].length>1){
		tmp=history[level].pop();
	}else{
		tmp=history[level][0];
	}
	if(chr==tmp.chr){
		if(tmp.start==svgList[level].xScale.domain()[0]  && tmp.stop==svgList[level].xScale.domain()[1]){
			if(history[level].length>1){
				tmp=history[level].pop();
			}else{
				tmp=history[level][0];
			}
		}
		if(level==0){
			$('#geneTxt').val(tmp.chr+":"+tmp.start+"-"+tmp.stop);
		}
		svgList[level].xScale.domain([tmp.start,tmp.stop]);
		svgList[level].scaleSVG.select(".x.axis").call(svgList[level].xAxis);
		svgList[level].redraw();
	}else{//reload

	}
}

//setup event handlers
function mup() {
	var i=0,p,start,width,minx,maxx;
	for (i=0; i<svgList.length; i++){
		if(svgList[i]!==null){
			if(svgList[i].overSettings==0 &&(!isNaN(svgList[i].downx) || !isNaN(svgList[i].downPanx)) ){
				if(i===0){
					updatePage(svgList[i]);
				}
        		svgList[i].downx = Math.NaN;
				svgList[i].downPanx = Math.NaN;
				svgList[i].updateFullData();
				if(i===0){
					DisplayRegionReport();
				}
				if(i==0||i==1){
					var tmp={};
					tmp.chr=chr;
					tmp.start=svgList[i].xScale.domain()[0];
					tmp.stop=svgList[i].xScale.domain()[1];
					history[i].push(tmp);
				}
			}else if(svgList[i].overSettings==0 &&!isNaN(svgList[i].downZoomx)){
				start=svgList[i].downZoomx;
				p = d3.mouse(svgList[i].vis[0][0]);
				svgList[i].downZoomxEnd=p[0];
				width=1;
				if(p[0]<start){
					start=p[0];
					width=svgList[i].downZoomx-start;
				}else{
					width=p[0]-start;
				}
				minx=Math.round(svgList[i].xScale.invert(start));
				maxx=Math.round(svgList[i].xScale.invert(start+width));
				svgList[i].downZoomx = Math.NaN;
				svgList[i].downZoomxEnd = Math.NaN;
				if(i===0){
					$('#geneTxt').val(chr+":"+minx+"-"+maxx);
				}
				d3.select("#Level"+svgList[i].levelNumber).selectAll("svg rect.zoomRect").remove();
				d3.select("#Level"+svgList[i].levelNumber).selectAll("svg text#zoomTextStart").remove();
				d3.select("#Level"+svgList[i].levelNumber).selectAll("svg text#zoomTextEnd").remove();
	            svgList[i].xScale.domain([minx,maxx]);
				svgList[i].scaleSVG.select(".x.axis").call(svgList[i].xAxis);
				svgList[i].redraw();
				svgList[i].updateFullData();
				if(i===0){
					DisplayRegionReport();
				}
				if(i==0||i==1){
					var tmp={};
					tmp.chr=chr;
					tmp.start=minx;
					tmp.stop=maxx;
					history[i].push(tmp);
				}
			}
		}
	}
	
}
function mmove(){
	var i,p,minx,maxx,dist,scaleDist,start,width;
	for (i=0; i<svgList.length; i++){
		if(svgList[i]!==null && svgList[i].overSettings==0){
			if (!isNaN(svgList[i].downx)) {
	          p = d3.mouse(svgList[i].vis[0][0]), rupx = p[0];
	          if (rupx !== 0) {
			  		minx=Math.round(svgList[i].downscalex.domain()[0]);
			  		maxx=Math.round(svgList[i].mw * (svgList[i].downx - svgList[i].downscalex.domain()[0]) / rupx + svgList[i].downscalex.domain()[0]);

					if(maxx<=svgList[i].xMax && minx>=svgList[i].xMin){
						if(i==0){
							$('#geneTxt').val(chr+":"+minx+"-"+maxx);
						}
	            		svgList[i].xScale.domain([minx,maxx]);
						svgList[i].scaleSVG.select(".x.axis").call(svgList[i].xAxis);
						svgList[i].redraw();
					}
	          }
	        }else if(!isNaN(svgList[i].downPanx)){
				p = d3.mouse(svgList[i].vis[0][0]), rupx = p[0];
				  if (rupx !== 0) {
						dist=svgList[i].downPanx-rupx;
						scaleDist=(svgList[i].downscalex.domain()[1]-svgList[i].downscalex.domain()[0])/svgList[i].mw;
						minx=Math.round(svgList[i].downscalex.domain()[0]+dist*scaleDist);
						maxx=Math.round(dist*scaleDist + svgList[i].downscalex.domain()[1]);
						if(maxx<=svgList[i].xMax && minx>=svgList[i].xMin){
							if(i===0){
								$('#geneTxt').val(chr+":"+minx+"-"+maxx);
							}
							svgList[i].xScale.domain([minx,maxx]);
							svgList[i].scaleSVG.select(".x.axis").call(svgList[i].xAxis);
							svgList[i].redraw();
							svgList[i].downPanx=p[0];
						}
					
				  }
			}else if(!isNaN(svgList[i].downZoomx)){
				start=svgList[i].downZoomx;
				p = d3.mouse(svgList[i].vis[0][0]);
				svgList[i].downZoomxEnd=p[0];
				width=1;
				if(p[0]<start){
					start=p[0];
					width=svgList[i].downZoomx-start;
				}else{
					width=p[0]-start;
				}
				minx=Math.round(svgList[i].xScale.invert(start));
				maxx=Math.round(svgList[i].xScale.invert(start+width));
				d3.select("#Level"+svgList[i].levelNumber).selectAll("svg rect.zoomRect")
								.attr("x",start)
								.attr("width",width);
				d3.select("#Level"+svgList[i].levelNumber).selectAll("svg text#zoomTextStart").attr("x",start).attr("y",15).text(numberWithCommas(minx));
				d3.select("#Level"+svgList[i].levelNumber).selectAll("svg text#zoomTextEnd").attr("x",start+width).attr("y",50).text(numberWithCommas(maxx));
			}
		}
	}
}

d3.select('html')
      .on("mousemove", mmove)
	  .on("mouseup", mup);

/*$(document).on('click','span.viewMenu', function (event){
	var baseName = $(this).attr("name");
    $('span.viewMenu.selected').removeClass("selected");
    $("span[name='"+baseName+"']").addClass("selected");
    //load default view
    defaultView=baseName;
    svgList[0].removeAllTracks();
    loadState(0);
});*/

$(window).resize(function (){
	for (var i=0; i<svgList.length; i++){
		if(svgList[i]!=null){
			svgList[i].resize($(window).width()-25);
		}
	}
});

$(document).on("click",".closeBtn",function(){
					var setting=new String($(this).attr("id"));
					setting=setting.substr(6);
					
					//if($("."+setting).is(":visible")){
						//alert("visible fading out");
					//console.log(setting);
					//console.log($("."+setting));
					$("."+setting).fadeOut("fast");
					//}
					if(setting.indexOf("viewsLevel")>-1){
						$("div.trackLevel"+setting.substr(setting.length-1)).fadeOut("fast");
					}
					return false;
				});

/*$(document).on("click",".settings",function(){
					var setting=$(this).attr("id");
					if(!$("."+setting).is(":visible")){
						var p=$(this).position();
						$("."+setting).css("top",p.top-3).css("left",p.left-267);
						$("."+setting).fadeIn("fast");
						//var tmpStr=new String(setting);
						//setupSettingUI(tmpStr.substr(tmpStr.length-1));
					}else{
						$("."+setting).fadeOut("fast");
					}
					return false;
				});*/

$(document).on("click",".viewSelect",function(){
					var setting=$(this).attr("id");
					var level=setting.substr(setting.length-1);
					if(!$(".viewsLevel"+level).is(":visible")){
						var p=$(this).parent().parent().position();
						console.log(p);
						var top=p.top+5;
						$(".viewsLevel"+level).css("top",top).css("left",$(window).width()-610);
						$(".viewsLevel"+level).fadeIn("fast");
						$("#trackSettingDialog").hide();
						tt.transition()        
				                .duration(200)      
				                .style("opacity", 0); 
						//$(".testToolTip").hide();
						//var tmpStr=new String(setting);
						//setupSettingUI(tmpStr.substr(tmpStr.length-1));
					}else{
						$(".viewsLevel"+level).fadeOut("fast");
					}
					return false;
				});

$(document).on("change","input[name='optioncbx']",function(){
	var idStr=new String($(this).attr("id"));
	var cbxInd=idStr.indexOf("CBX");
	var prefix=new String(idStr.substr(0,cbxInd));
	var level=idStr.substr(cbxInd+3,1);
	redrawTrack(level,prefix);
});


$(document).on("change","input[name='imgCBX']", function(){
	var idStr=new String($(this).attr("id"));
	var cbxInd=idStr.indexOf("CBX");
	var prefix=new String(idStr.substr(0,cbxInd));
	var level=idStr.substr(cbxInd+3,1);
	svgList[level].redraw();
	DisplayRegionReport();
});

$(document).on("click",".reset",function(){
	var id=new String($(this).attr("id"));
	var level=id.substr(id.length-1);
	if(id.indexOf("resetImage")==0){
		if(level==0){
			$('#geneTxt').val(chr+":"+initMin+"-"+initMax);
	        svgList[0].xScale.domain([initMin,initMax]);
			svgList[0].scaleSVG.select(".x.axis").call(svgList[0].xAxis);
			svgList[0].redraw();
		}
	}else if(id.indexOf("resetTracks")==0){
		svgList[level].removeAllTracks();
		setupDefaultView(level);
		//saveToCookie(level);
	}
});



function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function displayHelpFirstTime(){
	if(navigator.userAgent.toLowerCase().indexOf("phantomjs")==-1){
		if($.cookie("genomeBrowserHelp")!=null){
	    	var trackListObj=$.cookie("genomeBrowserHelp");
	    	if(trackListObj==siteVer){

	    	}else{
	    		$("a#fbhelp1").click();
	    		$.cookie("genomeBrowserHelp",siteVer);
	    	}
	    }else{
			$("a#fbhelp1").click();
			$.cookie("genomeBrowserHelp",siteVer);
	    }
	}
}

function removeTrack(level,track){
	if(svgList[level]!=undefined){
		svgList[level].removeTrack(track);
	}
}

function redrawTrack(level,track){

	svgList[level].redrawTrack(track);
}

function changeTrackHeight(id,val){
	if(val>0){
		var size=val+"px";
		$("#Scroll"+id).css({"max-height":size,"overflow":"auto"});
	}else{
		$("#Scroll"+id).css({"max-height":'',"overflow":"hidden"});
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
	var tmpContext=contextPath +"/"+ pathPrefix;
	if(pathPrefix==""){
		tmpContext="";
	}
	$.ajax({
				url:  tmpContext+"settingsMenu.jsp",
   				type: 'GET',
				data: {level: level, organism: organism,type: type},
				dataType: 'html',
    			success: function(data2){
    				$("#imageMenu"+level).remove();
    				d3.select("div#imageMenu").append("div").attr("id","imageMenu"+level);
    				$("#imageMenu"+level).html(data2);
    			},
    			error: function(xhr, status, error) {
    				$("#imageMenu"+level).remove();
    				d3.select("div#imageMenu").append("div").attr("id","imageMenu"+level);
        			$('#imageMenu'+level).append("<div class=\"settingsLevel"+level+"\">An error occurred generating this menu.  Please try back later.</div>");
    			},
    			async:   false
			});
}


//Load/Save settings to/from cookies
function loadStateFromString(state,imgState,levelInd,svg){
	/*if(svgList[levelInd]!=undefined){
		svgList[levelInd].removeAllTracks();
	}*/
	//console.log(state);
	//TODO MAKE SURE TO LOAD CUSTOM TRACKS ON LOADING TRACK EDITOR
	loadSavedConfigTracks(state,levelInd,svg);
	loadImageState(imgState,levelInd);
}



function loadSavedConfigTracks(trackListObj,levelInd,curSvg){
	var trackArray=trackListObj.split(";");
	var addedCount=0;
	var tmpSvg=NaN;
	if(levelInd<90){
		tmpSvg=svgList[levelInd];
	}else{
		tmpSvg=curSvg;
	}
	for(var m=0;m<trackArray.length;m++){
		var trackVars=trackArray[m].split(",");
		//console.log("loadingSavedTrack");
		//console.log(trackVars);
		if( (organism=="Rn" && mouseOnly[trackVars[0]]==undefined) || (organism=="Mm" && ratOnly[trackVars[0]]== undefined)) {
    		if(trackVars[0]!="") {
    			addedCount++;
    			var ext="";
    			if(trackVars.length>2){
    				for(var n=2;n<trackVars.length;n++){
    					if(n==2){
    						ext=trackVars[n];
    					}else{
    						ext=ext+","+trackVars[n];
    					}
    				}
    			}
    			if(levelInd==1){
    				ext=ext+",DrawTrx";
    			}
    			
    			tmpSvg.addTrack(trackVars[0],trackVars[1],ext,0);
    			
    		}
		}
	}
	if(addedCount==0){
		setupDefaultView(levelInd);
		//saveToCookie(levelInd);
	}
	/*}else{
		setupDefaultView(levelInd);
    	saveToCookie(levelInd);
	}*/
	/*if(hasOldTrackValues){
		saveToCookie(levelInd);
	}*/
}

function loadImageState(trackListObj,levelInd){
	/*if($.cookie("imgstate"+defaultView+levelInd)!=null){
    	var trackListObj=$.cookie("imgstate"+defaultView+levelInd);*/
    if(trackListObj!=undefined && trackListObj!=""){
	    var trackArray=trackListObj.split(";");
	    for(var m=0;m<trackArray.length;m++){
			var trackVars=trackArray[m].split("=");
			var tmp=new String(trackVars[0]);
			if(tmp.indexOf("displaySelect")==0){
				changeTrackHeight("Level"+levelInd,trackVars[1]);
			}
	    }
	}	

	//}	
}

function setupDefaultView(levelInd){
	$("input[name='trackcbx']").each(function(){
    		if($(this).is(":checked")){
    			$(this).prop('checked', false);
    		}
    	});
	if(defaultView=="viewGenome"){
		var addtl="annotOnly";
		if(levelInd==1){
			addtl=addtl+",DrawTrx";
		}
		$("div.settingsLevel"+levelInd+" #ensemblcodingCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #ensemblnoncodingCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #ensemblsmallncCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #refSeqCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #snpSHRHCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #snpBNLXCBX"+levelInd).prop('checked',true);
		svgList[levelInd].addTrack("ensemblcoding",3,addtl,0);
    	svgList[levelInd].addTrack("ensemblnoncoding",3,addtl,0);
    	svgList[levelInd].addTrack("ensemblsmallnc",3,addtl,0);
    	svgList[levelInd].addTrack("refSeq",3,addtl,0);
		svgList[levelInd].addTrack("snpBNLX",1,"",0);
    	svgList[levelInd].addTrack("snpSHRH",1,"",0);
    	if(levelInd!=1){
    		$("div.settingsLevel"+levelInd+" #qtlCBX"+levelInd).prop('checked',true);
			svgList[levelInd].addTrack("qtl",3,"",0);
		}
	}else if(defaultView=="viewTrxome"){
		var addtl="trxOnly";
		if(levelInd==1){
			addtl=addtl+",DrawTrx";
		}
		$("div.settingsLevel"+levelInd+" #braincodingCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #spliceJnctCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #brainnoncodingCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #liverTotalCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #liverspliceJnctCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #probeCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #brainsmallncCBX"+levelInd).prop('checked',true);
		svgList[levelInd].addTrack("braincoding",3,addtl,0);
		svgList[levelInd].addTrack("spliceJnct",3,addtl,0);
		svgList[levelInd].addTrack("liverTotal",3,addtl,0);
		svgList[levelInd].addTrack("liverspliceJnct",3,addtl,0);
    	svgList[levelInd].addTrack("brainnoncoding",3,addtl,0);
    	svgList[levelInd].addTrack("brainsmallnc",3,addtl,0);
    	svgList[levelInd].addTrack("probe",3,"",0);
	}else if(defaultView=="viewAll"){
		var addtl="all";
		if(levelInd==1){
			addtl=addtl+",DrawTrx";
		}
		$("div.settingsLevel"+levelInd+" #ensemblcodingCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #braincodingCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #spliceJnctCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #liverTotalCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #liverspliceJnctCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #ensemblnoncodingCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #brainnoncodingCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #ensemblsmallncCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #brainsmallncCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #refSeqCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #probeCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #snpSHRHCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #snpBNLXCBX"+levelInd).prop('checked',true);
		svgList[levelInd].addTrack("ensemblcoding",3,addtl,0);
		svgList[levelInd].addTrack("braincoding",3,addtl,0);
		svgList[levelInd].addTrack("spliceJnct",3,addtl,0);
		svgList[levelInd].addTrack("liverTotal",3,addtl,0);
		svgList[levelInd].addTrack("liverspliceJnct",3,addtl,0);
    	svgList[levelInd].addTrack("ensemblnoncoding",3,addtl,0);
    	svgList[levelInd].addTrack("brainnoncoding",3,addtl,0);
    	svgList[levelInd].addTrack("ensemblsmallnc",3,addtl,0);
    	svgList[levelInd].addTrack("brainsmallnc",3,addtl,0);
    	svgList[levelInd].addTrack("refSeq",3,addtl,0);
    	svgList[levelInd].addTrack("snpBNLX",1,"",0);
    	svgList[levelInd].addTrack("snpSHRH",1,"",0);
    	svgList[levelInd].addTrack("probe",3,"",0);
    	if(levelInd!=1){
    		$("div.settingsLevel"+levelInd+" #qtlCBX"+levelInd).prop('checked',true);
    		svgList[levelInd].addTrack("qtl",3,"",0);
    	}
	}
}


function calculateBin(len,width){
		var bpPerPixel=len/width;
		bpPerPixel=Math.floor(bpPerPixel);
		var bpPerPixelStr=new String(bpPerPixel);
		var firstDigit=bpPerPixelStr.substr(0,1);
		var firstNum=firstDigit*Math.pow(10,(bpPerPixelStr.length-1));
		var bin=firstNum/2;
		bin=Math.floor(bin);
		if(bin<5){
			bin=0;
		}
		return bin;
}

//D3 helper functions
function key(d) {if(d!=undefined){return d.getAttribute("ID");}else{return "unknown"}};
function keyName(d) {if(d!=undefined){return d.getAttribute("name");}else{return "unknown"}};
function keyStart(d) {if(d!=undefined){return d.getAttribute("start");}else{return "unknown"}};
function keyTissue(d,tissue){if(d!=undefined){return d.getAttribute("ID")+tissue;}else{return "unknown"}};
function keyPos(d){if(d!=undefined){return d.pos;}else{return "unknown"}};
function keyID(d){if(d!=undefined){return d.id;}else{return "unknown"}};

//SVG functions
function GenomeSVG(div,imageWidth,minCoord,maxCoord,levelNumber,title,type){
	var that={};
	that.isToolTip=0;
	that.folderName="";
	that.selectedTrackSetting="";
	that.trackListHash={};
	that.overSettings=0;
	if(levelNumber==0){
		that.folderName=regionfolderName;
	}
	var tmp={};
	tmp.chr=chr;
	tmp.start=minCoord;
	tmp.stop=maxCoord;
	
	history[levelNumber].push(tmp);

	that.get=function(attr){return that[attr];};
	that.getTrackData=function (track){
			var data=new Array();
			for(var l=0;l<that.trackList.length;l++){
				if(that.trackList[l]!=undefined && that.trackList[l].trackClass==track){
					data=that.trackList[l].data;
				}
			}
			return data;
	};
	that.getTrack=function (track){
			var tr;
			tr=that.trackListHash[track];
			/*for(var l=0;l<that.trackList.length;l++){
				if(that.trackList[l]!=undefined && that.trackList[l].trackClass==track){
					tr=that.trackList[l];
				}
			}*/
			return tr;
	};

	that.addTrackErrorRemove=function(svg,selector){
		var remove=svg.append("g").attr("class","removeErrorTrack")
											.attr("id",track+"_"+that.levelNumber)
											.attr("transform", "translate("+(that.width-40)+",0)");
		remove.append("image").attr("width","16px")
										.attr("height","16px")
										.attr("xlink:href","data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJ"
															+"bWFnZVJlYWR5ccllPAAAARBJREFUeNpi/P//PwMlgBHZgNNajGCO6bX/jNgUY5UHGQDCpzSB1Jn/"
															+"YAxmQ8UJyaNKNitAMJoifPJMIFecvA4ktitCnPT7DwPDJlkG08X/wU4GYRAbJAaWY4CoBetBDoMp"
															+"jIz/c4rlIKI/v0HohNcQeoEohGbngqjtfcSQ8x8SDiiBCDYkAar41zfUEGSDal7wGq4ZwwC4IT48"
															+"WKNsypYvKJpBgAVdkbkmkHj3DasBYDk0wIQez+AA+/kPK4YFLNaEBNccC3QhF45kB3IYyBCgGnhi"
															+"QolnEA3CxhA8mQGCYXwwhqqFpQOwAWBFWDTDEhKGIUjy8KQ6mwG7ZmyGIMtjpAMQjR5V+OQZKc3O"
															+"AAEGAInHQgT+/r+xAAAAAElFTkSuQmCC")
										.attr("pointer-events", "all")
										.style("cursor","pointer")
										.on("click",function(d){
											d3.select(selector).remove();
										})
										.on("mouseover",function(){
											that.overSettings=1;
											$("#mouseHelp").html("");
										})
										.on("mouseout",function(){
											that.overSettings=0;
											$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
										});
	};

	that.addTrack=function (track,density,additionalOptions,retry){
		//console.log("Add Track:"+track);
		if(that.forceDrawAsValue=="Trx"){
			var additionalOptionsStr=new String(additionalOptions);
			if(additionalOptionsStr.indexOf("DrawTrx")==-1){
				additionalOptions=additionalOptions+"DrawTrx,";
			}
		}
		var folderStr=new String(that.folderName);
		if(folderStr.indexOf("_"+that.xScale.domain()[0]+"_")<0 || folderStr.indexOf("_"+that.xScale.domain()[1]+"_")<0){
			//update folderName because it doesn't match the current range.  that folder should exist, but getFullPath.jsp will call methods to generate if needed
			$.ajax({
					url:  pathPrefix +"getFullPath.jsp",
	   				type: 'GET',
	   				async: false,
					data: {chromosome: chr,minCoord:that.xScale.domain()[0],maxCoord:that.xScale.domain()[1],panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism},
					dataType: 'json',
	    			success: function(data2){ 
	        			that.folderName=data2.folderName;
	        			if(levelNumber==0){
							regionfolderName=that.folderName;
						}
	    			},
	    			error: function(xhr, status, error) {
	        			console.log(error);
	    			}
				});
		}
		var newTrack=null;
		
		//Setup the track div if not setup
		var tmpvis=d3.select("#Level"+that.levelNumber+track);
		if(tmpvis[0][0]==null){
					var dragDiv=that.topLevel.append("li").attr("class","draggable"+that.levelNumber).attr("id","li"+track).style("margin-bottom","-3px");
					//dragDiv.append("span").style("background","#CECECE").style("height","100%").style("width","10px").style("display","inline-block");
					var svg = dragDiv.append("svg:svg")
					.attr("width", that.width)
					.attr("height", 30)
					.attr("class", "track")
					.attr("id","Level"+that.levelNumber+track)
					//.attr("pointer-events", "all")
					.style("cursor", "move")
					
					.on("mouseover", function(){
						if(overSelectable==0){
							if(that.defaultMouseFunct=="dragzoom"){
								$("#mouseHelp").html("<B>Zoom:</B> Click and drag to select a region to zoom in. <B>Navigate or Reorder Tracks:</B> Select the appropriate function at the top left of the image.");
							}else if(that.defaultMouseFunct=="pan"){
								$("#mouseHelp").html("<B>Navigate:</B> Move along Genome by clicking and dragging in desired direction. <B>Zoom or Reorder Tracks:</B> Select the appropriate function at the top left of the image.");
							}else if(that.defaultMouseFunct=="reorder"){
								$("#mouseHelp").html("<B>Reorder Tracks:</B> Click on the track and drag up or down to desired location. <B>Zoom or Navigate:</B> Select the appropriate function at the top left of the image.");
							}	
						}
					})
					.on("mouseout", function(){
						if(overSelectable==0){
							$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
						}
					});
					//.on("mousedown", that.panDown);
					//that.svg.append("text").text(that.label).attr("x",that.gsvg.width/2-20).attr("y",12);
					var lblStr=new String("Loading...");
					svg.append("text").text(lblStr).attr("x",that.width/2-(lblStr.length/2)*7.5).attr("y",12).attr("id","trkLbl");
					//var info=svg.append("g").attr("class","infoIcon").attr("transform", "translate(" + (that.width/2+((lblStr.length/2)*7.5)+16) + ",0)");
					var info=svg.append("g").attr("class","infoIcon")
											.attr("transform", "translate("+(that.width-20)+",0)")
											.style("cursor","pointer")
											.attr("track",track)
											.attr("title",track)
											.on("mouseover",function(){
												var tmpTrack=$(this).attr("track");
												var d=trackInfo[tmpTrack];
												var ttsr=$(this).tooltipster({
													position: 'top-right',
													maxWidth: 250,
													offsetX: 24,
													offsetY: 5,
													contentAsHTML:true,
													//arrow: false,
													interactive: true,
											   		interactiveTolerance: 350
												});
												ttsr.tooltipster('content',d.Description);
												ttsr.tooltipster('show');
											})
											.on("mouseout",function(){
												$(this).tooltipster('hide');
											});
					info.append("rect")
										.attr("x",0)
										.attr("y",0)
										.attr("rx",3)
										.attr("ry",3)
								    	.attr("height",14)
										.attr("width",14)
										.attr("fill","#A7C5E2")
										.attr("stroke","#7795B2");
					info.append("text").attr("x",2.5).attr("y",12).attr("style","font-family:monospace;font-weight:bold;").attr("fill","#FFFFFF").text("i");
					var settings=svg.append("g").attr("class","settings")
											.attr("id",track+"_"+that.levelNumber)
											.attr("transform", "translate("+(that.width-40)+",0)")
											;
					settings.append("image").attr("width","16px")
										.attr("height","16px")
										.attr("xlink:href","data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAAAmJLR0QA/4ePzL8AAAAJcEhZcwAA"+
												"AEgAAABIAEbJaz4AAAAJdnBBZwAAABAAAAAQAFzGrcMAAAGASURBVCjPlZGxaxNhAMV/9128JF/u"+
												"LsndaVoPhEopFW2RGAXpKOpQHNwEHXTVf0Chm6OL4OhccFHoYKGFQgMOLoIUEQfBSZCUBtI2yaVt"+
												"8hwarI6+5cF7v+HBg/+RH1U3q2/+zdxjK0znO0EhWgru20t2J/fZnXInjrYBHAD/ut30OkW3FBUR"+
												"fXrtLDroduf2f4ABaARlLzkdRwFFLCFxFBMdPezDGLj5PT/yMChLNqLm6MDFI2eSvT9Dzj2/qLqu"+
												"7q4+0mXVlx83BnVdUPrC9wEor6Sa0awW38oCKLy1NqsZpap8AgP5BTgk41fP6QE4u60s4xCwCQAr"+
												"DxofUk2q1i5NAJSmantnlWphvXkXABXf3U6GsSrytwsvC6+CTlWxat2v1+SNR96ZLA9ChSrJyspX"+
												"qFDlwfkUIAfwcbrvGRwEwAgzEjLDlJ9joPXl6VK639h5cm9rEebfv14emOaZZ9+ck0uUKJTXnret"+
												"fHvrik7JU+W4+QsCOdzAsOEMT7LfaTGJVMIWBCwAAAAldEVYdGRhdGU6Y3JlYXRlADIwMTAtMDIt"+
												"MTFUMDA6NTM6MDItMDY6MDDZzrlFAAAAJXRFWHRkYXRlOm1vZGlmeQAyMDA5LTA4LTE4VDAyOjI2"+
												"OjEwLTA1OjAw2ytpkgAAAABJRU5ErkJggg==")
										.attr("pointer-events", "all")
											.style("cursor","pointer")
											.on("click",function(d){
												if(track!=that.selectedTrackSetting){
													var trackObj=that.getTrack(track);
													trackObj.generateSettingsDiv("div#trackSettingContent");
													that.selectedTrackSetting=track;
													var p=$(this).position();
													$('#trackSettingDialog').css("top",p.top).css("left",$(window).width()-380);
													$('#trackSettingDialog').fadeIn("fast");
												}else{
													that.selectedTrackSetting="";
													$('#trackSettingDialog').fadeOut("fast");
												}
												return false;
											})
											.on("mouseover",function(){
												that.overSettings=1;
												$("#mouseHelp").html("Track Settings: Click to access track settings or quickly remove the track from the current view.");
											})
											.on("mouseout",function(){
												that.overSettings=0;
												$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
											});

		}
		//end of track div setup

		var success=0;
		if(track=="genomeSeq"){
			var newTrack=SequenceTrack(that,track,"Reference Genomic Sequence",additionalOptions);
			that.addTrackList(newTrack);
		}else if(track.indexOf("noncoding")>-1){
				d3.xml(dataPrefix+"tmpData/regionData/"+that.folderName+"/"+track+".xml",function (error,d){
					if(error){
						if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								that.addTrack(track,density,additionalOptions,retry+1);
							},time);
						}else if(success!=1){
							d3.select("#Level"+that.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+track).attr("height", 15);
							that.addTrackErrorRemove(d3.select("#Level"+that.levelNumber+track),"#Level"+that.levelNumber+track);
						}
					}else{
						if(d==null){
							if(retry>=4){
								var data=new Array();
								var newTrack= GeneTrack(that,data,track,"Long Non-Coding / Non-PolyA+ Genes",additionalOptions);
								that.addTrackList(newTrack);
							}else{
								setTimeout(function (){
									that.addTrack(track,density,additionalOptions,4);
								},5000);
							}
						}else{
							var data=d.documentElement.getElementsByTagName("Gene");
							var newTrack= GeneTrack(that,data,track,"Long Non-Coding / Non-PolyA+ Genes",additionalOptions);
							that.addTrackList(newTrack);
							if(selectGene!=""){
								newTrack.setSelected(selectGene);
							}
						}
					}
				});
		}else if(track.indexOf("coding")>-1){
				d3.xml(dataPrefix+"tmpData/regionData/"+that.folderName+"/"+track+".xml",function (error,d){
					if(error){
						if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								that.addTrack(track,density,additionalOptions,retry+1);
							},time);
						}else{
							d3.select("#Level"+that.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+track).attr("height", 15);
							that.addTrackErrorRemove(d3.select("#Level"+that.levelNumber+track),"#Level"+that.levelNumber+track);
						}
					}else{
						if(d==null){
							if(retry>=4){
								var data=new Array();
								var newTrack= GeneTrack(that,data,track,"Protein Coding / PolyA+",additionalOptions);
								that.addTrackList(newTrack);
							}else{
								setTimeout(function (){
									that.addTrack(track,density,additionalOptions,4);
								},5000);
							}
						}else{
							var data=d.documentElement.getElementsByTagName("Gene");
							var newTrack= GeneTrack(that,data,track,"Protein Coding / PolyA+",additionalOptions);
							that.addTrackList(newTrack);
							if(selectGene!=""){
								newTrack.setSelected(selectGene);
							}
						}
					}
				});
		}else if(track.indexOf("smallnc")>-1){
				d3.xml(dataPrefix+"tmpData/regionData/"+that.folderName+"/"+track+".xml",function (error,d){
					if(error){
						if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								that.addTrack(track,density,additionalOptions,retry+1);
							},time);
						}else{
							d3.select("#Level"+that.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+track).attr("height", 15);
							that.addTrackErrorRemove(d3.select("#Level"+that.levelNumber+track),"#Level"+that.levelNumber+track);
						}
					}else{
						if(d==null){
							if(retry>=4){
								var data=new Array();
								var newTrack= GeneTrack(that,data,track,"Small RNA (<200 bp) Genes",additionalOptions);
								that.addTrackList(newTrack);
							}else{
								setTimeout(function (){
									that.addTrack(track,density,additionalOptions,4);
								},5000);
							}
						}else{
							var data=d.documentElement.getElementsByTagName("smnc");
							var newTrack= GeneTrack(that,data,track,"Small RNA (<200 bp) Genes",additionalOptions);
							that.addTrackList(newTrack);
							if(selectGene!=""){
								newTrack.setSelected(selectGene);
							}
						}
					}
				});
		}else if(track=="liverTotal" || track=="heartTotal" || track=="brainTotal"){
				var lbl="Liver Reconstructed";
				if(track=="heartTotal"){
					lbl="Heart Reconstructed";
				}else if(track=="brainTotal"){
					lbl="Whole Brain Reconstructed";
				}

				d3.xml(dataPrefix+"tmpData/regionData/"+that.folderName+"/"+track+".xml",function (error,d){
					if(error){
						if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								that.addTrack(track,density,additionalOptions,retry+1);
							},time);
						}else{
							d3.select("#Level"+that.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+track).attr("height", 15);
							that.addTrackErrorRemove(d3.select("#Level"+that.levelNumber+track),"#Level"+that.levelNumber+track);
						}
					}else{
						if(d==null){
							if(retry>=4){
								var data=new Array();
								var newTrack= GeneTrack(that,data,track,lbl,additionalOptions);
								that.addTrackList(newTrack);
							}else{
								setTimeout(function (){
									that.addTrack(track,density,additionalOptions,4);
								},5000);
							}
						}else{
							var data=d.documentElement.getElementsByTagName("Gene");
							var newTrack= GeneTrack(that,data,track,lbl,additionalOptions);
							that.addTrackList(newTrack);
							if(selectGene!=""){
								newTrack.setSelected(selectGene);
							}
						}
					}
				});
		}else if(track.indexOf("refSeq")==0){
				var include=$("#"+track+that.levelNumber+"Select").val();
				var tmpMin=that.xScale.domain()[0];
				var tmpMax=that.xScale.domain()[1];
				var file=dataPrefix+"tmpData/regionData/"+that.folderName+"/"+track+".xml";
				d3.xml(file,function (error,d){
					if(error){
						console.log(error);
						if(retry==0){
							$.ajax({
								url: contextPath +"/"+ pathPrefix +"generateTrackXML.jsp",
				   				type: 'GET',
								data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: track, folder: that.folderName},
								dataType: 'json',
				    			success: function(data2){
				    				
				    			},
				    			error: function(xhr, status, error) {
				        			
				    			}
							});
						}
						if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								that.addTrack(track,density,additionalOptions,retry+1);
							},time);
						}else{
							d3.select("#Level"+that.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+track).attr("height", 15);
							that.addTrackErrorRemove(d3.select("#Level"+that.levelNumber+track),"#Level"+that.levelNumber+track);
						}
					}else{
						if(d==null){
							if(retry>=4){
								var data=new Array();
								var newTrack= RefSeqTrack(that,data,track,"Ref Seq Genes",additionalOptions);
								that.addTrackList(newTrack);
							}else{
								setTimeout(function (){
									that.addTrack(track,density,additionalOptions,4);
								},5000);
							}
						}else{
							var data=d.documentElement.getElementsByTagName("Gene");
							var newTrack= RefSeqTrack(that,data,track,"Ref Seq Genes",additionalOptions);
							that.addTrackList(newTrack);
						}
					}
				});
		}else if(track.indexOf("snp")==0){
				//var include=$("#"+track+that.levelNumber+"Select").val();
				var tmpMin=that.xScale.domain()[0];
				var tmpMax=that.xScale.domain()[1];
				var file=dataPrefix+"tmpData/regionData/"+that.folderName+"/"+track+".xml";
				d3.xml(file,function (error,d){
					if(error){
						console.log(error);
						if(retry==0){
							$.ajax({
								url: contextPath +"/"+ pathPrefix +"generateTrackXML.jsp",
				   				type: 'GET',
								data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: track, folder: that.folderName},
								dataType: 'json',
				    			success: function(data2){
				    				
				    			},
				    			error: function(xhr, status, error) {
				        			
				    			}
							});
						}
						if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=20000;
							}
							setTimeout(function (){
								that.addTrack(track,density,additionalOptions,retry+1);
							},time);
						}else{
							d3.select("#Level"+that.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+track).attr("height", 15);
							that.addTrackErrorRemove(d3.select("#Level"+that.levelNumber+track),"#Level"+that.levelNumber+track);
						}
					}else{
						if(d==null){
							if(retry>=4){
								var snp=new Array();
								var newTrack= SNPTrack(that,snp,track,density,additionalOptions);
								that.addTrackList(newTrack);
							}else{
								setTimeout(function (){
									that.addTrack(track,density,additionalOptions,4);
								},5000);
							}
						}else{
							var snp=d.documentElement.getElementsByTagName("Snp");
							var newTrack= SNPTrack(that,snp,track,density,additionalOptions);
							that.addTrackList(newTrack);
						}
					}
				});
		}else if(track=="qtl"){
				d3.xml(dataPrefix+"tmpData/regionData/"+that.folderName+"/qtl.xml",function (error,d){
					if(error){
						if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								that.addTrack(track,density,additionalOptions,retry+1);
							},time);
						}else{
							d3.select("#Level"+that.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+track).attr("height", 15);
							that.addTrackErrorRemove(d3.select("#Level"+that.levelNumber+track),"#Level"+that.levelNumber+track);
						}
					}else{
						if(d==null){
							if(retry>=4){
								var qtl=new Array();
								var newTrack= QTLTrack(that,qtl,track,density);
								that.addTrackList(newTrack);
							}else{
								setTimeout(function (){
									that.addTrack(track,density,additionalOptions,4);
								},5000);
							}
						}else{
							var qtl=d.documentElement.getElementsByTagName("QTL");
							var newTrack= QTLTrack(that,qtl,track,density);
							that.addTrackList(newTrack);
							//success=1;
						}
					}
				});
		}else if(track=="trx"){
				var txList=getAllChildrenByName(getFirstChildByName(that.selectedData,"TranscriptList"),"Transcript");
				var newTrack= TranscriptTrack(that,txList,track,density);
				that.addTrackList(newTrack);

		}else if(track=="probe"){
				d3.xml(dataPrefix+"tmpData/regionData/"+that.folderName+"/probe.xml",function (error,d){
					if(error){
						if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								that.addTrack(track,density,additionalOptions,retry+1);
							},time);
						}else{
							d3.select("#Level"+that.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+track).attr("height", 15);
							that.addTrackErrorRemove(d3.select("#Level"+that.levelNumber+track),"#Level"+that.levelNumber+track);
						}
					}else{
						if(d==null){
							if(retry>=4){
								probe=new Array();
								var newTrack= ProbeTrack(that,probe,track,"Affy Exon 1.0 ST Probe Sets",density+","+additionalOptions);
								that.addTrackList(newTrack);
							}else{
								setTimeout(function (){
								that.addTrack(track,density,additionalOptions,4);
								},5000);
							}
						}else{
							var probe=d.documentElement.getElementsByTagName("probe");
							var newTrack= ProbeTrack(that,probe,track,"Affy Exon 1.0 ST Probe Sets",density+","+additionalOptions);
							that.addTrackList(newTrack);
							//success=1;
						}
					}
				});
		}else if(track=="helicos"||track.indexOf("illuminaTotal")>-1||track.indexOf("illuminaSmall")>-1||track=="illuminaPolyA"){
				var tmpMin=that.xScale.domain()[0];
				var tmpMax=that.xScale.domain()[1];
				var len=tmpMax-tmpMin;
				var tmpBin=calculateBin(len,that.width);
				var file=dataPrefix+"tmpData/regionData/"+that.folderName+"/count"+track+".xml";
				if(tmpBin>0){
					tmpMin=tmpMin-(tmpMin%tmpBin);
					tmpMax=tmpMax+(tmpBin-(tmpMax%tmpBin));
					file=dataPrefix+"tmpData/regionData/"+that.folderName+"/tmp/"+tmpMin+"_"+tmpMax+".bincount."+tmpBin+"."+track+".xml";
				}
				d3.xml(file,function (error,d){
					if(error){
						if(retry==0){
							$.ajax({
								url: contextPath +"/"+ pathPrefix +"generateTrackXML.jsp",
				   				type: 'GET',
								data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: track, folder: that.folderName,binSize:tmpBin},
								dataType: 'json',
				    			success: function(data2){
				    				
				    			},
				    			error: function(xhr, status, error) {
				        			
				    			}
							});
						}
						if(retry<6){//wait before trying again
							var time=5000;
							if(retry==1){
								time=10000;
							}
							setTimeout(function (){
								that.addTrack(track,density,additionalOptions,retry+1);
							},time);
						}else{
							d3.select("#Level"+that.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+track).attr("height", 15);
							that.addTrackErrorRemove(d3.select("#Level"+that.levelNumber+track),"#Level"+that.levelNumber+track);
						}
					}else{
						//console.log(d);
						if(d==null){
							if(retry>=4){
								data=new Array();
								if(track=="helicos"){
									newTrack= HelicosTrack(that,data,track,1);
								}else if(track=="illuminaTotal"){
									newTrack= IlluminaTotalTrack(that,data,track,1);
								}else if(track=="illuminaSmall"){
									newTrack= IlluminaSmallTrack(that,data,track,1);
								}else if(track=="illuminaPolyA"){
									newTrack= IlluminaPolyATrack(that,data,track,1);
								}else if(track=="liverilluminaTotalPlus"){
									newTrack= LiverIlluminaTotalPlusTrack(that,data,track,1);
								}else if(track=="liverilluminaTotalMinus"){
									newTrack= LiverIlluminaTotalMinusTrack(that,data,track,1);
								}else if(track=="heartilluminaTotalPlus"){
									newTrack= HeartIlluminaTotalPlusTrack(that,data,track,1);
								}else if(track=="heartilluminaTotalMinus"){
									newTrack= HeartIlluminaTotalMinusTrack(that,data,track,1);
								}else if(track=="brainilluminaTotalPlus"){
									newTrack= BrainIlluminaTotalPlusTrack(that,data,track,1);
								}else if(track=="brainilluminaTotalMinus"){
									newTrack= BrainIlluminaTotalMinusTrack(that,data,track,1);
								}else if(track=="liverilluminaSmall"){
									newTrack= LiverIlluminaSmallTrack(that,data,track,1);
								}else if(track=="heartilluminaSmall"){
									newTrack= HeartIlluminaSmallTrack(that,data,track,1);
								}
								that.addTrackList(newTrack);
							}else{
								setTimeout(function (){
									that.addTrack(track,density,additionalOptions,4);
								},3000);
							}
						}else{
							var data=d.documentElement.getElementsByTagName("Count");
							var newTrack;
							if(track=="helicos"){
								newTrack= HelicosTrack(that,data,track,1);
							}else if(track=="illuminaTotal"){
								newTrack= IlluminaTotalTrack(that,data,track,1);
							}else if(track=="illuminaSmall"){
								newTrack= IlluminaSmallTrack(that,data,track,1);
							}else if(track=="illuminaPolyA"){
								newTrack= IlluminaPolyATrack(that,data,track,1);
							}else if(track=="liverilluminaTotalPlus"){
								newTrack= LiverIlluminaTotalPlusTrack(that,data,track,1);
							}else if(track=="liverilluminaTotalMinus"){
								newTrack= LiverIlluminaTotalMinusTrack(that,data,track,1);
							}else if(track=="heartilluminaTotalPlus"){
									newTrack= HeartIlluminaTotalPlusTrack(that,data,track,1);
							}else if(track=="heartilluminaTotalMinus"){
									newTrack= HeartIlluminaTotalMinusTrack(that,data,track,1);
							}else if(track=="brainilluminaTotalPlus"){
									newTrack= BrainIlluminaTotalPlusTrack(that,data,track,1);
							}else if(track=="brainilluminaTotalMinus"){
									newTrack= BrainIlluminaTotalMinusTrack(that,data,track,1);
							}else if(track=="liverilluminaSmall"){
									newTrack= LiverIlluminaSmallTrack(that,data,track,1);
								}else if(track=="heartilluminaSmall"){
									newTrack= HeartIlluminaSmallTrack(that,data,track,1);
								}
							that.addTrackList(newTrack);
							//success=1;
						}
					}
				});
		}else if(track.indexOf("spliceJnct")>-1){
				//var include=$("#"+track+that.levelNumber+"Select").val();
				var tmpMin=that.xScale.domain()[0];
				var tmpMax=that.xScale.domain()[1];
				var file=dataPrefix+"tmpData/regionData/"+that.folderName+"/"+track+".xml";
				var lblPrefix="Brain ";
				if(track=="liverspliceJnct"){
					lblPrefix="Liver ";
				}else if(track=="heartspliceJnct"){
					lblPrefix="Heart ";
				}
				d3.xml(file,function (error,d){
					if(error){
						console.log(error);
						if(retry==0){
							$.ajax({
								url: contextPath +"/"+ pathPrefix +"generateTrackXML.jsp",
				   				type: 'GET',
								data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: track, folder: that.folderName},
								dataType: 'json',
				    			success: function(data2){
				    				
				    			},
				    			error: function(xhr, status, error) {
				        			
				    			}
							});
						}
						if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=20000;
							}
							setTimeout(function (){
								that.addTrack(track,density,additionalOptions,retry+1);
							},time);
						}else{
							d3.select("#Level"+that.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+track).attr("height", 15);
							that.addTrackErrorRemove(d3.select("#Level"+that.levelNumber+track),"#Level"+that.levelNumber+track);
						}
					}else{
						if(d==null){
							if(retry>=4){
								var data=new Array();
								var newTrack= SpliceJunctionTrack(that,data,track,lblPrefix+"Splice Junctions",1,"");
								that.addTrackList(newTrack);
							}else{
								setTimeout(function (){
									that.addTrack(track,density,additionalOptions,4);
								},5000);
							}
						}else{
							var data=d.documentElement.getElementsByTagName("Feature");
							var newTrack= SpliceJunctionTrack(that,data,track,lblPrefix+"Splice Junctions",3,"");
							that.addTrackList(newTrack);
						}
					}
				});
		}else if(track=="polyASite"){
				d3.xml(dataPrefix+"tmpData/regionData/"+that.folderName+"/polyASite.xml",function (error,d){
					if(error){
						if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								that.addTrack(track,density,additionalOptions,retry+1);
							},time);
						}else{
							d3.select("#Level"+that.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+track).attr("height", 15);
							that.addTrackErrorRemove(d3.select("#Level"+that.levelNumber+track),"#Level"+that.levelNumber+track);
						}
					}else{
						if(d==null){
							if(retry>=4){
								var data=new Array();
								var newTrack= PolyATrack(that,data,track,"Predicted PolyA Sites",additionalOptions);
								that.addTrackList(newTrack);
							}else{
								setTimeout(function (){
									that.addTrack(track,density,additionalOptions,4);
								},5000);
							}
						}else{
							var data=d.documentElement.getElementsByTagName("Feature");
							var newTrack= PolyATrack(that,data,track,"Predicted PolyA Sites",additionalOptions);
							that.addTrackList(newTrack);
						}
					}
				});
		}else if(track.indexOf("custom")==0){
			var trackDetails=trackInfo[track];
			additionalOptions=additionalOptions+",Name="+trackDetails.Name;
			additionalOptions="DataFile="+trackDetails.Location+","+additionalOptions;
			if(trackDetails.Type=="bed"||trackDetails.Type=="bb"){
				var data=new Array();
				var newTrack=CustomTranscriptTrack(that,data,track,trackDetails.Name,3,additionalOptions);
				that.addTrackList(newTrack);
				//newTrack.redraw();
				newTrack.updateFullData(0,0);
			}else if(trackDetails.Type=="bg"||trackDetails.Type=="bw"){
				var data=new Array();
				var newTrack=CustomCountTrack(that,data,track,3,additionalOptions);
				that.addTrackList(newTrack);
			}
		}
		$(".sortable"+that.levelNumber).sortable( "refresh" );	
	};
	
	that.addTrackList= function (newTrack){
		if(newTrack!=null){
				that.trackList[that.trackCount]=newTrack;
				that.trackCount++;
				that.trackListHash[newTrack.trackClass]=newTrack;
				DisplayRegionReport();
		}
	};

	that.updateLinks=function(){
		if(that.levelNumber==1 && d3.select("#probeSetDetailLink"+that.levelNumber)[0][0]!=undefined){
			var url=new String(d3.select("#probeSetDetailLink"+that.levelNumber).attr("href"));
			url=url.substr(0,url.lastIndexOf("=")+1);
			url=url+that.currentView.ViewID;
			d3.select("#probeSetDetailLink"+that.levelNumber).attr("href",url);
		}
	};

	that.changeTrackHeight = function (level,val){
			if(val>0){
				d3.select("#"+level+"Scroll").style("max-height",val+"px").style("overflow","auto");
			}else{
				d3.select("#"+level+"Scroll").style("max-height","none").style("overflow","hidden");
			}
		};

	that.removeAllTracks=function(){
		d3.selectAll("li.draggable"+that.levelNumber).remove();
			/*for(var l=0;l<that.trackList.length;l++){
				if(that.trackList[l]!=undefined&& that.trackList[l].trackClass!="genomeSeq"){
					d3.select("#Level"+that.levelNumber+that.trackList[l].trackClass).remove();
					d3.select("li.draggable"+that.levelNumber+"#li"+that.trackList[l].trackClass).remove();
				}
			}*/
		that.trackList=[];
		DisplayRegionReport();
	};

	that.removeTrack=function (track){
			d3.select("#Level"+that.levelNumber+track).remove();
			for(var l=0;l<that.trackList.length;l++){
				if(that.trackList[l]!=undefined && that.trackList[l].trackClass==track){
					that.trackList.splice(l,1);
					that.trackCount--;
				}
			}
			that.trackListHash[track]=undefined;
			DisplayRegionReport();
	};

	that.redrawTrack=function (track){
			for(var l=0;l<that.trackList.length;l++){
				if(that.trackList[l]!=undefined && that.trackList[l].trackClass==track){
					that.trackList[l].redraw();
				}
			}
			DisplayRegionReport();
	};

	that.redraw=function (){
		for(var l=0;l<that.trackList.length;l++){
			if(that.trackList[l]!=undefined && that.trackList[l].redraw!=undefined){
				//flog("redraw trackList"+l+":"+that.trackList[l].trackClass);
				that.trackList[l].redraw();
			}
		}
		that.selectSvg.redraw();
		//DisplayRegionReport();
	};

	that.update=function (){
		for(var i=0;i<that.trackList.length;i++){
			if(that.trackList[i].update!=undefined){
				that.trackList[i].update();
			}
		}
		DisplayRegionReport();
	};

	that.updateData=function (){
		for(var i=0;i<that.trackList.length;i++){
			if(that.trackList[i]!=undefined && that.trackList[i].updateData!=undefined){
				that.trackList[i].updateData(0);
			}
		}
		that.updateFullData();
		DisplayRegionReport();
	};

	that.updateFullData=function(){
		var chkStr=new String(that.folderName);
		if(chkStr.indexOf("img")>-1){
			$.ajax({
					url:  pathPrefix +"getFullPath.jsp",
	   				type: 'GET',
	   				async: false,
					data: {chromosome: chr,minCoord:that.xScale.domain()[0],maxCoord:that.xScale.domain()[1],panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism},
					dataType: 'json',
	    			success: function(data2){ 
	        			that.folderName=data2.folderName;
	        			if(that.levelNumber==0){
	        				if(regionfolderName!=that.folderName){
	        					regionfolderName=that.folderName;
	        				}
	        			}
	    			},
	    			error: function(xhr, status, error) {
	        			console.log(error);
	    			}
				});
		}
		for(var i=0;i<that.trackList.length;i++){
			if(that.trackList[i]!=undefined && that.trackList[i].updateFullData!=undefined){
				that.trackList[i].updateFullData(0,1);
			}
		}
	};

	that.setLoading=function (){
		for(var i=0;i<that.trackList.length;i++){
			if(that.trackList[i]!=undefined && 
				(that.trackList[i].updateData!=undefined||that.trackList[i].updateFullData!=undefined)){
				that.trackList[i].showLoading();
			}
		}
	};

	that.clearSelection=function (){
		that.selectionStart=-1;
		that.selectionEnd=-1;
		that.scaleSVG.selectAll("rect.selectedArea").remove();
		that.selectSvg.setVis(false);
		for(var i=0;i<that.trackList.length;i++){
			if(that.trackList[i]!=undefined && that.trackList[i].clearSelection!=undefined){
				that.trackList[i].clearSelection();
			}
		}
	};

	that.mdown=function() {
		if(that.overSettings==0){
			if((that.defaultMouseFunct!="dragzoom" && d3.event.altKey ) || (that.defaultMouseFunct=="dragzoom" && !d3.event.altKey )){
					var p = d3.mouse(that.vis[0][0]);
					that.downZoomx=p[0];
					that.scaleSVG.append("rect")
							.attr("class","zoomRect")
							.attr("x",p[0])
							.attr("y",0)
			    			.attr("height",that.scaleSVG.attr("height"))
							.attr("width",1)
							.attr("fill","#CECECE")
							.attr("opacity",0.3);
					that.scaleSVG.append("text").attr("id","zoomTextStart").attr("x",that.downZoomx).attr("y",15).text(numberWithCommas(Math.round(that.xScale.invert(that.downZoomx))));
					that.scaleSVG.append("text").attr("id","zoomTextEnd").attr("x",that.downZoomx).attr("y",50).text(numberWithCommas(Math.round(that.xScale.invert(that.downZoomx))));
			}else{ 
				if(processAjax==0){
					that.prevMinCoord=that.xScale.domain()[0];
					that.prevMaxCoord=that.xScale.domain()[1];
			        var p = d3.mouse(that.vis[0][0]);
			        that.downx = that.xScale.invert(p[0]);
			        that.downscalex = that.xScale;
		    	}
		    }
		}
	};

	that.forceDrawAs=function(value){
		for(var i=0;i<that.trackList.length;i++){
			if(that.trackList[i]!=undefined && (that.trackList[i].drawAs!=undefined)){
				that.trackList[i].drawAs=value;
				that.trackList[i].draw(that.trackList[i].data);
			}
		}
		that.forceDrawAsValue=value;
	};

	that.resize=function(newWidth){
		that.width=newWidth;
		that.xScale.range([0, that.width]);
		that.xAxis = d3.svg.axis()
    				.scale(that.xScale)
				    .orient("top")
					.ticks(6)
					.tickSize(8)
				    .tickPadding(10);
		that.scaleSVG.attr("width", that.width);
		that.scaleSVG.select(".x.axis").call(that.xAxis);
	
		d3.select("#Level"+that.levelNumber).select(".axisLbl")
					.attr("x", ((that.width-(that.margin*2))/2));
	
		that.topLevel.style("width",(that.width+18)+"px");
		for(var l=0;l<that.trackList.length;l++){
			if(that.trackList[l]!=undefined && that.trackList[l].redraw!=undefined){
				that.trackList[l].resize();
			}
		}
		that.selectSvg.width=newWidth;
		that.selectSvg.draw();
	};

	that.updateCountScales=function(minVal,maxVal){
		for(var i=0;i<that.trackList.length;i++){
			if(that.trackList[i]!=undefined && that.trackList[i].updateCountScale!=undefined){
				that.trackList[i].updateCountScale(minVal,maxVal);
			}
		}
	};

	//Function Bar functions
	that.resetDefaultMouse=function(prevSelected){
		var image="/web/images/icons/"+prevSelected+"_dark.png";
		d3.select("span#"+prevSelected+that.levelNumber+" img").attr("src",image);
		d3.select("span#"+prevSelected+that.levelNumber).style("background","#DCDCDC");
	}

	that.changeTrackCursor=function(cursor){
		for(var i=0;i<that.trackList.length;i++){
			if(that.trackList[i]!=undefined && that.trackList[i].svg!=undefined){
				that.trackList[i].svg.style("cursor",cursor);
			}
		}
	};

	that.changeScaleCursor=function(cursor){
		if(that.scaleSVG!=undefined){
			that.scaleSVG.style("cursor",cursor);
		}
	};

	that.updateTrackSelectedArea=function(start,end){
		that.selectionStart=start;
		that.selectionEnd=end;
		var xStart=that.xScale(start);
		var width=that.xScale(end)-xStart;
		that.scaleSVG.selectAll("rect.selectedArea").remove();
		if((xStart>0 || (xStart+width)>0)&&(xStart<that.width)){
			if(width<1){
				width=1;
			}
			that.scaleSVG.append("rect").attr("class","selectedArea")
							.attr("x",xStart)
							.attr("y",15)
			    			.attr("height",that.scaleSVG.attr("height")-15)
							.attr("width",width)
							.attr("fill","#CECECE")
							.attr("opacity",0.3)
							.attr("pointer-events","none");
			for(var i=0;i<that.trackList.length;i++){
				if(that.trackList[i]!=undefined && that.trackList[i].setSelectedArea!=undefined){
					that.trackList[i].setSelectedArea(start,end);
				}
			}
		}
	};


	that.getAddMenus=function (){
		var tmpContext=contextPath +"/"+ pathPrefix;
		if(pathPrefix==""){
			tmpContext="";
		}
		$.ajax({
				url:  tmpContext+"trackMenu.jsp",
   				type: 'GET',
				data: {level: that.levelNumber, organism: organism},
				dataType: 'html',
    			success: function(data2){
    				$("#trackMenu"+that.levelNumber).remove();
    				d3.select("div#trackMenu").append("div").attr("id","trackMenu"+that.levelNumber);
    				$("#trackMenu"+that.levelNumber).html(data2);
    			},
    			error: function(xhr, status, error) {
    				$("#trackMenu"+that.levelNumber).remove();
    				d3.select("div#trackMenu").append("div").attr("id","trackMenu"+that.levelNumber);
        			$('#trackMenu'+that.levelNumber).append("<div class=\"viewsLevel"+that.levelNumber+"\">An error occurred generating this menu.  Please try back later.</div>");
    			},
    			async:   false
			});

		$.ajax({
				url:  tmpContext+"viewMenu.jsp",
   				type: 'GET',
				data: {level: that.levelNumber, organism: organism},
				dataType: 'html',
    			success: function(data2){
    				$("#viewMenu"+that.levelNumber).remove();
    				d3.select("div#viewMenu").append("div").attr("id","viewMenu"+that.levelNumber);
    				$("#viewMenu"+that.levelNumber).html(data2);

    			},
    			error: function(xhr, status, error) {
    				$("#viewMenu"+that.levelNumber).remove();
    				d3.select("div#viewMenu").append("div").attr("id","viewMenu"+that.levelNumber);
        			$('#viewMenu'+that.levelNumber).append("<div class=\"viewsLevel"+that.levelNumber+"\">An error occurred generating this menu.  Please try back later.</div>");
    			},
    			async:   false
			});

	};

	that.setupFunctionBar=function(){
		d3.select(div).select("#functLevel"+that.levelNumber).remove();
		//Setup Function Bar
		that.functionBar=that.vis.append("div").attr("class","functionBar")
			.attr("id","functLevel"+that.levelNumber)
			.style("float","left");
		//Setup Mouse Default Function Control
		var defMouse=that.functionBar.append("div").attr("class","defaultMouse").attr("id","defaultMouse"+that.levelNumber);
		defMouse.append("span").attr("id","dragzoom"+that.levelNumber).style("height","24px").style("display","inline-block")
			.style("cursor","pointer")
			.append("img").attr("class","mouseOpt dragzoom")
			.attr("src","/web/images/icons/dragzoom_dark.png")
			.attr("pointer-events","all")
			.on("click",function(){
				that.resetDefaultMouse(that.defaultMouseFunct);
				that.defaultMouseFunct="dragzoom";
				d3.select(this).attr("src","/web/images/icons/dragzoom_white.png");
				d3.select("span#dragzoom"+that.levelNumber).style("background","#989898");
				that.changeTrackCursor("crosshair");
				that.changeScaleCursor("crosshair");
			})
			.on("mouseout",function(){
				if(that.defaultMouseFunct!="dragzoom"){
					d3.select(this).attr("src","/web/images/icons/dragzoom_dark.png");
					d3.select("span#dragzoom"+that.levelNumber).style("background","#DCDCDC");
				}
			})
			.on("mouseover",function(){
				d3.select(this).attr("src","/web/images/icons/dragzoom_white.png");
				d3.select("span#dragzoom"+that.levelNumber).style("background","#989898");
				$("#mouseHelp").html("Click to set default mouse function to allow click and drag to select a region to zoom in on.");
			});
		defMouse.append("span").attr("id","pan"+that.levelNumber).style("height","24px").style("display","inline-block")
			.style("cursor","pointer")
			.append("img")
			.attr("class","mouseOpt pan")
			.attr("src","/web/images/icons/pan_dark.png")
			.attr("pointer-events","all")
			.on("click",function(){
				that.resetDefaultMouse(that.defaultMouseFunct);
				that.defaultMouseFunct="pan";
				d3.select(this).attr("src","/web/images/icons/pan_white.png");
				d3.select("span#pan"+that.levelNumber).style("background","#989898");
				that.changeTrackCursor("move");
				that.changeScaleCursor("ew-resize");
			})
			.on("mouseout",function(){
				if(that.defaultMouseFunct!="pan"){
					d3.select(this).attr("src","/web/images/icons/pan_dark.png");
					d3.select("span#pan"+that.levelNumber).style("background","#DCDCDC");
				}
			})
			.on("mouseover",function(){
				d3.select(this).attr("src","/web/images/icons/pan_white.png");
				d3.select("span#pan"+that.levelNumber).style("background","#989898");
				$("#mouseHelp").html("Click to set default mouse function to allow click and drag to navigate along the genome.");
			});
		defMouse.append("span").attr("id","reorder"+that.levelNumber).style("height","24px").style("display","inline-block")
			.style("cursor","pointer").append("img")
			.attr("class","mouseOpt pan")
			.attr("src","/web/images/icons/reorder_dark.png")
			.attr("pointer-events","all")
			.on("click",function(){
				that.resetDefaultMouse(that.defaultMouseFunct);
				that.defaultMouseFunct="reorder";
				d3.select(this).attr("src","/web/images/icons/reorder_white.png");
				d3.select("span#reorder"+that.levelNumber).style("background","#989898");
				that.changeTrackCursor("ns-resize");
				that.changeScaleCursor("ew-resize");
			})
			.on("mouseout",function(){
				if(that.defaultMouseFunct!="reorder"){
					d3.select(this).attr("src","/web/images/icons/reorder_dark.png");
					d3.select("span#reorder"+that.levelNumber).style("background","#DCDCDC");
				}
			})
			.on("mouseover",function(){
				d3.select(this).attr("src","/web/images/icons/reorder_white.png");
				d3.select("span#reorder"+that.levelNumber).style("background","#989898");
				$("#mouseHelp").html("Click to set default mouse function to reorder image tracks.");
			});
		$("span#"+that.defaultMouseFunct+that.levelNumber+" img").click();
		//Setup Additional Buttons
		that.functionBar.append("span").attr("class","saveImage control").style("display","inline-block")
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
				$("#mouseHelp").html("Click to download a PNG image of the current view.");
			})
			.on("mouseout",function(){
				d3.select(this).attr("src","/web/images/icons/savePic_dark.png");
				d3.select("span#savePic"+that.levelNumber).style("background","#989898");
				//$(this).css("background","#DCDCDC").html("<img src=\"/web/images/icons/savePic_dark.png\">");
				$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
			});

		that.functionBar.append("span").attr("class","reset control").style("display","inline-block")
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
				$("#mouseHelp").html("Click to reset image zoom to initial region.");
			})
			.on("mouseout",function(){
				d3.select(this).attr("src","/web/images/icons/reset_dark.png");
				d3.select("span#reset"+that.levelNumber).style("background","#989898");
				$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
			});

		that.functionBar.append("span").attr("class","back control").style("display","inline-block")
			.attr("id","backButton"+that.levelNumber)
			.style("cursor","pointer")
			.append("img")//.attr("class","mouseOpt dragzoom")
			.attr("src","/web/images/icons/back_dark2.png")
			.attr("pointer-events","all")
			.attr("cursor","pointer")
			.on("click",function(){
				back(that.levelNumber);
			})
			.on("mouseover",function(){
				d3.select(this).attr("src","/web/images/icons/back_white2.png");
				//d3.select("span#backButton"+that.levelNumber).style("background","#DCDCDC");
				$("#mouseHelp").html("Click to undo last zoom/pan.");
			})
			.on("mouseout",function(){
				d3.select(this).attr("src","/web/images/icons/back_dark2.png");
				//d3.select("span#backButton"+that.levelNumber).style("background","#989898");
				$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
			});
	};

	that.generateSettingsString=function(){
		ret="";
		$("#ScrollLevel"+that.levelNumber+" li.draggable"+that.levelNumber).each(function(){
			var idStr=new String($(this).attr("id"));
			idStr=idStr.substr(2);
			if(that.trackListHash[idStr]!=undefined){
				ret=ret+that.trackListHash[idStr].generateTrackSettingString();
			}
		});
		/*for(var i=0;i<that.trackList.length;i++){
			if(that.trackList[i]!=undefined && that.trackList[i].generateTrackSettingString!=undefined){
				ret=ret+that.trackList[i].generateTrackSettingString();
			}
		}*/
		return ret;
	};

	that.setCurrentViewModified=function(){
		that.currentView.modified=1;
		$("span#viewModifiedCtl"+that.levelNumber).show();
	};
	that.clearCurrentView=function(){
		that.currentView.modified=0;
		$("span#viewModifiedCtl"+that.levelNumber).hide();
	};

	//Genome SVG Setup
	that.type=type;
	that.div=div;
	that.margin=0;

	that.halfWindowWidth = $(window).width()/2;
	//that.mw=that.width-that.margin;
	that.mh=400;

	//vars for manipulation
	that.downx = Math.NaN;
	that.downscalex;
	that.downPanx=Math.NaN;
	that.downZoomx=Math.NaN;
	that.downZoomxEnd=Math.NaN;
	that.defaultMouseFunct="pan";


	that.xMax=290000000;
	that.xMin=1;

	that.prevMinCoord=minCoord;
	that.prevMaxCoord=maxCoord;
	
	that.initMin=minCoord;
	that.initMax=maxCoord;

	that.dataMinCoord=minCoord;
	that.dataMaxCoord=maxCoord;

	that.y=0;

	that.xScale = null;
	that.xAxis = null;
	that.vis=null;
	that.level=null;

	that.svg = null;
		

	that.txType=null;
	that.txList=null;
		
	that.tt=null;

	that.trackList=new Array();
	that.trackCount=0;

	that.levelNumber=levelNumber;
	that.selectedData=null;
	that.txType=null;

	that.selectionStart=-1;
	that.selectionEnd=-1;
	that.scrollSize=350;
	//setup code
	that.width=imageWidth;
	that.mw=that.width-that.margin;
	//d3.select(div).select("#settingsLevel"+levelNumber).remove();
	d3.select(div).select("#viewsLevel"+levelNumber).remove();
	d3.select(div).select("#Level"+levelNumber).remove();
	that.vis=d3.select(div);

	that.setupFunctionBar();

	/*that.vis.append("span").attr("class","views button")
		.attr("id","viewsLevel"+levelNumber)
		.style("float","right")
		.style("width","80px")
		.style("margin-right","5px")
		.text("Views")
		.on("mouseover",function(){
			$("#mouseHelp").html("Click to change views or save the current view.");
		})
		.on("mouseout",function(){
			$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
		});*/

	if($("#viewSelect"+that.levelNumber).length==0){
		var viewDivTop=that.vis.append("div")
		.style("float","right")
		.style("display","inline-block")
		.style("margin-right","5px");
		var viewBtnSpan=viewDivTop.append("div");
		viewBtnSpan.append("button").attr("id","viewSelect"+that.levelNumber).attr("class","viewSelect").text("Select/Edit Views");
		viewBtnSpan.append("button").attr("id","viewMenuSelect"+that.levelNumber).attr("class","viewSelectMenu");
		if(testChrome){
			viewDivTop.style("position","relative").style("top","-7px");
			d3.select("#viewMenuSelect"+that.levelNumber).style("position","relative").style("top","7px");
		}else if(testSafari){
			viewDivTop.style("position","relative").style("top","-2px");
			d3.select("#viewMenuSelect"+that.levelNumber).style("position","relative").style("top","-1px");
		}else if(testFireFox){
			//nothing
		}else if(testIE){
			d3.select("#viewSelect"+that.levelNumber).style("position","relative").style("top","-8px").style("height","2.3em");
		}
		var viewDivMenu=viewDivTop.append("ul").attr("id","viewSelectMenu"+that.levelNumber);
		viewDivMenu.append("li").attr("id","menusaveView"+that.levelNumber)
			.on("click",function(){
				viewMenu[that.levelNumber].saveView(that.currentView.ViewID,that,false);
				//remove modified labels
				$("#viewModifiedCtl"+that.level).hide();
			})
			.text("Save");
		viewDivMenu.append("li").attr("id","menusaveAsView"+that.levelNumber)
			.on("click",function(){
				viewMenu[that.levelNumber].saveAsView(that.currentView,svgList[that.levelNumber]);
				$(".viewsLevel"+that.levelNumber).css("top",250).css("left",$(window).width()-610);
				$(".viewsLevel"+that.levelNumber).fadeIn("fast");
				$("#viewModifiedCtl"+that.level).hide();
				//TODO: still need to make it load the new view instead of using the old view.
			})
			.text("Save As");
		viewDivMenu.append("li").attr("id","menudeleteView"+that.levelNumber)
			.on("click",function(){
				//viewMenu[that.levelNumber].setSelectedView(that.currentView.ViewID);
				viewMenu[that.levelNumber].confirmDeleteView(that.currentView);
				$(".viewsLevel"+that.levelNumber).css("top",250).css("left",$(window).width()-610);
				$(".viewsLevel"+that.levelNumber).fadeIn("fast");
			})
			.text("Delete");
		//viewDivMenu.append("li").attr("id","menuresetView"+that.levelNumber).text("Reset");

		$("#viewSelect"+that.levelNumber )
	      	.button()
		      .click(function() {
		        
		      })
	      	.next()
	        	.button({
		          text: false,
		          icons: {
		            primary: "ui-icon-triangle-1-s"
		          }
		        })
		        .click(function() {
		          var menu = $( this ).parent().next().show().position({
		            my: "left top",
		            at: "left bottom",
		            of: this
		          });
		          $( document ).one( "click", function() {
		            menu.hide();
		          });
		          return false;
		        })
	        .parent()
	          .buttonset()
	          .next()
	            .hide()
	            .menu();

		var imgCtrl=that.vis.append("span").style("float","right").style("margin-right","5px");

		imgCtrl.append("input")
			.attr("type","checkbox")
			.attr("name","imgCBX")
			.attr("id","forceTrxCBX"+that.levelNumber);
		imgCtrl.append("label")
				.attr("for","forceTrxCBX"+that.levelNumber)
				.text("Draw Genes as Transcripts");
		$("input#forceTrxCBX"+that.levelNumber).button();

		var scrollCtrl=that.vis.append("span").style("float","right").style("margin-right","5px");
		

		var scrollSize=scrollCtrl.append("div").attr("class","defaultMouse")
			.style("width","64px")
			.attr("id","scrollSize"+that.levelNumber);
			scrollSize.append("span")
				.attr("id","scrollIncr"+that.levelNumber)
				.style("height","24px")
				.style("display","inline-block")
				.style("cursor","pointer")
				.append("img").attr("class","mouseOpt ")
				.attr("src","/web/images/icons/scroll_smaller.png")
				.attr("pointer-events","all")
				.on("click",function(){
					that.scrollSize=that.scrollSize-100;
					if(that.scrollSize<100){
						that.scrollSize=100;
					}
					changeTrackHeight("Level"+that.levelNumber,that.scrollSize);
				})
				.on("mouseout",function(){
					$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
				})
				.on("mouseover",function(){
					$("#mouseHelp").html("Decrease the vertical length of the scrollable browser image on the page.");
				});
			scrollSize.append("span")
				.attr("id","pan"+that.levelNumber)
				.style("height","24px")
				.style("display","inline-block")
				.style("cursor","pointer")
				.append("img")
				.attr("class","mouseOpt pan")
				.attr("src","/web/images/icons/scroll_larger.png")
				.attr("pointer-events","all")
				.on("click",function(){
					if(that.scrollSize<$("#ScrollLevel"+that.levelNumber)[0].scrollHeight){
						that.scrollSize=that.scrollSize+100;
						changeTrackHeight("Level"+that.levelNumber,that.scrollSize);
					}
				})
				.on("mouseout",function(){
					$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
				})
				.on("mouseover",function(){
					$("#mouseHelp").html("Increase the vertical length of the scrollable browser image on the page.");
				});
		scrollCtrl.append("span").attr("class","scrollBtn control").style("display","inline-block")
				.attr("id","scrollImage"+that.levelNumber)
				.style("cursor","pointer")
				.append("img")//.attr("class","mouseOpt dragzoom")
				.attr("src","/web/images/icons/scroll.png")
				.attr("pointer-events","all")
				.attr("cursor","pointer")
				.on("click",function(){
					if(d3.select(this).attr("src")=="/web/images/icons/no_scroll.png"){
						d3.select(this).attr("src","/web/images/icons/scroll.png");
						d3.select("span#reset"+that.levelNumber).style("background","#989898");
						$("#scrollSize"+that.levelNumber).show();
						changeTrackHeight("Level"+that.levelNumber,that.scrollSize);
					}else{
						d3.select(this).attr("src","/web/images/icons/no_scroll.png");
						d3.select("span#reset"+that.levelNumber).style("background","#DCDCDC");
						$("#scrollSize"+that.levelNumber).hide();
						changeTrackHeight("Level"+that.levelNumber,0);
					}
				})
				.on("mouseover",function(){
					$("#mouseHelp").html("Click to toggle browser image scrolling on/off.  <b>Off</b> the image takes as much space as needed. <b>On</b> you can adjust the maximum length of the image.");
				})
				.on("mouseout",function(){
					$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
				});
	}

	that.topDiv=that.vis.append("div")
		.attr("id","Level"+levelNumber)
		.style("text-align","left");
	
	that.xScale = d3.scale.linear().
  		domain([minCoord, maxCoord]). 
  		range([0, that.width]);
	var tmpHist={};
	tmpHist.chr=chr;
	tmpHist.start=minCoord;
	tmpHist.stop=maxCoord;
	history[that.levelNumber].push(tmpHist);

	that.xAxis = d3.svg.axis()
    				.scale(that.xScale)
				    .orient("top")
					.ticks(6)
					.tickSize(8)
				    .tickPadding(10);
	
	that.scaleSVG = that.topDiv.append("svg:svg")
					    .attr("width", that.width)
					    .attr("height", 60)
						.attr("pointer-events", "all")
					    .attr("class", "scale")

						//.attr("pointer-events", "all")
						.on("mousedown", that.mdown)
						.on("mouseup",mup)
						.on("mouseover", function(){
							if(that.defaultMouseFunct!="dragzoom"){
								$("#mouseHelp").html("<B>Zoom:</b> Click and Drag right to zoom in or left to zoom out. <B>OR</B> Hold the Alt/Option Key while clicking, then drag to select a specific area.");
							}else{
								$("#mouseHelp").html("<B>Zoom:</b> Click and Drag to select an area to zoom in on it. <B>OR</B> Hold the Alt/Option Key while clicking and drag right to zoom in or left to zoom out.");
							}
							if(d3.event.altKey && that.defaultMouseFunct!="dragzoom"){
								that.changeScaleCursor("crosshair");
							}else if(d3.event.altKey && that.defaultMouseFunct=="dragzoom"){
								that.changeScaleCursor("ew-resize");
							}
						})
						.on("mouseout", function(){
							$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
						})
						.on("mousemove",function(){
							if(d3.event.altKey && that.defaultMouseFunct!="dragzoom"){
								that.changeScaleCursor("crosshair");
							}else if(d3.event.altKey && that.defaultMouseFunct=="dragzoom"){
								that.changeScaleCursor("ew-resize");
							}else if(!d3.event.altKey && that.defaultMouseFunct=="dragzoom"){
								that.changeScaleCursor("crosshair");
							}else if(!d3.event.altKey && that.defaultMouseFunct!="dragzoom"){
								that.changeScaleCursor("ew-resize");
							}
						})
						.style("cursor", "ew-resize");
	
	that.scaleSVG.append("g")
				 .attr("class", "x axis")
				 .attr("transform", "translate(0,55)")
				 .attr("shape-rendering","crispEdges")
				 .call(that.xAxis);
	
	d3.select("#Level"+that.levelNumber).select(".x.axis")
					.append("text")
					.text(title)
					.attr("x", ((that.width-(that.margin*2))/2))
					.attr("y",-40)
					.attr("class","axisLbl");
	
	that.topLevel=that.topDiv.append("div")
					.attr("id","ScrollLevel"+levelNumber)
					.attr("class","scroll")
					.style("max-height","350px")
					.style("overflow","auto")
					.style("width","100%")
					.append("ul")
					.attr("id","sortable"+levelNumber);
    
    //getAddMenuDiv(levelNumber,that.type);
    that.getAddMenus();
	svgList[levelNumber]=that;
	
	 $( "#sortable"+levelNumber ).sortable({
										      ///revert: true,
										      //snap: "li",
											  //axis: "y",
											  appendTo: "parent",
											  containment: "parent",
											  //helper: "original",
											  stop: function() {
										        //saveToCookie(levelNumber);
										      }
										    }).disableSelection();
	
    $( ".draggable"+levelNumber ).draggable({
										      connectToSortable: "#sortable"+levelNumber,
										      scroll: true,
										      //helper: "original",
										      revert: "invalid",
											  axis: "y"
										    });
    //$( "ul,li");
    var orgVer=mmVer;
    if(organism=="Rn"){
    	orgVer=rnVer;
    }
    var header=d3.select("div#imageHeader").html("Organism: "+orgVer+"&nbsp&nbsp&nbsp&nbsp"+siteVer);
    //Add Sequence Track
    that.addTrack("genomeSeq",3,"both",0);

    that.selectSvg= selectionSVG('#Level'+that.levelNumber,that.width,that.levelNumber,that);
    //trackMenu[that.levelNumber]=TrackMenu(that.levelNumber);
    return that;
}

function toolTipSVG(div,imageWidth,minCoord,maxCoord,levelNumber,title,type){
	var that={};
	
	that.isToolTip=1;
	that.folderName=regionfolderName;

	that.updateTimeoutHandle={};
	that.timeoutTrack=-1;
	that.forLevel=-1;

	that.get=function(attr){return that[attr];};
	
	that.getTrack=function (track){
			var tr;
			for(var l=0;l<that.trackList.length;l++){
				if(that.trackList[l]!=undefined && that.trackList[l].trackClass==track){
					tr=that.trackList[l];
				}
			}
			return tr;
	};

	that.addTrack=function (track,density,additionalOptions,data){
		//console.log("addTrack():"+additionalOptions);
		if(that.forceDrawAsValue=="Trx"){
			var additionalOptionsStr=new String(additionalOptions);
			if(additionalOptionsStr.indexOf("DrawTrx")==-1){
				additionalOptions=additionalOptions+"DrawTrx,";
			}
		}
		var tmpvis=d3.select("#Level"+that.levelNumber+track);
		if(tmpvis[0][0]==null){
				var dragDiv=that.topLevel.append("li").attr("class","draggable"+that.levelNumber);
				var svg = dragDiv.append("svg:svg")
				.attr("width", that.get('width'))
				.attr("height", 30)
				.attr("class", "track")
				.attr("id","Level"+that.levelNumber+track);
				var lblStr=new String("Loading...");
				svg.append("text").text(lblStr).attr("x",that.width/2-(lblStr.length/2)*7.5).attr("y",12).attr("id","trkLbl");
		}
		var success=0;
		var currentSettings="";
		if(that.forLevel>-1 && that.levelNumber==99 && svgList[that.forLevel]!=undefined){
			currentSettings=svgList[that.forLevel].getTrack(track).generateTrackSettingString();
			currentSettings=currentSettings.substr(currentSettings.indexOf(",")+1);
			additionalOptions=currentSettings;
			//console.log("current Settings:"+currentSettings);
		}
		if(track=="genomeSeq"){
			var newTrack= SequenceTrack(that,track,"Reference Genomic Sequence",additionalOptions);
			newTrack.seqRegionSize=10;
			that.addTrackList(newTrack);
		}else if(track.indexOf("noncoding")>-1){
			var newTrack= GeneTrack(that,data,track,"Non-Coding/Non-PolyA+ Transcripts",additionalOptions);
			that.addTrackList(newTrack);
		}else if(track.indexOf("coding")>-1){
			var newTrack= GeneTrack(that,data,track,"Protein Coding/PolyA+ Transcripts",additionalOptions);
			that.addTrackList(newTrack);
		}else if(track=="liverTotal" || track=="heartTotal" || track=="brainTotal"){
			var lbl="Liver Total RNA Transcripts";
			if(track=="heartTotal"){
				lbl="Heart Total RNA Transcripts";
			}else if(track=="brainTotal"){
				lbl="Brain Total RNA Transcripts";
			}
			var newTrack= GeneTrack(that,data,track,lbl,additionalOptions);
			that.addTrackList(newTrack);
		}else if(track.indexOf("smallnc")>-1){
			var newTrack= GeneTrack(that,data,track,"Small RNA (<200 bp) Genes",additionalOptions);
			that.addTrackList(newTrack);
		}else if(track.indexOf("refSeq")==0){
			if(that.levelNumber==99){
				additionalOptions=additionalOptions+"DrawTrx,";
			}
			var newTrack= RefSeqTrack(that,data,track,"Ref Seq Genes",additionalOptions);
			if(that.levelNumber==99){
				newTrack.density=2;
			}else{
				newTrack.density=density;
			}
			that.addTrackList(newTrack);
		}else if(track.indexOf("snp")==0){
			var newTrack= SNPTrack(that,data,track,1,"4");
			that.addTrackList(newTrack);
		}else if(track=="qtl"){
			var newTrack= QTLTrack(that,data,track,1);
			that.addTrackList(newTrack);
		}else if(track=="trx"){
				var txList=getAllChildrenByName(getFirstChildByName(that.selectedData,"TranscriptList"),"Transcript");
				var newTrack= TranscriptTrack(that,txList,track,density);
				that.addTrackList(newTrack);
		}else if(track=="probe"){
				if(that.levelNumber!=99){
					additionalOptions=density+","+additionalOptions;
				}
				var newTrack= ProbeTrack(that,data,track,"Affy Exon 1.0 ST Probe Sets",additionalOptions);
				//var newTrack= ProbeTrack(that,data,track,"Affy Exon 1.0 ST Probe Sets",density+",annot,"+additionalOptions);
				that.addTrackList(newTrack);
		}else if(track.indexOf("spliceJnct")>-1){
				var lblPrefix="Brain ";
				if(track=="liverspliceJnct"){
					lblPrefix="Liver ";
				}else if(track=="heartspliceJnct"){
					lblPrefix="Heart ";
				}
				var newTrack= SpliceJunctionTrack(that,data,track,lblPrefix+"Splice Junctions",3,"");
				if(that.levelNumber==100){
					newTrack.density=density;
				}
				that.addTrackList(newTrack);
		}else if(track=="polyASite"){
				var newTrack= PolyATrack(that,data,track,"Predicted PolyA Sites",additionalOptions);
				that.addTrackList(newTrack);
		}else if(track=="helicos"||track.indexOf("illuminaTotal")>-1||track.indexOf("illuminaSmall")>-1||track=="illuminaPolyA"){
			if(that.updateTimeoutHandle[track]==undefined){
				that.updateTimeoutHandle[track]=-1;
			}
			var newTrack;
			var curDensity=2;
			var opts=currentSettings.split(",");
			if(opts.length>1&&(opts[1]==1||opts[1]==2)){
				curDensity=opts[1];
			}
			if(track=="helicos"){
				newTrack= HelicosTrack(that,data,track,curDensity);
			}else if(track=="illuminaTotal"){
				newTrack= IlluminaTotalTrack(that,data,track,curDensity);
			}else if(track=="illuminaSmall"){
				newTrack= IlluminaSmallTrack(that,data,track,curDensity);
			}else if(track=="illuminaPolyA"){
				newTrack= IlluminaPolyATrack(that,data,track,curDensity);
			}else if(track=="liverilluminaTotalPlus"){
				newTrack= LiverIlluminaTotalPlusTrack(that,data,track,curDensity);
			}else if(track=="liverilluminaTotalMinus"){
				newTrack= LiverIlluminaTotalMinusTrack(that,data,track,curDensity);
			}else if(track=="heartilluminaTotalPlus"){
				newTrack= HeartIlluminaTotalPlusTrack(that,data,track,curDensity);
			}else if(track=="heartilluminaTotalMinus"){
				newTrack= HeartIlluminaTotalMinusTrack(that,data,track,curDensity);
			}else if(track=="brainilluminaTotalPlus"){
				newTrack= BrainIlluminaTotalPlusTrack(that,data,track,curDensity);
			}else if(track=="brainilluminaTotalMinus"){
				newTrack= BrainIlluminaTotalMinusTrack(that,data,track,curDensity);
			}else if(track=="liverilluminaSmall"){
				newTrack= LiverIlluminaSmallTrack(that,data,track,curDensity);
			}else if(track=="heartilluminaSmall"){
				newTrack= HeartIlluminaSmallTrack(that,data,track,curDensity);
			}
			if(that.levelNumber==99){
				if(that.updateTimeoutHandle[track]!=0){
					clearTimeout(that.updateTimeoutHandle[track]);
					try{
						clearTimeout(that.timeoutTrack[track].fullDataTimeOutHandle);
					}catch(error){
						console.log(error);
					}
					that.updateTimeoutHandle[track]=0;
				}
				that.updateTimeoutHandle[track]= setTimeout(function(){
					newTrack.updateFullData(0,1);
					that.timeoutTrack[track]=newTrack;
					that.updateTimeoutHandle[track]=0;
				},300);
			}
			that.addTrackList(newTrack);
		}else if(track.indexOf("custom")>-1){
			var trackDetails=trackInfo[track];
			additionalOptions="DataFile="+trackDetails.Location+","+additionalOptions;
			if(trackDetails.Type=="bed"||trackDetails.Type=="bb"){
				var data=new Array();
				var newTrack=CustomTranscriptTrack(that,data,track,trackDetails.Name,3,additionalOptions);
				that.addTrackList(newTrack);
				//newTrack.updateFullData(0,0);
			}else if(trackDetails.Type=="bg"||trackDetails.Type=="bw"){
				var data=new Array();
				var newTrack=CustomCountTrack(that,data,track,3,additionalOptions);
				that.addTrackList(newTrack);
			}

		}
		$(".sortable"+that.levelNumber).sortable( "refresh" );
			
	};
	
	that.addTrackList= function (newTrack){
		if(newTrack!=null){
				that.trackList[that.trackCount]=newTrack;
				that.trackCount++;
				DisplayRegionReport();
		}
	};

	that.changeTrackHeight = function (level,val){
			if(val>0){
				d3.select("#"+level+"Scroll").style("max-height",val+"px");
			}else{
				d3.select("#"+level+"Scroll").style("max-height","none");
			}
		};

	that.removeAllTracks=function(){
			for(var l=0;l<that.trackList.length;l++){
				if(that.trackList[l]!=undefined&& that.trackList[l].trackClass!="genomeSeq"){
					d3.select("#Level"+that.levelNumber+that.trackList[l].trackClass).remove();
				}
			}
			that.trackList=[];
			DisplayRegionReport();
	};

	that.removeTrack=function (track){
			d3.select("#Level"+that.levelNumber+track).remove();
			for(var l=0;l<that.trackList.length;l++){
				if(that.trackList[l]!=undefined && that.trackList[l].trackClass==track){
					that.trackList.splice(l,1);
					that.trackCount--;
				}
			}
			DisplayRegionReport();
	};

	that.redrawTrack=function (track){
			for(var l=0;l<that.trackList.length;l++){
				if(that.trackList[l]!=undefined && that.trackList[l].trackClass==track){
					that.trackList[l].redraw();
				}
			}
			DisplayRegionReport();
	};

	that.redraw=function (){
		for(var l=0;l<that.trackList.length;l++){
			if(that.trackList[l]!=undefined && that.trackList[l].redraw!=undefined){
				that.trackList[l].redraw();
			}
		}
		//DisplayRegionReport();
	};

	that.update=function (){
		for(var i=0;i<that.trackList.length;i++){
			if(that.trackList[i].update!=undefined){
				that.trackList[i].update();
			}
		}
		DisplayRegionReport();
	};

	that.updateData=function (){
		for(var i=0;i<that.trackList.length;i++){
			if(that.trackList[i]!=undefined && that.trackList[i].updateData!=undefined){
				that.trackList[i].updateData(0);
			}
		}
		that.updateFullData();
		DisplayRegionReport();
	};

	that.updateFullData=function(){
		var chkStr=new String(that.folderName);
		if(chkStr.indexOf("img")>-1){
			$.ajax({
					url:  pathPrefix +"getFullPath.jsp",
	   				type: 'GET',
	   				async: false,
					data: {chromosome: chr,minCoord:that.xScale.domain()[0],maxCoord:that.xScale.domain()[1],panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism},
					dataType: 'json',
	    			success: function(data2){ 
	        			that.folderName=data2.folderName;
	    			},
	    			error: function(xhr, status, error) {
	        			//console.log(error);
	    			}
				});
		}
		for(var i=0;i<that.trackList.length;i++){
			if(that.trackList[i]!=undefined && that.trackList[i].updateFullData!=undefined){
				that.trackList[i].updateFullData(0,1);
			}
		}
	};

	that.setLoading=function (){
		for(var i=0;i<that.trackList.length;i++){
			if(that.trackList[i]!=undefined && (that.trackList[i].updateData!=undefined||that.trackList[i].updateFullData!=undefined)){
				that.trackList[i].showLoading();
			}
		}
	};

	that.clearSelection=function (){
		for(var i=0;i<that.trackList.length;i++){
			if(that.trackList[i]!=undefined && that.trackList[i].clearSelection!=undefined){
				that.trackList[i].clearSelection();
			}
		}
	};

	that.mdown=function() {
			if(processAjax==0){
				that.prevMinCoord=that.xScale.domain()[0];
				that.prevMaxCoord=that.xScale.domain()[1];
		        var p = d3.mouse(that.vis[0][0]);
		        that.downx = that.xScale.invert(p[0]);
		        that.downscalex = that.xScale;
	    	}
	};

	that.forceDrawAs=function(value){
		for(var i=0;i<that.trackList.length;i++){
			if(that.trackList[i]!=undefined && (that.trackList[i].drawAs!=undefined)){
				that.trackList[i].drawAs=value;
				that.trackList[i].draw(that.trackList[i].data);
			}
		}
		that.forceDrawAsValue=value;
	};

	that.generateSettingsString=function(){
		ret="";
		for(var i=0;i<that.trackList.length;i++){
			if(that.trackList[i]!=undefined && that.trackList[i].generateTrackSettingString!=undefined){
				ret=ret+that.trackList[i].generateTrackSettingString();
			}
		}
		return ret;
	};

	that.setCurrentViewModified=function(){
		if(that.currentView!=undefined){
			that.currentView.modified=1;
			$("span#viewModifiedCtl"+that.levelNumber).show();
		}
	};
	that.clearCurrentView=function(){
		that.currentView.modified=0;
		$("span#viewModifiedCtl"+that.levelNumber).hide();
	};

	that.type=type;
	that.div=div;
	that.margin=0;
	that.halfWindowWidth = $(window).width()/2;
	//that.mw=that.width-that.margin;
	that.mh=400;

	//vars for manipulation
	that.downx = Math.NaN;
	that.downscalex;
	that.downPanx=Math.NaN;


	that.xMax=290000000;
	that.xMin=1;

	that.prevMinCoord=minCoord;
	that.prevMaxCoord=maxCoord;
	
	that.dataMinCoord=minCoord;
	that.dataMaxCoord=maxCoord;
	
	that.y=0;

	that.xScale = null;
	that.xAxis = null;
	that.vis=null;
	that.level=null;

	that.svg = null;
		

	that.txType=null;
	that.txList=null;
		
	that.tt=null;

	that.trackList=new Array();
	that.trackCount=0;

	that.levelNumber=levelNumber;
	that.selectedData=null;
	that.txType=null;
	//setup code
	that.width=imageWidth;
	that.mw=that.width-that.margin;


	that.vis=d3.select(div);

	
	that.topDiv=that.vis.append("div")
		.attr("id","Level"+levelNumber)
		.style("text-align","left");
	
	that.xScale = d3.scale.linear().
  		domain([minCoord, maxCoord]). 
  		range([0, that.width]);
		
	that.xAxis = d3.svg.axis()
    				.scale(that.xScale)
				    .orient("top")
					.ticks(3)
					.tickSize(8)
				    .tickPadding(10);
	
	that.scaleSVG = that.topDiv.append("svg:svg")
					    .attr("width", that.width)
					    .attr("height", 60)
					    .attr("class", "scale");
	
	that.scaleSVG.append("g")
				 .attr("class", "x axis")
				 .attr("transform", "translate(0,55)")
				 .attr("shape-rendering","crispEdges")
				 .call(that.xAxis);
	
	d3.select("#Level"+that.levelNumber).select(".x.axis")
					.append("text")
					.text(title)
					.attr("x", ((that.width-(that.margin*2))/2))
					.attr("y",-40)
					.attr("class","axisLbl");
	
	that.topLevel=that.topDiv.append("div")
					.attr("id","ScrollLevel"+that.levelNumber)
					/*.style("max-height","350px")
					.style("overflow","none")*/
					.style("width",(that.width+18)+"px")
					.append("ul")
					.attr("id","sortable"+that.levelNumber);
    //Add Sequence Track
    //that.addTrack("genomeSeq",3,"both",0);
    return that;
}

function selectionSVG(div,imageWidth,levelNumber,parent){
	var that={};
	
	that.imageWidth=imageWidth+25;
	that.levelNumber=levelNumber;
	that.parent=parent;

	that.coordSelectStart=0;
	that.coordSelectStop=0;
	that.visible=false;

	that.changeSelection=function(start,stop){
		that.start=start;
		that.stop=stop;
		
		that.setVis(true);		

		that.draw();
	}

	that.setVis=function(visible){
		that.visible=visible;
		if(that.visible){
			that.svg.style("display","inline-block");
			$("div#regionDiv").hide();
		}else{
			that.svg.style("display","none");
			$("div#regionDiv").show();
		}
		
	};

	that.draw=function(){
		if(that.visible){
			var w=that.xScale(that.stop)-that.xScale(that.start);
			that.parent.updateTrackSelectedArea(that.start,that.stop);
			var startStr=new String(numberWithCommas(Math.floor(that.start)));
			var stopStr=new String(numberWithCommas(Math.floor(that.stop)));
			that.svg.selectAll("line").remove();
			that.svg.selectAll("text").remove();
			that.svg.append("line")
				.attr("x1",function(){
					var ret=that.xScale(that.start);
					if(ret<0){
						ret=0;
					}
					return ret;
				})
				.attr("x2",function(){
					var ret=that.xScale(that.start);
					if(ret<0){
						ret=0;
					}
					return ret;
				})
				.attr("y1",0)
				.attr("y2",15)
				.attr("stroke","#00992D")
				.attr("stroke-width","1");
			that.svg.append("line")
				.attr("x1",function(){return that.xScale(that.stop);})
				.attr("x2",function(){return that.xScale(that.stop);})
				.attr("y1",0)
				.attr("y2",15)
				.attr("stroke","#00992D")
				.attr("stroke-width","1");
			that.svg.append("line")
				.attr("x1",function(){
					var ret=that.xScale(that.start);
					if(ret<0){
						ret=0;
					}
					return ret;
				})
				.attr("x2",0)
				.attr("y1",15)
				.attr("y2",60)
				.attr("stroke","#00992D")
				.attr("stroke-width","1");
			that.svg.append("line")
				.attr("x1",function(){return that.xScale(that.stop);})
				.attr("x2",that.imageWidth)
				.attr("y1",15)
				.attr("y2",60)
				.attr("stroke","#00992D")
				.attr("stroke-width","1");
			that.svg.append("text")
								.attr("x",that.xScale(that.start)-(startStr.length*7.5)-10)
								.attr("y",15)
								.text(startStr);
			that.svg.append("text")
								.attr("x",that.xScale(that.stop)+10)
								.attr("y",15)
								.text(stopStr);
		}
	};
	that.redraw=function(){
		that.draw();
	};
	that.setup=function(){
		    that.svg=d3.select(div).append("svg:svg")
					    .attr("width", that.imageWidth)
					    .attr("height", 60)
					    .attr("id","selectionLevel"+that.levelNumber)
					    .style("display","none");
			that.xScale=that.parent.xScale;
	}
	that.setup();
	return that;
}

//Track Functions
function Track(gsvgP,dataP,trackClassP,labelP){
	var that={};

	that.selectionStart=gsvgP.selectionStart;
	that.selectionEnd=gsvgP.selectionEnd;

	that.ttSVGMinWidth=20;

	that.panDown=function(){
		if(that.gsvg.overSettings==0 && that.gsvg.defaultMouseFunct=="dragzoom" && overSelectable==0){
			var p = d3.mouse(that.gsvg.vis[0][0]);
				that.gsvg.downZoomx=p[0];
				that.svg.append("rect")
						.attr("class","zoomRect")
						.attr("x",p[0])
						.attr("y",0)
		    			.attr("height",that.svg.attr("height"))
						.attr("width",1)
						.attr("fill","#CECECE")
						.attr("opacity",0.3);
				that.scaleSVG.append("rect")
						.attr("class","zoomRect")
						.attr("x",p[0])
						.attr("y",0)
		    			.attr("height",that.scaleSVG.attr("height"))
						.attr("width",1)
						.attr("fill","#CECECE")
						.attr("opacity",0.3);
				that.scaleSVG.append("text").attr("id","zoomTextStart").attr("x",that.gsvg.downZoomx).attr("y",15).text(numberWithCommas(Math.round(that.xScale.invert(that.gsvg.downZoomx))));
				that.scaleSVG.append("text").attr("id","zoomTextEnd").attr("x",that.gsvg.downZoomx).attr("y",50).text(numberWithCommas(Math.round(that.xScale.invert(that.gsvg.downZoomx))));
		}else if(that.gsvg.overSettings==0 && that.gsvg.defaultMouseFunct=="pan" && overSelectable==0){
			if(processAjax==0){
				var p = d3.mouse(that.gsvg.vis[0][0]);
	        	that.gsvg.downPanx = p[0];
	        	that.gsvg.downscalex = that.xScale;
        	}
		}else if(that.gsvg.overSettings==0 && that.gsvg.defaultMouseFunct=="reorder"){

		}
	};

	that.zoomToFeature= function(d){
					var len=d.getAttribute("stop")-d.getAttribute("start");
					len=len*0.25;
					var minx=d.getAttribute("start")-len;
					var maxx=(d.getAttribute("stop")*1)+len;
					if(maxx<=that.gsvg.xMax && minx>=1){
	            		that.xScale.domain([minx,maxx]);
						that.scaleSVG.select(".x.axis").call(that.xAxis);
						that.gsvg.redraw();
						if(that.gsvg.levelNumber==0||that.gsvg.levelNumber==1){
							var tmp={};
							tmp.chr=chr;
							tmp.start=minx;
							tmp.stop=maxx;
							history[that.gsvg.levelNumber].push(tmp);
						}
					}
	};
	that.clearSelection = function (){
		that.selectionStart=-1;
		that.selectionEnd=-1;
		//d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("rect.selectedArea").remove();
		that.svg.selectAll("rect.selectedArea").remove();
		that.svg.selectAll(".selected").each(function(){
							that.svg.select(this).attr("class","").style("fill",that.color);
						});
		/*d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".selected").each(function(){
							d3.select(that).attr("class","").style("fill",that.color);
						});*/
	};

	that.setSelectedArea=function(start,end){
		that.selectionStart=start;
		that.selectionEnd=end;
		that.redrawSelectedArea();
	};
	that.redrawSelectedArea = function (){
		d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".selectedArea").remove();
		if(that.selectionStart>-1&&that.selectionEnd>-1){
			var tmpStart=that.xScale(that.selectionStart);
			var tmpW=that.xScale(that.selectionEnd)-tmpStart;
			if(tmpW<1){
				tmpW=1;
			}
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).append("rect")
							.attr("class","selectedArea")
							.attr("x",tmpStart)
							.attr("y",0)
			    			.attr("height",function(){
			    					var rectH=that.svg.attr("height");
			    					if(rectH<15){
			    						rectH=15;
			    					}
			    					return rectH;
			    				})
							.attr("width",tmpW)
							.attr("fill","#CECECE")
							.attr("opacity",0.3)
							.attr("pointer-events","none");
		}
	};
	that.colorStroke = function (d){
			var colorRet="black";
			if(that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"))<3){
				colorRet=that.color(d);
			}
			return colorRet;
	};

	that.calcY = function (start,end,i){
		var tmpY=0;
		if(that.density==3){
			if((start>=that.xScale.domain()[0]&&start<=that.xScale.domain()[1])||
				(end>=that.xScale.domain()[0]&&end<=that.xScale.domain()[1])||
				(start<=that.xScale.domain()[0]&&end>=that.xScale.domain()[1])){
				var pStart=Math.round(that.xScale(start));
				if(pStart<0){
					pStart=0;
				}
				var pEnd=Math.round(that.xScale(end));
				if(pEnd>=that.gsvg.width){
					pEnd=that.gsvg.width-1;
				}
				var pixStart=pStart-2;
				if(pixStart<0){
					pixStart=0;
				}
				var pixEnd=pEnd+2;
				if(pixEnd>=that.gsvg.width){
					pixEnd=that.gsvg.width-1;
				}
				var yMax=0;
				for(var pix=pixStart;pix<=pixEnd;pix++){
					if(that.yArr[pix]>yMax){
						yMax=that.yArr[pix];
					}
				}
				yMax++;
				if(yMax>that.trackYMax){
					that.trackYMax=yMax;
				}
				for(var pix=pStart;pix<=pEnd;pix++){
					that.yArr[pix]=yMax;
				}
				tmpY=yMax*15;
			}else{
				tmpY=15;
			}
		}else if(that.density==2){
			tmpY=(i+1)*15;
		}else{
			tmpY=15;
		}
		if(that.trackYMax<(tmpY/15)){
			that.trackYMax=(tmpY/15);
		}
		return tmpY;
	};

	that.positionTTLeft = function(pageX){
		var x=pageX+20;
    	if(x>that.gsvg.halfWindowWidth){
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

	that.drawLegend = function (legendList){
		var lblStr=new String(that.label);
		var x=that.gsvg.width/2+(lblStr.length/2)*7.5+16;
		if(that.gsvg.width<500){
			x=(lblStr.length)*7.5;
		}
		d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".legend").remove();
		for(var i=0;i<legendList.length;i++){
			that.svg.append("rect")
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
			that.svg.append("text").text(lblStr).attr("class","legend").attr("x",x+18).attr("y",12);
			x=x+25+lblStr.length*8;
		}
	};

	that.drawScaleLegend = function (minVal,maxVal,lbl,minColor,maxColor,offset){
		var lblStr=new String(that.label);
		var x=that.gsvg.width/2+(lblStr.length/2)*7.5+16;
		if(that.gsvg.width<500){
			x=(lblStr.length)*7.5;
		}
		x=x+offset;
		d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".legend").remove();
		d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("#def1").remove();
		var grad=that.svg.append("defs").attr("id","def1").append("linearGradient").attr("id","grad"+that.gsvg.levelNumber+that.trackClass);
		grad.append("stop").attr("offset","0%").style("stop-color",minColor);
		grad.append("stop").attr("offset","100%").style("stop-color",maxColor);
		lblStr=new String(minVal);
		var initOff=lblStr.length*7.6;
		that.svg.append("text").text(lblStr).attr("class","legend").attr("x",x).attr("y",12);
		that.svg.append("rect")
				.attr("class","legend")
				.attr("x",x+initOff+5)
				.attr("y",0)
				.attr("rx",3)
				.attr("ry",3)
		    	.attr("height",12)
				.attr("width",75)
				.attr("fill","url(#grad"+that.gsvg.levelNumber+that.trackClass+")");
				//.attr("stroke","#FFFFFF");
			lblStr=new String(maxVal);
			that.svg.append("text").text(lblStr).attr("class","legend").attr("x",x+initOff+80).attr("y",12);
			var off=lblStr.length*8+5;
			lblStr=new String(lbl);
			that.svg.append("text").text(lblStr).attr("class","legend").attr("x",x+initOff+80+off).attr("y",12);
	};

	that.showLoading = function (){
		if(d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.loading")>0){
			that.loading=d3.select(that.svg).selectAll("g.loading");
		}else{
			that.loading=that.svg.append("g").attr("class","loading");
			that.loading.append("rect")
						.attr("x",0)
						.attr("y",0)
		    			.attr("height",that.svg.attr("height"))
						.attr("width",that.gsvg.width)
						.attr("fill","#CECECE")
						.attr("opacity",0.6);
			that.loading.append("text").text("Loading...")
					.attr("x",that.gsvg.width/2-5*7.5)
					.attr("y",that.svg.attr("height")/2);
		}
	};

	that.hideLoading = function (){
		that.loading=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.loading");
		if(that.loading!=undefined){
			that.loading.remove();
		}
	};

	that.displayBreakDown=function(divSelector){
		var tmpW= 300,tmpH = 300,radius = Math.min(tmpW, tmpH) / 2;
		var winWidth=$(window).width()/2;
		if($(window).width()>1000){
			winWidth=($(window).width()-1000)/2;
		}

		if(!(typeof that.counts==="undefined") && that.counts.length>0){
			var noCounts=1;
			for(var n=0;n<that.counts.length&&noCounts==1;n++){
				if(that.counts[n].value>0){
					noCounts=0;
				}
			}
			if(noCounts==0){
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
		      		.data(pie(that.counts))
		    		.enter().append("g")
		      		.attr("class", "arc");
		      	g.append("path")
		      		.attr("d", arc)
		      		.attr("fill", that.pieColor)
			      	.on("mouseover",function (d){
			      		d3.select('.testToolTip').transition()        
				                .duration(200)      
				                .style("opacity", .95);      
				        d3.select('.testToolTip').html("Name: "+d.data.names+"<BR>Count: "+d.data.value)  
				                .style("left", (d3.event.pageX) + "px" )  
				                .style("top", (d3.event.pageY + 20) + "px");
				        that.triggerTableFilter(d);
				        /**/
			      		})
			      	.on("mouseout", function(d){
			      		d3.select('.testToolTip').transition()
							 .delay(500)       
			                .duration(200)      
			                .style("opacity", 0);
			            that.clearTableFilter(d);
			            
			      	});
		      	g.append("text")
		      		.attr("transform", function(d) { return "translate(" + arc.centroid(d) + ")"; })
		      		.attr("dy", ".35em")
		      		.attr("fill","#FFFFFF")
		      		//.attr("stroke","#000000")
		      		.style("text-anchor", "middle")
		      		.text(function(d) { 
		      				var ret=d.value;
		      				if(d.value==0){
		      					ret="";
		      				}
		      				return ret;
		      	});
	      	}
      	}
		
	};

	that.updateLabel= function (label){
		that.label=label;
		var lblStr=new String(that.label);
		if(that.gsvg.width>600){
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).select("#trkLbl").attr("x",that.gsvg.width/2-(lblStr.length/2)*7.5).text(lblStr);
		}else{
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).select("#trkLbl").attr("x",0).text(lblStr);
		}
		d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).select(".infoIcon").attr("transform", "translate("+(that.gsvg.width-20)+",0)");
		d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).select(".settings").attr("transform", "translate("+(that.gsvg.width-40)+",0)");
		//d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).select(".infoIcon").attr("transform", "translate(" + (that.gsvg.width/2+((lblStr.length/2)*7.5)) + ",0)");
	};

	that.resize=function(){
		d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).attr("width", that.gsvg.width);
		that.updateLabel(that.label);
		if(that.redrawLegend!=undefined){
			that.redrawLegend();
		}
		that.redraw();
	};

	that.triggerTableFilter=function(d){
		//not supported for general tracks see specific tracks.
	};
	that.clearTableFilter=function(d){
		//not supported for general tracks see specific tracks.
	};

	that.getDisplayID=function(d){
		return d.getAttribute("ID");
	};

	that.setupToolTipSVG=function(d,perc){
		//Setup Tooltip SVG
		var start=d.getAttribute("start")*1;
		var stop=d.getAttribute("stop")*1;
		var len=stop-start;
		var margin=Math.floor(len*perc);
		if(margin<20){
			margin=20;
		}
		var tmpStart=start-margin;
		var tmpStop=stop+margin;
		if(tmpStart<1){
			tmpStart=1;
		}
		if(that.ttSVGMinWidth!=undefined){
			if(tmpStop-tmpStart<that.ttSVGMinWidth){
				tmpStart=start-(that.ttSVGMinWidth/2);
				tmpStop=stop+(that.ttSVGMinWidth/2);
			}
		}
		var newSvg=toolTipSVG("div#ttSVG",450,tmpStart,tmpStop,99,that.getDisplayID(d),"transcript");
		newSvg.forLevel=that.gsvg.levelNumber;
		//Setup Track for current feature
		var dataArr=new Array();
		dataArr[0]=d;
		newSvg.addTrack(that.trackClass,3,"",dataArr);
		//Setup Other tracks included in the track type(listed in that.ttTrackList)
		for(var r=0;r<that.ttTrackList.length;r++){
			//console.log("track.setupToolTipSVG()");
			//console.log(that.ttTrackList[r]);
			//console.log(that.gsvg);
			//console.log(that.gsvg.getTrackData);
			var tData=that.gsvg.getTrackData(that.ttTrackList[r]);
			var fData=new Array();
			if(tData!=undefined&&tData.length>0){
				var fCount=0;
				for(var s=0;s<tData.length;s++){
					if((tmpStart<=tData[s].getAttribute("start")&&tData[s].getAttribute("start")<=tmpStop)
						|| (tData[s].getAttribute("start")<=tmpStart&&tData[s].getAttribute("stop")>=tmpStart)
						){
						fData[fCount]=tData[s];
						fCount++;
					}
				}
				if(fData.length>0){
					newSvg.addTrack(that.ttTrackList[r],3,"DrawTrx",fData);	
				}
			}
		}
	};

	that.generateSettingsDiv=function(topLevelSelector){
		that.savePrevious();
		var d=trackInfo[that.trackClass];
		//console.log(trackInfo);
		//console.log(d);
		d3.select(topLevelSelector).select("table").select("tbody").html("");
		if(d.Controls.length>0 && d.Controls!="null"){
			var controls=new String(d.Controls).split(",");
			var table=d3.select(topLevelSelector).select("table").select("tbody");
			table.append("tr").append("td").style("font-weight","bold").html("Track Settings: "+d.Name);
			for(var c=0;c<controls.length;c++){
				if(controls[c]!=undefined && controls[c]!=""){
					var params=controls[c].split(";");
					var div=table.append("tr").append("td");
					var lbl=params[0].substr(5);
					div.append("text").text(lbl+": ");
					var def="";
					if(params.length>3  && params[3].indexOf("Default=")==0){
						def=params[3].substr(8);
					}
					if(params[1].toLowerCase().indexOf("select")==0){
						var selClass=params[1].split(":");
						var opts=params[2].split("}");
						var prefix="";
						var suffix="";
						if(selClass.length>2){
							prefix=selClass[2];
						}
						if(selClass.length>3){
							suffix=selClass[3];
						}
						var sel=div.append("select").attr("id",that.trackClass+prefix+that.level+suffix)
							.attr("name",selClass[1]);
						for(var o=0;o<opts.length;o++){
							var option=opts[o].substr(1).split(":");
							if(option.length==2){
								var tmpOpt=sel.append("option").attr("value",option[1]).text(option[0]);

								if(prefix=="Dense" &&option[1]==that.density){
									tmpOpt.attr("selected","selected");
								}else if(option[1]==def){
									tmpOpt.attr("selected","selected");
								}
							}
						}
						d3.select("select#"+that.trackClass+prefix+that.level+suffix).on("change", function(){
							that.updateSettingsFromUI();
							that.redraw();
						});
					}else {
						console.log("Undefined track settings:  "+controls[c]);
					}
				}
			}
			var buttonDiv=table.append("tr").append("td");
			buttonDiv.append("input").attr("type","button").attr("value","Remove Track").style("float","left").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
				that.gsvg.setCurrentViewModified();
				that.gsvg.removeTrack(that.trackClass);
			});
			buttonDiv.append("input").attr("type","button").attr("value","Apply").style("float","right").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
				if(that.density!=that.prevSetting.density){
					that.gsvg.setCurrentViewModified();
				}
			});
			buttonDiv.append("input").attr("type","button").attr("value","Cancel").style("float","right").style("margin-left","5px").on("click",function(){
				that.revertPrevious();
				that.draw(that.data);
				$('#trackSettingDialog').fadeOut("fast");
			});
		}else{
			var table=d3.select(topLevelSelector).select("table").select("tbody");
			table.append("tr").append("td").style("font-weight","bold").html("Track Settings: "+d.Name);
			table.append("tr").append("td").html("Sorry no settings for this track.");
			var buttonDiv=table.append("tr").append("td");
			buttonDiv.append("input").attr("type","button").attr("value","Remove Track").style("float","left").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
				that.gsvg.setCurrentViewModified();
				that.gsvg.removeTrack(that.trackClass);
			});
			buttonDiv.append("input").attr("type","button").attr("value","Cancel").style("float","right").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
			});
		}
	};

	//poll UI controls to adjust settings and do nothing if they are not found
	that.updateSettingsFromUI=function(){
		if($("#"+that.trackClass+"Dense"+that.level+"Select").length>0){
			that.density=$("#"+that.trackClass+"Dense"+that.level+"Select").val();
		}
	};

	that.savePrevious=function(){
		that.prevSetting={};
		that.prevSetting.density=that.density;
	};
	
	that.revertPrevious=function(){
		that.density=that.prevSetting.density;
	};

	//update current settings from a view setting string
	that.updateSettings=function(setting){

	};
	//generate the setting string for a view from current settings
	that.generateTrackSettingString=function(){
		return that.trackClass+","+that.density+";";
	};

	that.ttMouseOver = function (){
		//console.log("Mouse OVER triggered:"+tt.style("opacity"));
		if(tt.style("opacity")>0){
					    		console.log("Mouse OVER TT");
					    		mouseTTOver=1;
					    		clearTimeout(ttHideHandle);
		}
	};

	that.ttMouseOver = function (){

	};

	that.gsvg=gsvgP;
	that.level=that.gsvg.levelNumber;
	that.data=dataP;
	that.label=labelP;
	that.density=2;
	that.yArr=new Array();
	that.loading;
	that.trackYMax=0;
	that.trackClass=trackClassP;
	that.topLevel=that.gsvg.get('topLevel');
	that.xScale=that.gsvg.get('xScale');
	that.scaleSVG=that.gsvg.get('scaleSVG');
	that.xAxis=that.gsvg.get('xAxis');
	for(var j=0;j<that.gsvg.width;j++){
				that.yArr[j]=0;
	}

	


	that.vis=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass);
	that.svg=d3.select("svg#Level"+that.gsvg.levelNumber+that.trackClass);
	that.svg.on("mousedown", that.panDown);
	that.updateLabel(that.label);
	return that;
}

//Specific Track Objects
/*Track for displaying sequence and translated aa sequence*/
function SequenceTrack(gsvg,trackClass,label,additionalOptions){
	var data=new Array();
	var that=Track(gsvg,data,trackClass,label);
	that.dispCutoff=300;
	that.aaDispCutoff=2900;
	that.seqRegionSize=4000;
	that.strands="both";
	that.includeAA=1;
	that.labelBase=label;
	that.lastUpdate=0;
	that.seqRegionMin=0;
	that.seqRegionMax=0;

	that.color=function(d){

	};
	that.colorAA=function(d,i){
		var color=d3.rgb("#FFFFFF");
		if(d.pos%2==0){
			color=d3.rgb("#C3C3C3");
		}else{
			color=d3.rgb("#838383");
		}
		if(d.aa=="M"){
			color=d3.rgb("#00FF00");
		}
		if(d.aa=="*"){
			color=d3.rgb("#FF0000");
		}
		return color;
	};
	that.createCodon=function(){
		that.codons=[];
		that.codons["AAA"]="K";
		that.codons["AAT"]="N";
		that.codons["AAG"]="K";
		that.codons["AAC"]="N";
		that.codons["ATA"]="I";
		that.codons["ATT"]="I";
		that.codons["ATG"]="M";
		that.codons["ATC"]="I";
		that.codons["ACA"]="T";
		that.codons["ACT"]="T";
		that.codons["ACG"]="T";
		that.codons["ACC"]="T";
		that.codons["AGA"]="R";
		that.codons["AGT"]="S";
		that.codons["AGG"]="R";
		that.codons["AGC"]="S";
		that.codons["TAA"]="*";
		that.codons["TAT"]="Y";
		that.codons["TAG"]="*";
		that.codons["TAC"]="Y";
		that.codons["TTA"]="L";
		that.codons["TTT"]="F";
		that.codons["TTG"]="L";
		that.codons["TTC"]="F";
		that.codons["TCA"]="S";
		that.codons["TCT"]="S";
		that.codons["TCG"]="S";
		that.codons["TCC"]="S";
		that.codons["TGA"]="*";
		that.codons["TGT"]="C";
		that.codons["TGG"]="W";
		that.codons["TGC"]="C";
		that.codons["CAA"]="Q";
		that.codons["CAT"]="H";
		that.codons["CAG"]="Q";
		that.codons["CAC"]="H";
		that.codons["CTA"]="L";
		that.codons["CTT"]="L";
		that.codons["CTG"]="L";
		that.codons["CTC"]="L";
		that.codons["CCA"]="P";
		that.codons["CCT"]="P";
		that.codons["CCG"]="P";
		that.codons["CCC"]="P";
		that.codons["CGA"]="R";
		that.codons["CGT"]="R";
		that.codons["CGG"]="R";
		that.codons["CGC"]="R";
		that.codons["GAA"]="E";
		that.codons["GAT"]="D";
		that.codons["GAG"]="E";
		that.codons["GAC"]="D";
		that.codons["GTA"]="V";
		that.codons["GTT"]="V";
		that.codons["GTG"]="V";
		that.codons["GTC"]="V";
		that.codons["GCA"]="A";
		that.codons["GCT"]="A";
		that.codons["GCG"]="A";
		that.codons["GCC"]="A";
		that.codons["GGA"]="G";
		that.codons["GGT"]="G";
		that.codons["GGG"]="G";
		that.codons["GGC"]="G";
	}
	that.translate=function(d){
		d=d.toUpperCase();
		return that.codons[d];
	}
	that.translateRegion=function(aaLevel,offset,start,stop){
		var aaSeq=new Array();
		var aaCount=0;
		var minus=0;
		if(start>stop){//minus strand
			minus=1;
			var tmpstart=start;
			start=stop;
			stop=tmpstart;
		}
		for(var i=start;i<=stop;i=i+3){
				var seq=that.data.substring(i,i+3);
				if(minus==1){
					seq=that.reverseCompliment(seq);
				}
				aaSeq[aaCount]=[];
				aaSeq[aaCount].aa=that.translate(seq);
				aaSeq[aaCount].pos=offset+(i-start);
				aaSeq[aaCount].id=aaLevel+":"+i+":"+that.translate(seq);
				aaCount++;
		}
		return aaSeq;
	}
	that.reverseCompliment=function (seq){
		var rc="";
		for(var k=seq.length-1;k>-1;k--){
			rc=rc+that.complement(seq.charAt(k));
		}
		return rc;
	}
	that.complement=function(d){
		var comp="N";
		if(d=="A"){
			comp="T";
		}else if(d=="T"){
			comp="A";
		}else if(d=="G"){
			comp="C";
		}else if(d=="C"){
			comp="G";
		}
		return comp;
	}
	that.redraw=function(){
		that.redrawSelectedArea();

		if(that.prevStrand!=that.strands||that.prevIncldAA!=that.includeAA){
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.base").each(function(d){d3.select(this).remove();});
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.aa0").each(function(d){d3.select(this).remove();});
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.aa1").each(function(d){d3.select(this).remove();});
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.aa2").each(function(d){d3.select(this).remove();});
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.aarev0").each(function(d){d3.select(this).remove();});
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.aarev1").each(function(d){d3.select(this).remove();});
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.aarev2").each(function(d){d3.select(this).remove();});
			that.draw(that.data);
		}else{
			var tmpMin=that.xScale.domain()[0];
			var tmpMax=that.xScale.domain()[1];
			var len=tmpMax-tmpMin;
			var aaFont="12px";
			if(len>200){
				aaFont="10px";
			}
			if( (len<=that.aaDispCutoff&&that.includeAA==1) || (len<=that.dispCutoff) ){
				if(!(that.seqRegionMin<=tmpMin && tmpMin<=that.seqRegionMax
					&& that.seqRegionMin<=tmpMax && tmpMax<=that.seqRegionMax)){
					that.updateData(0);
				}else{
					var charWidth=that.gsvg.width/len;
					var offsetNA=charWidth/2;
					var startInd=tmpMin-that.seqRegionMin;
					var stopInd=len+startInd;
					var seqYPos=27;
					if(that.includeAA==1&&that.strands!="-"){
							seqYPos=seqYPos+30;
					}
					if(len<that.dispCutoff){
						d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.line").remove();
						var dataLen=that.data.length;
						var dArr=new Array();
						for(var j=startInd;j<stopInd;j++){
							dArr[j-startInd]=[];
							dArr[j-startInd].base=that.data.charAt(j);
							dArr[j-startInd].id=j;
							dArr[j-startInd].pos=j-startInd;
						}
						var textSizeVar=that.textSize(len);
						var yPosComp=that.yPosition(len);

						
						
						var base=that.svg.selectAll(".base")
					   			.data(dArr,keyID)
								.attr("transform",function(d,i){ return "translate("+((d.pos)*charWidth-offsetNA)+","+seqYPos+")";});
						//add new
						var appended=base.enter().append("g")
								.attr("class","base")
								.attr("transform",function(d,i){ return "translate("+((d.pos)*charWidth-offsetNA)+","+seqYPos+")";});
						appended.each(function(d){
								d3.select(this).append("text")
					    		.text(function(d){
					    			if(that.strands!="-"){
					    				return d.base;
					    			}else{
					    				return that.complement(d.base);
					    			}
					    		});
					    		if(that.strands=="both"){
					    			d3.select(this).append("text")
					    				.attr("class","comp")
										.attr("y",yPosComp)
							    		.text(function(d){
							    				return that.complement(d.base);
							    		});
					    		}
					    	});
						
						base.exit().remove();
						base.selectAll("text").attr("font-size",function(d){return that.textSize(len);});
						base.selectAll("text.comp").attr("y",yPosComp);
					}else{
						d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.base").remove();
						that.svg.append("g")
							.attr("class","line")
							.append("line")
							.attr("stroke","#000000")
							.attr("x1",0)
							.attr("y1",seqYPos)
							.attr("x2",that.gsvg.width)
							.attr("y2",seqYPos);
					}
					if(that.includeAA==1){
						var aaCharW=charWidth*3;
						/*var offsetAA=charWidth/2;
						if(offsetAA<5){
							offsetAA=0;
						}*/
						var aaXLoc=aaCharW/2-4;
						var tmpLineAt=25;
						if(that.strands=="both"||that.strands=="+"){
							var modStart=tmpMin%3;
							var zeroStart=startInd-modStart;
							var aaList=new Array();
							aaList[0]=that.translateRegion(0,tmpMin-modStart,zeroStart,zeroStart+len);
							aaList[1]=that.translateRegion(1,tmpMin-modStart-1,zeroStart-1,zeroStart-1+len);
							aaList[2]=that.translateRegion(2,tmpMin-modStart-2,zeroStart-2,zeroStart-2+len);
							var tmpLineAt=25;
							for(var j=0;j<3;j++){
								var aa=that.svg.selectAll(".aa"+j)
					   				.data(aaList[j],keyID)
									.attr("transform",function(d,i){ return "translate("+(that.xScale(d.pos)-charWidth)+","+tmpLineAt+")";})
									.each(function(d){
										d3.select(this).select("rect").attr("width",aaCharW);
										if(len<that.dispCutoff){
											if(d3.select(this).select("text").size()==0){
												d3.select(this).append("text")
												.attr("x",aaXLoc)
												.attr("font-size",aaFont)
							    				.text(function(d){
							    					return d.aa;
							    				});
											}else{
												d3.select(this).select("text").attr("x",aaXLoc).attr("font-size",aaFont);
											}
										}else{
											d3.select(this).select("text").remove();
										}
									});
								//add new
								var appended=aa.enter().append("g")
										.attr("class","aa"+j)
										.attr("transform",function(d,i){ return "translate("+(that.xScale(d.pos)-charWidth)+","+tmpLineAt+")";});
								appended.each( function (d){
										d3.select(this).append("rect")
											.attr("y",-10)
											.attr("height",10)
											.attr("width",aaCharW)
											.attr("stroke",that.colorAA)
											.attr("fill",that.colorAA);
										if(len<that.dispCutoff){	
											d3.select(this).append("text")
												.attr("x",aaXLoc)
												.attr("font-size",aaFont)
							    				.text(function(d){
							    					return d.aa;
							    				});
							    		}
							    	});
								aa.exit().remove();
								tmpLineAt=tmpLineAt+11;
							}
							
						}
						if(that.strands=="both"){
							tmpLineAt=80;
						}else{
							tmpLineAt=45;
						}
						if(that.strands=="both"||that.strands=="-"){
							var modStart=tmpMin%3;
							var zeroStart=startInd-modStart;
							var aaList=new Array();
							aaList[0]=that.translateRegion(0,tmpMin-modStart,zeroStart+len,zeroStart);
							aaList[1]=that.translateRegion(1,tmpMin-modStart-1,zeroStart-1+len,zeroStart-1);
							aaList[2]=that.translateRegion(2,tmpMin-modStart-2,zeroStart-2+len,zeroStart-2);
							for(var j=0;j<3;j++){
								var aa=that.svg.selectAll(".aarev"+j)
					   				.data(aaList[j],keyID)
									.attr("transform",function(d,i){ return "translate("+(that.xScale(d.pos)-charWidth)+","+tmpLineAt+")";})
									.each(function(d){
										d3.select(this).select("rect").attr("width",aaCharW);
										if(len<that.dispCutoff){
											if(d3.select(this).select("text").size()==0){
												d3.select(this).append("text")
												.attr("x",aaXLoc)
												.attr("font-size",aaFont)
							    				.text(function(d){
							    					return d.aa;
							    				});
											}else{
												d3.select(this).select("text").attr("x",aaXLoc).attr("font-size",aaFont);
											}
										}else{
											d3.select(this).select("text").remove();
										}	
									});
								//add new
								var appended=aa.enter().append("g")
										.attr("class","aarev"+j)
										.attr("transform",function(d,i){ return "translate("+that.xScale(d.pos)+","+tmpLineAt+")";});
								appended.each( function (d){
										d3.select(this).append("rect")
											.attr("y",-10)
											.attr("height",10)
											.attr("width",aaCharW)
											.attr("stroke",that.colorAA)
											.attr("fill",that.colorAA);
										if(len<that.dispCutoff){	
											d3.select(this).append("text")
												.attr("x",aaXLoc)
												.attr("font-size",aaFont)
								    			.text(function(d){
								    				return d.aa;
								    			});
							    		}
							    	});
								aa.exit().remove();
								tmpLineAt=tmpLineAt+11;
							}
						}
						if(that.strands=="both"){
							that.svg.attr("height", 125);
						}else{
							that.svg.attr("height", 75);
						}
					}else{
						if(that.strands=="both"){
							that.svg.attr("height", 45);
						}else{
							that.svg.attr("height", 30);
						}
					}
				}
				$("li.draggable"+that.gsvg.levelNumber+"#li"+that.trackClass).show();
			}else{
				that.svg.attr("height", 0);
				$("li.draggable"+that.gsvg.levelNumber+"#li"+that.trackClass).hide();
			}
		}
	};
	that.draw=function(data){
		that.redrawSelectedArea();
		
		var aaLabel="";
		if(that.includeAA==1){
			aaLabel=" and Amino Acids"
		}

		if(that.strands=="both"){
			that.label=that.labelBase+aaLabel+" on +/- strands";
		}else if(that.strands=="+"){
			that.label=that.labelBase+aaLabel+" on + strand";
		}else if(that.strands=="-"){
			that.label=that.labelBase+aaLabel+" on - strand";
		}

		if((len<=that.aaDispCutoff&&that.includeAA==1) || (len<=that.dispCutoff)){
		}else{//Only needed to Fix IE Bug which still displays the label
			that.label="";
		}
		
		that.updateLabel(that.label);
		that.data=data;
		var tmpMin=that.xScale.domain()[0];
		var tmpMax=that.xScale.domain()[1];
		var len=tmpMax-tmpMin;
		var aaFont="10px";
		if(len>200){
			aaFont="8px";
		}
		if((len<=that.aaDispCutoff&&that.includeAA==1) || (len<=that.dispCutoff)){
			that.svg.selectAll("text.dir").remove();
			if(that.strands=="both"){
				that.svg.append("text").attr("class","dir").attr("x",5).attr("y",15).text("-->");
				that.svg.append("text").attr("class","dir").attr("x",5).attr("y",120).text("<--");
				that.svg.append("text").attr("class","dir").attr("x",that.gsvg.width-60).attr("y",15).text("-->");
				that.svg.append("text").attr("class","dir").attr("x",that.gsvg.width-20).attr("y",120).text("<--");
			}else if(that.strands=="+"){
				that.svg.append("text").attr("class","dir").attr("x",5).attr("y",15).text("-->");
				that.svg.append("text").attr("class","dir").attr("x",that.gsvg.width-60).attr("y",15).text("-->");
			}else if(that.strands=="-"){
				that.svg.append("text").attr("class","dir").attr("x",5).attr("y",15).text("<--");
				that.svg.append("text").attr("class","dir").attr("x",that.gsvg.width-60).attr("y",15).text("<--");
			}
			
			if(len<that.dispCutoff){
				var dataLen=data.length;
				var startInd=tmpMin-that.seqRegionMin;
				var stopInd=len+startInd;
				var dArr=new Array();
				for(var j=startInd;j<stopInd;j++){
					dArr[j-startInd]=[];
					dArr[j-startInd].base=data.charAt(j);
					dArr[j-startInd].id=j;
					dArr[j-startInd].pos=j-startInd;
				}
				var textSizeVar=that.textSize(len);
				var yPosComp=that.yPosition(len);
				var seqYPos=27;
				if(that.includeAA==1&&that.strands!="-"){
					seqYPos=seqYPos+30;
				}

				var charWidth=that.gsvg.width/len;
				var base=that.svg.selectAll(".base")
			   			.data(dArr,keyID)
						.attr("transform",function(d,i){ return "translate("+((d.pos)*charWidth)+","+seqYPos+")";});
				//add new
				var appended=base.enter().append("g")
						.attr("class","base")
						.attr("transform",function(d,i){ return "translate("+((d.pos)*charWidth)+","+seqYPos+")";});
				appended.each( function (d){		
						d3.select(this).append("text")
			    		.text(function(d){
			    			if(that.strands!="-"){
			    				return d.base;
			    			}else{
			    				return that.complement(d.base);
			    			}
			    		});
			    		if(that.strands=="both"){
			    			d3.select(this).append("text")
			    				.attr("class","comp")
								.attr("y",yPosComp)
					    		.text(function(d){
					    				return that.complement(d.base);
					    		});
			    		}
			    	});
				
				base.exit().remove();
				base.selectAll("text").attr("font-size",textSizeVar);
			}else{
				that.svg.append("g")
					.attr("class","base")
					.append("line")
					.attr("stroke","#000000")
					.attr("x1",0)
					.attr("y1",57)
					.attr("x2",that.gsvg.width)
					.attr("y2",57);
			}
			if(that.includeAA==1){
				var aaCharW=charWidth*3;
				var offsetAA=charWidth/2;
				var aaXLoc=aaCharW/2-4;
				var tmpLineAt=25;
				if(that.strands=="both"||that.strands=="+"){
					var modStart=tmpMin%3;
					var zeroStart=startInd-modStart;
					var aaList=new Array();
					aaList[0]=that.translateRegion(0,tmpMin-modStart,zeroStart,zeroStart+len);
					aaList[1]=that.translateRegion(1,tmpMin-modStart-2,zeroStart-2,zeroStart-2+len);
					aaList[2]=that.translateRegion(2,tmpMin-modStart-1,zeroStart-1,zeroStart-1+len);
					var tmpLineAt=25;
					for(var j=0;j<3;j++){
						var aa=that.svg.selectAll(".aa"+j)
			   				.data(aaList[j],keyID)
							.attr("transform",function(d,i){ return "translate("+that.xScale(d.pos)+","+tmpLineAt+")";});
						//add new
						var appended=aa.enter().append("g")
								.attr("class","aa"+j)
								.attr("transform",function(d,i){ return "translate("+that.xScale(d.pos)+","+tmpLineAt+")";});
						appended.each( function (d){
								d3.select(this).append("rect")
									.attr("y",-10)
									.attr("height",10)
									.attr("width",aaCharW)
									.attr("stroke",that.colorAA)
									.attr("fill",that.colorAA);	
								d3.select(this).append("text")
									.attr("x",aaXLoc)
									.attr("font-size",aaFont)
					    			.text(function(d){
					    				return d.aa;
					    			});
					    	});
						aa.exit().remove();
						tmpLineAt=tmpLineAt+11;
					}
					
				}
				if(that.strands=="both"){
					tmpLineAt=80;
				}else{
					tmpLineAt=45;
				}
				if(that.strands=="both"||that.strands=="-"){
					var modStart=tmpMin%3;
					var zeroStart=startInd-modStart;
					var aaList=new Array();
					aaList[0]=that.translateRegion(0,tmpMin-modStart,zeroStart+len,zeroStart);
					aaList[1]=that.translateRegion(1,tmpMin-modStart-1,zeroStart-1+len,zeroStart-1);
					aaList[2]=that.translateRegion(2,tmpMin-modStart-2,zeroStart-2+len,zeroStart-2);
					for(var j=0;j<3;j++){
						var aa=that.svg.selectAll(".aarev"+j)
			   				.data(aaList[j],keyID)
							.attr("transform",function(d,i){ return "translate("+that.xScale(d.pos)+","+tmpLineAt+")";});
						//add new
						var appended=aa.enter().append("g")
								.attr("class","aarev"+j)
								.attr("transform",function(d,i){ return "translate("+that.xScale(d.pos)+","+tmpLineAt+")";});
						appended.each( function (d){
								d3.select(this).append("rect")
									.attr("y",-10)
									.attr("height",10)
									.attr("width",aaCharW)
									.attr("stroke",that.colorAA)
									.attr("fill",that.colorAA);	
								d3.select(this).append("text")
									.attr("x",aaXLoc)
									.attr("font-size",aaFont)
					    			.text(function(d){
					    				return d.aa;
					    			});
					    	});
						aa.exit().remove();
						tmpLineAt=tmpLineAt+11;
					}
				}
				if(that.strands=="both"){
					that.svg.attr("height", 125);
				}else{
					that.svg.attr("height", 75);
				}
			}else{
				if(that.strands=="both"){
					that.svg.attr("height", 45);
				}else{
					that.svg.attr("height", 30);
				}
			}
			that.prevStrand=that.strands;
			that.prevIncldAA=that.includeAA;
			$("li.draggable"+that.gsvg.levelNumber+"#li"+that.trackClass).show();
		}else{
			that.svg.attr("height", 0);
			$("li.draggable"+that.gsvg.levelNumber+"#li"+that.trackClass).hide();
		}
	};
	

	that.textSize = function (len){
		var size="9px";
		if(len<=100){
			    				size="11px";
		}else if(len<=150){
			    				size="8px";
		}else if(len<=200){
			    				size="6.8px";
		}else if(len<=250){
			    				size="5.8px";
		}else if(len<=300){
			    				size="4.8px";
		}
		return size;
	}
	that.yPosition = function (len){
		var size=12;
		if(len<=100){
			size=12;
		}else if(len<=150){
			size=10;
		}else if(len<=200){
			size=8;
		}else if(len<=250){
			size=6;
		}else if(len<=300){
			size=5;
		}
		return size;
	}
	that.updateData=function(retry){
		var curTime=(new Date()).getTime();
		if(curTime-that.lastUpdate>25000||retry>0){
			var tmpseqRegionMin=that.xScale.domain()[0]-that.seqRegionSize;
			var tmpseqRegionMax=that.xScale.domain()[1]+that.seqRegionSize;
			if(tmpseqRegionMin<0){
				tmpseqRegionMin=0;
			}
			if((that.xScale.domain()[1]-that.xScale.domain()[0])<that.aaDispCutoff){
				that.lastUpdate=curTime;
				if(that.svg.attr("height")<30){
					that.svg.attr("height", 30);
				}
				if(retry==0){
					that.showLoading();
				}
				
				var path=dataPrefix+"tmpData/regionData/"+that.gsvg.folderName+"/"+tmpseqRegionMin+"_"+tmpseqRegionMax+".seq";
				d3.text(path,function (error,d){
					if(error){
						//console.log(error);
						if(retry==0){
									$.ajax({
										url: contextPath +"/"+ pathPrefix +"generateTrackXML.jsp",
						   				type: 'GET',
										data: {chromosome: chr,minCoord:tmpseqRegionMin,maxCoord:tmpseqRegionMax,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: that.trackClass, folder: that.gsvg.folderName},
										dataType: 'json',
						    			success: function(data2){
						    				
						    			},
						    			error: function(xhr, status, error) {
						        			
						    			}
									});
						}
						if(retry<3){//wait before trying again
								var time=10000;
								if(retry==1){
										time=15000;
								}
								setTimeout(function (){
									that.updateData(retry+1);
								},time);
						}else{
									that.seqRegionMin=0;
									that.seqRegionMax=0;
									that.hideLoading();
									d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).select("#trkLbl").text("An errror occurred loading Track:"+that.trackClass);
									d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).attr("height", 15);
									that.gsvg.addTrackErrorRemove(that.svg,"#Level"+that.gsvg.levelNumber+that.trackClass);
									that.lastUpdate=0;
						}
					}else{
						that.seqRegionMin=tmpseqRegionMin;
						that.seqRegionMax=tmpseqRegionMax;
						
						that.draw(d);
						that.hideLoading();
						that.lastUpdate=0;
						DisplayRegionReport();
					}
				});
			}
		}
	};

	that.updateSettingsFromUI=function(){
		if($("#"+that.trackClass+that.level+"Select").length>0){
			that.strands=$("#"+that.trackClass+that.level+"Select").val();
		}
		if($("#"+that.trackClass+"CBX"+that.level+"dispAA").length>0){
			if($("#"+that.trackClass+"CBX"+that.level+"dispAA").is(":checked")){
				that.includeAA=1;
			}else{
				that.includeAA=0;
			}
		}
	};

	that.savePrevious=function(){
		that.prevSetting={};
		that.prevSetting.strands=that.strands;
		that.prevSetting.includeAA=that.includeAA;
	};
	
	that.revertPrevious=function(){
		that.strands=that.prevSetting.strands;
		that.includeAA=that.prevSetting.includeAA;
	};

	that.generateTrackSettingString=function(){
		return that.trackClass+","+that.strands+","+that.includeAA+";";
	};

	that.generateSettingsDiv=function(topLevelSelector){
		var d=trackInfo[that.trackClass];
		that.savePrevious();
		//console.log(trackInfo);
		//console.log(d);
		d3.select(topLevelSelector).select("table").select("tbody").html("");
		if(d.Controls.length>0 && d.Controls!="null"){
			var controls=new String(d.Controls).split(",");
			var table=d3.select(topLevelSelector).select("table").select("tbody");
			table.append("tr").append("td").style("font-weight","bold").html("Track Settings: "+d.Name);
			for(var c=0;c<controls.length;c++){
				if(controls[c]!=undefined && controls[c]!=""){
					var params=controls[c].split(";");
					
					var div=table.append("tr").append("td");
					var lbl=params[0].substr(5);
					
					var def="";
					if(params.length>3  && params[3].indexOf("Default=")==0){
						def=params[3].substr(8);
					}
					if(params[1].toLowerCase().indexOf("select")==0){
						div.append("text").text(lbl+": ");
						var selClass=params[1].split(":");
						var opts=params[2].split("}");
						var id=that.trackClass+that.level+"Select";
						var sel=div.append("select").attr("id",id)
							.attr("name",selClass[1]);
						for(var o=0;o<opts.length;o++){
							var option=opts[o].substr(1).split(":");
							if(option.length==2){
								var tmpOpt=sel.append("option").attr("value",option[1]).text(option[0]);
								if(option[1]==that.strands){
									tmpOpt.attr("selected","selected");
								}
								/*if(option[1]==def){
									tmpOpt.attr("selected","selected");
								}*/
							}
						}
						d3.select("select#"+id).on("change", function(){
							that.updateSettingsFromUI();
							that.redraw();
						});
					}else if(params[1].toLowerCase().indexOf("cbx")==0){	
						div.append("text").text(lbl);
						var selClass=params[1].split(":");
						var opts=params[2].split("}");
						
						for(var o=0;o<opts.length;o++){
							var option=opts[o].substr(1).split(":");
							if(option.length==2){
								var span=div.append("div").style("display","inline-block");
								var suffix="";
								var prefix="";
								if(selClass.length>2){
									prefix=selClass[2];
								}
								if(selClass.length>3){
									suffix=selClass[3];
								}
								var sel=span.append("input").attr("type","checkbox").attr("id",that.trackClass+prefix+"CBX"+that.level+suffix)
									.attr("name",selClass[1])
									.style("margin-left","5px");
								span.append("text").text(option[0]);
								//console.log(def+"::"+option[1]);
								if(that.includeAA==1){
									$("#"+that.trackClass+prefix+"CBX"+that.level+suffix).prop('checked',true);
									//sel.attr("checked","checked");
								}else{
									$("#"+that.trackClass+prefix+"CBX"+that.level+suffix).prop('checked',false);
								}
								d3.select("input#"+that.trackClass+prefix+"CBX"+that.level+suffix).on("change", function(){
									//console.log("CBX changed");
									that.updateSettingsFromUI();
									that.redraw();
								});
							}
						}
					}
				}
			}
			var buttonDiv=table.append("tr").append("td");
			buttonDiv.append("input").attr("type","button").attr("value","Remove Track").style("float","left").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
				that.gsvg.removeTrack(that.trackClass);
			});
			buttonDiv.append("input").attr("type","button").attr("value","Apply").style("float","right").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
				if(that.strands!=that.prevSetting.strands || that.includeAA!=that.prevSetting.includeAA){
					that.gsvg.setCurrentViewModified();
				}
			});
			buttonDiv.append("input").attr("type","button").attr("value","Cancel").style("float","right").style("margin-left","5px").on("click",function(){
				that.revertPrevious();
				that.draw(that.data);
				$('#trackSettingDialog').fadeOut("fast");
			});
		}else{
			var table=d3.select(topLevelSelector).select("table").select("tbody");
			table.append("tr").append("td").style("font-weight","bold").html("Track Settings: "+d.Name);
			table.append("tr").append("td").html("Sorry no settings for this track.");
			var buttonDiv=table.append("tr").append("td");
			buttonDiv.append("input").attr("type","button").attr("value","Remove Track").style("float","left").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
			});
			buttonDiv.append("input").attr("type","button").attr("value","Cancel").style("float","right").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
			});
		}
	};

	that.createCodon();
	that.updateData(0);
	that.draw(data);
	return that;
}
/*Track for displaying ProteinCoding,Long Non Coding, Small RNAs*/
function GeneTrack(gsvg,data,trackClass,label,additionalOptions){
	var that= Track(gsvg,data,trackClass,label);
	that.counts=[{value:0,names:"Ensembl"},{value:0,names:"Brain RNA-Seq"}];
	var additionalOptStr=new String(additionalOptions);
	that.drawAs="Gene";
	that.trxCutoff=100000;
	var additionalOptStr=new String(additionalOptions);
	var tmpMin=that.xScale.domain()[0];
	var tmpMax=that.xScale.domain()[1];
	var len=tmpMax-tmpMin;
	if(additionalOptStr.indexOf("DrawTrx")>-1){
		that.drawAs="Trx";
	}
	that.density=3;

	that.ttTrackList=[];
	if(that.trackClass.indexOf("smallnc")==-1){	
		that.ttTrackList.push("ensemblcoding");
		that.ttTrackList.push("braincoding");
		that.ttTrackList.push("liverTotal");
		that.ttTrackList.push("heartTotal");
		that.ttTrackList.push("refSeq");
		that.ttTrackList.push("ensemblnoncoding");
		that.ttTrackList.push("brainnoncoding");
		that.ttTrackList.push("snpSHRH");
		that.ttTrackList.push("snpBNLX");
		that.ttTrackList.push("snpF344");
		that.ttTrackList.push("snpSHRJ");
	}else{
		that.ttTrackList.push("ensemblsmallnc");
		that.ttTrackList.push("brainsmallnc");
		that.ttTrackList.push("liversmallnc");
		that.ttTrackList.push("heartsmallnc");
		that.ttTrackList.push("refSeq");
		that.ttTrackList.push("snpSHRH");
		that.ttTrackList.push("snpBNLX");
		that.ttTrackList.push("snpF344");
		that.ttTrackList.push("snpSHRJ");
	}

	if(trackClass=="braincoding"){
		that.ttTrackList.push("illuminaPolyA");
	}else if(trackClass=="liverTotal"){
		that.ttTrackList.push("liverilluminaTotalPlus");
		that.ttTrackList.push("liverilluminaTotalMinus");
	}else if(trackClass=="heartTotal"){
		that.ttTrackList.push("heartilluminaTotalPlus");
		that.ttTrackList.push("heartilluminaTotalMinus");
	}

	//Initialize Y Positioning Variables
	that.yMaxArr=new Array();
	that.yArr=new Array();
	that.yArr[0]=new Array();
	for(var j=0;j<that.gsvg.width;j++){
				that.yMaxArr[j]=0;
				that.yArr[0][j]=0;
	}
	
	that.color =function(d){
		var color=d3.rgb("#000000");
		if(that.trackClass=="ensemblcoding"){
			color=d3.rgb("#DFC184");
		}else if(that.trackClass=="braincoding"){
			color=d3.rgb("#7EB5D6");
		}else if(that.trackClass=="ensemblnoncoding"){
			color=d3.rgb("#B58AA5");
		}else if(that.trackClass=="brainnoncoding"){
			color=d3.rgb("#CECFCE");
		}else if(that.trackClass=="ensemblsmallnc"){
			color=d3.rgb("#FFCC00");
		}else if(that.trackClass=="brainsmallnc"){
			color=d3.rgb("#99CC99");
		}else if(that.trackClass=="liverTotal"){
			color=d3.rgb("#bbbedd");
		}else if(that.trackClass=="heartTotal"){
			color=d3.rgb("#DC7252");
		}
		else if(that.trackClass=="brainTotal"){
			color=d3.rgb("#7EB5D6");
		}else if(that.trackClass=="liversmallnc"){
			color=d3.rgb("#8b8ead");
		}else if(that.trackClass=="heartsmallnc"){
			color=d3.rgb("#BC5232");
		}
		return color;
	};

	that.pieColor =function(d,i){
		return that.color(d);
	};

	that.getDisplayID=function(id){
		if(that.trackClass.indexOf("smallnc")>-1){
			if(id.indexOf("ENS")==-1){
				var prefix="smRNA_";
				id=id.substr(id.indexOf("_")+1);
				id=id.replace(/^0+/, '');
				id=prefix+id;
			}
		}
		return id;
	};

	that.createToolTip=function(d){
		//console.log("createToolTip:GeneTrack");
		var tooltip="";
		var txListStr="";
		if(that.trackClass.indexOf("smallnc")>-1){
			var prefix="smRNA_";
			var rnaSeqData="<BR>Total Reads: "+d.getAttribute("reads")+"<BR>Reference Sequence:<BR>"+d.getAttribute("refseq");
			if(new String(d.getAttribute("ID")).indexOf("ENS")>-1){
				prefix="";
				rnaSeqData="";
			}else{

			}
			tooltip="<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div>ID: "+prefix+d.getAttribute("ID")+"<BR>Length: "+(d.getAttribute("stop")-d.getAttribute("start"))+"<BR>Location: "+d.getAttribute("chromosome")+":"+numberWithCommas(d.getAttribute("start"))+"-"+numberWithCommas(d.getAttribute("stop"))+"<BR>Strand: "+d.getAttribute("strand")+rnaSeqData+"<BR>";																																																						  
		}else{
			var gid=d.getAttribute("ID");
			gid=that.getDisplayID(gid);
			var geneSym="";
			if(d.getAttribute("geneSymbol")!=undefined){
				geneSym=d.getAttribute("geneSymbol");
			}else if(d.parent!=undefined && d.parent.getAttribute("geneSymbol")!=undefined){
				geneSym=d.parent.getAttribute("geneSymbol");
			}
			var strand=".";
			if(d.getAttribute("strand")==1){
				strand="+";
			}else if(d.getAttribute("strand")==-1){
				strand="-";
			}
			if(d.parent!=undefined){
				//console.log("tt text");
				//console.log(d.parent);
				var txList=getAllChildrenByName(getFirstChildByName(d.parent,"TranscriptList"),"Transcript");
				//console.log(txList);
				for(var m=0;m<txList.length;m++){
					var id=new String(txList[m].getAttribute("ID"));
					/*if(id.indexOf("ENS")==-1){
						id=id.substr(id.indexOf("_")+1);
						id=id.replace(/^0+/, '');
						id="Brain.T"+id;
					}*/
					if(gid!=id){
						if(new String(txList[m].getAttribute("ID")).indexOf("ENS")>-1){
							txListStr+="<B>"+id+"</B>";
							txListStr+="<br>";
						}else {
							txListStr+="<B>"+id+"</B>";
							if(new String(txList[m].getAttribute("ID")).indexOf("ENS")==-1 ){
								var annot=getFirstChildByName(getFirstChildByName(txList[m],"annotationList"),"annotation");
								if(annot!=null){
									txListStr+=" - "+annot.getAttribute("reason");
								}
							}
							txListStr+="<br>";
						}
					}
					if(geneSym==""){
						var annotList=getAllChildrenByName(getFirstChildByName(txList[m],"annotationList"),"annotation");
						for(var p=0;p<annotList.length&&geneSym=="";p++){
							if(annotList[p].getAttribute("source")=="AKA"){
								var aka=annotList[p].getAttribute("annot_value");
								var akaList=new String(aka).split(":");
								if(new String(akaList[akaList.length-1]).indexOf("ENS")!=0){
									geneSym=akaList[akaList.length-1];
								}else{
									geneSym=akaList[0];
								}
							}
						}
					}

				}
				tooltip="<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div><BR>Transcript ID: "+gid+"<BR>Location: "+d.getAttribute("chromosome")+":"+numberWithCommas(d.getAttribute("start"))+"-"+numberWithCommas(d.getAttribute("stop"))+"<BR>Strand: "+strand;
				tooltip=tooltip+"<BR><BR>Gene Symbol: "+geneSym+"<BR>Gene ID: "+that.getDisplayID(d.parent.getAttribute("ID"))+"<BR><BR>Other Transcripts:<BR>"+txListStr+"<BR>";
			}else{
				//console.log("parent undef tt text");
				//console.log(d);
				var txList=getAllChildrenByName(getFirstChildByName(d,"TranscriptList"),"Transcript");
				//console.log(txList);
				for(var m=0;m<txList.length;m++){
					var id=new String(txList[m].getAttribute("ID"));
					if(new String(txList[m].getAttribute("ID")).indexOf("ENS")>-1){
						txListStr+="<B>"+id+"</B>";
						txListStr+="<br>";
					}else{
						txListStr+="<B>"+id+"</B>";
						if(new String(txList[m].getAttribute("ID")).indexOf("ENS")==-1 ){
							var annot=getFirstChildByName(getFirstChildByName(txList[m],"annotationList"),"annotation");
							if(annot!=null){
								txListStr+=" - "+annot.getAttribute("reason");
							}
						}
						txListStr+="<br>";
					}
					if(geneSym==""){
						var annotList=getAllChildrenByName(getFirstChildByName(txList[m],"annotationList"),"annotation");
						for(var p=0;p<annotList.length&&geneSym=="";p++){
							if(annotList[p].getAttribute("source")=="AKA"){
								var aka=annotList[p].getAttribute("annot_value");
								var akaList=new String(aka).split(":");
								if(new String(akaList[akaList.length-1]).indexOf("ENS")!=0){
									geneSym=akaList[akaList.length-1];
								}else{
									geneSym=akaList[0];
								}
							}
						}
					}
				}
				tooltip="<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div>Gene ID: "+gid+"<BR>Gene Symbol: "+geneSym+"<BR>Location: "+d.getAttribute("chromosome")+":"+numberWithCommas(d.getAttribute("start"))+"-"+numberWithCommas(d.getAttribute("stop"))+"<BR>Strand: "+strand+"<BR><BR>Transcripts:<BR>"+txListStr+"<BR>";
			}
			
		}
		return tooltip;
	};

	that.calcY = function (start,end,i){
		var tmpY=0;
		if(that.density==3){
			if((start>=that.xScale.domain()[0]&&start<=that.xScale.domain()[1])||
				(end>=that.xScale.domain()[0]&&end<=that.xScale.domain()[1])||
				(start<=that.xScale.domain()[0]&&end>=that.xScale.domain()[1])){
				var pStart=Math.floor(that.xScale(start));
				if(pStart<0){
					pStart=0;
				}
				var pEnd=Math.floor(that.xScale(end))+1;
				if(pEnd>=that.gsvg.width){
					pEnd=that.gsvg.width-1;
				}
				var pixStart=pStart-5;
				if(pixStart<0){
					pixStart=0;
				}
				var pixEnd=pEnd+5;
				if(pixEnd>=that.gsvg.width){
					pixEnd=that.gsvg.width-1;
				}
				//find yMax that is clear this is highest line that is clear
				var yMax=0;
				for(var pix=pixStart;pix<=pixEnd;pix++){
					if(that.yMaxArr[pix]>yMax){
						yMax=that.yMaxArr[pix];
					}
				}
				yMax++;
				//may need to extend yArr for a new line
				var addLine=yMax;
				if(that.yArr.length<=yMax){
					that.yArr[addLine]=new Array();
					for(var j=0;j<that.gsvg.width;j++){
						that.yArr[addLine][j]=0;
					}
				}
				//check a couple lines back to see if it can be squeezed in
				var startLine=yMax-12;
				if(startLine<1){
					startLine=1;
				}
				var prevLine=-1;
				var stop=0;
				for(var scanLine=startLine;scanLine<yMax&&stop==0;scanLine++){
					var available=0;
					for(var pix=pixStart;pix<=pixEnd&&available==0;pix++){
						if(that.yArr[scanLine][pix]>available){
							available=1;
						}
					}
					if(available==0){
						yMax=scanLine;
						stop=1;
					}
				}
				if(yMax>that.trackYMax){
					that.trackYMax=yMax;
				}
				for(var pix=pStart;pix<=pEnd;pix++){
					if(that.yMaxArr[pix]<yMax){
						that.yMaxArr[pix]=yMax;
					}
					that.yArr[yMax][pix]=1;
				}
				tmpY=yMax*15;
			}else{
				tmpY=15;
			}
		}else if(that.density==2){
			tmpY=(i+1)*15;
		}else{
			tmpY=15;
		}
		if(that.trackYMax<(tmpY/15)){
			that.trackYMax=(tmpY/15);
		}
		return tmpY;
		};

	that.redraw=function(){
		
		/*if($("#"+that.trackClass+"CBX"+that.gsvg.levelNumber).is(":checked")){
			that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").val();
		}*/

		that.yMaxArr=new Array();
		that.yArr=new Array();
		that.yArr[0]=new Array();
		for(var p=0;p<that.gsvg.width;p++){
			that.yMaxArr[p]=0;
			that.yArr[0][p]=0;
		}
		that.trackYMax=0;

		var tmpMin=that.xScale.domain()[0];
		var tmpMax=that.xScale.domain()[1];
		var len=tmpMax-tmpMin;
		var overrideTrx=0;
		if((len<that.trxCutoff&&that.drawnAs=="Gene")||(len>=that.trxCutoff&&that.drawnAs=="Trx"&&that.drawAs!="Trx")||(that.drawnAs=="Gene" && $("#forceTrxCBX"+that.gsvg.levelNumber).is(":checked"))){
			that.draw(that.data);	
		}else{
			
				if(len<that.trxCutoff&&that.drawnAs=="Trx"&&that.drawAs!="Trx"){
					overrideTrx=1;
				}
				if( (that.drawAs=="Gene"  && overrideTrx==0) || that.trackClass.indexOf("smallnc")>-1){
					if(that.svg[0][0]!=null){
						d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene").attr("transform",function (d,i){
									var st=that.xScale(d.getAttribute("start"));
									return "translate("+st+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i)+")";
							});
						d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene rect").attr("width",function(d) {
									var wX=1;
									if(that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"))>1){
										wX=that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"));
									}
									return wX;
							})
							.attr("stroke",that.colorStroke);
						d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene").each( function(d){
							var d3This=d3.select(this);
							var strChar=">";
							if(d.getAttribute("strand")=="-1"){
								strChar="<";
							}
							var fullChar="";
							var rectW=d3This.select("rect").attr("width");
							if(rectW>=7.9 && rectW<=15.8){
								fullChar=strChar;
							}else{
								while(rectW>8.5){
									fullChar=fullChar+strChar;
									rectW=rectW-7.9;
								}
							}
							d3This.select("text#strandTxt").text(fullChar);
							var dThis=d;
							if(that.density==2){
								var curLbl=dThis.getAttribute("ID");
								if(dThis.getAttribute("geneSymbol")!=undefined && dThis.getAttribute("geneSymbol").length>0){
									curLbl=curLbl+" ("+dThis.getAttribute("geneSymbol")+")";
								}
								if(d3This.select("text#lblTxt").size()==0){
									d3This.append("svg:text").attr("dx",function(){
											var xpos=that.xScale(dThis.getAttribute("start"));
											if(xpos<($(window).width()/2)){
												xpos=that.xScale(dThis.getAttribute("stop"))-that.xScale(dThis.getAttribute("start"))+5;
											}else{
												xpos=-1*curLbl.length*9;
											}
											return xpos;
										})
									.attr("dy",10)
									.attr("id","lblTxt")
									.text(curLbl);
								}else{
									d3This.select("text#lblTxt").attr("dx",function(){
											var xpos=that.xScale(dThis.getAttribute("start"));
											if(xpos<($(window).width()/2)){
												xpos=that.xScale(dThis.getAttribute("stop"))-that.xScale(dThis.getAttribute("start"))+5;
											}else{
												xpos=-1*curLbl.length*9;
											}
											return xpos;
										});
								}
							}else{
								d3This.select("text#lblTxt").remove();
							}
						});
					}
					if(that.density==1){
						that.svg.attr("height", 30);
					}else if(that.density==2){
						that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene").size()+1)*15);
					}else if(that.density==3){
						that.svg.attr("height", (that.trackYMax+1)*15);
					}
				}else if(overrideTrx==1 || that.drawAs=="Trx"){
					var txG=that.svg.selectAll(".trx"+that.gsvg.levelNumber);
					txG//.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
						.each(function(d,i){
							var cdsStart=d.getAttribute("start");
							var cdsStop=d.getAttribute("stop");
							if(d.getAttribute("cdsStart")!=undefined&&d.getAttribute("cdsStop")!=undefined){
								cdsStart=d.getAttribute("cdsStart");
								cdsStop=d.getAttribute("cdsStop");
							}

							exList=getAllChildrenByName(getFirstChildByName(d,"exonList"),"exon");
							var pref="";
							if(that.gsvg.levelNumber==1){
								pref="tx";
							}else if(that.gsvg.levelNumber==99){
								pref="ttTx";
							}
							for(var m=0;m<exList.length;m++){
								var exStrt=exList[m].getAttribute("start");
								var exStp=exList[m].getAttribute("stop");
								if((exStrt<cdsStart&&cdsStart<exStp)||(exStp>cdsStop&&cdsStop>exStrt)){
									var ncStrt=exStrt;
									var ncStp=cdsStart;
									if(exStp>cdsStop){
										ncStrt=cdsStop;
										ncStp=exStp;
										exStrt=exStrt;
										exStp=cdsStop;
									}else{
										exStrt=cdsStart;
										exStp=exStp;
									}
									d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" g#"+pref+d.getAttribute("ID")+that.gsvg.levelNumber+" rect#ExNC"+exList[m].getAttribute("ID"))
										.attr("x",function(d){ return that.xScale(ncStrt); })
										.attr("width",function(d){ return that.xScale(ncStp) - that.xScale(ncStrt); });
								}
								d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" g#"+pref+d.getAttribute("ID")+that.gsvg.levelNumber+" rect#Ex"+exList[m].getAttribute("ID"))
									.attr("x",function(d){ return that.xScale(exStrt); })
									.attr("width",function(d){ return that.xScale(exStp) - that.xScale(exStrt); });
								/*d3.select("g#"+pref+d.getAttribute("ID")+" rect#Ex"+exList[m].getAttribute("ID"))
									.attr("x",function(d){ return that.xScale(exList[m].getAttribute("start")); })
									.attr("width",function(d){ return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start")); });
								*/
								if(m>0){
									var strChar=">";
									if(d.getAttribute("strand")=="-1"){
										strChar="<";
									}
									var fullChar=strChar;
									var intStart=that.xScale(exList[m-1].getAttribute("stop"));
									var intStop=that.xScale(exList[m].getAttribute("start"));
									var rectW=intStop-intStart;
									var alt=0;
									var charW=6.5;
									if(rectW<charW){
											fullChar="";
									}else{
										rectW=rectW-charW;
										while(rectW>(charW+1)){
											if(alt==0){
												fullChar=fullChar+" ";
												alt=1;
											}else{
												fullChar=fullChar+strChar;
												alt=0;
											}
											rectW=rectW-charW;
										}
									}
									d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" g.trx"+that.gsvg.levelNumber+"#"+pref+d.getAttribute("ID")+that.gsvg.levelNumber+" line#Int"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID"))
										.attr("x1",intStart)
										.attr("x2",intStop);

									d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" g.trx"+that.gsvg.levelNumber+"#"+pref+d.getAttribute("ID")+that.gsvg.levelNumber+" #IntTxt"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID"))
										.attr("dx",intStart+1).text(fullChar);
								}
							}
							var dThis=d;
							if(that.density==2){
								var curLbl=dThis.getAttribute("ID");
								if(dThis.getAttribute("geneSymbol")!=undefined && dThis.getAttribute("geneSymbol").length>0){
									curLbl=curLbl+" ("+dThis.getAttribute("geneSymbol")+")";
								}
								if(d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" g.trx"+that.gsvg.levelNumber+"#"+pref+d.getAttribute("ID")+that.gsvg.levelNumber+" text#lblTxt").size()==0){
									d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" g.trx"+that.gsvg.levelNumber+"#"+pref+d.getAttribute("ID")+that.gsvg.levelNumber).append("svg:text").attr("dx",function(){
											var xpos=that.xScale(dThis.parent.getAttribute("start"));
											if(xpos<($(window).width()/2)){
												xpos=that.xScale(dThis.parent.getAttribute("stop"))-that.xScale(dThis.parent.getAttribute("start"))+5;
											}else{
												xpos=-1*curLbl.length*9;;
											}
											return xpos;
										})
									.attr("dy",10)
									.attr("id","lblTxt")
									.text(curLbl);
								}else{
									d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" g.trx"+that.gsvg.levelNumber+"#"+pref+d.getAttribute("ID")+that.gsvg.levelNumber+" text#lblTxt").attr("dx",function(){
											var xpos=that.xScale(dThis.getAttribute("start"));
											if(xpos<($(window).width()/2)){
												xpos=that.xScale(dThis.getAttribute("stop"))-that.xScale(dThis.getAttribute("start"))+5;
											}else{
												xpos=-1*curLbl.length*9;;
											}
											return xpos;
										});
								}
							}else{
								d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" g.trx"+that.gsvg.levelNumber+"#"+pref+d.getAttribute("ID")+that.gsvg.levelNumber+" text#lblTxt").remove();
							}	
						});
						if(that.density==1){
							that.svg.attr("height", 30);
						}else if(that.density==2){
							that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.trx"+that.gsvg.levelNumber).size()+1)*15);
						}else if(that.density==3){
							//that.svg.attr("height", (that.trackYMax+2)*15);
						}
				}
			
		}
		that.redrawSelectedArea();
	};

	that.setSelected=function(geneID){
		if(geneID !=""){
			if(d3.selectAll("g.gene").size()>0){
				//console.log("setup with genes");
				d3.selectAll("rect.selected").each(function(){
					d3.select(this).attr("class","").style("fill",that.color);
					});
				var gene=d3.select("g.gene rect#"+geneID);
				if(gene != undefined){
					gene.attr("class","selected").style("fill","green");
					that.setupDetailedView(gene.data()[0]);
					selectGene="";
				}
			}else if(d3.selectAll("g.trx"+that.gsvg.levelNumber).size()>0){
				//console.log("setup with transcripts");
				var str=(new String(geneID)).replace(".","_");
				that.svg.selectAll("g.trx"+that.gsvg.levelNumber+".selected").selectAll("line").style("stroke",that.color);
				that.svg.selectAll("g.trx"+that.gsvg.levelNumber+".selected").selectAll("rect").style("fill",that.color);
				that.svg.selectAll("g.trx"+that.gsvg.levelNumber+".selected").selectAll("text").style("opacity","0.6").style("fill",that.color);

				that.svg.selectAll("g.trx"+that.gsvg.levelNumber+".selected").each(function(){var tmpCl=new String($(this).attr("class"));tmpCl=tmpCl.replace(" selected","");$(this).attr("class",tmpCl);});
				that.svg.selectAll("g.gene"+str).each(function(){var tmpCl=$(this).attr("class")+" selected";$(this).attr("class",tmpCl);});
							
				that.svg.selectAll("g.gene"+str).selectAll("line").style("stroke","green");
				that.svg.selectAll("g.gene"+str).selectAll("rect").style("fill","green");
				that.svg.selectAll("g.gene"+str).selectAll("text").style("opacity","0.3").style("fill","green");
				var tmp;
				if(that.svg.selectAll("g.gene"+str)[0][0]!=undefined){
					tmp=that.svg.selectAll("g.gene"+str)[0][0].__data__;
					that.setupDetailedView(tmp.parent);
				}
				
				selectGene="";
			}
		}
	};

	that.clearSelection=function(){
		that.selectionStart=-1;
		that.selectionEnd=-1;
		that.svg.selectAll("rect.selectedArea").remove();
		if(that.svg.selectAll("g.gene").size()>0){
				that.svg.selectAll("rect.selected").each(function(d){
					d3.select(this).attr("class","").style("fill",that.color);
					});
		}else if(that.svg.selectAll("g.trx"+that.gsvg.levelNumber).size()>0){
				that.svg.selectAll("g.trx"+that.gsvg.levelNumber+".selected").selectAll("line").style("stroke",that.color);
				that.svg.selectAll("g.trx"+that.gsvg.levelNumber+".selected").selectAll("rect").style("fill",that.color);
				that.svg.selectAll("g.trx"+that.gsvg.levelNumber+".selected").selectAll("text").style("opacity","0.6").style("fill",that.color);
				that.svg.selectAll("g.trx"+that.gsvg.levelNumber+".selected").each(function(){var tmpCl=new String($(this).attr("class"));tmpCl=tmpCl.replace(" selected","");$(this).attr("class",tmpCl);});
			}
	};

	that.setupDetailedView=function(d){
		if(d!=undefined){
			that.gsvg.clearSelection();
			var e = jQuery.Event("keyup");
			e.which = 32; // # Some key code value
			var newLevel=that.gsvg.levelNumber+1;
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
			if(that.trackClass=="liverTotal"){
				localTxType="liverTotal";
			}else if(that.trackClass=="heartTotal"){
				localTxType="heartTotal";
			}else if(that.trackClass=="brainTotal"){
				localTxType="brainTotal";
			}else if(d.getAttribute("biotype")=="protein_coding" && (d.getAttribute("stop")-d.getAttribute("start"))>=200){
				localTxType="protein";
			}else if(d.getAttribute("biotype")!="protein_coding" && (d.getAttribute("stop")-d.getAttribute("start"))>=200){
				localTxType="long";
			}else if((d.getAttribute("stop")-d.getAttribute("start"))<200){
				localTxType="small";
			}
			var newMin=0;
			var newMax=0;
			if(localTxType=="protein"||localTxType=="long"||localTxType=="liverTotal"||localTxType=="heartTotal"||localTxType=="brainTotal"||(localTxType=="small"&& new String(d.getAttribute("ID")).indexOf("ENS")>-1)){
					var displayID=d.getAttribute("ID");
					var akaENS="";
					var akaGenSym="";
					if(d.getAttribute("geneSymbol")!=undefined&&d.getAttribute("geneSymbol")!=""){
						displayID=displayID+" ("+d.getAttribute("geneSymbol")+")";
					}else{
						var txList=getAllChildrenByName(getFirstChildByName(d,"TranscriptList"),"Transcript");
						for(var m=0;m<txList.length&&akaENS=="";m++){
							if(akaENS==""){
								var annotList=getAllChildrenByName(getFirstChildByName(txList[m],"annotationList"),"annotation");
								for(var p=0;p<annotList.length&&akaENS=="";p++){
									if(annotList[p].getAttribute("source")=="AKA"){
										var aka=annotList[p].getAttribute("annot_value");
										var akaList=new String(aka).split(":");
										if(akaList.length>=1){
											akaENS=akaList[0];
											displayID=displayID+" ("+akaENS+")";
										}else if(akaList.length>=2){
											akaENS=akaList[0];
											akaGenSym=akaList[1];
											displayID=displayID+" ("+akaGenSym+")";
										}
									}
								}
							}
						}
					}
					var min=d.getAttribute("start");
					var max=d.getAttribute("stop");
					if(d.getAttribute("extStart")!=undefined&&d.getAttribute("extStop")!=undefined){
						min=d.getAttribute("extStart");
						max=d.getAttribute("extStop");
					}

					if(svgViewIDList[newLevel]==undefined){
						svgViewIDList[newLevel]=that.gsvg.currentView.ViewID;
					}
					var newSvg= GenomeSVG("div#selectedImage",that.gsvg.width,min,max,newLevel,displayID,"transcript");
					newSvg.xMin=min-(max-min)*0.05;
					newSvg.xMax=(max*1)+(max-min)*0.05;
					newMin=newSvg.xMin;
					newMax=newSvg.xMax;
					svgList[newLevel]=newSvg;
					svgList[newLevel].txType=localTxType;
					svgList[newLevel].selectedData=d;
					//svgList[newLevel].addTrack("trx",2,"",0);
					
					//viewMenu[newLevel].applySelectedView(tmpViewID);
					
					//loadStateFromString(that.gsvg.generateSettingsString(),"",newLevel,newSvg);
					//loadState(newLevel);

				selectedGeneSymbol=d.getAttribute("geneSymbol");
				selectedID=new String(d.getAttribute("ID"));
				if(selectedID.indexOf("ENS")==-1){
					if(akaENS!=""){
						selectedID=akaENS;
					}
				}
				$('div#selectedImage').show();
				if((new String(selectedID)).indexOf("ENS")>-1){
					$('div#selectedReport').show();
					var jspPage= pathPrefix +"geneReport.jsp";
					var params={id:selectedID,geneSymbol:selectedGeneSymbol,chromosome:chr,species:organism};
					DisplaySelectedDetailReport(jspPage,params);
				}else{
					$('div#selectedReport').html("<BR><BR>Detailed Gene Reports are not currently provided for RNA-Seq(Cufflinks) generated genes that are novel and have not been matched to an existing annotated gene.  In the future overlapping probesets and SNPs will be summarized in the same manner.  This feature should be added by December 2014.  Please keep checking back or let us know you'd like to see it sooner.");
				}
			}else if(localTxType=="small"){
				if(new String(d.getAttribute("ID")).indexOf("ENS")==-1){
					$('div#selectedImage').hide();
					$('div#selectedReport').show();
					newMin=d.getAttribute("start");
					newMax=d.getAttribute("stop");
					//Add SVG graphic later
					//For now processing.js graphic is in jsp page of the detail report
					var jspPage= pathPrefix +"viewSmallNonCoding.jsp";
					var params={id: d.getAttribute("ID"),name: "smRNA_"+d.getAttribute("ID")};
					DisplaySelectedDetailReport(jspPage,params);
				}else{
					//FILL IN to allow selecting miRNA.
				}
			}
			that.gsvg.selectSvg.changeSelection(newMin,newMax);
			$('html, body').animate({
				scrollTop: $( '#selectedDetail' ).offset().top
			}, 200);
		}	
	};

	that.getDisplayedData= function (){
		var dispData=new Array();
		var dispDataCount=0;
		if(that.drawnAs=="Gene"){
			var dataElem=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene");
			that.counts=that.counts=[{value:0,names:"Ensembl"},{value:0,names:"Brain RNA-Seq"},{value:0,names:"Liver RNA-Seq"},{value:0,names:"Heart RNA-Seq"}];
			var tmpDat=dataElem[0];
			//console.log(dataElem);
			if (!(typeof tmpDat === 'undefined')) {
				for(var l=0;l<tmpDat.length;l++){
					if(tmpDat[l].__data__ != undefined){
						var start=that.xScale(tmpDat[l].__data__.getAttribute("start"));
						var stop=that.xScale(tmpDat[l].__data__.getAttribute("stop"));
						//console.log("start:"+start+":"+stop);
						if((0<=start && start<=that.gsvg.width)||(0<=stop &&stop<=that.gsvg.width)){
							if((new String(tmpDat[l].childNodes[0].id)).indexOf("ENS")>-1){
								that.counts[0].value++;
							}else{
								if((new String(tmpDat[l].childNodes[0].id)).indexOf("Brain")>-1){
									that.counts[1].value++;
								}else if((new String(tmpDat[l].childNodes[0].id)).indexOf("Liver")>-1){
									that.counts[2].value++;
								}else if((new String(tmpDat[l].childNodes[0].id)).indexOf("Heart")>-1){
									that.counts[3].value++;
								}
							}
							dispData[dispDataCount]=tmpDat[l].__data__;
							dispDataCount++;
						}
					}
				}
			}else{
				that.counts=[];
			}
		}else if(that.drawnAs=="Trx"){
			var dataElem=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.trx"+that.gsvg.levelNumber);
			that.counts=that.counts=[{value:0,names:"Ensembl"},{value:0,names:"Brain RNA-Seq"},{value:0,names:"Liver RNA-Seq"},{value:0,names:"Heart RNA-Seq"}];
			var tmpDat=dataElem[0];
			if (!(typeof tmpDat === 'undefined')) {
				for(var l=0;l<tmpDat.length;l++){
					if(tmpDat[l].__data__ != undefined){
						var start=that.xScale(tmpDat[l].__data__.getAttribute("start"));
						var stop=that.xScale(tmpDat[l].__data__.getAttribute("stop"));
						//console.log("start:"+start+":"+stop);
						//console.log("tmpDat:"+l);
						//console.log(tmpDat[l]);
						//console.log("tmpDat.childNodes:");
						//console.log(tmpDat[l].childNodes);

						if((0<=start && start<=that.gsvg.width)||(0<=stop &&stop<=that.gsvg.width)){
							if((new String(tmpDat[l].id)).indexOf("ENS")>-1){
								that.counts[0].value++;
							}else{
								if((new String(tmpDat[l].id)).indexOf("Brain")>-1){
									that.counts[1].value++;
								}else if((new String(tmpDat[l].id)).indexOf("Liver")>-1){
									that.counts[2].value++;
								}else if((new String(tmpDat[l].id)).indexOf("Heart")>-1){
									that.counts[3].value++;
								}
							}
							dispData[dispDataCount]=tmpDat[l].__data__;
							dispDataCount++;
						}
					}
				}
			}else{
				that.counts=[];
			}
		}
		return dispData;
	};

	that.updateData=function(retry){
		var tag="Gene";
		var path=dataPrefix+"tmpData/regionData/"+that.gsvg.folderName+"/"+that.trackClass+".xml";
		d3.xml(path,function (error,d){
			if(error){
				if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								that.updateData(retry+1);
							},time);
				}else{
							d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).attr("height", 15);
							that.gsvg.addTrackErrorRemove(that.svg,"#Level"+that.gsvg.levelNumber+that.trackClass);
				}
			}else{
				var data=d.documentElement.getElementsByTagName(tag);
				var mergeddata=new Array();
				var checkName=new Array();
				var curInd=0;
				for(var l=0;l<data.length;l++){
					if(data[l]!=undefined ){
						mergeddata[curInd]=data[l];
						checkName[data[l].getAttribute("ID")]=1;
						curInd++;
					}
				}
				for(var l=0;l<that.data.length;l++){
					if(that.data[l]!=undefined && checkName[that.data[l].getAttribute("ID")]==undefined){
						mergeddata[curInd]=that.data[l];
						curInd++;
					}
				}
				that.draw(mergeddata);
				that.hideLoading();
				DisplayRegionReport();
			}
		});
	};

	that.drawTrx=function (d,i){
		var cdsStart=d.getAttribute("start");
		var cdsStop=d.getAttribute("stop");
		if(d.getAttribute("cdsStart")!=undefined && d.getAttribute("cdsStop")!=undefined){
			cdsStart=d.getAttribute("cdsStart");
			cdsStop=d.getAttribute("cdsStop");
		}
		var pref="";
		if(that.gsvg.levelNumber==1){
			pref="tx";
		}else if(that.gsvg.levelNumber==99){
			pref="ttTx";
		}
		//var txG=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).select("#"+pref+d.getAttribute("ID"));
		var txG=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" #"+pref+d.getAttribute("ID")+that.gsvg.levelNumber);
		exList=getAllChildrenByName(getFirstChildByName(d,"exonList"),"exon");
		for(var m=0;m<exList.length;m++){
			var exStrt=exList[m].getAttribute("start");
			var exStp=exList[m].getAttribute("stop");
			if((exStrt<cdsStart&&cdsStart<exStp)||(exStp>cdsStop&&cdsStop>exStrt)){//need to draw two rect one for CDS and one non CDS
				var xPos1=0;
				var xWidth1=0;
				var xPos2=0;
				var xWidth2=0;
				if(exStrt<cdsStart){
					xPos1=that.xScale(exList[m].getAttribute("start"));
					xWidth1=that.xScale(cdsStart) - that.xScale(exList[m].getAttribute("start"));
					xPos2=that.xScale(cdsStart);
					xWidth2=that.xScale(exList[m].getAttribute("stop")) - that.xScale(cdsStart);
				}else if(exStp>cdsStop){
					xPos2=that.xScale(exList[m].getAttribute("start"));
					xWidth2=that.xScale(cdsStop) - that.xScale(exList[m].getAttribute("start"));
					xPos1=that.xScale(cdsStop);
					xWidth1=that.xScale(exList[m].getAttribute("stop")) - that.xScale(cdsStop);
				}
				txG.append("rect")//non CDS
					.attr("x",xPos1)
					.attr("y",2.5)
					//.attr("x",function(d){ return that.xScale(exList[m].getAttribute("start")); })
					//.attr("rx",1)
					//.attr("ry",1)
			    	.attr("height",5)
			    	.attr("width",xWidth1)
					//.attr("width",function(d){ return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start")); })
					.attr("title",function(d){ return exList[m].getAttribute("ID");})
					.attr("id",function(d){return "ExNC"+exList[m].getAttribute("ID");})
					//.attr("class",function(d){})
					.style("fill",that.color)
					.style("cursor", "pointer");
				txG.append("rect")//CDS
						.attr("x",xPos2)
						//.attr("x",function(d){ return that.xScale(exList[m].getAttribute("start")); })
						//.attr("rx",1)
						//.attr("ry",1)
				    	.attr("height",10)
				    	.attr("width",xWidth2)
						//.attr("width",function(d){ return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start")); })
						.attr("title",function(d){ return exList[m].getAttribute("ID");})
						.attr("id",function(d){return "Ex"+exList[m].getAttribute("ID");})
						.style("fill",that.color)
						.style("cursor", "pointer");
				
			}else{
				var height=10;
				var y=0;
				if((exStrt<cdsStart&&exStp<cdsStart)||(exStp>cdsStop&&exStrt>cdsStop)){
					height=5;
					y=2.5;
				}
				txG.append("rect")
					.attr("x",function(d){ return that.xScale(exList[m].getAttribute("start")); })
					.attr("y",y)
					//.attr("rx",1)
					//.attr("ry",1)
			    	.attr("height",height)
					.attr("width",function(d){ return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start")); })
					.attr("title",function(d){ return exList[m].getAttribute("ID");})
					.attr("id",function(d){return "Ex"+exList[m].getAttribute("ID");})
					.style("fill",that.color)
					.style("cursor", "pointer");
			}
			/*txG.append("rect")
			.attr("x",function(d){ return that.xScale(exList[m].getAttribute("start")); })
			.attr("rx",1)
			.attr("ry",1)
	    	.attr("height",10)
			.attr("width",function(d){ return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start")); })
			.attr("title",function(d){ return exList[m].getAttribute("ID");})
			.attr("id",function(d){return "Ex"+exList[m].getAttribute("ID");})
			.style("fill",that.color)
			.style("cursor", "pointer")*/
			if(m>0){
				txG.append("line")
				.attr("x1",function(d){ return that.xScale(exList[m-1].getAttribute("stop")); })
				.attr("x2",function(d){ return that.xScale(exList[m].getAttribute("start")); })
				.attr("y1",5)
				.attr("y2",5)
				.attr("id",function(d){ return "Int"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID");})
				.attr("stroke",that.color)
				.attr("stroke-width","2");
				var strChar=">";
				if(d.getAttribute("strand")=="-1"){
					strChar="<";
				}
				var fullChar=strChar;
				var intStart=that.xScale(exList[m-1].getAttribute("stop"));
				var intStop=that.xScale(exList[m].getAttribute("start"));
				var rectW=intStop-intStart;
				var alt=0;
				var charW=6.5;
				if(rectW<charW){
						fullChar="";
				}else{
					rectW=rectW-charW;
					while(rectW>(charW+1)){
						if(alt==0){
							fullChar=fullChar+" ";
							alt=1;
						}else{
							fullChar=fullChar+strChar;
							alt=0;
						}
						rectW=rectW-charW;
					}
				}
				txG.append("svg:text").attr("id",function(d){ return "IntTxt"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID");}).attr("dx",intStart+1)
					.attr("dy","11")
					.style("pointer-events","none")
					.style("opacity","0.5")
					.style("fill",that.color)
					.style("font-size","16px")
					.text(fullChar);
				
			}
		}
		var dThis=d;
		if(that.density==2){
			var curLbl=dThis.getAttribute("ID");
			if(dThis.getAttribute("geneSymbol")!=undefined && dThis.getAttribute("geneSymbol").length>0){
				curLbl=curLbl+" ("+dThis.getAttribute("geneSymbol")+")";
			}
			txG.append("svg:text").attr("dx",function(){
					var xpos=that.xScale(dThis.getAttribute("start"));
					if(xpos<($(window).width()/2)){
						xpos=that.xScale(dThis.getAttribute("stop"))-that.xScale(dThis.getAttribute("start"))+5;
					}else{
						xpos=-1*curLbl.length*9;;
					}
					return xpos;
				})
			.attr("dy",10)
			.attr("id","lblTxt")
			.text(curLbl);
		}else{
			txG.select("text#lblTxt").remove();
		}
	};

	that.setupToolTipSVG=function(d,perc){
		//console.log("setupToolTipSVG:GeneTrack");
		var tmpMin=0;
    	var tmpMax=0;
    	if(d.getAttribute("extStart")!=undefined){
			tmpMin=d.getAttribute("extStart")*1;
			tmpMax=d.getAttribute("extStop")*1;
    	}else{
    		tmpMin=d.getAttribute("start")*1;
			tmpMax=d.getAttribute("stop")*1;
    	}
    	var margin=Math.floor((tmpMax-tmpMin)*perc);
    	if(margin<10){
    		margin=10;
    	}
    	tmpMin=tmpMin-margin;
    	tmpMax=tmpMax+margin;

        var newSvg=toolTipSVG("div#ttSVG",450,tmpMin,tmpMax,99,d.getAttribute("ID"),"transcript");
		newSvg.xMin=tmpMin;
		newSvg.xMax=tmpMax;
		var localTxType="none";
		if(that.trackClass=="liverTotal"){
			localTxType="liverTotal";
		}else if(that.trackClass=="heartTotal"){
			localTxType="heartTotal";
		}else if(that.trackClass=="brainTotal"){
			localTxType="brainTotal";
		}else if( (d.getAttribute("stop")-d.getAttribute("start"))<200){
			localTxType="small";
		}else if(d.getAttribute("biotype")=="protein_coding" && (d.getAttribute("stop")-d.getAttribute("start"))>=200){
			localTxType="protein";
		}else if(d.getAttribute("biotype")!="protein_coding" && (d.getAttribute("stop")-d.getAttribute("start"))>=200){
			localTxType="long";
		}
		newSvg.txType=localTxType;
		newSvg.selectedData=d;
		var dataArr=new Array();
		dataArr[0]=d;
		if(d.parent!=undefined){
			dataArr[0]=d.parent;
		}
		newSvg.addTrack(that.trackClass,2,"DrawTrx",dataArr);
		//Setup Other tracks included in the track type(listed in that.ttTrackList)
		for(var r=0;r<that.ttTrackList.length;r++){
			if(that.ttTrackList[r]!=that.trackClass){
				var tData=that.gsvg.getTrackData(that.ttTrackList[r]);
				var fData=new Array();
				if(tData!=undefined&&tData.length>0){
					var fCount=0;
					for(var s=0;s<tData.length;s++){
						if((tmpMin<=tData[s].getAttribute("start")&&tData[s].getAttribute("start")<=tmpMax)
							|| (tData[s].getAttribute("start")<=tmpMin&&tData[s].getAttribute("stop")>=tmpMin)
							//|| (newSvg.xMin<=tData[s].getAttribute("stop")&&tData[s].getAttribute("stop")<=newSvg.xMax)
							//|| (tData[s].getAttribute("start")<=newSvg.xMin&&newSvg.xMax<=tData[s].getAttribute("stop"))
							){
							fData[fCount]=tData[s];
							fCount++;
						}
					}
					if(fData.length>0){
						newSvg.addTrack(that.ttTrackList[r],3,"DrawTrx",fData);	
					}
				}
			}
		}
		
	};

	that.draw=function (data){

		that.data=data;

		that.trackYMax=0;
		that.yArr=new Array();
		that.yArr[0]=new Array();
		for(var j=0;j<that.gsvg.width;j++){
				that.yMaxArr[j]=0;
				that.yArr[0][j]=0;
		}
		
		that.svg.selectAll(".gene").remove();
		
		/*if($("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").length>0){
			that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").val();
		}*/
		
		var prevDrawAs=that.drawAs;
		var tmpMin=that.xScale.domain()[0];
		var tmpMax=that.xScale.domain()[1];
		var len=tmpMax-tmpMin;
		if(len<that.trxCutoff || $("#forceTrxCBX"+that.gsvg.levelNumber).is(":checked")){
			that.drawAs="Trx";
		}

		var type="Genes";
		if(that.drawAs=="Trx"){
			type="Transcripts";
		}
		var lbl="Protein Coding";
		var lbltxSuffix=" / PolyA+";
		if(that.trackClass.indexOf("noncoding")>-1){
			lbl="Long Non-Coding";
			lbltxSuffix=" / Non-PolyA+"
		}else if(that.trackClass.indexOf("smallnc")>-1){
			var lblTissue="Brain";
			if(that.trackClass.indexOf("liver")>-1){
				lblTissue="Liver";
			}else if(that.trackClass.indexOf("heart")>-1){
				lblTissue="Heart";
			}
			lbl=lblTissue+" Small RNA";
			lbltxSuffix="";
		}else if(that.trackClass=="liverTotal"){
			lbl="Liver RNA-Seq Reconstruction ";
			lbltxSuffix="Total RNA";
		}else if(that.trackClass=="heartTotal"){
			lbl="Heart RNA-Seq Reconstruction ";
			lbltxSuffix="Total RNA";
		}else if(that.trackClass=="brainTotal"){
			lbl="Whole Brain RNA-Seq Reconstruction ";
			lbltxSuffix="Total RNA";
		}
		if(that.trackClass.indexOf("ensembl")>-1){
			lbl="Ensembl "+lbl+" "+type;
		}else if(that.trackClass!="liverTotal"&&that.trackClass!="heartTotal"){
			lbl="Brain RNA-Seq Reconstruction "+lbl+lbltxSuffix+" "+type;
		}else{
			lbl=lbl+lbltxSuffix+" "+type;
		}
		that.updateLabel(lbl);
		that.redrawLegend();
		var filterData=data;

			if(that.drawAs=="Trx" && that.trackClass.indexOf("smallnc")==-1){
				filterData=[];
				var newCount=0;
				for(var l=0;l<data.length;l++){
					if(data[l]!=undefined ){
						/*if(that.gsvg.levelNumber!=1 
							|| (that.gsvg.levelNumber==1 && that.gsvg.selectedData!=undefined  && data[l].getAttribute("ID")!=that.gsvg.selectedData.getAttribute("ID") )
							){*/
								var tmpTxList=getAllChildrenByName(getFirstChildByName(data[l],"TranscriptList"),"Transcript");
								for(var k=0;k<tmpTxList.length;k++){
									filterData[newCount]=tmpTxList[k];
									filterData[newCount].parent=data[l];
									newCount++;
								}
						//}
					}
				}
			}

		
		if(that.drawAs=="Gene" || that.trackClass.indexOf("smallnc")>-1){
			that.drawnAs="Gene";
			that.svg.selectAll(".trx0").each(function(){d3.select(this).remove();});
			var gene=that.svg.selectAll(".gene")
		   			.data(filterData,key)
					.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i)+")";});
			//add new
			gene.enter().append("g")
					.attr("class","gene")
					.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i)+")";})
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
				.on("click", function(d){
						//that.zoomToFeature(d);
						
						
						that.setupDetailedView(d);
						/*d3.selectAll("rect.selected").each(function(){
								d3.select(this).attr("class","").style("fill",that.color);
							});*/
						d3.select(this).attr("class","selected").style("fill","green");
					})
				.on("dblclick", that.zoomToFeature)
				.on("mouseover", function(d) { 
						//if(mouseTTOver==0){
						//console.log("MouseOver");
						if(that.gsvg.isToolTip==0){
							//console.log("not tooltip"); 
							overSelectable=1;
							$("#mouseHelp").html("<B>Click</B> to see additional details. <B>Double Click</B> to zoom in on this feature.");
							d3.select(this).style("fill","green");
				        	//that.gsvg.get('tt').transition()
				        	tt.transition()        
				                .duration(200)      
				                .style("opacity", 1);      
				        	//that.gsvg.get('tt').html(that.createToolTip(d)) 
				        	tt.html(that.createToolTip(d)) 
				                .style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
								.style("top", function(){return that.positionTTTop(d3.event.pageY);});
				            if(d!=undefined){
					            that.triggerTableFilter(d);
					            if(that.trackClass.indexOf("smallnc")==-1){
					            	that.setupToolTipSVG(d,0.05);
								}else{
									//console.log("display tooltip svg");
									var newSvg=toolTipSVG("div#ttSVG",450,((d.getAttribute("start")*1)-10),((d.getAttribute("stop")*1)+10),99,that.getDisplayID(d.getAttribute("ID")),"");
									newSvg.xMin=d.getAttribute("start")-20;
									newSvg.xMax=d.getAttribute("stop")+20;
									var dataArr=new Array();
									dataArr[0]=d;
									newSvg.addTrack(that.trackClass,2,"",dataArr);
								}
							}
						}
						//}
			            //return false;
		            })
				.on("mouseout", function(d) { 
					overSelectable=0;
						$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
						if(d3.select(this).attr("class")!="selected"){
							d3.select(this).style("fill",that.color);
						}
			            //that.gsvg.get('tt').transition(
	            		tt.transition()
	            			.delay(500)       
	                		.duration(200)      
	                		.style("opacity", 0);
	                	that.clearTableFilter(d);
		            
		        });
			
			gene.exit().remove();

			
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene").each( function(d){
				if(d!=undefined){
					var d3This=d3.select(this);
					var strChar=">";
					if(d.getAttribute("strand")=="-1"){
						strChar="<";
					}
					var fullChar=strChar;
					var rectW=d3This.select("rect").attr("width");
					if(rectW<7.9){
						fullChar="";
					}else{
						rectW=rectW-7.9;
						fullChar=strChar;
						while(rectW>8.5){
							fullChar=fullChar+strChar;
							rectW=rectW-7.9;
						}
					}

					d3This.append("svg:text").attr("dx","1").attr("dy","10").attr("id","strandTxt").style("pointer-events","none").text(fullChar);
					var dThis=d;
					if(that.density==2){
						var curLbl=dThis.getAttribute("ID");
						if(dThis.getAttribute("geneSymbol")!=undefined && dThis.getAttribute("geneSymbol").length>0){
							curLbl=curLbl+" ("+dThis.getAttribute("geneSymbol")+")";
						}
						d3This.append("svg:text").attr("dx",function(){
								var xpos=that.xScale(dThis.getAttribute("start"));
								if(xpos<($(window).width()/2)){
									xpos=that.xScale(dThis.getAttribute("stop"))-that.xScale(dThis.getAttribute("start"))+5;
								}else{
									xpos=-1*curLbl.length*9;;
								}
								return xpos;
							})
						.attr("dy",10)
						.attr("id","lblTxt")
						.text(curLbl);
					}else{
						d3This.select("text#lblTxt").remove();
					}
				}
			});

			if(that.density==1){
				that.svg.attr("height", 30);
			}else if(that.density==2){
				that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene").size()+1)*15);
			}else if(that.density==3){
				that.svg.attr("height", (that.trackYMax+1)*15);
			}
		}else if(that.drawAs=="Trx"){
			that.drawnAs="Trx";
			that.svg.selectAll(".gene").each(function(){d3.select(this).remove();});
			that.svg.selectAll(".trx"+that.gsvg.levelNumber).remove();
			var tx=that.svg.selectAll(".trx"+that.gsvg.levelNumber)
		   			.data(filterData,key)
					.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i)+")";});
					
		  	tx.enter().append("g")
					.attr("class",function (d){
						var str=new String(d.parent.getAttribute("ID"));
						return "trx"+that.gsvg.levelNumber+" gene"+str.replace(".","_");
					})
					//.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
					.attr("transform",function(d,i){ return "translate(0,"+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i)+")";})
					.attr("id",function(d){
						var prefix="";
						if(that.gsvg.levelNumber==1){
							prefix="tx";
						}if(that.gsvg.levelNumber==99){
							prefix="ttTx";
						}
						return prefix+d.getAttribute("ID")+that.gsvg.levelNumber;})
					.attr("pointer-events", "all")
					.style("cursor", "pointer")
					.on("click", function(d){
						if(that.gsvg.levelNumber==0){
							var str=(new String(d.parent.getAttribute("ID"))).replace(".","_");
							that.svg.selectAll("g.trx"+that.gsvg.levelNumber+".selected").selectAll("line").style("stroke",that.color);
							that.svg.selectAll("g.trx"+that.gsvg.levelNumber+".selected").selectAll("rect").style("fill",that.color);
							that.svg.selectAll("g.trx"+that.gsvg.levelNumber+".selected").selectAll("text").style("opacity","0.6").style("fill",that.color);

							that.svg.selectAll("g.trx"+that.gsvg.levelNumber+".selected").each(function(){var tmpCl=new String($(this).attr("class"));tmpCl=tmpCl.replace(" selected","");$(this).attr("class",tmpCl);});
							that.svg.selectAll("g.gene"+str).each(function(){var tmpCl=$(this).attr("class")+" selected";$(this).attr("class",tmpCl);});
							
							that.svg.selectAll("g.gene"+str).selectAll("line").style("stroke","green");
							that.svg.selectAll("g.gene"+str).selectAll("rect").style("fill","green");
							that.svg.selectAll("g.gene"+str).selectAll("text").style("opacity","0.3").style("fill","green");
							that.setupDetailedView(d.parent);
						}
					})
					.on("dblclick", that.zoomToFeature)
					.on("mouseover", function(d) {
						if(that.gsvg.isToolTip==0){ 
							if(that.gsvg.levelNumber==0&&d.parent!=undefined){
								var str=(new String(d.parent.getAttribute("ID"))).replace(".","_");
								that.svg.selectAll("g.gene"+str).selectAll("line").style("stroke","green");
								that.svg.selectAll("g.gene"+str).selectAll("rect").style("fill","green");
								that.svg.selectAll("g.gene"+str).selectAll("text").style("opacity","0.3").style("fill","green");
							}else{
								d3.select(this).selectAll("line").style("stroke","green");
								d3.select(this).selectAll("rect").style("fill","green");
								d3.select(this).selectAll("text").style("opacity","0.3").style("fill","green");
							}
		            		tt.transition()        
									.duration(200)      
									.style("opacity", 1);      
							tt.html(that.createToolTip(d))  
									.style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
									.style("top", function(){return that.positionTTTop(d3.event.pageY);});
							that.triggerTableFilter(d);
							if(d!=undefined){
					            that.triggerTableFilter(d);
					            if(that.trackClass.indexOf("smallnc")==-1){
					            	that.setupToolTipSVG(d,0.05);
								}else{
									var newSvg=toolTipSVG("div#ttSVG",450,((d.getAttribute("start")*1)-10),((d.getAttribute("stop")*1)+10),99,that.getDisplayID(d.getAttribute("ID")),"");
									newSvg.xMin=d.getAttribute("start")-20;
									newSvg.xMax=d.getAttribute("stop")+20;
									var dataArr=new Array();
									dataArr[0]=d;
									newSvg.addTrack(that.trackClass,2,"",dataArr);
								}
							}
						}
		            })
					.on("mouseout", function(d) {
						var tmp=new String(d3.select(this).attr("class"));
						if(tmp.indexOf("selected")==-1){
							if(that.gsvg.levelNumber==0){
								var str=(new String(d.parent.getAttribute("ID"))).replace(".","_");
								that.svg.selectAll("g.gene"+str).selectAll("line").style("stroke",that.color);
								that.svg.selectAll("g.gene"+str).selectAll("rect").style("fill",that.color);
								that.svg.selectAll("g.gene"+str).selectAll("text").style("opacity","0.6").style("fill",that.color);
							}else{
								d3.select(this).selectAll("line").style("stroke",that.color);
								d3.select(this).selectAll("rect").style("fill",that.color);
								d3.select(this).selectAll("text").style("opacity","0.6").style("fill",that.color);  
							}
						}
							tt.transition()
								 .delay(500)       
								.duration(200)      
								.style("opacity", 0);  
							that.clearTableFilter(d);
		        		});
			
			
			 tx.exit().remove();
			 tx.each(that.drawTrx);
			if(that.density==1){
				that.svg.attr("height", 30);
			}else if(that.density==2){
				that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.trx"+that.gsvg.levelNumber).size()+1)*15);
			}else if(that.density==3){
				that.svg.attr("height", (that.trackYMax+1)*15);
			}
		}
		that.redrawSelectedArea();
		that.drawAs=prevDrawAs;
	};

	that.redrawLegend=function (){
		/*var legend=[];
		var curPos=0;
		if(that.trackClass!="liverTotal"){
			if(that.annotType!="trxOnly"){
				if(trackClass == "coding"){
					legend[curPos]={color:"#DFC184",label:"Ensembl"};
				}else if(trackClass == "noncoding"){
					legend[curPos]={color:"#B58AA5",label:"Ensembl"};
				}else if(trackClass == "smallnc"){
					legend[curPos]={color:"#FFCC00",label:"Ensembl"};
				}
				curPos++;
			}
			if(organism=="Rn" && that.annotType!="annotOnly"){
				if(trackClass == "coding"){
					legend[curPos]={color:"#7EB5D6",label:"Brain RNA-Seq"};
				}else if(trackClass == "noncoding"){
					legend[curPos]={color:"#CECFCE",label:"Brain RNA-Seq"};
				}else if(trackClass == "smallnc"){
					legend[curPos]={color:"#99CC99",label:"Brain RNA-Seq"};
				}
				curPos++;
				
			}
		}else if(that.trackClass=="liverTotal"){
			legend[curPos]={color:"#bbbedd",label:"Liver Total RNA Sequencing"};
		}

		that.drawLegend(legend);*/
	};

	that.triggerTableFilter=function(d){
		var e = jQuery.Event("keyup");
		e.which = 32; // # Some key code value
		var filterStr="";
		//to support different types of d depending on source need to determine what d is.
		if(d.getAttribute==undefined || d.getAttribute("ID")==undefined){

		}else{//represents a track feature
			filterStr=that.getDisplayID(d.getAttribute("ID"));
		}
		if(that.trackClass.indexOf("smallnc")==-1){
			$('#tblGenes'+that.trackClass+'_filter input').val(filterStr).trigger(e);
		}else{
			$('#tblsmGenes_filter input').val(filterStr).trigger(e);
		}
	};
	that.clearTableFilter=function(d){
		var e = jQuery.Event("keyup");
		e.which = 32; // # Some key code value
		if(that.trackClass!="smallnc"){
			$('#tblGenes'+that.trackClass+'_filter input').val("").trigger(e);
		}else{
			$('#tblsmGenes_filter input').val("").trigger(e);
		}
	};

	that.redrawLegend();
	that.draw(data);
	
	return that;
}
/*Track for displaying RefSeq Genes/Transcripts*/
function RefSeqTrack(gsvg,data,trackClass,label,additionalOptions){
	var that= GeneTrack(gsvg,data,trackClass,label);
	that.counts=[{value:0,names:"Ensembl"},{value:0,names:"RNA-Seq"}];
	that.drawAs="Gene";
	that.trxCutoff=100000;
	that.density=3;
	var additionalOptStr=new String(additionalOptions);
	if(additionalOptStr.indexOf("DrawTrx")>-1){
		that.drawAs="Trx";
	}

	//Initialize Y Positioning Variables
	that.yMaxArr=new Array();
	that.yArr=new Array();
	that.yArr[0]=new Array();
	for(var j=0;j<that.gsvg.width;j++){
				that.yMaxArr[j]=0;
				that.yArr[0][j]=0;
	}

	that.ttTrackList=[];	
	that.ttTrackList.push("ensemblcoding");
	that.ttTrackList.push("braincoding");
	that.ttTrackList.push("liverTotal");
	that.ttTrackList.push("heartTotal");
	that.ttTrackList.push("ensemblnoncoding");
	that.ttTrackList.push("brainnoncoding");
	that.ttTrackList.push("snpSHRH");
	that.ttTrackList.push("snpBNLX");
	that.ttTrackList.push("snpF344");
	that.ttTrackList.push("snpSHRJ");

	that.color =function(d){
		var color=d3.rgb("#000000");
		if(that.drawnAs=="Gene"){
			var txList=getAllChildrenByName(getFirstChildByName(d,"TranscriptList"),"Transcript");
			var mostValid=-1;
			for(var m=0;m<txList.length;m++){
					var cat=new String(txList[m].getAttribute("category"));
					var val=-1;
					if(cat=="Reviewed"){
						val=4;
					}else if(cat=="Validated"){
						val=3;
					}else if(cat=="Provisional"){
						val=2;
					}else if(cat=="Inferred"){
						val=1;
					}else if(cat=="Predicted"){
						val=0;
					}
					if(mostValid<val){
						mostValid=val;
					}
			}
			if(mostValid==4){
				color=d3.rgb("#18814F");
			}if(mostValid==3){
				color=d3.rgb("#38A16F");
			}else if(mostValid==2){
				color=d3.rgb("#78E1AF");
			}else if(mostValid==1){
				color=d3.rgb("#A8FFDF");
			}else if(mostValid==0){
				color=d3.rgb("#A8DFFF");
			}
		}else if(that.drawnAs=="Trx"){
			var cat=new String(d.getAttribute("category"));
			if(cat=="Reviewed"){
				color=d3.rgb("#18814F");
			}else if(cat=="Validated"){
				color=d3.rgb("#38A16F");
				//color=d3.rgb("#48B17F");
			}else if(cat=="Provisional"){
				color=d3.rgb("#78E1AF");
				//color=d3.rgb("#68D19F");
			}else if(cat=="Inferred"){
				color=d3.rgb("#A8FFDF");
				//color=d3.rgb("#88F1BF");
			}else if(cat=="Predicted"){
				color=d3.rgb("#A8DFFF");
			}
		}
		return color;
	};
	that.pieColor =function(d,i){
		var color=d3.rgb("#000000");
		var tmpName=new String(d.data.names);

		if(tmpName.indexOf("Reviewed")>-1){
				color=d3.rgb("#18814F");
		}else if(tmpName.indexOf("Validated")>-1){
				color=d3.rgb("#38A16F");
		}else if(tmpName.indexOf("Provisional")>-1){
				color=d3.rgb("#78E1AF");
		}else if(tmpName.indexOf("Inferred")>-1){
				color=d3.rgb("#A8FFDF");
		}else if(tmpName.indexOf("Predicted")>-1){
				color=d3.rgb("#A8DFFF");
		}
		return color;
	};

	that.getDisplayedData= function (){
		var dataElem=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".gene");
		that.counts=new Array();
		var countsInd=0;
		var tmpDat=dataElem[0];
		var dispData=new Array();
		var dispDataCount=0;
		var total=0;
		if(tmpDat!=undefined){
		for(var l=0;l<tmpDat.length;l++){
			var start=that.xScale(tmpDat[l].__data__.getAttribute("start"));
			var stop=that.xScale(tmpDat[l].__data__.getAttribute("stop"));
			if((0<=start && start<=that.gsvg.width)||(0<=stop &&stop<=that.gsvg.width)||(start<=0&&stop>=that.gsvg.width)){
				//var nameStr=new String(tmpDat[l].__data__.getAttribute("name"));
				var txList=getAllChildrenByName(getFirstChildByName(tmpDat[l].__data__,"TranscriptList"),"Transcript");
				var mostValid=-1;
				for(var m=0;m<txList.length;m++){
						var cat=new String(txList[m].getAttribute("category"));
						var val=-1;
						if(cat=="Reviewed"){
							val=4;
						}else if(cat=="Validated"){
							val=3;
						}else if(cat=="Provisional"){
							val=2;
						}else if(cat=="Inferred"){
							val=1;
						}else if(cat=="Predicted"){
							val=0;
						}
						if(mostValid<val){
							mostValid=val;
						}
				}
				var name="Unknown";
				if(mostValid==4){
					name="Reviewed";
				}else if(mostValid==3){
					name="Validated";
				}else if(mostValid==2){
					name="Provisional";
				}else if(mostValid==1){
					name="Inferred";
				}else if(mostValid==0){
					name="Predicted";
				}
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
		}
		return dispData;
	};

	that.createToolTip=function(d){
		var tooltip="";
		if(that.drawnAs=="Gene"){
			var txListStr="";
			var txList=getAllChildrenByName(getFirstChildByName(d,"TranscriptList"),"Transcript");
			for(var m=0;m<txList.length;m++){
				var id=new String(txList[m].getAttribute("ID"));
				txListStr+="<B>"+id+"</B> - "+txList[m].getAttribute("category");
				txListStr+="<br>";
			}
			tooltip="<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div>Gene Symbol: "+d.getAttribute("geneSymbol")+"<BR>Location: "+d.getAttribute("chromosome")+":"+numberWithCommas(d.getAttribute("start"))+"-"+numberWithCommas(d.getAttribute("stop"))+"<BR>Strand: "+d.getAttribute("strand")+"<BR>Transcripts:<BR>"+txListStr;
		}else if(that.drawnAs=="Trx"){
				var txListStr="";
				var id=new String(d.getAttribute("ID"));
				txListStr="<B>"+id+"</B>";
			tooltip="RefSeq ID:"+txListStr+"<BR>Status: "+d.getAttribute("category")+"<BR>Gene Symbol: "+d.getAttribute("geneSymbol")+"<BR>Location: "+d.getAttribute("chromosome")+":"+numberWithCommas(d.getAttribute("start"))+"-"+numberWithCommas(d.getAttribute("stop"))+"<BR>Strand: "+d.getAttribute("strand");
		}
		return tooltip;
	};

	that.calcY = function (start,end,i){
		var tmpY=0;
		if(that.density==3){
			if((start>=that.xScale.domain()[0]&&start<=that.xScale.domain()[1])||
				(end>=that.xScale.domain()[0]&&end<=that.xScale.domain()[1])||
				(start<=that.xScale.domain()[0]&&end>=that.xScale.domain()[1])){
				var pStart=Math.floor(that.xScale(start));
				if(pStart<0){
					pStart=0;
				}
				var pEnd=Math.floor(that.xScale(end))+1;
				if(pEnd>=that.gsvg.width){
					pEnd=that.gsvg.width-1;
				}
				var pixStart=pStart-5;
				if(pixStart<0){
					pixStart=0;
				}
				var pixEnd=pEnd+5;
				if(pixEnd>=that.gsvg.width){
					pixEnd=that.gsvg.width-1;
				}
				//find yMax that is clear this is highest line that is clear
				var yMax=0;
				for(var pix=pixStart;pix<=pixEnd;pix++){
					if(that.yMaxArr[pix]>yMax){
						yMax=that.yMaxArr[pix];
					}
				}
				yMax++;
				//may need to extend yArr for a new line
				var addLine=yMax;
				if(that.yArr.length<=yMax){
					that.yArr[addLine]=new Array();
					for(var j=0;j<that.gsvg.width;j++){
						that.yArr[addLine][j]=0;
					}
				}
				//check a couple lines back to see if it can be squeezed in
				var startLine=yMax-12;
				if(startLine<1){
					startLine=1;
				}
				var prevLine=-1;
				var stop=0;
				for(var scanLine=startLine;scanLine<yMax&&stop==0;scanLine++){
					var available=0;
					for(var pix=pixStart;pix<=pixEnd&&available==0;pix++){
						if(that.yArr[scanLine][pix]>available){
							available=1;
						}
					}
					if(available==0){
						yMax=scanLine;
						stop=1;
					}
				}
				if(yMax>that.trackYMax){
					that.trackYMax=yMax;
				}
				for(var pix=pStart;pix<=pEnd;pix++){
					if(that.yMaxArr[pix]<yMax){
						that.yMaxArr[pix]=yMax;
					}
					that.yArr[yMax][pix]=1;
				}
				tmpY=yMax*15;
			}else{
				tmpY=15;
			}
		}else if(that.density==2){
			tmpY=(i+1)*15;
		}else{
			tmpY=15;
		}
		if(that.trackYMax<(tmpY/15)){
			that.trackYMax=(tmpY/15);
		}
		return tmpY;
		};

	that.redraw=function(){
		
		var tmpMin=that.xScale.domain()[0];
		var tmpMax=that.xScale.domain()[1];
		var len=tmpMax-tmpMin;
		var overrideTrx=0;

		that.yMaxArr=new Array();
		that.yArr=new Array();
		that.yArr[0]=new Array();
		for(var p=0;p<that.gsvg.width;p++){
			that.yMaxArr[p]=0;
			that.yArr[0][p]=0;
		}
		that.trackYMax=0;

		if((len<that.trxCutoff&&that.drawnAs=="Gene")||(len>=that.trxCutoff&&that.drawnAs=="Trx"&&that.drawAs!="Trx")||(that.drawnAs=="Gene"&&$("#forceTrxCBX"+that.gsvg.levelNumber).is(":checked"))) {
			that.draw(that.data);
		}else{
			if(len<that.trxCutoff && that.drawnAs=="Trx" && that.drawAs!="Trx"){
				overrideTrx=1;
			}
			if(that.drawAs=="Gene" && overrideTrx==0){
				if(that.svg[0][0]!=null){
						that.svg.selectAll(".trx").each(function(){d3.select(this).remove();});
						d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene").attr("transform",function (d,i){
									var st=that.xScale(d.getAttribute("start"));
									return "translate("+st+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i)+")";
							});
						d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene rect").attr("width",function(d) {
									var wX=1;
									if(that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"))>1){
										wX=that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"));
									}
									return wX;
							})
							.attr("stroke",that.colorStroke);
						d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene").each( function(d){
							var d3This=d3.select(this);
							var strChar=">";
							if(d.getAttribute("strand")=="-1"||d.getAttribute("strand")=="-"){
								strChar="<";
							}
							var fullChar="";
							var rectW=d3This.select("rect").attr("width");
							if(rectW>=7.9 && rectW<=15.8){
								fullChar=strChar;
							}else{
								while(rectW>8.5){
									fullChar=fullChar+strChar;
									rectW=rectW-7.9;
								}
							}
							d3This.select("text").text(fullChar);
						});
					}


				if(that.density==1){
					that.svg.attr("height", 30);
				}else if(that.density==2){
					that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene").size()+1)*15);
				}else if(that.density==3){
					that.svg.attr("height", (that.trackYMax+1)*15);
				}
			}else if(overrideTrx==1 || that.drawAs=="Trx"){
				var txG=that.svg.selectAll("g.trx"+that.gsvg.levelNumber);
			
				txG//.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
					.each(function(d,i){
						var cdsStart=d.getAttribute("cdsStart");
						var cdsStop=d.getAttribute("cdsStop");
						exList=getAllChildrenByName(getFirstChildByName(d,"exonList"),"exon");
						var pref="";
						if(that.gsvg.levelNumber==1){
								pref="tx";
						}
						for(var m=0;m<exList.length;m++){
							var exStrt=exList[m].getAttribute("start");
							var exStp=exList[m].getAttribute("stop");
							if((exStrt<cdsStart&&cdsStart<exStp)||(exStp>cdsStop&&cdsStop>exStrt)){
								var ncStrt=exStrt;
								var ncStp=cdsStart;
								if(exStp>cdsStop){
									ncStrt=cdsStop;
									ncStp=exStp;
									exStrt=exStrt;
									exStp=cdsStop;
								}else{
									exStrt=cdsStart;
									exStp=exStp;
								}
								d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).select("g#"+pref+d.getAttribute("ID")+" rect#ExNC"+exList[m].getAttribute("ID"))
									.attr("x",function(d){ return that.xScale(ncStrt); })
									.attr("width",function(d){ return that.xScale(ncStp) - that.xScale(ncStrt); });
							}
							d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).select("g#"+pref+d.getAttribute("ID")+" rect#Ex"+exList[m].getAttribute("ID"))
								.attr("x",function(d){ return that.xScale(exStrt); })
								.attr("width",function(d){ return that.xScale(exStp) - that.xScale(exStrt); });
							if(m>0){
								var strChar=">";
								if(d.getAttribute("strand")=="-1"){
									strChar="<";
								}
								var fullChar=strChar;
								var intStart=that.xScale(exList[m-1].getAttribute("stop"));
								var intStop=that.xScale(exList[m].getAttribute("start"));
								var rectW=intStop-intStart;
								var alt=0;
								var charW=6.5;
								if(rectW<charW){
										fullChar="";
								}else{
									rectW=rectW-charW;
									while(rectW>(charW+1)){
										if(alt==0){
											fullChar=fullChar+" ";
											alt=1;
										}else{
											fullChar=fullChar+strChar;
											alt=0;
										}
										rectW=rectW-charW;
									}
								}
								d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).select("g#"+pref+d.getAttribute("ID")+" line#Int"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID"))
									.attr("x1",intStart)
									.attr("x2",intStop);

								d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).select("g#"+pref+d.getAttribute("ID")+" #IntTxt"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID"))
									.attr("dx",intStart+1).text(fullChar);
							}
						}
					});
				if(that.density==1){
					that.svg.attr("height", 30);
				}else if(that.density==2){
					that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.trx"+that.gsvg.levelNumber).size()+1)*15);
				}else if(that.density==3){
					that.svg.attr("height", (that.trackYMax+1)*15);
				}
			}
		}
		that.redrawSelectedArea();
	};

	that.updateData=function(retry){
		var tag="Gene";
		var tmpMin=that.xScale.domain()[0];
		var tmpMax=that.xScale.domain()[1];
		var path=dataPrefix+"tmpData/regionData/"+that.gsvg.folderName+"/refSeq.xml";
		d3.xml(path,function (error,d){
			if(error){
				//console.log(error);
				if(retry==0){
							$.ajax({
								url: contextPath +"/"+ pathPrefix +"generateTrackXML.jsp",
				   				type: 'GET',
								data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: that.trackClass, folder: that.gsvg.folderName,panel:panel},
								dataType: 'json',
				    			success: function(data2){
				    				
				    			},
				    			error: function(xhr, status, error) {
				        			
				    			}
							});
						}
						if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								that.updateData(retry+1);
							},time);
						}else{
							d3.select("#Level"+that.levelNumber+that.trackClass).select("#trkLbl").text("An errror occurred loading Track:"+that.trackClass);
							d3.select("#Level"+that.levelNumber+that.trackClass).attr("height", 15);
							that.gsvg.addTrackErrorRemove(that.svg,"#Level"+that.gsvg.levelNumber+that.trackClass);
						}
			}else{
				var data=d.documentElement.getElementsByTagName(tag);
				var mergeddata=new Array();
				var checkName=new Array();
				var curInd=0;
					for(var l=0;l<data.length;l++){
						if(data[l]!=undefined ){
							mergeddata[curInd]=data[l];
							checkName[data[l].getAttribute("ID")]=1;
							curInd++;
						}
					}
					for(var l=0;l<that.data.length;l++){
						if(that.data[l]!=undefined && checkName[that.data[l].getAttribute("ID")]==undefined){
							mergeddata[curInd]=that.data[l];
							curInd++;
						}
					}
				that.draw(mergeddata);
				that.hideLoading();
				DisplayRegionReport();
			}
		});
	};

	that.drawTrx=function (d,i){
		var cdsStart=d.getAttribute("cdsStart");
		var cdsStop=d.getAttribute("cdsStop");
		var prefix="";
		if(that.gsvg.levelNumber==1){
			prefix="tx";
		}
		var txG=that.svg.select("#"+prefix+d.getAttribute("ID"));
		exList=getAllChildrenByName(getFirstChildByName(d,"exonList"),"exon");
		for(var m=0;m<exList.length;m++){
			var exStrt=exList[m].getAttribute("start");
			var exStp=exList[m].getAttribute("stop");
			if((exStrt<cdsStart&&cdsStart<exStp)||(exStp>cdsStop&&cdsStop>exStrt)){//need to draw two rect one for CDS and one non CDS
				var xPos1=0;
				var xWidth1=0;
				var xPos2=0;
				var xWidth2=0;
				if(exStrt<cdsStart){
					xPos1=that.xScale(exList[m].getAttribute("start"));
					xWidth1=that.xScale(cdsStart) - that.xScale(exList[m].getAttribute("start"));
					xPos2=that.xScale(cdsStart);
					xWidth2=that.xScale(exList[m].getAttribute("stop")) - that.xScale(cdsStart);
				}else if(exStp>cdsStop){
					xPos2=that.xScale(exList[m].getAttribute("start"));
					xWidth2=that.xScale(cdsStop) - that.xScale(exList[m].getAttribute("start"));
					xPos1=that.xScale(cdsStop);
					xWidth1=that.xScale(exList[m].getAttribute("stop")) - that.xScale(cdsStop);
				}
				txG.append("rect")//non CDS
					.attr("x",xPos1)
					.attr("y",2.5)
			    	.attr("height",5)
			    	.attr("width",xWidth1)
					.attr("title",function(d){ return exList[m].getAttribute("ID");})
					.attr("id",function(d){return "ExNC"+exList[m].getAttribute("ID");})
					.style("fill",that.color)
					.style("cursor", "pointer");
				txG.append("rect")//CDS
						.attr("x",xPos2)
				    	.attr("height",10)
				    	.attr("width",xWidth2)
						//.attr("width",function(d){ return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start")); })
						.attr("title",function(d){ return exList[m].getAttribute("ID");})
						.attr("id",function(d){return "Ex"+exList[m].getAttribute("ID");})
						.style("fill",that.color)
						.style("cursor", "pointer");
				
			}else{
				var height=10;
				var y=0;
				if((exStrt<cdsStart&&exStp<cdsStart)||(exStp>cdsStop&&exStrt>cdsStop)){
					height=5;
					y=2.5;
				}
				txG.append("rect")
					.attr("x",function(d){ return that.xScale(exList[m].getAttribute("start")); })
					.attr("y",y)
			    	.attr("height",height)
					.attr("width",function(d){ return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start")); })
					.attr("title",function(d){ return exList[m].getAttribute("ID");})
					.attr("id",function(d){return "Ex"+exList[m].getAttribute("ID");})
					.style("fill",that.color)
					.style("cursor", "pointer");
			}
			if(m>0){
				txG.append("line")
				.attr("x1",function(d){ return that.xScale(exList[m-1].getAttribute("stop")); })
				.attr("x2",function(d){ return that.xScale(exList[m].getAttribute("start")); })
				.attr("y1",5)
				.attr("y2",5)
				.attr("id",function(d){ return "Int"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID");})
				.attr("stroke",that.color)
				.attr("stroke-width","2");
				var strChar=">";
				if(d.getAttribute("strand")=="-" || d.getAttribute("strand")=="-1"){
					strChar="<";
				}
				var fullChar=strChar;
				var intStart=that.xScale(exList[m-1].getAttribute("stop"));
				var intStop=that.xScale(exList[m].getAttribute("start"));
				var rectW=intStop-intStart;
				var alt=0;
				var charW=6.5;
				if(rectW<charW){
						fullChar="";
				}else{
					rectW=rectW-charW;
					while(rectW>(charW+1)){
						if(alt==0){
							fullChar=fullChar+" ";
							alt=1;
						}else{
							fullChar=fullChar+strChar;
							alt=0;
						}
						rectW=rectW-charW;
					}
				}
				txG.append("svg:text").attr("id",function(d){ return "IntTxt"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID");}).attr("dx",intStart+1)
					.attr("dy","11")
					.style("pointer-events","none")
					.style("opacity","0.5")
					.style("fill",that.color)
					.style("font-size","16px")
					.text(fullChar);
				
			}
		}
		
	};

	that.draw=function (data){


		that.data=data;
		
		that.trackYMax=0;
		that.yArr=new Array();
		that.yArr[0]=new Array();
		for(var j=0;j<that.gsvg.width;j++){
				that.yMaxArr[j]=0;
				that.yArr[0][j]=0;
		}

		that.svg.selectAll(".gene").remove();
		that.svg.selectAll(".trx"+that.gsvg.levelNumber).remove();
		
		/*if($("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").length>0){
			that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").val();
		}*/
			
		var prevDrawAs=that.drawAs;
		var tmpMin=that.xScale.domain()[0];
		var tmpMax=that.xScale.domain()[1];
		var len=tmpMax-tmpMin;
		if(len<that.trxCutoff || $("#forceTrxCBX"+that.gsvg.levelNumber).is(":checked")){
			that.drawAs="Trx";
		}
		if(that.drawAs=="Gene"){
			that.drawnAs="Gene";
			that.label="Ref Seq Genes";
			that.updateLabel(that.label);
			that.redrawLegend();
			
			var gene=that.svg.selectAll(".gene")
		   			.data(data,key)
					.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+(that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i))+")";});
			//add new
			gene.enter().append("g")
					.attr("class","gene")
					.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+(that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i))+")";})
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
				.on("dblclick", that.zoomToFeature)
				.on("mouseover", function(d) {
					if(that.gsvg.isToolTip==0){ 
						overSelectable=1;
						$("#mouseHelp").html("<B>Double Click</B> to zoom in on this feature.");
						d3.select(this).style("fill","green");
			        	//that.gsvg.get('tt').transition()
			        	tt.transition()        
			                .duration(200)      
			                .style("opacity", 1);      
			        	//that.gsvg.get('tt').html(that.createToolTip(d))  
			        	tt.html(that.createToolTip(d))
			                .style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
							.style("top", function(){return that.positionTTTop(d3.event.pageY);});
			            that.setupToolTipSVG(d,0.05);
					}
			            return false;
		            })
				.on("mouseout", function(d) { 
					overSelectable=0;
					$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
					if(d3.select(this).attr("class")!="selected"){
						d3.select(this).style("fill",that.color);
					}
		            tt.transition()
						 .delay(500)       
		                .duration(200)      
		                .style("opacity", 0);  
		        });
			
			gene.exit().remove();
			
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene").each( function(d){
				if(d!=undefined){
				var d3This=d3.select(this);
				var strChar=">";
				if(d.getAttribute("strand")=="-" || d.getAttribute("strand")=="-1"){
					strChar="<";
				}
				var fullChar=strChar;
				var rectW=d3This.select("rect").attr("width");
				if(rectW<7.9){
					fullChar="";
				}else{
					rectW=rectW-7.9;
					fullChar=strChar;
					while(rectW>8.5){
						fullChar=fullChar+strChar;
						rectW=rectW-7.9;
					}
				}
				d3This.append("svg:text").attr("dx","1").attr("dy","10").style("pointer-events","none").text(fullChar);
				}
			});

			if(that.density==1){
				that.svg.attr("height", 30);
			}else if(that.density==2){
				that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene").size()+1)*15);
			}else if(that.density==3){
				that.svg.attr("height", (that.trackYMax+1)*15);
			}
		}else if(that.drawAs="Trx"){
			that.drawnAs="Trx";
			that.label="Ref Seq Transcripts";
			that.updateLabel(that.label);
			that.redrawLegend();
			//var geneList=getAllChildrenByName(getFirstChildByName(data,"GeneList"),"Gene");
			var txList=new Array();
			var txListSize=0;
			for(var j=0;j<data.length;j++){
				var tmpTxList=getAllChildrenByName(getFirstChildByName(data[j],"TranscriptList"),"Transcript");
				for(var k=0;k<tmpTxList.length;k++){
					txList[txListSize]=tmpTxList[k];
					txList[txListSize].parent=data[j];
					txListSize++;
				}
			}
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".trx"+that.gsvg.levelNumber).remove();
			var tx=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".trx"+that.gsvg.levelNumber)
		   			.data(txList,key)
					.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+(that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i))+")";});
					
		  	tx.enter().append("g")
					.attr("class","trx"+that.gsvg.levelNumber)
					//.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
					.attr("transform",function(d,i){ return "translate(0,"+(that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i))+")";})
					.attr("id",function(d){
						var prefix="";
						if(that.gsvg.levelNumber==1){
							prefix="tx";
						}
						return prefix+d.getAttribute("ID");})
					.on("mouseover", function(d) {
							if(that.gsvg.isToolTip==0){ 
								d3.select(this).selectAll("line").style("stroke","green");
								d3.select(this).selectAll("rect").style("fill","green");
								d3.select(this).selectAll("text").style("opacity","0.3").style("fill","green");
		            			tt.transition()        
									.duration(200)      
									.style("opacity", 1);      
								tt.html(that.createToolTip(d))  
									.style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
									.style("top", function(){return that.positionTTTop(d3.event.pageY);});
							}
		            	})
					.on("mouseout", function(d) {
							d3.select(this).selectAll("line").style("stroke",function(d){return that.color(d);});
							d3.select(this).selectAll("rect").style("fill",function(d){return that.color(d);});
							d3.select(this).selectAll("text").style("opacity","0.6").style("fill",function(d){return that.color(d);});  
							tt.transition()
								 .delay(500)       
								.duration(200)      
								.style("opacity", 0);  
		        		})
					.each(that.drawTrx);
			 tx.exit().remove();
			if(that.density==2){
				that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.trx"+that.gsvg.levelNumber).size()+1)*15);
			}else if(that.density==3){
				that.svg.attr("height", (that.trackYMax+1)*15);
			}else{
				that.svg.attr("height", 30);
			}
		}
		that.redrawSelectedArea();
		that.drawAs=prevDrawAs;
	};

	that.redrawLegend=function (){
		var legend=[];
		var curPos=0;
		legend=[{color:"#18814F",label:"Reviewed"},{color:"#38A16F",label:"Validated"},{color:"#78E1AF",label:"Provisional"},{color:"#A8FFDF",label:"Inferred"},{color:"#A8DFFF",label:"Predicted"}];
		that.drawLegend(legend);
	};

	
	that.redrawLegend();
	that.draw(data);
	
	return that;
}
/*Track for displaying Probesets*/
function ProbeTrack(gsvg,data,trackClass,label,additionalOptions){
	var that= Track(gsvg,data,trackClass,label);

	//console.log("creating probe track options:"+additionalOptions);
	var opts=new String(additionalOptions).split(",");
	if(opts.length>0){
		that.density=opts[0];
		if(opts.length>1){
			that.colorSelect=opts[1];
		}else{
			that.colorSelect="annot";
		}
		if(opts.length>2){
			that.tissues=opts[2].split(":");

		}else{
			that.tissues=["Brain"];
			if(organism=="Rn"){
				that.tissues=["Brain","BrownAdipose","Heart","Liver"];
			}
		}
	}else{
		that.density=3;
		that.colorSelect="annot";
		that.tissues=["Brain"];
		if(organism=="Rn"){
			that.tissues=["Brain","BrownAdipose","Heart","Liver"];
		}
	}

	that.tissuesAll=["Brain"];
	if(organism=="Rn"){
		that.tissuesAll=["Brain","BrownAdipose","Heart","Liver"];
	}

	that.curColor=that.colorSelect;
	//console.log("start Probes");
	//console.log("density:"+that.density);
	//console.log("colorSelect:"+that.colorSelect);
	//console.log("curColor:"+that.curColor);
	//console.log(that.tissues);

	that.ttTrackList=new Array();
	that.ttTrackList.push("ensemblcoding");
	that.ttTrackList.push("braincoding");
	that.ttTrackList.push("liverTotal");
	that.ttTrackList.push("heartTotal");
	that.ttTrackList.push("ensemblnoncoding");
	that.ttTrackList.push("brainnoncoding");
	//that.ttTrackList.push("ensemblsmallnc");
	//that.ttTrackList.push("brainsmallnc");

	that.color =function(d,tissue){
		var color=d3.rgb("#000000");
		if(that.colorSelect=="annot"){
			if(d.getAttribute("type")=="core"){
					color=d3.rgb(255,0,0);
			}else if(d.getAttribute("type")=="extended"){
					color=d3.rgb(0,0,255);
			}else if(d.getAttribute("type")=="full"){
					color=d3.rgb(0,100,0);
			}else if(d.getAttribute("type")=="ambiguous"){
					color=d3.rgb(0,0,0);
			}
		}else if(that.colorSelect=="herit"){
			var value=getFirstChildByName(d,"herit").getAttribute(tissue);
			var cval=Math.floor(value*255);
			color=d3.rgb(cval,0,0);
		}else if(that.colorSelect=="dabg"){
			var value=getFirstChildByName(d,"dabg").getAttribute(tissue);
			var cval=Math.floor(value*2.55);
			color=d3.rgb(0,cval,0);
		}
		return color;
	};

	that.pieColor =function(d,i){
		var color=d3.rgb("#000000");
		var tmpName=new String(d.data.names);
			if(tmpName=="Core"){
					color=d3.rgb(255,0,0);
			}else if(tmpName=="Extended"){
					color=d3.rgb(0,0,255);
			}else if(tmpName=="Full"){
					color=d3.rgb(0,100,0);
			}else if(tmpName=="Ambiguous"){
					color=d3.rgb(0,0,0);
			}
		return color;
	};

	that.createToolTip=function(d){
		var strand=".";
		if(d.getAttribute("strand") == 1){
			strand="+";
		}else if(d.getAttribute("strand")==-1){
			strand="-";
		}
		var len=d.getAttribute("stop")-d.getAttribute("start");
		var tooltiptext="<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div><BR>Affy Probe Set ID: "+d.getAttribute("ID")+"<BR>Strand: "+strand+"<BR>Location: "+d.getAttribute("chromosome")+":"+numberWithCommas(d.getAttribute("start"))+"-"+numberWithCommas(d.getAttribute("stop"))+" ("+len+"bp)<BR>";
		tooltiptext=tooltiptext+"Type: "+d.getAttribute("type")+"<BR><BR>";
		//var tissues=$(".settingsLevel"+that.gsvg.levelNumber+" input[name=\"tissuecbx\"]:checked");
		var herit=getFirstChildByName(d,"herit");
		var dabg=getFirstChildByName(d,"dabg");
		tooltiptext=tooltiptext+"<table class=\"tooltipTable\" width=\"100%\" colSpace=\"0\"><tr><TH>Tissue</TH><TH>Heritability</TH><TH>DABG</TH></TR>";
		if(that.tissues.length<that.tissuesAll.length){
			tooltiptext=tooltiptext+"<TR><TD colspan=\"3\">Displayed Tissues:</TD></TR>";
		}
		var displayed={};
		for(var t=0;t<that.tissues.length;t++){
			var tissue=new String(that.tissues[t]);
			if(tissue.indexOf("Affy")>-1){
				tissue=tissue.substr(0,tissue.indexOf("Affy"));
			}
			displayed[tissue]=1;
			var hval=Math.floor(herit.getAttribute(tissue)*255);
			var hcol=d3.rgb(hval,0,0);
			var dval=Math.floor(dabg.getAttribute(tissue)*2.55);
			var dcol=d3.rgb(0,dval,0);
			tooltiptext=tooltiptext+"<TR><TD>"+tissue+"</TD><TD style=\"background:"+hcol+";color:white;\">"+herit.getAttribute(tissue)+"</TD><TD style=\"background:"+dcol+";color:white;\">"+dabg.getAttribute(tissue)+"%</TD></TR>";
		}
		if(that.tissues.length<that.tissuesAll.length){
			tooltiptext=tooltiptext+"<TR><TD colspan=\"3\">Other Tissues:</TD></TR>";
			for(var t=0;t<that.tissuesAll.length;t++){
				var tissue=new String(that.tissuesAll[t]);
				if(tissue.indexOf("Affy")>-1){
					tissue=tissue.substr(0,tissue.indexOf("Affy"));
				}
				if(displayed[tissue]!=1){
					var hval=Math.floor(herit.getAttribute(tissue)*255);
					var hcol=d3.rgb(hval,0,0);
					var dval=Math.floor(dabg.getAttribute(tissue)*2.55);
					var dcol=d3.rgb(0,dval,0);
					tooltiptext=tooltiptext+"<TR><TD>"+tissue+"</TD><TD style=\"background:"+hcol+";color:white;\">"+herit.getAttribute(tissue)+"</TD><TD style=\"background:"+dcol+";color:white;\">"+dabg.getAttribute(tissue)+"%</TD></TR>";
				}
			}
		}
		tooltiptext=tooltiptext+"</table>";
		return tooltiptext;
	};

	that.updateSettingsFromUI=function(){
		if($("#"+that.trackClass+"Dense"+that.level+"Select").length>0){
			that.density=$("#"+that.trackClass+"Dense"+that.level+"Select").val();
		}
		that.curColor=that.colorSelect;
		if($("#"+that.trackClass+that.level+"colorSelect").length>0){
			that.curColor=$("#"+that.trackClass+that.level+"colorSelect").val();
		}
		var count=0;
		if($("#affyTissues"+that.level+" input[name=\"tissuecbx\"]").length>0){
			that.tissues=[];
			var tis=$("#affyTissues"+that.level+" input[name=\"tissuecbx\"]:checked");
			for(var t=0;t<tis.length;t++){
					var tissue=new String(tis[t].id);
					tissue=tissue.substr(0,tissue.indexOf("Affy"));
					that.tissues[count]=tissue;
					count++;
			}
		}
	};

	that.savePrevious=function(){
		that.prevSetting={};
		that.prevSetting.density=that.density;
		that.prevSetting.curColor=that.curColor;
		that.prevSetting.tissues=that.tissues;
	};
	
	that.revertPrevious=function(){
		that.density=that.prevSetting.density;
		that.curColor=that.prevSetting.curColor;
		that.tissues=that.prevSetting.tissues;
	};

	that.redraw=function(){
		var tissueLen=that.tissues.length;
		if(that.curColor!=that.colorSelect || ((that.colorSelect=="herit" || that.colorSelect=="dabg") && tissueLen!=that.tissueLen)){
			that.tissueLen=tissueLen;
			that.draw(that.data);
		}else{
			that.colorSelect=that.curColor;
			that.tissueLen=tissueLen;
			if(that.colorSelect=="dabg"||that.colorSelect=="herit"){
				if(that.colorSelect=="dabg"){
					that.drawScaleLegend("0%","100%","of Samples DABG","#000000","#00FF00",0);
				}else if(that.colorSelect=="herit"){
					that.drawScaleLegend("0","1.0","Probeset Heritability","#000000","#FF0000",0);
				}
				d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.probe").each( function(d){
									var d3This=d3.select(this);
									var strChar=">";
									if(d.getAttribute("strand")=="-1"){
										strChar="<";
									}
									var fullChar="";
									var rectW=d3This.select("rect").attr("width");
									if(rectW>=7.5 && rectW<=15){
										fullChar=strChar;
									}else if(rectW>15){
										rectW=rectW-7.5;
										while(rectW>7.5){
											fullChar=fullChar+strChar;
											rectW=rectW-7.5;
										}
									}
									d3This.select("text").text(fullChar);
								});
				var totalYMax=1;
				for(var t=0;t<that.tissues.length;t++){
					var tissue=new String(that.tissues[t]);
					//tissue=tissue.substr(0,tissue.indexOf("Affy"));
					
						that.trackYMax=0;
						that.yArr=new Array();
						for(var j=0;j<100;j++){
									that.yArr[j]=-299999999;
						}
						totalYMax++;
						d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).select("text."+tissue).attr("y",totalYMax*15);
						d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.probe."+tissue).attr("transform",function (d,i){
																			   var st=that.xScale(d.getAttribute("start"));
																			   var y=that.calcY(d.getAttribute("start"),d.getAttribute("stop"),that.density,i,2)+totalYMax*15-10;
																				return "translate("+st+","+y+")";
																			});
						
						d3.select("#Level"+that.gsvg.levelNumber+that.trackClass)
							.selectAll("g.probe rect."+tissue)
								.attr("width",function(d) {
									   var wX=1;
									   if(that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"))>1){
										   wX=that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"));
									   }
									   return wX;
		   						})
								.attr("fill",function(d){
										return that.color(d,tissue);
								});
						totalYMax=totalYMax+that.trackYMax;
					
				}
				that.trackYMax=totalYMax*15;
				that.svg.attr("height", that.trackYMax);
							
			}else if(that.colorSelect=="annot"){
				var legend=[{color:"#FF0000",label:"Core"},{color:"#0000FF",label:"Extended"},{color:"#006400",label:"Full"},{color:"#000000",label:"Ambiguous"}];
				that.drawLegend(legend);
				that.trackYMax=0;
				that.yArr=new Array();
				for(var j=0;j<100;j++){
					that.yArr[j]=-299999999;
				}
				
				d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.probe").attr("transform",function (d,i){
																	   var st=that.xScale(d.getAttribute("start"));
																		return "translate("+st+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),that.density,i,2)+")";
																	});
				d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.probe rect")
																.attr("width",function(d) {
																												   var wX=1;
																												   if(that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"))>1){
																													   wX=that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"));
																												   }
																												   return wX;
										   						})
																.attr("fill",function(d){
																	return that.color(d,"");
																});
				d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.probe").each( function(d){
							var d3This=d3.select(this);
							var strChar=">";
							if(d.getAttribute("strand")=="-1"){
								strChar="<";
							}
							var fullChar="";
							var rectW=d3This.select("rect").attr("width");
							if(rectW>=7.5 && rectW<=15){
								fullChar=strChar;
							}else if(rectW>15){
								rectW=rectW-7.5;
								while(rectW>7.5){
									fullChar=fullChar+strChar;
									rectW=rectW-7.5;
								}
							}
							d3This.select("text").text(fullChar);
						});
				if(that.density==1){
					that.svg.attr("height", 30);
				}else if(that.density==2){
					that.svg.attr("height", (that.trackYMax+1)*15);
				}else if(that.density==3){
					that.svg.attr("height", (that.trackYMax+1)*15);
				}
			}
		}
		that.redrawSelectedArea();
	};

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
				for (var iy=startAt;iy<that.yArr.length&&!found;iy++){
						if((that.yArr[iy]+spacing)<that.xScale(start)){
							found=true;
							tmpY=(iy+1)*15;
							if(that.xScale(end)>that.yArr[iy]){
								that.yArr[iy]=that.xScale(end);
								//found=true;
							}
						}
				}
				if(!found){
					count++;
					startAt=that.yArr.length;
					for(var n=0;n<50;n++){
						that.yArr.push(-299999999);
					}
				}
			}
			if(!found){
				tmpY=(that.yArr.length+1)*15;
			}
		}
		if((tmpY/15)>that.trackYMax){
			that.trackYMax=tmpY/15;
		}
		return tmpY;
	};

	that.update=function (d){
		that.redraw();
	};

	that.updateData = function(retry){
		var tag="probe";
		var path=dataPrefix+"tmpData/regionData/"+that.gsvg.folderName+"/probe.xml";
		d3.xml(path,function (error,d){
				if(error){
					if(retry<3){//wait before trying again
							var time=5000;
							if(retry==1){
								time=10000;
							}
							setTimeout(function (){
								that.updateData(retry+1);
							},time);
					}else if(retry>=3){
							d3.select("#Level"+that.levelNumber+that.trackClass).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+that.trackClass).attr("height", 15);
							that.gsvg.addTrackErrorRemove(that.svg,"#Level"+that.gsvg.levelNumber+that.trackClass);
					}
				}else{
						var probe=d.documentElement.getElementsByTagName(tag);
						var mergeddata=new Array();
						var checkName=new Array();
						var curInd=0;
						for(var l=0;l<that.data.length;l++){
							if(that.data[l]!=undefined){ 
								mergeddata[curInd]=that.data[l];
								checkName[that.data[l].getAttribute("ID")]=1;
								curInd++;
							}
						}
						for(var l=0;l<probe.length;l++){
							if(probe[l]!=undefined && checkName[probe[l].getAttribute("ID")]==undefined){
								mergeddata[curInd]=probe[l];
								curInd++;
							}
						}
						
						that.draw(mergeddata);
						that.hideLoading();
					}
			});
	};

	that.draw= function (data){
		that.data=data;
		that.colorSelect=that.curColor;
		if(that.colorSelect=="dabg"||that.colorSelect=="herit"){
			if(that.colorSelect=="dabg"){
				that.drawScaleLegend("0%","100%","of Samples DABG","#000000","#00FF00",0);
			}else if(that.colorSelect=="herit"){
				that.drawScaleLegend("0","1.0","Probeset Heritability","#000000","#FF0000",0);
			}
			that.svg.selectAll(".probe").remove();
			that.svg.selectAll(".tissueLbl").remove();
			//var tissues=$(".settingsLevel"+that.gsvg.levelNumber+" input[name=\"tissuecbx\"]:checked");
			//that.tissueLen=tissues.length;
			/*var count=0;
			if($(".settingsLevel"+that.gsvg.levelNumber+" input[name=\"tissuecbx\"]").length>0){
				that.tissues=[];
				var tis=$(".settingsLevel"+that.gsvg.levelNumber+" input[name=\"tissuecbx\"]:checked");
				for(var t=0;t<tis.length;t++){
						var tissue=new String(tis[t].id);
						tissue=tissue.substr(0,tissue.indexOf("Affy"));
						that.tissues[count]=tissue;
						count++;
				}
			}*/
			that.tissueLen=that.tissues.length;
			var totalYMax=1;
			for(var t=0;t<that.tissues.length;t++){
						var tissue=new String(that.tissues[t]);
						if(tissue.indexOf(";")>0){
							tissue=tissue.substr(0,tissue.indexOf(";"));
						}
						if(tissue.indexOf(":")>0){
							tissue=tissue.substr(0,tissue.indexOf(":"));
						}
						//tissue=tissue.substr(0,tissue.indexOf("Affy"));
						that.trackYMax=0;
						that.yArr=new Array();
						for(var j=0;j<100;j++){
							that.yArr[j]=-299999999;
						}
						var dispTissue=tissue;
						if(dispTissue=="BrownAdipose"){
							dispTissue="Brown Adipose";
						}else if(dispTissue=="Brain"){
							dispTissue="Whole Brain";
						}
						var tisLbl=new String("Tissue: "+dispTissue);
						totalYMax++;
						that.svg.append("text").attr("class","tissueLbl "+tissue).attr("x",that.gsvg.width/2-(tisLbl.length/2)*7.5).attr("y",totalYMax*15).text(tisLbl);
						
						//console.log(";.probe."+tissue+";");
						//update
						var probes=that.svg.selectAll(".probe."+tissue)
				   			.data(data,function(d){return keyTissue(d,tissue);})
							.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+(that.calcY(d.getAttribute("start"),d.getAttribute("stop"),that.density,i,2)+totalYMax*15-10)+")";})
										
						//add new
						probes.enter().append("g")
							.attr("class","probe "+tissue)
							.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+(that.calcY(d.getAttribute("start"),d.getAttribute("stop"),that.density,i,2)+totalYMax*15-10)+")";})
							.append("rect")
							//.attr("class",tissue)
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
							.attr("id",function(d){return d.getAttribute("ID")+tissue;})
							.style("fill",function (d){return that.color(d,tissue);})
							.style("cursor", "pointer")
									/*.style("opacity", function(d){
												var op=1;
												if(!(typeof that.gsvg.selectedData ==="undefined")){
													if(d.getAttribute("strand")==that.gsvg.selectedData.getAttribute("strand")){

													}else{
														op=0;
													}
												}
												return op;
										})*/
							.on("dblclick", that.zoomToFeature)

							.on("mouseover", function(d) {
									if(that.gsvg.isToolTip==0){ 
										overSelectable=1;
										$("#mouseHelp").html("<B>Double Click</B> to zoom in on this feature.");
										var thisD3=d3.select(this); 
										that.curTTColor=thisD3.style("fill");
										if(thisD3.style("opacity")>0){
											thisD3.style("fill","green");
							            	tt.transition()        
							                	.duration(200)      
							                	.style("opacity", 1);      
							            	tt.html(that.createToolTip(d))  
							                	.style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
												.style("top", function(){return that.positionTTTop(d3.event.pageY);});
							                //Setup Tooltip SVG
							                that.setupToolTipSVG(d,0.2);
							            }
							        }
							    })
							.on("mouseout", function(d) {
								overSelectable=0;
								$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
								var thisD3=d3.select(this); 
								if(thisD3.style("opacity")>0){  
								thisD3.style("fill",that.curTTColor);
					            tt.transition()
									 .delay(500)       
					                .duration(200)      
					                .style("opacity", 0); 
					            } 
					        });
							d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.probe").each( function(d){
								var d3This=d3.select(this);
								var strChar=">";
								if(d.getAttribute("strand")=="-1"){
									strChar="<";
								}
								var fullChar=strChar;
								var rectW=d3This.select("rect").attr("width");
								if(rectW<7.5){
									fullChar="";
								}else{
									rectW=rectW-7.5;
									while(rectW>8.5){
										fullChar=fullChar+strChar;
										rectW=rectW-7.5;
									}
								}
								d3This.append("svg:text").attr("dx","1").attr("dy","10").style("pointer-events","none").style("fill","white").text(fullChar);
							});
							totalYMax=totalYMax+that.trackYMax+1;
			}
			//probes.exit().remove();
			that.trackYMax=totalYMax;
			that.svg.attr("height", totalYMax*15+45);
		}else if(that.colorSelect=="annot"){
			var legend=[{color:"#FF0000",label:"Core"},{color:"#0000FF",label:"Extended"},{color:"#006400",label:"Full"},{color:"#000000",label:"Ambiguous"}];
			that.drawLegend(legend);
			that.trackYMax=0;
			that.yArr=new Array();
			for(var j=0;j<100;j++){
				that.yArr[j]=-299999999;
			}
			that.svg.selectAll(".probe").remove();
			that.svg.selectAll(".tissueLbl").remove();
			//update
			var probes=that.svg.selectAll(".probe.annot")
	   			.data(data,key)
				.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),that.density,i,2)+")";})
					
			//add new
			probes.enter().append("g")
				.attr("class","probe annot")
				.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),that.density,i,2)+")";})
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
				.style("fill",function (d){return that.color(d,"");})
				.style("cursor", "pointer")
				.on("dblclick", that.zoomToFeature)
				.on("mouseover", function(d) {
					if(that.gsvg.isToolTip==0){ 
						overSelectable=1;
						$("#mouseHelp").html("<B>Double Click</B> to zoom in on this feature.");
						var thisD3=d3.select(this); 
						if(thisD3.style("opacity")>0){
							thisD3.style("fill","green");
			            	tt.transition()        
			                	.duration(200)      
			                	.style("opacity", 1);      
			            	tt.html(that.createToolTip(d))  
			                	.style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
								.style("top", function(){return that.positionTTTop(d3.event.pageY);});
			                //Setup Tooltip SVG
			                that.setupToolTipSVG(d,0.2);
							/*var start=d.getAttribute("start")*1;
							var stop=d.getAttribute("stop")*1;
							var len=stop-start;
							var fivePerc=Math.floor(len*0.20);
							var newSvg=toolTipSVG("div#ttSVG",450,start-fivePerc,stop+fivePerc,99,d.getAttribute("ID"),"transcript");
							//Setup Track for current feature
							var dataArr=new Array();
							dataArr[0]=d;
							newSvg.addTrack(that.trackClass,3,"",dataArr);
							//Setup Other tracks included in the track type(listed in that.ttTrackList)

							//TODO can't I replage this with setupToolTipSVG
							for(var r=0;r<that.ttTrackList.length;r++){
								var tData=that.gsvg.getTrackData(that.ttTrackList[r]);
								var fData=new Array();
								if(tData!=undefined&&tData.length>0){
									var fCount=0;
									for(var s=0;s<tData.length;s++){
										if((start<=tData[s].getAttribute("start")&&tData[s].getAttribute("start")<=stop)
											|| (tData[s].getAttribute("start")<=start&&tData[s].getAttribute("stop")>=start)
											){
											fData[fCount]=tData[s];
											fCount++;
										}
									}
									if(fData.length>0){
										newSvg.addTrack(that.ttTrackList[r],3,"DrawTrx",fData);	
									}
								}
							}*/
			            }
			        }
		            })
				.on("mouseout", function(d) {
					overSelectable=0;
					$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
					var thisD3=d3.select(this); 
					if(thisD3.style("opacity")>0){  
					thisD3.style("fill",that.color);
		            tt.transition()
						 .delay(500)       
		                .duration(200)      
		                .style("opacity", 0); 
		            } 
		        });
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.probe").each( function(d){
				var d3This=d3.select(this);
				var strChar=">";
				if(d.getAttribute("strand")=="-1"){
					strChar="<";
				}
				var fullChar=strChar;
				var rectW=d3This.select("rect").attr("width");
				if(rectW<7.5){
					fullChar="";
				}else{
					rectW=rectW-7.5;
					while(rectW>15){
						fullChar=fullChar+strChar;
						rectW=rectW-7.5;
					}
				}
				d3This.append("svg:text").attr("dx","1").attr("dy","10").style("pointer-events","none").style("fill","white").text(fullChar);
			});
			
		
			//probes.exit().remove();
			if(that.density==1){
				that.svg.attr("height", 30);
			}else if(that.density==2){
				//that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.probe").length+1)*15);
				that.svg.attr("height", (that.trackYMax+1)*15);
			}else if(that.density==3){
				that.svg.attr("height", (that.trackYMax+1)*15);
			}
		}
		that.redrawSelectedArea();
	};

	that.getDisplayedData= function (){
		var dataElem=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.probe");
		that.counts=[{value:0,names:"Core"},{value:0,names:"Extended"},{value:0,names:"Full"},{value:0,names:"Ambiguous"}];
		var tmpDat=dataElem[0];
		var dispData=new Array();
		var dispDataCount=0;
		if (!(typeof tmpDat === 'undefined')) {
			for(var l=0;l<tmpDat.length;l++){
				var start=that.xScale(tmpDat[l].__data__.getAttribute("start"));
				var stop=that.xScale(tmpDat[l].__data__.getAttribute("stop"));
				if((0<=start && start<=that.gsvg.width)||(0<=stop &&stop<=that.gsvg.width)){
					if(tmpDat[l].__data__.getAttribute("type")=="core"){
						that.counts[0].value++;
					}else if(tmpDat[l].__data__.getAttribute("type")=="extended"){
						that.counts[1].value++;
					}else if(tmpDat[l].__data__.getAttribute("type")=="full"){
						that.counts[2].value++;
					}else if(tmpDat[l].__data__.getAttribute("type")=="ambiguous"){
						that.counts[3].value++;
					}
					dispData[dispDataCount]=tmpDat[l].__data__;
					dispDataCount++;
				}
			}
		}else{
			that.counts=[];
		}
		return dispData;
	};

	that.generateSettingsDiv=function(topLevelSelector){
		var d=trackInfo[that.trackClass];
		that.savePrevious();
		//console.log(trackInfo);
		//console.log(d);
		d3.select(topLevelSelector).select("table").select("tbody").html("");
		if(d.Controls.length>0 && d.Controls!="null"){
			var controls=new String(d.Controls).split(",");
			var table=d3.select(topLevelSelector).select("table").select("tbody");
			table.append("tr").append("td").style("font-weight","bold").html("Track Settings: "+d.Name);
			for(var c=0;c<controls.length;c++){
				if(controls[c]!=undefined && controls[c]!=""){
					var params=controls[c].split(";");
					
					var div=table.append("tr").append("td");
					var lbl=params[0].substr(5);
					
					var def="";
					if(params.length>3  && params[3].indexOf("Default=")==0){
						def=params[3].substr(8);
					}
					if(params[1].toLowerCase().indexOf("select")==0){
						div.append("text").text(lbl+": ");
						var selClass=params[1].split(":");
						var opts=params[2].split("}");
						var id=that.trackClass+"Dense"+that.level+"Select";
						if(selClass[1]=="colorSelect"){
							id=that.trackClass+that.level+"colorSelect";
						}
						var sel=div.append("select").attr("id",id)
							.attr("name",selClass[1]);
						for(var o=0;o<opts.length;o++){
							var option=opts[o].substr(1).split(":");
							if(option.length==2){
								var tmpOpt=sel.append("option").attr("value",option[1]).text(option[0]);
								if(selClass[1]=="colorSelect" && option[1]==that.curColor ){
									tmpOpt.attr("selected","selected");
								}else if(option[1]==that.density){
									tmpOpt.attr("selected","selected");
								}
							}
						}
						d3.select("select#"+id).on("change", function(){
							if($(this).val()=="dabg"||$(this).val()=="herit"){
								$("div#affyTissues"+that.level).show();
							}else{
								$("div#affyTissues"+that.level).hide();
							}
							that.updateSettingsFromUI();
							that.redraw();
						});
					}else if(params[1].toLowerCase().indexOf("cbx")==0){
						div=div.append("div").attr("id","affyTissues"+that.level).style("display","none");
						div.append("text").text(lbl+": ");
						var selClass=params[1].split(":");
						var opts=params[2].split("}");
						
						for(var o=0;o<opts.length;o++){
							var option=opts[o].substr(1).split(":");
							if(option.length==2){
								var span=div.append("div").style("display","inline-block");
								var sel=span.append("input").attr("type","checkbox").attr("id",option[1]+"CBX"+that.level)
									.attr("name",selClass[1])
									.style("margin-left","5px");
								span.append("text").text(option[0]);
								//console.log(def+"::"+option[1]);
								
								d3.select("input#"+option[1]+"CBX"+that.level).on("change", function(){
									that.updateSettingsFromUI();
									that.redraw();
								});
							}
						}
					}
				}
			}
			if(that.curColor=="dabg"||that.curColor=="herit"){
				$("div#affyTissues"+that.level).show();
			}else{
				$("div#affyTissues"+that.level).hide();
			}
			for(var p=0;p<that.tissues.length;p++){
					//console.log("#"+that.tissues[p]+"AffyCBX"+that.level);
					$("#"+that.tissues[p]+"AffyCBX"+that.level).prop('checked',true);
			}
			var buttonDiv=table.append("tr").append("td");
			buttonDiv.append("input").attr("type","button").attr("value","Remove Track").style("float","left").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
				that.gsvg.removeTrack(that.trackClass);
			});
			buttonDiv.append("input").attr("type","button").attr("value","Apply").style("float","right").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
				if(that.density!=that.prevSetting.density || that.curColor!=that.prevSetting.curColor || that.tissues!=that.prevSetting.tissues){
					that.gsvg.setCurrentViewModified();
				}
			});
			buttonDiv.append("input").attr("type","button").attr("value","Cancel").style("float","right").style("margin-left","5px").on("click",function(){
				that.revertPrevious();
				that.draw(that.data);
				$('#trackSettingDialog').fadeOut("fast");
			});
		}else{
			var table=d3.select(topLevelSelector).select("table").select("tbody");
			table.append("tr").append("td").style("font-weight","bold").html("Track Settings: "+d.Name);
			table.append("tr").append("td").html("Sorry no settings for this track.");
			var buttonDiv=table.append("tr").append("td");
			buttonDiv.append("input").attr("type","button").attr("value","Remove Track").style("float","left").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
			});
			buttonDiv.append("input").attr("type","button").attr("value","Cancel").style("float","right").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
			});
		}
	};

	that.generateTrackSettingString=function(){
		var tissueStr="";
		for(var k=0;k<that.tissues.length;k++){
			if(k>0){
				tissueStr=tissueStr+":";
			}
			tissueStr=tissueStr+that.tissues[k];
			/*if(k<(that.tissues.length-1)){
				tissueStr=tissueStr+":";
			}*/
		}
		return that.trackClass+","+that.density+","+that.curColor+","+tissueStr+";";
	};
	
	that.draw(data);
	return that;
}
/*Track for displaying SNPs/Indels*/
function SNPTrack(gsvg,data,trackClass,density,additionalOptions){
	var that= Track(gsvg,data,trackClass,lbl);
	var strain=(new String(trackClass)).substr(3);
	var opts=new String(additionalOptions).split(",");
	if(opts.length>0){
		that.include=opts[0];
	}else{
		that.include=4;
	}
	that.density=density;
	var lbl=strain;
	if(lbl=="SHRH"){
		lbl="SHR/OlaPrin";
	}else if(lbl=="BNLX"){
		lbl="BN-Lx/CubPrin";
	}else if(lbl=="SHRJ"){
		lbl="SHR/NCrlPrin";
	}
	that.displayStrain=lbl;
	if(that.include==1){
		lbl=lbl+" SNPs";
	}else if(that.include==2){
		lbl=lbl+" Insertions";
	}else if(that.include==3){
		lbl=lbl+" Deletions";
	}else if(that.include==4){
		lbl=lbl+" SNPs/Indels";
	}
	that.counts=[{value:0,perc:0,names:"SNP "+that.displayStrain},{value:0,perc:0,names:"Insertion "+that.displayStrain},{value:0,perc:0,names:"Deletion "+that.displayStrain}];
	that.strain=strain;

	that.ttTrackList=new Array();
	that.ttTrackList.push("ensemblcoding");
	that.ttTrackList.push("braincoding");
	that.ttTrackList.push("liverTotal");
	that.ttTrackList.push("heartTotal");
	that.ttTrackList.push("refSeq");
	that.ttTrackList.push("ensemblnoncoding");
	that.ttTrackList.push("brainnoncoding");
	that.ttTrackList.push("ensemblsmallnc");
	that.ttTrackList.push("brainsmallnc");
	that.ttTrackList.push("probe");

	that.updateSettingsFromUI=function(){
		if($("#"+that.trackClass+"Dense"+that.level+"Select").length>0){
			that.density=$("#"+that.trackClass+"Dense"+that.level+"Select").val();
		}
		if($("#"+that.trackClass+that.level+"Select").length>0){
			that.include=$("#"+that.trackClass+that.level+"Select").val();
		}
	};

	that.savePrevious=function(){
		that.prevSetting={};
		that.prevSetting.density=that.density;
		that.prevSetting.include=that.include;
	};
	
	that.revertPrevious=function(){
		that.density=that.prevSetting.density;
		that.include=that.prevSetting.include;
	};

	that.generateTrackSettingString=function(){
		return that.trackClass+","+that.density+","+that.include+";";
	};

	that.generateSettingsDiv=function(topLevelSelector){
		var d=trackInfo[that.trackClass];
		that.savePrevious();
		//console.log(trackInfo);
		//console.log(d);
		d3.select(topLevelSelector).select("table").select("tbody").html("");
		if(d.Controls.length>0 && d.Controls!="null"){
			var controls=new String(d.Controls).split(",");
			var table=d3.select(topLevelSelector).select("table").select("tbody");
			table.append("tr").append("td").style("font-weight","bold").html("Track Settings: "+d.Name);
			for(var c=0;c<controls.length;c++){
				if(controls[c]!=undefined && controls[c]!=""){
					var params=controls[c].split(";");
					var div=table.append("tr").append("td");
					var lbl=params[0].substr(5);
					div.append("text").text(lbl+": ");
					var def="";
					if(params.length>3  && params[3].indexOf("Default=")==0){
						def=params[3].substr(8);
					}
					if(params[1].toLowerCase().indexOf("select")==0){
						var selClass=params[1].split(":");
						var opts=params[2].split("}");
						var prefix="";
						var suffix="";
						if(selClass.length>2){
							prefix=selClass[2];
						}
						if(selClass.length>3){
							suffix=selClass[3];
						}
						var sel=div.append("select").attr("id",that.trackClass+prefix+that.level+suffix)
							.attr("name",selClass[1]);
						for(var o=0;o<opts.length;o++){
							var option=opts[o].substr(1).split(":");
							if(option.length==2){
								var tmpOpt=sel.append("option").attr("value",option[1]).text(option[0]);
								if((prefix=="Dense"&&option[1]==that.density)||
									(prefix==""&&option[1]==that.include)){
									tmpOpt.attr("selected","selected");
								}
							}
						}
						//console.log("#"+that.trackClass+prefix+that.level+suffix);
						d3.select("#"+that.trackClass+prefix+that.level+suffix).on("change", function(){
							that.updateSettingsFromUI();
							that.updateData();
						});
					}else {
						console.log("Undefined track settings:  "+controls[c]);
					}
				}
			}
			var buttonDiv=table.append("tr").append("td");
			buttonDiv.append("input").attr("type","button").attr("value","Remove Track").style("float","left").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
				that.gsvg.removeTrack(that.trackClass);
			});
			buttonDiv.append("input").attr("type","button").attr("value","Apply").style("float","right").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
				if(that.density!=that.prevSetting.density || that.include!=that.prevSetting.include){
					that.gsvg.setCurrentViewModified();
				}
			});
			buttonDiv.append("input").attr("type","button").attr("value","Cancel").style("float","right").style("margin-left","5px").on("click",function(){
				that.revertPrevious();
				that.draw(that.data);
				$('#trackSettingDialog').fadeOut("fast");
			});
		}else{
			var table=d3.select(topLevelSelector).select("table").select("tbody");
			table.append("tr").append("td").style("font-weight","bold").html("Track Settings: "+d.Name);
			table.append("tr").append("td").html("Sorry no settings for this track.");
			var buttonDiv=table.append("tr").append("td");
			buttonDiv.append("input").attr("type","button").attr("value","Remove Track").style("float","left").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
			});
			buttonDiv.append("input").attr("type","button").attr("value","Cancel").style("float","right").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
			});
		}
	};

	that.redraw=function (){

		/*that.density=$("#snp"+strain+"Dense"+that.gsvg.levelNumber+"Select").val();
		that.include=$("#snp"+strain+that.gsvg.levelNumber+"Select").val();
		if(that.density==null || that.density==undefined){
			that.density=1;
		}*/
		for(var j=0;j<that.yArr.length;j++){
			that.yArr[j]=-299999999;
		}
		d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.snp")
				.attr("transform",function (d,i){
										var st=that.xScale(d.getAttribute("start"));
										return "translate("+st+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i,2)+")";
										});
		d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.snp rect")
								.attr("width",function(d) {
								   var wX=1;
								   if(that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"))>1){
									   wX=that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"));
								   }
								   return wX;
								 });
		if(that.xScale(that.xScale.domain()[0]+1)>6){
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass)
				.selectAll(".snp").each(function(d){
						var wX=that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"));
						var str=new String(d.getAttribute("strainSeq"));
						var font="8px";
						var fW=3.2;
						var fY=8;
						if(d.getAttribute("type")!="SNP"){
							font="7px";
							fW=3;
							fY=7;
						}
						if(d3.select(this).selectAll("text").size()==0 && (str.length*fW)<wX){
							
							d3.select(this).append("text")
							.attr("y",fY)
							.attr("x",function(d){
								var x=0;
								if(wX>7){
									x=(wX/2)-(str.length/2*fW);
								}
								return x;
							})
							.attr("font-size",font)
							.attr("stroke",d3.rgb("#FFFFFF"))
							.attr("class","snpLbl")
							.text(str);
						}else{
							d3.select(this).selectAll(".snpLbl")
								.attr("x",function(d){
											var x=0;
											if(wX>7){
												x=(wX/2)-(str.length/2*fW);
											}
											return x;
								});
						}
					});
		}else{
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass)
				.selectAll("text.snpLbl").remove();
		}

		if(that.density==1){
			that.svg.attr("height", 30);
		}else if(that.density==2){
			that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.snp").length+1)*15);
		}else if(that.density==3){
			var tmpYMax=-1;
			for(var j=0;j<that.yArr.length&&tmpYMax==-1;j++){
				if(that.yArr[j]==-299999999){
					that.svg.attr("height", (j+1)*15);
					tmpYMax=j;
				}
			}
		}
		that.redrawSelectedArea();
	};

	that.calcY=function (start,end,i,spacing){
		var tmpY=-299999999;
		var found=false;
		if(that.density==1){
			tmpY=15;
		}else if(that.density==2){
			tmpY=(i+1)*15;
		}else{
			var found=false;
			var count=0;
			var startAt=0;
			while(!found && count<3){
				for (var iy=startAt;iy<that.yArr.length&&!found;iy++){
						if((that.yArr[iy]+spacing)<that.xScale(start)){
							found=true;
							tmpY=(iy+1)*15;
							if(that.xScale(end)>that.yArr[iy]){
								that.yArr[iy]=that.xScale(end);
								found=true;
							}
						}
				}
				if(!found){
					count++;
					startAt=that.yArr.length;
					for(var n=0;n<50;n++){
						that.yArr.push(-299999999);
					}
				}
			}
			if(!found){
				tmpY=(that.YArr.length+1)*15;
			}
		}
		return tmpY;
	};

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
	};

	that.getDisplayID=function(d){
		return d.getAttribute("type")+"_"+d.getAttribute("ID");
	}
	that.createToolTip=function (d){
		var tooltip="";
		var strain=d.getAttribute("strain");
		if(strain=="SHRH"){
			strain="SHR";
		}
		tooltip="<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div><BR>Type: "+d.getAttribute("type")+"<BR>Strain: "+strain+"<BR>Sequence: "+d.getAttribute("refSeq")+"->"+d.getAttribute("strainSeq")+"<BR>Location: chr"+d.getAttribute("chromosome")+":"+numberWithCommas(d.getAttribute("start"));
		if(d.getAttribute("type")=="SNP"){

		}else{
			tooltip=tooltip+"-"+numberWithCommas((d.getAttribute("stop")));
		}
		return tooltip;
	};

	that.update=function (d){
		that.redraw();
	};
	
	that.updateData = function(retry){
		var tag="Snp";
		var path=dataPrefix+"tmpData/regionData/"+that.gsvg.folderName+"/snp"+that.strain+".xml";
		/*that.include=$("#"+that.trackClass+that.gsvg.levelNumber+"Select").val();
		that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").val();*/
		d3.xml(path,function (error,d){
				if(error){
					if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								that.updateData(retry+1);
							},time);
					}else if(retry>=3){
							d3.select("#Level"+that.levelNumber+that.trackClass).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+that.trackClass).attr("height", 15);
							that.gsvg.addTrackErrorRemove(that.svg,"#Level"+that.gsvg.levelNumber+that.trackClass);
					}
				}else{
						var snp=d.documentElement.getElementsByTagName(tag);
						var mergeddata=new Array();
						var checkName=new Array();
						var curInd=0;
						for(var l=0;l<snp.length;l++){
							if(snp[l]!=undefined ){
								mergeddata[curInd]=snp[l];
								checkName[snp[l].getAttribute("ID")]=1;
								curInd++;
							}
						}
						for(var l=0;l<that.data.length;l++){
							if(that.data[l]!=undefined && checkName[that.data[l].getAttribute("ID")]==undefined){
								mergeddata[curInd]=that.data[l];
								curInd++;
							}
						}
						that.draw(mergeddata);
						that.hideLoading();
					}
			});
	};

	that.getDisplayedData= function (){
		var dataElem=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".snp");
		//that.counts=[{value:0,perc:0,names:"SNP "+that.displayStrain},{value:0,perc:0,names:"Insertion "+that.displayStrain},{value:0,perc:0,names:"Deletion "+that.displayStrain}];
		that.counts=[{value:0,perc:0,names:"SNP"},{value:0,perc:0,names:"Insertion"},{value:0,perc:0,names:"Deletion"}];
		var tmpDat=dataElem[0];
		var dispData=new Array();
		var dispDataCount=0;
		var total=0;
		if(tmpDat!=undefined){
		for(var l=0;l<tmpDat.length;l++){
			if(tmpDat[l].__data__!=undefined){
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
		}
		}
		/*for(var l=0;l<that.counts.length;l++){
			that.counts[l].perc=Math.round(that.counts[l].value/total*100);
		}*/
		//console.log(that.counts);
		return dispData;
	};

	that.draw= function (data){
		
		that.data=data;
		for(var j=0;j<that.yArr.length;j++){
				that.yArr[j]=-299999999;
		}

		var lbl=that.strain;
		if(lbl=="SHRH"){
			lbl="SHR/OlaPrin";
		}else if(lbl=="BNLX"){
			lbl="BN-Lx/CubPrin";
		}else if(lbl=="SHRJ"){
			lbl="SHR/NCrlPrin";
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
			//.style("cursor", "pointer")
			//.on("mousedown", setupTranscripts)
			.on("mouseover", function(d) { 
				if(that.gsvg.isToolTip==0){ 
					d3.select(this).style("fill","green");
		            tt.transition()        
		                .duration(200)      
		                .style("opacity", 1);      
		            tt.html(that.createToolTip(d))  
		                .style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
						.style("top", function(){return that.positionTTTop(d3.event.pageY);});
		                that.setupToolTipSVG(d,0.2);
		        }
	        })
			.on("mouseout", function(d) {  
				d3.select(this).style("fill",that.color);
	            tt.transition()
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
		that.redrawSelectedArea();
	};

	that.pieColor =function(d,i){
		var color=d3.rgb("#000000");
		var tmpName=new String(d.data.names);
		//console.log(d.data.names);
		//console.log(tmpName);
		if(that.strain=="BNLX"){
			if(tmpName.indexOf("SNP")>-1){
				color=d3.rgb(0,0,255);
			}else if(tmpName.indexOf("Insertion")>-1){
				color=d3.rgb(0,0,175);
			}else{
				color=d3.rgb(0,0,125);
			}
		}else if(that.strain=="SHRJ"){
			if(tmpName.indexOf("SNP")>-1){
				color=d3.rgb(0,255,0);
			}else if(tmpName.indexOf("Insertion")>-1){
				color=d3.rgb(0,175,00);
			}else{
				color=d3.rgb(0,125,00);
			}
		}else if(that.strain=="F344"){
			if(tmpName.indexOf("SNP")>-1){
				color=d3.rgb(0,255,255);
			}else if(tmpName.indexOf("Insertion")>-1){
				color=d3.rgb(0,175,175);
			}else{
				color=d3.rgb(0,125,125);
			}
		}else if(that.strain=="SHRH"){
			if(tmpName.indexOf("SNP")>-1){
				color=d3.rgb(255,0,0);
			}else if(tmpName.indexOf("Insertion")>-1){
				color=d3.rgb(175,0,0);
			}else{
				color=d3.rgb(125,0,0);
			}
		}
		return color;
	};


	that.redrawLegend=function (){
		var legend=[];
		if(that.include==4){
			if(that.strain=="BNLX"){
				legend=[{color:"#0000FF",label:"SNP"},{color:"#000096",label:"Insertion/Deletion"}];
			}else if(that.strain=="SHRH"){
				legend=[{color:"#FF0000",label:"SNP"},{color:"#960000",label:"Insertion/Deletion"}];
			}else if(that.strain=="SHRJ"){
				legend=[{color:"#00FF00",label:"SNP"},{color:"#009600",label:"Insertion/Deletion"}];
			}else if(that.strain=="F344"){
				legend=[{color:"#00FFFF",label:"SNP"},{color:"#009696",label:"Insertion/Deletion"}];
			}else{
				legend=[{color:"#DEDEDE",label:"SNP"},{color:"#969696",label:"Insertion/Deletion"}];
			}
		}else if(that.include==3 || that.include==2){
			if(that.strain=="BNLX"){
				legend=[{color:"#000096",label:"Insertion/Deletion"}];
			}else if(that.strain=="SHRH"){
				legend=[{color:"#960000",label:"Insertion/Deletion"}];
			}else if(that.strain=="SHRJ"){
				legend=[{color:"#009600",label:"Insertion/Deletion"}];
			}else if(that.strain=="F344"){
				legend=[{color:"#009696",label:"Insertion/Deletion"}];
			}else{
				legend=[{color:"#969696",label:"Insertion/Deletion"}];
			}
		}else if(that.include==1){
			if(that.strain=="BNLX"){
				legend=[{color:"#0000FF",label:"SNP"}];
			}else if(that.strain=="SHRH"){
				legend=[{color:"#FF0000",label:"SNP"}];
			}else if(that.strain=="SHRJ"){
				legend=[{color:"#00FF00",label:"SNP"}];
			}else if(that.strain=="F344"){
				legend=[{color:"#00FFFF",label:"SNP"}];
			}else{
				legend=[{color:"#DEDEDE",label:"SNP"}];
			}
		}
		that.drawLegend(legend);
	};

	that.strain=strain;

	that.redrawLegend();
	that.draw(data);	
	
	return that;
}
/*Track for displaying QTLs*/
function QTLTrack(gsvg,data,trackClass,density){
	var that= Track(gsvg,data,trackClass,"QTLs Overlapping Region");
	
	that.color= function (name){
		return that.pieColorPalette(name);
	};

	that.redraw= function (){
		
		//var qtlSvg=d3.select("#"+level+"qtl");
		var density=2;
		that.yCount=0;
		//var tmpYArr=new Array();
		that.idList=new Array();
		
		var qtls=that.svg//d3.select("#"+level+"qtl")
						.selectAll("g.qtl")
						.attr("transform",function (d,i){
								var st=that.xScale(d.getAttribute("start"));
								return "translate("+st+","+that.calcY(d,i)+")";
						});
		d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.qtl rect")
						.attr("width",function(d) {
								var wX=1;
								if(that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"))>1){
									wX=that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"));
								}
								return wX;
						});

		/*var qtl=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass)
										.selectAll(".qtl");*/
		/*qtls[0].forEach(function(d){
				var nameStr=d.__data__.getAttribute("name");
				var end=nameStr.indexOf("QTL")-1;
				var name=nameStr.substr(0,end);
				d3.select(d).select("rect").style("fill",that.color(name));
		});*/
		that.svg.attr("height", that.yCount*15);
		that.redrawSelectedArea();
	};

	that.createToolTip=function (d){
		var tooltip="";
		tooltip="Name: "+d.getAttribute("name")+"<BR>Location: "+d.getAttribute("chromosome")+":"+numberWithCommas(d.getAttribute("start"))+"-"+numberWithCommas(d.getAttribute("stop"))+"<BR>Trait:<BR>"+d.getAttribute("trait")+"<BR><BR>Phenotype:<BR>"+d.getAttribute("phenotype")+"<BR><BR>Candidate Genes:<BR>"+d.getAttribute("candidate");
		return tooltip;
	};

	that.pieColorPalette=d3.scale.category20();

	//For Reports and Pie Chart
	that.pieColor=function (d){
		return that.pieColorPalette(d.data.names);
	};
	that.triggerTableFilter=function(d){
		var e = jQuery.Event("keyup");
		e.which = 32; // # Some key code value
		var filterStr="";
		if(d.getAttribute==undefined || d.getAttribute("ID")==undefined){
			if(d.data!=undefined&& d.data.names!=undefined){
				filterStr=d.data.names;
			}
		}else{//represents a track feature
			filterStr=d.getAttribute("ID");
		}
		$('#tblBQTL_filter input').val(filterStr).trigger(e);
	};
	that.clearTableFilter=function(d){
		var e = jQuery.Event("keyup");
		e.which = 32; // # Some key code value
		$('#tblBQTL_filter input').val("").trigger(e);
	};
	
	that.getDisplayedData= function (){
		var dataElem=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".qtl");
		that.counts=new Array();
		var countsInd=0;
		var tmpDat=dataElem[0];
		var dispData=new Array();
		var dispDataCount=0;
		var total=0;
		if(tmpDat!=undefined){
		for(var l=0;l<tmpDat.length;l++){
			var start=that.xScale(tmpDat[l].__data__.getAttribute("start"));
			var stop=that.xScale(tmpDat[l].__data__.getAttribute("stop"));
			if((0<=start && start<=that.gsvg.width)||(0<=stop &&stop<=that.gsvg.width)||(start<=0&&stop>=that.gsvg.width)){
				var nameStr=new String(tmpDat[l].__data__.getAttribute("name"));
				var re = /[0-9]+\s*$/g;
				var end1=nameStr.search(re);
				if(end1>-1){
					nameStr=nameStr.substr(0,end1);
				}
				re = /QTL\s*$/g;
				end1=nameStr.search(re);
				if(end1>-1){
					nameStr=nameStr.substr(0,end1);
				}
				re = /traits+\s*$/g;
				end1=nameStr.search(re);
				if(end1>-1){
					nameStr=nameStr.substr(0,end1+5);
				}
				var name=nameStr;
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
		}
		return dispData;
	};

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
				var jspPage= pathPrefix +"bQTLReport.jsp";
				var params={id: d.getAttribute("ID"),species: organism};
				DisplaySelectedDetailReport(jspPage,params);
			
	};

	that.updateData= function(retry){
		d3.xml(dataPrefix+"tmpData/regionData/"+that.gsvg.folderName+"/qtl.xml",function (error,d){
					if(error){
						if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								that.updateDate(retry+1);
							},time);
						}else {
							d3.select("#Level"+that.levelNumber+that.trackClass).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+that.trackClass).attr("height", 15);
							that.gsvg.addTrackErrorRemove(that.svg,"#Level"+that.gsvg.levelNumber+that.trackClass);
						}
					}else{
						var qtl=d.documentElement.getElementsByTagName("QTL");
						var mergeddata=new Array();
						var checkName=new Array();
						var curInd=0;

						for(var l=0;l<qtl.length;l++){
							if(qtl[l]!=undefined ){
								mergeddata[curInd]=qtl[l];
								checkName[qtl[l].getAttribute("ID")]=1;
								curInd++;
							}
						}
						for(var l=0;l<that.data.length;l++){
							if(that.data[l]!=undefined && checkName[that.data[l].getAttribute("ID")]==undefined){
								mergeddata[curInd]=that.data[l];
								curInd++;
							}
						}
						that.draw(mergeddata);
						that.hideLoading();
					}
				});
	};

	that.calcY=function(d,i){
		var ret=0;
		if(typeof that.idList[d.getAttribute("ID")] === "undefined"){
			ret=that.yCount++;
		}
		return (ret+1)*15;
	}
	that.draw=function(data){
		
		that.data=data;
		that.yCount=0;
		that.idList=new Array();
		//update
		that.svg.selectAll(".qtl").remove();
		var qtls=that.svg.selectAll(".qtl")
	   			.data(data,key)
				.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d,i)+")";});
						
		//add new
		qtls.enter().append("g")
				.attr("class","qtl")
				.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d,i)+")";})
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
			.attr("id",function(d){return d.getAttribute("id");})
			.style("fill","blue")
			.style("cursor", "pointer")
			//.on("mouseover", that.onMouseOver)
			//.on("mouseout", that.onMouseOut);
			.on("click", that.setupDetailedView)
			.on("mouseover", function(d) { 
				if(that.gsvg.isToolTip==0){ 
					overSelectable=1;
					$("#mouseHelp").html("<B>Click</B> to see additional details. <B>Double Click</B> to zoom in on this feature.");
					d3.select(this).style("fill","green");
		            tt.transition()        
		                .duration(200)      
		                .style("opacity", 1);      
		            tt.html(that.createToolTip(d))  
		                .style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
						.style("top", function(){return that.positionTTTop(d3.event.pageY);});
		            that.triggerTableFilter(d);
		        }
	        })
			.on("mouseout", function(d) {
				overSelectable=0;
				$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
				var nameStr=d.getAttribute("name");
				var re = /[0-9]+\s*$/g;
				var end1=nameStr.search(re);
				if(end1>-1){
					nameStr=nameStr.substr(0,end1);
				}
				re = /QTL\s*$/g;
				end1=nameStr.search(re);
				if(end1>-1){
					nameStr=nameStr.substr(0,end1);
				}
				re = /traits?\s*$/g;
				end1=nameStr.search(re);
				if(end1>-1){
					nameStr=nameStr.substr(0,end1+5);
				}
				var name=nameStr;
				d3.select(this).style("fill",that.color(name));
	            tt.transition()
					 .delay(500)       
	                .duration(200)      
	                .style("opacity", 0);  
	            that.clearTableFilter(d);
	        });

		qtls.exit().remove();


		if(qtls[0]!=undefined){
			qtls[0].forEach(function(d){
				if(d!=undefined){
					var nameStr=new String(d.__data__.getAttribute("name"));
					var re = /[0-9]+\s*$/g;
					var end1=nameStr.search(re);
					if(end1>-1){
						nameStr=nameStr.substr(0,end1);
					}
					re = /QTL\s*$/g;
					end1=nameStr.search(re);
					if(end1>-1){
						nameStr=nameStr.substr(0,end1);
					}
					re = /traits?\s*$/g;
					end1=nameStr.search(re);
					if(end1>-1){
						nameStr=nameStr.substr(0,end1+5);
					}
					var name=nameStr;
					d3.select(d).select("rect").style("fill",that.color(name));
				}
			});
		}
		that.svg.attr("height", that.yCount*15);
		//that.getDisplayedData();
		that.redrawSelectedArea();
	};
	that.draw(data);
	that.redraw();
	return that;
}
/*Track to display transcripts for a selected Gene*/
function TranscriptTrack(gsvg,data,trackClass,density){
	var that= Track(gsvg,data,trackClass,"Selected Gene Transcripts");

	that.createToolTip= function(d){
		var tooltip="";
		var strand=".";
		if(d.getAttribute("strand") == 1){
			strand="+";
		}else if(d.getAttribute("strand")==-1){
			strand="-";
		}
		var id=d.getAttribute("ID");
		tooltip="ID: "+id+"<BR>Location: chr"+d.getAttribute("chromosome")+":"+numberWithCommas(d.getAttribute("start"))+"-"+numberWithCommas(d.getAttribute("stop"))+"<BR>Strand: "+strand;
		if(new String(d.getAttribute("ID")).indexOf("ENS")==-1){
				var annot=getFirstChildByName(getFirstChildByName(d,"annotationList"),"annotation");
				if(annot!=null){
					tooltip+="<BR>Matching: "+annot.getAttribute("reason");
				}
		}
		return tooltip;
	};

	that.color= function (d){
		var color=d3.rgb("#000000");
		if(that.gsvg.txType=="protein"){
			if((new String(d.getAttribute("ID"))).indexOf("ENS")>-1){
				color=d3.rgb("#DFC184");
			}else{
				color=d3.rgb("#7EB5D6");
			}
		}else if(that.gsvg.txType=="long"){
			if((new String(d.getAttribute("ID"))).indexOf("ENS")>-1){
				color=d3.rgb("#B58AA5");
			}else{
				color=d3.rgb("#CECFCE");
			}
		}else if(that.gsvg.txType=="small"){
			if((new String(d.getAttribute("ID"))).indexOf("ENS")>-1){
				color=d3.rgb("#FFCC00");
			}else{
				color=d3.rgb("#99CC99");
			}
		}else if(that.gsvg.txType=="liverTotal"){
			color=d3.rgb("#bbbedd");
		}else if(that.gsvg.txType=="heartTotal"){
			color=d3.rgb("#DC7252");
		}
		return color;
	};

	that.drawTrx=function (d,i){
		var cdsStart=d.getAttribute("start");
		var cdsStop=d.getAttribute("stop");
		if(d.getAttribute("cdsStart")!=undefined && d.getAttribute("cdsStop")!=undefined){
			cdsStart=d.getAttribute("cdsStart");
			cdsStop=d.getAttribute("cdsStop");
		}

		var txG=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" #tx"+d.getAttribute("ID"));
		exList=getAllChildrenByName(getFirstChildByName(d,"exonList"),"exon");
		for(var m=0;m<exList.length;m++){
			var exStrt=exList[m].getAttribute("start");
			var exStp=exList[m].getAttribute("stop");
			if((exStrt<cdsStart&&cdsStart<exStp)||(exStp>cdsStop&&cdsStop>exStrt)){//need to draw two rect one for CDS and one non CDS
				var xPos1=0;
				var xWidth1=0;
				var xPos2=0;
				var xWidth2=0;
				if(exStrt<cdsStart){
					xPos1=that.xScale(exList[m].getAttribute("start"));
					xWidth1=that.xScale(cdsStart) - that.xScale(exList[m].getAttribute("start"));
					xPos2=that.xScale(cdsStart);
					xWidth2=that.xScale(exList[m].getAttribute("stop")) - that.xScale(cdsStart);
				}else if(exStp>cdsStop){
					xPos2=that.xScale(exList[m].getAttribute("start"));
					xWidth2=that.xScale(cdsStop) - that.xScale(exList[m].getAttribute("start"));
					xPos1=that.xScale(cdsStop);
					xWidth1=that.xScale(exList[m].getAttribute("stop")) - that.xScale(cdsStop);
				}
				txG.append("rect")//non CDS
					.attr("x",xPos1)
					.attr("y",2.5)
			    	.attr("height",5)
			    	.attr("width",xWidth1)
					.attr("title",function(d){ return exList[m].getAttribute("ID");})
					.attr("id",function(d){return "ExNC"+exList[m].getAttribute("ID");})
					.style("fill",that.color)
					.style("cursor", "pointer");
				txG.append("rect")//CDS
						.attr("x",xPos2)
				    	.attr("height",10)
				    	.attr("width",xWidth2)
						.attr("title",function(d){ return exList[m].getAttribute("ID");})
						.attr("id",function(d){return "Ex"+exList[m].getAttribute("ID");})
						.style("fill",that.color)
						.style("cursor", "pointer");
				
			}else{
				var height=10;
				var y=0;
				if((exStrt<cdsStart&&exStp<cdsStart)||(exStp>cdsStop&&exStrt>cdsStop)){
					height=5;
					y=2.5;
				}
				txG.append("rect")
					.attr("x",function(d){ return that.xScale(exList[m].getAttribute("start")); })
					.attr("y",y)
					//.attr("rx",1)
					//.attr("ry",1)
			    	.attr("height",height)
					.attr("width",function(d){ return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start")); })
					.attr("title",function(d){ return exList[m].getAttribute("ID");})
					.attr("id",function(d){return "Ex"+exList[m].getAttribute("ID");})
					.style("fill",that.color)
					.style("cursor", "pointer");
			}
			/*txG.append("rect")
			.attr("x",function(d){ return that.xScale(exList[m].getAttribute("start")); })
			.attr("rx",1)
			.attr("ry",1)
	    	.attr("height",10)
			.attr("width",function(d){ return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start")); })
			.attr("title",function(d){ return exList[m].getAttribute("ID");})
			.attr("id",function(d){return "Ex"+exList[m].getAttribute("ID");})
			.style("fill",that.color)
			.style("cursor", "pointer");*/
			if(m>0){
				txG.append("line")
				.attr("x1",function(d){ return that.xScale(exList[m-1].getAttribute("stop")); })
				.attr("x2",function(d){ return that.xScale(exList[m].getAttribute("start")); })
				.attr("y1",5)
				.attr("y2",5)
				.attr("id",function(d){ return "Int"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID");})
				.attr("stroke",that.color)
				.attr("stroke-width","2");
				var strChar=">";
				if(d.getAttribute("strand")=="-1"){
					strChar="<";
				}
				var fullChar=strChar;
				var intStart=that.xScale(exList[m-1].getAttribute("stop"));
				var intStop=that.xScale(exList[m].getAttribute("start"));
				var rectW=intStop-intStart;
				var alt=0;
				var charW=6.5;
				if(rectW<charW){
						fullChar="";
				}else{
					rectW=rectW-charW;
					while(rectW>(charW+1)){
						if(alt==0){
							fullChar=fullChar+" ";
							alt=1;
						}else{
							fullChar=fullChar+strChar;
							alt=0;
						}
						rectW=rectW-charW;
					}
				}
				txG.append("svg:text").attr("id",function(d){ return "IntTxt"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID");}).attr("dx",intStart+1)
					.attr("dy","11")
					.style("pointer-events","none")
					.style("opacity","0.5")
					.style("fill",that.color)
					.style("font-size","16px")
					.text(fullChar);
				
			}
		}
		
	};

	that.redraw = function (){
		
		var txG=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.trx"+that.gsvg.levelNumber);
		//var txG=that.svg.selectAll("g.trx"+that.gsvg.levelNumber);
		
		txG//.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
			.each(function(d,i){
				var cdsStart=d.getAttribute("start");
				var cdsStop=d.getAttribute("stop");
				if(d.getAttribute("cdsStart")!=undefined&&d.getAttribute("cdsStop")!=undefined){
					cdsStart=d.getAttribute("cdsStart");
					cdsStop=d.getAttribute("cdsStop");
				}
				exList=getAllChildrenByName(getFirstChildByName(d,"exonList"),"exon");
				var pref="tx";
				for(var m=0;m<exList.length;m++){
					var exStrt=exList[m].getAttribute("start");
					var exStp=exList[m].getAttribute("stop");
					if((exStrt<cdsStart&&cdsStart<exStp)||(exStp>cdsStop&&cdsStop>exStrt)){
						var ncStrt=exStrt;
						var ncStp=cdsStart;
						if(exStp>cdsStop){
							ncStrt=cdsStop;
							ncStp=exStp;
							exStrt=exStrt;
							exStp=cdsStop;
						}else{
							exStrt=cdsStart;
							exStp=exStp;
						}
						d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" g#"+pref+d.getAttribute("ID")+" rect#ExNC"+exList[m].getAttribute("ID"))
							.attr("x",function(d){ return that.xScale(ncStrt); })
							.attr("width",function(d){ return that.xScale(ncStp) - that.xScale(ncStrt); });
					}
					d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" g#"+pref+d.getAttribute("ID")+" rect#Ex"+exList[m].getAttribute("ID"))
						.attr("x",function(d){ return that.xScale(exStrt); })
						.attr("width",function(d){ return that.xScale(exStp) - that.xScale(exStrt); });
					if(m>0){
						var strChar=">";
						if(d.getAttribute("strand")=="-1"){
							strChar="<";
						}
						var fullChar=strChar;
						var intStart=that.xScale(exList[m-1].getAttribute("stop"));
						var intStop=that.xScale(exList[m].getAttribute("start"));
						var rectW=intStop-intStart;
						var alt=0;
						var charW=6.5;
						if(rectW<charW){
								fullChar="";
						}else{
							rectW=rectW-charW;
							while(rectW>(charW+1)){
								if(alt==0){
									fullChar=fullChar+" ";
									alt=1;
								}else{
									fullChar=fullChar+strChar;
									alt=0;
								}
								rectW=rectW-charW;
							}
						}
						d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" g#tx"+d.getAttribute("ID")+" line#Int"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID"))
							.attr("x1",intStart)
							.attr("x2",intStop);

						d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" g#tx"+d.getAttribute("ID")+" #IntTxt"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID"))
							.attr("dx",intStart+1).text(fullChar);
					}
				}
			});
		that.redrawSelectedArea();
	};

	that.update = function(){
		var txList=getAllChildrenByName(getFirstChildByName(that.gsvg.selectedData,"TranscriptList"),"Transcript");
		var min=that.gsvg.selectedData.getAttribute("start");
		var max=that.gsvg.selectedData.getAttribute("stop");
		if(that.gsvg.selectedData.getAttribute("extStart")!=undefined&&that.gsvg.selectedData.getAttribute("extStop")!=undefined){
			min=that.gsvg.selectedData.getAttribute("extStart");
			max=that.gsvg.selectedData.getAttribute("extStop");
		}
		that.txMin=min;
		that.txMax=max;
		that.svg.attr("height", (1+txList.length)*15);
		d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".trx"+that.gsvg.levelNumber).remove();
		var tx=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".trx"+that.gsvg.levelNumber)
	   			.data(txList,key)
				.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d,i)+")";});
				
	  	tx.enter().append("g")
				.attr("class","trx"+that.gsvg.levelNumber)
				//.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
				.attr("transform",function(d,i){ return "translate(0,"+that.calcY(d,i)+")";})
				.attr("id",function(d){return d.getAttribute("ID");})
				.attr("pointer-events", "all")
				.style("cursor", "pointer")
				.on("mouseover", function(d) { 
						if(that.gsvg.isToolTip==0){ 
							d3.select(this).selectAll("line").style("stroke","green");
							d3.select(this).selectAll("rect").style("fill","green");
							d3.select(this).selectAll("text").style("opacity","0.3").style("fill","green");
	            			tt.transition()        
								.duration(200)      
								.style("opacity", 1);      
							tt.html(that.createToolTip(d))  
								.style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
								.style("top", function(){return that.positionTTTop(d3.event.pageY);});
						}
	            	})
				.on("mouseout", function(d) {
						d3.select(this).selectAll("line").style("stroke",that.color);
						d3.select(this).selectAll("rect").style("fill",that.color);  
						d3.select(this).selectAll("text").style("opacity","0.6").style("fill",that.color);
						tt.transition()
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
		}else if(that.gsvg.txType=="liverTotal"){
			legend=[{color:"#bbbedd",label:"Liver RNA-Seq"}];
		}
		that.drawLegend(legend);
	};

	that.calcY=function(d,i){
		return (i+1)*15;
	}

	that.redrawLegend=function (){
		/*var legend=[];
		var curPos=0;
		if(that.gsvg.txType!="liverTotal"){
			if(that.gsvg.txType=="protein"){
				legend[curPos]={color:"#DFC184",label:"Ensembl"};
			}else if(that.gsvg.txType=="long"){
				legend[curPos]={color:"#B58AA5",label:"Ensembl"};
			}else if(that.gsvg.txType=="small"){
				legend[curPos]={color:"#FFCC00",label:"Ensembl"};
			}
			curPos++;

			if(organism=="Rn"){
				if(that.gsvg.txType=="protein"){
					legend[curPos]={color:"#7EB5D6",label:"Brain RNA-Seq"};
				}else if(that.gsvg.txType=="long"){
					legend[curPos]={color:"#CECFCE",label:"Brain RNA-Seq"};
				}else if(that.gsvg.txType=="small"){
					legend[curPos]={color:"#99CC99",label:"Brain RNA-Seq"};
				}
				curPos++;
			}
		}else if(that.gsvg.txType=="liverTotal"){
			legend[curPos]={color:"#bbbedd",label:"Liver RNA-Seq"};
			curPos++;
		}
		that.drawLegend(legend);*/
	};
	if(that.gsvg.selectedData.getAttribute("extStart")!=undefined){
		that.txMin=that.gsvg.selectedData.getAttribute("extStart");
		that.txMax=that.gsvg.selectedData.getAttribute("extStop");
	}else{
		that.txMin=that.gsvg.selectedData.getAttribute("start");
		that.txMax=that.gsvg.selectedData.getAttribute("stop");
	}
	d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).attr("height", (1+data.length)*15);
	d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".trx"+that.gsvg.levelNumber).remove();
	var tx=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".trx"+that.gsvg.levelNumber)
   			.data(data,key)
			.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d,i)+")";});
			
  	tx.enter().append("g")
			.attr("class","trx"+that.gsvg.levelNumber)
			//.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
			.attr("transform",function(d,i){ return "translate(0,"+that.calcY(d,i)+")";})
			.attr("id",function(d){return "tx"+d.getAttribute("ID");})
			.attr("pointer-events", "all")
			.style("cursor", "pointer")
			.on("mouseover", function(d) {
					if(that.gsvg.isToolTip==0){ 
						d3.select(this).selectAll("line").style("stroke","green");
						d3.select(this).selectAll("rect").style("fill","green");
						d3.select(this).selectAll("text").style("opacity","0.3").style("fill","green");
            			tt.transition()        
							.duration(200)      
							.style("opacity", 1);      
						tt.html(that.createToolTip(d))  
							.style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
							.style("top", function(){return that.positionTTTop(d3.event.pageY);});
					}
            	})
			.on("mouseout", function(d) {
					d3.select(this).selectAll("line").style("stroke",that.color);
					d3.select(this).selectAll("rect").style("fill",that.color);
					d3.select(this).selectAll("text").style("opacity","0.6").style("fill",that.color);  
					tt.transition()
						 .delay(500)       
						.duration(200)      
						.style("opacity", 0);  
        		})
			.each(that.drawTrx);
	
	
	 tx.exit().remove();
	that.redrawLegend();
	 that.scaleSVG.transition()        
				.duration(300)      
				.style("opacity", 1);
	 that.svg.transition()        
				.duration(300)      
				.style("opacity", 1);
	that.redraw();
	return that;
}
/* Setup specific count tracks*/
function HelicosTrack(gsvg,data,trackClass,density){
	var that= CountTrack(gsvg,data,trackClass,density);
	that.graphColorText="#DD0000";
	var lbl="Brain Helicos RNA Read Counts";
	that.updateLabel(lbl);
	that.redrawLegend();
	that.redraw();
	return that;
}
function IlluminaSmallTrack(gsvg,data,trackClass,density){
	var that= CountTrack(gsvg,data,trackClass,density);
	that.graphColorText="#99CC99";
	var lbl="Brain Illumina Small RNA Read Counts";
	that.updateLabel(lbl);
	that.redrawLegend();that.redraw();
	that.redraw();
	return that;
}
function IlluminaTotalTrack(gsvg,data,trackClass,density){
	var that= CountTrack(gsvg,data,trackClass,density);
	var lbl="Brain Illumina Total RNA(rRNA depleted) Read Counts";
	that.updateLabel(lbl);
	that.redrawLegend();
	return that;
}
function LiverIlluminaTotalPlusTrack(gsvg,data,trackClass,density){
	var that= CountTrack(gsvg,data,trackClass,density);
	that.graphColorText="#abaecd";
	var lbl="Liver + Strand Total-RNA Read Counts";
	that.updateLabel(lbl);
	that.redrawLegend();
	that.redraw();
	return that;
}
function LiverIlluminaTotalMinusTrack(gsvg,data,trackClass,density){
	var that= CountTrack(gsvg,data,trackClass,density);
	that.graphColorText="#dbdefd";
	var lbl="Liver - Strand Total-RNA Read Counts";
	that.updateLabel(lbl);
	that.redrawLegend();
	that.redraw();
	return that;
}
function LiverIlluminaSmallTrack(gsvg,data,trackClass,density){
	var that= CountTrack(gsvg,data,trackClass,density);
	that.graphColorText="#7b7e9d";
	var lbl="Liver Small-RNA Read Counts";
	that.updateLabel(lbl);
	that.redrawLegend();
	that.redraw();
	return that;
}

function HeartIlluminaTotalPlusTrack(gsvg,data,trackClass,density){
	var that= CountTrack(gsvg,data,trackClass,density);
	that.graphColorText="#CC6242";
	var lbl="Heart + Strand Total-RNA Read Counts";
	that.updateLabel(lbl);
	that.redrawLegend();
	that.redraw();
	return that;
}
function HeartIlluminaTotalMinusTrack(gsvg,data,trackClass,density){
	var that= CountTrack(gsvg,data,trackClass,density);
	that.graphColorText="#FC9272";
	var lbl="Heart - Strand Total-RNA Read Counts";
	that.updateLabel(lbl);
	that.redrawLegend();
	that.redraw();
	return that;
}
function HeartIlluminaSmallTrack(gsvg,data,trackClass,density){
	var that= CountTrack(gsvg,data,trackClass,density);
	that.graphColorText="#9C3212";
	var lbl="Heart Small-RNA Read Counts";
	that.updateLabel(lbl);
	that.redrawLegend();
	that.redraw();
	return that;
}
function BrainIlluminaTotalPlusTrack(gsvg,data,trackClass,density){
	var that= CountTrack(gsvg,data,trackClass,density);
	that.graphColorText="#7EB5D6";
	var lbl="Brain + Strand Total-RNA Read Counts";
	that.updateLabel(lbl);
	that.redrawLegend();
	that.redraw();
	return that;
}
function BrainIlluminaTotalMinusTrack(gsvg,data,trackClass,density){
	var that= CountTrack(gsvg,data,trackClass,density);
	//that.graphColorText="#CC6242";
	var lbl="Brain - Strand Total-RNA Read Counts";
	that.updateLabel(lbl);
	that.redrawLegend();
	that.redraw();
	return that;
}
function IlluminaPolyATrack(gsvg,data,trackClass,density){
	var that= CountTrack(gsvg,data,trackClass,density);
	that.graphColorText="#7EB5D6";
	var lbl="Brain Illumina PolyA+ RNA Read Counts";
	that.updateLabel(lbl);
	that.redrawLegend();
	that.redraw();
	return that;
}
function SpliceJunctionTrack(gsvg,data,trackClass,label,density,additionalOptions){
	var that= GenericTranscriptTrack(gsvg,data,trackClass,label,density,additionalOptions);
	
	that.dataFileName=trackClass+".xml";
	that.xmlTag="Feature";
	that.xmlTagBlockElem="block";
	that.idPrefix="splcJnct";
	if(trackClass=="liverspliceJnct"){
		that.idPrefix="lvrsplcJnct";
	}else if(trackClass=="heartspliceJnct"){
		that.idPrefix="hrtsplcJnct";
	}
	that.ttSVG=1;
	that.ttTrackList=new Array();
	that.ttTrackList[0]="liverspliceJnct";
	if(trackClass=="spliceJnct"){
		that.ttTrackList[0]="splcJnct";
	}
	that.ttTrackList[1]="ensemblcoding";
	that.ttTrackList[2]="braincoding";
	that.ttTrackList[3]="liverTotal";
	that.ttTrackList[4]="refSeq";
	that.colorValueField="readCount";
	that.colorScale=d3.scale.linear().domain([1,1000]).range(["#E6E6E6","#000000"]);
	that.legendLbl="Read Depth";
	that.density=3;
	
	//console.log("Splice Junction TRACK:"+that.trackClass);

	that.getDisplayID=function(d){
		return	d.getAttribute("name");
	};

	that.createToolTip=function(d){
		var tooltip="";
		tooltip=tooltip+"<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div><BR>ID: "+d.getAttribute("name");
		tooltip=tooltip+"<BR>Read Counts="+numberWithCommas(d.getAttribute("readCount"));
		tooltip=tooltip+"<BR>Splice Junction in "+d.getAttribute("sampleCount")+" of ";
		if(that.trackClass=="liverspliceJnct"){
			tooltip=tooltip+"3 samples(3 BN-Lx)";
		}else{
			tooltip=tooltip+"6 samples(3 BN-Lx, 3 SHR)";
		}
		var bList=getAllChildrenByName(getFirstChildByName(d,"blockList"),"block");
		var exon1=0;
		var exon2=1;
		var first="start";
		var second="stop";
		if(d.getAttribute("strand")==-1){
			exon1=1;
			exon2=0;
			first="stop";
			second="start";
		}
		tooltip=tooltip+"<BR><BR>Coverage Exon 1: "+numberWithCommas(bList[exon1].getAttribute(first))+"-"+numberWithCommas(bList[exon1].getAttribute(second))+" ("+(bList[exon1].getAttribute("stop")*1-bList[exon1].getAttribute("start")*1)+" bp)";
		tooltip=tooltip+"<BR>Coverage Exon 2: "+numberWithCommas(bList[exon2].getAttribute(first))+"-"+numberWithCommas(bList[exon2].getAttribute(second))+" ("+(bList[exon2].getAttribute("stop")*1-bList[exon2].getAttribute("start")*1)+" bp)";
		tooltip=tooltip+"<BR>Intron: "+numberWithCommas((bList[1].getAttribute("start")*1-bList[0].getAttribute("stop")*1))+" bp<BR>";
		return tooltip;
	};

   	that.drawScaleLegend("1","1000+","Read Counts","#E6E6E6","#000000",0);
	that.draw(data);
	return that;
}
function CustomCountTrack(gsvg,data,trackClass,density,additionalOptions){
	var that= CountTrack(gsvg,data,trackClass,density);
	that.graphColorText="#4E85A6";
	that.updateControl=0;
	var lbl="Custom Count Track";
	var opts=additionalOptions.split(",");
	if(opts.length>0){
		for(var j=0;j<opts.length;j++){
			if(j==0){
				that.dataFileName=opts[j].substr(9);
			}else if(opts[j].indexOf("Name=")){
				lbl=opts[j].substr(5);
			}
		}
	}
	

	that.updateFullData = function(retry,force){
		if(that.updateControl==retry){
			that.updateControl=retry+1;
			var tmpMin=that.xScale.domain()[0];
			var tmpMax=that.xScale.domain()[1];
			var len=tmpMax-tmpMin;

			that.showLoading();
			that.bin=that.calculateBin(len);
			var tag="Count";
			var file=dataPrefix+"tmpData/trackXML/"+that.gsvg.folderName+"/count"+that.trackClass+".xml";
			var bedFile=dataPrefix+"tmpData/trackUpload/"+that.trackClass.substr(6);
			var type="bg";
			var web="";
			if(that.bin>0){
				tmpMin=tmpMin-(that.bin*2);
				tmpMin=tmpMin-(tmpMin%(that.bin*2));
				tmpMax=tmpMax+(that.bin*2);
				tmpMax=tmpMax+(that.bin*2-(tmpMax%(that.bin*2)));
				file=dataPrefix+"tmpData/trackXML/"+that.gsvg.folderName+"/"+tmpMin+"_"+tmpMax+".bincount."+that.bin+"."+that.trackClass+".xml";
			}
			if(that.dataFileName.indexOf("http")>-1){
				//file=dataPrefix+"tmpData/trackXML/"+that.gsvg.folderName+"/count"+that.trackClass+".xml";
				bedFile=that.dataFileName;
				web=that.dataFileName;
				type="bw";
			}
			
			d3.xml(file,function (error,d){
						if(error){
							if(retry==0||force==1){
								$.ajax({
													url: contextPath +"/"+ pathPrefix +"generateTrackXML.jsp",
									   				type: 'GET',
													data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax, myOrganism: organism, track: that.trackClass,bedFile: bedFile,outFile:file, folder: that.gsvg.folderName,binSize:that.bin,type:type,web:web},
													//data: {chromosome: chr,minCoord:minCoord,maxCoord:maxCoord,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: that.trackClass, folder: folderName,binSize:that.bin},
													dataType: 'json',
									    			success: function(data2){
									    				//console.log("generateTrack:DONE");	
									    			},
									    			error: function(xhr, status, error) {
									        			
									    			}
												});
							}
							//console.log(error);
							if(retry<8){//wait before trying again
								var time=500;
								/*if(retry==0){
									time=10000;
								}*/
								that.fullDataTimeOutHandle=setTimeout(function (){
									that.updateFullData(retry+1);
								},time);
							}else if(retry<30){
								var time=1000;
								that.fullDataTimeOutHandle=setTimeout(function (){
									that.updateFullData(retry+1);
								},time);
							}else if(retry<32){
								var time=10000;
								that.fullDataTimeOutHandle=setTimeout(function (){
									that.updateFullData(retry+1);
								},time);
							}else{
								d3.select("#Level"+that.levelNumber+that.trackClass).select("#trkLbl").text("An errror occurred loading Track:"+that.trackClass);
								d3.select("#Level"+that.levelNumber+that.trackClass).attr("height", 15);
								that.gsvg.addTrackErrorRemove(that.svg,"#Level"+that.gsvg.levelNumber+that.trackClass);
								that.hideLoading();
								that.fullDataTimeOutHandle=setTimeout(function (){
										that.updateFullData(retry+1,0);
									},15000);
							}
						}else{
							//console.log(d);
							if(d==null){
								if(retry>=4){
									data=new Array();
									that.draw(data);
									//that.hideLoading();
								}else{
									that.fullDataTimeOutHandle=setTimeout(function (){
										that.updateFullData(retry+1,0);
									},5000);
								}
							}else{
								that.fullDataTimeOutHandle=0;
								that.loadedDataMin=tmpMin;
					    		that.loadedDataMax=tmpMax;
								var data=d.documentElement.getElementsByTagName("Count");
								that.draw(data);
								//that.hideLoading();
								that.updateControl=0;
							}
						}
						//that.hideLoading();
					});
			}
		};


	that.updateLabel(lbl);
	that.redrawLegend();
	that.redraw();
	return that;
}
/*Generic numeric track which displays numeric values accross the genome*/
function CountTrack(gsvg,data,trackClass,density){
	var that= Track(gsvg,data,trackClass,"Generic Counts");
	that.loadedDataMin=that.xScale.domain()[0];
	that.loadedDataMax=that.xScale.domain()[1];
	that.dataFileName=that.trackClass;
	that.scaleMin=1;
	that.scaleMax=5000;
	that.graphColorText="steelblue";
	that.colorScale=d3.scale.linear().domain([that.scaleMin,that.scaleMax]).range(["#EEEEEE","#000000"]);
	that.ttSVG=1;

	that.ttTrackList=[];
	if(trackClass.indexOf("illuminaSmall")>-1){
		that.ttTrackList.push("ensemblsmallnc");
		that.ttTrackList.push("brainsmallnc");
		that.ttTrackList.push("liversmallnc");
		that.ttTrackList.push("heartsmallnc");
	}else{
		that.ttTrackList.push("ensemblcoding");
		that.ttTrackList.push("braincoding");
		that.ttTrackList.push("liverTotal");
		that.ttTrackList.push("heartTotal");
		that.ttTrackList.push("refSeq");
		that.ttTrackList.push("ensemblnoncoding");
		that.ttTrackList.push("brainnoncoding");
		that.ttTrackList.push("probe");
		that.ttTrackList.push("polyASite");
		that.ttTrackList.push("spliceJnct");
		that.ttTrackList.push("liverspliceJnct");
		that.ttTrackList.push("heartspliceJnct");
	}
	


	that.calculateBin= function(len){
		var w=that.gsvg.width;
		var bpPerPixel=len/w;
		bpPerPixel=Math.floor(bpPerPixel);
		var bpPerPixelStr=new String(bpPerPixel);
		var firstDigit=bpPerPixelStr.substr(0,1);
		var firstNum=firstDigit*Math.pow(10,(bpPerPixelStr.length-1));
		var bin=firstNum/2;
		bin=Math.floor(bin);
		if(bin<5){
			bin=0;
		}
		return bin;
	};

	that.data=data;
	that.density=density;
	that.prevDensity=density;
	that.displayBreakDown=null;
	var tmpMin=that.gsvg.xScale.domain()[0];
	var tmpMax=that.gsvg.xScale.domain()[1];
	var len=tmpMax-tmpMin;
	that.bin=that.calculateBin(len);
	that.fullDataTimeOutHandle=0;

	that.color= function (d){
		var color="#FFFFFF";
		if(d.getAttribute("count")>=that.scaleMin){
			color=d3.rgb(that.colorScale(d.getAttribute("count")));
			//color=d3.rgb(that.colorScale(d.getAttribute("count")));
		}		
		return color;
	};

	that.redraw= function (){
		
		/*if($("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").length>0){
			that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").val();
		}*/
		
		var tmpMin=that.gsvg.xScale.domain()[0];
		var tmpMax=that.gsvg.xScale.domain()[1];
		//var len=tmpMax-tmpMin;
		var tmpBin=that.bin;
		var tmpW=that.xScale(tmpMin+tmpBin)-that.xScale(tmpMin);
		/*if(tmpW>2||tmpW<0.5){
			that.updateFullData(0,1);
		}*//*else if(tmpMin<that.prevMinCoord||tmpMax>that.prevMaxCoord){
			that.updateFullData(0,1);
		}*///else{
		
			that.prevMinCoord=tmpMin;
			that.prevMaxCoord=tmpMax;

			var tmpMin=that.xScale.domain()[0];
				var tmpMax=that.xScale.domain()[1];
				var newData=[];
				var newCount=0;
				var tmpYMax=0;
				for(var l=0;l<that.data.length;l++){
					if(that.data[l]!=undefined ){
						var start=that.data[l].getAttribute("start")*1;
						var stop=that.data[l].getAttribute("stop")*1;
						var count=that.data[l].getAttribute("count")*1;
						if(that.density!=1 ||(that.density==1 && start!=stop)){
							if((l+1)<that.data.length){
								var startNext=that.data[l+1].getAttribute("start")*1;
								if(	(start>=tmpMin&&start<=tmpMax) || (startNext>=tmpMin&&startNext<=tmpMax)
									){
									newData[newCount]=that.data[l];
									if(count>tmpYMax){
										tmpYMax=count;
									}
									newCount++;
								}else{ 

								}
							}else{
								if(start>=tmpMin&&start<=tmpMax){
									newData[newCount]=that.data[l];
									if(count>tmpYMax){
										tmpYMax=count;
									}
									newCount++;
								}else{

								}
							}
						}
					}
				}
			if(that.density==1){
				if(that.density!=that.prevDensity){
					that.redrawLegend();
					var tmpMax=that.gsvg.xScale.domain()[1];
					that.prevDensity=that.density;
					that.svg.selectAll(".area").remove();
					that.svg.selectAll("g.y").remove();
					that.svg.selectAll(".grid").remove();
					that.svg.selectAll(".leftLbl").remove();
					var points=that.svg.selectAll("."+that.trackClass).data(newData,keyStart)
			    	points.enter()
							.append("rect")
							.attr("x",function(d){return that.xScale(d.getAttribute("start"));})
							.attr("y",15)
							.attr("class", that.trackClass)
				    		.attr("height",10)
							.attr("width",function(d,i) {
											   var wX=1;
											   wX=that.xScale((d.getAttribute("stop")))-that.xScale(d.getAttribute("start"));
											
											   return wX;
											   })
							.attr("fill",that.color)
							.on("mouseover", function(d) { 
								if(that.gsvg.isToolTip==0){ 
									d3.select(this).style("fill","green");
			            			tt.transition()        
										.duration(200)      
										.style("opacity", 1);      
									tt.html(that.createToolTip(d))  
										.style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
										.style("top", function(){return that.positionTTTop(d3.event.pageY);});  
								}
		            			})
							.on("mouseout", function(d) {  
								d3.select(this).style("fill",that.color);
					            tt.transition()
									 .delay(500)       
					                .duration(200)      
					                .style("opacity", 0);
					        });
					points.exit().remove();
				}else{
					that.svg.selectAll("."+that.trackClass)
						.attr("x",function(d){return that.xScale(d.getAttribute("start"));})
						.attr("width",function(d,i) {
											   var wX=1;
											    wX=that.xScale((d.getAttribute("stop")))-that.xScale(d.getAttribute("start"));
											   /*if((i+1)<that.data.length){
											   		if(that.xScale((that.data[i+1].getAttribute("start")))-that.xScale(d.getAttribute("start"))>1){
												   		wX=that.xScale((that.data[i+1].getAttribute("start")))-that.xScale(d.getAttribute("start"));
											   		}
												}/*else{
													if(d3.select(this).attr("width")>0){
														wX=d3.select(this).attr("width")
													}else{
														if(that.xScale(tmpMax)-that.xScale(d.getAttribute("start"))>1){
												   			wX=that.xScale(tmpMax)-that.xScale(d.getAttribute("start"));
											   			}
											   		}
												}*/
											   return wX;
											   })
						.attr("fill",that.color);
				}
				that.svg.attr("height", 30);
			}else if(that.density==2){
				
				
				that.svg.selectAll("."+that.trackClass).remove();
				that.svg.select(".y.axis").remove();
				that.svg.select("g.grid").remove();
				that.svg.selectAll(".leftLbl").remove();
				that.yScale.domain([0, tmpYMax]);
				that.svg.select(".area").remove();
				that.area = d3.svg.area()
	    				.x(function(d) { return that.xScale(d.getAttribute("start")); })
					    .y0(140)
					    .y1(function(d) { return that.yScale(d.getAttribute("count")); });
				that.redrawLegend();
				that.prevDensity=that.density;
				that.svg.append("g")
					      .attr("class", "y axis")
					      .call(that.yAxis);
				that.svg.append("g")         
			        	.attr("class", "grid")
			        	.call(that.yAxis
			            		.tickSize((-that.gsvg.width+10), 0, 0)
			            		.tickFormat("")
			        		);
				that.svg.select("g.y").selectAll("text").each(function(d){
																	var str=new String(d);
																	d3.select(this).attr("x",function(){
															     							return str.length*7.7+5;
															     						})
											     									.attr("dy","0.05em");
				    													
					    											that.svg.append("svg:text").attr("class","leftLbl")
					    													.attr("x",that.gsvg.width-(str.length*7.8+5))
					    													.attr("y",function(){return that.yScale(d)})
					    													.attr("dy","0.01em")
					    													.style("font-weight","bold")
					    													.text(numberWithCommas(d));
											    						
											    						
				    											});
				
			    that.svg.append("path")
				      	.datum(newData)
				      	.attr("class", "area")
				      	.attr("stroke",that.graphColorText)
				      	.attr("fill",that.graphColorText)
				      	.attr("d", that.area);
		
				that.svg.attr("height", 140);
			}
			that.redrawSelectedArea();
		//}
	};

	that.createToolTip=function (d){
		var tooltip="";
		tooltip="<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div><BR>Read Count="+ numberWithCommas(d.getAttribute("count"));
		if(that.bin>0){
			var tmpEnd=(d.getAttribute("start")*1)+(that.bin*1);
			tooltip=tooltip+"*<BR><BR>*Data compressed for display. Using 90th percentile of<BR>region:"+numberWithCommas(d.getAttribute("start"))+"-"+numberWithCommas(tmpEnd)+"<BR><BR>Zoom in further to see raw data(roughly a region <1000bp). The bin size will decrease as you zoom in thus the resolution of the count data will improve as you zoom in.";
		}/*else{
			tooltip=tooltip+"<BR>Read Count:"+d.getAttribute("count");
		}*/
		return tooltip;
	};

	that.update=function (d){
		var tmpMin=that.xScale.domain()[0];
		var tmpMax=that.xScale.domain()[1];
		if(that.loadedDataMin<=tmpMin &&tmpMax<=that.loadedDataMax){
			that.redraw();
		}else{
			that.updateFullData(0,1);
		}
	};

	that.updateFullData = function(retry,force){
		var tmpMin=that.xScale.domain()[0];
		var tmpMax=that.xScale.domain()[1];

		var len=tmpMax-tmpMin;

		that.showLoading();
		that.bin=that.calculateBin(len);
		var tag="Count";
		var file=dataPrefix+"tmpData/regionData/"+that.gsvg.folderName+"/count"+that.trackClass+".xml";
		if(that.bin>0){
			tmpMin=tmpMin-(that.bin*2);
			tmpMin=tmpMin-(tmpMin%(that.bin*2));
			tmpMax=tmpMax+(that.bin*2);
			tmpMax=tmpMax+(that.bin*2-(tmpMax%(that.bin*2)));
			file=dataPrefix+"tmpData/regionData/"+that.gsvg.folderName+"/tmp/"+tmpMin+"_"+tmpMax+".bincount."+that.bin+"."+that.trackClass+".xml";
		}
		
		d3.xml(file,function (error,d){
					if(error){
						if(retry==0||force==1){
							$.ajax({
												url: contextPath +"/"+ pathPrefix +"generateTrackXML.jsp",
								   				type: 'GET',
												data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: that.trackClass, folder: that.gsvg.folderName,binSize:that.bin},
												//data: {chromosome: chr,minCoord:minCoord,maxCoord:maxCoord,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: that.trackClass, folder: folderName,binSize:that.bin},
												dataType: 'json',
								    			success: function(data2){
								    				//console.log("generateTrack:DONE");	
								    			},
								    			error: function(xhr, status, error) {
								        			
								    			}
											});
						}
						//console.log(error);
						if(retry<8){//wait before trying again
							var time=500;
							/*if(retry==0){
								time=10000;
							}*/
							that.fullDataTimeOutHandle=setTimeout(function (){
								that.updateFullData(retry+1);
							},time);
						}else if(retry<30){
							var time=1000;
							that.fullDataTimeOutHandle=setTimeout(function (){
								that.updateFullData(retry+1);
							},time);
						}else if(retry<32){
							var time=10000;
							that.fullDataTimeOutHandle=setTimeout(function (){
								that.updateFullData(retry+1);
							},time);
						}else{
							d3.select("#Level"+that.levelNumber+that.trackClass).select("#trkLbl").text("An errror occurred loading Track:"+that.trackClass);
							d3.select("#Level"+that.levelNumber+that.trackClass).attr("height", 15);
							that.gsvg.addTrackErrorRemove(that.svg,"#Level"+that.gsvg.levelNumber+that.trackClass);
							that.hideLoading();
							that.fullDataTimeOutHandle=setTimeout(function (){
									that.updateFullData(retry+1,0);
								},15000);
						}
					}else{
						//console.log(d);
						if(d==null){
							if(retry>=4){
								data=new Array();
								that.draw(data);
								//that.hideLoading();
							}else{
								that.fullDataTimeOutHandle=setTimeout(function (){
									that.updateFullData(retry+1,0);
								},5000);
							}
						}else{
							that.fullDataTimeOutHandle=0;
							that.loadedDataMin=tmpMin;
				    		that.loadedDataMax=tmpMax;
							var data=d.documentElement.getElementsByTagName("Count");
							that.draw(data);
							//that.hideLoading();
						}
					}
					//that.hideLoading();
				});
	};

	that.updateCountScale= function(minVal,maxVal){
		that.scaleMin=minVal;
		that.scaleMax=maxVal;
		that.colorScale=d3.scale.linear().domain([that.scaleMin,that.scaleMax]).range(["#EEEEEE","#000000"]);
		if(that.density==1){
			that.redrawLegend();
			that.redraw();
		}
	};

	that.setupToolTipSVG=function(d,perc){
		//Setup Tooltip SVG
		var tmpMin=that.xScale.domain()[0];
		var tmpMax=that.xScale.domain()[1];
		var start=d.getAttribute("start")*1;
		var stop=d.getAttribute("stop")*1;
		var len=stop-start;
		var margin=Math.floor((tmpMax-tmpMin)*perc);
		if(margin<20){
			margin=20;
		}
		var tmpStart=start-margin;
		var tmpStop=stop+margin;
		if(tmpStart<1){
			tmpStart=1;
		}
		if(that.ttSVGMinWidth!=undefined){
			if(tmpStop-tmpStart<that.ttSVGMinWidth){
				tmpStart=start-(that.ttSVGMinWidth/2);
				tmpStop=stop+(that.ttSVGMinWidth/2);
			}
		}

		var newSvg=toolTipSVG("div#ttSVG",450,tmpStart,tmpStop,99,d.getAttribute("ID"),"transcript");
		//Setup Track for current feature
		//var dataArr=new Array();
		//dataArr[0]=d;
		newSvg.addTrack(that.trackClass,3,"",that.data);
		//Setup Other tracks included in the track type(listed in that.ttTrackList)
		for(var r=0;r<that.ttTrackList.length;r++){
			var tData=that.gsvg.getTrackData(that.ttTrackList[r]);
			var fData=new Array();
			if(tData!=undefined&&tData.length>0){
				var fCount=0;
				for(var s=0;s<tData.length;s++){
					if((tmpStart<=tData[s].getAttribute("start")&&tData[s].getAttribute("start")<=tmpStop)
						|| (tData[s].getAttribute("start")<=tmpStart&&tData[s].getAttribute("stop")>=tmpStart)
						){
						fData[fCount]=tData[s];
						fCount++;
					}
				}
				if(fData.length>0){
					newSvg.addTrack(that.ttTrackList[r],3,"DrawTrx",fData);	
				}
			}
		}
	}

	that.draw=function(data){
		
		that.hideLoading();
		//d3.selectAll("."+that.trackClass).remove();
		//data.sort(function(a, b){return a.getAttribute("start")-b.getAttribute("start")});
		that.data=data;
		/*if($("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").length>0){
			that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").val();
		}*/
		
		that.redrawLegend();
		var tmpMin=that.xScale.domain()[0];
		var tmpMax=that.xScale.domain()[1];
		var newData=[];
		var newCount=0;
		var tmpYMax=0;
		for(var l=0;l<data.length;l++){
			if(data[l]!=undefined ){
				var start=data[l].getAttribute("start")*1;
				var stop=data[l].getAttribute("stop")*1;
				var count=data[l].getAttribute("count")*1;
				if(that.density!=1 ||(that.density==1 && start!=stop)){
					if((l+1)<data.length){
						var startNext=data[l+1].getAttribute("start")*1;
						if(	(start>=tmpMin&&start<=tmpMax) || (startNext>=tmpMin&&startNext<=tmpMax)){
							newData[newCount]=data[l];
							if(count>tmpYMax){
								tmpYMax=count;
							}
							newCount++;
						}else{ 

						}
					}else{
						if((start>=tmpMin&&start<=tmpMax)){
							newData[newCount]=data[l];
							if(count>tmpYMax){
								tmpYMax=count;
							}
							newCount++;
						}else{

						}
					}
				}
			}
		}
		data=newData;
		that.svg.selectAll("."+that.trackClass).remove();
		that.svg.select(".y.axis").remove();
		that.svg.select("g.grid").remove();
		that.svg.selectAll(".leftLbl").remove();
		that.svg.select(".area").remove();
		that.svg.selectAll(".area").remove();
		if(that.density==1){
			var tmpMax=that.gsvg.xScale.domain()[1];
	    	var points=that.svg.selectAll("."+that.trackClass)
	   			.data(data,keyStart);
	    	points.enter()
					.append("rect")
					.attr("x",function(d){return that.xScale(d.getAttribute("start"));})
					.attr("y",15)
					.attr("class", that.trackClass)
		    		.attr("height",10)
					.attr("width",function(d,i) {
									   var wX=1;
									   wX=that.xScale((d.getAttribute("stop")))-that.xScale(d.getAttribute("start"));
									   /*if((i+1)<that.data.length){
										   if(that.xScale((that.data[i+1].getAttribute("start")))-that.xScale(d.getAttribute("start"))>1){
											   wX=that.xScale((that.data[i+1].getAttribute("start")))-that.xScale(d.getAttribute("start"));
										   }
										}else{
											if(that.xScale(tmpMax)-that.xScale(d.getAttribute("start"))>1){
											   	wX=that.xScale(tmpMax)-that.xScale(d.getAttribute("start"));
										   	}
										}*/
									   return wX;
									   })
					.attr("fill",that.color)
					.on("mouseover", function(d) {
							console.log("mouseover count track");
							if(that.gsvg.isToolTip==0){
								console.log("setup tooltip:countTrack");
								d3.select(this).style("fill","green");
		            			tt.transition()        
									.duration(200)      
									.style("opacity", 1);      
								tt.html(that.createToolTip(d))  
									.style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
									.style("top", function(){return that.positionTTTop(d3.event.pageY);});
								if(that.ttSVG==1){
									//Setup Tooltip SVG
									that.setupToolTipSVG(d,0.005);
								}
							}
            			})
					.on("mouseout", function(d) {  
						d3.select(this).style("fill",that.color);
			            tt.transition()
							 .delay(500)       
			                .duration(200)      
			                .style("opacity", 0);
			        });
			that.svg.attr("height", 30);
	    }else if(that.density==2){
	    	that.yScale.domain([0, tmpYMax]);
	    	that.yAxis = d3.svg.axis()
    				.scale(that.yScale)
    				.orient("left")
    				.ticks(5);
    		that.svg.select("g.grid").remove();
    		that.svg.select(".y.axis").remove();
    		that.svg.selectAll(".leftLbl").remove();
	    	that.svg.append("g")
		      .attr("class", "y axis")
		      .call(that.yAxis);

		    that.svg.select("g.y").selectAll("text").each(function(d){
		    												var str=new String(d);
		    												that.svg.append("svg:text").attr("class","leftLbl")
		    													.attr("x",that.gsvg.width-(str.length*7.8+5))
		    													.attr("y",function(){return that.yScale(d)})
		    													.attr("dy","0.01em")
		    													.style("font-weight","bold")
		    													.text(numberWithCommas(d));
								    						
								    						d3.select(this).attr("x",function(){
								     							return str.length*7.7+5;
								     						})
								     						.attr("dy","0.05em");
						     						});

	    	that.svg.append("g")         
		        .attr("class", "grid")
		        .call(that.yAxis
		            		.tickSize((-that.gsvg.width+10), 0, 0)
		            		.tickFormat("")
		        		);
		    that.svg.select(".area").remove();
		    that.area = d3.svg.area()
    				.x(function(d) { return that.xScale(d.getAttribute("start")); })
				    .y0(140)
				    .y1(function(d,i) { return that.yScale(d.getAttribute("count"));; });
		    that.svg.append("path")
		      	.datum(data)
		      	.attr("class", "area")
		      	.attr("stroke",that.graphColorText)
		      	.attr("fill",that.graphColorText)
		      	.attr("d", that.area);
			that.svg.attr("height", 140);
		}
		that.redrawSelectedArea();
	};

	that.redrawLegend=function (){

		if(that.density==2){
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".legend").remove();
		}else if(that.density==1){
			var lblStr=new String(that.label);
			var x=that.gsvg.width/2+(lblStr.length/2)*7.5-10;
			var ltLbl=new String("<"+that.scaleMin);
			that.drawScaleLegend(that.scaleMin,numberWithCommas(that.scaleMax)+"+","Read Counts","#EEEEEE","#00000",15+(ltLbl.length*7.6));
			that.svg.append("text").text("<"+that.scaleMin).attr("class","legend").attr("x",x).attr("y",12);
			that.svg.append("rect")
					.attr("class","legend")
					.attr("x",x+ltLbl.length*7.6+5)
					.attr("y",0)
					.attr("rx",2)
					.attr("ry",2)
			    	.attr("height",12)
					.attr("width",15)
					.attr("fill","#FFFFFF")
					.attr("stroke","#CECECE");
		}
		
	};

	that.redrawSelectedArea=function(){
		var rectH=that.svg.attr("height");
		if(that.density==1){
			rectH=10;
		}
		d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".selectedArea").remove();
		if(that.selectionStart>-1&&that.selectionEnd>-1){
			var tmpStart=that.xScale(that.selectionStart);
			var tmpW=that.xScale(that.selectionEnd)-tmpStart;
			if(tmpW<1){
				tmpW=1;
			}
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).append("rect")
							.attr("class","selectedArea")
							.attr("x",tmpStart)
							.attr("y",0)
			    			.attr("height",rectH)
							.attr("width",tmpW)
							.attr("fill","#CECECE")
							.attr("opacity",0.3)
							.attr("pointer-events","none");
		}
	};


	that.savePrevious=function(){
		that.prevSetting={};
		that.prevSetting.density=that.density;
		that.prevSetting.scaleMin=that.scaleMin;
		that.prevSetting.scaleMax=that.scaleMax;

	};
	
	that.revertPrevious=function(){
		that.density=that.prevSetting.density;
		that.scaleMin=that.prevSetting.scaleMin;
		that.scaleMax=that.prevSetting.scaleMax;
	};

	that.generateTrackSettingString=function(){
		return that.trackClass+","+that.density+","+that.include+";";
	};

	that.generateSettingsDiv=function(topLevelSelector){
		var d=trackInfo[that.trackClass];
		that.savePrevious();
		//console.log(trackInfo);
		//console.log(d);
		d3.select(topLevelSelector).select("table").select("tbody").html("");
		if(d.Controls.length>0 && d.Controls!="null"){
			var controls=new String(d.Controls).split(",");
			var table=d3.select(topLevelSelector).select("table").select("tbody");
			table.append("tr").append("td").style("font-weight","bold").html("Track Settings: "+d.Name);
			for(var c=0;c<controls.length;c++){
				if(controls[c]!=undefined && controls[c]!=""){
					var params=controls[c].split(";");
					
					var div=table.append("tr").append("td");
					var lbl=params[0].substr(5);
					
					var def="";
					if(params.length>3  && params[3].indexOf("Default=")==0){
						def=params[3].substr(8);
					}
					if(params[1].toLowerCase().indexOf("select")==0){
						div.append("text").text(lbl+": ");
						var selClass=params[1].split(":");
						var opts=params[2].split("}");
						var id=that.trackClass+"Dense"+that.level+"Select";
						if(selClass[1]=="colorSelect"){
							id=that.trackClass+that.level+"colorSelect";
						}
						var sel=div.append("select").attr("id",id)
							.attr("name",selClass[1]);
						for(var o=0;o<opts.length;o++){
							var option=opts[o].substr(1).split(":");
							if(option.length==2){
								var tmpOpt=sel.append("option").attr("value",option[1]).text(option[0]);
								if(id.indexOf("Dense")>-1){
									if(option[1]==that.density){
										tmpOpt.attr("selected","selected");
									}
								}else if(option[1]==def){
									tmpOpt.attr("selected","selected");
								}
							}
						}
						d3.select("select#"+id).on("change", function(){
							if($(this).attr("id")==that.trackClass+"Dense"+that.level+"Select" && $(this).val()==1){
								$("#scaleControl"+that.level).show();
							}else{
								$("#scaleControl"+that.level).hide();
							}
							that.updateSettingsFromUI();
							that.redraw();
						});
					}else if(params[1].toLowerCase().indexOf("slider")==0){
						var disp="none";
						if(that.density==1){
							disp="inline-block";
						}
						div=div.append("div").attr("id","scaleControl"+that.level).style("display",disp);
						div.append("text").text(lbl+": ");
						div.append("input").attr("type","text").attr("id","amount").attr("value",that.scaleMin+"-"+that.scaleMax).style("border",0).style("color","#f6931f").style("font-weight","bold").style("background-color","#EEEEEE");
						var selClass=params[1].split(":");
						var opts=params[2].split("}");
						
						div=div.append("div");
						div.append("text").text("Min:").append("div").attr("id","min-"+selClass[1]).style("width","85%").style("display","inline-block").style("float","right");
						div.append("br");
						div.append("text").text("Max:").append("div").attr("id","max-"+selClass[1]).style("width","85%").style("display","inline-block").style("float","right");

						$( "#min-"+selClass[1] ).slider({
							  min: 1,
							  max: 1000,
							  step:1,
							  value:  that.scaleMin	 ,
							  slide: that.processSlider
							});
						$( "#max-"+selClass[1] ).slider({
							  min: 1000,
							  max: 20000,
							  step:100,
							  value: that.scaleMax ,
							  slide: that.processSlider
							});
						
							that.updateSettingsFromUI();
							that.redraw();
						
							
						
					}
				}
			}
			var buttonDiv=table.append("tr").append("td");
			buttonDiv.append("input").attr("type","button").attr("value","Remove Track").style("float","left").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
				that.gsvg.setCurrentViewModified();
				that.gsvg.removeTrack(that.trackClass);
			});
			buttonDiv.append("input").attr("type","button").attr("value","Apply").style("float","right").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
				if(that.density!=that.prevSetting.density || that.scaleMin!=that.prevSetting.scaleMin || that.scaleMax!= that.prevSetting.scaleMax){
					that.gsvg.setCurrentViewModified();
				}
			});
			buttonDiv.append("input").attr("type","button").attr("value","Cancel").style("float","right").style("margin-left","5px").on("click",function(){
				that.revertPrevious();
				that.updateCountScale(that.scaleMin,that.scaleMax);
				that.draw(that.data);
				$('#trackSettingDialog').fadeOut("fast");
			});
		}else{
			var table=d3.select(topLevelSelector).select("table").select("tbody");
			table.append("tr").append("td").style("font-weight","bold").html("Track Settings: "+d.Name);
			table.append("tr").append("td").html("Sorry no settings for this track.");
			var buttonDiv=table.append("tr").append("td");
			buttonDiv.append("input").attr("type","button").attr("value","Remove Track").style("float","left").style("margin-left","5px").on("click",function(){
				that.gsvg.setCurrentViewModified();
				$('#trackSettingDialog').fadeOut("fast");
			});
			buttonDiv.append("input").attr("type","button").attr("value","Cancel").style("float","right").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
			});
		}
	};

	that.processSlider=function(event,ui){
		var min=$( "#min-rangeslider" ).slider( "value");
		var max=$( "#max-rangeslider" ).slider( "value");
		$( "#amount" ).val(  min+ " - " + max );
		that.updateCountScale(min,max);
	};

	that.yScale = d3.scale.linear()
				.range([140, 20])
				.domain([0, d3.max(data, function(d) { return d.getAttribute("count"); })]);
    /*that.colorDomain=[0,1,5,10,25,50,75,100,200,300,400,500,600,700,800,900,1000];
    that.colorRange=["#FFFFFF","#EEEEEE","#DDDDDD","#CCCCCC","#BBBBBB","#AAAAAA","#999999","#888888","#777777","#666666","#555555","#444444","#333333","#222222","#111111","#000000"];
   	that.colorScale= d3.scale.threshold()
   						.domain(that.colorDomain)
   						.range(that.colorRange);*/
    that.area = d3.svg.area()
    				.x(function(d) { return that.xScale(d.getAttribute("start")); })
				    .y0(140)
				    .y1(function(d) { return d.getAttribute("count"); });
    that.yAxis = d3.svg.axis()
    				.scale(that.yScale)
    				.orient("left")
    				.ticks(5);
   	that.redrawLegend();
    that.draw(data);
	return that;
}

function PolyATrack(gsvg,data,trackClass,label,density,additionalOptions){
	var that=GenericTranscriptTrack(gsvg,data,trackClass,label,density,additionalOptions);
	that.dataFileName="polyASite.xml";
	that.density=3;
	that.minFeatureWidth=1;
	that.colorBy="Color";
	that.ttSVG=1;
	that.ttTrackList=[];
	that.ttTrackList.push("ensemblcoding");
	that.ttTrackList.push("braincoding");
	that.ttTrackList.push("liverTotal");
	that.ttTrackList.push("heartTotal");
	that.ttTrackList.push("refSeq");
	that.ttSVGMinWidth=200;
	

	that.createToolTip=function(d){
		var tooltip="";
		var strand=".";
		if(d.getAttribute("strand")==1){
			strand="+";
		}else if(d.getAttribute("strand")==-1){
			strand="-";
		}
		var zero="0";
		if(d.getAttribute("pvalue")==1){
			zero="";
		}
		tooltip="<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div><BR>Motif:"+d.getAttribute("motif")+"<BR>Strand:"+strand+"<BR>Location: chr"+d.getAttribute("chromosome")+":"+d.getAttribute("start")+"-"+d.getAttribute("stop")+"<BR>Probability of site: "+zero+d.getAttribute("pvalue");
		return tooltip;
	};

	that.updateData = function(retry){
		var path=dataPrefix+"tmpData/regionData/"+that.gsvg.folderName+"/"+that.dataFileName;
		d3.xml(path,function (error,d){
				if(error){
					if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								that.updateData(retry+1);
							},time);
					}else if(retry>=3){
							d3.select("#Level"+that.levelNumber+that.trackClass).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+that.trackClass).attr("height", 15);
							that.gsvg.addTrackErrorRemove(that.svg,"#Level"+that.gsvg.levelNumber+that.trackClass);
					}
				}else{
						var feature=d.documentElement.getElementsByTagName(that.xmlTag);
						var mergeddata=new Array();
						var checkName=new Array();
						var curInd=0;
						for(var l=0;l<feature.length;l++){
							if(feature[l]!=undefined ){
								mergeddata[curInd]=feature[l];
								checkName[feature[l].getAttribute("ID")]=1;
								curInd++;
							}
						}
						for(var l=0;l<that.data.length;l++){
							if(that.data[l]!=undefined && checkName[that.data[l].getAttribute("ID")]==undefined){
								mergeddata[curInd]=that.data[l];
								curInd++;
							}
						}
						that.draw(mergeddata);
						that.hideLoading();
					}
			});
	};

	that.redrawLegend=function (){
		var legend=[];
		legend[0]={color:"#FF8000",label:"+ Strand >>>"};
		legend[1]={color:"#330570",label:"- Strand <<<"};
		that.drawLegend(legend);
		
	};
	
	that.updateFullData = undefined;

	that.draw(data);
	return that;
}

function CustomTranscriptTrack(gsvg,data,trackClass,label,density,additionalOptions){
	var that=GenericTranscriptTrack(gsvg,data,trackClass,label,density,additionalOptions);
	var opts=additionalOptions.split(",");
	that.density=density;
	if(opts.length>0){
		that.dataFileName=opts[0].substr(9);
	}
	if(opts.length>1){
		that.colorBy=opts[1];
	}else{
		that.colorBy="Score";
	}
	if(opts.length>2){
		that.minValue=opts[2];
	}
	if(opts.length>3){
		that.maxValue=opts[3];
	}
	if(opts.length>4){
		that.minColor=opts[4];
	}
	if(opts.length>5){
		that.maxColor=opts[5];
	}
	//that.dataFileName=trackClass.substr(6)+".bed";
	that.colorValueField="score";
	that.minFeatureWidth=1;
	that.updateControl=0;

	if(that.colorBy=="Score"){
		that.createColorScale();
	}

	that.updateFullData = function(retry,force){
		if(that.updateControl==retry){
			that.updateControl=retry+1;
			var tmpMin=that.xScale.domain()[0];
			var tmpMax=that.xScale.domain()[1];
			var file=dataPrefix+"tmpData/trackXML/"+that.gsvg.folderName+"/"+that.dataFileName+".xml";
			var bedFile=dataPrefix+"tmpData/trackUpload/"+that.dataFileName;
			var http="";
			var tmp=new Date();
			var type="bed"
			if(that.dataFileName.indexOf("http")>-1){
				http=that.dataFileName;
				bedFile="tmpData/tmpDownload/"+tmp.getTime()+"_"+that.trackClass;
				file=dataPrefix+"tmpData/trackXML/"+that.gsvg.folderName+"/"+that.trackClass+".xml";
				type="bb";
			}


			d3.xml(file,function (error,d){
						//console.log("Handling retry:"+retry+"  force:"+force);
						if(error){
							//console.log("ERROR******");
							console.log(error);
							if(retry==0 || force==1){
								$.ajax({
									url: contextPath +"/"+ pathPrefix +"generateTrackXML.jsp",
					   				type: 'GET',
									data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,folder:that.gsvg.folderName,bedFile: bedFile,outFile:file,track:that.trackClass,web:http,type:type},
									//data: {chromosome: chr,minCoord:minCoord,maxCoord:maxCoord,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: that.trackClass, folder: folderName,binSize:that.bin},
									dataType: 'json',
					    			success: function(data2){
					    				
					    			},
					    			error: function(xhr, status, error) {
					        			console.log(error);
					    			}
								});
							}
							if(retry<3){//wait before trying again
								var time=10000;
								if(retry==1){
									time=15000;
								}
								setTimeout(function (){
									that.updateFullData(retry+1,0);
								},time);
							}else{
								d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).select("#trkLbl").text("An errror occurred loading Track:"+that.trackClass);
								d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).attr("height", 15);
								that.gsvg.addTrackErrorRemove(that.svg,"#Level"+that.gsvg.levelNumber+that.trackClass);
								that.hideLoading();
							}
						}else{
							//console.log("SUCCESS******");
							//console.log(d);
							/*if(d==null){
								console.log("D:NULL");
								if(retry>=4){
									data=new Array();
									that.draw(data);
									that.hideLoading();
								}else{
									setTimeout(function (){
										that.updateFullData(retry+1,0);
									},5000);
								}
							}else{*/
								//console.log("SETUP TRACK");
								var data=d.documentElement.getElementsByTagName(that.xmlTag);
								//console.log(that.trackClass+" received the following:");
								//console.log(data);
								that.draw(data);
								that.hideLoading();
								that.updateControl=0;
							//}
						}
					});
		}
	};

	that.updateSettingsFromUI=function(){
		if($("#"+that.trackClass+"Dense"+that.level+"Select").length>0){
			that.density=$("#"+that.trackClass+"Dense"+that.level+"Select").val();
		}
		if($("#"+that.trackClass+that.level+"colorSelect").length>0){
			that.colorBy=$("#"+that.trackClass+that.level+"colorSelect").val();
		}
		if(that.colorBy=="Score"){
			console.log("colorby:Score");
			that.minValue=$("#"+that.trackClass+"minData"+that.level).val();
			that.maxValue=$("#"+that.trackClass+"maxData"+that.level).val();
			if(testIE||testSafari){
				that.minColor=$("#"+that.trackClass+"minColor"+that.level).spectrum("get").toHexString();
				that.maxColor=$("#"+that.trackClass+"maxColor"+that.level).spectrum("get").toHexString();
				console.log(that.minColor+":::"+that.maxColor);
			}else{
				that.minColor=$("#"+that.trackClass+"minColor"+that.level).val();
				that.maxColor=$("#"+that.trackClass+"maxColor"+that.level).val();
			}	
			that.createColorScale();
		}
	};

	that.generateSettingsDiv=function(topLevelSelector){
		var d=trackInfo[that.trackClass];
		that.savePrevious();
		d3.select(topLevelSelector).select("table").select("tbody").html("");
		if(d.Controls.length>0 && d.Controls!="null"){
			var controls=new String(d.Controls).split(",");
			var table=d3.select(topLevelSelector).select("table").select("tbody");
			table.append("tr").append("td").style("font-weight","bold").html("Track Settings: "+d.Name);
			for(var c=0;c<controls.length;c++){
				if(controls[c]!=undefined && controls[c]!=""){
					var params=controls[c].split(";");
					var div=table.append("tr").append("td");
					var lbl=params[0].substr(5);
					var def="";
					if(params.length>3  && params[3].indexOf("Default=")==0){
						def=params[3].substr(8);
					}
					if(params[1].toLowerCase().indexOf("select")==0){
						div.append("text").text(lbl+": ");
						var selClass=params[1].split(":");
						var opts=params[2].split("}");
						var id=that.trackClass+"Dense"+that.level+"Select";
						if(selClass[1]=="colorSelect"){
							id=that.trackClass+that.level+"colorSelect";
						}
						var sel=div.append("select").attr("id",id)
							.attr("name",selClass[1]);
						for(var o=0;o<opts.length;o++){
							var option=opts[o].substr(1).split(":");
							if(option.length==2){
								var tmpOpt=sel.append("option").attr("value",option[1]).text(option[0]);
								if((id.indexOf("Dense")>-1 && option[1]==that.density)|| (id.indexOf("colorSelect")>-1&&option[1]==that.colorBy)){
									tmpOpt.attr("selected","selected");
								}
							}
						}
						d3.select("select#"+id).on("change", function(){
							if($(this).val()=="Score"){
								$("div."+that.trackClass+"Scale"+that.level).show();
							}else if($(this).val()=="Color"){
								$("div."+that.trackClass+"Scale"+that.level).hide();
							}
							that.updateSettingsFromUI();
							that.draw(that.data);
						});
					}else if(params[1].toLowerCase().indexOf("txt")==0){
						if($("#colorTrack"+that.level).size()==0){
							div=div.append("div").attr("class",that.trackClass+"Scale"+that.level).style("display","none");
						}else{
							div=d3.select("#"+that.trackClass+"Scale"+that.level);
						}						
						div.append("text").text(lbl+": ");
						var selClass=params[1].split(":");
						var opts=params[2].split("}");
						var txtType="Data";
						var inputType="text";
						var inputMin=that.minValue;
						var inputMax=that.maxValue;
						if(selClass[1]=="color"){
							txtType="Color";
							inputType="Color";
							inputMin=that.minColor;
							inputMax=that.maxColor;
						}
						
						div.append("input").attr("type",inputType).attr("id",that.trackClass+"min"+txtType+that.level)
									.attr("class",selClass[1])
									.style("margin-left","5px")
									.attr("value",inputMin);
						div.append("text").text(" - ");
						div.append("input").attr("type",inputType).attr("id",that.trackClass+"max"+txtType+that.level)
									.attr("class",selClass[1])
									.style("margin-left","5px")
									.attr("value",inputMax);

						
						if(txtType=="Color" && (testIE||testSafari)){//Change for IE and Safari
							$("#"+that.trackClass+"min"+txtType+that.level).spectrum({
								change: function(color){
										that.updateSettingsFromUI();
										//that.createColorScale();
										that.draw(that.data);
									}
								});
							$("#"+that.trackClass+"max"+txtType+that.level).spectrum({
								change: function(color){
										//that.maxColor=color.toHexString();
										that.updateSettingsFromUI();
										//that.createColorScale();
										that.draw(that.data);
									}
								});
						}else{
							$("input#"+that.trackClass+"min"+txtType+that.level).on("change",function(){
								that.updateSettingsFromUI();
								that.draw(that.data);
							});

							$("input#"+that.trackClass+"max"+txtType+that.level).on("change",function(){
								that.updateSettingsFromUI();
								that.draw(that.data);
							});
						}
					}
				}
			}
			if($("#"+that.trackClass+that.level+"colorSelect").val()=="Score"){
				$("div."+that.trackClass+"Scale"+that.level).show();
			}else if($("#"+that.trackClass+that.level+"colorSelect").val()=="Color"){
				$("div."+that.trackClass+"Scale"+that.level).hide();
			}
			var buttonDiv=table.append("tr").append("td");
			buttonDiv.append("input").attr("type","button").attr("value","Remove Track").style("float","left").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
				that.gsvg.removeTrack(that.trackClass);
			});
			buttonDiv.append("input").attr("type","button").attr("value","Apply").style("float","right").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
			});
			buttonDiv.append("input").attr("type","button").attr("value","Cancel").style("float","right").style("margin-left","5px").on("click",function(){
				that.revertPrevious();
				that.draw(that.data);
				$('#trackSettingDialog').fadeOut("fast");
			});
		}else{
			var table=d3.select(topLevelSelector).select("table").select("tbody");
			table.append("tr").append("td").style("font-weight","bold").html("Track Settings: "+d.Name);
			table.append("tr").append("td").html("Sorry no settings for this track.");
			var buttonDiv=table.append("tr").append("td");
			buttonDiv.append("input").attr("type","button").attr("value","Remove Track").style("float","left").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
			});
			buttonDiv.append("input").attr("type","button").attr("value","Cancel").style("float","right").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
			});
		}
	};

	that.generateTrackSettingString=function(){
		return that.trackClass+","+that.density+","+that.colorBy+","+that.minValue+","+that.maxValue+","+that.minColor+","+that.maxColor+";";
	};

	return that;
}

function GenericTranscriptTrack(gsvg,data,trackClass,label,density,additionalOptions){
	var that= Track(gsvg,data,trackClass,label);
	//Set Defaults
	that.dataFileName=trackClass+".xml";
	that.xmlTag="Feature";
	that.xmlTagBlockElem="block";
	that.idPrefix="genTrx";
	that.ttSVG=0;
	that.ttTrackList=new Array();
	that.colorValueField="score";
	that.colorBy="Score";
	that.minValue=1;
	that.maxValue=1000;
	that.minColor="#E6E6E6";
	that.maxColor="#000000";
	that.minFeatureWidth=-1;
	that.ttSVGMinWidth=0;
	that.legendLbl="";
	//Set Specified Options
	var addtlOpt=new String(additionalOptions);
	if(additionalOptions!=undefined && addtlOpt.length>0){
		var opt=addtlOpt.split(",");
		for(var i=0;i<opt.length;i++){
			var optStr=new String(opt[i]);
			if(optStr.indexOf("colorBy=")==0){
				that.colorBy=optStr.substr(optStr.indexOf("=")+1);
			}else if(optStr.indexOf("minColor=")==0){
				that.minColor=optStr.substr(optStr.indexOf("=")+1);
			}else if(optStr.indexOf("maxColor=")==0){
				that.maxColor=optStr.substr(optStr.indexOf("=")+1);
			}else if(optStr.indexOf("minValue=")==0){
				that.minValue=optStr.substr(optStr.indexOf("=")+1);
			}else if(optStr.indexOf("maxValue=")==0){
				that.maxValue=optStr.substr(optStr.indexOf("=")+1);
			}
		}
	}


	//Initialize Y Positioning Variables
	that.yMaxArr=new Array();
	that.yArr=new Array();
	that.yArr[0]=new Array();
	for(var j=0;j<that.gsvg.width;j++){
				that.yMaxArr[j]=0;
				that.yArr[0][j]=0;
	}
	
	that.createColorScale=function (){
		if(that.minColor!=undefined && that.maxColor!=undefined){
			that.colorScale=d3.scale.linear().domain([that.minValue,that.maxValue]).range([that.minColor,that.maxColor]);
		}
	};
	that.createColorScale();

	that.setMinColor=function (color){
		that.minColor="#"+color;
		that.createColorScale();
		that.draw(that.data);
	};

	that.setMaxColor=function(color){
		that.maxColor="#"+color;
		that.createColorScale();
		that.draw(that.data);
	};

	that.setMinValue=function (value){
		that.minValue=value;
		that.createColorScale();
		that.draw(that.data);
	};

	that.setMaxValue=function (value){
		that.maxValue=value;
		that.createColorScale();
		that.draw(that.data);
	};
	that.setColorBy=function(value){
		that.colorBy=value;
		that.createColorScale();
		that.draw(that.data);
	}

	that.getDisplayID=function(d){
		return d.getAttribute("ID");
	};

	that.createToolTip=function(d){
		var tooltip="";
		return tooltip;
	};

	//Pack method does perform additional packing above the default method in track.  
	//May be slightly slower but avoids the waterfall like non optimal packing that occurs with the sorted features.
	that.calcY = function (start,end,i){
		var tmpY=0;
		if(that.density==3){
			if((start>=that.xScale.domain()[0]&&start<=that.xScale.domain()[1])||
				(end>=that.xScale.domain()[0]&&end<=that.xScale.domain()[1])||
				(start<=that.xScale.domain()[0]&&end>=that.xScale.domain()[1])){
				var pStart=Math.round(that.xScale(start));
				if(pStart<0){
					pStart=0;
				}
				var pEnd=Math.round(that.xScale(end));
				if(pEnd>=that.gsvg.width){
					pEnd=that.gsvg.width-1;
				}
				var pixStart=pStart-2;
				if(pixStart<0){
					pixStart=0;
				}
				var pixEnd=pEnd+2;
				if(pixEnd>=that.gsvg.width){
					pixEnd=that.gsvg.width-1;
				}
				//find yMax that is clear this is highest line that is clear
				var yMax=0;
				for(var pix=pixStart;pix<=pixEnd;pix++){
					if(that.yMaxArr[pix]>yMax){
						yMax=that.yMaxArr[pix];
					}
				}
				yMax++;
				//may need to extend yArr for a new line
				var addLine=yMax;
				if(that.yArr.length<=yMax){
					that.yArr[addLine]=new Array();
					for(var j=0;j<that.gsvg.width;j++){
						that.yArr[addLine][j]=0;
					}
				}
				//check a couple lines back to see if it can be squeezed in
				var startLine=yMax-12;
				if(startLine<1){
					startLine=1;
				}
				var prevLine=-1;
				var stop=0;
				for(var scanLine=startLine;scanLine<yMax&&stop==0;scanLine++){
					var available=0;
					for(var pix=pixStart;pix<=pixEnd&&available==0;pix++){
						if(that.yArr[scanLine][pix]>available){
							available=1;
						}
					}
					if(available==0){
						yMax=scanLine;
						stop=1;
					}
				}
				if(yMax>that.trackYMax){
					that.trackYMax=yMax;
				}
				for(var pix=pStart;pix<=pEnd;pix++){
					if(that.yMaxArr[pix]<yMax){
						that.yMaxArr[pix]=yMax;
					}
					that.yArr[yMax][pix]=1;
				}
				tmpY=yMax*15;
			}else{
				tmpY=15;
			}
		}else if(that.density==2){
			tmpY=(i+1)*15;
		}else{
			tmpY=15;
		}
		if(that.trackYMax<(tmpY/15)){
			that.trackYMax=(tmpY/15);
		}
		return tmpY;
	};

	that.getColorValue=function(d){
		return d.getAttribute(that.colorValueField);
	}

	that.color= function (d){
		var color=d3.rgb("#FFFFFF");
		if(that.colorBy=="Score"){
			color=that.colorScale(that.getColorValue(d));
		}else if(that.colorBy=="Color"){
			var colorStr=new String(d.getAttribute("color"));
			var colorArr=colorStr.split(",");
			if(colorArr.length==3){
				color=d3.rgb(colorArr[0],colorArr[1],colorArr[2]);
			}
		}
		return color;
	};

	that.savePrevious=function(){
		that.prevSetting={};
		that.prevSetting.density=that.density;
		that.prevSetting.colorValueField=that.colorValueField;
		that.prevSetting.colorBy=that.colorBy;
		that.prevSetting.minValue=that.minValue;
		that.prevSetting.maxValue=that.maxValue;
		that.prevSetting.minColor=that.minColor;
		that.prevSetting.maxColor=that.maxColor;
	};
	
	that.revertPrevious=function(){
		that.density=that.prevSetting.density;
		that.colorValueField=that.prevSetting.colorValueField;
		that.colorBy=that.prevSetting.colorBy;
		that.minValue=that.prevSetting.minValue;
		that.maxValue=that.prevSetting.maxValue;
		that.minColor=that.prevSetting.minColor;
		that.maxColor=that.prevSetting.maxColor;
		if(that.colorBy=="Score"){
			that.createColorScale();
		}
	};

	that.drawTrx=function (d,i){
		var txG=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).select("#"+that.idPrefix+"tx"+d.getAttribute("ID"));
		exList=getAllChildrenByName(getFirstChildByName(d,that.xmlTagBlockElem+"List"),that.xmlTagBlockElem);
		for(var m=0;m<exList.length;m++){
			var curR=txG.append("rect")
			.attr("x",function(d){ return that.xScale(exList[m].getAttribute("start"))-that.xScale(d.getAttribute("start")); })
			.attr("rx",1)
			.attr("ry",1)
	    	.attr("height",10)
			.attr("width",function(d){ 
					var tmpW=that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start"));
					if(that.minFeatureWidth>0&&tmpW<that.minFeatureWidth){
						tmpW=that.minFeatureWidth;
					}
					return  tmpW;
				})
			//.attr("title",function(d){ return exList[m].getAttribute("ID");})
			.attr("id",function(d,i){
					var id=that.idPrefix+"Ex"+exList[m].getAttribute("ID");
					if(exList[m].getAttribute("ID")==null){
						id=that.idPrefix+"Ex"+d.getAttribute("ID")+"_"+m;
					}
					return id;
				})
			.style("fill",that.color)
			.style("cursor", "pointer");
			if(m>0){
				var intStart=that.xScale(exList[m-1].getAttribute("stop"))-that.xScale(d.getAttribute("start"));
				var intStop=that.xScale(exList[m].getAttribute("start"))-that.xScale(d.getAttribute("start"));
				txG.append("line")
				.attr("x1",intStart)//function(d){ return that.xScale(exList[m-1].getAttribute("stop"))-that.xScale(d.getAttribute("start")); })
				.attr("x2",intStop)//function(d){ return that.xScale(exList[m].getAttribute("start"))-that.xScale(d.getAttribute("start")); })
				.attr("y1",5)
				.attr("y2",5)
				.attr("stroke",that.color)
				.attr("stroke-width","2")
				.attr("id",function(d,i){ 
					var id=that.idPrefix+"Int"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID");
					if(exList[m].getAttribute("ID")==null){
						id=that.idPrefix+"Int"+d.getAttribute("ID")+"_"+(m-1)+"_"+m;
					}
					return id;
					 });
				var strChar=">";
				if(d.getAttribute("strand")=="-1"){
					strChar="<";
				}
				var fullChar=strChar;
				
				var rectW=intStop-intStart;
				var alt=0;
				var charW=6.5;
				if(rectW<charW){
						fullChar="";
				}else{
					rectW=rectW-charW;
					while(rectW>(charW+1)){
						if(alt==0){
							fullChar=fullChar+" ";
							alt=1;
						}else{
							fullChar=fullChar+strChar;
							alt=0;
						}
						rectW=rectW-charW;
					}
				}
				txG.append("svg:text").attr("id",function(d){ 
							var id=that.idPrefix+"IntTxt"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID");
							if(exList[m].getAttribute("ID")==null){
								id=that.idPrefix+"IntTxt"+d.getAttribute("ID")+"_"+(m-1)+"_"+m;
							}
							return id;
						})
					.attr("dx",intStart+1)
					.attr("dy","11")
					.style("pointer-events","none")
					.style("opacity","0.5")
					.style("fill",that.color)
					.style("font-size","16px")
					.text(fullChar);
				
			}
		}
		
	};

	that.redraw = function (){
		if(that.prevDensity!=that.density){
			that.draw(that.data);
		}else{
			that.yMaxArr=new Array();
			that.yArr=new Array();
			that.yArr[0]=new Array();
			for(var p=0;p<that.gsvg.width;p++){
					that.yMaxArr[p]=0;
					that.yArr[0][p]=0;
			}
			that.trackYMax=0;
			var txG=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g."+that.idPrefix+"trx"+that.gsvg.levelNumber)
				.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i)+")";});
			txG.each(function(d,i){
					exList=getAllChildrenByName(getFirstChildByName(d,that.xmlTagBlockElem+"List"),that.xmlTagBlockElem);
					for(var m=0;m<exList.length;m++){
						var id=that.idPrefix+"Ex"+exList[m].getAttribute("ID");
						if(exList[m].getAttribute("ID")==null){
							id=that.idPrefix+"Ex"+d.getAttribute("ID")+"_"+m;
						}
						d3.select("g#"+that.idPrefix+"tx"+d.getAttribute("ID")+" rect#"+id)
							.attr("x",function(d){ return that.xScale(exList[m].getAttribute("start")) -that.xScale(d.getAttribute("start")); })
							.attr("width",function(d){ return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start")); });
						if(m>0){
							var strChar=">";
							if(d.getAttribute("strand")=="-1"){
								strChar="<";
							}
							var fullChar=strChar;
							var intStart=that.xScale(exList[m-1].getAttribute("stop")) -that.xScale(d.getAttribute("start"));
							var intStop=that.xScale(exList[m].getAttribute("start")) -that.xScale(d.getAttribute("start"));
							var rectW=intStop-intStart;
							var alt=0;
							var charW=6.5;
							if(rectW<charW){
									fullChar="";
							}else{
								rectW=rectW-charW;
								while(rectW>(charW+1)){
									if(alt==0){
										fullChar=fullChar+" ";
										alt=1;
									}else{
										fullChar=fullChar+strChar;
										alt=0;
									}
									rectW=rectW-charW;
								}
							}
							var id=exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID");
							if(exList[m].getAttribute("ID")==null){
								id=d.getAttribute("ID")+"_"+(m-1)+"_"+m;
							}
							d3.select("g#"+that.idPrefix+"tx"+d.getAttribute("ID")+" line#"+that.idPrefix+"Int"+id)
								.attr("x1",intStart)
								.attr("x2",intStop);

							d3.select("g#"+that.idPrefix+"tx"+d.getAttribute("ID")+" #"+that.idPrefix+"IntTxt"+id)
								.attr("dx",intStart+1).text(fullChar);
						}
					}
				});
			if(that.density==1){
								that.svg.attr("height", 30);
			}else if(that.density==2){
								that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g."+that.idPrefix+"trx"+that.gsvg.levelNumber).size()+1)*15);
			}else if(that.density==3){
								that.svg.attr("height", (that.trackYMax+1)*15);
			}
			that.redrawSelectedArea();
		}
	};

	that.update=function (d){
		that.redraw();
	};

	that.updateFullData = function(retry,force){
		var tmpMin=that.xScale.domain()[0];
		var tmpMax=that.xScale.domain()[1];
		var file=dataPrefix+"tmpData/regionData/"+that.gsvg.folderName+"/"+that.dataFileName;
		d3.xml(file,function (error,d){
					if(error){
						//console.log(error);
						if(retry==0 || force==1){
							$.ajax({
								url: contextPath +"/"+ pathPrefix +"generateTrackXML.jsp",
				   				type: 'GET',
								data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: that.trackClass, folder: that.gsvg.folderName},
								//data: {chromosome: chr,minCoord:minCoord,maxCoord:maxCoord,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: that.trackClass, folder: folderName,binSize:that.bin},
								dataType: 'json',
				    			success: function(data2){
				    				
				    			},
				    			error: function(xhr, status, error) {
				        			
				    			}
							});
						}
						if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								that.updateFullData(retry+1,0);
							},time);
						}else{
							d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).select("#trkLbl").text("An errror occurred loading Track:"+that.trackClass);
							d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).attr("height", 15);
							that.gsvg.addTrackErrorRemove(that.svg,"#Level"+that.gsvg.levelNumber+that.trackClass);
							that.hideLoading();
						}
					}else{
						if(d==null){
							if(retry>=4){
								data=new Array();
								that.draw(data);
								that.hideLoading();
							}else{
								setTimeout(function (){
									that.updateFullData(retry+1,0);
								},5000);
							}
						}else{
							var data=d.documentElement.getElementsByTagName(that.xmlTag);
							that.draw(data);
							that.hideLoading();
						}
					}
				});
	};

	that.redrawLegend=function (){
		var legend=[];
		var curPos=0;
		if(that.colorBy=="Score"){
			that.drawScaleLegend(that.minValue,that.maxValue+"+",that.legendLbl,that.minColor,that.maxColor,0);
		}else if(that.colorBy=="Color"){
			legend[curPos]={color:"#FFFFFF",label:"User assigned color from track file."};
			that.drawLegend(legend);
		}
		
	};


	/*that.checkDensity=function(){
		var den=-1;
		if($("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").length>0){
			den=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").val();
		}
		return den;
	}
	that.setDensity=function(){
		var tmpDen=that.checkDensity();
		if(tmpDen>0){
			that.density=tmpDen;
		}

	};*/

	that.draw=function(data){
		
		that.data=data;
		that.prevDensity=that.density;
		//that.setDensity();
		that.trackYMax=0;
		that.yArr=new Array();
		that.yArr[0]=new Array();
		for(var j=0;j<that.gsvg.width;j++){
				that.yMaxArr[j]=0;
				that.yArr[0][j]=0;
		}

		d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("."+that.idPrefix+"trx"+that.gsvg.levelNumber).remove();
		that.redrawLegend();
		var tx=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("."+that.idPrefix+"trx"+that.gsvg.levelNumber)
	   			.data(data,key)
				.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i)+")";});
	  	tx.enter().append("g")
				.attr("class",that.idPrefix+"trx"+that.gsvg.levelNumber)
				.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i)+")";})
				.attr("id",function(d){return that.idPrefix+"tx"+d.getAttribute("ID");})
				.attr("pointer-events", "all")
				.style("cursor", "move")
				.on("mouseover", function(d) {
						if(that.gsvg.isToolTip==0&&that.trackClass.indexOf("custom")!=0){ 
							d3.select(this).selectAll("line").style("stroke","green");
							d3.select(this).selectAll("rect").style("fill","green");
							d3.select(this).selectAll("text").style("opacity","0.3").style("fill","green");
	            			tt.transition()        
								.duration(200)      
								.style("opacity", 1);      
							tt.html(that.createToolTip(d))  
								.style("left", function(){return that.positionTTLeft(d3.event.pageX);})     
								.style("top", function(){return that.positionTTTop(d3.event.pageY);});
							if(that.ttSVG==1){
								that.setupToolTipSVG(d,0.05);
							}
						}
	            	})
				.on("mouseout", function(d) {
						//if(that.gsvg.isToolTip==0){ 
							/*mouseTTOver=0;
							console.log("FEATURE MOUSEOUT");*/
								//var tmpThis=this;
								//ttHideHandle=setTimeout(function(){
												
												//if(mouseTTOver==0){
												//	console.log("MOUSE STILL NOT OVER TT");
													d3.select(this).selectAll("line").style("stroke",that.color);
													d3.select(this).selectAll("rect").style("fill",that.color);
													d3.select(this).selectAll("text").style("opacity","0.6").style("fill",that.color);  
													tt.transition()
														 .delay(100)       
														.duration(200)      
														.style("opacity", 0);
												/*}else{
													console.log("MOUSE IS NOW OVER TT")
												}*/
								//			},2000);
						//}
	        		})
				.each(that.drawTrx);
		tx.exit().remove();
		if(that.density==1){
							that.svg.attr("height", 30);
		}else if(that.density==2){
							that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g."+that.idPrefix+"trx"+that.gsvg.levelNumber).size()+1)*15);
		}else if(that.density==3){
							that.svg.attr("height", (that.trackYMax+2)*15);
		}
		that.redrawSelectedArea();
	};
	return that;
}

window['GenomeSVG']=GenomeSVG;

