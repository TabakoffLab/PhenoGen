<%--
 *  Author: Cheryl Hornbaker
 *  Created: July, 2008
 *  Description:  The web page created by this file allows the user to  
 *		execute a cluster analysis
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/analysisHeader.jsp"  %>

<%

	log.info("in cluster.jsp.  datasetID = "+selectedDataset.getDataset_id() + 
		", version = "+selectedDatasetVersion.getVersion() + ", user = "+user);
	log.debug("analysisPath = "+ analysisPath);

	extrasList.add("progressBar.js");
	extrasList.add("cluster.js");
	optionsList.add("datasetVersionDetails");

	boolean ranFilters = true;
	boolean hdf5file=false;
	boolean async=false;
	String clusterObjectText = "";
    String clusterObject = "";

	ParameterValue[] analysisParameters = myParameterValue.getParameterValues(parameterGroupID, dbConn);
	if (analysisParameters != null && analysisParameters.length > 1) {
		myParameterValue.sortParameterValues(analysisParameters, "parameterValueID", "A");
	}

	request.setAttribute( "selectedStep", "4" ); 

        int newParameterGroupID = -99;
        int clusterGroupID = ((String) request.getParameter("newParameterGroupID") != null ?
                Integer.parseInt((String) request.getParameter("newParameterGroupID")) :
                -99);
		if(clusterGroupID>0){
			newParameterGroupID=clusterGroupID;
			analysisParameters = myParameterValue.getParameterValues(newParameterGroupID, dbConn);
                	if (analysisParameters != null && analysisParameters.length > 1) {
                        	myParameterValue.sortParameterValues(analysisParameters, "parameterValueID", "A");
                	}
                	for (int i=0; i<analysisParameters.length; i++) {
                        	if (analysisParameters[i].getParameter().equals("Cluster Object")) {
                                	clusterObject = analysisParameters[i].getValue();
                        	}
                	}
                	clusterObjectText = (clusterObject.equals("genes") ? "probes" : clusterObject);
		}
        int num_probes = ((String) request.getParameter("num_probes") != null ?
                Integer.parseInt((String) request.getParameter("num_probes")) :
                45000);

	log.debug("num_arrays = "+ selectedDataset.getNumber_of_arrays() + 
		", num_probes here = "+num_probes);

	String currentGeneCountMsg = (String) session.getAttribute("currentGeneCountMsg");
	Hashtable durationHash = (Hashtable) session.getAttribute("durationHash");
	if(durationHash==null){
		durationHash = myDataset.getExpectedDuration(selectedDataset.getNumber_of_arrays(), num_probes, dbConn);
		session.setAttribute("durationHash", durationHash);
	}
	log.debug("durationHash = "); myDebugger.print(durationHash);

	num_probes = ((String) session.getAttribute("num_probes") != null ?
				Integer.parseInt((String) session.getAttribute("num_probes")) :
				45000);
	int num_probes_start = num_probes;
	log.debug("now num_probes = "+num_probes);

        int footerPosition = 20;

        boolean giveWarning = false;

        

	int numGroups = ((String) session.getAttribute("numGroups") != null ? 
		Integer.parseInt((String) session.getAttribute("numGroups")) : 2);

	// Is this needed?
	Dataset.Group[] groups = (Dataset.Group[]) session.getAttribute("groups");

        analysisType = "cluster";
	String versionType = selectedDatasetVersion.getVersion_type();

	if ((new File(selectedDataset.getPath() + "Affy.NormVer.h5")).exists()) {
			hdf5file = true;
			log.debug("clustering HDF5 file exists");
		}
	//log.debug("numGroups = "+numGroups);

	fieldNames.add("cluster_method");
	fieldNames.add("distanceHierarch");
	fieldNames.add("distanceKmeans");
	fieldNames.add("clusterObjectHierarch"); 
	fieldNames.add("clusterObjectKmeans"); 
	fieldNames.add("groupMeansHierarch"); 
	fieldNames.add("groupMeansKmeans"); 
	fieldNames.add("numClustersKmeans"); 
	fieldNames.add("numClustersHierarch"); 
	fieldNames.add("dissimilar"); 

	%><%@ include file="/web/common/getFieldValues.jsp" %><%

	// Put the field values into variables for those that are referenced more than once
	String cluster_method = (String) fieldValues.get("cluster_method");
	String distanceHierarch = (String) fieldValues.get("distanceHierarch");
	String distanceKmeans = (String) fieldValues.get("distanceKmeans");
	String clusterObjectHierarch = (String) fieldValues.get("clusterObjectHierarch");
	String clusterObjectKmeans = (String) fieldValues.get("clusterObjectKmeans");
	String groupMeansHierarch = (String) fieldValues.get("groupMeansHierarch");
	String groupMeansKmeans = (String) fieldValues.get("groupMeansKmeans");
	String groupMeans = (cluster_method.equals("hierarch") ? groupMeansHierarch : groupMeansKmeans);
	String groupMeansBoolean = (groupMeans.equals("NA") ? "FALSE" : groupMeans);
	String numClustersKmeans = (String)fieldValues.get("numClustersKmeans"); 
	String numClustersHierarch = (String)fieldValues.get("numClustersHierarch"); 
        String dissimilar = (String) fieldValues.get("dissimilar"); 

	boolean continueWithOutput = true;
	log.debug("action = "+action);

	if (selectedDataset.getPlatform().equals(selectedDataset.AFFYMETRIX_PLATFORM) || 
		selectedDataset.getPlatform().equals(selectedDataset.CODELINK_PLATFORM))  {
		if (!(new File(analysisPath + selectedDataset.getPlatform() + ".filter.genes.output.Rdata")).exists()) {
			// 
			// user went straight to statistics without doing filters
			// 
			ranFilters = false;
		}
	}
	log.debug("ranFilters = "+ranFilters);
	//log.debug("fieldValues = "); myDebugger.print(fieldValues);
        //if (action != null && action.equals("Next >")) {
    if (action != null && action.equals("Run")) {

		// 
		// set the creation time once for all parameter values
		// so they are the same
		//
		myParameterValue.setCreate_date();

		String inputFile = "";
		String outputFile = "";

		if (selectedDataset.getPlatform().equals(selectedDataset.AFFYMETRIX_PLATFORM) || 
			selectedDataset.getPlatform().equals(selectedDataset.CODELINK_PLATFORM))  {
			String prefix = "";
			if ((new File(analysisPath + selectedDataset.getPlatform() + ".filter.genes.output.Rdata")).exists()) {
				inputFile = "'" + analysisPath + selectedDataset.getPlatform() + ".filter.genes.output.Rdata'"; 
			// 
			// user went straight to clustering without doing filters
			// 
			} else {
				inputFile = "'" + selectedDatasetVersion.getNormalized_RData_FileName() + "'";
			}
			
			outputFile = "'" + analysisPath + selectedDataset.getPlatform() + ".statistics.output.Rdata'"; 
		}

		String clusterObjectRaw = (cluster_method.equals("hierarch") ? clusterObjectHierarch : clusterObjectKmeans);
		log.debug("clusterObjectRaw = "+clusterObjectRaw);
		String distance = (cluster_method.equals("hierarch") ? distanceHierarch : distanceKmeans);
                clusterObject = (clusterObjectRaw.equals("groups") ? "samples" : clusterObjectRaw);
		clusterObjectText = (groupMeansBoolean.equals("TRUE") ?
                                                        (clusterObject.equals("samples") ? "groups" :
                                                                (clusterObject.equals("genes") ? "probes" : clusterObject)) :
                                                        (clusterObject.equals("genes") ? "probes" : clusterObject));

		String numClusters = (cluster_method.equals("hierarch") ? numClustersHierarch : numClustersKmeans);
		String parameter1 = (cluster_method.equals("hierarch") ? "'" + dissimilar + "'" : numClusters);
		String parameter2 = (cluster_method.equals("hierarch") && !clusterObject.equals("both") ?
                                                                numClusters : "-99");
		long startTime = 0;
		startTime = Calendar.getInstance().getTimeInMillis();
		log.debug("expected duration = "+durationHash.get(cluster_method + clusterObject));
		String version="v"+selectedDatasetVersion.getVersion();
		if(hdf5file){
			inputFile =  "'" + selectedDataset.getPath() + "Affy.NormVer.h5'";
			if(selectedDataset.getCreator().equals("public")){
				inputFile="'"+userLoggedIn.getUserDatasetDir() + selectedDataset.getNameNoSpaces() + "/"+"Affy.NormVer.h5'";
			}
		}
		newParameterGroupID = myParameterValue.copyParameters(parameterGroupID, dbConn);
                try {
                        async=myStatistic.callClusterStatistics(selectedDataset,
                				inputFile,
								version,
								newParameterGroupID,
                                                cluster_method,
						selectedDatasetVersion.getGroupFileName(),
						distance, 
						clusterObject,
						groupMeansBoolean,
						parameter1,
						parameter2,
						analysisPath);
			long finishTime = Calendar.getInstance().getTimeInMillis();
			int actualDuration = new Long((finishTime - startTime)/1000).intValue();
                	String duration_method = cluster_method;
			if (cluster_method.equals("hierarch")  ||
				cluster_method.equals("kmeans")) {
				duration_method = duration_method + 
					(cluster_method.equals("hierarch") ? clusterObjectHierarch : clusterObjectKmeans);
			}
			log.debug("Just before updating duration. "+
					//num_arrays = "+ selectedDataset.getNumber_of_arrays() + 
					//", num_probes_start here = "+num_probes_start + 
					", duration_method used for updating = "+duration_method +
						" actualDuration = "+actualDuration);
			selectedDataset.updateDuration(duration_method, 
					selectedDataset.getNumber_of_arrays(), num_probes_start,
					actualDuration, dbConn);
			mySessionHandler.createDatasetActivity("Successfully Ran Clustering", dbConn);
			// 
			// Create parameter values when saving cluster results or gene list
			//
			

			log.debug("newParameterGroupID from copyParams = "+newParameterGroupID);
			myParameterValue.setCreate_date();
			myParameterValue.setParameter_group_id(newParameterGroupID);

                	myParameterValue.setCategory("Statistical Method");
                	myParameterValue.setParameter("Method");
                	myParameterValue.setValue(cluster_method);
                	myParameterValue.createParameterValue(dbConn);

			myParameterValue.setCategory("Cluster");

			myParameterValue.setParameter("Cluster Object");
			myParameterValue.setValue(((String) fieldValues.get("cluster_method")).equals("hierarch") ? 
							(String) fieldValues.get("clusterObjectHierarch") : 
							(String) fieldValues.get("clusterObjectKmeans"));
			myParameterValue.createParameterValue(dbConn);

			myParameterValue.setParameter("Expression Values Used");
			myParameterValue.setValue(groupMeans.equals("TRUE") ? "group" : "sample");
			myParameterValue.createParameterValue(dbConn);

			myParameterValue.setParameter("Distance Measure");
			myParameterValue.setValue(distance);
			myParameterValue.createParameterValue(dbConn);

			myParameterValue.setParameter("Number of Probes");
			myParameterValue.setValue(Integer.toString(num_probes));
			myParameterValue.createParameterValue(dbConn);

			if (dissimilar != null && !dissimilar.equals("")) {
				myParameterValue.setParameter("Dissimilarity Measure");
				myParameterValue.setValue("'" + dissimilar + "'");
				myParameterValue.createParameterValue(dbConn);
			}

			if (!clusterObject.equals("both")) {
				myParameterValue.setParameter("Number of Clusters");
				//log.debug("numClustersHieararch = "+(String) fieldValues.get("numClustersHierarch"));
				//log.debug("numClustersKmeans = "+(String) fieldValues.get("numClustersKmeans"));
				myParameterValue.setValue(numClusters);
				myParameterValue.createParameterValue(dbConn);
			}
			if (selectedDataset.getCreator().equals("public")) {
				myParameterValue.setParameter("User ID");
				myParameterValue.setValue(Integer.toString(userLoggedIn.getUser_id()));
				myParameterValue.createParameterValue(dbConn);
			}
                	analysisParameters = myParameterValue.getParameterValues(newParameterGroupID, dbConn);
                	if (analysisParameters != null && analysisParameters.length > 1) {
                        	myParameterValue.sortParameterValues(analysisParameters, "parameterValueID", "A");
                	}
                	for (int i=0; i<analysisParameters.length; i++) {
                        	if (analysisParameters[i].getParameter().equals("Cluster Object")) {
                                	clusterObject = analysisParameters[i].getValue();
                        	}
                	}
                	clusterObjectText = (clusterObject.equals("genes") ? "probes" : clusterObject);
			if(async){
                 session.setAttribute("successMsg", "EXP-057");
                 response.sendRedirect(datasetsDir + "listDatasets.jsp");
			}
		} catch (RException e) {
                	rExceptionErrorMsg = e.getMessage();
			log.debug("RException = "+rExceptionErrorMsg);
			if (rExceptionErrorMsg.indexOf("had a zero variance") > -1) {
				mySessionHandler.createDatasetActivity("Got No Variance Warning When Running R Cluster Function", dbConn);
                		%><%@ include file="/web/datasets/include/rWarning.jsp" %><%
			} else {
				mySessionHandler.createDatasetActivity("Got RException When Running R Cluster Function", dbConn);
                		%><%@ include file="/web/datasets/include/rError.jsp" %><%
			}
		}
	} else if (action != null && action.equals("Save Gene List")) {
		String version="v"+selectedDatasetVersion.getVersion();
		String sampleFile=selectedDataset.getPath()+version+"_samples.txt";
		try {
			myStatistic.callOutputGeneList(selectedDataset.getPlatform(), 
							analysisPath + "ClusterSummary.Rdata", 
							version,
							sampleFile,
							selectedDatasetVersion.getGroupFileName(),
							analysisPath);
			mySessionHandler.createDatasetActivity("Creating gene list from cluster results where cluster object is samples/groups",
				dbConn);
        		response.sendRedirect(datasetsDir + "nameGeneListFromAnalysis.jsp" + queryString);
		} catch (RException e) {
			rExceptionErrorMsg = e.getMessage();
			mySessionHandler.createDatasetActivity("Got Error When Running R OutputGeneList Function", dbConn);
			%><%@ include file="/web/datasets/include/rError.jsp" %><%
		}
	} else if (action != null && action.equals("Save Cluster Results")) {
        	newParameterGroupID = ((String) request.getParameter("newParameterGroupID") != null ?
                	Integer.parseInt((String) request.getParameter("newParameterGroupID")) :
                	-99);
		log.debug("newParameterGroupID from last run= "+newParameterGroupID);
                String clusterDir = selectedDatasetVersion.getClusterDir();
                String clusterUserDir = clusterDir + userName + "/";
                String clusterUserAnalysisDir = clusterUserDir + newParameterGroupID + "/";
	
		if (!myFileHandler.createDir(clusterDir) ||
                	!myFileHandler.createDir(clusterUserDir) ||
                	!myFileHandler.createDir(clusterUserAnalysisDir)) {
			log.debug("error creating cluster directory in cluster.jsp"); 
					
			mySessionHandler.createDatasetActivity(
				"got error creating cluster directory in cluster.jsp for " + selectedDataset.getName(),
				dbConn);
			session.setAttribute("errorMsg", "SYS-001");
                        response.sendRedirect(commonDir + "errorMsg.jsp");
		} else {
			log.debug("no problems creating cluster directory in cluster.jsp"); 
	
			// Copy files to new directory
			File [] clusterFiles = selectedDataset.getClusterFiles(analysisPath);

			for (int i=0; i<clusterFiles.length; i++) {
				//log.debug("copying " clusterFiles[i].getName() + " to "+clusterUserAnalysisDir);
				myFileHandler.copyFile(clusterFiles[i], new File(clusterUserAnalysisDir + clusterFiles[i].getName()));
			}
		}
		//Success - "Cluster results saved"
		session.setAttribute("successMsg", "EXP-030");
		response.sendRedirect(commonDir + "successMsg.jsp");
	} else if (action != null && action.equals("Next >")) {
        	response.sendRedirect(datasetsDir + "allClusterResults.jsp?datasetID=" + selectedDataset.getDataset_id() +
                                                (selectedDatasetVersion.getVersion() != -99 ?
                                                "&datasetVersion=" + selectedDatasetVersion.getVersion() : "")); 
	} else if (action != null && action.equals("< Previous")) {
        	response.sendRedirect(datasetsDir + "filters.jsp" + queryString);
	}
	//log.debug("End of if statements");

   long NumberOfExcludedArrays = selectedDatasetVersion.getNumberOfExcludedArrays(selectedDatasetVersion.getGrouping_id(), dbConn);

	formName = "cluster.jsp";
%>


	<%@ include file="/web/common/microarrayHeader.jsp" %>
	<%
	if (selectedDataset.getDataset_id() != -99 && selectedDatasetVersion.getVersion() != -99) { 
		
	%>
		<%@ include file="/web/datasets/include/fillDurationHash.jsp" %>
		<%@ include file="/web/datasets/include/viewingPane.jsp" %>
	        <%@ include file="/web/datasets/include/analysisSteps.jsp" %>
		<div class="page-intro"> Select the parameters for clustering. 
			<% if (!ranFilters) { %>
				<p>NOTE: It appears that you did not remove any probes during the filtering process.  Although this is okay, you may want to consider 
				running some filters prior to clustering.  You may press "Previous" to return to the filters page.</p>
			<% } %>
		</div>
		<div style="clear:left"> </div>

        	<div class="datasetForm">
		<form	method="post" 
			action="<%=formName%><%=queryString%>" 
			enctype="application/x-www-form-urlencoded"
			name="cluster">
			<div style="float:left; width:550px">

				<%@ include file="/web/datasets/include/topClusterDiv.jsp" %>

				<%@ include file="/web/datasets/include/hierarchicDiv.jsp" %>
				<%@ include file="/web/datasets/include/kmeansDiv.jsp" %>

                		<div class="brClear"> </div>
				<div id="pageSubmit">
					<div class="submit"><input type="submit" name="action" value="Run"  onClick="return IsClusterFormComplete()"></div>
                        		<div class="hint">You may cluster your data using as many combinations of parameters as you like, and with each
						run, you may save the results if desired.  Press 'Next' to view the details of the results 
						you saved. 
                                	</div>
				</div>
			</div> <!-- div width550px -->

			<% String message = currentGeneCountMsg; %>
			<div class="filterResults">
				<%@ include file="/web/common/analysisParameters.jsp" %>
			</div>

<%
                	//if (action != null && action.equals("Run")) {
							String level = "Summary";
                        	if ((new File(analysisPath + "ClusterSummary.txt")).exists() ||
                                	(new File(analysisPath + "Heatmap.png")).exists()) { %>
                                	<div class="brClear"></div>
                                	<%@ include file="/web/datasets/include/displayClusterResults.jsp" %><%
                        	}
                	//}
%>
			<div class="brClear"></div>
			<div id="prevNext">
				<div class="left">
					<span class="info" title="Return to filtering.">
						<%@ include file="/web/common/previousButton.jsp" %>
                    				<img src="<%=imagesDir%>icons/info.gif" alt="Help">
					</span>
				</div>
				<div class="right">
					<span class="info" title="Continue to view cluster results.">
                    				<img src="<%=imagesDir%>icons/info.gif" alt="Help">
						<%@ include file="/web/common/nextButton.jsp" %>
					</span>
				</div>
			</div> <!-- end div_id_prevNext -->


			<input type="hidden" name="datasetID" value=<%=selectedDataset.getDataset_id()%>>
			<input type="hidden" name="datasetVersion" value=<%=selectedDatasetVersion.getVersion()%>>
			<input type="hidden" name="numGroups" value=<%=numGroups%>>
			<input type="hidden" name="newParameterGroupID" value=<%=newParameterGroupID%>>
        		<input type="hidden" name="number_of_arrays" id="number_of_arrays" value="<%=selectedDataset.getNumber_of_arrays()%>">
        		<input type="hidden" name="number_of_groups" id="number_of_groups" value="<%=selectedDatasetVersion.getNumber_of_non_exclude_groups()%>">
        		<input type="hidden" name="number_of_probes" id="number_of_probes" value="<%=num_probes%>">
				<input type="hidden" name="number_of_excluded_arrays" id="number_of_excluded_arrays" value="<%=NumberOfExcludedArrays%>">
				
			<!-- need this for Save button to work -->
        		<input type="hidden" name="action" value="">

			<input type="hidden" name="duration" id="duration" value="">
		</form>
		</div> <!-- div_datasetForm -->

		<div class="saveClusterList"></div>
		<div class="saveGeneList"></div>

		<script type="text/javascript">
            		$(document).ready(function(){
				displayOnLoad();
				setupSaveButton();
				setupExpandCollapse();
				var duration_method = document.cluster.cluster_method.value;
        			if (document.cluster.cluster_method.value == 'hierarch') {
                			duration_method = duration_method + document.cluster.clusterObjectHierarch.value;
        			} else {
                			duration_method = duration_method + document.cluster.clusterObjectKmeans.value;
        			}
				populateDuration(duration_method, document.cluster);
			}); // document ready
		</script> <% 
	} 
%>
<%@ include file="/web/common/footer.jsp" %>
