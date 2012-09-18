<%--
 *  Author: Cheryl Hornbaker
 *  Created: Mar, 2010
 *  Description:  The web page created by this file allows the user to  
 *  		confirm his/her desire to delete an experiment.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/experiments/include/experimentHeader.jsp"  %>
<%
	log.info("in deleteExperiment.jsp. user = " + user + ", itemID= "+itemID);

	int experimentID = itemID;

	%><%@ include file="/web/experiments/include/setupExperiment.jsp" %><%

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-005");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }
	log.debug("subid = "+selectedExperiment.getSubid());
	String hybridIDs = myArray.getHybridIDsForSubmission(selectedExperiment.getSubid(), dbConn);
	log.debug("hybridIDs = "+hybridIDs);
        Dataset[] myDatasets = myDataset.getDatasetsUsingArrayIDs(hybridIDs, dbConn);
	log.debug("after setting myDtasets");
	if (myDatasets != null && myDatasets.length > 0) {
        	myDatasets = myDataset.sortDatasets(myDatasets, "datasetName", "A");
		log.debug("after sorting myDtasets");
	}

	if (action != null && action.equals("Delete")) {
        	try {
	 		log.debug("deleteing selectedExperiment = "+selectedExperiment.getExp_id());
        		mySessionHandler.createSessionActivity(session.getId(), 
					"Deleted Experiment # " + selectedExperiment.getExp_id() + 
						" called '" + selectedExperiment.getExpName() + "'",
                			dbConn);

			selectedExperiment.deleteExperiment(dbConn);
			session.setAttribute("experimentsForUser", null);
			session.setAttribute("selectedExperiment", null);

			//Success - "Experiment deleted"
			session.setAttribute("successMsg", "EXP-039");
			response.sendRedirect(experimentsDir + "listExperiments.jsp");
        	} catch( Exception e ) {
            		throw e;
        	}
	}
%>
<%@ include file="/web/common/includeExtras.jsp" %>
	<div class="scrollable">
	<form	method="post" 
		action="deleteExperiment.jsp" 
		enctype="application/x-www-form-urlencoded"
		name="deleteExperiment">

		<% if (myDatasets != null && myDatasets.length > 0) { %> 
			<div class="title"> Datasets Linked to Experiment&nbsp;<i>'<%=selectedExperiment.getExpName()%>'</i>: </div>
			<div class="title"> The arrays from this experiment are included in <%=myDatasets.length%> dataset(s): </div>
      			<table class="list_base tablesorter" id="datasets" cellpadding="0" cellspacing="3">
				<thead>
                                <tr class="col_title">
                                        <th>Dataset Name
                                        <th>Create date
                                        <th>Owner
				</tr>
				</thead>
				<tbody>
                               	<% for (int i=0; i<myDatasets.length; i++) {
					%><tr>
						<td><%=myDatasets[i].getName()%></td>
                                                <td><%=myDatasets[i].getCreate_date_as_string()%></td>
                                                <td><%=myDatasets[i].getCreated_by_full_name()%></td>
					</tr><%
				}
				%> 
				<tbody>
			</table> 
			<BR>
			<div class="title"> Experiments with datasets cannot be deleted.</div>
		<% } else { %>
			<BR><BR>
			<div class="title"> Click Delete to delete '<%=selectedExperiment.getExpName()%>'.</div>
			<BR><BR>
			<center> <input type="submit" name="action" value="Delete" onClick="return confirmDelete()"></center>
		<% } %>

		<input type="hidden" name="itemID" value="<%=itemID%>">
		<input type="hidden" name="experimentID" value="<%=selectedExperiment.getExp_id()%>">
	</form>
	</div>
	<script type="text/javascript">
               $(document).ready(function(){
                       $("table[id='datasets']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
               });
	</script>

