


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
if(request.getParameter("type")!=null){
    rType=request.getParameter("type");
}
log.debug("TYPE:"+rType);
ArrayList<GenericSharedFile> files=null;
if(rType.equals("myFiles")){
    files=sfiles.getMyFiles(session);
}else if(rType.equals("sharedFiles")){
    files=sfiles.getFilesSharedWithMe(session);
}

response.setContentType("application/json");
%>
[
	<%
        if(files!=null){
            for(int j=0;j<files.size();j++){
                GenericSharedFile gsf=files.get(j);

                String url=contextRoot.substring(0,contextRoot.length()-1)+"/userFiles"+gsf.getPath();%>
                <%if(j>0){%>,<%}%>
                {
                    "FileID":"<%=gsf.getFileID()%>",
                    "Owner":"<%=gsf.getOwner().getFirst_name()+" "+gsf.getOwner().getLast_name()%>",
                    "OwnerID":<%=gsf.getOwner().getUser_id()%>,
                    "Shared":"<%=gsf.isShared()%>",
                    "ShareAll":"<%=gsf.isSharedAll()%>",
                    "Path":"<%=url%>",
                    "Description":"<%=gsf.getDescription()%>",
                    "Time":"<%=gsf.getCreated().toString()%>"
                }
            <%}
        }%> 
]



