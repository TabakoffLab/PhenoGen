


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

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<jsp:useBean id="bt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.BrowserTools" scope="session"> </jsp:useBean>

<%
int tmpuserID=0;
bt.setSession(session);

if(request.getParameter("userLoggedIn")!=null){
	tmpuserID=userLoggedIn.getUser_id();
}
ArrayList<BrowserTrack> tracks=bt.getBrowserTracks(tmpuserID);

response.setContentType("application/json");
%>
[
	<%for(int j=0;j<tracks.size();j++){
        BrowserTrack btrk=tracks.get(j);%>
        <%if(j>0){%>,<%}%>
        {
        "TrackID":<%=btrk.getID()%>,
        "UserID":<%=btrk.getUserID()%>,
        "TrackClass": "<%=btrk.getTrackClass()%>",
        "Name": "<%=btrk.getTrackName()%>",
        "Description": "<%=btrk.getTrackDescription()%>",
        "Organism":"<%=btrk.getOrganism()%>",
        "Settings":"<%=btrk.getSettings()%>",
        "Order":<%=btrk.getOrder()%>,
        "GenericCategory":"<%=btrk.getGenericCategory()%>",
        "Category":"<%=btrk.getCategory()%>",
        "Controls":"<%=btrk.getControls()%>"
        }
    <%}%> 
]



