<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>
<%
	selectedDatasetVersion = selectedDataset.new DatasetVersion(-99);
	log.debug("in listDatasetVersions.  datasetID = "+selectedDataset.getDataset_id());
	request.setAttribute( "selectedStep", "1" );
	extrasList.add("listDatasetVersions.js");
	extrasList.add("downloadDataset.js");
	optionsList.add("datasetDetails");
	if (!selectedDataset.getCreator().equals("public")) { 
		optionsList.add("createNewNormalization");
	}
	mySessionHandler.createDatasetActivity(session.getId(), selectedDataset.getDataset_id(), -99, "Looked at dataset versions", dbConn);

	if ((selectedDataset.getDatasetVersions() == null || selectedDataset.getDatasetVersions().length == 0)) {
		log.debug("no versions yet for this dataset");
                if (selectedDataset.getName().indexOf("(Pending)") > 0) { 
                        log.debug("cannot move forward with Pending datasets");
                        //Error - "Cannot move forward with Pending datasets"
                        session.setAttribute("errorMsg", "EXP-028");
                        response.sendRedirect(commonDir + "errorMsg.jsp");
		} else if (selectedDataset.getQc_complete().equals("N")) { 
			log.debug("qc not run yet, so going there");
			response.sendRedirect("qualityControl.jsp" + datasetQueryString);
		} else if (selectedDataset.getQc_complete().equals("1")) { 
			log.debug("running qc, so give message saying can't do anything yet");
                	//Error - "Feature not allowed for guests"
                	session.setAttribute("errorMsg", "QC-004");
                	response.sendRedirect(commonDir + "errorMsg.jsp");
		} else if (selectedDataset.getQc_complete().equals("R")) { 
			log.debug("reviewing qc");
			response.sendRedirect("qualityControlResults.jsp" + datasetQueryString);
		} else if (selectedDataset.getGroupings(dbConn).length == 0) { 
			log.debug("no versions, no groups, going to groupArrays");
			response.sendRedirect("groupArrays.jsp" + datasetQueryString);
		} else { 
			log.debug("no versions, some groups, going to normalize");
			response.sendRedirect("normalize.jsp" + datasetQueryString);
		}
	}
%>
	<%@ include file="/web/common/microarrayHeader.jsp" %>

	<%@ include file="/web/datasets/include/viewingPane.jsp" %>
    <script type="text/javascript">
        var crumbs = ["Home", "Analyze Microarray Data"]; 
    </script>
	<%
	if ((selectedDataset.getDatasetVersions() == null || selectedDataset.getDatasetVersions().length == 0)) {
	%>
		<%@ include file="/web/datasets/include/prepSteps.jsp" %>
    		<div class="page-intro">
			<p>You have not yet created any normalized versions of your dataset.
			</p>
    		</div> <!-- // end page-intro -->
	<% } else { %>
		<div class="brClear"></div>
		<%@ include file="/web/datasets/include/preAnalysisSteps.jsp" %>
		<div class="brClear"></div>
    		<div class="page-intro">
			<p>Click on a normalized version for analysis.  </p>
    		</div> <!-- // end page-intro -->
	<% } %>


	<div class="list_container">
		<form name="tableList" action="chooseDataset.jsp" method="get">
			<input type="hidden" name="datasetVersion" />
			<input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>" />

		<div class="leftTitle">  Versions  </div>
		<table name="items" class="list_base tablesorter" cellpadding="0" cellspacing="3" width="98%">
			<thead>
			<tr>
				<th colspan="7" class="topLine">&nbsp;</th>
				<th colspan="3" class="center noSort topLine">Results</th>
				<% if (!selectedDataset.getCreator().equals("public")) { %>
					<th colspan="3" class="topLine">&nbsp;</th>
				<% } else { %> 
					<th colspan="1" class="topLine">&nbsp;</th>
				<% } %> 
			</tr>
			<tr class="col_title">
				<th>#</th>
				<th>Version Name</th>
				<th>Date Created</th>
				<th>Grouping Used</th>
				<th>Number of Groups</th>
				<th>Normalization Method</th>
				<th>Phenotype Data</th>
				<th>Cluster Results</th>
                <th>Filter/Statistics Results</th>
				<th>Gene Lists </th>
				<th class="noSort">Details</th>
				<% if (!selectedDataset.getCreator().equals("public")) { %>
				    <th class="noSort">Delete</th>
				<% } %>
				<th class="noSort">Download</th>
			</tr>
			</thead>
			<tbody>
<%
	if (selectedDataset.getDatasetVersions() != null && selectedDataset.getDatasetVersions().length > 0 
			&& selectedDataset.hasVisibleVersions()) {

		for (int j=0; j<selectedDataset.getDatasetVersions().length; j++) {
			Dataset.DatasetVersion thisVersion = selectedDataset.getDatasetVersions()[j];

			String chooseDatasetString = "<a href='"+datasetsDir + "chooseDataset.jsp?datasetID=" + selectedDataset.getDataset_id() + 
						"&datasetVersion=" + thisVersion.getVersion();
                	String clusterLink = chooseDatasetString + "&goTo=ClusterResults'>" + resultsIcon + "</a>";
                	String phenotypeLink = chooseDatasetString + "&goTo=Phenotype'>" + resultsIcon + "</a>";
                	String geneListLink = chooseDatasetString + "&goTo=GeneList'>" + resultsIcon + "</a>";
					String filterStatLink = chooseDatasetString + "&goTo=GeneList'>" + resultsIcon + "</a>";

                        String phenotypeData =
                                (thisVersion.hasPhenotypeData(userLoggedIn.getUser_id()) == true ?
                                        phenotypeLink : "");

                        String clusterResults =
                                (thisVersion.hasClusterResults(userLoggedIn.getUser_id()) == true  ?
                                        clusterLink : "");

                        String geneLists =
                                (thisVersion.hasGeneLists() == true ?
                                        geneListLink : "");
						String filterStatResults=(thisVersion.hasFilterStatsResults(userLoggedIn.getUser_id(),dbConn) == true ?
                                        filterStatLink : "");
			// Only display visible versions 
			if (thisVersion.getVisible() == 1) {
				Dataset.Group thisGrouping = selectedDataset.new Group().getGrouping(thisVersion.getGrouping_id(), dbConn);
				%>
        			<tr id="<%=selectedDataset.getDataset_id()%>|||<%=thisVersion.getVersion()%>">
					<td><%=thisVersion.getVersion()%></td>
					<td><%=thisVersion.getVersion_name()%></td>
					<td><%=thisVersion.getCreate_date_as_string().substring(0, thisVersion.getCreate_date_as_string().indexOf(" "))%></td>
                                	<td><%=thisGrouping.getGrouping_name()%></td>
                                	<td><%=thisVersion.getNumber_of_non_exclude_groups()%></td>
                                	<td><%=thisVersion.getNormalization_method()%></td>
					<td class="actionIcons"><%=phenotypeData%></td>
					<td class="actionIcons"><%=clusterResults%></td>
                    <td class="actionIcons"><%=filterStatResults%></td>
					<td class="actionIcons"><%=geneLists%></td>
    					<td class="details">View</td>
                    			<% if (!selectedDataset.getCreator().equals("public")) { %>
					    <td class="actionIcons">
						    <div class="linkedImg delete"></div>
					    </td>
					<% } %>
					<td class="actionIcons">
						<div class="linkedImg download"></div>
					</td>
				</tr>
				<%
			}
		}
	} else { 
		%> <tr><td colspan="12" class="center"><h2>There are no normalized versions ready for this dataset</h2></td></tr><%
	}

%>

	</tbody>
      </table>
   </form>
  </div>

  <div class="itemDetails"></div>
  <div class="deleteItem"></div>
  <div class="downloadItem"></div>

  <script type="text/javascript">
    $(document).ready(function() {
        setupPage( );
	setTimeout("setupMain()", 100); 
    });
  </script>
<%@ include file="/web/common/footer.jsp" %>

