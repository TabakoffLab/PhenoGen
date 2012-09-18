<%--
 *  Author: Cheryl Hornbaker
 *  Created: Feb, 2010
 *  Description:  This file handles the multipart request from the uploadSpreadsheet.jsp
 *	web page.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/experiments/include/experimentHeader.jsp"  %>

<%-- The FileHandler bean handles the multipart request containing the files to be uploaded.  --%>

<jsp:useBean id="thisFileHandler" class="edu.ucdenver.ccp.util.FileHandler" >
        <jsp:setProperty name="thisFileHandler" property="request"
                        value="<%= request %>" />
</jsp:useBean>

<%
	log.info("in uploadSpreadsheet2.jsp. user = " + user);

        String experimentUploadDir = userLoggedIn.getUserExperimentUploadDir();
        log.debug("experiment upload dir = "+experimentUploadDir);

        log.debug("before call to uploadFiles");
	// Path must be set before calling uploadFiles
        thisFileHandler.setPath(experimentUploadDir);
	try {
		thisFileHandler.uploadFiles();

		Vector fileNames = thisFileHandler.getFilenames(); 
		Vector fileParameterNames = thisFileHandler.getFileParameterNames(); 

		String[] messages;
		boolean errorFound = false;
		for (int i=0; i<fileNames.size(); i++) {
			String nextParam = (String) fileParameterNames.elementAt(i);
			String nextFileName = (String) fileNames.elementAt(i);
			log.debug("nextFileName = "+nextFileName);

			if (nextParam.equals("filename")) {
				log.debug("lastIndex = " + nextFileName.lastIndexOf("."));
				String expName = nextFileName.substring(0, nextFileName.lastIndexOf("."));
				log.debug("expName = "+expName);
				if (!expName.equals(selectedExperiment.getExpName())) {
					//Error - "File name does not match experiment name"
					session.setAttribute("errorMsg", "EXP-040");
					response.sendRedirect(commonDir + "errorMsg.jsp");
				} else {
                        		String expFileName = experimentUploadDir + nextFileName;
					File expFile = new File(expFileName);
					log.debug("expFileName = "+expFileName);
					// 
					// If the length of the file that was created on the server is 0,
					// the remote file must not have existed.
					//
					if (expFile.length() == 0) {
						expFile.delete();	
						//Error - "File does not exist"
						session.setAttribute("errorMsg", "GL-002");
						response.sendRedirect(commonDir + "errorMsg.jsp");
					} else {
						log.debug("expOrigFileName = "+nextFileName);
						try {
							//messages = new String[] {"blat"};
							messages = myExperiment.readSpreadsheet(new File(expFileName), userLoggedIn, dbConn);
                					for (int j=0; j<messages.length; j++) {
                        					if (messages[j].indexOf("ERROR") > -1) {
									errorFound = true;
									break;
								}
                					}
							String messageText = myObjectHandler.getAsSeparatedString(messages, "<BR>");
							session.setAttribute("screenSize", "big");
							session.setAttribute("additionalInfo", "<BR>" + messageText + "<BR>");
							if (errorFound) {
								session.setAttribute("errorMsg", "EXP-044");
			                			mySessionHandler.createExperimentActivity("Had problems uploading experiment spreadsheet for " + expFileName, dbConn);
								response.sendRedirect(commonDir + "errorMsg.jsp");
							} else {
								//Success -- file uploaded
								if (messageText.length() < 200) {
									session.removeAttribute("screenSize");
								}
								session.setAttribute("successMsg", "EXP-038");
			                			mySessionHandler.createExperimentActivity("Uploaded experiment spreadsheet for " + expFileName, dbConn);
								response.sendRedirect(experimentsDir + "uploadCELFiles.jsp?experimentID="+selectedExperiment.getExp_id());
							}
						} catch (Exception e) {
							log.debug("exception=", e);
							if (e.getClass() != null) {
								log.debug("e.getClass() = "+e.getClass().getName());
								if (e.getClass().getName().equals("java.sql.SQLException")) {
									log.error("did not successfully upload spreadsheet because of SQL Error. e.getErrorCode() = " + ((SQLException) e).getErrorCode());
									session.setAttribute("errorMsg", "EXP-046");
			                				mySessionHandler.createExperimentActivity("Got SQL error uploading experiment spreadsheet for " + expFileName, dbConn);
								} else if (e.getClass().getName().equals("jxl.read.biff.BiffException")) {
									log.error("did not successfully upload spreadsheet because of BiffException.");
									session.setAttribute("errorMsg", "EXP-045");
			                				mySessionHandler.createExperimentActivity("Got BiffException error uploading experiment spreadsheet for " + expFileName, dbConn);
								} else if (e.getClass().getName().equals("java.io.IOException")) {
									log.error("did not successfully upload spreadsheet because of IO Error.");
									session.setAttribute("errorMsg", "EXP-046");
			                				mySessionHandler.createExperimentActivity("Got IO error uploading experiment spreadsheet for " + expFileName, dbConn);
								} else if (e.getClass().getName().equals("edu.ucdenver.ccp.PhenoGen.data.DataException")) {
									log.error("did not successfully upload spreadsheet because of IO Error.");
									session.setAttribute("errorMsg", "EXP-046");
			                				mySessionHandler.createExperimentActivity("Got DataException error uploading experiment spreadsheet for " + expFileName, dbConn);
								} else {
									log.error("did not successfully upload spreadsheet because of General Error.");
									session.setAttribute("errorMsg", "EXP-046");
			                				mySessionHandler.createExperimentActivity("Got error uploading experiment spreadsheet for " + expFileName, dbConn);
								}
                						session.setAttribute("sendEmail", "YES");
								response.sendRedirect(commonDir + "errorMsg.jsp");
							} else {
								log.debug("e.getClass() is null");
							}
			                		//throw e;
						}
					}
				}
                	}
		}
	} catch (IOException e) {
  		log.error("did not successfully upload spreadsheet because of IO Error.", e);
                session.setAttribute("sendEmail", "YES");
                session.setAttribute("errorMsg", "EXP-046");
                mySessionHandler.createExperimentActivity("Got IO error uploading experiment spreadsheet for " + 
						selectedExperiment.getExp_description(), dbConn);
		response.sendRedirect(commonDir + "errorMsg.jsp");
	}
%>

