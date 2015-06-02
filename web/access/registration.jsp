
<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  The web page created by this file registers new users.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/access/include/login_vars.jsp" %>
<%
	extrasList.add("main.min.css");
	extrasList.add("userCommon.js");
	extrasList.add("registrationPopup.js");
	extrasList.add("registrationPopup.css");
	pageDescription="Sign up for a free account to analyze data";
%>

<%@ page session="true" %>



<jsp:useBean id="newUser" class="edu.ucdenver.ccp.PhenoGen.data.User">
	<jsp:setProperty name="newUser" property="*" />
</jsp:useBean>

<%
	Properties myProperties = new Properties();
        File myPropertiesFile = new File(captchaPropertiesFile);
        myProperties.load(new FileInputStream(myPropertiesFile));
	String pub="";
	String secret="";
	pub=myProperties.getProperty("PUBLIC");
	secret=myProperties.getProperty("SECRET");
	
	
	log.info("in registration.jsp.");
	log.debug("caller = " + caller);
	log.debug("accessDir = " + accessDir);
	log.debug("host = " + host);
	log.debug("contextRoot = " + contextRoot);
	loggedIn = false;

	//
	// if person is already logged in, log them out first
	//
/*
	if ((String) session.getAttribute("userID") != null) {
		log.debug("Person registering is already logged in as " + 
				session.getAttribute("userID") + "-" + 
				session.getAttribute("userName"));
		mySessionHandler.setSession_id(session.getId());
                mySessionHandler.logoutSession(dbConn);
                session.invalidate();
		log.debug("Just invalidated session.");
	}
	else {
		log.debug("Person registering is not already logged in");
	}
*/


	//
	// Set the column values for a new user and then insert the 
	// user into the database
	//

	int thisUser_id = -99;
	String msg = "";

	log.debug("action = "+action);
	log.debug("first_name = "+newUser.getFirst_name());

        if ((action != null) && action.equals("Register")) {
                        String remoteIP=request.getRemoteAddr();
                        String gResponse="";
                        if(request.getParameter("g-recaptcha-response")!=null){
                            gResponse=request.getParameter("g-recaptcha-response");
                        }
                        reCaptcha re=new reCaptcha();
			session.setAttribute("contextRoot", contextRoot);
			session.setAttribute("webDir", webDir);
			session.setAttribute("commonDir", commonDir);
			String full_name = newUser.getTitle() + " "+ 
				newUser.getFirst_name() + " "+
				newUser.getLast_name(); 
			log.debug("full_name = "+full_name);
			log.debug("user_name = "+newUser.getUser_name());
			log.debug("contextRoot = "+contextRoot);

	
			if (re.checkResponse(secret,gResponse,remoteIP)) {
				thisUser_id = myUser.checkUserExists(newUser, dbConn);
				log.debug("user_id = "+thisUser_id);
				if (thisUser_id != -1) {
					//userLoggedIn = myUser.getUser(thisUser_id, dbConn);
					// Error - "User exists" 
					//session.setAttribute("errorMsg", "REG-001");
							//session.setAttribute("userID", "-1");
							//session.setAttribute("userLoggedIn", userLoggedIn);
					thisUser_id=-99;
					msg = "A user has already registered with the username you chose, "+
						"or somebody with the same first and last name has already registered with us. "+
						"If you think you might have already registered and would like us to email your password, "+
						"click <a href='" + accessDir + "emailPassword.jsp'>here.</a> ";
						//"<BR><BR> <a href='" + accessDir + "registration.jsp'>Return to Registration Page</a>";
					//response.sendRedirect(accessDir + "registration.jsp");
		
				} else {
					if(newUser.getFirst_name().equals(newUser.getLast_name())){
						log.debug("creation of user attempted with same first and last name");
						newUser.toString();
					}else{
						 int newUserID = myUser.createUser(newUser, dbConn);
						log.debug("just created new user.  The id is "+newUserID);
						// Still need to create a record in the TSUBMTR table -- remove this when combining with users table
						if(newUserID==-1){
							log.debug("UserID=-1: Possible fake registration?");
						}else{
							myUser.createTSUBMTR(newUser, dbConn);
				
							User requestor = myUser.getUser(newUserID, dbConn);
							//session.setAttribute("userID", "-1");
									//session.setAttribute("userLoggedIn", userLoggedIn);
                                                        int port=request.getServerPort();
                                                        String http="http://";
                                                        if(port==443){
                                                            http="https://";
                                                        }
							mainURL = http + host + contextRoot + "index.jsp";
				
							String userDir = requestor.getUserMainDir(userFilesRoot); 
				
							if (!myFileHandler.createDir(userDir) ||
								!myFileHandler.createDir(userDir+"GeneLists") ||
								!myFileHandler.createDir(userDir+"Arrays") ||
								!myFileHandler.createDir(userDir+"Datasets") ||
								!myFileHandler.createDir(userDir+"Experiments") ||
								!myFileHandler.createDir(userDir+"GeneLists/uploads") ||
								!myFileHandler.createDir(userDir+"GeneLists/downloads") ||
								!myFileHandler.createDir(userDir+"Datasets/uploads") ||
								!myFileHandler.createDir(userDir+"Experiments/uploads")) { 
				
								log.debug("error creating user directories in registration"); 
									
							} else {
								log.debug("no problems creating user directories in registration"); 
				
								myUser.updateRegistrationApproval(requestor, true, mainURL, dbConn);
								//Success - "Registration approval complete"
								//	session.setAttribute("successMsg", "REG-005");
								//	response.sendRedirect(commonDir + "successMsg.jsp");
							}
							//int piUserID = Integer.parseInt((String) request.getParameter("pi_user_id"));
							//User approver = new User();
							//if (piUserID != -99) {					// if pi selected: send email to pi
							//	approver = approver.getUser(piUserID, dbConn);
							//} else {
							//	approver = approver.getRegistrationApprover(dbConn);
							//}
							//try {
							//	newUser.sendRegistrationRequest(approver, mainURL, dbConn);
							//} catch (Exception e) {
							//	log.error("error sending email with registration request");
								// Error - "Error sending email when registering"
								//session.setAttribute("errorMsg", "REG-002");
							//	msg = "An error occurred while sending an email to the website administrator requesting "+
							//		"access to the website. As a result, you must return to the previous screen and re-submit "+
							//		"your registration. We apologize for the inconvenience.";
								//response.sendRedirect(accessDir + "errorMsg.jsp");
							//}
							msg = "New User Registration Successful." + 
								"<BR> " +
								"<BR> " +
								"For best results, your computer should meet or exceed the following hardware "+
								"requirements: <BR><BR> "+
								"3.0 Ghz CPU <BR>" +
								"1 Gb RAM <BR><BR>"+
							//"Your registration submission has been sent to the website administrator or your selected Principal Investigator.  "+
							//"Your registration request has been sent to the website administrator.  "+
							//"<BR> "+
							//"It will be reviewed within 24 hours of registering.  You will receive an email when you are approved."+
							//"<BR> "+
							//"<BR> "+
							"<a href='" + mainURL + "'>Log in to the website</a>";
							session.removeAttribute("userID");
							session.removeAttribute("userLoggedIn");
						}
					}
				}
			}else{
				msg="The text entered for the image doesn't match.  Please try again.";
			} //end of if captcha is valid
        }// end of if request is register

%>

<%@ include file="/web/common/basicHeader.jsp" %>
<script src='https://www.google.com/recaptcha/api.js'></script>
<script language="JAVASCRIPT" type="text/javascript">

	function codeOfEthicsMsg() {
        	var answer = confirm("Please read the terms associated with using this website for " +
					"research." + "\n" +
                                         "1.  I agree to be honest in reporting conclusions based on research " +
                                         "performed on this site." + "\n" +
                                         "2.  I agree not to use others' data to support my hypothesis without " +
                                         "written consent from the data's owner." + "\n" +
                                         "3.  I understand that if my actions disagree with the terms outlined " +
                                         "above, my privileges on this site may be restricted or revoked." + "\n" +
                                         "Select 'OK' if you agree to the terms outlined above.");
        	if (answer) {
                	return true;
        	} else {
                	return false;
        	}
	}
</script>

<% if (thisUser_id == -99) { %>

        <div id="main_body" class="body_border">
	<form	method="post" 
		action="<%=accessDir%>registration.jsp" 
		enctype="application/x-www-form-urlencoded" 
		onSubmit="return IsUserFormComplete(this)" 
		name="registration">
	<BR>

			<div class="title"> Provide the following information </div>
			<div style="padding-left:150px"><span style="color:red;"> * </span> Required fields</div>
			<center>
			<table class="list_base" style="border:1px solid;" cellpadding="5" cellspacing="2">	
			<TR><TD colspan="100%"><div style="text-align:center;font-size:14px;color:#FF0000; font-weight:bold;"><%=msg%></div></TD></TR>
			<tr>
				<td><b>Name</b></td>
				<td align="right">Title </td>
				<td>
					<%
					selectName = "title";
					selectedOption = "Dr.";
					onChange = "";
					style = "";
					optionHash = myHTMLHandler.getTitleList();
					%><%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr><tr>
				<td>&nbsp;</td> 
				<td align="right"> <span style="color:red;"> * </span> First </td>
				<td> <input type="text" name="first_name" size="15" value="<%=newUser.getFirst_name()%>"> &nbsp; 
				</td>
			</tr><tr>
				<td>&nbsp;</td> 
				<td align="right"> MI</td>
				<td><input type="text" name="middle_name"  size="3" value="<%=newUser.getMiddle_name()%>">&nbsp; </td>
			</tr><tr>
				<td>&nbsp;</td> 
				<td align="right"> <span style="color:red;"> * </span> Last  </td>
				<td><input type="text" name="last_name"  size="20" value="<%=newUser.getLast_name()%>"> </td>
			</tr>

			<tr><td colspan="3"><hr></td></tr>
			<tr>
				<td><b>Login</b></td>
				<td align="right"> <span style="color:red;"> * </span> Username </td>
				<td><input type="text" name="user_name" size="30" value="<%=newUser.getUser_name()%>"> </td>
			</tr>

			<tr>
				<td>&nbsp;</td> 
				<td align="right"> <span style="color:red;"> * </span> Password  </td>
				<td><input type="password" name="password" size="16" maxlength="16" value="<%=newUser.getPassword()%>"></td>
			</tr>
			<tr>
				<td>&nbsp;</td> 
				<td align="right"><span style="color:red;"> * </span> Re-enter Password </td>
				<td><input type="password" name="password2" size="16" maxlength="16" value="<%=newUser.getPassword()%>"> </td>
			</tr>

			<tr><td colspan="3"><hr></td></tr>
			<tr>
				<td><b>Contact</b></td>
				<td align="right"> <span style="color:red;"> * </span> Email </td>
				<td><input type="text" name="email"  size="30" value="<%=newUser.getEmail()%>"> </td>
			</tr>
			<tr>
				<td>&nbsp;</td> 
				<td align="right"> Phone </td>
				<td><input type="text" name="telephone"  size="15" value="<%=newUser.getTelephone()%>"> </td>
			</tr>
			<tr>
				<td>&nbsp;</td> 
		    		<td align="right">Fax </td>
				<td><input type="text" name="fax"  size="15" value="<%=newUser.getFax()%>"> </td>
			</tr>
			<tr><td colspan="3"><hr></td></tr>

			<tr>
				<td><b>Institution</b></td>
				<td align="right"> <span style="color:red;"> * </span> Name </td>
				<td><input type="text" name="institution"  size="50" value="<%=newUser.getInstitution()%>"> </td>
			</tr>

			<tr>
				<td>&nbsp;</td> 
				<td align="right"> Dept </td>
				<td><input type="text" name="lab_name"  size="30" value="<%=newUser.getLab_name()%>"></td>
			</tr>
			<tr>
				<td>&nbsp;</td> 
				<td align="right"> Box </td>
				<td><input type="text" name="box"  size="5" value="<%=newUser.getBox()%>"> </td>
			</tr>

			<tr>
				<td>&nbsp;</td>
				<td align="right"> <span style="color:red;"> * </span> Principal Investigator </td>
				<td> 
                
                <%
					String piUserName="Self";
					if(newUser.getPi_user_id()!=-99){
						piUserName=newUser.getUser_name(newUser.getPi_user_id(),dbConn);
					}
				%>
                
				 <INPUT type=radio name="selfPIRadio" id="selfPIRadio1" checked><span id="selectedPI" style="text-transform:capitalize"><%=piUserName%></span>
                 
				
				
					<% 
					optionHash = new LinkedHashMap();
					optionHash.put("-99", "Self");
					optionHash.putAll(newUser.getAllPrincipalInvestigators(dbConn));
					selectName = "pi_user_id";
					selectedOption = "-99";
					if(newUser.getPi_user_id()!=-99){
						selectedOption=Integer.toString(newUser.getPi_user_id());
					}
					%>					
					  
			                <span class="info" title="A Principal Investigator has ownership control 
					over microarray data that is uploaded by users reporting to them.  
					Other website users may request access to their data, and it is the principal
					investigator's responsiblity to approve or deny those requests.
					If you are not reporting to a PI in your organization, specify <i>Self</i> as
					your PI.
					">
                    				<img src="<%=imagesDir%>icons/info.gif" alt="Help">
			                </span>
				</td>
				

			</tr>
			<tr>
			   <td>&nbsp;</td><td>&nbsp;</td>
			   <td colspan="2" aligh="right"><span id="button"><INPUT type=radio name="selfPIRadio"  id="selfPIRadio2">Choose a Principal Investigator<BR></span></td>
			</tr>
			
			<div id="popupContact">
		       <a id="popupContactClose">x</a>
		      <h2>Enter a Principal Investigator</h2> 
		      
		      
		<p id="contactArea">
			
			<br/>
			
			
			<label for="piFirstName">First Name</label>
			<input id="piFirstName" name="piFirstName" size="30" type="text" style="text-transform:capitalize"/><br/>
			
			<label for="piFirstName">Last Name</label>
			<input id="piLastName" name="piLastName" size="30" type="text" style="text-transform:capitalize"/><br/>
				
			<br/>
			<input id="getPI" name="getPI" type="button" value="Find PI" />
			<div id="piReport"> </div><br/><br/> OR <br/><br/>
			<div id="useSelf"><a>Choose Myself as Principal Investigator</a> </div>
			
			
			
			<input id="pi_user_id" name="pi_user_id" type="hidden" value="<%=selectedOption%>"/>
			
			
			
			
			
		</p>
	     </div>			
	     <div id="backgroundPopup"></div>

			<tr><td colspan="3"><hr></td></tr>
			<tr>
				<td><b>Address</b></td>
				<td align="right"> Street </td>
				<td><input type="text" name="street"  size="65" value="<%=newUser.getStreet()%>"> </td>
			</tr>

			<tr>
				<td>&nbsp;</td>
				<td align="right"> City </td>
				<td><input type="text" name="city"  size="15" value="<%=newUser.getCity()%>"></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td align="right">State </td>
				<td>
					<%
					selectName = "state";
					selectedOption = "CO";
					if(!newUser.getState().equals("CO")){
						selectedOption=newUser.getState();
					}
					onChange = "";
					style = "";
					optionHash = myHTMLHandler.getStateList();
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td align="right"> Zip </td>
				<td><input type="text" name="zip"  size="6" value="<%=newUser.getZip()%>"></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td align="right"> Country </td>
				<td><input type="text" name="country" value="<%=newUser.getCountry()%>" size="10"> </td>		
			</tr>
             <tr><td colspan="100%">&nbsp;</td></tr>
			<TR>
                    <TD colspan="4" >
                    	<div style="text-align:center;width:100%">
                            <div class="g-recaptcha" data-sitekey="<%=pub%>"></div>
                	</div>
                    </TD>
                </TR>
            <tr><td colspan="100%">&nbsp;</td></tr>
			<tr><td colspan="100%" class="center">
			<input type="checkbox" id="termscheckbox"><%=twoSpaces%> I agree to the <a href="http://www.ucdenver.edu/POLICY/Pages/LegalNotices.aspx">Legal Notices</a> and <a href="http://www.ucdenver.edu/policy/Pages/PrivacyPolicy.aspx">Privacy Policy</a> 

			</td></tr>
            
			<tr><td colspan="100%">&nbsp;</td></tr>
			<tr><td>&nbsp;</td><td>&nbsp;</td><td>
			<input type="reset" value="Reset"><%=tenSpaces%>
			<input type="submit" name="action" value="Register" onClick="return codeOfEthicsMsg()" disabled="true" id="registerSubmitBtn">

			</td></tr>
			</table>
			</form>
			<BR><BR>
        </div> <!-- // end div_list_containter -->

<% } else { %>
	<div style="margin:50px;"><%=msg%> </div>
	
<% } %>
	<div class="brClear"></div>
    </div>
    </div>
	<%@ include file="/web/common/basicFooter.jsp" %>
        <script type="text/javascript">
                $(document).ready(function() {
                        setTimeout("setupMain()", 100);
                });
        </script>
