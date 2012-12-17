<%@ include file="/web/common/session_vars.jsp" %>
<jsp:useBean id="myDataset" class="edu.ucdenver.ccp.PhenoGen.data.Dataset"> </jsp:useBean>

<%
	extrasList.add("index.css");
	request.setAttribute( "selectedMain", "exonTools" );

	// This is needed in order to set the default dataset when calling calculateQTLs
    //    Dataset[] qtlDatasets = myDataset.getPublicDatasetsForQTL(publicDatasets);
	//session.setAttribute("qtlDatasets", qtlDatasets);
	//int defaultDatasetID = myDataset.getDefaultPublicDatasetID(qtlDatasets);

	mySessionHandler.createSessionActivity(session.getId(), "On Explore Exons Main Page", dbConn);

%>

<%@ include file="/web/common/header.jsp" %>



    <div id="primary-content">
        <div id="welcome" style="height:480px">
            <h2>Explore Exons</h2>
                        <p>Use our tools to compare expression of individual exons within a gene or transcript.  You may:
			<ul id="tools" style="padding-left:40px;">
			<li>Identify exons within a gene that are not expressed
            <li>Identify exons within a gene with low heritability
            <li>Use correlation patterns among exons to identify expressed isoforms.
			</ul>
                        </p>

        <div id="what-to-do">
            <h2>What Would You Like To Do?</h2>
		<div>
            <p><a href="<%=exonDir%>exonCorrelationGene.jsp">View exon-level information for a gene</a></p>
		</div>
        </div> <!-- // end what-to-do -->
        </div> <!-- // end welcome-->
    </div> <!-- // end primary-content -->
    
<script type="text/javascript">
	$(document).ready(function(){
		setTimeout("setupMain()", 100); 
	});
</script>
<%@ include file="/web/common/footer.jsp" %>
