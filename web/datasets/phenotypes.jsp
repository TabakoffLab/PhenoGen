<%-- 
 *  Author: Cheryl Hornbaker
 *  Created: Dec, 2010
 *  Description:  The web page created by this file displays the user's phenotype data.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/analysisHeader.jsp"  %>

<%
	log.debug("in phenotypes.jsp. user = " + user + ", action = "+action); 
	
	formName="phenotypes";

	extrasList.add("correlation.js");
	optionsList.add("datasetDetails");
	optionsList.add("chooseNewVersion");
	optionsList.add("chooseNewDataset");

	ParameterValue.Phenotype[] myPhenotypes = 
		(selectedDataset.getDataset_id() != -99 && selectedDatasetVersion.getVersion() != -99 ?
			myParameterValue.getPhenotypeValuesForGrouping(userID, selectedDatasetVersion, dbConn) :
			(selectedDataset.getDataset_id() != -99 && selectedDatasetVersion.getVersion() == -99 ?
				myParameterValue.getPhenotypeValuesForDataset(userID, selectedDataset, -99, dbConn) :
				null));
	mySessionHandler.createDatasetActivity("Looked at phenotypes", dbConn);
%>

	<%@ include file="/web/common/microarrayHeader.jsp" %>



	<%@ include file="/web/datasets/include/viewingPane.jsp" %>
	<BR><BR>
	<div class="page-intro">
		<p>Listed below are the phenotypes that you've created for this dataset<% 
		if (selectedDatasetVersion.getVersion() != -99) { 
			%> version<% 
		} %>.
		</p>
		 
	</div> <!-- // end page-intro -->
	<form name="listPhenotypes"
        	method="post"
                action="filters.jsp"
                enctype="application/x-www-form-urlencoded">

	<%@ include file="/web/common/formatPhenotypes.jsp" %>

	<input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>"/>
        <input type="hidden" name="datasetVersion" value="<%=selectedDatasetVersion.getVersion()%>"/>
        <input type="hidden" name="analysisType" value="<%=analysisType%>"/>
        <input type="hidden" name="numGroups" value="<%=selectedDatasetVersion.getNumber_of_non_exclude_groups()%>"/>
        <input type="hidden" name="phenotypeParameterGroupID" id="phenotypeParameterGroupID" value=""/>
        <input type="hidden" name="formName" id="formName" value="<%=formName%>"/>

        </form>

  <div class="itemDetails"></div>
  <div class="deleteItem"></div>
  <div class="downloadItem"></div>

	<script type="text/javascript">
		$(document).ready(function() {
			setupPage();
			setTimeout("setupMain()", 100); 
		});
	</script>

<%@ include file="/web/common/footer.jsp" %>


