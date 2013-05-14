<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  Establish a connection with the PhenoGen database.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%><jsp:useBean id="myDbConnErrorEmail" class="edu.ucdenver.ccp.PhenoGen.web.mail.Email"/><%
	/* see if we have a connection in the session */
	Connection dbConn = (Connection)session.getAttribute("dbConn");
	boolean dbConnAvailable = true;

	if (dbConn == null || dbConn.isClosed()) {
		log.debug("dbConn is null or closed.  Trying to open it");
		//log.debug("dbutil dbPropertiesfile = "+dbPropertiesFile);

		if (dbPropertiesFile != null) {
			try {
				dbConn = new PropertiesConnection().getConnection(dbPropertiesFile);
				/* save newly created connection in the session */
				session.setAttribute("dbConn", dbConn);

				Properties myProperties = new Properties();
				File myPropertiesFile = new File(dbPropertiesFile);
				myProperties.load(new FileInputStream(myPropertiesFile));
				session.setAttribute("oracleSID", myProperties.getProperty("ORACLE_SID"));
				session.setAttribute("oracleUser", myProperties.getProperty("USER"));
				log.debug("successfully opened dbConn");
			} catch (Exception e) {
				log.error("dbConn was not successfully opened.  Sending email to phenogen.help", e);
				dbConnAvailable = false;
                        	myDbConnErrorEmail.setSubject("PhenoGen Database is Unavailable");
                        	myDbConnErrorEmail.setContent("The PhenoGen database connection is unavailable.");
                        	try {
                        		myDbConnErrorEmail.sendEmailToAdministrator("Spencer.Mahaffey@ucdenver.edu");
                        	} catch (Exception error) {
                                	log.error("exception while trying to send message to phenogen.help about phenogen db connection", error);
                        	}
			}
		} else {
			log.debug("*** dbPropertiesFile is null or session must be inactive. *** ");
		}
	} else {
		//log.debug("*** dbConn is already open *** ");
	}
%>
