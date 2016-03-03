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
<jsp:useBean id="anonUser" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser" scope="session"> </jsp:useBean>

<%    
    java.util.UUID id=java.util.UUID.randomUUID();
    anonUser=myAnonUser.createAnonUser(id.toString(),pool);
    if(anonUser!=null){
%>
    { "uuid":"<%=anonUser.getUUID()%>",
      "status":"SUCCESS"
    }
<%}else{%>
    { "uuid":"","status":"ERROR"}
<%}%>


