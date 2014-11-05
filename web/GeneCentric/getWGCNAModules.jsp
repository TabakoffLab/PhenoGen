


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
if(request.getParameter("id")!=null){
	id=request.getParameter("id");
}
wgt.setSession(session);

ArrayList<String> modules=wgt.getWGCNAModulesForGene(id,"ILS/ISS","Brain","Mm");

response.setContentType("application/json");
%>
[
	<%for(int i=0;i<modules.size();i++){
		String mod=modules.get(i);%>
            <%if(i>0){%>,<%}%>{"ModuleID":"<%=mod%>"}
        <%}%>
]



