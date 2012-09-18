<%--
 *  Author: Cheryl Hornbaker
 *  Created: Mar, 2006
 *  Description:  This file creates a web page that displays information about the user
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/common/session_vars.jsp"  %>

<%
	int thisUserID = Integer.parseInt((String) request.getParameter("userID"));

	log.info("in userDetails.jsp. userID = "+thisUserID);

	User thisUser = myUser.getUser(thisUserID, dbConn);

%>
<table class=userSpecificWide>
	<tr>
		<th width="15%"> Name </th>
		<td><%=thisUser.getFull_name()%></td>
	</tr><tr>
		<th width="15%"> Email Address </th>
		<td><%=thisUser.getEmail()%></td>
	</tr><tr>
		<th width="10%"> Phone Number </th>
		<td><%=thisUser.getTelephone()%></td>
		<th width="10%"> Fax Number </th>
		<td><%=thisUser.getFax()%></td>
	</tr><tr>
		<th width="5%"> Institution </th>
		<td><%=thisUser.getInstitution()%></td>
		<th width="5%"> Dept or Lab </th>
		<td><%=thisUser.getLab_name()%></td>
		<th width="5%"> Box </th>
		<td><%=thisUser.getBox()%></td>
	</tr><tr>
		<th width="35%"> Address </th>
		<td><%=thisUser.getStreet()%>&nbsp;<%=thisUser.getCity()%>&nbsp;<%=thisUser.getState()%>&nbsp;<%=thisUser.getZip()%>&nbsp;<%=thisUser.getCountry()%></td>
	</tr>

</table>

