<%--
 *  Author: Cheryl Hornbaker
 *  Created: Sep, 2007
 *  Description:  The web page created by this file displays the genes belonging to a certain cluster
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/analysisHeader.jsp"  %>

<%
	log.info("in clusterDetails.jsp. user =  "+ user);
	
	String clusterNumber = (String) request.getParameter("clusterNumber");
	String clusterObject = ((String) request.getParameter("clusterObject") != null ?
				(String) request.getParameter("clusterObject") : "");		
	String numGroups = (String) request.getParameter("numGroups");
	String level = ((String) request.getParameter("level") != null ?
				(String) request.getParameter("level") : "");		
	String clusterGroupID = ((String) request.getParameter("clusterGroupID") != null ?
				(String) request.getParameter("clusterGroupID") : "");		
	selectedDatasetVersion = selectedDataset.getDatasetVersionForParameterGroup(Integer.parseInt(clusterGroupID), dbConn);
	analysisType = "cluster";

	log.debug("cluster dir = "+selectedDatasetVersion.getClusterDir());
        analysisPath = (level.equals("all") ?  selectedDatasetVersion.getClusterDir() +
                                		userName + "/" +
                                		clusterGroupID + "/" : 
						analysisPath);

	log.debug("numGroups = "+numGroups + ", level = " + level + ", analysisPath = "+analysisPath);

	String[] clusterGenes = myFileHandler.getFileContents(new File(analysisPath + "Cluster" + clusterNumber + ".txt"), "withSpaces");

	mySessionHandler.createDatasetActivity("Viewed clusterDetails for cluster # '" + clusterNumber +  "'", dbConn);

%>

<%@ include file="/web/common/externalWindowHeader.jsp" %>

	<div class="scrollable">
        	<form   method="post"
                        action="clusterDetails.jsp"
                        enctype="application/x-www-form-urlencoded"
                        name="clusterDetails">
		<div class="title">Cluster Results for Cluster <%= clusterNumber %>
			<% 
			String imageFileName = "Cluster" + clusterNumber + ".png";
			if ((new File(analysisPath + imageFileName)).exists()) {
				String path = myFileHandler.getPathFromUserFiles(analysisPath);
				%><%=fiveSpaces%><a href="clusterImages.jsp?imageFile=<%=imageFileName%>&path=<%=path%>" target="Cluster Images">View Graph</a><%	
			}
 %>
		</div>
		<table name="items" class="list_base tablesorter" cellpadding="0" cellspacing="3">
			<thead>
			<tr class="col_title">
				<%
				String[] lineElements = clusterGenes[0].split("\t");
        			for (int j=0; j<lineElements.length; j++) {
        				%><th><%=lineElements[j]%></th><%
				}
				%>
			</tr>
			</thead>
			<tbody>
			<%
			    // rowStart is initialized to 2 because the first row is just the cluster number and not the result, also we dont want to include it in the sorting
                int rowStart = 2;
				if (clusterObject.equalsIgnoreCase("genes")){
				    rowStart = 1;
				}			
			
        		for (int i=rowStart; i<clusterGenes.length; i++) {
        			%> <tr> <%
                		lineElements = clusterGenes[i].split("\t");
                		for (int j=0; j<lineElements.length; j++) {
					if (j==0) {
						%> <td class=right> <%=lineElements[j]%> </td> <%
					} else {
						%> <td class=right> <%=new DecimalFormat("###.###").format(Double.parseDouble(lineElements[j]))%> </td> <%
					}
				}
			%> </tr> <%
			} %>
			</tbody>
        	</table>
	
        <input type="hidden" name="clusterGroupID" value="<%=clusterGroupID%>">
        <input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>">
        <input type="hidden" name="datasetVersion" value="<%=selectedDatasetVersion.getVersion()%>">
        <input type="hidden" name="analysisType" value="<%=analysisType%>">
        <input type="hidden" name="clusterNumber" value="<%=clusterNumber%>">
        <input type="hidden" name="numGroups" value="<%=numGroups%>">
	</form>
	</div>

<%@ include file="/web/common/externalWindowFooter.html" %>
	
