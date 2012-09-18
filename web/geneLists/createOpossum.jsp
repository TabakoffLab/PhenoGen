<%--
 *  Author: Cheryl Hornbaker
 *  Created: Apr, 2005
 *  Description:  The web page created by this file prompts the user 
 *	for parameters to pass to the promoter module.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %> 

<jsp:useBean id="thisIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"> </jsp:useBean>
<jsp:useBean id="myPromoter" class="edu.ucdenver.ccp.PhenoGen.data.Promoter"> </jsp:useBean>

<%
	log.info("in createOpossum.jsp. user = " + user);

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-004");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }

        String displayNow = myObjectHandler.getNowAsMMMddyyyy();

	log.debug("createOpossum action = "+ action);
	formName="createOpossum.jsp";
	request.setAttribute( "selectedTabId", "promoter" );

        if ((action != null) && action.equals("Run oPOSSUM")) {

		String conservationLevel = (String) request.getParameter("conservationLevel");
		String thresholdLevel = (String) request.getParameter("thresholdLevel");
		String searchRegionLevel = (String) request.getParameter("searchRegionLevel");
		String description = (String) request.getParameter("description");

		mySessionHandler.createGeneListActivity("Ran oPOSSUM Process ", dbConn);
	
		HashMap ids = new HashMap();

        	//String targets[] = {"RefSeq RNA ID"};
			String targets[] = {"Entrez Gene ID"};
			//String targets[] = {"Ensembl ID"};
			thisIDecoderClient.setNum_iterations(1);
        	//Set refseqSet = thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersForTarget(iDecoderSet, targets));
			Set refseqSet = thisIDecoderClient.getIdentifiersByInputIDAndTarget(selectedGeneList.getGene_list_id(), targets,dbConn);
			//Set refseqSet = thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersByInputIDAndTarget(selectedGeneList.getGene_list_id(), targets,dbConn));
        	//thisIDecoderClient.setNum_iterations(1);
        	String genesToFile = "";
		if (refseqSet == null) {
			//Error - "No RefSeqIDs from Promoter"
			session.setAttribute("errorMsg", "GL-008");
                	response.sendRedirect(commonDir + "errorMsg.jsp");
        	} else { 
			log.debug("refseqSet from iDecoder = "); myDebugger.print(refseqSet);
			//log.debug("iDecoderResult from iDecoder = "); myDebugger.print(iDecoderResult);

			//
                	// Convert refseqSet identifer list to a string separated
                	// by carriage return and line feeds
                	//
					//OLD VERSION
       			//genesToFile = myObjectHandler.getAsSeparatedString(refseqSet, "\n");
				
				//NEW VERSION
				
				Iterator it = refseqSet.iterator();
                while (it.hasNext()) {
							Identifier tmp=(Identifier)it.next();
							Set relID=tmp.getRelatedIdentifiers();
							Iterator it2=relID.iterator();
							while(it2.hasNext()){
								String id=((Identifier)it2.next()).getIdentifier();
								
									if(genesToFile.equals("")){
										genesToFile=id;
									}else{
										genesToFile=genesToFile+"\n"+id;
									}
								
							}
				}

	        	String now = myObjectHandler.getNowAsMMddyyyy_HHmmss();
				java.sql.Timestamp timeNow = myObjectHandler.getNowAsTimestamp();
	
			log.debug("now = " + now + ", timeNow = "+ timeNow);

                               String geneListAnalysisDir = selectedGeneList.getGeneListAnalysisDir(userLoggedIn.getUserMainDir());
                               String promoterDir = selectedGeneList.getOPOSSUMDir(geneListAnalysisDir);

			if (!myFileHandler.createDir(geneListAnalysisDir) || 
				!myFileHandler.createDir(promoterDir)) {
				log.debug("error creating promoterDir directory in promoter.jsp"); 
					
				mySessionHandler.createGeneListActivity("got error creating promoterDir directory in promoter.jsp for " +
					selectedGeneList.getGene_list_name(),
					dbConn);
				session.setAttribute("errorMsg", "SYS-001");
                        	response.sendRedirect(commonDir + "errorMsg.jsp");
			} else {
				log.debug("no problems creating promoterDir directory in promoter.jsp"); 

				String filePrefix = promoterDir + now + "_";

				myFileHandler.writeFile(genesToFile, filePrefix + "promoterGenes.txt");

				log.debug("conservationLevel = "+conservationLevel);
				log.debug("thresholdLevel = "+thresholdLevel);
				log.debug("searchRegionLevel = "+searchRegionLevel);

				myPromoter.setGene_list_id(selectedGeneList.getGene_list_id());
				myPromoter.setUser_id(userID);
				myPromoter.setCreate_date(timeNow);

                		Iterator itr = iDecoderSet.iterator();
                		while (itr.hasNext()) {
                			Identifier thisIdentifier = (Identifier) itr.next();
					Set identifierValuesSet = thisIDecoderClient.getValues((Set) thisIdentifier.getRelatedIdentifiers());
					String[] identifierValues = (String[]) identifierValuesSet.toArray(new String[identifierValuesSet.size()]); 
					ids.put(thisIdentifier.getIdentifier(), identifierValues);
				}

//	        		log.debug("ids = "); myDebugger.print(ids);

				myPromoter.setIds(ids);

				String searchRegionLevelText = "";
				String conservationLevelText = "";
				String thresholdLevelText = "";

				if (searchRegionLevel.equals("1")) {
					searchRegionLevelText = "-10000 bp to +10000 bp";		
				} else if (searchRegionLevel.equals("2")) {
					searchRegionLevelText = "-10000 bp to +5000 bp";
				} else if (searchRegionLevel.equals("3")) {
					searchRegionLevelText = "-5000 bp to +5000 bp";		
				} else if (searchRegionLevel.equals("4")) {
					searchRegionLevelText = "-5000 bp to +2000 bp";
				} else if (searchRegionLevel.equals("5")) {
					searchRegionLevelText = "-2000 bp to +2000 bp";
				} else {
					searchRegionLevelText = "-2000 bp to +0 bp";
				}	

				if (conservationLevel.equals("1")) {
					conservationLevelText = "Top 30% of conserved regions (min. conservation 60%)";
				} else if (conservationLevel.equals("2")) {
					conservationLevelText = "Top 20% of conserved regions (min. conservation 65%)";
				} else {
					conservationLevelText = "Top 10% of conserved regions (min. conservation 70%)";	
				}

				if (thresholdLevel.equals("1")) {
					thresholdLevelText = "75% of maximum possible PWM score for the TFBS";
				} else if (thresholdLevel.equals("2")) {
					thresholdLevelText = "80% of maximum possible PWM score for the TFBS";
				} else {
					thresholdLevelText = "85% of maximum possible PWM score for the TFBS";
				}

				myPromoter.setSearchRegionLevel(searchRegionLevelText);
				myPromoter.setConservationLevel(conservationLevelText);
				myPromoter.setThresholdLevel(thresholdLevelText);
				myPromoter.setDescription(description);
	
				log.debug("just set create date from promoter.jsp to "+timeNow);

				log.debug("userEmail = " +userLoggedIn.getEmail());
				Thread thread = new Thread(new AsyncPromoter(
					session,
					conservationLevel,
					thresholdLevel,
					searchRegionLevel,
					myPromoter,
					filePrefix,
					"Entrez Gene"));

				log.debug("Starting first thread "+ thread.getName());

				thread.start();

				//Success - "oPOSSUM started"
				session.setAttribute("successMsg", "GLT-009");
				response.sendRedirect(commonDir + "successMsg.jsp");

			}
		}
	}
%>


<%@ include file="/web/common/headTags.jsp" %>
<script type="text/javascript">
    var crumbs = ["Home", "Research Genes", "Promoter"];
</script>

<% if (selectedGeneList.getOrganism().equals("Hs") || selectedGeneList.getOrganism().equals("Mm")) { %>

	<form	name="promoter" 
		method="post" 
		action="createOpossum.jsp" 
		enctype="application/x-www-form-urlencoded"   onSubmit="return IsOpossumFormComplete(this)"> 
	<BR>
	<div class="title">oPOSSUM Parameters</div>
      	<table name="items" class="list_base" cellpadding="0" cellspacing="3" >
		<tr>
			<td>
				<strong>Search Region Level:</strong> 
                        	<span class="info" title="Size of the region around the transcription start site which is analyzed for transcription factor binding sites.">
                        	<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        	</span>
			</td><td>
				<%
				selectName = "searchRegionLevel";
				selectedOption = "6";
				onChange = "";
				style = "";
				optionHash = new LinkedHashMap();
                        	optionHash.put("1", "-10000 bp to +10000 bp");
                        	optionHash.put("2", "-10000 bp to +5000 bp");
                        	optionHash.put("3", "-5000 bp to +5000 bp");
                        	optionHash.put("4", "-5000 bp to +2000 bp");
                        	optionHash.put("5", "-2000 bp to +2000 bp");
                        	optionHash.put("6", "-2000 bp to +0 bp");
				%>
				<%@ include file="/web/common/selectBox.jsp" %>
			</td>
		</tr> 
		<tr>	
			<td>
				<strong>Conservation Level:</strong>
                        	<span class="info" title="Conservation with the aligned orthologous mouse sequences is used as a filter such that only sites which fall within these non-coding conserved regions are kept; the most stringent level of conservation is the default.">
                        	<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        	</span>
			</td><td>
				<%
				selectName = "conservationLevel";
				selectedOption = "3";
				onChange = "";
				style = "";
				optionHash = new LinkedHashMap();
                        	optionHash.put("3", "Top 10% of conserved regions (min. conservation 70%)");
                        	optionHash.put("2", "Top 20% of conserved regions (min. conservation 65%)");
                        	optionHash.put("1", "Top 30% of conserved regions (min. conservation 60%)");
				%>
				<%@ include file="/web/common/selectBox.jsp" %>
			</td></tr> 
		<tr>
			<td>
				<strong>Matrix match threshold:</strong>
                        	<span class="info" title="The minimum relative score used to report the position as a putative binding site.">
                        	<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        	</span>
			</td><td>
				<%
				selectName = "thresholdLevel";
				selectedOption = "2";
				onChange = "";
				style = "";
				optionHash = new LinkedHashMap();
                        	optionHash.put("1", "75% of maximum possible PWM score for the TFBS");
                        	optionHash.put("2", "80% of maximum possible PWM score for the TFBS");
                        	optionHash.put("3", "85% of maximum possible PWM score for the TFBS");
				%>
				<%@ include file="/web/common/selectBox.jsp" %>
			</td>
		</tr><tr>
			<td>
				<strong>Description:</strong>
                        	<span class="info" title="A descriptive name for this analysis.">
                        	<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        	</span>
			</td><td>
				 <input type="text" size=50 name="description" value="<%=selectedGeneList.getGene_list_name()%> oPOSSUM Analysis on <%=displayNow%>">

			</td>
		</tr> 

		</table>

	<BR>
	<center>
	<input type="reset" value="Reset"> <%=tenSpaces%>
	<input type="submit" name="action" value="Run oPOSSUM"> 

	</center>
        <input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>">

	</form>

<% } else { %>
	<BR>
	<center>
	<p>You can only run the oPOSSUM promoter analysis on gene lists containing Human or Mouse genes. </p>
	</center>
	<div class="closeWindow">Close</div>
<% } %>


