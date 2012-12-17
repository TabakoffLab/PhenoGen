<%--
 *  Author: Cheryl Hornbaker
 *  Created: April, 2009
 *  Description:  The web page created by this file allows the user to
 *              download intensity data for a list of genes in a dataset.
 *  Todo:
 *  Modification Log:
 *
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %>

<jsp:useBean id="myDataset" class="edu.ucdenver.ccp.PhenoGen.data.Dataset"> </jsp:useBean>

<%
        log.info("in expressionValues.jsp. user =  "+ user);

        extrasList.add("expressionValues.js");
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
        if (selectedDataset.getDataset_id() != -99 && selectedDatasetVersion.getVersion() != -99) {
		optionsList.add("download");
	}

	request.setAttribute( "selectedTabId", "expressionValues" );

        mySessionHandler.createGeneListActivity("Looked at expression values for gene list", dbConn);
%>

	<%@ include file="/web/common/expressionValuesLogic.jsp"%>


<%@ include file="/web/common/header.jsp" %>

	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>

	<div class="page-intro">
		<% if (selectedDataset.getDataset_id() == -99) { %> 
                        <p> Click on a dataset to select it for extracting the expression values for the genes in this list.  </p>
		<% } else if (selectedDataset.getDataset_id() != -99 && selectedDatasetVersion.getVersion() == -99) { %>
                        <p> Click on a normalized version of this dataset to select it.  </p>
        	<% } else if (selectedDataset.getDataset_id() != -99 && selectedDatasetVersion.getVersion() != -99) { %>
			<p> Click the "Array Values" or "Group Means" links to see the different values.   </p>
		<% } %>
	</div> <!-- // end page-intro -->

	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>


	<% if (selectedDataset.getDataset_id() == -99) { %> 
	
  		<div class="dataContainer" style="height:480px; overflow:auto">
		<form name="tableList" action="expressionValues.jsp" method="post">
        		<div class="brClear"> </div>
                	<div class="title">  Normalized Datasets
                	<span class="info" title="This list contains both the public and the private datasets which have normalized versions.">
                    	<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                	</span></div>
                	<table name="items" id="datasets" class="list_base tablesorter" cellpadding="0" cellspacing="3" width="95%">
                	<thead>
                	<tr class="col_title">
                        	<th>Dataset Name</th>
                        	<th>Date Created</th>
                        	<th class="noSort">Details</th>
                	</tr>                           
                	</thead>
                	<tbody>
			<%
			
                	for (Dataset dataset : publicDatasets) {
				if (dataset.getDatasetVersions() != null && 
					dataset.getDatasetVersions().length > 0 &&
					selectedGeneList.getOrganism().equalsIgnoreCase(dataset.getOrganism())&&
					dataset.getVisible()) {
				 	//&& dataset.hasVisibleVersions())
					%>
                        		<tr id="<%=dataset.getDataset_id()%>">
                                		<td><%=dataset.getName()%></td>
                                		<td><%=dataset.getCreate_date_as_string().substring(0, dataset.getCreate_date_as_string().indexOf(" "))%></td>
                                		<td class="details">View</td>
                        		</tr>
                		<%
				}
			}
			%><tr><td colspan="100%">&nbsp;</td></tr><%
                	for (Dataset dataset : privateDatasetsForUser) {
				if (dataset.getDatasetVersions() != null && 
					dataset.getDatasetVersions().length > 0 &&
					selectedGeneList.getOrganism().equalsIgnoreCase(dataset.getOrganism())&&
					dataset.getVisible()) {
				 	//&& dataset.hasVisibleVersions())
					%>
                        		<tr id="<%=dataset.getDataset_id()%>">
                                		<td><%=dataset.getName()%></td>
                                		<td><%=dataset.getCreate_date_as_string().substring(0, dataset.getCreate_date_as_string().indexOf(" "))%></td>
                                		<td class="details">View</td>
                        		</tr>
                		<%
				}
			}
			%>
                	</tbody>
        		</table>
  		</div>

        	<input type="hidden" name="itemIDString" />
        	<input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>"/>
	</form>
	<% } else if (selectedDataset.getDataset_id() != -99 && selectedDatasetVersion.getVersion() == -99) { %>
        	<div class="dataContainer">
		<div id="related_links">
			<div class="action" title="Return to select a different dataset">
				<a class="linkedImg return" href="expressionValues.jsp?itemIDString=-99">
				<%=fiveSpaces%>
				Select Different Dataset
				</a>
			</div>
		</div>
		<div class="viewingPane">
			<div class="viewingTitle">You have selected:</div>
			<div class="listName"><%=selectedDataset.getName()%></div>
		</div>
		<div class="brClear"></div>
                <form name="versionList" action="expressionValues.jsp" method="post">
                        <input type="hidden" name="datasetVersion" />
                        <input type="hidden" name="itemIDString" value="<%=selectedDataset.getDataset_id()%>" />

                	<div class="title">  Versions  </div>
                	<table name="items" id="versions" class="list_base tablesorter" cellpadding="0" cellspacing="3" width="98%">
                        <thead>
                        <tr class="col_title">
                                <th>#</th>
                                <th>Version Name</th>
                                <th>Date Created</th>
                                <th>Grouping Used</th>
                                <th>Number of Groups</th>
                                <th>Normalization Method</th>
                                <th class="noSort">Details</th>
                        </tr>
                        </thead>
                        <tbody>
			<%
                	for (int j=0; j<selectedDataset.getDatasetVersions().length; j++) {
                        	Dataset.DatasetVersion thisVersion = selectedDataset.getDatasetVersions()[j];
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
                                        	<td class="details">View</td>
                                	</tr>
                                	<%
                        	}
                	}

%>
			</tbody>
		</table>
		</div>
		<input type="hidden" name="action" value="" />
		<input type="hidden" name="itemIDString" value="" />
        	<input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>"/>
	</form>
        <% } else if (selectedDataset.getDataset_id() != -99 && selectedDatasetVersion.getVersion() != -99) {
		optionsList.add("download");
	 %>
        	<div class="dataContainer">
		<div id="related_links">
			<div class="action" title="Return to select a different dataset">
				<a class="linkedImg return" href="expressionValues.jsp?itemIDString=-99">
				<%=fiveSpaces%>
				Select Different Dataset
				</a>
			</div>
		</div>
		<div class="viewingPane">
			<div class="viewingTitle">You have selected:</div>
			<div class="listName"><%=selectedDataset.getName()%> v<%=selectedDatasetVersion.getVersion()%></div>
		</div>
		<div class="brClear"></div>
		<div class="menuBar">
        		<div id="tabMenu">
                        	<div id="arrayValues" class="left inlineButton"><a href="#">Array Values</a></div><span>|</span>
                        	<div id="groupValues" class="left inlineButton"><a href="#">Group Means</a></div>
			</div> <!-- tabMenu -->
		</div> <!-- menuBar -->
		<div class="brClear"></div>
		<% if (action != null && action.equals("View") && setOfIdentifiers.size() > 0) { %>
			<div class="scrollable">
				<div id="displayGroupMeans">
					<div class="title">Group Mean Values<BR><span style="font-size:small"><i>Note: The values are log2 transformed gene expression values</i></span></div>
                			<table name="items" id="groupMeans" class="list_base tablesorter" cellpadding="0" cellspacing="3" width="95%">
					<thead>
					<tr class="col_title">
					<%
					String[] fileContents = myFileHandler.getFileContents(new File(groupValuesFileName));
					String[] headers = fileContents[0].split("\t");
					for (int j=0; j<headers.length; j++) {
						%><th><%=headers[j].replaceAll("\"", "")%></th><%
					}
					%></tr></thead><tbody><%
					for (int i=1; i<fileContents.length; i++) {
						String[] columns = fileContents[i].split("\t");
						%><tr><%
						for (int j=0; j<columns.length; j++) {
							%><td><%=columns[j].replaceAll("\"", "")%></td><%
						}
						%></tr><%
					}
					%></tbody></table>
				</div> <!-- displayGroupMeans -->
				<div id="displayArrayValues" style="display:none">
					<div class="title">Individual Array Values</div>
                			<table name="items" id="arrayValues" class="list_base tablesorter" cellpadding="0" cellspacing="3" width="95%">
					<thead>
					<tr class="col_title">
					<%
					fileContents = myFileHandler.getFileContents(new File(individualValuesFileName));
					headers = fileContents[0].split("\t");
					for (int j=0; j<headers.length; j++) {
						%><th><%=headers[j].replaceAll("\"", "")%></th><%
					}
					%></tr></thead><tbody><%
					for (int i=1; i<fileContents.length; i++) {
						String[] columns = fileContents[i].split("\t");
						%><tr><%
						for (int j=0; j<columns.length; j++) {
							%><td><%=columns[j].replaceAll("\"", "")%></td><%
						}
						%></tr><%
					}
					%></tbody></table>
				</div> <!-- displayArrayValues -->
				<BR>
				<form   method="post"
                        		action="expressionValues.jsp"
                        		enctype="application/x-www-form-urlencoded"
                        		name="expressionValuesDownload">
				<center>        
				<input type="hidden" name="itemIDString" value="<%=itemIDString%>">
        			<input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>"/>
				<input type="hidden" name="action" value="" />
				</center>
				</form>
			</div> <!-- scrollable -->
		<% } %>
	<% } %>

  <div class="itemDetails"></div>
  <div class="versionDetails"></div>
  <div class="object_details"></div>
  <div class="load">Loading...</div>

  <script type="text/javascript">
    $(document).ready(function() {
        setupPage();
	setTimeout("setupMain()", 100); 
    });
  </script>

<%@ include file="/web/common/footer.jsp" %>


