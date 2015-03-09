<%--
 *  Author: Cheryl Hornbaker
 *  Created: July, 2005
 *  Description:  The web page created by this file displays the eQTL query results.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/qtls/include/qtlHeader.jsp"%>

<%

	log.info("in eQTLResults.jsp. user = " + user);
	action = (action != null && !action.equals("") ? action : "All");
	//log.debug("action = " + action);

        extrasList.add("geneListMain.css");
        extrasList.add("locEQTL.css");
        extrasList.add("main.min.css");
        extrasList.add("eQTLResults.js");

	String ensemblOrganism = new ObjectHandler().replaceBlanksWithUnderscores(
					new Organism().getOrganism_name(selectedGeneList.getOrganism(), dbConn));

        String ensemblTarget = " target=\"Ensembl Window\">";

        String ensemblText = "<a href=\"http://www.ensembl.org/" + ensemblOrganism +
				"/Search/Details?species="+
                                ensemblOrganism + ";idx=;q=";

        String ncbiTarget = " target=\"NCBI Window\"";
	String markerText = "<a href=\"http://view.ncbi.nlm.nih.gov/snp/";
	String footnoteText = "identifier maps to more than one gene symbol";

	String haveEQTL = (request.getParameter("haveEQTL") != null ? (String)request.getParameter("haveEQTL") : "Y");
	Double eQTLPValue = (request.getParameter("eQTLPValue") != null ? 
					Double.parseDouble((String) request.getParameter("eQTLPValue")) : 
					new Double(-99));
	int qtlListID = (request.getParameter("qtlListID") != null ? 
					Integer.parseInt((String) request.getParameter("qtlListID")) : 
					-99);
	String constraint = (request.getParameter("constraint") != null ? 
					(String) request.getParameter("constraint") : 
					"none");
	String arrows = (request.getParameter("arrows") != null ? 
					(String) request.getParameter("arrows") : 
					"red");
	log.debug("arrows = "+arrows);
	String constraintInfo = "(i.e., "+ "<b><i>" + 
				(arrows.equals("red") ? "physical location is " : 
				(arrows.equals("green") ? "transcription control location is " : 
				(arrows.equals("both") ? "both physical location and transcription control location are ":""))) +
				"displayed" +
				"</b><i>" + 
				(arrows.equals("green") || arrows.equals("both") ? 
						", and at least one probeset per gene meets the eQTL p-value of <b><i>" + eQTLPValue + "</b></i>" : "") + 
				(qtlListID != -99 && !constraint.equals("none") ? ", and the probesets <b><i>" +
					(constraint.equals("phys") ? "are physically " : 
					(constraint.equals("eQTL") ? "have their transcription control (eQTL) " : 
					(constraint.equals("either") ? "are either physically located or have their transcription control (eQTL) ":
        				(constraint.equals("both") ? "are both physically located and have their transcription control (eQTL) ": "")))) + 
				"located in the region</b></i>" : "") + 
				")";

        String advancedSettings = (request.getParameter( "advSettings" ) != null &&
                                        request.getParameter( "advSettings" ).length() > 0 ?
                                        request.getParameter( "advSettings" ) : "closed");

	QTL selectedQTLList = (qtlListID != -99 ? myQTL.getQTLList(qtlListID, dbConn) : null);
	QTL.Locus[] selectedLoci = (qtlListID != -99 ? selectedQTLList.getLoci() : null);
	String qtl_list_name = (qtlListID != -99 ? selectedQTLList.getQtl_list_name() : "");

	log.debug("haveEQTL = "+haveEQTL + ", qtlListID = "+qtlListID + ", constraint = "+constraint);
	String[] rowRestrictions = (request.getParameter("rowRestrictions") != null ?
		request.getParameterValues("rowRestrictions") : null);
	String[] correlationColumns = (request.getParameter("correlationColumns") != null ?
		request.getParameterValues("correlationColumns") : null);
	String checked = "";
	boolean inGeneList = false;
	boolean meetPValue = false;
	boolean inRegion = false;
	boolean displayCoefficient = false;
	boolean displayRawPValue = false;
	boolean displayAdjPValue = false;
	if (rowRestrictions != null) {
		for (int i=0; i<rowRestrictions.length; i++) {
			if (rowRestrictions[i].equals("inGeneList")) {
				inGeneList = true;
			}
			if (rowRestrictions[i].equals("meetPValue")) {
				meetPValue = true;
			}
			if (rowRestrictions[i].equals("inRegion")) {
				inRegion = true;
			}
		}
	}
	if (correlationColumns != null) {
		for (int i=0; i<correlationColumns.length; i++) {
			if (correlationColumns[i].equals("displayRawPValue")) {
				displayRawPValue = true;
			}
			if (correlationColumns[i].equals("displayAdjPValue")) {
				displayAdjPValue = true;
			}
			if (correlationColumns[i].equals("displayCoefficient")) {
				displayCoefficient = true;
			}
		}
	}
	//log.debug("inGeneList = "+inGeneList);
	//log.debug("displayRawPValue = "+displayRawPValue);
	//log.debug("inRegion = "+inRegion);

	List qtlList = new ArrayList();
	String eQTLID = (String) request.getParameter("eQTLID");
	log.debug("eQTLID parameter = "+eQTLID);
	String tissue = (String) request.getParameter("tissue");
	log.debug("tissue parameter = "+tissue);

/*
	tissue = (tissue == null ? "All" :
		(tissue.equals("brain") ? "Whole Brain" :
		(tissue.equals("heart") ? "Heart" :
		(tissue.equals("brown adipose") ? "Brown Adipose" :
		(tissue.equals("liver") ? "Liver" : "All")))));
	log.debug("tissue parameter now = "+tissue);
*/
	//
	// eQTLID will be 'displayedGenes' if it is called from locationEQTL page 
	//
	Set displayedGenes = (eQTLID.equals("displayedGenes") ? (LinkedHashSet) session.getAttribute("displayedGenes") : null);
	if (displayedGenes != null) {
		qtlList = myObjectHandler.getAsSeparatedStrings(displayedGenes, ",", "'", 999);
	} else {
		qtlList.add(eQTLID);
	}
	//log.debug("in eQTL Results displayedGenes = "); myDebugger.print(displayedGenes);
	//log.debug("eQTLID for displayedGenes = "+eQTLID);
	//log.debug("qtlList= "+qtlList);

	// If this is called from the locationEQTL page, displayedGenes will be not null, so get all eQTL records
	// matching on the gene symbol and probesetID for those with no gene symbols that have physical locations.  
	// Otherwise, it will be called from the Basic Annotation page, so get all the eQTL records
	// matching on probeset ID.
	QTL.EQTL[] myEQTLsBasedOnProbesetID = myEQTL.getExpressionQTLInfo(qtlList, "ProbesetID", selectedGeneList.getOrganism(), tissue, dbConn);
	QTL.EQTL[] myEQTLsBasedOnBoth = myEQTL.getExpressionQTLInfo(qtlList, "Both", selectedGeneList.getOrganism(), tissue, dbConn);

	QTL.EQTL[] myEQTLs = (displayedGenes != null ? 
				myEQTLsBasedOnBoth :
				myEQTLsBasedOnProbesetID); 

	GeneList.Gene[] myGeneArray = selectedGeneList.getGenesAsGeneArray(dbConn); 

	Arrays.sort(myEQTLs);
	Arrays.sort(myGeneArray);

	Set<QTL.EQTL> noDisplayEQTLList = new TreeSet<QTL.EQTL>();
	Set<GeneList.Gene> noDisplayGeneSet = new TreeSet<GeneList.Gene>();
	Set<String> noDisplayGeneStrings = new TreeSet<String>();

	//log.debug("myEQTLs= "); myDebugger.print(myEQTLs);
	//log.debug("myGeneArray= "); myDebugger.print(myGeneArray);

	//
	// noDisplayGeneStrings contains all the genes from the original list that don't have an eQTL record that
	// met the criteria. 
	//
	for (int i=0; i<myGeneArray.length; i++) {
		if (Arrays.binarySearch(myEQTLs, myQTL.new EQTL(myGeneArray[i].getGene_id())) < -1) {
			noDisplayGeneStrings.add(myGeneArray[i].getGene_id());
		}
	}
	List noDisplayGeneList = myObjectHandler.getAsSeparatedStrings(noDisplayGeneStrings, ",", "'", 999); 
	//log.debug("noDisplayGeneList = "); myDebugger.print(noDisplayGeneList);
	QTL.EQTL[] noDisplayGenesWithEQTLs = myEQTL.getExpressionQTLInfo(
					noDisplayGeneList, "ProbesetID", selectedGeneList.getOrganism(), tissue, dbConn);
	//log.debug("noDisplayGenesWithEQTLs = "); myDebugger.print(noDisplayGenesWithEQTLs);

	//
	// noDisplayGeneSet contains all the genes from the original list that don't have an eQTL record that
	// met the criteria. 
	//
	for (int i=0; i<myGeneArray.length; i++) {
		if (Arrays.binarySearch(noDisplayGenesWithEQTLs, myQTL.new EQTL(myGeneArray[i].getGene_id())) < 0 &&
			Arrays.binarySearch(myEQTLs, myQTL.new EQTL(myGeneArray[i].getGene_id())) < 0) {
			noDisplayGeneSet.add(myGeneArray[i]);
		}
	}
	//log.debug("noDisplayGeneSet = "); myDebugger.print(noDisplayGeneSet);
	GeneList.Gene[] noDisplayGenes = 
			(GeneList.Gene[]) noDisplayGeneSet.toArray(
					new GeneList.Gene[noDisplayGeneSet.size()]);

	// Then get all the eQTL records that don't have physical locations
	for (int i=0; i<myEQTLs.length; i++) {
		//log.debug("eQTL is "+myEQTLs[i].getIdentifier() + ", " + myEQTLs[i].getGene_name());
		if ((arrows.equals("red")) && (myEQTLs[i].getGene_chromosome() == null ||
				(myEQTLs[i].getGene_chromosome() != null && 
				myEQTLs[i].getGene_chromosome().equals("")))) {
			noDisplayEQTLList.add(myEQTLs[i]);
			//log.debug("there is no physical location");
		} else {
			//log.debug("this record should be displayed = " + myEQTLs[i].getIdentifier());
		}
	}
	//log.debug("noDisplayEQTLList = "); myDebugger.print(noDisplayEQTLList);
	QTL.EQTL[] noDisplayEQTLs = (QTL.EQTL[]) noDisplayEQTLList.toArray(new QTL.EQTL[noDisplayEQTLList.size()]);

	//log.debug("statistical method = "+selectedGeneList.getStatisticalMethod());
	boolean correlation = (selectedGeneList.getStatisticalMethod() != null &&
				!selectedGeneList.getStatisticalMethod().equals("") &&
				(selectedGeneList.getStatisticalMethod().equals("pearson") || 
        				selectedGeneList.getStatisticalMethod().equals("spearman")) ? true : false);
	
	Hashtable<String, Integer> indexHash = selectedGeneList.getColumnIdxHash();

	String[] tableHeaders = myEQTL.getTableHeaders(correlation);
	List<String[]> rowsWithEQTL = myEQTL.getRowsWithEQTL(correlation, myEQTLs, inGeneList, meetPValue, inRegion, 
								eQTLPValue, constraint, myGeneArray, selectedLoci, indexHash);
	List<String[]> rowsWithoutEQTL = myEQTL.getRowsWithoutEQTL(correlation, indexHash, noDisplayEQTLs, myGeneArray);

        if ((action != null) && action.equals("Download")) {

		String downloadDir = userLoggedIn.getUserGeneListsDownloadDir();
		String downloadFileName = downloadDir + "eQTLResults.txt";
		//File downloadFile = new File(downloadDir + "eQTLResults.txt");
		//log.debug("creating file "+downloadFileName);
		//downloadFile.createNewFile();
		String[] headersForDownload = new String[tableHeaders.length-1];
		for (int i=0; i<tableHeaders.length-1; i++) {
			headersForDownload[i] = tableHeaders[i];
		}

                //BufferedWriter fileListingWriter =
                //	new BufferedWriter(new FileWriter(downloadFileName), 10000);
                BufferedWriter fileListingWriter = myFileHandler.getBufferedWriter(downloadDir + "eQTLResults.txt");
		
		String headerLine = myObjectHandler.getAsSeparatedString(headersForDownload, "\t");

		fileListingWriter.write(headerLine);
		fileListingWriter.newLine();
	
		if (haveEQTL.equals("Y") && myEQTLs.length > 0 & rowsWithEQTL.size() > 0) {
                        for (Iterator itr = rowsWithEQTL.iterator(); itr.hasNext();) {
				String[] thisRow = (String[]) itr.next();
				// If this row does not have a physical location, and the red arrows are selected, skip it
				if ((arrows.equals("red") || arrows.equals("both")) &&  
						thisRow[thisRow.length-7].equals("")) continue; 
				String row = myObjectHandler.getAsSeparatedString(thisRow, "\t");
				fileListingWriter.write(row);
				fileListingWriter.newLine();
			}
		} else if (rowsWithoutEQTL.size() > 0) {
                        for (Iterator itr = rowsWithoutEQTL.iterator(); itr.hasNext();) {
				String[] thisRow = (String[]) itr.next();
				String row = myObjectHandler.getAsSeparatedString(thisRow, "\t");
				fileListingWriter.write(row);
				fileListingWriter.newLine();
			}
		}

		fileListingWriter.newLine();
		fileListingWriter.write("** (1) "+footnoteText);
		fileListingWriter.newLine();
		fileListingWriter.flush();
		fileListingWriter.close();

                request.setAttribute("fullFileName", downloadFileName);

                myFileHandler.downloadFile(request, response);

		//// This is required to avoid the getOutputStream() has already been called for this response error
		out.clear();
		out = pageContext.pushBody(); 

                mySessionHandler.createGeneListActivity("Downloaded eQTLResults", dbConn);
        }

        mySessionHandler.createGeneListActivity(
		"Viewed eQTL results for eQTLIDs " + eQTLID.substring(0,Math.min(eQTLID.length(),20)) + ", and others",
                dbConn);
	
%>


<%@ include file="/web/common/externalWindowHeader.jsp" %>

	<form   method="POST"
        	name="eQTLResults"
                action="eQTLResults.jsp"
                enctype="application/x-www-form-urlencoded">

		<% if (eQTLID.equals("displayedGenes")) { %>
			<%@ include file="/web/qtls/include/customizeButton.jsp" %>
		<% } %>
        	<input type="hidden" name="action" value="">
        	<input type="hidden" name="eQTLID" value="<%=eQTLID%>">
        	<input type="hidden" name="tissue" value="<%=tissue%>">
		<input name="advSettings" type="hidden" value="<%= advancedSettings %>" />
		<input name="eQTLPValue" type="hidden" value="<%= eQTLPValue %>" />
		<input name="qtlListID" type="hidden" value="<%= qtlListID %>" />
		<input name="constraint" type="hidden" value="<%= constraint %>" />
		<input name="arrows" type="hidden" value="<%= arrows %>" />
	</form>

<div class="scrollable" style="z-index:10">

	<div class="title"> Expression QTLs  </div>
	<div class="linkedImg download" id="download"></div>
	<div style="font-size:12px">
	<table name="items" class="list_base tablesorter" cellpadding="0" cellspacing="3" width="99%">
		<thead>
		<tr class="col_title">
			<% for (int i=0; i<tableHeaders.length; i++) { %>
				<th><%=tableHeaders[i]%>
				<% if (i==0) { %>
                                	<span class="info" title="Probeset ID is in the '<i><%=selectedGeneList.getGene_list_name()%></i>' list.">
                                	<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                                	</span></th>
				<% } %>
				</th>
			<% } %>
		</tr>
		</thead>
		<tbody>
		<%
			boolean printFootnoteText = false;
			if (haveEQTL.equals("Y") && myEQTLs.length > 0 & rowsWithEQTL.size() > 0) {
                        	for (Iterator itr = rowsWithEQTL.iterator(); itr.hasNext();) {
					String[] thisRow = (String[]) itr.next();
					// If this row does not have a physical location, and the red arrows are selected, skip it
					if ((arrows.equals("red")) &&  
						thisRow[thisRow.length-8].equals("")) continue; 
					String footnoteNumber = "";
					if (thisRow[1].indexOf(" (1)") > -1) {
						footnoteNumber = "<sup>1</sup>";
						thisRow[1] = thisRow[1].substring(0,thisRow[1].indexOf(" (1)"));
						printFootnoteText = true;
					} 
					for (int i=0; i<thisRow.length; i++) {
						thisRow[i] = (thisRow[i].equals("") ? "&nbsp;" : thisRow[i]);
					}
					%> <tr><%
                                        //      
                                        // Only provide link to ensembl if it's a mouse id (which implies an affy id)
                                        // ensembl does not have information for codeLink ids (we are assuming Rn implies codeLink)
                                        //      
					%><td class="center"><%=thisRow[0]%></a></td><%
                                        if (thisRow[1] != null && !thisRow[1].equals("---") && selectedGeneList.getOrganism().equals("Mm")) {
						%><td><%=ensemblText%><%=thisRow[1]%>"<%=ensemblTarget%><%=thisRow[1]%><%=footnoteNumber%></a></td><%
                                        } else {
						%><td><%=thisRow[1]%><%=footnoteNumber%></td><%
                                        }
                                        if (thisRow[2] != null && !thisRow[2].equals("---")) {
						%><td><%=ensemblText%><%=thisRow[2]%>"<%=ensemblTarget%><%=thisRow[2]%></a></td><%
                                        } else {
                                                        %><td><%=thisRow[2]%></td><%
                                        }
					for (int j=3; j<thisRow.length; j++) {
						// add a hyperlink on the marker column
						if (!selectedGeneList.getOrganism().equals("Rn") && (j==thisRow.length-3)) {
							%><td><%=markerText%><%=thisRow[j]%>"<%=ncbiTarget%>><%=thisRow[j]%></a></td><%
						} else {
							%><td><%=thisRow[j]%></td><%
						}
					}
					if ((new File("/data/LODPlots/Probe." + thisRow[1] + ".jpg")).exists()) {
                                                        %><td><a href="<%=qtlsDir%>lodPlots.jsp?probeID=<%=thisRow[1]%>" target="ImageWindow">View</a></td><%
					} else {
						%><td>&nbsp;</td><%
					}
					%></tr><%
				}
			} else  {
				if (rowsWithoutEQTL.size() > 0) {
                        		for (Iterator itr = rowsWithoutEQTL.iterator(); itr.hasNext();) {
						String[] thisRow = (String[]) itr.next();
						for (int j=0; j<thisRow.length; j++) {
							thisRow[j] = (thisRow[j].equals("") ? "&nbsp;" : thisRow[j]);
						}
						%> <tr><%
						for (int j=0; j<thisRow.length; j++) {
							String extraText = (j==0 ? " class=\"center\"" :""); 
							%><td<%=extraText%>><%=thisRow[j]%></td><%
						}
						%><td colspan="100%" class="center">
						****************
                                                <%=fiveSpaces%>
                                                Probeset did not meet restriction criteria or was not considered in eQTL analysis
                                                <%=fiveSpaces%>
						****************
						</td><%
						%></tr><%
					}
				}
				if (noDisplayGenesWithEQTLs.length > 0) {
                        		for (int i=0; i<noDisplayGenesWithEQTLs.length; i++) {
						List<String> corrCols = (correlation ? 
							myQTL.getCorrelationValues(indexHash, noDisplayGenesWithEQTLs[i].getIdentifier(), myGeneArray) :
							null);
						List<String> endCols = myQTL.getCommonEndColumns(noDisplayGenesWithEQTLs[i]);
						%> <tr>
							<td class="center">*</td>
							<td><%=noDisplayGenesWithEQTLs[i].getIdentifier()%></td>
							<td><%=noDisplayGenesWithEQTLs[i].getGene_name()%></td>
							<% if (corrCols != null) {
								for (Iterator itr = corrCols.iterator(); itr.hasNext();) { 
									String thisCol = (String) itr.next();
									%><td><%=thisCol%></td><%
								}
							} 
							for (Iterator itr = endCols.iterator(); itr.hasNext();) { 
								String thisCol = (String) itr.next();
									%><td><%=thisCol%></td><%
							}
							if ((new File("/data/LODPlots/Probe." + noDisplayGenesWithEQTLs[i].getIdentifier() + ".jpg")).exists()) {
                                                        	%><td><a href="<%=qtlsDir%>lodPlots.jsp?probeID=<%=noDisplayGenesWithEQTLs[i].getIdentifier()%>" target="ImageWindow">View</a></td><%
							} %>
						</tr><%
					}
				}
				if (noDisplayGenes.length > 0) {
                        		for (int i=0; i<noDisplayGenes.length; i++) {
						%> <tr>
							<td class="center">*</td>
							<td><%=noDisplayGenes[i].getGene_id()%></td>
							<td><%=noDisplayGenes[i].getMainGeneSymbol()%></td>
							<td colspan="100%" class="center">
							****************
                                                	<%=fiveSpaces%>
                                                	Probeset did not meet restriction criteria
                                                	<%=fiveSpaces%>
							****************
							</td>
						</tr><%
					}
				}
			}
			%>
		</tbody>
		</table>
		</div>
		<% if (printFootnoteText) { %>
			<br>
			<br>
			<div style="margin-left:5px">
			<sup>1</sup><%=footnoteText%>
			</div>
		<% } %>

</div> <!-- scrollable -->

<script type="text/javascript">
	$(document).ready(function() {
		setupPage();
	});
</script>

<%@ include file="/web/common/externalWindowFooter.html" %>

