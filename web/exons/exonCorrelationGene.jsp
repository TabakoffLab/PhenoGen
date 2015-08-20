
<%@ include file="/web/exons/include/exonHeader.jsp"  %>

<%request.setAttribute( "selectedMain", "exonTools" );
	session.setAttribute("myGeneArray",null);
	session.setAttribute("geneListOrganism",null);
	extrasList.add("exonCorrelationTab0.1.js");
	//extrasList.add("progressBar.js");
%>

<%@ include file="/web/common/header.jsp" %>


    
    <div class="leftTitle">Exon-Exon Correlations</div>
    <div style="font-size:14px">
    <div id="wait1"><img src="<%=imagesDir%>wait.gif" alt="Working..." /><BR />Working...It may take up to 3 minutes the first time you run an exon correlation.</div>
    <%@ include file="/web/exons/exonCorrelationForm.jsp" %>
    <p></p>
    <%@ include file="/web/exons/exonCorrelationMain.jsp" %>
    </div>
  	<script>
		document.getElementById("wait1").style.display = 'none';
	</script>
<%@ include file="/web/common/footer.jsp" %>
