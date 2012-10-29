<%--
 *  Author: Spencer Mahaffey
 *  Created: Dec, 2011
 *  Description:  This file sets up the header for the exon screens
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/common/session_vars.jsp"  %>


<jsp:useBean id="myGeneList" class="edu.ucdenver.ccp.PhenoGen.data.GeneList"/>
<jsp:useBean id="myIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"/>
<jsp:useBean id="myIdentifier" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.Identifier"/>

<jsp:useBean id="myStatistic" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.Statistic">
        <jsp:setProperty name="myStatistic" property="RFunctionDir" value="<%=rFunctionDir%>" />
        <jsp:setProperty name="myStatistic" property="session" value="<%=session%>" />
</jsp:useBean>

<jsp:useBean id="myParameterValue" class="edu.ucdenver.ccp.PhenoGen.data.ParameterValue"> </jsp:useBean>

<%

        //log.info("in qtlHeader.jsp. user = " + user);
		//request.setAttribute( "selectedMain", "exonTools" );

        extrasList.add("common.js");
		
		Set iDecoderSet = (Set) session.getAttribute("iDecoderSet");
		//List noIDecoderList = (List) session.getAttribute("noIDecoderList");

	%><% //@include file="/web/datasets/include/selectDataset.jsp"%><%

        String[] rErrorMsg = null;
        String rExceptionErrorMsg = "";
%>



