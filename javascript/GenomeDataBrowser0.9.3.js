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
var svgList=new Array();
var processAjax=0;
var ajaxList=new Array();
var selectedGeneSymbol="";
var selectedID="";
var trackSettings=new Array();
var overSelectable=0;

var ratOnly=new Array();
var mouseOnly=new Array();

var customTrackCount=0;

//var defaultMouseFunct="pan";

ratOnly["snpSHRJ"]=1;
ratOnly["snpF344"]=1;
ratOnly["snpSHRH"]=1;
ratOnly["snpBNLX"]=1;
ratOnly["helicos"]=1;
ratOnly["spliceJnct"]=1;
ratOnly["illuminaTotal"]=1;
ratOnly["illuminaSmall"]=1;
ratOnly["illuminaPolyA"]=1;



var mmVer="Mouse(mm10) Strain:C57BL/6J";
var rnVer="Rat(rn5) Strain:BN";
var siteVer="PhenoGen v2.10.6(3/13/2014)";

var trackBinCutoff=10000;
var customTrackLevel=-1;



//setup tooltip text div
var tt=d3.select("body").append("div")   
	    	.attr("class", "testToolTip") 
	    	.attr("pointer-events", "all")              
	    	.style("opacity", 0)
	    	/*.on("mouseover",function(){
	    		console.log("Mouse OVER TT");
	    		mouseTTOver=1;
	    	})
	    	.on("mouseout",function(){
	    		console.log("Mouse OUT TT");
	    		if(mouseTTOver==1){
	    			setTimeout(function(){
		    		mouseTTOver=0;
		    		tt.transition()
								 .delay(500)       
				                .duration(200)      
				                .style("opacity", 0);
				    },500);
			    }
	    	})*/;



//setup event handlers
d3.select('html')
      .on("mousemove", mmove)
	  .on("mouseup", mup);

$(document).on('click','span.viewMenu', function (event){
	var baseName = $(this).attr("name");
    $('span.viewMenu.selected').removeClass("selected");
    $("span[name='"+baseName+"']").addClass("selected");
    //load default view
    defaultView=baseName;
    svgList[0].removeAllTracks();
    loadState(0);
});

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
					return false;
				});

$(document).on("click",".settings",function(){
					var setting=$(this).attr("id");
					if(!$("."+setting).is(":visible")){
						var p=$(this).position();
						$("."+setting).css("top",p.top-3).css("left",p.left-277);
						$("."+setting).fadeIn("fast");
						//var tmpStr=new String(setting);
						//setupSettingUI(tmpStr.substr(tmpStr.length-1));
					}else{
						$("."+setting).fadeOut("fast");
					}
					return false;
				});
			
$(document).on("change","input[name='trackcbx']",function(){
	 			//var type=$(this).val();
				//var typeStr=new String(type);
				var idStr=new String($(this).attr("id"));
				var cbxInd=idStr.indexOf("CBX");
				var prefix=new String(idStr.substr(0,cbxInd));
				var level=idStr.substr(idStr.length-1);
				if($(this).is(":checked")){
					var addtlOpt="";
					if(level==1){
						addtlOpt="DrawTrx";
					}
					/*if(prefix.indexOf("coding") || prefix.indexOf("noncoding")||prefix.indexOf("smallnc")){
						var tmpType=idStr.substr(idStr.length-2,1);
						if(tmpType=="g"){
							addtlOpt="annotOnly;";
						}else if(tmpType=="t"){
							addtlOpt="trxOnly;";
						}
					}*/
					if(d3.select("#Level"+level+prefix).size()>0){
						redrawTrack(level,prefix);
					}else{
						if($("#"+prefix+"Dense"+level+"Selectg").length>0){
							svgList[level].addTrack(prefix,$("#"+prefix+"Dense"+level+"Selectg").val(),addtlOpt,0);
						}else{
							svgList[level].addTrack(prefix,$("#"+prefix+"Dense"+level+"Select").val(),addtlOpt,0);
						}
					}
				}else{
					var isSelected=0;
					$(".settingsLevel"+level+" [id^="+prefix+"CBX]").each(function (){
						if($(this).is(":checked")){
							isSelected=1;
						}
					});
					if(isSelected==0){
						removeTrack(level,prefix);
					}else{
						redrawTrack(level,prefix);
					}
				}
				saveToCookie(level);
	 		});
$(document).on("change","select[name='trackSelect']",function(){
				var idStr=new String($(this).attr("id"));
				//console.log("TrackSelect:"+idStr);
				var cl=$(this).attr("class");
				var value=$(this).val();
				var level=idStr.substr(idStr.length-7,1);
				if(level=="S"){
					level=idStr.substr(idStr.length-8,1);
				}
				//console.log("TrackSelect Level:"+level);
				if(svgList[level]!=undefined){
					try{
						if(idStr.indexOf("Dense")>0){
							if(idStr.indexOf("coding")>-1 || idStr.indexOf("smallnc")>-1){
								$("."+cl).each(function(){
									$(this).val(value);
								});
							}
							svgList[level].redraw();
						}else if(idStr.indexOf("snp")==0){
							svgList[level].updateData();
						}else{
							svgList[level].redraw();
						}
					}catch(err){
						bugsense.notify( err, { controlID:idStr,level:level } );
					}
				}
				saveToCookie(level);

	 		});

$(document).on("change","select[name='colorSelect']",function(){
				var idStr=new String($(this).attr("id"));
				var value=$(this).val();
				var level=idStr.substr(idStr.length-12,1);
				if(value=="dabg" || value=="herit"){
						$("div#affyTissues"+level).show();
				}else if(value=="annot"){
						$("div#affyTissues"+level).hide();
				}
				if($("#probeCBX"+level).is(":checked")){
					redrawTrack(level,"probe");
					saveToCookie(level);
				}
	 		});
$(document).on("change","input[name='tissuecbx']",function(){
	 			var idStr=new String($(this).attr("id"));
				var level=idStr.substr(idStr.length-1,1);
				if($("#probeCBX"+level).is(":checked")){
					redrawTrack(level,"probe");
					saveToCookie(level);
				}
	 		});

$(document).on("change","select[name='imgSelect']", function(){
				var id=new String($(this).attr("id"));
				var len=id.length-1;
				var curlvl=id.substr(len);
	 			changeTrackHeight("Level"+curlvl,$(this).val());
	 			$.cookie("imgstate"+defaultView+curlvl,"displaySelect"+curlvl+"="+$(this).val()+";");
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
		saveToCookie(level);
	}
});
$(document).on("change","input[name='optioncbx']",function(){
	var idStr=new String($(this).attr("id"));
	var cbxInd=idStr.indexOf("CBX");
	var prefix=new String(idStr.substr(0,cbxInd));
	var level=idStr.substr(cbxInd+3,1);
	redrawTrack(level,prefix);
});


/*$(document).on("click",".saveImage",function(){
	var id=$(this).attr("id");
	var levelID=(new String(id)).substr(4);
	var content=$("div#"+levelID).html();
		content+"\n";
		$.ajax({
				url: pathPrefix+"saveBrowserImage.jsp",
   				type: 'POST',
				contentType: 'text/html',
				data: content,
				processData: false,
				dataType: 'json',
    			success: function(data2){ 
        			//console.log(data2.imageFile);
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
															    	console.log("xhr status:"+status);
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
																	$("#"+id).append("<span style='color:#FF0000;'>Your browser will not save the image directly. Image will open in a popup, in the new window right click to save image.</span>");
																	window.open(url);
																}	
																delete a;
															    return true;
															}
					  /*xhr.onload = function() {
						var a = document.createElement('a');
						a.href = window.URL.createObjectURL(xhr.response); // xhr.response is a blob
						a.download = filename; // Set the file name.
						a.style.display = 'none';
						document.body.appendChild(a);
						a.click();
						delete a;
					  };*/
					  
/*				},
    			error: function(xhr, status, error) {
        			console.log(error);
    			}
			});
});*/

function confirmUpload(level){
	$("div#confirmUpload"+level).show();
	$("div#uploadBtn"+level).hide();
}
function confirmBed(level){
	$("input#hasconfirmBed"+level).val(1);
	createCustomTrack(level);
}
function cancelUpload(level){
	$("div#confirmUpload"+level).hide();
	$("div#confirmBed"+level).hide();
	$("div#uploadBtn"+level).show();
}
function createCustomTrack(level){
	$("div#confirmUpload"+level).hide();
	customTrackLevel=level;
	var file = $("input#customBedFile"+level)[0].files[0]; //Files[0] = 1st file
	var fName=file.name;
	var fSize=(file.size/1000.0)/1000.0;
	$(".uploadStatus").show();
	var fExt="";
	if(fName.indexOf(".")>0){
		var ind=0;
		var fTrunc=fName;
		while(fTrunc.indexOf(".")>-1){
			fTrunc=fTrunc.substr(fTrunc.indexOf(".")+1);
		}
		if(fTrunc!="" && fTrunc!=fName){
			fExt=fTrunc;
		}
	}
	//check file size and extension
	if(fSize<20){
		if(fExt!="bed"){
			if(fExt=="gz"||fExt=="tar"||fExt=="zip"||fExt=="exe"||fExt=="bin"){
				//cancel with no support
				setTimeout(function(){
        				$("div#uploadBtn"+customTrackLevel).show();
        				$(".progressInd").hide();
        			},5000);
				$(".uploadStatus").html("Error: Selected File Type is not supported.");
			}else if($("input#hasconfirmBed"+level).val()==0){
				//display confirmation
				$("div#confirmBed"+customTrackLevel).show();
			}else if($("input#hasconfirmBed"+level).val()==1){
				$("div#confirmBed"+customTrackLevel).hide();
				//continue
				readFile(file);
			}
		}else{
			readFile(file);
		}
	}else{
		$("div#uploadBtn"+customTrackLevel).show();
        $(".progressInd").hide();
		$(".uploadStatus").html("File is too large.  20MB is the current limit.");
	}
}

function readFile(file){
	var reader = new FileReader();
	reader.readAsText(file, 'UTF-8');
	reader.onload = sendFile;
}

function sendFile(event){
	var result = event.target.result;
	$.ajax({
				url: pathPrefix+"trackUpload.jsp",
   				type: 'POST',
				contentType: 'text/plain',
				xhr: function() {  // Custom XMLHttpRequest
		            var myXhr = $.ajaxSettings.xhr();
		            //if(myXhr.upload){ // Check if upload property exists
		                myXhr.upload.addEventListener('progress',progressHandlingFunction, false); // For handling the progress of the upload
		            //}
		            return myXhr;
		        },
				data: result,
				processData: false,
				cache: false,
				dataType: 'json',
    			success: function(data2){
        			$(".uploadStatus").html("Upload Completed Successfully");
        			var tmp=new Date();
        			//add new custom track to Custom Track Cookie
        			var track=data2.trackFile.substring(0,data2.trackFile.length-4)

        			var trackToAdd="custom"+track+",organism="+organism+",created="+tmp.toDateString()+",dispTrackName="+$("input#usrtrkNameTxt"+customTrackLevel).val()+",originalFile="+$("input#customBedFile"+customTrackLevel)[0].files[0].name+",";
        			if($("#usrtrkColorSelect"+customTrackLevel).val()=="Score"){
        				trackToAdd=trackToAdd+"colorBy=Score,";
        				trackToAdd=trackToAdd+"minValue="+$("#usrtrkScoreMinTxt"+customTrackLevel).val()+",";
        				trackToAdd=trackToAdd+"maxValue="+$("#usrtrkScoreMaxTxt"+customTrackLevel).val()+",";
        				trackToAdd=trackToAdd+"minColor=#"+$("#usrtrkColorMin"+customTrackLevel).val()+",";
        				trackToAdd=trackToAdd+"maxColor=#"+$("#usrtrkColorMax"+customTrackLevel).val()+",";
        			}else{
						trackToAdd=trackToAdd+"colorBy=Color,";
        			}
        			saveCustomTrackCookie(trackToAdd+";");
        			//load the track from the new cookie
        			svgList[customTrackLevel].addTrack("custom"+track,3,"",0);
        			//update the Custom UI 
        			addCustomTrackUI(trackToAdd,1);

        			//reset some of the inputs
        			$("input#customBedFile"+customTrackLevel).val("");
        			$("input#usrtrkNameTxt"+customTrackLevel).val("");
        			$("#usrtrkColorSelect"+customTrackLevel).val("color");
        			setTimeout(function(){
        				$("div#uploadBtn"+customTrackLevel).show();
        				$(".progressInd").hide();
        				$(".uploadStatus").hide();
        				saveToCookie(customTrackLevel);
        			},15000);
    			},
    			error: function(xhr, status, error) {
        			console.log(error);
        			$(".uploadStatus").html("Error:"+error);
        			$("div#uploadBtn"+customTrackLevel).show();
    			}
			});
}

function progressHandlingFunction(e){
	$(".progressInd").show();
	$(".uploadStatus").html("Uploading...");
    if(e.lengthComputable){
        $('progress').attr({value:e.loaded,max:e.total});
    }
}


function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function displayHelpFirstTime(){
	/*if($.cookie("genomeBrowserHelp")!=null){
    	var trackListObj=$.cookie("genomeBrowserHelp");
    	if(trackListObj==siteVer){

    	}else{
    		$("a#helpExampleNav").click();
    		$.cookie("genomeBrowserHelp",siteVer);
    	}
    }else{*/
    //	$("a#helpExampleNav").click();
    /*	$.cookie("genomeBrowserHelp",siteVer);
    }*/
}

function mup() {
	for (var i=0; i<svgList.length; i++){
		if(svgList[i]!=null){
			if(!isNaN(svgList[i].downx)|| !isNaN(svgList[i].downPanx)){
				if(i==0){
					updatePage(svgList[i]);
				}
        		svgList[i].downx = Math.NaN;
				svgList[i].downPanx = Math.NaN;
				svgList[i].updateFullData();
				if(i==0){
					DisplayRegionReport();
				}
			}else if(!isNaN(svgList[i].downZoomx)){
				var start=svgList[i].downZoomx;
				var p = d3.mouse(svgList[i].vis[0][0]);
				svgList[i].downZoomxEnd=p[0];
				var width=1;
				if(p[0]<start){
					start=p[0];
					width=svgList[i].downZoomx-start;
				}else{
					width=p[0]-start;
				}
				var minx=Math.round(svgList[i].xScale.invert(start));
				var maxx=Math.round(svgList[i].xScale.invert(start+width));
				svgList[i].downZoomx = Math.NaN;
				svgList[i].downZoomxEnd = Math.NaN;
				if(i==0){
					$('#geneTxt').val(chr+":"+minx+"-"+maxx);
				}
				d3.select("#Level"+svgList[i].levelNumber).selectAll("svg rect.zoomRect").remove();
				d3.select("#Level"+svgList[i].levelNumber).selectAll("svg text#zoomTextStart").remove();
				d3.select("#Level"+svgList[i].levelNumber).selectAll("svg text#zoomTextEnd").remove();
	            svgList[i].xScale.domain([minx,maxx]);
				svgList[i].scaleSVG.select(".x.axis").call(svgList[i].xAxis);
				svgList[i].redraw();
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
						if(maxx<=svgList[i].xMax && minx>=svgList[i].xMin){
							if(i==0){
								$('#geneTxt').val(chr+":"+minx+"-"+maxx);
							}
							svgList[i].xScale.domain([minx,maxx]);
							svgList[i].scaleSVG.select(".x.axis").call(svgList[i].xAxis);
							svgList[i].redraw();
							svgList[i].downPanx=p[0];
						}
					
				  }
			}else if(!isNaN(svgList[i].downZoomx)){
				var start=svgList[i].downZoomx;
				var p = d3.mouse(svgList[i].vis[0][0]);
				svgList[i].downZoomxEnd=p[0];
				var width=1;
				if(p[0]<start){
					start=p[0];
					width=svgList[i].downZoomx-start;
				}else{
					width=p[0]-start;
				}
				var minx=Math.round(svgList[i].xScale.invert(start));
				var maxx=Math.round(svgList[i].xScale.invert(start+width));
				d3.select("#Level"+svgList[i].levelNumber).selectAll("svg rect.zoomRect")
								.attr("x",start)
								.attr("width",width);
				d3.select("#Level"+svgList[i].levelNumber).selectAll("svg text#zoomTextStart").attr("x",start).attr("y",15).text(numberWithCommas(minx));
				d3.select("#Level"+svgList[i].levelNumber).selectAll("svg text#zoomTextEnd").attr("x",start+width).attr("y",50).text(numberWithCommas(maxx));
			}
		}
	}
}

function updatePage(topSVG){
	var min=Math.round(topSVG.xScale.domain()[0]);
	var max=Math.round(topSVG.xScale.domain()[1]);
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
function loadState(levelInd){
	loadCustomTracksCookie();
	setupSettingUI(levelInd);
	loadSavedConfigTracks(levelInd);
	loadImageState(levelInd);
}

function setupSettingUI(levelInd){
	setupTrackSettingUI(levelInd);
	setupImageSettingUI(levelInd);
}

function loadSavedConfigTracks(levelInd){
	if($.cookie("state"+defaultView+levelInd+"trackList")!=null){
    	var trackListObj=$.cookie("state"+defaultView+levelInd+"trackList");
    	var trackArray=trackListObj.split(";");
    	var addedCount=0;
    	for(var m=0;m<trackArray.length;m++){
    		var trackVars=trackArray[m].split(",");
    		if(organism=="Rn" || (organism=="Mm" && ratOnly[trackVars[0]]== undefined)){
	    		if(trackVars[0]!=""){
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
	    			svgList[levelInd].addTrack(trackVars[0],trackVars[1],ext,0);
	    		}
    		}
    	}
    	if(addedCount==0){
    		setupDefaultView(levelInd);
    		saveToCookie(levelInd);
    	}
	}else{
		setupDefaultView(levelInd);
    	saveToCookie(levelInd);
	}
}

function loadImageState(levelInd){
	if($.cookie("imgstate"+defaultView+levelInd)!=null){
    	var trackListObj=$.cookie("imgstate"+defaultView+levelInd);
    	var trackArray=trackListObj.split(";");
    	for(var m=0;m<trackArray.length;m++){
    		var trackVars=trackArray[m].split("=");
    		var tmp=new String(trackVars[0]);
    		if(tmp.indexOf("displaySelect")==0){
    			changeTrackHeight("Level"+levelInd,trackVars[1]);
    		}
    	}

	}	
}

function setupTrackSettingUI(levelInd){
	if($.cookie("state"+defaultView+levelInd+"trackList")!=null){
    	var trackListObj=$.cookie("state"+defaultView+levelInd+"trackList");
    	var trackArray=trackListObj.split(";");
    	$("div.settingsLevel"+levelInd+" input[name='trackcbx']").each(function(){
    		if($(this).is(":checked")){
    			$(this).prop('checked', false);
    		}
    	});
    	for(var m=0;m<trackArray.length;m++){
    		var trackVars=trackArray[m].split(",");
    		if(trackVars[0]!=""){
    			if(trackVars[0]=="noncoding"||trackVars[0]=="coding"||trackVars[0]=="smallnc"){
    				if(trackVars[2]!=undefined){
    					if(trackVars[2]=="annotOnly"){
    						$("div.settingsLevel"+levelInd+" #"+trackVars[0]+"CBXg"+levelInd).prop('checked',true);
    					}else if(trackVars[2]=="trxOnly"){
    						$("div.settingsLevel"+levelInd+" #"+trackVars[0]+"CBXt"+levelInd).prop('checked',true);
    					}else{
    						$("div.settingsLevel"+levelInd+" #"+trackVars[0]+"CBXg"+levelInd).prop('checked',true);
							$("div.settingsLevel"+levelInd+" #"+trackVars[0]+"CBXt"+levelInd).prop('checked',true);
    					}
					}else{
						$("div.settingsLevel"+levelInd+" #"+trackVars[0]+"CBXg"+levelInd).prop('checked',true);
						$("div.settingsLevel"+levelInd+" #"+trackVars[0]+"CBXt"+levelInd).prop('checked',true);
					}
    			}else{
    				$("div.settingsLevel"+levelInd+" #"+trackVars[0]+"CBX"+levelInd).prop('checked',true);
    			}
    			if($("div.settingsLevel"+levelInd+" #"+trackVars[0]+"Dense"+levelInd+"Select").length>0 
    				&& trackVars[1]!=undefined){
    				$("div.settingsLevel"+levelInd+" #"+trackVars[0]+"Dense"+levelInd+"Select").val(trackVars[1]);
    			}else if( ($("div.settingsLevel"+levelInd+" #"+trackVars[0]+"Dense"+levelInd+"Selectg").length>0||
    						$("div.settingsLevel"+levelInd+" #"+trackVars[0]+"Dense"+levelInd+"Selectt").length>0) 
    					  && trackVars[1]!=undefined){
    				$("div.settingsLevel"+levelInd+" #"+trackVars[0]+"Dense"+levelInd+"Selectt").val(trackVars[1]);
    				$("div.settingsLevel"+levelInd+" #"+trackVars[0]+"Dense"+levelInd+"Selectg").val(trackVars[1]);
    			}
    			if($("div.settingsLevel"+levelInd+" #"+trackVars[0]+levelInd+"Select").length>0  && trackVars[2]!=undefined){
    				$("div.settingsLevel"+levelInd+" #"+trackVars[0]+levelInd+"Select").val(trackVars[2]);
    			}
    		}

    	}
	}else{
		//console.log("no cookie:"+"state"+defaultView+levelInd+"trackList");
	}
}

function setupImageSettingUI(levelInd){
	if($.cookie("imgstate"+defaultView+levelInd)!=null){
    	var trackListObj=$.cookie("imgstate"+defaultView+levelInd);
    	var trackArray=trackListObj.split(";");
    	for(var m=0;m<trackArray.length;m++){
    		var trackVars=trackArray[m].split("=");
    		$("#"+trackVars[0]).val(trackVars[1]);
    		/*var tmp=new String(trackVars[0]);
    		if(tmp.indexOf("displaySelect")==0){
    			changeTrackHeight("Level"+levelInd,trackVars[1]);
    		}*/
    	}

	}
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
		$("div.settingsLevel"+levelInd+" #codingCBXg"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #noncodingCBXg"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #smallncCBXg"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #refSeqCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #snpSHRHCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #snpBNLXCBX"+levelInd).prop('checked',true);
		svgList[levelInd].addTrack("coding",3,addtl,0);
    	svgList[levelInd].addTrack("noncoding",3,addtl,0);
    	svgList[levelInd].addTrack("smallnc",3,addtl,0);
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
		$("div.settingsLevel"+levelInd+" #codingCBXt"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #spliceJnctCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #noncodingCBXt"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #probeCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #smallncCBXt"+levelInd).prop('checked',true);
		svgList[levelInd].addTrack("coding",3,addtl,0);
		svgList[levelInd].addTrack("spliceJnct",3,addtl,0);
    	svgList[levelInd].addTrack("noncoding",3,addtl,0);
    	svgList[levelInd].addTrack("smallnc",3,addtl,0);
    	svgList[levelInd].addTrack("probe",3,"",0);
	}else if(defaultView=="viewAll"){
		var addtl="all";
		if(levelInd==1){
			addtl=addtl+",DrawTrx";
		}
		$("div.settingsLevel"+levelInd+" #codingCBXg"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #codingCBXt"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #spliceJnctCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #noncodingCBXg"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #noncodingCBXt"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #smallncCBXg"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #smallncCBXt"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #refSeqCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #probeCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #snpSHRHCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #snpBNLXCBX"+levelInd).prop('checked',true);
		svgList[levelInd].addTrack("coding",3,addtl,0);
		svgList[levelInd].addTrack("spliceJnct",3,addtl,0);
    	svgList[levelInd].addTrack("noncoding",3,addtl,0);
    	svgList[levelInd].addTrack("smallnc",3,addtl,0);
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

function saveToCookie(curLevel){
	var cookieStr="";
	$( "#sortable"+curLevel+" li svg").each(function() {
	        var id = (new String ($(this).attr("id"))).substr(6);
	        cookieStr=cookieStr+id;
	        if($("#"+id+"Dense"+curLevel+"Select").length > 0){
	          	cookieStr=cookieStr+","+$("#"+id+"Dense"+curLevel+"Select").val();
	        }else if($("#"+id+"Dense"+curLevel+"Selectg").length > 0){
	          	cookieStr=cookieStr+","+$("#"+id+"Dense"+curLevel+"Selectg").val();
	        }else if($("#"+id+"Dense"+curLevel+"Selectt").length > 0){
	          	cookieStr=cookieStr+","+$("#"+id+"Dense"+curLevel+"Selectt").val();
	        }
	        if($("#"+id+curLevel+"Select").length > 0){
	          	cookieStr=cookieStr+","+$("#"+id+curLevel+"Select").val();
	        }
	        if($("#"+id+"CBXg"+curLevel).length>0){
	        		var curAnnot="";
		          	if($("#"+id+"CBXg"+curLevel).is(":checked")
						&&
						$("#"+id+"CBXt"+curLevel).is(":checked")){
						curAnnot="all";
					}else if($("#"+id+"CBXg"+curLevel).is(":checked")){
						curAnnot="annotOnly";
					}else if($("#"+id+"CBXt"+curLevel).is(":checked")){
						curAnnot="trxOnly";
					}
					cookieStr=cookieStr+","+curAnnot;
	        }
          cookieStr=cookieStr+";";
        });
	//Need to preserve Rat or Mouse Only tracks and custom tracks while other species is viewed
	if($.cookie("state"+defaultView+curLevel+"trackList")!=null){
    	var trackListObj=$.cookie("state"+defaultView+curLevel+"trackList");
    	var trackArray=trackListObj.split(";");
    	for(var m=0;m<trackArray.length;m++){
    		var trackVars=trackArray[m].split(",");
    		if((organism=="Rn" && mouseOnly[trackVars[0]]!= undefined) || (organism=="Mm" && ratOnly[trackVars[0]]!= undefined)){
	    		cookieStr=cookieStr+trackArray[m]+";";
    		}else if(trackVars[0].indexOf("custom")==0){//Supports preserving custom tracks.  Will add any of the opposite species to the new cookieStr
    			var trackStr=loadCustomTrackCookie(trackVars[0]);
    			var trkOrg=trackStr.substr(trackStr.indexOf("organism=")+9,2);
    			if(organism!=trkOrg){
    				cookieStr=cookieStr+trackStr+";";
    			}
    		}
    	}
    }
	$.cookie("state"+defaultView+curLevel+"trackList",cookieStr);
}


function loadCustomTracksCookie(){
	loadCustomTrackCookieUI();
}

function saveCustomTrackCookie(newTrack){
	var existingCookieStr="";
	if($.cookie("customTrackList")!=null){
    	existingCookieStr=$.cookie("customTrackList");
    }
    existingCookieStr=existingCookieStr+newTrack;
    $.cookie("customTrackList",existingCookieStr);
}

function removeCustomTrackCookie(removeTrack){
	var existingCookieStr="";
	var newCookieStr="";
	if($.cookie("customTrackList")!=null){
    	existingCookieStr=$.cookie("customTrackList");
    	var trackArray=existingCookieStr.split(";");
    	for(var m=0;m<trackArray.length;m++){
    		if(trackArray[m].indexOf(removeTrack)==0){
    			console.log("removed track from cookie:"+trackArray[m]);
    		}else{
    				newCookieStr=newCookieStr+trackArray[m]+";";
    		}
    	}
    }
    $.cookie("customTrackList",newCookieStr);
}

function loadCustomTrackCookieUI(){
	var existingCookieStr="";
	if($.cookie("customTrackList")!=null){
    	existingCookieStr=$.cookie("customTrackList");
    	var trackArray=existingCookieStr.split(";");
    	var addedCount=0;
    	for(var m=0;m<trackArray.length;m++){
    		if(trackArray[m].indexOf("custom")==0 && trackArray[m].indexOf("organism="+organism)>0){
    			addCustomTrackUI(trackArray[m],0);
    		}
    	}
    }
}

function addCustomTrackUI(trackString,checked){
	var dispName="";
	var date="";
	var filename="";

	var details=trackString.split(",");
	var id=details[0];

	for(var m=1;m<details.length;m++){
		if(details[m].indexOf("dispTrackName=")==0){
			dispName=details[m].substr(details[m].indexOf("=")+1);
		}
		if(details[m].indexOf("originalFile=")==0){
			filename=details[m].substr(details[m].indexOf("=")+1);
		}
		if(details[m].indexOf("created=")==0){
			date=details[m].substr(details[m].indexOf("=")+1);
		}
	}
	$(".usrTrack").each(function(){
		var divID=$(this).attr("id");
		var level=$(this).attr("id").substr(8);
		var trackDiv=d3.select("#"+divID).append("div").attr("class","custTrack"+id);
		//var tmp=$(this).html();
		var check="";
		if(checked==1){
			check="checked=\"checked\"";
		}

        var tmp="<input name=\"trackcbx\" type=\"checkbox\" id=\""+id+"CBX"+level+"\""+check+"> "+dispName;
		tmp=tmp+" <span class=\"tracktooltip"+level+"\" id=\""+id+"InfoDesc"+level+"\" title=\"Custom Track<BR>Defined: "+date+"<BR>Original Filename: "+filename+"\"><img src=\"web/images/icons/info.gif\"></span><select name=\"trackSelect\" class=\""+id+"Dense"+level+"Select\" id=\""+id+"Dense"+level+"Select\">";
        tmp=tmp+"<option value=\"1\" >Dense</option><option value=\"3\" selected=\"selected\">Pack</option>";
        tmp=tmp+"<option value=\"2\" >Full</option></select>";
        //tmp=tmp+"<input type=\"button\" id=\""+id+"ColorBtn"+level+"\" value=\"Edit Color\" onClick=\"showCustomColor('"+id+"','"+level+"')\">";
        tmp=tmp+"&nbsp&nbsp&nbsp<span id=\""+id+"ColorBtn"+level+"\" title=\"Edit Color\" style=\"cursor:pointer;\"><img src=\"web/images/icons/color_sm2.png\"></span>";
        //tmp=tmp+"&nbsp&nbsp&nbsp<span title=\"Save as Track Default Settings\" style=\"cursor:pointer;\"><img src=\"web/images/icons/disk_sm.png\"></span>";
        //tmp=tmp+"<input type=\"button\" id=\""+id+"SaveBtn"+level+"\" value=\"Save As Default\" title=\"Saves the current track settings as the default settings in the future.\" onClick=\"saveDefault('"+id+"','"+level+"')\">";
        /**/
        tmp=tmp+"<span class=\"delCustom\"  id=\""+id+"Delete"+level+"\" title=\"Delete Custom Track\" style=\"float:right;cursor:pointer;\"><img src=\"web/images/icons/delete.png\">"+"</span>";
        tmp=tmp+"<div id=\""+id+"Scale"+level+"\" style=\"display:none;\">Color*:<select id=\""+id+"ColorSelect"+level+"\" class=\"usrtrkColor\" id=\"\">";
       	tmp=tmp+"<option value=\"Score\" >Score based scale</option>";
        tmp=tmp+"<option value=\"Color\" selected=\"selected\">Feature defined</option></select>";
        tmp=tmp+"<div id=\""+id+"ScaleSetting"+level+"\" style=\"display:none;\">Setup Scale:Data:<input id=\""+id+"minData"+level+"\" type=\"text\" size=\"4\"> - <input id=\""+id+"maxData"+level+"\" type=\"text\" size=\"4\"> <BR>";
        tmp=tmp+"Color: <input id=\""+id+"minColor"+level+"\" class=\"color\" size=\"6\" value=\"FFFFFF\"> - <input id=\""+id+"maxColor"+level+"\" class=\"color\" size=\"6\" value=\"000000\"></div></div><HR />";
        trackDiv.html(tmp);

        $("div#usrTrack"+level+" span#"+id+"InfoDesc"+level).each(function(){
				$(this).tooltipster({
					position: 'top-right',
					maxWidth: 250,
					offsetX: 10,
					offsetY: 5,
					contentAsHTML:true,
					//arrow: false,
					interactive: true,
					interactiveTolerance: 350
				});
			});
        $("div#usrTrack"+level+" span#"+id+"Delete"+level).each(function(){
        		$(this).on("click",function(){
        			var tmpID=$(this).attr("id");
        			tmpID=tmpID.substring(0,tmpID.length-7);
        			deleteCustomTrack(tmpID);
        			});
        	});
       	$("div#usrTrack"+level+" #"+id+"ColorSelect"+level).each(function(){
        		$(this).on("change",function(){
        			var tmpID=$(this).attr("id");
        			tmpID=tmpID.substring(0,tmpID.length-12);
        			if($(this).val()=="Score"){
        				$("div#"+tmpID+"ScaleSetting"+level).show();
        			}else{
        				$("div#"+tmpID+"ScaleSetting"+level).hide();
        			}
        			var track=svgList[level].getTrack(tmpID);
        			track.setColorBy($(this).val());
        			});
        	});
       	$("span#"+id+"ColorBtn"+level).each(function(){
       		$(this).on("click",function(){
       			if($("div#"+id+"Scale"+level).is(':visible')){
					$("div#"+id+"Scale"+level).hide();
					//$("#"+id+"ColorBtn"+level).prop("value","Edit Color");
				}else{
					$("div#"+id+"Scale"+level).show();
					//$("#"+id+"ColorBtn"+level).prop("value","Hide Edit Color");
				    var track=svgList[level].getTrack(id);
				    $("#"+id+"ColorSelect"+level).val(track.colorBy);
				    if(track.colorBy=="Score"){
				    	$("div#"+id+"ScaleSetting"+level).show();
				    }else{
				    	$("div#"+id+"ScaleSetting"+level).hide();
				    }
				    if(track!=undefined && track.minColor!=undefined&&track.maxColor!=undefined){
				        $("#"+id+"minData"+level).val(track.minValue);
				        $("#"+id+"maxData"+level).val(track.maxValue);
				        document.getElementById(id+"minColor"+level).color.fromString(track.minColor);
				        document.getElementById(id+"maxColor"+level).color.fromString(track.maxColor);
				    }
				}
       		});
       	});

		$("div#usrTrack"+level+" #"+id+"minColor"+level).each(function(){
        	$(this).on("change",function(){
        		var tmpID=$(this).attr("id");
        		tmpID=tmpID.substring(0,tmpID.length-9);
        		var track=svgList[level].getTrack(tmpID);
        		track.setMinColor($(this).val());
        	});
        });
        $("div#usrTrack"+level+" #"+id+"maxColor"+level).each(function(){
        	$(this).on("change",function(){
        		var tmpID=$(this).attr("id");
        		tmpID=tmpID.substring(0,tmpID.length-9);
        		var track=svgList[level].getTrack(tmpID);
        		track.setMaxColor($(this).val());
        	});
        });
        $("div#usrTrack"+level+" #"+id+"minData"+level).each(function(){
        	$(this).on("change",function(){
        		var tmpID=$(this).attr("id");
        		tmpID=tmpID.substring(0,tmpID.length-8);
        		var track=svgList[level].getTrack(tmpID);
        		track.setMinValue($(this).val());
        	});
        });
        $("div#usrTrack"+level+" #"+id+"maxData"+level).each(function(){
        	$(this).on("change",function(){
        		var tmpID=$(this).attr("id");
        		tmpID=tmpID.substring(0,tmpID.length-8);
        		var track=svgList[level].getTrack(tmpID);
        		track.setMaxValue($(this).val());
        	});
        });
	});
}

/*function showCustomColor(id,level){
	if($("div#"+id+"Scale"+level).is(':visible')){
		$("div#"+id+"Scale"+level).hide();
		$("#"+id+"ColorBtn"+level).prop("value","Edit Color");
	}else{
		$("div#"+id+"Scale"+level).show();
		$("#"+id+"ColorBtn"+level).prop("value","Hide Edit Color");
	    var track=svgList[level].getTrack(id);
	    $("#"+id+"ColorSelect"+level).val(track.colorBy);
	    if(track.colorBy=="Score"){
	    	$("div#"+id+"ScaleSetting"+level).show();
	    }else{
	    	$("div#"+id+"ScaleSetting"+level).hide();
	    }
	    if(track!=undefined && track.minColor!=undefined&&track.maxColor!=undefined){
	        $("#"+id+"minData"+level).val(track.minValue);
	        $("#"+id+"maxData"+level).val(track.maxValue);
	        document.getElementById(id+"minColor"+level).color.fromString(track.minColor);
	        document.getElementById(id+"maxColor"+level).color.fromString(track.maxColor);
	    }
	}
	
}*/


function deleteCustomTrack(track){
	//console.log("remove custom track:"+track);
	//delete from cookie
	removeCustomTrackCookie(track);
	//console.log("after delete from cookie");
	//remove track from image
	removeTrack(0,track);
	//console.log("after remove from level0");
	removeTrack(1,track);
	//console.log("after remove from level 1");
	//remove track from UI
	$("div.custTrack"+track).each(function(){$(this).remove();});
	//console.log("after remove from settings");
	saveToCookie(0);
	//console.log("after save to cookie");
	//remove track from server
	$.ajax({
			url: contextPath +"/"+ pathPrefix +"removeCustomTrack.jsp",
			type: 'GET',
			data: {id: track},
								//data: {chromosome: chr,minCoord:minCoord,maxCoord:maxCoord,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: that.trackClass, folder: folderName,binSize:that.bin},
			dataType: 'json',
			success: function(data2){
				    				
			},
			error: function(xhr, status, error) {
					        			
			}
	});
	//console.log("end of remove");
}

function loadCustomTrackCookie(track){
	var existingCookieStr="";
	var customTrack="";
	if($.cookie("customTrackList")!=null){
    	existingCookieStr=$.cookie("customTrackList");
    	var trackArray=existingCookieStr.split(";");
    	var addedCount=0;
    	for(var m=0;m<trackArray.length;m++){
    		//console.log(trackArray[m]);
    		if(trackArray[m].indexOf(track)==0){
    			customTrack=trackArray[m];
    		}
    	}
    }
    return customTrack;
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

/*function timeoutFunc(){
	console.log("timeout function call");
}*/

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
			for(var l=0;l<that.trackList.length;l++){
				if(that.trackList[l]!=undefined && that.trackList[l].trackClass==track){
					tr=that.trackList[l];
				}
			}
			return tr;
	};
	that.addTrack=function (track,density,additionalOptions,retry){
		if(that.forceDrawAsValue=="Trx"){
			var additionalOptionsStr=new String(additionalOptions);
			if(additionalOptionsStr.indexOf("DrawTrx")==-1){
				additionalOptions=additionalOptions+"DrawTrx,";
			}
		}
		var folderStr=new String(folderName);
		if(folderStr.indexOf("_"+that.xScale.domain()[0]+"_")<0 || folderStr.indexOf("_"+that.xScale.domain()[1]+"_")<0){
			//update folderName because it doesn't match the current range.  that folder should exist, but getFullPath.jsp will call methods to generate if needed
			$.ajax({
					url:  pathPrefix +"getFullPath.jsp",
	   				type: 'GET',
	   				async: false,
					data: {chromosome: chr,minCoord:that.xScale.domain()[0],maxCoord:that.xScale.domain()[1],panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism},
					dataType: 'json',
	    			success: function(data2){ 
	        			folderName=data2.folderName;
	    			},
	    			error: function(xhr, status, error) {
	        			console.log(error);
	    			}
				});
		}
		var newTrack=null;
		var tmpvis=d3.select("#Level"+that.levelNumber+track);
		if(tmpvis[0][0]==null){
				var dragDiv=that.topLevel.append("li").attr("class","draggable"+that.levelNumber);
				//dragDiv.append("span").style("background","#CECECE").style("height","100%").style("width","10px").style("display","inline-block");
				var svg = dragDiv.append("svg:svg")
				.attr("width", that.get('width'))
				.attr("height", 30)
				.attr("class", "track")
				.attr("id","Level"+that.levelNumber+track)
				.attr("pointer-events", "all")
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
											var tmp=$('#'+tmpTrack+'InfoDesc'+that.levelNumber);
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
											ttsr.tooltipster('content',tmp.tooltipster('content'));
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
		}

		var success=0;
		if(track=="genomeSeq"){
			var newTrack=SequenceTrack(that,track,"Reference Genomic Sequence",additionalOptions);
			that.addTrackList(newTrack);
		}else if(track=="coding"){
				d3.xml(dataPrefix+"tmpData/regionData/"+folderName+"/coding.xml",function (error,d){
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
			}else if(track=="noncoding"){
				d3.xml(dataPrefix+"tmpData/regionData/"+folderName+"/noncoding.xml",function (error,d){
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
			}else if(track=="smallnc"){
				d3.xml(dataPrefix+"tmpData/regionData/"+folderName+"/smallnc.xml",function (error,d){
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
			}else if(track.indexOf("refSeq")==0){
				var include=$("#"+track+that.levelNumber+"Select").val();
				var tmpMin=that.xScale.domain()[0];
				var tmpMax=that.xScale.domain()[1];
				var file=dataPrefix+"tmpData/regionData/"+folderName+"/"+track+".xml";
				d3.xml(file,function (error,d){
					if(error){
						console.log(error);
						if(retry==0){
							$.ajax({
								url: contextPath +"/"+ pathPrefix +"generateTrackXML.jsp",
				   				type: 'GET',
								data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: track, folder: folderName},
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
				var include=$("#"+track+that.levelNumber+"Select").val();
				var tmpMin=that.xScale.domain()[0];
				var tmpMax=that.xScale.domain()[1];
				var file=dataPrefix+"tmpData/regionData/"+folderName+"/"+track+".xml";
				d3.xml(file,function (error,d){
					if(error){
						console.log(error);
						if(retry==0){
							$.ajax({
								url: contextPath +"/"+ pathPrefix +"generateTrackXML.jsp",
				   				type: 'GET',
								data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: track, folder: folderName},
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
						}
					}else{
						if(d==null){
							if(retry>=4){
								var snp=new Array();
								var newTrack= SNPTrack(that,snp,track,density,include);
								that.addTrackList(newTrack);
							}else{
								setTimeout(function (){
									that.addTrack(track,density,additionalOptions,4);
								},5000);
							}
						}else{
							var snp=d.documentElement.getElementsByTagName("Snp");
							var newTrack= SNPTrack(that,snp,track,density,include);
							that.addTrackList(newTrack);
						}
					}
				});
			}else if(track=="qtl"){
				d3.xml(dataPrefix+"tmpData/regionData/"+folderName+"/qtl.xml",function (error,d){
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
				d3.xml(dataPrefix+"tmpData/regionData/"+folderName+"/probe.xml",function (error,d){
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
						}
					}else{
						if(d==null){
							if(retry>=4){
								probe=new Array();
								var newTrack= ProbeTrack(that,probe,track,"Affy Exon 1.0 ST Probe Sets",density);
								that.addTrackList(newTrack);
							}else{
								setTimeout(function (){
								that.addTrack(track,density,additionalOptions,4);
								},5000);
							}
						}else{
							var probe=d.documentElement.getElementsByTagName("probe");
							var newTrack= ProbeTrack(that,probe,track,"Affy Exon 1.0 ST Probe Sets",density);
							that.addTrackList(newTrack);
							//success=1;
						}
					}
				});
			}else if(track=="helicos"||track=="illuminaTotal"||track=="illuminaSmall"||track=="illuminaPolyA"){
				var tmpMin=that.xScale.domain()[0];
				var tmpMax=that.xScale.domain()[1];
				var len=tmpMax-tmpMin;
				var tmpBin=calculateBin(len,that.width);
				var file=dataPrefix+"tmpData/regionData/"+folderName+"/count"+track+".xml";
				if(tmpBin>0){
					file=dataPrefix+"tmpData/regionData/"+folderName+"/bincount."+tmpBin+"."+track+".xml";
				}
				d3.xml(file,function (error,d){
					if(error){
						console.log(error);
						if(retry==0){
							$.ajax({
								url: contextPath +"/"+ pathPrefix +"generateTrackXML.jsp",
				   				type: 'GET',
								data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: track, folder: folderName,binSize:tmpBin},
								dataType: 'json',
				    			success: function(data2){
				    				
				    			},
				    			error: function(xhr, status, error) {
				        			
				    			}
							});
						}
						if(retry<3){//wait before trying again
							var time=15000;
							if(retry==1){
								time=20000;
							}
							setTimeout(function (){
								that.addTrack(track,density,additionalOptions,retry+1);
							},time);
						}else{
							d3.select("#Level"+that.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+track).attr("height", 15);
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
								}
								that.addTrackList(newTrack);
							}else{
								setTimeout(function (){
									that.addTrack(track,density,additionalOptions,4);
								},5000);
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
							}
							that.addTrackList(newTrack);
							//success=1;
						}
					}
				});
			}else if(track=="spliceJnct"){
				//var include=$("#"+track+that.levelNumber+"Select").val();
				var tmpMin=that.xScale.domain()[0];
				var tmpMax=that.xScale.domain()[1];
				var file=dataPrefix+"tmpData/regionData/"+folderName+"/"+track+".xml";
				d3.xml(file,function (error,d){
					if(error){
						console.log(error);
						if(retry==0){
							$.ajax({
								url: contextPath +"/"+ pathPrefix +"generateTrackXML.jsp",
				   				type: 'GET',
								data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: track, folder: folderName},
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
						}
					}else{
						if(d==null){
							if(retry>=4){
								var data=new Array();
								var newTrack= SpliceJunctionTrack(that,data,track,"Splice Junctions",1,"");
								that.addTrackList(newTrack);
							}else{
								setTimeout(function (){
									that.addTrack(track,density,additionalOptions,4);
								},5000);
							}
						}else{
							var data=d.documentElement.getElementsByTagName("Feature");
							var newTrack= SpliceJunctionTrack(that,data,track,"Splice Junctions",3,"");
							that.addTrackList(newTrack);
						}
					}
				});
			}else if(track.indexOf("custom")==0){
				var trackDetails=loadCustomTrackCookie(track);
				if(trackDetails.indexOf("organism="+organism)>0){
					console.log("loadedFromCookie:"+trackDetails);
					var details=trackDetails.split(",");
					var dispName="";
					for(var m=0;m<details.length;m++){
						if(details[m].indexOf("dispTrackName=")==0){
							dispName=details[m].substr(details[m].indexOf("=")+1);
						}
					}
					var data=new Array();
					var newTrack=CustomTranscriptTrack(that,data,track,dispName,3,trackDetails);
					that.addTrackList(newTrack);
					newTrack.updateFullData(0,0);
				}else{
					d3.select("#Level"+that.levelNumber+track).remove();
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
				d3.select("#"+level+"Scroll").style("max-height",val+"px").style("overflow","auto");
			}else{
				d3.select("#"+level+"Scroll").style("max-height","none").style("overflow","hidden");
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
				//console.log("redraw trackList"+l+":"+that.trackList[l].trackClass);
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
		/*var chkStr=new String(folderName);
		if(chkStr.indexOf("img")>-1){
			$.ajax({
					url:  pathPrefix +"getFullPath.jsp",
	   				type: 'GET',
	   				async: false,
					data: {chromosome: chr,minCoord:that.xScale.domain()[0],maxCoord:that.xScale.domain()[1],panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism},
					dataType: 'json',
	    			success: function(data2){ 
	        			folderName=data2.folderName;
	        			console.log("new folder for update"+folderName);
	    			},
	    			error: function(xhr, status, error) {
	        			console.log(error);
	    			}
				});
		}
		for(var i=0;i<that.trackList.length;i++){
			if(that.trackList[i]!=undefined && that.trackList[i].updateFullData!=undefined){
				console.log("updateFullData:"+that.trackList[i].trackClass);
				that.trackList[i].updateFullData(0,0);
			}
		}*/
		that.updateFullData();
		DisplayRegionReport();
	};

	that.updateFullData=function(){
		var chkStr=new String(folderName);
		if(chkStr.indexOf("img")>-1){
			$.ajax({
					url:  pathPrefix +"getFullPath.jsp",
	   				type: 'GET',
	   				async: false,
					data: {chromosome: chr,minCoord:that.xScale.domain()[0],maxCoord:that.xScale.domain()[1],panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism},
					dataType: 'json',
	    			success: function(data2){ 
	        			folderName=data2.folderName;
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
		for(var i=0;i<that.trackList.length;i++){
			if(that.trackList[i]!=undefined && that.trackList[i].clearSelection!=undefined){
				that.trackList[i].clearSelection();
			}
		}
	};

	that.mdown=function() {
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
	//setup code
	that.width=imageWidth;
	that.mw=that.width-that.margin;
	d3.select(div).select("#settingsLevel"+levelNumber).remove();
	d3.select(div).select("#functLevel"+levelNumber).remove();
	d3.select(div).select("#Level"+levelNumber).remove();
	that.vis=d3.select(div);

	//Setup Function Bar
	that.functionBar=that.vis.append("div").attr("class","functionBar")
		.attr("id","functLevel"+levelNumber)
		.style("float","left");
	//Setup Mouse Default Function Control
	var defMouse=that.functionBar.append("div").attr("class","defaultMouse").attr("id","defaultMouse"+levelNumber);
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
		.attr("id","saveLevel"+levelNumber)
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
						  /*xhr.onload = function() {
							var a = document.createElement('a');
							a.href = window.URL.createObjectURL(xhr.response); // xhr.response is a blob
							a.download = filename; // Set the file name.
							a.style.display = 'none';
							document.body.appendChild(a);
							a.click();
							delete a;
						  };*/
						  
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
		.attr("id","resetImage"+levelNumber)
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

	//Setup Settings Button
	that.vis.append("span").attr("class","settings button")
		.attr("id","settingsLevel"+levelNumber)
		.style("float","right")
		.style("width","130px")
		.text("Customize Image")
		.on("mouseover",function(){
			$("#mouseHelp").html("Click to Customize Tracks,Change Image Height, Reset Image Zoom, and Reset Tracks.");
		})
		.on("mouseout",function(){
			$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
		});

	//that.vis.append("span").attr("class","reset button").attr("id","resetLevel"+that.levelNumber).style("float","left").style("width","118px").text("Reset Image");
	//that.vis.append("span").attr("class","undo button").attr("id","undoLevel"+that.levelNumber).style("float","left").style("width","220px").text("Undo last Zoom/Move");
	that.topDiv=that.vis.append("div")
		.attr("id","Level"+levelNumber)
		.style("text-align","left");
	
	that.xScale = d3.scale.linear().
  		domain([minCoord, maxCoord]). 
  		range([0, that.width]);
		
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
    
    getAddMenuDiv(levelNumber,that.type);
	svgList[levelNumber]=that;
	
	 $( "#sortable"+levelNumber ).sortable({
										      ///revert: true,
										      //snap: "li",
											  //axis: "y",
											  appendTo: "parent",
											  containment: "parent",
											  //helper: "original",
											  stop: function() {
										        saveToCookie(levelNumber);
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
    //Add AA Seq Track
    return that;
}

function toolTipSVG(div,imageWidth,minCoord,maxCoord,levelNumber,title,type){
	var that={};
	that.get=function(attr){return that[attr];};
	
	that.addTrack=function (track,density,additionalOptions,data){
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
				//var info=svg.append("g").attr("class","infoIcon").attr("transform", "translate(" + (that.width/2+((lblStr.length/2)*7.5)+16) + ",0)");

				//uncomment to put info icon back but for now tooltip isn't displayed long enough to use it.
				/*var info=svg.append("g").attr("class","infoIcon")
										.attr("transform", "translate("+(that.width-20)+",0)")
										.style("cursor","pointer")
										.attr("track",track)
										.attr("title",track)
										.on("mouseover",function(){
											var tmpTrack=$(this).attr("track");
											var tmp=$('#'+tmpTrack+'InfoDesc'+that.levelNumber);
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
											ttsr.tooltipster('content',tmp.tooltipster('content'));
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
				info.append("text").attr("x",2.5).attr("y",12).attr("style","font-family:monospace;font-weight:bold;").attr("fill","#FFFFFF").text("i");*/
		}

		var success=0;
		if(track=="genomeSeq"){
			var newTrack= SequenceTrack(that,track,"Reference Genomic Sequence",additionalOptions);
			newTrack.seqRegionSize=10;
			that.addTrackList(newTrack);
		}else if(track=="coding"){
			var newTrack= GeneTrack(that,data,track,"Protein Coding/PolyA+ Transcripts",additionalOptions);
			that.addTrackList(newTrack);
		}else if(track=="noncoding"){
			var newTrack= GeneTrack(that,data,track,"Non-Coding/Non-PolyA+ Transcripts",additionalOptions);
			that.addTrackList(newTrack);
		}else if(track=="smallnc"){
			var newTrack= GeneTrack(that,data,track,"Small RNA (<200 bp) Genes",additionalOptions);
			that.addTrackList(newTrack);
		}else if(track.indexOf("refSeq")==0){
			additionalOptions=additionalOptions+"DrawTrx,";
			var newTrack= RefSeqTrack(that,data,track,"Ref Seq Genes",additionalOptions);
			newTrack.density=2;
			that.addTrackList(newTrack);
		}else if(track.indexOf("snp")==0){
			var newTrack= SNPTrack(that,data,track,3,4);
			that.addTrackList(newTrack);
		}else if(track=="qtl"){
				
			}else if(track=="trx"){
				var txList=getAllChildrenByName(getFirstChildByName(that.selectedData,"TranscriptList"),"Transcript");
				var newTrack= TranscriptTrack(that,txList,track,density);
				that.addTrackList(newTrack);

			}else if(track=="probe"){
				var newTrack= ProbeTrack(that,data,track,"Affy Exon 1.0 ST Probe Sets",3);
				that.addTrackList(newTrack);
			}else if(track=="spliceJnct"){
				var newTrack= SpliceJunctionTrack(that,data,track,"Splice Junctions",3,"");
				that.addTrackList(newTrack);
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
		/*var chkStr=new String(folderName);
		if(chkStr.indexOf("img")>-1){
			$.ajax({
					url:  pathPrefix +"getFullPath.jsp",
	   				type: 'GET',
	   				async: false,
					data: {chromosome: chr,minCoord:that.xScale.domain()[0],maxCoord:that.xScale.domain()[1],panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism},
					dataType: 'json',
	    			success: function(data2){ 
	        			folderName=data2.folderName;
	        			console.log("new folder for update"+folderName);
	    			},
	    			error: function(xhr, status, error) {
	        			console.log(error);
	    			}
				});
		}
		for(var i=0;i<that.trackList.length;i++){
			if(that.trackList[i]!=undefined && that.trackList[i].updateFullData!=undefined){
				console.log("updateFullData:"+that.trackList[i].trackClass);
				that.trackList[i].updateFullData(0,0);
			}
		}*/
		that.updateFullData();
		DisplayRegionReport();
	};

	that.updateFullData=function(){
		var chkStr=new String(folderName);
		if(chkStr.indexOf("img")>-1){
			$.ajax({
					url:  pathPrefix +"getFullPath.jsp",
	   				type: 'GET',
	   				async: false,
					data: {chromosome: chr,minCoord:that.xScale.domain()[0],maxCoord:that.xScale.domain()[1],panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism},
					dataType: 'json',
	    			success: function(data2){ 
	        			folderName=data2.folderName;
	        			//console.log("new folder for update"+folderName);
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
			if(that.trackList[i]!=undefined && (that.trackList[i].updateData!=undefined||that.trackList[i].updateFullData!=undefined)){
				//console.log("not undef");
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
					.style("max-height","350px")
					.style("overflow","auto")
					.style("width",(that.width+18)+"px")
					.append("ul")
					.attr("id","sortable"+that.levelNumber);
	
	
	/*$( "#sortable"+levelNumber ).sortable({
										      ///revert: true,
										      //snap: "li",
											  //axis: "y",
											  appendTo: "parent",
											  containment: "parent"
										    }).disableSelection();
	
    $( ".draggable"+levelNumber ).draggable({
										      connectToSortable: "#sortable"+levelNumber,
										      scroll: true,
										      //helper: "original",
										      revert: "invalid",
											  axis: "y"
										    });*/
    //Add Sequence Track
    //that.addTrack("genomeSeq",3,"both",0);
    return that;
}

//Track Functions
function Track(gsvgP,dataP,trackClassP,labelP){
	var that={};
	/*that.panDown=function(){
		if(d3.event.altKey||d3.event.shiftKey){
			if(d3.event.altKey){
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
			}else if(d3.event.shiftKey){//Disable panning to make rearranging easier

			}
		}else if(processAjax==0){
			var p = d3.mouse(that.gsvg.vis[0][0]);
        	that.gsvg.downPanx = p[0];
        	that.gsvg.downscalex = that.xScale;
    	}
	};*/

	that.panDown=function(){
		if(that.gsvg.defaultMouseFunct=="dragzoom" && overSelectable==0){
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
		}else if(that.gsvg.defaultMouseFunct=="pan" && overSelectable==0){
			if(processAjax==0){
				var p = d3.mouse(that.gsvg.vis[0][0]);
	        	that.gsvg.downPanx = p[0];
	        	that.gsvg.downscalex = that.xScale;
        	}
		}else if(that.gsvg.defaultMouseFunct=="reorder"){

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
					}
	};
	that.clearSelection = function (){
		d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".selected").each(function(){
							d3.select(that).attr("class","").style("fill",that.color);
						});
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
		//console.log(start+":"+end+":"+i+"->"+tmpY)
		return tmpY;
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

	that.drawScaleLegend = function (minVal,maxVal,lbl,minColor,maxColor){
		var lblStr=new String(that.label);
		var x=that.gsvg.width/2+(lblStr.length/2)*7.5+16;
		if(that.gsvg.width<500){
			x=(lblStr.length)*7.5;
		}
		d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".legend").remove();
		d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("#def1").remove();
		var grad=that.svg.append("defs").attr("id","def1").append("linearGradient").attr("id","grad"+that.gsvg.levelNumber+that.trackClass);
		grad.append("stop").attr("offset","0%").style("stop-color",minColor);
		grad.append("stop").attr("offset","100%").style("stop-color",maxColor);
		that.svg.append("rect")
				.attr("class","legend")
				.attr("x",x+20)
				.attr("y",0)
				.attr("rx",3)
				.attr("ry",3)
		    	.attr("height",12)
				.attr("width",75)
				.attr("fill","url(#grad"+that.gsvg.levelNumber+that.trackClass+")");
				//.attr("stroke","#FFFFFF");
			lblStr=new String(minVal);
			that.svg.append("text").text(lblStr).attr("class","legend").attr("x",x).attr("y",12);
			lblStr=new String(maxVal);
			that.svg.append("text").text(lblStr).attr("class","legend").attr("x",x+98).attr("y",12);
			var off=lblStr.length*8+5;
			lblStr=new String(lbl);
			that.svg.append("text").text(lblStr).attr("class","legend").attr("x",x+98+off).attr("y",12);
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

	that.gsvg=gsvgP;
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
	that.willDraw=1;
	that.labelBase=label;
	that.lastUpdate=0;
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
		var tmpStrands=$("#"+that.trackClass+that.gsvg.levelNumber+"Select").val();
		var tmpAA=0;
		if($("#"+that.trackClass+"CBX"+that.gsvg.levelNumber+"dispAA").is(":checked")){
			tmpAA=1;
		}
		if(that.strands!=tmpStrands||tmpAA!=that.includeAA){
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.base").each(function(d){d3.select(this).remove();});
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.aa0").each(function(d){d3.select(this).remove();});
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.aa1").each(function(d){d3.select(this).remove();});
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.aa2").each(function(d){d3.select(this).remove();});
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.aarev0").each(function(d){d3.select(this).remove();});
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.aarev1").each(function(d){d3.select(this).remove();});
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.aarev2").each(function(d){d3.select(this).remove();});
			that.draw(that.data);
		}else{
			if($("#"+that.trackClass+"CBX"+that.gsvg.levelNumber).is(":checked")){
				that.willDraw=1;
			}else{
				that.willDraw=0;
			}
			var tmpMin=that.xScale.domain()[0];
			var tmpMax=that.xScale.domain()[1];
			var len=tmpMax-tmpMin;
			var aaFont="12px";
			if(len>200){
				aaFont="10px";
			}
			if(that.willDraw==1&&((len<=that.aaDispCutoff&&that.includeAA==1)||(len<=that.dispCutoff))){
				if(!(that.seqRegionMin<=tmpMin && tmpMin<=that.seqRegionMax
					&& that.seqRegionMin<=tmpMax && tmpMax<=that.seqRegionMax)){
					that.updateData(0);
				}else{
					var charWidth=that.gsvg.width/len;
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
								.attr("transform",function(d,i){ return "translate("+((d.pos)*charWidth)+","+seqYPos+")";});
						//add new
						var appended=base.enter().append("g")
								.attr("class","base")
								.attr("transform",function(d,i){ return "translate("+((d.pos)*charWidth)+","+seqYPos+")";});
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
									.attr("transform",function(d,i){ return "translate("+that.xScale(d.pos)+","+tmpLineAt+")";})
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
									.attr("transform",function(d,i){ return "translate("+that.xScale(d.pos)+","+tmpLineAt+")";})
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
			}else{
				that.svg.attr("height", 0);
			}
		}
	};
	that.draw=function(data){
		that.strands=$("#"+that.trackClass+that.gsvg.levelNumber+"Select").val();
		if($("#"+that.trackClass+"CBX"+that.gsvg.levelNumber).is(":checked")){
			that.willDraw=1;
		}else{
			that.willDraw=0;
		}
		var aaLabel="";
		if($("#"+that.trackClass+"CBX"+that.gsvg.levelNumber+"dispAA").is(":checked")){
			that.includeAA=1;
			aaLabel=" and Amino Acids"
		}else{
			that.includeAA=0;
		}
		if(that.strands=="both"){
			that.label=that.labelBase+aaLabel+" on +/- strands";
		}else if(that.strands=="+"){
			that.label=that.labelBase+aaLabel+" on + strand";
		}else if(that.strands=="-"){
			that.label=that.labelBase+aaLabel+" on - strand";
		}
		if(that.willDraw==0){//Only needed to Fix IE Bug which still displays the label
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
		if(that.willDraw==1&&((len<=that.aaDispCutoff&&that.includeAA==1)||(len<=that.dispCutoff))){
			that.svg.selectAll("text.dir").remove();
			if(that.strands=="both"){
				that.svg.append("text").attr("class","dir").attr("x",5).attr("y",15).text("-->");
				that.svg.append("text").attr("class","dir").attr("x",5).attr("y",120).text("<--");
				that.svg.append("text").attr("class","dir").attr("x",that.gsvg.width-40).attr("y",15).text("-->");
				that.svg.append("text").attr("class","dir").attr("x",that.gsvg.width-20).attr("y",120).text("<--");
			}else if(that.strands=="+"){
				that.svg.append("text").attr("class","dir").attr("x",5).attr("y",15).text("-->");
				that.svg.append("text").attr("class","dir").attr("x",that.gsvg.width-40).attr("y",15).text("-->");
			}else if(that.strands=="-"){
				that.svg.append("text").attr("class","dir").attr("x",5).attr("y",15).text("<--");
				that.svg.append("text").attr("class","dir").attr("x",that.gsvg.width-40).attr("y",15).text("<--");
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
			
		}else{
			that.svg.attr("height", 0);
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
		//console.log("called updateData()");
		var curTime=(new Date()).getTime();
		if(curTime-that.lastUpdate>25000||retry>0){
			//console.log("updateData will try");
			var tmpseqRegionMin=that.xScale.domain()[0]-that.seqRegionSize;
			var tmpseqRegionMax=that.xScale.domain()[1]+that.seqRegionSize;
			if(tmpseqRegionMin<0){
				tmpseqRegionMin=0;
			}
			if((that.xScale.domain()[1]-that.xScale.domain()[0])<that.aaDispCutoff){
				that.lastUpdate=curTime;
				//console.log("Seq.UpdateData("+retry+")");
				if(that.svg.attr("height")<30){
					that.svg.attr("height", 30);
				}
				if(retry==0){
					that.showLoading();
				}
				
				var path=dataPrefix+"tmpData/regionData/"+folderName+"/"+tmpseqRegionMin+"_"+tmpseqRegionMax+".seq";
				d3.text(path,function (error,d){
					if(error){
						console.log(error);
						if(retry==0){
									$.ajax({
										url: contextPath +"/"+ pathPrefix +"generateTrackXML.jsp",
						   				type: 'GET',
										data: {chromosome: chr,minCoord:tmpseqRegionMin,maxCoord:tmpseqRegionMax,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: that.trackClass, folder: folderName},
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
									//console.log("Seq.updateData():ERROR");
									d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).select("#trkLbl").text("An errror occurred loading Track:"+that.trackClass);
									d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).attr("height", 15);
									that.lastUpdate=0;
						}
					}else{
						//console.log("Seq.UpdateData.Success:"+retry+":"+tmpseqRegionMin+"_"+tmpseqRegionMax);
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

	that.createCodon();
	that.updateData(0);
	that.draw(data);
	return that;
}
/*Track for displaying ProteinCoding,Long Non Coding, Small RNAs*/
function GeneTrack(gsvg,data,trackClass,label,additionalOptions){
	var that= Track(gsvg,data,trackClass,label);
	that.counts=[{value:0,names:"Ensembl"},{value:0,names:"RNA-Seq"}];
	var additionalOptStr=new String(additionalOptions);
	if(additionalOptStr.indexOf("annotOnly;")>-1){
		that.annotType="annotOnly";
	}else if(additionalOptStr.indexOf("trxOnly;")>-1){
		that.annotType="trxOnly";
	}else{
		that.annotType="all";
	}
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
	that.color =function(d){
		var color=d3.rgb("#000000");
		if(that.trackClass=="coding"){
			if((new String(d.getAttribute("ID"))).indexOf("ENS")>-1 && !(that.annotType=="trxOnly")){
				color=d3.rgb("#DFC184");
			}else{
				color=d3.rgb("#7EB5D6");
			}
		}else if(d.getAttribute("biotype")!="protein_coding" && (d.getAttribute("stop")-d.getAttribute("start"))>=200){
			if((new String(d.getAttribute("ID"))).indexOf("ENS")>-1 && !(that.annotType=="trxOnly")){
				color=d3.rgb("#B58AA5");
			}else{
				color=d3.rgb("#CECFCE");
			}
		}else if((d.getAttribute("stop")-d.getAttribute("start"))<200){
			if((new String(d.getAttribute("ID"))).indexOf("ENS")>-1 && !(that.annotType=="trxOnly")){
				color=d3.rgb("#FFCC00");
			}else{
				color=d3.rgb("#99CC99");
			}
		}
		return color;
	};

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
	};

	that.getDisplayID=function(id){
		if(that.trackClass!="smallnc"){
			if(id.indexOf("ENS")==-1){
				var prefix="Brain.G";
				if(id.indexOf("TCON")>-1){
					prefix="Brain.T";
				}
				id=id.substr(id.indexOf("_")+1);
				id=id.replace(/^0+/, '');
				id=prefix+id;
			}
		}else{
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
		//console.log("gene toottip");
		var tooltip="";
		var txListStr="";
		if((d.getAttribute("stop")-d.getAttribute("start"))<200){
			var prefix="smRNA_";
			var rnaSeqData="<BR>Total Reads: "+d.getAttribute("reads")+"<BR>Reference Sequence:<BR>"+d.getAttribute("refseq");
			if(new String(d.getAttribute("ID")).indexOf("ENS")>-1){
				prefix="";
				rnaSeqData="";
			}else{

			}
			tooltip="<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div>ID: "+prefix+d.getAttribute("ID")+"<BR>Length:"+(d.getAttribute("stop")-d.getAttribute("start"))+"<BR>Location: "+d.getAttribute("chromosome")+":"+numberWithCommas(d.getAttribute("start"))+"-"+numberWithCommas(d.getAttribute("stop"))+"<BR>Strand: "+d.getAttribute("strand")+rnaSeqData+"<BR>";
																																																													  
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
				var txList=getAllChildrenByName(getFirstChildByName(d.parent,"TranscriptList"),"Transcript");
				for(var m=0;m<txList.length;m++){
					var id=new String(txList[m].getAttribute("ID"));
					if(id.indexOf("ENS")==-1){
						id=id.substr(id.indexOf("_")+1);
						id=id.replace(/^0+/, '');
						id="Brain.T"+id;
					}
					if(gid!=id){
						if(that.annotType=="annotOnly" && new String(txList[m].getAttribute("ID")).indexOf("ENS")>-1){
							txListStr+="<B>"+id+"</B>";
							txListStr+="<br>";
						}else if(that.annotType=="trxOnly" && new String(txList[m].getAttribute("ID")).indexOf("ENS")==-1){
							txListStr+="<B>"+id+"</B>";
							txListStr+="<br>";
						}else if(that.annotType=="all"){
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

				}
				tooltip="<BR>Transcript ID: "+gid+"<BR>Gene Symbol:"+geneSym+"<BR>Location:"+d.getAttribute("chromosome")+":"+numberWithCommas(d.getAttribute("start"))+"-"+numberWithCommas(d.getAttribute("stop"))+"<BR>Strand:"+strand;
				tooltip=tooltip+"<BR><BR>Gene ID: "+that.getDisplayID(d.parent.getAttribute("ID"))+"<BR>Other Transcripts:<BR>"+txListStr+"<BR>";
			}else{
				var txList=getAllChildrenByName(getFirstChildByName(d,"TranscriptList"),"Transcript");
				for(var m=0;m<txList.length;m++){
					var id=new String(txList[m].getAttribute("ID"));
					if(id.indexOf("ENS")==-1){
						id=id.substr(id.indexOf("_")+1);
						id=id.replace(/^0+/, '');
						id="Brain.T"+id;
					}
					if(that.annotType=="annotOnly" && new String(txList[m].getAttribute("ID")).indexOf("ENS")>-1){
						txListStr+="<B>"+id+"</B>";
						txListStr+="<br>";
					}else if(that.annotType=="trxOnly" && new String(txList[m].getAttribute("ID")).indexOf("ENS")==-1){
						txListStr+="<B>"+id+"</B>";
						txListStr+="<br>";
					}else if(that.annotType=="all"){
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
				tooltip="<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div>Gene ID: "+gid+"<BR>Gene Symbol:"+geneSym+"<BR>Location:"+d.getAttribute("chromosome")+":"+numberWithCommas(d.getAttribute("start"))+"-"+numberWithCommas(d.getAttribute("stop"))+"<BR>Strand:"+strand+"<BR>Transcripts:<BR>"+txListStr+"<BR>";
			}
			
		}
		return tooltip;
	};

	that.redraw=function(){
		console.log("gene.draw()");
		//set annotType
		var curAnnot="";
		if($("#"+that.trackClass+"CBXg"+that.gsvg.levelNumber).is(":checked")
			&&
			$("#"+that.trackClass+"CBXt"+that.gsvg.levelNumber).is(":checked")){
			that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Selectg").val();
			curAnnot="all";
		}else if($("#"+that.trackClass+"CBXg"+that.gsvg.levelNumber).is(":checked")){
			that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Selectg").val();
			curAnnot="annotOnly";
		}else if($("#"+that.trackClass+"CBXt"+that.gsvg.levelNumber).is(":checked")){
			that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Selectt").val();
			curAnnot="trxOnly";
		}
		var tmpMin=that.xScale.domain()[0];
		var tmpMax=that.xScale.domain()[1];
		var len=tmpMax-tmpMin;
		var overrideTrx=0;
		if((len<that.trxCutoff&&that.drawnAs=="Gene")||(len>=that.trxCutoff&&that.drawnAs=="Trx"&&that.drawAs!="Trx")||(that.drawnAs=="Gene" && $("#forceTrxCBX"+that.gsvg.levelNumber).is(":checked"))){
			that.draw(that.data);	
		}else{
			//console.log("annot:"+curAnnot);
			//console.log("prev:"+that.annotType);
			if(curAnnot==that.annotType){
				if(len<that.trxCutoff&&that.drawnAs=="Trx"&&that.drawAs!="Trx"){
					overrideTrx=1;
				}
				//console.log("redraw as "+that.drawAs);
				if((that.drawAs=="Gene" || that.trackClass=="smallnc")&&overrideTrx==0){
					that.trackYMax=0;
					if(that.svg[0][0]!=null){
						for(var j=0;j<that.gsvg.width;j++){
							that.yArr[j]=0;
						}
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
							d3This.select("text").text(fullChar);
						});
					}
					if(that.density==1){
						that.svg.attr("height", 30);
					}else if(that.density==2){
						that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene").size()+1)*15);
					}else if(that.density==3){
						that.svg.attr("height", (that.trackYMax+2)*15);
					}
				}else if(overrideTrx==1 || that.drawAs=="Trx"){
					//console.log("redraw TRX");
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
							//console.log("process trx:"+d.getAttribute("ID")+":"+i+":"+exList.length);
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
									console.log("redraw:"+"#Level"+that.gsvg.levelNumber+that.trackClass+" g.trx"+that.gsvg.levelNumber+"#"+pref+d.getAttribute("ID")+that.gsvg.levelNumber+" line#Int"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID"))
									d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" g.trx"+that.gsvg.levelNumber+"#"+pref+d.getAttribute("ID")+that.gsvg.levelNumber+" line#Int"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID"))
										.attr("x1",intStart)
										.attr("x2",intStop);

									d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" g.trx"+that.gsvg.levelNumber+"#"+pref+d.getAttribute("ID")+that.gsvg.levelNumber+" #IntTxt"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID"))
										.attr("dx",intStart+1).text(fullChar);
								}
							}
						});
						if(that.density==1){
							that.svg.attr("height", 30);
						}else if(that.density==2){
							that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.trx"+that.gsvg.levelNumber).size()+1)*15);
						}else if(that.density==3){
							that.svg.attr("height", (that.trackYMax+2)*15);
						}
				}
			}else{
				that.draw(that.data);
			}
		}
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
		if(d3.selectAll("g.gene").size()>0){
				d3.selectAll("rect.selected").each(function(){
					d3.select(this).attr("class","").style("fill",that.color);
					});
			}else if(d3.selectAll("g.trx"+that.gsvg.levelNumber).size()>0){
				that.svg.selectAll("g.trx"+that.gsvg.levelNumber+".selected").selectAll("line").style("stroke",that.color);
				that.svg.selectAll("g.trx"+that.gsvg.levelNumber+".selected").selectAll("rect").style("fill",that.color);
				that.svg.selectAll("g.trx"+that.gsvg.levelNumber+".selected").selectAll("text").style("opacity","0.6").style("fill",that.color);
				that.svg.selectAll("g.trx"+that.gsvg.levelNumber+".selected").each(function(){var tmpCl=new String($(this).attr("class"));tmpCl=tmpCl.replace(" selected","");$(this).attr("class",tmpCl);});
			}
	};

	that.setupDetailedView=function(d){
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
			if(d.getAttribute("biotype")=="protein_coding" && (d.getAttribute("stop")-d.getAttribute("start"))>=200){
				localTxType="protein";
			}else if(d.getAttribute("biotype")!="protein_coding" && (d.getAttribute("stop")-d.getAttribute("start"))>=200){
				localTxType="long";
			}else if((d.getAttribute("stop")-d.getAttribute("start"))<200){
				localTxType="small";
			}
			if(localTxType=="protein"||localTxType=="long"){
				//if(svgList[newLevel]==null){
					var displayID=d.getAttribute("ID");
					if(d.getAttribute("geneSymbol")!=undefined&&d.getAttribute("geneSymbol")!=""){
						displayID=displayID+" ("+d.getAttribute("geneSymbol")+")"
					}
					var newSvg= GenomeSVG("div#selectedImage",that.gsvg.width,d.getAttribute("extStart"),d.getAttribute("extStop"),newLevel,displayID,"transcript");
					newSvg.xMin=d.getAttribute("extStart")-(d.getAttribute("extStop")-d.getAttribute("extStart"))*0.05;
					newSvg.xMax=d.getAttribute("extStop")+(d.getAttribute("extStop")-d.getAttribute("extStart"))*0.05;
					svgList[newLevel]=newSvg;
					svgList[newLevel].txType=localTxType;
					svgList[newLevel].selectedData=d;
					svgList[newLevel].addTrack("trx",2,"",0);
					loadState(newLevel);
				/*}else{
					svgList[newLevel].xScale.domain([d.getAttribute("extStart"),d.getAttribute("extStop")]);
					svgList[newLevel].xMin=d.getAttribute("extStart")-(d.getAttribute("extStop")-d.getAttribute("extStart"))*0.05;
					svgList[newLevel].xMax=d.getAttribute("extStop")+(d.getAttribute("extStop")-d.getAttribute("extStart"))*0.05;
					svgList[newLevel].scaleSVG.select(".x.axis").call(svgList[newLevel].xAxis);
					d3.select("#Level"+newLevel).select(".axisLbl").text(d.getAttribute("ID")).attr("x", ((that.gsvg.width-(that.gsvg.margin*2))/2)).attr("y",-40);
					svgList[newLevel].txType=localTxType;
					svgList[newLevel].selectedData=d;
					console.log();
					console.log();
					d3.select("#settingsLevel"+that.gsvg.levelNumber+1).remove();
					d3.select("#Level"+that.gsvg.levelNumber+1).remove();
					svgList[newLevel].update();
				}*/
				selectedGeneSymbol=d.getAttribute("geneSymbol");
				selectedID=d.getAttribute("ID");
				$('div#selectedImage').show();
				if((new String(selectedID)).indexOf("ENS")>-1){
					$('div#selectedReport').show();
					var jspPage= pathPrefix +"geneReport.jsp";
					var params={id:selectedID,geneSymbol:selectedGeneSymbol,chromosome:chr,species:organism};
					DisplaySelectedDetailReport(jspPage,params);
				}else{
					$('div#selectedReport').html("Detailed Gene Reports are not currently provided for RNA-Seq(Cufflinks) generated genes.");
				}
			}else if(localTxType=="small"){
				if(new String(d.getAttribute("ID")).indexOf("ENS")==-1){
					$('div#selectedImage').hide();
					$('div#selectedReport').show();
					//Add SVG graphic later
					//For now processing.js graphic is in jsp page of the detail report
					var jspPage= pathPrefix +"viewSmallNonCoding.jsp";
					var params={id: d.getAttribute("ID"),name: "smRNA_"+d.getAttribute("ID")};
					DisplaySelectedDetailReport(jspPage,params);
				}
			}
			
	};

	that.getDisplayedData= function (){
		var dispData=new Array();
		var dispDataCount=0;
		if(that.drawnAs=="Gene"){
			var dataElem=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene");
			that.counts=[{value:0,names:"Ensembl"},{value:0,names:"RNA-Seq"}];
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
							that.counts[1].value++;
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
			that.counts=[{value:0,names:"Ensembl"},{value:0,names:"RNA-Seq"}];
			var tmpDat=dataElem[0];
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
							that.counts[1].value++;
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
		var path=dataPrefix+"tmpData/regionData/"+folderName+"/coding.xml";
		if(that.trackClass=="noncoding"){
			path=dataPrefix+"tmpData/regionData/"+folderName+"/noncoding.xml";
		}else if(that.trackClass=="smallnc"){
			path=dataPrefix+"tmpData/regionData/"+folderName+"/smallnc.xml";
			tag="smnc";
		}
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
				}
			}else{
				var data=d.documentElement.getElementsByTagName(tag);
				var mergeddata=new Array();
				var checkName=new Array();
				var curInd=0;
				//console.log("new data:"+data.length);
				//console.log("old data:"+that.data.length);
					for(var l=0;l<data.length;l++){
						if(data[l]!=undefined ){
							mergeddata[curInd]=data[l];
							checkName[data[l].getAttribute("ID")]=1;
							curInd++;
						}
					}
					//console.log("size after new:"+curInd);
					for(var l=0;l<that.data.length;l++){
						//console.log("l:"+l);
						//console.log(that.data[l]);
						//console.log(that.data[l].getAttribute("ID"));
						//console.log(checkName[that.data[l].getAttribute("ID")]);
						if(that.data[l]!=undefined && checkName[that.data[l].getAttribute("ID")]==undefined){
							mergeddata[curInd]=that.data[l];
							curInd++;
						}
					}
					//console.log("size after old:"+curInd);

				that.draw(mergeddata);
				that.hideLoading();
				DisplayRegionReport();
			}
		});
	};

	that.drawTrx=function (d,i){
		console.log("drawTrx level:"+that.gsvg.levelNumber);
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
		
	};

	that.draw=function (data){
		//console.log("geneTrack.draw()");
		that.data=data;

		that.trackYMax=0;
		that.svg.selectAll(".gene").remove();
		
		//set annotType
		if($("#"+that.trackClass+"CBXg"+that.gsvg.levelNumber).is(":checked")
			&&
			$("#"+that.trackClass+"CBXt"+that.gsvg.levelNumber).is(":checked")){
			//that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Selectg").val();
			that.annotType="all";
		}else if($("#"+that.trackClass+"CBXg"+that.gsvg.levelNumber).is(":checked")){
			//that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Selectg").val();
			that.annotType="annotOnly";
		}else if($("#"+that.trackClass+"CBXt"+that.gsvg.levelNumber).is(":checked")){
			//that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Selectt").val();
			that.annotType="trxOnly";
		}
		if($("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Selectg").length>0){
			that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Selectg").val();
		}
		//console.log("set annotType:"+that.annotType);
		for(var j=0;j<that.gsvg.width;j++){
				that.yArr[j]=0;
		}

		var prevDrawAs=that.drawAs;
		var tmpMin=that.xScale.domain()[0];
		var tmpMax=that.xScale.domain()[1];
		var len=tmpMax-tmpMin;
		if(len<that.trxCutoff || $("#forceTrxCBX"+that.gsvg.levelNumber).is(":checked")){
			that.drawAs="Trx";
		}

		var lbl="Protein Coding";
		var lbltxSuffix=" / PolyA+";
		if(that.trackClass=="noncoding"){
			lbl="Long Non-Coding";
			lbltxSuffix=" / Non-PolyA+"
		}else if(that.trackClass=="smallnc"){
			lbl="Small RNA";
			lbltxSuffix="";
		}
		if(that.annotType=="annotOnly"){
			lbl="Annotated "+lbl+" Genes";
		}else if(that.annotType=="trxOnly"){
			lbl="RNA-Seq Transcriptome "+lbl+lbltxSuffix+" Genes";
		}else{
			if(that.drawAs=="Gene"){
				lbl=lbl+lbltxSuffix+" Genes";
			}else{
				lbl=lbl+lbltxSuffix+" Transcripts";
			}
		}
		that.updateLabel(lbl);
		that.redrawLegend();

		//console.log(data);
		var filterData=data;
		/*if(that.gsvg.levelNumber==0){
			console.log("before filter:Data:");
			console.log(data);
			console.log("annotation type:"+that.annotType);
		}*/
		if(that.annotType!="all"){
			filterData=[];
			var newCount=0;
			if(that.drawAs=="Gene" || that.trackClass=="smallnc"){
				for(var l=0;l<data.length;l++){
					if(data[l]!=undefined ){
						if(that.gsvg.levelNumber!=1 ||
							(that.gsvg.levelNumber==1 &&
							 that.gsvg.selectedData!=undefined 
							 && data[l].getAttribute("ID")!=that.gsvg.selectedData.getAttribute("ID"))
							){
								if(that.annotType=="annotOnly" && (new String(data[l].getAttribute("ID"))).indexOf("ENS")>-1){
									filterData[newCount]=data[l];
									newCount++;
								}else if(that.annotType=="trxOnly" ){
									
										if((new String(data[l].getAttribute("ID"))).indexOf("ENS")==-1){
											filterData[newCount]=data[l];
											newCount++;
										}else{
											var txList=getAllChildrenByName(getFirstChildByName(data[l],"TranscriptList"),"Transcript");
											var found=0;
											for(var m=0;m<txList.length&&found==0;m++){
												if((new String(txList[m].getAttribute("ID"))).indexOf("ENS")==-1){
													found=1;
												}
											}
											if(found==1){
												filterData[newCount]=data[l];
												newCount++;
											}
										}
									
								}
						}
					}
				}
			}else if(that.drawAs=="Trx"){
				console.log("geneTrack.draw(ALL,TRX)");
				for(var l=0;l<data.length;l++){
					if(data[l]!=undefined ){
						if(that.gsvg.levelNumber!=1 ||
							(that.gsvg.levelNumber==1 && that.gsvg.selectedData!=undefined && data[l].getAttribute("ID")!=that.gsvg.selectedData.getAttribute("ID") )
							){
								var tmpTxList=getAllChildrenByName(getFirstChildByName(data[l],"TranscriptList"),"Transcript");
								for(var k=0;k<tmpTxList.length;k++){
									if(that.annotType=="annotOnly" && (new String(tmpTxList[k].getAttribute("ID"))).indexOf("ENS")>-1){
										filterData[newCount]=tmpTxList[k];
										filterData[newCount].parent=data[l];
										newCount++;
									}else if(that.annotType=="trxOnly" && (new String(tmpTxList[k].getAttribute("ID"))).indexOf("ENS")==-1){
											filterData[newCount]=tmpTxList[k];
											filterData[newCount].parent=data[l];
											newCount++;
									}
								}
						}
					}
				}
			}
			
		}else{
			if(that.drawAs=="Trx" && that.trackClass!="smallnc"){
				filterData=[];
				var newCount=0;
				for(var l=0;l<data.length;l++){
					if(data[l]!=undefined ){
						if(that.gsvg.levelNumber!=1 ||
							(that.gsvg.levelNumber==1 && that.gsvg.selectedData!=undefined  && data[l].getAttribute("ID")!=that.gsvg.selectedData.getAttribute("ID") )
							){
								var tmpTxList=getAllChildrenByName(getFirstChildByName(data[l],"TranscriptList"),"Transcript");
								for(var k=0;k<tmpTxList.length;k++){
									filterData[newCount]=tmpTxList[k];
									filterData[newCount].parent=data[l];
									newCount++;
								}
						}
					}
				}
			}
		}
		//console.log("geneTrack.filterData");
		//console.log(filterData);
		/*if(that.gsvg.levelNumber==0){
			console.log("draw:"+that.trackClass);
			console.log("selectedData=");
			console.log(that.gsvg.selectedData);
			console.log("DrawGeneTrack: FilterData:");
			console.log(filterData);
		}*/
		/*if(that.gsvg.levelNumber==1 && that.gsvg.selectedData!=undefined){
			var newFilter=[];
			var ind=0;
			for(var l=0;l<filterData.length;l++){
				if(filterData[l].getAttribute("ID")!=that.gsvg.selectedData.getAttribute("ID")){
					newFilter[ind]=filterData[l];
					ind++;
				}
			}
			filterData=newFilter;
		}*/
		
		if(that.drawAs=="Gene" || that.trackClass=="smallnc"){
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
						d3.selectAll("rect.selected").each(function(){
								d3.select(this).attr("class","").style("fill",that.color);
							});
						d3.select(this).attr("class","selected").style("fill","green");
						that.setupDetailedView(d);
					})
				.on("dblclick", that.zoomToFeature)
				.on("mouseover", function(d) { 
						//console.log("mouseover geneTrack:asGene");
						//if(mouseTTOver==0){
							overSelectable=1;
							$("#mouseHelp").html("<B>Click</B> to see additional details. <B>Double Click</B> to zoom in on this feature.");
							d3.select(this).style("fill","green");
				        	//that.gsvg.get('tt').transition()
				        	tt.transition()        
				                .duration(200)      
				                .style("opacity", .95);      
				        	//that.gsvg.get('tt').html(that.createToolTip(d)) 
				        	tt.html(that.createToolTip(d)) 
				                .style("left", function(){
				                	var x=d3.event.pageX;
				                	if(x>that.gsvg.halfWindowWidth){
				                		x=x-450;
				                	}
				                	var xPos=x+"px";
				                	return xPos;
				                })  
				                .style("top", (d3.event.pageY + 15) + "px");
				            that.triggerTableFilter(d);
				            if(that.trackClass!="smallnc"){
					            var newSvg=toolTipSVG("div#ttSVG",450,d.getAttribute("extStart"),d.getAttribute("extStop"),99,d.getAttribute("ID"),"transcript");
								newSvg.xMin=d.getAttribute("extStart")-(d.getAttribute("extStop")-d.getAttribute("extStart"))*0.05;
								newSvg.xMax=d.getAttribute("extStop")+(d.getAttribute("extStop")-d.getAttribute("extStart"))*0.05;
								var localTxType="none";
								if(d.getAttribute("biotype")=="protein_coding" && (d.getAttribute("stop")-d.getAttribute("start"))>=200){
									localTxType="protein";
								}else if(d.getAttribute("biotype")!="protein_coding" && (d.getAttribute("stop")-d.getAttribute("start"))>=200){
									localTxType="long";
								}else if((d.getAttribute("stop")-d.getAttribute("start"))<200){
									localTxType="small";
								}
								newSvg.txType=localTxType;
								newSvg.selectedData=d;
								var dataArr=new Array();
								dataArr[0]=d;
								newSvg.addTrack("trx",2,"",dataArr);
							}else{
								var newSvg=toolTipSVG("div#ttSVG",450,((d.getAttribute("start")*1)-10),((d.getAttribute("stop")*1)+10),99,that.getDisplayID(d.getAttribute("ID")),"");
								newSvg.xMin=d.getAttribute("start")-20;
								newSvg.xMax=d.getAttribute("stop")+20;
								var dataArr=new Array();
								dataArr[0]=d;
								newSvg.addTrack("smallnc",2,"",dataArr);
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
				d3This.append("svg:text").attr("dx","1").attr("dy","10").style("pointer-events","none").text(fullChar);
				}
			});

			if(that.density==1){
				that.svg.attr("height", 30);
			}else if(that.density==2){
				that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene").size()+1)*15);
			}else if(that.density==3){
				that.svg.attr("height", (that.trackYMax+2)*15);
			}
		}else if(that.drawAs=="Trx"){
			that.drawnAs="Trx";
			that.svg.selectAll(".gene").each(function(){d3.select(this).remove();});
			//console.log("drawRefSeq as TRX "+that.trackClass);
			//console.log(filterData);
			//var txList=new Array();
			//var txListSize=0;
			
			//console.log("Gene TX List"+that.trackClass);
			//console.log(txList);
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
									.style("opacity", .95);      
								tt.html(that.createToolTip(d))  
									.style("left", function(){
					                	var x=d3.event.pageX;
					                	if(x>that.gsvg.halfWindowWidth){
					                		x=x-450;
					                	}
					                	var xPos=x+"px";
					                	return xPos;
				                	})	     
									.style("top", (d3.event.pageY +5) + "px");  
									that.triggerTableFilter(d);
		            	})
					.on("mouseout", function(d) {
						var tmp=new String(d3.select(this).attr("class"));
						//console.log("class(mouseout):"+tmp);
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
					//.each(that.drawTrx);
			
			
			 tx.exit().remove();
			 tx.each(that.drawTrx);
			if(that.density==1){
				that.svg.attr("height", 30);
			}else if(that.density==2){
				that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.trx"+that.gsvg.levelNumber).size()+1)*15);
			}else if(that.density==3){
				that.svg.attr("height", (that.trackYMax+2)*15);
			}
		}
		that.drawAs=prevDrawAs;
	};

	that.redrawLegend=function (){
		var legend=[];
		var curPos=0;

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
		

		that.drawLegend(legend);
	};

	that.triggerTableFilter=function(d){
		var e = jQuery.Event("keyup");
		e.which = 32; // # Some key code value
		var filterStr="";
		//to support different types of d depending on source need to determine what d is.
		if(d.getAttribute==undefined || d.getAttribute("ID")==undefined){
			//console.log("trigger:undefined");
		}else{//represents a track feature
			//console.log("trigger:feature");
			filterStr=that.getDisplayID(d.getAttribute("ID"));
		}
		if(that.trackClass!="smallnc"){
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
	that.density=2;
	var additionalOptStr=new String(additionalOptions);
	if(additionalOptStr.indexOf("DrawTrx")>-1){
		that.drawAs="Trx";
	}
	that.color =function(d){
		var color=d3.rgb("#000000");
		if(that.drawnAs=="Gene"){
			var txList=getAllChildrenByName(getFirstChildByName(d,"TranscriptList"),"Transcript");
			var mostValid=-1;
			for(var m=0;m<txList.length;m++){
					var cat=new String(txList[m].getAttribute("category"));
					var val=-1;
					if(cat=="Validated"){
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

			if(mostValid==3){
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
			if(cat=="Validated"){
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
		if(tmpName.indexOf("Validated")>-1){
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
						if(cat=="Validated"){
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
				if(mostValid==3){
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
		return dispData;
	};

	that.createToolTip=function(d){
		var tooltip="";
		if(that.drawAs=="Gene"){
			var txListStr="";
			var txList=getAllChildrenByName(getFirstChildByName(d,"TranscriptList"),"Transcript");
			for(var m=0;m<txList.length;m++){
				var id=new String(txList[m].getAttribute("ID"));
				txListStr+="<B>"+id+"</B> - "+txList[m].getAttribute("category");
				txListStr+="<br>";
			}
			tooltip="<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div>Gene Symbol: "+d.getAttribute("geneSymbol")+"<BR>Location: "+d.getAttribute("chromosome")+":"+numberWithCommas(d.getAttribute("start"))+"-"+numberWithCommas(d.getAttribute("stop"))+"<BR>Strand: "+d.getAttribute("strand")+"<BR>Transcripts:<BR>"+txListStr;
		}else if(that.drawAs=="Trx"){
			//console.log(d);
				var txListStr="";
				var id=new String(d.getAttribute("ID"));
				txListStr+="<B>"+id+"</B>";
			tooltip="Transcript:"+txListStr+"<BR>Status: "+d.getAttribute("category")+"<BR>Gene Symbol: "+d.getAttribute("geneSymbol")+"<BR>Location: "+d.getAttribute("chromosome")+":"+numberWithCommas(d.getAttribute("start"))+"-"+numberWithCommas(d.getAttribute("stop"))+"<BR>Strand: "+d.getAttribute("strand");
		}
		return tooltip;
	};

	that.redraw=function(){
		var tmpMin=that.xScale.domain()[0];
		var tmpMax=that.xScale.domain()[1];
		var len=tmpMax-tmpMin;
		var overrideTrx=0;
		if((len<that.trxCutoff&&that.drawnAs=="Gene")||(len>=that.trxCutoff&&that.drawnAs=="Trx"&&that.drawAs!="Trx")||(that.drawnAs=="Gene"&&$("#forceTrxCBX"+that.gsvg.levelNumber).is(":checked"))) {
			that.draw(that.data);
		}else{
			if(len<that.trxCutoff && that.drawnAs=="Trx" && that.drawAs!="Trx"){
				overrideTrx=1;
			}
			if(that.drawAs=="Gene" && overrideTrx==0){
				that.trackYMax=0;
				if(that.svg[0][0]!=null){
						for(var j=0;j<that.gsvg.width;j++){
							that.yArr[j]=0;
						}
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
					that.svg.attr("height", (that.trackYMax+2)*15);
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
					that.svg.attr("height", (that.trackYMax+2)*15);
				}
			}
		}
	};

	that.updateData=function(retry){
		var tag="Gene";
		var tmpMin=that.xScale.domain()[0];
		var tmpMax=that.xScale.domain()[1];
		var path=dataPrefix+"tmpData/regionData/"+folderName+"/refSeq.xml";
		d3.xml(path,function (error,d){
			if(error){
				console.log(error);
				if(retry==0){
							$.ajax({
								url: contextPath +"/"+ pathPrefix +"generateTrackXML.jsp",
				   				type: 'GET',
								data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: that.trackClass, folder: folderName,panel:panel},
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
							d3.select("#Level"+that.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+track).attr("height", 15);
						}
			}else{
				var data=d.documentElement.getElementsByTagName(tag);
				var mergeddata=new Array();
				var checkName=new Array();
				var curInd=0;
				//console.log("new data:"+data.length);
				//console.log("old data:"+that.data.length);
					for(var l=0;l<data.length;l++){
						if(data[l]!=undefined ){
							mergeddata[curInd]=data[l];
							checkName[data[l].getAttribute("ID")]=1;
							curInd++;
						}
					}
					//console.log("size after new:"+curInd);
					for(var l=0;l<that.data.length;l++){
						//console.log("l:"+l);
						//console.log(that.data[l]);
						//console.log(that.data[l].getAttribute("ID"));
						//console.log(checkName[that.data[l].getAttribute("ID")]);
						if(that.data[l]!=undefined && checkName[that.data[l].getAttribute("ID")]==undefined){
							mergeddata[curInd]=that.data[l];
							curInd++;
						}
					}
					//console.log("size after old:"+curInd);
				that.draw(mergeddata);
				that.hideLoading();
				DisplayRegionReport();
			}
		});
	};

	that.drawTrx=function (d,i){
		//console.log("drawTrx:"+i);
		var cdsStart=d.getAttribute("cdsStart");
		var cdsStop=d.getAttribute("cdsStop");
		//console.log("CDS:"+cdsStart);
		//console.log("CDS:"+cdsStop);
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
				//console.log("xPos1"+xPos1+"xPos2:"+xPos2+"xWidth1"+xWidth1+"xWidth2:"+xWidth2);
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
		that.svg.selectAll(".gene").remove();
		that.svg.selectAll(".trx"+that.gsvg.levelNumber).remove();
		
		if($("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").length>0){
			that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").val();
		}
			//console.log("set annotType:"+that.annotType);
		for(var j=0;j<that.gsvg.width;j++){
			that.yArr[j]=0;
		}
		var prevDrawAs=that.drawAs;
		var tmpMin=that.xScale.domain()[0];
		var tmpMax=that.xScale.domain()[1];
		var len=tmpMax-tmpMin;
		if(len<that.trxCutoff || $("#forceTrxCBX"+that.gsvg.levelNumber).is(":checked")){
			that.drawAs="Trx";
		}
		//console.log("RefSeq draw:"+that.drawAs);
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
						overSelectable=1;
						$("#mouseHelp").html("<B>Double Click</B> to zoom in on this feature.");
						d3.select(this).style("fill","green");
			        	//that.gsvg.get('tt').transition()
			        	tt.transition()        
			                .duration(200)      
			                .style("opacity", .95);      
			        	//that.gsvg.get('tt').html(that.createToolTip(d))  
			        	tt.html(that.createToolTip(d))
			                .style("left", function(){
				                	var x=d3.event.pageX;
				                	if(x>that.gsvg.halfWindowWidth){
				                		x=x-450;
				                	}
				                	var xPos=x+"px";
				                	return xPos;
				                })
			                .style("top", (d3.event.pageY + 20) + "px");
			            //var add=(d.getAttribute("stop")*1-d.getAttribute("start")*1)*0.04;
			            var min=d.getAttribute("start")*1;
			            var max=d.getAttribute("stop")*1;
			            var newSvg= toolTipSVG("div#ttSVG",450,min,max,99,d.getAttribute("geneSymbol"),"transcript");
						//newSvg.selectedData=d;
						var dataArr=new Array();
						dataArr[0]=d;
						newSvg.addTrack("refSeq",2,"",dataArr);
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
				that.svg.attr("height", (that.trackYMax+2)*15);
			}
		}else if(that.drawAs="Trx"){
			that.drawnAs="Trx";
			//console.log("drawRefSeq as TRX");
			//console.log("density:"+that.density);
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
			//console.log(txList);
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
					//.attr("pointer-events", "all")
					//.style("cursor", "pointer")
					.on("mouseover", function(d) { 
								d3.select(this).selectAll("line").style("stroke","green");
								d3.select(this).selectAll("rect").style("fill","green");
								d3.select(this).selectAll("text").style("opacity","0.3").style("fill","green");
		            			tt.transition()        
									.duration(200)      
									.style("opacity", .95);      
								tt.html(that.createToolTip(d))  
									.style("left", function(){
					                	var x=d3.event.pageX;
					                	if(x>that.gsvg.halfWindowWidth){
					                		x=x-450;
					                	}
					                	var xPos=x+"px";
					                	return xPos;
					                })     
									.style("top", (d3.event.pageY +5) + "px");  
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
			
			 /*tx.each(function(d,i){
			 	that.drawTrx(d,i);
			 	return true;
			 });*/
			 tx.exit().remove();
			 //console.log("density:"+that.density);
			if(that.density==2){
				that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.trx"+that.gsvg.levelNumber).size()+1)*15);
			}else if(that.density==3){
				that.svg.attr("height", (that.trackYMax+2)*15);
			}else{
				that.svg.attr("height", 30);
			}
			//console.log(that.svg.attr("height"));
		}
		that.drawAs=prevDrawAs;
	};

	that.redrawLegend=function (){
		var legend=[];
		var curPos=0;
		legend=[{color:"#38A16F",label:"Validated"},{color:"#78E1AF",label:"Provisional"},{color:"#A8FFDF",label:"Inferred"},{color:"#A8DFFF",label:"Predicted"}];
		that.drawLegend(legend);
	};

	
	that.redrawLegend();
	//console.log("RefSeq First draw");
	//console.log(data);
	that.draw(data);
	
	return that;
}
/*Track for displaying Probesets*/
function ProbeTrack(gsvg,data,trackClass,label,density){
	var that= Track(gsvg,data,trackClass,label);
	that.density=density;
	that.colorSelect="annot";
	that.ttTrackList=new Array();
	that.ttTrackList[0]="coding";
	that.ttTrackList[1]="noncoding";
	that.ttTrackList[2]="smallnc";

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
		tooltiptext=tooltiptext+"Type: "+d.getAttribute("type")+"<BR><BR><table class=\"tooltipTable\" width=\"100%\" colSpace=\"0\"><tr><TH>Tissue</TH><TH>Heritability</TH><TH>DABG</TH></TR>";
		var tissues=$(".settingsLevel"+that.gsvg.levelNumber+" input[name=\"tissuecbx\"]:checked");
		var herit=getFirstChildByName(d,"herit");
		var dabg=getFirstChildByName(d,"dabg");
		for(var t=0;t<tissues.length;t++){
			var tissue=new String(tissues[t].id);
			tissue=tissue.substr(0,tissue.indexOf("Affy"));
			var hval=Math.floor(herit.getAttribute(tissue)*255);
			var hcol=d3.rgb(hval,0,0);
			var dval=Math.floor(dabg.getAttribute(tissue)*2.55);
			var dcol=d3.rgb(0,dval,0);
			tooltiptext=tooltiptext+"<TR><TD>"+tissue+"</TD><TD style=\"background:"+hcol+";color:white;\">"+herit.getAttribute(tissue)+"</TD><TD style=\"background:"+dcol+";color:white;\">"+dabg.getAttribute(tissue)+"%</TD></TR>";
		}
		tooltiptext=tooltiptext+"</table>";
		return tooltiptext;
	};

	that.redraw=function(){
		that.density=$("#probeDense"+that.gsvg.levelNumber+"Select").val();
		var curColor=$("#probe"+that.gsvg.levelNumber+"colorSelect").val();
		var tissues=$(".settingsLevel"+that.gsvg.levelNumber+" input[name=\"tissuecbx\"]:checked");
		var tissueLen=tissues.length;
		if(curColor!=that.colorSelect || ((that.colorSelect=="herit" || that.colorSelect=="dabg") && tissueLen!=that.tissueLen)){
			that.tissueLen=tissueLen;
			that.draw(that.data);
		}else{
			that.colorSelect=curColor;
			that.tissueLen=tissueLen;
			if(that.colorSelect=="dabg"||that.colorSelect=="herit"){
				if(that.colorSelect=="dabg"){
					that.drawScaleLegend("0%","100%","of Samples DABG","#000000","#00FF00");
				}else if(that.colorSelect=="herit"){
					that.drawScaleLegend("0","1.0","Probeset Heritability","#000000","#FF0000");
				}
				//console.log("redraw Tissues:");
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
				//console.log(tissues);
				
				var totalYMax=1;
				for(var t=0;t<tissues.length;t++){
					var tissue=new String(tissues[t].id);
					tissue=tissue.substr(0,tissue.indexOf("Affy"));
					
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
		var path=dataPrefix+"tmpData/regionData/"+folderName+"/probe.xml";
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
							d3.select("#Level"+that.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+track).attr("height", 15);
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
		if($("#probeDense"+that.gsvg.levelNumber+"Select").length>0){
			that.density=$("#probeDense"+that.gsvg.levelNumber+"Select").val();
		}
		if($("#probe"+that.gsvg.levelNumber+"colorSelect").length>0){
			that.colorSelect=$("#probe"+that.gsvg.levelNumber+"colorSelect").val();
		}
		if(that.colorSelect=="dabg"||that.colorSelect=="herit"){
			if(that.colorSelect=="dabg"){
				that.drawScaleLegend("0%","100%","of Samples DABG","#000000","#00FF00");
			}else if(that.colorSelect=="herit"){
				that.drawScaleLegend("0","1.0","Probeset Heritability","#000000","#FF0000");
			}
			that.svg.selectAll(".probe").remove();
			that.svg.selectAll(".tissueLbl").remove();
			var tissues=$(".settingsLevel"+that.gsvg.levelNumber+" input[name=\"tissuecbx\"]:checked");
			that.tissueLen=tissues.length;
			//console.log("redraw Tissues:");
			var totalYMax=1;
			//that.svg.selectAll(".probe").remove();
			for(var t=0;t<tissues.length;t++){
						var tissue=new String(tissues[t].id);
						tissue=tissue.substr(0,tissue.indexOf("Affy"));
						//console.log(t+":"+tissue);
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
						

						//update
						var probes=that.svg.selectAll(".probe."+tissue)
				   			.data(data,function(d){return keyTissue(d,tissue);})
							.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+(that.calcY(d.getAttribute("start"),d.getAttribute("stop"),that.density,i,2)+totalYMax*15-10)+")";})
										
						//add new
						probes.enter().append("g")
							.attr("class","probe "+tissue)
							.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+(that.calcY(d.getAttribute("start"),d.getAttribute("stop"),that.density,i,2)+totalYMax*15-10)+")";})
							.append("rect")
							.attr("class",tissue)
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
										overSelectable=1;
										$("#mouseHelp").html("<B>Double Click</B> to zoom in on this feature.");
										var thisD3=d3.select(this); 
										that.curTTColor=thisD3.style("fill");
										if(thisD3.style("opacity")>0){
											thisD3.style("fill","green");
							            	tt.transition()        
							                	.duration(200)      
							                	.style("opacity", .95);      
							            	tt.html(that.createToolTip(d))  
							                	.style("left", function(){
									                	var x=d3.event.pageX;
									                	if(x>that.gsvg.halfWindowWidth){
									                		x=x-450;
									                	}
									                	var xPos=x+"px";
									                	return xPos;
									                })     
							                	.style("top", (d3.event.pageY + 20) + "px");
							                //Setup Tooltip SVG
											var start=d.getAttribute("start")*1;
											var stop=d.getAttribute("stop")*1;
											var len=stop-start;
											var fivePerc=Math.floor(len*0.20);
											var newSvg=toolTipSVG("div#ttSVG",450,start-fivePerc,stop+fivePerc,99,d.getAttribute("ID"),"transcript");
											//Setup Track for current feature
											var dataArr=new Array();
											dataArr[0]=d;
											newSvg.addTrack(that.trackClass,3,"",dataArr);
											//Setup Other tracks included in the track type(listed in that.ttTrackList)
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
					overSelectable=1;
					$("#mouseHelp").html("<B>Double Click</B> to zoom in on this feature.");
					var thisD3=d3.select(this); 
					if(thisD3.style("opacity")>0){
						thisD3.style("fill","green");
		            	tt.transition()        
		                	.duration(200)      
		                	.style("opacity", .95);      
		            	tt.html(that.createToolTip(d))  
		                	.style("left", function(){
				                	var x=d3.event.pageX;
				                	if(x>that.gsvg.halfWindowWidth){
				                		x=x-250;
				                	}
				                	var xPos=x+"px";
				                	return xPos;
				                })     
		                	.style("top", (d3.event.pageY + 20) + "px"); 
		                //Setup Tooltip SVG
						var start=d.getAttribute("start")*1;
						var stop=d.getAttribute("stop")*1;
						var len=stop-start;
						var fivePerc=Math.floor(len*0.20);
						var newSvg=toolTipSVG("div#ttSVG",450,start-fivePerc,stop+fivePerc,99,d.getAttribute("ID"),"transcript");
						//Setup Track for current feature
						var dataArr=new Array();
						dataArr[0]=d;
						newSvg.addTrack(that.trackClass,3,"",dataArr);
						//Setup Other tracks included in the track type(listed in that.ttTrackList)
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
	};

	that.getDisplayedData= function (){
		var dataElem=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.probe");
		that.counts=[{value:0,names:"Core"},{value:0,names:"Extended"},{value:0,names:"Full"},{value:0,names:"Ambiguous"}];
		var tmpDat=dataElem[0];
		//console.log(tmpDat);
		var dispData=new Array();
		var dispDataCount=0;
		if (!(typeof tmpDat === 'undefined')) {
			for(var l=0;l<tmpDat.length;l++){
				var start=that.xScale(tmpDat[l].__data__.getAttribute("start"));
				var stop=that.xScale(tmpDat[l].__data__.getAttribute("stop"));
				//console.log("start:"+start+":"+stop);
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
	
	that.draw(data);

	
	return that;
}
/*Track for displaying SNPs/Indels*/
function SNPTrack(gsvg,data,trackClass,density,include){
	var that= Track(gsvg,data,trackClass,lbl);
	var strain=(new String(trackClass)).substr(3);
	var lbl=strain;
	if(lbl=="SHRH"){
		lbl="SHR/OlaPrin";
	}else if(lbl=="BNLX"){
		lbl="BN-Lx/CubPrin";
	}else if(lbl=="SHRJ"){
		lbl="SHR/NCrlPrin";
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

	that.ttTrackList=new Array();
	that.ttTrackList[0]="coding";
	that.ttTrackList[1]="noncoding";
	that.ttTrackList[2]="smallnc";
	that.ttTrackList[3]="probe";


	that.redraw=function (){
		that.density=$("#snp"+strain+"Dense"+that.gsvg.levelNumber+"Select").val();
		that.include=$("#snp"+strain+that.gsvg.levelNumber+"Select").val();
		if(that.density==null || that.density==undefined){
			that.density=1;
		}
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
		//console.log("SNP Larger width:"+that.xScale(1));
		if(that.xScale(that.xScale.domain()[0]+1)>6){
			//console.log("SNP Larger width:"+that.xScale(that.xScale.domain()[0]+1));
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
			tooltip=tooltip+"-"+(d.getAttribute("stop"));
		}
		return tooltip;
	};

	that.update=function (d){
		that.redraw();
	};
	
	that.updateData = function(retry){
		var tag="Snp";
		var path=dataPrefix+"tmpData/regionData/"+folderName+"/snp"+that.strain+".xml";
		that.include=$("#"+that.trackClass+that.gsvg.levelNumber+"Select").val();
		that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").val();
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
							d3.select("#Level"+that.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+track).attr("height", 15);
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
		//console.log("getDisplayedData");
		var dataElem=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".snp");
		//that.counts=[{value:0,perc:0,names:"SNP "+that.displayStrain},{value:0,perc:0,names:"Insertion "+that.displayStrain},{value:0,perc:0,names:"Deletion "+that.displayStrain}];
		that.counts=[{value:0,perc:0,names:"SNP"},{value:0,perc:0,names:"Insertion"},{value:0,perc:0,names:"Deletion"}];
		var tmpDat=dataElem[0];
		var dispData=new Array();
		var dispDataCount=0;
		var total=0;
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
				d3.select(this).style("fill","green");
		            tt.transition()        
		                .duration(200)      
		                .style("opacity", .95);      
		            tt.html(that.createToolTip(d))  
		                .style("left", function(){
					                	var x=d3.event.pageX;
					                	if(x>that.gsvg.halfWindowWidth){
					                		x=x-150;
					                	}
					                	var xPos=x+"px";
					                	return xPos;
					                })     
		                .style("top", (d3.event.pageY + 20) + "px");
		            var start=d.getAttribute("start")*1;
		            var stop=d.getAttribute("stop")*1;
	            	var newSvg=toolTipSVG("div#ttSVG",450,d.getAttribute("start")*1-10,d.getAttribute("stop")*1+10,99,that.getDisplayID(d),"transcript");
					//Setup Track for current feature
					var dataArr=new Array();
					dataArr[0]=d;
					newSvg.addTrack(that.trackClass,3,"",dataArr);

					//Setup Other tracks included in the track type(listed in that.ttTrackList)
					for(var r=0;r<that.ttTrackList.length;r++){
						var tData=that.gsvg.getTrackData(that.ttTrackList[r]);
						var fData=new Array();
						if(tData!=undefined&&tData.length>0){
							var fCount=0;
							for(var s=0;s<tData.length;s++){
								if(tData[s].getAttribute("start")<=start&&start<=tData[s].getAttribute("stop")){
									fData[fCount]=tData[s];
									fCount++;
								}
							}
							if(fData.length>0){
								newSvg.addTrack(that.ttTrackList[r],3,"DrawTrx",fData);	
							}
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
		//console.log(color);
		return color;
	};


	that.redrawLegend=function (){
		var legend=[];
		if(that.include==4){
			if(that.strain=="BNLX"){
				legend=[{color:"#0000FF",label:"SNP"},{color:"#000096",label:"Indel"}];
			}else if(that.strain=="SHRH"){
				legend=[{color:"#FF0000",label:"SNP"},{color:"#960000",label:"Indel"}];
			}else if(that.strain=="SHRJ"){
				legend=[{color:"#00FF00",label:"SNP"},{color:"#009600",label:"Indel"}];
			}else if(that.strain=="F344"){
				legend=[{color:"#00FFFF",label:"SNP"},{color:"#009696",label:"Indel"}];
			}else{
				legend=[{color:"#DEDEDE",label:"SNP"},{color:"#969696",label:"Indel"}];
			}
		}else if(that.include==3 || that.include==2){
			if(that.strain=="BNLX"){
				legend=[{color:"#000096",label:"Indel"}];
			}else if(that.strain=="SHRH"){
				legend=[{color:"#960000",label:"Indel"}];
			}else if(that.strain=="SHRJ"){
				legend=[{color:"#009600",label:"Indel"}];
			}else if(that.strain=="F344"){
				legend=[{color:"#009696",label:"Indel"}];
			}else{
				legend=[{color:"#969696",label:"Indel"}];
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
	that.include=include;
	that.density=density;
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
		d3.xml(dataPrefix+"tmpData/regionData/"+folderName+"/qtl.xml",function (error,d){
					if(error){
						if(success!=1 && retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								that.updateDate(retry+1);
							},time);
						}else if(success!=1){
							d3.select("#Level"+that.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+track).attr("height", 15);
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
		//console.log("QTL CALCY:"+d.getAttribute("ID"));
		//console.log(typeof that.idList[d.getAttribute("ID")]);
		if(typeof that.idList[d.getAttribute("ID")] === "undefined"){
			ret=that.yCount++;
			//console.log("RET:"+ret);
		}
		return (ret+1)*15;
	}
	that.draw=function(data){
		that.data=data;
		that.yCount=0;
		that.idList=new Array();
		//update
		that.svg.selectAll(".qtl").remove();
		//console.log(data);
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
				overSelectable=1;
				$("#mouseHelp").html("<B>Click</B> to see additional details. <B>Double Click</B> to zoom in on this feature.");
				d3.select(this).style("fill","green");
	            tt.transition()        
	                .duration(200)      
	                .style("opacity", .95);      
	            tt.html(that.createToolTip(d))  
	                .style("left", function(){
				                	var x=d3.event.pageX;
				                	if(x>that.gsvg.halfWindowWidth){
				                		x=x-250;
				                	}
				                	var xPos=x+"px";
				                	return xPos;
				                })     
	                .style("top", (d3.event.pageY + 20) + "px");
	            that.triggerTableFilter(d);
	            })
			.on("mouseout", function(d) {
				overSelectable=0;
				$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
				var nameStr=d.getAttribute("name");
				var re = /[0-9]+\s*$/g;
				var end1=nameStr.search(re);
				//console.log("End Number"+nameStr+"::"+end1);
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

		qtls[0].forEach(function(d){
				var nameStr=new String(d.__data__.getAttribute("name"));
				var re = /[0-9]+\s*$/g;
				var end1=nameStr.search(re);
				//console.log("End Number"+nameStr+"::"+end1);
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
		});
		that.svg.attr("height", that.yCount*15);
		//that.getDisplayedData();
	};
	that.draw(data);
	that.redraw();
	return that;
}
/*Track to display transcripts for a selected Gene*/
function TranscriptTrack(gsvg,data,trackClass,density){
	var that= Track(gsvg,data,trackClass,"Selected Gene Transcripts");

	that.createToolTip= function(d){
		//console.log("transcript toottip");
		var tooltip="";
		var strand=".";
		if(d.getAttribute("strand") == 1){
			strand="+";
		}else if(d.getAttribute("strand")==-1){
			strand="-";
		}
		var id=d.getAttribute("ID");
		if(id.indexOf("ENS")==-1){
			id=id.substr(id.indexOf("_")+1);
			id=id.replace(/^0+/, '');
			id="Brain.T"+id;
		}
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
				//console.log("xPos1:"+xPos1);
				//console.log("xWidth1:"+xWidth1);
				//console.log("xPos2:"+xPos2);
				//console.log("xWidth2:"+xWidth2);
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
					/*d3.select("g#tx"+d.getAttribute("ID")+" rect#Ex"+exList[m].getAttribute("ID"))
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
						d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" g#tx"+d.getAttribute("ID")+" line#Int"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID"))
							.attr("x1",intStart)
							.attr("x2",intStop);

						d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" g#tx"+d.getAttribute("ID")+" #IntTxt"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID"))
							.attr("dx",intStart+1).text(fullChar);
					}
				}
			});
	};

	that.update = function(){
		var txList=getAllChildrenByName(getFirstChildByName(that.gsvg.selectedData,"TranscriptList"),"Transcript");
		that.txMin=that.gsvg.selectedData.getAttribute("extStart");
		that.txMax=that.gsvg.selectedData.getAttribute("extStop");
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
							d3.select(this).selectAll("line").style("stroke","green");
							d3.select(this).selectAll("rect").style("fill","green");
							d3.select(this).selectAll("text").style("opacity","0.3").style("fill","green");
	            			tt.transition()        
								.duration(200)      
								.style("opacity", .95);      
							tt.html(that.createToolTip(d))  
								.style("left", function(){
				                	var x=d3.event.pageX;
				                	if(x>that.gsvg.halfWindowWidth){
				                		x=x-450;
				                	}
				                	var xPos=x+"px";
				                	return xPos;
				                })     
								.style("top", (d3.event.pageY +5) + "px");  
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
		}
		that.drawLegend(legend);
	};

	that.calcY=function(d,i){
		return (i+1)*15;
	}

	that.redrawLegend=function (){
		var legend=[];
		var curPos=0;
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
		that.drawLegend(legend);
	};

	that.txMin=that.gsvg.selectedData.getAttribute("extStart");
	that.txMax=that.gsvg.selectedData.getAttribute("extStop");
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
						d3.select(this).selectAll("line").style("stroke","green");
						d3.select(this).selectAll("rect").style("fill","green");
						d3.select(this).selectAll("text").style("opacity","0.3").style("fill","green");
            			tt.transition()        
							.duration(200)      
							.style("opacity", .95);      
						tt.html(that.createToolTip(d))  
							.style("left", function(){
				                	var x=d3.event.pageX;
				                	if(x>that.gsvg.halfWindowWidth){
				                		x=x-450;
				                	}
				                	var xPos=x+"px";
				                	return xPos;
				                })     
							.style("top", (d3.event.pageY +5) + "px");  
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
	var lbl="Helicos RNA log2(read counts)";
	that.updateLabel(lbl);
	that.redrawLegend();
	return that;
}
function IlluminaSmallTrack(gsvg,data,trackClass,density){
	var that= CountTrack(gsvg,data,trackClass,density);
	var lbl="Illumina Small RNA log2(read counts)";
	that.updateLabel(lbl);
	that.redrawLegend();
	return that;
}
function IlluminaTotalTrack(gsvg,data,trackClass,density){
	var that= CountTrack(gsvg,data,trackClass,density);
	var lbl="Illumina Total RNA(rRNA depleted) log2(read counts)";
	that.updateLabel(lbl);
	that.redrawLegend();
	return that;
}
function IlluminaPolyATrack(gsvg,data,trackClass,density){
	var that= CountTrack(gsvg,data,trackClass,density);
	var lbl="Illumina PolyA+ RNA log2(read counts)";
	that.updateLabel(lbl);
	that.redrawLegend();
	return that;
}
function SpliceJunctionTrack(gsvg,data,trackClass,label,density,additionalOptions){
	var that= GenericTranscriptTrack(gsvg,data,trackClass,label,density,additionalOptions);
	
	that.dataFileName="spliceJnct.xml";
	that.xmlTag="Feature";
	that.xmlTagBlockElem="block";
	that.idPrefix="splcJnct";
	that.ttSVG=1;
	that.ttTrackList=new Array();
	that.ttTrackList[0]="coding";
	that.colorValueField="readCount";
	that.colorScale=d3.scale.linear().domain([1,1000]).range(["#E6E6E6","#000000"]);

	

	that.getDisplayID=function(d){
		return	d.getAttribute("name");
	};

	that.createToolTip=function(d){
		//console.log("splice junction tooltip");
		//console.log(that.gsvg);
		var tooltip="";
		tooltip=tooltip+"<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div><BR>ID: "+d.getAttribute("name");
		tooltip=tooltip+"<BR>Read Counts="+numberWithCommas(d.getAttribute("readCount"));
		tooltip=tooltip+"<BR>Splice Junction in "+d.getAttribute("sampleCount")+" of 6 samples(3 BN-Lx, 3 SHR)";
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
		//console.log(tooltip);
		return tooltip;
	};

   	that.drawScaleLegend("1","1000+","Read Counts","#E6E6E6","#000000");
	that.draw(data);
	return that;
}
/*Generic numeric track which displays numeric values accross the genome*/
function CountTrack(gsvg,data,trackClass,density){
	var that= Track(gsvg,data,trackClass,"Generic Counts");

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
	that.prevDensity=density;
	that.displayBreakDown=null;
	var tmpMin=that.gsvg.xScale.domain()[0];
	var tmpMax=that.gsvg.xScale.domain()[1];
	var len=tmpMax-tmpMin;
	that.bin=that.calculateBin(len);

	that.color= function (d){
		var color="#FFFFFF";
		if(d.getAttribute("logcount")>0){
			color=d3.rgb(that.colorScale(d.getAttribute("logcount")));
		}		
		return color;
	};

	that.redraw= function (){
		that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").val();
		var tmpMin=that.gsvg.xScale.domain()[0];
		var tmpMax=that.gsvg.xScale.domain()[1];
		//var len=tmpMax-tmpMin;
		var tmpBin=that.bin;
		//console.log("redraw bin:"+tmpBin);
		var tmpW=that.xScale(tmpMin+tmpBin)-that.xScale(tmpMin);
		//console.log("curBinWidth:"+tmpW);
		/*if(tmpW>2||tmpW<0.5){
			that.updateFullData(0,1);
		}*//*else if(tmpMin<that.prevMinCoord||tmpMax>that.prevMaxCoord){
			that.updateFullData(0,1);
		}*///else{
			that.prevMinCoord=tmpMin;
			that.prevMaxCoord=tmpMax;
			//console.log("count:redraw("+that.density+")");
			if(that.density==1){
				if(that.density!=that.prevDensity){
					that.redrawLegend();
					var tmpMax=that.gsvg.xScale.domain()[1];
					that.prevDensity=that.density;
					that.svg.selectAll(".area").remove();
					that.svg.selectAll("g.y").remove();
					that.svg.selectAll(".grid").remove();
					var points=that.svg.selectAll("."+that.trackClass).data(that.data,keyStart)
			    	points.enter()
							.append("rect")
							.attr("x",function(d){return that.xScale(d.getAttribute("start"));})
							.attr("y",15)
							.attr("class", that.trackClass)
				    		.attr("height",10)
							.attr("width",function(d,i) {
											   var wX=1;
											   if((i+1)<that.data.length){
											   		if(that.xScale((that.data[i+1].getAttribute("start")))-that.xScale(d.getAttribute("start"))>1){
												   		wX=that.xScale((that.data[i+1].getAttribute("start")))-that.xScale(d.getAttribute("start"));
											   		}
												}else{
													if(that.xScale(tmpMax)-that.xScale(d.getAttribute("start"))>1){
												   		wX=that.xScale(tmpMax)-that.xScale(d.getAttribute("start"));
											   		}
												}
											   return wX;
											   })
							.attr("fill",that.color)
							.on("mouseover", function(d) { 
								d3.select(this).style("fill","green");
		            			tt.transition()        
									.duration(200)      
									.style("opacity", .95);      
								tt.html(that.createToolTip(d))  
									.style("left", function(){
					                	var x=d3.event.pageX;
					                	if(x>that.gsvg.halfWindowWidth){
					                		x=x-450;
					                	}
					                	var xPos=x+"px";
					                	return xPos;
					                })    
									.style("top", (d3.event.pageY +5) + "px");  
		            			})
							.on("mouseout", function(d) {  
								d3.select(this).style("fill",that.color);
					            tt.transition()
									 .delay(500)       
					                .duration(200)      
					                .style("opacity", 0);
					        });
				}else{
					that.svg.selectAll("."+that.trackClass).attr("x",function(d){return that.xScale(d.getAttribute("start"));})
						.attr("width",function(d,i) {
											   var wX=1;
											   if((i+1)<that.data.length){
											   		if(that.xScale((that.data[i+1].getAttribute("start")))-that.xScale(d.getAttribute("start"))>1){
												   		wX=that.xScale((that.data[i+1].getAttribute("start")))-that.xScale(d.getAttribute("start"));
											   		}
												}else{
													if(that.xScale(tmpMax)-that.xScale(d.getAttribute("start"))>1){
												   		wX=that.xScale(tmpMax)-that.xScale(d.getAttribute("start"));
											   		}
												}
											   return wX;
											   });
				}
				that.svg.attr("height", 30);
			}else if(that.density==2){
				/*
				var tmpMin=that.xScale.domain()[0];
				var tmpMax=that.xScale.domain()[1];

				that.y.domain([0, d3.max(that.data, function(d,i) {
					var ret=d.getAttribute("logcount");
					var start=d.getAttribute("start");
					if(start<tmpMin || start>tmpMax){
						ret=0;
					}
					return ret; 
					})]);
					*/

				that.svg.select(".area").remove();
				that.area = d3.svg.area()
	    				.x(function(d) { return that.xScale(d.getAttribute("start")); })
					    .y0(140)
					    .y1(function(d) { return that.y(d.getAttribute("logcount")); });
				//that.y.domain([0, d3.max(that.data, function(d) { return d.getAttribute("logcount"); })]);

				if(that.density!=that.prevDensity){
					that.redrawLegend();
					that.prevDensity=that.density;
					that.svg.selectAll("."+that.trackClass).remove();
					that.svg.append("g")
					      .attr("class", "y axis")
					      .call(that.yAxis);
				    that.svg.select("g.y").selectAll("text").each(function(){d3.select(this).attr("x","10").attr("dy","0.05em");});
					that.svg.append("g")         
			        	.attr("class", "grid")
			        	.call(that.yAxis
			            		.tickSize((-that.gsvg.width+10), 0, 0)
			            		.tickFormat("")
			        		);
			        that.svg.append("path")
				      	.datum(that.data)
				      	.attr("class", "area")
				      	.attr("stroke","steelblue")
				      	.attr("fill","steelblue")
				      	.attr("d", that.area);
				}else{
					
					//that.svg.select("g.y.axis").remove();
					//that.svg.selectAll("g.grid").remove();

					/*that.svg.append("g")
				      .attr("class", "y axis")
				      .call(that.yAxis);

			     	that.svg.select("g.y").selectAll("text").each(function(){d3.select(this).attr("x","10").attr("dy","0.05em");});

			    	that.svg.append("g")         
				        .attr("class", "grid")
				        .call(that.yAxis
				            		.tickSize((-that.gsvg.width+10), 0, 0)
				            		.tickFormat("")
				        		);*/

					that.svg.append("path")
				      	.datum(that.data)
				      	.attr("class", "area")
				      	.attr("stroke","steelblue")
				      	.attr("fill","steelblue")
				      	.attr("d", that.area);
				}			
				that.svg.attr("height", 140);
			}
		//}
	};

	that.createToolTip=function (d){
		var tooltip="";
		tooltip="log2(read count)="+d.getAttribute("logcount");
		if(that.bin>0){
			var tmpEnd=(d.getAttribute("start")*1)+(that.bin*1);
			tooltip=tooltip+"*<BR><BR>*Data compressed for display. Using 90th percentile of<BR>region:"+numberWithCommas(d.getAttribute("start"))+"-"+numberWithCommas(tmpEnd)+"<BR><BR>Zoom in further to see raw data(roughly a region <1000bp). The bin size will decrease as you zoom in thus the resolution of the count data will improve as you zoom in.";
		}else{
			tooltip=tooltip+"<BR>Read Count:"+d.getAttribute("logcount");
		}
		return tooltip;
	};

	that.update=function (d){
		that.redraw();
	};

	that.updateFullData = function(retry,force){
		//that.showLoading();
		var tmpMin=that.xScale.domain()[0];
		var tmpMax=that.xScale.domain()[1];
		var len=tmpMax-tmpMin;
		//that.showLoading();
		that.bin=that.calculateBin(len);
		var tag="Count";
		var file=dataPrefix+"tmpData/regionData/"+folderName+"/count"+that.trackClass+".xml";
		if(that.bin>0){
			file=dataPrefix+"tmpData/regionData/"+folderName+"/bincount."+that.bin+"."+that.trackClass+".xml";
		}
		//console.log("");
		d3.xml(file,function (error,d){
					if(error){
						console.log(error);
						if(retry==0 || force==1){
							$.ajax({
								url: contextPath +"/"+ pathPrefix +"generateTrackXML.jsp",
				   				type: 'GET',
								data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: that.trackClass, folder: folderName,binSize:that.bin},
								//data: {chromosome: chr,minCoord:minCoord,maxCoord:maxCoord,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: that.trackClass, folder: folderName,binSize:that.bin},
								dataType: 'json',
				    			success: function(data2){
				    				
				    			},
				    			error: function(xhr, status, error) {
				        			
				    			}
							});
						}
						if(retry<3){//wait before trying again
							var time=15000;
							if(retry==1){
								time=20000;
							}
							setTimeout(function (){
								that.updateFullData(retry+1);
							},time);
						}else{
							d3.select("#Level"+that.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+that.levelNumber+track).attr("height", 15);
							that.hideLoading();
						}
					}else{
						//console.log(d);
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
							var data=d.documentElement.getElementsByTagName("Count");
							that.draw(data);
							that.hideLoading();
						}
					}
					//that.hideLoading();
				});
	};

	that.draw=function(data){
		that.data=data;
		that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").val();
		that.redrawLegend();
		//console.log("count:draw("+that.density+")");
		var tmpMin=that.xScale.domain()[0];
		var tmpMax=that.xScale.domain()[1];
		var newData=[];
		var newCount=0;
		for(var l=0;l<data.length;l++){
			if(data[l]!=undefined ){
				if((l+1)<that.data.length){
					if(	(that.data[l].getAttribute("start")>=tmpMin&&that.data[l].getAttribute("start")<=tmpMax)
						||
						(that.data[l+1].getAttribute("start")>=tmpMin&&that.data[l+1].getAttribute("start")<=tmpMax)
						){
						newData[newCount]=data[l];
						newCount++;
					}else{ 

					}
				}else{
					if((that.data[l].getAttribute("start")>=tmpMin&&that.data[l].getAttribute("start")<=tmpMax)){
						newData[newCount]=data[l];
						newCount++;
					}else{

					}
				}
			}
		}
		data=newData;

		if(that.density==1){
			var tmpMax=that.gsvg.xScale.domain()[1];
	    	var points=that.svg.selectAll("."+that.trackClass)
	   			.data(data,keyStart)
	    	points.enter()
					.append("rect")
					.attr("x",function(d){return that.xScale(d.getAttribute("start"));})
					.attr("y",15)
					.attr("class", that.trackClass)
		    		.attr("height",10)
					.attr("width",function(d,i) {
									   var wX=1;
									   if((i+1)<that.data.length){
										   if(that.xScale((that.data[i+1].getAttribute("start")))-that.xScale(d.getAttribute("start"))>1){
											   wX=that.xScale((that.data[i+1].getAttribute("start")))-that.xScale(d.getAttribute("start"));
										   }
										}else{
											if(that.xScale(tmpMax)-that.xScale(d.getAttribute("start"))>1){
											   	wX=that.xScale(tmpMax)-that.xScale(d.getAttribute("start"));
										   	}
										}
									   return wX;
									   })
					.attr("fill",that.color)
					.on("mouseover", function(d) { 
						d3.select(this).style("fill","green");
            			tt.transition()        
							.duration(200)      
							.style("opacity", .95);      
						tt.html(that.createToolTip(d))  
							.style("left", function(){
				                	var x=d3.event.pageX;
				                	if(x>that.gsvg.halfWindowWidth){
				                		x=x-450;
				                	}
				                	var xPos=x+"px";
				                	return xPos;
				                })     
							.style("top", (d3.event.pageY +5) + "px");  
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
	    	that.y.domain([0, d3.max(that.data, function(d) { return d.getAttribute("logcount"); })]);
	    	that.yAxis = d3.svg.axis()
    				.scale(that.y)
    				.orient("left")
    				.ticks(5);

	    	that.svg.append("g")
		      .attr("class", "y axis")
		      .call(that.yAxis);

		     that.svg.select("g.y").selectAll("text").each(function(){d3.select(this).attr("x","10").attr("dy","0.05em");});

	    	that.svg.append("g")         
		        .attr("class", "grid")
		        .call(that.yAxis
		            		.tickSize((-that.gsvg.width+10), 0, 0)
		            		.tickFormat("")
		        		);
		    that.svg.select(".area").remove();
		    that.svg.append("path")
		      	.datum(data)
		      	.attr("class", "area")
		      	.attr("stroke","steelblue")
		      	.attr("fill","steelblue")
		      	.attr("d", that.area);
			that.svg.attr("height", 140);
		}
	};

	that.redrawLegend=function (){
		that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").val();
		if(that.density==2){
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".legend").remove();
		}else if(that.density==1){
			var lblStr=new String(that.label);
			var x=that.gsvg.width/2+(lblStr.length/2)*7.5+5;
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".legend").remove();
			that.svg.append("text").text("0").attr("class","legend").attr("x",x-15).attr("y",12);
			
			for(var i=0;i<that.colorRange.length;i++){
				that.svg.append("rect")
					.attr("class","legend")
					.attr("x",x)
					.attr("y",0)
			    	.attr("height",12)
					.attr("width",10)
					.attr("fill",that.colorRange[i])
					.attr("stroke",that.colorRange[i]);
				x=x+10;
			}
			that.svg.append("text").text("16+").attr("class","legend").attr("x",x+10).attr("y",12);
		}
		
	};

	that.y = d3.scale.linear()
    	.range([140, 20]);
    that.colorDomain=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
    that.colorRange=["#FFFFFF","#EEEEEE","#DDDDDD","#CCCCCC","#BBBBBB","#AAAAAA","#999999","#888888","#777777","#666666","#555555","#444444","#333333","#222222","#111111","#000000"];
   	that.colorScale= d3.scale.threshold()
   						.domain(that.colorDomain)
   						.range(that.colorRange);
    that.area = d3.svg.area()
    				.x(function(d) { return that.xScale(d.getAttribute("start")); })
				    .y0(140)
				    .y1(function(d) { return that.y(d.getAttribute("logcount")); });
    that.y.domain([0, d3.max(that.data, function(d) { return d.getAttribute("logcount"); })]);
    that.yAxis = d3.svg.axis()
    				.scale(that.y)
    				.orient("left")
    				.ticks(5);
   	that.redrawLegend();
    that.draw(data);
	return that;
}

function CustomTranscriptTrack(gsvg,data,trackClass,label,density,additionalOptions){
	var that=GenericTranscriptTrack(gsvg,data,trackClass,label,density,additionalOptions);
	that.dataFileName=trackClass.substr(6)+".bed";
	that.density=3;
	that.colorValueField="score";

	that.updateFullData = function(retry,force){
		var tmpMin=that.xScale.domain()[0];
		var tmpMax=that.xScale.domain()[1];
		var file=dataPrefix+"tmpData/trackXML/"+folderName+"/"+that.dataFileName+".xml";
		var bedFile=dataPrefix+"tmpData/trackUpload/"+that.dataFileName;
		//console.log(file);
		//console.log(bedFile);
		d3.xml(file,function (error,d){
					if(error){
						console.log(error);
						if(retry==0 || force==1){
							//console.log("calling ajax");
							$.ajax({
								url: contextPath +"/"+ pathPrefix +"generateTrackXML.jsp",
				   				type: 'GET',
								data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,folder:folderName,bedFile: bedFile,outFile:file,track:that.trackClass},
								//data: {chromosome: chr,minCoord:minCoord,maxCoord:maxCoord,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: that.trackClass, folder: folderName,binSize:that.bin},
								dataType: 'json',
				    			success: function(data2){
				    				console.log("custom ajax success");
				    				console.log(data2);
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
							that.hideLoading();
						}
					}else{
						//console.log(d);
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
							//console.log(data);
							that.draw(data);
							that.hideLoading();
						}
					}
				});
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
	that.colorValueField="Score";
	that.colorBy="Score";
	that.minValue=1;
	that.maxValue=1000;
	that.minColor="#E6E6E6";
	that.maxColor="#000000";
	//Set Specified Options
	var addtlOpt=new String(additionalOptions);
	//console.log(additionalOptions);
	if(additionalOptions.length>0){
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

	//setup color scales if needed
	//if(that.minColor!=undefined && that.maxColor!=undefined){
		
	//}

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

	that.drawTrx=function (d,i){
		//console.log("genericTrx.drawTrx("+i+")");
		//console.log(d);
		var txG=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).select("#"+that.idPrefix+"tx"+d.getAttribute("ID"));
		exList=getAllChildrenByName(getFirstChildByName(d,that.xmlTagBlockElem+"List"),that.xmlTagBlockElem);
		for(var m=0;m<exList.length;m++){
			var curR=txG.append("rect")
			.attr("x",function(d){ return that.xScale(exList[m].getAttribute("start"))-that.xScale(d.getAttribute("start")); })
			.attr("rx",1)
			.attr("ry",1)
	    	.attr("height",10)
			.attr("width",function(d){ return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start")); })
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
		var tmpDen=that.checkDensity();
		if(tmpDen!=that.density){
			that.draw(that.data);
		}else{
			//console.log("genericTrx.redraw()");
			that.yMaxArr=new Array();
			that.yArr=new Array();
			that.yArr[0]=new Array();
			for(var p=0;p<that.gsvg.width;p++){
					that.yMaxArr[p]=0;
					that.yArr[0][p]=0;
			}
			that.trackYMax=0;
			//console.log("g."+that.idPrefix+"trx"+that.gsvg.levelNumber);
			var txG=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g."+that.idPrefix+"trx"+that.gsvg.levelNumber)
				.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i)+")";});
			txG.each(function(d,i){
				//console.log("genericTrx.redraw().each()");
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
		}
	};

	that.update=function (d){
		that.redraw();
	};

	that.updateFullData = function(retry,force){
		var tmpMin=that.xScale.domain()[0];
		var tmpMax=that.xScale.domain()[1];
		var file=dataPrefix+"tmpData/regionData/"+folderName+"/"+that.dataFileName;
		d3.xml(file,function (error,d){
					if(error){
						console.log(error);
						if(retry==0 || force==1){
							$.ajax({
								url: contextPath +"/"+ pathPrefix +"generateTrackXML.jsp",
				   				type: 'GET',
								data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: that.trackClass, folder: folderName},
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
							that.hideLoading();
						}
					}else{
						//console.log(d);
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
							//console.log(data);
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
			that.drawScaleLegend(that.minValue,that.maxValue+"+","",that.minColor,that.maxColor);
		}else if(that.colorBy=="Color"){
			legend[curPos]={color:"#FFFFFF",label:"User assigned color from track file."};
			that.drawLegend(legend);
		}
		
	};


	that.checkDensity=function(){
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
			console.log("density="+that.density);
		}
		console.log("return:"+that.density);
	};

	that.draw=function(data){
		that.data=data;
		that.setDensity();
		that.trackYMax=0;
		that.yArr=new Array();
		that.yArr[0]=new Array();
		for(var j=0;j<that.gsvg.width;j++){
				that.yMaxArr[j]=0;
				that.yArr[0][j]=0;
		}
		//console.log("GenericTranscriptTrack.draw()");
		//console.log(data);

		d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("."+that.idPrefix+"trx"+that.gsvg.levelNumber).remove();
		//console.log("#Level"+that.gsvg.levelNumber+that.trackClass);
		//console.log("."+that.idPrefix+"trx"+that.gsvg.levelNumber);
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
							//console.log("mouseover GenericTranscriptTrack");
							d3.select(this).selectAll("line").style("stroke","green");
							d3.select(this).selectAll("rect").style("fill","green");
							d3.select(this).selectAll("text").style("opacity","0.3").style("fill","green");
	            			tt.transition()        
								.duration(200)      
								.style("opacity", .95);      
							tt.html(that.createToolTip(d))  
								.style("left", function(){
					                	var x=d3.event.pageX;
					                	if(x>that.gsvg.halfWindowWidth){
					                		x=x-450;
					                	}
					                	var xPos=x+"px";
					                	return xPos;
					                })     
								.style("top", (d3.event.pageY +5) + "px");
							if(that.ttSVG==1){
								//Setup Tooltip SVG
								var start=d.getAttribute("start")*1;
								var stop=d.getAttribute("stop")*1;
								var len=stop-start;
								var fivePerc=Math.floor(len*0.05);
								var newSvg=toolTipSVG("div#ttSVG",450,start-fivePerc,stop+fivePerc,99,that.getDisplayID(d),"transcript");
								//Setup Track for current feature
								var dataArr=new Array();
								dataArr[0]=d;
								newSvg.addTrack(that.trackClass,3,"",dataArr);
								//Setup Other tracks included in the track type(listed in that.ttTrackList)
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
								}
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
		if(that.density==1){
							that.svg.attr("height", 30);
		}else if(that.density==2){
							that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g."+that.idPrefix+"trx"+that.gsvg.levelNumber).size()+1)*15);
		}else if(that.density==3){
							that.svg.attr("height", (that.trackYMax+2)*15);
		}
	};
	return that;
}


