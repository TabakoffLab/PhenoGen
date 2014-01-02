<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  The web page created by this file displays contact information.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/access/include/login_vars.jsp" %>

<jsp:useBean id="myEmail" class="edu.ucdenver.ccp.PhenoGen.web.mail.Email"> </jsp:useBean>

<% 
	extrasList.add("index.css"); 
	String msg = "";
	if (action != null && action.equals("Submit")) {
                String emailAddress = (String) request.getParameter("emailAddress");
                String subject = (String) request.getParameter("subject");
                String feedback = (String) request.getParameter("feedback").trim();

		myEmail.setSubject("PhenoGen "+subject);
		myEmail.setContent("Feedback from "+ emailAddress + " :" + "\n\n" + feedback);
                try {
			myEmail.sendEmailToAdministrator(adminEmail);
			//mySessionHandler.createSessionActivity(session.getId(), "Sent an email from contact page", dbConn);
                } catch (Exception e) {
			log.error("exception while trying to send feedback to administrator", e);
                }
		if(dbConn!=null){
			String msgNum = "ADM-003";
			session.setAttribute("successMsg", msgNum);
			response.sendRedirect(commonDir + "startPage.jsp");
		}else{
			response.sendRedirect(commonDir + "startPage.jsp");
		}
	}
	//mySessionHandler.createSessionActivity(session.getId(), "Looked at contact page", dbConn);
%>
<%pageTitle="Contact Us";
pageDescription="Contact Us, provide feedback or ask questions";
%>
	<%@ include file="/web/common/header.jsp" %>

        	<div id="welcome" style="height:575px; width:946px;">
			<h2>Contact PhenoGen </h2>
                        <p> The quality, functionality, and continued maintenance of the PhenoGen Informatics 
			website depends on feedback from you, our user.  We welcome your questions and appreciate 
			your comments and suggestions.
			Use the form below to send us your question or to give us feedback.
                        </p>


			<BR>
			<BR>
			<center>
        		<form   method="post"
        			action="contact.jsp"
        			name="contact"
        			enctype="application/x-www-form-urlencoded">
			<div style="margin-left:10px;">
			<table>
			<tr>
				<td colspan="2"><h2>Provide the following information:</h2></td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr>
				<td> Your email address: </td>
				<td><input type="text" name="emailAddress" size="30"/></td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr>
				<td>Subject:</td>
                		<td><select name="subject">
					<option label="Question" value="Question">Question</option>
					<option label="Suggestion" value="Suggestion">Suggestion</option>
					<option label="Feedback" value="Feedback">Feedback</option>
					<option label="Error" value="Error">Error</option>
					</select>
				</td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
            <tr>
        			<td>Feedback:</td>
            </tr>
			<tr>
				<td colspan="2"><textarea name="feedback" cols="80" rows="10"></textarea></td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr>
				<td colspan="2" align="center">
				<input type="reset" name="reset" value="Reset"> <%=tenSpaces%>
        			<input type="submit" name="action" value="Submit">
				</td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			</table>
			<BR><BR>
        	</form>
			</center>
		</div> <!-- // end welcome-->


	<%@ include file="/web/common/footer.jsp" %>
  <script type="text/javascript">
    $(document).ready(function() {
	setTimeout("setupMain()", 100); 
    });
  </script>
