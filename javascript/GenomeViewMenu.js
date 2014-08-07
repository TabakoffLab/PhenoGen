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

	//generates the preview image on the preview tab.
	that.generatePreview=function(d){
		$("div#previewOuter"+that.level+" div#previewContent").html("");
		var tmpOrg=new String(organism).toUpperCase();
		if(d.Organism=="AA"||d.Organism==tmpOrg){
			var min=svgList[that.level].xScale.domain()[0];
			var max=svgList[that.level].xScale.domain()[1];
			var newSvg=toolTipSVG("div#previewOuter"+that.level+" div#previewContent",565,min,max,that.previewLevel,chr,svgList[that.level].type);
			$("div#ScrollLevel"+that.previewLevel).css("overflow","auto").css("max-height","430px");
			var trackString=that.generateSettingsString(d);
					loadStateFromString(trackString,"",that.previewLevel,newSvg);
					newSvg.updateData();
					newSvg.updateFullData();
		}else{
			$("div#previewOuter"+that.level+" div#previewContent").html("No Preview Available: The current organism doesn't match the tracks included in this view.");
		}
		
	};


	//called to generate the rows of the track list table 
	//creates the dragging/sorting behavior
	//creates the controls in each row
	that.generateTrackList=function(d){
		var bvData=d;
		d3.select("table#trackListTbl"+that.level).select("tbody").selectAll('tr').remove();
		var tracktbl=d3.select("table#trackListTbl"+that.level).select("tbody").selectAll('tr').data(d.TrackList).enter().append("tr").attr("class",function(d,i){
				if(i%2==0){
					return "even";
				}else{
					return "odd";
				}
			}).attr("id",function(d){return "trk"+d.TrackID;});
		tracktbl.each(function(d,i){
			var grab="<img src=\""+iconPath+"grab_light.png\" style=\"cursor: move; cursor: -webkit-grab; cursor: -moz-grab; \" class=\"handle"+that.level+"\">";
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
			var edit="<span class=\"moveUp"+that.level+"\" name=\""+d.TrackID+"\" style=\"cursor:pointer;\" ><img src=\""+iconPath+"smArrowUp.png\"></span>";
			edit=edit+" <span class=\"moveDown"+that.level+"\" name=\""+d.TrackID+"\" style=\"cursor:pointer;\"><img src=\""+iconPath+"smArrowDown.png\"></span>";
			if(d.Controls!=undefined && d.Controls!="null" && d.Controls!=""){
				edit=edit+"&nbsp&nbsp&nbsp<span class=\"trackSetting"+that.level+"\" name=\""+d.TrackID+"\" style=\"cursor:pointer;\"><img src=\""+iconPath+"gear.png\"></span>";
			}
			edit=edit+"&nbsp&nbsp&nbsp<span class=\"delete"+that.level+"\" name=\""+d.TrackID+"\" style=\"cursor:pointer;\"><img src=\""+iconPath+"delete.png\"></span>";
			
			d3.select(this).append("td").html(edit);
			d3.select("table#trackListTbl"+that.level).selectAll(".trackSetting"+that.level)
				.on("click",function(){
					var trackID=d3.select(this).attr("name");
					if(trackID!=that.selectedTrackSetting){
						that.generateSettingsDiv(that.findTrack(trackID));
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
				.on("mouseover",function(){
					$("#controlInfo"+that.level).html("Click to move the track to the top of the list.");
				})
				.on("mouseout",function(){
					$("#controlInfo"+that.level).html("");
				});
			d3.select("table#trackListTbl"+that.level).selectAll(".moveDown"+that.level)
				.on("mouseover",function(){
					$("#controlInfo"+that.level).html("Click to move the track to the end of the list.");
				})
				.on("mouseout",function(){
					$("#controlInfo"+that.level).html("");
				});
			d3.select("table#trackListTbl"+that.level).selectAll(".delete"+that.level)
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
		/*$("#trackListTbl"+that.level+" tbody").draggable({
											  handle: ".handle"+that.level,
										      connectToSortable: "#trackListTbl"+that.level+" tbody",
										      scroll: true,
										      //helper: "original",
										      revert: "invalid",
											  axis: "y"
										    });*/

		$(".moveUp"+that.level).on("click",function(){
			var trkID=$(this).attr("name");
			$('tr#trk'+trkID).insertBefore($("table#trackListTbl"+that.level+" tbody tr:first"));
			that.updateTrackNumber("",$('tr#trk'+trkID));
		});
		$(".moveDown"+that.level).on("click",function(){
			var trkID=$(this).attr("name");
			$('tr#trk'+trkID).insertAfter($("table#trackListTbl"+that.level+" tbody tr:last"));
			that.updateTrackNumber("",$('tr#trk'+trkID));
		});
								
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
	that.applyView=function(id){
		var d=that.findSelectedView();
		var settingStr=that.generateSettingsString(d);
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
				var grab="<img src=\""+iconPath+"grab_light.png\" style=\"cursor: move; cursor: -webkit-grab; cursor: -moz-grab; \" class=\"handle"+that.level+"\">    ";
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

	that.getViewData=function(){
		var tmpContext=contextPath +"/"+ pathPrefix;
		if(pathPrefix==""){
			tmpContext="";
		}
		
		d3.json(tmpContext+"getBrowserViews.jsp",function (error,d){
			if(error){
				
			}else{
				that.viewList=d;
				var opt=d3.select("#viewSelect"+that.level).on("change",that.selectChange).selectAll('option').data(d);
				opt.enter().append("option").attr("value",function(d){return d.ViewID;}).text(function(d){
						var ret=d.Name;
						if(d.UserID==0){
							ret=ret+"      (Predefined)";
						}else{
							ret=ret+"     (Custom)";
						}
						ret=ret+"     ("+d.TrackList.length+" tracks)";

						if(d.Organism!="AA"){
							if(d.Organism=="RN"){
								ret=ret+"      (Rat Only)";
							}else if(d.Organism=="MM"){
								ret=ret+"     (Mouse Only)";
							}
						}
						
						return ret;
					});
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

	that.setupControls=function(){
		$(".control"+that.level).on("click",function(){
			var id=$(this).attr("id");
			if(id==("addTrack"+that.level)){
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
						trackMenu[that.level].generateTrackTable();
						var p=$("span#viewsLevel"+that.level).position();
						var left=-380;
						if($(window).width()>=1200){
							left=-1117;
						}
						$(".trackLevel"+that.level).css("top",p.top).css("left",p.left+left);
						var d=that.findSelectedView();
						$(".trackLevel"+that.level+" span#selectedViewName").html(d.Name);
						$(".trackLevel"+that.level).fadeIn("fast");
				}else{
						$(".trackLevel"+that.level).fadeOut("fast");
				}
			}
		});
	};

	that.generateSettingsDiv=function (d){
		d3.select("div#trackSettingContent").select("table").select("tbody").html("");
		if(d.Controls.length>0 && d.Controls!="null"){
			var controls=new String(d.Controls).split(",");
			var table=d3.select("div#trackSettingContent").select("table").select("tbody");
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
						var sel=div.append("select").attr("id",d.TrackClass+"Dense"+that.previewLevel+"Select")
							.attr("name",selClass[1]);
						for(var o=0;o<opts.length;o++){
							var option=opts[o].substr(1).split(":");
							if(option.length==2){
								var tmpOpt=sel.append("option").attr("value",option[1]).text(option[0]);
								if(option[1]==def){
									tmpOpt.attr("selected","selected");
								}
							}
						}
					}else if(params[1].toLowerCase().indexOf("cbx")==0){
						var selClass=params[1].split(":");
						var opts=params[2].split("}");
						
						for(var o=0;o<opts.length;o++){
							var option=opts[o].substr(1).split(":");
							if(option.length==2){
								var sel=div.append("input").attr("type","checkbox").attr("id",option[1]+"CBX"+that.previewLevel)
									.attr("name",selClass[1])
									.style("margin-left","5px");
								div.append("text").text(option[0]);
								//console.log(def+"::"+option[1]);
								if(def.indexOf(option[1])>-1){
									$("#"+option[1]+"CBX"+that.previewLevel).prop('checked',true);
									//sel.attr("checked","checked");
								}
							}
						}
					}
				}
			}
			var buttonDiv=table.append("tr").append("td");
			buttonDiv.append("input").attr("type","button").attr("value","Apply").style("float","right").style("margin-left","5px").on("click",function(){

			});
			buttonDiv.append("input").attr("type","button").attr("value","Cancel").style("float","right").style("margin-left","5px").on("click",function(){
				$('#trackSettingDialog').fadeOut("fast");
			});
		}
	};

	that.getViewData();
	that.setupControls();
	return that;
}

				
				
				
				
				
				

				
				
				
				
				
				
				
				