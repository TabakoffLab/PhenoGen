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



function TrackMenu(level){
	var that={};
	that.level=level;
	that.trackList=[];
	that.previewLevel=101;
	that.previewSVG=NaN;
	that.dataInitialized=0;

	that.generateTrackTable=function(){
		var filter=$("#trackTypeSelect"+that.level).val();
		var btData=[];
		var count=0;
		for(var j=0;j<that.trackList.length;j++){
			if(	filter==="all" ||
				(filter==="allpublic" && that.trackList[j].UserID===0) ||
				(filter==="custom" && that.trackList[j].UserID!==0) ||
				(filter==="genome" && that.trackList[j].GenericCategory==="Genome") ||
				(filter==="trxome" && that.trackList[j].GenericCategory==="Transcriptome")
				){
				if(  that.trackList[j].Organism.toUpperCase()==="AA" || 
					 (that.trackList[j].Organism.toUpperCase()===organism.toUpperCase())
					){
					if($("table#trackListTbl"+that.level+" tr#trk"+that.trackList[j].TrackID).length===0){
						btData[count]=that.trackList[j];
						count++;
					}
				}
			}
		}
		try{
			if($.fn.DataTable.isDataTable( 'table#trkSelList'+that.level )){
				trackDataTable.destroy();
			}
		}catch(error){
			Bugsense.notify( error, { datatables: "not initialized" } );
		}

		if(filter==="custom"&&btData.length===0){
			$("#noCustomTracks").show();
			if(uid===0){
				$("#notSignedIn1").show();
			}else{
				$("#notSignedIn1").hide();
			}
		}else{
			$("#noCustomTracks").hide();
			$("#notSignedIn1").hide();
		}

		d3.select("table#trkSelList"+that.level).select("tbody").selectAll('tr').remove();
		var tracktbl=d3.select("table#trkSelList"+that.level).select("tbody").selectAll('tr').data(btData)
				.enter().append("tr")
				.attr("id",function(d){return "trk"+d.TrackID;})
				.attr("class",function(d,i){var ret="odd";if(i%2===0){ret="even";} return ret;});
		tracktbl.each(function(d,i){
				var addtl="";
				var local="";
				if(d.Source==="local"){
					local=" (Local)";
				}
				if(d.UserID!==0){
					var setup=new String(d.SetupDate);
					setup=setup.substr(0,setup.indexOf(":",setup.indexOf(":")+1));
					addtl="<BR><BR>File:"+d.OriginalFile+"<BR><BR>Setup Date:"+setup+"<BR><BR>Type:"+d.Type;
					if(d.Source==="local"){
						addtl=addtl+"<BR><BR>Local Track only available on this computer.";
					}
				}
				var info="  <span class=\"trlisttooltip"+that.level+"\" title= \""+d.Description+addtl+"\"><img src=\""+iconPath+"info.gif\"></span>";

				d3.select(this).append("td").html(d.Name+local+info);
				var org="";
				if(d.Organism==="RN"){
					org="Rat";
				}else if(d.Organism==="MM"){
					org="Mouse";
				}
				var avail="Public";
				if(d.UserID!==0){
					avail="Custom";
				}
				d3.select(this).append("td").html(org);
				d3.select(this).append("td").html(d.GenericCategory);
				d3.select(this).append("td").html(d.Category);
				d3.select(this).append("td").html(avail);
		});
		
		//$('table#trkSelList'+that.level).dataTable().destroy();
		if(!$.fn.DataTable.isDataTable( 'table#trkSelList'+that.level )){
			var tmpHeight=that.getInitTrackTableHeight(btData);
			trackDataTable=$('table#trkSelList'+that.level).DataTable({
				"bPaginate": false,
				/*"bProcessing": true,
				"bStateSave": false,
				"bAutoWidth": true,
				"bDeferRender": true,*/
				"aaSorting": [[ 3, "asc" ]],
				"sScrollY": tmpHeight ,
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
                            try{
                                    trackDataTable.columns.adjust().draw();
                            }catch(error){
                                Bugsense.notify( error, { datatables: "error adjusting columns:132" } );
                            }
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
                                if(track && track.generateSettingsDiv){
                                                track.generateSettingsDiv("td#selectedTrack"+that.level);
                                        }
                                        $("td#selectedTrack"+that.level+" #trackListTbl"+that.level+" tbody tr:first").remove();
                                        $("td#selectedTrack"+that.level+" #trackListTbl"+that.level+" tbody tr:last").remove();
                                        if(d.UserID!==0){
                                                $("span#deleteCustomTrack"+that.level).show();
                                        }else{
                                                $("span#deleteCustomTrack"+that.level).hide();
                                        }
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

	that.getInitTrackTableHeight=function (btData){
		var ret="750px";
		if(btData.length===0){
			ret="30px";
		}else if(btData.length<15){
			ret=(30*btData.length)+"px";
		}
		return ret;
	};

	that.getTrackTableHeight=function (btData){
		var ret="300px";
		if(btData.length===0){
			ret="20px";
		}else if(btData.length<10){
			ret=(30*btData.length)+"px";
		}
		return ret;
	};

	that.getTrackData=function(){
		var tmpContext=contextPath +"/"+ pathPrefix;
		if(pathPrefix===""){
			tmpContext="";
		}
		d3.json(tmpContext+"getBrowserTracks.jsp",function (error,d){
			if(error){
				console.log(error);
			}else{
				that.trackList=d;
				if(that.level===0){
					trackInfo=[];
					for(var i=0;i<that.trackList.length;i++){
						trackInfo[that.trackList[i].TrackClass]=that.trackList[i];
					}
				}
				//if(uid==0){//add cookie based tracks
				that.readCookieTracks();
				//}
				that.dataInitialized=1;
				that.generateTrackTable();
				if(trackMenu[that.level] && trackMenu[that.level].readCookieViews){
					trackMenu[that.level].readCookieViews();
					trackMenu[that.level].generateViewList();
				}
			}
		});
	};

	that.readCookieTracks=function(){
		var trackString="";
		if(isLocalStorage() === true){
			var cur=localStorage.getItem("phenogenCustomTracks");
			if(cur){
				trackString=cur;
			}
		}else{
			if($.cookie("phenogenCustomTracks")){
				trackString=$.cookie("phenogenCustomTracks");
			}
		}
		if(trackString && trackString.indexOf("<;>")>-1){
			var trackStrings=trackString.split("<;>");
			for(var j=0;j<trackStrings.length;j++){
				var params=trackStrings[j].split("<->");
				var obj={};
				for(k=0;k<params.length;k++){
					var values=params[k].split("=");
					if(values.length<=2){
						obj[values[0]]=values[1];
					}else if(values.length>2){
						var name=params[k].substr(0,params[k].indexOf("="));
						var value=params[k].substr(params[k].indexOf("=")+1);
						obj[name]=value;
					}
				}
				obj.Source="local";
				if(params.length>3){
					that.trackList.push(obj);
					if(that.level===0){
						trackInfo[obj.TrackClass]=obj;
					}
				}
			}
		}
	};


	that.findSelectedTrack=function (){
		var id=$('table#trkSelList'+that.level+' tbody tr.selected').attr("id");
		id=id.substr(3);
		var d=NaN;
		for(var i=0;i<that.trackList.length&&isNaN(d);i++){
			if(that.trackList[i].TrackID===id){
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
		if(d.Organism==="AA"||d.Organism===tmpOrg){
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

	that.confirmdeleteCustomTrack=function(){
		var d=that.findSelectedTrack();
		$("#deleteUsrTrack"+that.level).show();
		$("#selectTrack"+that.level).hide();
		
		var info="Name: <B>"+d.Name+"</B><BR>Description: <B>"+d.Description+"</B><BR>Original File: <B>"+d.OriginalFile+"</B><BR>Setup Date: <B>"+d.SetupDate+"</b>";
		$("span#customTrackInfo"+that.level).html(info);
	};

	that.cancelDeleteTrack=function(){
		$("#deleteUsrTrack"+that.level).hide();
		$("#selectTrack"+that.level).show();
	};

	that.deleteTrack=function(){
		var d=that.findSelectedTrack();
		if(d.Source==="local"){
			//remove from the cookie
			var toDelete="TrackClass="+d.TrackClass+"<->";
			var trackString="";
			if(isLocalStorage() === true){
				var cur=localStorage.getItem("phenogenCustomTracks");
				if(cur){
					trackString=cur;
				}
			}else{
				if($.cookie("phenogenCustomTracks")){
					trackString=$.cookie("phenogenCustomTracks");
				}
			}
			if(trackString && trackString.indexOf("<;>")>-1){
				var newTrackString="";
				var trackStrings=trackString.split("<;>");
				for(var j=0;j<trackStrings.length;j++){
					//console.log(trackStrings[j]);
					if(trackStrings[j].indexOf(toDelete)===-1){
						newTrackString=newTrackString+trackStrings[j]+"<;>";
					}
				}
				var tmpContext=contextPath +"/"+ pathPrefix;
				if(!pathPrefix){
					tmpContext="";
				}
				$.ajax({
					url:  tmpContext +"removeCustomTrack.jsp",
	   				type: 'GET',
					data: {trackID:d.TrackID},
					dataType: 'json',
	    			success: function(data2){
	    				if(isLocalStorage() === true){
	    					localStorage.setItem("phenogenCustomTracks",newTrackString);
	    				}else{
	    					$.cookie("phenogenCustomTracks",newTrackString);
	    				}
	    			},
	    			error: function(xhr, status, error) {
	    				console.log(error);
	    			},
	    			async:   false
				});
			}
		}else if(d.Source==="db"){
			//remove from the database
			var tmpContext=contextPath +"/"+ pathPrefix;
			if(!pathPrefix){
				tmpContext="";
			}
			$.ajax({
				url:  tmpContext +"deleteTrack.jsp",
   				type: 'GET',
				data: {trackID:d.TrackID},
				dataType: 'json',
    			success: function(data2){
    				//console.log("add track status:"+data2.success);
    				if(data2.success==="true"){
    					$(".uploadStatus").html("<B>Track Setup Successfully</B>");
    				}else{
    					$(".uploadStatus").html("<B>Track Setup Failed</B>");
    				}
    			},
    			error: function(xhr, status, error) {
    				console.log(error);
    			},
    			async:   false
			});
		}
		that.getTrackData();
		$("#deleteUsrTrack"+that.level).hide();
		$("#selectTrack"+that.level).show();
		that.generateTrackTable();
	};

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
		if(type==="bed"||type==="bg"){
			that.createUploadedCustomTrack();
		}else if(type==="bb"||type==="bw"){
			that.createRemoteCustomTrack();
		}
	};

	that.createUploadedCustomTrack=function(){
		var file = $("input#customUploadFile"+that.level)[0].files[0]; //Files[0] = 1st file
		var type=$("#usrtrkFileTypeSelect"+that.level).val();
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
			if(fTrunc!=="" && fTrunc!==fName){
				fExt=fTrunc;
			}
		}
		//check file size and extension
		if(fSize<20){
			if(fExt!==type){
				if(fExt==="gz"||fExt==="tar"||fExt==="zip"||fExt==="exe"||fExt==="bin"){
					//cancel with no support
					setTimeout(function(){
	        				$("div#uploadBtn"+customTrackLevel).show();
	        				$(".progressInd").hide();
	        			},5000);
					$(".uploadStatus").html("Error: Selected File Type is not supported.");
				}else if($("input#hasconfirmBed"+that.level).val()===0){
					//display confirmation
					$("div#confirmBed"+customTrackLevel).show();
				}else if($("input#hasconfirmBed"+that.level).val()===1){
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
		$(".uploadStatus").html("Setting up track...");
		$(".uploadStatus").show();
		var file=$("#customFileURL"+that.level).val();
		var session="";
		var tmp=new Date();
		if($.cookie("JSESSIONID")){
    		session=$.cookie("JSESSIONID");
    		session=session+"_"+tmp.getTime();
    	}
		that.saveTrack(session,file);
	};

	that.saveTrack=function(trackClass,file){
		//console.log("saving track uid:"+uid);
		//if uid==0 not logged in >0 should save back to DB.
		var trackName=$("#usrtrkNameTxt"+that.level).val();
		var desc=$("#usrtrkDescTxt"+that.level).val();
		var org=$("#usrtrkOrgSelect"+that.level).val();
		var genCat=$("#usrtrkGenCatSelect"+that.level).val();
		var cat=$("#usrtrkCatTxt"+that.level).val();
		var control="";
		var loc=file;
		var type=$("#usrtrkFileTypeSelect"+that.level).val();
		var prevFile="";
		if(type==="bed"||type==="bg"){
			prevFile=$("input#customUploadFile"+that.level)[0].files[0].name;
		}
		var colorSel="Color";
		if($("#usrtrkColorSelect"+that.level).length>0){
			colorSel=$("#usrtrkColorSelect"+that.level).val();
		}
		if(colorSel==="Score"){
			var minCol="000000";
			var maxCol="FFFFFF";
			var minVal=1;
			var maxVal=1000;
			if(testIE||testSafari){
				minCol=$("#urstrkColorMin"+that.level).spectrum("get").toHexString();
				maxCol=$("#urstrkColorMax"+that.level).spectrum("get").toHexString();
				minCol=minCol.substr(1);
				maxCol=maxCol.substr(1);
			}else{
				minCol=$("#urstrkColorMin"+that.level).val();
				maxCol=$("#urstrkColorMax"+that.level).val();
				minCol=minCol.substr(1);
				maxCol=maxCol.substr(1);
			}
			minVal=$("#urstrkScoreMinTxt"+that.level).val();
			maxVal=$("#urstrkScoreMaxTxt"+that.level).val();
			
		}
		if(type==="bed"){
			control="Name=View Density;Select:trackSelect:Dense:Select;{Dense:1}{Pack:3}{Full:2};Default=3,Name=Color by;Select:colorSelect::colorSelect;{Feature Defined:Color}{Score based scale:Score};Default="+colorSel+",Name=Scale Range;Txt:tissuecbx;{min:1}{max:1000};Default="+minVal+":"+maxVal+",Name=Color Range;Txt:color;{min:FFFFFF}{max:000000};Default="+minCol+":"+maxCol;
		}else if(type==="bg"){
			control="Name=View Density;Select:trackSelect:Dense:Select;{Dense:1}{Full:2};Default=1,Name=Scale Range;Slider:rangeslider;{min:1-1000}{max:1000-20000};Default=1:5000";
		}else if(type==="bw"){
			control="Name=View Density;Select:trackSelect:Dense:Select;{Dense:1}{Full:2};Default=1,Name=Scale Range;Slider:rangeslider;{min:1-1000}{max:1000-20000};Default=1:5000";
		}else if(type==="bb"){
			control="Name=View Density;Select:trackSelect:Dense:Select;{Dense:1}{Pack:3}{Full:2};Default=3,Name=Color by;Select:colorSelect::colorSelect;{Feature Defined:Color}{Score based scale:Score};Default="+colorSel+",Name=Scale Range;Txt:tissuecbx;{min:1}{max:1000};Default="+minVal+":"+maxVal+",Name=Color Range;Txt:color;{min:FFFFFF}{max:000000};Default="+minCol+":"+maxCol;
		}
		trackClass="custom"+trackClass;
		if(uid>0){
			var tmpContext=contextPath +"/"+ pathPrefix;
			if(!pathPrefix){
				tmpContext="";
			}
			//console.log("saving track to db");
			$.ajax({
				url:  tmpContext +"addTrack.jsp",
   				type: 'GET',
				data: {trackClass: trackClass,trackName: trackName, trackDesc:desc,trackOrg:org,genericCategory:genCat,category:cat,controls:control,location:loc,type:type,file:prevFile},
				dataType: 'json',
    			success: function(data2){
    				//console.log("add track status:"+data2.success);
    				if(data2.success==="true"){
    					$(".uploadStatus").html("<B>Track Setup Successfully</B>");
    				}else{
    					$(".uploadStatus").html("<B>Track Setup Failed</B>");
    				}
    			},
    			error: function(xhr, status, error) {
    				console.log(error);
    			},
    			async:   false
			});
		}else{
			//Save to Cookie if not logged in.
			var tmp=new Date();
			var customTrackStr="TrackID="+trackClass+"<->UserID=-999<->TrackClass="+trackClass+"<->Name="+trackName+"<->Description="+desc+"<->Organism="+org.toUpperCase();
			customTrackStr=customTrackStr+"<->Settings=<->Order=0<->GenericCategory="+genCat+"<->Category="+cat+"<->Controls="+control+"<->SetupDate="+tmp+"<->Type="+type;
			customTrackStr=customTrackStr+"<->OriginalFile="+prevFile;
			customTrackStr=customTrackStr+"<->Location="+loc;

			customTrackStr=customTrackStr+"<;>";
			if(isLocalStorage() === true){
				var cur=localStorage.getItem("phenogenCustomTracks");
				if(cur){
					customTrackStr=cur+customTrackStr;
				}
				localStorage.setItem("phenogenCustomTracks",customTrackStr);
			}else{
				if($.cookie("phenogenCustomTracks")){
					customTrackStr=$.cookie("phenogenCustomTracks")+customTrackStr;
				}
				$.cookie("phenogenCustomTracks",customTrackStr);
			}
			$(".uploadStatus").html("<B>Track Setup Successfully</B>");
		}
		
		//reset some of the inputs
		$("div#finished"+that.level).show();
		$("input#customUploadFile"+that.level).val("");
		$("input#customURL"+that.level).val("");
		$("input#usrtrkNameTxt"+that.level).val("");
		$("#usrtrkDescTxt"+that.level).val("");
		$("input#usrtrkOrgSelect"+that.level).val("Rn");
		$("input#usrtrkGenCatSelect"+that.level).val("Genome");
		$("input#usrtrkCatTxt"+that.level).val("");
		$("#usrtrkColorSelect"+that.level).val("Color");
		$("#customFileURL"+that.level).val("");
		
		that.getTrackData();
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
	        			$(".uploadStatus").html("<B>Upload Completed Successfully</b>");
	        			
	        			//add new custom track to Custom Track Cookie
	        			var track=data2.trackFile;
	        			var file=data2.trackFile;
	        			that.saveTrack(track,file);
	    			},
	    			error: function(xhr, status, error) {
	        			console.log(error);
	        			$(".uploadStatus").html("Error:"+error);
	        			$("div#uploadBtn"+customTrackLevel).show();
	    			}
				});
	};

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

				
				
				
				
				
				

				
				
				
				
				
				
				
				