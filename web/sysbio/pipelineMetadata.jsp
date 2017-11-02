<%--
 *  Author: Spencer Mahaffey
 *  Created: Oct, 2017
 *  Description:  The web page created by this file allows the user to 
 *		view metadata associated with RNASeqDatasets.
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/sysbio/include/sysBioHeader.jsp"  %>

<%
    int resource = (request.getParameter("resource") == null ? -99 : Integer.parseInt((String) request.getParameter("resource")));
    String type = (request.getParameter("type") == null ? "" : (String) request.getParameter("type"));
    RNAResult myRR=new RNAResult();
    RNAResult rr=myRR.getRNAResultByID(resource,pool);
    ArrayList<RNAPipeline> pipelines=rr.getPipeline();
%>

<%@include file="/web/rnaseq/pipelineMetadata_content.jsp" %>