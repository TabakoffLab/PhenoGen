<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  The web page created by this file displays the options
 *  		for calling iDecoder, and then passes the selected values
 *		to iDecoder.
 *  Todo: 
 *  Modification Log:
		Cheryl Hornbaker, Mar, 2006: Modified to call iDecoder
 *      
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %>

<jsp:useBean id="myEnsembl" class="edu.ucdenver.ccp.PhenoGen.data.external.Ensembl"> </jsp:useBean>
<jsp:useBean id="thisIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"> </jsp:useBean>

<%
	
	log.info("in advancedAnnotation.jsp. user = " + user);

	request.setAttribute( "selectedTabId", "annotation" );
	extrasList.add("advancedAnnotation.js");
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
	optionsList.add("basicAnnotation");

	String[] identifierTypes = thisIDecoderClient.getIdentifierTypes(pool);
	String[] affyBoxes = thisIDecoderClient.getArraysForPlatform(new Dataset().AFFYMETRIX_PLATFORM, pool);
	String[] codeLinkBoxes = thisIDecoderClient.getArraysForPlatform(new Dataset().CODELINK_PLATFORM, pool);

	Set iDecoderValues = null;

	log.debug("action in advancedAnnotation = "+action);
	
	mySessionHandler.createGeneListActivity("Looked at advanced annotation page", pool);
	if ((action != null) && (action.equals("Run") )) {

		//if (selectedGeneList.getNumber_of_genes() > 200) {
		//	log.debug("trying to do annotation on list with more than 200 genes");
			//Error - "Cannot do annotation on list with more than 200 genes"
                 //       session.setAttribute("errorMsg", "GL-009");
                  //      response.sendRedirect(commonDir + "errorMsg.jsp");
		//} else {

			String[] iDecoderTargets = request.getParameterValues("iDecoderChoice");
			String[] iDecoderTargetsPlusEnsembl = request.getParameterValues("iDecoderChoice");
			String[] affymetrixChipTargets = request.getParameterValues("AffymetrixArrayChoice");
			String[] codeLinkChipTargets = request.getParameterValues("CodeLinkArrayChoice");

			List arrayNames = new ArrayList();
			if (affymetrixChipTargets != null) {	
				arrayNames.addAll(Arrays.asList(affymetrixChipTargets));
			}
			if (codeLinkChipTargets != null) {
				arrayNames.addAll(Arrays.asList(codeLinkChipTargets));
			}
			String[] arrayTargets = (arrayNames.size() > 0 ? (String[]) arrayNames.toArray(new String[arrayNames.size()]) : null);
			//log.debug("iDecoder targetSize = "+iDecoderTargets.length); myDebugger.print(iDecoderTargets);
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
									iDecoderTargetsPlusEnsembl, arrayTargets, pool);
			} catch (Exception e) {
				log.error("iDecoder timed out");
				//Error - "No iDecoder"
				session.setAttribute("errorMsg", "GLT-001");
	                	response.sendRedirect(commonDir + "errorMsg.jsp");
			}

			//log.debug("before going to results, iDecoderValues = "); myDebugger.print(iDecoderValues);
	
			if (iDecoderValues != null) {
				session.setAttribute("iDecoderValues", iDecoderValues);
				session.setAttribute("iDecoderTargets", iDecoderTargets);
				//
        			// If the user selected Genetic Variations, get the transcripts from Ensembl
        			//
				if (Arrays.binarySearch(iDecoderTargets, "Genetic Variations") >= 0) {
					String[] ensemblTargets = {ensemblString};
	        			Set allEnsemblSet = thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersForTarget(iDecoderValues, ensemblTargets));
	
       		 			%><%@ include file="/web/common/dbutil_ensembl.jsp" %><%
	
					if (ensemblConn != null && !ensemblConn.isClosed()) {
						try {
                               				Hashtable ensemblHash = myEnsembl.getTranscripts(allEnsemblSet, ensemblConn);
							session.setAttribute("ensemblHash", ensemblHash);
                               				ensemblConn.close();
							//log.debug("ensemblHash = ");myDebugger.print(ensemblHash);
						} catch (Exception e) {
							log.error("got error retrieving stuff from Ensmbl", e);
						}
					}
				}
				
			
			session.setAttribute("checkBoxiDecoderTargets", request.getParameterValues("iDecoderChoice"));			
			session.setAttribute("checkBoxaffymetrixChipTargets", request.getParameterValues("AffymetrixArrayChoice"));
			session.setAttribute("checkBoxcodeLinkChipTargets", request.getParameterValues("CodeLinkArrayChoice"));
			
				
			response.sendRedirect(geneListsDir + "iDecoderResults.jsp?geneListID="+selectedGeneList.getGene_list_id());
				
			} else {
				//Error - "iDecoder error"
                		session.setAttribute("errorMsg", "GLT-002");
                		response.sendRedirect(commonDir + "errorMsg.jsp");
			}
			mySessionHandler.createGeneListActivity("Ran advanced annotation on gene list", pool);

		//}
        } 
        formName = "advancedAnnotation.jsp";
	
%>

<%@ include file="/web/common/header_adaptive_menu.jsp" %>

	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>

	<div class="page-intro">
		<p> Select one or more targets.
		</p>
	</div> <!-- // end page-intro -->


	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>


	<div class="dataContainer" style="padding-bottom:70px;">
	<form   name="advancedAnnotation"
        	method=POST
        	action="advancedAnnotation.jsp"
		onSubmit="return IsAdvancedAnnotationComplete()"
        	enctype="application/x-www-form-urlencoded">

		<% if (selectedGeneList.getNumber_of_genes() > 400) { %>
			<div class="tab-intro">
			<p>Since your gene list contains more than 400 genes, 
				the results cannot be displayed online.<%=twoSpaces%>
				You may only download the results.
			</p>
			</div>
		<% } %>

		<%@ include file="/web/geneLists/include/identifierTypes.jsp" %>

		<BR>

		<center>
			<input type="reset" value="Reset"> <%=tenSpaces%>
			 <!-- <input type="submit" name = "action" value="Download"> -->
                <input type="button" name = "action" value="Download" id="downloadBtn">
				 
			<% if (selectedGeneList.getNumber_of_genes() <= 400) { %>
				<%=tenSpaces%>
				<input type="submit" name = "action" value="Run"> 
			
			<% } %>
		</center>
        	<input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>" >
		</form>
	</div>
		  <div class="itemDetails"></div>

<%@ include file="/web/common/footer_adaptive.jsp" %>
