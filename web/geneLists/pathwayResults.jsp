<%--
 *  Author: Cheryl Hornbaker
 *  Created: August, 2010
 *  Description:  This file formats the pathway results.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %> 
<% 	
	int itemID = Integer.parseInt((String) request.getParameter("itemID"));
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
	optionsList.add("download");
	
	log.debug("in pathwayResults. itemID = " + itemID);
	extrasList.add("pathwayResults.js");

	GeneListAnalysis thisGeneListAnalysis = myGeneListAnalysis.getGeneListAnalysis(itemID, dbConn);
			
	GeneList thisGeneList = thisGeneListAnalysis.getAnalysisGeneList();
	String pValueUsed = thisGeneListAnalysis.getThisParameter("P-value Used");
        String pathwayDir = thisGeneList.getPathwayDir(thisGeneList.getGeneListAnalysisDir(userLoggedIn.getUserMainDir()));
        String pathwayDirPlusTime = pathwayDir + thisGeneListAnalysis.getCreate_date_for_filename() + "_"; 
	String relativePath = myFileHandler.getPathFromUserFiles(pathwayDirPlusTime);
        String outputFileName = pathwayDirPlusTime + "OutputTable.txt";
        String auxFileName = pathwayDirPlusTime + "AuxTable.txt";
        String plotFileName = "Plot.jpg";

	log.debug("pathwayDir = "+pathwayDir);
	log.debug("outputFileName = "+outputFileName);

	String[] outputTable = myFileHandler.getFileContents(new File(outputFileName), "withSpaces");
	String[] auxTable = myFileHandler.getFileContents(new File(auxFileName), "withSpaces");

	if ((action != null) && action.equals("Download")) {
		String downloadPath = userLoggedIn.getUserGeneListsDownloadDir();  
		String downloadFileName = downloadPath +
                         		thisGeneList.getGene_list_name_no_spaces() + 	
					"_PathwayOutput.txt";
		log.debug("downloadFileName = "+downloadFileName);
		myFileHandler.copyFile(new File(outputFileName), new File(downloadFileName));

		request.setAttribute("fullFileName", downloadFileName);
                myFileHandler.downloadFile(request, response);
		// This is required to avoid the getOutputStream() has already been called for this response error
		out.clear();
		out = pageContext.pushBody(); 

		mySessionHandler.createGeneListActivity("Downloaded Pathway Results", dbConn);
	} else {
		mySessionHandler.createGeneListActivity("Viewed all pathway results", dbConn);
	}


%>
<%@ include file="/web/common/header.jsp" %>


	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>
	<div class="page-intro">
		<p></p>
	</div> <!-- // end page-intro -->

	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>

	<div class="dataContainer" >
		<div id="related_links">
			<div class="action" title="Return to select a different pathway analysis">
				<a class="linkedImg return" href="pathwayTab.jsp">
				<%=fiveSpaces%>
				Select Another Pathway Analysis 
				</a>
			</div>
		</div>
		<div class="brClear"></div>

		<div class="title">Parameters Used:</div> 
		<table class="list_base" cellpadding="0" cellspacing="3" width="50%">
			<tr class="col_title">
				<th class="noSort">Parameter Name</th>
				<th class="noSort">Value</th>
			</tr>
			<tr>
				<td width="30%"><b>P-value Used:</b> </td>
				<td width="70%"><%=pValueUsed%></td>
			</tr>
		</table>

		<BR>

        <div class="other_actions" >
            <span id="PathwayPlotLink"><a href="#">Pathway Plot</a></span>
        </div>			
		<table name="items" class="list_base tablesorter" cellpadding="0" cellspacing="3" width="95%">
			<thead>
			<tr class="col_title">
			<th>Path Name</th>
			<th>Path ID</th>
			<th>Path Size</th>
			<th>Num DE Genes</th>
			<th>DE Genes</th>
			<th>tA</th>
			<th>pNDE</th>
			<th>pPert</th>
			<th>pG</th>
			<th>pGFdr</th>
			<th>pGFWER</th>
			<th>Status</th>
			</tr>
			</thead>
			<tbody>
			<%
			for (int i=1; i<outputTable.length; i++) {
				%> <tr> <%
				String[] columns = outputTable[i].split("\t");
				for (int j=0; j<columns.length-1; j++) {
					String value = columns[j].replaceAll("\"", "");
					String pathwayLink = columns[columns.length-1].replaceAll("\"", "");
					String pathwayID = columns[1].replaceAll("\"", "");
					if (j>0) {
						if (j==4) {
							%><td><a href="<%=geneListsDir%>pathwayResultsDetails.jsp?itemID=<%=itemID%>&pathwayID=<%=pathwayID%>"> <%=value%></td><%
						} else {
							%><td> <%=value%></td><%
						}
					} else {
					     if (value.equalsIgnoreCase("No Pathways Found")) {%>
						      <td><%=value%></td>
					   <%} else {%>
						     <td><a href="<%=pathwayLink%>" target="KEGG Window"><%=value%></a></td><%
					     }
					}
				}
				%></tr> <%
			}
			%>
			</tbody>
		</table>

        <input type="hidden" name="pathwayPlotUrl" id="pathwayPlotUrl" value="<%=request.getContextPath()%><%=relativePath%><%=plotFileName%>"/>
        	<form   method="POST"
                	action="pathwayResults.jsp"
			name="pathwayResults"
                	enctype="application/x-www-form-urlencoded">

		<input type="hidden" name="action" value="">
		<input type="hidden" name="itemID" value="<%=itemID%>">
		</form>
	</div>
    <div class="itemDetails"></div>
	<script type="text/javascript">
		/* * *
		 *  Sets up the "Download" link click
		/*/
		$(document).ready(function() {
			setupPage();
		});
	</script>
<%@ include file="/web/common/footer.jsp" %>
