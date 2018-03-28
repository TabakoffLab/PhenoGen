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
	extrasList.add("main.min.css");
	extrasList.add("main1.0.2.js");
	loggedIn = false;
	
	String emailAddress = "";
	String firstName = "";
	String lastName = "";
	if( request.getParameter("emailAddress")!=null){
		emailAddress = (String) request.getParameter("emailAddress");
	}
	if( request.getParameter("firstName") !=null){
			firstName = (String) request.getParameter("firstName");
	}
	if( request.getParameter("lastName")!=null){
			lastName = (String) request.getParameter("lastName");
	}
	
	
	Properties myProperties = new Properties();
        File myPropertiesFile = new File(captchaPropertiesFile);
        myProperties.load(new FileInputStream(myPropertiesFile));
	String errorMsg="";
	String pub="";
	String secret="";
	pub=myProperties.getProperty("PUBLIC");
	secret=myProperties.getProperty("SECRET");

	log.info("In emailPassword.jsp.");

	String msg ="Enter the email address you used during registration OR enter your first and last name.<BR>"+
		"An email will be sent to you containing your password.";

	if (action != null && action.equals("Send Password")) {
		String remoteAddr = request.getRemoteAddr();
		reCaptcha re=new reCaptcha();
                String gResponse="";
                if(request.getParameter("g-recaptcha-response")!=null){
                    gResponse=request.getParameter("g-recaptcha-response");
                }

		if (re.checkResponse(secret,gResponse,remoteAddr)) {

			String password = "";
			if (emailAddress != null && !emailAddress.equals("")) {
				password = myUser.getUserPassword(emailAddress, pool);
			} else {
				String[] values = myUser.getUserPassword(firstName, lastName, pool);
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
						firstName + " " + lastName + " requested password be sent to " + emailAddress, pool); 
				} catch (Exception e) {
					log.error("exception while trying to send message notifying user of password", e);
				}
			}
		}else{
				errorMsg="The text entered for the image doesn't match.  Please try again.";
		} //end of if captcha is valid
	} 
			

%>
<%@ include file="/web/common/basicHeader.jsp" %>
<script src='https://www.google.com/recaptcha/api.js'></script>
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
    		<TR><TD colspan="100%"><div style="text-align:center;font-size:14px;color:#FF0000; font-weight:bold;"><%=errorMsg%></div></TD></TR>
        	<tr>
			<td width="50%"><b>Email Address</b>:</td>
			<td><input type="text" name="emailAddress" id="emailAddress"  size="60" value="<%=emailAddress%>" ></td>
		</tr>
		<tr><td colspan="100%">&nbsp;</td></tr>
		<tr><td colspan="100%"><strong>OR</strong></td></tr>
		<tr><td colspan="100%">&nbsp;</td></tr>
        	<tr>
			<td><b>First Name</b>:</td>
			<td><input type="text" name="firstName" id="firstName"  size="60" value="<%=firstName%>"></td>
		</tr>
        	<tr>
			<td><b>Last Name</b>:</td>
			<td><input type="text" name="lastName" id="lastName"  size="60" value="<%=lastName%>"></td>
		</tr>
		<tr><td colspan="100%">&nbsp;</td></tr>
        <TR>
                    <TD colspan="100%" >
                    	
                           <div style="text-align:center;width:100%">
                                <div class="g-recaptcha" data-sitekey="<%=pub%>"></div>
                            </div>
                	
                    </TD>
                </TR>
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
    </div></div>
	<div class="brClear"></div>
	<%@ include file="/web/common/basicFooter.jsp" %>
        <script type="text/javascript">
                $(document).ready(function() {
						$("#emailAddress").focus();
						//document.emailPassword.emailAddress.focus();
                        setTimeout("setupMain()", 100);
                });
	function IsPasswordRequestFormComplete(){

		if ($("#emailAddress").val() != '' &&
        		$("#firstName").val() != '' &&
        		$("#lastName").val() != '') { 
                	alert('Enter either your email address OR your first and last name, but not both.');
                    $("#emailAddress").focus();
                	return false;
		}
        	if ($("#emailAddress").val() == '' &&
        		$("#firstName").val() == '' &&
        		$("#lastName").val() == '') { 
                	alert('Enter either your email address or your first and last name before proceeding.');
                    $("#emailAddress").focus();
                	return false;
		}
        	if (($("#firstName").val() != '' &&
        		$("#lastName").val() == '') ||
        		($("#firstName").val() == '' &&
        		$("#lastName").val() != '')) {
                	alert('Enter both your first and last name before proceeding.');
                    $("#emailAddress").focus();
                	return false;
        	}
	}
	</script>
