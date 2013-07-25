function regionReport(){
	d3.select('#collaspableReport').selectAll('div').remove();
	var tmptrackList=svgList[0].trackList;
	console.log("region Report");
	console.log(svgList[0]);
	console.log(svgList[0].trackCount);
	console.log(svgList[0].trackList);
	for(var l=0;l<tmptrackList.length;l++){
		data=tmptrackList[l].getData();
		console.log(data);
		d3.select('#collaspableReport').append("div").html(tmptrackList[l].label+":"+data[0].length+"<BR>");
	}
}
