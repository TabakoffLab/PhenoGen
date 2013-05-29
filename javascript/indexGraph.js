
function showDiv(jspPage){
	if($('#imageColumn').attr("class")=="full"){
		$('#indexImage svg').attr("width","660px");
		width=660;
		force.size([width, height]);
		force.start();
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
	force.size([width, height]);
	force.start();
	$('div#indexDesc').hide();
}


var width = 980,
    height = 750,
	radius = 50;
var charWidth=7.5;

var mouseEnter=NaN;


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

var force = d3.layout.force()
    .charge(-2800)
    .linkDistance(40)
    .size([width, height]);

var svg = d3.select("div#indexImage").append("svg")
    .attr("width", width)
    .attr("height", height)
	.style("background-color",d3.rgb("#1F344F"));
	
	
d3.json("top.json", function(error, graph) {
  force
      .nodes(graph.nodes)
      .links(graph.links)
      .start();

  var link = svg.selectAll(".link")
      .data(graph.links)
    .enter().append("line")
      .attr("class", function(d){
							  var classStr="link";
							  console.log(d.target.index);
							  if(d.target.index>0){
								  //classStr="secondLink";
								  classStr=graph.nodes[d.target.index].id+" link detail";
							  }
							  return classStr;
							  })
      .style("stroke-width", function(d) { 
									  		var stroke=2;
									  		if(d.target.index>0){
												stroke=0;
											}
									  return stroke; 
									});

  var node = svg.selectAll(".node")
      .data(graph.nodes)
    .enter().append("g")
	.style("opacity", function (d){ var op=1;
								  if(d.level>1){
									  op=0;
								  }
								  return op;
								  })
	.style("cursor","move")
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
							 if(mouseEnter!=NaN && ((curTime-mouseEnter>40 && d.level==1) ||(curTime-mouseEnter>80 && d.level==2))){
									 var classStr=d.id;
									 d3.selectAll("g.detail").transition().duration(350).style("opacity",0);
									 d3.selectAll("line.detail").transition().duration(350).style("stroke-width",0);
									 d3.selectAll("g."+classStr).transition().duration(350).style("opacity",1.0);
									 d3.selectAll("line."+classStr).transition().duration(350).style("stroke-width",2.0);
								 
							 }
							 if(d.level==2){
								 if(mouseEnter!=NaN && curTime-mouseEnter>80){
									 if(d3.select(this).style("opacity")==1){
										showDiv(d.descPage);
									 }
								 }
							 }else if(d.level==0 && curTime-mouseEnter>120){
								 hideDiv();
							 }
					})
	.on("click",function(d){
						var classStr=d.id;
						d3.selectAll("g.detail").transition().duration(350).style("opacity",0);
						d3.selectAll("line.detail").transition().duration(350).style("stroke-width",0);
						d3.selectAll("g."+classStr).transition().duration(350).style("opacity",1.0);
						d3.selectAll("line."+classStr).transition().duration(350).style("stroke-width",2.0);
						if(d.level==2){
							if(d3.select(this).style("opacity")==1){
								showDiv(d.descPage);
							}
								 
						}else if(d.level==0){
							hideDiv();
						}
						 })
	.call(force.drag);
	  
	  node.append("circle")
	  //.attr("class", "node")
      .attr("r",function(d,i) { var r=radius; if(i==0){r=r*1.3;} return r; })
      .style("fill", function(d) { return color(d.group); })
	  .style("stroke",d3.rgb("#999999"));
	  //.call(force.drag);
	  
	  
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




  force.on("tick", function() {
    link.attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });

    node.attr("transform", function(d) { return "translate("+d.x+","+d.y+")"; });
  });
});