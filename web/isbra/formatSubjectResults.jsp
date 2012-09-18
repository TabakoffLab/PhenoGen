<%--
 *  Author: Cheryl Hornbaker
 *  Created: May, 2007
 *  Description:  This formats the ISBRA subjects 
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%

	String subjectDetailsLink = "<a href='"+isbraDir + "subjectDetails.jsp?subjectID=";
	
	if (mySubjects.length == 0) {
		%> <h1>No Subjects Found </h1><% 
	} 
	%>
	<TABLE class=arrayWide>
	<TR>
        <td ><input type="checkbox" id="checkBoxHeader" onClick="checkUncheckAll(this.id, 'subjectID')"> Check/Uncheck All</td>

	<TH width="10%">Subject Identification Number</TH>

	</TR>
	<%
	for (int i=0; i<mySubjects.length;i++) {
		int subjectID = mySubjects[i].getSubject_id();
		%><TR><%
		// create a checkbox for the subjectID column to select the subject for
                // including in a group
                //
		%> <TD class=center><input type="checkbox" name="subjectID" value="<%=subjectID%>"></TD>

		<TD><%=subjectDetailsLink%><%=subjectID%>'><%=mySubjects[i].getCenter_name()%><%=twoSpaces%>
			<%=mySubjects[i].getSubject_identification_number()%></a></TD> 
		</TR>
		<%
	}
	%> </TABLE> 
