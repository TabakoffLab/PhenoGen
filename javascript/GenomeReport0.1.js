
function DisplayRegionReport(){
	d3.select('#collaspableReportList').selectAll('li').remove();
	var tmptrackList=svgList[0].trackList;
	for(var l=0;l<tmptrackList.length;l++){
		displayTrackReport(tmptrackList[l]);
	}
	//displayBQTLReport(loadBQTLs());
	//displayGeneEQTLReport(loadGeneEQTLs());
}


function displayTrackReport(track){
	var data=track.getData();
	console.log(data);
	d3.select('#collaspableReportList').append("li").html(track.label+": "+data[0].length).on("click",displayDetailedView(track));
}


function displayDetailedView(track){
	if(track.trackClass=="coding"||track.trackClass=="noncoding"){
		track.displayBreakDown("div#collaspableReport div#content");
	}
}