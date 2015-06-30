<%@ include file="/web/common/session_vars.jsp" %>

<%
        int itemID = -99;

        String id="";
	if(request.getParameter("geneListAnalysisID")!=null){
		id=request.getParameter("geneListAnalysisID");
                itemID = Integer.parseInt(id);
	}
        
        String type = ((String)request.getParameter("type") != null ? (String) request.getParameter("type") : "");
	if (itemID != -99) {
		if (type.equals("oPOSSUM")) {
			response.sendRedirect("promoterResults.jsp?itemID="+itemID);
		} else if (type.equals("Upstream")) {
			response.sendRedirect("upstreamExtractionResults.jsp?itemID="+itemID);
		} else {
			response.sendRedirect("memeResults.jsp?itemID="+itemID);
		}
	}
%>