<%--
 *  Author: Cheryl Hornbaker
 *  Created: Oct, 2007
 *  Description:  This file is included in clusterResults.jsp to display the cluster results
 *			NOTE: analysisPath, and clusterObjectText must be set in calling program
 *  Todo:
 *  Modification Log:
 *
--%>
		<BR><BR>

                <%
		//log.debug("caller = "+caller);
		if ((new File(analysisPath + "ClusterSummary.txt")).exists() || 
                	(new File(analysisPath + "Heatmap.png")).exists()) {
			%>
                        <div class="title">Cluster Results
				<% if (level.equals("Summary")) { %>
                        		<div class="inlineButton" id="saveClusterResults"> Save Results</div>
				<% } else if (clusterObject.equals("samples") && 
        					!userLoggedIn.getUser_name().equals("guest") 
						&& level.equals("all")
						) { %>
						<BR><BR>
						<div class="inlineButton" id="saveGeneList"> Save Gene List</div> 
				<% } %> 
			</div>
				<div class="brClear"></div>
				<div class="scrollable">
				<table name="items" class="list_base tablesorter" cellpadding="0" cellspacing="3">
				<thead>
                        	<tr class="col_title">
					<td>
					<%
                        			String imageFileName = "Dendogram.png";
                        			if ((new File(analysisPath + imageFileName)).exists()) {
							String path = myFileHandler.getPathFromUserFiles(analysisPath);
                                			%>
							<div>
							<a href="clusterImages.jsp?imageFile=<%=imageFileName%>&path=<%=path%>" target="Cluster Images">View Dendrogram</a>
							</div>
							<%
                        			} else {
							%>&nbsp;<%
						}
					%> </td> <% 
		} 
                                
                if ((new File(analysisPath + "ClusterSummary.txt")).exists()) {
                        String[] clusterResults =
                                myFileHandler.getFileContents(new File(analysisPath + "ClusterSummary.txt"), "withSpaces");
                        String[] clusterNumbers = clusterResults[0].split("\t");
                        String[] numberProbes = clusterResults[1].split("\t");
                        for (int j=1; j<clusterNumbers.length; j++) {
 				String resultsLink = "<a href='clusterDetails.jsp?datasetID=" + selectedDataset.getDataset_id() +
						"&datasetVersion=" + selectedDatasetVersion.getVersion() +
						"&clusterNumber="+ clusterNumbers[j] +
						"&numGroups=" + numberProbes[j] +
						"&clusterObject=" + clusterObject + 
						"&clusterGroupID=" + newParameterGroupID + 
						"&level=" + level + "'";
                                %><th class="noSort right"><%=resultsLink%> target="Cluster Details"> 
					Cluster #&nbsp;<%=clusterNumbers[j]%></a><BR>
					contains&nbsp; <%=numberProbes[j]%>&nbsp;<%=clusterObjectText%>
					<% 
					// Decided they can only save gene lists by the cluster after
					// they have saved the cluster results because when 
					// when saving on a modal, the successMsg redirects back to the caller, 
					// which is cluster.jsp, not saveClusterGeneList.  So the 
					// same results might not happen again.  Therefore, user has to save results
					// before being able to save individual cluster gene lists.
					if (clusterObject.equals("genes") && level.equals("all")){ %> 
						<BR><BR>
						<div class="inlineButton" name="saveClusterGeneList" id="<%=clusterNumbers[j]%>">Save Gene List</div> 
					<% } 
                        } 
			%> 
			</tr>
			<% if (level.equals("all")) { %>
                        	<tr class="col_title">
					<th class="right">Probe ID</th>
                        		<%
                        		for (int j=1; j<clusterNumbers.length; j++) {
                                		%><th class="right">Mean</th><%
                        		}
                        	%></tr></thead><tbody>
				<% 
				for (int i=2; i<clusterResults.length; i++) { %> 
					<tr> 
					<%
                                	String[] lineElements = clusterResults[i].split("\t");
                                	for (int j=0; j<lineElements.length; j++) {
                                        	if (j != 0) {
                                                	%> <td class="right"> <%=new DecimalFormat("###.###").format(Double.parseDouble(lineElements[j]))%> </td> <%
                                        	} else {
                                                	%> <td class="right"> <%=lineElements[j]%> </td> <%
                                        	}
                                	}
                                	%> </tr> <%
                        	}
                        	%></tbody><%
			} else {
				%></thead><tbody></tbody><%
			} %>	
			</table>
		</div> <%
                } else if ((new File(analysisPath + "Heatmap.png")).exists()) {
                        String imageFileName = "Heatmap.png";
                        if ((new File(analysisPath + imageFileName)).exists()) { 
				String path = myFileHandler.getPathFromUserFiles(analysisPath);
			%>
				<td> <a href="clusterImages.jsp?imageFile=<%=imageFileName%>&path=<%=path%>" target="Cluster Images">View Heatmap</a>
				</td>
                        <% } %>
			</tr></thead><tbody></tbody></table>
			</div><%
                }
%>

