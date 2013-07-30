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
		extrasList.add("jquery.dataTables.js");
		extrasList.add("jquery.tooltipster.js");
		extrasList.add("tooltipster.css");
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
        if (selectedDataset.getDataset_id() != -99 && selectedDatasetVersion.getVersion() != -99) {
		optionsList.add("download");
	}

	request.setAttribute( "selectedTabId", "expressionValues" );

        mySessionHandler.createGeneListActivity("Looked at expression values for gene list", dbConn);
		
	GeneList.Gene[] myGeneArray = selectedGeneList.getGenesAsGeneArray(dbConn);
	HashMap<String,String> geneSymbolsHM=new HashMap<String,String>();
	for (int i=0; i<myGeneArray.length; i++) {
					String geneSymbolList="";
					Identifier thisIdentifier = myIdentifier.getIdentifierFromSet(myGeneArray[i].getGene_id(), iDecoderSet); 			
					if (thisIdentifier != null) {
						myIDecoderClient.setNum_iterations(3);
						Set geneSymbols = myIDecoderClient.getIdentifiersForTargetForOneID(thisIdentifier.getTargetHashMap(), 
												new String[] {"Gene Symbol"});
						if (geneSymbols.size() > 0) { 						
							for (Iterator symbolItr = geneSymbols.iterator(); symbolItr.hasNext();) { 
								Identifier symbol = (Identifier) symbolItr.next();                					
								geneSymbolList=geneSymbolList+symbol.getIdentifier() + "<BR>";
							}
						}
					}
					geneSymbolsHM.put(myGeneArray[i].getGene_id(),geneSymbolList);            
	}
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
                	<table name="items" id="groupMeans" class="list_base" cellpadding="0" cellspacing="3" width="95%">
					<thead>
					<tr class="col_title">
                    	<TH>Gene Symbol</TH>
					<%
					String[] fileContents = myFileHandler.getFileContents(new File(groupValuesFileName));
					String[] headers = fileContents[0].split("\t");
					for (int j=0; j<headers.length; j++) {
						%><th><%=headers[j].replaceAll("\"", "")%>
                        <%if(j==0){%>
                        	<span class="toolTip" title="This is the Gene Identifier from the current gene list.  The identifier was used to find a gene.  From the gene all the probesets in the current dataset/version annotated as that gene were found.  These are the probesets in the next column. <BR><BR><b>NOTE: This list has most likely expanded from your original list.  If you started with probeset IDs from the current dataset, then the IDs from your original list have the same ID in this column and the next column.</b>"><img src="<%=imagesDir%>icons/info.gif"></span>
						<%}else if(j==1){%>
                        	<span class="toolTip" title="These are all of the probesets in the current dataset/version associated with the gene symbol/gene id in the previous 2 columns.  <BR><BR><b>NOTE: This list has most likely expanded from your original list.  If you started with probeset IDs from the current dataset, then the IDs from your original list have the same ID in this column and the previous column.</b>"><img src="<%=imagesDir%>icons/info.gif"></span>
						<%}%>
                        </th><%
					}
					%></tr></thead><tbody><%
					for (int i=1; i<fileContents.length; i++) {
						String[] columns = fileContents[i].split("\t");
						%><tr>
                        <TD>
                        	<%=geneSymbolsHM.get(columns[0])%>
                        </TD>
						<%
						for (int j=0; j<columns.length; j++) {
							%><td><%=columns[j].replaceAll("\"", "")%></td><%
						}
						%></tr><%
					}
					%></tbody></table>
				</div> <!-- displayGroupMeans -->
				<div id="displayArrayValues" style="display:none">
					<div class="title">Individual Array Values</div>
                			<table name="items" id="arrayValues" class="list_base" cellpadding="0" cellspacing="3" width="95%">
					<thead>
					<tr class="col_title">
                    	<TH>Gene Symbol</TH>
					<%
					fileContents = myFileHandler.getFileContents(new File(individualValuesFileName));
					headers = fileContents[0].split("\t");
					for (int j=0; j<headers.length; j++) {
						%><th><%=headers[j].replaceAll("\"", "")%>
                        <%if(j==0){%>
                        	<span class="toolTip" title="This is the Gene Identifier from the current gene list.  The identifier was used to find a gene.  From the gene all the probesets in the current dataset/version annotated as that gene were found.  These are the probesets in the next column. <BR><BR><b>NOTE: This list has most likely expanded from your original list.  If you started with probeset IDs from the current dataset, then the IDs from your original list have the same ID in this column and the next column.</b>"><img src="<%=imagesDir%>icons/info.gif"></span>
						<%}else if(j==1){%>
                        	<span class="toolTip" title="These are all of the probesets in the current dataset/version associated with the gene symbol/gene id in the previous 2 columns.  <BR><BR><b>NOTE: This list has most likely expanded from your original list.  If you started with probeset IDs from the current dataset, then the IDs from your original list have the same ID in this column and the previous column.</b>"><img src="<%=imagesDir%>icons/info.gif"></span>
						<%}%>
                        </th><%
					}
					%></tr></thead><tbody><%
					for (int i=1; i<fileContents.length; i++) {
						String[] columns = fileContents[i].split("\t");
						%><tr>
						<TD>
                        	<%=geneSymbolsHM.get(columns[0])%>
                        </TD>
						<%
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
 	 var arrayVAdjust=0;
	 var arrayV;
    $(document).ready(function() {
		
		
        setupPage();
		setTimeout("setupMain()", 100);
		
			$("table[id='groupMeans']").dataTable({
					"bPaginate": false,
					"bProcessing": true,
					"bStateSave": false,
					"bAutoWidth": true,
					"sScrollX": "950px",
					"sScrollY": "550px",
					"aaSorting": [[ 1, "asc" ]],
					/*"aoColumnDefs": [
					  { "bVisible": false, "aTargets": geneTargets }
					],*/
					"sDom": '<"leftSearch"fr><t>'
					/*"oTableTools": {
							"sSwfPath": "/css/swf/copy_csv_xls_pdf.swf"
						}*/
	
			});
			arrayV=$("table[id='arrayValues']").dataTable({
					"bPaginate": false,
					"bProcessing": true,
					"bStateSave": false,
					"bAutoWidth": true,
					"sScrollX": "950px",
					"sScrollY": "550px",
					"aaSorting": [[ 1, "asc" ]],
					/*"aoColumnDefs": [
					  { "bVisible": false, "aTargets": geneTargets }
					],*/
					"sDom": '<"leftSearch"fr><t>'
					/*"oTableTools": {
							"sSwfPath": "/css/swf/copy_csv_xls_pdf.swf"
						}*/
	
			});
			
			$('.toolTip').tooltipster({
							position: 'top-right',
							maxWidth: 350,
							offsetX: 24,
							offsetY: 5,
							//arrow: false,
							interactive: true,
							interactiveTolerance: 350
						});
    });
  </script>

<%@ include file="/web/common/footer.jsp" %>


