<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  The web page created by this file allows the user to apply 
 *		statistical tools to filter genes from a dataset	
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/analysisHeader.jsp"  %>

<jsp:useBean id="myGeneList" class="edu.ucdenver.ccp.PhenoGen.data.GeneList"> </jsp:useBean>
<jsp:useBean id="myQTL" class="edu.ucdenver.ccp.PhenoGen.data.QTL"> </jsp:useBean>
<jsp:useBean id="myIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"> </jsp:useBean>

<%

	log.info("in filters. user = " + user);
	
	pool=(DataSource)session.getAttribute("dbPool");
	
	request.setAttribute( "selectedMain", "microarrayTools" );
	request.setAttribute( "selectedStep", "3" ); 
    if (analysisType.equals("correlation")) {
		request.setAttribute( "selectedStep", "4" );
	}
	extrasList.add("progressBar.js");
	extrasList.add("filters.js");
	optionsList.add("datasetVersionDetails");

	log.debug("action = "+action);
	String currentDate = (String) request.getParameter("thisSessionDate");
	String currentTime = (String) request.getParameter("thisSessionTime");
	boolean hdf5file=false;
	String currentGeneCountMsg = "";
	String filterMethodText = "";
    Dataset.Group[] groups = null;
    String filtersRun = "No Filters Have Been Run Yet";
    String filtersList = "";
    String lastCategory = "";
    String canIgnore = "";
	String groupingUserPhenotypeDir=null;
	String abnormalPath=null;
    int numGroups = 0;
	Hashtable criteriaList = null;
	ParameterValue[] analysisParameters = null;
	Hashtable durationHash = null;
	String firstTime = "Y";	
	File firstInputFile;
	onClickString="return displayWorking()";
	log.debug("HDF5 file Checking:"+selectedDataset.getPath() + "Affy.NormVer.h5");
	if ((new File(selectedDataset.getPath() + "Affy.NormVer.h5")).exists()) {//test for HDF5 file if exists use DB for filter results
			hdf5file = true;
			log.debug("HDF5 file Found");
	}
	// If this is an exon array and the analysis was done on the probeset level, then start with 1,222,000 probes.
	// If this is an exon array and the analysis was done on the transcript level, then start with 290,000 probes.
	// Otherwise, start with 45000 probes
        int num_probes = ((String) request.getParameter("num_probes") != null ?
                Integer.parseInt((String) request.getParameter("num_probes")) :
		(new edu.ucdenver.ccp.PhenoGen.data.Array().EXON_ARRAY_TYPES.contains(selectedDataset.getArray_type()) ? 
		//JUST A PLACEHOLDER!!!YIKES!!!
		1222000 :
		//	(selectedDataset.getNormalization_analysis_level().equals("probeset") ? 1222000 : 290000) :
                45000));

        if (action == null) { 
        	//
	        // Get the current time so that a directory can be created for
       		// this analysis session
	        //
        	currentDate = myObjectHandler.getNowAsMMddyyyy();
        	currentTime = myObjectHandler.getNowAsHmmss();
			firstTime = "Y";
			analysisParameters = myParameterValue.getParameterValues(selectedDatasetVersion.getMasterParameterGroupID(), dbConn);
        }
	log.debug("firstTime = "+firstTime);

	//log.debug("currentDate = "+currentDate + ", currentTime = "+currentTime);

        Hashtable filterText = myStatistic.getFilterText();

	if ((String) request.getParameter("firstTime") != null) {
		firstTime = (String) request.getParameter("firstTime");
	}
	log.debug("firstTime = "+firstTime);
	log.debug("at beginning of filters, parameterGroupID = "+parameterGroupID);
        log.debug("phenotypeParameterGroupID = " + phenotypeParameterGroupID);

        fieldNames.add("filterMethod");
        fieldNames.add("codeLinkCallGroup1");         
        fieldNames.add("codeLinkCallGroup2");         
        fieldNames.add("codeLinkCallOverall");         
        fieldNames.add("codeLinkCallParameter2");         
        fieldNames.add("absCallGroup1");         
        fieldNames.add("absCallGroup2");         
        fieldNames.add("absCallOverall");         
        fieldNames.add("absCallParameter2");         
        fieldNames.add("negParam");         
        fieldNames.add("negativeControlGroup1");         
        fieldNames.add("negativeControlGroup2");         
        fieldNames.add("negativeControlOverall");         
        fieldNames.add("negativeControlParameter2");         
        fieldNames.add("codeLinkNegativeControlGroup1");         
        fieldNames.add("codeLinkNegativeControlGroup2");         
        fieldNames.add("codeLinkNegativeControlOverall");         
        fieldNames.add("codeLinkNegativeControlParameter2");         
        fieldNames.add("coeffGroup1");         
        fieldNames.add("coeffGroup2");         
        fieldNames.add("coeffOverall");         
        fieldNames.add("coeffParameter2");         
        fieldNames.add("flagGroup1");         
        fieldNames.add("flagGroup2");         
        fieldNames.add("flagOverall");         
        fieldNames.add("flagParameter2");         
        fieldNames.add("bg2sdGroup1");         
        fieldNames.add("bg2sdGroup2");         
        fieldNames.add("bg2sdOverall");         
        fieldNames.add("lowIntGroup1");         
        fieldNames.add("lowIntGroup2");         
        fieldNames.add("lowIntOverall");         
        fieldNames.add("lowIntThreshold");         
        fieldNames.add("filterThreshold");         
        fieldNames.add("parameter3");         
        fieldNames.add("heritabilityPanel");         
        fieldNames.add("heritabilityLevel");         
        fieldNames.add("qtlListID");         
        fieldNames.add("tissue");         
        fieldNames.add("geneListID");         
        fieldNames.add("geneListParameter2");         
        fieldNames.add("translateGeneList");         
        fieldNames.add("keepPercentage");         
        fieldNames.add("keepNumber");         
        fieldNames.add("lastCategory");         
        fieldNames.add("canIgnore");         

        %><%@ include file="/web/common/getFieldValues.jsp" %><%

         // Put the field values into variables for those that are referenced more than once
    String filterMethod = (String) fieldValues.get("filterMethod");         

	boolean keepGoing = true;
        int[] groupCount = selectedDatasetVersion.getGroupCounts();
	groups = selectedDatasetVersion.getGroupsWithExpressionData(dbConn);
	numGroups = selectedDatasetVersion.getNumber_of_non_exclude_groups();
	//log.debug("numGroups = " + numGroups);
	//log.debug("groups= "); myDebugger.print(groups);
	//log.debug("groupCount = "); myDebugger.print(groupCount);
	String versionType = selectedDatasetVersion.getVersion_type();
	log.debug("versionType = "+versionType);

	//log.debug("Number of non-exclude groups = " + numGroups);
	session.setAttribute("groups", groups);
					
	session.setAttribute("numGroups", Integer.toString(numGroups));

	log.debug("numGroups = "+numGroups + 
			", num_arrays = "+ selectedDataset.getNumber_of_arrays() + 
			", num_probes here = "+num_probes);
	durationHash = myDataset.getExpectedDuration(selectedDataset.getNumber_of_arrays(), num_probes, dbConn);
	session.setAttribute("durationHash", durationHash);
	//log.debug("durationHash here = "); myDebugger.print(durationHash);
	String curDate=(String)session.getAttribute("verFilterDate");
	String curTime=(String)session.getAttribute("verFilterTime");
	log.debug("curDate:"+curDate+"\nCurTime:"+curTime);
	String analysisPathPartial = userLoggedIn.getUserGeneListsDir() + 
                       selectedDataset.getNameNoSpaces() + 
                       "_v" +
                       selectedDatasetVersion.getVersion() +
                       "_Analysis" + "/";
	String analysisPathPlusDate="";
	String analysisPathPlusDateTime="";
	if(curDate!=null&&!curDate.equals("")&&curTime!=null&&!curTime.equals("")){
		log.debug("Using stored values");
		analysisPathPlusDate = analysisPathPartial + curDate + "/";
		analysisPathPlusDateTime = analysisPathPlusDate + curTime + "/";
        analysisPath = analysisPathPlusDateTime;
	}else{
		log.debug("CREATING NEW VALUES");
		java.util.Date d=new java.util.Date();
		curDate=DateTimeFormatter.getFormattedDate(d,null);
    	curTime=DateTimeFormatter.getFormattedTime(d,null,true);

		analysisPathPlusDate = analysisPathPartial + curDate + "/";
		analysisPathPlusDateTime = analysisPathPlusDate + curTime + "/";
        analysisPath = analysisPathPlusDateTime;
	
		log.debug("analysisPath= "+analysisPath);
		session.setAttribute("analysisPath", analysisPath);
		session.setAttribute("verFilterDate", curDate);
		session.setAttribute("verFilterTime", curTime);
	}
	String prevFiltersList = (String) request.getParameter("prevFiltersList");

	if (prevFiltersList != null) {
		filtersList = prevFiltersList; 
		filtersRun = "Filters Already Run: "; 
		lastCategory = (String) fieldValues.get("lastCategory");
		canIgnore = (String) fieldValues.get("canIgnore");
	}
	log.debug("filtersList here = "+filtersList);
	log.debug("fieldValues = "); myDebugger.print(fieldValues);
	log.debug("filterText = "); myDebugger.print(filterText);

	log.debug("2 parameterGroupID = "+parameterGroupID);

	if (phenotypeParameterGroupID != -99) {
		String thisPhenotypeName = myParameterValue.getPhenotypeName(phenotypeParameterGroupID, dbConn);
                groupingUserPhenotypeDir = 
				selectedDatasetVersion.getGroupingUserPhenotypeDir(userName, thisPhenotypeName); 

		session.setAttribute("groupingUserPhenotypeDir", groupingUserPhenotypeDir);
		if (analysisType.equals("correlation") && groupingUserPhenotypeDir!=null && hdf5file) {
				abnormalPath=groupingUserPhenotypeDir;
		}
		firstInputFile = new File(selectedDatasetVersion.getNormalizedForGrouping_RData_FileName(groupingUserPhenotypeDir));

		if (!firstInputFile.exists()) {
			firstInputFile = new File(selectedDatasetVersion.getNormalized_RData_FileName()); 
		}
	} else {
		firstInputFile = new File(selectedDatasetVersion.getNormalized_RData_FileName()); 
	}

	String inputFileName = analysisPath + selectedDataset.getPlatform() + ".filter.genes.output.Rdata";
	String outputFileName = analysisPath + selectedDataset.getPlatform() + ".filter.genes.output.Rdata";
	String prevInputFileName = inputFileName + "_PREVIOUS";

	File prevInputFile = new File(prevInputFileName);
	File inputFile = new File(inputFileName);

	String geneCountFileName = analysisPath + "GeneCountAfterFilter.txt";
	File geneCountFile = new File(geneCountFileName);
	File prevGeneCountFile = new File(geneCountFileName + "_PREVIOUS");

    if ((action != null) && action.equals("Run Filter")) {
			log.debug("action is Run Filter."); 
	
			//
			// If this is the first time analysis has been run, create a new directory and
			// set up the parameterGroupID
			//
	
			%><%@ include file="/web/datasets/include/firstTime.jsp" %><%

			if ((selectedDataset.getPlatform().equals(selectedDataset.AFFYMETRIX_PLATFORM) || 
				selectedDataset.getPlatform().equals(selectedDataset.CODELINK_PLATFORM))) { 
	
				if (filterMethod != null && filterMethod.equals("GeneListFilter")) {
					if(!hdf5file){
						int geneListID = Integer.parseInt((String) fieldValues.get("geneListID"));
						GeneList thisGeneList = myGeneList.getGeneList(geneListID, dbConn);
						String geneListFileName = analysisPath + "FilterGeneList.txt";
						fieldValues.put("geneListName", thisGeneList.getGene_list_name()); 
						fieldValues.put("geneListFileName", geneListFileName);
						File myGeneListFile = thisGeneList.writeGeneListToFile(selectedDataset, fieldValues, dbConn);
		
						if (!myGeneListFile.exists() || (myGeneListFile.exists() && myGeneListFile.length() == 0)) {
							mySessionHandler.createDatasetActivity("iDecoder returned no results for gene list filter", dbConn);
							//Error - "No genes found for this chip
							keepGoing = false;
							session.setAttribute("errorMsg", "EXP-014");
										//response.sendRedirect(commonDir + "errorMsg.jsp");
						}
					}else{
						int geneListID = Integer.parseInt((String) fieldValues.get("geneListID"));
						GeneList thisGeneList = myGeneList.getGeneList(geneListID, dbConn);
						fieldValues.put("geneListName", thisGeneList.getGene_list_name()); 
						fieldValues.put("geneListFileName", Integer.toString(geneListID));
					}
				}
				if (filterMethod != null && filterMethod.equals("QTLFilter")) { 
					if(!hdf5file){
						int qtlListID = Integer.parseInt((String) fieldValues.get("qtlListID"));
						QTL thisQTLList = myQTL.getQTLList(qtlListID, dbConn);
		
						String qtlListFileName = analysisPath + "qtlFilterList.txt";
						fieldValues.put("qtlListName", thisQTLList.getQtl_list_name());
						fieldValues.put("qtlListFileName", qtlListFileName);
						/*
						log.debug("qtlListID = "+(String) fieldValues.get("qtlListID"));
						log.debug("qtlListName = "+(String) fieldValues.get("qtlListName"));
						log.debug("qtlListFileName = "+(String) fieldValues.get("qtlListFileName"));
						*/
		
						QTL.EQTL myEQTL = myQTL.new EQTL();
						QTL.EQTL[] theseEQTLs = myEQTL.getExpressionQTLsInList(selectedDataset.getOrganism(), qtlListID, (String) fieldValues.get("tissue"), 0.1, dbConn);
						log.debug("theseEQTLs has "+theseEQTLs.length + " records");
						Set<String> probesetIDs = myEQTL.getProbesetIDs(theseEQTLs);
						myFileHandler.writeFile(myObjectHandler.getAsSeparatedString(probesetIDs, "\n") + "\n", qtlListFileName);
		
						File myQTLListFile = new File(qtlListFileName);
						log.debug("length = " +myQTLListFile.length());
						if (!myQTLListFile.exists() || (myQTLListFile.exists() && myQTLListFile.length() <= 1)) {
							mySessionHandler.createDatasetActivity("there are no results for QTL list filter", dbConn);
							//Error - "No expression qtls found for this QTL list
							keepGoing = false;
							session.setAttribute("errorMsg", "EXP-054");
						}
					}else{
						int qtlListID = Integer.parseInt((String) fieldValues.get("qtlListID"));
						QTL thisQTLList = myQTL.getQTLList(qtlListID, dbConn);
						fieldValues.put("qtlListName", thisQTLList.getQtl_list_name()); 
						fieldValues.put("qtlListFileName", Integer.toString(qtlListID));
					}
					
				}
			}
			

			log.debug("expected duration = "+durationHash.get(filterMethodText));
			//log.debug("fieldValues = "); myDebugger.print(fieldValues);
	
			Hashtable filterParameters = 
				myStatistic.setFilterParameters(userLoggedIn, fieldValues, filterText, selectedDataset);  
	
			log.debug("filterParameters = "); myDebugger.print(filterParameters);
	
			//
			// set the creation time once for all parameter values
			// so they are the same
			//
			myParameterValue.setCreate_date();
	
			//Not sure why these are here, so commenting them out for now
			//session.setAttribute("parameter1", (String) filterParameters.get("parameter1"));
			//session.setAttribute("parameter2", (String) filterParameters.get("parameter2"));
			//session.setAttribute("parameter3", (String) filterParameters.get("parameter3"));
	
			filterMethodText = (String) filterParameters.get("filterMethodText");
			filtersList = (!filterMethodText.equals("") ? filtersList + filterMethodText + ", &nbsp" : filtersList);
	
			log.debug("filtersList here2 = " + filtersList);
			// 
	
			myParameterValue.setParameter_group_id(parameterGroupID);
			myParameterValue.setCategory(filterMethodText);
			myParameterValue.setParameter((String) filterParameters.get("parameter1Text"));
			myParameterValue.setValue((String) filterParameters.get("parameter1Value"));
			myParameterValue.createParameterValue(dbConn);
		
			//
			// Do not create a second record with an empty parameter
			//
			if (filterParameters.get("parameter2Value") != null && 
				!((String) filterParameters.get("parameter2Value")).equals("Null") && 
				!((String) filterParameters.get("parameter2Value")).equals("")) {
				myParameterValue.setParameter_group_id(parameterGroupID);
				myParameterValue.setCategory(filterMethodText);
				myParameterValue.setParameter((String) filterParameters.get("parameter2Text"));
				myParameterValue.setValue((String) filterParameters.get("parameter2Value"));
				myParameterValue.createParameterValue(dbConn);
			}

			//
			// Do not create a third record with an empty parameter
			//
			if (filterParameters.get("parameter3Value") != null && 
				!((String) filterParameters.get("parameter3Value")).equals("Null") 
				&& !((String) filterParameters.get("parameter3Value")).equals("")) {
				myParameterValue.setParameter_group_id(parameterGroupID);
				myParameterValue.setCategory(filterMethodText);
				myParameterValue.setParameter((String) filterParameters.get("parameter3Text"));
				myParameterValue.setValue((String) filterParameters.get("parameter3Value"));
				myParameterValue.createParameterValue(dbConn);
			}
	
			lastCategory = myParameterValue.getCategory();
			log.debug("lastCategory = " + lastCategory);
	
			//
			// If the filter genes process has already been run (i.e., 
			// inputFile exists), then use the output from that run (which is the 
			// inputFile specified above).  Otherwise, use the output from the
			// Normalization R call (i.e., firstInputFile).
			// 
			// Also, if the filter genes process has already been run, make 
			// a copy of the output file in case the user chooses to ignore the 
			// most recent filter
			//
			if(!hdf5file){
				if (!inputFile.exists()) {
					log.debug("input file does not exist -- this is first time");
		
					inputFileName = firstInputFile.getPath(); 
					inputFile = new File(inputFileName);
					myFileHandler.copyFile(firstInputFile, prevInputFile);
					canIgnore = "T";
				} else {
					log.debug("inputFile does exist -- this is NOT first time");
					//log.debug("user chose Run filter, so copying file to PREVIOUS");
					// 
					// copy the current input file and gene count file in case user
					// wants to ignore this filter
					//
					myFileHandler.copyFile(inputFile, prevInputFile); 
		
					if (geneCountFile.exists()) {
						myFileHandler.copyFile(geneCountFile, prevGeneCountFile);
					}
					canIgnore = "T";
				}
			}
	
			log.debug("before call to R_session. here keepGoing = "+keepGoing);
        	long startTime = Calendar.getInstance().getTimeInMillis();
			log.debug("CALLING FILTER:"+(String) filterParameters.get("filterMethodName")+"\nP1:"+(String) filterParameters.get("parameter1")+"\nP2:"+(String) filterParameters.get("parameter2")+"\nP3:"+(String) filterParameters.get("parameter3")+"\n");
			if (keepGoing) {
				try {
						String version="v"+selectedDatasetVersion.getVersion();
						
						
						myStatistic.callFilterGenes(selectedDataset.getPlatform(),
													selectedDataset,
													version,
													inputFile,
													(String) filterParameters.get("filterMethodName"),
													(String) filterParameters.get("parameter1"),
													(String) filterParameters.get("parameter2"),
													(String) filterParameters.get("parameter3"),
													analysisPath,
							geneCountFile,
							outputFileName,
							abnormalPath,
							phenotypeParameterGroupID,
							parameterGroupID,
							firstInputFile);
							canIgnore = "F";
				 } catch (RException e) {
								rExceptionErrorMsg = e.getMessage();
								mySessionHandler.createDatasetActivity("Got RException When Running R Filter Genes Function", dbConn);
								%><%@ include file="/web/datasets/include/rError.jsp" %><%
				}
				long finishTime = Calendar.getInstance().getTimeInMillis();
				int actualDuration = new Long((finishTime - startTime)/1000).intValue();
				log.debug("actualDuration = "+actualDuration);
				myDataset.updateDuration(filterMethod, 
						selectedDataset.getNumber_of_arrays(), num_probes, 
						actualDuration, dbConn);
				mySessionHandler.createDatasetActivity("Successfully Ran this filter: "+filterMethod, dbConn);
			} else if (((String) session.getAttribute("errorMsg")).equals("EXP-014") || ((String) session.getAttribute("errorMsg")).equals("EXP-054")) {
				response.sendRedirect(commonDir + "errorMsg.jsp");
			}
			analysisParameters = myParameterValue.getParameterValues(parameterGroupID, dbConn);
        } else if ((action != null) && action.equals("< Previous")) {
			log.debug("user chose to ignore last filter, so copying the PREVIOUS files\n Start filterList:"+filtersList); 
			//
			// delete the last filter parameter values
			//
			myParameterValue.deleteParameterValuesByCategory(parameterGroupID, lastCategory, dbConn);
			//
			// If the filter genes process has already been run (i.e., 
			// inputFile exists), then use the output from that run (which is the 
			// inputFile specified above).  Otherwise, use the output from the
			// Normalization R call (i.e., firstInputFile).
			// 
			// Also, if the filter genes process has already been run, make 
			// a copy of the output file in case the user chooses to ignore the 
			// most recent filter
			//
			if(!hdf5file){
				if (!inputFile.exists()) {
					log.debug("input file does not exist -- using firstInputFile as the previous file");
					prevInputFile = firstInputFile;
				} else {
					log.debug("input file exists -- using that inputFile as the previous file");
					prevInputFile = prevInputFile; 
				}
				//
				// copy the PREVIOUS file to the existing file name
				//
				myFileHandler.copyFile(prevInputFile, inputFile);
				if (prevGeneCountFile.exists()) {
					myFileHandler.copyFile(prevGeneCountFile, geneCountFile);
					num_probes = Integer.parseInt(myFileHandler.getFileContents(geneCountFile, "noSpaces")[0]);
				} else {
					try {
						myFileHandler.deleteFile(geneCountFile);
					} catch (Exception e) {
						log.error("got error deleting geneCountFile");
					}
				}
				
			}else{
				num_probes=myStatistic.callPreviousFilter(selectedDataset,
													selectedDatasetVersion,
													userLoggedIn.getUser_id(),abnormalPath);
				currentGeneCountMsg = "Current Number of Probes: " + num_probes;
			}
	
			
			canIgnore = "F";
			
			// 
			// Take off the last filter 
			// If the FilterList string has more than one comma, then create a substring
			// which starts at the beginning of filterList and ends at the next-to-last comma.
			// Otherwise, create a null string
			//
			int last=filtersList.lastIndexOf(",");
			int nextLast=-1;
			if(last==-1){
				filtersList="";
			}else{
				nextLast=filtersList.lastIndexOf(",", last-1);
				if(nextLast==-1){
					filtersList="";	
				}else{
					filtersList.substring(0, nextLast+1);
				}
			}
			
			filterMethodText = "";
			mySessionHandler.createDatasetActivity("Removed last filter", dbConn);
			analysisParameters = myParameterValue.getParameterValues(parameterGroupID, dbConn);
			log.debug("end filterList:"+filtersList);
        } else if ((action != null) && action.equals("Next >")) {
			log.debug("user pushed Filter>Next");
			mySessionHandler.createDatasetActivity("Successfully Ran Choose Filters", dbConn);

			%><%@ include file="/web/datasets/include/firstTime.jsp" %><%

			session.setAttribute("num_probes", new Integer(num_probes).toString());
			if(hdf5file){
				log.debug("HDF5 file exists");
				int tmpnumprobe=myStatistic.moveFilterToHDF5(selectedDataset,selectedDatasetVersion,abnormalPath);
				log.debug("beginning of first time");
						String verFDate=(String)session.getAttribute("verFilterDate");
                		String verFTime=(String)session.getAttribute("verFilterTime");
						DSFilterStat tmpDS=new DSFilterStat();
						DSFilterStat dsfs = tmpDS.getFilterStatFromDB(selectedDataset.getDataset_id(), selectedDatasetVersion.getVersion(), userLoggedIn.getUser_id(), verFDate, verFTime, pool);
						if(dsfs.getDSFilterStatID()==0){
							int fsID=selectedDatasetVersion.createFilterStats(verFDate,verFTime,analysisType,userLoggedIn.getUser_id(),pool);
							DSFilterStat tmp=selectedDatasetVersion.getFilterStat(fsID,userLoggedIn.getUser_id(),pool);
							tmp.addFilterStep("Not Filtered","Not Filtered",tmpnumprobe,1,0,0,pool);
						}
			}
			if (!analysisType.equals("cluster")) {
                	response.sendRedirect(datasetsDir + "statistics.jsp" + 
						queryString); 
			} else {
                	response.sendRedirect(datasetsDir + "cluster.jsp" + queryString);
			}
		}

	// 
	// Display the current gene count.  
	//
    if ((action != null) && (geneCountFile.exists())&&(!hdf5file||action.equals("Run Filter"))) { 
			num_probes = Integer.parseInt(myFileHandler.getFileContents(geneCountFile, "noSpaces")[0]);
			log.debug("PROBECOUNT:"+num_probes);
			currentGeneCountMsg = "Current Number of Probes: " + num_probes;
	} else {
			currentGeneCountMsg = "";
	}
	session.setAttribute("currentGeneCountMsg", currentGeneCountMsg);
	session.setAttribute("num_probes", new Integer(num_probes).toString());
	//filtersRun=""+filtersList;
	filtersRun = filtersRun + filtersList;
	log.debug("FILTERS RUN:"+filtersRun);
	formName = "filters.jsp";

%>
	<%@ include file="/web/common/microarrayHeader.jsp" %>

	


<% 
	String typeOfAnalysis = (analysisType.equals("diffExp") || 
				analysisType.equals("correlation") ? 
				"statistical analysis" : "clustering");

%>
	<%@ include file="/web/datasets/include/fillDurationHash.jsp" %>
	<%@ include file="/web/datasets/include/viewingPane.jsp" %>
	<%@ include file="/web/datasets/include/analysisSteps.jsp" %>

	<div class="page-intro" style="width:900px">
		Filters can be applied prior to analysis to limit the number of genes that will be
		tested.  <BR><BR>
		We recommend eliminating probe(set)s that represent controls on the chip 
		(<i>Affy Control Genes Filter/CodeLink Control Genes Filter</i>) and many people eliminate 
		probe(set)s based on present/absent calls (<i>MAS5 Absolute Call Filter/CodeLink Call Filter</i>).<BR><BR>
		Choose a filtering method to specify which probes should remain for further analysis.  
	</div>
	<div style="clear:left"> </div>
	<div class="datasetForm">
	<div style="float:left; width:550px">
	<form method="post" 
		action="<%=formName%>"
		enctype="application/x-www-form-urlencoded"
		name="filters">

		
		<%@ include file="/web/datasets/include/filterChoiceDiv.jsp" %>

		<%@ include file="/web/datasets/include/absCallDiv.jsp" %>
		<%@ include file="/web/datasets/include/negativeControlDiv.jsp" %>
		<%@ include file="/web/datasets/include/codeLinkCallDiv.jsp" %>
		<%@ include file="/web/datasets/include/medianDiv.jsp" %>
		<%@ include file="/web/datasets/include/coeffDiv.jsp" %>
		<%@ include file="/web/datasets/include/negDiv.jsp" %>
		<%@ include file="/web/datasets/include/heritabilityDiv.jsp" %>
		<%@ include file="/web/datasets/include/geneListDiv.jsp" %>
		<%@ include file="/web/datasets/include/qtlListDiv.jsp" %>
		<%@ include file="/web/datasets/include/clusterFilterDiv.jsp" %>
		<%@ include file="/web/datasets/include/flagDiv.jsp" %>
		<%@ include file="/web/datasets/include/bg2sdDiv.jsp" %>
		<%@ include file="/web/datasets/include/lowIntDiv.jsp" %>

		<div style="clear:left"> </div>
		<div id="pageSubmit"> 
			<div class="submit"> <input type="submit" name="action" value="Run Filter"  onClick="return IsChooseFilterFormComplete()"> </div>
			<div class="hint">Execute as many filters as you like before continuing to <%=typeOfAnalysis%>.  <BR>
				<i>Note: Filters <b>ARE</b> cumulative.  Also, you can remove the last filter by pressing the 'Previous' button.</i>
				</div> 
		</div>
		</div><!-- div width=550px -->
		<% //if (!filtersRun.equals("")) { 
			if (analysisParameters != null && analysisParameters.length > 0) {
				myParameterValue.sortParameterValues(analysisParameters, "parameterValueID", "A");
				String message = currentGeneCountMsg;
				log.debug("INCLUDE ANALYSIS PARAMS\n"+message);
			%> 
				<div class="filterResults">
					<%@ include file="/web/common/analysisParameters.jsp" %>
				</div>
			<% } else { log.debug("Parameters not inlucded Analysis param");}
   		//}else { log.debug("filters run empty");} 
		%>
		<div class="brClear"></div>
		<div id="prevNext">
			<% //if (!filtersRun.equals("") && canIgnore.equals("T")) { 
				log.debug("At Previous Button FiltersRun="+filtersRun+";;");
				if (!filtersRun.equals("No Filters Have Been Run Yet")&&!filtersRun.equals("")&&!filtersRun.equals("Filters Already Run: ")) {
			%> 
				<div class="left">
			                <span class="info" title="Remove the last filter executed.">
						<%@ include file="/web/common/previousButton.jsp" %>
                    				<img src="<%=imagesDir%>icons/info.gif" alt="Help">
			                </span>
				</div>
   			<% } %>
			<div class="right">
            	<div id="hdf5-working">Preparing data for statistics<BR /><img src="<%=imagesDir%>wait.gif" alt="Working..." /></div>
				<span class="info" title="Continue to <%=typeOfAnalysis%>.">
                    			<img src="<%=imagesDir%>icons/info.gif" alt="Help">
					<%@ include file="/web/common/nextButton.jsp" %>
				</span>
			</div>
		</div> <!-- end div_id_prevNext -->

		<input type="hidden" name="prevFiltersList" value="<%=filtersList%>">
		<input type="hidden" name="step" value="filter">
		<input type="hidden" name="phenotypeParameterGroupID" value="<%=phenotypeParameterGroupID%>">
		<input type="hidden" name="lastCategory" value="<%=lastCategory%>">
		<input type="hidden" name="canIgnore" value="<%=canIgnore%>">
		<input type="hidden" name="firstTime" value="<%=firstTime%>">
		<input type="hidden" name="thisSessionDate" value="<%=currentDate%>">
		<input type="hidden" name="thisSessionTime" value="<%=currentTime%>">
		<input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>">
		<input type="hidden" name="datasetVersion" value="<%=selectedDatasetVersion.getVersion()%>">
		<input type="hidden" name="datasetPlatform" id="datasetPlatform" value="<%=selectedDataset.getPlatform()%>">
		<input type="hidden" name="numGroups" value="<%=numGroups%>">
		<input type="hidden" name="num_probes" id="num_probes" value="<%=num_probes%>">
		<input type="hidden" name="duration" id="duration" value="">
		<input type="hidden" name="analysisType" id="analysisType" value="<%=analysisType%>">

		</form>
		</div>
		<script type="text/javascript">
            		$(document).ready(function(){
					document.getElementById("hdf5-working").style.display = 'none';
				populateDuration(document.filters.filterMethod.value, document.filters);
				displayParameters();
				setTimeout("setupMain()", 100); 
				setupExpandCollapse();
		            }); // document ready
		</script> <% 
%>
<%@ include file="/web/common/footer.jsp" %>
