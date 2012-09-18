

<%@ page language="java"
        import="java.sql.*"
        import="java.net.URL"
        import="java.io.*"
        import="edu.ucdenver.ccp.util.*"
    
       
%>

<br/><br/>
<%
/*   commenting out in case we decide to make it a drop down selection
         User[] users = myUser.getAllUsers(dbConn);
            optionHash = new LinkedHashMap();
            optionHash.put("-99", "---- Select a user ----");
            for (int i=0; i<users.length; i++) {
                optionHash.put(Integer.toString(users[i].getUser_id()), users[i].getLast_name() + ", " + users[i].getFirst_name());
            }
                    selectName = "grantee_id";
                    selectedOption = "-99";
					onChange = "getArraysForUser()";
*/
%>                 		
		<%
		
        //	session.setAttribute("checkMark", checkMark);	
		String thisAction = request.getParameter("action"); 
		if (thisAction != null) { %>
		    <%@ include file="/web/experiments/grantArrayAccess.jsp" %>

		<%  
		}
		%>	<center>	
		<table>
			<tr>
				<td>First Name</td>
				<td><input type="text" name="firstName" size="25" id="piFirstName"/></td>
			</tr>
			<tr>
				<td>Last Name</td>
                <td><input type="text" name="lastName" size="25" id="piLastName"/></td>
			</tr>
		</table>
		<input type="button" name="findUser" id="findUser" value="Find User" />
		<div id="userDetails"> </div><br/>
		</center>  
		<%
		String experimentID = request.getParameter("experimentID");
		String experimentName = request.getParameter("experimentName");		
		%>
		
		<input type="hidden" name="experimentID" id="experimentID" value="<%= experimentID %>" />
		<input type="hidden" name="experimentName" id="experimentName" value="<%= experimentName %>" />
		<input type="hidden" name="userID" id="userID" />
			
		<div id="detailsDisplay"></div>
		
         
<script type="text/javascript">
    $(document).ready(function() {
       setupChooseUserPage();    
    });
</script> 
