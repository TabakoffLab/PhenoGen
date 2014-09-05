


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

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<jsp:useBean id="bt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.BrowserTools" scope="session"> </jsp:useBean>

<%

bt.setSession(session);

int id=-1;
String tracks="";
String msg="";
if(request.getParameter("viewID")!=null){
		id=Integer.parseInt(request.getParameter("viewID"));
}
if(request.getParameter("trackList")!=null){
		tracks=request.getParameter("trackList");
}
log.debug("ID:"+id);
log.debug("TRACKS"+tracks);

if(id>0){
	msg=bt.updateView(id,tracks);
}

response.setContentType("application/json");
%>
{"msg":"<%=msg%>"}



