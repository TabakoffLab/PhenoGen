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



var viewMenu=[];


function ViewMenu(level){
	var that={};
	that.level=level;
	that.viewList=[];
	that.selectedTrackSetting=0;
	that.previewLevel=100;
	that.previewSVG=NaN;
	that.curOrg=(new String(organism)).toUpperCase();
	//generates the preview image on the preview tab.
	that.generatePreview=function(d){
		$("div#previewOuter"+that.level+" div#previewContent").html("");
		var tmpOrg=new String(organism).toUpperCase();
		if(d.Organism=="AA"||d.Organism==tmpOrg){
			var min=svgList[that.level].xScale.domain()[0];
			var max=svgList[that.level].xScale.domain()[1];
			that.previewSVG=toolTipSVG("div#previewOuter"+that.level+" div#previewContent",565,min,max,that.previewLevel,chr,svgList[that.level].type);
			$("div#ScrollLevel"+that.previewLevel).css("overflow","auto").css("max-height","430px");
			var trackString=that.generateSettingsString(d);
			if(trackString!=""){
					loadStateFromString(trackString,"",that.previewLevel,that.previewSVG);
					that.previewSVG.updateData();
					that.previewSVG.updateFullData();
			}
		}else{
			$("div#previewOuter"+that.level+" div#previewContent").html("No Preview Available: The current organism doesn't match the tracks included in this view.");
		}
		
	};


	//called to generate the rows of the track list table 
	//creates the dragging/sorting behavior
	//creates the controls in each row
	that.generateTrackList=function(d){
		
		var bvData=[];
		//filter organism specific tracks out if they don't match current organism
		for(var i=0;i<d.TrackList.length;i++){
			if(d.TrackList[i].Organism=="AA"||(d.TrackList[i].Organism==that.curOrg)){
				bvData.push(d.TrackList[i]);
			}
		}

		d3.select("table#trackListTbl"+that.level).select("tbody").selectAll('tr').remove();
		var tracktbl=d3.select("table#trackListTbl"+that.level).select("tbody").selectAll('tr').data(bvData)
				.enter().append("tr").attr("class",function(d,i){
				if(i%2==0){
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
			if(d.Organism!="AA"){
				var shortOrg=d.Organism;
				if(shortOrg=="RN"){
					shortOrg="Rat";
				}else if(shortOrg=="MM"){
					shortOrg="Mouse";
				}
				species=shortOrg+" only";
			}
			d3.select(this).append("td").html(species);
			var edit="<span class=\"moveUp"+that.level+"\" name=\""+d.TrackID+"\" style=\"cursor:pointer;\" ><img src=\""+iconPath+"up_flat.png\"></span>";
			edit=edit+" <span class=\"moveDown"+that.level+"\" name=\""+d.TrackID+"\" style=\"cursor:pointer;\"><img src=\""+iconPath+"down_flat.png\"></span>";
			if(d.Controls!=undefined && d.Controls!="null" && d.Controls!=""){
				edit=edit+"&nbsp&nbsp&nbsp<span class=\"trackSetting"+that.level+"\" name=\""+d.TrackID+"\" style=\"cursor:pointer;\"><img src=\""+iconPath+"gear_flat.png\"></span>";
			}
			edit=edit+"&nbsp&nbsp&nbsp<span class=\"delete"+that.level+"\" name=\""+d.TrackID+"\" style=\"cursor:pointer;\"><img src=\""+iconPath+"del_flat.png\"></span>";
			
			d3.select(this).append("td").html(edit);
			d3.select("table#trackListTbl"+that.level).selectAll(".trackSetting"+that.level)
				.on("click",function(){
					var trackID=d3.select(this).attr("name");
					if(trackID!=that.selectedTrackSetting){
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
					var index=that.findTrackIndex(trackID);
					var viewInd=that.findSelectedViewIndex();
					var d=that.findSelectedView();
					d.TrackList.splice(index,1);
					that.generateTrackList(d);
					that.generateViewList();
					that.generatePreview(d);
					$("#viewSelect"+that.level).prop("selectedIndex",viewInd);
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
		var settingStr=that.generateSettingStringFromUI();
		svgList[that.level].removeAllTracks();
		loadStateFromString(settingStr,d.imgSettings,that.level,svgList[that.level]); 
		$("div.viewsLevel"+that.level).hide();
		$("div.trackLevel"+that.level).hide();
		$("span#viewLbl"+that.level).html("View: "+d.Name);
	};


	//called after dragging a track to reoder it which generates the first column again with the numbers etc.
	//reruns stripping to maintain appropriate alternating colors
	that.updateTrackNumber=function(e, ui) {
		$('td.ind', $("table#trackListTbl"+that.level)).each(function (i) {
				var grab="<img src=\""+iconPath+"grab_flat.png\" style=\"cursor: move; cursor: -webkit-grab; cursor: -moz-grab; \" class=\"handle"+that.level+"\">    ";
			 	$(this).html(grab+(i + 1));
		});
		d3.select("table#trackListTbl"+that.level).select("tbody").selectAll('tr').attr("class",function(d,i){
				if(i%2==0){
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
		if(pathPrefix==""){
			tmpContext="";
		}
		
		d3.json(tmpContext+"getBrowserViews.jsp",function (error,d){
			if(error){
				
			}else{
				//that.viewList=d;
				for(var i=0;i<d.length;i++){
					if(d[i].Organism=="AA"||d[i].Organism==that.curOrg){
						var orgCount=0;
						for(var j=0;j<d[i].TrackList.length;j++){
							var tmp=d[i].TrackList[j];
							if(tmp.Organism=="AA"||tmp.Organism==that.curOrg){
								orgCount++;
							}
						}
						d[i].orgCount=orgCount;
						that.viewList.push(d[i]);
					}
				}
				that.generateViewList();
			}
		});
	};

	that.selectChange=function(){
					var append="";
					var d=that.findSelectedView();
					if(d.Organism!="AA"){
							if(d.Organism=="RN"){
								append="<BR><BR>Available for Rat Only";
							}else if(d.Organism=="MM"){
								append="<BR><BR>Available for Mouse Only";
							}
					}
					if(d.UserID==0){
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
	};

	that.findSelectedView=function (){
		var id=$("#viewSelect"+that.level).val();
		var d=NaN;
		for(var i=0;i<that.viewList.length&&isNaN(d);i++){
			if(that.viewList[i].ViewID==id){
				d=that.viewList[i];
			}
		}
		return d;
	};
	that.findSelectedViewIndex=function(){
		var id=$("#viewSelect"+that.level).val();
		var d=NaN;
		for(var i=0;i<that.viewList.length&&isNaN(d);i++){
			if(that.viewList[i].ViewID==id){
				d=i;
			}
		}
		return d;
	};
	that.findTrack=function(id){
		var d=that.findSelectedView();
		var trackList=d.TrackList;
		var td=NaN;
		for(var i=0;i<trackList.length&&isNaN(td);i++){
			if(trackList[i].TrackID==id){
				td=trackList[i];
			}
		}
		return td;
	};

	that.findTrackIndex=function(id){
		var d=that.findSelectedView();
		var trackList=d.TrackList;
		var td=NaN;
		for(var i=0;i<trackList.length&&isNaN(td);i++){
			if(trackList[i].TrackID==id){
				td=i;
			}
		}
		return td;
	};

	that.setupControls=function(){
		$(".control"+that.level+"#addTrack"+that.level).on("click",function(){
			if($(".trackList"+that.level).length==0){
					var tmpContext=contextPath +"/"+ pathPrefix;
					if(pathPrefix==""){
						tmpContext="";
					}
					$.ajax({
							url:  tmpContext+"trackMenu.jsp",
			   				type: 'GET',
							data: {level: that.level, organism: organism},
							dataType: 'html',
			    			success: function(data2){
			    				$("#trackMenu"+that.level).remove();
			    				d3.select("div#trackMenu").append("div").attr("id","trackMenu"+that.level);
			    				$("#trackMenu"+that.level).html(data2);
			    			},
			    			error: function(xhr, status, error) {
			    				$("#trackMenu"+that.level).remove();
			    				d3.select("div#trackMenu").append("div").attr("id","trackMenu"+that.level);
			        			$('#trackMenu'+that.level).append("<div class=\"viewsLevel"+that.level+"\">An error occurred generating this menu.  Please try back later.</div>");
			    			},
			    			async:   false
						});
				}
				if(!$(".trackLevel"+that.level).is(":visible")){
						var p=$("span#viewsLevel"+that.level).position();
						var left=-515;
						if($(window).width()>=1200){
							left=-1117;
						}
						$(".trackLevel"+that.level).css("top",p.top).css("left",p.left+left);
						var d=that.findSelectedView();
						$(".trackLevel"+that.level+" span#selectedViewName").html(d.Name);
						$(".trackLevel"+that.level).fadeIn("fast");
						trackMenu[that.level].generateTrackTable();
				}else{
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
			
		})
		.on("mouseover",function(){
			$("#topcontrolInfo"+that.level).html("Click to create a new view with no tracks.");
		})
		.on("mouseout",function(){
			$("#topcontrolInfo"+that.level).html("");
		});


		$(".control"+that.level+"#copyView"+that.level).on("click",function(){
			
		})
		.on("mouseover",function(){
			$("#topcontrolInfo"+that.level).html("Click to create a new view copied from the selected view.");
		})
		.on("mouseout",function(){
			$("#topcontrolInfo"+that.level).html("");
		});

		$(".control"+that.level+"#saveView"+that.level).on("click",function(){
			
		})
		.on("mouseover",function(){
			$("#topcontrolInfo"+that.level).html("Click to save changes to the currently selected view.");
		})
		.on("mouseout",function(){
			$("#topcontrolInfo"+that.level).html("");
		});

		$(".control"+that.level+"#deleteView"+that.level).on("click",function(){
			var ind=that.findSelectedViewIndex();
			that.viewList.splice(ind,1);
			that.generateViewList();
		})
		.on("mouseover",function(){
			$("#topcontrolInfo"+that.level).html("Click to delete current view.");
		})
		.on("mouseout",function(){
			$("#topcontrolInfo"+that.level).html("");
		});
		$(".control"+that.level+"#deleteView"+that.level).on("click",function(){
			var ind=that.findSelectedViewIndex();
			that.viewList.splice(ind,1);
			that.generateViewList();
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
	};

	that.generateViewList=function(){
		d3.select("#viewSelect"+that.level).html("");

		that.filterList=[];
		var filterValue=$("#viewTypeSelect"+that.level).val();

		for(var i=0;i<that.viewList.length;i++){
			if( filterValue=="all" ||
				(filterValue=="predefined" && that.viewList[i].UserID==0)||
				(filterValue=="custom" && that.viewList[i].UserID!=0)
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
						if(d.UserID==0){
							ret=ret+"      (Predefined)";
						}else{
							ret=ret+"     (Custom)";
						}
						ret=ret+"     ("+d.orgCount+" tracks)";

						if(d.Organism!="AA"){
							if(d.Organism=="RN"){
								ret=ret+"      (Rat Only)";
							}else if(d.Organism=="MM"){
								ret=ret+"     (Mouse Only)";
							}
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
	};


	that.getViewData();
	that.setupControls();
	return that;
}

				
				
				
				
				
				

				
				
				
				
				
				
				
				