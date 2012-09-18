<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  The web page created by this file displays a message that 
 *	is set by the calling module.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/common/session_vars.jsp" %>

<%	
	String successMsg = (String) session.getAttribute("successMsg");

	log.info("In successMsg.jsp.  successMsg = "+successMsg);

	//String homePage = "<a href=" + commonDir + "startPage.jsp>Home</a>";

	//String msg = (successMsg != null && !successMsg.equals("") ? 
	//		myMessage.getMessage(successMsg, dbConn) : "");

	//String additionalInfo = ((String) session.getAttribute("additionalInfo") != null ?
	//			(String) session.getAttribute("additionalInfo") : "");
	
	//msg = msg + "  " + additionalInfo + "<BR><BR>" + homePage;

	//session.setAttribute("additionalInfo", "");
	//log.debug("caller is "+caller);
	response.sendRedirect(caller);


%>
