<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2008
 *  Description:  This file creates a web page for the user to specify values for
 *	normalization parameters.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/analysisHeader.jsp" %>

<%
	selectedDatasetVersion = selectedDataset.new DatasetVersion(-99);
	session.setAttribute("selectedDatasetVersion", selectedDatasetVersion);
	request.setAttribute( "selectedStep", "2" );
	extrasList.add("normalize.js");
	extrasList.add("showGroupingDetails.js");
	optionsList.add("datasetDetails");
	optionsList.add("createNewGrouping");
	
	String newGroupingID = (String) request.getParameter("newGroupingID");

	log.info("in normalize.jsp. user = " + user + ", and array_type = "+selectedDataset.getArray_type());
	//log.debug("getArrays = "+ (selectedDataset.getArrays() != null ? " is not null " : " is null"));

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-004");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }

        fieldNames.add("version_name");
        fieldNames.add("normalize_method");
        fieldNames.add("probeMask");
        fieldNames.add("grouping_id");
        fieldNames.add("analysis_level");
        fieldNames.add("annotation_level");

        %><%@ include file="/web/common/getFieldValues.jsp" %><%

	String version_name = ((String) fieldValues.get("version_name")).trim();
	String probeMask = (!((String) fieldValues.get("probeMask")).equals("") ? (String) fieldValues.get("probeMask") : "F");

	//log.debug("probeMask is now "+probeMask);
        //log.debug("action = "+action);

	Dataset.Group[] groupings = selectedDataset.getGroupings(dbConn);

	if ((action != null) && action.equals("Next >")) {

		edu.ucdenver.ccp.PhenoGen.data.Array[] myArrays = selectedDataset.getArrays();
                myArrays = myArray.sortArrays(myArrays, "hybrid_name");
		selectedDataset.setArrays(myArrays);

		int grouping_id = Integer.parseInt((String) fieldValues.get("grouping_id"));
		String normalize_method = (String) fieldValues.get("normalize_method");
		//log.debug("grouping_id= "+grouping_id);

		String codeLink_parameter1 = "";
        	if (selectedDataset.getPlatform().equals(selectedDataset.CODELINK_PLATFORM)) {
			if (normalize_method.equals("limma")) {
	        		codeLink_parameter1 = (String) request.getParameter("limma_div_parameter1");
			} else if (normalize_method.equals("loess")) {
	        		codeLink_parameter1 = (String) request.getParameter("loess_div_parameter1");
			}
                	if (codeLink_parameter1.equals("")) {
                        	codeLink_parameter1 = "Null";
                	}
        	}
		String versionType = "N";
		Dataset.Group thisGrouping = myDataset.new Group().getGrouping(grouping_id, dbConn);

		if (thisGrouping.getCriterion().equals("replicateExperiment")) {
			versionType = "R";
		}

		try {
			int nextVersionNumber = myStatistic.doNormalization(
							normalize_method, 
							version_name, 
							grouping_id,
							probeMask,
							codeLink_parameter1, 
							versionType, 
							null, 
							(String) fieldValues.get("analysis_level"),
							(String) fieldValues.get("annotation_level"),
							true);

                        mySessionHandler.createDatasetActivity(session.getId(), 
                                        selectedDataset.getDataset_id(), nextVersionNumber,
                                        "Normalized dataset from normalize.jsp",
                                        dbConn);

			session.setAttribute("privateDatasetsForUser", null);
                	if (nextVersionNumber > 1) {
                                //Success -- "New version will be created"
                                session.setAttribute("successMsg", "EXP-024");
                                response.sendRedirect(datasetsDir + "listDatasets.jsp");
                	} else {
                                //Success -- "First version will be created"
                                session.setAttribute("successMsg", "EXP-025");
                                response.sendRedirect(datasetsDir + "listDatasets.jsp");
                	}

		} catch (ErrorException e) {
                        session.setAttribute("additionalInfo", e.getAdditionalInfo()); 
                        session.setAttribute("errorMsg", e.getMessage());
			if (e.getMessage().equals("SYS-001")) {
                        	mySessionHandler.createDatasetActivity(session.getId(), 
                                        selectedDataset.getDataset_id(), -99,
                                        "got error when running in doNormalization for " +
                                        selectedDataset.getName(),
                                        dbConn);
			}
                        response.sendRedirect(commonDir + "errorMsg.jsp");
		} 
	} 

	formName = "normalize.jsp";
%>
	
	<%@ include file="/web/common/microarrayHeader.jsp" %>


	<%@ include file="/web/datasets/include/viewingPane.jsp" %>
	<div class="brClear"></div>
	<%@ include file="/web/datasets/include/prepSteps.jsp" %>
	<div class="brClear"></div>

	<div class="page-intro">
		<p>Click on a grouping and choose the normalization method you want to use.  
		Provide a descriptive name for this 'version' of your analysis.  Once you are ready, press 'Next'.
		</p>
		 
	</div> <!-- // end page-intro -->


	<div class="brClear"></div>
		<form   method="post"
			action="<%=formName%>"
			enctype="application/x-www-form-urlencoded"
			name="normalize">
		<div class="list_container">
			<div class="leftTitle">  Available Array  Groupings </div>
			<table name="items" class="list_base tablesorter" cellpadding="0" cellspacing="3" width="95%">
				<thead>
				<tr class="col_title">
					<th class="radio">&nbsp;</th>
					<th>Grouping Name</th>
					<th>Criterion Used</th>
					<th class="noSort">Details</th>
					<!-- 
					<th class="noSort">Delete</th>
					-->
				</tr>
				</thead>
				<tbody>
				<% 
				if (groupings.length > 0) {
					for (int i=0; i<groupings.length; i++) { 
						int grouping_id = groupings[i].getGrouping_id();
						%>
						<tr id="<%=grouping_id%>" name="<%=groupings[i].getGrouping_name()%>">
							<td><input type="radio" name="grp_id" value="<%=grouping_id%>"></td>
							<td><%=groupings[i].getGrouping_name()%></td>
							<td><%=groupings[i].getCriterion()%></td>
							<td class="details"> View </td>

							<!--
							<td class="actionIcons">
								<div class="linkedImg delete"></div>
							</td>
							-->
						</tr>
						<%
					} 
				} else { 
					%> <tr><td colspan="4" class="center"><h2>No Array Groupings Exist For This Dataset</h2></td></tr><%
				}%>
				</tbody>
			</table>


		<BR><BR>

			<table class="parameters"> 
                                <tr>
                        		<td><b>Normalization Method: </b></td>
					<td>
						<%
						selectName = "normalize_method";
						selectedOption = "";
						onChange = "";
						style = "";
						optionHash = new LinkedHashMap();
						if (selectedDataset.getPlatform().equals(selectedDataset.AFFYMETRIX_PLATFORM)) {
							onChange = "show_mask()";
       			 				optionHash.put("None", "-- Select an option --");
							if (myArray.EXON_ARRAY_TYPES.contains(selectedDataset.getArray_type())) {
								optionHash.put("rma-sketch", "rma");
								optionHash.put("plier-gcbg-sketch", "plier");
							} else {
								optionHash.put("mas5", "mas5");
								optionHash.put("dchip", "dchip");
								optionHash.put("rma", "rma");
								optionHash.put("vsn", "vsn");
								optionHash.put("gcrma", "gcrma");
								//optionHash.put("plier", "plier");
								//optionHash.put("pdnn", "pdnn");
							}
						} else if (selectedDataset.getPlatform().equals("cDNA")) {
       			 				optionHash.put("None", "-- Select an option --");
							optionHash.put("none", "none");
							optionHash.put("vsn", "vsn");
							optionHash.put("quantile", "quantile");
							optionHash.put("loess", "loess");
							optionHash.put("loessScale", "loessScale");
							optionHash.put("loessQuantile", "loessQuantile");
						} else if (selectedDataset.getPlatform().equals(selectedDataset.CODELINK_PLATFORM)) {
							onChange = "show_codeLink_normalization_parameters()";
       			 				optionHash.put("None", "-- Select an option --");
							optionHash.put("none", "none");
							optionHash.put("loess", "loess");
							optionHash.put("vsn", "vsn");
							optionHash.put("limma", "limma");
						}
						%>
						<%@ include file="/web/common/selectBox.jsp" %>
						<% if (selectedDataset.getPlatform().equals(selectedDataset.AFFYMETRIX_PLATFORM)) { 
							if (!myArray.EXON_ARRAY_TYPES.contains(selectedDataset.getArray_type())) { %>
                						<span class="info" title="RMA or gcRMA are the most often used normalization methods in microarray publications."> 
                    						<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                						</span>
							<% } %>
						<% } else if (selectedDataset.getPlatform().equals(selectedDataset.CODELINK_PLATFORM)) { %>
                					<span class="info" title="Cyclic LOESS (loess) is recommended for normalizing CodeLink data.  See manual for article comparing normalization methods."> 
                    						<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                					</span>
						<% } %>
					</td>
				</tr>
				<tr>
				<td colspan="2">
				<%@ include file="/web/datasets/include/loessDiv.jsp" %>
				<%@ include file="/web/datasets/include/limmaDiv.jsp" %>
				</td>
				</tr>
				<%if (selectedDataset.getPlatform().equals(selectedDataset.AFFYMETRIX_PLATFORM)) {
					if (selectedDataset.getArray_type().equals(myArray.MOUSE430V2_ARRAY_TYPE) || 
						myArray.EXON_ARRAY_TYPES.contains(selectedDataset.getArray_type())) { 
						if (myArray.EXON_ARRAY_TYPES.contains(selectedDataset.getArray_type())) { 
							%>
							<tr> 
                        					<td><b> Signal estimates on:</b> 
								</td>
								<td>
									<%
									selectName = "analysis_level";
									selectedOption = "";
									onChange = "";
									style = "";
									optionHash = new LinkedHashMap();
       			 						optionHash.put("probeset", "exon-level");
									optionHash.put("transcript", "gene-level");
									%>
									<%@ include file="/web/common/selectBox.jsp" %>
								</td>
							</tr><tr>
                        					<td><b>Confidence in Annotation Source:</b> 
								</td>
								<td>
									<%
									selectName = "annotation_level";
									selectedOption = "";
									onChange = "";
									style = "";
									optionHash = new LinkedHashMap();
       			 						optionHash.put("core", "core (highest confidence)");
									optionHash.put("extended", "extended (some confidence)");
									optionHash.put("full", "full (least confidence)");
									%>
									<%@ include file="/web/common/selectBox.jsp" %>
								</td>
							</tr> 
							<% 	
						} 
						%>
							<tr> 
                        				<td><b> Eliminate probes with poor sequence integrity:</b> 
                						<span class="info" title="Individual probes are eliminated if their 
									sequence does not match the genome or if the corresponding area of 
									the genome contains a known SNP that differs between the PhenoGen
									panel of inbred mouse strains.  <BR><BR>This option is only available for 
									datasets that use the Affymetrix Mouse430_2 chip, and it is not available
									for the gcrma normalization method."> 
                    							<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                						</span>
							</td>
							<td>
								<input type="radio" name="probeMask" value="T">&nbsp;Yes
								<%=tenSpaces%>
								<input type="radio" name="probeMask" value="F" checked>&nbsp;No
							</td>
							</tr> 
						<%
					}
				}
				%>
				<tr> 
                        		<td ><b>Version name: </b></td>
					<td> <textarea name="version_name"  rows="2" cols="35"><%=version_name%></textarea></td>
				</tr> 
			</table>


			<input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>"> 
			<input type="hidden" name="grouping_id" value="">
			<input type="hidden" name="newGroupingID" id="newGroupingID" value="<%= newGroupingID %>"> 
			

			<div id="prevNext">
				<div class="right">
					<% onClickString = "return IsNormalizationFormComplete()"; %>
					<%@ include file="/web/common/nextButton.jsp" %>

				</div>
			</div> <!-- end div_id_prevNext -->

		</form>
		</div>

  <div class="itemDetails"></div>
  <script type="text/javascript">
    $(document).ready(function() {
	setupPage();
    })
    </script>

<%@ include file="/web/common/footer.jsp" %>
