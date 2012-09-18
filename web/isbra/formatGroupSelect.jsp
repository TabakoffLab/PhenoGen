<%--
 *  Author: Cheryl Hornbaker
 *  Created: May, 2007
 *  Description:  This file formats the groups in the drop down list.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<script language="JAVASCRIPT" type="text/javascript">
	function IsGroupSelectionFormComplete(){
		if ((document.groupSelect.groupSelect.value == 'None') || 
			(document.groupSelect.groupSelect.value == '')) {

			alert('You must select a valid group before proceeding.');
			document.groupSelect.groupSelect.focus();
			return false;
		}
		return true;
	}
</script>

                                                                                                                  
<%
	Isbra.Group[] myIsbraGroups = myIsbra.getIsbraGroups(userID, dbConn);
	log.debug("numGrousp = "+myIsbraGroups.length);
%>

<BR>
	<form   method="post"
        	action="<%=formName%>"
        	enctype="application/x-www-form-urlencoded"
        	onSubmit="return IsGroupSelectionFormComplete()"
        	name="groupSelect">

	<TABLE class="borderlessTableWide">
	<TR>
<%

	Isbra.Group thisGroup = null;
	if (isbraGroupID != -99) {
		thisGroup = myIsbra.getIsbraGroup(isbraGroupID, dbConn);
	}
        if (isbraGroupID != -99) {
		%><TD width="50%"><%
                %> <%@ include file="displayGroup.jsp" %> <%
		%></TD> <TD class="right"> <%
	}
%>

	<%
                optionHash = new LinkedHashMap();
		if (isbraGroupID != -99) {
        		optionHash.put("None", "---------- Select a new group ----------"); 
		} else {
			optionHash.put("None", "---------- Select a group  ----------");
		}

                for (int i=0; i<myIsbraGroups.length; i++) {
                        optionHash.put(myIsbraGroups[i].getGroup_id() == -99 ? "None" : Integer.toString(myIsbraGroups[i].getGroup_id()), 
					myIsbraGroups[i].getGroup_name());
                }

                selectName = "groupSelect";

                %> <%@ include file="/web/common/selectBox.jsp" %>

		<%=twoSpaces%> <input type="submit" name="action" value="Go" >


	</TD>
</TR></TABLE>
	
</form>

