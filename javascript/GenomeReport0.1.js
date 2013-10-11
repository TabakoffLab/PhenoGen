var reportSelectedTrack=null;
var loadedTrackTable=null;
var regionDetailLoaded={};

$(document).on('click','span.triggerRegionTable', function (event){
		var baseName = $(this).attr("name");
        var thisHidden = $("div#" + baseName).is(":hidden");
        //$(this).toggleClass("less");
		//console.log(baseName+":"+thisHidden);
        if (thisHidden) {
			$("div#" + baseName).show();
			$(this).addClass("less");
			var curRptRegion=chr+":"+minCoord+"-"+maxCoord+":"+reportSelectedTrack;
			if( regionDetailLoaded[baseName]  && regionDetailLoaded[selectedTab]==curRptRegion){
				//don't have to load might reset?
			}else{
				//last loaded in a different region need to update.
				if(reportSelectedTrack!=null){
					loadTrackTable();
				}
				regionDetailLoaded[baseName]=curRptRegion;
			}
        } else {
			$("div#" + baseName).hide();
			$(this).removeClass("less");
        }
	});

$(document).on('click','span.detailMenu', function (event){
	var baseName = $(this).attr("name");
    var selectedTab=$('span.detailMenu.selected').attr("name");
    $("div#"+selectedTab).hide();
    $('span.detailMenu.selected').removeClass("selected");
    $("span[name='"+baseName+"']").addClass("selected");
    $("div#"+baseName).show();
    //check if loaded load if not
    var curRptRegion=chr+":"+minCoord+"-"+maxCoord;
    if(baseName=="regionTable"){
		curRptRegion=curRptRegion+":"+reportSelectedTrack;
	}

	if(regionDetailLoaded[baseName] && regionDetailLoaded[baseName]==curRptRegion){
				//don't have to load might reset?
	}else{
		if(baseName=="regionTable" && reportSelectedTrack!=null){
					loadTrackTable();
		}else if(baseName="regionEQTLTable"){
					loadEQTLTable();
		}
		regionDetailLoaded[baseName]=curRptRegion;
	}
});

function loadTrackTable(){
	var jspPage="";
	var params={
			species: organism,
			minCoord: minCoord,
			maxCoord: maxCoord,
			chromosome: chr,
			rnaDatasetID: rnaDatasetID,
			arrayTypeID: arrayTypeID,
			forwardPvalueCutoff:forwardPValueCutoff,
			folderName: folderName
		};
	if(reportSelectedTrack.trackClass=="coding"){
		jspPage="web/GeneCentric/geneTable.jsp";
		params.type="coding";
	}else if(reportSelectedTrack.trackClass=="noncoding"){
		params.type="noncoding";
		jspPage="web/GeneCentric/geneTable.jsp";
	}else if(reportSelectedTrack.trackClass=="smallnc"){
		jspPage="web/GeneCentric/smallGeneTable.jsp";
	}else if(reportSelectedTrack.trackClass=="snp"){
		jspPage="web/GeneCentric/snpTable.jsp";
	}else if(reportSelectedTrack.trackClass=="qtl"){
		jspPage="web/GeneCentric/bqtlTable.jsp";
	}else if(reportSelectedTrack.trackClass=="transcript"){
		jspPage="web/GeneCentric/transcriptTable.jsp";
	}
	loadDivWithPage("div#regionTable",jspPage,params,
		"<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Laoding...</span>");
}

function loadEQTLTable(){
	var jspPage="web/GeneCentric/regionEQTLTable.jsp";
	var params={
			species: organism,
			minCoord: minCoord,
			maxCoord: maxCoord,
			chromosome: chr,
			rnaDatasetID: rnaDatasetID,
			arrayTypeID: arrayTypeID,
			pValueCutoff:pValueCutoff,
			folderName: folderName
		};
	loadDivWithPage("div#regionEQTLTable",jspPage,params,
		"<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Loading...</span>");
}



function loadDivWithPage(divSelector,jspPage,params,loadingHTML){
	$(divSelector).html(loadingHTML);
	$.ajax({
				url: jspPage,
   				type: 'GET',
				data: params,
				dataType: 'html',
    			success: function(data2){ 
        			$(divSelector).html(data2);
    			},
    			error: function(xhr, status, error) {
        			$(divSelector).html("<span style=\"color:#FF0000;\">An error occurred generating this page.  Please try back later.</span>");
    			}
			});
}

function trKey(d){
	var key="";
	if(d!=undefined){
		key=d.trackClass;
	}
	return key;
}

function DisplayRegionReport(){
	if(!$('div#collapsableReport').is(":hidden")){
		//d3.select('#collaspableReportList').selectAll('li').remove();
		var tmptrackList=svgList[0].trackList;
		if(reportSelectedTrack==null){
			reportSelectedTrack=tmptrackList[0];
		}
		var list=d3.select('#collapsableReportList').selectAll('li.report').data(tmptrackList,trKey).html(function(d){
				var label="";
				if(d.getDisplayedData!=undefined){
					var data=d.getDisplayedData();
					label=d.label+": "+data.length;
				}
				return label;
		});

		list.enter().append("li")
			.attr("class",function (d){return "report "+d.trackClass;})
			.html(function(d){
					var label="";
					if(d.getDisplayedData!=undefined){
						var data=d.getDisplayedData();
						label=d.label+": "+data.length;
					}
					return label;
				})
			.on("click",displayDetailedView);

		list.exit().remove();

		if(reportSelectedTrack!=null){
			displayDetailedView(reportSelectedTrack);
			if(d3.select('#collapsableReportList').selectAll('li.report.selected').length==0){
				$("li."+reportSelectedTrack.trackClass).addClass("selected");
			}
			if(!$('div#regionTable').is(":hidden")){
				loadTrackTable();
			}
		}

		//d3.select('#collaspableReportList').selectAll('li.report.selected').forEach(function (d){displayDetailedView(d);});
		//for(var l=0;l<tmptrackList.length;l++){
		//	displayTrackReport(tmptrackList[l]);
		//}
		//displayBQTLReport(loadBQTLs());
		//displayGeneEQTLReport(loadGeneEQTLs());
	}
}


/*function displayTrackReport(track){
	var data=track.getData();
	console.log(data);
	d3.select('#collaspableReportList').append("li").html(track.label+": "+data[0].length).on("click",displayDetailedView);
}*/


function displayDetailedView(track){
	reportSelectedTrack=track;
	$('li.report').removeClass("selected");
	$("li."+track.trackClass).addClass("selected");
	if(track.displayBreakDown!=undefined){
		$('div#trackGraph').html("");
		track.displayBreakDown("div#collapsableReport div#trackGraph");
	}
	if(!$('div#regionTable').is(":hidden")){
			loadTrackTable();
	}
}


function DisplaySelectedDetailReport(jspPage,params){
	loadDivWithPage("div#selectedReport",jspPage,params,
		"<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Laoding...</span>");
}