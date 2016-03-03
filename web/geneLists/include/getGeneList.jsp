<%--
 *  Author: Spencer Mahaffey
 *  Created: Feb, 2016
 *  Description:  This file is called to create a list of available Gene Lists.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/common/anon_session_vars.jsp" %>

<jsp:useBean id="anonU" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser" scope="session" />


<%
    AnonGeneList myAnonGL=new AnonGeneList();
    
    log.debug("GET GENELIST for USER:\n"+anonU.getUUID());
    
    AnonGeneList[] glList=myAnonGL.getGeneListsForAllDatasetsForUser(anonU.getUUID(),pool);
    
    response.setContentType("application/json");
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setDateHeader("Expires", 0);
%>

[
    <%for(int i=0;i<glList.length;i++){
        if(i>0){%>
            ,
        <%}%>
        <%=glList[i].toJSON("summary")%>
    <%}%>
]


