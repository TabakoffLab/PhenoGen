<%-- 
 *  Author: Cheryl Hornbaker
 *  Created: Nov, 2009
 *  Description:  The web page created by this file runs the QTL.analysis program
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/qtls/include/qtlHeader.jsp"  %>

<%
	log.debug("in runQTLAnalysis.jsp. user = " + user + ", action = "+action); 
	
	//extrasList.add("correlation.js");
	extrasList.add("progressBar.js");
	extrasList.add("runQTLAnalysis.js");
	extrasList.add("datasetMain.css");
	extrasList.add("viewingPane.css");
        fieldNames.add("weight");
        fieldNames.add("numPerms");
	optionsList.add("phenotypeDetails");
	optionsList.add("chooseNewPhenotype");

        %><%@ include file="/web/common/getFieldValues.jsp" %><%

        String numPerms = (String) fieldValues.get("numPerms");
	
	String weight = (fieldValues.get("weight") == null || 
			(fieldValues.get("weight") != null && 
			((String) fieldValues.get("weight")).equals("")) ? 
			"F" :
			(String) fieldValues.get("weight"));
	log.debug("weight = "+weight);
	ParameterValue.Phenotype thisPhenotype = (phenotypeParameterGroupID != -99 ? 
				myParameterValue.getPhenotypeValuesForParameterGroupID(phenotypeParameterGroupID, dbConn) :
				myParameterValue.new Phenotype());	
	String phenotypeName = thisPhenotype.getName(); 
	if (action != null && action.equals("Run")) {
                String groupingUserPhenotypeDir = selectedDatasetVersion.getGroupingUserPhenotypeDir(userName, phenotypeName);
                String dataPrepOutputFile = groupingUserPhenotypeDir + "QTLdataPrepResults.Rdata";

		String method="mr";
                String analysisOutputFile = groupingUserPhenotypeDir + "QTLAnalysisOutput.Rdata";
                String analysisOutputTxtFile = groupingUserPhenotypeDir + "QTLAnalysisOutput.txt";
                String analysisGraphicFile = groupingUserPhenotypeDir + "QTLAnalysisGraphic.png";
                try {
                	myStatistic.callQTLAnalysis(groupingUserPhenotypeDir,
						dataPrepOutputFile,
                                        	method,
                                        	weight,
                                        	numPerms,
                                        	analysisOutputFile,
                                        	analysisOutputTxtFile,
                                        	analysisGraphicFile);
                        mySessionHandler.createDatasetActivity("Ran QTL.analysis Function", dbConn);
                } catch (RException e) {
                        rExceptionErrorMsg = e.getMessage();
                        mySessionHandler.createDatasetActivity("Got RException When Running R QTL.analysis Function", dbConn);

                        %><%@ include file="/web/datasets/include/rError.jsp" %><%
		}

		response.sendRedirect(qtlsDir + "displayQTLResults.jsp?datasetID="+selectedDataset.getDataset_id()+
					"&datasetVersion=1&phenotypeParameterGroupID=" + phenotypeParameterGroupID +
					"&numPerms="+numPerms);
	}

%>

<%@ include file="/web/common/header.jsp" %>

<% if (selectedDataset.getDataset_id() != -99) { %>
	<script type="text/javascript">
            var crumbs = ["Home", "Investigate QTL Regions", "Calculate QTLs for phenotype"];
	</script>


	<%@ include file="/web/qtls/include/viewingPane.jsp" %>
	<form name="runQTLAnalysis"
		method="post"
                action="runQTLAnalysis.jsp"
                enctype="application/x-www-form-urlencoded">

		<div class="page-intro">
			<p>Number of strains included in this phenotype:<%=twoSpaces%><%=thisPhenotype.getMeans().size()%>
			<BR>
			<BR>
			Specify the following parameters:
			</p>
		</div> <!-- // end page-intro -->
		<div class="brClear"></div>

		<div class="datasetForm">
                <table class="parameters">
			<tr><td>&nbsp;</td></tr>
			<% if (thisPhenotype.getVariances().size() > 1) { %>
                		<tr>
                        	<td width="250px"><b>Weight the analysis based on variance? </b></td>
                        	<td>
                                	<%
                                        	radioName = "weight";
                                        	selectedOption = weight;
                                        	onClick = "";

                                        	optionHash = new LinkedHashMap();
                                        	optionHash.put("T", "Yes" + fiveSpaces);
                                        	optionHash.put("F", "No");
                                	%>
                                	<%@ include file="/web/common/radio.jsp" %>
				</td>
                        	</tr>
			<% } %>
			<tr><td>&nbsp;</td></tr>
			<tr>
                        <td width="250px"><b># of permutations</b> 
                                <span class="info" title="
					The number of permutations to use for calculating the p-value.  
					Provide a number from 0 to 1,000,000. 
					0 indicates that empirical p-values are not calculated.">
                                        <img src="<%=imagesDir%>icons/info.gif" alt="Help">
                                </span>
				</td>
                        <td>
				<input type="text" id="numPerms" name="numPerms" value="<%=numPerms%>"/> 
			</td>
                        </tr>
			<tr><td>&nbsp;</td></tr>
			<tr><td>&nbsp;</td></tr>
			<tr><td>
			<input type="submit" name="action" value="Run"  onClick="return IsQTLFormComplete()"></div>
			</td></tr>
		</table>
		</div>

                <input type="hidden" name="phenotypeParameterGroupID" value="<%=phenotypeParameterGroupID%>" />
		<input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>"/>
		<!-- hard-coded this because version does not need to be selected here -->
		<input type="hidden" name="datasetVersion" value="1"/>

	</form>
<% } %>

	<script type="text/javascript">
		$(document).ready(function() {
			$("#numPerms").focus();
			setTimeout("setupMain()", 100); 
		});
	</script>

<%@ include file="/web/common/footer.jsp" %>


