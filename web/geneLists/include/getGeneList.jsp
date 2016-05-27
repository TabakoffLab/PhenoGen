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
    
    String useUUID=anonU.getUUID();
    
    
    if(request.getParameter("rgd")!=null){
        String tmpUUID="";
        tmpUUID=FilterInput.getFilteredInput(request.getParameter("rgd"));
        myAnonGL.linkRGDListToUser(useUUID,tmpUUID,pool);
    }
    
    
    log.debug("GET GENELIST for USER:\n"+useUUID);
    
    AnonGeneList[] glList=myAnonGL.getGeneListsForAllDatasetsForUser(useUUID,pool);
    
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


