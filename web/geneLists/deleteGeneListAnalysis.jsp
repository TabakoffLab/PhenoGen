<%--
 *  Author: Cheryl Hornbaker
 *  Created: Apr, 2008
 *  Description:  This file handles deleting a gene list analysis result
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %>

<%
	int itemID = (request.getParameter("itemID") == null ? -99 : Integer.parseInt((String) request.getParameter("itemID")));

	log.info("in deleteGeneListAnalysis.jsp. user = " + user + ", itemID = "+itemID);

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-005");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }
	GeneListAnalysis thisGLA = new GeneListAnalysis().getGeneListAnalysis(itemID, pool);
	String analysisType = thisGLA.getAnalysis_type();
	log.debug("analysisType = "+analysisType);

	String buttonText = "";
	if (analysisType.equals("LitSearch")) { 
		buttonText = "Delete Literature Search";
	} else if (analysisType.equals("oPOSSUM")) { 
		buttonText = "Delete oPOSSUM Analysis";
	} else if (analysisType.equals("MEME")) { 
		buttonText = "Delete MEME Analysis";
	} else if (analysisType.equals("Pathway")) { 
		buttonText = "Delete Pathway Analysis";
	} else if (analysisType.equals("Upstream")) { 
		buttonText = "Delete Upstream Sequence Extraction";
	}
	log.debug("itemID = "+itemID);

        if (action != null && action.equals("Delete Literature Search")) {
        	try {
                        new LitSearch().deleteLitSearch(itemID, dbConn);

			mySessionHandler.createGeneListActivity("Deleted Lit Search : " + itemID, pool);
			session.setAttribute("successMsg", "GLT-008");
			response.sendRedirect(geneListsDir + "litSearch.jsp?geneListID="+selectedGeneList.getGene_list_id());
        	} catch( Exception e ) {
            		throw e;
        	}
	} else if (action != null && action.equals("Delete Upstream Sequence Extraction")) {
        	try {
			myGeneListAnalysis.deleteGeneListAnalysisFiles(userLoggedIn.getUserMainDir(), itemID, pool);
			myGeneListAnalysis.deleteGeneListAnalysisResult(itemID, pool);

			mySessionHandler.createGeneListActivity("Deleted Upstream Sequence Extraction: " + itemID, pool);

			session.setAttribute("successMsg", "GLT-006");
			response.sendRedirect(geneListsDir + "promoter.jsp");
        	} catch( Exception e ) {
            		throw e;
        	}
	} else if (action != null && action.equals("Delete Pathway Analysis")) {
        	try {
			myGeneListAnalysis.deleteGeneListAnalysisFiles(userLoggedIn.getUserMainDir(), itemID, pool);
			myGeneListAnalysis.deleteGeneListAnalysisResult(itemID, pool);

			mySessionHandler.createGeneListActivity("Deleted Pathway Analysis: " + itemID, pool);

			session.setAttribute("successMsg", "GLT-017");
			response.sendRedirect(geneListsDir + "pathwayTab.jsp");
        	} catch( Exception e ) {
            		throw e;
        	}
	} else if (action != null && action.equals("Delete MEME Analysis")) {
        	try {
			myGeneListAnalysis.deleteGeneListAnalysisFiles(userLoggedIn.getUserMainDir(), itemID,pool);
			myGeneListAnalysis.deleteGeneListAnalysisResult(itemID, pool);

			mySessionHandler.createGeneListActivity("Deleted MEME Analysis: " + itemID, pool);

			session.setAttribute("successMsg", "GLT-007");
			response.sendRedirect(geneListsDir + "promoter.jsp");
        	} catch( Exception e ) {
            		throw e;
        	}
	} else if (action != null && action.equals("Delete oPOSSUM Analysis")) {
        	try {
			myGeneListAnalysis.deleteGeneListAnalysisFiles(userLoggedIn.getUserMainDir(), itemID, pool);
			new Promoter().deletePromoterResult(itemID, dbConn);

			mySessionHandler.createGeneListActivity("Deleted oPOSSUM Analysis: " + itemID, pool);

			session.setAttribute("successMsg", "GLT-011");
			response.sendRedirect(geneListsDir + "promoter.jsp");
        	} catch( Exception e ) {
            		throw e;
        	}
	}
%>

	<form	method="post" 
		action="deleteGeneListAnalysis.jsp" 
		enctype="application/x-www-form-urlencoded"
		name="deleteGeneListAnalysis">

		<BR> <BR>
		<center> <input type="submit" name="action" value="<%=buttonText%>" onClick="return confirmDelete()"></center>
		<input type="hidden" name="itemID" value="<%=itemID%>">
		<input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>">
	</form>
