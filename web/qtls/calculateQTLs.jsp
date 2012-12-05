<%-- 
 *  Author: Cheryl Hornbaker
 *  Created: Jul, 2009
 *  Description:  The web page created by this file accepts the values for the user's phenotype data.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/qtls/include/qtlHeader.jsp"  %>

<%
	log.debug("in calculateQTLs.jsp. user = " + user + ", action = "+action); 
	
	log.debug("publicDatasets length = "+publicDatasets.length);
	Dataset[] qtlDatasets = ((Dataset[]) session.getAttribute("qtlDatasets") == null ? 
				myDataset.getPublicDatasetsForQTL(publicDatasets) : 
				(Dataset[]) session.getAttribute("qtlDatasets"));
	session.setAttribute("qtlDatasets", qtlDatasets);
	log.debug("qtlDatasets length = "+qtlDatasets.length);

	formName = "calculateQTLs";

	extrasList.add("correlation.js");
	// This should be included here and NOT in createPhenotype.jsp
	extrasList.add("progressBar.js");
	optionsListModal.add("createNewPhenotype");

        int datasetID = ((String) request.getParameter("datasetID") != null &&
                !((String) request.getParameter("datasetID")).equals("")  ?
                Integer.parseInt((String)request.getParameter("datasetID")) :
                -99);
	
	for (int i=0; i<qtlDatasets.length; i++) {
		log.debug("datasetID= "+datasetID);
		if (qtlDatasets[i].getDataset_id() == datasetID) {
			selectedDataset = qtlDatasets[i];
			selectedDatasetVersion = qtlDatasets[i].getDatasetVersion(1);
			log.debug("path for chosen dataset= "+qtlDatasets[i].getPath());
			log.debug(" setting selectedDataset to " + selectedDataset.getName());
			session.setAttribute("selectedDataset", selectedDataset);
			session.setAttribute("selectedDatasetVersion", selectedDatasetVersion);
			break;
		}
	}
	%> <% //@ include file="/web/datasets/include/selectDataset.jsp" %> <%

	ParameterValue.Phenotype[] myPhenotypes = myParameterValue.getPhenotypeValuesForGrouping(userID, selectedDatasetVersion, dbConn); 

	log.debug("action = " + action + " whichDataset = "+selectedDataset.getDataset_id() + 
			", whichVersion = "+selectedDatasetVersion.getVersion());

	if (action != null && action.equals("Run") && phenotypeParameterGroupID != -99) {
		log.debug("phenotypeParameterGroupID = "+phenotypeParameterGroupID);
		String phenotypeName = (phenotypeParameterGroupID != -99 ? 
				myParameterValue.getPhenotypeName(phenotypeParameterGroupID, dbConn) :
				"");	
                String inputGenotypeFile = selectedDataset.getPath() + 
                	(selectedDataset.getName().equals(selectedDataset.BXDRI_DATASET_NAME) ? 
				"BXDgeno.Rdata" :
				selectedDataset.getName().equals(selectedDataset.HXBRI_DATASET_NAME) ? 
					"HXB.BXHgeno.Rdata":
				selectedDataset.getName().equals(selectedDataset.LXSRI_DATASET_NAME) ? 
					"LXSgeno.Rdata":
				selectedDataset.getName().equals(selectedDataset.INBRED_DATASET_NAME) ?
					"Inbredgeno.Rdata": "");

                String groupingUserPhenotypeDir = selectedDatasetVersion.getGroupingUserPhenotypeDir(userName, phenotypeName);
		log.debug("groupingUserPhenotypeDir = "+groupingUserPhenotypeDir);
                String dataPrepOutputFile = groupingUserPhenotypeDir + "QTLdataPrepResults.Rdata";

                try {
			if (!(new File(dataPrepOutputFile)).exists()) {
				log.debug("data prep file does not already exist");
                		myStatistic.callQTLDataPrep(groupingUserPhenotypeDir,
							inputGenotypeFile,
							selectedDatasetVersion.getPhenotypeDataOutputFileName(userName, phenotypeName),
                                        		dataPrepOutputFile);
                        	mySessionHandler.createDatasetActivity("Ran QTL.data.prep Function", dbConn);
			} else {
				log.debug("data prep file already exists");
			}
			response.sendRedirect(qtlsDir + "runQTLAnalysis.jsp?datasetID="+selectedDataset.getDataset_id() +
					"&datasetVersion=1&phenotypeParameterGroupID=" + phenotypeParameterGroupID);
                } catch (RException e) {
			log.debug("got error running QTLDataPrep. datasetID = " + selectedDataset.getDataset_id());
                        rExceptionErrorMsg = e.getMessage();
                        mySessionHandler.createDatasetActivity("Got RException When Running R QTL.data.prep Function", dbConn);

                        %><%@ include file="/web/datasets/include/rError.jsp" %><%
		}
	}

%>

<%pageTitle="Calculate QTLs";%>

<%@ include file="/web/common/header.jsp" %>



	<form name="listPhenotypes"
		method="post"
                action="calculateQTLs.jsp"
                enctype="application/x-www-form-urlencoded">

		<div class="page-intro">
			<p>First select the marker dataset. </p>
		 	<p>Then click on the phenotype data you would like to use, or enter new phenotype data. </p>
		</div> <!-- // end page-intro -->
		<BR><BR>
		<div style="clear:left"></div>

		<% if (qtlDatasets != null && qtlDatasets.length > 0) { %>
			<%
			optionHash = new LinkedHashMap();
			radioName = "chosenDatasetID";
                	selectedOption = Integer.toString(selectedDataset.getDataset_id());
                	onClick = "";
                        for (int i=0; i<qtlDatasets.length; i++) {
                                optionHash.put(Integer.toString(qtlDatasets[i].getDataset_id()), qtlDatasets[i].getName() + 
						tenSpaces + fiveSpaces);	
                	}
			%>
			<table width="100%" style="background:transparent">
                        <tr>
				<td class="center">
                		<%@ include file="/web/common/radio.jsp" %>
				</td>
			</tr>
                	</table>
		<% } %>
        <div class="page-intro">
        	<div style="font-size:12px"><p>Additional Phenotype Data for the above marker sets may be found on <a target="_blank" href="http://genenetwork.org/webqtl/main.py">GeneNetwork.org</a>.  Calculated QTLs may then be imported back to Phenogen <a href="<%=qtlsDir%>defineQTL.jsp?fromMain=Y">here</a>.</p></div>	
		</div> <!-- // end page-intro -->
		

		<%@ include file="/web/common/formatPhenotypes.jsp" %>

		<input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>"/> 
		<input type="hidden" name="datasetVersion" value="1"/>

                <input type="hidden" name="phenotypeParameterGroupID" id="phenotypeParameterGroupID" value=""/>
		<input type="hidden" name="formName" id="formName" value="<%=formName%>"/>
		<input type="hidden" name="action" id="action" value=""/>

	</form>

  <div class="itemDetails"></div>
  <div class="deleteItem"></div>
  <div class="downloadItem"></div>
  <div class="load">Loading...</div>
  <div class="createPhenotypeData"></div>

	<script type="text/javascript">
		$(document).ready(function() {
			setupPage();
			setTimeout("setupMain()", 100); 
		});
	</script>

<%@ include file="/web/common/footer.jsp" %>


