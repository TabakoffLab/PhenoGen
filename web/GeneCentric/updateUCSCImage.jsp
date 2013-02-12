<%@ include file="/web/common/session_vars.jsp" %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>


<%
String myOrganism="";
String chromosome="";
int min=0;
int max=0;
String myTrackList="";
boolean geneView=false;
if(request.getParameter("chromosome")!=null){
		chromosome=request.getParameter("chromosome");
}
if(request.getParameter("minCoord")!=null){
		min=Integer.parseInt(request.getParameter("minCoord"));
}
if(request.getParameter("maxCoord")!=null){
		max=Integer.parseInt(request.getParameter("maxCoord"));
}

if(request.getParameter("species")!=null){
		myOrganism=request.getParameter("species");
}
if(request.getParameter("trackList")!=null){
		myTrackList=request.getParameter("trackList");
		
}
if(request.getParameter("type")!=null){
	String type=request.getParameter("type");
	if(type.equals("geneView")){
		geneView=true;
	}
}
	String html="";
if(!geneView){
	String[] result=gdt.getUCSCRegionImage(myTrackList,myOrganism,chromosome,min,max);
	if(result==null || result.length<2 || result[1].equals("error")){
		html="<H2>ERROR: An error occurred generating this image.  Please try again later.</H2>";
	}else{
		html="<a class=\"fancybox fancybox.iframe\" href=\""+result[1]+"\" title=\"UCSC Genome Browser\"><img src=\""+result[0]+"\"/></a>";
	}
}else{
	String[] result=gdt.getUCSCRegionViewImage(myTrackList,myOrganism,chromosome,min,max);
	if(result==null || result.length<2 || result[1].equals("error")){
		html="<H2>ERROR: An error occurred generating this image.  Please try again later.</H2>";
	}else{
		html="<a class=\"fancyboxExt fancybox.iframe\" href=\""+result[1]+"\" title=\"UCSC Genome Browser\"><img src=\""+result[0]+"\"/></a>";
	}
}

%>





<%=html%>