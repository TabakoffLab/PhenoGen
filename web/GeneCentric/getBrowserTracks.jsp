


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

<%@ include file="/web/common/anon_session_vars.jsp"  %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<jsp:useBean id="bt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.BrowserTools" scope="session"> </jsp:useBean>

<%
log.debug("TESTING");
int tmpuserID=0;
bt.setSession(session);

ArrayList<BrowserTrack> tracks=bt.getBrowserTracks();

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
        "Controls":"<%=btrk.getControls()%>",
        "SetupDate":"<%=btrk.getSetupTime()%>",
        "OriginalFile":"<%=btrk.getOriginalFile()%>",
        "Type":"<%=btrk.getType()%>",
        "Location":"<%=btrk.getLocation()%>",
        "Source": "db"
        }
    <%}%> 
]



