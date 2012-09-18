<%@ include file="/web/geneLists/include/geneListHeader.jsp"%>

<jsp:useBean id="myEnsembl" class="edu.ucdenver.ccp.PhenoGen.data.external.Ensembl"> </jsp:useBean>
<jsp:useBean id="thisIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"> </jsp:useBean>
	
<%
	String fullFileName = (String) session.getAttribute("fullFileName");
	Set iDecoderValues = (Set) session.getAttribute("downloadiDecoderValues");

	String[] iDecoderTargets = (String[]) session.getAttribute("iDecoderTargets");
	
	String fileFormat = (String)request.getParameter("fileFormat");

	log.debug("chose to download file in format " + fileFormat);

	myIDecoderClient.writeToFileByTarget(iDecoderValues, Arrays.asList(iDecoderTargets), fullFileName, fileFormat);

	request.setAttribute("fullFileName", fullFileName);

	myFileHandler.downloadFile(request, response);
	// This is required to avoid the getOutputStream() has already been called for this response error
	out.clear();
	out = pageContext.pushBody(); 

	mySessionHandler.createGeneListActivity("Downloaded Advanced Annotation for Gene List in format " + fileFormat, dbConn);
%>
