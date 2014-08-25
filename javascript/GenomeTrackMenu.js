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
				if(  that.trackList[j].Organism=="AA" || 
					 (that.trackList[j].Organism==organism.toUpperCase())
					){
					if($("table#trackListTbl"+that.level+" tr#trk"+that.trackList[j].TrackID).length==0){
						btData[count]=that.trackList[j];
						count++;
					}
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
				"aaSorting": [[ 3, "asc" ]],
				"sScrollY": "750px" ,
				"sDom": '<"rightSearch"fr><t>'
			});
		}
		trackDataTable.draw();
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
				trackDataTable.columns.adjust().draw();
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

	that.confirmUpload=function(){
		$("div#confirmUpload"+that.level).show();
		$("div#uploadBtn"+that.level).hide();
	};
	
	that.confirmBed=function(){
		$("input#hasconfirmBed"+that.level).val(1);
		that.createCustomTrack(that.level);
	};

	that.cancelUpload=function(){
		$("div#confirmUpload"+that.level).hide();
		$("div#confirmBed"+that.level).hide();
		$("div#uploadBtn"+that.level).show();
	};

	that.createCustomTrack=function (){
		$("div#confirmUpload"+that.level).hide();
		customTrackLevel=that.level;
		var type=$("#usrtrkFileTypeSelect"+that.level).val();
		if(type=="bed"||type=="bg"){
			that.createUploadedCustomTrack();
		}else if(type=="bb"||type=="bw"){
			that.createRemoteCustomTrack();
		}
	};

	that.createUploadedCustomTrack=function(){
		var file = $("input#customUploadFile"+that.level)[0].files[0]; //Files[0] = 1st file
		var fName=file.name;
		var fSize=(file.size/1024.0)/1024.0;
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
				}else if($("input#hasconfirmBed"+that.level).val()==0){
					//display confirmation
					$("div#confirmBed"+customTrackLevel).show();
				}else if($("input#hasconfirmBed"+that.level).val()==1){
					$("div#confirmBed"+customTrackLevel).hide();
					//continue
					that.createTrack(file);
				}
			}else{
				that.createTrack(file);
			}
		}else{
			$("div#uploadBtn"+customTrackLevel).show();
	        $(".progressInd").hide();
			$(".uploadStatus").html("File is too large.  20MB is the current limit.");
		}

	};

	that.createTrack=function(file){
		that.readFile(file);
	};

	that.createRemoteCustomTrack=function(){

	};

	that.saveTrack=function(trackClass){
		//if uid==0 not logged in >0 should save back to DB.
		if(uid>0){
			$.ajax({
				url:  tmpContext+"addTrack.jsp",
   				type: 'GET',
				data: {trackClass: trackClass,trackName: trackName, trackDesc:desc,trackOrg:org,genericCategory:genCat,category:cat,controls:control,location:loc},
				dataType: 'html',
    			success: function(data2){
    				
    			},
    			error: function(xhr, status, error) {
    				
    			},
    			async:   false
			});
		}
		//Save to Cookie if not logged in.
		var trackToAdd="custom"+track+",organism="+organism+",created="+tmp.toDateString()+",dispTrackName="+$("input#usrtrkNameTxt"+customTrackLevel).val()+",originalFile="+$("input#customUploadFile"+customTrackLevel)[0].files[0].name+",";
	    if($("#usrtrkColorSelect"+customTrackLevel).val()=="Score"){
			trackToAdd=trackToAdd+"colorBy=Score,";
			trackToAdd=trackToAdd+"minValue="+$("#usrtrkScoreMinTxt"+customTrackLevel).val()+",";
			trackToAdd=trackToAdd+"maxValue="+$("#usrtrkScoreMaxTxt"+customTrackLevel).val()+",";
			trackToAdd=trackToAdd+"minColor=#"+$("#usrtrkColorMin"+customTrackLevel).val()+",";
			trackToAdd=trackToAdd+"maxColor=#"+$("#usrtrkColorMax"+customTrackLevel).val()+",";
		}else{
			trackToAdd=trackToAdd+"colorBy=Color,";
		}
		//reset some of the inputs
		$("input#customUploadFile"+customTrackLevel).val("");
		$("input#usrtrkNameTxt"+customTrackLevel).val("");
		$("#usrtrkColorSelect"+customTrackLevel).val("color");
		setTimeout(function(){
			$("div#uploadBtn"+customTrackLevel).show();
			$(".progressInd").hide();
			$(".uploadStatus").hide();
			//saveToCookie(customTrackLevel);
			$("div#addUsrTrack"+that.level).hide();
			$("div#selectTrack"+that.level).show();
			
		},15000);
	};


	that.readFile = function (file){
		var reader = new FileReader();
		reader.readAsText(file, 'UTF-8');
		reader.onload = that.sendFile;
	};

	that.sendFile=function (event){
		var result = event.target.result;
		$.ajax({
					url: pathPrefix+"trackUpload.jsp",
	   				type: 'POST',
					contentType: 'text/plain',
					xhr: function() {  // Custom XMLHttpRequest
			            var myXhr = $.ajaxSettings.xhr();
			            //if(myXhr.upload){ // Check if upload property exists
			                myXhr.upload.addEventListener('progress',that.progressHandlingFunction, false); // For handling the progress of the upload
			            //}
			            return myXhr;
			        },
					data: result,
					processData: false,
					cache: false,
					dataType: 'json',
	    			success: function(data2){
	        			$(".uploadStatus").html("Upload Completed Successfully");
	        			//var tmp=new Date();
	        			//add new custom track to Custom Track Cookie
	        			var track=data2.trackFile.substring(0,data2.trackFile.length-4);
	        			that.saveTrack(track);
	    			},
	    			error: function(xhr, status, error) {
	        			console.log(error);
	        			$(".uploadStatus").html("Error:"+error);
	        			$("div#uploadBtn"+customTrackLevel).show();
	    			}
				});
	}

	that.progressHandlingFunction=function(e){
		$(".progressInd").show();
		$(".uploadStatus").html("Uploading...");
	    if(e.lengthComputable){
	        $('progress').attr({value:e.loaded,max:e.total});
	    }
	};

	that.getTrackData();
	return that;
}

				
				
				
				
				
				

				
				
				
				
				
				
				
				