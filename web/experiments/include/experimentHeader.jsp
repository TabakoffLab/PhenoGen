<%--
 *  Author: Cheryl Hornbaker
 *  Created: Mar, 2010
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/common/session_vars.jsp"  %>

<jsp:useBean id="myValidTerm" class="edu.ucdenver.ccp.PhenoGen.data.ValidTerm" > </jsp:useBean>
<jsp:useBean id="myExperiment" class="edu.ucdenver.ccp.PhenoGen.data.Experiment" > </jsp:useBean>
<jsp:useBean id="myDataset" class="edu.ucdenver.ccp.PhenoGen.data.Dataset" > </jsp:useBean>
<%
	//log.info("in experimentHeader.jsp. user = " + user);

	request.setAttribute( "selectedMain", "microarrayTools" );
        extrasList.add("experimentMain.css");
        extrasList.add("viewingPane.css");
        extrasList.add("common.js");
        extrasList.add("insideTabs.js");

	int itemID = (request.getParameter("itemID") == null ? -99 : Integer.parseInt((String) request.getParameter("itemID")));
%>



