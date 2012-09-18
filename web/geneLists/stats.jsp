<%@ include file="/web/geneLists/include/geneListHeader.jsp"%>

<%
	log.debug("in geneList.jsp. ID = "+selectedGeneList.getGene_list_id());

	request.setAttribute( "selectedTabId", "stats" );
	extrasList.add("stats.js");
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
	optionsListModal.add("download");
	GeneList.Gene[] myGeneArray = selectedGeneList.getGenesAsGeneArray(dbConn);
	String[] columnHeadings = selectedGeneList.getColumnHeadings();
	Hashtable<String, Integer> indexHash = selectedGeneList.getSortingColumnIdxHash();
//	log.debug("indexHash ="); myDebugger.print(indexHash);

	//log.debug("iDecoderSet = "); myDebugger.print(iDecoderSet);

       	if ((action != null) && action.equals("Download")) {
		log.debug("action is Download");
		//log.debug("columnHeadings ="); myDebugger.print(columnHeadings);
		List<String> indexHeadings = new ArrayList<String>();
		List<String> groupMeanHeadings = new ArrayList<String>();
		String output = "Accession ID,Gene ID,";
                for (int j=0; j<columnHeadings.length; j++) {
			if (indexHash.containsKey(columnHeadings[j])) {
				indexHeadings.add(columnHeadings[j]);
                	}                 
		}
		// Then print the headings that are group means
                for (int j=0; j<columnHeadings.length; j++) {
			if (!indexHash.containsKey(columnHeadings[j])) {
				groupMeanHeadings.add(columnHeadings[j]);
			}
		}
		output = output + (indexHeadings.size() > 0 ? myObjectHandler.getAsSeparatedString(indexHeadings, ",") + "," : "") +
					(groupMeanHeadings.size() > 0 ? myObjectHandler.getAsSeparatedString(groupMeanHeadings, ",") + "," : "");
		output = output + "\r\n"; 
		for (int i=0; i<myGeneArray.length; i++) {
			Identifier thisIdentifier = myIdentifier.getIdentifierFromSet(myGeneArray[i].getGene_id(), iDecoderSet); 			
			output = output + myGeneArray[i].getGene_id() + ","; 
			if (thisIdentifier != null) {
				Set geneSymbols = myIDecoderClient.getValues(myIDecoderClient.getIdentifiersForTargetForOneID(thisIdentifier.getTargetHashMap(), 
										new String[] {"Gene Symbol"}));
				if (geneSymbols.size() > 0) { 						
					output = output + myObjectHandler.getAsSeparatedString(geneSymbols, "///");
				} 
			}
			output = output + ",";
			if (myGeneArray[i].getStatisticsValues() != null && myGeneArray[i].getStatisticsValues().size() > 0) {
				List<String> indexValues = new ArrayList<String>();
				List<String> groupMeanValues = new ArrayList<String>();
				// First print those values that are not group means
                                       for (int j=0; j<myGeneArray[i].getStatisticsValues().size(); j++) {
					if (indexHash.containsValue(j)) {
						indexValues.add(Double.toString(myGeneArray[i].getStatisticsValues().get(j)));
                			}                 
				}
				// Then print those values that are group means
                                       for (int j=0; j<myGeneArray[i].getStatisticsValues().size(); j++) {
					if (!indexHash.containsValue(j)) {
						groupMeanValues.add(Double.toString(myGeneArray[i].getStatisticsValues().get(j)));
                			}                 
				}
				output = output + (indexValues.size() > 0 ? myObjectHandler.getAsSeparatedString(indexValues, ",") + "," : "") +
							(groupMeanValues.size() > 0 ? myObjectHandler.getAsSeparatedString(groupMeanValues, ",") + "," : "");
			}
			output = output + "\r\n";
		}
		mySessionHandler.createGeneListActivity("Downloaded Gene List With Statistics", dbConn);
		String fileName = userLoggedIn.getUserGeneListsDir() + "downloads/" + selectedGeneList.getGene_list_name() + "Gene_List_Statistics.csv";
		myFileHandler.writeFile(output, fileName);
		request.setAttribute("fullFileName", fileName);
		myFileHandler.downloadFile(request, response);
		// This is required to avoid the getOutputStream() has already been called for this response error
		out.clear();
		out = pageContext.pushBody(); 
	}
	mySessionHandler.createGeneListActivity("Looked at analysis statistics for gene list", dbConn);
%>

<%@ include file="/web/common/header.jsp" %>

<script type="text/javascript">
    var crumbs = ["Home", "Research Genes", "Analysis Statistics"];
</script>

<%@ include file="/web/geneLists/include/viewingPane.jsp" %> 
        <div class="page-intro">
                <p> This page contains the values from the statistical analysis from which this gene list was 
		derived.
                </p>
        </div> <!-- // end page-intro -->

<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>

	<div class="dataContainer">
	<form 	method="POST"
		name="stats"
		action="stats.jsp"
		enctype="application/x-www-form-urlencoded">
	<% if (selectedGeneList.getDataset_id() != -99) { %>
		<div class="title">  Statistics Values  </div>
		<table name="items" id="items" class="list_base tablesorter" cellpadding="0" cellspacing="3">
			<thead>
			<tr class="col_title">
				<th> Accession ID </th>
				<th> GeneSymbol</th>
				<%
				// First print those headings that are not group means
                		for (int j=0; j<columnHeadings.length; j++) {
					if (indexHash.containsKey(columnHeadings[j])) {
						%><th style="width:10%;word-wrap:break-word;"><%=columnHeadings[j]%></th><%
					}
                		}                 
				// Then print the headings that are group means
                		for (int j=0; j<columnHeadings.length; j++) {
					if (!indexHash.containsKey(columnHeadings[j])) {
						%><th style="width:10%;word-wrap:break-word;"><%=columnHeadings[j]%></th><%
					}
                		}                 
				%>
				</tr>
			</thead>
			<tbody>
			<%

                	for (int i=0; i<myGeneArray.length; i++) {
				%>
                        	<tr>
				<td><%=myGeneArray[i].getGene_id()%></td>
				<%
				Identifier thisIdentifier = myIdentifier.getIdentifierFromSet(myGeneArray[i].getGene_id(), iDecoderSet); 
				if (thisIdentifier == null) {
					//log.debug("identifier not found");
					%> <td> &nbsp;</td><%
				} else {
					Set geneSymbols = 
						myIDecoderClient.getIdentifiersForTargetForOneID(thisIdentifier.getTargetHashMap(), 
						new String[] {"Gene Symbol"});
					if (geneSymbols.size() > 0) { 
						%> <td> <%
                				for (Iterator symbolItr = geneSymbols.iterator(); symbolItr.hasNext();) { 
                                        		Identifier symbol = (Identifier) symbolItr.next();
                					%>
                                        		<%=symbol.getIdentifier()%><BR/>
							<%
						}
						%> </td> 
					<% } else { 
						//log.debug("no gene symbols");	
						%>
                            			<td> &nbsp;</td>
					<% } 
				}
				if (myGeneArray[i].getStatisticsValues() != null && myGeneArray[i].getStatisticsValues().size() > 0) {
					// First print those values that are not group means
                                        for (int j=0; j<myGeneArray[i].getStatisticsValues().size(); j++) {
						if (indexHash.containsValue(j)) {
                                                        %> <td class="left" style="width:10%"> <%=myGeneArray[i].getStatisticsValues().get(j)%> </td> <%
                				}                 
					}
					// Then print those values that are group means
                                        for (int j=0; j<myGeneArray[i].getStatisticsValues().size(); j++) {
						if (!indexHash.containsValue(j)) {
                                                        %> <td class="left" style="width:10%"> <%=myGeneArray[i].getStatisticsValues().get(j)%> </td> <%
                				}                 
					}
				}
                       	%> </tr> <%
           		}
		%> 
		</tbody>
	</table> 
	<% } else {  %>
		<h2>This gene list was not derived from a microarray analysis, so no statistics are available. </h2>
	<% } %>
		<input type="hidden" name="action" value="">
		<input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>"/>
	</form>
	</div>
	<div class="brClear"> </div>
	<script type="text/javascript">
		$(document).ready(function() {
			setupPage();
		});
	</script>

<%@ include file="/web/common/footer.jsp" %>
