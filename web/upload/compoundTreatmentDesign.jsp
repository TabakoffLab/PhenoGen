<html>
<body><%@ include file="templateHeader.jsp"  %><table><%
	String exp = (request.getParameter("exp") != null ? (String) request.getParameter("exp") : "");
	int value = myExperiment.isCompoundDesign(exp, dbConn);
	edu.ucdenver.ccp.PhenoGen.data.Array.ArrayCount[] myCounts = (value != -99 ? myArray.getCompounds("All", "Single", dbConn) : null);
	if (value != -99) {
		%><tr><td>Yes</td></tr><%
	} else {
		%><tr><td>No</td></tr><%
	}
%></table></body></html>
