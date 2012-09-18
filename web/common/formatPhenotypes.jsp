	<div class="list_container">
		<div class="leftTitle">  Phenotype Values 
		<% if (formName.equals("correlation") || formName.equals("phenotypes")) { %>
			(Matching 5 or more strains)
		<% } else if (formName.equals("calculateQTLs")) { %>
			(Matching 15 or more strains)
		<% } %>
		</div>
		<table name="items" class="list_base tablesorter" width="99%">
			<thead>
				<tr class="col_title">
					<% if (formName.equals("phenotypes") && selectedDatasetVersion.getVersion() == -99) { %>
						<th>Dataset Versions</th>
						<th>Grouping Name</th>
					<% } %>
					<th>Phenotype Name</th>
					<th>Description</th>
					<th class="noSort">Details</th>
					<th class="noSort">Delete</td>
					<th class="noSort">Download</td>
				</tr>
			</thead>
			<tbody>
                        <%
			if (myPhenotypes != null && myPhenotypes.length > 0) { 
                        	for (ParameterValue.Phenotype thisPhenotype : myPhenotypes) { 
					if ((formName.equals("correlation") && thisPhenotype.getGroupsWithExpressionData() > 0) || 
						formName.equals("phenotypes") ||
						(formName.equals("calculateQTLs") && thisPhenotype.getGroupsWithGenotypeData() > 14)) {
						%>
                                        	<tr id="<%=thisPhenotype.getParameter_group_id()%>">
							<% 
							if (formName.equals("phenotypes") && selectedDatasetVersion.getVersion() == -99) {
								List<String> versions = new ArrayList<String>();
								for (Dataset.DatasetVersion thisVersion : selectedDataset.getDatasetVersions()) {
									if (thisVersion.getGrouping_id() == thisPhenotype.getGrouping_id()) {
										versions.add(Integer.toString(thisVersion.getVersion()));	
									}
								}
								String versionString = myObjectHandler.getAsSeparatedString(versions, ",");
							 	%> <td><%=versionString%><BR></td> <%
								String groupingName = selectedDataset.new Group().getGrouping(thisPhenotype.getGrouping_id(), dbConn).getGrouping_name();
							%><td><%=groupingName%><%
							} 
							%>
                                        		<td><%=thisPhenotype.getName()%></td>
                                                	<td><%=thisPhenotype.getDescription()%></td>
							<td class="details">View </td>
							<td class="actionIcons">
								<div class="linkedImg delete"></div>
							</td>
							<td class="actionIcons">
								<div class="linkedImg download"></div>
							</td>
						</tr> <%
					}
				}
			} else { 
				%> <tr><td colspan="100%" align="center"><h2>No Phenotype Data Exists For This Grouping of Arrays</h2></td></tr> <% 
			} %>
			</tbody>
		</table>
	</div>
