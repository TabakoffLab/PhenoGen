<%--
 *  Author: Cheryl Hornbaker
 *  Created: Nov, 2006
 *  Description:  The web page created by this file prompts the user 
 *	for parameters to pass for running MEME.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %> 

<%
	log.info("in meme.jsp. user = " + user);

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-004");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }

	log.debug("meme action = "+ action);
	formName = "meme.jsp";

	java.util.Date displayTime = Calendar.getInstance().getTime();
	SimpleDateFormat displayFormat = new SimpleDateFormat("MMM dd, yyyy");
	String displayNow = displayFormat.format(displayTime);

        if ((action != null) && action.equals("Run MEME")) {

		String upstreamLengthPassedIn = (String) request.getParameter("upstreamLength");
		String minWidth = (String) request.getParameter("minWidth");
		String maxWidth = (String) request.getParameter("maxWidth");
		String distribution = (String) request.getParameter("distribution");
		String maxMotifs = (String) request.getParameter("maxMotifs");
                String description = (String) request.getParameter("description");

        	//
        	// upstreamLengthPassedIn will be 0.5, 1, or 2, so multiply it by 1000 to get kb
        	//
        	Float upstreamLength1 = new Float((Float.valueOf(upstreamLengthPassedIn).floatValue()) *
                                                	(new Float("1000").floatValue()));
        	int upstreamLength = (int) upstreamLength1.intValue();

        	log.debug("numberOfGenes = "+ selectedGeneList.getNumber_of_genes());
        	int totalLength = upstreamLength * selectedGeneList.getNumber_of_genes(); 
        	log.debug("totalLength = "+ totalLength);
        	if (totalLength > 60000) {
			NumberFormat nf = NumberFormat.getInstance();
                        //Error - "Over 60,000 characters"
                        session.setAttribute("errorMsg", "PRM-004");
                        session.setAttribute("additionalInfo", "Your request contains "+selectedGeneList.getNumber_of_genes() + 
					" genes times "+upstreamLength + " characters for each gene, which equals "+
        				nf.format(totalLength) + " total characters.");
                        response.sendRedirect(commonDir + "errorMsg.jsp");
		} else {
	
	        	String now = myObjectHandler.getNowAsMMddyyyy_HHmmss();
			java.sql.Timestamp timeNow = myObjectHandler.getNowAsTimestamp();

        		String geneListAnalysisDir = selectedGeneList.getGeneListAnalysisDir(userLoggedIn.getUserMainDir());
        		String memeDir = selectedGeneList.getMemeDir(geneListAnalysisDir,now);
        		//String sequenceFileName = selectedGeneList.getUpstreamFileName(memeDir, upstreamLength, now);
				String sequenceFileName = memeDir+"upstream_"+ upstreamLength + "bp.fasta.txt";

			if (!myFileHandler.createDir(geneListAnalysisDir) || 
        			!myFileHandler.createDir(memeDir)) {
				log.debug("error creating geneListAnalysisDir or memeDir directory in meme.jsp"); 
					
				mySessionHandler.createGeneListActivity(
					"got error creating geneListAnalysisDir or memeDir directory in meme.jsp for " +
					selectedGeneList.getGene_list_name(),
					dbConn);
				session.setAttribute("errorMsg", "SYS-001");
                        	response.sendRedirect(commonDir + "errorMsg.jsp");
			} else {
				log.debug("no problems creating geneListAnalysisDir or memeDir directory in meme.jsp"); 


	        		int parameter_group_id = myParameterValue.createParameterGroup(dbConn);

				myGeneListAnalysis.setGene_list_id(selectedGeneList.getGene_list_id());
                		myGeneListAnalysis.setUser_id(userID);
                		myGeneListAnalysis.setCreate_date(timeNow);
                		myGeneListAnalysis.setAnalysis_type("MEME");
                		myGeneListAnalysis.setDescription(description);
                		myGeneListAnalysis.setAnalysisGeneList(myGeneList.getGeneList(selectedGeneList.getGene_list_id(), dbConn));
				myGeneListAnalysis.setParameter_group_id(parameter_group_id);
		
				log.debug("now = "+now);
	        		//String memeFileName = selectedGeneList.getMemeFileName(memeDir, now);
				String memeFileName = memeDir;

				ParameterValue[] myParameterValues = new ParameterValue[6];
				for (int i=0; i<myParameterValues.length; i++) {
					myParameterValues[i] = new ParameterValue();
					myParameterValues[i].setCreate_date();
					myParameterValues[i].setParameter_group_id(parameter_group_id);
					myParameterValues[i].setCategory("MEME");
				}
                		myParameterValues[0].setParameter("Sequence Length");
                		myParameterValues[0].setValue(Integer.toString(upstreamLength));
                		myParameterValues[1].setParameter("Distribution of Motifs");
                		myParameterValues[1].setValue(distribution);
                		myParameterValues[2].setParameter("Maximum Number of Motifs");
                		myParameterValues[2].setValue(maxMotifs);
                		myParameterValues[3].setParameter("Minimum Motif Width");
                		myParameterValues[3].setValue(minWidth);
                		myParameterValues[4].setParameter("Maximum Motif Width");
                		myParameterValues[4].setValue(maxWidth);
						myParameterValues[5].setParameter("MEME Dir");
                		myParameterValues[5].setValue(memeDir);

				myGeneListAnalysis.setParameterValues(myParameterValues);

				mySessionHandler.createGeneListActivity("Ran MEME on Gene List", dbConn);
	
				Thread thread = new Thread(new AsyncPromoterExtraction(
						session,
						sequenceFileName,
						true,
                        myGeneListAnalysis));

				log.debug("Starting first thread to run PromoterExtraction: "+ thread.getName());

                		thread.start();

				Thread thread2 = new Thread(new AsyncMeme(
						session,
						memeFileName,
						sequenceFileName,
						distribution,
						maxMotifs,
						minWidth,
						maxWidth,
                        myGeneListAnalysis,
						thread));

				log.debug("Starting second thread to run Meme "+ thread2.getName());

                		thread2.start();

				//Success - "MEME started"
				session.setAttribute("successMsg", "GLT-012");
				response.sendRedirect(commonDir + "successMsg.jsp");
			}

		}
	}
%>
<% if (selectedGeneList.getOrganism().equals("Mm") ||
	selectedGeneList.getOrganism().equals("Rn") ||
	selectedGeneList.getOrganism().equals("Hs")) {
%>
	<%@ include file="/web/common/headTags.jsp" %>

	<form	name="promoter" id="promoter"
		method="post" 
		action="meme.jsp" 
		enctype="application/x-www-form-urlencoded" onSubmit="return IsMeMeFormComplete(this)"> 
	<BR>
	<div class="title">MEME Parameters</div>
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

		<tr>	
			<td>
				<strong>Motif distribution:</strong>
			</td><td class=bottom>
				<%
				selectName = "distribution";
				selectedOption = "";
				onChange = "";
				style = "";
				optionHash = new LinkedHashMap();
                        	optionHash.put("oops", "One per sequence");
                        	optionHash.put("zoops", "Zero or one per sequence");
                        	optionHash.put("tcm", "Any number of repetitions");
				%>
				<%@ include file="/web/common/selectBox.jsp" %>
			</td>
		</tr>
		<tr>	
			<td>
				<strong>Optimum width of each motif: </strong>
			</td><td class=bottom>
					Min Width (>=2) <input type="text" size=3 name="minWidth" value=6>
					Max Width (<= 300) <input type="text" size=3 name="maxWidth" value=20>
			</td>
		</tr>
		<tr>	
			<td>
				<strong>Maximum number of motifs to find: </strong>
			</td><td>
					<input type="text" size=3 name="maxMotifs" value=3>
			</td>
		</tr>
		<tr>
			    <td>
                                <strong>Description:</strong>
                        </td><td>
                                 <input type="text" size=50 name="description" id="description" "value="<%=selectedGeneList.getGene_list_name()%> MEME Analysis on <%=displayNow%>">

                        </td>

		</tr>

	</table>
		
	<BR>

	<center>
	<input type="reset" value="Reset"> <%=tenSpaces%>
	<input type="submit" id="runMemeBtn" name="action" value="Run MEME"> 
	<input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>">
	<input type="hidden" name="numberOfGenes" value="<%=selectedGeneList.getNumber_of_genes()%>">
	
	</center>

	</form>

<% } else { %>
        <BR>
        <center>
        <p> You can only run MEME on gene lists containing Human, Mouse, or Rat genes.</p>
        </center>
        <div class="closeWindow">Close</div>
<% } %>

