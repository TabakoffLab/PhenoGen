<%--
 *  Author: Cheryl Hornbaker
 *  Created: Mar, 2006
 *  Description:  The web page created by this file displays the results
 *  		returned from iDecoder.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/geneLists/include/geneListHeader.jsp" %>

<%	

	log.info("in iDecoderResults.jsp");
    	request.setAttribute( "selectedTabId", "annotation" );
	extrasList.add("iDecoderResults.js");
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
	optionsListModal.add("download");
	optionsList.add("basicAnnotation");
	Set iDecoderValues = (Set) session.getAttribute("iDecoderValues");
	String[] iDecoderTargets = (String[]) session.getAttribute("iDecoderTargets");
	Hashtable ensemblHash = (Hashtable) session.getAttribute("ensemblHash");

	String ensemblOrganism = new ObjectHandler().replaceBlanksWithUnderscores(
							new Organism().getOrganism_name(selectedGeneList.getOrganism(), dbConn));
	String mapViewerOrganism = new ObjectHandler().replaceBlanksWithUnderscores(
							new Organism().getTaxon_id(selectedGeneList.getOrganism(), dbConn));
	log.debug("action in iDecoderResults = "+action);

        if ((action != null) && action.equals("Download")) {
                String fullFileName = userLoggedIn.getUserGeneListsDownloadDir() +
			selectedGeneList.getGene_list_name_no_spaces() +
			 "_AdvancedAnnotation.txt";
		session.setAttribute("fullFileName", fullFileName);
		session.setAttribute("iDecoderValues", iDecoderValues);
		session.setAttribute("iDecoderTargets", iDecoderTargets);
		session.setAttribute("callingForm", "advancedAnnotation.jsp");
		response.sendRedirect(geneListsDir + "downloadAnnotationPopup.jsp?callingForm=iDecoderResults.jsp");
        } 

        String linkText = "";
        String target = " target=\"Link Window\">";
        String mgiTarget = " target=\"MGI Window\">";
        String rgdTarget = " target=\"RGD Window\">";
        String genbankNucleotideTarget = " target=\"NCBI Nucleotide Window\">";
        String genbankProteinTarget = " target=\"NCBI Protein Window\">";
        String genbankOmimTarget = " target=\"NCBI OMIM Window\">";
        String genbankPubMedTarget = " target=\"NCBI PubMed Window\">";
        String genbankTaxonomyTarget = " target=\"NCBI Taxonomy Window\">";
        String mapViewerTarget = " target=\"MapViewer Window\">";
        String locusLinkTarget = " target=\"Locus Link Window\">";
        String swissprotTarget = " target=\"SwissProt Window\">";
        String unigeneTarget = " target=\"Unigene Window\">";
        String cddTarget = " target=\"Conserved Domain Window\">";
        String stanfordTarget = " target=\"Stanford Window\">";
        String torontoTarget = " target=\"University of Toronto Window\">";
        String ensemblTarget = " target=\"Ensembl Window\">";
        String database = "";

	String ncbiText = "<a href=\"http://view.ncbi.nlm.nih.gov/";
        String genbankNucleotideText = ncbiText + "nucleotide/";  
        String genbankGeneText = ncbiText + "gene?term=";  
        String genbankProteinText = ncbiText + "protein/";  
        String omimText = ncbiText + "omim/";  
        String pubMedText = ncbiText + "pubmed/";  
        String taxonomyText = ncbiText + "taxonomy/";  
	String cddText = ncbiText + "cdd/";
	String unigeneText = ncbiText + "unigene/";

        String mgiText = "<a href=\"http://www.informatics.jax.org/javawi2/servlet/WIFetch?page=searchTool&amp;selectedQuery=Accession+IDs&amp;query=";
        String rgdText = "<a href=\"http://rgd.mcw.edu/generalSearch/RgdSearch.jsp?quickSearch=1&amp;searchKeyword=";
        String swissprotText = "<a href=\"http://www.expasy.org/cgi-bin/niceprot.pl?";
        String ensemblSNPText = "<a href=\"http://www.ensembl.org/" + ensemblOrganism + 
				"/transcriptsnpview?db=core;transcript=";
        String ensemblText = "<a href=\"http://www.ensembl.org/" + ensemblOrganism + 
				"/geneview?gene="; 
        String ensemblAffyText = "<a href=\"http://www.ensembl.org/" + ensemblOrganism + 
				"/searchview?species=" +
				ensemblOrganism + "&amp;idx=All&amp;q=";
        String ensemblLocText = "<a href=\"http://www.ensembl.org/" + ensemblOrganism + 
				"/contigview?l="; 
	String mapViewerText = "<a href=\"http://www.ncbi.nlm.nih.gov/mapview/map_search.cgi?taxid=" + mapViewerOrganism +
				"&amp;query=";
	String stanfordText = "<a href=\"http://db.yeastgenome.org/cgi-bin/SGD/locus.pl?locus=";
%>




<%@ include file="/web/common/header_adaptive_menu.jsp" %>
	
	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>
	<div class="page-intro"> Shown below are the links to other databases </div>
	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>
 <style>
                    tr.evenEven td{
                        background: #FFFFFF;
                    }
                    tr.evenOdd td{
                        background: #F5F5F5;
                    }
                    tr.oddEven td{
                        background: #DEDEDE;
                    }
                    tr.oddOdd td{
                        background: #BEBEBE;
                    }
</style>
	<div class="dataContainer" style="padding-bottom:70px;">

	<form   method="post"
		name="annotation"
		action="iDecoderResults.jsp"
        	enctype="application/x-www-form-urlencoded">

		<div class="brClear"></div>
		<input type="hidden" name="action" value="">
        	<input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>" >
	
	</form>

	<table name="items" class="list_base" cellpadding="0" cellspacing="3" width="98%" rules="rows">
		<tr class="col_title">
			<th width="10%" class="noSort">Gene ID</th>
			<th width="25%" class="noSort">Database</th>
			<th width="65%" class="noSort">Links</th>
		</tr>
                
               

<% 	


        //
        // Turn the iDecoderValues into a List of Identifiers
        //
        List myIdentifierList = Arrays.asList(iDecoderValues.toArray((Identifier[]) new Identifier[iDecoderValues.size()]));
        myIdentifierList = new Identifier().sortIdentifiers(myIdentifierList, "identifier");
        Iterator sortedIterator = myIdentifierList.iterator();

	log.debug("size of iDecoderValues is " +iDecoderValues.size());
	//log.debug("is location included?"+Arrays.binarySearch(iDecoderTargets, "Location"));

	mySessionHandler.createGeneListActivity("Looked at Advanced Annotation results", dbConn);
	//
	// go through the original gene list, in sorted order
	//
	String msg = "No identifiers found for selected targets";
        String topOE="odd";
        int geneCnt=0;
        while (sortedIterator.hasNext()) {
                if(geneCnt%2==0){
                    topOE="even";
                }else{
                    topOE="odd";
                }
		List identifiersWithLocationInfo = new ArrayList();
		List geneSymbolsForMapViewer = new ArrayList();
                Identifier thisIdentifier = (Identifier) sortedIterator.next();

		//log.debug("thisIdentifier = "+thisIdentifier);
		//
		// linkKeys contains the databases that have a link for the gene
		//
                HashMap linksHash = thisIdentifier.getTargetHashMap();
		//log.debug("linksHash = "); myDebugger.print(linksHash);
                Enumeration linkKeys = null;
		//
		// If this is the list of Ensembl IDs, then get the Ensembl transcripts for 
		// them and create a new "key" called "Genetic Variations" for this 
		// gene ID 
		//
		List ensemblList = myObjectHandler.getAsList((Set) linksHash.get("Ensembl ID"));
		if (ensemblList != null) {
			//
			// If there is a list of Ensembl IDs in the result, but the user did 
			// not originally request them, remove them because they were used only 
			// to get the transcripts.
			//
			Arrays.sort(iDecoderTargets);
			if (Arrays.binarySearch(iDecoderTargets, "Ensembl ID") < 0) {
				linksHash.remove("Ensembl ID");
			}
			for (int i=0; i<ensemblList.size(); i++) {
                		String ensemblValue = ((Identifier) ensemblList.get(i)).getIdentifier();
                        	if (ensemblHash != null && ensemblHash.containsKey(ensemblValue)) {
					List ensemblTranscripts = (List) ensemblHash.get(ensemblValue);
					if (ensemblTranscripts != null && ensemblTranscripts.size() > 0) {
						Set ensemblIdentifiers = new HashSet();
						for (int j=0; j<ensemblTranscripts.size(); j++) {
							ensemblIdentifiers.add(new Identifier((String) ensemblTranscripts.get(j)));
						}
						linksHash.put("Genetic Variations", ensemblIdentifiers);
					}
                        	}
			}
                	thisIdentifier.setTargetHashMap(linksHash);
			//log.debug("just set linksHash for "+thisIdentifier.getIdentifier() +
			//	" to "); myDebugger.print(linksHash);
		}


        session.setAttribute("downloadiDecoderValues" , new TreeSet(myIdentifierList));

		//log.debug("iDecoderValues = "); myDebugger.print(iDecoderValues);
		Set linkKeysSet = linksHash.keySet();
		//log.debug("linkKeysSet = "); myDebugger.print(linkKeysSet);
		String[] linkKeysArray = (String[]) linkKeysSet.toArray(new String[linksHash.size()]);
		Arrays.sort(linkKeysArray);

		for (int i=0; i<linkKeysArray.length; i++) {
			String thisKey = linkKeysArray[i];
			if (thisKey.equals("MGI ID")) { 
				linkText = mgiText;
				target = mgiTarget;
				database = "MGD";
			} else if (thisKey.equals("RGD ID")) {
				linkText = rgdText;
				target = rgdTarget;
				database = "RGD";
			} else if (thisKey.equals("Entrez Gene ID")) {
				linkText = genbankGeneText;
				target = locusLinkTarget;
				database = "NCBI-genbank Gene Accession ID";
			} else if (thisKey.equals("NCBI RNA ID")) {
				linkText = genbankNucleotideText;
				target = genbankNucleotideTarget;
				database = "NCBI-genbank Nucleotide Accession ID";
			} else if (thisKey.equals("RefSeq RNA ID")) { 
				linkText = genbankNucleotideText;
				target = genbankNucleotideTarget;
				database = "NCBI-refseq mRNA Accession ID";
			} else if (thisKey.equals("NCBI Protein ID")) {
				linkText = genbankProteinText;
				target = genbankProteinTarget;
				database = "NCBI-genbank Protein Accession ID";
			} else if (thisKey.equals("RefSeq Protein ID")) { 
				linkText = genbankProteinText;
				target = genbankProteinTarget;
				database = "NCBI-refseq Protein Accession ID";
			} else if (thisKey.equals("Synonym") 
				|| thisKey.equals("Gene Symbol")) {
				linkText = genbankGeneText;
				target = genbankNucleotideTarget;
				if (thisKey.equals("Synonym")) {
					database = "Synonym";
				} else if (thisKey.equals("Gene Symbol")) {	
					database = "Gene Symbol";
				}
			} else if (thisKey.equals("UniGene ID")) {
				linkText = unigeneText;
				target = unigeneTarget;
				database = "Unigene";
			} else if (thisKey.equals("SwissProt ID")
				|| thisKey.equals("SwissProt Name")) {
				linkText = swissprotText;
				target = swissprotTarget;
				if (thisKey.equals("SwissProt ID")) {
					database = "SwissProt ID";
				} else if (thisKey.equals("SwissProt Name")) {	
					database = "SwissProt Name";
				}
			} else if (thisKey.equals("Genetic Variations")) {	
				database = "Genetic Variations";
				linkText = ensemblSNPText;
				target = ensemblTarget;
			} else if (thisKey.equals("Ensembl ID")) {	
				database = "Ensembl";
				linkText = ensemblText;
				target = ensemblTarget;
			} else if (thisKey.equals("Affymetrix ID")) {	
				database = "Affymetrix probeset";
				linkText = ensemblAffyText;
				target = ensemblTarget;
			} else {
				linkText = "";
				database = thisKey; 
			}

			List linkList = myObjectHandler.getAsList((Set) linksHash.get(thisKey));
			myIdentifier.sortIdentifiers(linkList, "identifier");
                        String oddEven=topOE+"Odd";
                        if(i%2==0){
                            oddEven=topOE+"Even";
                        }
                        
			if (i==0) {
	                        %><tr class="<%=oddEven%>"><td><%=thisIdentifier.getIdentifier()%></td><%
			} else {
	                        %><tr class="<%=oddEven%>"><td>&nbsp;</td><%
			}
			
			if (!thisKey.equals("Location")) {
				%><td><%=database%></td><%
			} %>
                        <td>
                        <% 
			if (thisKey.equals("Affymetrix ID") || thisKey.equals("CodeLink ID")) {
				// arrayHash contains the gene chip name pointing to a Set of Identifiers
				TreeMap arrayHash = myIDecoderClient.getIdentifiersByGeneChip((Set) linksHash.get(thisKey));
				//log.debug("arrayHash = "+arrayHash);
		                for (Iterator itr = arrayHash.keySet().iterator(); itr.hasNext();) {
					String chipName = (String) itr.next();	
					%><%=chipName%>:<%=twoSpaces%><%
		                	for (Iterator idItr = ((Set) arrayHash.get(chipName)).iterator(); idItr.hasNext();) {
						Identifier thisID = (Identifier) idItr.next();
                                		String linkListValue = thisID.getIdentifier();
						if (!linkText.equals("")) {
							%> <%=linkText%><%=linkListValue%>" <%=target%> <%
						} 
                                		%><%=linkListValue%> <%
						if (!linkText.equals("")) {
							%></a><%
						} 
 						%>&nbsp;&nbsp;&nbsp;<%
					}
 					%><BR><%
                        	}
			} else if (thisKey.equals("Location")) {
				for (int j=0; j<linkList.size(); j++) {
					Identifier relatedIdentifier = (Identifier) linkList.get(j);
					identifiersWithLocationInfo.add(relatedIdentifier);
				}
			} else {
				for (int j=0; j<linkList.size(); j++) {
					Identifier relatedIdentifier = (Identifier) linkList.get(j);
					if ((Arrays.binarySearch(iDecoderTargets, "Location") >= 0) &&
							((relatedIdentifier.getChromosome() != null && 
							!relatedIdentifier.getChromosome().equals("")) ||
							(relatedIdentifier.getMapLocation() != null && 
							!relatedIdentifier.getMapLocation().equals("")))) { 
							identifiersWithLocationInfo.add(relatedIdentifier);
					}
					if (Arrays.binarySearch(iDecoderTargets, "Location") >= 0 &&
						relatedIdentifier.getIdentifierTypeName() != null &&
						relatedIdentifier.getIdentifierTypeName().equals("Gene Symbol")) { 
						geneSymbolsForMapViewer.add(relatedIdentifier);
					}
                                	String linkListValue = ((Identifier) linkList.get(j)).getIdentifier();
					if (!linkText.equals("")) {
						%> <%=linkText%><%=linkListValue%>" <%=target%> <%
					} 
                                	%><%=linkListValue%> <%
					if (!linkText.equals("")) {
						%></a><%
					} 
 					%>&nbsp;&nbsp;&nbsp;<%
                        	}
			}
                        %> </td></tr><%
                }
		if (identifiersWithLocationInfo.size() > 0) {
			%><tr><td>&nbsp;</td><td>Location</td><td><%
			for (Iterator itr = identifiersWithLocationInfo.iterator(); itr.hasNext(); ) {
				Identifier locationIdentifier = (Identifier) itr.next();
				%><%=locationIdentifier.getQualifiedLocation()%><%=twoSpaces%><%
				if (!locationIdentifier.getIdentifierTypeName().equals("Entrez Gene ID") &&
					locationIdentifier.getMapLocation() != null &&
					locationIdentifier.getMapLocation().indexOf("-") > 0) {
					%><%=ensemblLocText%><%=locationIdentifier.getChromosomeLocation()%>" <%=ensemblTarget%>ContigView</a><%
				}
				%><BR><%
			}
			%></td></tr><%
		}
		if (geneSymbolsForMapViewer.size() > 0) {
			%><tr><td>&nbsp;</td><td>&nbsp;</td><td>MapViewer:<%=twoSpaces%><%
			for (Iterator itr = geneSymbolsForMapViewer.iterator(); itr.hasNext(); ) {
				Identifier geneSymbolIdentifier = (Identifier) itr.next();
				%><%=mapViewerText%><%=geneSymbolIdentifier.getIdentifier()%>" <%=mapViewerTarget%><%=geneSymbolIdentifier.getIdentifier()%></a>
				&nbsp;&nbsp;&nbsp;
				<%	
			}
			%></td></tr><%
		}
		
		if (linksHash.size() > 0 ) {
			msg = "";
			%><tr><td colspan=3><hr class=annotation></td></tr> <%
		}
            geneCnt++;
	}
	if (!msg.equals("")) {
		%><tr><td colspan=3><h1> <%=msg%></h1></td></tr><%
	}
	session.setAttribute("iDecoderValues", iDecoderValues);
%> 

<%
    
String[] hiddenCheckBoxiDecoderTargets              = (String[])    session.getAttribute("checkBoxiDecoderTargets");
String[] hiddenCheckBoxaffymetrixChipTargets        = (String[])    session.getAttribute("checkBoxaffymetrixChipTargets");
String[] hiddenCheckBoxcodeLinkChipTargets          = (String[])    session.getAttribute("checkBoxcodeLinkChipTargets");

if (hiddenCheckBoxiDecoderTargets != null) {
  for (String checkBoxiDecoderTargetsItem : hiddenCheckBoxiDecoderTargets) {
       %><input type="checkbox" checked style="display:none;" name="iDecoderChoice" value="<%=checkBoxiDecoderTargetsItem%>"/><%
  }
}

if (hiddenCheckBoxaffymetrixChipTargets != null) {
  for (String checkBoxaffymetrixChipTargetsItem : hiddenCheckBoxaffymetrixChipTargets) {
       %><input type="checkbox" checked style="display:none;" name="AffymetrixArrayChoice" value="<%=checkBoxaffymetrixChipTargetsItem%>"/><%
  }
}

if (hiddenCheckBoxcodeLinkChipTargets != null) {
  for (String hiddenCheckBoxcodeLinkChipTargetsItem : hiddenCheckBoxcodeLinkChipTargets) {
       %><input type="checkbox" checked style="display:none;" name="CodeLinkArrayChoice" value="<%=hiddenCheckBoxcodeLinkChipTargetsItem%>"/><%
  }
}


%>
 
<!-- </table></td></tr> -->
</table>
</div>
<div class="itemDetails"></div>
	<script type="text/javascript">
		$(document).ready(function() {
			setupPage();
		});
	</script>

<%@ include file="/web/common/footer_adaptive.jsp" %>

