var width = $(window).width()-25,
    height = $(window).height()-180;

var panZoom=NaN;
var minDim=height;
if(width<height){
	minDim=width;
}
var linkDistance=minDim/8;
var force = d3.layout.force()
    .charge(-340)
    .linkDistance(linkDistance)
    .size([width, height]);

var fullNodeList;
var fullLinkList;
var selectedNode=undefined;
var nodes=[];
var neighbors=[];
var links=[];
var drawLabels=false;
var edgeCutoff=1;




var svg = d3.select("#graphic").append("svg")
    .attr("width", width)
    .attr("height", height)
    .attr("id","svgGraph");

var defs=svg.append("defs");
defs.append("marker")
.attr("id","arrow")
.attr("viewBox","0 -5 10 10")
.attr("refX","18")
.attr("refY","0")
.attr("markerWidth","8")
.attr("markerHeight","8")
.attr("orient","auto")
.attr("markerUnits","userSpaceOnUse")
.append("path").attr("d","M0,-5L10,0L0,5");






var topG=svg.append("g").attr("class","svg-pan-zoom_viewport");


$(window).resize(function (){
	width = $(window).width()-25;
    height = $(window).height()-180;
    minDim=height;
    if(width<height){
		minDim=width;
	}
	svg.attr("width",width).attr("height",height);
	if(width>800){
		force.size([width+50, height]);
	}else{
		force.size([width, height]);
	}
	redrawGraph(false);
});

function drawGraph(drwNodes,drwLinks){

  drwNodes.forEach(function(d, i) {
  		if(typeof d.x ==='undefined' || typeof d.y ==='undefined'){ 
  			d.x = d.y = width / 2;
  		} 
  	});
  force.nodes(drwNodes).links(drwLinks);
  var n=drwNodes.length;
  if(n<40){
    n=40;
  }
  //start force layout and run multiple ticks.
  force.start();
  for (var i = n*3; i > 0; --i) force.tick();

  //setup image
  var link = topG.selectAll(".link")
	 .data(drwLinks);
    link.enter().append("line")
	 .attr("class", function(d){
	 		var cl="link";
	 		if(d.pairType==='predicted'){
	 			cl=cl+" predicted";
	 		}
	 		return cl;
		})
	 .style("stroke-width", function(d) { return d.value/2-3.5; })
	 //.style("stroke",function(d){var color="#00000"; if(d.pairType==='predicted'){color="#BBBBBB"} return color;});
	 .style("stroke","#000000")
	 .attr("marker-end", "url(#arrow)");
    link.exit().remove();



  var gNodes = topG.selectAll(".node")
	 .data(drwNodes)
	 .enter().append("path")
	 .attr("id", function(d){return "node"+d.id;})
	 .attr("class", function(d){
	 		var type=d.type; 
	 		var dir="up"; 
	 		if(typeof selectedNode !=='undefined' && d.id===selectedNode.id){type=type+" selected";} 
	 		if(d.effect<0){dir="down";} 
	 		return "node "+type+" "+dir;
	 	})
	 .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
	 .attr("d", d3.svg.symbol()
	   .size(function(d) { return d.logpval*20; })
	   .type(function(d) { var val="circle"; if(d.type==='gene'){val="triangle-up";} return val; }))
	 .call(force.drag)
	 .on("mouseover",function(d){
	   $("#graphicHelp").html("Double click to zoom in on the node and connected nodes. Hover over to display labels for node and connected nodes.");
	   if(! drawLabels){
		topG.selectAll(".label").remove();
		selectedNeighbors=neighbors[d.id];
		for(var i=0;i<selectedNeighbors.length;i++){
		  curD=d3.select("#node"+selectedNeighbors[i].id).data()[0];
		  tmplbl=topG.append("g").attr("class","label").attr("transform","translate("+(curD.x-25)+","+(curD.y-30)+")");
		  tmplbl.append("rect").attr("rx",3).attr("ry",3).attr("height","20px").attr("width",curD.name.length*8.5+10).attr("fill","#CECECE");
		  tmplbl.append("text").attr("x",5).attr("y",15).text(curD.name);
		}
	   }
	 })
	 .on("mouseout", function(d){
	   $("#graphicHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
	   if(! drawLabels){
		topG.selectAll(".label").remove();
	   }
	 })
	 .on("click", function(d){
	 	if(selectedNode){
	 		topG.select(".node"+selectedNode.id).style("stroke","#FFFFFF").style("stroke-width","0px");
	 	}
	 	selectedNode=d;
		//console.log(d);
		topG.select(".node"+d.id).style("stroke","#008800").style("stroke-width","4px");

	 	var jspPage= contextRoot+"web/GeneCentric/geneReport.jsp";
	 	var params={id:d.ENSID,species:"Mm"};
	 	if(d.ENSID!==""){
	 		selectedID=d.ENSID;
	 		$("#report").html("<span style=\"text-align:center;width:100%;\"><img src=\""+contextRoot+"web/images/ucsc-loading.gif\"><BR>Loading...</span>");
		 	$.ajax({
					url: jspPage,
	   				type: 'GET',
	   				cache: false,
					data: params,
					dataType: 'html',
	    			success: function(data2){ 
	        			$("#report").html(data2);
	    				setTimeout(function(){
	        					$('html, body').animate({
										scrollTop: $( "#report").offset().top
									}, 200);
	        				},300);
	        			
	        			//setTimeout(displayHelpFirstTime,200);
	    			},
	    			error: function(xhr, status, error) {
	        			$(divSelector).html("<span style=\"color:#FF0000;\">An error occurred generating this page.  Please try back later.</span>");
	    			}
				});
	 	}else{
	 		$("#report").html("");
	 	}
	 })
	 .on("dblclick",function(d){
		selectedNode=d;
		//console.log(d);
		curclass=topG.select("#node"+d.id).attr("class") + " selected";
		topG.select(".node"+d.id).attr("class",curclass);
		redrawGraph(false);
	 });
  if(drawLabels){
    gNodes.each(function(d){
	 tmplbl=topG.append("g").attr("class","label").attr("id","nodeLbl"+d.id).attr("transform","translate("+(d.x-25)+","+(d.y-30)+")");
	 tmplbl.append("rect").attr("rx",3).attr("ry",3).attr("height","20px").attr("width",d.name.length*8.5+10).attr("fill","#CECECE");
	 tmplbl.append("text").attr("x",5).attr("y",15).text(d.name);
    });
  }
}

function redrawGraph(reset){
  var nodeList=[];
  var linkList=[];
  force.stop();
  console.log("redraw");
  topG.selectAll(".label").remove();
  topG.selectAll(".node").remove();
  topG.selectAll(".link").remove();
  if(typeof selectedNode === 'object'){
	//nodeList=neighbors[selectedNode.id];
	var nodeLinkHash={};
	console.log(nodeLinkHash);
	for(var i=0;i<neighbors[selectedNode.id].length;i++){
		nodeList.push(neighbors[selectedNode.id][i]);
		nodeLinkHash["node"+neighbors[selectedNode.id][i].id]=1;
	}

	//linkList=links[selectedNode.id];
	for(var i=0;i<links[selectedNode.id].length;i++){
		linkList.push(links[selectedNode.id][i]);
		nodeLinkHash["link"+links[selectedNode.id][i].source.id+"To"+links[selectedNode.id][i].target.id]=1;
	}
	var prevLevelNodes=neighbors[selectedNode.id];
	//run through each level
    	for (var i=1;i<edgeCutoff;i++){
		levelNodes=[];
	 	//add nodes connected to the current level
		for(var j=0;j<prevLevelNodes.length;j++){
	   		var newNodes=neighbors[prevLevelNodes[j].id];
	   		for(var k=0;k<newNodes.length;k++){
				if(nodeLinkHash["node"+newNodes[k].id] !==1){
					levelNodes.push(newNodes[k]);
					nodeLinkHash["node"+newNodes[k].id]=1;
				}
			}
		}
		if(levelNodes.length===0){
			edgeCutoff=i-1;
			//imageBar.select("#edgeCountLbl").html("Edge Count limit: "+edgeCutoff);
		}
		//push level onto list
		nodeList=nodeList.concat(levelNodes);
		//move level to previous level
		prevLevelNodes=levelNodes;

    	}
    	console.log(nodeList);
	//add links for nodes in graph
	for(var m=0;m<nodeList.length;m++){
		var curNode=nodeList[m];
		for(var p=0;p<links[curNode.id].length;p++){
			var link=links[curNode.id][p];
			console.log(nodeLinkHash);
			if(nodeLinkHash["node"+link.source.id] === 1 && nodeLinkHash["node"+link.target.id] === 1){
				console.log("passed:"+"link"+link.source.id+"To"+link.target.id);
				if(nodeLinkHash["link"+link.source.id+"To"+link.target.id]!==1){
					console.log("added");
					nodeLinkHash["link"+link.source.id+"To"+link.target.id]=1;
					linkList.push(link);
				}
		   	}
	   	}
	}
	//console.log("after");
	//console.log(linkList);
	var chkBox = d3.select("#labelsCBX")[0][0];
	checkedDrawLabels=chkBox.checked;
    	if(checkedDrawLabels || edgeCutoff<4){
		drawLabels=true;
    	}else{
		drawLabels=false;
    	}
    	d3.select("#edgeCtl").style("display","inline-block");
  }else{
    linkList=fullLinkList;
    nodeList=fullNodeList;
    var chkBox = d3.select("#labelsCBX")[0][0];
	checkedDrawLabels=chkBox.checked;
    	if(checkedDrawLabels ){
    		drawLabels=true;
    	}else{
		drawLabels=false;
    	}
    	d3.select("#edgeCtl").style("display","none");
  }
  




  if(reset){
  	for(var m=0;m<nodeList.length;m++){
  		nodeList[m].x=m;
  		nodeList[m].y=m;
  	}
  }

  if(typeof selectedNode !=='undefined'){
    linkDist=minDim/(3+edgeCutoff);
  }else{
  	linkDist=minDim/8;
  }
  /*
  linkDist=80;
  if(edgeCutoff===1){
    linkDist=140;
  }else if(edgeCutoff===2){
    linkDist=120;
  }else if(edgeCutoff===3){
    linkDist=100;
  }*/
  force.linkDistance(linkDist);  
  

  drawGraph(nodeList,linkList);
}

function addControls(){
  var imageBar=d3.select("#controls").append("span");//.style("float","left");
  imageBar.append("span").attr("class","saveImage control").style("display","inline-block")
	 .attr("id","saveImage")
	 .style("cursor","pointer")
	 .append("img")//.attr("class","mouseOpt dragzoom")
	 .attr("src",contextRoot+"web/images/icons/savePic_dark.png")
	 .attr("pointer-events","all")
	 .attr("cursor","pointer")
	 .on("click",function(){
		   var content="";
		   content=$("div#graphic").html();
		   var w=$(window).width();
		   //content=content.replace("width=\"100%\"","width=\""+w+"px\"");
		   content="<style>.node.gene.up { fill:#ccccff;} "+
				   ".node.gene.down { fill: #ccccff; }"+
				   ".node.miRNA.down { fill: #ffcccc;  }"+
				   ".node.miRNA.up {  fill: #ffcccc;  }"+
				   ".node.gene,.node.miRNA{ stroke: #FFFFFF;stroke-width: 0px;}"+
				   ".link{ stroke: #000;stroke-opacity: .9;}"+
				   ".link.predicted {stroke-dasharray: 0,2 1;}</style>"+content+"\n";
		   $.ajax({
				url: contextRoot+"web/GeneCentric/saveBrowserImage.jsp",
				type: 'POST',
				contentType: 'text/html',
				data: content,
				processData: false,
				dataType: 'json',
				success: function(data2){ 
					var d=new Date();
					var datePart=(d.getMonth()+1)+"_"+d.getDate()+"_"+d.getFullYear();
					var http="http://";
					if (location.protocol === 'https:') {
							    http="https://";
					}
				 	var url=http+urlprefix+"/tmpData/download/"+data2.imageFile;
				 	var region="vestal";
				 	var filename = region+"_"+datePart+".png";
				 	var xhr = new XMLHttpRequest(); 
				   	xhr.open('GET', url);
				   	xhr.responseType = 'blob';
				   	xhr.send();
				   xhr.onreadystatechange = function(){
					//ready?
					if (xhr.readyState != 4)
					    return false;
					//get status:
					var status = xhr.status;
					//maybe not successful?
					if (status != 200) {
					    return false;
					}
					var a = document.createElement('a');
				   a.href = window.URL.createObjectURL(xhr.response); // xhr.response is a blob
				   a.download = filename; // Set the file name.
				   a.style.display = 'none';
				   document.body.appendChild(a);
				   try{
					a.click();
				   }catch(error){
					//$("#"+id).append("<span style='color:#FF0000;'>Your browser will not save the image directly. Image will open in a popup, in the new window right click to save image.</span>");
					$("#wgcnaMouseHelp").html("<span style='color:#FF0000;'>Your browser will not save the image directly. Image will open in a popup, in the new window right click to save image.</span>");
					window.open(url);
				   } 
				   delete a;
					return true;
				 }
				 },
				 error: function(xhr, status, error) {
					console.log(error);
				 }
			});
	   })
	 .on("mouseover",function(){
	   d3.select(this).attr("src",contextRoot+"web/images/icons/savePic_white.png");
	   $("#graphicHelp").html("Click to download a PNG image of the current view.");
	 })
	 .on("mouseout",function(){
	   d3.select(this).attr("src",contextRoot+"web/images/icons/savePic_dark.png");
	   $("#graphicHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
	 });

    imageBar.append("span").attr("class","reset control").style("display","inline-block")
	 .attr("id","wgcnaresetImage")
	 .style("cursor","pointer")
	 .append("img")//.attr("class","mouseOpt dragzoom")
	 .attr("src",contextRoot+"web/images/icons/reset_dark.png")
	 .attr("pointer-events","all")
	 .attr("cursor","pointer")
	 .on("click",function(){
		panZoom.reset();
	 })
	 .on("mouseover",function(){
	   d3.select(this).attr("src",contextRoot+"web/images/icons/reset_white.png");
	   $("#wgcnaMouseHelp").html("Click to reset image zoom to initial region.");
	 })
	 .on("mouseout",function(){
	   d3.select(this).attr("src",contextRoot+"web/images/icons/reset_dark.png");
	   $("#wgcnaMouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
	 });
    imageBar.append("span").attr("class","zoomIn control")
	 .style({
	   "display":"inline-block",
	   "cursor":"pointer",
	   "position":"relative",
	   "top":"7px"
	 })
	 .attr("id","wgcnazoomInImage")
	 .append("img")
	 .attr({
	   "src":contextRoot+"web/images/icons/magPlus_dark_32.png",
	   "pointer-events":"all",
	   "cursor":"pointer"
	 })
	 .style({
	   "position":"relative",
	   "top":"-5px"
	 })
	 .on("click",function(){
	   panZoom.zoomIn();
	 })
	 .on("mouseover",function(){
	   d3.select(this).attr("src",contextRoot+"web/images/icons/magPlus_light_32.png");
	   $("#graphicHelp").html("Click to zoom in.");
	 })
	 .on("mouseout",function(){
	   d3.select(this).attr("src",contextRoot+"web/images/icons/magPlus_dark_32.png");
	   $("#graphicHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
	 });
    imageBar.append("span").attr("class","zoomOut control")
	 .style({
	   "display":"inline-block",
	   "cursor":"pointer",
	   "position":"relative",
	   "top":"7px"
	 })
	 .attr("id","wgcnazoomOutImage")
	 .append("img")
	 .attr("src",contextRoot+"web/images/icons/magMinus_dark_32.png")
	 .attr("pointer-events","all")
	 .attr("cursor","pointer")
	 .style({
	   "position":"relative",
	   "top":"-5px"
	 })
	 .on("click",function(){
	   panZoom.zoomOut();
	 })
	 .on("mouseover",function(){
	   d3.select(this).attr("src",contextRoot+"web/images/icons/magMinus_light_32.png");
	   $("#graphicHelp").html("Click to zoom out.");
	 })
	 .on("mouseout",function(){
	   d3.select(this).attr("src",contextRoot+"web/images/icons/magMinus_dark_32.png");
	   $("#graphicHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
	 });
	imageBar.append("input").attr("type","checkbox")
				.attr("id","labelsCBX")
				    .style({"margin-left":"12px",
				    	"margin-right":"3px",
				    	"position":"relative",
				    	"top":"-8px"})
				    .on("click",function(){
					   var chkBox = d3.select("#labelsCBX")[0][0];
					   drawLabels=chkBox.checked;
					   redrawGraph(false);
				    });
    imageBar.append("text").style({"position":"relative",
				    	"top":"-8px"}).text("Display Labels");

	 var edgeCtl=imageBar.append("span").attr("id","edgeCtl").style({"display":"none","padding-left":"30px"});

	edgeCtl.append("span").attr("class","edgePlus control")
		 .style({
		   "display":"inline-block",
		   "cursor":"pointer",
		   "position":"relative",
		   "top":"7px",

		 })
		 .attr("id","edgePlusImage")
		 .append("img")
		 .attr("src",contextRoot+"web/images/icons/edge_plus_dark_32.png")
		 .attr("pointer-events","all")
		 .attr("cursor","pointer")
		 .style({
		   "position":"relative",
		   "top":"-5px"
		 })
		 .on("click",function(){
		   	edgeCutoff+=1;
		   	imageBar.select("#edgeCountLbl").html("Edge Count limit: "+edgeCutoff);
			redrawGraph(false);
		 })
		 .on("mouseover",function(){
		   d3.select(this).attr("src",contextRoot+"web/images/icons/edge_plus_light_32.png");
		   $("#graphicHelp").html("Click to add one level of edges out from the selected node.");
		 })
		 .on("mouseout",function(){
		   d3.select(this).attr("src",contextRoot+"web/images/icons/edge_plus_dark_32.png");
		   $("#graphicHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
		 });

	edgeCtl.append("span").attr("class","edgeMinus control")
		 .style({
		   "display":"inline-block",
		   "cursor":"pointer",
		   "position":"relative",
		   "top":"7px"
		 })
		 .attr("id","edgeMinusImage")
		 .append("img")
		 .attr("src",contextRoot+"web/images/icons/edge_minus_dark_32.png")
		 .attr("pointer-events","all")
		 .attr("cursor","pointer")
		 .style({
		   "position":"relative",
		   "top":"-5px"
		 })
		 .on("click",function(){
		   edgeCutoff-=1;
		   if(edgeCutoff<1){
		   	edgeCutoff=1;
		   }
		   imageBar.select("#edgeCountLbl").html("Edge Count limit: "+edgeCutoff);
			redrawGraph(false);
		 })
		 .on("mouseover",function(){
		   d3.select(this).attr("src",contextRoot+"web/images/icons/edge_minus_light_32.png");
		   $("#graphicHelp").html("Click remove the furthest edges from the selected node.");
		 })
		 .on("mouseout",function(){
		   d3.select(this).attr("src",contextRoot+"web/images/icons/edge_minus_dark_32.png");
		   $("#graphicHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
		 });

	edgeCtl.append("span").attr("class","edgeReset control")
		 .style({
		   "display":"inline-block",
		   "cursor":"pointer",
		   "position":"relative",
		   "top":"-1px",

		 })
		 .attr("id","edgeMinusImage")
		 .append("img")
		 .attr("src",contextRoot+"web/images/icons/edge_reset_dark_32.png")
		 .attr("pointer-events","all")
		 .attr("cursor","pointer")
		 .style({
		   "position":"relative",
		   "top":"0px"
		 })
		 .on("click",function(){
		 	force.linkDistance(80);
		 	edgeCutoff=1;
		   	selectedNode=undefined;
		   	drawLabels=false;
			redrawGraph(false);
		 })
		 .on("mouseover",function(){
		   d3.select(this).attr("src",contextRoot+"web/images/icons/edge_reset_light_32.png");
		   $("#graphicHelp").html("Click reset the image back to the initial view.");
		 })
		 .on("mouseout",function(){
		   d3.select(this).attr("src",contextRoot+"web/images/icons/edge_reset_dark_32.png");
		   $("#graphicHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
		 });
	edgeCtl.append("span").attr("id","edgeCountLbl").style({"padding-left":"10px","position":"relative","top":"-8px"}).html("Edge Count limit: "+edgeCutoff);


    
    

    
	 

}

function drawLegend(){
	lgd=svg.append("g").attr("class","legend");
	lgd.append("rect")
		   .attr("class","legend")
		   .attr("x",2)
		   .attr("y",2)
		   .attr("rx",5)
		   .attr("ry",5)
		   .attr("height",150)
		   .attr("width",150)
		   .attr("fill","#FFFFFF")
		   .attr("stroke","#000000");
	lgd.append("text").attr("x",4).attr("y",20).text("Nodes");
	lgd.append("text").attr("x",50).attr("y",80).text("miRNA");
	lgd.append("text").attr("x",50).attr("y",100).text("Gene");
	lgd.append("text").attr("x",50).attr("y",40).text("Up ISS");
	lgd.append("text").attr("x",50).attr("y",60).text("Up ILS");

  /*lgd.append("path")
  		.attr("transform","translate(26,55)")
  		.attr("fill","#ccccff")
	   	.attr("stroke","#ccccff")
  		.attr("d", d3.svg.symbol()
			   		.size(70)
			   		.type("triangle-up")
	   		);*/

    lgd.append("rect")
	   .attr("class","legend")
	   .attr("x",20)
	   .attr("y",30)
	   .attr("height",12)
	   .attr("width",24)
	   .attr("fill","#ffcccc")
	   .attr("stroke","#ffcccc");
  /*lgd.append("rect")
	   .attr("class","legend")
	   .attr("x",80)
	   .attr("y",50)
	   .attr("height",12)
	   .attr("width",12)
	   .attr("fill","#2CA02C")
	   .attr("stroke","#2CA02C");*/

  lgd.append("rect")
	   .attr("class","legend")
	   .attr("x",20)
	   .attr("y",50)
	   .attr("height",12)
           .attr("width",24)
	   .attr("fill","#ccccff")
	   .attr("stroke","#ccccff");

	lgd.append("circle")
           .attr("class","legend")
           .attr("cx",32)
           .attr("cy",76)
           .attr("r",6)
           .attr("fill","#000000")
           .attr("stroke","#000000");


 	lgd.append("path")
                .attr("transform","translate(32,94)")
                .attr("fill","#000000")
                .attr("stroke","#000000")
                .attr("d", d3.svg.symbol()
                                        .size(50)
                                        .type("triangle-up")
                        );

    /*lgd.append("circle")
	   .attr("class","legend")
	   .attr("cx",86)
	   .attr("cy",80)
	   .attr("r",6)
	   .attr("fill","#9467BD")
	   .attr("stroke","#9467BD");*/

	lgd.append("path")
  		.attr("transform","translate(21,117)")
  		.attr("fill","#000000")
	   	.attr("stroke","#000000")
  		.attr("d", d3.svg.symbol()
			   		.size(8)
			   		.type("triangle-up")
	   		);

  	lgd.append("path")
  		.attr("transform","translate(28,116)")
  		.attr("fill","#000000")
	   	.attr("stroke","#000000")
  		.attr("d", d3.svg.symbol()
			   		.size(15)
			   		.type("triangle-up")
	   		);

  	lgd.append("path")
  		.attr("transform","translate(38,115)")
  		.attr("fill","#000000")
	   	.attr("stroke","#000000")
  		.attr("d", d3.svg.symbol()
			   		.size(30)
			   		.type("triangle-up")
	   		);
  	lgd.append("path")
  		.attr("transform","translate(50,114)")
  		.attr("fill","#000000")
	   	.attr("stroke","#000000")
  		.attr("d", d3.svg.symbol()
			   		.size(50)
			   		.type("triangle-up")
	   		);

    /*lgd.append("rect")
	   .attr("class","legend")
	   .attr("x",20)
	   .attr("y",106)
	   .attr("height",3)
	   .attr("width",3)
	   .attr("fill","#000000")
	   .attr("stroke","#0000000");
    lgd.append("rect")
	   .attr("class","legend")
	   .attr("x",25)
	   .attr("y",115)
	   .attr("height",5)
	   .attr("width",5)
	   .attr("fill","#000000")
	   .attr("stroke","#0000000");
    lgd.append("rect")
	   .attr("class","legend")
	   .attr("x",32)
	   .attr("y",112.5)
	   .attr("height",10)
	   .attr("width",10)
	   .attr("fill","#000000")
	   .attr("stroke","#0000000");
    lgd.append("rect")
	   .attr("class","legend")
	   .attr("x",45)
	   .attr("y",110)
	   .attr("height",15)
	   .attr("width",15)
	   .attr("fill","#000000")
	   .attr("stroke","#0000000");*/
    lgd.append("circle")
	   .attr("class","legend")
	   .attr("cx",21.5)
	   .attr("cy",135)
	   .attr("r",1.5)
	   .attr("fill","#000000")
	   .attr("stroke","#000000");
    lgd.append("circle")
	   .attr("class","legend")
	   .attr("cx",27.5)
	   .attr("cy",135)
	   .attr("r",2.5)
	   .attr("fill","#000000")
	   .attr("stroke","#000000");
    lgd.append("circle")
	   .attr("class","legend")
	   .attr("cx",37)
	   .attr("cy",135)
	   .attr("r",5)
	   .attr("fill","#000000")
	   .attr("stroke","#000000");
    lgd.append("circle")
	   .attr("class","legend")
	   .attr("cx",52.5)
	   .attr("cy",135)
	   .attr("r",7.5)
	   .attr("fill","#000000")
	   .attr("stroke","#000000");

  lgd.append("text").attr("x",75).attr("y",130).text("abs(Effect)");

  lgd.append("rect")
	   .attr("class","legend")
	   .attr("x",2)
	   .attr("y",160)
	   .attr("rx",5)
	   .attr("ry",5)
	   .attr("height",150)
	   .attr("width",150)
	   .attr("fill","#FFFFFF")
	   .attr("stroke","#000000");
  lgd.append("text").attr("x",4).attr("y",175).text("Edges");
  lgd.append("line").attr("stroke","#000000").attr("stroke-width","3px").attr("x1",20).attr("y1",190).attr("x2",50).attr("y2",190);
  lgd.append("line").attr("stroke","#000000").attr("class","link predicted").attr("stroke-width","3px").attr("x1",20).attr("y1",210).attr("x2",50).attr("y2",210);
  lgd.append("text").attr("x",60).attr("y",195).text("Validated");
  lgd.append("text").attr("x",60).attr("y",215).text("Predicted");

  lgd.append("line").attr("stroke","#000000").attr("stroke-width","1px").attr("x1",20).attr("y1",240).attr("x2",50).attr("y2",240);
  lgd.append("line").attr("stroke","#000000").attr("stroke-width","2px").attr("x1",20).attr("y1",250).attr("x2",50).attr("y2",250);
  lgd.append("line").attr("stroke","#000000").attr("stroke-width","3px").attr("x1",20).attr("y1",260).attr("x2",50).attr("y2",260);
  lgd.append("line").attr("stroke","#000000").attr("stroke-width","5px").attr("x1",20).attr("y1",270).attr("x2",50).attr("y2",270);
  lgd.append("text").attr("x",60).attr("y",260).text("Meta P-value");
}


d3.json("vestal.json", function(error, graph) {
  fullLinkList=graph.links;
  fullNodeList=graph.nodes;

  var n = graph.nodes.length;
  //construct an ordered list of nodes for pushing into neighbors arrays.
  for(var i=0;i<graph.nodes.length;i++){
    nodes[graph.nodes[i].id]=graph.nodes[i];
  }
  //construct neighbors and link lists
  for(var i=0;i<graph.links.length;i++){
    if(! neighbors[graph.links[i].source]){
	 neighbors[graph.links[i].source]=[nodes[graph.links[i].source]]
    }
    if(! neighbors[graph.links[i].target]){
	 neighbors[graph.links[i].target]=[nodes[graph.links[i].target]]
    }
    neighbors[graph.links[i].source].push(nodes[graph.links[i].target]);
    neighbors[graph.links[i].target].push(nodes[graph.links[i].source]);

    if(! links[graph.links[i].source]){
	 links[graph.links[i].source]=[]
    }
    if(! links[graph.links[i].target]){
	 links[graph.links[i].target]=[]
    }
    links[graph.links[i].source].push(graph.links[i]);
    links[graph.links[i].target].push(graph.links[i]);
  }

  //assign node position in deterministic manner
  //graph.nodes.forEach(function(d, i) { d.x = d.y = width / n * i; });
  //add node and links prior to running force
  //force.nodes(graph.nodes).links(graph.links);

  //start force layout and run multiple ticks.
  //force.start();
  //for (var i = n*1.5; i > 0; --i) force.tick();

  drawGraph(graph.nodes,graph.links);
  addControls();
  drawLegend();
  panZoom=svgPanZoom('#svgGraph',{
								    panEnabled: true
								  , controlIconsEnabled:false
								  , zoomEnabled: true
								  , dblClickZoomEnabled: false
								  , zoomScaleSensitivity: 0.2
								  , minZoom: 0.1
								  , maxZoom: 4
								  , fit: true
								  , center: true
								  
							 });
  
  force.on("tick", function() {
    topG.selectAll(".link").attr("x1", function(d) { return d.source.x; })
	   .attr("y1", function(d) { return d.source.y; })
	   .attr("x2", function(d) { return d.target.x;})
	   .attr("y2", function(d) { return d.target.y; });
    topG.selectAll("path")
	 .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; }).each(function(d){
	   topG.select("#nodeLbl"+d.id).attr("transform","translate("+(d.x-25)+","+(d.y-30)+")")
	 });
  });
});
