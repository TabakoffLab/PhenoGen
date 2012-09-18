<%--
 *  Author: Cheryl Hornbaker
 *  Created: May, 2007
 *  Description:  The web page created by this file displays subjects matching a criteria
 *		and allows the user to create subject groups
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/common/session_vars.jsp"%>

<jsp:useBean id="myIsbra" class="edu.ucdenver.ccp.PhenoGen.data.Isbra"> </jsp:useBean>

<%

	log.info("in browseSubjects.jsp." );

	fieldNames.add("criterion1");
	fieldNames.add("criterion2");
	fieldNames.add("criterion2_value");

        %><%@ include file="/web/common/getFieldValues.jsp" %><%
	
	Isbra.Subject[] mySubjects = null;
	int numRows = 0;

	String whichSubmit = (String)request.getParameter("whichSubmit");
        log.debug("whichSubmit = " + whichSubmit);

	String action = (String)request.getParameter("action"); 
        log.debug("action = " + action);

	if ((whichSubmit != null && whichSubmit.equals("selectmenu")) || 
		(action != null && action.equals("Find Subjects"))) {
		
		if (action != null && action.equals("Find Subjects")) {

                	//
                	// Fill up the attributes HashMap 
                	//
			Hashtable attributes = new Hashtable(); 
			String criterion1 = (String) fieldValues.get("criterion1");
			String criterion2 = (String) fieldValues.get("criterion2");

                	if (criterion1 != null && !criterion1.equals("")) {
                        	attributes.put("center", criterion1);
                	}
                	if (criterion2 != null && !criterion2.equals("-99")) {
                        	attributes.put("question", criterion2 + "///" + (String) fieldValues.get("criterion2_value"));
                	}

			mySubjects = myIsbra.getSubjectsThatMatchCriteria(attributes, dbConn);
	
			if (mySubjects == null) {
				//Error - "No subjects"
				//session.setAttribute("errorMsg", "CHP-004");
				response.sendRedirect(commonDir + "errorMsg.jsp");
			} else {
				numRows = mySubjects.length;
			}
		}
	} else if ((action != null) && (action.equals("Add Subject(s)") || action.equals("Create Group"))) {
		log.debug("here adding subjects or creating groups");
		String[] checkedList = null;
                if (request.getParameter("subjectID") != null) {
			checkedList = request.getParameterValues("subjectID");
			log.debug("checkedList.length = "+checkedList.length); myDebugger.print(checkedList);
		}
		List subjectList = new ArrayList();

		if (action.equals("Add Subject(s)")) {

			int groupID = Integer.parseInt(request.getParameter("groupSelect"));
			//
			// Get all the subjects which the user selected and create group_subjects for 
			// each of them.  
			//
			log.debug("adding subjects to group "+groupID);

			mySessionHandler.createSessionActivity(session.getId(), 
                                        "Added "+ checkedList.length + " subjects to '" + 
                                        "' group. ", dbConn);

			for (int i=0; i<checkedList.length; i++) {
       	                 	myIsbra.createGroup_subjects(Integer.parseInt(checkedList[i]), groupID, dbConn);
			}
			//Success - "Subjects added"
			session.setAttribute("successMsg", "ISB-001");
			response.sendRedirect(commonDir + "successMsg.jsp");

		} else if (action.equals("Create Group")) {

			log.debug("group_name ="+ request.getParameter("group_name"));
	
			String group_name = request.getParameter("group_name");

                	if (myIsbra.groupNameExists(group_name, userID, dbConn)) {
                        	log.debug("group name already exists");
				//Error - "group exists"
                        	//session.setAttribute("errorMsg", "EXP-003");
                        	response.sendRedirect(commonDir + "errorMsg.jsp");
                	} else {
                        	log.debug("group name does not already exist");

                                int groupID = myIsbra.createIsbraGroup(group_name, userID, dbConn);

                                mySessionHandler.createSessionActivity(session.getId(), 
                                               	"Created a new ISBRA group called '" +
						group_name +  "'. It contains "+ checkedList.length + " subjects. ", dbConn);

				for (int i=0; i<checkedList.length; i++) {
       	                 		myIsbra.createGroup_subjects(Integer.parseInt(checkedList[i]), groupID, dbConn);
				}

				//Success - "Group created"
				session.setAttribute("successMsg", "ISB-002");
				response.sendRedirect(commonDir + "successMsg.jsp");
                	} 
		}
	}
	String formName = "browseSubjects.jsp";
	boolean loggedIn = true;

   
%>

<%@ include file="/web/common/gatewayHeader.html" %>

<script language="javascript" type="text/javascript">
	function setFormSubmitMarker(frm,valu) {
		frm.whichSubmit.value=valu;
	}
</script>


<%@ include file="formatBrowseSubjects.jsp" %>

<form method="post"
        action="browseSubjects.jsp"
        enctype="application/x-www-form-urlencoded"
        name="browseSubjects">
<%
	if ((action != null) && (action.equals("Find Subjects"))) {
		%> <%@ include file="formatSubjectResults.jsp" %> <% 
	}
	if (numRows > 0) {
        	%>
	        <BR>
		<table class=borderlessWide>
		<tr>
		<td width="30%">
			<b>Add selected subjects(s) to this group:</b> 
		</td><td width="60%">
		<%
        		Isbra.Group[] myIsbraGroups = myIsbra.getIsbraGroups(userID, dbConn);

        		optionHash = new LinkedHashMap();
        		optionHash.put("-99", "----- Select a Group -----");

        		for (int i=0; i<myIsbraGroups.length; i++) {
                		optionHash.put(Integer.toString(myIsbraGroups[i].getGroup_id()), myIsbraGroups[i].getGroup_name());
        		}

        		selectName = "groupSelect";
        		selectedOption = "-99";
			onChange = "";

        	%> 
		<%@ include file="/web/common/selectBox.jsp" %>

		</td><td width="10%">
			<input type="submit" name="action" value="Add Subject(s)" onClick="return IsSomethingCheckedOnForm(browseSubjects) && setFormSubmitMarker(this.form,'submitbutton')"> 
		</td>
		</tr>
		<tr> <td colspan=3>
		<BR>
		<b>OR</b>
		<BR>
		<BR>
		</td></tr>
		<tr>
		<td>
		<b>Create a new group:</b>
		</td><td>
			<table class=arrayNarrow>
			<tr>
				<th width="50%" class="arrayHdr">Group Name:<%=twoSpaces%> <TD><input type="text" name="group_name" size="40"  /></TD>
			</tr>
			</table>
		</td><td>
		<input type="submit" name="action" value="Create Group" onClick="return IsSomethingCheckedOnForm(browseSubjects)" >
		</td>
		</tr>
		</table>
		<%
	} 

%>
	<input type="hidden" name="whichSubmit" value="">
	</form>

<%@ include file="/web/common/footer.html" %> 
