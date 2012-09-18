<html>
<body><%@ include file="templateHeader.jsp"  %><table><%
	String exp = (request.getParameter("exp") != null ? (String) request.getParameter("exp") : "");
	String type = (request.getParameter("type") != null ? (String) request.getParameter("type") : "");
	log.debug("exp = "+exp + ", type = "+type);
	Experiment_protocol[] myExperiment_protocols = myExperiment_protocol.getExperiment_protocolsByType(exp, type, dbConn); 
        Protocol[] myPublicProtocols = myProtocol.getPublicProtocols(dbConn);
	if (myExperiment_protocols != null && myExperiment_protocols.length > 0) {
		for (int i=0; i<myExperiment_protocols.length; i++) {
			String protocolName = myExperiment_protocols[i].getProtocolName();
			String globid = myExperiment_protocols[i].getGlobid();
			if (globid != null && !globid.equals("")) {
				Protocol thisTprotcl = myProtocol.getProtocolByGlobid(Integer.parseInt(globid), myPublicProtocols);
				%><tr><td><%=thisTprotcl.getProtocol_description()%></td></tr><%
			} else {
				%><tr><td><%=myExperiment_protocols[i].getProtocolName()%></td></tr><%
			}
		}
	} else {
		%><tr><td>None</td></tr><%
	}
%></table></body></html>
