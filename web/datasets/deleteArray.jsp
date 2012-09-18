<%--
 *  Author: Cheryl Hornbaker
 *  Created: Apr, 2009
 *  Description:  This file handles deleting an array during review of quality control results
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>

<%
	log.info("in deleteArray.jsp. user = " + user + ", itemID = "+itemID + ", datasetID = "+selectedDataset.getDataset_id());

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-005");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }

	log.debug("action = "+action);
	// can also pass action of "Delete" in on URL
        if (action != null && (action.equals("Delete Array") || action.equals("Delete"))) {
        	try {
			selectedDataset.deleteDataset_chip(userID, itemID, dbConn);

			// Have to re-set selectedDataset without the chip
			int datasetID = selectedDataset.getDataset_id();
			%><%@ include file="/web/datasets/include/setupDataset.jsp"%><%

			session.setAttribute("selectedDataset", selectedDataset);

			mySessionHandler.createDatasetActivity("Deleted array " + itemID+
                                        	" while viewing Quality Control Results for dataset '" +
                                        	selectedDataset.getName() + "'",
                                	dbConn);

                	//Success - "Array deleted"
                	session.setAttribute("successMsg", "EXP-020");
                	response.sendRedirect(commonDir + "successMsg.jsp");
        	} catch( Exception e ) {
            		throw e;
        	}
	}
%>

	<form	method="post" 
		action="deleteArray.jsp" 
		enctype="application/x-www-form-urlencoded"
		name="deleteArray">

		<BR> <BR>
		<center> <input type="submit" name="action" value="Delete Array" onClick="return confirmDelete()"></center>
		<input type="hidden" name="itemID" value="<%=itemID%>">
		<input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>">
	</form>
