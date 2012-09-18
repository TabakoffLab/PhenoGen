<%@ include file="/web/experiments/include/experimentHeader.jsp"  %>
<%
	extrasList.add("reviewExperiment.js");
	// Need to include this here, so that it's available on the modal
	extrasList.add("createTsample.js");
	optionsList.add("experimentDetails");
	optionsList.add("chooseNewExperiment");
	request.setAttribute( "selectedStep", "5" ); 

        log.debug("subid = "+selectedExperiment.getSubid());
	edu.ucdenver.ccp.PhenoGen.data.Array[] myArrays = myArray.getArraysForSubmission(selectedExperiment.getSubid(), dbConn); 
	log.debug("there are " + myArrays.length + " arrays");
	String tableHeight = Math.min(340, myArrays.length*100) + "px";

	log.debug("action = "+action);
        mySessionHandler.createExperimentActivity("Reviewed experiment", dbConn);
	if (action != null && action.equals("Finalize")) {
		myArray.updateSubmissionStatus(selectedExperiment.getSubid(), "C", dbConn);
                session.setAttribute("successMsg", "EXP-050");
                response.sendRedirect(experimentsDir + "listExperiments.jsp");
	}
%>

	<%@ include file="/web/common/microarrayHeader.jsp" %>

    	<script type="text/javascript">
        	var crumbs = ["Home", "Analyze Microarray Data", "Upload Data"]; 
    	</script>

	<%@ include file="/web/experiments/include/viewingPane.jsp" %>
	<%@ include file="/web/experiments/include/uploadSteps.jsp" %>

	<div class="page-intro">
		<p>Click on each of the links to display different information about the hybridizations.<%=twoSpaces%>
		Click<%=twoSpaces%><img src="<%=imagesDir%>icons/edit.png"><%=twoSpaces%>on a particular row to make changes to that row.
		<%=twoSpaces%>Once you are satisfied with the details of your experiment, click 'Finalize' to finalize your submission.
		</p>
	</div> <!-- // end page-intro -->

	<div class="list_container scrollable">

		<div class="brClear"></div>

		<div class="center">
		<div class="navigationButton" id="goTo_1">Basic Sample Properties </div>
		<div class="navigationButton" id="goTo_2">Additional Sample Properties </div>
		<div class="navigationButton" id="goTo_3">Treatment Details </div>
		<div class="navigationButton" id="goTo_4">Protocol Details </div>
		<div class="navigationButton" id="goTo_5"> Hybridization Details </div>
		</div>
		<div class="brClear"></div>
	<BR>

<!--		<div class="left inlineButton" name="createNewHybridization"> Create New Hybridization</div> -->
		<div class="title"> Arrays</div>
		<div class="brClear"></div>
		<div id="1">

		<div style="height:<%=tableHeight%>" class="scrollable">
		<table name="items" class="list_base tablesorter" cellpadding="0" cellspacing="2" width="95%">
		<thead>
		<tr class="col_title"><th class="noSort" colspan="100%"><b>Basic Sample Properties </b></th></tr>
		<tr class="col_title">
			<th>Hybridization Name</th>
			<th>Sample Name</th>
			<th>Organism</th>
			<th>Sex</th>
			<th>Organism part</th>
			<th>Sample type</th>
			<th>Development stage</th>
			<th>Age</th>
			<th>Genetic modification</th>
			<th>Individual identifier</th>
			<th class="noSort">Edit</th>
			<th class="noSort">Delete</th>
			</tr>
			</thead>
			<tbody>

		<%

		for ( int i = 0; i < myArrays.length; i++ ) {
			edu.ucdenver.ccp.PhenoGen.data.Array thisArray = myArrays[i];  
			String age = (thisArray.getAge_range_max() == 0.0 ? 
						thisArray.getAge_range_min() : 
						thisArray.getAge_range_min() + "-" + thisArray.getAge_range_max()) +
						" " +thisArray.getAge_range_units();
			%>
			<tr id="<%=thisArray.getHybrid_id()%>">
				<td><%=thisArray.getHybrid_name()%></td>
				<td><%=thisArray.getSample_name()%></td>
				<td><%=thisArray.getOrganism()%></td>
				<td><%=thisArray.getGender()%></td>
				<td><%=thisArray.getOrganism_part()%></td>
				<td><%=thisArray.getBiosource_type()%></td>
				<td><%=thisArray.getDevelopment_stage()%></td>
				<td><%=age%></td>
				<td><%=thisArray.getGenetic_variation()%></td>
				<td><%=thisArray.getIndividual_identifier()%></td>
				<td class="actionIcons">
					<div class="linkedImg edit"></div>
				</td>
				<td class="actionIcons">
					<div class="linkedImg delete"></div>
				</td>
				</tr>
			<% } %>
			</tbody>
		</table>
		</div>
		</div>

		<div id="2">
		<div style="height:<%=tableHeight%>" class="scrollable">
		<table name="items" class="list_base tablesorter" cellpadding="0" cellspacing="2" width="95%">
		<thead>
		<tr class="col_title"><th class="noSort" colspan="100%"><b>Additional Sample Properties</b></th></tr>
		<tr class="col_title">
			<th>Hybridization Name</th>
			<th>Sample Name</th>
			<th>Genotype</th>
			<th>Selected line</th>
			<th>Strain</th>
			<th>Cell type</th>
			<th>Disease state</th>
			<th>Additional Clinical Information</th>
			<th class="noSort">Edit</th>
			<th class="noSort">Delete</th>
			</tr>
			</thead>
			<tbody>

		<%

		for ( int i = 0; i < myArrays.length; i++ ) {
			edu.ucdenver.ccp.PhenoGen.data.Array thisArray = myArrays[i];  
			%>
			<tr id="<%=thisArray.getHybrid_id()%>">
				<td><%=thisArray.getHybrid_name()%></td>
				<td><%=thisArray.getSample_name()%></td>
				<td><%=thisArray.getIndividual_genotype()%></td>
				<td><%=thisArray.getCell_line()%></td>
				<td><%=thisArray.getStrain()%></td>
				<td><%=thisArray.getTarget_cell_type()%></td>
				<td><%=thisArray.getDisease_state()%></td>
				<td><%=thisArray.getAdditional()%></td>
				<td class="actionIcons">
					<div class="linkedImg edit"></div>
				</td>
				<td class="actionIcons">
					<div class="linkedImg delete"></div>
				</td>
				</tr>
			<% } %>
			</tbody>
		</table>
		</div>
		</div> <!-- sample page 2 -->

		<div id="3">
		<div style="height:<%=tableHeight%>" class="scrollable">
		<table name="items" class="list_base tablesorter" cellpadding="0" cellspacing="2" width="95%">
		<thead>
		<tr class="col_title"><th class="noSort" colspan="100%"><b>Treatment Details</b></th></tr>
		<tr class="col_title">
			<th>Hybridization Name</th>
			<th>Sample Name</th>
			<th>Compound</th>
			<th>Dose</th>
			<th>Treatment</th>
			<th>Duration</th>
			<th>Treatment protocol</th>
			<th class="noSort">Edit</th>
			<th class="noSort">Delete</th>
			</tr>
			</thead>
			<tbody>

		<%

		for ( int i = 0; i < myArrays.length; i++ ) {
			edu.ucdenver.ccp.PhenoGen.data.Array thisArray = myArrays[i];  
			%>
			<tr id="<%=thisArray.getHybrid_id()%>">
				<td><%=thisArray.getHybrid_name()%></td>
				<td><%=thisArray.getSample_name()%></td>
				<td><%=thisArray.getCompound()%></td>
				<td><%=thisArray.getDose()%></td>
				<td><%=thisArray.getTreatment()%></td>
				<td><%=thisArray.getDuration()%></td>
				<td><%=thisArray.getSampleTreatmentProtocol()%></td>
				<td class="actionIcons">
					<div class="linkedImg edit"></div>
				</td>
				<td class="actionIcons">
					<div class="linkedImg delete"></div>
				</td>
				</tr>
			<% } %>
			</tbody>
		</table>
		</div>
		</div> <!-- sample page 3 -->

		<div id="4">
		<div style="height:<%=tableHeight%>" class="scrollable">
		<table name="items" class="list_base tablesorter" cellpadding="0" cellspacing="2" width="95%">
		<thead>
		<tr class="col_title"><th class="noSort" colspan="100%"><b>Protocol Details</b></th></tr>
		<tr class="col_title">
			<th>Hybridization Name</th>
			<th>Sample Name</th>
			<th>Growth protocol</th>
			<th>Extract name</th>
			<th>Extract protocol</th>
			<th>Labeled extract name</th>
			<th>Labeled extract protocol</th>
			<th class="noSort">Edit</th>
			<th class="noSort">Delete</th>
			</tr>
			</thead>
			<tbody>

		<%

		for ( int i = 0; i < myArrays.length; i++ ) {
			edu.ucdenver.ccp.PhenoGen.data.Array thisArray = myArrays[i];  
			%>
			<tr id="<%=thisArray.getHybrid_id()%>">
				<td><%=thisArray.getHybrid_name()%></td>
				<td><%=thisArray.getSample_name()%></td>
				<td><%=thisArray.getGrowthConditionsProtocol()%></td>
				<td><%=thisArray.getTextract_id()%></td>
				<td><%=thisArray.getExtractProtocol()%></td>
				<td><%=thisArray.getTlabel_id()%></td>
				<td><%=thisArray.getLabelExtractProtocol()%></td>
				<td class="actionIcons">
					<div class="linkedImg edit"></div>
				</td>
				<td class="actionIcons">
					<div class="linkedImg delete"></div>
				</td>
				</tr>
			<% } %>
			</tbody>
		</table>
		</div>
		</div> <!-- extractPage -->

		<div id="5">
		<div style="height:<%=tableHeight%>" class="scrollable">
		<table name="items" class="list_base tablesorter" cellpadding="0" cellspacing="2" width="95%">
		<thead> 
		<tr class="col_title"><th class="noSort" colspan="100%"><b>Hybridization Details</b></th></tr>
		<tr class="col_title">
			<th>Hybridization Name</th>
			<th>Array Design Name</th>
			<th>Hybridization Protocol</th>
			<th>Scanning Protocol</th>
			<th>File Name</th>
			<th class="noSort">Edit</th>
			<th class="noSort">Delete</th>
			</tr>
			</thead>
			<tbody>

		<%

		for ( int i = 0; i < myArrays.length; i++ ) {
			edu.ucdenver.ccp.PhenoGen.data.Array thisArray = myArrays[i];  
			%>
			<tr id="<%=thisArray.getHybrid_id()%>">
				<td><%=thisArray.getHybrid_name()%></td>
				<td><%=thisArray.getArray_type()%></td>
				<td><%=thisArray.getHybridizationProtocol()%></td>
				<td><%=thisArray.getScanningProtocol()%></td>
				<td><%=thisArray.getFile_name()%></td>
				<td class="actionIcons">
					<div class="linkedImg edit"></div>
				</td>
				<td class="actionIcons">
					<div class="linkedImg delete"></div>
				</td>
				</tr>
			<% } %>
			</tbody>
		</table>
		</div>
		</div> <!-- hybrid Page -->

	<form   name="reviewExperiment" 
        	method="get" 
        	onSubmit="return AreYouSureToContinue()"
        	action="reviewExperiment.jsp" 
		enctype="application/x-www-form-urlencoded">


		<input type="hidden" name="experimentID" value="<%=selectedExperiment.getExp_id()%>">
		<input type="hidden" name="currentDiv" value="">
		<div style="padding:30px 0px">
			<div class="right">
        			<span class="info" title="Finalize submission.">
				<input type="submit" name="action" value="Finalize" 
					style="background:url(/web/images/Button.gif) no-repeat; 
						border:none; width:80px; height:28px; color:white; " alt="Finalize Submission"
					onClick="<%=onClickString%>">
			</div>
		</div>
	</form>
		</div>
	<div class="createNewHybrid"></div>
	<div class="deleteItem"></div>
	<div class="editItem"></div>
	<script type="text/javascript">
		$(document).ready(function() {
			setupPage();
			setTimeout("setupMain()", 100); 
		});
	</script>

<%@ include file="/web/common/footer.jsp"%>
