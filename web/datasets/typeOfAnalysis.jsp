<%@ include file="/web/datasets/include/analysisHeader.jsp"  %>
<%
	request.setAttribute( "selectedStep", "2" );
	extrasList.add("jquery.dataTables.min.js");
	extrasList.add("typeOfAnalysis.js");
	optionsList.add("datasetVersionDetails");

	String analysisAction = (request.getParameter("analysisAction") != null ? (String) request.getParameter("analysisAction") : "0");
	log.debug("in typeOfAnalysis. analysisAction = "+analysisAction);
	queryString = "?datasetID=" + selectedDataset.getDataset_id() + "&datasetVersion="+selectedDatasetVersion.getVersion();
	log.debug("queryString = " + queryString);
	int numGroups = 0;
	if (analysisAction != null && (analysisAction.equals("diffExp") || analysisAction.equals("cluster"))) {
	        numGroups = selectedDatasetVersion.getNumber_of_non_exclude_groups();
	        int[] groupCount = selectedDatasetVersion.getGroupCounts();
        	// If any of the groups have less than 5 arrays, set a flag to warn that non-parametric
        	// results may be suspect
        	//
        	if (numGroups == 0) {
                	//Error - "Can't do analysis on dataset that was 
                	//normalized without choosing groups 
                	session.setAttribute("errorMsg", "EXP-007");
                	response.sendRedirect(commonDir + "errorMsg.jsp");
        	} else {
                	boolean foundAGroup = false;
                	for (int i=0; i<numGroups; i++) {
                        	if (groupCount[i] < 5) {
                                	session.setAttribute("tooSmallGroupsForNonParametricTest", "true");
                        	}
                        	/* On Sep 8, 2010 we noticed this was commented out, but don't know why, so now it's back in! */
                        	/* Maybe to test a dataset that caused the multiple testing error using the Storey method? */
                        	if (groupCount[i] < 2 && analysisAction.equals("diffExp")) {
                                	//Error - "Can't do differential analysis on a dataset version that  
                                	//has only one chip in one of its groups 
                                	foundAGroup = true;
                        	}
                	}
                	if (foundAGroup) {
				log.debug("foundAGroup");
                        	session.setAttribute("errorMsg", "EXP-016");
                        	response.sendRedirect(datasetsDir + "typeOfAnalysis.jsp");
                	} else {
				mySessionHandler.createDatasetActivity("Chose to do "+ analysisAction + " analysis", dbConn);
				session.setAttribute("verFilterDate", "");
				session.setAttribute("verFilterTime", "");
				response.sendRedirect("filters.jsp" + queryString + "&analysisType="+analysisAction);
			}
		}
	} else if (analysisAction != null && (analysisAction.equals("correlation"))) {
		session.setAttribute("verFilterDate", "");
		session.setAttribute("verFilterTime", "");
		mySessionHandler.createDatasetActivity("Chose to do "+ analysisAction + " analysis", dbConn);
		response.sendRedirect("correlation.jsp" + queryString + "&analysisType="+analysisAction);
	} 
	
%>
	<%@ include file="/web/common/microarrayHeader.jsp" %>
	<%@ include file="/web/datasets/include/viewingPane.jsp" %>
		<div class="brClear"></div>
		<%@ include file="/web/datasets/include/preAnalysisSteps.jsp" %>
		<div class="brClear"></div>
    <%if(!selectedDataset.getName().startsWith("Public HXB/BXH RI Rats (") ||(selectedDataset.getName().startsWith("Public HXB/BXH RI Rats (") && selectedDatasetVersion.getVersion()>3)){%>
    <div class="page-intro">
                        <p>You may perform any of the following types of analyses on your normalized dataset.</p>
                        <% if (new edu.ucdenver.ccp.PhenoGen.data.Array().EXON_ARRAY_TYPES.contains(selectedDataset.getArray_type())) { %>
                        <p>Choose a new analysis method to start a new analysis or choose previous results to continue/review an analysis.  </p>
                        <%}%>
    </div> <!-- // end page-intro-->
  	<div class="analysis_choice">
    	<form name="typeOfAnalysisForm" action="" method="post">
		<h3>Start A New Analysis:</h3> Choose a type of analysis:

		<%
		selectName = "analysisAction";
        	selectedOption = analysisAction;
        	onChange = "submit()";

		optionHash = new LinkedHashMap();
        	optionHash.put("0", "--- Select Analysis Method ---");
        	optionHash.put("diffExp", "Differential Expression");
        	optionHash.put("correlation", "Correlation");
        	optionHash.put("cluster", "Clustering");

		%><%@ include file="/web/common/selectBox.jsp" %>
			<span class="info" title="<i>Differential Expression</i> will find genes whose expression values differ between groups of samples.<BR><BR>
						<i>Correlation</i> will find genes whose expression values follow a pattern similar to a pattern in phenotypic data.<BR><BR>
						<i>Clustering</i> will find genes and/or samples whose expression values show similar trends.">
                    		<img src="<%=imagesDir%>icons/info.gif" alt="Help">
			</span>

		<input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>" />
		<input type="hidden" name="datasetVersion" value="<%=selectedDatasetVersion.getVersion()%>" />
        <input type="hidden" name="action" value="">
    	</form>
	</div>
    <%}else{%>
    	<div class="page-intro">
                        <p>This is a previous version of the dataset for an earlier version of the genome.  A newer version is available for new analysis, while this version has been preserved for access to previous analyses.</p>
       </div>
    <%}%>
    <BR />
    <% if (new edu.ucdenver.ccp.PhenoGen.data.Array().EXON_ARRAY_TYPES.contains(selectedDataset.getArray_type())) { %>
        <div class="list_container">
        <form name="tableList" action="choosePrevResult.jsp" method="get">
                <input type="hidden" name="datasetVersion" value="<%= selectedDatasetVersion.getVersion()%>" />
                <input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>" />
                <input type="hidden" name="itemIDString" value=""/>
                <input type="hidden" name="dsFilterStatID" value=""/>
                <input type="hidden" name="specificStep" value=""/>
                <h3>Go To Previous Analysis:</h3><BR />
                <table id="prevList" class="list_base" cellpadding="0" cellspacing="3" width="95%" style="text-align:center;">
                <thead>
                <tr>
                <th colspan="1" class="topLine noSort noBox">&nbsp;</th>
                <th colspan="2" class="center noSort topLine">Filters</th>
                <th colspan="3" class="center noSort topLine">Statistics</th>
                <th colspan="3" class="topLine noSort noBox">&nbsp;</th>
                </tr>
                <tr class="col_title">
                    <th>Date Created</th>
                    <th class="noSort">Filters</th>
                    <th>Probeset Count</th>
                    <th class="noSort">Methods</th>
                    <th> Status</th>
                    <th> Probeset Count</th>
                    <th>Analysis Type</th>
                    <th>Expiration Date</th>
                    <th class="noSort">Delete</th>
                </tr>
                </thead>
                <tbody>
                <%
                    User tmpUser=(User) session.getAttribute("userLoggedIn");
                    selectedDatasetVersion.getFilterStatsFromDB(tmpUser.getUser_id(),dbConn);
                    DSFilterStat[] dsfs = selectedDatasetVersion.getFilterStats(tmpUser.getUser_id(),dbConn);
                    if(dsfs!=null&&dsfs.length>0){
                        for (int j=0; j<dsfs.length; j++) {
                            FilterStep[] tmpFSteps=new FilterStep[0];
							FilterGroup tmpFG=dsfs[j].getFilterGroup();
							if(tmpFG!=null){
								tmpFSteps=tmpFG.getFilterSteps();
							}
							StatsStep[] tmpSSteps=new StatsStep[0];
							StatsGroup tmpSG=dsfs[j].getStatsGroup();
							if(tmpSG!=null){
                            	tmpSSteps=tmpSG.getStatsSteps();
							}
                        	if((tmpFSteps==null||(tmpFSteps!=null&&tmpFSteps.length==0)||(tmpFSteps.length==1&&tmpFSteps[0].getFilterName().equals("Not Filtered")))&&(tmpSSteps==null || (tmpSSteps!=null && tmpSSteps.length==0))){%>
                            <%}else{%>
                                <tr id=<%= dsfs[j].getDSFilterStatID()%>>
                                    <td><%= dsfs[j].getCreateDate()%></td>
                                    <td>
                                    <% if(tmpFSteps!=null&&tmpFSteps.length>0){ 
                                        for(int i=0;i<tmpFSteps.length;i++){
											if(i>0){%>
                                            <BR /><BR />
                                            <%}%>
                                            Step <%= tmpFSteps[i].getStepNumber()%>: <%= tmpFSteps[i].getFilterName()%>
                                            <%if(tmpFSteps[i].getFilterParameter()!=null && !tmpFSteps[i].getFilterParameter().equals("")){%>
                                            	<BR /><%=tmpFSteps[i].getFilterParameter()%>
                                            <%}%>
                                        <%}
                                    }else{%>
                                        Not Yet Performed
                                    <%}%>
                                    </td>
                                    <td><%if(tmpFG!=null){%>
                                    <%=tmpFG.getLastCount() %>
                                    <%}%>
                                    </td>
                                    <td>
                                    <% if(tmpSSteps!=null&&tmpSSteps.length>0){
                                        for(int i=0;i<tmpSSteps.length;i++){%>
                                         Step <%= tmpSSteps[i].getStepNumber()%>: <%= tmpSSteps[i].getStatsName()%> (<%= tmpSSteps[i].getShortParam()%>)<BR /><BR />
                                        <%}
                                        if((dsfs[j].getAnalysisType().equals("Differential Expression")||dsfs[j].getAnalysisType().equals("Correlation"))
                                        && tmpSSteps!=null &&tmpSSteps.length==1){
                                        	if(dsfs[j].getStatsGroup().getStatusString().equals("Done")){%>
                                            	Step 2: <span id="multtest" class="specific"><a href="#">Run Multiple Testing Correction</a></span> <img src="/PhenoGen/web/images/icons/info.gif" alt="Help" title="Continue analysis with multiple testing correction.">
                                            <%}%>
                                        <%}else if(dsfs[j].getAnalysisType().equals("Clustering") && tmpSSteps!=null &&tmpSSteps.length==1){
											if(dsfs[j].getStatsGroup().getStatusString().equals("Done")){%>
                                        	<span id="cluster" class="specific"><a href="#">Save Results or Rerun Clustering</a></span> <img src="/PhenoGen/web/images/icons/info.gif" alt="Help" title="Click to rerun and save clusters."><BR /><BR />
                                            <span id="clusterResults" class="specific"><a href="#">Review Cluster Results</a></span> <img src="/PhenoGen/web/images/icons/info.gif" alt="Help" title="Click to Review Cluster Results.">
                                            <%}
                                        }
                                    }else{
                                        if((dsfs[j].getAnalysisType().equals("Differential Expression")||dsfs[j].getAnalysisType().equals("Correlation"))
                                        && (tmpSSteps==null || tmpSSteps.length==0) && tmpFSteps!=null &&tmpFSteps.length>0 ){
											if(dsfs[j].getAnalysisType().equals("Differential Expression")){%>
                                            Step 1: <span id="stats" class="specific"><a href="#">Run Statistics</a></span> <img src="/PhenoGen/web/images/icons/info.gif" alt="Help" title="Continue analysis with statistics.">
                                            <%}else if(dsfs[j].getAnalysisType().equals("Correlation")){%>
                                            Step 1: <span id="statscorr" class="specific"><a href="#">Run Statistics</a></span> <img src="/PhenoGen/web/images/icons/info.gif" alt="Help" title="Continue analysis with statistics.">
                                            <%}%>
                                        <%}else if(dsfs[j].getAnalysisType().equals("Clustering") && (tmpSSteps==null || tmpSSteps.length==0) && tmpFSteps!=null &&tmpFSteps.length>0 ){%>
                                        	Step 1: <span id="cluster" class="specific"><a href="#">Run Clustering</a></span> <img src="/PhenoGen/web/images/icons/info.gif" alt="Help" title="Continue analysis with clustering.">
										<%}else{%>
                                            Not Yet Performed
                                        <%}%>
                                    <%}%>
                                    <%if((dsfs[j].getAnalysisType().equals("Differential Expression")||dsfs[j].getAnalysisType().equals("Correlation"))
                                        && tmpSSteps!=null &&tmpSSteps.length==2){%>
                                        <span id="genelist" class="specific"><a href="#">Save Gene List as ...</a></span> <img src="/PhenoGen/web/images/icons/info.gif" alt="Help" title="Allows you to return and save a gene list in case you couldn't after multiple testing or if you just want to save it again."><BR /><BR />
                                        <span id="multtest" class="specific"><a href="#">Rerun Multiple Testing Correction</a></span> <img src="/PhenoGen/web/images/icons/info.gif" alt="Help" title="Allows you to rerun Multiple Testing Correction with a new P-value Cut-off and then save a new Gene List.">
                                    <%}%>
                                    
                                    </td>
                                    <td><%=dsfs[j].getStatsGroup().getStatusString() %></td>
                                    <td><%=(dsfs[j].getStatsGroup().getLastCount()==-1) ? (dsfs[j].getAnalysisTypeShort().equals("cluster"))? "N/A": "" :dsfs[j].getStatsGroup().getLastCount()  %></td>
                                    <td><%=dsfs[j].getAnalysisType() %></td>
                                    <td><div class="expiration"><%=dsfs[j].getExpirationDate().toString() %> <img src="<%=imagesDir%>icons/add.png"></div></td>
                                    <td class="actionIcons">
                                    <div class="linkedImg delete"></div>
                                </td>
                                </tr>
                    	<%}
						}	
                    } else { 
                    %> <tr><td colspan="9" class="center"><h2>There are no Filter/Statistics results for this dataset</h2></td></tr>
                    <% } %>
                    </tbody>
                    </table>
                
        </form>
        </div>
  <% }%>
	<BR><BR>
	<BR><BR>
	<BR><BR>
	<BR><BR>
    <div class="deleteItem"></div>


<%@ include file="/web/common/footer.jsp" %>
<script type="text/javascript">
	$(document).ready(function() {
		setupPage();
		setTimeout("setupMain()", 100);
		
		$("table[id='prevList']").dataTable({
					"bPaginate": false,
					"bProcessing": true,
					"bStateSave": false,
					"bAutoWidth": true,
					"sScrollX": "950px",
					"sScrollY": "550px",
					"aaSorting": [[ 4, "desc" ],[ 0, "desc" ]],
					/*"aoColumnDefs": [
      						{ "bVisible": false, "aTargets": hideFirst }
    					],*/
					"sDom": '<"leftSearch"fr><t>'
					/*"oTableTools": {
							"sSwfPath": "/css/swf/copy_csv_xls.swf",
							"aButtons": [ "csv", "xls","copy"]
							}*/
	
			});
		
		window.setInterval(function(){
  			location.reload(true);
		}, 60000);
	});
</script>

