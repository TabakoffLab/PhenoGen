<%--
 *  Author: Cheryl Hornbaker
 *  Created: April, 2008
 *  Description:  This file formats filter and/or statistics parameters used 
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>
<%@ include file="/web/geneLists/include/geneListHeaderExtra.jsp"%>

<%
	log.info("in formatParameters");

        String hybridIDs = "All";

	String parameterType = ((String) request.getParameter("parameterType") != null ? 
			(String) request.getParameter("parameterType") :
			"dataset");
	parameterGroupID = ((String) request.getParameter("parameterGroupID") != null ? 
			Integer.parseInt((String) request.getParameter("parameterGroupID")) :
			-99);

	// Have to save the current exp and version in case calling this before a version has been selected
	Dataset savedDataset = selectedDataset;
	Dataset.DatasetVersion savedDatasetVersion = selectedDatasetVersion;
	log.debug("saved datasetID = " + savedDataset.getDataset_id() + ", saved datasetVersion = " + savedDatasetVersion.getVersion());

	%><%@include file="/web/datasets/include/selectDataset.jsp"%><%

	Dataset thisDataset = selectedDataset;
	Dataset.DatasetVersion thisDatasetVersion = selectedDatasetVersion;

	log.debug("this datasetID = " + thisDataset.getDataset_id() + ", this datasetVersion = " + thisDatasetVersion.getVersion());

	session.setAttribute("selectedDataset", savedDataset);
	session.setAttribute("selectedDatasetVersion", savedDatasetVersion);

	log.debug("parameterGroupID = " + parameterGroupID + ", parameterType = " + parameterType);

	String paramTitle = "";
	ParameterValue[] myParameterValues = null;
	User.UserChip[] chipAssignments = null;
	ParameterValue[] normalizationParameters = null;
	ParameterValue.Phenotype[] phenotypeParameters = null;
	ParameterValue[] paramsToDisplay = null;
	List parameterValueList = new ArrayList();
	edu.ucdenver.ccp.PhenoGen.data.Array[] myArrays = null;
	String qcStatus = "";
	String qcLink = "";
	String expressionValuesLink = "";
	String clusterResultsLink = "";
	
	
	
	GeneList.Gene[] myGeneArray=new GeneList.Gene[0];// = selectedGeneList.getGenesAsGeneArray(dbConn);

	boolean printDatasetDetails = false,  
		printArrayDetails = false,
		printVersionDetails = false, 
		printNormalizedVersions = false, 
		printNormalizationParameters= false, 
		printAllPhenotypes = false, 
		printPhenotypeParameters = false, 
		printGroupAssignments = false, 
		printGeneLists = false,
		printGeneList = false,
		printGeneListDetails = false,
		printGeneListParameters = false;

	if (parameterType.equals("dataset") || parameterType.equals("datasetVersion")) {

		parameterType = (thisDatasetVersion.getVersion() != -99 ? "datasetVersion" : parameterType); 
		//parameterType = (datasetVersion != -99 ? "datasetVersion" : parameterType); 

		//log.debug("Dataset="+thisDataset);
		//log.debug("qcComplete="+thisDataset.getQc_complete());
		qcStatus = (thisDataset.getQc_complete().equals("N") ? "Not started" :
					((thisDataset.getQc_complete().equals("Y") ||
					 thisDataset.getQc_complete().equals("I")) ? "Complete" :
						(thisDataset.getQc_complete().equals("R") ? "Needs Review" :
							(thisDataset.getQc_complete().equals("O") ? "Not required" :
								(thisDataset.getQc_complete().equals("1") ? "In progress" : "")))));
		qcLink = ((thisDataset.getQc_complete().equals("N") ||
					 thisDataset.getQc_complete().equals("O") || 
					 thisDataset.getQc_complete().equals("1")) ? "" :
					((thisDataset.getQc_complete().equals("Y") ||
					 thisDataset.getQc_complete().equals("R") || 
					 thisDataset.getQc_complete().equals("I")) ? 
						"<a href='" + datasetsDir + 
						"chooseDataset.jsp?datasetID=" + thisDataset.getDataset_id() + "&goTo=QCResults" +
						"'>View Quality Control Results</a>" : ""));
		//log.debug("qcLink="+qcLink);
		expressionValuesLink = "<a href='" + datasetsDir + 
						(thisDatasetVersion.getVersion() == -99 ? 
						"chooseDataset.jsp?datasetID=" + thisDataset.getDataset_id() + "&goTo=geneData" : 
						"geneData.jsp?itemIDString="+thisDataset.getDataset_id()+
						"|||" + thisDatasetVersion.getVersion()) +
						"'>Get Expression Values</a>";  
		clusterResultsLink = "<a href='" + datasetsDir + 
						"chooseDataset.jsp?datasetID=" + thisDataset.getDataset_id() +
						(thisDatasetVersion.getVersion() != -99 ? 
						"&datasetVersion=" + thisDatasetVersion.getVersion() : "") + "&goTo=ClusterResults" + 
						"'>View Cluster Results</a>";  
                //
                // This gets the hybrid IDs for this dataset, and then retrieves
                // the arrays from the database.
                //
                hybridIDs = thisDataset.getDatasetHybridIDs(dbConn);
                if (!hybridIDs.equals("()")) {
                        myArrays = myArray.getArraysForDataset(hybridIDs, dbConn);
			//log.debug("here myArrays length = "+myArrays.length);
                        thisDataset.setArray_type(myArray.getDatasetArrayType(hybridIDs, dbConn));
		}
		if (parameterType.equals("dataset")) {
			printDatasetDetails = true;
			printArrayDetails = true;
			if (thisDataset.getDatasetVersions() != null && thisDataset.getDatasetVersions().length > 0){ 
				printNormalizedVersions = true;
			}
			mySessionHandler.createDatasetActivity(session.getId(), 
				thisDataset.getDataset_id(), thisDatasetVersion.getVersion(), 
				"Looked at details for this dataset",
				dbConn);
		} else if (parameterType.equals("datasetVersion")) {
			normalizationParameters = 
				myParameterValue.getNormalizationParameters(
				thisDataset.getDataset_id(),
                        	thisDatasetVersion.getVersion(), dbConn);
			chipAssignments = 
				thisDataset.new Group().getChipAssignments(thisDatasetVersion.getGrouping_id(), dbConn);
			//log.debug("myArrays length = "+myArrays.length);
			//log.debug("chipAssignments length = "+chipAssignments.length);
			for (int i=0; i<chipAssignments.length; i++) {
				chipAssignments[i].setHybrid_name(
					myArray.getArrayFromMyArrays(myArrays, chipAssignments[i].getHybrid_id()).getHybrid_name());
			}

			phenotypeParameters = myParameterValue.getPhenotypeValuesForGrouping(userID, 
					thisDatasetVersion, dbConn);
			log.debug("there are "+phenotypeParameters.length + "phenotype values");

			printDatasetDetails = true;
			printVersionDetails = true;
			printNormalizationParameters= true; 
			printAllPhenotypes = true; 
			printGroupAssignments = true; 
			printGeneLists = true;
			mySessionHandler.createDatasetActivity(session.getId(), 
				thisDataset.getDataset_id(), thisDatasetVersion.getVersion(), 
				"Looked at details for this dataset version",
				dbConn);
		}
	} else if (parameterType.equals("geneList")) {
		%><%@include file="/web/geneLists/include/selectGeneList.jsp"%><%
		myParameterValues = myParameterValue.getGeneListParameters(parameterGroupID, dbConn);
		//log.debug("Before getGenesAsGeneArray:"+selectedGeneList.getGene_list_id());
		myGeneArray = selectedGeneList.getGenesAsGeneArray(dbConn);
		/*String[] targets = new String[] {
			"Gene Symbol", 
			// for Location tool
			"Location", 
			// for oPOSSUM tool
        		"RefSeq RNA ID"
		};
		iDecoderSet = myIDecoderClient.getIdentifiersByInputIDandTarget(selectedGeneList.getGene_list_id(), targets,dbConn);*/
		//log.debug("After getGenesAsGeneArray");
		printGeneListDetails = true; 
		printGeneListParameters = true; 
		printPhenotypeParameters = true; 
		printGeneList = true;
		mySessionHandler.createGeneListActivity("Looked at details for this gene list", dbConn);
	} else if (parameterType.equals("filter")) {
		myParameterValues = myParameterValue.getFiltersUsed(parameterGroupID, dbConn);
		mySessionHandler.createActivity("Looked at details for filter.  PGID = " + parameterGroupID, dbConn);
	} else if (parameterType.equals("phenotype")) {
		printPhenotypeParameters = true;
		mySessionHandler.createActivity("Looked at details for phenotype " , dbConn);
	} else {
		mySessionHandler.createActivity("Looked at details of something.  parameterType = " + parameterType + " and PGID = "+ parameterGroupID,
				dbConn);
		myParameterValues = myParameterValue.getParameterValues(parameterGroupID, dbConn);
	} 

// Do not include header tags on this page, since it's called by ajax -- document.ready doesn't work if you do
//include file="/web/common/headTags.jsp"
%>	

<center>
	<div> 
		<p style="font-size:12px; margin:10px 0px;">
		(Click the <img src="<%=imagesDir%>icons/add.png" alt="expand"> and <img src="<%=imagesDir%>icons/min.png" alt="contract"> 
		icons next to the section titles to open and close the section details)
		</p>
		<BR>
	</div>
	<% if (printDatasetDetails) { %>
		<div class="title"> 
			<span class="trigger less" name="datasetStuff">
			Dataset Details 
			</span>
		</div>
		<div id="datasetStuff">
      			<table class="list_base" cellpadding="0" cellspacing="3" style="margin:0px 10px">
				<tr><td><b>Dataset Name:</b></td><td> <%=thisDataset.getName()%></td></tr>
				<tr><td><b>Description:</b></td><td> <%=thisDataset.getDescription()%></td></tr>
				<tr><td><b>Organism:</b></td><td><%=thisDataset.getOrganism()%></td></tr>
				<tr><td><b>Date Created:</b></td><td><%=thisDataset.getCreate_date_as_string()%></td></tr>
				<tr><td><b>Platform:</b></td><td><%=thisDataset.getPlatform()%></td></tr>
				<tr><td><b># of Arrays:</b></td><td><%=thisDataset.getNumber_of_arrays()%></td></tr>
				<tr><td><b>Array Used:</b></td><td><%=thisDataset.getArray_type()%></td></tr>
				<tr><td><b>Quality Control Status:</b></td><td><%=qcStatus%></td></tr>
			</table>
		</div>
		<div class="brClear"></div>
	<% } %>
	<% if (printNormalizationParameters) { 
		paramsToDisplay = normalizationParameters;
		paramTitle = "Normalization Parameters";

		if (paramsToDisplay != null && paramsToDisplay.length > 0) {
			// Included code from displayParams here because the column headings are different
			%>
			<div class="title"> 
				<span class="trigger less" name="normalizationParametersStuff">
				Normalization Parameters
				</span>
			</div>
			<div id="normalizationParametersStuff">
      				<table id="normalization_parameters" class="list_base tablesorter" cellpadding="0" cellspacing="3"  style="margin:0px 10px;">
				<thead>
				<tr class="col_title">
					<th> Parameter Name
					<th> Value
				</tr>
				</thead>
				<tbody>
                        	<% for (int i=0; i<paramsToDisplay.length; i++) { %>
					<tr>
                                		<td><b><%=paramsToDisplay[i].getParameter()%></b></td>
                                        	<td><%=paramsToDisplay[i].getValue()%></td>
					</tr>
				<% } %>
				</tbody>
				</table>
			</div>
			<div class="brClear"></div>
		<% } %>
	<% } %>
	<% if (printAllPhenotypes) { %>

		<% if (phenotypeParameters != null && phenotypeParameters.length > 0) { %>
                <div class="title">
                        <span class="trigger" name="<%=parameterType%>_parameters_Stuff">
                        Phenotype Values
                        </span>
                </div>
                <div id="<%=parameterType%>_parameters_Stuff" style="display:none">
                <table id="<%=parameterType%>_parameters" class="list_base tablesorter" cellpadding="0" cellspacing="3">
			<% for (ParameterValue.Phenotype thisPhenotype : phenotypeParameters) {%>
				<table class="list_base">
				<tr>
                                	<td> <b>Phenotype Name:<%=twoSpaces%></b></td>
					<td><%=thisPhenotype.getName()%></td>
				</tr><tr>
					<td><b>Description:<%=twoSpaces%></b></td>
					<td><%=thisPhenotype.getDescription()%></td>
				</tr>
				<% 
				Hashtable<Dataset.Group, Double> means = thisPhenotype.getMeans();
				Hashtable<Dataset.Group, Double> variances = thisPhenotype.getVariances();
				%>
				<tr class="col_title">
					<th> Group Name</th>
					<th> Mean </th>
					<% if (variances != null && variances.size() > 0) { %>
						<th> Variance</th>
					<% } %>
				</tr>
				<%
				//log.debug("means = " + means.keySet());
				if (means != null && means.size() > 0) {
					//log.debug("means is not null");
					for (Iterator itr = new TreeSet(means.keySet()).iterator(); itr.hasNext();) {
						Dataset.Group group = (Dataset.Group) itr.next();
						String meanValue = (String) means.get(group).toString();
						String varianceValue = (variances !=null && variances.size() > 0 ?
							(variances.get(group) != null ? (String) variances.get(group).toString() : " ") 
							: "");
						%>
						<tr>
                                			<td><%=group.getGroup_name()%></td>
                                			<td><%=meanValue%></td>
                                			<td><%=varianceValue%></td>
						</tr>
					<% } %>
				<% } %>
				</table><BR>
			<% } %>
		</table>
		</div>
		<div class="brClear"></div>
		<% } %>
	<% } %>
	<% if (printGroupAssignments) { %>	
		<div class="title"> 
			<span class="trigger" name="groupAssignmentStuff">
			Group Assignments
			</span>
		</div>
		<div id="groupAssignmentStuff" style="display:none">
			<%=chipAssignments[0].getGroup().getGrouping_name()%>
      		<table class="list_base" id="groupAssignments" cellpadding="0" cellspacing="3" >
			<thead>
			<tr class="col_title">
				<th> Array Name</th>
				<th> Group Assignment</th>
			</tr>
			</thead>
			<tbody>
			<% for (int i=0; i<chipAssignments.length; i++) { %>
				<tr>
					<td><b><%=chipAssignments[i].getHybrid_name()%></b></td>
					<td>Group #: <%=chipAssignments[i].getGroup().getGroup_number()%>:<%=twoSpaces%><%=chipAssignments[i].getGroup().getGroup_name()%></td>
				</tr>
			<% } %>
			</tbody>
		</table>
		</div>
		<div class="brClear"></div>
	<% } %>
	<% if (printNormalizedVersions) { %>
		<div class="title"> 
			<span class="trigger less" name="normalizedVersionStuff">
			Normalized Versions
			</span>
		</div>
		<div id="normalizedVersionStuff">
      		<table class="list_base" id="normalizedVersions" cellpadding="0" cellspacing="3">
			<thead>
			<tr class="col_title">
				<th>#</th>
				<th>Version Name</th>
				<th>Number of Groups</th>
				<th>Normalization Method</th>
			</tr>
			</thead>
			<tbody>
			<% for (int i=0; i<thisDataset.getDatasetVersions().length; i++) { 
				Dataset.DatasetVersion thisVersion = thisDataset.getDatasetVersions()[i];
				%>
				<tr> 
					<td class="center"><%=thisVersion.getVersion()%></td>
					<td><%=thisVersion.getVersion_name()%></td>
					<td class="center"><%=thisVersion.getNumber_of_non_exclude_groups()%></td>
					<td class="center"><%=thisVersion.getNormalization_method()%></td>
				</tr>
			<% } %>
		</tbody>
		</table>
		</div>
		<div class="brClear"></div>
	<% } %>
	<% if (printArrayDetails) { %> 
		<div class="title"> 
			<span class="trigger" name="arrayStuff">
			Arrays in Dataset	
			</span>
		</div>
		<div id="arrayStuff" style="display:none">
      		<table class="list_base" id="arrayList" cellpadding="0" cellspacing="3" >
			<thead>
			<tr class="col_title">
				<th> Array Name</th>
				<th> File Name</th>
			</tr>
			</thead>
			<tbody>
			<% for (int i=0; i<myArrays.length; i++) { %>
				<tr>
					<td><b><%=myArrays[i].getHybrid_name()%></b></td>
					<td><%=myArrays[i].getFile_name()%></td>
				</tr>
			<% } %>
			</tbody>
		</table>
		</div>
		<div class="brClear"></div>
	<% } %>
	
	
	 
    <% if (printGeneLists && selectedDatasetVersion.getGeneLists() != null && selectedDatasetVersion.getGeneLists().length > 0 )  { %> 
        <div class="title"> 
            <span class="trigger" name="geneLists">
            Gene Lists
            </span>
        </div>
        <div id="geneLists" style="display:none">
            <table class="list_base" id="geneList" cellpadding="0" cellspacing="3" >
            <thead>
            <tr class="col_title">
                <th> Gene List Name</th>
            </tr>
            </thead>
            <tbody>
            <% for (GeneList geneList2 : selectedDatasetVersion.getGeneLists() ) { %>
                <tr>
                    <td>
                    	<a href="<%=geneListsDir%>chooseGeneList.jsp?geneListID=<%=geneList2.getGene_list_id()%>"><%=geneList2.getGene_list_name()%></a>
                    </td>
                </tr>
            <% } %>
            </tbody>
        </table>
        </div>
        <div class="brClear"></div>
     <% } %>
	
	
	
	<% if (printGeneListDetails) { log.debug("print geneListDetails"); %> 
		<div class="title"> 
			<span class="trigger less" name="geneListStuff">
			Gene List Details
			</span>
		</div>
		<div id="geneListStuff">
      			<table class="list_base " cellpadding="0" cellspacing="3" style="margin:0px 10px;">
				<tr><td><b>Gene List Name:</b></td><td> <%=selectedGeneList.getGene_list_name()%></td></tr>
				<tr><td><b>Description:</b></td><td> <%=selectedGeneList.getDescription()%></td></tr>
				<tr><td><b>Organism:</b></td><td><%=selectedGeneList.getOrganism()%></td></tr>
				<tr><td><b>Date Created:</b></td><td><%=selectedGeneList.getCreate_date_as_string()%></td></tr>
				<tr><td><b>Source:</b></td><td><%=selectedGeneList.getGene_list_source()%></td></tr>
				<tr><td><b>Owner:</b></td><td><%=selectedGeneList.getGene_list_owner()%></td></tr>
			</table>
		</div>
		<div class="brClear"></div>
	<% } %>
	<% if (printGeneListParameters) { log.debug("print geneListParameters");
		paramsToDisplay = myParameterValues;
		paramTitle = "Parameters Used in Creating Gene List";
		%>
		<%@ include file="/web/common/displayParams.jsp" %>
	<% } %>
	<% if (printPhenotypeParameters) { log.debug("print PhenotypeParameters");
		ParameterValue.Phenotype thisPhenotype = myParameterValue.getPhenotypeValuesForParameterGroupID(parameterGroupID, dbConn);
		String phenotypeName = thisPhenotype.getName(); 
		Hashtable<Dataset.Group, Double> means = thisPhenotype.getMeans();
		Hashtable<Dataset.Group, Double> variances = thisPhenotype.getVariances();

		if (means != null && means.size() > 0) {
			// Included code from displayParams here because the column headings are different
			%>
			<div class="title"> 
				<span class="trigger less" name="phenotypeStuff">
				Phenotype Values for '<%=phenotypeName%>'
				</span>
			</div>
			<div id="phenotypeStuff">
      				<table id="phenotype_parameters" class="list_base" cellpadding="0" cellspacing="3" width="60%">
				<thead>
				<tr class="col_title">
					<th> Group name</th>
                                        <% if (thisDataset.CALC_QTL_DATASETS.contains(thisDataset.getName())) { %>
                                        	<th >Expression Data</th>
                                        	<th >Genotype Data</th>
                                        <% } %>
					<th> Mean </th>
					<% if (variances != null && variances.size() > 0) { %>
						<th> Variance </th>
					<% } %>
				</tr>
				</thead>
				<tbody>
                        	<% for (Iterator itr=new TreeSet(means.keySet()).iterator(); itr.hasNext();) { 
					Dataset.Group group = (Dataset.Group) itr.next();	
					String mean = (String) means.get(group).toString();
					String variance = (variances != null && variances.size() > 0 ? 
							(variances.get(group) != null ? (String) variances.get(group).toString() : " ") 
							: "");
					%>
					<tr>
                                		<td><b><%=group.getGroup_name()%></b></td>
						<% if (thisDataset.CALC_QTL_DATASETS.contains(thisDataset.getName())) { %>
							<td class="center"><%=(group.getHas_expression_data().equals("Y") ? checkMark : "-")%></td>
                                                        <td class="center"><%=(group.getHas_genotype_data().equals("Y") ? checkMark : "-")%></td>
                                                <% } %>
                                		<td class="right"><%=mean%></td>
						<% if (!variance.equals("")) { %>
                                        		<td class="right"><%=variance%></td>
						<% } %>
					</tr>
				<% } %>
				</tbody>
				</table>
			</div>
			<div class="brClear"></div>
		<% }

		if (thisDataset.getDataset_id() != -99 && thisDatasetVersion.getVersion() != -99) {
			String callingFrom = ((String) request.getParameter("formName") != null ? 
					(String) request.getParameter("formName") :
					"correlation");
                	String imageFileName = (callingFrom.equals("correlation")||callingFrom.equals("phenotypes") ? thisDatasetVersion.getExpressionGraphFileName(userName, phenotypeName) :
                				thisDatasetVersion.getQTLGraphFileName(userName, phenotypeName));
                	String textFileName = (callingFrom.equals("correlation") ||callingFrom.equals("phenotypes") ? thisDatasetVersion.getExpressionSummaryFileName(userName, phenotypeName) :
                				thisDatasetVersion.getQTLSummaryFileName(userName, phenotypeName));
			log.debug("callingFrom = "+callingFrom);
			log.debug("imageFileName = "+imageFileName);
			log.debug("textFileName = "+textFileName);
                	File imageFile = new File(imageFileName);
                	File textFile = new File(textFileName);
                	if (imageFile.exists()) {
				String imagesFile = myFileHandler.getPathFromUserFiles(imageFileName);
                        	%><img src="<%=imagesFile%>" alt="<%=imageFileName%>"><%
                	}
                	if (textFile.exists()) { 
				%> <BR><BR>
				<div class="title">Summary of Phenotype Data</div>
				<table class="list_base" cellpadding="0" cellspacing="3"><%
                		String[] fileContents = new FileHandler().getFileContents(textFile, "spaces");
				for (int i=0; i<fileContents.length; i++) {
					%><tr><%
					String[] columns = fileContents[i].split("[\\t]+");
					for (int j=0; j<columns.length; j++) {
						%><td> <%=columns[j]%></td><%
					}
					%></tr><%
				}
				%></table><%
			}
		}
	} %>
    <% if (printGeneList) { log.debug("print geneList");%> 
		<div class="title"> 
			<span class="trigger less" name="geneList2">
			Gene List Contents
			</span>
		</div>
        <div id="geneList2">
		<table name="items" id="items" class="list_base tablesorter" cellpadding="0" cellspacing="3">			 
			<thead>
			<tr class="col_title">
				<th > Accession ID </th>
				<th> GeneSymbol</th>
			</tr>
			</thead>
			<tbody>
			<%
	                session.setAttribute("myGeneArray", myGeneArray);
					log.debug("myGeneArray:"+myGeneArray.length);
                	for (int i=0; i<myGeneArray.length; i++) {
						//log.debug("i:"+i+":"+myGeneArray[i].getGene_id());
				%>
                        <tr><td><%=myGeneArray[i].getGene_id()%></td><%
							Identifier thisIdentifier = myIdentifier.getIdentifierFromSet(myGeneArray[i].getGene_id(), iDecoderSet); 
							if (thisIdentifier != null) {
								Set geneSymbols = myIDecoderClient.getIdentifiersForTargetForOneID(thisIdentifier.getTargetHashMap(), new String[] {"Gene Symbol"});
								if (geneSymbols != null && geneSymbols.size() > 0) { 
									%><td><%
                						for (Iterator symbolItr = geneSymbols.iterator(); symbolItr.hasNext();) { 
                                        	Identifier symbol = (Identifier) symbolItr.next();
                							%><%=symbol.getIdentifier()%><BR><%
										}
									%></td><% 
								} else { 
									log.debug("no gene symbols");	
									%><td>&nbsp; </td><% 
								} 
							} else {
								%><td>&nbsp; </td><%
							} 
                       	%></tr><%
                	}
			%>
			</tbody>
		</table>
        </div>
		<div class="brClear"></div>
	<% } %>
	</center>
	<script type="text/javascript">
        	$(document).ready(function(){
                        var tablesorterSettings = { widgets: ['zebra'] };
                        $("table[id='arrayList']").tablesorter(tablesorterSettings);
		        $("table[id='arrayList']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
                        $("table[id='groupAssignments']").tablesorter(tablesorterSettings);
		        $("table[id='groupAssignments']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
                        $("table[id='normalizedVersions']").tablesorter(tablesorterSettings);
		        $("table[id='normalizedVersions']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
                        $("table[id='<%=parameterType%>_parameters']").tablesorter(tablesorterSettings);
		        $("table[id='<%=parameterType%>_parameters']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
                        $("table[id='geneList']").tablesorter(tablesorterSettings);
			setupExpandCollapse();
        	})
	</script>

	<div class="closeWindow">Close</div>

