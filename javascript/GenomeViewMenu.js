var viewMenu=[];


function ViewMenu(level){
	var that={};
	that.level=level;
	that.viewList=[];

	that.generatePreview=function(d){
		$("div#previewOuter"+that.level+" div#previewContent").html("");
		var min=svgList[that.level].xScale.domain()[0];
		var max=svgList[that.level].xScale.domain()[1];
		var newSvg=toolTipSVG("div#previewOuter"+that.level+" div#previewContent",570,min,max,100,chr,svgList[that.level].type);
		var trackString=that.generateSettingsString(d);
		loadStateFromString(trackString,"",100,newSvg);
		newSvg.updateData();
		newSvg.updateFullData();
	};

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
			var grab="<img src=\""+iconPath+"grab_light.png\" style=\"cursor: move; cursor: -webkit-grab; cursor: -moz-grab; \">";
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
			var edit="<span class=\"moveUp"+that.level+"\" name=\""+d.TrackID+"\" ><img src=\""+iconPath+"smArrowUp.png\"></span>";
			edit=edit+" <span class=\"moveDown"+that.level+"\" name=\""+d.TrackID+"\" ><img src=\""+iconPath+"smArrowDown.png\"></span>";
			edit=edit+" <span class=\"trackSetting"+that.level+"\"><img src=\""+iconPath+"gear.png\"></span>";
			if(bvData.UserID!=0){
				edit=edit+" <span class=\"delete"+that.level+"\" name=\""+d.TrackID+"\" ><img src=\""+iconPath+"delete.png\"></span>";
			}
			d3.select(this).append("td").html(edit);
		});
		
		$("#trackListTbl"+that.level+" tbody").sortable({
									//start: that.updateDraggingInterface,
									stop: that.updateTrackNumber
								}).disableSelection();

		$(".moveUp"+that.level).on("click",function(){
			console.log("mup");
			var trkID=$(this).attr("name");
			$('tr#trk'+trkID).insertBefore($("table#trackListTbl"+that.level+" tbody tr:first"));
			that.updateTrackNumber("",$('tr#trk'+trkID));
		});
		$(".moveDown"+that.level).on("click",function(){
			console.log("mdown");
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

	that.applyView=function(id){
		var d=that.findSelectedView();
		var settingStr=that.generateSettingsString(d);
		svgList[that.level].removeAllTracks();
		loadStateFromString(settingStr,d.imgSettings,that.level,svgList[that.level]); 
		$("div#viewsLevel"+that.level).hide();
	};

	that.updateTrackNumber=function(e, ui) {
		$('td.ind', $("table#trackListTbl"+that.level)).each(function (i) {
				var grab="<img src=\""+iconPath+"grab_light.png\" style=\"cursor: move; cursor: -webkit-grab; cursor: -moz-grab; \">    ";
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
		/*console.log(d);
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
						
						return ret;
					});
			}
		});
	};

	that.selectChange=function(){
					var d=that.findSelectedView();
					$("div#descOuter"+that.level+" div#descContent").html(d.Description);
					that.generateTrackList(d);
					that.generatePreview(d);
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

	that.getViewData();
	return that;
}

				
				
				
				
				
				

				
				
				
				
				
				
				
				