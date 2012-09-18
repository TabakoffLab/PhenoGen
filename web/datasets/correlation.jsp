<%-- 
 *  Author: Cheryl Hornbaker
 *  Created: Jun, 2008
 *  Description:  The web page created by this file accepts the values for the user's phenotype data.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/analysisHeader.jsp"  %>

<%
	log.debug("in correlation.jsp. user = " + user + ", action = "+action); 
	
	formName="correlation";
	analysisType = "correlation";
	request.setAttribute( "selectedStep", "3" ); 

	extrasList.add("correlation.js");
//	extrasList.add("createPhenotype.js");
	// This should be included here and NOT in createPhenotype.jsp
	extrasList.add("progressBar.js");
	optionsList.add("datasetVersionDetails");
	optionsListModal.add("createNewPhenotype");

	ParameterValue.Phenotype[] myPhenotypes = 
		(selectedDataset.getDataset_id() != -99 && selectedDatasetVersion.getVersion() != -99 ?
			myParameterValue.getPhenotypeValuesForGrouping(userID, selectedDatasetVersion, dbConn) :
			null);
	mySessionHandler.createDatasetActivity("Chose to run correlation", dbConn);

	if (selectedDataset.getDataset_id() != -99 && !selectedDatasetVersion.readyForCorrelation()) {
		//Error - "Can't do a correlation analysis on dataset that was 
		//normalized with less than 5 groups 
		session.setAttribute("errorMsg", "EXP-012");
		response.sendRedirect(commonDir + "errorMsg.jsp");
	} 
%>

	<%@ include file="/web/common/microarrayHeader.jsp" %>

<% if (selectedDataset.getDataset_id() != -99 && selectedDatasetVersion.getVersion() != -99) { %>
	<script type="text/javascript">
            var crumbs = ["Home", "Analyze Microarray Data", "Correlation Analysis"];
	</script>

	<%@ include file="/web/datasets/include/viewingPane.jsp" %>
	<%@ include file="/web/datasets/include/analysisSteps.jsp" %>
	<BR><BR>
	<div class="page-intro">
		<p>Click on the phenotype data you would like to use, or enter new phenotype data.
		</p>
		 
	</div> <!-- // end page-intro -->
	<form name="listPhenotypes"
        	method="post"
                action="filters.jsp"
                enctype="application/x-www-form-urlencoded">

	<div style="clear:left"></div>

	<%@ include file="/web/common/formatPhenotypes.jsp" %>

	<input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>"/>
        <input type="hidden" name="datasetVersion" value="<%=selectedDatasetVersion.getVersion()%>"/>
        <input type="hidden" name="analysisType" value="<%=analysisType%>"/>
        <input type="hidden" name="numGroups" value="<%=selectedDatasetVersion.getNumber_of_non_exclude_groups()%>"/>
        <input type="hidden" name="phenotypeParameterGroupID" id="phenotypeParameterGroupID" value=""/>
        <input type="hidden" name="formName" id="formName" value="<%=formName%>"/>

        </form>
<% } %>

  <div class="itemDetails"></div>
  <div class="deleteItem"></div>
  <div class="downloadItem"></div>
  <div class="createPhenotypeData"></div>

	<script type="text/javascript">
		$(document).ready(function() {
			setupPage();
			setTimeout("setupMain()", 100); 
		});
	</script>

<%@ include file="/web/common/footer.jsp" %>


