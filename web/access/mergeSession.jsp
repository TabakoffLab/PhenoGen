<%@ include file="/web/common/anon_session_vars.jsp" %>

<jsp:useBean id="myAnonUser" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser"> </jsp:useBean>
<jsp:useBean id="anonU" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser" scope="session"> </jsp:useBean>
<%--
 *  Author: Spencer Mahaffey
 *  Created: May, 2016
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%
    extrasList.add("d3.v3.5.16.min.js");
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setDateHeader("Expires", 0);
    
    String uuidSrc="";
    if(request.getParameter("uuidSource")!=null){
            uuidSrc=FilterInput.getFilteredInput(request.getParameter("uuidSource"));
    }
    String uuidDest="";
    if(request.getParameter("uuidDest")!=null){
            uuidDest=FilterInput.getFilteredInput(request.getParameter("uuidDest"));
    }
    String status="failed";
    boolean success=anonU.mergeSessionTo(uuidSrc,uuidDest,pool);
    if(success){
        status="success";
    }
%>

{ "status":"<%=status%>"}