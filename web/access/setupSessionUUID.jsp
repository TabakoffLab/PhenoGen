<%--
 *  Author: Spencer Mahaffey
 *  Created: Feb, 2016
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/common/anon_session_vars.jsp" %>

<jsp:useBean id="myAnonUser" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser"> </jsp:useBean>
<jsp:useBean id="anonU" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser" scope="session" />

<%
    String id="";
    if(request.getParameter("uuid") != null){
        id=FilterInput.getFilteredInput(request.getParameter("uuid"));
    }
    log.debug("SESSION UUID:\n"+id);
    //anonU=myAnonUser.getAnonUser(id,pool);
    AnonUser tmp=myAnonUser.getAnonUser(id,true,pool);
    
    anonU.setUUID(tmp.getUUID());
    anonU.setCreated(tmp.getCreated());
    anonU.setLast_access(tmp.getLast_access());
    anonU.setAccess_count(tmp.getAccess_count());
    anonU.setEmail(tmp.getEmail());
    //anonU.incrementLogin(pool);
    log.debug(anonU.getUUID());
    if(anonU!=null){
%>
    {"status":"SUCCESS","id":"<%=anonU.getUUID()%>"}
    
    
<%}else{%>
    { "status":"ERROR" }
<%}
log.debug("\n\nend");%>


