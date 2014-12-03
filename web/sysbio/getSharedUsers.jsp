


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

<%@ include file="/web/common/session_vars.jsp"  %>

<jsp:useBean id="sfiles" class="edu.ucdenver.ccp.PhenoGen.data.internal.SharedFiles" scope="session"> </jsp:useBean>

<%
int fid=-99;

if(request.getParameter("fid")!=null){
    fid=Integer.parseInt(request.getParameter("fid"));
}

String uids=sfiles.getSharedUsers(fid,session);


response.setContentType("application/json");
%>
{
    "UIDs":"<%=uids%>"
}



