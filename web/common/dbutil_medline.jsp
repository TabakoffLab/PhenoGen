<%--
 *  Author: Cheryl Hornbaker
 *  Created: April, 2005
 *  Description:  Establish a connection with the Medline database.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<jsp:useBean id="myMdlnErrorEmail" class="edu.ucdenver.ccp.PhenoGen.web.mail.Email"> </jsp:useBean>

<%
	/* see if we have a connection in the session */
	Connection mdlnConn = (Connection)session.getAttribute("mdlnConn");

	if (mdlnConn == null || mdlnConn.isClosed()) {
		log.debug("mdlnConn is null or closed.  Trying to open it");

		try {
			mdlnConn = new PropertiesConnection().getConnection(propertiesDir + "halMdlnProd.properties");
			//
			// save newly created connection in the session 
			//
			session.setAttribute("mdlnConn", mdlnConn);
			log.debug("mdlnConn successfully opened.");
		} catch (Exception e) {
			log.error("mdlnConn was not successfully opened. Sending email to phenogen.help");
                        myMdlnErrorEmail.setSubject("Mdln Database is Unavailable");
                        myMdlnErrorEmail.setContent("The Mdln connection is unavailable.");
                        try {
                        	myMdlnErrorEmail.sendEmailToAdministrator();
                        } catch (Exception error) {
                                log.error("exception while trying to send message to phenogen.help about mdlnConn connection", error);
                        }
		}
	} else {
		log.debug("mdlnConn is already open");
	}
%>
