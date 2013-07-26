<%--
 *  Author: Cheryl Hornbaker
 *  Created: July, 2008
 *  Description:  The web page created by this file allows the user to  
 *		select a multiple test method.
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/analysisHeader.jsp"  %>

<%
	log.info("in multipleTest.jsp.  datasetID = "+selectedDataset.getDataset_id() + 
		", version = "+selectedDatasetVersion.getVersion() + ", user = "+user);
	log.debug("analysisPath = "+ analysisPath);
	ParameterValue[] analysisParameters = myParameterValue.getParameterValues(parameterGroupID, dbConn);

	extrasList.add("progressBar.js");
	extrasList.add("multipleTest.js");
	optionsList.add("datasetVersionDetails");

        int num_probes = ((String) request.getParameter("num_probes") != null ?
                Integer.parseInt((String) request.getParameter("num_probes")) :
			((String) session.getAttribute("num_probes") != null ?
				Integer.parseInt((String) session.getAttribute("num_probes")) :
				45000));

	request.setAttribute( "selectedStep", "5" ); 
	if (analysisType.equals("correlation")) {
		request.setAttribute( "selectedStep", "6" );
	}
	boolean hdf5file=false;
	log.debug("num_arrays = "+ selectedDataset.getNumber_of_arrays() + 
		", num_probes here = "+num_probes);

	String currentGeneCountMsg = (String) session.getAttribute("currentGeneCountMsg");

	int numGroups = ((String) session.getAttribute("numGroups") != null ? 
		Integer.parseInt((String) session.getAttribute("numGroups")) : 2);

	log.debug("phenotypeParameterGroupID = "+phenotypeParameterGroupID);

	log.debug("numGroups = "+numGroups);

	fieldNames.add("mt_method");
	fieldNames.add("pvalue");
	fieldNames.add("fdr_parameter2");
	fieldNames.add("testTypeDiv_parameter2");
	fieldNames.add("testTypeDiv_parameter3");
	fieldNames.add("storey_parameter2");
	fieldNames.add("stat_method");

	%><%@ include file="/web/common/getFieldValues.jsp" %><%

	//fieldValues.put("stat_method", (String) session.getAttribute("stat_method"));
	// Put the field values into variables for those that are referenced more than once
	String mt_method = (String) fieldValues.get("mt_method");
	String stat_method = (String) fieldValues.get("stat_method");

	log.debug("action = "+action);
        if (action != null && action.equals("Run Adjustment")) {
		log.debug("fieldValues = "); myDebugger.print(fieldValues);

		myParameterValue.deleteMultipleTestParameterValues(parameterGroupID, dbConn);

		myParameterValue.setCreate_date();
		if ((new File(selectedDataset.getPath() + "Affy.NormVer.h5")).exists()) {
			// 
			// user went straight to statistics without doing filters
			// 
			hdf5file = true;
		}
		String statisticsRdataFileName = analysisPath + selectedDataset.getPlatform() + 
								".statistics.output.Rdata"; 
		String multipleTestRdataFileName = analysisPath + selectedDataset.getPlatform() + 
								".multipleTest.output.Rdata"; 
		String geneCountAfterMultipleTestFileName = analysisPath + 
								"GeneCountAfterMultipleTest.txt";

		
		String version="v"+selectedDatasetVersion.getVersion();
		String sampleFile=selectedDataset.getPath()+version+"_samples.txt";
		
		if(hdf5file){
			statisticsRdataFileName = selectedDataset.getPath() + "Affy.NormVer.h5";
			multipleTestRdataFileName = selectedDataset.getPath() + "Affy.NormVer.h5";
			if(selectedDataset.getCreator().equals("public")){
				if(phenotypeParameterGroupID==-99){
					statisticsRdataFileName=userLoggedIn.getUserDatasetDir() + selectedDataset.getNameNoSpaces() + "/"+"Affy.NormVer.h5";
					multipleTestRdataFileName=userLoggedIn.getUserDatasetDir() + selectedDataset.getNameNoSpaces() + "/"+"Affy.NormVer.h5";
				}else{
					String thisPhenotypeName = myParameterValue.getPhenotypeName(phenotypeParameterGroupID, dbConn);
                	String groupingUserPhenotypeDir = 
						selectedDatasetVersion.getGroupingUserPhenotypeDir(userName, thisPhenotypeName);
					//statisticsRdataFileName=groupingUserPhenotypeDir +"Affy.NormVer.h5";
					//multipleTestRdataFileName=groupingUserPhenotypeDir +"Affy.NormVer.h5";
					//sampleFile=groupingUserPhenotypeDir+version+"_samples.txt";
					statisticsRdataFileName=userLoggedIn.getUserDatasetDir() + selectedDataset.getNameNoSpaces() + "/"+"Affy.NormVer.h5";
					multipleTestRdataFileName=userLoggedIn.getUserDatasetDir() + selectedDataset.getNameNoSpaces() + "/"+"Affy.NormVer.h5";
					sampleFile=userLoggedIn.getUserDatasetDir() + selectedDataset.getNameNoSpaces() + "/"+version+"_samples.txt";
				}
			}
		}
		
		log.debug("before param creation");
		if (!stat_method.equals("Noise distribution t-test")) {
			log.debug("after call to Statistics."); 
                	Hashtable mtParameters = myStatistic.setMTParameters(fieldValues);
                	log.debug("mtParameters = "); myDebugger.print(mtParameters);

                	//
                	// set the creation time once for all parameter values
                	// so they are the same
                	//
                	myParameterValue.setCreate_date();

                	myParameterValue.setParameter_group_id(parameterGroupID);
                	myStatistic.createMTParameters(mtParameters, myParameterValue, dbConn);
					
			try {
                        	myStatistic.callMultipleTest(selectedDataset.getPlatform(),
                                				statisticsRdataFileName,
												version,
												selectedDataset.getDataset_id(),
                                                multipleTestRdataFileName,
								(String) mtParameters.get("mtMethodName"),
                                                               	geneCountAfterMultipleTestFileName,
								(String) mtParameters.get("mcc_parameter1"),
								(String) mtParameters.get("mcc_parameter2"),
								(String) mtParameters.get("mcc_parameter3"),
								(String) mtParameters.get("mcc_parameter4"),
								analysisPath);
				num_probes = Integer.parseInt(myFileHandler.getFileContents(new File(geneCountAfterMultipleTestFileName), "noSpaces")[0]);
				currentGeneCountMsg = "<b>Number of Statistically Significant Probes:" + twoSpaces + "</b>" + num_probes;
				try {
					String groupFile=selectedDatasetVersion.getGroupFileName();
					if(hdf5file){
						groupFile=selectedDataset.getPath() + "v"+selectedDatasetVersion.getVersion()+"_groups.txt";
					}
					myStatistic.callOutputGeneList(selectedDataset.getPlatform(), 
											multipleTestRdataFileName,
											version,
											sampleFile,
											groupFile,
											analysisPath);
				} catch (RException e) {
							rExceptionErrorMsg = e.getMessage();
							mySessionHandler.createDatasetActivity("Got Error When Running R OutputGeneList Function", dbConn);
							%><%@ include file="/web/datasets/include/rError.jsp" %><%
				}

			} catch (RException e) {
                        			rExceptionErrorMsg = e.getMessage();
						log.debug("RException = "+rExceptionErrorMsg);
						mySessionHandler.createDatasetActivity("Got RException When Running R MultipleTest Function", dbConn);
                        			%><%@ include file="/web/datasets/include/rError.jsp" %><%
                	} catch (IOException e) {
				log.debug("IOException", e);
			}
		} else {
			myParameterValue.setParameter_group_id(parameterGroupID);
			myParameterValue.setCategory("Statistical Method");
			myParameterValue.setParameter("P-value");
			myParameterValue.setValue((String)fieldValues.get("pvalue"));
			myParameterValue.createParameterValue(dbConn);
		}
		analysisParameters = myParameterValue.getParameterValues(parameterGroupID, dbConn);
		mySessionHandler.createDatasetActivity("Successfully Ran Multiple Test", dbConn);
	} else if (action != null && action.equals("< Previous")) {
        	response.sendRedirect(datasetsDir + "statistics.jsp" + queryString);
	} else if (action != null && action.equals("Next >")) {
		mySessionHandler.createDatasetActivity("Going to save gene list", dbConn);
        	response.sendRedirect(datasetsDir + "nameGeneListFromAnalysis.jsp" + queryString);
	}

	formName = "multipleTest.jsp";
%>


	<%@ include file="/web/common/microarrayHeader.jsp" %>

	<%@ include file="/web/datasets/include/viewingPane.jsp" %>
        <%@ include file="/web/datasets/include/analysisSteps.jsp" %>
        <BR><BR>

		<div class="page-intro">
		Select the method you would like to use to adjust your p-value for the number of probe(set)s that are 
		being tested.  The false discovery rate (FDR) methods are recommended and most
		often used.  <i>Benjamini and Hochberg</i> is the original and most popular form of FDR, but the
		<i>Storey</i> method has been gaining in popularity for use in microarray data.
		</div>
		<div style="clear:left"> </div>
		<div class="datasetForm">
		<div style="float:left; width:550px">
		<form	method="post" 
			action="<%=formName%><%=queryString%>" 
			enctype="application/x-www-form-urlencoded"
			name="multipleTest">

				<%@ include file="/web/datasets/include/mtDiv.jsp" %>
				<%@ include file="/web/datasets/include/alphaDiv.jsp" %>
				<%@ include file="/web/datasets/include/testTypeDiv.jsp" %>
				<%@ include file="/web/datasets/include/storeyDiv.jsp" %>


                	<div style="clear:left"> </div>
			<div id="pageSubmit">
				<div class="submit"><input type="submit" name="action" value="Run Adjustment"  onClick="return IsMultipleTestFormComplete()"></div>
				<div class="hint">Try as many adjustments as you like until you are satisfied with the number of statistically significant probes. <BR><i>Note:<%=twoSpaces%>Adjustments are NOT cumulative.</i></div> 
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
			                <span class="info" title="Return to statistical test.">
						<%@ include file="/web/common/previousButton.jsp" %>
                    				<img src="<%=imagesDir%>icons/info.gif" alt="Help">
			                </span>
				</div>
				<% if (action != null && num_probes > 0) { %>
					<div class="right">
						<span class="info" title="Save gene list.">
                    					<img src="<%=imagesDir%>icons/info.gif" alt="Help">
							<%@ include file="/web/common/nextButton.jsp" %>
						</span>
					</div>
				<% }%> 
			</div> <!-- end div_id_prevNext -->

			<input type="hidden" name="datasetID" value=<%=selectedDataset.getDataset_id()%>>
			<input type="hidden" name="datasetVersion" value=<%=selectedDatasetVersion.getVersion()%>>
			<input type="hidden" name="analysisType" value=<%=analysisType%>>
			<input type="hidden" name="numGroups" value=<%=numGroups%>>
			<input type="hidden" name="num_probes" id="num_probes" value=<%=num_probes%>>
			<!-- Hard-code the duration since it is short, but now the Working box will show up -->
			<input type="hidden" name="duration" id="duration" value="8">
			<input type="hidden" name="phenotypeParameterGroupID" value=<%=phenotypeParameterGroupID%>>


		</form>
		</div>

		<script type="text/javascript">
			displayOnLoad();
			setupExpandCollapse();
		</script> 
<%@ include file="/web/common/footer.jsp" %>
