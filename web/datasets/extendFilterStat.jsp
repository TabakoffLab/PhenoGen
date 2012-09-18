<%--
 *  Author: Spencer Mahaffey
 *  Created: Mar, 2012
 *  Description:  This file handles extending the Expiration Date of Filter/Statistic Results
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>
<%
   String itemIDString = (request.getParameter("itemIDString") == null ? 
				(request.getParameter("itemID") == null ? "-99": (String) request.getParameter("itemID")) :
				(String) request.getParameter("itemIDString"));

	log.debug("action = "+action);
	
	DSFilterStat dsfs=selectedDatasetVersion.getFilterStat(Integer.parseInt(itemIDString),userLoggedIn.getUser_id(),dbConn);
	dsfs.extend(dbConn);
	mySessionHandler.createDatasetActivity("Extended Expiration Filter/Stats results for Dataset_Filter_Stat_ID = " + itemID, dbConn);
	session.setAttribute("successMsg", "EXP-056");
	response.sendRedirect(commonDir + "successMsg.jsp");
%>