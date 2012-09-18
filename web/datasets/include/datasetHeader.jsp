<%--
 *  Author: Cheryl Hornbaker
 *  Created: Jan, 2009
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/common/session_vars.jsp"  %>

<jsp:useBean id="myDataset" class="edu.ucdenver.ccp.PhenoGen.data.Dataset"> </jsp:useBean>
<jsp:useBean id="myParameterValue" class="edu.ucdenver.ccp.PhenoGen.data.ParameterValue" > </jsp:useBean>

<%
	//log.info("in datasetHeader.jsp. user = " + user);

	request.setAttribute( "selectedMain", "microarrayTools" );
        extrasList.add("datasetMain.css");
        extrasList.add("viewingPane.css");
	extrasList.add("messageBars.css");
        extrasList.add("common.js");
        extrasList.add("datasetMain.js");
        extrasList.add("insideTabs.js");
		
        String datasetQueryString = "?datasetID=" + selectedDataset.getDataset_id();

	int itemID = (request.getParameter("itemID") == null ? -99 : Integer.parseInt((String) request.getParameter("itemID")));
%>



