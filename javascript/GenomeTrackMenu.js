/*
*	D3js/Jquery based Track Menu for the Genome Data Browser
*
* 	Author: Spencer Mahaffey
*	for http://phenogen.ucdenver.edu
*	Tabakoff Lab
* 	University of Colorado Denver AMC
* 	Department of Pharmaceutical Sciences Skaggs School of Pharmacy & Pharmaceutical Sciences
*
*	In conjunction with trackMenu.jsp builds the Track Menu for the Genome/Transcriptome Data Browser
*/

var trackDataTable;
var trackMenu=[];


function TrackMenu(level){
	var that={};
	that.level=level;
	that.trackList=[];
	that.previewLevel=101;
	that.previewSVG=NaN;
	that.dataInitialized=0;

	that.generateTrackTable=function(){
		var filter=$("select#trackTypeSelect"+that.level).val();
		var btData=[];
		var count=0;
		console.log("generateTrackTable");
		console.log(that.trackList);
		for(var j=0;j<that.trackList.length;j++){
			if(	filter=="all" ||
				(filter=="allpublic" && that.trackList[j].UserID==0) ||
				(filter=="custom" && that.trackList[j].UserID!=0) ||
				(filter=="genome" && that.trackList[j].GenericCategory=="Genome") ||
				(filter=="trxome" && that.trackList[j].GenericCategory=="Transcriptome")
				){
				if($("table#trackListTbl"+that.level+" tr#trk"+that.trackList[j].TrackID).length==0){
					btData[count]=that.trackList[j];
					count++;
				}
			}
		}
		if($.fn.DataTable.isDataTable( 'table#trkSelList'+that.level )){
			trackDataTable.destroy();
		}
		d3.select("table#trkSelList"+that.level).select("tbody").selectAll('tr').remove();
		var tracktbl=d3.select("table#trkSelList"+that.level).select("tbody").selectAll('tr').data(btData)
				.enter().append("tr")
				.attr("id",function(d){return "trk"+d.TrackID;});
		tracktbl.each(function(d,i){
				var info="  <span class=\"trlisttooltip"+that.level+"\" title= \""+d.Description+"\"><img src=\""+iconPath+"info.gif\"></span>";
				d3.select(this).append("td").html(d.Name+info);
				var org=""
				if(d.Organism=="RN"){
					org="Rat";
				}else if(d.Organism=="MM"){
					org="Mouse";
				}
				var avail="Public";
				if(d.UserID!=0){
					avail="Custom";
				}
				d3.select(this).append("td").html(org);
				d3.select(this).append("td").html(d.GenericCategory);
				d3.select(this).append("td").html(d.Category);
				d3.select(this).append("td").html(avail);
		});
		
		//$('table#trkSelList'+that.level).dataTable().destroy();
		if(!$.fn.DataTable.isDataTable( 'table#trkSelList'+that.level )){
			trackDataTable=$('table#trkSelList'+that.level).DataTable({
				"bPaginate": false,
				/*"bProcessing": true,
				"bStateSave": false,
				"bAutoWidth": true,
				"bDeferRender": true,*/
				"sScrollY": "750px" ,
				"sDom": '<"rightSearch"fr><t>'
			});
		}
		$("td#selectedTrack"+that.level).hide();

		$('table#trkSelList'+that.level+' tbody').on( 'click', 'tr', function () {
	        if (! $(this).hasClass('selected') ) {
	            $('table#trkSelList'+that.level+' tbody tr.selected').removeClass('selected');
	            $(this).addClass('selected');
	            var id=$(this).attr("id");
	            var d=that.findSelectedTrack();
	            var data="Selected Track Name: "+d.Name+"  <span class=\"trInfotooltip"+that.level+"\" title= \""+d.Description+"\"><img src=\""+iconPath+"info.gif\"></span>";
	            $("div#trackHeaderOuter"+that.level+" #trackHeaderContent").html(data);
	            var tblHeight=that.getTrackTableHeight(btData);
	            //trackDataTable.settings().sScrollY =  tblHeight;
	            trackDataTable.settings()[0].oScroll.sy=tblHeight;
				trackDataTable.draw();
				$('#trkSelList'+that.level+'_wrapper div.dataTables_scroll div.dataTables_scrollBody').css('height', tblHeight);
	            $("td#selectedTrack"+that.level).show();
	            $(".trInfotooltip"+that.level).tooltipster({
						position: 'top-right',
						maxWidth: 250,
						offsetX: 10,
						offsetY: 5,
						contentAsHTML:true,
						interactive: true,
						interactiveTolerance: 350
					});
	            //that.generateSettingsDiv(d);
	           	that.generatePreview(d);
	           	var track=that.previewSVG.getTrack(d.TrackClass);
				track.generateSettingsDiv("td#selectedTrack"+that.level);
				$("td#selectedTrack"+that.level+" #trackListTbl"+that.level+" tbody tr:first").remove();
				$("td#selectedTrack"+that.level+" #trackListTbl"+that.level+" tbody tr:last").remove();
	        }
    	} );

		//$('table#trkSelList'+that.level).dataTable().draw();					
		$(".trlisttooltip"+that.level).tooltipster({
			position: 'top-right',
			maxWidth: 250,
			offsetX: 10,
			offsetY: 5,
			contentAsHTML:true,
			interactive: true,
			interactiveTolerance: 350
		});
	};

	that.getTrackTableHeight=function (btData){
		var ret="300px";
		if(btData.length<10){
			ret=(30*btData.length)+"px";
		}
		return ret;
	};

	that.getTrackData=function(){
		var tmpContext=contextPath +"/"+ pathPrefix;
		if(pathPrefix==""){
			tmpContext="";
		}
		d3.json(tmpContext+"getBrowserTracks.jsp",function (error,d){
			if(error){
				
			}else{
				that.trackList=d;
				if(that.level==0){
					trackInfo=[];
					for(var i=0;i<that.trackList.length;i++){
						trackInfo[that.trackList[i].TrackClass]=that.trackList[i];
					}
				}
				that.dataInitialized=1;
				that.generateTrackTable();

			}
		});
	};


	that.findSelectedTrack=function (){
		var id=$('table#trkSelList'+that.level+' tbody tr.selected').attr("id");
		id=new String(id).substr(3);
		var d=NaN;
		for(var i=0;i<that.trackList.length&&isNaN(d);i++){
			if(that.trackList[i].TrackID==id){
				d=that.trackList[i];
			}
		}
		return d;
	};

	that.generateSettingsString=function(d){
		var ret="";
		ret=d.TrackClass+","+d.Settings+";";
		return ret;
	};

	that.generatePreview=function(d){
		$("div#trackPreviewOuter"+that.level+" div#trackPreviewContent").html("");
		var tmpOrg=new String(organism).toUpperCase();
		if(d.Organism=="AA"||d.Organism==tmpOrg){
			var min=svgList[that.level].xScale.domain()[0];
			var max=svgList[that.level].xScale.domain()[1];
			that.previewSVG=toolTipSVG("div#trackPreviewOuter"+that.level+" div#trackPreviewContent",565,min,max,that.previewLevel,chr,svgList[that.level].type);
			that.previewSVG.folderName=svgList[that.level].folderName;
			var trackString=that.generateSettingsString(d);
			loadStateFromString(trackString,"",that.previewLevel,that.previewSVG);
			that.previewSVG.updateData();
			that.previewSVG.updateFullData();
			$("div#trackPreviewContent div#ScrollLevel"+that.previewLevel).css("max-height","250px").css("overflow","auto");
		}else{
			$("div#previewOuter"+that.level+" div#previewContent").html("No Preview Available: The current organism doesn't match the tracks included in this view.");
		}
		
	};

	that.setupControls=function(){
		$("#trackTypeSelect"+that.level).on("change",function(){
			that.generateTrackTable();
		});
	};

	that.removeTrack=function(track){
		that.generateTrackTable();
	};


	/*that.generateSettingsDiv=function (d){
		d3.select("td#selectedTrack"+that.level).select("table#trackListTbl"+that.level).select("tbody").html("");
		if(d.Controls.length>0 && d.Controls!="null"){
			var controls=new String(d.Controls).split(",");
			var table=d3.select("td#selectedTrack"+that.level).select("table#trackListTbl"+that.level).select("tbody");
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
		}
	};*/
	that.getTrackData();
	that.setupControls();
	return that;
}

				
				
				
				
				
				

				
				
				
				
				
				
				
				