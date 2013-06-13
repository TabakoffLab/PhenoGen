function showDiv(jspPage){
  /*if($('#imageColumn').attr("class")=="full"){
    $('#indexImage svg').attr("width","660px");
    width=660;
    //$('#imageColumn').removeClass().addClass("wide");
    //$('#descColumn').removeClass().addClass("narrow");
  }*/
  d3.html("web/overview/"+jspPage,function(error,html){
               if(error==null){
                 $('div#indexDescContent').html(html);
                 $('div#indexDesc').show();
               }
               });
  
  
}

function shiftLeft(){
  d3.select("#shift").attr("transform", "translate(-100,20)");
}

function shiftRight(){
  d3.select("#shift").attr("transform", "translate(75,20)");
}

var m = [20, 120, 20, 120],
    w = 660,
    h = 800,
    i = 0,
    root;

var radius = 50;
var charWidth=7.5;

var color = d3.scale.category20();

var tree = d3.layout.tree()
    .size([h, w]);

var diagonal = d3.svg.diagonal()
    .projection(function(d) { return [d.y, d.x]; });

var vis = d3.select("div#indexImage").append("svg:svg")
    .attr("width", w )
    .attr("height", h )
  .append("svg:g")
    .attr("id","shift")
    .attr("transform", "translate(75,20)");

d3.json("top.tree.json", function(json) {
  root = json;
  root.x0 = h / 2;
  root.y0 = 0;

  function toggleAll(d) {
    if (d.children) {
      d.children.forEach(toggleAll);
      toggle(d);
    }
  }

  // Initialize the display to show a few nodes.
  root.children.forEach(toggleAll);
  /*toggle(root.children[1]);
  toggle(root.children[1].children[2]);
  toggle(root.children[9]);
  toggle(root.children[9].children[0]);*/

  update(root);
});

function update(source) {
  var duration = d3.event && d3.event.altKey ? 5000 : 500;

  // Compute the new tree layout.
  var nodes = tree.nodes(root).reverse();

  // Normalize for fixed-depth.
  nodes.forEach(function(d) { d.y = d.depth * 180; });

  // Update the nodes…
  var node = vis.selectAll("g.node")
      .data(nodes, function(d) { return d.id || (d.id = ++i); });

  // Enter any new nodes at the parent's previous position.
  var nodeEnter = node.enter().append("svg:g")
      .attr("class", "node")
      .attr("transform", function(d) { return "translate(" + source.y0 + "," + source.x0 + ")"; })
      .style("cursor","pointer")
      .on("click", function(d) { toggle(d); update(d); if(d.descPage!=undefined){showDiv(d.descPage);}})
      .on("mouseover",function(d){ if(d.descPage!=undefined){showDiv(d.descPage);}});

  nodeEnter.append("svg:circle")
      .attr("r", 50)
      .style("fill", function(d) { return color(d.group); })
      .style("stroke",d3.rgb("#999999"));

  /*nodeEnter.append("svg:text")
      .attr("x", function(d) { return d.children || d._children ? -10 : 10; })
      .attr("dy", ".5em")
      .attr("text-anchor", function(d) { return d.children || d._children ? "end" : "start"; })
      .text(function(d) { return d.name; })
      .style("fill-opacity", 1e-6);*/

  nodeEnter.each( function(d,i){
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

  // Transition nodes to their new position.
  var nodeUpdate = node.transition()
      .duration(duration)
      .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

  nodeUpdate.select("circle")
      .attr("r", 50)
      .style("fill", function(d) { return color(d.group); })
      .style("stroke",d3.rgb("#999999"));

  nodeUpdate.select("text")
      .style("fill-opacity", 1);

  // Transition exiting nodes to the parent's new position.
  var nodeExit = node.exit().transition()
      .duration(duration)
      .attr("transform", function(d) { return "translate(" + source.y + "," + source.x + ")"; })
      .remove();

  nodeExit.select("circle")
      .attr("r", 1e-6);

  nodeExit.select("text")
      .style("fill-opacity", 1e-6);

  

  // Update the links…
  var link = vis.selectAll("path.link")
      .data(tree.links(nodes), function(d) { return d.target.id; });

  // Enter any new links at the parent's previous position.
  link.enter().insert("svg:path", "g")
      .attr("class", "link")
      .attr("d", function(d) {
        var o = {x: source.x0, y: source.y0};
        return diagonal({source: o, target: o});
      })
    .transition()
      .duration(duration)
      .attr("d", diagonal);

  // Transition links to their new position.
  link.transition()
      .duration(duration)
      .attr("d", diagonal);

  // Transition exiting nodes to the parent's new position.
  link.exit().transition()
      .duration(duration)
      .attr("d", function(d) {
        var o = {x: source.x, y: source.y};
        return diagonal({source: o, target: o});
      })
      .remove();

  // Stash the old positions for transition.
  nodes.forEach(function(d) {
    d.x0 = d.x;
    d.y0 = d.y;
  });
}

// Toggle children.
function toggle(d) {
  if (d.children) {
    d._children = d.children;
    d.children = null;
  } else {
    d.children = d._children;
    d._children = null;
  }
}

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

    