<%--
 *  Author: Cheryl Hornbaker
 *  Created: July, 2005
 *  Description:  The web page created by this file allows the user to maintain
 * 	user access for a gene list.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %> 

<%
	log.info ("in geneListUsers.jsp. user = " + user);

	request.setAttribute( "selectedTabId", "share" );
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
        extrasList.add("jquery.dataTables.1.10.9.min.js");


        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-004");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }

	String owner = "";
	int numRows;
	User[] myGeneListUsers = null;
	
	if (selectedGeneList.getGene_list_id() != -99) {
		myGeneListUsers = myGeneList.getGeneListUsers(selectedGeneList.getGene_list_id(), pool);

		numRows = myGeneListUsers.length;
		owner = selectedGeneList.getUserIsOwner();
		log.debug("owner = " + owner);
		mySessionHandler.createGeneListActivity("Viewed user access for gene list", pool);
	}

	
	if ((action != null) && action.equals("Update Gene List Users")) {
	
		//
		// delete the users that were there before, and 
		// then insert any users that are checked now
		//
		selectedGeneList.deleteGeneListUsers(pool);

		if (request.getParameter("userList") != null) {
			List userList = Arrays.asList(request.getParameterValues("userList")); 
			//log.debug("userList = "); myDebugger.print(userList);

			myGeneList.setGene_list_users(userList);
			myGeneList.setGene_list_id(selectedGeneList.getGene_list_id());
			myGeneList.createGeneListUsers(pool);
		}
		mySessionHandler.createGeneListActivity("Updated User Access for Gene List", pool);

		//Success - "Gene list users updated"
		session.setAttribute("successMsg", "GL-015");
		response.sendRedirect(commonDir + "successMsg.jsp");
	}

	formName = "geneListUsers.jsp";
%>
<%@ include file="/web/geneLists/include/geneListJS.jsp"  %>
<%@ include file="/web/common/header_adaptive_menu.jsp" %>


	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>
        
	<div class="page-intro">
		<p>Listed below are the users of this website.  To share your genelist with other user(s), click the checkbox next to their name(s).
		</p>
	</div> <!-- // end page-intro -->

	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>

<% if (selectedGeneList.getGene_list_id() != -99) { %>

<% if (!selectedGeneList.getUserIsOwner().equals("N")) { 
	%>	
		<form   name="geneListUsers"
			method="post"
		        action="geneListUsers.jsp"
		        enctype="application/x-www-form-urlencoded">

		<%
	} else { 
		owner = "N";
		%> 
		<BR> <BR>
		<center><h2>Note: You can only change user access for a gene list that you own.</h2></center> 
		<BR> <BR>
	<%
	} 
	%>


	<div class="dataContainer" style="padding-bottom: 70px;">
	<div class="title"> Users who can view the selected gene list </div>
      	<table class="list_base tablesorter" name="items" id="items" cellpadding="0" cellspacing="3" width="100%">
		<thead>
		<tr class="col_title">
			<% if (owner.equals("Y")) { %>
				<th><input type="checkbox" id="checkBoxHeader" onClick="checkUncheckAll(this.id, 'userList')"> </th>
			<% } else { %>
				<th>Access</th>
			<% } %>
			<th> User</th>
		</tr>
		</thead>
		<tbody>
		<% 	

		/*
	 	* If this user "owns" the gene list, then display check 
	 	* boxes that he/she can update.  
	 	*/
	
		for (int i=0; i<myGeneListUsers.length; i++) {
			String columnVal = "";
			String checked = "";
			%> <tr> <%
				if (myGeneListUsers[i].getUser_id() == selectedGeneList.getCreated_by_user_id()) {
					columnVal = "Owner";
					%> <td class=center><%=columnVal%></td><%
				} else if (myGeneListUsers[i].getUser_id() == userID) {
					columnVal = "X";
					%> <td class=center><%=columnVal%></td> <%
				} else {
					if (owner.equals("Y")) {
						if (myGeneListUsers[i].getChecked() == 1) {
							checked = " checked";
						}
						%> <td class=center><input type="checkbox" name="userList" value="<%=myGeneListUsers[i].getUser_id() %>"<%=checked%>></td><%
					} else {
						if (myGeneListUsers[i].getChecked() == 1) {
							%> <td class=center>X</td> <%
						} else {
							%> <td class=center>&nbsp;</td> <%
						}
					}
				}
				%><td><%=myGeneListUsers[i].getSorting_name()%></td>
			</tr> <%
		}
		%>
		</tbody>
		</table>

	<% if (!owner.equals("N")) {
	%>
		<BR> <BR>
		<center>
		<input type="reset" name="reset" value="Reset"> <%=tenSpaces%>
		<input type="submit" name="action" value="Update Gene List Users">  
		</center>
		<BR> <BR>
		<input type="hidden" name="geneListID" value=<%=selectedGeneList.getGene_list_id()%>>
		</form>
	<%
	}
	%>
	</div>
<% } %>
<script type="text/javascript">
        /*$(document).ready(function() {
                var tablesorterSettings = { widgets: ['zebra'] };
                $("table[id='items']").tablesorter(tablesorterSettings);
        	$("table[id='items']").tablesorter({headers:{0:{sorter:false}}});
        	$("table[id='items']").find("tr.col_title").find("th").slice(1,2).addClass("headerSortDown");
	});*/
        $(document).ready(function() {
            $("table#items").dataTable({
					"bPaginate": false,
					"bAutoWidth": true,
					"sScrollX": "100%",
					"sScrollY": "600px",
					"aaSorting": [[ 1, "asc" ]],
					"sDom": 'fti'
			});
        });
</script>

<%@ include file="/web/common/footer_adaptive.jsp" %>
