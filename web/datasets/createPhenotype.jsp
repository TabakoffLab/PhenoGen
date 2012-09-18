<%--
 *  Author: Cheryl Hornbaker
 *  Created: Jun, 2008
 *  Description:  The web page created by this file accepts the values for the user's phenotype data.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/analysisHeader.jsp"  %>

<%
	log.debug("in createPhenotype.jsp. user = " + user + ", action = "+action); 
	analysisType = "correlation";

//	extrasList.add("progressBar.js");
	extrasList.add("createPhenotype.js");

        fieldNames.add("phenotypeParameterGroupID");         

        %><%@ include file="/web/common/getFieldValues.jsp" %><%

	phenotypeParameterGroupID = ((String) fieldValues.get("phenotypeParameterGroupID") != null && 
					!((String) fieldValues.get("phenotypeParameterGroupID")).equals("") ? 
						Integer.parseInt((String) fieldValues.get("phenotypeParameterGroupID")) : -99);



        String timedFunctionMasking = "Masking.Missing.Strains";
        String callingForm = (request.getParameter("formName") != null ?
                (String) request.getParameter("formName") :
                "correlation");
	log.debug("callingForm = "+callingForm);

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-004");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }
	log.debug("Dataset array type = "+selectedDataset.getArray_type());
	// Only renormalize public datasets that are not masked versions
        boolean askToRenormalize = (selectedDataset.getCreator().equals("public") && 
					!new edu.ucdenver.ccp.PhenoGen.data.Array().EXON_ARRAY_TYPES.contains(selectedDataset.getArray_type()) &&
			//		selectedDatasetVersion.getVersion() < 6 &&
					callingForm.equals("correlation") &&
					!userLoggedIn.getUser_name().equals("guest")); 

        log.debug("phenotypeParameterGroupID = " + phenotypeParameterGroupID + 
			", askToRenormalize = "+askToRenormalize +", parameterGroupID in createPhenotype is "+parameterGroupID);

	Dataset.Group[] myGroups = selectedDatasetVersion.getGroups(dbConn);
	Hashtable<String, List<String>> parentsWithGroups = selectedDatasetVersion.getParentsWithGroups(dbConn);
	if (callingForm.equals("correlation")) {
		sortColumn = "has_expression_data";
	} else {
		sortColumn = "has_genotype_data";
	}
	myDataset.new Group().sortGroups(myGroups, sortColumn, "D");
	session.setAttribute("phenotypeGroups", myGroups);

	ParameterValue.Phenotype[] myPhenotypeValues = myParameterValue.getPhenotypeValuesForGrouping(userID, 
						selectedDatasetVersion, dbConn); 

        // Number of probes to use for durationHash
        int num_probes = ((String) request.getParameter("num_probes") != null ?
                Integer.parseInt((String) request.getParameter("num_probes")) :
                45000);

	Hashtable durationHash = (selectedDataset.getDataset_id() != -99 ?
			myDataset.getExpectedDuration(selectedDataset.getNumber_of_arrays(), num_probes, dbConn) :
			new Hashtable());

        session.setAttribute("durationHash", durationHash);
	//log.debug("durationHash here = "); myDebugger.print(durationHash);

	log.debug("dataset name = "+selectedDataset.getName());
	log.debug("datasets with genotype = "); myDebugger.print(selectedDataset.DATASETS_WITH_GENOTYPE_DATA);
	log.debug("readyForCorrelation = "+selectedDatasetVersion.readyForCorrelation());
	if (selectedDataset.getDataset_id() != -99 && !selectedDatasetVersion.readyForCorrelation()) {
		//Error - "Can't do a correlation analysis on dataset that was 
		//normalized with only 5 groups 
		session.setAttribute("errorMsg", "EXP-012");
		response.sendRedirect(commonDir + "errorMsg.jsp");
	} 
	mySessionHandler.createDatasetActivity("Created phenotype", dbConn);
%>

<%@ include file="/web/common/includeExtras.jsp" %>

	<!-- use javascript to fill up the client-side array with saved phenotype values -->
	<%@ include file="/web/datasets/include/fillPhenotype.jsp" %>

	<!-- use javascript to fill up the client-side array with saved duration values -->
	<%@ include file="/web/datasets/include/fillDurationHash.jsp" %>

	<div class="datasetForm">

	<form   name="createPhenotype"
		method="post"
		onSubmit="return IsCreatePhenotypeFormComplete()"
                action="<%=datasetsDir%>uploadPhenotype2.jsp?datasetID=<%=selectedDataset.getDataset_id()%>&amp;datasetVersion=<%=selectedDatasetVersion.getVersion()%>"
                enctype="multipart/form-data">

		<div class="page-intro">
                        <% if (selectedDataset.DATASETS_WITH_GENOTYPE_DATA.contains(selectedDataset.getName())) { %>
			<p> For the public dataset <i>"<%=selectedDataset.getName()%>"</i>, we have both genotype data and brain expression data for the strains
			shown below. You may enter phenotype data for any or all of the strains.  Phenotype values for strains for which we have expression data will be 
			included in correlation analyses on this dataset, and strains for which we have genotype data will be included in QTL calculations.
			<BR>
			<BR>
			</p>
			<% } %>
			<p>Step 1. Name the phenotype data and provide a description of it. 
			</p>
		</div> <!-- // end page-intro -->
		<div class="brClear"></div>

		<div>
			<table class="list_base">
               		<tr>
                		<td><strong>Phenotype Name:</strong></td>
			</tr> <tr>

                        	<td><input type="text" name="phenotypeName" size="30"></td>
			</tr> <tr>
                		<td><strong>Phenotype Description:</strong></td>
			</tr> <tr>
                        	<td><textarea name="description" rows="3" cols="30"></textarea></td>
			</tr> 
			</table>
		</div>

		<div class="page-intro">
			<p>Step 2. Choose whether you are going to upload a file containing the phenotype data, enter the data manually, or copy 
			an existing set of phenotype data and make changes to it.  (To download a template file containing the group names, click <a href="<%=datasetsDir%>downloadTemplate.jsp">here:<%=twoSpaces%><img src="<%=imagesDir%>/icons/download_g.png" /></a>.)
			</p>
			<% if (callingForm.equals("calculateQTLs")) { %>
				<BR>
				<p> Also, you can enter variance values for your strains by clicking the 'Enter Variance Values' box.<BR><BR>
				</p>
			<% } %>
		</div> <!-- // end page-intro -->
		<div class="brClear"></div>

			<%@ include file="/web/datasets/include/phenotypeChoiceDiv.jsp" %> 

			<%@ include file="/web/datasets/include/uploadDiv.jsp" %> 

		<div class="brClear"></div>

			<%@ include file="/web/datasets/include/listPhenotypesDiv.jsp" %> 

		<div class="brClear"></div>

        		<%@ include file="/web/datasets/include/newDiv_new.jsp" %>

		<div class="page-intro">
			<p>Step 3. Save the data.  </p>
		</div> <!-- // end page-intro -->

		<div class="brClear"></div>

		<div id="save_div" style="margin:10px 0px;">
                	<table class="list_base">
				<tr>
				<td class="center">
		                	<input type=submit id="action" name="action" value="Save Values">
				</td>
				</tr> 
			</table>

		</div>  <!-- end of save_div -->


                <input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>"/>
                <input type="hidden" name="datasetVersion" value="<%=selectedDatasetVersion.getVersion()%>"/>
                <input type="hidden" name="expName" value="<%=selectedDataset.getName()%>"/>
                <input type="hidden" name="analysisType" value="<%=analysisType%>"/>
                <input type="hidden" name="numGroups" value="<%=selectedDatasetVersion.getNumber_of_non_exclude_groups()%>"/>
                <input type="hidden" name="askToRenormalize" value="<%=askToRenormalize%>"/>
		<!-- need both of these -->
                <input type="hidden" name="formName" value="<%=callingForm%>"/>
                <input type="hidden" name="callingForm" value="<%=callingForm%>"/>
                <input type="hidden" name="goingToRenormalize" value="false"/>

		<input type="hidden" name="phenotypeParameterGroupID" value=""/>
		<input type="hidden" name="step" value="filter"/>
		<input type="hidden" name="duration" id="duration" value="">
        </form>
	</div>
	<div style="clear:both; float:none; height: 5px;">&nbsp;</div>

	<script type="text/javascript">
		$(document).ready(function() {
			populateDuration("Masking.Missing.Strains", document.createPhenotype); 
			showPhenotypeFields(); 
			toggleVarianceFields();
			disableCopyOptionIfPhenotypeEmpty();
			document.createPhenotype.phenotypeName.focus();
                        var tablesorterSettings = { widgets: ['zebra'] };
                        $("table[id='groups']").tablesorter(tablesorterSettings);
                        $("table[id='variances']").tablesorter(tablesorterSettings);
			setupExpandCollapse();
		});
	</script> 
