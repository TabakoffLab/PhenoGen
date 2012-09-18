<%--
 *  Author: Cheryl Hornbaker
 *  Created: July, 2006
 *  Description:  This file handles the multipart request from the uploadPhenotype.jsp
 *	web page.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/analysisHeader.jsp"  %>

<%-- The FileHandler bean handles the multipart request containing the files to be uploaded.  --%>

<jsp:useBean id="thisFileHandler" class="edu.ucdenver.ccp.util.FileHandler" >
        <jsp:setProperty name="thisFileHandler" property="request"
                        value="<%= request %>" />
</jsp:useBean>

<%
	log.info("in uploadPhenotype2.jsp. user = " + user);

        String timedFunctionMasking = "Masking.Missing.Strains";
        int num_probes = 45000;

	String description = "";
	String phenotypeName = "";
	String goingToRenormalize = "";
	String callingForm = "";
	String includeVariance = "F";
	edu.ucdenver.ccp.PhenoGen.data.Array[] myArrays = null;

	String versionType = "";
	String uploadDir = userLoggedIn.getUserDatasetUploadDir(); 

        log.debug("before call to uploadFiles. uploadDir = "+uploadDir);
	// Path must be set before calling uploadFiles
        thisFileHandler.setPath(uploadDir);
	thisFileHandler.uploadFiles();

	Vector parameterNames = thisFileHandler.getParameterNames(); 
	Vector parameterValues = thisFileHandler.getParameterValues(); 
	Vector fileNames = thisFileHandler.getFilenames(); 
	Vector fileParameterNames = thisFileHandler.getFileParameterNames(); 

	Hashtable durationHash = (Hashtable) session.getAttribute("durationHash");
	//
	// Parameters have to be parsed this way because the form
	// is multi-part/data
	//
	//log.debug("fileNames = ");myDebugger.print(fileNames); 
	boolean uploadingFile = ((fileNames.size() > 0 && 
					fileNames.elementAt(0) != null &&
					!((String) fileNames.elementAt(0)).equals("null") &&
					!((String) fileNames.elementAt(0)).equals("")) ? true : false);
	log.debug("fileNames = " + (String) fileNames.elementAt(0));
	log.debug("uploadingFile = "+uploadingFile);
	//log.debug("fileName = XXX"+ fileNames.elementAt(0) + "XXX");
	List<String> groupNumberList = new ArrayList<String>();
	Hashtable<String,String> groupMeanList = new Hashtable<String,String>();
	Hashtable<String,String> groupVarianceList = new Hashtable<String,String>();
log.debug("number of parameters = "+parameterNames.size());
	for (int i=0; i<parameterNames.size(); i++) {
		String nextParam = (String) parameterNames.elementAt(i);
		String nextParamValue = (String) parameterValues.elementAt(i);
//log.debug("i = " + i + ", param = "+nextParam + ", value = "+nextParamValue);
		if (nextParam.equals("description")) {  
			description = nextParamValue.trim(); 
		} else if (nextParam.equals("phenotypeName")) {  
			phenotypeName = nextParamValue; 
		} else if (nextParam.equals("callingForm")) {  
			callingForm = nextParamValue; 
		} else if (nextParam.equals("goingToRenormalize")) {  
			goingToRenormalize = nextParamValue; 
		} else if (nextParam.equals("showVariance")) {  
			log.debug("showVariance = "+nextParamValue);
			if (nextParamValue.equals("on")) {
				includeVariance = "T";
			}
		}
		if (!uploadingFile) {
			nextParam = nextParam.replaceAll("SLASH", "/");
			if (nextParam.indexOf("MEAN") > -1) {  
				groupMeanList.put(nextParam, nextParamValue);
			}
			if (nextParam.indexOf("VARIANCE") > -1) {  
				groupVarianceList.put(nextParam, nextParamValue);
			}
		}
	}
	//log.debug("includeVariance = "+includeVariance);
	//log.debug("description = "+ description);
	//log.debug("phenotypeName = "+ phenotypeName);
	//log.debug("goingToRenormalize = "+ goingToRenormalize);
	//log.debug("callingForm = "+ callingForm);
	//log.debug("parameterGroupID in uploadPhenotype2 is "+parameterGroupID);
	//log.debug("groupMeanList = "); myDebugger.print(groupMeanList);
	//log.debug("groupVarianceList = "); myDebugger.print(groupVarianceList);
	//log.debug("uploadingFile = "+ uploadingFile);

	//
	// make sure the phenotype data name is unique
	//
	if (myParameterValue.checkPhenotypeNameExists(phenotypeName, userID, selectedDatasetVersion, dbConn)) { 
			//Error - "Phenotype name exists"
			session.setAttribute("errorMsg", "EXP-010");
                	response.sendRedirect(commonDir + "errorMsg.jsp");
        } else {
		int newParameterGroupID = 
			myParameterValue.copyMasterParameters(selectedDataset.getDataset_id(), 
						selectedDatasetVersion.getVersion(), dbConn);
		log.debug("just copied master parameters with newParameterGroupID ="+newParameterGroupID);
		myParameterValue.setCreate_date();

		myParameterValue.setParameter_group_id(newParameterGroupID);
                myParameterValue.setCategory("Phenotype Data");
                myParameterValue.setParameter("User ID");
                myParameterValue.setValue(Integer.toString(userID));
                myParameterValue.createParameterValue(dbConn);

                myParameterValue.setParameter_group_id(newParameterGroupID);
                myParameterValue.setCategory("Phenotype Data");
                myParameterValue.setParameter("Name");
                myParameterValue.setValue(phenotypeName);
                myParameterValue.createParameterValue(dbConn);

                myParameterValue.setParameter_group_id(newParameterGroupID);
                myParameterValue.setCategory("Phenotype Data");
                myParameterValue.setParameter("Description");
                myParameterValue.setValue(description);
                myParameterValue.createParameterValue(dbConn);
		log.debug("just created phenotype parameters with newParameterGroupID ="+newParameterGroupID);

        	Hashtable<String, String> groupNames = new Hashtable<String, String>();
		// Entering new values or copying from existing
		if (!uploadingFile) {
			String phenotypeVals = "";
			String phenotypeDownloadVals = "";
			Dataset.Group[] myGroups = selectedDatasetVersion.getGroups(dbConn);
			for (int i=0; i<myGroups.length; i++) {
				String meanValue = (String) groupMeanList.get(myGroups[i].getGroup_name() + "_MEAN");
				String varianceValue = (String) groupVarianceList.get(myGroups[i].getGroup_name() + "_VARIANCE");
								
				//log.debug("masterPG = " + selectedDatasetVersion.getMasterParameterGroupID()); 
				String groupNumber = Integer.toString(myGroups[i].getGroup_number());
				//log.debug("groupNumber = "+groupNumber + ", meanValue = "+meanValue + ", varianceValue = "+varianceValue);
				if (meanValue != null && !meanValue.equals("")) {
					groupNumberList.add(groupNumber);

					log.debug("meanValue for "+myGroups[i].getGroup_name()+" is "+meanValue);
					//log.debug("varianceValue for "+myGroups[i].getGroup_name()+" is "+varianceValue);
					myParameterValue.setParameter_group_id(newParameterGroupID);
                               		myParameterValue.setCategory("Phenotype Group Value");
                               		myParameterValue.setParameter(groupNumber);
                               		myParameterValue.setValue(meanValue);
                               		myParameterValue.createParameterValue(dbConn);

					if (varianceValue != null && !varianceValue.equals("")) {
                               			myParameterValue.setCategory("Phenotype Variance Value");
                               			myParameterValue.setParameter(groupNumber);
                               			myParameterValue.setValue(varianceValue);
                               			myParameterValue.createParameterValue(dbConn);
					}
		
       	                        	//
                                	//Start with the group name and the value
                                	//
					String row = myGroups[i].getGroup_name().replaceAll(" ", "_") + "\t" + meanValue +
						(includeVariance.equals("T") ? "\t" + (varianceValue !=null && !varianceValue.equals("") ? varianceValue : "NA") : "");

                                	//
                                	// The first time through, don't add the delimiter
                                	//

                                	if (phenotypeVals.equals("")) {
                                		phenotypeVals = groupNumber + "\t" + row;
                                	} else {
						phenotypeVals = phenotypeVals + "\n"+
                                				groupNumber + "\t" + row;
                                	}
					String downloadRow = myGroups[i].getGroup_name() + "\t" + meanValue + 
						(includeVariance.equals("T") ? "\t" + (varianceValue !=null && !varianceValue.equals("") ? varianceValue : "NA") : "");

                                	if (phenotypeDownloadVals.equals("")) {
                                		phenotypeDownloadVals = downloadRow;
                                	} else {
						phenotypeDownloadVals = phenotypeDownloadVals + "\n" +
                                				downloadRow;
                                	}
					groupNames.put(groupNumber, myGroups[i].getGroup_name());
				}
			}
        		if (groupNumberList.size() < 3) {
				log.debug("less than 3 groups have data, so sending error message EXP-027");
                		//Error - "Only 2 groups have data
				session.setAttribute("errorMsg", "EXP-027");
                        	response.sendRedirect(commonDir + "errorMsg.jsp");
			}
			log.debug("just created group parameters with newParameterGroupID ="+newParameterGroupID);
			log.debug("expected duration for " + timedFunctionMasking + "= "+
                					durationHash.get(timedFunctionMasking));

			//
			// Needs to be set prior to calling runPhenotypePrograms
			//
        		String phenotypeOrigFileName = "";
                	%><%@ include file="/web/datasets/include/runPhenotypePrograms.jsp" %><%

			mySessionHandler.createDatasetActivity("Created phenotype", dbConn);
		} else {
			// uploading a file
			for (int i=0; i<fileNames.size(); i++) {
				String nextParam = (String) fileParameterNames.elementAt(i);
				String nextFileName = (String) fileNames.elementAt(i);
				log.debug("nextFileName = "+nextFileName);

				if (nextParam.equals("filename")) {
					int numberOfLines = 0;
                        		String phenotypeFileName = uploadDir + nextFileName;
					File phenotypeFile = new File(phenotypeFileName);
					log.debug("phenotypeFileName = "+phenotypeFileName);
					// 
					// If the length of the file that was created on the server is 0,
					// the remote file must not have existed.
					//
					if (phenotypeFile.length() == 0) {
						phenotypeFile.delete();	
						//Error - "File does not exist"
						session.setAttribute("errorMsg", "GL-002");
			                	response.sendRedirect(commonDir + "errorMsg.jsp");
					} else {
						boolean thereIsAProblem = false;
	                        		String phenotypeOrigFileName = nextFileName;
						log.debug("phenotypeOrigFileName = "+phenotypeOrigFileName);

                        			String [] fileContents = new FileHandler().getFileContents(phenotypeFile);
			                	String phenotypeVals = "";
			                	String phenotypeDownloadVals = "";
						Set uploadedGroupNames = new TreeSet();

                        			for (int j=0; j<fileContents.length; j++) {
                                			String[] fields = fileContents[j].split("\\t");
                                			if (fields !=null && fields.length > 0) {
								//log.debug("fields[0]="+fields[0]);
								if (!callingForm.equals("calculateQTLs") && fields.length > 2) {
									log.debug("file contains more than 2 columns");
									thereIsAProblem = true;
									//Error - "File contains more than 2 columns"
									session.setAttribute("errorMsg", "EXP-033");
									break;
								} else if (callingForm.equals("calculateQTLs") && fields.length > 3) {
									log.debug("file contains more than 3 columns");
									thereIsAProblem = true;
									//Error - "File contains more than 3 columns"
									session.setAttribute("errorMsg", "EXP-034");
									break;
								}
								if (uploadedGroupNames.contains(fields[0])) {
									log.debug("file contains group more than once");
									thereIsAProblem = true;
									//Error - "File contains group more than once"
									session.setAttribute("errorMsg", "EXP-031");
									break;
								} 
								// Make sure the value is a number
								if (fields.length > 1 && fields[1] != null && !fields[1].equals("")) {
									try {
										//log.debug("fields[1]="+fields[1]); 
										Double test = Double.parseDouble(fields[1]);
										if (fields.length > 2 && fields[2] != null && !fields[2].equals("")) {
											log.debug("fields[2]="+fields[2]);
											test = Double.parseDouble(fields[2]);
										}
									} catch (Exception e) {
										log.debug("value is not a number");
										thereIsAProblem = true;
										//Error - "File contains non-numeric value for a group
										session.setAttribute("errorMsg", "EXP-032");
										break;
									}
									uploadedGroupNames.add(fields[0]);
									if (fields.length > 2) {
										includeVariance = "T";
									}
									//log.debug("thereIsAProblem = "+thereIsAProblem);
                                        				String groupNumber = myParameterValue.getGroupNumber(
												selectedDataset.getDataset_id(), 
												selectedDatasetVersion.getVersion(), 
												fields[0], dbConn);
									//log.debug("groupNumber retrieved for this label "+fields[0] +
									//		" is "+ groupNumber);
                                        				if (!groupNumber.equals("None")) {
										groupNumberList.add(groupNumber);

                                                				myParameterValue.setParameter_group_id(newParameterGroupID);
                                                				myParameterValue.setCategory("Phenotype Group Value");
                                                				myParameterValue.setParameter(groupNumber);
                                                				myParameterValue.setValue(fields[1].trim());
                                                				myParameterValue.createParameterValue(dbConn);
										if (fields.length > 2 && fields[2] != null && !fields[2].equals("")) {
                                                					myParameterValue.setCategory("Phenotype Variance Value");
                                                					myParameterValue.setParameter(groupNumber);
                                                					myParameterValue.setValue(fields[2].trim());
                                                					myParameterValue.createParameterValue(dbConn);
										}

										groupNames.put(groupNumber, fields[0].trim());
				                                		//
				                                		//Start with the group name and the value
                               				 			//
				                                		String row = fields[0].replaceAll(" ", "_") + "\t" + fields[1] + 
											(includeVariance.equals("T") ? 
												(fields.length > 2 && fields[2] !=null && !fields[2].equals("") ? 
												"\t" + fields[2] : "\tNA") : "");

				                                		//
                               				 			// The first time through, don't add the delimiter
				                                		//

                               				 			if (phenotypeVals.equals("")) {
				                                        		phenotypeVals = groupNumber + "\t" + row;
                               				 			} else {
				                                        		phenotypeVals = phenotypeVals + "\n"+
				                                                        		groupNumber + "\t" + row;
                               				 			}

				                                		String downloadRow = fields[0] + "\t" + fields[1] +
											(includeVariance.equals("T") ? 
												(fields.length > 2 && fields[2] !=null && !fields[2].equals("") ? 
												"\t" + fields[2] : "\tNA") : "");
                               				 			if (phenotypeDownloadVals.equals("")) {
				                                        		phenotypeDownloadVals = downloadRow;
                               				 			} else {
				                                        		phenotypeDownloadVals = phenotypeDownloadVals + "\n" +
				                                                        		downloadRow;
                               				 			}
                                        				}
								} 
                                			}
                        			}
						if (thereIsAProblem) {
							log.debug("there is a problem with the uploaded file");
                        				myParameterValue.deleteParameterValues(newParameterGroupID, dbConn);
                					response.sendRedirect(commonDir + "errorMsg.jsp");
						} else {
							//log.debug("groupNames is this: "); myDebugger.print(groupNames);
							log.debug("expected duration for " + timedFunctionMasking + "= "+
                							durationHash.get(timedFunctionMasking));

							formName = "uploadPhenotype2.jsp";

                					%><%@ include file="/web/datasets/include/runPhenotypePrograms.jsp" %><%
						}
					}
				}
			}
			mySessionHandler.createDatasetActivity("Uploaded phenotype file", dbConn);
		}
	}
%>
