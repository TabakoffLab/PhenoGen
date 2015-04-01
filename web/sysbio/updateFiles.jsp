


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
String rType="";
int fid=-99;
boolean all=false;
boolean success=false;
boolean status=false;
String message="";
String list="";

if(request.getParameter("type")!=null){
    rType=request.getParameter("type");
}
if(request.getParameter("fid")!=null){
    fid=Integer.parseInt(request.getParameter("fid"));
}
if(request.getParameter("idList")!=null){
    list=request.getParameter("idList");
}

if(rType.equals("share")){
    all=false;
    success=sfiles.toggleFileShare(fid,all,session);
    status=sfiles.getFileShareStatus(fid,all,session);
}else if(rType.equals("shareAll")){
    all=true;
    success=sfiles.toggleFileShare(fid,all,session);
    status=sfiles.getFileShareStatus(fid,all,session);
}else if(rType.equals("delete")){
    success=sfiles.deleteFile(fid,session);
}else if(rType.equals("updateSharedWith")){
    success=sfiles.updateSharedWith(fid,list,session);
}


if(!success){
    message="An error occured.  Please try again.";
}

response.setContentType("application/json");
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setDateHeader("Expires", 0);
%>
{
    "success":"<%=success%>",
    "status":"<%=status%>",
    "message":"<%=message%>"
}