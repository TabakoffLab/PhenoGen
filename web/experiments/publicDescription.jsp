<%--
 *  Author: Cheryl Hornbaker
 *  Created: Feb, 2010
 *  Description:  The web page created by this file displays the description of a public protocol 
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/experiments/include/experimentHeader.jsp"  %>
<%

/*
	String title = (request.getParameter("title") != null && !((String) request.getParameter("title")).equals("") ? 
				(String) request.getParameter("title") : "");
*/
	String protocolID = (request.getParameter("protocolID") != null && !((String) request.getParameter("protocolID")).equals("") ? 
				(String) request.getParameter("protocolID") : "-99");

	int globid = Integer.parseInt(protocolID);
	Protocol publicProtocol = new Protocol().getPublicProtocolByGlobid(globid, dbConn);
	String description = publicProtocol.getProtocol_description();
	mySessionHandler.createExperimentActivity("Viewed description of public protocol: " + protocolID, dbConn); 

	log.debug("in publicDescripton.jsp. protocolID = " + protocolID); 
%>
	<table><tr><td><%=description%></td></tr></table>
<div class="closeWindow">Close</div>
