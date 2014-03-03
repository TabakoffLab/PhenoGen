<%--
 *  Author: Cheryl Hornbaker
 *  Created: Oct, 2009
 *  Description:  The web page created by this file displays the results of the QTL calculation process
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/qtls/include/qtlHeader.jsp"  %>

<%
	log.info("in displayQTLResults.jsp. user =  "+ user);

	mySessionHandler.createDatasetActivity("Viewed QTL Results", dbConn);

	extrasList.add("qtlMain.css");
	extrasList.add("viewingPane.css");
        extrasList.add("displayQTLResults.js");
	optionsList.add("phenotypeDetails");
	optionsList.add("chooseNewPhenotype");
	optionsListModal.add("download");

        fieldNames.add("numPerms");
        fieldNames.add("narrowBy");
        fieldNames.add("LOD_score");
        fieldNames.add("pvalue");
        fieldNames.add("chromosome");
        fieldNames.add("minbp");
        fieldNames.add("maxbp");
        fieldNames.add("confType");
        fieldNames.add("numSamples");
        fieldNames.add("numDrop");
        fieldNames.add("coverage");

        %><%@ include file="/web/common/getFieldValues.jsp" %><%

        String[] checkedList = new String[3];
	String numPerms = (String) fieldValues.get("numPerms");
	
	int selectedVer=4;//default for ILSXISS and HXBBXH will set to 1 for BXD.
	if((selectedDataset.getDataset_id() != -99)&&selectedDataset.getName().equals(selectedDataset.BXDRI_DATASET_NAME)){
		selectedVer=1;
	}

	log.debug("phenotypeParameterGroupID = "+phenotypeParameterGroupID);
	String phenotypeName = (phenotypeParameterGroupID != -99 ? 
			myParameterValue.getPhenotypeName(phenotypeParameterGroupID, dbConn) :
			"");	
	log.debug("phenotypeName = "+phenotypeName);
        String groupingUserPhenotypeDir = selectedDatasetVersion.getGroupingUserPhenotypeDir(userName, phenotypeName);
	String analysisOutputRdataFileName = groupingUserPhenotypeDir + "QTLAnalysisOutput.Rdata"; 
        String[] summaryResults = null;
	mySessionHandler.createDatasetActivity("Viewed QTL Calculation results", dbConn);

        if ((action != null) && action.equals("Run Summary")) {
		String criteria=(String) fieldValues.get("narrowBy");
		String threshold = (criteria.equals("LOD") ? (String) fieldValues.get("LOD_score") :
					criteria.equals("pvalue") ? (String) fieldValues.get("pvalue") :
					criteria.equals("location") ? (String) fieldValues.get("chromosome") + ":" +  
									(String) fieldValues.get("minbp") +  "-" + 
									(String) fieldValues.get("maxbp") : "");
		log.debug("threshold = "+threshold);
		String confidenceType = (String) fieldValues.get("confType");
		String confidenceCriteriaString = (confidenceType.equals("bootstrap") ? (String) fieldValues.get("numSamples") :
					confidenceType.equals("lod") ? (String) fieldValues.get("numDrop") :
					confidenceType.equals("bayesian") ? (String) fieldValues.get("coverage") : "-99");
		Double confidenceCriteria = Double.parseDouble(confidenceCriteriaString);
		log.debug("confidenceCriteria = "+confidenceCriteria);
                String summaryOutputTxtFile = groupingUserPhenotypeDir + "QTLSummaryOutput.txt";
                try {
                	myStatistic.callQTLSummary(groupingUserPhenotypeDir,
						analysisOutputRdataFileName,
                                        	criteria,
                                        	threshold,
                                        	confidenceType,
                                        	confidenceCriteria,
                                        	summaryOutputTxtFile);
                        mySessionHandler.createDatasetActivity("Ran QTL.summary Function", dbConn);
        		summaryResults = myFileHandler.getFileContents(new File(summaryOutputTxtFile), "withSpaces");
                } catch (RException e) {
                        rExceptionErrorMsg = e.getMessage();
                        mySessionHandler.createDatasetActivity("Got RException When Running R QTL.summary Function", dbConn);
                        %><%@ include file="/web/datasets/include/rError.jsp" %><%
		}

        }

%>


	<%@ include file="/web/common/header.jsp" %>

	<%@ include file="/web/qtls/include/viewingPane.jsp" %>


	<div class="brClear"></div>
	<BR>
	<BR>
	<BR>
        <form   method="post" 
                action="displayQTLResults.jsp" 
                enctype="application/x-www-form-urlencoded" 
                name="displayQTLResults">
	<table name="items" cellpadding="0" cellspacing="2" width="950px">
	<tr id="<%=phenotypeParameterGroupID%>">
		<td class="center"><h2>QTL LOD plot </h2></td>
	</tr>
	</table>
	<div class="scrollable">
        	<% 
		String imageHeight = "255px";
		String imageWidth = "950px";

		String[] imageFileNames = new String[]{"QTLAnalysisGraphic.png"};
		%>
        	<%@include file="/web/qtls/include/displayImages.jsp"%>
	</div>
	<table class="list_base" cellpadding="0" cellspacing="2">
		<tr><td colspan="100%" class="center"><h2>View Results By Marker</h2></td></tr>
		<tr><td>&nbsp;</td></tr>
		<tr><td width="450px" style="vertical-align:top">

		<div id="narrow_div">
                <table>
                	<tr>
                        <td width="200px"><b>Narrow the results by: </b></td>
                        <td>
                        	<%
                                selectName = "narrowBy";
                                selectedOption = (String) fieldValues.get(selectName);
                                onChange = "show_more_parameters()";
                                style = "";
                                optionHash = new LinkedHashMap();
                                optionHash.put("0", "-- Select an option --");
                                optionHash.put("LOD", "LOD threshold");
				if (!numPerms.equals("0")) {
                                	optionHash.put("pvalue", "pvalue threshold");
				}
                                optionHash.put("location", "genomic location");
                                %>
                                <%@ include file="/web/common/selectBox.jsp" %>
			</td>
                        </tr>
		</table>
		</div>
		<div id="LOD_div" class="qtlParameters">
                <table>
                	<tr>
                        <td width="200px"><b>Markers with a LOD score above: </b></td>
                        <td>
				<input type="text" id="LOD_score" name="LOD_score" value="<%=fieldValues.get("LOD_score")%>"/> 
			</td>
                        </tr>
		</table>
		</div>
		<div id="pvalue_div" class="qtlParameters">
                <table>
                	<tr>
                        <td width="200px"><b>Markers with a p-value less than: </b></td>
                        <td>
				<input type="text" id="pvalue" name="pvalue" value="<%=fieldValues.get("pvalue")%>"/> 
			</td>
                        </tr>
		</table>
		</div>
		<div id="location_div" class="qtlParameters">
                <table>
                	<tr>
                        	<td width="200px"><b>Chromosome: </b></td>
                        	<td> <input type="text" id="chromosome" name="chromosome" value="<%=fieldValues.get("chromosome")%>"/> </td>
                        </tr>
                	<tr>
                        	<td width="200px"><b>Min bp: </b></td>
                        	<td> <input type="text" id="minbp" name="minbp" value="<%=fieldValues.get("minbp")%>"/> </td>
                        </tr>
                	<tr>
                        	<td width="200px"><b>Max bp: </b></td>
                        	<td> <input type="text" id="maxbp" name="maxbp" value="<%=fieldValues.get("maxbp")%>"/> </td>
                        </tr>
		</table>
		</div>
		</td>
		<td width="450px" style="vertical-align:top">
		<div id="confType_div">
                <table>
                	<tr>
                        <td width="250px"><b>Method to calculate location confidence interval: </b></td>
                        <td>
                        	<%
                                selectName = "confType";
                                selectedOption = (String) fieldValues.get(selectName);
                                onChange = "show_conf_parameters()";
                                style = "";
                                optionHash = new LinkedHashMap();
                                optionHash.put("none", "do not calculate");
                                optionHash.put("bootstrap", "nonparametric bootstrap");
                                optionHash.put("lod", "LOD support interval");
                                optionHash.put("bayesian", "Bayesian credible interval");
                                %>
                                <%@ include file="/web/common/selectBox.jsp" %>
			</td>
                        </tr>
		</table>
		</div>
		<div id="bootstrap_div" class="qtlParameters">
                <table>
                	<tr>
                        <td width="250px"><b>Probability coverage: </b></td>
                        <td>
                        	<%
                                selectName = "numSamples";
                                selectedOption = (String) fieldValues.get(selectName);
                                onChange = "";
                                style = "";
                                optionHash = new LinkedHashMap();
                                optionHash.put("0.90", "0.90");
                                optionHash.put("0.95", "0.95");
                                optionHash.put("0.99", "0.99");
                                %>
                                <%@ include file="/web/common/selectBox.jsp" %>
			</td>
                        </tr>
		</table>
		</div>
		<div id="lodDrop_div" class="qtlParameters">
                <table>
                	<tr>
                        <td width="250px"><b>Number of LOD units to drop: </b></td>
                        <td>
                        	<%
                                selectName = "numDrop";
                                selectedOption = (String) fieldValues.get(selectName);
                                onChange = "";
                                style = "";
                                optionHash = new LinkedHashMap();
                                optionHash.put("1", "1");
                                optionHash.put("1.2", "1.2");
                                optionHash.put("1.5", "1.5");
                                optionHash.put("2", "2");
                                %>
                                <%@ include file="/web/common/selectBox.jsp" %>
			</td>
                        </tr>
		</table>
		</div>
		<div id="bayesian_div" class="qtlParameters">
                <table>
                	<tr>
                        <td width="250px"><b>Probability coverage: </b></td>
                        <td>
                        	<%
                                selectName = "coverage";
                                selectedOption = (String) fieldValues.get(selectName);
                                onChange = "";
                                style = "";
                                optionHash = new LinkedHashMap();
                                optionHash.put("0.90", "0.90");
                                optionHash.put("0.95", "0.95");
                                optionHash.put("0.99", "0.99");
                                %>
                                <%@ include file="/web/common/selectBox.jsp" %>
			</td>
                        </tr>
		</table>
		</div>
		</td></tr>
		<tr><td colspan="100%" class="center">
			<input type="submit" name="action" value="Run Summary" onClick="return IsRunQTLSummaryFormComplete()" />
		</td></tr>
		</table>

		<% if (summaryResults != null) { %>
			<div class="scrollable">
			<div class="title"> QTL Analysis Results</div>
        		<table class="list_base tablesorter" cellpadding="0" cellspacing="3" width="98%">
                		<thead>
                		<tr class="col_title">
				<%
        			//
        			// The first line of this file is the column headers
        			//
                		String[] headers = summaryResults[0].split("\t");
                		for (int j=0; j<headers.length; j++) {
                        		%><th><%=headers[j]%></th><%
				} %>
                		</tr>
                		</thead>
                		<tbody>
        		<%
        		//
        		// The first line of this file is the column headers, so start reading from the second line
        		//
        		for (int i=1; i<summaryResults.length; i++) {
                		%> <tr> <%
                		String[] lineElements = summaryResults[i].split("\t");
                		for (int j=0; j<lineElements.length; j++) {
                                	%><td> <%=lineElements[j]%> </td> <%
                		}
                		%> </tr> <%
        		}
        		%>
        		</tbody>
        		</table>
			</div>
		<% } %>
		<BR><BR>

		<input type="hidden" name="action" value="">
                <input type="hidden" name="phenotypeParameterGroupID" value="<%=phenotypeParameterGroupID%>" />
                <input type="hidden" name="itemID" value="<%=phenotypeParameterGroupID%>" />
                <input type="hidden" name="numPerms" value="<%=numPerms%>" />
		<input type="hidden" name="formName" id="formName" value="displayQTLResults"/>
		<input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>"/>
		<!-- hard-coded this because version does not need to be selected here -->
		<input type="hidden" name="datasetVersion" value="<%=selectedVer%>"/>

	</form>

        <div class="downloadPage"></div>

	<script type="text/javascript">
		$(document).ready(function() {
			setupPage();
			setTimeout("setupMain()", 100); 
		});
	</script>

<%@ include file="/web/common/footer.jsp" %>
