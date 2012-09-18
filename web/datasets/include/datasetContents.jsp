<%
                        int thisDatasetID = dataset.getDataset_id();
			String chooseDatasetString = "<a href='"+datasetsDir + "chooseDataset.jsp?datasetID=" + thisDatasetID;
                        String qcLink = (dataset.getName().indexOf("(Pending)") > 0 ? "" : chooseDatasetString + "&goTo=QC'>Run</a>");
                        String qcResultsLink = chooseDatasetString + "&goTo=QCResults'>Review Results</a>";
                        String normalizeLink = chooseDatasetString + "&goTo=versions'>Run</a>";
                        //String normalizeLink = "";
                        //String geneListsLink = "<a href='"+geneListsDir + "geneLists.jsp?datasetID=" + thisDatasetID + "'>" +  checkMark + "</a>";
                        String clusterLink = chooseDatasetString + "&goTo=ClusterResults'>" + resultsIcon + "</a>";
                        String phenotypeLink = chooseDatasetString + "&goTo=Phenotype'>" + resultsIcon + "</a>";
                        String geneListLink = chooseDatasetString + "&goTo=GeneList'>" + resultsIcon + "</a>";
						String filterStatLink = chooseDatasetString + "&goTo=versions'>" + resultsIcon + "</a>";
                        String qualityControlResults = 
                                (dataset.getQc_complete().equals("Y") ||
                                        dataset.getQc_complete().equals("O") ||
                                        dataset.getQc_complete().equals("I") ?
				chooseDatasetString + "&goTo=QCResults'>" + resultsIcon + "</a>" : "");
                        String qualityControl =
                                (dataset.getQc_complete().equals("Y") ||
                                        dataset.getQc_complete().equals("O") ||
                                        dataset.getQc_complete().equals("I") ?
                                checkMark : (dataset.getQc_complete().equals("1") ?
                                                "In Progress" : 
							(dataset.getQc_complete().equals("R") ?
                                                	qcResultsLink : 
								(dataset.getQc_complete().equals("N") ?
                                                		qcLink : ""))));
                        String normalized = "";
			if (dataset.getDatasetVersions().length > 0 ) {
				for (int j=0; j<dataset.getDatasetVersions().length; j++) {
					if (dataset.getDatasetVersions()[j].getVisible() == 1) {
						normalized = checkMark; 
						break;
					}
				}
				normalized = (normalized.equals("") ? "In Progress" : normalized);
			} else if (dataset.getQc_complete().equals("Y") || dataset.getQc_complete().equals("I")) { 
				normalized = normalizeLink;
			}

			String phenotypeData =
					(dataset.hasPhenotypeData(userLoggedIn.getUser_id()) == true ?
							phenotypeLink : "");

			String clusterResults =
					(dataset.hasClusterResults(userLoggedIn.getUser_id()) == true  ?
							clusterLink : "");

			String geneLists =
					(dataset.hasGeneLists() == true ?
							geneListLink : "");
			String filterStatsResults="N/A";
			
			if (new edu.ucdenver.ccp.PhenoGen.data.Array().EXON_ARRAY_TYPES.contains(dataset.getArray_type())) {				
				filterStatsResults = (dataset.hasFilterStatsResults(userLoggedIn.getUser_id(),dbConn) == true ? filterStatLink : "");
			}
						
			if(dataset.getVisible()){
			%>
        		<tr id="<%=dataset.getDataset_id()%>">
				<td><%=dataset.getName()%></td>
				<td><%=dataset.getCreate_date_as_string().substring(0, dataset.getCreate_date_as_string().indexOf(" "))%></td>
				<td><%=qualityControl%></td>
				<td><%=normalized%></td>
				<td class="actionIcons"><%=phenotypeData%></td>
				<td class="actionIcons"><%=qualityControlResults%></td>
                <td class="actionIcons"><%=filterStatsResults%></td>
				<td class="actionIcons"><%=clusterResults%></td>
				<td class="actionIcons"><%=geneLists%></td>
    				<td class="details">View</td>
				<% if (!dataset.getCreator().equals("public")) { %>
					<td class="actionIcons">
						<div class="linkedImg delete"></div>
					</td>
				<% } %>
				<td class="actionIcons">
					<% if (dataset.getName().indexOf("(Pending)") == -1) { %>
						<div class="linkedImg download"></div>
					<% } %>
				</td>
			</tr>
            
			<% } else {%>
            	<tr id="<%=dataset.getDataset_id()%>">
				<td><%=dataset.getName()%></td>
				<td><%=dataset.getCreate_date_as_string().substring(0, dataset.getCreate_date_as_string().indexOf(" "))%></td>
				<td colspan="9"><%= dataset.getVisibleNote() %></td>
				</tr>
            <% } %>
