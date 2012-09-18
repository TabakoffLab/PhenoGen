<%--
 *  Author: Cheryl Hornbaker
 *  Created: Feb, 2009
 *  Description:  The web page created by this file allows the user to  
 *  		confirm his/her desire to delete a dataset.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>
<%
	%> <%@ include file="/web/datasets/include/splitDatasetIDAndVersion.jsp"  %> <%

	log.info("in deleteDataset.jsp. user = " + user + ", itemIDString = "+itemIDString);

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-005");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }

	log.debug("action = "+action);
	boolean userCanDelete = (selectedDataset.getCreator().equals("public") ? false : true); 

	String message = (userCanDelete ? "" : "You may only delete datasets that you own."); 
	// Tried to use this to dynamically calculate how big to create the modal window, but doesn't work 'cuz height is not set til after modal is opened.
	int numElements = 0;

	if ( userCanDelete && (action != null) && action.equals("Delete")) {
        	try {
			log.debug("deleteing selectedDatasetID = "+selectedDataset.getDataset_id());
			//
			// delete dataset and all the files in the directory
			//
			if (specificVersion) {
				mySessionHandler.createDatasetActivity("Deleted Dataset Version  " + 
						" # " + 
						selectedDatasetVersion.getVersion() + 
						" called '" + selectedDataset.getName() + "'" , dbConn);
						String ver="v"+selectedDatasetVersion.getVersion();
				Async_HDF5_FileHandler ahf=new Async_HDF5_FileHandler(selectedDataset,ver,selectedDataset.getPath()+ver+"/","Affy.NormVer.h5","deleteVersion",null,session);
                Thread thread = new Thread(ahf);
				thread.start();
				selectedDatasetVersion.deleteDatasetVersion(userLoggedIn.getUser_id(),dbConn);
				session.setAttribute("successMsg", "EXP-022");
				//re-query so the screen is refreshed
				log.debug("re-querying selected Dataset");
				selectedDataset = myDataset.getDataset(selectedDataset.getDataset_id(), userLoggedIn, dbConn);
				log.debug("now array type is " + selectedDataset.getArray_type());
				session.setAttribute("selectedDataset", selectedDataset);
				session.setAttribute("selectedDatasetVersion", null);
				
			} else {
				mySessionHandler.createDatasetActivity("Deleted Dataset # " + selectedDataset.getDataset_id() + 
						" called '" + selectedDataset.getName() + "'",
                			dbConn);
				selectedDataset.deleteDataset(userLoggedIn.getUser_id(),dbConn);
				session.setAttribute("selectedDataset", null);
				session.setAttribute("successMsg", "EXP-021");
			}

			session.setAttribute("privateDatasetsForUser", null);
			//Success - "Dataset deleted"
			//response.sendRedirect(commonDir + "successMsg.jsp");
			if (specificVersion) {
				log.debug("deleted a specific version, so redirecting to listDatasetVersions");
				response.sendRedirect(datasetsDir + "listDatasetVersions.jsp?datasetID="+selectedDataset.getDataset_id());
			} else {
				log.debug("deleted the dataset, so redirecting to listDatasets");
				response.sendRedirect(datasetsDir + "listDatasets.jsp");
			}
        	} catch( Exception e ) {
            		throw e;
        	}
	}
	formName = "deleteDataset.jsp";
%>

	<div class="scrollable">
	<% if (selectedDataset.getCreator().equals("public")) { %> 
		<h2><%=message%></h2> 
	<% } else { 
		if (!specificVersion) {
			numElements = selectedDataset.getDatasetVersions().length; 
			if (selectedDataset.getDatasetVersions() != null && selectedDataset.getDatasetVersions().length > 0) { %> 
				<div class="title"> Data Linked to Dataset&nbsp;'<%=selectedDataset.getName()%>': </div>
				<div class="title"> <%=selectedDataset.getDatasetVersions().length%>&nbsp;normalized versions have been saved for this dataset: </div>
      				<table class="list_base" id="versions" cellpadding="0" cellspacing="3">
					<thead>
                                	<tr class="col_title">
                                        	<th>#
                                        	<th>Version Name
                                        	<th>Create date
                                        	<th># of Gene Lists Saved
                                            <th># of Filter/Stats Results
					</tr>
					</thead>
					<tbody>
                               		<% for (int k=0; k<selectedDataset.getDatasetVersions().length; k++) {
						%><tr>
							<td><%=selectedDataset.getDatasetVersions()[k].getVersion()%></td>
                                                	<td><%=selectedDataset.getDatasetVersions()[k].getVersion_name()%></td>
                                                	<td><%=selectedDataset.getDatasetVersions()[k].getCreate_date_as_string()%></td>
                                                	<td class="center"><%=selectedDataset.getDatasetVersions()[k].getGeneLists().length%></td>
                                                    <td class="center"><%=selectedDataset.getDatasetVersions()[k].getFilterStats(userLoggedIn.getUser_id(),dbConn).length%></td>
						</tr><%
					}
					%> 
					<tbody>
				</table> 
				<%
			} else {
				%>
      				<table class="list_base" cellpadding="0" cellspacing="3">
                                	<tr class="title">
        					<th colspan="100%">No normalized versions have been saved for this dataset.</th>
					</tr>
				</table> <%
			} 
		} else {
			numElements = selectedDatasetVersion.getGeneLists().length; 
			%>
			<div class="title"> Data Linked to Normalized Version of Dataset&nbsp;'<%=selectedDataset.getName()%>': </div>
			<div class="title"> <%=selectedDatasetVersion.getGeneLists().length%>&nbsp;gene lists have been saved for this normalized version of dataset: </div>
			<% if (selectedDatasetVersion.getGeneLists().length > 0) { %>
      				<table class="list_base" id="geneLists" cellpadding="0" cellspacing="3">
					<thead>
                                	<tr class="col_title">
                                        	<th>Gene List Name
                                        	<th># of Genes
                                        	<th>Create date
					</tr>
					</thead>
					<tbody>
                    <% for (int k=0; k<selectedDatasetVersion.getGeneLists().length; k++) {
						GeneList thisGeneList = selectedDatasetVersion.getGeneLists()[k];
						%><tr>
							<td><%=thisGeneList.getGene_list_name()%></td>
                                                	<td><%=thisGeneList.getNumber_of_genes()%></td>
                                                	<td><%=thisGeneList.getCreate_date_as_string()%></td>
						</tr><%
					}
				%> 
					<tbody>
				</table> 
			<%
			}%>
			<div class="title"> <%=selectedDatasetVersion.getFilterStats(userLoggedIn.getUser_id(),dbConn).length%>&nbsp;filter/stats results are available for this normalized version of dataset: </div>
            <% if (selectedDatasetVersion.getFilterStats(userLoggedIn.getUser_id(),dbConn).length > 0) { %>
      				<table class="list_base" id="filterstatLists" cellpadding="0" cellspacing="3">
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
                </tr>
                </thead>
                <tbody>
                <%
                    DSFilterStat[] dsfs = selectedDatasetVersion.getFilterStats(userLoggedIn.getUser_id(),dbConn);
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
                            <% if(tmpFSteps!=null){ 
								for(int i=0;i<tmpFSteps.length;i++){%>
                                 	Step <%= tmpFSteps[i].getStepNumber()%>: <%= tmpFSteps[i].getFilterName()%><BR />
                            	<%}
							}%>
                            </td>
                            <td><%if(tmpFG!=null){%>
							<%=tmpFG.getLastCount() %>
                            <%}%>
                            </td>
                            <td>
                            <% if(tmpSSteps!=null){
								for(int i=0;i<tmpSSteps.length;i++){%>
                                 Step <%= tmpSSteps[i].getStepNumber()%>: <%= tmpSSteps[i].getStatsName()%> (<%= tmpSSteps[i].getShortParam()%>)<BR />
                            	<%}
							}%>
                            
                            </td>
                            <td><%=dsfs[j].getStatsGroup().getStatusString() %></td>
                            <td><%=(dsfs[j].getStatsGroup().getLastCount()==-1) ? (dsfs[j].getAnalysisTypeShort().equals("cluster"))? "N/A": "Not Performed" :dsfs[j].getStatsGroup().getLastCount()  %></td>
                            <td><%=dsfs[j].getAnalysisType() %></td>
                            <td><%=dsfs[j].getExpirationDate().toString() %> </td>
                        </tr>
                    <%}	%>
                    </tbody>
				</table> 
			<%}%>
		<%}%> 
        <div class="brClear"></div>

		<form	method="post" 
			action="deleteDataset.jsp" 
			enctype="application/x-www-form-urlencoded"
			name="deleteDataset">

			<BR> <BR>
			<center> <input type="submit" name="action" value="Delete" onClick="return confirmDelete()"></center>
			<input type="hidden" name="itemIDString" value="<%=itemIDString%>">
			<input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>">
			<input type="hidden" name="datasetVersion" value="<%=selectedDatasetVersion.getVersion()%>">
		</form>
<% 	
	} 
%>
	</div>
	<script type="text/javascript">
                var tablesorterSettings = { widgets: ['zebra'] };
                $(document).ready(function(){
                        $("table[id='versions']").tablesorter(tablesorterSettings);
                        $("table[id='versions']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
                        $("table[id='geneLists']").tablesorter(tablesorterSettings);
                        $("table[id='geneLists']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
                });
	</script>

