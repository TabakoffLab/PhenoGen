<%--
 *  Author: Cheryl Hornbaker
 *  Created: Feb, 2010
 *  Description:  This file handles the multipart request from the uploadCELFiles.jsp
 *	web page.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/experiments/include/experimentHeader.jsp"  %>

<%-- The FileHandler bean handles the multipart request containing the files to be uploaded.  --%>

<jsp:useBean id="thisFileHandler" class="edu.ucdenver.ccp.util.FileHandler" scope="request" >
        <jsp:setProperty name="thisFileHandler" property="request"
                        value="<%= request %>" />
</jsp:useBean>

<%
	log.info("in uploadCELFiles2.jsp."); 

        String experimentUploadDir = userLoggedIn.getUserExperimentUploadDir();
        log.debug("experiment upload dir = "+experimentUploadDir);

        log.debug("before call to uploadFiles");
	// Path must be set before calling uploadFiles
	try {
        	thisFileHandler.setPath(experimentUploadDir);
		thisFileHandler.uploadFiles();

        	Vector parameterNames = thisFileHandler.getParameterNames();
        	Vector parameterValues = thisFileHandler.getParameterValues();
		log.debug("parameterName = "); myDebugger.print(parameterNames);
        	for (int i=0; i<parameterNames.size(); i++) {
                	String nextParam = (String) parameterNames.elementAt(i);
                	String nextParamValue = (String) parameterValues.elementAt(i);
                	action = (nextParam.equals("action") ? nextParamValue : action);
        	}

		Vector fileNames = thisFileHandler.getFilenames(); 
		Vector fileParameterNames = thisFileHandler.getFileParameterNames(); 

		log.debug("fileNames = "); myDebugger.print(fileNames);
		log.debug("fileParameterNames = "); myDebugger.print(fileParameterNames);

		String redirectString = experimentsDir + (action != null && action.equals("Next >") ? 
					"reviewExperiment" : "uploadCELFiles") +
					".jsp?experimentID=" + selectedExperiment.getExp_id();

	
		boolean thereIsAnError = false;
		for (int i=0; i<fileNames.size(); i++) {
			String nextParam = (String) fileParameterNames.elementAt(i);
			String nextFileName = (String) fileNames.elementAt(i);
			//log.debug("nextParam = "+nextParam + ", nextFileName = "+nextFileName);

			if (nextParam.endsWith("_file") && nextFileName != null && !nextFileName.equals("null") && !nextFileName.equals("")) {
				int hybridID = Integer.parseInt(nextParam.substring(0,nextParam.indexOf("_file")));

				try {
					String answer = new Data_file().uploadDataFile(session, nextFileName, hybridID, selectedExperiment, dbConn);
					if (!answer.equals("")) {
						thereIsAnError = true;
						//Error - "File name is not unique for experiment"
						session.setAttribute("errorMsg", answer);
						response.sendRedirect(redirectString);
						break;
					} else {
						mySessionHandler.createExperimentActivity("Uploaded CEL File:" + hybridID, dbConn); 
					}
				} catch (Exception e) {
					thereIsAnError = true;
					mySessionHandler.createExperimentActivity("Got error uploading CEL Files for " + 
							selectedExperiment.getExpName(), dbConn);
					throw e;
				}
                	}
		}

		//Success -- file uploaded
		if (!thereIsAnError) {
			if (redirectString.indexOf("reviewExperiment") > -1) {
				session.removeAttribute("successMsg");
			} else {
				session.setAttribute("successMsg", "EXP-041");
			}
			response.sendRedirect(redirectString);
		}
	} catch (IOException e) {
		log.debug("got exception in edit6 while uploading file", e); 
		//Error - "Unexpected error with file upload"
		session.setAttribute("errorMsg", "SYS-005");
		response.sendRedirect(commonDir + "errorMsg.jsp");
	}
%>

