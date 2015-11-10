<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  The web page created by this file allows a user to update his/her information.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/common/session_vars.jsp"  %>

<%
	extrasList.add("registrationPopup.js");
	extrasList.add("registrationPopup.css");
%>
<jsp:useBean id="myOriginalUser" class="edu.ucdenver.ccp.PhenoGen.data.User"> </jsp:useBean>
<jsp:useBean id="myUpdatedUser" class="edu.ucdenver.ccp.PhenoGen.data.User">
	<jsp:setProperty name="myUpdatedUser" property="*" />
</jsp:useBean>



<%
	userID = Integer.parseInt((String) session.getAttribute("userID"));

	log.info("in userUpdate.  user = " + user);

	myOriginalUser = myOriginalUser.getUser(userID, pool);

	if (myOriginalUser.getUser_name().equals("guest")) {
		//Error - "Can't update guest's information
                session.setAttribute("errorMsg", "GST-001");
                response.sendRedirect(commonDir + "errorMsg.jsp");
	}

	myUpdatedUser.setUser_id(userID);

        action = (String)request.getParameter("action");

        if ((action != null) && action.equals("Update")) {

		full_name =  myUpdatedUser.getTitle() + 
					" " + 
					myUpdatedUser.getFirst_name() + 
					" " + 
					myUpdatedUser.getLast_name();

		session.setAttribute("full_name", full_name);
		log.debug("full_name = "+full_name);

		myUpdatedUser.setUser_name(myOriginalUser.getUser_name());
		myUpdatedUser.setState(request.getParameter("state"));
                myUpdatedUser.updateUser(myUpdatedUser, pool);

                session.setAttribute("userID", Integer.toString(userID));
		session.setAttribute("full_name", myUpdatedUser.getTitle() + 
					" " + 
					myUpdatedUser.getFirst_name() + 
					" " + 
					myUpdatedUser.getLast_name());
		session.setAttribute("lab_name", myUpdatedUser.getLab_name());
		session.setAttribute("userName", myUpdatedUser.getUser_name());
		log.debug ("emailAddress= "+ myUpdatedUser.getEmail());

                userLoggedIn = myUser.getUser(userLoggedIn.getUser_id(), pool);
		userLoggedIn.setUserMainDir(userFilesRoot);
		session.setAttribute("userLoggedIn", userLoggedIn);

		mySessionHandler.createActivity("Updated user profile.", pool);

		//Success - "User Updated"
		session.setAttribute("successMsg", "REG-004");
		response.sendRedirect(commonDir + "successMsg.jsp");
        }

%>

<%@ include file="/web/common/header.jsp" %>
<script language="JAVASCRIPT" src="<%=javascriptDir%>userCommon.js" type="text/javascript"></script>

	<form	method="post" 
		action="<%=accessDir%>userUpdate.jsp" 
		enctype="application/x-www-form-urlencoded" 
		onSubmit="return IsUserFormComplete(this)"
		name="UserUpdate">
	<BR>
        <div class="list_container">
	<center>
			<table class="list_base" style="border:1px solid;" cellpadding="5" cellspacing="2">	

			<tr>
				<td><b>Name</b></td>
				<td align="right">Title </td>
				<td>
					<%
					selectName = "title";
					selectedOption = myOriginalUser.getTitle();
					selectedOption = "Dr.";
					onChange = "";
					style = "";
					optionHash = myHTMLHandler.getTitleList();
					%><%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr><tr>
				<td>&nbsp;</td> 
				<td align="right"> <span style="color:red;"> * </span> First </td>
				<td> <input type="text" name="first_name" size="15" value="<%=myOriginalUser.getFirst_name()%>"> &nbsp; 
				</td>
			</tr><tr>
				<td>&nbsp;</td> 
				<td align="right"> MI</td>
				<td><input type="text" name="middle_name"  size="3" value="<%=myOriginalUser.getMiddle_name()%>">&nbsp; </td>
			</tr><tr>
				<td>&nbsp;</td> 
				<td align="right"> <span style="color:red;"> * </span> Last  </td>
				<td><input type="text" name="last_name"  size="20" value="<%=myOriginalUser.getLast_name()%>"> </td>
			</tr>

			<tr><td colspan="3"><hr></td></tr>

			<tr>
				<td><b>Login</b></td>
				<td align="right"> <span style="color:red;"> * </span> Username </td>
				<td><input type="text" name="user_name" size="30" value="<%=myOriginalUser.getUser_name()%>" onFocus="blur()"> &nbsp;&nbsp;<b>Note: Username can NOT be modified</b> </td>
			</tr>

			<tr>
				<td>&nbsp;</td> 
				<td align="right"> <span style="color:red;"> * </span> Password  </td>
				<td><input type="password" name="password" size="16" maxlength="16" value="<%=myOriginalUser.getPassword()%>"></td>
			</tr>
			<tr>
				<td>&nbsp;</td> 
				<td align="right"><span style="color:red;"> * </span> Re-enter Password </td>
				<td><input type="password" name="password2" size="16" maxlength="16" value="<%=myOriginalUser.getPassword()%>"> </td>
			</tr>

			<tr><td colspan="3"><hr></td></tr>
			<tr>
				<td><b>Contact</b></td>
				<td align="right"> <span style="color:red;"> * </span> Email </td>
				<td><input type="text" name="email"  size="30" value="<%=myOriginalUser.getEmail()%>"> </td>
			</tr>
			<tr>
				<td>&nbsp;</td> 
				<td align="right"> Phone </td>
				<td><input type="text" name="telephone"  size="15" value="<%=myOriginalUser.getTelephone()%>"> </td>
			</tr>
			<tr>
				<td>&nbsp;</td> 
		    		<td align="right">Fax </td>
				<td><input type="text" name="fax"  size="15" value="<%=myOriginalUser.getFax()%>"> </td>
			</tr>
			<tr><td colspan="3"><hr></td></tr>

			<tr>
				<td><b>Institution</b></td>
				<td align="right"> <span style="color:red;"> * </span> Name </td>
				<td><input type="text" name="institution"  size="50" value="<%=myOriginalUser.getInstitution()%>"> </td>
			</tr>

			<tr>
				<td>&nbsp;</td> 
				<td align="right"> Dept </td>
				<td><input type="text" name="lab_name"  size="30" value="<%=myOriginalUser.getLab_name()%>"></td>
			</tr>
			<tr>
				<td>&nbsp;</td> 
				<td align="right"> Box </td>
				<td><input type="text" name="box"  size="5" value="<%=myOriginalUser.getBox()%>"> </td>
			</tr>

			<tr>
				<td>&nbsp;</td>
				<td align="right"> <span style="color:red;"> * </span> Principal Investigator </td>
				<td>
				
				
				
				<%
				User piUser = myOriginalUser.getUser(myOriginalUser.getPi_user_id(), pool);
				String PIFullname = piUser.getPi_user_id()==piUser.getUser_id()?"Self":piUser.getFull_name();
				%>
				
				
				<INPUT type=radio name="selfPIRadio" id="selfPIRadio1" checked><span id="selectedPI" style="text-transform:capitalize"><%= PIFullname %></span>
				
					
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
			<div id="useSelfOnUpdate"><a>Choose Myself as Principal Investigator</a> </div>
			
			
		   <input id="initial_pi_user_id" name="initial_pi_user_id" type="hidden" value="<%= String.valueOf(userID) %>"/>
           <input id="pi_user_id" name="pi_user_id" type="hidden" value="<%= String.valueOf(myOriginalUser.getPi_user_id()) %>"/>	
			
			
		</p>
	     </div>			
	     <div id="backgroundPopup"></div>			

			
			<tr><td colspan="3"><hr></td></tr>
			<tr>
				<td><b>Address</b></td>
				<td align="right"> Street </td>
				<td><input type="text" name="street"  size="65" value="<%=myOriginalUser.getStreet()%>"> </td>
			</tr>

			<tr>
				<td>&nbsp;</td>
				<td align="right"> City </td>
				<td><input type="text" name="city"  size="15" value="<%=myOriginalUser.getCity()%>"></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td align="right">State </td>
				<td>
					<%
					selectName = "state";
					selectedOption = myOriginalUser.getState();
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
				<td><input type="text" name="zip"  size="6" value="<%=myOriginalUser.getZip()%>"></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td align="right"> Country </td>
				<td<input type="text" name="country" value="USA" size="10" value="<%=myOriginalUser.getCountry()%>"> </td>		
			</tr>

			</table>
		</center>

		<BR>

	<center>
		<input type="reset" value="Reset"><%=tenSpaces%>
		<input type="submit" name="action" value="Update">
	</center>

	</form>
        </div> <!-- // end div_list_containter -->
<%@ include file="/web/common/footer.jsp" %>
