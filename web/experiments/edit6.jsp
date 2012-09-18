<%--
 *  Author: Cheryl Hornbaker
 *  Created: May, 2010
 *  Description:  This file handles the multipart request from the edit5.jsp
 *	web page.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/experiments/include/experimentHeader.jsp"  %>

<%-- The FileHandler bean handles the multipart request containing the files to be uploaded.  --%>

<jsp:useBean id="thisFileHandler" class="edu.ucdenver.ccp.util.FileHandler" scope="request">
        <jsp:setProperty name="thisFileHandler" property="request"
                        value="<%= request %>" />
</jsp:useBean>

<%
	log.info("in edit6.jsp. user = " + user);

	int hybridID = -99;
	String tarray_designid = "";
	String hybrid_protocol_id = "";
	String hybrid_scan_protocol_id = "";
        String experimentUploadDir = userLoggedIn.getUserExperimentUploadDir();

	// This has to be called first, to setup the parameters
	// So upload the files to a temporary directory, and then once we
	// get the specific directory for an array, then copy them there
	// We can't get the specific directory til after we get the 
	// itemID

        log.debug("before call to uploadFiles");
	// Path must be set before calling uploadFiles
	try {
        	thisFileHandler.setPath(experimentUploadDir);
		thisFileHandler.uploadFiles();

		Vector parameterNames = thisFileHandler.getParameterNames(); 
		Vector parameterValues = thisFileHandler.getParameterValues(); 

		//
		// Parameters have to be parsed this way because the form
		// is multi-part/data
		//
		for (int i=0; i<parameterNames.size(); i++) {
			String nextParam = (String) parameterNames.elementAt(i);
			String nextParamValue = (String) parameterValues.elementAt(i);
                	hybridID = (nextParam.equals("itemID") ? Integer.parseInt(nextParamValue) : hybridID);
                	tarray_designid = (nextParam.equals("tarray_designid") ? nextParamValue : tarray_designid);
                	hybrid_scan_protocol_id = (nextParam.equals("hybrid_scan_protocol_id") ? nextParamValue : hybrid_scan_protocol_id);
                	hybrid_protocol_id = (nextParam.equals("hybrid_protocol_id") ? nextParamValue : hybrid_protocol_id);
		}

		log.debug("hybridID = "+ hybridID);
		log.debug("tarray_designid = "+ tarray_designid);
		log.debug("hybrid_protocol_id = "+ hybrid_protocol_id);

		Vector fileNames = thisFileHandler.getFilenames(); 
		Vector fileParameterNames = thisFileHandler.getFileParameterNames(); 

		for (int i=0; i<fileNames.size(); i++) {
			String nextParam = (String) fileParameterNames.elementAt(i);
			String nextFileName = (String) fileNames.elementAt(i);
			log.debug("nextFileName = "+nextFileName);

			if (nextParam.equals("file_name") && nextFileName != null && !nextFileName.equals("null") && !nextFileName.equals("")) {
				try {
                                        String answer = new Data_file().uploadDataFile(session, nextFileName, hybridID, selectedExperiment, dbConn);
                                        if (!answer.equals("")) {
                                                session.setAttribute("errorMsg", answer);
                                                response.sendRedirect(commonDir + "errorMsg.jsp");
                                                break;
                                        } else {
                                                mySessionHandler.createExperimentActivity("Uploaded CEL File:" + hybridID, dbConn);
                                        }
				} catch (Exception e) {
                                        mySessionHandler.createExperimentActivity("Got error updating hybridization information for array " + 
						hybridID, dbConn);
					//Error - "Unexpected error with file upload"
					session.setAttribute("errorMsg", "SYS-005");
			               	response.sendRedirect(commonDir + "errorMsg.jsp");
                                        //throw e;        
                                }               
                	}
		}
		try {
			//log.debug("myUpdateArray protocolID = "+myUpdatedArray.getHybrid_protocol_id());
			//log.debug("myUpdateArray scan protocolID = "+myUpdatedArray.getHybrid_scan_protocol_id());

                	edu.ucdenver.ccp.PhenoGen.data.Array myUpdatedArray =
                                new edu.ucdenver.ccp.PhenoGen.data.Array().getSampleDetailsForHybridID(hybridID, dbConn);
			myUpdatedArray.setTarray_designid(Integer.parseInt(tarray_designid));
			myUpdatedArray.setHybrid_protocol_id(Integer.parseInt(hybrid_protocol_id));
			myUpdatedArray.setHybrid_scan_protocol_id(Integer.parseInt(hybrid_scan_protocol_id));
			myUpdatedArray.setHybrid_id(hybridID);
        		myUpdatedArray.updateHybridizationStuff(myUpdatedArray, userLoggedIn, dbConn);
			mySessionHandler.createExperimentActivity("Updated hybridization information for array " + hybridID, 
						dbConn);
			//Success - "Array Updated"
			session.setAttribute("successMsg", "EXP-042");
			response.sendRedirect(commonDir + "successMsg.jsp");
		} catch (SQLException e) {
			mySessionHandler.createExperimentActivity("Got SQLException updating hybridization information for array " + hybridID, 
						dbConn);
			}
	} catch (IOException e) {
		log.debug("got exception in edit6 while uploading file", e); 
		//Error - "Unexpected error with file upload"
		session.setAttribute("errorMsg", "SYS-005");
		response.sendRedirect(commonDir + "errorMsg.jsp");
	}
%>

