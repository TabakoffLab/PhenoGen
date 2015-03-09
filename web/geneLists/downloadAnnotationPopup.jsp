<%--
 *  Author: Aris Tan
 *  Created: Aug, 2010
 *  Description:  The web page created by this file allows the user to 
 *		download advanced annotation information in different formats.
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"%>

<jsp:useBean id="myEnsembl" class="edu.ucdenver.ccp.PhenoGen.data.external.Ensembl"> </jsp:useBean>
<jsp:useBean id="thisIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"> </jsp:useBean>

<%

	extrasList.add("main.min.css");
	
	String[] iDecoderTargets   = request.getParameterValues("iDecoderChoice[]");
	String[] iDecoderTargetsPlusEnsembl = request.getParameterValues("iDecoderChoice[]");
	String[] affymetrixChipTargets = request.getParameterValues("AffymetrixArrayChoice[]");
	String[] codeLinkChipTargets = request.getParameterValues("CodeLinkArrayChoice[]");
			
	Set iDecoderValues = null;
			
	mySessionHandler.createGeneListActivity("Chose format for downloading advanced annotation", dbConn);
	
       	List arrayNames = new ArrayList();
			
	if (affymetrixChipTargets != null) {	
		arrayNames.addAll(Arrays.asList(affymetrixChipTargets));
	}
	if (codeLinkChipTargets != null) {
		arrayNames.addAll(Arrays.asList(codeLinkChipTargets));
	}
			
	String[] arrayTargets = (arrayNames.size() > 0 ? (String[]) arrayNames.toArray(new String[arrayNames.size()]) : null);
			
	// 
	// If the user selected "Genetic Variations", make sure "Ensembl ID" is one of the targets
	// because these will need to be passed to Ensembl to get the transcripts
	//
	String ensemblString = "Ensembl ID";
	Arrays.sort(iDecoderTargets);
			
	if (Arrays.binarySearch(iDecoderTargets, "Genetic Variations") >= 0) { 
		if (Arrays.binarySearch(iDecoderTargets, ensemblString) < 0) {
			iDecoderTargetsPlusEnsembl = new String[iDecoderTargets.length+1];
			for (int i=0; i<iDecoderTargets.length; i++) {
				iDecoderTargetsPlusEnsembl[i] = iDecoderTargets[i];
			}
			iDecoderTargetsPlusEnsembl[iDecoderTargets.length] = ensemblString; 
		}
	}

	//log.debug("iDecoderPlusEnsemble targetSize = "+iDecoderTargetsPlusEnsembl.length); myDebugger.print(iDecoderTargetsPlusEnsembl);
	try {
		iDecoderValues = thisIDecoderClient.getIdentifiersByInputIDAndTarget(selectedGeneList.getGene_list_id(), 
									iDecoderTargetsPlusEnsembl, arrayTargets, dbConn);
	} catch (Exception e) {
		log.error("iDecoder timed out");
		//Error - "No iDecoder"
		session.setAttribute("errorMsg", "GLT-001");
	        response.sendRedirect(commonDir + "errorMsg.jsp");
	}

	String fullFileName = userLoggedIn.getUserGeneListsDownloadDir() + 
							selectedGeneList.getGene_list_name_no_spaces() + "_AdvancedAnnotation.txt";
	session.setAttribute("fullFileName", fullFileName);
	session.setAttribute("iDecoderValues", iDecoderValues);
	session.setAttribute("iDecoderTargets", iDecoderTargets);
	session.setAttribute("callingForm", "advancedAnnotation.jsp");
	Set downloadiDecoderValues = (Set) session.getAttribute("downloadiDecoderValues");
	// downloadiDecoderValues is null when coming in from advancedAnnotation.jsp
	if (downloadiDecoderValues==null){
		session.setAttribute("downloadiDecoderValues", iDecoderValues);
	}
%>

	<form	method="post" 
		action="downloadAnnotation.jsp" 
		enctype="application/x-www-form-urlencoded"
		name="downloadAnnotation">
	
	<div class="leftTitle">Choose the file format:</div>
		<table class="list_base"> 
		<tr>
		<th>&nbsp;</th>
		<th width="50%">Sample File Format</th>
		</tr>
		<tr>  
			<td class="sideHeading"> <input type="radio" name="fileFormat" value="oneRow" checked>&nbsp;Each row contains all matches separated by '///'</td>  
			<td><table border="1" cellspacing="3" cellpadding="10"><tr>
				<th>Identifier</th><th>Affymetrix ID(s)</th><th>Ensembl ID(s)</th>
				</tr><tr>
				<td>NM_145512</td><td>106189_at///111682_at///1425026_at</td><td>ENSMU...///ENSMU...</td>
				</tr><tr>
				<td>NM_177129</td><td>107389_at///114733_at</td><td>ENSMU...///ENSMU...</td>
			</tr></table></td>
		</tr>
		<tr><td colspan="100%">&nbsp;</td></tr>
		<tr><td colspan="100%">&nbsp;</td></tr>
		<tr>
			<td class="sideHeading"> 
				<input type="radio" name="fileFormat" value="separateRows">&nbsp;Each row is a single match and shows the exact target name</td>  
			<td><table border="1" cellspacing="3" cellpadding="10"><tr>
				<th>Identifier</th><th>Target Name</th><th>Target Identifier</th>
				</tr><tr>
				<td>NM_145512</td><td>Affymetrix ID--Murine Genome U74Cv2 Array</td><td>106189_at</td>
				</tr><tr>
				<td>NM_145512</td><td>Affymetrix ID--Mouse Genome 430 2.0 Array</td><td>111682_at</td>
				</tr><tr>
				<td>NM_145512</td><td>Affymetrix ID--Mouse Genome 430 2.0 Array</td><td>1425026_at</td>
				</tr><tr>
				<td>NM_145512</td><td>Ensembl ID</td><td>ENSMU...</td>
				</tr><tr>
				<td>NM_145512</td><td>Ensembl ID</td><td>ENSMU...</td>
				</tr><tr>
				<td>NM_177129</td><td>Affymetrix ID--Murine Genome U74Cv2 Array</td><td>107389_at</td>
				</tr><tr>
				<td>NM_177129</td><td>Affymetrix ID--Mouse Genome 430 2.0 Array</td><td>114733_at</td>
				</tr><tr>
				<td>NM_177129</td><td>Ensembl ID</td><td>ENSMU...</td>
				</tr><tr>
				<td>NM_177129</td><td>Ensembl ID</td><td>ENSMU...</td>
			</tr></table></td>
		</tr> 
		<tr><td colspan="100%">&nbsp;</td></tr>
		<tr><td colspan="100%">&nbsp;</td></tr>
		<tr><td colspan="100%">&nbsp;</td></tr>
		<tr><td colspan="100%" class="center">
		<input type="submit" value="Download"> <%=fiveSpaces%>
		</td></tr>
		</table> <BR> 
		
	</form>
	</div>
	

	
