<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %>

<jsp:useBean id="myQTL" class="edu.ucdenver.ccp.PhenoGen.data.QTL"> </jsp:useBean>
<jsp:useBean id="myOrganism" class="edu.ucdenver.ccp.PhenoGen.data.Organism"> </jsp:useBean>
<jsp:useBean id="thisIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"> </jsp:useBean>

<%
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setDateHeader("Expires", 0);
	QTL.EQTL myEQTL = myQTL.new EQTL();
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
        QTL[] myQTLLists= myQTL.getQTLLists(userID, selectedGeneList.getOrganism(), dbConn);
        QTL[] myQTLs= myQTL.getQTLListsForUser(userID, dbConn);
        QTL.Locus[] selectedLoci = null; 
        QTL.EQTL[] expressionQTLs = null;
	QTL.EQTL[] expressionQTLsPlusNoPhysicalLocation = null;
	String qtl_list_name = "";

        LinkedHashSet iDecoderSetForGenes = (session.getAttribute("iDecoderSet") != null ? 
			new LinkedHashSet((Set) session.getAttribute("iDecoderSet")) : null);

        Organism.Chromosome[] myChromosomes = myOrganism.getChromosomes(selectedGeneList.getOrganism(), dbConn);

	session.setAttribute("myChromosomes", myChromosomes);

        fieldNames.add("genesOrProbes");
        fieldNames.add("tissue");
        fieldNames.add("eQTLPValue");
        fieldNames.add("constraint");
        fieldNames.add("ht");
        fieldNames.add("wd");
        fieldNames.add("mode");

        int qtlListID = ((String) request.getParameter("qtlListID") != null ?
                Integer.parseInt((String) request.getParameter("qtlListID")) : -99);

        if (qtlListID != -99) {
                selectedLoci = myQTL.getQTLList(qtlListID, dbConn).getLoci();
		qtl_list_name = myQTL.getQtl_list_name(qtlListID, dbConn);
        }

	//log.debug("iDecoderSetForGenes contains "+iDecoderSetForGenes.size() + " elements.");
	//log.debug("at start. iDecoderSetForGenes = "); myDebugger.print(iDecoderSetForGenes);
        //log.debug("qtlListID = "+qtlListID);
        //log.debug("selectedLoci = "); myDebugger.print(selectedLoci);

        %><%@ include file="/web/common/getFieldValues.jsp" %><%

        //log.debug("fieldValues = "); myDebugger.print(fieldValues);
        String[] displayWhich = request.getParameterValues("displayWhich");

        boolean redArrows = false;
        boolean greenArrows = false;
        if (displayWhich != null) {
                for (int i=0; i<displayWhich.length; i++) {
                        //log.debug("displayWhich[i] = "+displayWhich[i]);
                        if (displayWhich[i].equals("redArrows")) {
                                redArrows = true;
                        }
                        if (displayWhich[i].equals("greenArrows")) {
                                greenArrows = true;
                        }
                }
        } else {
		// default is true
		redArrows = true;
	}

	String arrows=(redArrows ? (greenArrows ? "both" : "red") : "green");

        fieldValues.put("constraint",
                        ((String) fieldValues.get("constraint") == null  ||
                                ((String) fieldValues.get("constraint")).equals("") ?
                        "none" :
                        (String) fieldValues.get("constraint")));

        String constraint = (String) fieldValues.get("constraint");
       	if ((String)fieldValues.get("eQTLPValue") == null || ((String)fieldValues.get("eQTLPValue")).equals("")) {
                        fieldValues.put("eQTLPValue", "0.05");
	}

	Double eQTLPValue = Double.parseDouble((String) fieldValues.get("eQTLPValue"));

	String geneListParameters = "Genes from '" + selectedGeneList.getGene_list_name() +                        
        			"' gene list ";
	if (constraint.equals("phys")) {
		geneListParameters = geneListParameters + "that are physically located ";
	} else if (constraint.equals("eQTL")) {
		geneListParameters = geneListParameters + "whose transcription control (eQTL) is located ";
	} else if (constraint.equals("either")) {
		geneListParameters = geneListParameters + "that are either physically located or whose transcription control (eQTL) is located ";
	} else if (constraint.equals("both")) {
		geneListParameters = geneListParameters + "that are both physically located and whose transcription control (eQTL) is located ";
	}
	if (!qtl_list_name.equals("")) {
		geneListParameters = geneListParameters + "within QTLs from '" + qtl_list_name + "' QTL list ";
	}
	mySessionHandler.createGeneListActivity("Looked at Location tab with these parameters: " + geneListParameters, dbConn);
	session.setAttribute("geneListParameters", geneListParameters); 

	request.setAttribute( "selectedTabId", "loc_eQTL" );
	extrasList.add("eqtl.temp.css");
	extrasList.add("locEQTL.css");
        extrasList.add("jquery.PrintArea.js");
        extrasList.add("qtlForms.js");
        extrasList.add("locationEQTL.js");
		extrasList.add("jquery.tooltip.js");
		extrasList.add("jquery.tooltip.css");
        extrasList.add("eQTLGraphicControl.js");
		
	extrasList.add("defineQTL.js");

	String advancedSettings = (request.getParameter( "advSettings" ) != null && 
					request.getParameter( "advSettings" ).length() > 0 ?
					request.getParameter( "advSettings" ) : "closed"); 

	String mode = (fieldValues.get( "mode" ) != null && 
		!fieldValues.get("mode").equals("") ? (String) fieldValues.get( "mode" ) : "initial");

	String tissue = (String) fieldValues.get("tissue");
	String[] targets = new String[4];
        targets[0] = "Affymetrix ID";
        targets[1] = "CodeLink ID";
        targets[2] = "Gene Symbol";
        //targets[3] = "Location";

	if (selectedGeneList.getOrganism().equals("Mm") || selectedGeneList.getOrganism().equals("Rn")) {
		log.debug("before getGeneSymbolsForProbeIDs");
		Hashtable probeToGeneSymbolHash = selectedGeneList.getGeneSymbolsForProbeIDs(dbConn);
		// This is a collection of Lists
		Collection useEQTLGeneSymbolCollection = probeToGeneSymbolHash.values();
		Set useEQTLGeneSymbolSet = new TreeSet();
		for (Iterator itr=useEQTLGeneSymbolCollection.iterator(); itr.hasNext();) {
			List thisList = (List) itr.next();
			useEQTLGeneSymbolSet.addAll(thisList);
		}
		List useEQTLGeneSymbolList = myObjectHandler.getAsSeparatedStrings(useEQTLGeneSymbolSet, ",", "'", 999); 

		Set useProbeIDSet = selectedGeneList.getProbeIDsWithNoGeneSymbols(dbConn);
		List useProbeIDList = myObjectHandler.getAsSeparatedStrings(useProbeIDSet, ",", "'", 999); 
		Set useProbeIDSetWithNoPhysicalLocation = selectedGeneList.getProbeIDsWithNoGeneSymbolsOrPhysicalLocation(dbConn);
		List useProbeIDListWithNoPhysicalLocation = myObjectHandler.getAsSeparatedStrings(useProbeIDSetWithNoPhysicalLocation, ",", "'", 999); 

		Set nonProbeIDSet = new TreeSet(); 

		Set nonProbeIDs = selectedGeneList.getNonProbeIDs(dbConn);

		for (Iterator itr=iDecoderSetForGenes.iterator(); itr.hasNext();) {
			Identifier id = (Identifier) itr.next();
			// If the id is not a probeset ID, then get the gene symbol from it's related identifiers
			if (nonProbeIDs.contains(id.getIdentifier())) { 
				//log.debug("this id is not a probeset, so use iDecoder gene symbols"+id.getIdentifier());
				id.setChromosomeMapTransAnnotation(null);
				id.setChromosomeMapGeneAnnotation(null);

				// Get the gene symbols from iDecoder 
				Set geneSymbolIdentifiers = thisIDecoderClient.getIdentifiersForTargetForOneID(
							id.getTargetHashMap(), new String[] {targets[2]});
				nonProbeIDSet.addAll(geneSymbolIdentifiers);
				List geneSymbols = new ArrayList(thisIDecoderClient.getValues(geneSymbolIdentifiers));
				//log.debug("setting the gene symbols for this id to "); myDebugger.print(geneSymbols);
				id.setEQTLGeneSymbols(geneSymbols);
			// Otherwise, if the id is a probeset ID, then mark it as such and don't use iDecoder related identifiers
			} else { 
				//log.debug("this id is a probeset "+id.getIdentifier());
				id.setUseForEQTLMatch(true);
				id.setEQTLGeneSymbols((List) probeToGeneSymbolHash.get(id.getIdentifier()));
			}
		}

		List nonProbeIDList = myObjectHandler.getAsSeparatedStrings(thisIDecoderClient.getValues(nonProbeIDSet), ",", "'", 999); 

		log.debug("probeToGeneSymbolHash = "); myDebugger.print(probeToGeneSymbolHash);
		log.debug("useEQTLGeneSymbolSet = "); myDebugger.print(useEQTLGeneSymbolSet);
		log.debug("useProbeIDSet = "); myDebugger.print(useProbeIDSet);
		log.debug("useProbeIDSetWithNoPhysicalLocation = "); myDebugger.print(useProbeIDSetWithNoPhysicalLocation);
		log.debug("nonProbeIDSet = "); myDebugger.print(nonProbeIDSet);
		log.debug("useEQTLGeneSymbolList = "); myDebugger.print(useEQTLGeneSymbolList);
		log.debug("useProbeIDList = "); myDebugger.print(useProbeIDList);
		log.debug("useProbeIDListWithNoPhysicalLocation = "); myDebugger.print(useProbeIDListWithNoPhysicalLocation);
		log.debug("nonProbeIDList = "); myDebugger.print(nonProbeIDList);

	        tissue = (greenArrows ? 
                	(tissue.equals("brain") ? "Whole Brain" :
	                (tissue.equals("heart") ? "Heart" :
	                (tissue.equals("brown adipose") ? "Brown Adipose" :
	                (tissue.equals("liver") ? "Liver" : "All")))) : "All");
	        log.debug("tissue parameter now = "+tissue);
		log.debug("calling getExpressionQTLInfo with useEQTLGeneSymbolList");
		List eQTLListByGeneName = Arrays.asList(myEQTL.getExpressionQTLInfo(
					useEQTLGeneSymbolList, "GeneName", selectedGeneList.getOrganism(), tissue, dbConn));

		log.debug("calling getExpressionQTLInfo with useProbeIDList");
		List eQTLListByProbeID = Arrays.asList(myEQTL.getExpressionQTLInfo(
					useProbeIDList, "ProbesetID", selectedGeneList.getOrganism(), tissue, dbConn));

		log.debug("calling getExpressionQTLInfo with useProbeIDListWithNoPhysicalLocation");
		List eQTLListByProbeIDWithNoPhysicalLocation = Arrays.asList(myEQTL.getExpressionQTLInfo(
					useProbeIDListWithNoPhysicalLocation, "ProbesetID", selectedGeneList.getOrganism(), tissue, dbConn));

		log.debug("calling getExpressionQTLInfo with nonProbeIDList");
		List eQTLListByBoth = Arrays.asList(myEQTL.getExpressionQTLInfo(
					nonProbeIDList, "Both", selectedGeneList.getOrganism(), tissue, dbConn));

		List eQTLList = new ArrayList();
		eQTLList.addAll(eQTLListByGeneName);
		eQTLList.addAll(eQTLListByProbeID);
		eQTLList.addAll(eQTLListByBoth);
		List eQTLListPlusNoPhysicalLocationList = new ArrayList(eQTLList);
		eQTLListPlusNoPhysicalLocationList.addAll(eQTLListByProbeIDWithNoPhysicalLocation);
		expressionQTLs = (QTL.EQTL[]) eQTLList.toArray(new QTL.EQTL[eQTLList.size()]);
		expressionQTLsPlusNoPhysicalLocation = (QTL.EQTL[]) eQTLListPlusNoPhysicalLocationList.toArray(new QTL.EQTL[eQTLListPlusNoPhysicalLocationList.size()]);
		/*
		log.debug("eQTLListByGeneName = "); myDebugger.print(eQTLListByGeneName);
		log.debug("eQTLListByProbeID = "); myDebugger.print(eQTLListByProbeID);
		log.debug("eQTLListByBoth = "); myDebugger.print(eQTLListByBoth);
		log.debug("expressionQTLsPlusNoPhysicalLocation = "); myDebugger.print(expressionQTLsPlusNoPhysicalLocation);
		*/
		log.debug("number of expressionQTLs values returned = " + expressionQTLs.length);
		log.debug("expressionQTLs = "); myDebugger.print(expressionQTLs);

	}
	//log.debug("myChromosomes = "); myDebugger.print(myChromosomes);

	// These two are Sets of Identifiers
	LinkedHashSet genesToDisplay = new LinkedHashSet();
        LinkedHashSet transToDisplay = new LinkedHashSet();

	// These two are Sets of Strings
        LinkedHashSet displayedGenes = new LinkedHashSet();
        LinkedHashSet regionsToDisplay = new LinkedHashSet();

	if (redArrows && iDecoderSetForGenes != null) {
		genesToDisplay = myEQTL.getGenesToDisplay(expressionQTLs, iDecoderSetForGenes, selectedGeneList.getOrganism());
		//log.debug("iDecoderSetForGenes = "); myDebugger.print(iDecoderSetForGenes);
		//log.debug("genesToDisplay = "); myDebugger.print(genesToDisplay);
		displayedGenes.addAll(thisIDecoderClient.getValues(genesToDisplay));
		log.debug("displayedGenes = "); myDebugger.print(displayedGenes);
	}
	if (greenArrows && expressionQTLsPlusNoPhysicalLocation != null && expressionQTLsPlusNoPhysicalLocation.length > 0) {
		log.debug("before gettting TransToDisplay");
		transToDisplay = myEQTL.getTransToDisplay(expressionQTLsPlusNoPhysicalLocation, 
						iDecoderSetForGenes, 
						selectedGeneList.getOrganism(),
						eQTLPValue, 
						"none");
		displayedGenes.addAll(thisIDecoderClient.getValues(transToDisplay));
		//log.debug("2 displayedGenes = "); myDebugger.print(displayedGenes);
	}
	if (selectedLoci != null && selectedLoci.length > 0) {
		// Do this if the user chooses any of the radio buttons except the 'No restrictions'
		if (!constraint.equals("none")) {
			displayedGenes = new LinkedHashSet();
			genesToDisplay = new LinkedHashSet();
			transToDisplay = new LinkedHashSet();
			LinkedHashSet genesInRegion = new LinkedHashSet();
			LinkedHashSet transInRegion = new LinkedHashSet();
			for (int i=0; i<selectedLoci.length; i++) {
				QTL.Locus locus = selectedLoci[i];
				regionsToDisplay.add(locus.getChromosome() + "|||" +
						locus.getRange_start() + "-" + locus.getRange_end());
				// Find the trans that are in the region
				//log.debug("there are "+expressionQTLs.length + " expressionQTL records returned");
				if (expressionQTLs != null && expressionQTLs.length > 0 &&  
					expressionQTLsPlusNoPhysicalLocation != null && expressionQTLsPlusNoPhysicalLocation.length > 0) {
log.debug("there are this many expressionQTLsPlusNoPhysicalLocation = "+expressionQTLsPlusNoPhysicalLocation.length);
log.debug("there are this many iDecoderSetForGenes = "+iDecoderSetForGenes.size());
log.debug("locus = "+locus);
log.debug("organism = "+selectedGeneList.getOrganism());
log.debug("eQTLPValue = "+eQTLPValue);
					transInRegion.addAll(myEQTL.getTransInRegion(expressionQTLsPlusNoPhysicalLocation, 
									iDecoderSetForGenes, 
									locus,
									selectedGeneList.getOrganism(), 
									eQTLPValue));
log.debug("after call");
					genesInRegion.addAll(myEQTL.getGenesInRegion(expressionQTLs, 
									iDecoderSetForGenes, 
									locus,
									selectedGeneList.getOrganism())); 
				}
				//log.debug("genesInRegion = "); myDebugger.print(genesInRegion);
				//log.debug("transInRegion = "); myDebugger.print(transInRegion);
				if (constraint.equals("phys")) {
					if (redArrows && genesInRegion != null && genesInRegion.size() > 0) {
						//genesToDisplay = myEQTL.getGenesToDisplay(genesInRegion);
						genesToDisplay = myEQTL.getGenesToDisplay(expressionQTLs, genesInRegion, selectedGeneList.getOrganism());
					}
					if (greenArrows && expressionQTLsPlusNoPhysicalLocation != null && expressionQTLsPlusNoPhysicalLocation.length > 0) {
						transToDisplay = myEQTL.getTransToDisplay(expressionQTLsPlusNoPhysicalLocation, 
										genesToDisplay,
										selectedGeneList.getOrganism(),
										eQTLPValue,
										constraint);
					}
					//log.debug("genesToDisplay for phys= "); myDebugger.print(genesToDisplay);
					//log.debug("trans for phys = "); myDebugger.print(transToDisplay);
				} else if (constraint.equals("eQTL")) {
					if (redArrows && genesInRegion != null && genesInRegion.size() > 0) {
						//genesToDisplay = myEQTL.getGenesToDisplay(transInRegion);
						genesToDisplay = myEQTL.getGenesToDisplay(expressionQTLs, transInRegion, selectedGeneList.getOrganism());
					}
					if (greenArrows && expressionQTLsPlusNoPhysicalLocation != null && expressionQTLsPlusNoPhysicalLocation.length > 0) {
						//log.debug("constraint is eQTL. transInRegion = "); myDebugger.print(transInRegion);
						transToDisplay = myEQTL.getTransToDisplay(expressionQTLsPlusNoPhysicalLocation, 
										transInRegion, 
										selectedGeneList.getOrganism(),
										eQTLPValue,
										constraint);
					}
 				} else if (constraint.equals("either")) {
					if (redArrows && genesInRegion != null && genesInRegion.size() > 0) {
						//genesToDisplay = myEQTL.getGenesToDisplay(genesInRegion);
						//genesToDisplay.addAll(myEQTL.getGenesToDisplay(transInRegion));
						genesToDisplay = myEQTL.getGenesToDisplay(expressionQTLs, genesInRegion, selectedGeneList.getOrganism());
						genesToDisplay.addAll(myEQTL.getGenesToDisplay(expressionQTLs, transInRegion, selectedGeneList.getOrganism()));
					}
					if (greenArrows && expressionQTLsPlusNoPhysicalLocation != null && expressionQTLsPlusNoPhysicalLocation.length > 0) {
						transToDisplay = myEQTL.getTransToDisplay(expressionQTLsPlusNoPhysicalLocation, 
										genesToDisplay,
										selectedGeneList.getOrganism(),
										eQTLPValue,
										constraint);
						transToDisplay.addAll(myEQTL.getTransToDisplay(expressionQTLsPlusNoPhysicalLocation, 
										transInRegion, 
										selectedGeneList.getOrganism(),
										eQTLPValue,
										constraint));
					}
				} else if (constraint.equals("both")) {
					if (redArrows && genesInRegion != null && genesInRegion.size() > 0) {
						//genesToDisplay = myEQTL.getGenesToDisplay(genesInRegion);
						//genesToDisplay.retainAll(myEQTL.getGenesToDisplay(transInRegion));
						genesToDisplay = myEQTL.getGenesToDisplay(expressionQTLs, genesInRegion, selectedGeneList.getOrganism());
						genesToDisplay.retainAll(myEQTL.getGenesToDisplay(expressionQTLs, transInRegion, selectedGeneList.getOrganism()));
					}
					if (greenArrows && expressionQTLsPlusNoPhysicalLocation != null && expressionQTLsPlusNoPhysicalLocation.length > 0) {
						transToDisplay = myEQTL.getTransToDisplay(expressionQTLsPlusNoPhysicalLocation, 
										genesToDisplay,
										selectedGeneList.getOrganism(),
										eQTLPValue,
										constraint);
						transToDisplay.retainAll(myEQTL.getTransToDisplay(expressionQTLsPlusNoPhysicalLocation, 
										transInRegion, 
										selectedGeneList.getOrganism(),
										eQTLPValue,
										constraint));
					}
				}
				displayedGenes.addAll(thisIDecoderClient.getValues(genesToDisplay));
				//log.debug("3 displayedGenes= "); myDebugger.print(displayedGenes);
				displayedGenes.addAll(thisIDecoderClient.getValues(transToDisplay));
				//log.debug("4 displayedGenes= "); myDebugger.print(displayedGenes);
			}
		// display the QTL regions if they select 'No Restrictions'
		} else {
			//log.debug("constraint is none, so getting QTLs");
			for (int i=0; i<selectedLoci.length; i++) {
				QTL.Locus locus = selectedLoci[i];
				regionsToDisplay.add(locus.getChromosome() + "|||" +
						locus.getRange_start() + "-" + locus.getRange_end());
			}
		}
	}
	//log.debug("by now genesToDisplay = "); myDebugger.print(genesToDisplay);
	//log.debug("by now transToDisplay = "); myDebugger.print(transToDisplay);
	//log.debug("by now regionsToDisplay"); myDebugger.print(regionsToDisplay);
	for (Iterator itr=iDecoderSetForGenes.iterator(); itr.hasNext();) {
		Identifier id = (Identifier) itr.next();
		//log.debug("gene symbols for this id are: "); myDebugger.print(id.getEQTLGeneSymbols());
		if (displayedGenes.contains(id.getIdentifier()) && id.getEQTLGeneSymbols() != null && id.getEQTLGeneSymbols().size() > 0) { 
			//log.debug("getting gene symbols for "+id.getIdentifier());
			displayedGenes.addAll(id.getEQTLGeneSymbols());
		}
	}

	request.getSession().setAttribute("genesToDisplay", genesToDisplay);
	request.getSession().setAttribute("organismToDisplay",selectedGeneList.getOrganism());
	log.debug(" added session variable for organismToDisplay "+selectedGeneList.getOrganism());
	request.getSession().setAttribute("displayedGenes", displayedGenes);
	//log.debug("5 displayedGenes = "); myDebugger.print(displayedGenes);
	// this has to be set for nameGeneList.jsp
	request.getSession().setAttribute("geneListSet", displayedGenes);
	request.getSession().setAttribute("transToDisplay", transToDisplay);
	request.getSession().setAttribute("regionsToDisplay", regionsToDisplay);
	request.getSession().setAttribute("selectedGeneList", selectedGeneList);
	request.getSession().setAttribute("dbConn", dbConn);

	%>
<%@ include file="/web/common/header_adaptive_menu.jsp" %> 
	<script type="text/javascript">
		var ctrlMode = "<%= mode %>";
		var qtlListID = "<%= qtlListID %>";
	  </script>

	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>
        <div class="page-intro">
                <p>&nbsp;  </p>
        </div> <!-- // end page-intro -->

<% if (fromQTL.equals("")) { %>
	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>
<% } %>
	
    
    
	  <div class="dataContainer" style="padding-bottom:70px;">
	   <div class="menuBar">
            <div id="tabMenu">
                 <div class="inlineButton" id="btnSaveGenes"><a href="#" >Save displayed genes</a><span class="info" title="Save the genes (triangular markers) that are displayed on the chromosomal map.">
                        <img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        </span></div>
                        <span>|</span>
         <div class="inlineButton"><a href=""  target="eQTLResults Window" 
                onClick="return popUp('<%=qtlsDir%>eQTLResults.jsp?eQTLID=displayedGenes&eQTLPValue=<%=eQTLPValue%>&qtlListID=<%=qtlListID%>&constraint=<%=constraint%>&arrows=<%=arrows%>&tissue=<%=tissue%>')">View in table form</a><span class="info" title="View in tabular form the physical location and eQTL details about the
                genes (triangular markers) displayed on the chromosomal map.">
                        <img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        </span>
                       	</div> 
        </div> <!-- tabMenu -->
        <div id="wait" style="text-align:center;"><img src="<%=imagesDir%>/wait.gif"/> Loading...
        </div>
    </div> <!-- menuBar -->
    <script type="text/javascript">
		$("#wait").hide();
    </script>
		<div class="brClear"></div>

	    <div id="displayLocEQTL">

	      <div id="graphic_container" class="<%=mode%>" >

        <div class="graphicControls">
          <div class="graphicEnlarge <%=mode%>"></div>
          <div class="graphicShrink <%=mode%>"></div>
          <div class="rotateChromoVertical <%=mode%>"></div>
          <div class="graphicPrint" data-specifiedPrintArea="div.horzontalImgPrintArea"></div>
          <div class="graphicDownload"></div>
        </div>

		<div style="float: left; clear: left; margin: 0 0 0 5px; font-size: 12px; color: #888;">Click chromosome for an expanded view</div>

		<div style="float: none; clear: both; height: 0px;"></div>

		<div id="graphic">
			<%@ include file="/web/geneLists/include/drawGeneGraphic.jsp" %>
		</div>

	      </div>


      <div id="eQTLRegionConfiguration" class="<%=mode%>">
        <form name="graphicSettingsForm" id="graphicSettingsForm" action="" method="get">
          <input name="geneListID" type="hidden" value="<%= selectedGeneList.getGene_list_id() %>" />
          <input name="qtlListID" type="hidden" value="<%= qtlListID %>" />
          <input name="mode" type="hidden" value="<%= mode %>" />
          <input name="chromosome" type="hidden" value="" />
          <input name="advSettings" type="hidden" value="<%= advancedSettings %>" />


		  <input name="ht" type="hidden" value="<%= fieldValues.get( "ht" ) %>" />
		  <input name="wd" type="hidden" value="<%= fieldValues.get( "wd" ) %>" />

		  <div class="menuBar">
		    <div class="title"> Gene Graphic Settings </div>
		  </div>

		  <div id="regionsOfInterest">

		    <div class="graphicSettingsWindow">
		      <div class="checkOption">
			<% 
			String checked = (redArrows ? "checked" : "");

                        selectName = "genesOrProbes";                         
			selectedOption = (String) fieldValues.get(selectName);
                        onChange = "form.submit()";
                        style = "";
                        optionHash = new LinkedHashMap();
                        optionHash.put("genes", "genes");
                        //optionHash.put("probes", "probes");
                        //optionHash.put("probesets", "probesets");
                        %>
			<input type="checkbox" name="displayWhich" value="redArrows" <%=checked%> onChange="form.submit()">
                	Show physical location of genes <%=twoSpaces%>(<img src="<%=imagesDir%>icons/redArrow.gif" alt="redArrow">)
                	<!-- <%@ include file="/web/common/selectBox.jsp" %> -->

              </div>

              <div class="checkOption">
                <div style="float: left;">
                        <% 
			checked = (greenArrows ? "checked" : ""); 
                        selectName = "tissue";
                        selectedOption = (String) fieldValues.get(selectName);
                        onChange = "form.submit()";
                        style = "";
                        optionHash = new LinkedHashMap();
                        optionHash.put("brain", "brain");
						if(selectedGeneList.getOrganism().equals("Rn")){
                        	optionHash.put("heart", "heart");
                        	optionHash.put("liver", "liver");
                        	optionHash.put("brown adipose", "brown adipose");
						}
                        %>
			<input type="checkbox" name="displayWhich" value="greenArrows" <%=checked%> onChange="form.submit()">
			Show genomic locations of transcription control in 
                        <%@ include file="/web/common/selectBox.jsp" %> 
			<%=twoSpaces%>(<img src="<%=imagesDir%>icons/greenArrow.gif" alt="greenArrow">)
                </div> 

                <div style="float: left; clear: both; margin: 3px 0 0 20px; width: 200px; text-align: right;">
                    ( eQTL p-value <
                        <%
                        selectName = "eQTLPValue";
                        selectedOption = (String) fieldValues.get(selectName);
                        onChange = "form.submit()";
                        style = "";
                        optionHash = new LinkedHashMap();
                        optionHash.put("0.001", "0.001");
                        optionHash.put("0.01", "0.01");
                        optionHash.put("0.05", "0.05");
                        optionHash.put("0.1", "0.1");
                        %>
                        <%@ include file="/web/common/selectBox.jsp" %>
                        )
                        <span class="info" title="The p-value threshold that your eQTLs must meet in order to be
						displayed on the chromosomal map.">
                        <img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        </span>
                </div>
              </div>
            </div>

            <div id="advancedSettingsButton" class="button menu">
              <b>
                <b>
                  <b>Advanced Settings
                        <span class="info" title="Use to create and/or select user-defined chromosomal regions.">
                        <img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        </span>&nbsp;&nbsp;&nbsp; 
			</b>
                </b>
              </b>
            </div>

            <div id="advancedSettingsRegions">
              <div class="menuBar ">
                <div class="title">User Defined Regions</div>
              </div>

              <div class="submenu">
                <div class="button" name="createNewRegion">
                  <b>
                    <b>
                      <b>Create New Region
                        <span class="info" title="Use to define new chromosomal regions.">
                        <img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        </span>
			</b>
                    </b>
                  </b>
                </div>
                <div class="expandList button">
			<b><b><b>Select Different Region
                        	<span class="info" title="Use to select a different chromosomal regions.">
                        	<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        	</span>
			</b></b></b>
                </div>
              </div>

              <div class="list_container" >
		<%@ include file="/web/geneLists/include/regionList.jsp" %>
              </div>

              <div class="advancedSettings">
                <div class="title"> Limit Genes by Region </div>
                <div class="graphicOptions">
                        <%
                        radioName = "constraint";
                        selectedOption = (String) fieldValues.get(radioName);
                        onClick = "form.submit()";
                        optionHash = new LinkedHashMap();
                        optionHash.put("none", "No restrictions<br/>");
                        optionHash.put("phys", "Physical location of gene within region<br/>");                         
						optionHash.put("eQTL", "Transcription control (eQTL) within region<br/>");                         
						optionHash.put("either", "Either physical location or transcription control (eQTL) within region<br/>");
						optionHash.put("both", "Both physical location and transcription control (eQTL) within region<br/>");
                        %>
                        <%@ include file="/web/common/radio.jsp" %>
                </div>
              </div> <!-- end div#advancedSettings -->
		<div class="brClear"></div>
            </div> <!-- end div#advancedSettingsRegions -->

          </div> <!-- end div#regionsOfInterest -->
	<input type="hidden" name="fromQTL" value="<%=fromQTL%>">
        </form>
      </div> <!-- end div#eQTLRegionConfiguration -->

        <script type="text/javascript">
            $(document).ready(function(){
                setupPage();
            }); // document ready
        </script>

	<div class="brClear"></div>
      <div style="height: 0px; clear: both; float: none; border: solid 0 blue;"></div>
    </div> <!-- end div#displayLocEQTL -->
  </div>  <!-- end div.dataContainer -->

  <div class="region_list" style="display:none">
    <div class="list_BoxTitle">
      List Contents (view only)
    </div>
    <div class="region_content"></div>
  </div>

  <div class="fullScreenGraphic"></div>

  <div class="createNewRegion"></div>

  <div class="verticalGraphic">
    <div class="graphicControls modal">
      <div class="graphicPrint" data-specifiedPrintArea="span.verticalImgPrintArea"></div>
      <div class="graphicDownload"></div>
    </div>
    <span class="verticalImgPrintArea"><img class="verticalImage" name="verticalImage" src="" /></span>
  </div>

  <div class="viewTableForm"></div>
  <div class="saveDisplayedGenes"></div>
  


<!--  <div class="load">Loading...</div> -->

<%@ include file="/web/common/footer_adaptive.jsp" %>

