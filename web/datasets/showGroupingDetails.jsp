<%-- *  Author: Cheryl Hornbaker
 *  Created: Feb, 2009
 *  Description:  This file creates a web page showing the details of a dataset grouping. 
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/datasetHeader.jsp" %>
<%
	extrasList.add("showGroupingDetails.js");

	int grouping_id = (request.getParameter("grouping_id") != null ? 
				Integer.parseInt((String) request.getParameter("grouping_id")) : -99);

	log.info("in showGroupingDetails.jsp. grouping_id = " + grouping_id);
	Dataset.Group[] groups = (grouping_id != -99 ? myDataset.getGroupsInGrouping(grouping_id, dbConn) : null); 
	mySessionHandler.createDatasetActivity("Looked at grouping details", dbConn);
%>
	
	<% if (groups != null) { %>
	<%@ include file="/web/common/headTags.jsp" %>

	<div class="list_container">
		<div class="title">  Groups </div>
		<table id="groupingDetails" name="groupingDetails" class="list_base" cellpadding="0" cellspacing="3">
			<thead>
			<tr class="col_title">
				<th>Group Number</th>
				<th>Group Name</th>
				<th class="noSort">Arrays in Group</th>
			</tr>
			</thead>
			<tbody>
			<% 
			for (int j=0; j<groups.length; j++) {
				User.UserChip[] myChips = groups[j].getChipAssignments(dbConn);
			%>
			<tr>
				<td class="center"><%=groups[j].getGroup_number()%></td>
				<td class="center"><%=groups[j].getGroup_name()%></td>
				<td class="center">
				<% for (int k=0; k<myChips.length; k++) { 
					if (myChips[k].getGroup().getGroup_number() == groups[j].getGroup_number()) { 
						%><%=myChips[k].getHybrid_name()%><BR><% 
					}
				} %>
				</td>
			</tr><%
			}
			%>
			</tbody>
		</table>
	</div>
		
	<% } %>

	<div class="closeWindow">Close</div>

    <script type="text/javascript">
        setUpShowGroupingDetailsPage();
    </script>

