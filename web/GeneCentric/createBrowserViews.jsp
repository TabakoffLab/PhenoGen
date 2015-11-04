


<%--
 *  Author: Spencer Mahaffey
 *  Created: May, 2013
 *  Description:  This file takes the input from an ajax request and returns a json object with genes.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ page language="java" %>

<%@ include file="/web/common/anon_session_vars.jsp"  %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<jsp:useBean id="bt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.BrowserTools" scope="session"> </jsp:useBean>

<%
int tmpuserID=0;
int copyFrom=-1;
String name="";
String desc="";
String type="";
String org="AA";
String disp="displaySelect0=700;";
int newID=-1;


bt.setSession(session);

if(request.getParameter("userLoggedIn")!=null&&!userLoggedIn.getUser_name().equals("anon")){
	tmpuserID=userLoggedIn.getUser_id();
}

if(request.getParameter("name")!=null){
	name=FilterInput.getFilteredInput(request.getParameter("name"));
}
if(request.getParameter("description")!=null){
	desc=FilterInput.getFilteredInput(request.getParameter("description"));
}
if(request.getParameter("type")!=null){
	type=FilterInput.getFilteredInput(request.getParameter("type"));
}
if(request.getParameter("copyFrom")!=null){
	copyFrom=Integer.parseInt(request.getParameter("copyFrom"));
}
if(request.getParameter("organism")!=null){
	org=FilterInput.getFilteredInput(request.getParameter("organism"));
}

if(type.equals("blank")){
	newID=bt.createBlankView(name,desc,org,disp);
}else{
	newID=bt.createCopiedView(name,desc,org,disp,copyFrom);
}

response.setContentType("application/json");
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setDateHeader("Expires", 0);
%>
{"viewID": <%=newID%> }


