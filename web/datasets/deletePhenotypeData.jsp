<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2008
 *  Description:  The web page created by this file displays the data related to the phenotype being deleted 
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>

<jsp:useBean id="myGeneList" class="edu.ucdenver.ccp.PhenoGen.data.GeneList"> </jsp:useBean>

<%
	log.debug("in deletePhenotypeData.jsp. user = " + user + ", action = "+action);

	log.debug("pPGID = "+itemID);

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-004");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        } 
	GeneList[] myGeneLists = myGeneList.getGeneListsForPhenotype(itemID, dbConn);

	if (action != null && (action.equals("Delete Phenotype"))) {
		myParameterValue.deletePhenotypeValues(itemID, dbConn);
		mySessionHandler.createDatasetActivity("Deleted phenotype records for parameterGroup '" + itemID, dbConn);
		//Success - "Phenotype values deleted"
		session.setAttribute("successMsg", "PHN-003");
		response.sendRedirect(commonDir + "successMsg.jsp");
	}

%>
	<% if (myGeneLists.length > 0) { %>
		<div class="title"> The following gene lists were saved during a correlation analysis using this phenotype data:<BR>
				<i><font size="-1">Note: These gene lists will NOT be deleted, but the phenotype values will be</font></i> </div>
      		<table class="list_base tablesorter" id="versions" cellpadding="0" cellspacing="3">
			<thead>
			<tr class="col_title">
			<th> Gene List Name
			<th> Date Created 
			<th> Owner
			</tr>
			</thead>
			<tbody>
				<% for (int i=0; i<myGeneLists.length; i++) { %>
				<tr>
					<td> <%=myGeneLists[i].getGene_list_name()%> </td>
					<td> <%=myGeneLists[i].getCreate_date()%> </td>
					<td> <%=myGeneLists[i].getGene_list_owner()%> </td>
				</tr>
				<% } %>
				</tbody>
			</table>
	<% } else { %>
      		<table class="list_base" cellpadding="0" cellspacing="3">
                	<tr class="title">
        			<th colspan="100%">No gene lists have been saved using this phenotype data.</th>
			</tr>
		</table> 
	<% } %>

		<form	method="post" 
			action="<%=datasetsDir%>deletePhenotypeData.jsp" 
			enctype="application/x-www-form-urlencoded"
			name="deletePhenotypeData">

			<BR> <BR>
			<center> <input type="submit" name="action" value="Delete Phenotype" onClick="return confirmDelete()"></center>
			<input type="hidden" name="itemID" value="<%=itemID%>">
		</form>
