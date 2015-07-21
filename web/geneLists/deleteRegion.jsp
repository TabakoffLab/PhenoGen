<%--
 *  Author: Cheryl Hornbaker
 *  Created: Apr, 2009
 *  Description:  This file handles deleting a QTL list
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/common/session_vars.jsp" %>

<%
	int itemID = (request.getParameter("itemID") == null ? -99 : Integer.parseInt((String) request.getParameter("itemID")));

	log.info("in deleteRegion.jsp. user = " + user + ", itemID = "+itemID);

        	try {
			new QTL().deleteQtlList(itemID, dbConn);
			mySessionHandler.createSessionActivity(session.getId(), "Deleted QTL list:" + itemID, pool);
        	} catch( Exception e ) {
            		throw e;
        	}
%>
