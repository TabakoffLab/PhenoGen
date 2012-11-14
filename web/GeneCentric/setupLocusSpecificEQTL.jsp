<%@ include file="/web/common/session_vars.jsp" %>

        
<%
	String geneSymbol=request.getParameter("geneSym").trim();
	String ensID=request.getParameter("ensID").trim();
	String start=request.getParameter("start").trim();
	String stop=request.getParameter("stop").trim();
	String level=request.getParameter("level").trim();
	String chr=request.getParameter("chr").trim();
	String tcID=request.getParameter("tcID").trim();
	
	
	String curDir=request.getParameter("curDir").trim();
	
	File newDir=new File(applicationRoot + contextRoot+"tmpData/regionData/"+curDir+"/"+ensID);
	if(!newDir.exists()){
		newDir.mkdirs();
	}
	
	String lastColumn=geneSymbol;
	if(lastColumn.equals("")){
		lastColumn=ensID;
	}
	
	String fileContent=tcID+"\t"+chr+"\t"+start+"\t"+stop+"\t"+level+"\t"+lastColumn+"\n";
	myFileHandler.writeFile(fileContent,applicationRoot + contextRoot+"tmpData/regionData/"+curDir+"/"+ensID+"/tmp_psList_transcript.txt");
	
	//session.setAttribute("geneSymbol",geneSymbol);
	//session.setAttribute("geneCentricPath", curDir+ensID+"/");
	session.removeAttribute("geneSymbol");
	session.removeAttribute("geneCentricPath");
	String tmpPath=applicationRoot + contextRoot+"tmpData/regionData/"+curDir+"/"+ensID+"/";
	
    response.sendRedirect(request.getContextPath()+"/web/GeneCentric/LocusSpecificEQTL.jsp?hiddenGeneSymbol="+geneSymbol+"&hiddenGeneCentricPath="+tmpPath);           
	
%>

