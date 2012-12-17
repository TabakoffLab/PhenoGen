<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  The web page created by this file displays an error message that 
 *	is set by the calling module.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/common/session_vars.jsp" %>

<jsp:useBean id="myEmail" class="edu.ucdenver.ccp.PhenoGen.web.mail.Email"> </jsp:useBean>

<%	
	loggedIn = false;

	if((String) session.getAttribute("userID") != null && 
		!((String) session.getAttribute("userID")).equals("-1")) { 
		loggedIn = true;
	} 
	
        String errorMsg = (String) session.getAttribute("errorMsg");
        String sendEmail = (String) session.getAttribute("sendEmail");

	log.info("In errorMsg.jsp.  errorMsg = "+errorMsg + ", caller = "+caller);

	if (errorMsg.startsWith("SYS") || (sendEmail != null && sendEmail.equals("YES"))) { 
        	myEmail.setSubject("User '"+ userName + 
			"' encountered system error '" + errorMsg +  
			"' on PhenoGen website"); 
		myEmail.setContent("System error " + errorMsg + " when on page "+caller);
		log.debug("Sending an email message notifying phenogen.help that an error has occurred.");
        	try {
        		myEmail.sendEmailToAdministrator(adminEmail);
			mySessionHandler.createSessionActivity(session.getId(), "Got system error:  " + errorMsg, dbConn);
        	} catch (Exception e) {
                	log.error("exception while trying to send message about an error on website", e);
        	}
        	session.setAttribute("sendEmail", "");
	}
	response.sendRedirect(caller);

%>
