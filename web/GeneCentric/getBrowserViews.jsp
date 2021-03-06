


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

bt.setSession(session);
String genomeVer="";
if(request.getParameter("genomeVer")!=null){
    genomeVer=request.getParameter("genomeVer");
}

ArrayList<BrowserView> views=bt.getBrowserViews(genomeVer);

response.setContentType("application/json");
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setDateHeader("Expires", 0);
%>
[
	<%for(int i=0;i<views.size();i++){
		BrowserView bv=views.get(i);%>
        <%if(i>0){%>,<%}%>
    	{
        	"ViewID":"<%=bv.getID()%>",
            "UserID":<%=bv.getUserID()%>,
            "Name": "<%=bv.getName()%>",
            "Description": "<%=bv.getDescription()%>",
            "Organism":"<%=bv.getOrganism()%>",
            "imgSettings" : "<%=bv.getImageSettings()%>",
            "genomeVersion":"<%= bv.getGenomeVersion()%>",
            "Source":"db",
            "TrackList":
            	[
            		<% ArrayList<BrowserTrack> btrks=bv.getTracks();
					for(int j=0;j<btrks.size();j++){
						BrowserTrack btrk=btrks.get(j);%>
                        <%if(j>0){%>,<%}%>
                        {
                        "TrackID":"<%=btrk.getID()%>",
                        "UserID":<%=btrk.getUserID()%>,
                        "TrackClass": "<%=btrk.getTrackClass()%>",
                        "Name": "<%=btrk.getTrackName()%>",
                        "Description": "<%=btrk.getTrackDescription()%>",
                        "Organism":"<%=btrk.getOrganism()%>",
                        "Settings":"<%=btrk.getSettings()%>",
                        "Order":<%=btrk.getOrder()%>,
                        "Controls":"<%=btrk.getControls()%>"
                        }
                    <%}%>
                ]
        }
    <%}%>
]



