<%--
 *  Author: Spencer Mahaffey
 *  Created: December, 2011
 *  Description:  The web page created by this file allows the user to
 *              select data to compute exon to exon correlations to look by eye for alternate splicing.
 *  Todo:
 *  Modification Log:
 *
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %>

<jsp:useBean id="myDataset" class="edu.ucdenver.ccp.PhenoGen.data.Dataset"> </jsp:useBean>
<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<jsp:useBean id="myFH" class="edu.ucdenver.ccp.util.FileHandler"/>

<%
        log.info("in exonCorrelationTab.jsp. user =  "+ user);

        extrasList.add("exonCorrelationTab.js");
        extrasList.add("jquery.dataTables.js");
	extrasList.add("jquery.cookie.js");
	extrasList.add("d3.v3.min.js");
        extrasList.add("spectrum.js");
	extrasList.add("tabs.css");
	extrasList.add("tooltipster.min.css");
        extrasList.add("spectrum.css");
        optionsList.add("geneListDetails");
        optionsList.add("chooseNewGeneList");
	request.setAttribute( "selectedTabId", "exonCorrelationTab" );
        mySessionHandler.createGeneListActivity("Looked at exon Correlation Values for a gene", pool);
%>

<%@ include file="/web/common/header_adaptive_menu.jsp" %>

    <!--<script language="JAVASCRIPT" type="text/javascript"><%
                String program = "exonCor";
                int duration = 120;
                        %>durationArray[0] = new durationRow('<%=program%>', <%=duration%>);
       </script>-->
	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>

	<div class="page-intro">
		<% if (session.getAttribute("exonCorGeneFile")==null) { %> 
                        <p> Select a transcript you wish to view, zoom in/out, filter probesets by annotation, or compare two transcripts side by side. </p>
		<% } %>
	</div> <!-- // end page-intro -->

	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>
    <div class="leftTitle">Exon-Exon Correlations</div>
    <div style="font-size:14px">
    <div id="wait1"><img src="<%=imagesDir%>wait.gif" alt="Working..." /><BR />Working...It may take up to 3 minutes the first time you run an exon correlation.</div>
    <%@ include file="/web/exons/exonCorrelationForm.jsp" %>
	
  	<%@ include file="/web/exons/exonCorrelationMain.jsp" %>
    </div><!-- end primary content-->

	<script>
		document.getElementById("wait1").style.display = 'none';
	</script>

<%@ include file="/web/common/footer_adaptive.jsp" %>


