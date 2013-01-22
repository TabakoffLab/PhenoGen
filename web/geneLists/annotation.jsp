<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  The web page created by this file displays the results
 *  		from a call to iDecoder using a pre-defined list of targets.
 *		This also queries the QTL database and knockout databases
 *		for occurrences of the gene identifier.
 *  Todo: 
 *  Modification Log:
		Mar, 2006: Modified by Cheryl Hornbaker to call iDecoder instead.
 *      
--%>
<%@ include file="/web/geneLists/include/geneListHeader.jsp"%>

<%@ include file="/web/geneLists/include/dbutil_jackson.jsp"  %>

<jsp:useBean id="myKnockOut" class="edu.ucdenver.ccp.PhenoGen.data.external.KnockOut"> </jsp:useBean>
<jsp:useBean id="thisIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"> </jsp:useBean>
<jsp:useBean id="myQTL" class="edu.ucdenver.ccp.PhenoGen.data.QTL"> </jsp:useBean>
<jsp:useBean id="myEnsembl" class="edu.ucdenver.ccp.PhenoGen.data.external.Ensembl"> </jsp:useBean>

<%

	QTL.EQTL myEQTL = myQTL.new EQTL();
	log.info("in annotation.jsp. user = " + user);
	log.debug("action = " +action);
	request.setAttribute( "selectedTabId", "annotation" );
	extrasList.add("annotation.js");
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
	optionsList.add("download");
	optionsList.add("moreAnnotation");

	QTL.EQTL[] eQTLList = null;

	String[] jacksonMutantsArray = null; 
	String[] iniaWestMutantsArray = null; 
	String[] iniaPreferenceMutantsArray = null; 

        String [] officialSymbolTargets = {"Gene Symbol"};
	String [] affyTargets = {"Affymetrix ID"};
	String [] chipTargets = {"Affymetrix ID", "CodeLink ID"};
	String [] eQTLTargets = {"Affymetrix ID", "CodeLink ID", "Gene Symbol"};

	String ucscOrganism = null;
	String snpOrganism = null;
	HashMap arrayInfo = null;
	Hashtable ensemblHash = new Hashtable();

	int numRows = 0;
	HashMap currentIDs = new HashMap();
	
        String [] entrezTargets = {
                "RefSeq RNA ID",
                "Gene Symbol",
                "Entrez Gene ID",
                "RefSeq Protein ID"};

        String [] uniprotTargets = {
                "SwissProt ID",
                "SwissProt Name"};
/*
                "RefSeq Protein ID",
                "NCBI Protein ID"};
*/

        String [] mgiTargets = {"MGI ID"};
        String [] rgdTargets = {"RGD ID"};
        String [] flyTargets = {"FlyBase ID"};

        String [] ucscTargets = {
                "RefSeq RNA ID",
                "RefSeq Protein ID",
                "Entrez Gene ID",
                "SwissProt ID",
                "Gene Symbol"};

        String [] refseqTargets = {
                "RefSeq RNA ID",
                "RefSeq Protein ID"};

        String [] ensemblTargets = {
                "Ensembl ID"};

        String [] brainAtlasRefseqTargets = {
                "RefSeq RNA ID"};

        String [] brainAtlasGeneSymbolTargets = {
		"Gene Symbol"};

	formName = "annotation.jsp";

       	if ((action != null) && action.equals("Download")) {
		log.debug("action is Download");
                String downloadPath = userLoggedIn.getUserGeneListsDownloadDir();
		String fullFileName = downloadPath + 
				selectedGeneList.getGene_list_name_no_spaces() + 
				"_BasicAnnotation.txt";

		List downloadTargetList = new ArrayList();
		downloadTargetList.add(officialSymbolTargets);
		downloadTargetList.add(entrezTargets);
		if (selectedGeneList.getOrganism().equals("Mm")) {
			downloadTargetList.add(mgiTargets);
		} else if (selectedGeneList.getOrganism().equals("Rn")) {
			downloadTargetList.add(rgdTargets);
		} else if (selectedGeneList.getOrganism().equals("Dm")) {
			downloadTargetList.add(flyTargets);
		}
		downloadTargetList.add(uniprotTargets);
		downloadTargetList.add(ucscTargets);

		thisIDecoderClient.writeToFileByPrioritizedTarget(iDecoderSet, downloadTargetList, fullFileName);

		request.setAttribute("fullFileName", fullFileName);

		myFileHandler.downloadFile(request, response);
		// This is required to avoid the getOutputStream() has already been called for this response error
		out.clear();
		out = pageContext.pushBody(); 

		mySessionHandler.createGeneListActivity("Downloaded Basic Annotation for Gene List", dbConn);
       	} else {
		if (selectedGeneList.getNumber_of_genes() > 400) { 
			response.sendRedirect("advancedAnnotation.jsp");
		} else {

			String organism = selectedGeneList.getOrganism(); 
			log.debug("organism = "+ organism);

			// default to Mouse
	
			ucscOrganism = selectedGeneList.getOrganism();
			snpOrganism = selectedGeneList.getOrganism();
			snpOrganism = new ObjectHandler().replaceBlanksWithUnderscores(
						new Organism().getOrganism_name(organism, dbConn));
			ucscOrganism = new Organism().getCommon_name_for_abbreviation(organism, dbConn);

			Iterator itr = iDecoderSet.iterator();

        		Set allOfficialSymbols = new TreeSet(); 

			//
			// Get a list of all the gene symbols returned 
			// in the iDecoder call
			//
                	Set allEQTLGeneSymbols = 
				thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersForTarget(
								iDecoderSet, officialSymbolTargets));
			//log.debug("allEQTLGeneSymbols.size() = "+allEQTLGeneSymbols.size());
			//myDebugger.print(allEQTLGeneSymbols);
			//
			// When doing eQTL queries, only get those affy IDs for this array since that is what is 
			// stored in the expression_qtls table
			//
/*
			String[] gene_chip_name = {
						"Mouse Genome 430 2.0 Array",
						"CodeLink Rat Whole Genome Array"
						};
*/
			String[] gene_chip_name = myObjectHandler.getAsArray(myArray.EQTL_ARRAY_TYPES, String.class);
			log.debug("gene_chip_name = "); myDebugger.print(gene_chip_name);

                	Set allEQTLChipIDs =thisIDecoderClient.getValues(
						thisIDecoderClient.getIdentifiersByGeneChip(
							thisIDecoderClient.getIdentifiersForTarget(iDecoderSet, chipTargets), 
							gene_chip_name));
			//log.debug("after getting Affy IDs restricted by gene_chip_name, now allEQTLChipIDs.size() = "+
			//		allEQTLChipIDs.size());
			//myDebugger.print(allEQTLChipIDs);

			List allIdentifiers = new ArrayList();
			List allGenesStrings = myObjectHandler.getAsSeparatedStrings(selectedGeneList.getGenesAsSet("Original", dbConn), ", ", "'", 999);
			log.debug("allGenesStrings = " +allGenesStrings);
			allIdentifiers.addAll(allGenesStrings);
			if (allEQTLGeneSymbols.size() > 0 && allEQTLChipIDs.size() > 0) {
	
				// 
				// See if there is any expression QTL information for any of the eQTL targets
				// If so, add that eQTL ID to a list so that a link can be created on the Basic Annotation page.
				//
				List allEQTLChipIDsStrings = myObjectHandler.getAsSeparatedStrings(allEQTLChipIDs, ", ", "'", 999);
				List allEQTLGeneSymbolsStrings = myObjectHandler.getAsSeparatedStrings(allEQTLGeneSymbols, ", ", "'", 999);
				allIdentifiers.addAll(allEQTLChipIDsStrings);
				allIdentifiers.addAll(allEQTLGeneSymbolsStrings);


			}
			eQTLList = myEQTL.getExpressionQTLInfo(allIdentifiers, "Both", selectedGeneList.getOrganism(), "All", dbConn);
			log.debug("eQTLList = "); myDebugger.print(eQTLList);
			//
			// Get a list of all the ensembl IDs returned 
			// in the first iDecoder call, and pass them to a query at Ensembl to get
			// transcript IDs
			//
                	Set allEnsemblSet = thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersForTarget(iDecoderSet, ensemblTargets));
			//log.debug("allEnsemblSet = "); myDebugger.print(allEnsemblSet);

                              	%><%@ include file="/web/common/dbutil_ensembl.jsp" %><%

			if (ensemblConn != null && !ensemblConn.isClosed()) {
				try {
                               		ensemblHash = myEnsembl.getTranscripts(allEnsemblSet, ensemblConn);
                               		ensemblConn.close();
				} catch (Exception e) {
					log.error("got error retrieving stuff from Ensmbl", e);
				}
			}
			while (itr.hasNext()) {
				Identifier thisIdentifier = (Identifier) itr.next();
				thisIdentifier.setCurrentIdentifier(thisIdentifier.getIdentifier());
				thisIdentifier.setOriginalIdentifier((String) currentIDs.get(thisIdentifier.getIdentifier()));
				//log.debug("this id = "+thisIdentifier.getIdentifier() + ", and related IDs = "); 
				//myDebugger.print(thisIdentifier.getRelatedIdentifiers());
                		HashMap linksHash = thisIdentifier.getTargetHashMap();

                		List officialSymbolList = myObjectHandler.getAsList(thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersForTargetForOneID(linksHash, officialSymbolTargets)));
				if (officialSymbolList != null) {
					//log.debug("officialSymbolList for " + thisIdentifier.getIdentifier() + " contains the following:");
					//myDebugger.print(officialSymbolList);

					allOfficialSymbols.addAll(officialSymbolList);
				}
				List<String> thisEQTLList = myObjectHandler.getAsList(thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersForTargetForOneID(linksHash, eQTLTargets)));

                		if (thisEQTLList != null) {
                        		//log.debug("thisEQTLList = ");myDebugger.print(thisEQTLList);
                        		Set<String> thisEQTLSet = new LinkedHashSet<String>(thisEQTLList);
                        		//log.debug("thisEQTLSet = ");myDebugger.print(thisEQTLSet);
                        		List<String> eQTLLink = new ArrayList<String>();
					for (String thisEQTL : thisEQTLSet) {
						if (eQTLList != null) {
							for (QTL.EQTL eQTL : eQTLList) {
                                				if (eQTL.getIdentifier().equals(thisEQTL)) {
                                        				eQTLLink.add(thisEQTL);
									break;
								}
                                			}
						}
                        		}
                        		String thisEQTLString = myObjectHandler.getAsSeparatedString(eQTLLink, ",", "'");
                        		thisIdentifier.setEQTLString(thisEQTLString);
                        		//log.debug("for id "+thisIdentifier.getIdentifier() + " set QTLString to "+thisIdentifier.getEQTLString());
                		}
                		List ensemblList = myObjectHandler.getAsList(thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersForPrioritizedTargetForOneID(linksHash, ensemblTargets)));
				if (ensemblList != null) {
					for (int i=0; i<ensemblList.size(); i++) {
						String ensemblValue = (String) ensemblList.get(i);
						if (ensemblHash != null && ensemblHash.containsKey(ensemblValue)) {
							List transcriptAccessionIDs = (List) ensemblHash.get(ensemblValue);
                        				thisIdentifier.setTranscripts(transcriptAccessionIDs);
						}
					}
				}
			}

			log.debug("allOfficalSymbols now contains " + allOfficialSymbols.size() + " elements");
			//log.debug("allOfficialSymbols = "); myDebugger.print(allOfficialSymbols);
			
			String [] allOfficialSymbolArray = (String[]) allOfficialSymbols.toArray(
								new String[allOfficialSymbols.size()]); 
	
			//
			// Query the Jackson lab database to see if any mutants exist
			// for this gene identifier.  If they do, add the gene symbol
			// to the jacksonMutants array so that it can be included in the URL
			// 

			if (jacksonConn != null) {
				try {
					jacksonMutantsArray = myKnockOut.getPhenotypicAlleleCount(
								allOfficialSymbolArray, jacksonConn);
				} catch (Exception e) {
					log.error("got error retrieving stuff from Jackson", e);
				}
				//log.debug("size of jacksonMutantsArray = "+jacksonMutantsArray.length);
				//log.debug("jacksonMutantsArray = "); myDebugger.print(jacksonMutantsArray);
			} 

			//
			// Query the INIA West database (Koob) to see if any mutants exist
			// for this gene identifier.  If they do, add the gene symbol
			// to the iniaWestMutants array so that it can be included in the URL
			// 

			iniaWestMutantsArray = myKnockOut.getIniaKnockOutCount(allOfficialSymbolArray, dbConn);
	
			//
			// Query the INIA West database (Blednov) to see if any mutants exist
			// for this gene identifier.  If they do, add the gene symbol
			// to the iniaPreferenceMutants array so that it can be included in the URL
			// 

			iniaPreferenceMutantsArray = myKnockOut.getIniaAlcoholPreferenceCount(allOfficialSymbolArray, dbConn);

			//
			// Get a list of all the affy IDs returned in the iDecoder call
			//
                	Set allAffySet = thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersForTarget(iDecoderSet, affyTargets));
			//log.debug("allAffySet = "); myDebugger.print(allAffySet);

			Results myAffyResults = null;
					
			mySessionHandler.createGeneListActivity("Ran Basic Annotation on gene list", dbConn);
		}
	}

%>

<%@ include file="/web/common/header.jsp" %>


	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>

        <div class="page-intro">
                <p> This page contains links to other databases for the genes in your list.  </p>
        </div> <!-- // end page-intro -->
	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>


	<% if (selectedGeneList.getGene_list_id() != -99) { %>
		  <div class="dataContainer">
			<form 	method="POST"
				name="annotation"
				action="annotation.jsp"
				enctype="application/x-www-form-urlencoded">

			<div class="brClear"></div>

			<div class="scrollable">
			<% if (selectedGeneList.getNumber_of_genes() <= 400) { %>
				<%@ include file="/web/geneLists/include/formatAnnotationResults.jsp" %> 
			<% } %>
			</div>

			<input type="hidden" name="action" value="">
			<input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>"/>
			</form>

		</div>
	<% } %>
    
    <% if (jacksonConn != null) {
			jacksonConn.close();
		}
	%>
	
	<script type="text/javascript">
		$(document).ready(function() {
			setupPage();
			setTimeout("setupMain()", 100); 
			setupExpandCollapse();
		});
	</script>

<%@ include file="/web/common/footer.jsp" %>
