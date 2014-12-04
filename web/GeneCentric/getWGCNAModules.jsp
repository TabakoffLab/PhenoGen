


<%--
 *  Author: Spencer Mahaffey
 *  Created: May, 2013
 *  Description:  This file takes the input from an ajax request and returns a json object with genes.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ page language="java"
import="org.json.*" %>

<%@ include file="/web/common/anon_session_vars.jsp"  %>

<jsp:useBean id="wgt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.WGCNATools" scope="session"> </jsp:useBean>

<%
String id="";
String org="";
String tissue="";
String panel="";

if(request.getParameter("id")!=null){
	id=request.getParameter("id");
}
if(request.getParameter("organism")!=null){
	org=request.getParameter("organism");
}
if(request.getParameter("panel")!=null){
	panel=request.getParameter("panel");
}
if(request.getParameter("tissue")!=null){
	tissue=request.getParameter("tissue");
}

wgt.setSession(session);

ArrayList<String> modules=wgt.getWGCNAModulesForGene(id,panel,tissue,org);

response.setContentType("application/json");
%>
[
	<%for(int i=0;i<modules.size();i++){
		String mod=modules.get(i);%>
            <%if(i>0){%>,<%}%>{"ModuleID":"<%=mod%>"}
        <%}%>
]



