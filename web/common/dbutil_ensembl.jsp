<%--
 *  Author: Cheryl Hornbaker
 *  Created: September, 2006
 *  Description:  Establish a connection with the Ensembl MySQL database.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<jsp:useBean id="myEnsemblErrorEmail" class="edu.ucdenver.ccp.PhenoGen.web.mail.Email"> </jsp:useBean>

<%
	//
	// see if we have a connection in the session 
	//
	Connection ensemblConn = (Connection)session.getAttribute("ensemblConn");
	if (selectedGeneList.getOrganism().equals("Dm")) {
		ensemblConn = null;
	}
	if ((ensemblConn == null || ensemblConn.isClosed()) && 
		(selectedGeneList.getOrganism().equals("Mm") ||
		selectedGeneList.getOrganism().equals("Rn") ||
		selectedGeneList.getOrganism().equals("Hs"))) {
		log.debug("ensemblConn is null or isClosed.  Trying to open it");

		File myPropertiesFile = new File(propertiesDir + 
						(selectedGeneList.getOrganism().equals("Mm") ? "ensemblMouse.properties" :
        						(selectedGeneList.getOrganism().equals("Rn") ? "ensemblRat.properties" :
        							(selectedGeneList.getOrganism().equals("Hs") ? "ensemblHuman.properties" : ""))));
		try {
			ensemblConn = new PropertiesConnection().getConnection(myPropertiesFile);
			//
			// save newly created connection in the session 
			//
			session.setAttribute("ensemblConn", ensemblConn);
			log.debug("ensemblConn successfully opened.");
		} catch (Exception e) {
			log.error("ensemblConn was not successfully opened. Sending email to phenogen.help");
                        myEnsemblErrorEmail.setSubject("Ensembl Database is Unavailable");
                        myEnsemblErrorEmail.setContent("The Ensembl connection is unavailable.");
                        try {
                        	myEnsemblErrorEmail.sendEmailToAdministrator("Spencer.Mahaffey@ucdenver.edu");
                        } catch (Exception error) {
                                log.error("exception while trying to send message to phenogen.help about ensembl lab connection", error);
                        }
		}
	}

%>


