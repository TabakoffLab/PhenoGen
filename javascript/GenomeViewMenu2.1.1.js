/*
*	D3js/Jquery based View Menu for the Genome Data Browser
*
* 	Author: Spencer Mahaffey
*	for http://phenogen.ucdenver.edu
*	Tabakoff Lab
* 	University of Colorado Denver AMC
* 	Department of Pharmaceutical Sciences Skaggs School of Pharmacy & Pharmaceutical Sciences
*
*	In conjunction with viewMenu.jsp builds the View Menu for the Genome/Transcriptome Data Browser
*/






function ViewMenu(level){
	var that={};
	that.level=level;
	that.viewList=[];
	that.selectedTrackSetting=0;
	that.previewLevel=100;
	that.previewSVG=NaN;
	that.curOrg=(new String(organism)).toUpperCase();
	that.initialized=0;
	//generates the preview image on the preview tab.
	that.generatePreview=function(d){
		$("div#previewOuter"+that.level+" div#previewContent").html("");
		var tmpOrg=new String(organism).toUpperCase();
		if(d.Organism==="AA"||d.Organism===tmpOrg){
			var min=svgList[that.level].xScale.domain()[0];
			var max=svgList[that.level].xScale.domain()[1];
			that.previewSVG=toolTipSVG("div#previewOuter"+that.level+" div#previewContent",555,min,max,that.previewLevel,chr,svgList[that.level].type);
			$("div#ScrollLevel"+that.previewLevel).css("overflow","auto").css("max-height","360px");
			var trackString=that.generateSettingsString(d);
			if(trackString){
					//console.log(trackString);
					loadStateFromString(trackString,"",that.previewLevel,that.previewSVG);
					that.previewSVG.updateData();
					that.previewSVG.updateFullData();
			}
		}else{
			$("div#previewOuter"+that.level+" div#previewContent").html("No Preview Available: The current organism doesn't match the tracks included in this view.");
		}
		
	};

	that.removeTrackWithID=function(id){
		var index=that.findTrackIndex(id);
		var viewID=that.findSelectedView().ViewID;
		that.removeTrackWithIDIdx(index,viewID);
	};
	that.removeTrackWithIDIdx=function(indx,vwID){
		var d=that.findViewWithID(vwID);
		var vwIndx=that.findViewIndexByID(vwID);
		d.TrackList.splice(indx,1);
		that.generateTrackList(d);
		that.findSelectedView().modified=1;
		that.generateViewList();
		that.generatePreview(d);
		$("#viewSelect"+that.level).prop("selectedIndex",vwIndx);
	};
	//called to generate the rows of the track list table 
	//creates the dragging/sorting behavior
	//creates the controls in each row
	that.generateTrackList=function(d){
		
		var bvData=[];
		//filter organism specific tracks out if they don't match current organism
		for(var i=0;i<d.TrackList.length;i++){
			if(d.TrackList[i].Organism==="AA"||(d.TrackList[i].Organism===that.curOrg)){
				bvData.push(d.TrackList[i]);
			}
		}

		d3.select("table#trackListTbl"+that.level).select("tbody").selectAll('tr').remove();
		var tracktbl=d3.select("table#trackListTbl"+that.level).select("tbody").selectAll('tr').data(bvData)
				.enter().append("tr").attr("class",function(d,i){
				if(i%2===0){
					return "even";
				}else{
					return "odd";
				}
					})
				.attr("id",function(d){return "trk"+d.TrackID;});
		tracktbl.each(function(d,i){
			var grab="<img src=\""+iconPath+"grab_flat.png\" style=\"cursor: move; cursor: -webkit-grab; cursor: -moz-grab; \" class=\"handle"+that.level+"\">";
			d3.select(this).append("td").attr("class","ind").html(grab+(i + 1));
			var info="  <span class=\"listtooltip"+that.level+"\" title= \""+d.Description+"\"><img src=\""+iconPath+"info.gif\"></span>";

			d3.select(this).append("td").html(d.Name+info);
			var species="";
			if(d.Organism!=="AA"){
				var shortOrg=d.Organism;
				if(shortOrg==="RN"){
					shortOrg="Rat";
				}else if(shortOrg==="MM"){
					shortOrg="Mouse";
				}
				species=shortOrg+" only";
			}
			d3.select(this).append("td").html(species);
			var edit="<span class=\"moveUp"+that.level+"\" name=\""+d.TrackID+"\" style=\"cursor:pointer;\" ><img src=\""+iconPath+"up_flat.png\"></span>";
			edit=edit+" <span class=\"moveDown"+that.level+"\" name=\""+d.TrackID+"\" style=\"cursor:pointer;\"><img src=\""+iconPath+"down_flat.png\"></span>";
			if(d.Controls&&d.Controls.length>5){
				edit=edit+"&nbsp&nbsp&nbsp<span class=\"trackSetting"+that.level+"\" name=\""+d.TrackID+"\" style=\"cursor:pointer;\"><img src=\""+iconPath+"gear_flat.png\"></span>";
			}
			edit=edit+"&nbsp&nbsp&nbsp<span class=\"delete"+that.level+"\" name=\""+d.TrackID+"\" style=\"cursor:pointer;\"><img src=\""+iconPath+"del_flat.png\"></span>";
			
			d3.select(this).append("td").html(edit);
			d3.select("table#trackListTbl"+that.level).selectAll(".trackSetting"+that.level)
				.on("click",function(){
					var trackID=d3.select(this).attr("name");
					if(trackID!==that.selectedTrackSetting){
						var track=that.previewSVG.getTrack(that.findTrack(trackID).TrackClass);
						track.generateSettingsDiv("div#trackSettingContent");
						//that.generateSettingsDiv(that.findTrack(trackID));
						that.selectedTrackSetting=trackID;
						var p=$(this).position();
						$('#trackSettingDialog').css("top",p.top+240).css("left",$(window).width()-415);
						$('#trackSettingDialog').fadeIn("fast");
					}else{
						$('#trackSettingDialog').fadeOut("fast");
					}

				})
				.on("mouseover",function(){
					$("#controlInfo"+that.level).html("Click to edit track settings.");
				})
				.on("mouseout",function(){
					$("#controlInfo"+that.level).html("");
				});
			d3.select("table#trackListTbl"+that.level).selectAll(".moveUp"+that.level)
				.on("click",function(){
					var trkID=$(this).attr("name");
					$('tr#trk'+trkID).insertBefore($("table#trackListTbl"+that.level+" tbody tr:first"));
					that.findSelectedView().modified=1;
					that.updateTrackNumber("",$('tr#trk'+trkID));
				})
				.on("mouseover",function(){
					$("#controlInfo"+that.level).html("Click to move the track to the top of the list.");
				})
				.on("mouseout",function(){
					$("#controlInfo"+that.level).html("");
				});
			d3.select("table#trackListTbl"+that.level).selectAll(".moveDown"+that.level)
				.on("click",function(){
					var trkID=$(this).attr("name");
					$('tr#trk'+trkID).insertAfter($("table#trackListTbl"+that.level+" tbody tr:last"));
					that.findSelectedView().modified=1;
					that.updateTrackNumber("",$('tr#trk'+trkID));
				})
				.on("mouseover",function(){
					$("#controlInfo"+that.level).html("Click to move the track to the end of the list.");
				})
				.on("mouseout",function(){
					$("#controlInfo"+that.level).html("");
				});
			d3.select("table#trackListTbl"+that.level).selectAll(".delete"+that.level)
				.on("click",function(){
					var trackID=d3.select(this).attr("name");
					that.removeTrackWithID(trackID);
				})
				.on("mouseover",function(){
					$("#controlInfo"+that.level).html("Click to remove the track from the view.");
				})
				.on("mouseout",function(){
					$("#controlInfo"+that.level).html("");
				});

		});
		
		$("#trackListTbl"+that.level+" tbody").sortable({
									handle: ".handle"+that.level,
									stop: that.updateTrackNumber
								}).disableSelection();

		$(".listtooltip"+that.level).tooltipster({
			position: 'top-right',
			maxWidth: 250,
			offsetX: 10,
			offsetY: 5,
			contentAsHTML:true,
			interactive: true,
			interactiveTolerance: 350
		});
	};


	//Called to apply current view to the main browser image
	//automatically closes the popup windows.
	that.applyView=function(){
		var d=that.findSelectedView();
		/*if(isNaN(d)){
			d=that.viewList[0];
		}*/
		var settingStr=that.generateSettingStringFromUI();
		that.setupImage(settingStr,d);
		$("div.viewsLevel"+that.level).hide();
		$("div.trackLevel"+that.level).hide();
		var tmpContext=contextPath +"/"+ pathPrefix;
		if(d.Source==="db"){
			if(!pathPrefix){
				tmpContext="";
			}
			$.ajax({
					url:  tmpContext +"addBrowserCount.jsp",
	   				type: 'GET',
	   				cache: false,
					data: {viewID:d.ViewID},
					dataType: 'json',
	    			success: function(data2){},
	    			error: function(xhr, status, error) {},
	    			async: true
				});	
		}
	};
	that.applySelectedView=function(viewID){
		var d=NaN;
		var ind=-1;
		for(var i=0;i<that.filterList.length&&isNaN(d);i++){
			if(that.filterList[i].ViewID===viewID){
				d=that.filterList[i];
				ind=i;
			}
		}
		/*if(isNaN(d)){
			d=that.filterList[0];
		}*/
		var settingString=that.generateSettingStringFromView(d);
		that.setupImage(settingString,d);
		$("#viewSelect"+that.level).prop("selectedIndex",ind);
		that.selectChange();
	};
	that.setupImage=function(settingString,d){
		svgList[that.level].removeAllTracks();
		svgList[that.level].currentView=d;
		svgViewIDList[that.level]=d.ViewID;
		//svgList[that.level].updateLinks();
		loadStateFromString(settingString,d.imgSettings,that.level,svgList[that.level]); 
		$("span#viewLbl"+that.level).html("View: "+d.Name);
		if(d.UserID===0){
			$("li#menusaveView"+that.level).addClass("ui-state-disabled");
			$("li#menudeleteView"+that.level).addClass("ui-state-disabled");
		}else{
			$("li#menusaveView"+that.level).removeClass("ui-state-disabled");
			$("li#menudeleteView"+that.level).removeClass("ui-state-disabled");
		}
	};

	//called after dragging a track to reoder it which generates the first column again with the numbers etc.
	//reruns stripping to maintain appropriate alternating colors
	that.updateTrackNumber=function(e, ui) {
		$('td.ind', $("table#trackListTbl"+that.level)).each(function (i) {
				var grab="<img src=\""+iconPath+"grab_flat.png\" style=\"cursor: move; cursor: -webkit-grab; cursor: -moz-grab; \" class=\"handle"+that.level+"\">    ";
			 	$(this).html(grab+(i + 1));
		});
		d3.select("table#trackListTbl"+that.level).select("tbody").selectAll('tr').attr("class",function(d,i){
				if(i%2===0){
					return "even";
				}else{
					return "odd";
				}
			});
		var d=that.findSelectedView();
		that.generatePreview(d);
    };

	that.generateSettingsString=function(d){
		var ret="";
		/*
		for(var k=0;k<d.TrackList.length;k++){
			ret=ret+d.TrackList[k].TrackClass+","+d.TrackList[k].Settings+";";
		}*/
		d3.select("table#trackListTbl"+that.level).select("tbody").selectAll('tr').each(function(d){
			ret=ret+d.TrackClass+","+d.Settings+";";
		});
		return ret;
	};

	that.generateSettingStringFromUI=function(){
		var ret="";
		ret=that.previewSVG.generateSettingsString();
		return ret;
	};

	that.getViewData=function(){
		var tmpContext=contextPath +"/"+ pathPrefix;
		if(!pathPrefix){
			tmpContext="";
		}
		
		d3.json(tmpContext+"getBrowserViews.jsp",function (error,d){
			if(error){
				
			}else{
				that.viewList=[];
				//that.viewList=d;
				for(var i=0;i<d.length;i++){
					if(d[i].Organism==="AA"||d[i].Organism===that.curOrg){
						var orgCount=0;
						for(var j=0;j<d[i].TrackList.length;j++){
							var tmp=d[i].TrackList[j];
							if(tmp.Organism==="AA"||tmp.Organism===that.curOrg){
								orgCount++;
							}
						}
						d[i].orgCount=orgCount;
						that.viewList.push(d[i]);
					}
				}
				if(trackInfo){
					that.readCookieViews();
				}
				that.generateViewList();
				if(that.initialized===0 && that.level===0){
					that.initialized=1;
					that.applySelectedView($("#defaultView").val());
				}else if(that.level===1){
					that.initialized=1;
					that.applySelectedView(svgViewIDList[that.level]);
				}
			}
		});
	};

	that.readCookieViews=function(){
		//console.log(trackInfo);
		var viewString="";
		if(isLocalStorage() === true){
			var cur=localStorage.getItem("phenogenCustomViews");
			if(cur){
				viewString=cur;
			}
		}else{
			if($.cookie("phenogenCustomViews")){
				viewString=$.cookie("phenogenCustomViews");
			}
		}
		if(viewString && viewString.indexOf("<///>")>-1){
			var viewStrings=viewString.split("<///>");
			for(var j=0;j<viewStrings.length;j++){
				var params=viewStrings[j].split("</>");
				var obj={};
				for(k=0;k<params.length;k++){
					var values=params[k].split("=");
					if(values[0]==="TrackSettingList"){
						var trList=values[1].split(";");
						obj.TrackList=[];
						for(var m=0;m<trList.length;m++){
							if(trList[m].length>0){
								var tc=trList[m].substr(0,trList[m].indexOf(","));
								var set=trList[m].substr(trList[m].indexOf(",")+1);
								var track={};
								track.TrackClass=tc;
								track.Settings=set;
								track.Order=m;
								obj.TrackList.push(track);
							}
						}
					}else if(values.length<=2){
						obj[values[0]]=values[1];
					}else if(values.length>2){
						var name=params[k].substr(0,params[k].indexOf("="));
						var value=params[k].substr(params[k].indexOf("=")+1);
						obj[name]=value;
					}
				}
				obj.Source="local";
				if(params.length>3){
					var orgCount=0;
					for(var k=0;k<obj.TrackList.length;k++){
						//console.log(obj.TrackList[k].TrackClass);
						var sourceTrack=trackInfo[obj.TrackList[k].TrackClass];
						if(sourceTrack){
							obj.TrackList[k].TrackID=sourceTrack.TrackID;
							obj.TrackList[k].UserID=sourceTrack.UserID;
							obj.TrackList[k].Name=sourceTrack.Name;
							obj.TrackList[k].Description=sourceTrack.Description;
							obj.TrackList[k].Organism=sourceTrack.Organism;
							obj.TrackList[k].Controls=sourceTrack.Controls;
						}
						var tmp=obj.TrackList[k];
						if(tmp.Organism==="AA"||tmp.Organism===that.curOrg){
							orgCount++;
						}
					}
					obj.orgCount=orgCount;
					//console.log("pushed object");
					//console.log(obj);
					that.viewList.push(obj);
				}
			}
		}
	};

	that.generateSettingStringFromView=function(view){
		var ret="";
		var tracks=view.TrackList;
		for(var j=0;j<tracks.length;j++){
			ret=ret+tracks[j].TrackClass+","+tracks[j].Settings+";";
		}
		return ret;
	};

	that.selectChange=function(){
					var append="";
					var d=that.findSelectedView();
					if(d.Organism!=="AA"){
							if(d.Organism==="RN"){
								append="<BR><BR>Available for Rat Only";
							}else if(d.Organism==="MM"){
								append="<BR><BR>Available for Mouse Only";
							}
					}
					if(d.UserID===0){
						$("#deleteView"+that.level).hide();
					}else{
						$("#deleteView"+that.level).show();
					}
					$("div#descOuter"+that.level+" div#descContent").html(d.Description+append);
					that.generateTrackList(d);
					that.generatePreview(d);
					if($(".trackLevel"+that.level).is(":visible")){
						trackMenu[that.level].generateTrackTable();
					}
					//if($("#trackSettingDialog").is(":visible")){
						$("#trackSettingDialog").hide();
						//cancel?
					//}
	};

	that.setSelectedView=function(id){
		$("#viewTypeSelect"+that.level).val("all");
		that.generateViewList();
		var ind=that.findDisplayedIndex(id);
		$("#viewSelect"+that.level).prop("selectedIndex",ind);
	};

	that.findSelectedView=function (){
		var id=$("#viewSelect"+that.level).val();
		var d=NaN;
		for(var i=0;i<that.viewList.length&&isNaN(d);i++){
			if(that.viewList[i].ViewID===id){
				d=that.viewList[i];
			}
		}
		return d;
	};

	that.findViewWithID=function (id){
		var d=NaN;
		for(var i=0;i<that.viewList.length&&isNaN(d);i++){
			if(that.viewList[i].ViewID===id){
				d=that.viewList[i];
			}
		}
		return d;
	};
	that.findViewIndexByID=function(id){
		var d=NaN;
		for(var i=0;i<that.viewList.length&&isNaN(d);i++){
			if(that.viewList[i].ViewID===id){
				d=i;
			}
		}
		return d;
	};

	that.findSelectedViewIndex=function(){
		var id=$("#viewSelect"+that.level).val();
		var d=NaN;
		for(var i=0;i<that.viewList.length&&isNaN(d);i++){
			if(that.viewList[i].ViewID===id){
				d=i;
			}
		}
		return d;
	};

	

	that.findDisplayedIndex=function(id){
		var ind=NaN;
		for(var i=0;i<that.filterList.length&&isNaN(ind);i++){
			if(that.filterList[i].ViewID===id){
				ind=i;
			}
		}
		return ind;
	};

	that.findTrackByClass=function(trackClass,viewID){
		var d=that.findViewWithID(viewID);
		var trackList=d.TrackList;
		var td=NaN;
		for(var i=0;i<trackList.length&&isNaN(td);i++){
			if(trackList[i].TrackClass===trackClass){
				td=trackList[i];
			}
		}
		return td;
	}

	that.findTrack=function(id){
		var d=that.findSelectedView();
		var trackList=d.TrackList;
		var td=NaN;
		for(var i=0;i<trackList.length&&isNaN(td);i++){
			if(trackList[i].TrackID===id){
				td=trackList[i];
			}
		}
		return td;
	};

	that.findTrackIndex=function(id){
		var d=that.findSelectedView();
		var trackList=d.TrackList;
		var td=NaN;
		if(typeof trackList!=='undefined'){
			for(var i=0;i<trackList.length&&isNaN(td);i++){
				if(trackList[i].TrackID===id){
					td=i;
				}
			}
		}
		return td;
	};

	that.findTrackIndexWithViewID=function(id,viewID){
		var d=that.findViewWithID(viewID);
		var trackList=d.TrackList;
		var td=NaN;
		for(var i=0;i<trackList.length&&isNaN(td);i++){
			if(trackList[i].TrackID===id){
				td=i;
			}
		}
		return td;
	}

	that.setupControls=function(){
		if(level>-1){
			$(".control"+that.level+"#addTrack"+that.level).on("click",function(){
					if(!$(".trackLevel"+that.level).is(":visible")){
							var p=$("div.viewsLevel"+that.level).position();
							//console.log($("div.trackLevel"+that.level)[0].getBoundingClientRect());
							//console.log(p);
							var left=0;
							if($(window).width()>=1200){
								left=-601;
							}
							trackMenu[that.level].standalone=false;
							$(".trackLevel"+that.level).css("top",p.top).css("left",p.left+left);
							var d=that.findSelectedView();
							$(".trackLevel"+that.level+" span#selectedViewName").html(d.Name);
							$(".trackLevel"+that.level).fadeIn("fast");
							$("div#selectTrack"+that.level).show();
                    		$("div#addUsrTrack"+that.level).hide();
                    		$("div#addUsrTrack"+that.level).hide();
                    		$("div#deleteUsrTrack"+that.level).hide();
							//console.log(trackMenu);
							setTimeout(function(){
								trackMenu[that.level].generateTrackTable();
							},250);
					} else{
							$(".trackLevel"+that.level).fadeOut("fast");
					}
				})
				.on("mouseover",function(){
					$("#controlInfo"+that.level).html("Click to add a track to the current view.");
				})
				.on("mouseout",function(){
					$("#controlInfo"+that.level).html("");
				});

			$(".control"+that.level+"#addView"+that.level).on("click",function(){
					$("div#nameView"+that.level).show();
					$("div#selection"+that.level).hide();
					$("span#viewMenuLbl"+that.level).text("Create View");
					$("input#createType"+that.level).val("blank");
					$("input#function"+that.level).val("create");
				})
				.on("mouseover",function(){
					$("#topcontrolInfo"+that.level).html("Click to create a new view with no tracks.");
				})
				.on("mouseout",function(){
					$("#topcontrolInfo"+that.level).html("");
				});

			$(".control"+that.level+"#copyView"+that.level).on("click",function(){
					$("div#nameView"+that.level).show();
					$("div#selection"+that.level).hide();
					$("span#viewMenuLbl"+that.level).text("Create View");
					$("input#createType"+that.level).val("copy");
					$("input#function"+that.level).val("create");
			})
				.on("mouseover",function(){
					$("#topcontrolInfo"+that.level).html("Click to create a new view copied from the selected view.");
				})
				.on("mouseout",function(){
					$("#topcontrolInfo"+that.level).html("");
				});

			$(".control"+that.level+"#saveView"+that.level).on("click",function(){
					var d=that.findSelectedView();
					if(d.UserID===0){//if predefined prompt to save as
						$("#predefinedSaveAs"+that.level).show();
						that.saveAsView(d,that.previewSVG);
					}else{//else save
						that.saveView(d.ViewID,that.previewSVG,false);
					}
				})
				.on("mouseover",function(){
					$("#topcontrolInfo"+that.level).html("Click to save changes to the currently selected view.");
				})
				.on("mouseout",function(){
					$("#topcontrolInfo"+that.level).html("");
				});

			$(".control"+that.level+"#deleteView"+that.level).on("click",function(){
					//confirm delete
					var ind=that.findSelectedViewIndex();
					var d=that.viewList[ind];
					that.confirmDeleteView(d);
			})
				.on("mouseover",function(){
					$("#topcontrolInfo"+that.level).html("Click to delete current view.");
				})
				.on("mouseout",function(){
					$("#topcontrolInfo"+that.level).html("");
				});
			$(".applyView"+that.level).on("click", function(){
							that.applyView();
			});

			d3.select("#viewTypeSelect"+that.level).on("change",that.generateViewList)
				.on("mouseover",function(){$("#topcontrolInfo"+that.level).html("Change to filter the view list by category.");})
				.on("mouseout",function(){$("#topcontrolInfo"+that.level).html("");});
		}
	};

	that.generateViewList=function(){
		d3.select("#viewSelect"+that.level).html("");

		that.filterList=[];
		var filterValue=$("#viewTypeSelect"+that.level).val();

		for(var i=0;i<that.viewList.length;i++){
			if( filterValue==="all" ||
				(filterValue==="predefined" && that.viewList[i].UserID===0)||
				(filterValue==="custom" && that.viewList[i].UserID!==0)
				){
					//if(that.viewList[i].Organism=="AA"||that.viewList[i].Organism==that.curOrg){
						that.filterList.push(that.viewList[i]);
					//}
			}
		}

		var opt=d3.select("#viewSelect"+that.level).on("change",that.selectChange)
					.on("mouseover",function(){$("#topcontrolInfo"+that.level).html("Click on a view to select it and view preview/details.");})
					.on("mouseout",function(){$("#topcontrolInfo"+that.level).html("");})
					.selectAll('option').data(that.filterList);
		opt.enter().append("option").attr("value",function(d){return d.ViewID;}).text(function(d){
						var ret=d.Name;
						if(d.UserID===0){
							ret=ret+"      (Predefined)";
						}else{
							var local="";
							if(d.Source==="local"){
								local=" local";
							}else{
								local=" server";
							}
							ret=ret+"     (Custom"+local+")";
						}
						ret=ret+"     ("+d.orgCount+" tracks)";

						if(d.Organism!=="AA"){
							if(d.Organism==="RN"){
								ret=ret+"      (Rat Only)";
							}else if(d.Organism==="MM"){
								ret=ret+"     (Mouse Only)";
							}
						}

						if(d.modified && d.modified===1){
							ret=ret+"   (Modified)";
						}
						
						return ret;
					});
		
	};

	that.addTrackToView=function(trackData){
		var view=that.findSelectedView();
		var viewInd=that.findSelectedViewIndex();
		//Add Data if needed
		view.TrackList.push(trackData);
		that.generateTrackList(view);
		that.generatePreview(view);
		that.generateViewList();
		$("#viewSelect"+that.level).prop("selectedIndex",viewInd);
		//update main menu on the browser form
		//getMainViewData(1);
	};
	that.addTrackToViewWithID=function(id,trackData){
		var view=that.findViewWithID(id);
		view.TrackList.push(trackData);
		that.generateTrackList(view);
		that.generatePreview(view);
		that.generateViewList();
		//$("#viewSelect"+that.level).prop("selectedIndex",viewInd);
	};

	that.createNewView = function(){
		$("#predefinedSaveAs"+that.level).hide();
		if(uid>0){
			if($("#function"+that.level).val()==="create"){
				var name=$("input#viewNameTxt"+that.level).val();
				var desc=$("#viewDescTxt"+that.level).val();
				var type=$("input#createType"+that.level).val();
				var copyID=-1;
				if(type==="copy"){
					copyID=that.findSelectedView().ViewID;
				}
				var tmpContext=contextPath +"/"+ pathPrefix;
				if(!pathPrefix){
					tmpContext="";
				}
				$.ajax({
						url:  tmpContext +"createBrowserViews.jsp",
		   				type: 'GET',
		   				cache: false,
						data: {name:name,description:desc,type:type,copyFrom:copyID,organism:organism},
						dataType: 'json',
		    			success: function(data2){
		    				that.getViewData();
		    				$("div#nameView"+that.level).hide();
							$("div#selection"+that.level).show();
							$("span#viewMenuLbl"+that.level).html("Select/Edit Views");
		    			},
		    			error: function(xhr, status, error) {
		    				console.log(error);
		    			},
		    			async:   false
					});
			}else if($("#function"+that.level).val()==="saveAs"){
				var name=$("input#viewNameTxt"+that.level).val();
				var desc=$("#viewDescTxt"+that.level).val();
				var type="blank";
				var copyID=-1;
				var tmpContext=contextPath +"/"+ pathPrefix;
				if(!pathPrefix){
					tmpContext="";
				}
				$.ajax({
						url:  tmpContext +"createBrowserViews.jsp",
		   				type: 'GET',
		   				cache: false,
						data: {name:name,description:desc,type:type,copyFrom:copyID,organism:organism},
						dataType: 'json',
		    			success: function(data2){
		    				var newViewID=data2.viewID;
		    				//save tracks/settings
		    				//that.saveView(newViewID,svgList[that.level],false);
		    				that.saveView(newViewID,that.saveAsImg,false);
		    				$("div#nameView"+that.level).hide();
							$("div#selection"+that.level).show();
							$("span#viewMenuLbl"+that.level).html("Select/Edit Views");
		    			},
		    			error: function(xhr, status, error) {
		    				console.log(error);
		    			},
		    			async:   false
					});
			}
		}else{
			//save view to cookie
			var name=$("input#viewNameTxt"+that.level).val();
			var desc=$("#viewDescTxt"+that.level).val();
			var type=$("input#createType"+that.level).val();
			//create a new view
			var newView="";
			var viewID=$.cookie("JSESSIONID");
			var curTime=new Date().getTime();
			viewID=viewID+"_"+curTime;
			newView="ViewID="+viewID+"</>UserID=-999</>Name="+name+"</>Description="+desc+"</>Organism="+organism.toUpperCase()+"</>imgSettings=displaySelect0=700;</>TrackSettingList=";
			
			if($("#function"+that.level).val()==="saveAs"){//save tracks to new view or copy
				var trackList=that.saveAsImg.generateSettingsString();
				//var trackList=svgList[that.level].generateSettingsString();
				newView=newView+trackList;
				//console.log("tracklist part:"+trackList);
			}else if(type==="copy"){
				var trackList="";
				var sourceTracks=that.findSelectedView().TrackList;
				for(var k=0;k<sourceTracks.length;k++){
					trackList=trackList+sourceTracks[k].TrackClass+","+sourceTracks[k].Settings+";";
				}
				newView=newView+trackList;
				//console.log("tracklist part:"+trackList);
			}
			
			newView=newView+"<///>";

			//console.log("Saving View:"+newView);

			if(isLocalStorage() === true){
				var cur=localStorage.getItem("phenogenCustomViews");
				if(cur){
					localStorage.setItem("phenogenCustomViews",cur+newView);
				}else{
					localStorage.setItem("phenogenCustomViews",newView);
				}
			}else{
				var cookieStr="";
				if($.cookie("phenogenCustomViews")){
					cookieStr=$.cookie("phenogenCustomViews")+newView;
				}else{
					cookieStr=newView;
				}
				$.cookie("phenogenCustomViews",cookieStr);
			}

			that.getViewData();
		    $("div#nameView"+that.level).hide();
			$("div#selection"+that.level).show();
			$("span#viewMenuLbl"+that.level).html("Select/Edit Views");
		}
		$("input#viewNameTxt"+that.level).val("");
		$("#viewDescTxt"+that.level).val("");
		$("input#createType"+that.level).val("blank");
		getMainViewData(1);
	};

	that.saveView= function(viewID,svgImage,async){
		if(uid>0){
			//save tracks/settings
			var trackList=svgImage.generateSettingsString();
			var tmpContext=contextPath +"/"+ pathPrefix;
			if(!pathPrefix){
				tmpContext="";
			}
			if(viewID>0){
				$.ajax({
					url:  tmpContext +"updateBrowserView.jsp",
	   				type: 'GET',
	   				cache: false,
					data: {viewID:viewID,trackList:trackList},
					dataType: 'json',
	    			success: function(data3){
	    				that.getViewData();
	    			},
	    			error: function(xhr, status, error) {
	    				console.log(error);
	    			},
	    			async:   async
				});
			}
		}else{
			//save to cookie or localStorage
			var cookieStr="";
			var newCookie="";
			if(isLocalStorage() === true){
				var cur=localStorage.getItem("phenogenCustomViews");
				if(cur){
					cookieStr=cur;
				}
			}else{
				if($.cookie("phenogenCustomViews")){
					cookieStr=$.cookie("phenogenCustomViews");
				}
			}
			var cookieList=cookieStr.split("<///>");
			for(var l=0;l<cookieList.length;l++){
				if(cookieList[l].length>10){
					if(cookieList[l].indexOf("ViewID="+viewID)>-1){
						var begining=cookieList[l].substr(0,cookieList[l].indexOf("</>TrackSettingList="));
						var list=svgImage.generateSettingsString();
						newCookie=newCookie+begining+"</>TrackSettingList="+list+"<///>";
					}else{
						newCookie=newCookie+cookieList+"<///>";
					}
				}
			}
			if(isLocalStorage() === true){
				localStorage.setItem("phenogenCustomViews",newCookie);
			}else{
				$.cookie("phenogenCustomViews",newCookie);
			}
			that.getViewData();
		}
		getMainViewData(1);
	};

	that.saveAsView=function(viewCopy,img){
		that.saveAs=viewCopy;
		that.saveAsImg=img;
		$("div#nameView"+that.level).show();
		$("div#selection"+that.level).hide();
		$("span#viewMenuLbl"+that.level).text("Save As...");
		$("input#createType"+that.level).val("blank");
		$("input#function"+that.level).val("saveAs");
	};

	that.confirmDeleteView = function(toDelete){
		if(that.findSelectedView().ViewID!==toDelete.ViewID){
			that.setSelectedView(toDelete.ViewID);
		}
		if(toDelete.UserID>0||Number(toDelete.UserID)===-999){
			$("div#selection"+that.level).hide();
			$("#deleteViewName"+that.level).html(toDelete.Name+"    ("+toDelete.orgCount+ " tracks)");
			$("#confirmDeleteView"+that.level).show();
		}else{
			$("#topcontrolInfo"+that.level).html("This is a predefined view, you may not delete it.");
		}
	};

	that.cancelDeleteView = function(){
		$("#confirmDeleteView"+that.level).hide();
		$("div#selection"+that.level).show();
	};

	that.deleteView = function(){
		var ind=that.findSelectedViewIndex();
		var d=that.viewList[ind];
		if(d.Source==="db"){
			var tmpContext=contextPath +"/"+ pathPrefix;
			if(!pathPrefix){
				tmpContext="";
			}
			$.ajax({
					url:  tmpContext +"deleteView.jsp",
	   				type: 'GET',
					data: {viewID:d.ViewID},
					dataType: 'json',
					cache: false,
	    			success: function(data2){
	    				if(data2.status==="Deleted Successfully"){
	    					that.viewList.splice(ind,1);
							that.generateViewList();
	    				}
	    				$("#topcontrolInfo"+that.level).html(data2.status);
	    			},
	    			error: function(xhr, status, error) {
	    				console.log(error);
	    				$("#topcontrolInfo"+that.level).html("There was an error deleting this view.");
	    			},
	    			async:   true
				});
		}else{
			var cookieStr="";
			var newCookie="";
			
			if(isLocalStorage() === true){
				var cur=localStorage.getItem("phenogenCustomViews");
				if(cur){
					cookieStr=cur;
				}
			}else{
				if($.cookie("phenogenCustomViews")){
					cookieStr=$.cookie("phenogenCustomViews");
				}
			}
			var cookieList=cookieStr.split("<///>");
			for(var l=0;l<cookieList.length;l++){
				if(cookieList[l].indexOf("ViewID="+d.ViewID)>-1){

				}else{
					if(cookieList[l].length>10){
						newCookie=newCookie+cookieList[l]+"<///>";
					}
				}
			}
			if(isLocalStorage() === true){
				localStorage.setItem("phenogenCustomViews",newCookie);
			}else{
				$.cookie("phenogenCustomViews",newCookie);
			}
			that.viewList.splice(ind,1);
			that.generateViewList();
		}
		$("#confirmDeleteView"+that.level).hide();
		$("div#selection"+that.level).show();

		$("#viewSelect"+that.level).prop("selectedIndex",0);
		that.selectChange();
		if(svgList[that.level].currentView.ViewID===d.ViewID){
			that.applyView();
		}

		//update main menu on the browser form
		getMainViewData(1);

	};
        
    that.cancelView = function(){
        $("div#nameView"+that.level).hide();
        $("div#selection"+that.level).show();
        $("#predefinedSaveAs"+that.level).hide();
        $("span#viewMenuLbl"+that.level).html("Select/Edit Views");
    };

	that.getViewData();
	that.setupControls();
	return that;
}

				
				
				
				
				
				

				
				
				
				
				
				
				
				