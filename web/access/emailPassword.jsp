<%--
 *  Author: Kendra Jones
 *  Created: June, 2004
 *  Description:  The web page created by this file allows a user to enter their email address and
 *  			receive an email containing their website password
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/access/include/login_vars.jsp" %>
<jsp:useBean id="myEmail" class="edu.ucdenver.ccp.PhenoGen.web.mail.Email"> </jsp:useBean>
<% 
	extrasList.add("main.css");
	extrasList.add("main.js");
	loggedIn = false;

	log.info("In emailPassword.jsp.");

	String msg ="Enter the email address you used during registration OR enter your first and last name.<BR>"+
		"An email will be sent to you containing your password.";

	if (action != null && action.equals("Send Password")) {

		String emailAddress = (String) request.getParameter("emailAddress"); 
		String firstName = (String) request.getParameter("firstName");
		String lastName = (String) request.getParameter("lastName");
		
		String password = "";
		if (emailAddress != null && !emailAddress.equals("")) {
			password = myUser.getUserPassword(emailAddress, dbConn);
		} else {
			String[] values = myUser.getUserPassword(firstName, lastName, dbConn);
			if (values != null) {
				password = values[0];
				emailAddress = values[1];
			}
		}

		if (password.equals("")) {
			msg = "No matching records were found for the information entered.  Please re-enter.";
        	} else {
			msg = "Your website password has been sent to your email address.";

			myEmail.setSubject("PhenoGen website password");
			myEmail.setTo(emailAddress);
			myEmail.setContent("Your password is " + password);
			try {
				myEmail.sendEmail();
                        	mySessionHandler.createSessionActivity("-99",
					firstName + " " + lastName + " requested password be sent to " + emailAddress, dbConn); 
			} catch (Exception e) {
				log.error("exception while trying to send message notifying user of password", e);
			}
                }
	} 
			

%>
<%@ include file="/web/common/basicHeader.jsp" %>

	<div id="main_body" class="body_border">
	<div class="page-intro"><%=msg%></div>

<% if (!msg.equals("Your website password has been sent to your email address.")) { %> 

	<div id="emailPassword">
	<form   method="post"
        action="<%=accessDir%>emailPassword.jsp"
        name="emailPassword"
        enctype="application/x-www-form-urlencoded" >
	<BR><BR>
	<table class="list_base">
        	<tr>
			<td width="50%"><b>Email Address</b>:</td>
			<td><input type="text" name="emailAddress"  size="60"></td>
		</tr>
		<tr><td colspan="100%">&nbsp;</td></tr>
		<tr><td colspan="100%"><strong>OR</strong></td></tr>
		<tr><td colspan="100%">&nbsp;</td></tr>
        	<tr>
			<td><b>First Name</b>:</td>
			<td><input type="text" name="firstName"  size="60"></td>
		</tr>
        	<tr>
			<td><b>Last Name</b>:</td>
			<td><input type="text" name="lastName"  size="60"></td>
		</tr>
		<tr><td colspan="100%">&nbsp;</td></tr>
		<tr><td>&nbsp;</td>
		<td><input type="reset" name="reset" value="Reset"> <%=twoSpaces%>
		<input type="submit" name="action" value="Send Password" onClick="return IsPasswordRequestFormComplete()"></td>
		</tr>
	</table>
	</form>

	</div> <!-- emailPassword -->
<% } %>
	</div> <!-- main_body -->
	<div class="brClear"></div>
	<%@ include file="/web/common/basicFooter.jsp" %>
        <script type="text/javascript">
                $(document).ready(function() {
			document.emailPassword.emailAddress.focus();
                        setTimeout("setupMain()", 100);
                });
        </script>

	<script language="JAVASCRIPT" type="text/javascript">
	function IsPasswordRequestFormComplete(){

        	if (document.emailPassword.emailAddress.value != '' &&
        		document.emailPassword.firstName.value != '' &&
        		document.emailPassword.lastName.value != '') { 
                	alert('Enter either your email address OR your first and last name, but not both.')
                        	document.emailPassword.emailAddress.focus();
                	return false;
		}
        	if (document.emailPassword.emailAddress.value == '' &&
        		document.emailPassword.firstName.value == '' &&
        		document.emailPassword.lastName.value == '') { 
                	alert('Enter either your email address or your first and last name before proceeding.')
                        	document.emailPassword.emailAddress.focus();
                	return false;
		}
        	if ((document.emailPassword.firstName.value != '' &&
        		document.emailPassword.lastName.value == '') ||
        		(document.emailPassword.firstName.value == '' &&
        		document.emailPassword.lastName.value != '')) {
                	alert('Enter both your first and last name before proceeding.')
                        	document.emailPassword.firstName.focus();
                	return false;
        	}
	}
	</script>
