<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2008
 *  Description:  The web section created by this file displays the datasets
 *		the user owns.  
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>

<jsp:useBean id="myStatistic" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.Statistic">
        <jsp:setProperty name="myStatistic" property="RFunctionDir" value="<%=rFunctionDir%>" />
        <jsp:setProperty name="myStatistic" property="session" value="<%=session%>" />
</jsp:useBean>

<%
	//log.info("in analysisHeader.jsp. user = " + user);

        String analysisType = ((String) request.getParameter("analysisType") != null ?
                                (String) request.getParameter("analysisType") : "diffExp");

        phenotypeParameterGroupID = ((String)request.getParameter("phenotypeParameterGroupID") != null ?
                                        Integer.parseInt((String)request.getParameter("phenotypeParameterGroupID")) :
                                        -99);

        String queryString = datasetQueryString + "&datasetVersion=" + selectedDatasetVersion.getVersion() + 
                                "&analysisType=" + analysisType;  
	//log.debug("queryString="+queryString);

        if (phenotypeParameterGroupID != -99) { 
                queryString = queryString + "&phenotypeParameterGroupID=" + phenotypeParameterGroupID;
        }


        String[] rErrorMsg = null;
        String rExceptionErrorMsg = "";

%>
