<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  Establish a connection to the MGI database.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<jsp:useBean id="myErrorEmail" class="edu.ucdenver.ccp.PhenoGen.web.mail.Email"> </jsp:useBean>

<%

	/* see if we have a connection in the session */
	Connection jacksonConn = (Connection)session.getAttribute("jacksonConn");

	if (jacksonConn == null || jacksonConn.isClosed()) {
		log.debug("jacksonConn is null or isClosed.  Trying to open it");

		try {
			jacksonConn = myPropertiesConnection.getConnection(propertiesDir + "jacksonMgd.properties");

			/* save newly created connection in the session */
			session.setAttribute("jacksonConn", jacksonConn);
			log.debug("jacksonConn successfully opened.");
		} catch (Exception e) {
			log.error("jacksonConn was not successfully opened. Sending email to phenogen.help");
			e.printStackTrace(System.out);
                        myErrorEmail.setSubject("Jackson Lab Database is Unavailable");
                        myErrorEmail.setContent("The MGI database connection is unavailable.");
                        try {
                        	myErrorEmail.sendEmailToAdministrator();
                        } catch (Exception error) {
                                log.error("exception while trying to send message to phenogen.help about jackson lab connection", error);
                        }
		}

	}

%>




