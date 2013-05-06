<%@ include file="/web/common/session_vars.jsp" %>
<script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
<% 
	
	extrasList.add("jquery.tooltipster.js");
	extrasList.add("jquery.svg.min.js");
	extrasList.add("jquery.svgdom.min.js");
	extrasList.add("SimpleGraph.js");
	extrasList.add("tooltipster.css");
%>

<%@ include file="/web/common/header_noBorder.jsp" %>


<style>
div.testToolTip {   
  position: absolute;           
  text-align: center;           
  width: 320px;                  
  height: 40px;                 
  padding: 2px;             
  font: 12px sans-serif;        
  background: #d3d3d3;   
  border: 0px;      
  border-radius: 8px;           
  pointer-events: none;         
}
.axis path{
	fill:none;
	stroke:black;
	shape-rendering: crispEdges;
}

.tick{
	fill:none;
	stroke: black;
}
</style>

<div class="svgDiv" style="width:100%; text-align:center;">
</div>

<script type="text/javascript">

registerKeyboardHandler = function(callback) {
  var callback = callback;
  d3.select(window).on("keydown", callback);  
};

var yArr=new Array();
var width=990;
var margin=10;
var halfWindowWidth = 0;

var mw=width-margin;
var mh=800;
var data=[];
//vars for manipulation
var downx = Math.NaN;
var downscalex;


if($(window).width()>1000){
	halfWindowWidth=($(window).width()-1000)/2;
}
var y=0;
//var xScale = d3.scale.linear().
//  domain([220933937, 228258506]). // your data minimum and maximum
//  range([10, 985]); // the pixels to map to, e.g., the width of the diagram.

var xScale = d3.scale.linear().
  domain([54000000, 55000000]). // your data minimum and maximum
  range([0, 990]); // the pixels to map to, e.g., the width of the diagram.
  
  var xAxis = d3.svg.axis()
    .scale(xScale)
    .orient("top")
	.ticks(6)
	.tickSize(8)
    .tickPadding(10);
	
var vis=d3.select(".svgDiv");
var scale = vis.append("svg:svg")
    .attr("width", width)
    .attr("height", 60)
	.attr("pointer-events", "all")
    .attr("class", "scale")
	.attr("pointer-events", "all")
	.on("mousedown", mdown);
/*var rectScale=scale.append("rect")
	.attr({
		"x":0,"y":0,
		"width":width,
		"height":60,
		"fill": "white"})
	.attr("pointer-events", "all")
	.on("mousedown", function(d) {
        var p = d3.mouse(vis[0][0]);
        downx = xScale.invert(p[0]);
        downscalex = xScale;
      });*/
var svg = vis.append("svg:svg")
    .attr("width", width)
    .attr("height", 800)
    .attr("class", "track")
	.attr("id","svg1")
	.attr("pointer-events", "all")
    /*.on("mousedown", function(d) {
        var p = d3.mouse(vis[0][1]);
        downx = x.invert(p[0]);
        downscalex = x;
		d3.event.preventDefault();
      	d3.event.stopPropagation();
      })*/;
var tt=d3.select("body").append("div")   
    .attr("class", "testToolTip")               
    .style("opacity", 0);

	
scale.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0,55)")
      .call(xAxis);
	  
d3.select(".x.axis").append("text").text("chr19").attr("x", ((width-(margin*2))/2)).attr("y",-40);

/*var stack = d3.layout.stack()
    .offset("wiggle")
    .values(function(d) { return d.values; });*/
  
	
/*function drawGenes(data){
	data.sort(function(a,b) {return a.start-b.start;});
	var yArr=new Array();
	for(var j=0;j<100;j++){
		yArr[j]=0;
	}
	svg.selectAll("rect")
    .data(data)
  .enter().append("rect")
    .attr("x", function(d) { return xScale(d.start); })
    .attr("y", function(d){
		var tmpY=0;
		var found=false;
		for (var i=0;i<yArr.length&&!found;i++){
			if((yArr[i]+20)<xScale(d.start)){
				found=true;
				tmpY=i*15;
				if(xScale(d.end)>yArr[i]){
					yArr[i]=xScale(d.end);
				}
			}
		}
		return tmpY;
	})
    .attr("height",10)
	.attr("width",function(d) { return xScale(d.end)-xScale(d.start); })
	.attr("title",function (d){return d.Name;})
	.attr("class","tt gene")
	.attr("stroke","black")
	.attr("stroke-width","1")
	//.attr("title",function(d){return d.html;})
	.style("fill",function(d) { var color=d3.rgb("#000000"); if((new String(d.Name)).indexOf("ENS")>-1){color=d3.rgb("#DFC184");}else{color=d3.rgb("#7EB5D6");} return color;})
	.on("mouseover", function(d) { 
			d3.select(this).style("fill","green");
			     
            tt.transition()        
                .duration(200)      
                .style("opacity", .9);      
            tt.html(d.html)  
                .style("left", (d3.event.pageX-halfWindowWidth) + "px")     
                .style("top", (d3.event.pageY - 50) + "px");  
            })
	.on("mouseout", function(d) {  
			d3.select(this).style("fill",function(d) { var color=d3.rgb("#000000"); if((new String(d.Name)).indexOf("ENS")>-1){color=d3.rgb("#DFC184");}else{color=d3.rgb("#7EB5D6");} return color;});
            tt.transition()        
                .duration(1800)      
                .style("opacity", 0);  
        });
}*/
function key(d) {return d.Name};
function calcY(start,end){
	var tmpY=0;
	var found=false;
	for (var i=0;i<yArr.length&&!found;i++){
			if((yArr[i]+20)<xScale(start)){
				found=true;
				tmpY=i*15;
				if(xScale(end)>yArr[i]){
					yArr[i]=xScale(end);
				}
			}
	}
	return tmpY;
}

function drawGenes(){
	data.sort(function(a,b) {return a.start-b.start;});
	for(var j=0;j<100;j++){
		yArr[j]=0;
	}
	var gene=svg.selectAll(".gene")
   			.data(data,key)
  			.enter().append("g")
			.attr("class","gene")
			.attr("transform",function(d){ return "translate("+xScale(d.start)+","+calcY(d.start,d.end)+")";});
			
	
	gene.append("rect")
    	.attr("height",10)
		.attr("width",function(d) { return xScale(d.end)-xScale(d.start); })
		.attr("title",function (d){return d.Name;})
		.attr("stroke","black")
		.attr("stroke-width","1")
		.attr("id",function(d){return d.Name;})
	//.attr("title",function(d){return d.html;})
		.style("fill",function(d) { var color=d3.rgb("#000000"); if((new String(d.Name)).indexOf("ENS")>-1){color=d3.rgb("#DFC184");}else{color=d3.rgb("#7EB5D6");} return color;})
		.on("mousedown", function(d) {
        		var p = d3.mouse(vis[0][1]);
        		downx = x.invert(p[0]);
        		downscalex = x;
      		})
		.on("mouseover", function(d) { 
			d3.select(this).style("fill","green");
			     
            tt.transition()        
                .duration(200)      
                .style("opacity", .9);      
            tt.html(d.html)  
                .style("left", (d3.event.pageX-halfWindowWidth) + "px")     
                .style("top", (d3.event.pageY - 50) + "px");  
            })
		.on("mouseout", function(d) {  
			d3.select(this).style("fill",function(d) { var color=d3.rgb("#000000"); if((new String(d.Name)).indexOf("ENS")>-1){color=d3.rgb("#DFC184");}else{color=d3.rgb("#7EB5D6");} return color;});
            tt.transition()        
                .duration(1800)      
                .style("opacity", 0);  
        });
		
	gene.append("text")
	  .text(function(d){
	  	var dirStr=" ";
		var dirChar=".";
		if(d.strand=="+"){
			dirChar=">";
		}
		else if(d.strand=="-"){
			dirChar="<";
		}
		var gW=xScale(d.end)-xScale(d.start);
		if(gW>8){
			for(var l=0; l*14<gW;l++){
				if(l==0){		
					dirStr=dirChar;
				}else{
					dirStr=dirStr+" "+dirChar;
				}
			}
		}
	  	return dirStr;
	  })
	  .attr("y",10)
	  .attr("x",function(d){return (xScale(d.end)-xScale(d.start))/2;})
      .attr("text-anchor", "middle")
	  .on("mouseover", function(d) { 
			d3.select("rect#"+d.Name).style("fill","green");
			     
            tt.transition()        
                .duration(200)      
                .style("opacity", .9);      
            tt.html(d.html)  
                .style("left", (d3.event.pageX-halfWindowWidth) + "px")     
                .style("top", (d3.event.pageY - 50) + "px");  
            })
		.on("mouseout", function(d) {  
			d3.select("rect#"+d.Name).style("fill",function(d) { var color=d3.rgb("#000000"); if((new String(d.Name)).indexOf("ENS")>-1){color=d3.rgb("#DFC184");}else{color=d3.rgb("#7EB5D6");} return color;});
            tt.transition()        
                .duration(1800)      
                .style("opacity", 0);  
        });
	  	
	 //gene.exit().remove();
	//gene.attr("transform",function(d){ return "translate("+xScale(d.start)+","+calcY(d.start,d.end);}).transition().duration(750);
	
}
/*function redraw(){
    var tx = function(d) { 
      return "translate(" + xScale(d) + ",0)"; 
    };
    stroke = function(d) { 
      return d ? "#ccc" : "#666"; 
    };
    fx = xScale.tickFormat(10);

    // Regenerate x-ticks…
    var gx = svg.selectAll("g.x")
        .data(xScale.ticks(10), String)
        .attr("transform", tx);

    gx.select("text")
        .text(fx);

    var gxe = gx.enter().insert("g", "a")
        .attr("class", "x")
        .attr("transform", tx);

    gxe.append("line")
        .attr("stroke", stroke)
        .attr("y1", 0)
        .attr("y2", 30);

    gxe.append("text")
        .attr("class", "axis")
        .attr("y", 30)
        .attr("dy", "1em")
        .attr("text-anchor", "middle")
        .text(fx)
        .style("cursor", "ew-resize")
        .on("mouseover", function(d) { d3.select(this).style("font-weight", "bold");})
        .on("mouseout",  function(d) { d3.select(this).style("font-weight", "normal");});
        //.on("mousedown.drag",  xaxis_drag())
        //.on("touchstart.drag", xaxis_drag());

    gx.exit().remove();

    
    svg.call(d3.behavior.zoom().x(xScale).on("zoom", redraw()));
    //self.update();    
}

function mousemove(){
	var p = d3.mouse(svg[0][0]),
        t = d3.event.changedTouches;
	if (!isNaN(downx)) {
      d3.select('body').style("cursor", "ew-resize");
      var rupx = xScale.invert(p[0]),
          xaxis1 = xScale.domain()[0],
          xaxis2 = xScale.domain()[1],
          xextent = xaxis2 - xaxis1;
      if (rupx != 0) {
        var changex, new_domain;
        changex = downx / rupx;
        new_domain = [xaxis1, xaxis1 + (xextent * changex)];
        xScale.domain(new_domain);
        redraw();
      }
      d3.event.preventDefault();
      d3.event.stopPropagation();
    };
}

function plot_drag() {
  var self = this;
    d3.select('body').style("cursor", "move");
}*/

function redrawAxis(){
	var tx = function(d) { 
      return "translate(" + xScale(d) + ",0)"; 
    };
    stroke = function(d) { 
      return  "#000000" ; 
    };
    fx = xScale.tickFormat(10);

    // Regenerate x-ticks…
    var gx = scale.selectAll("g.x")
        .data(xScale.ticks(8), String)
        .attr("transform", tx);

    gx.select("text")
        .text(fx);

    var gxe = gx.enter().insert("g", "a")
        .attr("class", "x")
        .attr("transform", tx);

    gxe.append("line")
        .attr("stroke", stroke)
        .attr("y1", 35)
        .attr("y2", 60);

    gxe.append("text")
        .attr("class", "axis")
        .attr("y", 30)
        .attr("dy", "1em")
        .attr("text-anchor", "middle")
        .text(fx)
        .style("cursor", "ew-resize")
        .on("mouseover", function(d) { d3.select(this).style("font-weight", "bold");})
        .on("mouseout",  function(d) { d3.select(this).style("font-weight", "normal");});
        //.on("mousedown.drag",  xaxis_drag())
        //.on("touchstart.drag", xaxis_drag());

    gx.exit().remove();

    
    //scale.call(d3.behavior.zoom().x(xScale).on("zoom", drawGenes()));
	drawGenes();
}

function mmove(){
        if (!isNaN(downx)) {
			
          var p = d3.mouse(vis[0][0]), rupx = p[0];
          if (rupx != 0) {
            xScale.domain([downscalex.domain()[0],  mw * (downx - downscalex.domain()[0]) / rupx + downscalex.domain()[0]]);
          }
          redrawAxis();
        }
}
function mdown() {
        var p = d3.mouse(vis[0][0]);
        downx = xScale.invert(p[0]);
        downscalex = xScale;
}
function mup() {
        downx = Math.NaN;
}

	$('#wait1').hide();
	
	d3.json("web/GeneCentric/tracks/geneTrack.jsp",function (d){
		data=d;
		drawGenes();
	});
	
	d3.select('body')
      .on("mousemove", mmove)
	  .on("mouseup", mup);
	
	/*$(window).load(function () {
        //var svgRoot = document.getElementById("svg1").svg('get');
		var svgRoot=$('#svg1').svg('get');
		$($('.gene').val(),svgRoot.root()).each(function(){
		$(this).tooltipster({
			position: 'top-right',
			maxWidth: 250,
			offsetX: 24,
			offsetY: 5,
			//arrow: false,
			interactive: true,
			interactiveTolerance: 350
		});
		});
	});*/
</script>




<%@ include file="/web/common/footer.jsp" %>





