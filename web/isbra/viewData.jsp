<%--
 *  Author: Cheryl Hornbaker
 *  Created: May, 2007
 *  Description:  The web page created by this file allows the user to 
 *		select specific data fields to which the answers are displayed
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/common/session_vars.jsp"  %>

<jsp:useBean id="myIsbra" class="edu.ucdenver.ccp.PhenoGen.data.Isbra"> </jsp:useBean>

<%
	log.info("in answers.jsp. user =  "+ user);

	String action = (String)request.getParameter("action");
	
	%><%@include file="/web/isbra/groupSelect.jsp"%><%
	
	Isbra.Subject[] mySubjects = null;
	Isbra.Question[] myQuestions = null;
	String questionString = ""; 

	if (isbraGroupID != -99) {
		myQuestions = myIsbra.getQuestions("All", dbConn);
        	if ((action != null) && action.equals("View Data")) {
			log.debug("get Data");
			String[] questions = (String[]) request.getParameterValues("category");
			questionString = "(" + myObjectHandler.getAsSeparatedString(questions, ",") + ")";
			mySubjects = myIsbra.getSubjects(isbraGroupID, questionString, dbConn);
		}
	}
	
	String formName = "viewData.jsp";
%>

<%@ include file="/web/common/gatewayHeader.html" %>

<%@ include file="/web/isbra/formatGroupSelect.jsp" %>


<% if(isbraGroupID != -99) { %>
	<form	method="post" 
		action="viewData.jsp" 
		enctype="application/x-www-form-urlencoded"
		name="viewData">

		<BR>
		<center> 
		<span class="heading"> Select attributes for which you would like values</span><BR>
		(Select one or more entries by holding down the 'Ctrl' key while selecting.)
		<BR>
		<select name="category" size="10" multiple>
		<% 
		String previousCategoryName = "";
		for (int i=0; i<myQuestions.length; i++) {
			if (i==0) {
				%><OPTGROUP label="<%=myQuestions[i].getCategory_name()%>"><%
			} else if (myQuestions[i].getCategory_name().equals(previousCategoryName)) {
				%><option value="<%=myQuestions[i].getQuestion_id()%>"><%=myQuestions[i].getDescription()%></option><%
			} else { 
				%></OPTGROUP><OPTGROUP label="<%=myQuestions[i].getCategory_name()%>"><%
			}
			previousCategoryName = myQuestions[i].getCategory_name();
		}
		%>
		</OPTGROUP>
		</select>

		<BR><BR>
		<input type="submit" name="action" value="View Data" /> </center>
		<BR>
		<HR width=1000>
	<% if (action.equals("View Data")) { %>
		<TABLE class=list_base>	
		<TR>
		<TH>Subject Identification Number</TH>
		<%
		myQuestions = myIsbra.getQuestions(questionString, dbConn);
		for (int i=0; i<myQuestions.length; i++) {
			%><TH><%=myQuestions[i].getDescription()%></TH><%
		}
		%></TR><%
		for (int i=0; i<mySubjects.length; i++) { 
			List answersList = new ArrayList(mySubjects[i].getAnswers());
			Collections.sort(answersList);
			%>
			<TR>
			<TD>
			<a href="<%=isbraDir%>subjectDetails.jsp?subjectID=<%=mySubjects[i].getSubject_id()%>"><%=mySubjects[i].getCenter_name()%><%=twoSpaces%><%=mySubjects[i].getSubject_identification_number()%></a></TD>
			<% for (Iterator itr = answersList.iterator(); itr.hasNext();) { 
				Isbra.Answer answerObject = (Isbra.Answer) itr.next();
				String answer = answerObject.getValue(); 
				%>
				<TD><%=answer%></TD>
			<% } %>
			</TR>
		<% } %>
		</TABLE>
	<% } %>

	<input type="hidden" name="isbraGroupID" value="<%=isbraGroupID%>" /> 
	
	</form>
<% } %>

<%@ include file="/web/common/footer.html" %>
