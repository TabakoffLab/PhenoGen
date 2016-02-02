<%@ include file="/web/access/include/login_vars.jsp" %>

<%
  extrasList.add("d3.v3.min.js");
  extrasList.add("svg-pan-zoom.3.2.3.min.js");

%>

<%@ include file="/web/common/header_adaptive.jsp" %>

<style>
    
    .node.gene.selected,.node.miRNA.selected {stroke: #008800; stroke-width:4px;}
    .node.gene.up { fill:#ccccff;/*fill: #1F77B4;*/}
    .node.gene.down { fill: #ccccff; /*fill: #2CA02C;*/ }
    .node.miRNA.down { fill: #ffcccc; /*fill: #9467BD;*/ }
    .node.miRNA.up {  fill: #ffcccc; /*fill: #FF7F0E;*/ }
    .node.gene,.node.miRNA{
        stroke: #FFFFFF;
        stroke-width: 0px;
    }

    .link{
        stroke: #000;
        stroke-opacity: .9;
    }

    .link.predicted {

        stroke-dasharray: 0,2 1;
    }
h1{
    color:#000000;
    font-weight: bold;
}

span.control{
		background:#DCDCDC;
		margin-left:2px;
		margin-right:2px;
		height:24px;
		/*padding:2px;*/
		display:inline-block;
		width:35px;
		border-style:solid;
		border-width:1px;
		border-color:#777777;
		-webkit-border-radius: 5px;
		-khtml-border-radius: 5px;
		-moz-border-radius: 5px;
		border-radius: 5px;
	}
	span.control:hover{
		background:#989898;
	}
	span.control.selected{
		border-width:2px;
		border-color:#000000;
	}
</style>
<script>
    var contextRoot="<%=contextRoot%>";
    var pathPrefix="web/GeneCentric/";
    var urlprefix="<%=host+contextRoot%>";
</script>
<H1>Figure ? Vestal, B. et. al. <a href="">link</a></H1>

<div id="controls" style="text-align: center;display:inline-block;">
</div>
<div id="graphicHelp" style="float:right;display:inline-block;">Navigation Hints: Hold mouse over areas of the image for available actions.</div>
<div id="graphic">
    
</div>



<script type="text/javascript" src="vestal.js"></script>
<%@ include file="/web/common/footer.jsp" %>