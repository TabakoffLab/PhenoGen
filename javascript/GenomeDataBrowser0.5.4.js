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

ratOnly["snpSHRJ"]=1;
ratOnly["snpF344"]=1;
ratOnly["snpSHRH"]=1;
ratOnly["snpBNLX"]=1;
ratOnly["helicos"]=1;
ratOnly["illuminaTotal"]=1;
ratOnly["illuminaSmall"]=1;
ratOnly["illuminaPolyA"]=1;



var mmVer="Mouse(mm10) Strain:C57BL/6J";
var rnVer="Rat(rn5) Strain:BN";
var siteVer="PhenoGen v2.10(12/4/2013)";

var trackBinCutoff=10000;

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
				var cl=$(this).attr("class");
				var value=$(this).val();
				var level=idStr.substr(idStr.length-7,1);
				if(level=="S"){
					level=idStr.substr(idStr.length-8,1);
				}
				if(idStr.indexOf("Dense")>0){
					if(idStr.indexOf("coding")>-1 || idStr.indexOf("smallnc")>-1){
						$("."+cl).each(function(){
							$(this).val(value);
						});
					}
					svgList[level].redraw();
				}else if(idStr.indexOf("snp")==0){
					svgList[level].updateData();
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
				//console.log("height:"+curlvl);
	 			changeTrackHeight("Level"+curlvl,$(this).val());
	 			$.cookie("imgstate"+defaultView+curlvl,"displaySelect"+curlvl+"="+$(this).val()+";");
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
				if(i==0){
					DisplayRegionReport();
				}
				svgList[i].updateFullData();
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
	var min=Math.round(topSVG.xScale.domain()[0]);
	var max=Math.round(topSVG.xScale.domain()[1]);
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

function redrawTrack(level,track){

	svgList[level].redrawTrack(track);
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
    			},
    			async:   false
			});
}

function loadState(levelInd){
	//console.log("loadState("+levelInd+")");
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
    	//console.log("LOADING:"+trackListObj);
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
    	//console.log("img state:"+trackListObj);
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
    	$("input[name='trackcbx']").each(function(){
    		if($(this).is(":checked")){
    			//console.log("unchecking"+$(this).attr("id"));
    			$(this).prop('checked', false);
    		}
    	});
    	//console.log("SETUP UI");
    	for(var m=0;m<trackArray.length;m++){
    		var trackVars=trackArray[m].split(",");
    		//console.log("setupTrackVars[0] "+trackVars[0]);
    		//console.log(trackVars);
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
		console.log("no cookie:"+"state"+defaultView+levelInd+"trackList");
	}
}

function setupImageSettingUI(levelInd){
	if($.cookie("imgstate"+defaultView+levelInd)!=null){
    	var trackListObj=$.cookie("imgstate"+defaultView+levelInd);
    	//console.log("img state:"+trackListObj);
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
	//console.log("setupDefaultView:"+defaultView);
	$("input[name='trackcbx']").each(function(){
    		if($(this).is(":checked")){
    			//console.log("unchecking"+$(this).attr("id"));
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
		$("div.settingsLevel"+levelInd+" #noncodingCBXt"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #probeCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #smallncCBXt"+levelInd).prop('checked',true);
		svgList[levelInd].addTrack("coding",3,addtl,0);
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
		$("div.settingsLevel"+levelInd+" #noncodingCBXg"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #noncodingCBXt"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #smallncCBXg"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #smallncCBXt"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #refSeqCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #probeCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #snpSHRHCBX"+levelInd).prop('checked',true);
		$("div.settingsLevel"+levelInd+" #snpBNLXCBX"+levelInd).prop('checked',true);
		svgList[levelInd].addTrack("coding",3,addtl,0);
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
	//Need to preserve Rat or Mouse Only tracks while other species is viewed
	if($.cookie("state"+defaultView+curLevel+"trackList")!=null){
    	var trackListObj=$.cookie("state"+defaultView+curLevel+"trackList");
    	var trackArray=trackListObj.split(";");
    	for(var m=0;m<trackArray.length;m++){
    		var trackVars=trackArray[m].split(",");
    		if((organism=="Rn" && mouseOnly[trackVars[0]]!= undefined) || (organism=="Mm" && ratOnly[trackVars[0]]!= undefined)){
	    		cookieStr=cookieStr+trackArray[m]+";";
    		}
    	}
    }
	$.cookie("state"+defaultView+curLevel+"trackList",cookieStr);
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
function key(d) {return d.getAttribute("ID");};
function keyName(d) {return d.getAttribute("name");};
function keyStart(d) {return d.getAttribute("start");};
function keyTissue(d,tissue){return d.getAttribute("ID")+tissue;};

//SVG functions
function GenomeSVG(div,imageWidth,minCoord,maxCoord,levelNumber,title,type){
	this.get=function(attr){return this[attr];}.bind(this);
	
	this.addTrack=function (track,density,additionalOptions,retry){
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
	        			folderName=data2.folderName;
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
				var dragDiv=this.topLevel.append("li").attr("class","draggable"+this.levelNumber);
				var svg = dragDiv.append("svg:svg")
				.attr("width", this.get('width'))
				.attr("height", 30)
				.attr("class", "track")
				.attr("id","Level"+this.levelNumber+track)
				.attr("pointer-events", "all")
				.style("cursor", "move")
				.on("mouseover", function(){
					if(overSelectable==0){
						$("#mouseHelp").html("<B>Navigate:</B> Move along Genome by clicking and dragging in desired direction. <B>Reorder Tracks:</B> Click on the track and drag up or down to desired location.");
					}
				})
				.on("mouseout", function(){
					if(overSelectable==0){
						$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
					}
				});
				//.on("mousedown", this.panDown);
				//this.svg.append("text").text(this.label).attr("x",this.gsvg.width/2-20).attr("y",12);
				var lblStr=new String("Loading...");
				svg.append("text").text(lblStr).attr("x",this.width/2-(lblStr.length/2)*7.5).attr("y",12).attr("id","trkLbl");
				var info=svg.append("g").attr("class","infoIcon").attr("transform", "translate(" + this.width/2+(lblStr.length/2)*7.5+16 + ",0)");;
				info.append("rect")
									.attr("x",0)
									.attr("y",0)
									.attr("rx",3)
									.attr("ry",3)
							    	.attr("height",14)
									.attr("width",14)
									.attr("fill","#A7C5E2");
				info.append("text").attr("x","2.5").attr("y",10).attr("fill","#FFFFFF").text("i");
		}

		var success=0;
		if(track=="coding"){

				d3.xml("tmpData/regionData/"+folderName+"/coding.xml",function (error,d){
					if(error){
						if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								this.addTrack(track,density,additionalOptions,retry+1);
							}.bind(this),time);
						}else{
							d3.select("#Level"+this.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+this.levelNumber+track).attr("height", 15);
						}
					}else{
						if(d==null){
							if(retry>=4){
								var data=new Array();
								var newTrack=new GeneTrack(par,data,track,"Protein Coding / PolyA+",additionalOptions);
								par.addTrackList(newTrack);
							}else{
								setTimeout(function (){
									this.addTrack(track,density,additionalOptions,4);
								}.bind(this),5000);
							}
						}else{
							var data=d.documentElement.getElementsByTagName("Gene");
							var newTrack=new GeneTrack(par,data,track,"Protein Coding / PolyA+",additionalOptions);
							par.addTrackList(newTrack);
							if(selectGene!=""){
								newTrack.setSelected(selectGene);
							}
						}
					}
				}.bind(this));
			}else if(track=="noncoding"){
				d3.xml("tmpData/regionData/"+folderName+"/noncoding.xml",function (error,d){
					if(error){
						if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								this.addTrack(track,density,additionalOptions,retry+1);
							}.bind(this),time);
						}else if(success!=1){
							d3.select("#Level"+this.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+this.levelNumber+track).attr("height", 15);
						}
					}else{
						if(d==null){
							if(retry>=4){
								var data=new Array();
								var newTrack=new GeneTrack(par,data,track,"Long Non-Coding / Non-PolyA+ Genes",additionalOptions);
								par.addTrackList(newTrack);
							}else{
								setTimeout(function (){
									this.addTrack(track,density,additionalOptions,4);
								}.bind(this),5000);
							}
						}else{
							var data=d.documentElement.getElementsByTagName("Gene");
							var newTrack=new GeneTrack(par,data,track,"Long Non-Coding / Non-PolyA+ Genes",additionalOptions);
							par.addTrackList(newTrack);
							if(selectGene!=""){
								newTrack.setSelected(selectGene);
							}
						}
					}
				}.bind(this));
			}else if(track=="smallnc"){
				d3.xml("tmpData/regionData/"+folderName+"/smallnc.xml",function (error,d){
					if(error){
						if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								this.addTrack(track,density,additionalOptions,retry+1);
							}.bind(this),time);
						}else{
							d3.select("#Level"+this.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+this.levelNumber+track).attr("height", 15);
						}
					}else{
						if(d==null){
							if(retry>=4){
								var data=new Array();
								var newTrack=new GeneTrack(par,data,track,"Small RNA (<200 bp) Genes",additionalOptions);
								par.addTrackList(newTrack);
							}else{
								setTimeout(function (){
									this.addTrack(track,density,additionalOptions,4);
								}.bind(this),5000);
							}
						}else{
							var data=d.documentElement.getElementsByTagName("smnc");
							var newTrack=new GeneTrack(par,data,track,"Small RNA (<200 bp) Genes",additionalOptions);
							par.addTrackList(newTrack);
							if(selectGene!=""){
								newTrack.setSelected(selectGene);
							}
						}
					}
				}.bind(this));
			}else if(track.indexOf("refSeq")==0){
				var include=$("#"+track+this.levelNumber+"Select").val();
				var tmpMin=this.xScale.domain()[0];
				var tmpMax=this.xScale.domain()[1];
				var file="tmpData/regionData/"+folderName+"/"+track+".xml";
				d3.xml(file,function (error,d){
					if(error){
						console.log(error);
						if(retry==0){
							$.ajax({
								url: contextPath + "/web/GeneCentric/generateTrackXML.jsp",
				   				type: 'GET',
								data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrgansim: organism, track: track, folder: folderName},
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
								this.addTrack(track,density,additionalOptions,retry+1);
							}.bind(this),time);
						}else{
							d3.select("#Level"+this.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+this.levelNumber+track).attr("height", 15);
						}
					}else{
						if(d==null){
							if(retry>=4){
								var data=new Array();
								var newTrack=new RefSeqTrack(par,data,track,"Ref Seq Genes",additionalOptions);
								par.addTrackList(newTrack);
							}else{
								setTimeout(function (){
									this.addTrack(track,density,additionalOptions,4);
								}.bind(this),5000);
							}
						}else{
							var data=d.documentElement.getElementsByTagName("Gene");
							var newTrack=new RefSeqTrack(par,data,track,"Ref Seq Genes",additionalOptions);
							par.addTrackList(newTrack);
						}
					}
				}.bind(this));
			}else if(track.indexOf("snp")==0){
				var include=$("#"+track+this.levelNumber+"Select").val();
				var tmpMin=this.xScale.domain()[0];
				var tmpMax=this.xScale.domain()[1];
				var file="tmpData/regionData/"+folderName+"/"+track+".xml";
				d3.xml(file,function (error,d){
					if(error){
						console.log(error);
						if(retry==0){
							$.ajax({
								url: contextPath + "/web/GeneCentric/generateTrackXML.jsp",
				   				type: 'GET',
								data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrgansim: organism, track: track, folder: folderName},
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
								this.addTrack(track,density,additionalOptions,retry+1);
							}.bind(this),time);
						}else{
							d3.select("#Level"+this.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+this.levelNumber+track).attr("height", 15);
						}
					}else{
						if(d==null){
							if(retry>=4){
								var snp=new Array();
								var newTrack=new SNPTrack(par,snp,track,density,include);
								par.addTrackList(newTrack);
							}else{
								setTimeout(function (){
									this.addTrack(track,density,additionalOptions,4);
								}.bind(this),5000);
							}
						}else{
							var snp=d.documentElement.getElementsByTagName("Snp");
							var newTrack=new SNPTrack(par,snp,track,density,include);
							par.addTrackList(newTrack);
						}
					}
				}.bind(this));
			}else if(track=="qtl"){
				d3.xml("tmpData/regionData/"+folderName+"/qtl.xml",function (error,d){
					if(error){
						if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								this.addTrack(track,density,additionalOptions,retry+1);
							}.bind(this),time);
						}else{
							d3.select("#Level"+this.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+this.levelNumber+track).attr("height", 15);
						}
					}else{
						if(d==null){
							if(retry>=4){
								var qtl=new Array();
								var newTrack=new QTLTrack(par,qtl,track,density);
								par.addTrackList(newTrack);
							}else{
								setTimeout(function (){
									this.addTrack(track,density,additionalOptions,4);
								}.bind(this),5000);
							}
						}else{
							var qtl=d.documentElement.getElementsByTagName("QTL");
							var newTrack=new QTLTrack(par,qtl,track,density);
							par.addTrackList(newTrack);
							//success=1;
						}
					}
				}.bind(this));
			}else if(track=="trx"){
				var txList=getAllChildrenByName(getFirstChildByName(this.selectedData,"TranscriptList"),"Transcript");
				var newTrack=new TranscriptTrack(par,txList,track,density);
				par.addTrackList(newTrack);

			}else if(track=="probe"){
				d3.xml("tmpData/regionData/"+folderName+"/probe.xml",function (error,d){
					if(error){
						if(retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								this.addTrack(track,density,additionalOptions,retry+1);
							}.bind(this),time);
						}else{
							d3.select("#Level"+this.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+this.levelNumber+track).attr("height", 15);
						}
					}else{
						if(d==null){
							if(retry>=4){
								probe=new Array();
								var newTrack=new ProbeTrack(par,probe,track,"Affy Exon 1.0 ST Probe Sets",density);
								par.addTrackList(newTrack);
							}else{
								setTimeout(function (){
								this.addTrack(track,density,additionalOptions,4);
								}.bind(this),5000);
							}
						}else{
							var probe=d.documentElement.getElementsByTagName("probe");
							var newTrack=new ProbeTrack(par,probe,track,"Affy Exon 1.0 ST Probe Sets",density);
							par.addTrackList(newTrack);
							//success=1;
						}
					}
				}.bind(this));
			}else if(track=="helicos"||track=="illuminaTotal"||track=="illuminaSmall"||track=="illuminaPolyA"){
				var tmpMin=this.xScale.domain()[0];
				var tmpMax=this.xScale.domain()[1];
				var len=tmpMax-tmpMin;
				var tmpBin=calculateBin(len,this.width);
				var file="tmpData/regionData/"+folderName+"/count"+track+".xml";
				if(tmpBin>0){
					file="tmpData/regionData/"+folderName+"/bincount."+tmpBin+"."+track+".xml";
				}
				d3.xml(file,function (error,d){
					if(error){
						console.log(error);
						if(retry==0){
							$.ajax({
								url: contextPath + "/web/GeneCentric/generateTrackXML.jsp",
				   				type: 'GET',
								data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrgansim: organism, track: track, folder: folderName,binSize:tmpBin},
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
								this.addTrack(track,density,additionalOptions,retry+1);
							}.bind(this),time);
						}else{
							d3.select("#Level"+this.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+this.levelNumber+track).attr("height", 15);
						}
					}else{
						//console.log(d);
						if(d==null){
							if(retry>=4){
								data=new Array();
								if(track=="helicos"){
									newTrack=new HelicosTrack(par,data,track,1);
								}else if(track=="illuminaTotal"){
									newTrack=new IlluminaTotalTrack(par,data,track,1);
								}else if(track=="illuminaSmall"){
									newTrack=new IlluminaSmallTrack(par,data,track,1);
								}else if(track=="illuminaPolyA"){
									newTrack=new IlluminaPolyATrack(par,data,track,1);
								}
								par.addTrackList(newTrack);
							}else{
								setTimeout(function (){
									this.addTrack(track,density,additionalOptions,4);
								}.bind(this),5000);
							}
						}else{
							var data=d.documentElement.getElementsByTagName("Count");
							var newTrack;
							if(track=="helicos"){
								newTrack=new HelicosTrack(par,data,track,1);
							}else if(track=="illuminaTotal"){
								newTrack=new IlluminaTotalTrack(par,data,track,1);
							}else if(track=="illuminaSmall"){
								newTrack=new IlluminaSmallTrack(par,data,track,1);
							}else if(track=="illuminaPolyA"){
								newTrack=new IlluminaPolyATrack(par,data,track,1);
							}
							par.addTrackList(newTrack);
							//success=1;
						}
					}
				}.bind(this));
			}
			$(".sortable"+this.levelNumber).sortable( "refresh" );
			
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

	this.removeAllTracks=function(){
			for(var l=0;l<this.trackList.length;l++){
				if(this.trackList[l]!=undefined){
					d3.select("#Level"+this.levelNumber+this.trackList[l].trackClass).remove();
				}
			}
			this.trackList=[];
			DisplayRegionReport();
	}.bind(this);

	this.removeTrack=function (track){
			d3.select("#Level"+this.levelNumber+track).remove();
			for(var l=0;l<this.trackList.length;l++){
				if(this.trackList[l]!=undefined && this.trackList[l].trackClass==track){
					this.trackList.splice(l,1);
					this.trackCount--;
				}
			}
			DisplayRegionReport();
	}.bind(this);

	this.redrawTrack=function (track){
			for(var l=0;l<this.trackList.length;l++){
				if(this.trackList[l]!=undefined && this.trackList[l].trackClass==track){
					this.trackList[l].redraw();
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
				this.trackList[i].updateData(0);
			}
		}
		var chkStr=new String(folderName);
		if(chkStr.indexOf("img")>-1){
			$.ajax({
					url: "web/GeneCentric/getFullPath.jsp",
	   				type: 'GET',
	   				async: false,
					data: {chromosome: chr,minCoord:this.xScale.domain()[0],maxCoord:this.xScale.domain()[1],panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrgansim: organism},
					dataType: 'json',
	    			success: function(data2){ 
	        			folderName=data2.folderName;
	    			}.bind(this),
	    			error: function(xhr, status, error) {
	        			console.log(error);
	    			}
				});
		}
		for(var i=0;i<this.trackList.length;i++){
			if(this.trackList[i]!=undefined && this.trackList[i].updateFullData!=undefined){
				this.trackList[i].updateFullData(0);
			}
		}
		DisplayRegionReport();
	}.bind(this);

	this.updateFullData=function(){
		for(var i=0;i<this.trackList.length;i++){
			if(this.trackList[i]!=undefined && this.trackList[i].updateFullData!=undefined){
				this.trackList[i].updateFullData(0,1);
			}
		}
	}.bind(this);

	this.setLoading=function (){
		for(var i=0;i<this.trackList.length;i++){
			if(this.trackList[i]!=undefined && (this.trackList[i].updateData!=undefined||this.trackList[i].updateFullData!=undefined)){
				//console.log("not undef");
				this.trackList[i].showLoading();
			}
		}
	}.bind(this);

	this.clearSelection=function (){
		for(var i=0;i<this.trackList.length;i++){
			if(this.trackList[i]!=undefined && this.trackList[i].clearSelection!=undefined){
				this.trackList[i].clearSelection();
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

	d3.select(div).select("#settingsLevel"+levelNumber).remove();
	d3.select(div).select("#Level"+levelNumber).remove();
	//d3.select(div).selectAll(".draggable"+levelNumber).remove();

	this.vis=d3.select(div);

	//this.vis.append("span").attr("class","settings").attr("id","settingsLevel"+this.levelNumber).style("position","relative").style("top","15px").style("left","486px").append("img").attr("src","web/images/icons/gear.png");
	this.vis.append("span").attr("class","settings button")
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
	//this.vis.append("span").attr("class","reset button").attr("id","resetLevel"+this.levelNumber).style("float","left").style("width","118px").text("Reset Image");
	//this.vis.append("span").attr("class","undo button").attr("id","undoLevel"+this.levelNumber).style("float","left").style("width","220px").text("Undo last Zoom/Move");
	this.topDiv=this.vis.append("div")
		.attr("id","Level"+levelNumber)
		.style("text-align","left");
	
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
						//.attr("pointer-events", "all")
						.on("mousedown", this.mdown)
						.on("mouseup",mup)
						.on("mouseover", function(){
							$("#mouseHelp").html("<B>Zoom:</b> Click and Drag right to zoom in or left to zoom out.");
						})
						.on("mouseout", function(){
							$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
						})
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
					.style("width",(this.width+18)+"px")
					.append("ul")
					.attr("id","sortable"+levelNumber);
	
	
	this.tt=d3.select("body").append("div")   
    	.attr("class", "testToolTip")               
    	.style("opacity", 0);
    getAddMenuDiv(levelNumber,this.type);
	svgList.push(this);
	
	
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
	this.clearSelection = function (){
		d3.select("#Level"+this.gsvg.levelNumber+this.trackClass).selectAll(".selected").each(function(){
							d3.select(this).attr("class","").style("fill",that.color);
						});
	}.bind(this);
	this.colorStroke = function (d){
			var colorRet="black";
			if(this.xScale(d.getAttribute("stop"))-this.xScale(d.getAttribute("start"))<3){
				colorRet=this.color(d);
			}
			return colorRet;
	}.bind(this);

	this.calcY = function (start,end,i){
		var tmpY=0;
		if(this.density==3){
			if((start>=this.xScale.domain()[0]&&start<=this.xScale.domain()[1])||
				(end>=this.xScale.domain()[0]&&end<=this.xScale.domain()[1])||
				(start<=this.xScale.domain()[0]&&end>=this.xScale.domain()[1])){
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
		}else if(this.density==2){
			tmpY=(i+1)*15;
		}else if(this.density==1){
			tmpY=15;
		}
		if(this.trackYMax<(tmpY/15)){
			this.trackYMax<(tmpY/15);
		}
		return tmpY;
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

	this.drawScaleLegend = function (minVal,maxVal,lbl,minColor,maxColor){
		var lblStr=new String(this.label);
		var x=this.gsvg.width/2+(lblStr.length/2)*7.5+16;
		d3.select("#Level"+this.gsvg.levelNumber+this.trackClass).selectAll(".legend").remove();
		d3.select("#Level"+this.gsvg.levelNumber+this.trackClass).selectAll("#def1").remove();
		var grad=this.svg.append("defs").attr("id","def1").append("linearGradient").attr("id","grad1");
		grad.append("stop").attr("offset","0%").style("stop-color",minColor);
		grad.append("stop").attr("offset","100%").style("stop-color",maxColor);
		this.svg.append("rect")
				.attr("class","legend")
				.attr("x",x+20)
				.attr("y",0)
				.attr("rx",3)
				.attr("ry",3)
		    	.attr("height",12)
				.attr("width",75)
				.attr("fill","url(#grad1)");
				//.attr("stroke","#FFFFFF");
			lblStr=new String(minVal);
			this.svg.append("text").text(lblStr).attr("class","legend").attr("x",x).attr("y",12);
			lblStr=new String(maxVal);
			this.svg.append("text").text(lblStr).attr("class","legend").attr("x",x+98).attr("y",12);
			var off=lblStr.length*8+5;
			lblStr=new String(lbl);
			this.svg.append("text").text(lblStr).attr("class","legend").attr("x",x+98+off).attr("y",12);
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

		if(!(typeof this.counts==="undefined") && this.counts.length>0){
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
		
	}.bind(this);

	this.updateLabel= function (label){
		this.label=label;
		var lblStr=new String(this.label);
		d3.select("#Level"+this.gsvg.levelNumber+this.trackClass).select("#trkLbl").attr("x",this.gsvg.width/2-(lblStr.length/2)*7.5).text(lblStr);
	}.bind(this);
	this.gsvg=gsvgP;
	this.data=dataP;
	this.label=labelP;
	this.density=3;
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
	
	this.vis=d3.select("#Level"+this.gsvg.levelNumber+this.trackClass);
	this.svg=d3.select("svg#Level"+this.gsvg.levelNumber+this.trackClass);
	this.svg.on("mousedown", this.panDown);
	this.updateLabel(this.label);
}


function GeneTrack(gsvg,data,trackClass,label,additionalOptions){
	var that=new Track(gsvg,data,trackClass,label);
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
	var additionalOptStr=new String(additionalOptions);
	if(additionalOptStr.indexOf("DrawTrx")>-1){
		that.drawAs="Trx";
	}
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
			}else{

			}
			tooltip="ID: "+prefix+d.getAttribute("ID")+"<BR>Length:"+(d.getAttribute("stop")-d.getAttribute("start"))+"<BR>Location: "+d.getAttribute("chromosome")+":"+d.getAttribute("start")+"-"+d.getAttribute("stop")+"<BR>Strand: "+d.getAttribute("strand")+rnaSeqData;
																																																													  
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
			var gid=d.getAttribute("ID");
			if(gid.indexOf("ENS")==-1){
					gid=gid.substr(gid.indexOf("_")+1);
					gid=gid.replace(/^0+/, '');
					gid="Brain.G"+gid;
			}
			tooltip="ID: "+gid+"<BR>Gene Symbol:"+d.getAttribute("geneSymbol")+"<BR>Location:"+d.getAttribute("chromosome")+":"+d.getAttribute("start")+"-"+d.getAttribute("stop")+"<BR>Strand:"+d.getAttribute("strand")+"<BR>Transcripts:<BR>"+txListStr;
		}
		return tooltip;
	}.bind(that);

	that.redraw=function(){
		that.trackYMax=0;
		//console.log("in redraw:"+that.annotType);
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
		//console.log("annot:"+curAnnot);
		//console.log("prev:"+that.annotType);
		if(curAnnot==that.annotType){
			//console.log("redraw as "+that.drawAs);
			if(that.drawAs=="Gene" || that.trackClass=="smallnc"){
				if(that.svg[0][0]!=null){
					for(var j=0;j<that.gsvg.width;j++){
						that.yArr[j]=0;
					}
					this.trackYMax=0;
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
			}else if(that.drawAs=="Trx"){
				//console.log("redraw TRX");
				var txG=that.svg.selectAll(".trx");
				txG//.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
					.each(function(d,i){
						
						exList=getAllChildrenByName(getFirstChildByName(d,"exonList"),"exon");
						//console.log("process trx:"+d.getAttribute("ID")+":"+i+":"+exList.length);
						for(var m=0;m<exList.length;m++){
							d3.select("g#"+d.getAttribute("ID")+" rect#Ex"+exList[m].getAttribute("ID"))
								.attr("x",function(d){ return that.xScale(exList[m].getAttribute("start")); })
								.attr("width",function(d){ return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start")); });
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
								d3.select("g#"+d.getAttribute("ID")+" line#Int"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID"))
									.attr("x1",intStart)
									.attr("x2",intStop);

								d3.select("g#"+d.getAttribute("ID")+" #IntTxt"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID"))
									.attr("dx",intStart+1).text(fullChar);
							}
						}
					});
			}
		}else{
			//console.log("run draw");
			that.draw(that.data);
		}

		if(that.density==1){
			that.svg.attr("height", 30);
		}else if(that.density==2){
			that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene").size()+1)*15);
		}else if(that.density==3){
			that.svg.attr("height", (that.trackYMax+2)*15);
		}
	}.bind(that);

	that.setSelected=function(geneID){
		if(geneID !=""){
			d3.selectAll("rect.selected").each(function(){
															d3.select(this).attr("class","").style("fill",that.color);
														});
			var gene=d3.select("g.gene rect#"+geneID);
			if(gene != undefined){
				gene.attr("class","selected").style("fill","green");
				//console.log(gene.data()[0]);
				that.setupDetailedView(gene.data()[0]);
				selectGene="";
			}
		}
	}

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
				//if(svgList[newLevel]==null){
					var newSvg=new GenomeSVG("div#selectedImage",this.gsvg.width,d.getAttribute("extStart"),d.getAttribute("extStop"),this.gsvg.levelNumber+1,d.getAttribute("ID"),"transcript");
					newSvg.xMin=d.getAttribute("extStart")-(d.getAttribute("extStop")-d.getAttribute("extStart"))*0.05;
					newSvg.xMax=d.getAttribute("extStop")+(d.getAttribute("extStop")-d.getAttribute("extStart"))*0.05;
					svgList[newLevel]=newSvg;
					svgList[newLevel].txType=localTxType;
					svgList[newLevel].selectedData=d;
					svgList[newLevel].addTrack("trx",2,"",0);
					loadState(this.gsvg.levelNumber+1);
				/*}else{
					svgList[newLevel].xScale.domain([d.getAttribute("extStart"),d.getAttribute("extStop")]);
					svgList[newLevel].xMin=d.getAttribute("extStart")-(d.getAttribute("extStop")-d.getAttribute("extStart"))*0.05;
					svgList[newLevel].xMax=d.getAttribute("extStop")+(d.getAttribute("extStop")-d.getAttribute("extStart"))*0.05;
					svgList[newLevel].scaleSVG.select(".x.axis").call(svgList[newLevel].xAxis);
					d3.select("#Level"+newLevel).select(".axisLbl").text(d.getAttribute("ID")).attr("x", ((this.gsvg.width-(this.gsvg.margin*2))/2)).attr("y",-40);
					svgList[newLevel].txType=localTxType;
					svgList[newLevel].selectedData=d;
					console.log();
					console.log();
					d3.select("#settingsLevel"+this.gsvg.levelNumber+1).remove();
					d3.select("#Level"+this.gsvg.levelNumber+1).remove();
					svgList[newLevel].update();
				}*/
				selectedGeneSymbol=d.getAttribute("geneSymbol");
				selectedID=d.getAttribute("ID");
				$('div#selectedImage').show();
				if((new String(selectedID)).indexOf("ENS")>-1){
					$('div#selectedReport').show();
					var jspPage="web/GeneCentric/geneReport.jsp";
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
		if (!(typeof tmpDat === 'undefined')) {
			for(var l=0;l<tmpDat.length;l++){
				if(tmpDat[l].__data__ != undefined){
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
			}
		}else{
			that.counts=[];
		}
		return dispData;
	}.bind(that);

	that.updateData=function(retry){
		var tag="Gene";
		var path="tmpData/regionData/"+folderName+"/coding.xml";
		if(this.trackClass=="noncoding"){
			path="tmpData/regionData/"+folderName+"/noncoding.xml";
		}else if(this.trackClass=="smallnc"){
			path="tmpData/regionData/"+folderName+"/smallnc.xml";
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
								this.updateData(retry+1);
							}.bind(this),time);
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
		
	}.bind(that);

	that.draw=function (data){
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
		that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Selectg").val();
		//console.log("set annotType:"+that.annotType);
		for(var j=0;j<that.gsvg.width;j++){
				that.yArr[j]=0;
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
	
		var filterData=data;
		if(that.annotType!="all"){
			var filterData=[];
			var newCount=0;
			for(var l=0;l<data.length;l++){
				if(data[l]!=undefined ){
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
			//console.log(filterData);
		}
		if(that.gsvg.levelNumber==1 && that.gsvg.selectedData!=undefined){
			var newFilter=[];
			var ind=0;
			for(var l=0;l<filterData.length;l++){
				if(filterData[l].getAttribute("ID")!=that.gsvg.selectedData.getAttribute("ID")){
					newFilter[ind]=filterData[l];
					ind++;
				}
			}
			filterData=newFilter;
		}
		
		if(that.drawAs=="Gene" || that.trackClass=="smallnc"){
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
					overSelectable=1;
					$("#mouseHelp").html("<B>Click</B> to see additional details. <B>Double Click</B> to zoom in on this feature.");
					d3.select(this).style("fill","green");
			        	that.gsvg.get('tt').transition()        
			                .duration(200)      
			                .style("opacity", .95);      
			        	that.gsvg.get('tt').html(that.createToolTip(d))  
			                .style("left", ((d3.event.pageX-gsvg.get('halfWindowWidth')) + "px") )  
			                .style("top", (d3.event.pageY + 20) + "px"); 
			            return false;
		            })
				.on("mouseout", function(d) { 
					overSelectable=0;
					$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
					if(d3.select(this).attr("class")!="selected"){
						d3.select(this).style("fill",that.color);
					}
		            that.gsvg.get('tt').transition()
						 .delay(500)       
		                .duration(200)      
		                .style("opacity", 0);  
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
			//console.log("drawRefSeq as TRX "+that.trackClass);
			//console.log(filterData);
			var txList=new Array();
			var txListSize=0;
			for(var j=0;j<filterData.length;j++){
				var tmpTxList=getAllChildrenByName(getFirstChildByName(filterData[j],"TranscriptList"),"Transcript");
				for(var k=0;k<tmpTxList.length;k++){
					txList[txListSize]=tmpTxList[k];
					txListSize++;
				}
			}
			//console.log("Gene TX List"+that.trackClass);
			//console.log(txList);
			that.svg.selectAll(".trx").remove();
			var tx=that.svg.selectAll(".trx")
		   			.data(txList,key)
					.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i)+")";});
					
		  	tx.enter().append("g")
					.attr("class","trx")
					//.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
					.attr("transform",function(d,i){ return "translate(0,"+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i)+")";})
					.attr("id",function(d){return d.getAttribute("ID");})
					.attr("pointer-events", "all")
					.style("cursor", "pointer")
					.on("mouseover", function(d) { 
								d3.select(this).selectAll("line").style("stroke","green");
								d3.select(this).selectAll("rect").style("fill","green");
								d3.select(this).selectAll("text").style("opacity","0.3").style("fill","green");
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
							d3.select(this).selectAll("text").style("opacity","0.6").style("fill",that.color);  
							that.gsvg.tt.transition()
								 .delay(500)       
								.duration(200)      
								.style("opacity", 0);  
		        		})
					.each(that.drawTrx);
			
			
			 tx.exit().remove();
			 if(that.density==1){
				that.svg.attr("height", 30);
			}else if(that.density==2){
				that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene").size()+1)*15);
			}else if(that.density==3){
				that.svg.attr("height", (that.trackYMax+2)*15);
			}
		}
	}.bind(that);

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
	}.bind(that);

	that.redrawLegend();
	that.draw(data);
	
	return that;
}

function RefSeqTrack(gsvg,data,trackClass,label,additionalOptions){
	var that=new GeneTrack(gsvg,data,trackClass,label);
	that.counts=[{value:0,names:"Ensembl"},{value:0,names:"RNA-Seq"}];
	that.drawAs="Gene";
	var additionalOptStr=new String(additionalOptions);
	if(additionalOptStr.indexOf("DrawTrx")>-1){
		that.drawAs="Trx";
	}
	that.color =function(d){
		var color=d3.rgb("#000000");
		if(that.drawAs=="Gene"){
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
					}else{
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
			}
		}else if(that.drawAs=="Trx"){
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
			}
		}
		return color;
	}.bind(that);
	that.pieColor =function(d,i){
		var color=d3.rgb("#000000");
		var tmpName=new String(d.data.names);
		if(tmpName.indexOf("Validated")>-1){
				color=d3.rgb("#38A16F");
		}else if(tmpName.indexOf("Provisional")>-1){
				color=d3.rgb("#78E1AF");
		}else if(tmpName.indexOf("Inferred")>-1){
				color=d3.rgb("#A8FFDF");
		}
		return color;
	}.bind(that);

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
						}else{
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
	}.bind(that);
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
			tooltip="Gene Symbol: "+d.getAttribute("geneSymbol")+"<BR>Location: "+d.getAttribute("chromosome")+":"+d.getAttribute("start")+"-"+d.getAttribute("stop")+"<BR>Strand: "+d.getAttribute("strand")+"<BR>Transcripts:<BR>"+txListStr;
		}else if(that.drawAs=="Trx"){
			//console.log(d);
				var txListStr="";
				var id=new String(d.getAttribute("ID"));
				txListStr+="<B>"+id+"</B>";
			tooltip="Transcript:"+txListStr+"<BR>Status: "+d.getAttribute("category")+"<BR>Gene Symbol: "+d.getAttribute("geneSymbol")+"<BR>Location: "+d.getAttribute("chromosome")+":"+d.getAttribute("start")+"-"+d.getAttribute("stop")+"<BR>Strand: "+d.getAttribute("strand");
		}
		return tooltip;
	}.bind(that);

	that.redraw=function(){
		that.trackYMax=0;
		if(that.drawAs=="Gene"){
				if(that.svg[0][0]!=null){
					for(var j=0;j<that.gsvg.width;j++){
						that.yArr[j]=0;
					}
					this.trackYMax=0;
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
		}else if(that.drawAs=="Trx"){
			var txG=this.svg.selectAll("g");
		
			txG//.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
				.each(function(d,i){
					exList=getAllChildrenByName(getFirstChildByName(d,"exonList"),"exon");
					for(var m=0;m<exList.length;m++){
						d3.select("g#"+d.getAttribute("ID")+" rect#Ex"+exList[m].getAttribute("ID"))
							.attr("x",function(d){ return that.xScale(exList[m].getAttribute("start")); })
							.attr("width",function(d){ return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start")); });
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
							d3.select("g#"+d.getAttribute("ID")+" line#Int"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID"))
								.attr("x1",intStart)
								.attr("x2",intStop);

							d3.select("g#"+d.getAttribute("ID")+" #IntTxt"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID"))
								.attr("dx",intStart+1).text(fullChar);
						}
					}
				});
			if(that.density==1){
				that.svg.attr("height", 30);
			}else if(that.density==2){
				that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene").size()+1)*15);
			}else if(that.density==3){
				that.svg.attr("height", (that.trackYMax+2)*15);
			}
		}
	}.bind(that);

	/*that.setSelected=function(geneID){
		if(geneID !=""){
			d3.selectAll("rect.selected").each(function(){
															d3.select(this).attr("class","").style("fill",that.color);
														});
			var gene=d3.select("g.gene rect#"+geneID);
			if(gene != undefined){
				gene.attr("class","selected").style("fill","green");
				//console.log(gene.data()[0]);
				that.setupDetailedView(gene.data()[0]);
				selectGene="";
			}
		}
	}*/


	that.updateData=function(retry){
		var tag="Gene";
		var tmpMin=this.xScale.domain()[0];
		var tmpMax=this.xScale.domain()[1];
		var path="tmpData/regionData/"+folderName+"/refSeq.xml";
		d3.xml(path,function (error,d){
			if(error){
				console.log(error);
				if(retry==0){
							$.ajax({
								url: contextPath + "/web/GeneCentric/generateTrackXML.jsp",
				   				type: 'GET',
								data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrgansim: organism, track: that.trackClass, folder: folderName},
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
							}.bind(this),time);
						}else{
							d3.select("#Level"+this.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+this.levelNumber+track).attr("height", 15);
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
	}.bind(that);

	that.drawTrx=function (d,i){
		//console.log("drawTrx:"+i);
		//console.log(d);
		var txG=that.svg.select("#"+d.getAttribute("ID"));
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
		
	}.bind(that);

	that.draw=function (data){
		that.data=data;
		that.trackYMax=0;
		that.svg.selectAll(".gene").remove();
			//console.log("in draw"+that.annotType);
			
		that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").val();
			//console.log("set annotType:"+that.annotType);
		for(var j=0;j<that.gsvg.width;j++){
			that.yArr[j]=0;
		}
		if(that.drawAs=="Gene"){
			that.label="Ref Seq Genes";
			that.updateLabel(that.label);
			that.redrawLegend();
			
			var gene=that.svg.selectAll(".gene")
		   			.data(data,key)
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
				//.style("cursor", "pointer")
				/*.on("click", function(d){
						d3.selectAll("rect.selected").each(function(){
								d3.select(this).attr("class","").style("fill",that.color);
							});
						d3.select(this).attr("class","selected").style("fill","green");
						that.setupDetailedView(d);
					})*/
				.on("dblclick", that.zoomToFeature)
				.on("mouseover", function(d) { 
					overSelectable=1;
					$("#mouseHelp").html("<B>Double Click</B> to zoom in on this feature.");
					d3.select(this).style("fill","green");
			        	that.gsvg.get('tt').transition()        
			                .duration(200)      
			                .style("opacity", .95);      
			        	that.gsvg.get('tt').html(that.createToolTip(d))  
			                .style("left", ((d3.event.pageX-gsvg.get('halfWindowWidth')) + "px") )  
			                .style("top", (d3.event.pageY + 20) + "px"); 
			            return false;
		            })
				.on("mouseout", function(d) { 
					overSelectable=0;
					$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
					if(d3.select(this).attr("class")!="selected"){
						d3.select(this).style("fill",that.color);
					}
		            that.gsvg.get('tt').transition()
						 .delay(500)       
		                .duration(200)      
		                .style("opacity", 0);  
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
		}else if(that.drawAs="Trx"){
			//console.log("drawRefSeq as TRX");
			that.label="Ref Seq Transcripts";
			that.updateLabel(that.label);
			//var geneList=getAllChildrenByName(getFirstChildByName(data,"GeneList"),"Gene");
			var txList=new Array();
			var txListSize=0;
			for(var j=0;j<data.length;j++){
				var tmpTxList=getAllChildrenByName(getFirstChildByName(data[j],"TranscriptList"),"Transcript");
				for(var k=0;k<tmpTxList.length;k++){
					txList[txListSize]=tmpTxList[k];
					txListSize++;
				}
			}
			//console.log(txList);
			that.svg.selectAll(".trx").remove();
			var tx=that.svg.selectAll(".trx")
		   			.data(txList,key)
					.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i)+")";});
					
		  	tx.enter().append("g")
					.attr("class","trx")
					//.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
					.attr("transform",function(d,i){ return "translate(0,"+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),i)+")";})
					.attr("id",function(d){return d.getAttribute("ID");})
					.attr("pointer-events", "all")
					.style("cursor", "pointer")
					.on("mouseover", function(d) { 
								d3.select(this).selectAll("line").style("stroke","green");
								d3.select(this).selectAll("rect").style("fill","green");
								d3.select(this).selectAll("text").style("opacity","0.3").style("fill","green");
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
							d3.select(this).selectAll("text").style("opacity","0.6").style("fill",that.color);  
							that.gsvg.tt.transition()
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
			 if(that.density==1){
				that.svg.attr("height", 30);
			}else if(that.density==2){
				that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene").size()+1)*15);
			}else if(that.density==3){
				that.svg.attr("height", (that.trackYMax+2)*15);
			}
			//console.log(that.svg.attr("height"));
		}
	}.bind(that);

	that.redrawLegend=function (){
		var legend=[];
		var curPos=0;
		legend=[{color:"#38A16F",label:"Validated"},{color:"#78E1AF",label:"Provisional"},{color:"#A8FFDF",label:"Inferred"}];
		that.drawLegend(legend);
	}.bind(that);

	that.redrawLegend();
	//console.log("First draw");
	//console.log(data);
	that.draw(data);
	
	return that;
}

function ProbeTrack(gsvg,data,trackClass,label,density){
	var that=new Track(gsvg,data,trackClass,label);
	that.density=density;
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
	}.bind(that);

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
	}.bind(that);

	that.redraw=function(){
		that.density=$("#probe"+that.gsvg.levelNumber+"Select").val();
		var curColor=$("#probe"+that.gsvg.levelNumber+"colorSelect").val();
		var tissues=$(".settingsLevel"+that.gsvg.levelNumber+" input[name=\"tissuecbx\"]:checked");
		var tissueLen=tissues.length;
		if(curColor!=that.colorSelect || ((that.colorSelect=="herit" || that.colorSelect=="dabg") && tissueLen!=that.tissueLen)){
		//if(curColor=="annot"&&(that.colorSelect=="herit" || that.colorSelect=="dabg")||
		//	that.colorSelect=="annot"&&(curColor=="herit" || curColor=="dabg")){
			//console.log("callDraw from redraw");
			that.colorSelect=curColor;
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
						
						//console.log(t+":"+tissue);
						//that.yArr=new Array();
						//for(var j=0;j<100;j++){
						//	that.yArr[j]=-299999999;
						//}
						totalYMax++;
						d3.select("#Level"+this.gsvg.levelNumber+this.trackClass).select("text."+tissue).attr("y",totalYMax*15);
						d3.select("#Level"+this.gsvg.levelNumber+this.trackClass).selectAll("g.probe."+tissue).attr("transform",function (d,i){
																			   var st=that.xScale(d.getAttribute("start"));
																				return "translate("+st+","+(that.calcY(d.getAttribute("start"),d.getAttribute("stop"),that.density,i,2)+totalYMax*15)+")";
																			});
						
						d3.select("#Level"+this.gsvg.levelNumber+this.trackClass)
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
				
				d3.select("#Level"+this.gsvg.levelNumber+this.trackClass).selectAll("g.probe").attr("transform",function (d,i){
																	   var st=that.xScale(d.getAttribute("start"));
																		return "translate("+st+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),that.density,i,2)+")";
																	});
				d3.select("#Level"+this.gsvg.levelNumber+this.trackClass).selectAll("g.probe rect")
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
				}else if(this.density==2){
					that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+"probe").selectAll("g.probe").length+1)*15);
				}else if(this.density==3){
					that.svg.attr("height", (that.trackYMax+1)*15);
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
		if((tmpY/15)>that.trackYMax){
			that.trackYMax=tmpY/15;
		}
		return tmpY;
	}.bind(that);

	that.update=function (d){

		that.redraw();
	}.bind(that);

	that.draw= function (data){
		that.colorSelect=$("#probe"+that.gsvg.levelNumber+"colorSelect").val();
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
						that.svg.append("text").attr("class","tissueLbl "+tissue).attr("x",this.gsvg.width/2-(tisLbl.length/2)*7.5).attr("y",totalYMax*15).text(tisLbl);
						

						//update
						var probes=that.svg.selectAll(".probe."+tissue)
				   			.data(data,function(d){return keyTissue(d,tissue);})
							.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+(that.calcY(d.getAttribute("start"),d.getAttribute("stop"),density,i,2)+totalYMax*15)+")";})
										
						//add new
						probes.enter().append("g")
							.attr("class","probe "+tissue)
							.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+(that.calcY(d.getAttribute("start"),d.getAttribute("stop"),density,i,2)+totalYMax*15)+")";})
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
							            	that.gsvg.get('tt').transition()        
							                	.duration(200)      
							                	.style("opacity", .95);      
							            	that.gsvg.get('tt').html(that.createToolTip(d))  
							                	.style("left", (d3.event.pageX-that.gsvg.get('halfWindowWidth')) + "px")     
							                	.style("top", (d3.event.pageY + 20) + "px");  
							            }
							            })
							.on("mouseout", function(d) {
								overSelectable=0;
								$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
								var thisD3=d3.select(this); 
								if(thisD3.style("opacity")>0){  
								thisD3.style("fill",that.curTTColor);
					            that.gsvg.get('tt').transition()
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
							totalYMax=totalYMax+that.trackYMax;
			}
			//probes.exit().remove();
			that.trackYMax=totalYMax;
			that.svg.attr("height", totalYMax*15);
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
				.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),density,i,2)+")";})
					
			//add new
			probes.enter().append("g")
				.attr("class","probe annot")
				.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),density,i,2)+")";})
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
		            	that.gsvg.get('tt').transition()        
		                	.duration(200)      
		                	.style("opacity", .95);      
		            	that.gsvg.get('tt').html(that.createToolTip(d))  
		                	.style("left", (d3.event.pageX-that.gsvg.get('halfWindowWidth')) + "px")     
		                	.style("top", (d3.event.pageY + 20) + "px");  
		            }
		            })
				.on("mouseout", function(d) {
					overSelectable=0;
					$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
					var thisD3=d3.select(this); 
					if(thisD3.style("opacity")>0){  
					thisD3.style("fill",that.color);
		            that.gsvg.get('tt').transition()
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
			if(density==1){
				that.svg.attr("height", 30);
			}else if(density==2){
				that.svg.attr("height", (data.length+1)*15);
			}else if(density==3){
				that.svg.attr("height", (that.trackYMax+1)*15);
			}
		}
	}.bind(that);

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
						this.counts[0].value++;
					}else if(tmpDat[l].__data__.getAttribute("type")=="extended"){
						this.counts[1].value++;
					}else if(tmpDat[l].__data__.getAttribute("type")=="full"){
						this.counts[2].value++;
					}else if(tmpDat[l].__data__.getAttribute("type")=="ambiguous"){
						this.counts[3].value++;
					}
					dispData[dispDataCount]=tmpDat[l].__data__;
					dispDataCount++;
				}
			}
		}else{
			that.counts=[];
		}
		return dispData;
	}.bind(that);
	
	that.draw(data);

	
	return that;
}

function SNPTrack(gsvg,data,trackClass,density,include){
	var that=new Track(gsvg,data,trackClass,lbl);
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
		var strain=d.getAttribute("strain");
		if(strain=="SHRH"){
			strain="SHR";
		}
		tooltip="Type: "+d.getAttribute("type")+"<BR>Strain: "+strain+"<BR>Sequence: "+d.getAttribute("refSeq")+"->"+d.getAttribute("strainSeq")+"<BR>Location: chr"+d.getAttribute("chromosome")+":"+d.getAttribute("start");
		if(d.getAttribute("type")=="SNP"){

		}else{
			tooltip=tooltip+"-"+(d.getAttribute("stop"));
		}
		return tooltip;
	}.bind(that);

	that.update=function (d){
		that.redraw();
	}.bind(that);
	
	that.updateData = function(retry){
		var tag="Snp";
		var path="tmpData/regionData/"+folderName+"/snp"+that.strain+".xml";
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
							}.bind(this),time);
					}else if(retry>=3){
							d3.select("#Level"+this.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+this.levelNumber+track).attr("height", 15);
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
	}.bind(that);

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
	}.bind(that);

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
	}.bind(that);


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
	}.bind(that);

	that.strain=strain;
	that.include=include;
	that.density=density;
	that.redrawLegend();
	that.draw(data);	
	
	return that;
}

function QTLTrack(gsvg,data,trackClass,density){
	var that=new Track(gsvg,data,trackClass,"QTLs Overlapping Region");
	
	that.color= function (name){
		return that.pieColorPalette(name);
	}.bind(that);

	that.redraw= function (){
		//var qtlSvg=d3.select("#"+level+"qtl");
		var density=2;
		that.yCount=0;
		//var tmpYArr=new Array();
		that.idList=new Array();
		
		var qtls=this.svg//d3.select("#"+level+"qtl")
						.selectAll("g.qtl")
						.attr("transform",function (d,i){
								var st=that.xScale(d.getAttribute("start"));
								return "translate("+st+","+that.calcY(d,i)+")";
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
		/*qtls[0].forEach(function(d){
				var nameStr=d.__data__.getAttribute("name");
				var end=nameStr.indexOf("QTL")-1;
				var name=nameStr.substr(0,end);
				d3.select(d).select("rect").style("fill",that.color(name));
		});*/
		that.svg.attr("height", that.yCount*15);
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

	that.updateData= function(retry){
		d3.xml("tmpData/regionData/"+folderName+"/qtl.xml",function (error,d){
					if(error){
						if(success!=1 && retry<3){//wait before trying again
							var time=10000;
							if(retry==1){
								time=15000;
							}
							setTimeout(function (){
								this.updateDate(retry+1);
							}.bind(this),time);
						}else if(success!=1){
							d3.select("#Level"+this.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+this.levelNumber+track).attr("height", 15);
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
	}.bind(that);

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
	            that.gsvg.get('tt').transition()        
	                .duration(200)      
	                .style("opacity", .95);      
	            that.gsvg.get('tt').html(that.createToolTip(d))  
	                .style("left", (d3.event.pageX-that.gsvg.halfWindowWidth) + "px")     
	                .style("top", (d3.event.pageY + 20) + "px");  
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
	            that.gsvg.tt.transition()
					 .delay(500)       
	                .duration(200)      
	                .style("opacity", 0);  
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
	}.bind(that);
	that.draw(data);
	that.redraw();
	return that;
}

function TranscriptTrack(gsvg,data,trackClass,density){
	that=new Track(gsvg,data,trackClass,"Selected Gene Transcripts");

	that.createToolTip= function(d){
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
		tooltip="ID: "+id+"<BR>Location: chr"+d.getAttribute("chromosome")+":"+d.getAttribute("start")+"-"+d.getAttribute("stop")+"<BR>Strand: "+strand;
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
						d3.select("g#"+d.getAttribute("ID")+" line#Int"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID"))
							.attr("x1",intStart)
							.attr("x2",intStop);

						d3.select("g#"+d.getAttribute("ID")+" #IntTxt"+exList[m-1].getAttribute("ID")+"_"+exList[m].getAttribute("ID"))
							.attr("dx",intStart+1).text(fullChar);
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
							d3.select(this).selectAll("text").style("opacity","0.3").style("fill","green");
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
						d3.select(this).selectAll("text").style("opacity","0.6").style("fill",that.color);
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

	that.redrawLegend=function (){
		var legend=[];
		var curPos=0;
			if(this.gsvg.txType=="protein"){
				legend[curPos]={color:"#DFC184",label:"Ensembl"};
			}else if(this.gsvg.txType=="long"){
				legend[curPos]={color:"#B58AA5",label:"Ensembl"};
			}else if(this.gsvg.txType=="small"){
				legend[curPos]={color:"#FFCC00",label:"Ensembl"};
			}
			curPos++;

		if(organism=="Rn"){
			if(this.gsvg.txType=="protein"){
				legend[curPos]={color:"#7EB5D6",label:"Brain RNA-Seq"};
			}else if(this.gsvg.txType=="long"){
				legend[curPos]={color:"#CECFCE",label:"Brain RNA-Seq"};
			}else if(this.gsvg.txType=="small"){
				legend[curPos]={color:"#99CC99",label:"Brain RNA-Seq"};
			}
			curPos++;
		}
		that.drawLegend(legend);
	}.bind(that);

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
						d3.select(this).selectAll("text").style("opacity","0.3").style("fill","green");
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
					d3.select(this).selectAll("text").style("opacity","0.6").style("fill",that.color);  
					that.gsvg.tt.transition()
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

function CountTrack(gsvg,data,trackClass,density){
	var that=new Track(gsvg,data,trackClass,"Generic Counts");

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
	}.bind(that);

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
	}.bind(that);

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
		            			that.gsvg.tt.transition()        
									.duration(200)      
									.style("opacity", .95);      
								that.gsvg.tt.html(that.createToolTip(d))  
									.style("left", (d3.event.pageX-that.gsvg.halfWindowWidth) + "px")     
									.style("top", (d3.event.pageY +5) + "px");  
		            			})
							.on("mouseout", function(d) {  
								d3.select(this).style("fill",that.color);
					            that.gsvg.get('tt').transition()
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
	}.bind(that);

	that.createToolTip=function (d){
		var tooltip="";
		tooltip="log2(read count)="+d.getAttribute("logcount");
		if(that.bin>0){
			var tmpEnd=(d.getAttribute("start")*1)+(that.bin*1);
			tooltip=tooltip+"*<BR><BR>*Data compressed for display. Using 90th percentile of<BR>region:"+d.getAttribute("start")+"-"+tmpEnd+"<BR><BR>Zoom in to a region smaller than "+trackBinCutoff+"bp to see raw data.";
		}else{
			tooltip=tooltip+"<BR>Read Count:"+d.getAttribute("logcount");
		}
		return tooltip;
	}.bind(that);

	that.update=function (d){
		that.redraw();
	}.bind(that);

	that.updateFullData = function(retry,force){
		//that.showLoading();
		var tmpMin=this.xScale.domain()[0];
		var tmpMax=this.xScale.domain()[1];
		var len=tmpMax-tmpMin;
		that.bin=that.calculateBin(len);
		var tag="Count";
		var file="tmpData/regionData/"+folderName+"/count"+that.trackClass+".xml";
		if(that.bin>0){
			file="tmpData/regionData/"+folderName+"/bincount."+that.bin+"."+that.trackClass+".xml";
		}
		d3.xml(file,function (error,d){
					if(error){
						console.log(error);
						if(retry==0 || force==1){
							$.ajax({
								url: contextPath + "/web/GeneCentric/generateTrackXML.jsp",
				   				type: 'GET',
								//data: {chromosome: chr,minCoord:tmpMin,maxCoord:tmpMax,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrgansim: organism, track: that.trackClass, folder: folderName,binSize:that.bin},
								data: {chromosome: chr,minCoord:minCoord,maxCoord:maxCoord,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrgansim: organism, track: that.trackClass, folder: folderName,binSize:that.bin},
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
							}.bind(this),time);
						}else{
							d3.select("#Level"+this.levelNumber+track).select("#trkLbl").text("An errror occurred loading Track:"+track);
							d3.select("#Level"+this.levelNumber+track).attr("height", 15);
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
									that.updateFullData(retry+1);
								}.bind(this),5000);
							}
						}else{
							var data=d.documentElement.getElementsByTagName("Count");
							that.draw(data);
							that.hideLoading();
						}
					}
					that.hideLoading();
				}.bind(this));
	}.bind(that);

	that.draw=function(data){
		that.data=data;
		that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").val();
		that.redrawLegend();
		//console.log("count:draw("+that.density+")");
		var tmpMin=this.xScale.domain()[0];
		var tmpMax=this.xScale.domain()[1];
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
            			that.gsvg.tt.transition()        
							.duration(200)      
							.style("opacity", .95);      
						that.gsvg.tt.html(that.createToolTip(d))  
							.style("left", (d3.event.pageX-that.gsvg.halfWindowWidth) + "px")     
							.style("top", (d3.event.pageY +5) + "px");  
            			})
					.on("mouseout", function(d) {  
						d3.select(this).style("fill",that.color);
			            that.gsvg.get('tt').transition()
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
	}.bind(that);

	that.redrawLegend=function (){
		that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").val();
		if(that.density==2){
			d3.select("#Level"+this.gsvg.levelNumber+this.trackClass).selectAll(".legend").remove();
		}else if(that.density==1){
			var lblStr=new String(that.label);
			var x=that.gsvg.width/2+(lblStr.length/2)*7.5+5;
			d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".legend").remove();
			this.svg.append("text").text("0").attr("class","legend").attr("x",x-15).attr("y",12);
			
			for(var i=0;i<that.colorRange.length;i++){
				this.svg.append("rect")
					.attr("class","legend")
					.attr("x",x)
					.attr("y",0)
			    	.attr("height",12)
					.attr("width",10)
					.attr("fill",that.colorRange[i])
					.attr("stroke",that.colorRange[i]);
				x=x+10;
			}
			this.svg.append("text").text("16+").attr("class","legend").attr("x",x+10).attr("y",12);
		}
		
	}.bind(that);

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

function HelicosTrack(gsvg,data,trackClass,density){
	var that=new CountTrack(gsvg,data,trackClass,density);
	var lbl="Helicos RNA log2(read counts)";
	that.updateLabel(lbl);
	that.redrawLegend();
	return that;
}
function IlluminaSmallTrack(gsvg,data,trackClass,density){
	var that=new CountTrack(gsvg,data,trackClass,density);
	var lbl="Illumina Small RNA log2(read counts)";
	that.updateLabel(lbl);
	that.redrawLegend();
	return that;
}
function IlluminaTotalTrack(gsvg,data,trackClass,density){
	var that=new CountTrack(gsvg,data,trackClass,density);
	var lbl="Illumina Total RNA(rRNA depleted) log2(read counts)";
	that.updateLabel(lbl);
	that.redrawLegend();
	return that;
}
function IlluminaPolyATrack(gsvg,data,trackClass,density){
	var that=new CountTrack(gsvg,data,trackClass,density);
	var lbl="Illumina PolyA+ RNA log2(read counts)";
	that.updateLabel(lbl);
	that.redrawLegend();
	return that;
}

