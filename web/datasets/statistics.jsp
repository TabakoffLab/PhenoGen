<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  The web page created by this file allows the user to  
 *		select a statistics test. 
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/analysisHeader.jsp"  %>

<%

	log.info("in statistics.jsp.  datasetID = "+selectedDataset.getDataset_id() + 
		", version = "+selectedDatasetVersion.getVersion() + ", user = "+user);
	log.debug("analysisPath = "+ analysisPath);
	boolean ranFilters = true;
	boolean hdf5file=false;
	ParameterValue[] analysisParameters = myParameterValue.getParameterValues(parameterGroupID, dbConn);

	extrasList.add("progressBar.js");
	extrasList.add("arrayTabs.js");
	extrasList.add("statistics.js");
	optionsList.add("datasetVersionDetails");

        int num_probes = ((String) request.getParameter("num_probes") != null ?
                Integer.parseInt((String) request.getParameter("num_probes")) :
			((String) session.getAttribute("num_probes") != null ?
				Integer.parseInt((String) session.getAttribute("num_probes")) :
				45000));

	request.setAttribute( "selectedStep", "4" ); 
	if (analysisType.equals("correlation")) {
		request.setAttribute( "selectedStep", "5" );
	}

	log.debug("num_arrays = "+ selectedDataset.getNumber_of_arrays() + 
		", num_probes here = "+num_probes);
	//log.debug("durationHash = "); myDebugger.print(durationHash);

	String currentGeneCountMsg = (String) session.getAttribute("currentGeneCountMsg");
	Hashtable durationHash = (Hashtable) session.getAttribute("durationHash");

	int num_probes_start = num_probes;

        int footerPosition = 20;

        boolean giveWarning = false;


        String versionType = selectedDatasetVersion.getVersion_type();
	log.debug("versionType = "+versionType);

	String tooSmallGroupsForNonParametricTest = 
		((String) session.getAttribute("tooSmallGroupsForNonParametricTest") != null ?
		(String) session.getAttribute("tooSmallGroupsForNonParametricTest") : "false");

	int numGroups = ((String) session.getAttribute("numGroups") != null ? 
		Integer.parseInt((String) session.getAttribute("numGroups")) : 2);

	Dataset.Group[] groups = (Dataset.Group[]) session.getAttribute("groups");

	log.debug("phenotypeParameterGroupID = "+phenotypeParameterGroupID);
	Hashtable criteriaList = null;
	edu.ucdenver.ccp.PhenoGen.data.Array[] myArrays = null;

	if (phenotypeParameterGroupID == -99) {
		myArrays = selectedDataset.getArrays();

		//
		// Remove all arrays that were 'Excluded'
		//
		User.UserChip[] myChipAssignments = 
			myDataset.new Group().getChipAssignments(selectedDatasetVersion.getGrouping_id(), dbConn);
		User.UserChip myUserChip = new User().new UserChip();
		myChipAssignments = myUserChip.sortUserChips(myChipAssignments, "hybrid_id");
		//log.debug("myArrays contains "+myArrays.length + " arrays");
		//log.debug("myArrays = "); myDebugger.print(myArrays);
		//log.debug("myChipAssignments = "); myDebugger.print(myChipAssignments);
		ArrayList myArrayList = new ArrayList(Arrays.asList(myArrays));
		for (int i=0; i<myChipAssignments.length; i++) {
			User.UserChip thisChip = 
				myUserChip.getUserChipFromMyUserChips(myChipAssignments, myChipAssignments[i].getHybrid_id());
			//log.debug("thisChip hybrid id = " + thisChip.getHybrid_id() + 
				//" and group = " + thisChip.getGroup().getGroup_name());
			if (thisChip.getGroup().getGroup_name().equals("Exclude")) {
				//log.debug("deleting it");
				myArrayList.remove(new edu.ucdenver.ccp.PhenoGen.data.Array(myChipAssignments[i].getHybrid_id()));
			}
		}
		myArrays = 
			(edu.ucdenver.ccp.PhenoGen.data.Array[]) myArrayList.toArray(new edu.ucdenver.ccp.PhenoGen.data.Array[myArrayList.size()]);
		criteriaList = myArray.getCriteriaList(myArrays);
		//log.debug("now myArrays contains "+myArrays.length + " arrays");

	}

	//log.debug("numGroups = "+numGroups);

	fieldNames.add("stat_method");
	fieldNames.add("factor1_criterion");
	fieldNames.add("factor2_criterion");
	fieldNames.add("factor1_name");
	fieldNames.add("factor2_name");
	fieldNames.add("twoWayPValue");
	fieldNames.add("pvalue");
	fieldNames.add("eaves_pvalue");
	if (myArrays != null) {
		for (int i=0; i<myArrays.length; i++) {
			fieldNames.add("factor1_"+i);
			fieldNames.add("factor2_"+i);
		}
	}
	
	
	%><%@ include file="/web/common/getFieldValues.jsp" %><%
	
	log.debug("parameterGroupID = "+parameterGroupID);

	// Put the field values into variables for those that are referenced more than once
	String stat_method = (String) fieldValues.get("stat_method");
	session.setAttribute("stat_method", stat_method);

	log.debug("action = "+action);
	String statisticsRdataFileName = analysisPath + selectedDataset.getPlatform() + 
							".statistics.output.Rdata"; 

	if ((new File(selectedDataset.getPath() + "Affy.NormVer.h5")).exists()) {
			hdf5file = true;
		}

	if (!hdf5file&&
	(selectedDataset.getPlatform().equals(selectedDataset.AFFYMETRIX_PLATFORM) || 
		selectedDataset.getPlatform().equals(selectedDataset.CODELINK_PLATFORM)))  {
		if (!(new File(analysisPath + selectedDataset.getPlatform() + ".filter.genes.output.Rdata")).exists()) {
			// 
			// user went straight to statistics without doing filters
			// 
			ranFilters = false;
		}
	}
	
	
	
	log.debug("ranFilters = "+ranFilters);
	boolean testCompleted = false;
    if (action != null && action.equals("Run Test")) {
		
		//log.debug("fieldValues = "); myDebugger.print(fieldValues);

		log.debug("parameterGroupID = "+parameterGroupID);

		myParameterValue.deleteStatisticsParameterValues(parameterGroupID, dbConn);

		// 
		// set the creation time once for all parameter values
		// so they are the same
		//
		myParameterValue.setCreate_date();

		myParameterValue.setParameter_group_id(parameterGroupID);
		myParameterValue.setCategory("Statistical Method");
		myParameterValue.setParameter("Method");
		myParameterValue.setValue(stat_method);
		myParameterValue.createParameterValue(dbConn);

		// Create another parameter with the p-value
		if (stat_method.equals("1-Way ANOVA")) { 
			myParameterValue.setParameter_group_id(parameterGroupID);
			myParameterValue.setCategory("Statistical Method");
			myParameterValue.setParameter("P-value");
			myParameterValue.setValue((String) fieldValues.get("pvalue"));
			myParameterValue.createParameterValue(dbConn);
		} else if (stat_method.equals("2-Way ANOVA")) { 
			myParameterValue.setParameter_group_id(parameterGroupID);
			myParameterValue.setCategory("Statistical Method");
			myParameterValue.setParameter("P-value");
			myParameterValue.setValue((String) fieldValues.get("twoWayPValue"));
			myParameterValue.createParameterValue(dbConn);

			myParameterValue.setParameter_group_id(parameterGroupID);
			myParameterValue.setCategory("Statistical Method");
			myParameterValue.setParameter("Factor 1");
			myParameterValue.setValue((String) fieldValues.get("factor1_name"));
			myParameterValue.createParameterValue(dbConn);

			myParameterValue.setParameter_group_id(parameterGroupID);
			myParameterValue.setCategory("Statistical Method");
			myParameterValue.setParameter("Factor 2");
			myParameterValue.setValue((String) fieldValues.get("factor2_name"));
			myParameterValue.createParameterValue(dbConn);

			for (int i=0; i<myArrays.length; i++) {
				myParameterValue.setParameter_group_id(parameterGroupID);
				myParameterValue.setCategory("Statistical Method");
				myParameterValue.setParameter("Factor 1 -- " + myArrays[i].getHybrid_name());
				myParameterValue.setValue((String) request.getParameter("factor1_"+i));
				myParameterValue.createParameterValue(dbConn);

				myParameterValue.setParameter("Factor 2 -- " + myArrays[i].getHybrid_name());
				myParameterValue.setValue((String) request.getParameter("factor2_"+i));
				myParameterValue.createParameterValue(dbConn);
			}
		} else if (stat_method.equals("Noise distribution t-test")) { 
			myParameterValue.setParameter_group_id(parameterGroupID);
			myParameterValue.setCategory("Statistical Method");
			myParameterValue.setParameter("P-value");
			myParameterValue.setValue((String)fieldValues.get("eaves_pvalue"));
			myParameterValue.createParameterValue(dbConn);
		}

		String geneCountAfterStatisticsFileName = analysisPath + "GeneCountAfterStatistics.txt";
		String phenotypeName = (phenotypeParameterGroupID == -99 ?  "" : 
					myParameterValue.getPhenotypeName(phenotypeParameterGroupID, dbConn));
                String groupingUserPhenotypeDir = (stat_method.equals("pearson") || stat_method.equals("spearman") ?
				selectedDatasetVersion.getGroupingUserPhenotypeDir(userName, phenotypeName) : "");


		String version="v"+selectedDatasetVersion.getVersion();
		String sampleFile=selectedDataset.getPath()+version+"_samples.txt";
		String inputFile = "";
		if(hdf5file){
			//if (phenotypeParameterGroupID == -99) {
				inputFile =  "'" + selectedDataset.getPath() + "Affy.NormVer.h5'";
				if(selectedDataset.getCreator().equals("public")){
					inputFile="'"+userLoggedIn.getUserDatasetDir() + selectedDataset.getNameNoSpaces() + "/"+"Affy.NormVer.h5'";
				}
			/*}else {
				inputFile="'" +groupingUserPhenotypeDir+"Affy.NormVer.h5'";
				sampleFile=groupingUserPhenotypeDir+version+"_samples.txt";
			}*/
		}else{
			if (ranFilters) {
				inputFile =  "'" + analysisPath + selectedDataset.getPlatform() + ".filter.genes.output.Rdata'";   
			} else {
				// 
				// user went straight to statistics without doing filters
				// 
				if (phenotypeParameterGroupID == -99) {  
					inputFile = "'" + selectedDatasetVersion.getNormalized_RData_FileName() + "'";
				} else { 
					inputFile = "'" + selectedDatasetVersion.getNormalizedForGrouping_RData_FileName(groupingUserPhenotypeDir) + "'";

					if (!new File(inputFile).exists()) {
						inputFile = "'" + selectedDatasetVersion.getNormalized_RData_FileName() + "'";
					}
				}
			}
		}
		log.debug("inputFile = "+inputFile);
		String outputFile = "'" + analysisPath + selectedDataset.getPlatform() + ".statistics.output.Rdata'"; 
		long startTime = 0;
		startTime = Calendar.getInstance().getTimeInMillis();
                String duration_method = stat_method;
		log.debug("expected duration = "+durationHash.get(duration_method));
		
        boolean async=false;        
		try {
			if (stat_method.equals("2-Way ANOVA")) {
                        	async=myStatistic.call2WayAnovaStatistics(selectedDataset,
                                                        inputFile,
														version,
                                                        outputFile,
                                                        geneCountAfterStatisticsFileName,
							myArrays,
							fieldValues,
							analysisPath);
			} else if (stat_method.equals("pearson") || stat_method.equals("spearman")) {
                        	async=myStatistic.callCorrelationStatistics(selectedDataset.getPlatform(),
													selectedDataset,
                                             		inputFile,
													version,
													sampleFile,
                                                        stat_method,
                                                        outputFile,
                                                        geneCountAfterStatisticsFileName,
							groupingUserPhenotypeDir,
							analysisPath);
			} else {
				String pvalue = "";
				if (stat_method.equals("1-Way ANOVA")) {
					pvalue = (String) fieldValues.get("pvalue");
				} else if (stat_method.equals("2-Way ANOVA")) {
					pvalue = (String) fieldValues.get("twoWayPValue");
				} else if (stat_method.equals("Noise distribution t-test")) {
					pvalue = (String) fieldValues.get("eaves_pvalue");
				}
							
                        	async=myStatistic.callStatistics(selectedDataset.getPlatform(),
                                                        inputFile,
														selectedDataset.getDataset_id(),
														version,
														sampleFile,
                                                        stat_method,
                                                        outputFile,
                                                        geneCountAfterStatisticsFileName,
							pvalue,
							analysisPath);
			}
			if(async){
                 session.setAttribute("successMsg", "EXP-057");
                 response.sendRedirect(datasetsDir + "listDatasets.jsp");
			}
			long finishTime = Calendar.getInstance().getTimeInMillis();
			int actualDuration = new Long((finishTime - startTime)/1000).intValue();
			log.debug("Just before updating duration. "+
					//num_arrays = "+ selectedDataset.getNumber_of_arrays() + 
					//", num_probes_start here = "+num_probes_start + 
					//", duration_method used for updating = "+duration_method +
						" actualDuration = "+actualDuration);
			selectedDataset.updateDuration(duration_method, 
					selectedDataset.getNumber_of_arrays(), num_probes_start,
					actualDuration, dbConn);
        		num_probes = Integer.parseInt(myFileHandler.getFileContents(new File(geneCountAfterStatisticsFileName), "noSpaces")[0]);
			//currentGeneCountMsg = "<b>Number of Statistically Significant Probes:" + twoSpaces + "</b>" + num_probes;
			currentGeneCountMsg = "<BR> Statistical Test Complete. <BR>" + currentGeneCountMsg;
			log.debug("after call to Statistics."); 
			analysisParameters = myParameterValue.getParameterValues(parameterGroupID, dbConn);
			testCompleted = true;
                } catch (IOException e) {
			log.debug("IOException", e);
                } catch (RException e) {
                        rExceptionErrorMsg = e.getMessage();
			log.debug("RException = "+rExceptionErrorMsg);
			if (rExceptionErrorMsg.indexOf("Model is over-parameterized") > -1) {
				mySessionHandler.createDatasetActivity("Got RException When Running OverParameterization Function", dbConn);
			} else {
				mySessionHandler.createDatasetActivity("Got RException When Running R Statistics Function", dbConn);
			}
                        %><%@ include file="/web/datasets/include/rError.jsp" %><%
		}
		mySessionHandler.createDatasetActivity("Successfully ran statistics test", dbConn);
	} else if (action != null && action.equals("Next >")) {
			if (!stat_method.equals("Noise distribution t-test")) { 
				response.sendRedirect("multipleTest.jsp" + queryString);
			} else {
				try {
							String groupFile=selectedDatasetVersion.getGroupFileName();
							if(hdf5file){
								statisticsRdataFileName = selectedDataset.getPath() + "Affy.NormVer.h5";
								groupFile=selectedDataset.getPath() + "v"+selectedDatasetVersion.getVersion()+"_groups.txt";
							}
							String version="v"+selectedDatasetVersion.getVersion();
							String sampleFile=selectedDataset.getPath()+version+"_samples.txt";
                			myStatistic.callOutputGeneList(selectedDataset.getPlatform(),
										statisticsRdataFileName,
										version,
										sampleFile,
										groupFile,
                                        analysisPath);
					mySessionHandler.createDatasetActivity("Saving gene list", dbConn);
				} catch (RException e) {
                			rExceptionErrorMsg = e.getMessage();
					mySessionHandler.createDatasetActivity("Got Error When Running R OutputGeneList Function after doing Noise Distribution test",
                        			dbConn);
                        		%><%@ include file="/web/datasets/include/rError.jsp" %><%
				}
                		response.sendRedirect(datasetsDir + "nameGeneListFromAnalysis.jsp" + queryString);
			}
	} else if (action != null && action.equals("< Previous")) {
                response.sendRedirect(datasetsDir + "filters.jsp" + queryString);
	}
	formName = "statistics.jsp";
%>


	<%@ include file="/web/common/microarrayHeader.jsp" %>
    <%  log.debug("past include /web/common/microarrayHeader.jsp");%>

	<%@ include file="/web/datasets/include/viewingPane.jsp" %>
    <%  log.debug("past include /web/datasets/include/viewingPane.jsp");%>
    
        <%@ include file="/web/datasets/include/analysisSteps.jsp" %>
        <%  log.debug("past include /web/datasets/include/analysisSteps.jsp");%>

		<%@ include file="/web/datasets/include/fillDurationHash.jsp" %>
        <%  log.debug("past include /web/datasets/include/fillDurationHash.jsp");%>
		<div class="page-intro">
		Select the type of statistics test you would like to run.  
		<% if (!ranFilters) { %>
			<p>NOTE: It appears that you did not remove any probes during the filtering process.  Although this is okay, you may want to consider 
			running some filters prior to running statistics.  You may press "Previous" to return to the filters page.</p>
		<% } %>
		</div>
		<div style="clear:left"> </div>
        	<div class="datasetForm">
		<div style="float:left; width:550px">
		<form	method="post" 
			action="<%=formName%><%=queryString%>" 
			enctype="application/x-www-form-urlencoded"
			onSubmit="showNonParametricWarning(<%=giveWarning%>)"
			name="statistics">


			<%@ include file="/web/datasets/include/topStatsDiv.jsp" %>
            <%  log.debug("past include /web/datasets/include/fillDurationHash.jsp");%>

			<%@ include file="/web/datasets/include/eavesDiv.jsp" %>
            <%  log.debug("past include /web/datasets/include/eavesDiv.jsp");%>
            
			<%@ include file="/web/datasets/include/oneWayAnovaDiv.jsp" %>
            <%  log.debug("past include /web/datasets/include/oneWayAnovaDiv.jsp");%>
            
			<%@ include file="/web/datasets/include/twoWayAnovaDiv.jsp" %>
            <%  log.debug("past include /web/datasets/include/twoWayAnovaDiv.jsp");%>


                	<div class="brClear"> </div>
			<div id="pageSubmit">
				<div class="submit"><input type="submit" name="action" value="Run Test"  onClick="return IsStatisticsFormComplete()"></div>
			</div>
		</div> <!-- div width550px -->

			<% 
			if (analysisParameters != null) {
				myParameterValue.sortParameterValues(analysisParameters, "parameterValueID", "A");
				String message = currentGeneCountMsg;
				%>
				<div class="filterResults">
					<%@ include file="/web/common/analysisParameters.jsp" %>
				</div>
			<% } %>
			<div class="brClear"></div>
			<div id="prevNext">
				<div class="left">
			                <span class="info" title="Return to filtering.">
						<%@ include file="/web/common/previousButton.jsp" %>
                    				<img src="<%=imagesDir%>icons/info.gif" alt="Help">
			                </span>
				</div>
				<% if (testCompleted) { %>
					<div class="right">
                    
						<span class="info" title="Continue to multiple testing adjustment.">
                    					<img src="<%=imagesDir%>icons/info.gif" alt="Help">
							<%@ include file="/web/common/nextButton.jsp" %>
						</span>
					</div>
				<% } %>
			</div> <!-- end div_id_prevNext -->


			<input type="hidden" name="datasetID" value=<%=selectedDataset.getDataset_id()%>>
			<input type="hidden" name="datasetVersion" value=<%=selectedDatasetVersion.getVersion()%>>
			<input type="hidden" name="numGroups" value=<%=numGroups%>>
			<input type="hidden" name="phenotypeParameterGroupID" value=<%=phenotypeParameterGroupID%>>
			<input type="hidden" name="duration" id="duration" value="">
			<input type="hidden" name="analysisType" id="analysisType" value="<%=analysisType%>">
			<input type="hidden" name="number_of_arrays" id="number_of_arrays" value="<%=selectedDataset.getNumber_of_arrays()%>">
			<input type="hidden" name="number_of_groups" id="number_of_groups" value="<%=selectedDatasetVersion.getNumber_of_non_exclude_groups()%>">
			<input type="hidden" name="number_of_probes" id="number_of_probes" value="<%=num_probes%>">

		</form>
		</div>

		<script type="text/javascript">
			populateDuration(document.statistics.stat_method.value, document.statistics);
			displayOnLoad();
           	$(document).ready(function(){
				setupPage();
				setupExpandCollapse();
			}); // document ready
		</script> 
		<div style="clear:both; float:none; height:5px;">&nbsp;</div>


<%@ include file="/web/common/footer.jsp" %>
