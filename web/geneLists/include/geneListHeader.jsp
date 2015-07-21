<%--
 *  Author: Cheryl Hornbaker
 *  Created: Sep, 2008
 *  Description:  This file sets up data for the selected gene list.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/common/session_vars.jsp" %>

<jsp:useBean id="myGeneList" class="edu.ucdenver.ccp.PhenoGen.data.GeneList"/>
<jsp:useBean id="myGeneListAnalysis" class="edu.ucdenver.ccp.PhenoGen.data.GeneListAnalysis"/>
<jsp:useBean id="myIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"/>
<jsp:useBean id="myIdentifier" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.Identifier"/>
<jsp:useBean id="myParameterValue" class="edu.ucdenver.ccp.PhenoGen.data.ParameterValue"> </jsp:useBean>
<%
	String fromQTL = "";
	if (request.getParameter("fromQTL") != null && ((String) request.getParameter("fromQTL")).equals("Y")) {
		log.info("in qtlHeader.jsp. user = " + user);
		fromQTL = "Y";
		request.setAttribute( "selectedMain", "qtlTools" );
	} else {
		log.info("in geneListHeader.jsp. user = " + user + ". gene list = " + selectedGeneList.getGene_list_id());
		request.setAttribute( "selectedMain", "geneListTools" );
	} 

        String geneList = "";
        String geneListDefaultNewName = "";

	//request.setAttribute( "selectedMain", "geneListTools" );
	extrasList.add("viewingPane.css");
	extrasList.add("geneListMain.css");
	extrasList.add("insideTabs.js");
        extrasList.add("common.js");

	Set iDecoderSet = (Set) session.getAttribute("iDecoderSet");
	List noIDecoderList = (List) session.getAttribute("noIDecoderList");

        String[] rErrorMsg = null;
        String rExceptionErrorMsg = "";

        String tall="100em";

%>
