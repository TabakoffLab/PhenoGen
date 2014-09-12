<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  The web page created by this file displays contact information.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ page import="net.tanesha.recaptcha.ReCaptcha" %>
<%@ page import="net.tanesha.recaptcha.ReCaptchaFactory" %>
<%@ page import="net.tanesha.recaptcha.ReCaptchaImpl" %>
<%@ page import="net.tanesha.recaptcha.ReCaptchaResponse" %>

<%@ include file="/web/access/include/login_vars.jsp" %>

<jsp:useBean id="myEmail" class="edu.ucdenver.ccp.PhenoGen.web.mail.Email"> </jsp:useBean>

<% 	extrasList.add("normalize.css");
	extrasList.add("index.css"); 
	
	Properties myProperties = new Properties();
    File myPropertiesFile = new File(captchaPropertiesFile);
    myProperties.load(new FileInputStream(myPropertiesFile));
	
	String pub="";
	String secret="";
	pub=myProperties.getProperty("PUBLIC");
	secret=myProperties.getProperty("SECRET");
	
	String msg = "";
	String emailAddress="";
	String subject="";
	String feedback="";
	if (action != null && action.equals("Submit")) {
        emailAddress = (String) request.getParameter("emailAddress");
        subject = (String) request.getParameter("subject");
        feedback = (String) request.getParameter("feedback").trim();
		String remoteAddr = request.getRemoteAddr();
        ReCaptchaImpl reCaptcha = new ReCaptchaImpl();
        reCaptcha.setPrivateKey(secret);

        String challenge = request.getParameter("recaptcha_challenge_field");
        String uresponse = request.getParameter("recaptcha_response_field");
        ReCaptchaResponse reCaptchaResponse = reCaptcha.checkAnswer(remoteAddr, challenge, uresponse);

        if (reCaptchaResponse.isValid()) {

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
		}else{
			msg="The text entered for the image doesn't match.  Please try again.";
		}
	}
	//mySessionHandler.createSessionActivity(session.getId(), "Looked at contact page", dbConn);
%>
<%pageTitle="Contact Us";
pageDescription="Contact Us, provide feedback or ask questions";
%>
	<%@ include file="/web/common/header.jsp" %>
			<script type="text/javascript">
			 var RecaptchaOptions = {
				theme : 'clean',
				custom_theme_widget: 'recaptcha_widget'
			 };
 			</script>
        	<div id="welcome" style="height:625px; width:946px;">
			<h2>Contact PhenoGen </h2>
                        <p> The quality, functionality, and continued maintenance of the PhenoGen Informatics 
			website depends on feedback from you, our user.  We welcome your questions and appreciate 
			your comments and suggestions.
			Use the form below to send us your question or to give us feedback.
                        </p>


			<BR>
			<BR>
            <div style="width:100%;">
                <div style="background:#FFFFFF;text-align:center;font-size:14px;color:#FF0000; font-weight:bold; width:800px;"><%=msg%></div>
                
                    <form   method="post"
                        action="contact.jsp"
                        name="contact"
                        enctype="application/x-www-form-urlencoded">
                <table width="800">
                <tr>
                    <td colspan="4"><h2>Provide the following information:</h2></td>
                </tr>
                <tr><td colspan="4">&nbsp;</td></tr>
                <tr>
                    <td> Your email address: </td>
                    <td><input type="text" name="emailAddress" size="30" value="<%=emailAddress%>"/></td>
                    <td>Subject:</td>
                            <td><select name="subject">
                        <option label="Question" value="Question" <%if(subject.equals("Question")){%>selected="selected"<%}%>>Question</option>
                        <option label="Suggestion" value="Suggestion" <%if(subject.equals("Suggestion")){%>selected="selected"<%}%>>Suggestion</option>
                        <option label="Feedback" value="Feedback" <%if(subject.equals("Feedback")){%>selected="selected"<%}%>>Feedback</option>
                        <option label="Error" value="Error" <%if(subject.equals("Error")){%>selected="selected"<%}%>>Error</option>
                        </select>
                    </td>
                </tr>
                
                <tr><td colspan="4">&nbsp;</td></tr>
                <tr>
                        <td>Feedback:</td>
                </tr>
                <tr>
                    <td colspan="4"><textarea name="feedback" cols="120" rows="10"><%=feedback%></textarea></td>
                </tr>
                <tr><td colspan="4">&nbsp;</td></tr>
                <TR>
                    <TD colspan="4" >
                    	<div style="text-align:center;width:100%">
                    <%
                      ReCaptcha c = ReCaptchaFactory.newReCaptcha(pub, secret, false);
                      out.print(c.createRecaptchaHtml(null, null));
                    %>
                	</div>
                    </TD>
                </TR>
                <tr>
                    <td colspan="4" align="center">
                    <input type="reset" name="reset" value="Reset"> <%=tenSpaces%>
                        <input type="submit" name="action" value="Submit">
                    </td>
                </tr>
                <tr><td colspan="4">&nbsp;</td></tr>
                </table>
                <BR><BR>
                </form>
            </div>
		</div> <!-- // end welcome-->
	</div>
    </div>

	<%@ include file="/web/common/footer.jsp" %>
  <script type="text/javascript">
    $(document).ready(function() {
	setTimeout("setupMain()", 100); 
    });
  </script>
