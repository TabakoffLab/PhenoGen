<%--
 *  Author: Cheryl Hornbaker
 *  Created: May, 2007
 *  Description:  This file performs the logic neccessary for selecting a group.
 *
 *  Todo:
 *  Modification Log:
 *
--%>

<%

	if ((String) request.getParameter("isbraGroupID") != null) {
                isbraGroupID = Integer.parseInt((String)request.getParameter("isbraGroupID"));
        } else {
		isbraGroupID = -99;
	}

	log.debug("in groupSelect. action = " + action + ", isbraGroupID = " + isbraGroupID);

	String groupSelect = "None"; 
	if ((action != null) && action.equals("Go")) {
		groupSelect = (String) request.getParameter("groupSelect");
		isbraGroupID = Integer.parseInt(groupSelect);
	}
	
	String groupName = "";
	if (isbraGroupID != -99) {

		selectedGroup = myIsbra.getIsbraGroup(isbraGroupID, dbConn);

		groupName = selectedGroup.getGroup_name();
		session.setAttribute("isbraGroupID", Integer.toString(isbraGroupID));
        	session.setAttribute("selectedGroup", selectedGroup);

	}
 
%>

