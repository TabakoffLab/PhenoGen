<%--
 *  Author: Cheryl Hornbaker
 *  Created: Oct, 2007
 *  Description:  This file handles deleting a cluster result
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>
<%

	log.debug("action = "+action);

	if (action != null && action.equals("Delete")) {
        	if (userLoggedIn.getUser_name().equals("guest")) {
                	//Error - "Feature not allowed for guests"
                	session.setAttribute("errorMsg", "GST-005");
                	response.sendRedirect(commonDir + "errorMsg.jsp");
        	} else {
                	log.debug("deleting Cluster Results");
                	log.debug("deleting clusterID "+itemID);
			Dataset.DatasetVersion thisDatasetVersion = 
				selectedDataset.getDatasetVersionForParameterGroup(itemID, dbConn);
			analysisPath = thisDatasetVersion.getClusterDir() +  
					userName + "/" + itemID + "/";
                	log.debug("analysisPath = "+analysisPath);
			selectedDataset.deleteClusterAnalysis(
				itemID, analysisPath, dbConn);
			mySessionHandler.createDatasetActivity("Deleted Cluster Analysis for clusterGroupID = " + itemID, dbConn);
			//Success - "Cluster analysis deleted"
			session.setAttribute("successMsg", "EXP-029");
			response.sendRedirect(commonDir + "successMsg.jsp");
		}

        }
%>
	<center><h2> Delete Cluster Results?</h2></center>
		<form	method="post" 
			action="deleteClusterResults.jsp" 
			enctype="application/x-www-form-urlencoded"
			name="deleteClusterResults">

			<BR> <BR>
			<center> <input type="submit" name="action" value="Delete" onClick="return confirmDelete()"></center>
			<input type="hidden" name="itemID" value="<%=itemID%>">
			<input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>">
			<input type="hidden" name="datasetVersion" value="<%=selectedDatasetVersion.getVersion()%>">
		</form>
