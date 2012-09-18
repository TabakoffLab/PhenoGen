<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  The web page created by this file allows the user to  
 *  		confirm his/her desire to delete a gene list.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %>

<%
	int itemID = (request.getParameter("itemID") == null ? -99 : Integer.parseInt((String) request.getParameter("itemID")));
	selectedGeneList = new GeneList().getGeneList(itemID, dbConn);
	selectedGeneList.setUserIsOwner(selectedGeneList.getCreated_by_user_id() == userID ? "Y" : "N"); 

	extrasList.add("listGeneList.js");

	log.info("in deleteGeneList.jsp. user = " + user + ", geneListID = "+selectedGeneList.getGene_list_id()+ 
			", geneListName = "+selectedGeneList.getGene_list_name());

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-005");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }

	log.debug("action = "+action);
	boolean userCanDelete = (selectedGeneList.getUserIsOwner().equals("N") ? false : true); 

	String message = (userCanDelete ? "" : "You may only delete gene lists that you own."); 

	if ( userCanDelete && (action != null) && action.equals("Delete Gene List")) {
        	try {
			//
			// delete genelist and all the files in the directory
			//
			mySessionHandler.createSessionActivity(session.getId(), 
				"Deleted Gene List # " + selectedGeneList.getGene_list_id() + 
					" called '" + selectedGeneList.getGene_list_name() + "'",
                		dbConn);

			log.debug("now deleting selectedGeneListID = "+selectedGeneList.getGene_list_id());

			selectedGeneList.deleteGeneList(dbConn);
			log.debug("just  deleted genelist ");

			//Success - "Gene List deleted"
			session.setAttribute("successMsg", "GL-014");
			session.setAttribute("selectedGeneList", null);
			//response.sendRedirect(commonDir + "successMsg.jsp");
			response.sendRedirect(geneListsDir + "listGeneLists.jsp");
        	} catch( Exception e ) {
            		throw e;
        	}
	}
	formName = "deleteGeneList.jsp";

%>

	<% if (selectedGeneList.getUserIsOwner().equals("N")) { %> 
		<BR>
		<center><%=message%></center> 
        <div class="closeWindow">Close</div>
	<% } else { %>

        	<center><h2> Data Linked to Gene List&nbsp;'<%=selectedGeneList.getGene_list_name()%>': </h2></center>
		<BR>
			<%
			User[] myGeneListUsers = selectedGeneList.getGeneListUsers(selectedGeneList.getGene_list_id(), dbConn);
			int userCount = 0;
			for (int i=0; i<myGeneListUsers.length; i++) {
				if (myGeneListUsers[i].getChecked() == 1 && 
					myGeneListUsers[i].getUser_id() != selectedGeneList.getCreated_by_user_id()) {
					userCount++;
				}
			}
			GeneListAnalysis[] myGeneListAnalyses =
                				myGeneListAnalysis.getAllGeneListAnalysisResults(
                                        		selectedGeneList.getGene_list_id(),
                                                	dbConn);
			%>
				<% if (userCount > 0) { %> 
					<center><h3><%=userCount%> other users have access to this gene list:</h3></center>
					<table class="list_base">
						<tr class="col_title">
							<th class="noSort"> Name</th>
							<th class="noSort"> Institution</th>
						</tr>
					<% for (int i=0; i<myGeneListUsers.length; i++) {
						if (myGeneListUsers[i].getChecked() == 1 && 
							myGeneListUsers[i].getUser_id() != selectedGeneList.getCreated_by_user_id()) { %>
							<tr>
								<td> <%=myGeneListUsers[i].getFull_name()%></td>
								<td> <%=myGeneListUsers[i].getInstitution()%></td>
							</tr>
						<% }
					} 
					%></table><%
				} else {
                                	%><center><h3>No other users have access to this gene list.</h3></center><%
				} 
				%><BR><BR><%
                        	if (myGeneListAnalyses != null && myGeneListAnalyses.length > 0) { %> 
		                	<center><h3><%=myGeneListAnalyses.length%>&nbsp;analyses have been saved for this gene list:</h3></center>
					<table class="list_base">
                                		<tr class="col_title">
                                        		<th class="noSort">Analysis Type
                                        		<th class="noSort">Description
                                        		<th class="noSort">Create date
                                        	</tr>
                                        <% for (int k=0; k<myGeneListAnalyses.length; k++) {
						%><tr>
                                                        <td><%=myGeneListAnalyses[k].getAnalysis_type()%></td>
                                                        <td><%=myGeneListAnalyses[k].getDescription()%></td>
                                                        <td><%=myGeneListAnalyses[k].getCreate_date_as_string()%></td>
                                               </tr><%
					}
					%> </table><%
				} else {
                                	%><center><h3>No analyses have been saved for this gene list.</h3></center><%
				}
				%>

		<form	method="post" 
			action="deleteGeneList.jsp" 
			enctype="application/x-www-form-urlencoded"
			name="deleteGeneList">

			<BR> <BR>
			<center> <input type="submit" name="action" value="Delete Gene List" onClick="return confirmDelete()"></center>
			<input type="hidden" name="itemID" value="<%=selectedGeneList.getGene_list_id()%>">
		</form>
<% 	
	} 
%>
