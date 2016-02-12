<%--
 *  Author: Cheryl Hornbaker
 *  Created: April, 2008
 *  Description:  This file formats filter and/or statistics parameters used 
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %>


<%
	log.info("in formatParameters");

        String hybridIDs = "All";

	String parameterType = ((String) request.getParameter("parameterType") != null ? 
			(String) request.getParameter("parameterType") :
			"geneList");
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

	boolean printPhenotypeParameters = false, 
		printGeneLists = false,
		printGeneList = false,
		printGeneListDetails = false,
		printGeneListParameters = false;

	if (parameterType.equals("geneList")) {
                log.debug("before include selectGeneList");
		%><%@include file="/web/geneLists/include/selectGeneList.jsp"%><%
                log.debug("Before parameters values");
		myParameterValues = myParameterValue.getGeneListParameters(parameterGroupID, pool);
		log.debug("Before getGenesAsGeneArray:"+selectedGeneList.getGene_list_id());
		myGeneArray = selectedGeneList.getGenesAsGeneArray(pool);
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
		mySessionHandler.createGeneListActivity("Looked at details for this gene list", pool);
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
		ParameterValue.Phenotype thisPhenotype = myParameterValue.getPhenotypeValuesForParameterGroupID(parameterGroupID, pool);
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
                    
                        $("table[id='<%=parameterType%>_parameters']").tablesorter(tablesorterSettings);
		        $("table[id='<%=parameterType%>_parameters']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
                        $("table[id='geneList']").tablesorter(tablesorterSettings);
			setupExpandCollapse();
        	})
	</script>

	<div class="closeWindow">Close</div>

