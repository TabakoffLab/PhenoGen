<%--
 *  Author: Cheryl Hornbaker
 *  Created: Oct, 2007
 *  Description:  The web page created by this file displays the results of cluster analysis
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/analysisHeader.jsp"  %>

<%

	String clusterGroupID = (String)request.getParameter("clusterGroupID");
	String newParameterGroupID = clusterGroupID;
	selectedDatasetVersion = selectedDataset.getDatasetVersionForParameterGroup(Integer.parseInt(clusterGroupID), dbConn);
	session.setAttribute("selectedDatasetVersion", selectedDatasetVersion);
	log.info("in clusterResults.jsp. user =  "+ user);
	log.debug("clusterGroupID = "+clusterGroupID + ", analysisPath = "+analysisPath);
	log.debug("selectedDataVersion = "+selectedDatasetVersion);

        log.debug("action here = "+action);

	extrasList.add("clusterResults.js");
	extrasList.add("cluster.js");
	optionsList.add("datasetVersionDetails");

	request.setAttribute( "selectedStep", "5" ); 

	analysisType = "cluster";
	
	String clusterObjectText = "";
	String clusterObject = "";
	String method = "";
	formName = "clusterResults.jsp";
	String currentGeneCountMsg = (String) session.getAttribute("currentGeneCountMsg");

	int numGroups = ((String) session.getAttribute("numGroups") != null ? 
		Integer.parseInt((String) session.getAttribute("numGroups")) : 2);

	ParameterValue[] analysisParameters = null; 
	String savedResultsPath = "";

	if (clusterGroupID != null && !clusterGroupID.equals("")) {
		savedResultsPath = selectedDatasetVersion.getClusterDir() + 
				userName + "/" + 
				clusterGroupID + "/";

		analysisPath = savedResultsPath;
		session.setAttribute("savedResultsPath", savedResultsPath);
		session.setAttribute("analysisPath", analysisPath);
		session.setAttribute("parameterGroupID", clusterGroupID);

		analysisParameters = myParameterValue.getParameterValues(Integer.parseInt(clusterGroupID), dbConn);
		if (analysisParameters != null && analysisParameters.length > 1) {
			myParameterValue.sortParameterValues(analysisParameters, "parameterValueID", "A");
		}
		for (int i=0; i<analysisParameters.length; i++) {
			if (analysisParameters[i].getParameter().equals("Cluster Object")) {
				clusterObject = analysisParameters[i].getValue();
			}
		}
		clusterObjectText = (clusterObject.equals("genes") ? "probes" : clusterObject);

		log.debug("savedResultsPath = "+savedResultsPath);

		mySessionHandler.createDatasetActivity("Viewed Cluster Results for Analysis done using parameterGroupID " + clusterGroupID,
				dbConn);
	}
	log.debug("now analysisPath should be savedResultsPath= "+analysisPath);
	if (action != null && action.equals("Save Gene List")) {
		try {
			String version="v"+selectedDatasetVersion.getVersion();
			String sampleFile=selectedDataset.getPath()+version+"_samples.txt";
			myStatistic.callOutputGeneList(selectedDataset.getPlatform(), 
							analysisPath + "ClusterSummary.Rdata", 
							version,
							sampleFile,
							selectedDatasetVersion.getGroupFileName(), 
							analysisPath);
			mySessionHandler.createDatasetActivity("Creating gene list from cluster results where cluster object is samples/groups",
				dbConn);
        		response.sendRedirect(datasetsDir + "nameGeneListFromAnalysis.jsp" + queryString);
		} catch (RException e) {
			rExceptionErrorMsg = e.getMessage();
			mySessionHandler.createDatasetActivity("Got Error When Running R OutputGeneList Function", dbConn);
			%><%@ include file="/web/datasets/include/rError.jsp" %><%
		}
	}

%>

	<%@ include file="/web/common/microarrayHeader.jsp" %>

        <%@ include file="/web/datasets/include/viewingPane.jsp" %>
                <%@ include file="/web/datasets/include/analysisSteps.jsp" %>
		<div class="brClear"></div>

		<BR>
		<div style="float:left; width:325px">
		<form	method="post" 
			action="clusterResults.jsp" 
			enctype="application/x-www-form-urlencoded"
			name="clusterResults">
		</div>

		<%

		if (clusterGroupID != null) {
			String level = "all";
			log.debug("analysisPath = "+analysisPath);
        		if ((new File(analysisPath + "ClusterSummary.txt")).exists() ||
                		(new File(analysisPath + "Heatmap.png")).exists()) {
				//String message = currentGeneCountMsg;
				String message = "";
				%>
				<div class="brClear"></div>
				<div class="filterResults">
					<%@ include file="/web/common/analysisParameters.jsp" %>
				</div>
				<div class="brClear"></div>
				<BR>
                		<%@ include file="/web/datasets/include/displayClusterResults.jsp" %><%

        		}
		}

		%>
        	<input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>">
        	<input type="hidden" name="datasetVersion" value="<%=selectedDatasetVersion.getVersion()%>">
        	<input type="hidden" name="clusterGroupID" value="<%=clusterGroupID%>">
        	<input type="hidden" name="numGroups" value="<%=numGroups%>">
        	<input type="hidden" name="analysisType" value="<%=analysisType%>">
		<input type="hidden" name="action" value="">

	</form>
	<BR><BR>
	<div class="saveClusterList"></div>

	<script type="text/javascript">
		$(document).ready(function() {
        		//default sort column
	        	$("table[name='items']").find("tr.col_title").find("th").not(".noSort").slice(0,1).addClass("headerSortDown");
			setupExpandCollapse();
			setupSaveGeneList();
			setupSaveClusterGeneList();
			setupSaveButton();
		});
	</script>
<%@ include file="/web/common/footer.jsp" %>
