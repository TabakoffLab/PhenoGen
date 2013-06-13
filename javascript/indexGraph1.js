
function showDiv(jspPage){
	if($('#imageColumn').attr("class")=="full"){
		$('#indexImage svg').attr("width","660px");
		width=660;
		$('#imageColumn').removeClass().addClass("wide");
		$('#descColumn').removeClass().addClass("narrow");
	}
	d3.html("web/overview/"+jspPage,function(error,html){
							 if(error==null){
								 $('div#indexDescContent').html(html);
								 $('div#indexDesc').show();
							 }
							 });
	
	
}

function hideDiv(){
	$('#imageColumn').removeClass().addClass("full");
	$('#descColumn').removeClass().addClass("none");
	$('#indexImage svg').attr("width","980px");
	width=980;
	$('div#indexDesc').hide();
}

function setXSpacing(newSpace){
	xSpacing=newSpace;
	if(xSpacing<=200){
		xLevel[0]=-radius*1.3;
		xLevel[1]=radius;
		xLevel[2]=xLevel[1]+xSpacing;
	}else{
		xLevel[0]=radius*1.3;
		xLevel[1]=xLevel[0]+xSpacing;
		xLevel[2]=xLevel[1]+xSpacing;
	}
}

function showDetailNodes(d){
	var classStr=d.id;
	 if(displayClassStr!=classStr){
		 yPos=new Array();
		 if(displayClassStr!=""){
			 d3.selectAll("g."+displayClassStr).transition().duration(350).style("opacity",0)
			 	.attr("transform", function(d){
			 		var x=xLevel[d.level];
			 		var y=-300;
			 		var ret="translate("+x+","+y+")";
			    	d.x=x;
			    	d.y=y;
			    	return ret;
			 	});
			 d3.selectAll("line."+displayClassStr).transition().duration(350).style("stroke-width",0)
			 		.attr("x1", function(d) { return graphData.nodes[d.source].x; })
			        .attr("y1", function(d) { return graphData.nodes[d.source].y; })
			        .attr("x2", function(d) { return graphData.nodes[d.target].x; })
			        .attr("y2", function(d) { return graphData.nodes[d.target].y; });
			    
		 
		 }
		 d3.selectAll("g."+classStr).transition().duration(350).style("opacity",1.0)
		 	.attr("transform", function(d){
		    	var x=0;
		    	var y=350;
		    	x=xLevel[d.level];
		    	if( yPos[d.level]==undefined){
					yPos[d.level]=0;
		    	}
		    
			   	yPos[d.level]++;
			    tmp=Math.floor(yPos[d.level]/2);
			    console.log(tmp);
			    tmp=tmp*ySpacing;
			    if(yPos[d.level]%2==1){
			    		tmp=tmp*-1;
			    }
		    	y=middle+tmp;
		    	var ret="translate("+x+","+y+")";
		    	d.x=x;
		    	d.y=y;
		    	return ret;
		    });
		d3.selectAll("line."+classStr).transition().duration(350).style("stroke-width",2.0)
		 		.attr("x1", function(d) { return graphData.nodes[d.source].x; })
		        .attr("y1", function(d) { return graphData.nodes[d.source].y; })
		        .attr("x2", function(d) { return graphData.nodes[d.target].x; })
		        .attr("y2", function(d) { return graphData.nodes[d.target].y; });
		displayClassStr=classStr;
 	}
}


var width = 980,
    height = 800,
	radius = 50;
var charWidth=7.5;
var xSpacing=240;
var ySpacing = 115;
var displayClassStr="";

var xLevel=new Array();
xLevel[0]=radius*1.3;
xLevel[1]=xLevel[0]+xSpacing;
xLevel[2]=xLevel[1]+xSpacing;

var yPos=new Array();

var middle=height/2;

var mouseEnter=NaN;

var graphData;


function wordWrap(d){
var words = d.name.split(' ');
var lines = new Array();
var length = 0;
var width = 2*radius -20;
var height = 2*radius-20;


var word;
do {
	//console.log(length+":"+lines[length])
   word = words.shift();
   var wordStr=new String(word);
   var linesStr=new String(lines[length]);
   if(linesStr == "undefined"){
				lines[length]=word;
	}else{
		if((linesStr.length+wordStr.length+1)*charWidth<width){
					lines[length]=lines[length]+" "+word;
				
		}else{
				lines[length+1]=word;
				length++;
		}
	}
 
  } while (words.length);
  return lines;
} 

var color = d3.scale.category20();



var svg = d3.select("div#indexImage").append("svg")
    .attr("width", width)
    .attr("height", height)
	.style("background-color",d3.rgb("#1F344F"));
	
	
d3.json("top.json", function(error, graph) {
	graphData=graph;
  var link = svg.selectAll(".link")
      .data(graph.links)
    .enter().append("line")
      .attr("class", function(d){
							  var classStr="link";
							  //console.log(d.target);
							  if(d.target>0){
								  //classStr="secondLink";
								  classStr=graph.nodes[d.target].id+" link detail";
							  }
							  return classStr;
							  })
      .style("stroke-width", function(d) { 
									  		var stroke=2;
									  		if(d.target>0){
												stroke=0;
											}
									  return stroke; 
									});

  var node = svg.selectAll(".node")
      .data(graph.nodes)
    .enter().append("g")
    .attr("transform", function(d){
    	var x=0;
    	var y=350;
    	x=xLevel[d.level];
    	if( yPos[d.level]==undefined){
			yPos[d.level]=0;
    	}
    	var tmp=0;
    	if(d.level<2){
    		yPos[d.level]++;
	    	tmp=Math.floor(yPos[d.level]/2);
	    	console.log(tmp);
	    	tmp=tmp*ySpacing;
	    	if(yPos[d.level]%2==1){
	    		tmp=tmp*-1;
	    	}
    	}else{
	    	tmp=-radius-middle-200;
	    }
    	y=middle+tmp;
    	var ret="translate("+x+","+y+")";
    	d.x=x;
    	d.y=y;
    	return ret;
    })
	.style("opacity", function (d){ var op=1;
								  if(d.level>1){
									  op=0;
								  }
								  return op;
								  })
	.style("cursor","pointer")
	.attr("class", function(d,i){
								var classStr="mainFeature";
							if(i==0){
								classStr="centerNode";
							}else if(d.level>1){
									  classStr=d.id+" detail";
							}
							return classStr;
							})
	.on("mouseenter",function(d){
							  mouseEnter=new Date().getTime();
							  })
	.on("mouseexit",function(d){
							 mouseEnter=NaN;
							 })
	.on("mouseover",function(d){
							 var curTime=new Date().getTime();
							 if(mouseEnter!=NaN && (curTime-mouseEnter>40 && d.level==1) ){
									 showDetailNodes(d);
							 }
							 if(d.level==2){
								 if(mouseEnter!=NaN && curTime-mouseEnter>40){
									 if(d3.select(this).style("opacity")==1){
									 	d3.selectAll("circle").style("stroke",d3.rgb("#999999")).style("stroke-width","1px");
										d3.select(this).select("circle").style("stroke",d3.rgb("#FFFF66")).style("stroke-width","4px");
										showDiv(d.descPage);
									 }
								 }
							 }else if(d.level==0 && curTime-mouseEnter>80){
								 hideDiv();
							 }
					})
	.on("click",function(d){
						var classStr=d.id;
						if(d.level==1){
							showDetailNodes(d)
						}else if(d.level==2){
							if(d3.select(this).style("opacity")==1){
								d3.selectAll("circle").style("stroke",d3.rgb("#999999")).style("stroke-width","1px");
								d3.select(this).select("circle").style("stroke",d3.rgb("#FFFF66")).style("stroke-width","4px");
								showDiv(d.descPage);
							}
								 
						}else if(d.level==0){
							hideDiv();
						}
						 });
	  
	  node.append("circle")
      .attr("r",function(d,i) { var r=radius; if(i==0){r=r*1.3;} return r; })
      .style("fill", function(d) { return color(d.group); })
	  .style("stroke",d3.rgb("#999999"));

	  
	  
	  node.each( function(d,i){
						  var txt=d3.select(this).append("text").style("fill",d3.rgb("#FFFFFF"))
									.style("font-size", "14px")
									.attr("x",function(d) { return (radius*-1)+3;})
									.attr("y",0);
						  	var lines2=wordWrap(d);
							txt.append("tspan").text(lines2[0])
									.attr("x",function(d) { var len=new String(lines2[0]).length;
															var x=0;
															x=x-(len*charWidth/2);
															return x;})
									.attr("y",function(d){
													   var y=0;
													   
													   	y=7-((lines2.length-1)*8);
													   
													   return y;
													   });
							for(var i=1;i<lines2.length;i++){
								txt.append("tspan").text(lines2[i])
									.attr("x",function(d) {var len=new String(lines2[i]).length;
															var x=0;
															x=x-(len*charWidth/2);
															return x;})
									.attr("dy",15);
							}
						  });
	  link.each(function(d){
	  		d3.select(this).attr("x1", function(d) { return graph.nodes[d.source].x; })
        .attr("y1", function(d) { return graph.nodes[d.source].y; })
        .attr("x2", function(d) { return graph.nodes[d.target].x; })
        .attr("y2", function(d) { return graph.nodes[d.target].y; })
	  });

});

function redraw(){
	d3.selectAll("g")
    .attr("transform", function(d){
    	var x=xLevel[d.level];
    	var y=d.y;
    	var ret="translate("+x+","+y+")";
    	d.x=x;
    	
    	return ret;
    });
    d3.selectAll("line").each(function(d){
	  		d3.select(this).attr("x1", function(d) { return graphData.nodes[d.source].x; })
        .attr("y1", function(d) { return graphData.nodes[d.source].y; })
        .attr("x2", function(d) { return graphData.nodes[d.target].x; })
        .attr("y2", function(d) { return graphData.nodes[d.target].y; })
	  });
}