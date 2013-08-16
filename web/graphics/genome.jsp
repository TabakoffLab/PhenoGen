<%@ include file="/web/access/include/login_vars.jsp" %>

<%
  extrasList.add("d3.v3.min.js");
%>


<%@ include file="/web/common/header_adaptive.jsp" %>



<style>
path {
  stroke: #737373;
  stroke-width: 1.5;
 cursor: pointer;
}

text {
  font: 15px sans-serif;
  cursor: pointer;
}


div.testToolTip {   
  position: absolute;           
  text-align: center;
  min-width: 250px;
  max-width: 500px;
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
.trigger{
        cursor: pointer;
        /* needed for IE?  Don't think so */
  /* cursor: hand; */
  background: url(<%=imagesDir%>icons/add.png) center left no-repeat; 
  padding: 0 10px 0 20px;
}

.less{
  background: url(<%=imagesDir%>icons/min.png) center left no-repeat; 
}
  #graphic{
    display: inline-block;
    text-align: center;
    width: 74%;
  }
  #table{
    display: inline-block;
    width: 25%;
    height: 850px;
    overflow:auto;
  }
  
  @media screen and (max-width:1140px){
    #graphic{
      width:100%;
    }
    #table{
      width: 100%;
      max-height: 400px;
    }
  }
  @media screen and (max-width:840px){
    #graphic{
      width: 100%;
      overflow: auto;
    }
    #table{
      width: 100%;
      max-height: 400px;
    }
  }

</style>
<div>
    <div style="text-align:center;">
    <H1>Characteristics of Genome Coverage</H1>
    <a href="transcriptome.jsp">View Reconstructed Long RNA Genes(Rat Brain Transcriptome)</a>
    </div>
    <div id="graphic"></div>

    <div id="table" >
            <table id="data" style="width:100%;">
              <thead>
                <TR>
                  <TH style="width:50%;">Name</TH>
                  <TH>Coverage (bp)</TH>
                  <TH>Coverage (Percent)</TH>
                </TR>
              </thead>
              <tbody>
              </tbody>
              </table>
    </div>
</div>



<script>
	$('#wait1').hide();
	var halfExtraWinWidth=0;
	if($(window).width()>1000){
		halfExtraWinWidth=($(window).width()-1000)/2;
	}
var selectedDepth=0;
var selectedNode;
var displayedLevel="d1";
var width = 840,
    height = width,
    padding = 5,
    radius = (Math.min(width, height) - 2 * padding)/ 2,
    duration = 1000;

var x = d3.scale.linear().range([0, 2 * Math.PI]);
var y = d3.scale.pow().exponent(1.3).domain([0, 1]).range([0, radius]);

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

d3.json("genomeNC.json", function(error, root) {
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
        return x(d.dx) > 0.035  ? 1:0;
      })
      .on("click", click);
  textEnter.append("tspan")
      .attr("x", 0)
    .text(function(d) { return d.depth<3 ? d.name.split(" ")[0] : d.name ; });
  textEnter.append("tspan")
      .attr("x", 0)
      .attr("dy", "1em")
     .text(function(d) { return d.depth<3 ? d.name.split(" ")[1] || "" : ""; });

  function click(d) {
    //console.log("click d:"+d);
    console.log("d:"+d.depth);
    selectedDepth=d.depth;
    selectedNode=d;
     
    filterRows(tableSelector(d),selectedDepth);

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
              if(selectedDepth==0 && e.dx/d.dx > 0.00625){
                op=1;
              }else if(selectedDepth==1 && isParentOf(d, e) && e.dx/d.dx > 0.00625 ){
                op=1;
              }
              else if(selectedDepth==2 && isParentOf(d, e) && e.dx/d.dx > 0.00625 ){
                op=1;
              }
              else if(selectedDepth>=3 && isParentOf(d, e)){
                op=1;
              }
              return op;
          });

  }

    //Add Table
    var columns = ["name", "coverBp","coverBpPerc"];
    var rows = d3.select("table#data tbody").selectAll("tr")
        .data(nodes)
        .enter()
        .append("tr")
        .style("background-color",function(d){
              return d.color;
            })
        .attr("class",function(d){return tableClass(d)+" d"+d.depth;});
    var cells = rows.selectAll("td")
        .data(function(row) {
            return columns.map(function(column) {
                return {column: column, value: row[column]};
            });
        }).enter().append("td")
        .style("padding-left",function(d){
              var pad=0;
      			  if(d.column=="name"){              
                      if(d.value=="small" || d.value=="polyA+" || d.value=="not PolyA+"){
                        pad=0;
                      }else if(d.value=="multi"||d.value=="unique alignment"){
                        pad=20;
                      }else if(d.value==">5x coverage"||d.value=="≤5x coverage"){
                        pad=40;
                      }else{
                        pad=60;
                      }
      				}else{
      					pad=10;
      				}
             
              return pad+"px";
          })
        .html(function(d,i) { 
          var val=d.value;
          if(d.column=="coverBp"){
            val=val+" bp";
          }else if(d.column=="coverBpPerc"){
            val=val+"%";
          }else if(d.column=="name"){
            var tmpDepth=4;
            if(d.value=="small" || d.value=="polyA+" || d.value=="not PolyA+"){
              tmpDepth=1;
            }else if(d.value=="multi"||d.value=="unique alignment"){
              tmpDepth=2;
            }else if(d.value==">5x coverage"||d.value=="≤5x coverage"){
              tmpDepth=3;
            }
            if(tmpDepth<4){
              val="<span class=\"trigger\" name=\"d"+(tmpDepth+1)+"\">"+val+"</span>";
            }
          }
          return val; 
        });
    d3.select("tr.rat").remove();
    $(".d4").hide();
    $(".d3").hide();
    $(".d2").hide();
});

d3.select(self.frameElement).style("height", height + "px");

$(document).on("click",".trigger",function(){
    var level=this.getAttribute("name");
    console.log("expandLevel"+level);
    changeDisplayedLevel(level);
});

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
    if(d.name=="small"||d.name=="polyA+"||d.name=="not PolyA+"){
      tooltip="Origin of Read: <B>"+d.name+"</b>";
    }else if(d.name=="multi"||d.name=="unique alignment"){
      tooltip="Alignment of Reads: <B>"+d.name+"</b>";
    }else if(d.name==">5x coverage"||d.name=="≤5x coverage"){
      tooltip="Depth of Coverage(reads): <B>"+d.name+"</b>";
    }else{
      tooltip="Location: <B>"+d.name+"</b>";
    }
    tooltip=tooltip+"<BR><B>"+d.coverBpPerc+"%</b>  of "+parentPath(d.parent)+"<BR> Coverage: <B>"+d.coverBp+" bp</b>";

    tt.html(tooltip)  
      .style("left", (d3.event.pageX- halfExtraWinWidth + "px") )  
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
  if(node!=undefined &&node.parent!=undefined && node.parent.name!="rat genome"){
    return node.name +" <- "+parentPath(node.parent);
  }else if(node!=undefined && node.parent!=undefined && node.parent.name=="rat genome"){
    return node.name +" <- genome";
  }else{
    return " rat genome covered by at least 1 read"
  }
}

function filterRows(selector,selDepth){
  $("table#data tbody tr").hide();
  console.log("filter"+selDepth+"::"+displayedLevel);
  if(selDepth==0){

  }else if(selDepth==1){
      if(displayedLevel!="d2" && displayedLevel!="d3" && displayedLevel!="d4"){
        changeDisplayedLevel("d2");
      }
  }else if(selDepth==2){
      if(displayedLevel!="d3" && displayedLevel!="d4"){
        changeDisplayedLevel("d3");
      }
  }else if(selDepth==3){
      if(displayedLevel!="d4"){
        changeDisplayedLevel("d4");
      }
  }else{
     if(displayedLevel!="d4"){
        changeDisplayedLevel("d4");
     }
  }
  console.log("later:"+selDepth+"::"+displayedLevel);
  /*if(selDepth==0){
      $("table#data tbody tr.d1").show();
  }else*/ 
  if(displayedLevel=="d1"){
      $("table#data tbody tr"+selector+".d1").show();
  }else if(displayedLevel=="d2"){
      $("table#data tbody tr"+selector+".d1").show();
      $("table#data tbody tr"+selector+".d2").show();
  }else if(displayedLevel=="d3"){
      $("table#data tbody tr"+selector+".d1").show();
      $("table#data tbody tr"+selector+".d2").show();
      $("table#data tbody tr"+selector+".d3").show();
  }else if(displayedLevel=="d4"){
      $("table#data tbody tr"+selector+".d1").show();
      $("table#data tbody tr"+selector+".d2").show();
      $("table#data tbody tr"+selector+".d3").show();
      $("table#data tbody tr"+selector+".d4").show();
  }
}

function changeDisplayedLevel(level){
  displayedLevel=level;
    var tblClass=tableSelector(selectedNode);
    if($(tblClass+"."+level).is(":hidden")){
        $(tblClass+"."+level).show();
        if(level=="d1"){
          $("span[name='d1']").addClass("less");
        }else if(level=="d2"){
          $("span[name='d1']").addClass("less");
          $("span[name='d2']").addClass("less");
        }else if(level=="d3"){
          $("span[name='d1']").addClass("less");
          $("span[name='d2']").addClass("less");
          $("span[name='d3']").addClass("less");
        }else if(level=="d4"){
          $("span[name='d1']").addClass("less");
          $("span[name='d2']").addClass("less");
          $("span[name='d3']").addClass("less");
          $("span[name='d4']").addClass("less");
        }
    }else{
        $(tblClass+"."+level).hide();
        $("span[name='"+level+"']").removeClass("less");
        if(level=="d1"){
          $(tblClass+".d2").hide();
          $("span[name='d2']").removeClass("less");
          $(tblClass+".d3").hide();
          $("span[name='d3']").removeClass("less");
          $(tblClass+".d4").hide();
          $("span[name='d4']").removeClass("less");
        }
        if(level=="d2"){
          $(tblClass+".d3").hide();
          $("span[name='d3']").removeClass("less");
          $(tblClass+".d4").hide();
          $("span[name='d4']").removeClass("less");
        }
        if(level=="d3"){
          $(tblClass+".d4").hide();
          $("span[name='d4']").removeClass("less");
        }
    }
}

function tableClass(node){
  var classStr="";
  if(node.name==">5x coverage"){
    classStr="gt5";
  }else if(node.name=="≤5x coverage"){
    classStr="lte5";
  }else if(node.name=="extended UTR"){
    classStr="eUTR";
  }else if(node.name=="unique alignment"){
    classStr="unique";
  }else if(node.name=="not PolyA+"){
    classStr="nonPolyA";
  }else if(node.name=="polyA+"){
    classStr="polyA";
  }else{
    classStr=node.name;
  }
  if(node.parent!=undefined && node.parent.name!="rat genome"){
    classStr=classStr+" "+tableClass(node.parent);
  }
  return classStr;
}
function tableSelector(node){
  var classStr="";
  if(node!=undefined){
    if(node.name!="rat genome"){
      if(node.name==">5x coverage"){
        classStr="gt5";
      }else if(node.name=="≤5x coverage"){
        classStr="lte5";
      }else if(node.name=="extended UTR"){
        classStr="eUTR";
      }else if(node.name=="unique alignment"){
        classStr="unique";
      }else if(node.name=="not PolyA+"){
        classStr="nonPolyA";
      }else if(node.name=="polyA+"){
        classStr="polyA";
      }else{
        classStr=node.name;
      }
      if(node.parent!=undefined && node.parent.name!="rat genome"){
        classStr="."+classStr+tableSelector(node.parent);
      }else{
        classStr="."+classStr;
      }
    }else{
      classStr="";
    }
  }
  return classStr;
}
</script>
<%@ include file="/web/common/footer.jsp" %>