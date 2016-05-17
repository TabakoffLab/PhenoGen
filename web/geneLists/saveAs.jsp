<%--
 *  Author: Cheryl Hornbaker
 *  Created: February, 2009
 *  Description:  This page allows the user to save a genelist using different identifiers
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %> 

<jsp:useBean id="myEnsembl" class="edu.ucdenver.ccp.PhenoGen.data.external.Ensembl"> </jsp:useBean>
<jsp:useBean id="thisIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"> </jsp:useBean>

<%
	log.debug("in saveAs.jsp");
	request.setAttribute( "selectedTabId", "saveAs" );
        extrasList.add("saveAs.js");
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");

	String[] identifierTypes = thisIDecoderClient.getIdentifierTypes(pool);
	String[] affyBoxes = thisIDecoderClient.getArraysForPlatform(new Dataset().AFFYMETRIX_PLATFORM,pool);
	String[] codeLinkBoxes = thisIDecoderClient.getArraysForPlatform(new Dataset().CODELINK_PLATFORM, pool);

	log.debug("action in saveAs = "+action);
	
	if (action != null && action.equals("Save As")) {
        	if (userLoggedIn.getUser_name().equals("guest")) {
                	//Error - "Feature not allowed for guests"
                	session.setAttribute("errorMsg", "GST-006");
                	response.sendRedirect(commonDir + "errorMsg.jsp");
        	} else {
                	String gene_list_name = (String) request.getParameter("gene_list_name");
                	String description = (String) request.getParameter("description").trim();
                	if (selectedGeneList.geneListNameExists(gene_list_name, userID, pool)) {
                        	//Error - "Gene list name exists"
                        	session.setAttribute("errorMsg", "GL-006");
                        	response.sendRedirect(commonDir + "errorMsg.jsp");
                	} else {
				Set iDecoderValues = null;

				String[] iDecoderTargets = request.getParameterValues("iDecoderChoice");
				String[] iDecoderTargetsPlusEnsembl = null;
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
				List iDecoderTargetList = (iDecoderTargets != null && iDecoderTargets.length > 0 ? 
							new ArrayList(Arrays.asList(iDecoderTargets)) : 
							new ArrayList());

				if (affymetrixChipTargets != null && !iDecoderTargetList.contains("Affymetrix ID")) {
					iDecoderTargetList.add("Affymetrix ID");
				}
				if (codeLinkChipTargets != null && !iDecoderTargetList.contains("CodeLink ID")) {
					iDecoderTargetList.add("CodeLink ID");
				}
				if (iDecoderTargets == null || iDecoderTargets.length != iDecoderTargetList.size()) {
					iDecoderTargets = (String[]) iDecoderTargetList.toArray(new String[iDecoderTargetList.size()]);
				}
				//log.debug("iDecoder targetSize = "+iDecoderTargets.length); myDebugger.print(iDecoderTargets);
				// 
				// If the user selected "Genetic Variations", make sure "Ensembl ID" is one of the targets
				// because these will need to be passed to Ensembl to get the transcripts
				//
				iDecoderTargetsPlusEnsembl = iDecoderTargets;
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
					log.error("iDecoder timed out", e);
					//Error - "No iDecoder"
					session.setAttribute("errorMsg", "GLT-001");
	                		response.sendRedirect(commonDir + "errorMsg.jsp");
				}

				//log.debug("before going to results, iDecoderValues = "); myDebugger.print(iDecoderValues);
	
				if (iDecoderValues == null) {
					//Error - "iDecoder error"
                			session.setAttribute("errorMsg", "GLT-002");
                			response.sendRedirect(commonDir + "errorMsg.jsp");
				}
				//Turn the results by target into a set of Strings
				Set allIdentifierValues = thisIDecoderClient.getValues(
								thisIDecoderClient.getIdentifiersForTarget(
									iDecoderValues, iDecoderTargetsPlusEnsembl));
				if (allIdentifierValues == null || allIdentifierValues.size() == 0) {
					//Error - "no genes"
                			session.setAttribute("errorMsg", "GLT-015");
                			response.sendRedirect(commonDir + "errorMsg.jsp");
				} else {
		
					GeneList newGeneList = new GeneList();
					newGeneList.setGene_list_name(gene_list_name);                    
					newGeneList.setDescription(description);                        
					newGeneList.setCreated_by_user_id(userID);                      
					newGeneList.setOrganism(selectedGeneList.getOrganism());                      
					newGeneList.setAlternateIdentifierSource("Current");                    
					newGeneList.setAlternateIdentifierSourceID(-99);        
					newGeneList.setGene_list_source("Copied Gene List");        

					int gene_list_id = newGeneList.createGeneList(pool);

					newGeneList.loadGeneListFromList(new ArrayList(allIdentifierValues), gene_list_id, pool);
		
					mySessionHandler.createGeneListActivity("Ran Save As on gene list", pool);

					/*
                        		if (selectedGeneList.getGeneList(gene_list_id, dbConn).getNumber_of_genes() > 200) {
                                		additionalInfo =  "<br> <br>" +
                                                               		"NOTE:  Your new gene list contains more than 200 entries, so you may "+
                                                               		"not be able to perform all the functions available on the website.";
                        		}
                        		session.setAttribute("additionalInfo", additionalInfo);
					*/

                        		//Success - "Gene list saved"
                        		session.setAttribute("successMsg", "GL-013");
                        		response.sendRedirect(geneListsDir + "listGeneLists.jsp");
				}
			}
		}
        } 
	formName = "saveAs.jsp";
%>
<%@ include file="/web/geneLists/include/geneListJS.jsp"  %>
<%@ include file="/web/common/header_adaptive_menu.jsp" %>



	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>
	<div class="page-intro">
		<p> Select one or more types of identifiers to save as a new gene list.
		</p>
	</div> <!-- // end page-intro -->

	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>

	<div class="dataContainer" style="padding-bottom: 70px;">

	<form   name="saveAs"
        	method=POST
        	action="saveAs.jsp"
		onSubmit="return IsCreateGeneListFormComplete(this)"
        	enctype="application/x-www-form-urlencoded">

		<div class="title"> Name the new gene list</div>
        	<table class="list_base">
        	<tr>
                	<td> <strong>Gene List Name:</strong> </td>
                	<td> <input type="text" name="gene_list_name"  size="60"> </td>
        	</tr><tr>
                	<td> <strong>Gene List Description:</strong> </td>
                	<td> <textarea  name="description" cols="60" rows="5"></textarea> </td>
        	</tr>
        	</table>
		<BR>

		<%@ include file="/web/geneLists/include/identifierTypes.jsp" %>

		<BR>

		<center>
			<input type="reset" value="Reset"> <%=tenSpaces%>
			<input type="submit" name = "action" value="Save As"> 
		</center>
        	<input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>" >
		</form>

	</div>

<%@ include file="/web/common/footer_adaptive.jsp" %>


