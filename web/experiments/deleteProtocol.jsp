<%--
 *  Author: Cheryl Hornbaker
 *  Created: Mar, 2010
 *  Description:  The web page created by this file allows the user to  
 *  		confirm his/her desire to delete a protocol.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/experiments/include/experimentHeader.jsp"  %>


<%
	log.info("in deleteProtocol.jsp. user = " + user + ", itemID= "+itemID);

	int protocolID = itemID;

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-005");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }
        Textract[] myTextracts = new Textract().getAllTextractForProtocol(protocolID, dbConn);
        Hybridization[] myHybridizations = new Hybridization().getAllHybridizationForProtocol(protocolID, dbConn);
        Tlabel[] myTlabels = new Tlabel().getAllTlabelForProtocol(protocolID, dbConn);
        Tsample[] myTsamples = new Tsample().getAllTsampleForProtocol(protocolID, dbConn);
	Protocol protocolToBeDeleted = new Protocol().getProtocol(protocolID, dbConn);

	if (action != null && action.equals("Delete")) {
        	try {
	 		log.debug("deleteing protocol = "+protocolID);

        		mySessionHandler.createExperimentActivity("Deleted protocol # " + protocolID, dbConn);

			new Protocol(protocolID).deleteProtocol(dbConn);

			//Success - "Protocol deleted"
			session.setAttribute("successMsg", "EXP-043");
			response.sendRedirect(experimentsDir + "chooseProtocols.jsp");
        	} catch( Exception e ) {
            		throw e;
        	}
	}
%>
<%@ include file="/web/common/includeExtras.jsp" %>
	<div class="scrollable">

	<form	method="post" 
		action="deleteProtocol.jsp" 
		enctype="application/x-www-form-urlencoded"
		name="deleteProtocol">

		<% if (myHybridizations != null && myHybridizations.length > 0) { %> 
			<div class="title"> Hybridizations Linked to Protocol&nbsp;<i>'<%= protocolToBeDeleted.getProtocol_name() %>'</i>: </div>
      			<table class="list_base tablesorter" id="hybrids" cellpadding="0" cellspacing="3">
				<thead>
                                <tr class="col_title">
                                        <th>Hybridization Name
                                        <th>Experiment Name
                                        <th>Create date
				</tr>
				</thead>
				<tbody>
                               	<% for (int i=0; i<myHybridizations.length; i++) {
					%><tr>
						<td><%=myHybridizations[i].getName()%></td>
                                                <td><%=myHybridizations[i].getExp_name()%></td>
                                                <td><%=myHybridizations[i].getCreate_date()%></td>
					</tr><%
				}
				%> 
				</tbody>
			</table> 
			<BR>
		<% } %>

		<% if (myTlabels != null && myTlabels.length > 0) { %> 
			<div class="title"> Labeled Extracts Linked to Protocol&nbsp;<i>'<%= protocolToBeDeleted.getProtocol_name() %>'</i>: </div>
      			<table class="list_base tablesorter" id="labels" cellpadding="0" cellspacing="3">
				<thead>
                                <tr class="col_title">
                                        <th>Labeled Extract Name
                                        <th>Experiment Name
                                        <th>Create date
				</tr>
				</thead>
				<tbody>
                               	<% for (int i=0; i<myTlabels.length; i++) {
					%><tr>
						<td><%=myTlabels[i].getTlabel_id()%></td>
                                                <td><%=myTlabels[i].getTlabel_exp_name()%></td>
                                                <td><%=myTlabels[i].getTlabel_last_change()%></td>
					</tr><%
				}
				%> 
				</tbody>
			</table> 
			<BR>
		<% } %>

		<% if (myTextracts != null && myTextracts.length > 0) { %> 
			<div class="title"> Extracts Linked to Protocol&nbsp;<i>'<%= protocolToBeDeleted.getProtocol_name() %>'</i>: </div>
      			<table class="list_base tablesorter" id="extracts" cellpadding="0" cellspacing="3">
				<thead>
                                <tr class="col_title">
                                        <th>Extract Name
                                        <th>Experiment Name
                                        <th>Create date
				</tr>
				</thead>
				<tbody>
                               	<% for (int i=0; i<myTextracts.length; i++) {
					%><tr>
						<td><%=myTextracts[i].getTextract_id()%></td>
                                                <td><%=myTextracts[i].getTextract_exp_name()%></td>
                                                <td><%=myTextracts[i].getTextract_last_change().toString()%></td>
					</tr><%
				}
				%> 
				</tbody>
			</table> 
			<BR>
		<% } %>

		<% if (myTsamples != null && myTsamples.length > 0) { %> 
			<div class="title"> Samples Linked to Protocol&nbsp;<i>'<%= protocolToBeDeleted.getProtocol_name() %>'</i>: </div>
      			<table class="list_base tablesorter" id="samples" cellpadding="0" cellspacing="3">
				<thead>
                                <tr class="col_title">
                                        <th>Sample Name
                                        <th>Experiment Name
                                        <th>Create date
				</tr>
				</thead>
				<tbody>
                               	<% for (int i=0; i<myTsamples.length; i++) {
					%><tr>
						<td><%=myTsamples[i].getTsample_id()%></td>
                                                <td><%=myTsamples[i].getTsample_exp_name()%></td>
                                                <td><%=myTsamples[i].getTsample_last_change()%></td>
					</tr><%
				}
				%> 
				</tbody>
			</table> 
			<BR>
		<% } %>
		<% if ((myHybridizations != null && myHybridizations.length > 0) || 
			(myTlabels != null && myTlabels.length > 0) ||
			(myTsamples != null && myTsamples.length > 0) ||
			(myTextracts != null && myTextracts.length > 0)) { %>
			<div class="title"> Protocols already used in experiments cannot be deleted.</div>
		<% } else { %>
			<BR><BR>
			<div class="title"> Click Delete to delete protocol '<%= protocolToBeDeleted.getProtocol_name() %>'.</div>
			<BR><BR>
			<center> <input type="submit" name="action" value="Delete" onClick="return confirmDelete()"></center>
		<% } %>

		<input type="hidden" name="itemID" value="<%=itemID%>">
		<input type="hidden" name="protocolID" value="<%=protocolID%>">
	</form>
	</div>
	<script type="text/javascript">
               var tablesorterSettings = { widgets: ['zebra'] };

               $(document).ready(function(){
                       $("table[id='hybrids']").tablesorter(tablesorterSettings);
                       $("table[id='hybrids']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
                       $("table[id='labels']").tablesorter(tablesorterSettings);
                       $("table[id='labels']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
                       $("table[id='extracts']").tablesorter(tablesorterSettings);
                       $("table[id='extracts']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
                       $("table[id='samples']").tablesorter(tablesorterSettings);
                       $("table[id='samples']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
               });
	</script>

