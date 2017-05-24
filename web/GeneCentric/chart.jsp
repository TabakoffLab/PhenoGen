<%@ include file="/web/common/anon_session_vars.jsp" %>
<%
	extrasList.add("jquery.dataTables.1.10.9.min.js");
	extrasList.add("jquery.cookie.js");
	extrasList.add("spectrum.js");
        extrasList.add("svg-pan-zoom.3.2.3.min.js");
	extrasList.add("d3.v4.8.0.min.js");
	extrasList.add("tabs.css");
	extrasList.add("tsmsselect.css");
	extrasList.add("jquery.fancybox.css");
	extrasList.add("jquery.fancybox-thumbs.css");
	extrasList.add("spectrum.css");
%>
<%@ include file="/web/common/header_adaptive_menu.jsp" %>
<%@ include file="/web/GeneCentric/browserCSS.jsp" %>
<style>
    .axis text {
  font: 10px sans-serif;
}

.axis path,
.axis line {
  fill: none;
  stroke: #000;
  shape-rendering: crispEdges;
}

</style>
<div style="min-height: 750px;">
    <div id="chart" style="padding-bottom: 80px;">
        
    </div>
</div>
<script type="text/javascript">
<%@ include file="/javascript/chart.js" %>
    testChart=chart({"data":"/PhenoGen/tmpData/browserCache/rn6/geneData/ENSRNOG000000000/GeneList.json",
        "selector":"#chart","allowResize":true,"type":"heatmap","width":"100%","displayHerit":true,
    "title":"Gene/Transcript Expression"});
</script>

<%@ include file="/web/common/footer_adaptive.jsp" %>





