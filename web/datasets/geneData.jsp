<%--
 *  Author: Cheryl Hornbaker
 *  Created: April, 2009
 *  Description:  The web page created by this file allows the user to
 *              download intensity data for a list of genes in a dataset.
 *  Todo:
 *  Modification Log:
 *
--%>
<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>
<jsp:useBean id="myGeneList" class="edu.ucdenver.ccp.PhenoGen.data.GeneList"> </jsp:useBean>

<%
        log.info("in geneData.jsp. user =  "+ user);
        extrasList.add("geneListMain.css");
        extrasList.add("viewingPane.css");
        extrasList.add("geneData.js");
	optionsList.add("download");

        String[] rErrorMsg = null;
        String rExceptionErrorMsg = "";

	%><%@include file="/web/geneLists/include/selectGeneList.jsp"%><%

	%><%@ include file="/web/common/expressionValuesLogic.jsp"%><%

        mySessionHandler.createDatasetActivity("Looked at expression values for dataset", dbConn);
%>

<%pageTitle="Gene expression data";%>

	<%@ include file="/web/common/microarrayHeader.jsp" %>



	<div class="title">Expression Values for a List of Genes in a Dataset</div>
        <div class="page-intro">
                <% if (selectedDataset.getDataset_id() == -99) { %>
                        <p> Click on a dataset to select it for extracting the expression values for the genes in this list.  </p>
                <% } else if (selectedDataset.getDataset_id() != -99 && selectedDatasetVersion.getVersion() == -99) { %>
                        <p> Click on a normalized version of this dataset to select it.  </p>
                <% } else if (selectedDataset.getDataset_id() != -99 && selectedDatasetVersion.getVersion() != -99
				&& selectedGeneList.getGene_list_id() == -99) { %>
                        <p> Click on the gene list for which you would like the expression values.   </p>
                <% } else if (selectedDataset.getDataset_id() != -99 && selectedDatasetVersion.getVersion() != -99 &&
				selectedGeneList.getGene_list_id() != -99) { %>
                        <p> Click the "Array Values" or "Group Means" links to see the different values.   </p>
                <% } %>
        </div> <!-- // end page-intro -->

        <% if (selectedDataset.getDataset_id() == -99) { %>
                <div class="datasetDataContainer">

                <form name="tableList" action="geneData.jsp" method="post">
                        <div class="brClear"> </div>
                        <div class="title">  My Normalized Datasets
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
                                        dataset.getDatasetVersions().length > 0) {
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
                                        dataset.getDatasetVersions().length > 0) {
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

                <input type="hidden" name="itemID" />
        </form>
        <% } else if (selectedDataset.getDataset_id() != -99 && selectedDatasetVersion.getVersion() == -99) { %>
                <div class="datasetDataContainer">
                <div id="related_links">
			<div class="action" title="Return to select a different dataset">
				<a class="linkedImg return" href="geneData.jsp?itemID=-99">
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
                <form name="versionList" action="geneData.jsp" method="post">
                        <input type="hidden" name="datasetVersion" />
                        <input type="hidden" name="itemID" value="<%=selectedDataset.getDataset_id()%>" />

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
                        <% for (int j=0; j<selectedDataset.getDatasetVersions().length; j++) {
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
                <input type="hidden" name="action" value="" />
                <input type="hidden" name="itemIDString" value="" />
	        </form>
                </div>
        <% } else if (selectedDataset.getDataset_id() != -99 && selectedDatasetVersion.getVersion() != -99 && selectedGeneList.getGene_list_id() == -99) { 
        	if (geneListsForUser == null) {
                	log.debug("geneListsForUser not set");
			geneListsForUser = myGeneList.getGeneLists(userID, "All", "All", dbConn);
        	}
%>
                <div class="datasetDataContainer">
                <div id="related_links">
			<div class="action" title="Return to select a different dataset">
				<a class="linkedImg return" href="geneData.jsp?itemID=-99">
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

                <form name="geneList" action="geneData.jsp" method="post">
                        <input type="hidden" name="geneListID" />
                        <input type="hidden" name="itemIDString" value="<%=itemIDString%>" />

                        <div class="title">Gene Lists</div>
                        <table name="items" id="geneLists" class="list_base tablesorter" cellpadding="0" cellspacing="3" width="98%">
                        <thead>
                        <tr class="col_title">
                                <th>Gene List Name</th>
                		<th>Date Created</th>
                		<th>Number of Genes</th>
                		<th>Organism</th>
                		<th>List Source</th>
                		<th class="noSort">Details</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% for (int i=0; i<geneListsForUser.length; i++) {
				GeneList thisGeneList = geneListsForUser[i];
				if ( thisGeneList.getOrganism().equalsIgnoreCase(selectedDataset.getOrganism()) ) {
				%>
				<tr id="<%=thisGeneList.getGene_list_id()%>">
					<td><%=thisGeneList.getGene_list_name()%></td>
                        		<td><%=thisGeneList.getCreate_date_as_string().substring(0, thisGeneList.getCreate_date_as_string().indexOf(" "))%></td>
                        		<td><%=thisGeneList.getNumber_of_genes()%></td>
                        		<td><%=thisGeneList.getOrganism()%></td>
                        		<td><%=thisGeneList.getGene_list_source()%></td>
                        		<td class="details"> View</td>
				</tr>
				<% } %>
			<% } %>
                        </tbody>
                	</table>
                	<input type="hidden" name="action" value="" />
                	<input type="hidden" name="itemIDString" value="<%=itemIDString%>" />
                	<input type="hidden" name="geneListID" value=""/>
			</form>
                </div>
        <% } else if (selectedDataset.getDataset_id() != -99 && selectedDatasetVersion.getVersion() != -99 && selectedGeneList.getGene_list_id() != -99) { %>
                <div class="datasetDataContainer">
                <div id="related_links">
			<div class="action" title="Return to select a different dataset">
				<a class="linkedImg return" href="geneData.jsp?itemID=-99">
				<%=fiveSpaces%>
				Select Different Dataset
				</a>
			</div>
			<div class="action" title="Return to select a different gene list">
				<a class="linkedImg return" href="geneData.jsp?itemIDString=<%=itemIDString%>&geneListID=-99"> 
				<%=fiveSpaces%>
				Select Different Gene List 
				</a>
			</div>
                        <div class="action">
                        </div>
                </div>
                <div class="viewingPane">
                        <div class="viewingTitle">You have selected this dataset:</div>
                        <div class="listName"><%=selectedDataset.getName()%> v<%=selectedDatasetVersion.getVersion()%></div>
			<BR>
                        <div class="viewingTitle">And this gene list:</div>
                        <div class="listName"><%=selectedGeneList.getGene_list_name()%> </div>
                </div>
                <div class="brClear"></div>
                <div class="menuBar">
                        <div id="tabMenu">
                                <div id="arrayValues">Array Values</div><span>|</span>
                                <div id="groupValues">Group Means</div>
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
log.debug("fileContents length = "+fileContents.length);
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
                                        action="geneData.jsp"
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
  <div class="geneListDetails"></div>
  <div class="load">Loading...</div>
  <script type="text/javascript">
    $(document).ready(function() {
        setupPage();
    });
  </script>

<%@ include file="/web/common/footer.jsp" %>



