<html>
<body><%@ include file="templateHeader.jsp"  %><table><%
//	String exp = (request.getParameter("exp") != null ? (String) request.getParameter("exp") : "");
//	int value = myExperiment.isCompoundDesign(exp, dbConn);
//	edu.ucdenver.ccp.PhenoGen.data.Array.ArrayCount[] myCounts = (value != -99 ? myArray.getCompounds("All", "Single", dbConn) : null);
	edu.ucdenver.ccp.PhenoGen.data.Array.ArrayCount[] myCounts = myArray.getCompounds("All", "Single", dbConn); 
	if (myCounts != null) {
		for (int i=0; i<myCounts.length; i++) {
			%><tr><td><%=myCounts[i].getCountName()%></td></tr><%
		}
	} else {
		%><tr><td>N/A</td></tr><%
	}
%></table></body></html>
