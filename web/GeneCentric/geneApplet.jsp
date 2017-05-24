<%@ include file="/web/common/anon_session_vars.jsp" %>




<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<jsp:useBean id="myFH" class="edu.ucdenver.ccp.util.FileHandler"/>


<%
gdt.setSession(session);
String chromosome="",panel="",myOrganism="Rn",viewID="20",genomeVer="rn6";
int min=0,max=0,rnaDatasetID=0,arrayTypeID=0;

String selectedID="";

if(request.getParameter("selectedID")!=null){
        selectedID=FilterInput.getFilteredInput(request.getParameter("selectedID"));
}
if(request.getParameter("defaultView")!=null){
        viewID=FilterInput.getFilteredInput(request.getParameter("defaultView"));
}

if(request.getParameter("myOrganism")!=null){
		myOrganism=FilterInput.getFilteredInput(request.getParameter("myOrganism").trim());
}else{
    if(selectedID.startsWith("ENSRNO")){
        myOrganism="Rn";
        genomeVer="rn6";
    }else if(selectedID.startsWith("ENSMUS")){
        myOrganism="Mm";
        genomeVer="mm10";
    }
}
if(request.getParameter("genomeVer")!=null){
		genomeVer=request.getParameter("genomeVer").trim();
}
if(genomeVer.equals("rn5")){
	viewID="10";
}else if(genomeVer.equals("rn6")){
	viewID="20";
}
if(request.getParameter("panel")!=null){
		panel=FilterInput.getFilteredInput(request.getParameter("panel").trim());
}else{
    if(myOrganism.toLowerCase().equals("rn")){
        panel="BNLX/SHRH";
    }else if(myOrganism.toLowerCase().equals("mm")){
        panel="ILS/ISS";
    }
}
int[] tmp=gdt.getOrganismSpecificIdentifiers(myOrganism,genomeVer);
if(tmp!=null&&tmp.length==2){
        rnaDatasetID=tmp[1];
        arrayTypeID=tmp[0];
}

String genURL="";
String urlPrefix=(String)session.getAttribute("mainURL");
if(urlPrefix.endsWith(".jsp")){
     urlPrefix=urlPrefix.substring(0,urlPrefix.lastIndexOf("/")+1);
}
if(request.getServerPort()!=80 && urlPrefix.indexOf("https")<0){
    urlPrefix=urlPrefix.replace("http","https");
}
genURL=urlPrefix+ "gene.jsp?speciesCB="+myOrganism+"&auto=Y&geneTxt="+selectedID+"&genomeVer="+genomeVer+"&section=geneApp";
        
        
response.sendRedirect(genURL);

%>



