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
        request.setAttribute( "selectedTabId", "pathway" );
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
	String pathwayID = (String) request.getParameter("pathwayID");
        String pathwayName = (String) request.getParameter("pathwayName");
	int itemID = Integer.parseInt((String) request.getParameter("itemID"));
	
	log.debug("in pathwayResultsDetails. itemID = " + itemID + " pathwayID = " + pathwayID);

	GeneListAnalysis thisGeneListAnalysis = myGeneListAnalysis.getGeneListAnalysis(itemID, pool);
			
	GeneList thisGeneList = thisGeneListAnalysis.getAnalysisGeneList();
        String pathwayDir = thisGeneList.getPathwayDir(thisGeneList.getGeneListAnalysisDir(userLoggedIn.getUserMainDir()));
        String pathwayDirPlusTime = pathwayDir + thisGeneListAnalysis.getCreate_date_for_filename() + "_"; 
        String auxFileName = pathwayDirPlusTime + "AuxTable.txt";

	log.debug("pathwayDir = "+pathwayDir);

	String[] auxTable = myFileHandler.getFileContents(new File(auxFileName), "withSpaces");

	mySessionHandler.createGeneListActivity("Viewed details of pathway results ", pool);


%>
<%@ include file="/web/geneLists/include/geneListJS.jsp"  %>
<%@ include file="/web/common/header_adaptive_menu.jsp" %>


	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>

	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>

	<div class="dataContainer" style="padding-bottom: 70px;" >
		<div id="related_links">
			<div class="action" title="Return to select a different pathway analysis" style="margin-left: 10px;">
				<a class="linkedImg return" href="pathwayResults.jsp?itemID=<%=itemID%>">
				<%=fiveSpaces%>
				Back to Pathway Results
				</a>
			</div>
		</div>

		<BR><BR>
                <div style="text-align: center; font-weight: bold; font-size:16px;">Gene List Entries for Pathway: <%=pathwayName%></div>
		<BR><BR>
		<table name="items" class="list_base tablesorter" cellpadding="0" cellspacing="3" width="70%">
			<thead>
			<tr class="col_title">
			<th>Entrez ID</th>
			<th>Path ID</th>
			<th>Gene Symbol</th>
			<th>Probeset IDs</th>
			<th>Fold Change Used</th>
			</tr>
			</thead>
			<tbody>
			<%
			for (int i=1; i<auxTable.length; i++) {
				String[] columns = auxTable[i].split("\t");
				for (int j=0; j<columns.length; j++) {
					columns[j] = columns[j].replaceAll("\"", "");
				}
				if (columns[1].equals(pathwayID)) {
					%> <tr> <%
					for (int j=0; j<columns.length; j++) {
						%><td> <%=columns[j]%></td><%
					}
					%></tr> <%
				}
			}
			%>
			</tbody>
		</table>

		<input type="hidden" name="itemID" value="<%=itemID%>">
		<input type="hidden" name="pathwayID" value="<%=pathwayID%>">
	</div>

<%@ include file="/web/common/footer_adaptive.jsp" %>
