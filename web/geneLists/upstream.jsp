<%--
 *  Author: Cheryl Hornbaker
 *  Created: Jan, 2006
 *  Description:  The web page created by this file prompts the user 
 *	for parameters to pass for extracting promoter sequences.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %> 

<%
	log.info("in upstream.jsp. user = " + user);

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-004");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }
        
	log.debug("action = "+ action);

	
        if ((action != null) && action.equals("Run Upstream Sequence Extraction")) {

		String upstreamLengthPassedIn = (String) request.getParameter("upstreamLength");

        	//
        	// upstreamLengthPassedIn will be 0.5, 1, or 2, so multiply it by 1000 to get kb
        	//
        	Float upstreamLength1 = new Float((Float.valueOf(upstreamLengthPassedIn).floatValue()) *
                                                	(new Float("1000").floatValue()));
        	int upstreamLength = (int) upstreamLength1.intValue();

	        String now = myObjectHandler.getNowAsMMddyyyy_HHmmss();
		java.sql.Timestamp timeNow = myObjectHandler.getNowAsTimestamp();

        	String geneListAnalysisDir = selectedGeneList.getGeneListAnalysisDir(userLoggedIn.getUserMainDir());
        	String upstreamDir = selectedGeneList.getUpstreamDir(geneListAnalysisDir);
	        String upstreamFileName = selectedGeneList.getUpstreamFileName(upstreamDir, upstreamLength, now);

		if (!myFileHandler.createDir(geneListAnalysisDir) || 
        		!myFileHandler.createDir(upstreamDir)) {
			log.debug("error creating geneListAnalysisDir or upstreamDir directory in upstream.jsp"); 
					
			mySessionHandler.createGeneListActivity(
				"got error creating geneListAnalysisDir or upstreamDir directory in upstream.jsp for " +
				selectedGeneList.getGene_list_name(),
				dbConn);
			session.setAttribute("errorMsg", "SYS-001");
                        response.sendRedirect(commonDir + "errorMsg.jsp");
		} else {
			log.debug("no problems creating geneListAnalysisDir or upstreamDir directory in upstream.jsp"); 

	        	int parameter_group_id = myParameterValue.createParameterGroup(dbConn);

			myGeneListAnalysis.setGene_list_id(selectedGeneList.getGene_list_id());
                	myGeneListAnalysis.setUser_id(userID);
                	myGeneListAnalysis.setCreate_date(timeNow);
                	myGeneListAnalysis.setAnalysis_type("Upstream");
                	myGeneListAnalysis.setDescription(selectedGeneList.getGene_list_name() + 
							"_" + upstreamLength + 
							" bp Upstream Sequence Extraction");
                	myGeneListAnalysis.setAnalysisGeneList(myGeneList.getGeneList(selectedGeneList.getGene_list_id(), dbConn));
			myGeneListAnalysis.setParameter_group_id(parameter_group_id);
		
			ParameterValue[] myParameterValues = new ParameterValue[1];
			myParameterValues[0] = new ParameterValue();
			myParameterValues[0].setCreate_date();
			myParameterValues[0].setParameter_group_id(parameter_group_id);
			myParameterValues[0].setCategory("Upstream Extraction");
                	myParameterValues[0].setParameter("Sequence Length");
                	myParameterValues[0].setValue(Integer.toString(upstreamLength));
			myGeneListAnalysis.setParameterValues(myParameterValues);

			mySessionHandler.createGeneListActivity("Ran Upstream Sequence Extraction on Gene List", dbConn);
	
			Thread thread = new Thread(new AsyncPromoterExtraction(
						session,
						upstreamFileName,
						false,
                                		myGeneListAnalysis));

			log.debug("Starting first thread "+ thread.getName());

                	thread.start();

			//Success - "Extraction started"
			session.setAttribute("successMsg", "GLT-010");
			response.sendRedirect(commonDir + "successMsg.jsp");

		}
	}
%>
<% if (selectedGeneList.getOrganism().equals("Mm") ||
	selectedGeneList.getOrganism().equals("Rn") ||
	selectedGeneList.getOrganism().equals("Hs")) {
%>
	<form	name="promoter" 
		method="post" 
		action="upstream.jsp" 
		enctype="application/x-www-form-urlencoded"> 

	<div class="title">Upstream Sequence Extraction Parameters</div>
      	<table name="items" class="list_base" cellpadding="0" cellspacing="3" >
	<tr>
		<td>
			<strong>Upstream sequence length:</strong>
		</td><td>
			<%
			selectName = "upstreamLength";
			selectedOption = "2";
			onChange = "";
			style = "";
			optionHash = new LinkedHashMap();
                        optionHash.put("0.5", "500 bp upstream region");
                        optionHash.put("1", "1 Kb upstream region");
                        optionHash.put("2", "2 Kb upstream region");
                        optionHash.put("3", "3 Kb upstream region");
                        optionHash.put("4", "4 Kb upstream region");
                        optionHash.put("5", "5 Kb upstream region");
                        optionHash.put("6", "6 Kb upstream region");
                        optionHash.put("7", "7 Kb upstream region");
                        optionHash.put("8", "8 Kb upstream region");
                        optionHash.put("9", "9 Kb upstream region");
                        optionHash.put("10", "10 Kb upstream region");
			%>
			<%@ include file="/web/common/selectBox.jsp" %>
		</td>
	</tr>
	</table>
	
	<BR>

	<center>
	<input type="submit" name="action" value="Run Upstream Sequence Extraction"> 
	<input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>"> 
	</center>

	</form>

<% } else { %>
        <BR>
        <center>
        <p> You can only run an upstream extraction on gene lists containing Human, Mouse, or Rat genes.</p>
        </center>
        <div class="closeWindow">Close</div>
<% } %>


