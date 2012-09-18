<%--
 *  Author: Cheryl Hornbaker
 *  Created: May, 2007
 *  Description:  This file creates a web page that displays detailed information 
 *	about a subject.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/common/session_vars.jsp"  %>

<jsp:useBean id="myIsbra" class="edu.ucdenver.ccp.PhenoGen.data.Isbra"> </jsp:useBean>

<%
	int subjectID = -99;
	if ((String)request.getParameter("subjectID") != null) {
        	subjectID = Integer.parseInt((String)request.getParameter("subjectID"));
	}

	log.info("in subjectDetails.jsp. subjectID = "+subjectID); 
	Isbra.Subject[] mySubject = myIsbra.getSubject(subjectID, dbConn);
	Isbra.Category[] myCategories = myIsbra.getIsbraCategories(dbConn);

%>

<%@ include file="/web/common/gatewayHeader.html" %>

	<a name="Top"></a>
	<TABLE class=list_base>	
		<TR><TD colspan=2>
		<% 
		for (int i=0; i<myCategories.length; i++) {
			%><a href="#<%=myCategories[i].getCategory_name()%>"><%=myCategories[i].getCategory_name()%></a><%=twoSpaces%> <%	
		}
		%></TD></TR><%
		Set myAnswers = new TreeSet(mySubject[0].getAnswers());
		String previousCategory = "X";
		for (Iterator itr = myAnswers.iterator(); itr.hasNext();) { 
			Isbra.Answer answerObject = (Isbra.Answer) itr.next();
			String category = answerObject.getQuestion().getCategory_name();
			String question = answerObject.getQuestion().getDescription();
			String answer = answerObject.getValue();
			
			%>
			<TR>
			<% if (!category.equals(previousCategory)) { %>
				<TD colspan=2><hr></TD></TR>
				<TR><TH class=center><a name="<%=category%>"><%=category%></a></TH>
				<TD colspan=2 class=right><a href="#Top">Top</a></TD>
			<% } else { %>
				<TH><%=question%></TH>
				<TD><%=answer%></TD>
			<% } %>
			</TR>
			<% 
			previousCategory = category;
		} %>
	</TABLE>
<%@ include file="/web/common/footer.html" %>
