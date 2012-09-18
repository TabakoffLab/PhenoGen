<%--
 *  Author: Cheryl Hornbaker
 *  Created: Sep, 2008
 *  Description:  The web page created by this file displays an error message that 
 *	the login information is incorrect
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/access/include/login_vars.jsp" %>

<%	
        String loginErrorMsg = (session.getAttribute("loginErrorMsg") != null ? (String) session.getAttribute("loginErrorMsg") : "");

	log.info("In loginError.jsp.  loginErrorMsg = "+loginErrorMsg);
	log.debug("caller = "+caller);

	String previousPage = "<a href='" + caller + "'>Previous Page</a>";
	String link = "<a href=\"" + contextRoot + "index.jsp\">";
	String msg = (loginErrorMsg.equals("Invalid") ? 
			"Invalid username/password combination. Please try again." :
				(loginErrorMsg.equals("Expired") ? 
				"Due to inactivity, your session has expired.  You must login again." : ""));
	formName ="loginError.jsp";
	actionForm=formName;

	%><%
%> 

<%@ include file="/web/common/basicHeader.jsp" %> 
                        	<h2>Error:<%=twoSpaces%><%=msg%> </h2>

<%@ include file="/web/access/include/loginBox.jsp" %> 

	<%@ include file="/web/common/basicFooter.jsp" %>
