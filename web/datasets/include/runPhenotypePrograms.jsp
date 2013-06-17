<%--
 *  Author: Cheryl Hornbaker
 *  Created: Oct, 2007
 *  Description:  This file is included in other files to handle writing phenoData.txt and also run 2 R programs.
 *		phenotypeName, phenotypeVals, and groupNames must be initialized prior to including this
 *
 *  Todo:
 *  Modification Log:
 *
--%>


<%

        log.debug("in runPhenotypePrograms");

        String phenotypeHeader = "grp.number\t" + "grp.name\t" + "phenotype" + (includeVariance.equals("T") ? "\tvariance" : "") + "\n";
        phenotypeVals = phenotypeHeader + phenotypeVals + "\n";
        //log.debug("phenotypeVals = "+phenotypeVals);
        boolean hdf5file=false;
		log.debug("Array Type:"+selectedDataset.getArray_type());
        if (new edu.ucdenver.ccp.PhenoGen.data.Array().EXON_ARRAY_TYPES.contains(selectedDataset.getArray_type())) {
                hdf5file=true;
				log.debug("Create HDF5 FILE");
        }

        String groupingDir = selectedDatasetVersion.getGroupingDir();
        String groupingUserDir = selectedDatasetVersion.getGroupingUserDir(userName);
        String groupingUserPhenotypeDir = selectedDatasetVersion.getGroupingUserPhenotypeDir(userName, phenotypeName);

        log.debug("groupings dir = " +groupingDir); 
		log.debug("groupings user dir = " +groupingUserDir); 
		log.debug("groupings user Phenotyp dir = " +groupingUserPhenotypeDir); 
        if (!myFileHandler.createDir(selectedDataset.getGroupingsDir()) ||
                !myFileHandler.createDir(groupingDir) ||
                !myFileHandler.createDir(groupingUserDir) ||
                !myFileHandler.createDir(groupingUserPhenotypeDir)) {
                log.debug("error creating grouping directories in runPhenotypePrograms"); 

                mySessionHandler.createActivity("got error creating grouping directories in runPhenotypePrograms",dbConn);
                session.setAttribute("errorMsg", "SYS-001");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        } else {
            log.debug("no problems creating grouping directories in runPhenotypePrograms"); 
            String phenotypeDataFileName = selectedDatasetVersion.getPhenotypeDataFileName(userName, phenotypeName);
            String phenotypeDataOutputFileName = selectedDatasetVersion.getPhenotypeDataOutputFileName(userName, phenotypeName);
            String phenotypeDownloadFileName = selectedDatasetVersion.getPhenotypeDownloadFileName(userName, phenotypeName);
			
			log.debug("phenotypeDataFile = " +phenotypeDataFileName); 
			log.debug("phenotypeDataOutputFile = " +phenotypeDataOutputFileName); 
			log.debug("phenotypeDownloadFile = " +phenotypeDownloadFileName);
			
			
            new FileHandler().writeFile(phenotypeVals, phenotypeDataFileName);
            new FileHandler().writeFile(phenotypeDownloadVals, phenotypeDownloadFileName);
            String groupNumbers = "(" + myObjectHandler.getAsSeparatedString(groupNames.keySet(), ",") + ")";
            //log.debug("groupNumbers = "+groupNumbers);

            long startTime = Calendar.getInstance().getTimeInMillis();

            try {
                    String publicIndicator = (selectedDataset.getCreator().equals("public") ? "TRUE" : "FALSE");
                    log.debug("publicIndicator = "+publicIndicator);
                    myStatistic.callPhenotypeImportTxt(phenotypeName, publicIndicator);

                    mySessionHandler.createActivity("Successfully uploaded phenotype file",
                                            dbConn);

                    String strainCountFile = (callingForm.equals("correlation") ? 
                                            selectedDatasetVersion.getExpressionStrainCountFileName(userName, phenotypeName) : 
                                            selectedDatasetVersion.getQTLStrainCountFileName(userName, phenotypeName)); 
                    int strainCount = Integer.parseInt(myFileHandler.getFileContents(new File(strainCountFile))[0]); 

                    if ((strainCount < 5 && callingForm.equals("correlation")) || 
                       (strainCount < 15 && callingForm.equals("calculateQTLs"))) {
                            String message = (uploadingFile ? "The file '"+ 
                                    phenotypeOrigFileName + "' was not uploaded because " :
                                    "The phenotype values were not saved because ") + 
                                    "only " + strainCount + " strain(s) matched "+
                                    "those in the dataset." + twoSpaces + 
                                    "In order to "+
                                    (callingForm.equals("correlation") ? "perform a correlation analysis" : "calculate a QTL") +
                                    ", you must "+
                                    "have data for at least "+
                                    (callingForm.equals("correlation") ? "5" : "15") +
                                    " groups." + twoSpaces + 
                                    (uploadingFile ? 
                                    "You may want to double-check that the phenotype/group "+
                                    "names in your data file are "+
                                    "exact matches with those listed for the particular dataset, "+
                                    "and then "+
                                    "try uploading your data again." :
                                    "Double-check that you entered values for those strains that are marked.");

                            session.setAttribute("additionalInfo", message);

                            myParameterValue.deleteParameterValues(newParameterGroupID, dbConn);

                            session.setAttribute("errorMsg", "-99");
                            response.sendRedirect(commonDir + "errorMsg.jsp");
                    } else { 
                            if (goingToRenormalize.equals("true")&&!(new edu.ucdenver.ccp.PhenoGen.data.Array().EXON_ARRAY_TYPES.contains(selectedDataset.getArray_type()))) {
                                    String renormalizedDatasetName = selectedDataset.getName().substring(
                                                            selectedDataset.getName().indexOf("Public") + 7) +
                                                            " Re-normalized for correlation with " +
                                                            "'" + phenotypeName + "'";
                                    String newDatasetName = renormalizedDatasetName;
                                    if (myDataset.datasetNameExists(renormalizedDatasetName, userID, dbConn)) {
                                            log.debug("dataset name already exists.trying next number");
                                            int nextNum=2;
                                            newDatasetName = renormalizedDatasetName + "_" + nextNum;
                                            log.debug("now trying this dataset Name:  "+newDatasetName);
                                            while (myDataset.datasetNameExists(newDatasetName, userID, dbConn)){
                                                    nextNum++;
                                                    newDatasetName = renormalizedDatasetName + "_" + nextNum;
                                                    log.debug("now trying this dataset Name:  "+newDatasetName);
                                            }
                                    }
                                    renormalizedDatasetName = newDatasetName;
                                    myDataset.setName(newDatasetName);
                                    myDataset.setDescription("Created by re-normalizing '"+
                                                            selectedDataset.getName() +
                                                            "' using only the strains for which phenotype data is available");
                                    myDataset.setPlatform(selectedDataset.getPlatform());
                                    myDataset.setOrganism(selectedDataset.getOrganism());
									myDataset.setArray_type(selectedDataset.getArray_type());
                                    myDataset.setCreated_by_user_id(userID);
                                    myDataset.setQc_complete("Y");

                                    mySessionHandler.createActivity("Re-normalized public dataset named '" + selectedDataset.getName() +
                                                    "'. It contains "+ new Integer(groupNames.size()) + " arrays. ", dbConn);

                                    String groupNumberString = "(" + myObjectHandler.getAsSeparatedString(groupNumberList, ",", "'") + ")";

                                    log.debug("groupNumberString = "+groupNumberString);
                                    //
                                    // This gets all the chips from the old dataset that are in the groups
                                    // that have phenotype values.
                                    //
                                    User.UserChip[] chipsInOldDataset = selectedDatasetVersion.getChipsInOldDataset(
                                                                            groupNumberString, dbConn);

                                    String[] hybridIDs = new String[chipsInOldDataset.length];
                                    for (int j=0; j<chipsInOldDataset.length; j++) {
                                            hybridIDs[j] = Integer.toString(chipsInOldDataset[j].getHybrid_id());
                                    }

                                    //
                                    // Make sure this user has all the user_chips records
                                    //
                                    selectedDataset.setupArrayRecords(hybridIDs, userLoggedIn, userFilesRoot, dbConn);

                                    Dataset oldDataset = selectedDataset;
                                    Dataset.DatasetVersion oldDatasetVersion = selectedDatasetVersion;

                                    selectedDataset = myDataset.getDataset(
                                                                    myDataset.createDataset(dbConn),
                                                                    userLoggedIn, dbConn,userFilesRoot);
									selectedDataset.setArray_type(oldDataset.getArray_type());
                                    selectedDatasetVersion = selectedDataset.new DatasetVersion(1);
                                    //
                                    // Create experiment chips for each hybrid_id
                                    // Does it one-by-one -- if it ends up being too slow, change
                                    //
                                    List chipsInNewDatasetList = new ArrayList();
                                    for (int j=0; j<hybridIDs.length; j++) {
                                            //
                                            // get the user_chip_id for this hybrid_id and user_id combination
                                            //
											//log.debug("hybridID="+hybridIDs[j]+ "for  user="+userID);
                                            int user_chip_id = myDataset.getUser_chip_id(Integer.parseInt(hybridIDs[j]), userID, dbConn);
											//log.debug("userChipID="+user_chip_id);
                                            User.UserChip thisUserChip = myUser.new UserChip(user_chip_id);
                                            thisUserChip.setHybrid_id(Integer.parseInt(hybridIDs[j]));
                                            chipsInNewDatasetList.add(thisUserChip);
                                            selectedDataset.createDataset_chip(user_chip_id, dbConn);
                                    }

                                    if (!myFileHandler.createDir(selectedDataset.getPath()) ||
                                            !myFileHandler.createDir(selectedDatasetVersion.getVersion_path())) {;
                                            log.debug("error creating new renormalized Dataset's directory");

                                            mySessionHandler.createSessionActivity(session.getId(), 
                                                    "got error creating selectedDataset's directory for " +
                                                    renormalizedDatasetName,
                                                    dbConn);
                                            session.setAttribute("errorMsg", "SYS-001");
                                            response.sendRedirect(commonDir + "errorMsg.jsp");

                                    } else {
                                            log.debug("no problems creating new renormalized Dataset's directory ");

                                            //
                                            //
                                            // Now run the Preparing.To.Renormalize function
                                            //
											Thread waitThread=null;
											if(!hdf5file){
															waitThread = myStatistic.callPreparingToRenormalize(oldDataset.getPath(),
																					//selectedDatasetVersion.getPhenotypeDataOutputFileName(userName, phenotypeName),
																					oldDatasetVersion.getPhenotypeDataOutputFileName(userName, phenotypeName),
																					selectedDataset.getPath());							
											}
		
											String normalize_method = myParameterValue.getNormalizationMethod(
																					oldDataset.getDataset_id(),
																					oldDatasetVersion.getVersion(), dbConn);
											log.debug("normalize_method = "+normalize_method);
		
											//
											// First create the list of CEL files for this dataset -- this step
											// is normally done during quality control
											//
		
											String hybridIDsString = "(" +             
															new ObjectHandler().getAsSeparatedString(hybridIDs, ",", "") + ")";
											log.debug("hybridIDsString is "+hybridIDsString);
											myArrays = myArray.getArraysForDataset(hybridIDsString, dbConn);
											//This doesn't work because selectedDataset is re-set above
											//myArrays = selectedDataset.getArrays();
											myArrays = myArray.sortArrays(myArrays, "hybrid_name");
		
											selectedDataset.setArrays(myArrays,null,"");
		
											if (selectedDataset.getPlatform().equals(selectedDataset.AFFYMETRIX_PLATFORM) ||
																	selectedDataset.getPlatform().equals(selectedDataset.CODELINK_PLATFORM)) {
													selectedDataset.createFileListing(userFilesRoot, true);
											//
											// for the cDNA fileListings, create a header line
											//
											} else if (selectedDataset.getPlatform().equals("cDNA")) {
													selectedDataset.createFileListing(userFilesRoot, 
																			true, 
																			"fileName\t" + "sampleid\t" + "phenotype\t" +
																			"sex\t" + "slideNumber");
											}
		
		
											User.UserChip[] chipsInNewDataset = (User.UserChip[]) chipsInNewDatasetList.toArray(new User.UserChip[chipsInNewDatasetList.size()]);

											// groupValues contains the user_chip_id mapped to the group number
											//
											LinkedHashMap groupValues = new LinkedHashMap();
											User.UserChip myUserChip = myUser.new UserChip();
											for (int j=0; j<myArrays.length; j++) {
													User.UserChip newChip = myUserChip.getUserChipFromMyUserChips(chipsInNewDataset,
																							myArrays[j].getHybrid_id());
													//
													// Find the user_chip in the old dataset that has the same hybrid_id
													// and get its groupNumber
													//
													User.UserChip oldChip = myUserChip.getUserChipFromMyUserChips(chipsInOldDataset,
																							myArrays[j].getHybrid_id());
													log.debug("newChip = "); myDebugger.print(newChip);
													log.debug("oldChip = "); myDebugger.print(oldChip);
													groupValues.put(Integer.toString(newChip.getUser_chip_id()), Integer.toString(oldChip.getGroup().getGroup_number()));
											}
											//
											// groupNames contains the group number mapped to the group label
											// (this was created above)
											//
											//log.debug("groupValues = "); myDebugger.print(groupValues);
											//log.debug("and groupNames = "); myDebugger.print(groupNames);
											int grouping_id = selectedDataset.checkGroupingExists(groupValues, dbConn);
											if (grouping_id == -99) {
													grouping_id = selectedDataset.createNewGrouping("strain",
																									"Groups based on 'strain'", 
																									groupValues,
																									groupNames,
																									dbConn);
											}
											selectedDatasetVersion.setGrouping_id(grouping_id);

											if (!myFileHandler.createDir(selectedDataset.getGroupingsDir()) || 
													!myFileHandler.createDir(selectedDatasetVersion.getGroupingDir()) ||
													!myFileHandler.createDir(selectedDatasetVersion.getGroupingUserDir(userName)) ||
													!myFileHandler.createDir(selectedDatasetVersion.getGroupingUserPhenotypeDir(userName, phenotypeName))) { 
															log.debug("got error creating grouping directories");
															mySessionHandler.createActivity("got error creating groupings directory for " +
																	selectedDataset.getName(),
																	dbConn);
															session.setAttribute("datasetID", "-99");
															session.setAttribute("errorMsg", "SYS-001");
															response.sendRedirect(commonDir + "errorMsg.jsp");
											} else {
													log.debug("no problems creating new renormalized correlation directory ");
		
													String newPhenotypeDataFileName = selectedDatasetVersion.getPhenotypeDataFileName(userName, phenotypeName);
													String newPhenotypeDataOutputFileName = selectedDatasetVersion.getPhenotypeDataOutputFileName(userName, phenotypeName);
													String newPhenotypeDownloadFileName = selectedDatasetVersion.getPhenotypeDownloadFileName(userName, phenotypeName);
													if(hdf5file){
															myFileHandler.copyFile(new File(oldDatasetVersion.getPhenotypeDataFileName(userName, phenotypeName)),
																					new File(newPhenotypeDataFileName));
															myFileHandler.copyFile(new File(oldDatasetVersion.getPhenotypeDataOutputFileName(userName, phenotypeName)),
																					new File(newPhenotypeDataOutputFileName));
															myFileHandler.copyFile(new File(oldDatasetVersion.getPhenotypeDownloadFileName(userName, phenotypeName)),
																					new File(newPhenotypeDownloadFileName));
													}
		
															versionType = "N";
															String version_name = "Groups based on 'strain', Normalized using '"+normalize_method + "'";
															int numGroups = groupNames.size();
		
															//
															// These values must all be set before including doNormalization
															//
															//
															String codeLink_parameter1 = (normalize_method.equals("limma") ||
																							normalize_method.equals("loess") ?
																							myParameterValue.getCodeLinkNormalizationParameter(
																									oldDataset.getDataset_id(),
																									oldDatasetVersion.getVersion(), dbConn) :
																							"");
		
															String probeMask = (myParameterValue.getProbeMaskParameter(
																							oldDataset.getDataset_id(),
																							oldDatasetVersion.getVersion(), dbConn)); 
		
																					String analysisLevel=(myParameterValue.getAnalysisLevelParameter(
																							oldDataset.getDataset_id(),
																							oldDatasetVersion.getVersion(), dbConn));
		
																					String annotationLevel = (myParameterValue.getAnnotationLevelParameter(
																							oldDataset.getDataset_id(),
																							oldDatasetVersion.getVersion(), dbConn));
		
															log.debug("probeMask = "+probeMask);
															try {
																	// These need to be set so that Normalization works correctly
																	session.setAttribute("selectedDataset", selectedDataset);
																	session.setAttribute("selectedDatasetVersion", selectedDatasetVersion);
																	myStatistic.setSession(session);
																	//myStatistic.setSession(session);
																	int nextVersionNumber = myStatistic.doNormalization(
																									normalize_method,
																									version_name, 
																									grouping_id,
																									probeMask,
																									codeLink_parameter1, 
																									versionType,
																									waitThread, 
																									analysisLevel,
																									annotationLevel,
																									true);
																	mySessionHandler.createDatasetActivity(session.getId(), 
																					selectedDataset.getDataset_id(), nextVersionNumber,
																					"Re-normalized new dataset from public dataset",
																					dbConn);
		
																	parameterGroupID = selectedDatasetVersion.getMasterParameterGroupID(dbConn);
		
																	// Copy the correlation parameters to the new dataset version
																	// This doesn't copy the User ID parameter, so have to do that separately
																	//
																	myParameterValue.copyCorrelationParameters(newParameterGroupID,
																													parameterGroupID, dbConn);
																	log.debug("just copied correlation parameters with parameterGroupID ="+parameterGroupID +
																					", and newParameterGroupID= "+ newParameterGroupID);
																	myParameterValue.setParameter_group_id(parameterGroupID);
																	myParameterValue.setCategory("Phenotype Data");
																	myParameterValue.setParameter("User ID");
																	myParameterValue.setValue(Integer.toString(userID));
																	myParameterValue.createParameterValue(dbConn);
		
																	// Now delete the correlation parameters from the original version
																	//
																	myParameterValue.deleteParameterValues(newParameterGroupID, dbConn);
		
																	session.setAttribute("privateDatasetsForUser", null);
																	//Success - "Dataset is being re-normalized"
																	session.setAttribute("successMsg", "PHN-002");
																	response.sendRedirect(datasetsDir + "listDatasets.jsp");
		
															} catch (ErrorException e) {
																	selectedDataset.deleteDataset(userLoggedIn.getUser_id(),dbConn);
																	session.setAttribute("additionalInfo", e.getAdditionalInfo());
																	session.setAttribute("errorMsg", e.getMessage());
																	if (e.getMessage().equals("SYS-001")) {
																			mySessionHandler.createActivity("got error creating dataset directory in doNormalization for " +
																					selectedDataset.getName(),
																					dbConn);
																	}
																	response.sendRedirect(commonDir + "errorMsg.jsp");
															}
													}
											}
							// Not going to re-normalize
                            } else {
										try {
												if (callingForm.equals("correlation")) {
														myStatistic.callMaskingMissingStrains(groupingUserPhenotypeDir,
																				selectedDatasetVersion,
																				phenotypeDataOutputFileName,hdf5file);
														long finishTime = Calendar.getInstance().getTimeInMillis();
														int actualDuration = new Long((finishTime - startTime)/1000).intValue();
														log.debug("startTime = "+startTime+
																		", finishTime = "+finishTime + 
																		", actualDuration for "+
																		timedFunctionMasking + " = "+actualDuration);
														selectedDataset.updateDuration(timedFunctionMasking,
																						selectedDataset.getNumber_of_arrays(), 
																						num_probes,
																						actualDuration, dbConn);
	
														mySessionHandler.createActivity("Successfully ran "+timedFunctionMasking,
																				dbConn);
												}
	
												String redirectString = (callingForm.equals("correlation") ? datasetsDir + "correlation.jsp" :
																				qtlsDir + "calculateQTLs.jsp") + queryString;
												log.debug("redirectString = "+redirectString);
	
												String strainCountMsg = "Number of matching strains loaded:" + twoSpaces;
	
												if (formName.equals("uploadPhenotype2.jsp")) {
														session.setAttribute("additionalInfo", "The file '" + phenotypeOrigFileName + 
																		"' has been successfully uploaded.  "+
																		" <BR><BR> "+
																		strainCountMsg + "  " + strainCount);
	
														session.setAttribute("successMsg", "SYS-004");
														response.sendRedirect(redirectString);
												} else {
														session.setAttribute("additionalInfo", "The phenotype data "+ 
																		" has been successfully saved.  "+
																		" <BR><BR> "+
																		strainCountMsg + "  " + strainCount);
	
														session.setAttribute("successMsg", "SYS-004");
														response.sendRedirect(redirectString);
												}
										} catch (RException e) {
												rExceptionErrorMsg = e.getMessage();
												mySessionHandler.createActivity("Got RException When Running R MaskingMissingStrains Function",
																dbConn);
												%><%@ include file="/web/datasets/include/rError.jsp" %><%
										}
									
                            }
                    }
            } catch (RException e) {
                    log.debug("got an error when running PhenotypeImportTxt. Deleting parameterValues");
                    myParameterValue.deleteParameterValues(newParameterGroupID, dbConn);
                    rExceptionErrorMsg = e.getMessage();
                    mySessionHandler.createActivity("Got RException When Running R PhenotypeImportTxt Function",
                                    dbConn);
                    %><%@ include file="/web/datasets/include/rError.jsp" %><%
            }
		}

	%>
