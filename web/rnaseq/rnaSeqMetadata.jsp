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
    RNADataset myRNA=new RNADataset();
    RNADataset thisData=myRNA.getRNADataset(resource,pool);
    ArrayList<RNASample> samples=thisData.getSamples();
    ArrayList<ArrayList<RNAProtocol>> prtcl=thisData.getProtocols();
    ArrayList<RNAPipeline> pipelines=thisData.getResultPipelines();
%>
<div id="metaDataDetails">
    <%@include file="samplesMetadata_content.jsp" %>
    <BR><BR>
    <%@include file="protocolMetadata_content.jsp" %>
    <BR><BR>
    <%@include file="pipelineMetadata_content.jsp" %>
</div>
    
