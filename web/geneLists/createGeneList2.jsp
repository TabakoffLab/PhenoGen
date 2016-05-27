<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  This file handles the multipart request from the uploadGeneList.jsp
 *	web page.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/common/anon_session_vars.jsp" %>

<%-- The FileHandler bean handles the multipart request containing the files to be uploaded.  --%>

<jsp:useBean id="thisFileHandler" class="edu.ucdenver.ccp.util.FileHandler" >
        <jsp:setProperty name="thisFileHandler" property="request"
                        value="<%= request %>" />
</jsp:useBean>

<jsp:useBean id="myGeneList" class="edu.ucdenver.ccp.PhenoGen.data.GeneList" > </jsp:useBean>
<jsp:useBean id="myErrorEmail" class="edu.ucdenver.ccp.PhenoGen.web.mail.Email"> </jsp:useBean>
<jsp:useBean id="myAnonGeneList" class="edu.ucdenver.ccp.PhenoGen.data.AnonGeneList"/>
<jsp:useBean id="anonU" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser" scope="session" />

<%
	log.info("in createGeneList2.jsp. user = " + user);

	String description = "";
	String organism = "";
	String gene_list_name = "";
	String inputGeneList = "";
	boolean manuallyEntered = false;

	//String additionalInfo = ""; 

        String geneListDir = userLoggedIn.getUserGeneListsUploadDir();
        if(userLoggedIn.getUser_name().equals("anon")){
            geneListDir=geneListDir+anonU.getUUID();
            File upDir=new File(geneListDir);
            if(!upDir.exists()){
                upDir.mkdirs();
            }
            geneListDir=geneListDir+"/";
                    
        }
        log.debug("upload geneList dir = "+geneListDir);

        log.debug("before call to uploadFiles");
        
	// Path must be set before calling uploadFiles
        thisFileHandler.setPath(geneListDir);
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
		if (nextParam.equals("description")) {  
			description = nextParamValue.trim(); 
		} else if (nextParam.equals("gene_list_name")) {  
			gene_list_name = nextParamValue; 
		} else if (nextParam.equals("inputGeneList") && !nextParamValue.equals("")) {  
			inputGeneList = nextParamValue.trim(); 
			manuallyEntered = true;
		} else if (nextParam.equals("organism")) {  
			organism = nextParamValue; 
		} else {
		}
	}
	log.debug("description = "+ description);
	log.debug("organism = "+ organism);

	//
	// make sure the gene list name is unique
	//
        boolean exists=false;
        if(userLoggedIn.getUser_name().equals("anon")){
            exists=myAnonGeneList.geneListNameExists(gene_list_name, anonU.getUUID() ,pool);
        }else{
            exists=myGeneList.geneListNameExists(gene_list_name, userID, pool);
        }
	if (exists) {
		//Error - "gene list name exists"
		session.setAttribute("errorMsg", "GL-006");
		session.setAttribute("gene_list_name", gene_list_name);
		session.setAttribute("description", description);
		session.setAttribute("organism", organism);
		session.setAttribute("inputGeneList", inputGeneList);
                response.sendRedirect(geneListsDir + "createGeneList.jsp?fromMain=Y");
	} else {
		int geneListID = -99;

		GeneList newGeneList = null;
                if(userLoggedIn.getUser_name().equals("anon")){
                    newGeneList=new AnonGeneList();
                    newGeneList.setCreated_by_user_id(-20);
                }else{
                    newGeneList=new GeneList();
                    newGeneList.setCreated_by_user_id(userID);
                }
		newGeneList.setGene_list_name(gene_list_name);	
		newGeneList.setDescription(description);
                
		newGeneList.setOrganism(organism);	
		newGeneList.setAlternateIdentifierSource("Current");	
		newGeneList.setAlternateIdentifierSourceID(-99);	

		if (manuallyEntered) {
                        newGeneList.setGene_list_source("Manually Entered");

                        TreeSet geneListSet = new TreeSet();
                        StringTokenizer tokenizer = new StringTokenizer(inputGeneList);
                        while(tokenizer.hasMoreTokens()) {
                            String token = tokenizer.nextToken();
                            //log.debug("token = " + token);
                            geneListSet.add(token);
                        }

                        ArrayList resultGeneList = new ArrayList(geneListSet);

                        geneListID = newGeneList.createGeneList(pool);
                        log.debug("geneListID = "+ geneListID);
                        
                        myGeneList.loadGeneListFromList(resultGeneList, geneListID, pool);
			additionalInfo = "";

                        mySessionHandler.createGeneListActivity(session.getId(), 
                                geneListID,
                                "Created Gene List by typing it in",
                                pool);
                       
                        if(userLoggedIn.getUser_name().equals("anon")){
                            anonU.linkGeneList(geneListID,pool);
                        }

                        log.debug("just loaded gene list into genes table");
			session.setAttribute("successMsg", "GL-013");
			session.setAttribute("selectedGeneList", newGeneList);
			response.sendRedirect(geneListsDir + "listGeneLists.jsp");
		} else {
			newGeneList.setGene_list_source("Uploaded File");	

			Vector fileNames = thisFileHandler.getFilenames(); 
			Vector fileParameterNames = thisFileHandler.getFileParameterNames(); 
			for (int i=0; i<fileNames.size(); i++) {
				String nextParam = (String) fileParameterNames.elementAt(i);
				String nextFileName = (String) fileNames.elementAt(i);
				log.debug("nextFileName = "+nextFileName);

				if (nextParam.equals("filename")) {
					int numberOfLines = 0;
                        		String geneListFileName = geneListDir + nextFileName;
					File geneListFile = new File(geneListFileName);
					log.debug("geneListFileName = "+geneListFileName);
					// 
					// If the length of the file that was created on the server is 0,
					// the remote file must not have existed.
					//
					if (geneListFile.length() == 0) {
						geneListFile.delete();	
//						newGlDir.delete();
						//Error - "File does not exist"
						session.setAttribute("errorMsg", "GL-002");
			                	response.sendRedirect(commonDir + "errorMsg.jsp");
					} else {
						log.debug("geneListOrigFileName = "+nextFileName);
						try {
							geneListID = newGeneList.loadFromFile(0,geneListFileName, pool); 
							log.debug("successfully uploaded gene list");
							additionalInfo = "The file "+
								nextFileName + 
								" has been <strong>successfully</strong> uploaded.<br>";
			                		mySessionHandler.createGeneListActivity(session.getId(), geneListID, 
												"Uploaded Gene List", pool);
                                                        if(userLoggedIn.getUser_name().equals("anon")){
                                                            anonU.linkGeneList(geneListID,pool);
                                                        }
							String genesNotFound = myGeneList.checkGenes(geneListID, pool);
							if (genesNotFound.length() > 0) {
								additionalInfo = additionalInfo + 
									"<BR>However, the following genes were not recognized in our database "+
									"for the organism you specified ("+organism+"):<BR><BR>"+
									genesNotFound.replaceAll("\n", "<BR>") +
									"<BR><BR>  (Note: The gene identifiers are case-sensitive) <BR><BR>"+
									"A message "+
									"has been sent to the administrator to investigate.";
                        					myErrorEmail.setSubject("Gene identifier(s) not found");
                        					myErrorEmail.setContent(userName + " tried to create or upload the following identifiers "+
											"which were not found by iDecoder for "+
												"the organism " + organism + ": \n\n" + 
												genesNotFound +
												"\n\n  The gene list ID is: "+geneListID);
                        					try {
                                					myErrorEmail.sendEmailToAdministrator(adminEmail);
                        					} catch (Exception error) {
                                					log.error("exception while trying to send message to phenogen.help about "+
											"genes not found by iDecoder", error);
                        					}
							}
							//Success -- file uploaded
							session.setAttribute("additionalInfo", additionalInfo);
							session.setAttribute("successMsg", "GL-013");
							session.setAttribute("selectedGeneList", newGeneList);
							session.removeAttribute("errorMsg");
							session.removeAttribute("gene_list_name");
							session.removeAttribute("description");
							session.removeAttribute("organism");
							session.removeAttribute("inputGeneList");
							response.sendRedirect(geneListsDir + "listGeneLists.jsp");
						} catch (SQLException e) {
							log.error("did not successfully upload gene list. e.getErrorCode() = " + e.getErrorCode());
			                		mySessionHandler.createGeneListActivity(session.getId(), geneListID, 
												"Got error uploading Gene List", pool);
							if (e.getErrorCode() == 1) {
			                        		log.debug("got duplicate entry error trying to insert genes record.");
								//Error - "Duplicate gene identifiers"
								session.setAttribute("errorMsg", "GL-003");
								response.sendRedirect(commonDir + "errorMsg.jsp");
			                		} else {
			                        		throw e;
                					}
						}
					}
                		}
			}
		}
	}
%>

