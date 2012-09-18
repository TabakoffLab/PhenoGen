<%--
 *  Author: Cheryl Hornbaker
 *  Created: Apr, 2008
 *  Description:  The web page created by this file displays the analysis results for a gene list
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %> 

<%
	log.info("in promoter.jsp. user = " + user);

	formName = "promoter.jsp";
	request.setAttribute( "selectedTabId", "promoter" );
        extrasList.add("promoter.js");
        extrasList.add("meme.js");
        extrasList.add("createOpossum.js");
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
	optionsListModal.add("createNewOpossum");
	optionsListModal.add("createNewMeme");
	optionsListModal.add("createNewUpstream");

	int itemID = (request.getParameter("itemID") != null ? Integer.parseInt((String) request.getParameter("itemID")) : -99);
        String type = ((String)request.getParameter("type") != null ? (String) request.getParameter("type") : "");
	if (itemID != -99) {
		if (type.equals("oPOSSUM")) {
			response.sendRedirect("promoterResults.jsp?itemID="+itemID);
		} else if (type.equals("Upstream")) {
			response.sendRedirect("upstreamExtractionResults.jsp?itemID="+itemID);
		} else {
			response.sendRedirect("memeResults.jsp?itemID="+itemID);
		}
	}

	GeneListAnalysis [] myAnalysisResults = null;
        String header = "";
        String columnHeader = "";
        String msg = "";
	String all="N";
	String title="";
	String createNew="";
	String button="";
	mySessionHandler.createGeneListActivity("On promoter tab", dbConn);

%>
<%@ include file="/web/common/header.jsp" %>

	<script type="text/javascript">
		var crumbs = ["Home", "Research Genes", "Promoter"];
	</script>

	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>
	<div class="page-intro">
		<p> Click on a promoter analysis name to view the results, or run a new analysis.
		</p>
	</div> <!-- // end page-intro -->

	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>

	<div class="dataContainer" >
<%
		myAnalysisResults = 
        		myGeneListAnalysis.getGeneListAnalysisResults(userID, selectedGeneList.getGene_list_id(), "oPOSSUM", dbConn);
		type = "oPOSSUM";
%>
		<%@ include file="/web/geneLists/include/formatAnalysisResults.jsp" %>
		<BR><BR>
<% 
		myAnalysisResults = 
        		myGeneListAnalysis.getGeneListAnalysisResults(userID, selectedGeneList.getGene_list_id(), "MEME", dbConn);
		type = "MEME";
%>
		<%@ include file="/web/geneLists/include/formatAnalysisResults.jsp" %>
		<BR><BR>

<% 
		myAnalysisResults = 
        		myGeneListAnalysis.getGeneListAnalysisResults(userID, selectedGeneList.getGene_list_id(), "Upstream", dbConn);

		type = "Upstream";
%>
		<%@ include file="/web/geneLists/include/formatAnalysisResults.jsp" %>
	</div>

	<div class="deleteItem"></div>
	<div class="createOpossum"></div>
	<div class="createMeme"></div>
	<div class="createUpstream"></div>
	<script type="text/javascript">
		$(document).ready(function() {
			setupPage();
		});
	</script>


<%@ include file="/web/common/footer.jsp" %>
  <script type="text/javascript">
    $(document).ready(function() {
	setTimeout("setupMain()", 100); 
    });
  </script>
