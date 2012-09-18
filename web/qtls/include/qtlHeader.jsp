<%--
 *  Author: Cheryl Hornbaker
 *  Created: Jul, 2009
 *  Description:  This file sets up the header for the qtl screens
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/common/session_vars.jsp"  %>

<jsp:useBean id="myDataset" class="edu.ucdenver.ccp.PhenoGen.data.Dataset"> </jsp:useBean>

<jsp:useBean id="myStatistic" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.Statistic">
        <jsp:setProperty name="myStatistic" property="RFunctionDir" value="<%=rFunctionDir%>" />
        <jsp:setProperty name="myStatistic" property="session" value="<%=session%>" />
</jsp:useBean>

<jsp:useBean id="myParameterValue" class="edu.ucdenver.ccp.PhenoGen.data.ParameterValue"> </jsp:useBean>

<jsp:useBean id="myQTL" class="edu.ucdenver.ccp.PhenoGen.data.QTL"> </jsp:useBean>
<%
        QTL.EQTL myEQTL = myQTL.new EQTL();
        //log.info("in qtlHeader.jsp. user = " + user);
	request.setAttribute( "selectedMain", "qtlTools" );

        extrasList.add("common.js");
        phenotypeParameterGroupID = (request.getParameter("phenotypeParameterGroupID") != null && 
        				!((String)request.getParameter("phenotypeParameterGroupID")).equals("") ?
                                        Integer.parseInt((String)request.getParameter("phenotypeParameterGroupID")) :
                                        -99);

	%><% //@include file="/web/datasets/include/selectDataset.jsp"%><%

        String[] rErrorMsg = null;
        String rExceptionErrorMsg = "";
%>



