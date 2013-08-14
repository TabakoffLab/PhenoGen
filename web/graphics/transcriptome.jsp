<%@ include file="/web/access/include/login_vars.jsp" %>

<%@ include file="/web/common/header_noBorder_noMenu.jsp" %>

<style>
path {
  stroke: #737373;
  stroke-width: 1.5;
 cursor: pointer;
}

text {
  font: 13px sans-serif;
  cursor: pointer;
}

body {
  width: 880px;
  margin: 0 auto;
}
div.testToolTip {   
  position: absolute;           
  text-align: center;
  max-width: 400px;
  min-height:50px;                             
  padding: 2px;             
  font: 12px sans-serif;        
  background: #d3d3d3;   
  border: 0px;      
  border-radius: 8px;           
  pointer-events: none;    
  color:#000000;
  text-align:left;     
}
h1 {
	font-weight:bold; background-color:#DEDEDE; color:#000000; width:100%;
}

</style>
<div style="text-align:center;">
	<H1>Characteristics of Reconstructed Long RNA Genes</H1>
    <a href="genome.jsp">View Genome Coverage</a>
  <div id="graphic" style="text-align:center;"></div>
  <div style=" max-height:400px; overflow:auto;width:100%;">
    <table id="data" style="width:100%;">
      <thead>
        <TR>
          <TH style="width:50%;">Name</TH>
          <TH>Transcripts</TH>
          <TH>Percent</TH>
        </TR>
      </thead>
      <tbody>
      </tbody>
      </table>
  </div>
</div>
  <script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
<script src="http://d3js.org/d3.v3.min.js"></script>
<script>
	$('#wait1').hide();
var selectedDepth=0;
var selectedNode;
var width = 840,
    height = width,
    padding = 5,
    radius = (Math.min(width, height) - 2 * padding)/ 2,
    duration = 1000;

var x = d3.scale.linear().range([0, 2 * Math.PI]);
var y = d3.scale.pow().exponent(1.1).domain([0, 1]).range([0, radius]);

var svg = d3.select("#graphic").append("svg")
    .attr("width", width)
    .attr("height", height)
    .append("g")
    .attr("transform", "translate(" + [radius + padding, radius + padding] + ")");

var tt=d3.select("body").append("div")   
    .attr("class", "testToolTip")               
    .style("opacity", 0);

var partition = d3.layout.partition()
//    .sort(null)
   .value(function(d) { return d.size; });

var arc = d3.svg.arc()
    .startAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, x(d.x))); })
    .endAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, x(d.x + d.dx))); })
    .innerRadius(function(d) { return Math.max(0, y(d.y)); })
    .outerRadius(function(d) { return Math.max(0, y(d.y + d.dy)); });

d3.json("transcriptome.json", function(error, root) {
 var nodes = partition.nodes(root);

  var path = svg.selectAll("path").data(nodes);
      path.enter().append("path")
      .attr("d", arc)
      .attr("fill-rule", "evenodd")
//      .style("fill", function(d) { return color((d.children ? d : d.parent).name); })
      .style("fill", function(d) { return d.color; })
      .on("click", click)
      .on("mouseover",hover)
      .on("mouseout",hideToolTip);

var text = svg.selectAll("text").data(nodes);
  var textEnter = text.enter().append("text")
      .style("fill-opacity", 1)
      .style("fill", "#000")
     .attr("text-anchor", function(d) {
        return x(d.x + d.dx / 2) > Math.PI ? "end" : "start";
      })
      .attr("dy", ".2em")
      .attr("transform", function(d) {
        var multiline = (d.name || "").split(" ").length > 1,
            angle = x(d.x + d.dx / 2) * 180 / Math.PI - 90,
            rotate = d.depth ? angle + (multiline ? -.5 : 0) : 0;
            translate = d.depth ? (y(d.y) + padding) : (y(d.y) + padding) - 35;
        return "rotate(" + rotate + ")translate(" + translate + ")rotate(" + (angle > 90 ? -180 : 0) + ")";
      }).style("opacity",function(d){
        return x(d.dx) > 0.075 || (d.depth>3 && x(d.dx) > 0.025) || (d.depth>4 && x(d.dx) > 0.0125) ? 1:0;
      })
      .on("click", click);
  textEnter.append("tspan")
      .attr("x", 0)
      .text(function(d) { return d.depth<4? d.name.split(" ")[0] : d.name; });
     //.text(function(d) { return x(d.dx) > 0.075 || (d.depth>3 && x(d.dx) > 0.025) || (d.depth>4 && x(d.dx) > 0.0125) ? (d.depth<4? d.name.split(" ")[0] : d.name) : ""; });
  textEnter.append("tspan")
      .attr("x", 0)
      .attr("dy", "1em")
      .text(function(d) { return d.depth<4? d.name.split(" ")[1] || "" : ""; });
      //.text(function(d) { return x(d.dx) > 0.075 || (d.depth>3 && x(d.dx) > 0.025) || (d.depth>4 && x(d.dx) > 0.0125) ? (d.depth<4 ? d.name.split(" ")[1] || "" : "") : ""; });

  function click(d) {
    //console.log("click d:"+d);
    console.log("d:"+d.depth);
    selectedDepth=d.depth;
    selectedNode=d;
     $("table#data tbody tr").hide();
     //console.log("show :"+"table#data tbody tr"+tableSelector(d))
     $("table#data tbody tr"+tableSelector(d)).show();

    path.transition()
      .duration(750)
      .attrTween("d", arcTween(d));

    // Somewhat of a hack as we rely on arcTween updating the scales.
    text.transition()
        .duration(duration)
        .attrTween("text-anchor", function(d) {
          return function() {
            return x(d.x + d.dx / 2) > Math.PI ? "end" : "start";
          };
        })
        .attrTween("transform", function(d) {
          var multiline = (d.name || "").split(" ").length > 1;
          return function() {
            var angle = x(d.x + d.dx / 2) * 180 / Math.PI - 90,
                rotate = angle + (multiline ? -.5 : 0),
                translate=(y(d.y) + padding),
                rotate2=(angle > 90 ? -180 : 0);
                if(d.depth==0){rotate=0;rotate2=0;}
                if(d.depth==0){translate=(y(d.y) + padding) - 35;}
            return "rotate(" + rotate + ")translate(" + translate + ")rotate(" + rotate2 + ")";
          };
        })
          .style("opacity",function(e){
              var op=0;
              //console.log(e.name+":"+d.dx+":"+e.dx+"::"+e.dx/d.dx);
              if(selectedDepth==0 && e.dx/d.dx > 0.01){
                op=1;
              }else if(selectedDepth==1 && isParentOf(d, e) && e.dx/d.dx > 0.01 ){
                op=1;
              }
              else if(selectedDepth==2 && isParentOf(d, e) && e.dx/d.dx > 0.005 ){
                op=1;
              }
              else if(selectedDepth>=3 && isParentOf(d, e) && e.dx/d.dx > 0.005 ){
                op=1;
              }else if(selectedDepth>=4 && isParentOf(d, e) && e.dx/d.dx > 0.005){
                op=1;
              }
              return op;
          });

  }

    //Add Table
    var columns = ["name", "trx","trxPerc"];
    var rows = d3.select("table#data tbody").selectAll("tr")
        .data(nodes)
        .enter()
        .append("tr")
        .style("background-color",function(d){
              return d.color;
            })
        .attr("class",tableClass);
    var cells = rows.selectAll("td")
        .data(function(row) {
            return columns.map(function(column) {
                return {column: column, value: row[column]};
            });
        }).enter().append("td")
        .style("padding-left",function(d){
              var pad=0;              
                if(d.value=="polyA+" || d.value=="not PolyA+"){
                  pad=0;
                }else if(d.value=="annotated"||d.value=="un- annotated"){
                  pad=20;
                }else if(d.value=="close match"||d.value=="generic overlap"||d.value=="perfect match"||d.value=="artifact"||d.value=="intergenic"||d.value=="intronic"){
                  pad=40;
                }else if(d.value=="1 isoform"||d.value=="2 isoforms"||d.value=="3+ isoforms"){
                  pad=60;
                }else{
                  pad=80;
                }
             
              return pad+"px";
          })
        .text(function(d) { 
          var val=d.value;
          if(d.column=="trxPerc"){
            val=val+"%";
          }
          return val; 
        });
    d3.select("tr.brain").remove();
});

d3.select(self.frameElement).style("height", height + "px");

function isParentOf(p, c) {
  if (p === c) return true;
  if (p.children) {
    return p.children.some(function(d) {
      return isParentOf(d, c);
    });
  }
  return false;
}

// Interpolate the scales!
function arcTween(d) {
  var xd = d3.interpolate(x.domain(), [d.x, d.x + d.dx]),
      yd = d3.interpolate(y.domain(), [d.y, 1]),
      yr = d3.interpolate(y.range(), [d.y ? 20 : 0, radius]);
  return function(d, i) {
    return i
        ? function(t) { return arc(d); }
        : function(t) { x.domain(xd(t)); y.domain(yd(t)).range(yr(t)); return arc(d); };
  };
}


function hover(d){
  //console.log(d);
  if((selectedNode==undefined || isParentOf(selectedNode,d))&&d.name!="rat genome"){
    var tooltip="";
    if(d.name=="polyA+"||d.name=="not PolyA+"){
      tooltip="Origin of Gene: <B>"+d.name+"</b>";
    }else if(d.name=="annotated"||d.name=="un- annotated"){
      tooltip="Overlap with Annotated Ensembl or RefSeq: <B>"+d.name+"</b>";
    }else if(d.name=="close match"||d.name=="generic overlap"||d.name=="perfect match"){
      tooltip="Type of Overlap: <B>"+d.name+"</b>";
    }else if(d.name=="intronic"||d.name=="artifact"||d.name=="intergenic"){
      tooltip="Location within Annotated Genome: <B>"+d.name+"</b>";
    }else if(d.name=="1 isoform"||d.name=="2 isoforms"||d.name=="3+ isoforms"){
      tooltip="Number of Isoforms Expressed in Rat Brain: <B>"+d.name+"</b>";
    }else{
      tooltip="Maximum Number of Exons Expressed in the Gene: <B>"+d.name+"</b>";
    }
    tooltip=tooltip+"<BR><B>"+d.trxPerc+"%</b>  of "+parentPath(d.parent)+"<BR> # Transcripts: <B>"+d.trx+"</B>";

    tt.html(tooltip)  
      .style("left", (d3.event.pageX + "px") )  
      .style("top", (d3.event.pageY + 20) + "px");
    tt.transition()        
      .duration(200)      
      .style("opacity", .95);
  }

}
function hideToolTip(){
    tt.transition()        
    .duration(200)      
    .style("opacity", 0);
}

function parentPath(node){
  if(node!=undefined &&node.parent!=undefined && node.parent.name!="brain transcriptome"){
    return node.name +" <- "+parentPath(node.parent);
  }else if(node!=undefined && node.parent!=undefined && node.parent.name=="brain transcriptome"){
    return node.name +" <- brain transcriptome";
  }else{
    return " brain transcriptome";
  }
}

function tableClass(node){
  var classStr="";
  if(node.name=="polyA+"){
    classStr="polyA";
  }else if(node.name=="not PolyA+"){
    classStr="nonPolyA";
  }else if(node.name=="un- annotated"){
    classStr="unannotated";
  }else if(node.name=="close match"){
    classStr="close";
  }else if(node.name=="generic overlap"){
    classStr="overlap";
  }else if(node.name=="perfect match"){
    classStr="perfect";
  }else if(node.name=="1 isoform"){
    classStr="iso1";
  }else if(node.name=="2 isoforms"){
    classStr="iso2";
  }else if(node.name=="3+ isoforms"){
    classStr="iso3";
  }else if(node.name=="1 exon"){
    classStr="exon1";
  }else if(node.name=="2 exons"){
    classStr="exon2";
  }else if(node.name=="3 exons"){
    classStr="exon3";
  }else if(node.name=="4 exons"){
    classStr="exon4";
  }else if(node.name=="5+ exons"){
    classStr="exon5";
  }
  else{
    classStr=node.name;
  }
  if(node.parent!=undefined && node.parent.name!="brain transcriptome"){
    classStr=classStr+" "+tableClass(node.parent);
  }
  return classStr;
}
function tableSelector(node){
  var classStr="";
  if(node.name!="brain transcriptome"){
    if(node.name=="polyA+"){
    classStr="polyA";
  }else if(node.name=="not PolyA+"){
    classStr="nonPolyA";
  }else if(node.name=="un- annotated"){
    classStr="unannotated";
  }else if(node.name=="close match"){
    classStr="close";
  }else if(node.name=="generic overlap"){
    classStr="overlap";
  }else if(node.name=="perfect match"){
    classStr="perfect";
  }else if(node.name=="1 isoform"){
    classStr="iso1";
  }else if(node.name=="2 isoforms"){
    classStr="iso2";
  }else if(node.name=="3+ isoforms"){
    classStr="iso3";
  }else if(node.name=="1 exon"){
    classStr="exon1";
  }else if(node.name=="2 exons"){
    classStr="exon2";
  }else if(node.name=="3 exons"){
    classStr="exon3";
  }else if(node.name=="4 exons"){
    classStr="exon4";
  }else if(node.name=="5+ exons"){
    classStr="exon5";
  }else{
      classStr=node.name;
    }
    if(node.parent!=undefined && node.parent.name!="brain transcriptome"){
      classStr="."+classStr+tableSelector(node.parent);
    }else{
      classStr="."+classStr;
    }
  }else{
    classStr="";
  }
  return classStr;
}
</script>
<%@ include file="/web/common/footer.jsp" %>