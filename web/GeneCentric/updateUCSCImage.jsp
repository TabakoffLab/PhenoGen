<%@ include file="/web/common/session_vars.jsp" %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>


<%
String myOrganism="";
String chromosome="";
int min=0;
int max=0;
String myTrackList="",type="",geneID="";

if(request.getParameter("chromosome")!=null){
		chromosome=request.getParameter("chromosome");
		log.debug("updateUCSC:"+chromosome);
}
if(request.getParameter("minCoord")!=null){
		min=Integer.parseInt(request.getParameter("minCoord"));
		log.debug("updateUCSC:"+min);
}
if(request.getParameter("maxCoord")!=null){
		max=Integer.parseInt(request.getParameter("maxCoord"));
		log.debug("updateUCSC:"+max);
}

if(request.getParameter("species")!=null){
		myOrganism=request.getParameter("species");
		log.debug("updateUCSC:"+myOrganism);
}
if(request.getParameter("trackList")!=null){
		myTrackList=request.getParameter("trackList");
		log.debug("updateUCSC:"+myTrackList);
}
if(request.getParameter("type")!=null){
	type=request.getParameter("type");
	log.debug("updateUCSC:"+type);
}
if(request.getParameter("geneID")!=null){
	geneID=request.getParameter("geneID");
	log.debug("updateUCSC:"+geneID);
}
	String html="";
	String[] result=null;
if(type.equals("region")){
	result=gdt.getUCSCRegionImage(myTrackList,myOrganism,chromosome,min,max);
}else if(type.equals("geneView")){
	result=gdt.getUCSCRegionViewImage(myTrackList,myOrganism,chromosome,min,max);
}else if(type.equals("Gene")){
	result=gdt.getUCSCGeneImage(myTrackList,myOrganism,chromosome,min,max,geneID);
}

if(result==null || result.length<2 || result[1].equals("error")){
		html="<H2>ERROR: An error occurred generating this image.  Please try again later.</H2>";
}else{
		html="<a class=\"fancybox fancybox.iframe\" href=\""+result[1]+"\" title=\"UCSC Genome Browser\"><img src=\""+result[0]+"\"/></a>";
}

%>





<%=html%>