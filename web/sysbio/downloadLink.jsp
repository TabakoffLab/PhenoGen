<%--
 *  Author: Cheryl Hornbaker
 *  Created: Jan, 2011
 *  Description:  The web page created by this file allows the user to download resource files.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/common/session_vars.jsp"  %>

<%
	
	String url = (request.getParameter("url") == null ? "" : (String) request.getParameter("url"));
	try{
		mySessionHandler.createActivity("Downloaded file: " + url,dbConn);
	}catch(Exception e){
		log.error("Error creating session activity(Downloads).", e);
	}
	response.sendRedirect(url);
%>

	