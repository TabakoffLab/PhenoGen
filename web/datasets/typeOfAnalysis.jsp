<%@ include file="/web/datasets/include/analysisHeader.jsp"  %>
<%
	request.setAttribute( "selectedStep", "2" );
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
    <BR />
    <% if (new edu.ucdenver.ccp.PhenoGen.data.Array().EXON_ARRAY_TYPES.contains(selectedDataset.getArray_type())) { %>
        <div class="list_container">
        <form name="tableList" action="choosePrevResult.jsp" method="get">
                <input type="hidden" name="datasetVersion" value="<%= selectedDatasetVersion.getVersion()%>" />
                <input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>" />
                <input type="hidden" name="itemIDString" value=""/>
                <input type="hidden" name="dsFilterStatID" value=""/>
                <h3>Go To Previous Analysis:</h3><BR />
                <table name="items" class="list_base tablesorter" cellpadding="0" cellspacing="3" width="95%">
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
                        %>
                        <tr id=<%= dsfs[j].getDSFilterStatID()%>>
                            <td><%= dsfs[j].getCreateDate()%></td>
                            <td>
                            <% if(tmpFSteps!=null&&tmpFSteps.length>0){ 
								for(int i=0;i<tmpFSteps.length;i++){%>
                                 	Step <%= tmpFSteps[i].getStepNumber()%>: <%= tmpFSteps[i].getFilterName()%><BR />
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
                                 Step <%= tmpSSteps[i].getStepNumber()%>: <%= tmpSSteps[i].getStatsName()%> (<%= tmpSSteps[i].getShortParam()%>)<BR />
                            	<%}
							}else{%>
                            	Not Yet Performed
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
	});
</script>

