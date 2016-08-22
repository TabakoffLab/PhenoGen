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
<jsp:useBean id="anonU" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser" scope="session"> </jsp:useBean>

<%    
    java.util.UUID id=java.util.UUID.randomUUID();
    AnonUser anonUser=myAnonUser.createAnonUser(id.toString(),pool);
    if(anonUser!=null){
        AnonUser tmp=myAnonUser.getAnonUser(id.toString(),true,pool);
        anonU.setUUID(tmp.getUUID());
        anonU.setCreated(tmp.getCreated());
        anonU.setLast_access(tmp.getLast_access());
        anonU.setAccess_count(tmp.getAccess_count());
        anonU.setEmail(tmp.getEmail());
%>
    { "uuid":"<%=anonUser.getUUID()%>",
      "status":"SUCCESS"
    }
<%}else{%>
    { "uuid":"","status":"ERROR"}
<%}%>


