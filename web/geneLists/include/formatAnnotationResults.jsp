<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  This file formats the results obtained from iDecoder.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%
%>

	<div class="title"> Links to Other Databases </div>
	<table name="items" class="list_base tablesorter" cellpadding="0" cellspacing="2" width="95%">

	<thead>
	<tr class="col_title">
		<th>Accession ID</th>
		<th>Official Symbol</th>
		<th>RefSeq</th>
		<% if (selectedGeneList.getOrganism().equals("Mm")) { %>
			<th>MGI</th>
		<% } else if (selectedGeneList.getOrganism().equals("Rn")) { %> 
			<th>RGD</th>
		<% } else if (selectedGeneList.getOrganism().equals("Dm")) { %>
			<th>FlyBase</th>
		<% } %>
		<th>UniProt</th>
		<th>UC Santa Cruz
		<% if (selectedGeneList.getOrganism().equals("Mm")) { %>
			<BR>------------<BR>
			UCSC with RNASeq data for ILSXISS Mice
		<% } else if (selectedGeneList.getOrganism().equals("Rn")) { %>
			<BR>------------<BR>
			UCSC with RNASeq data for BNLX/SHRH Rats
		<% } %>
		</th>
		<th>Genetically<BR>Modified<BR>Animal<BR>Available</th>
		<th>QTLs
                        <span class="info" title="Quantitative Trait Loci.">
                        <img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        </span>
		</th>
		<th>Genetic Variations
                        <span class="info" title="Genetic variations (e.g., in/del, polymorphisms) in the 
				transcripts of interest.">
                        <img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        </span>
		</th>
		<% if (selectedGeneList.getOrganism().equals("Mm")) { %>
			<th class="noSort"> <a href="" onClick="return popUp('include/allenBrainAtlasInstructions.jsp')"> 
				Allen Brain Atlas<BR>
				(Instructions)
				</a></th>
		<% } %>
	</tr>
	</thead>
	<tbody>

<% 	
	String columnName = "";
	String officialSymbolText = "<a href=\"http://view.ncbi.nlm.nih.gov/gene?term=";
	String entrezText = "<a href=\"http://view.ncbi.nlm.nih.gov/nucleotide/";
	String mgiText = "<a href=\"http://www.informatics.jax.org/javawi2/servlet/WIFetch?"+
				"page=searchTool&amp;selectedQuery=Accession+IDs&amp;query=";
	String rgdText = "<a href=\"http://rgd.mcw.edu/generalSearch/RgdSearch.jsp?"+
				"quickSearch=1&amp;searchKeyword=";
	String flyText = "<a href=\"http://flybase.bio.indiana.edu/reports/";
	String uniprotText = "<a href=\"http://www.uniprot.org/entry/";

	String ucscText = "<a href=\"http://genome.ucsc.edu/cgi-bin/hgTracks?org=" + 
				ucscOrganism + "&amp;position=";

				/*
				track type=bigBed name="ILS1" colorByStrand="0,0,255 255,0,0" bigDataUrl=http://ucsc:JU7etr5t@phenogen.ucdenver.edu/ucsc/ILS1.bb
				track type=bigBed name="ILS2" colorByStrand="0,0,255 255,0,0" bigDataUrl=http://ucsc:JU7etr5t@phenogen.ucdenver.edu/ucsc/ILS2.bb
				track type=bigBed name="ISS1" colorByStrand="0,0,255 255,0,0" bigDataUrl=http://ucsc:JU7etr5t@phenogen.ucdenver.edu/ucsc/ISS1.bb
				track type=bigBed name="ISS2" colorByStrand="0,0,255 255,0,0" bigDataUrl=http://ucsc:JU7etr5t@phenogen.ucdenver.edu/ucsc/ISS2.bb
				*/
	String ucscTextWithRNASeq = "<a href=\"http://genome.ucsc.edu/cgi-bin/hgTracks?org=" + 
				ucscOrganism + 
				"&amp;hgt.customText=http://ucsc:JU7etr5t%40phenogen.ucdenver.edu/ucsc/UCSCTrackLines" +
/*
				"&amp;hgct_customText=track%20type=bigBed%20name=ILS1%20colorByStrand=%220,0,255%20255,0,0%22%20bigDataUrl=http://ucsc:JU7etr5t%40phenogen.ucdenver.edu/ucsc/ILS1.bb" +
				"&amp;hgct_customText=track%20type=bigBed%20name=ILS2%20colorByStrand=%220,0,255%20255,0,0%22%20bigDataUrl=http://ucsc:JU7etr5t%40phenogen.ucdenver.edu/ucsc/ILS2.bb" +
				"&amp;hgct_customText=track%20type=bigBed%20name=ISS1%20colorByStrand=%220,0,255%20255,0,0%22%20bigDataUrl=http://ucsc:JU7etr5t%40phenogen.ucdenver.edu/ucsc/ISS1.bb" +
				"&amp;hgct_customText=track%20type=bigBed%20name=ISS2%20colorByStrand=%220,0,255%20255,0,0%22%20bigDataUrl=http://ucsc:JU7etr5t%40phenogen.ucdenver.edu/ucsc/ISS2.bb" +
*/
				"&amp;position=";

	String ucscTextWithRatRNASeq = "<a href=\"http://genome.ucsc.edu/cgi-bin/hgTracks?org=" + 
				ucscOrganism + 
				"&amp;hgt.customText=http://ucsc:JU7etr5t%40phenogen.ucdenver.edu/ucsc/UCSCRatTrackLines" +
/*
				"&amp;hgct_customText=track%20type=bigBed%20name=ILS1%20colorByStrand=%220,0,255%20255,0,0%22%20bigDataUrl=http://ucsc:JU7etr5t%40phenogen.ucdenver.edu/ucsc/ILS1.bb" +
				"&amp;hgct_customText=track%20type=bigBed%20name=ILS2%20colorByStrand=%220,0,255%20255,0,0%22%20bigDataUrl=http://ucsc:JU7etr5t%40phenogen.ucdenver.edu/ucsc/ILS2.bb" +
				"&amp;hgct_customText=track%20type=bigBed%20name=ISS1%20colorByStrand=%220,0,255%20255,0,0%22%20bigDataUrl=http://ucsc:JU7etr5t%40phenogen.ucdenver.edu/ucsc/ISS1.bb" +
				"&amp;hgct_customText=track%20type=bigBed%20name=ISS2%20colorByStrand=%220,0,255%20255,0,0%22%20bigDataUrl=http://ucsc:JU7etr5t%40phenogen.ucdenver.edu/ucsc/ISS2.bb" +
*/
				"&amp;position=";

	String webQTLText = "<a href=\"http://www.webqtl.org/cgi-bin/WebQTL.py?"+
				"cmd=show&amp;db=";

	String mutantText = "<a href=\"" + geneListsDir + "allele.jsp?knockoutSource=";
	String eQTLText = "<a href=\"" + qtlsDir + "eQTLResults.jsp?eQTLID=";
	String snpText = "<a href=\"http://www.ensembl.org/" +
				snpOrganism + "/transcriptsnpview?db=core;transcript=";
	String mgiSnpText = "<a href=\"http://www.informatics.jax.org/searches/snp_report.cgi?geneSymname=";
	List thisList = null;
	String thisValue = "";
	String thisText = "";
	String extraText = "";
	String pTag = "";
	String closingTag = "";
	String target = null;

	//
	// Turn the iDecoderSet into a List of Identifiers
	//
	List myIdentifierList = Arrays.asList(iDecoderSet.toArray((Identifier[]) new Identifier[iDecoderSet.size()]));
	myIdentifierList = myIdentifier.sortIdentifiers(myIdentifierList, "identifier");
	Iterator sortedIterator = myIdentifierList.iterator();
	
	while (sortedIterator.hasNext()) {
		List officialSymbolMutants = new ArrayList();

		Identifier thisIdentifier = (Identifier) sortedIterator.next();

		// 
		// key contains the currently selected ID
		// currentIDs.get(key) contains the original accession ID 
		//

		HashMap linksHash = thisIdentifier.getTargetHashMap();

		//log.debug("thisIdentifier.getIdentifier() = " + thisIdentifier.getIdentifier() + ", linksHash = "); myDebugger.print(linksHash);
		List<String> officialSymbolList = myObjectHandler.getAsList(thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersForPrioritizedTargetForOneID(linksHash, officialSymbolTargets)));
		//log.debug("now officialsymbolList = "+officialSymbolList);
                List<String> entrezList = myObjectHandler.getAsList(thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersForPrioritizedTargetForOneID(linksHash, entrezTargets)));
                List<String> uniprotList = myObjectHandler.getAsList(thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersForPrioritizedTargetForOneID(linksHash, uniprotTargets)));
                List<String> mgiList = myObjectHandler.getAsList(thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersForPrioritizedTargetForOneID(linksHash, mgiTargets)));
                List<String> rgdList = myObjectHandler.getAsList(thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersForPrioritizedTargetForOneID(linksHash, rgdTargets)));
                List<String> flyList = myObjectHandler.getAsList(thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersForPrioritizedTargetForOneID(linksHash, flyTargets)));
                List<String> ucscList = myObjectHandler.getAsList(thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersForPrioritizedTargetForOneID(linksHash, ucscTargets)));
                List<String> affyList = myObjectHandler.getAsList(thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersForPrioritizedTargetForOneID(linksHash, affyTargets)));
		List<String> refseqList = myObjectHandler.getAsList(thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersForPrioritizedTargetForOneID(linksHash, refseqTargets)));
                List<String> brainAtlasRefseqList = myObjectHandler.getAsList(thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersForPrioritizedTargetForOneID(linksHash, brainAtlasRefseqTargets)));
                List<String> brainAtlasGeneSymbolList = myObjectHandler.getAsList(thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersForPrioritizedTargetForOneID(linksHash, brainAtlasGeneSymbolTargets)));

        	%>
		<tr>

		<%-- this prints the currently selected identifier and 
			the original identifier in the first column --%>


		<%
		String radioButton = "";
		if (selectedGeneList.getUserIsOwner().equals("Y")) {
			//radioButton = "<input type=\"radio\" name=\"" + thisIdentifier.getOriginalIdentifier() + "\" value=\"" + thisIdentifier.getOriginalIdentifier() + "\"";
		} %>
		<td> <!-- Commented out for ZZZ-369: Remove currently selected identifiers <strong><%=thisIdentifier.getCurrentIdentifier()%> </strong>
			<BR> --> 
			<%=radioButton%> <%=thisIdentifier.getIdentifier()%>  
            <%if (officialSymbolList != null && officialSymbolList.size() > 0) {%>
            	<div class="smallSummary"><a href="<%=request.getContextPath()%>/gene.jsp?geneTxt=<%=officialSymbolList.get(0)%>&speciesCB=<%=selectedGeneList.getOrganism()%>&auto=Y&newWindow=Y">Detailed Transcription Information</a></div>
            <%}%>
            
<!-- <p><a href="<%=geneListsDir%>showGraph.jsp?identifier=<%=thisIdentifier.getIdentifier()%>" target="_blank">Show Graph</a></p> -->
		<input type="hidden" name="<%=thisIdentifier.getOriginalIdentifier()%>_currentValue" value="<%=thisIdentifier.getCurrentIdentifier()%>">
		</td>
		<% 
		String officialSymbolString = "";
		if (officialSymbolList != null && officialSymbolList.size() > 0) {
			for (int i=0; i< officialSymbolList.size(); i++) {
				//
				// If any of the official symbols occur in any of the xxxMutants array, then
				// create a link in the mutants column to the mutant source 
				// Also create an array of official symbols to pass to the source 
				// 
				if ((jacksonMutantsArray != null && Arrays.binarySearch(jacksonMutantsArray, officialSymbolList.get(i)) >= 0) || 
					(iniaWestMutantsArray != null && Arrays.binarySearch(iniaWestMutantsArray, officialSymbolList.get(i)) >= 0) ||
					(iniaPreferenceMutantsArray != null && Arrays.binarySearch(iniaPreferenceMutantsArray, officialSymbolList.get(i)) >= 0)) {
					if (!officialSymbolMutants.contains(officialSymbolList.get(i))) {
						officialSymbolMutants.add(officialSymbolList.get(i));
					}
				} 
			}
			for (int i=0; i< officialSymbolList.size(); i++) {
				if (jacksonMutantsArray != null && Arrays.binarySearch(jacksonMutantsArray, officialSymbolList.get(i)) >= 0) {
					thisIdentifier.setJacksonSearchString("[" + myObjectHandler.getAsSeparatedString(officialSymbolMutants, ",%20") + "]");
				} else if (jacksonMutantsArray == null) {
					thisIdentifier.setJacksonSearchString("Unavailable");
				}
				if (iniaWestMutantsArray != null && Arrays.binarySearch(iniaWestMutantsArray, officialSymbolList.get(i)) >= 0) {
					thisIdentifier.setIniaWestSearchString("[" + myObjectHandler.getAsSeparatedString(officialSymbolMutants, ",%20") + "]");
				}
				if (iniaPreferenceMutantsArray != null && Arrays.binarySearch(iniaPreferenceMutantsArray, officialSymbolList.get(i)) >= 0) {
					thisIdentifier.setIniaPreferenceSearchString("[" + myObjectHandler.getAsSeparatedString(officialSymbolMutants, ",%20") + "]");
				}
			}
			//if (officialSymbolMutants != null && officialSymbolMutants.size() > 0) {
			//	officialSymbolString = "[" + myObjectHandler.getAsSeparatedString(officialSymbolMutants, ",%20") + "]";
			//}
		}
		%>	 

<!--
		<td class=center><a href="cytoscape.jnlp" target="_blank">
		<img src="<%=imagesDir%>l-026.gif" width="20" height="10" border="0" alt=""></a> </td>
-->
		<td>
		<% 
		//log.debug("now officialsymbolList = "+officialSymbolList);
		if (officialSymbolList != null && officialSymbolList.size() > 0) {
			columnName = "Symbol";
			thisList = officialSymbolList;
			thisText = officialSymbolText;
			target = "Entrez Window";
			%><%@ include file="/web/geneLists/include/displayIdentifiers.jsp" %>
		<% 
		} else {
			%>&nbsp<%
		}
		%> </td>

		<td>
		<% if (entrezList != null && entrezList.size() > 0) {
			columnName = "Entrez";
			thisList = entrezList;
			thisText = entrezText;
			target = "Entrez Window";
			%><%@ include file="/web/geneLists/include/displayIdentifiers.jsp" %><% 
		} else {
			%>&nbsp<%
		}	
		%> </td>

		<%
		if (selectedGeneList.getOrganism().equals("Mm") ||
			selectedGeneList.getOrganism().equals("Rn") ||
			selectedGeneList.getOrganism().equals("Dm")) {
			columnName = "OrgSpecific";

			%><td><%
			if (selectedGeneList.getOrganism().equals("Mm")) {
				thisList = mgiList;
				thisText = mgiText;
				target = "MGI Window";
			} else if (selectedGeneList.getOrganism().equals("Rn")) {
				thisList = rgdList;
				thisText = rgdText;
				target = "RGD Window";
			} else if (selectedGeneList.getOrganism().equals("Dm")) {
				thisList = flyList;
				thisText = flyText;
				target = "FlyBase Window";
			}
			if (thisList != null && thisList.size() > 0) {
				%><%@ include file="/web/geneLists/include/displayIdentifiers.jsp" %><%
			} else {
				%>&nbsp<%
			}

			%></td><%
		} %>
		<td>
		<% if (uniprotList != null && uniprotList.size() > 0) {
			columnName = "Uniprot";
			thisList = uniprotList;
			thisText = uniprotText;
			target = "Uniprot Window";
			%><%@ include file="/web/geneLists/include/displayIdentifiers.jsp" %><%
		} else {
			%>&nbsp<%
		}
		%> </td>

		<td>
		<% if (ucscList != null && ucscList.size() > 0) {
			columnName = "Ucsc";
			thisList = ucscList;
			thisText = ucscText;
			target = "UCSC Window";
			%><%@ include file="/web/geneLists/include/displayIdentifiers.jsp" %><%

			if (selectedGeneList.getOrganism().equals("Mm")) { 
				%>----------<BR><%	
				columnName = "UcscWithRNASeq";
				thisList = ucscList;
				thisText = ucscTextWithRNASeq;
				extraText = " w/ RNASeq Data";
				target = "UCSC Window";
				%><%@ include file="/web/geneLists/include/displayIdentifiers.jsp" %><%
			}else if (selectedGeneList.getOrganism().equals("Rn")) { 
				%>----------<BR><%	
				columnName = "UcscWithRNASeq";
				thisList = ucscList;
				thisText = ucscTextWithRatRNASeq;
				extraText = " w/ RNASeq Data";
				target = "UCSC Window";
				%><%@ include file="/web/geneLists/include/displayIdentifiers.jsp" %><%
			}
		} else {
			%>&nbsp<%
		}
		extraText = "";
		%> </td>

		<td>
		<% if (!thisIdentifier.getJacksonSearchString().equals("")) {
			if (thisIdentifier.getJacksonSearchString().equals("Unavailable")) {
				%><%=thisIdentifier.getJacksonSearchString()%><BR><%
			} else {
				%><%=mutantText%>1&amp;geneSymbol=<%=thisIdentifier.getJacksonSearchString()%>" target="Mutant Window">MGI</a><BR><%
			}
		} 
		if (!thisIdentifier.getIniaWestSearchString().equals("")) {
			%><%=mutantText%>2&amp;geneSymbol=<%=thisIdentifier.getIniaWestSearchString()%>" target="Mutant Window">Crabbe et al.</a><BR><%
		} 
		if (!thisIdentifier.getIniaPreferenceSearchString().equals("")) {
			%><%=mutantText%>3&amp;geneSymbol=<%=thisIdentifier.getIniaPreferenceSearchString()%>" target="Mutant Window">U Texas</a><BR><%
		} 
		%> 
		</td> 

		<td>
		<% 
		if (affyList != null && affyList.size() > 0) {
			String affyString = "(" + myObjectHandler.getAsSeparatedString(affyList, ",", "'") + ")";
			for (int i=0; i< affyList.size(); i++) {
				String affyValue = (String) affyList.get(i);
				//
				// Find the array type for this affyValue
				//
				if (arrayInfo != null) {
					List arrayList = Arrays.asList((String[])arrayInfo.get(affyValue));
					String dbName = "";
					if (arrayList.contains("MG-U74Av2") 
//						|| arrayList.contains("MOE430A") 
//						|| arrayList.contains("Mouse430A_2")
						) {
	
						if (arrayList.contains("MG-U74Av2") 
							//|| arrayList.contains("MG-U74Bv2")
							) {
							dbName = "bra12-03pdnn";
						}
//						else if (arrayList.contains("MOE430A")
//							|| arrayList.contains("Mouse430A_2")
//							) {
//							dbName = "bra10-04pdnn";
//						}
						else {
						}
						String thisWebQTLText = webQTLText + dbName + "&probeset=";
						%> <%=thisWebQTLText%><%=affyValue%>" target="WebQTL Window">WebQTL</a> <BR><%
					}
				}
			}
		} else {
			%>&nbsp<%
		}

		//log.debug("here QTLSring = "+thisIdentifier.getEQTLString());
		if (thisIdentifier.getEQTLString() != null && 
			!thisIdentifier.getEQTLString().equals("") && 
			!thisIdentifier.getEQTLString().equals("()")//&&
			//!selectedGeneList.getOrganism().equals("Mm")// ***************  REMOVE ONCE PUBLIC LXS DATASET is fixed TEMPORARY since LXS Dataset has problems.
			) {
				%> <%=eQTLText%><%=thisIdentifier.getEQTLString()%>&tissue=All" target="QTL Window">PhenoGen eQTL</a> <BR><%
		} else {
			%>&nbsp<%
		}
		%> 
		</td> <td>
		<% if (thisIdentifier.getTranscripts() != null && thisIdentifier.getTranscripts().size() > 0) {
			columnName = "Transcript";
			thisList = thisIdentifier.getTranscripts();
			thisText = snpText;
			target = "Ensembl Window";
			%><%@ include file="/web/geneLists/include/displayIdentifiers.jsp" %><%
		} else {
			%>&nbsp<%
		}
		if (officialSymbolList != null  && officialSymbolList.size() > 0&& selectedGeneList.getOrganism().equals("Mm")) {
			columnName = "Snp";
			thisList = officialSymbolList;
			thisText = mgiSnpText;
			target = "SNP Window";
			%><%@ include file="/web/geneLists/include/displayIdentifiers.jsp" %><%
		} else {
			%>&nbsp<%
		}
		%> </td> <% 
		if (selectedGeneList.getOrganism().equals("Mm")) {
			%><td><%
			String idString = "";
			if (brainAtlasRefseqList.size() > 0) {
				idString = "refseq=" + myObjectHandler.getAsSeparatedString(brainAtlasRefseqList, "%20OR%20refseq=");
			} 
			if (brainAtlasGeneSymbolList.size() > 0) {
				if (idString.equals("")) {
					idString = "genesym="; 
				} else {
					idString = idString + "%20OR%20genesym=";
				}
				idString = idString + myObjectHandler.getAsSeparatedString(brainAtlasGeneSymbolList, "%20OR%20genesym=");
			} 
			if (!idString.equals("")) {
				%><a href="http://www.brain-map.org/search.do?queryText=<%=idString%>" target="Allen Brain Atlas Window">Link</a><%
			} 
			%></td><%
		}
		%></tr><% 
	}	
	%> </tbody></table> <%

	//
	// print at the bottom of the page all the identifiers that were not found by iDecoder
	//
	if (noIDecoderList != null && noIDecoderList.size() > 0) {
		Collections.sort(noIDecoderList);
        	%>
		<div class="title">Identifiers Not Found </div>
		<table name="notFoundItems" class="list_base tablesorter" cellpadding="0" cellspacing="2" width="95%">
		<thead>
		<tr class="col_title">
			<th>Accession ID</th>
			<th class="noSort">Official Symbol</th>
			<th class="noSort">RefSeq</th>
			<% if (selectedGeneList.getOrganism().equals("Mm")) { %>
				<th class="noSort">MGI</th>
			<% } else if (selectedGeneList.getOrganism().equals("Rn")) { %> 
				<th class="noSort">RGD</th>
			<% } else if (selectedGeneList.getOrganism().equals("Dm")) { %>
				<th class="noSort">FlyBase</th>
			<% } %>
			<th class="noSort">UniProt</th>
			<th class="noSort">UC Santa Cruz</th>
			<th class="noSort">Genetically<BR>Modified<BR>Animal<BR>Available</th>
			<th class="noSort">QTLs</th>
			<th class="noSort">Genetic Variations</th>
			<% if (selectedGeneList.getOrganism().equals("Mm")) { %>
				<th class="noSort"> Allen Brain Atlas<BR> (Instructions)</th>
			<% } %>
		</tr>
		</thead>
		<tbody>
		<%
		for (int i=0; i< noIDecoderList.size(); i++) {
			thisValue = (String) noIDecoderList.get(i);
			%>
			<tr>
			<%-- this prints the currently selected identifier and 
				the original identifier in the first column --%>

			<% if (selectedGeneList.getUserIsOwner().equals("Y")) { %>
				<td> <%=thisValue%> 
				<input type="hidden" 
					name="<%=currentIDs.get(thisValue)%>_currentValue" 
					value="<%=thisValue%>">
			<% } else { %>
				<td><%=currentIDs.get(thisValue)%>
			<% } %>
			<BR>
			<i> <!-- commented out for ZZZ-369: Remove currently selected identifiers <input type="radio" 
				name="<%=currentIDs.get(thisValue)%>" 
				value="<%=currentIDs.get(thisValue)%>"> 
				<%=currentIDs.get(thisValue)%> --> 
			</i>
			</td>
			<td colspan="100%" class="center"> Not Available </td>
			</tr>
		<% 
		}
		%> </tbody></table> <%
	}
%> 
	

