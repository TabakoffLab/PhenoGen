<%@ include file="/web/common/session_vars.jsp" %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>


<%
String myOrganism="";
String chromosome="";
int min=0;
int max=0;
String myTrackList="";
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

String[] result=gdt.getUCSCRegionImage(myTrackList,myOrganism,chromosome,min,max);

String html="";
if(result==null || result.length<2 || result[1].equals("error")){
	html="<H2>ERROR: An error occurred generating this image.  Please try again later.</H2>";
}else{
	html="<a class=\"fancybox fancybox.iframe\" href=\""+result[1]+"\" title=\"UCSC Genome Browser\"><img src=\""+result[0]+"\"/></a>";
}

%>





<%=html%>