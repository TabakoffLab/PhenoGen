
function trKey(d){
	var key="";
	if(d!=undefined){
		key=d.trackClass;
	}
	return d.trackClass;
}

function DisplayRegionReport(){
	//d3.select('#collaspableReportList').selectAll('li').remove();
	var tmptrackList=svgList[0].trackList;
	var list=d3.select('#collaspableReportList').selectAll('li.report').data(tmptrackList,trKey).html(function(d){
			var data=d.getData();
			return d.label+": "+data[0].length;
	});

	list.enter().append("li")
		.attr("class",function (d){return "report "+d.trackClass;})
		.html(function(d){
			var data=d.getData();
			return d.label+": "+data[0].length;
	})
		.on("click",displayDetailedView);

	list.exit().remove();

	d3.select('#collaspableReportList').selectAll('li.report.selected').forEach(function (d){displayDetailedView(d);});
	//for(var l=0;l<tmptrackList.length;l++){
	//	displayTrackReport(tmptrackList[l]);
	//}
	//displayBQTLReport(loadBQTLs());
	//displayGeneEQTLReport(loadGeneEQTLs());
}


function displayTrackReport(track){
	var data=track.getData();
	console.log(data);
	d3.select('#collaspableReportList').append("li").html(track.label+": "+data[0].length).on("click",displayDetailedView);
}


function displayDetailedView(track){
	$('li.report').removeClass("selected");
	$("li."+track.trackClass).addClass("selected");
	if(track.trackClass=="coding"||track.trackClass=="noncoding"||track.trackClass=="smallnc"){
		$('div#content').html("");
		track.displayBreakDown("div#collaspableReport div#content");
	}
}