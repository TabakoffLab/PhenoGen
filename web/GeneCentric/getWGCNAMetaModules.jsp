<%--
 *  Author: Spencer Mahaffey
 *  Created: April, 2017
 *  Description:  This file takes the input from an ajax request and returns a json object with genes.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ page language="java"
import="org.json.*" %>

<%@ include file="/web/common/anon_session_vars.jsp"  %>

<jsp:useBean id="wgt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.WGCNATools" scope="session"> </jsp:useBean>
<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>

<%
String modid="";
String org="";
String tissue="";
String panel="";
String region="";
String genomeVer="";
String source="";
int geneList=0;

if(request.getParameter("id")!=null){
	modid=request.getParameter("id");
}
if(request.getParameter("organism")!=null){
	org=request.getParameter("organism");
}
if(request.getParameter("panel")!=null){
	panel=request.getParameter("panel");
}
if(request.getParameter("tissue")!=null){
	tissue=request.getParameter("tissue");
}
if(request.getParameter("region")!=null){
	region=request.getParameter("region");
}
if(request.getParameter("genomeVer")!=null){
        genomeVer=request.getParameter("genomeVer");
}
if(request.getParameter("source")!=null){
        source=request.getParameter("source");
}

wgt.setSession(session);
gdt.setSession(session);
ArrayList<WGCNAMetaModule> modules=null;

modules=wgt.getWGCNAMetaModulesForModule(gdt,id,panel,tissue,org,genomeVer,source);

response.setContentType("application/json");
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setDateHeader("Expires", 0);
%>
[
<%for(int i=0;i<modules.size();i++){
    curMod=modlues.get(i);
    ArrayList<String> mods=curMod.getModNames();
    ArrayList<String> modCol=curMod.getModColors();
    ArrayList<WGCNAMetaModLink> links=curMod.getLinks();
    
    if(i>0){%>,<%}%>
    {"MMID":"<%=curMod.getMMID()%>","MODULES":[
        <%for(int j=0;j<.size();j++){
            
            if(j>0){%>,<%}%>
            {"MODULE":"<%=mods.get(j)%>" , "COLOR":"<%=modCol.get(j)%>"}
        <%}%>
    ],"LINKS":[
        <%for(int j=0;j<.size();j++){
            if(j>0){%>,<%}%>
            {
                "MOD1":"<%=links.get(j).getModuleName1()%>",
                "MOD2":"<%=links.get(j).getModuleName2()%>",
                "COR":<%=links.get(j).getCorrelation()%>
            }
        <%}%>
    ]
    }
<%}%>
]



