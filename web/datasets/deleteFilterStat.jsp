<%--
 *  Author: Cheryl Hornbaker
 *  Created: Oct, 2007
 *  Description:  This file handles deleting a cluster result
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>
<%
	log.debug("DELETE FILTER STAT");
	 extrasList.add("main.js");
	
	DataSource pool=(DataSource)session.getAttribute("dbPool");
	
   String itemIDString = (request.getParameter("itemIDString") == null ? 
				(request.getParameter("itemID") == null ? "-99": (String) request.getParameter("itemID")) :
				(String) request.getParameter("itemIDString"));
	userLoggedIn=(User)session.getAttribute("userLoggedIn");

	log.debug("action = "+action);
	DSFilterStat dsfs=selectedDatasetVersion.getFilterStat(Integer.parseInt(itemIDString),userLoggedIn.getUser_id(),pool);
	if (action != null && action.equals("Delete")) {
        	if (userLoggedIn.getUser_name().equals("guest")) {
                	//Error - "Feature not allowed for guests"
                	session.setAttribute("errorMsg", "GST-005");
                	response.sendRedirect(commonDir + "errorMsg.jsp");
        	} else {
                	log.debug("deleting Filter/Stats Results");
                	log.debug("deleting Dataset_Filter_Stat_ID: "+itemID);
					String analysisPathPartial = userLoggedIn.getUserGeneListsDir() + 
                       selectedDataset.getNameNoSpaces() + 
                       "_v" +
                       selectedDatasetVersion.getVersion() +
                       "_Analysis" + "/";
					String curDate=dsfs.getFilterDate();
					String curTime=dsfs.getFilterTime();
					String analysisPathPlusDate = analysisPathPartial + curDate + "/";
					String analysisPathPlusDateTime = analysisPathPlusDate + curTime + "/";
    				analysisPath = analysisPathPlusDateTime;
					String outputDir=selectedDataset.getPath();
					if(selectedDataset.getCreator().equals("public")){
						outputDir=userLoggedIn.getUserDatasetDir() + selectedDataset.getNameNoSpaces() + "/";
					}
					Async_HDF5_FileHandler ahf=new Async_HDF5_FileHandler(selectedDataset,"v"+selectedDatasetVersion.getVersion(),outputDir,"Affy.NormVer.h5","deleteFilterStats",null,session);
                   	ahf.setDeleteFilterStats(curDate,curTime,dbConn);
                    Thread thread = new Thread(ahf);
					thread.start();
					myFileHandler.deleteAllFilesPlusDirectory(new File(analysisPath));
					dsfs.deleteFromDB(pool);
					mySessionHandler.createDatasetActivity("Deleted Filter/Stats results for Dataset_Filter_Stat_ID = " + itemID, dbConn);
					//Success - "Cluster analysis deleted"
					session.setAttribute("successMsg", "EXP-055");
					response.sendRedirect(commonDir + "successMsg.jsp");
			}

   }
   log.debug("END DELETE FILTER STAT");
%>
	<div class="scrollable">
				<div class="title"> Filter Statistic Results Details: </div>
      		Filter:	
            <table class="list_base tablesorter" id="filterLists" cellpadding="0" cellspacing="3">
					<thead>
                <tr class="col_title">
                	<th>Step</th>
                    <th>Filter Method</th>
                    <th>Probeset Count</th>
                </tr>
                </thead>
                <tbody>
                <%
                            FilterStep[] tmpFSteps=new FilterStep[0];
							FilterGroup tmpFG=dsfs.getFilterGroup();
							if(tmpFG!=null){
								tmpFSteps=tmpFG.getFilterSteps();
							}
							if(tmpFSteps.length>0){
								for(int i=0;i<tmpFSteps.length;i++){%>
                                    <tr>
                                        <td><%= tmpFSteps[i].getStepNumber()%></td>
                                        <td><%= tmpFSteps[i].getFilterName()%></td>
                                        <td><%= tmpFSteps[i].getStepCount() %></td>
                                      
                                    </tr>
                                 <%}   
                    		}else{%>
                    				<tr><td colspan="3">No Filtering Performed</td></tr>
							<%}%>
                    </tbody>
				</table>
            Statistics:
			<table class="list_base" id="statLists" cellpadding="0" cellspacing="3">
					<thead>
                <tr class="col_title">
                	<th>Step</th>
                    <th>Statistics Method</th>
                    <th>Statistics Parameters</th>
                    <th>Probeset Count</th>
                </tr>
                </thead>
                <tbody>
                <%
							StatsStep[] tmpSSteps=new StatsStep[0];
							StatsGroup tmpSG=dsfs.getStatsGroup();
							if(tmpSG!=null){
                            	tmpSSteps=tmpSG.getStatsSteps();
							}
							if(tmpSSteps.length>0){
								for(int i=0;i<tmpSSteps.length;i++){%>
                                    <tr>
                                        <td><%= tmpSSteps[i].getStepNumber()%></td>
                                        <td><%= tmpSSteps[i].getStatsName()%></td>
                                        <td><%= tmpSSteps[i].getStatsParameter()%></td>
                                        <td><%= tmpSSteps[i].getStepCount() %></td>
                                      
                                    </tr>
                    			<%}	
					}else{%>
                    	<tr><td colspan="4">No Statistics Performed</td></tr>
					<%}%>
                    </tbody>
				</table>
	
		 <div class="brClear"></div>

		<form	method="post" 
			action="deleteFilterStat.jsp" 
			enctype="application/x-www-form-urlencoded"
			name="deleteFilterStat">

			<BR> <BR>
			<center> <input type="submit" name="action" value="Delete" onClick="return confirmDelete()"></center>
			<input type="hidden" name="itemIDString" value="<%=itemIDString%>">
			<input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>">
			<input type="hidden" name="datasetVersion" value="<%=selectedDatasetVersion.getVersion()%>">
		</form>
        <script type="text/javascript">
                var tablesorterSettings = { widgets: ['zebra'] };
                $(document).ready(function(){
                        $("table[id='filterLists']").tablesorter(tablesorterSettings);
                        $("table[id='filterLists']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
                        $("table[id='statLists']").tablesorter(tablesorterSettings);
                        $("table[id='statLists']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
						var filterRows=$("table[name='filterLists']").find("tr").not(".title, .col_title");
						var statRows=$("table[name='statLists']").find("tr").not(".title, .col_title");
						stripeAndHoverTable( filterRows );
						stripeAndHoverTable( statRows );
                });
	</script>