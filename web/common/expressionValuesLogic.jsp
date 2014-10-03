<%--
 *  Author: Cheryl Hornbaker
 *  Created: April, 2009
 *  Description:  This contains the common logic for obtaining the expression values
 *
--%>
<jsp:useBean id="myStatistic" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.Statistic"> 
        <jsp:setProperty name="myStatistic" property="RFunctionDir" value="<%=rFunctionDir%>" />
        <jsp:setProperty name="myStatistic" property="session" value="<%=session%>" />
</jsp:useBean>
<jsp:useBean id="myDateTime" class="edu.ucdenver.ccp.util.DateTimeFormatter"> </jsp:useBean>
<jsp:useBean id="thisIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"> </jsp:useBean>
<%
        log.info("in expressionValuesLogic.jsp. user =  "+ user);

        %><%@include file="/web/datasets/include/splitDatasetIDAndVersion.jsp"%><%

        String datasetArrayType = "";
        log.debug("action = "+action + ", dataset_id= " + selectedDataset.getDataset_id() +" version = "+selectedDatasetVersion.getVersion());
		log.debug("geneSymbolsHM.size()="+geneSymbolsHM.size());
        Dataset.Group[] groups = null;
        String previousGeneNames = "";
        Set setOfIdentifiers = null;
        String groupValuesFileName = "";
        String individualValuesFileName = "";
		boolean hdf5file=false;

        if (selectedDataset.getDataset_id() != -99 && 
		selectedDatasetVersion.getVersion() != -99 
		&& selectedGeneList.getGene_list_id() != -99) {
		
		if ((new File(selectedDataset.getPath() + "Affy.NormVer.h5")).exists()) {
			hdf5file = true;
		}

		datasetArrayType = myArray.getDatasetArrayType(selectedDataset.getDatasetHybridIDs(dbConn), dbConn);
		groups = selectedDatasetVersion.getGroupsWithExpressionData(dbConn);
		//log.debug("groups = "); myDebugger.print(groups);
		java.util.Date tmpDate=new java.util.Date();
		String time=myDateTime.getFormattedTime(tmpDate,"",true);
        String inputFileName = selectedDatasetVersion.getNormalized_RData_FileName(); 
			
        String geneListFileName = selectedDatasetVersion.getVersion_path()+"temp/" + 
					"GenesOfInterest_"+time+".txt";
		groupValuesFileName = selectedDatasetVersion.getVersion_path()+"temp/" + 
				selectedDataset.getNameNoSpaces() + 
				"_GroupMeanValues_"+time+".txt";
		individualValuesFileName = selectedDatasetVersion.getVersion_path()+"temp/" + 
				selectedDataset.getNameNoSpaces() + 
				"_IndividualValues_"+time+".txt";
		String groupValuesStartFileName = selectedDatasetVersion.getVersion_path()+"temp/" + 
					selectedDataset.getNameNoSpaces() + 
					"_GroupMeanValuesStart_"+time+".txt";
					
		String individualValuesStartFileName = selectedDatasetVersion.getVersion_path()+"temp/" + 
								selectedDataset.getNameNoSpaces() + 
								"_IndividualValuesStart_"+time+".txt";
								
		String zipFileName = selectedDatasetVersion.getVersion_path()+"temp/" + 
				selectedDataset.getNameNoSpaces() + 
				"_GeneValues_Download_"+time+".zip";
		String outputDir=selectedDatasetVersion.getVersion_path()+"temp/";
				
		if(hdf5file){
				
				inputFileName =  selectedDataset.getPath()+ "Affy.NormVer.h5";
				geneListFileName = selectedDataset.getPath()+"temp/"+"v"+selectedDatasetVersion.getVersion() +"_GenesOfInterest_"+time+".txt";
				groupValuesFileName = selectedDataset.getPath()+"temp/" + selectedDataset.getNameNoSpaces() + "_v"+selectedDatasetVersion.getVersion() +"_GroupMeanValues_"+time+".txt";
				individualValuesFileName = selectedDataset.getPath()+"temp/" + selectedDataset.getNameNoSpaces() + "_v"+selectedDatasetVersion.getVersion() +"_IndividualValues_"+time+".txt";
				groupValuesStartFileName = selectedDataset.getPath()+"temp/" + selectedDataset.getNameNoSpaces() + "_v"+selectedDatasetVersion.getVersion() + "_GroupMeanValuesStart_"+time+".txt";
				individualValuesStartFileName = selectedDataset.getPath()+"temp/" + selectedDataset.getNameNoSpaces() + "_v"+selectedDatasetVersion.getVersion() +"_IndividualValuesStart_"+time+".txt";
				zipFileName = selectedDataset.getPath()+"temp/" + selectedDataset.getNameNoSpaces() + "_v"+selectedDatasetVersion.getVersion() + "_GeneValues_Download_"+time+".zip";
				outputDir=selectedDataset.getPath()+"temp/";
		}
		File tmpDir=new File(outputDir);
		if(!tmpDir.exists()){
			tmpDir.mkdirs();
		}
		log.debug("groupValuesFileName = "+groupValuesFileName);
		log.debug("individualValuesFileName = "+individualValuesFileName);

		Set thisIDecoderSet = null;
		String version="v"+selectedDatasetVersion.getVersion();
		String sampleFile=selectedDataset.getPath()+version+"_samples.txt";

        if ((action != null) && action.equals("View")) {
			String geneChipName = myArray.getManufactureArrayName(datasetArrayType, dbConn);
			log.debug("geneChipName = "+geneChipName);
			String [] targets = new String[1];
			String organism = selectedDataset.getOrganism();
			if (selectedDataset.getPlatform().equals(selectedDataset.AFFYMETRIX_PLATFORM)) {
				targets[0] = "Affymetrix ID";
			} else if (selectedDataset.getPlatform().equals(selectedDataset.CODELINK_PLATFORM)) {
				targets[0] = "CodeLink ID";
			}
			thisIDecoderSet = thisIDecoderClient.getIdentifiers(selectedGeneList.getGene_list_id(), targets, geneChipName, dbConn);
			
			Set caseIgnoreSet=thisIDecoderClient.getIdentifiersIgnoreCase(selectedGeneList.getGene_list_id(), targets, geneChipName, pool);
			for(Iterator itr=caseIgnoreSet.iterator();itr.hasNext();){
				Identifier tmpID=(Identifier) itr.next();
				if(!thisIDecoderSet.contains(tmpID)){
					thisIDecoderSet.add(tmpID);
				}
			}
			//log.debug("thisIDecoderSet = "); myDebugger.print(thisIDecoderSet);

			setOfIdentifiers = thisIDecoderClient.getValues(thisIDecoderSet);

			log.debug("setOfIdentifiers.size() = " + setOfIdentifiers.size()); 
			session.setAttribute("thisIDecoderSet", thisIDecoderSet);
			//log.debug("setOfIdentifiers = "+setOfIdentifiers);
			if (setOfIdentifiers.size() > 0) {

                		myFileHandler.writeFile(myObjectHandler.getAsSeparatedString(setOfIdentifiers, "\n") + 
							"\n", geneListFileName);

                		log.debug("before call to R_session");
						if(hdf5file){
							try {
									myStatistic.callOutputRawSpecificGeneBoth(selectedDataset.getPlatform(),
																		inputFileName,
																		version,
																		sampleFile,
																		geneListFileName,
										individualValuesStartFileName,
										groupValuesStartFileName,
										outputDir);
							} catch (RException e) {
									rExceptionErrorMsg = e.getMessage();
									mySessionHandler.createDatasetActivity(
																"Got RException When Running R Output Raw Specific Gene Function for group",
																dbConn);
									%><%@ include file="/web/datasets/include/rError.jsp" %><%
							}
						}else{
							try {
									myStatistic.callOutputRawSpecificGene(selectedDataset.getPlatform(),
																		inputFileName,
																		version,
																		sampleFile,
																		geneListFileName,
										groupValuesStartFileName,
										"Group",
										outputDir);
							} catch (RException e) {
									rExceptionErrorMsg = e.getMessage();
									mySessionHandler.createDatasetActivity(
																"Got RException When Running R Output Raw Specific Gene Function for group",
																dbConn);
									%><%@ include file="/web/datasets/include/rError.jsp" %><%
							}
						}

                       mySessionHandler.createSessionActivity(session.getId(), 
									-99,
                                	selectedDataset.getDataset_id(), 
									selectedDatasetVersion.getVersion(), 
									selectedGeneList.getGene_list_id(),
                                	"Viewed Group Mean Intensity Values",
                                	dbConn);

				String [] fileContents = myFileHandler.getFileContents(new File(groupValuesStartFileName));
				//String outFileContents = "";
				StringBuilder sb=new StringBuilder();
				//
				// For all rows after the header row, look through the Set of Identifiers returned by IDecoder
				// and create a new column with the originating Identifier that matches with the one returned by IDecoder
				//
				Dataset.Group myGroup = selectedDataset.new Group(); 
				for (int i=0; i<fileContents.length; i++) {
					String[] columns = fileContents[i].split("\t");
					if (i == 0) {
						sb.append( "Gene Identifier" + "\t"); 
						for (int j=0; j<columns.length; j++) {
							if (columns[j].startsWith("Group")) {
								//log.debug("column start with Group " + columns[j]);
								//
								// The column headings are 'Group.1.Mean', etc, so look for the first occurrence
								// of the dot and get the string between that and the second occurrence
								// of the dot
								//

								String[] columnHeadingPieces = columns[j].split("\\.");
								int groupNumber = Integer.parseInt(columnHeadingPieces[1]);

								if (groups.length > 0) {
									columns[j] = 
										myGroup.getGroupFromMyGroups(groups, groupNumber).getGroup_name();
								}
								sb.append( columns[j] + " " +columnHeadingPieces[2]);
								if (j < columns.length) {
									sb.append( "\t");
								}
							} else {
								sb.append( columns[j] + "\t");
							}
						}
					} else {
						for (Iterator itr = thisIDecoderSet.iterator(); itr.hasNext();) {
							Identifier thisIdentifier = (Identifier) itr.next();
							if ((thisIdentifier.getIdentifier()).equals(columns[0].replaceAll("\"", ""))) {
								sb.append((thisIdentifier.getOriginatingIdentifier()).getIdentifier() + "\t" + 
											fileContents[i]);
							}
						}
					}
					sb.append("\n");
				}
				myFileHandler.writeFile(sb.toString(), groupValuesFileName);

				if(!hdf5file){
                		try {
                        		myStatistic.callOutputRawSpecificGene(selectedDataset.getPlatform(),
                                                                	inputFileName,
																	version,
																	sampleFile,
                                                                	geneListFileName,
									individualValuesStartFileName,
									"Individual",
									outputDir);
                		} catch (RException e) {
                        		rExceptionErrorMsg = e.getMessage();
                        		mySessionHandler.createDatasetActivity(
                                                        	"Got RException When Running R Output Raw Specific Gene Function for individual",
                                                        	dbConn);
                        		%><%@ include file="/web/datasets/include/rError.jsp" %><%
                		}
				}

				fileContents = myFileHandler.getFileContents(new File(individualValuesStartFileName));
				sb=new StringBuilder();
				//
				// For all rows after the header row, look through the Set of Identifiers returned by IDecoder
				// and create a new column with the originating Identifier that matches with the one returned by IDecoder
				//
				for (int i=0; i<fileContents.length; i++) {
					String[] columns = fileContents[i].split("\t");
					if (i == 0) {
						sb.append("Gene Identifier" + "\t" + fileContents[i]);	
					} else {
						for (Iterator itr = thisIDecoderSet.iterator(); itr.hasNext();) {
							Identifier thisIdentifier = (Identifier) itr.next();
							if ((thisIdentifier.getIdentifier()).equals(columns[0].replaceAll("\"", ""))) {
								sb.append( 
											(thisIdentifier.getOriginatingIdentifier()).getIdentifier() + "\t" + 
											fileContents[i]);
							}
						}
					}
					sb.append("\n");
				}
				myFileHandler.writeFile(sb.toString(), individualValuesFileName);
		
				session.setAttribute("exprGroupFile", groupValuesFileName);
				session.setAttribute("exprArrayFile", individualValuesFileName);
			} else {
                        	//Error - "Can't find a probeset id for the identifiers
                        	mySessionHandler.createActivity("Used the following geneList: "+ selectedGeneList.getGene_list_name(), 
                                		dbConn);
				session.setAttribute("additionalInfo", "");
                        	session.setAttribute("errorMsg", "GLT-013");
                        	response.sendRedirect(commonDir + "errorMsg.jsp");
			}
        	} else if ((action != null) && action.equals("Download")) {
				log.debug("Downloading individual and group values");
				thisIDecoderSet = (Set) session.getAttribute("thisIDecoderSet");
				String view="group";
				if(request.getParameter("view")!=null){
					view=(String)request.getParameter("view");
				}
				boolean incGS=false;
				if(request.getParameter("incGS")!=null){
					String tmp=(String)request.getParameter("incGS");
					if(tmp.equals("true")){
						incGS=true;
					}
				}
				String exp="expanded";
				if(request.getParameter("exp")!=null){
					exp=(String)request.getParameter("exp");
				}
				
				String file="";
				if(view.equals("group")){
					file = (String)session.getAttribute("exprGroupFile"); 
				}else{
					file = (String)session.getAttribute("exprArrayFile"); 
				}
				
				if(exp.equals("original") || incGS){
					String extra="_";
					if(exp.equals("original")){
						extra=extra+"orig";
					}
					if(incGS){
						extra=extra+"GS";
					}
					String outfile=file.substring(0,file.length()-4)+extra+".txt";
					File outFile=new File(outfile);
					if(!outFile.exists()){
						String[] fileContents = myFileHandler.getFileContents(new File(file));
						StringBuilder sb=new StringBuilder();
						//
						// For all rows after the header row, look through the Set of Identifiers returned by IDecoder
						// and create a new column with the originating Identifier that matches with the one returned by IDecoder
						//
						for (int i=0; i<fileContents.length; i++) {
							String[] columns = fileContents[i].split("\t");
							if (i == 0) {
								if(incGS){
									sb.append("Gene Symbol\t"+ fileContents[i]);
								}else{
									sb.append(fileContents[i]);	
								}
								sb.append("\n");
							} else {
								if(incGS && exp.equals("expanded")){
									String symbol=geneSymbolsHM.get(columns[0]).replaceAll("<BR>",",");
									if(symbol.endsWith(",")){
										symbol=symbol.substring(0,symbol.length()-1);
									}
									sb.append(symbol+"\t"+fileContents[i]);
									sb.append("\n");
								}else if(exp.equals("original")){
									if(columns[0].equals(columns[1])){
										if(incGS){
											String symbol=geneSymbolsHM.get(columns[0]).replaceAll("<BR>",",");
											if(symbol.endsWith(",")){
												symbol=symbol.substring(0,symbol.length()-1);
											}
											sb.append(symbol+"\t"+fileContents[i]);
										}else{
											sb.append(fileContents[i]);
										}
										sb.append("\n");
									}
								}
							}
							
						}
						
						myFileHandler.writeFile(sb.toString(), outfile);
						file=outfile;
					}else{
						file=outfile;
					}
				}
				//log.debug("zipFileName = "+zipFileName);
				/*		myFileHandler.createZipFile(files, zipFileName);
						request.setAttribute("fullFileName", zipFileName);
						*/
				
				request.setAttribute("fullFileName",file );
				myFileHandler.downloadFileNoDelete(request, response);
				// This is required to avoid the getOutputStream() has already been called for this response error
				out.clear();
				out = pageContext.pushBody(); 

                	mySessionHandler.createDatasetActivity("Downloaded Raw Intensity Values for Dataset", dbConn);
        	}

	}
%>

