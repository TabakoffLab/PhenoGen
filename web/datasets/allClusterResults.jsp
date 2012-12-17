<%--
 *  Author: Cheryl Hornbaker
 *  Created: Oct, 2007
 *  Description:  The web page created by this file displays the cluster results for this dataset.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/datasets/include/analysisHeader.jsp"  %>

<%
	log.info("in allClusterResults.jsp. user = " + user);
        extrasList.add("allClusterResults.js");
	optionsList.add("datasetVersionDetails");
	optionsList.add("chooseNewDataset");

	//log.debug("datasetID = "+selectedDataset.getDataset_id() + ", and version = "+selectedDatasetVersion.getVersion());

        int clusterGroupID = (request.getParameter("clusterGroupID") != null ? Integer.parseInt((String) request.getParameter("clusterGroupID")) : -99);
	log.debug("clusterGroupID = "+clusterGroupID);

        if (clusterGroupID != -99) {
                log.debug("clusterGroupID = "+clusterGroupID);
                response.sendRedirect("clusterResults.jsp?datasetID="+selectedDataset.getDataset_id() +
//							"&datasetVersion=" + selectedDatasetVersion.getVersion() + 
							"&clusterGroupID=" + clusterGroupID);
        }               

	ParameterValue [] myClusterResults = myParameterValue.getAllClusterParameterGroups(userID, 
						selectedDataset.getDataset_id(), selectedDatasetVersion.getVersion(), dbConn);

	log.debug("myClusterResults length = "+myClusterResults.length);
	mySessionHandler.createDatasetActivity("Viewed all cluster results for dataset", dbConn);

%>

	<%@ include file="/web/common/microarrayHeader.jsp" %>

        <%@ include file="/web/datasets/include/viewingPane.jsp" %>
	<div class="page-intro">
		<p> Click on a row to view the details of that cluster analysis.
		</p>
	</div> <!-- // end page-intro -->
	<div class="brClear"></div>

	<div class="title">Cluster Results</div>

	<%
	if (myClusterResults != null && myClusterResults.length > 0) { 
		%>
        	<form   method="post"
                	action="allClusterResults.jsp"
                	onSubmit="return AreYouSure(this)"
                	enctype="application/x-www-form-urlencoded"
                	name="allClusterResults">

		<table name="items" class="list_base tablesorter" cellpadding="0" cellspacing="3" width="90%">
			<thead>
			<tr class="col_title">
				<% if (selectedDatasetVersion.getVersion() == -99) { %>
					<th width="10%">Version #</th>
				<% } %>
				<th>Method</th>
				<th>Cluster Object</th>
				<th>Number of Probes</th>
				<th>Expression Values Used</th>
				<th>Distance Measure</th>
				<th>Dissimilarity Measure</th>
				<th>Number of Clusters</th>
				<th>Run Date</th>
				<th class="noSort"> Delete</th> 
			</tr>
			</thead>
			<tbody>
			<%
			for (int i=0; i<myClusterResults.length; i++) {
                		String typeOfAnalysis = (myClusterResults[i].getValue().equals("hierarch") ? "Hierarchical" : "K-Means");
		                String analysisDirString; 
				Dataset.DatasetVersion thisVersion = selectedDataset.new DatasetVersion(); 	
				//log.debug("selectedDataset has this many versions: " + selectedDataset.getDatasetVersions().length);
				if (selectedDatasetVersion.getVersion() != -99) {
		                	analysisDirString = selectedDatasetVersion.getClusterDir() +
                                			userName + "/" +
                                			myClusterResults[i].getParameter_group_id() + "/";
				} else {
					thisVersion = 	
						selectedDataset.getDatasetVersionForParameterGroup(myClusterResults[i].getParameter_group_id(), dbConn); 
		                	analysisDirString = thisVersion.getClusterDir() +
                                			userName + "/" +
                                			myClusterResults[i].getParameter_group_id() + "/";
				}
		                File analysisDir = new File(analysisDirString); 
				//log.debug("analysisDir = "+analysisDirString);
				if (analysisDir.exists() &&  
					((new File(analysisDirString + "ClusterSummary.txt")).exists() || 
					(new File(analysisDirString + "Heatmap.png")).exists())) {

					ParameterValue[] analysisParameters = myParameterValue.getParameterValues(myClusterResults[i].getParameter_group_id(), dbConn);
					String object = "";
					String values = "";
					String distance = "";
					String dissimilar = "";
					String numProbes = "";
					String numClusters = "";
					for (int j=0; j<analysisParameters.length; j++) {
						if (analysisParameters[j].getParameter().indexOf("bject") > 0) {
							object = analysisParameters[j].getValue();
						} else if (analysisParameters[j].getParameter().indexOf("alues Used") > 0) {
							values = analysisParameters[j].getValue();
						} else if (analysisParameters[j].getParameter().indexOf("istance") > 0) {
							distance = analysisParameters[j].getValue();
						} else if (analysisParameters[j].getParameter().indexOf("umber of Probes") > 0) {
							numProbes = analysisParameters[j].getValue();
						} else if (analysisParameters[j].getParameter().indexOf("issimilar") > 0) {
							dissimilar = analysisParameters[j].getValue();
						} else if (analysisParameters[j].getParameter().indexOf("umber of Clusters") > 0) {
							numClusters = analysisParameters[j].getValue();
						} 
					} 
					numProbes = (numProbes.equals("") ? "Unknown" : numProbes); 
					%>
					<tr id="<%=myClusterResults[i].getParameter_group_id()%>">
						<% if (selectedDatasetVersion.getVersion() == -99) { %>
							<td><%=thisVersion.getVersion()%></td>
						<% } %>
						<td><%=typeOfAnalysis%>&nbsp;Analysis</td>
						<td><%=object%></td>
						<td><%=numProbes%></td>
						<td><%=values%></td>
						<td><%=distance%></td>
						<td><%=dissimilar%></td>
						<td><%=numClusters%></td>
                        			<td><%=myClusterResults[i].getCreate_date_as_string()%></td>
						<td class="actionIcons">
							<div class="linkedImg delete"></div>
						</td>
					</tr> <%
				} else {
					log.debug("analysisDir does not exist = "+analysisDirString + " or doesn't contain ClusterSummary or HeatMap"); 
					log.debug(" so deleting parameter values");
					myParameterValue.deleteParameterValues(myClusterResults[i].getParameter_group_id(), dbConn);
				}
			}
			%>
			</tbody>
		</table>
        	<BR>
		<input type="hidden" name="clusterGroupID" value="">
		<input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>">
		<input type="hidden" name="datasetVersion" value="<%=selectedDatasetVersion.getVersion()%>">
        	</form>
	<%
	} else {
                %> No cluster analyses have been performed on this dataset version. <%
	} %>

	<div class="deleteItem"></div>

	<script type="text/javascript">
		$(document).ready(function() {
			setTimeout("setupMain()", 100); 
			setupPage();
		});
	</script>


	<%@ include file="/web/common/footer.jsp" %>

