<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %>
<%
	extrasList.add("listGeneList.js");
	// Need to include this here, so that it's available on the modal
	extrasList.add("createGeneList.js");
	optionsListModal.add("createGeneList");
	session.setAttribute("selectedGeneList", null);

	int datasetID = ((String) request.getParameter("datasetID") != null ? Integer.parseInt((String) request.getParameter("datasetID")) : -99);
	int datasetVersion = ((String) request.getParameter("datasetVersion") != null ? Integer.parseInt((String) request.getParameter("datasetVersion")) : -99);

        mySessionHandler.createSessionActivity(session.getId(), "Viewed all genelists", dbConn);
	//
        // Get the gene lists which are stored in PhenoGen
        //
        if (datasetID == -99) {
        	if (geneListsForUser == null) {
        		log.debug("getting new geneListsForUser");
                	geneListsForUser = myGeneList.getGeneLists(userID, "All", "All", dbConn); 
        	} else {
                	log.debug("geneListsForUser already set");
        	}
	} else {
                geneListsForUser = myGeneList.getGeneListsForDataset(userID, datasetID, datasetVersion, dbConn); 
	}

%>

<%pageTitle="Analyze gene list";%>

<%@ include file="/web/common/header.jsp"%>
	<script type="text/javascript">
		crumbs = ["Home", "Research Genes"]; 
	</script>
	<div class="page-intro">
		<p>Click on a gene list to select it for further investigation.</p>
	</div> <!-- // end page-intro -->
	<div class="brClear"></div>

	<div class="list_container">
	<form name="chooseGeneList" action="chooseGeneList.jsp" method="get">

		<div class="leftTitle">Gene Lists </div>
		<table name="items" class="list_base tablesorter" cellpadding="0" cellspacing="2" width="98%">
        		<thead>
        		<tr class="col_title">
				<th>Gene List Name</th>
				<th>Date Created</th>
				<th>Number of Genes</th>
				<th>Organism</th>
				<th>List Source
                        		<span class="info" title="Either the dataset that was analyzed to create this gene list, or it's origin.">
                        		<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        		</span>
				</th>
				<th class="noSort" width="8%">Details <span class="info" title="Parameters used in creating this gene list.">
                        		<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        		</span>
				</th>
				<th class="noSort">Delete</th>
				<th class="noSort">Download</th>
        		</tr>
        		</thead>
        		<tbody>

			<%
        		for ( int i = 0; i < geneListsForUser.length; i++ ) {
                		GeneList gl = (GeneList) geneListsForUser[i];  %>
                		<tr id="<%=gl.getGene_list_id()%>" parameterGroupID="<%=gl.getParameter_group_id()%>">
                			<td><%=gl.getGene_list_name()%></td>
                			<td><%=gl.getCreate_date_as_string().substring(0, gl.getCreate_date_as_string().indexOf(" "))%></td>
                			<td><%=gl.getNumber_of_genes()%></td>
                			<td><%=gl.getOrganism()%></td>
                			<td><%=gl.getGene_list_source()%></td>
    					<td class="details"> View</td>
					<td class="actionIcons">
						<div class="linkedImg delete"></div>
					</td>
					<td class="actionIcons">
						<div class="linkedImg download"></div>
					</td>
				</tr>
			<% } %>
			</tbody>
		</table>
		<input type="hidden" name="geneListID" />
		<input type="hidden" name="action" value="" />
		<input type="hidden" name="fromQTL" value="<%=fromQTL%>" />
	</form>
	</div>
	<div class="itemDetails"></div>
	<div class="newGeneList"></div>
	<div class="deleteItem"></div>
	<div class="downloadItem"></div>
	<div class="load">Loading...</div>
	<script type="text/javascript">
		$(document).ready(function() {
			setupPage();
			setTimeout("setupMain()", 100); 
		});
	</script>

<%@ include file="/web/common/footer.jsp"%>
