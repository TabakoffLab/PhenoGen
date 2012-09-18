<%
                        if (firstTime.equals("Y")) {
						
                                if (!myFileHandler.createDir(analysisPathPartial) ||
                                        !myFileHandler.createDir(analysisPathPlusDate) ||
                                        !myFileHandler.createDir(analysisPathPlusDateTime)) {
                                        log.debug("error creating analysis directories in filters ");
                                        keepGoing = false;

										mySessionHandler.createActivity("got error creating analysis directories for filters",
                                                        dbConn);
                                        session.setAttribute("errorMsg", "SYS-001");
                                        response.sendRedirect(commonDir + "errorMsg.jsp");
                                } else {
                                        log.debug("no problems creating analysis directories in filters");
                                        parameterGroupID = myParameterValue.copyMasterParameters(selectedDataset.getDataset_id(), 
										selectedDatasetVersion.getVersion(), dbConn);
                                        if (phenotypeParameterGroupID != -99) {
												myParameterValue.setCreate_date();
                                                myParameterValue.setParameter_group_id(parameterGroupID);
                                                myParameterValue.setCategory("Phenotype Data");
                                                myParameterValue.setParameter("Parameter Group ID");
                                                myParameterValue.setValue(Integer.toString(phenotypeParameterGroupID));
                                                myParameterValue.createParameterValue(dbConn);
                                        }
										myStatistic.setupFilter(selectedDataset,selectedDatasetVersion,analysisType,userLoggedIn.getUser_id());
										firstTime = "N";
                                }
								
                        }
	                	session.setAttribute("parameterGroupID", Integer.toString(parameterGroupID));

%>

