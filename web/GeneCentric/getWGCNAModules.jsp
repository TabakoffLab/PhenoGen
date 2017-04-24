


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

<jsp:useBean id="wgt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.WGCNATools" scope="session"> </jsp:useBean>
<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>

<%
String id="";
String org="";
String tissue="";
String panel="";
String region="";
String genomeVer="";
String source="";
int geneList=0;

if(request.getParameter("id")!=null){
	id=request.getParameter("id");
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
if(request.getParameter("geneList")!=null){
	geneList=Integer.parseInt(request.getParameter("geneList"));
}
if(request.getParameter("genomeVer")!=null){
        genomeVer=request.getParameter("genomeVer");
}
if(request.getParameter("source")!=null){
        source=request.getParameter("source");
}

wgt.setSession(session);
gdt.setSession(session);
ArrayList<String> modules=null;
if(!id.equals("")){
    modules=wgt.getWGCNAModulesForGene(gdt,id,panel,tissue,org,genomeVer,source);
}else if(!region.equals("")){
    modules=wgt.getWGCNAModulesForRegion(gdt,region,panel,tissue,org,genomeVer,source);
}else if(geneList>0){
    modules=wgt.getWGCNAModulesForGeneList(gdt,geneList,panel,tissue,genomeVer,source);
}
response.setContentType("application/json");
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setDateHeader("Expires", 0);
%>
[
	<%for(int i=0;i<modules.size();i++){
            String mod=modules.get(i);%>
            <%if(i>0){%>,<%}%>
            {
                <%if(mod.contains(":")){
                    String mod1=mod.substring(0,mod.indexOf(":"));
                    String gl=mod.substring(mod.indexOf(":")+1);
                %>
                "ModuleID":"<%=mod1%>"
                ,"GeneList":"<%=gl%>"
                <%}else{%>
                    "ModuleID":"<%=mod%>"
                <%}%>
            }
        <%}%>
]



