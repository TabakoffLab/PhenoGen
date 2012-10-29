<%@ include file="/web/geneLists/include/geneListHeader.jsp"%>

<%
	request.setAttribute( "selectedTabId", "list" );
	extrasList.add("geneList.js");
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
	optionsListModal.add("download");
	GeneList.Gene[] myGeneArray = selectedGeneList.getGenesAsGeneArray(dbConn);
	session.setAttribute("geneListOrganism",selectedGeneList.getOrganism());
	log.debug("geneListOrganism="+selectedGeneList.getOrganism());
	//log.debug("iDecoderSet = "); myDebugger.print(iDecoderSet);
       	if ((action != null) && action.equals("Download")) {
		log.debug("action is Download");
		mySessionHandler.createGeneListActivity("Downloaded Gene List", dbConn);
		String output = "";
		for (int i=0; i<myGeneArray.length; i++) {
			Identifier thisIdentifier = myIdentifier.getIdentifierFromSet(myGeneArray[i].getGene_id(), iDecoderSet); 			
			if (thisIdentifier != null) {
				myIDecoderClient.setNum_iterations(1);
				Set geneSymbols = myIDecoderClient.getIdentifiersForTargetForOneID(thisIdentifier.getTargetHashMap(), 
										new String[] {"Gene Symbol"});
				if (geneSymbols.size() > 0) { 						
                			for (Iterator symbolItr = geneSymbols.iterator(); symbolItr.hasNext();) { 
						Identifier symbol = (Identifier) symbolItr.next();                					
						output = output + myGeneArray[i].getGene_id() + "," + symbol.getIdentifier() + "\r\n";
					}
				} else {
					output = output + myGeneArray[i].getGene_id() + "\r\n";
				} 
			}                       
		}
		String fileName = userLoggedIn.getUserGeneListsDir() + "downloads/" + selectedGeneList.getGene_list_name() + "Gene_List_Contents.csv";
		myFileHandler.writeFile(output, fileName);
		request.setAttribute("fullFileName", fileName);
		myFileHandler.downloadFile(request, response);
		// This is required to avoid the getOutputStream() has already been called for this response error
		out.clear();
		out = pageContext.pushBody(); 
//		response.sendRedirect(geneListsDir + "downloadGeneListInCSV.jsp?geneName=" + selectedGeneList.getGene_list_name());
	}
        mySessionHandler.createGeneListActivity("Viewed geneList contents", dbConn);
%>

<%@ include file="/web/common/header.jsp" %>

<script type="text/javascript">
    var crumbs = ["Home", "Research Genes", "List"];
</script>

<%@ include file="/web/geneLists/include/viewingPane.jsp" %>
        <div class="page-intro">
                <p> This page contains the identifiers and their symbols for the genes in your list.
                </p>
        </div> <!-- // end page-intro -->

<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>
	<form 	method="POST"
		name="geneList"
		action="geneList.jsp"
		enctype="application/x-www-form-urlencoded">
	<div class="dataContainer">
		<div class="title">  Gene List Contents </div>

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
                	for (int i=0; i<myGeneArray.length; i++) {
				%>
                        	<tr><td><%=myGeneArray[i].getGene_id()%></td><%
				Identifier thisIdentifier = myIdentifier.getIdentifierFromSet(myGeneArray[i].getGene_id(), iDecoderSet); 
				if (thisIdentifier != null) {
					Set geneSymbols = myIDecoderClient.getIdentifiersForTargetForOneID(thisIdentifier.getTargetHashMap(), 
										new String[] {"Gene Symbol"});
					if (geneSymbols != null && geneSymbols.size() > 0) { 
						%><td><%
                				for (Iterator symbolItr = geneSymbols.iterator(); symbolItr.hasNext();) { 
                                    Identifier symbol = (Identifier) symbolItr.next();
                					%><a href="<%=request.getContextPath()%>/gene.jsp?geneTxt=<%=symbol.getIdentifier()%>&speciesCB=<%=selectedGeneList.getOrganism()%>&auto=Y&newWindow=Y"><%=symbol.getIdentifier()%></a><BR><%
						}
						%></td><% 
					} else { 
						//log.debug("no gene symbols");	
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
		<input type="hidden" name="action" value="">
		<input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>"/>
	</form>
	</div>
	<div class="brClear"> </div>

	<script type="text/javascript">
		$(document).ready(function() {
			setupPage();
			setTimeout("setupMain()", 100); 
		});
	</script>

<%@ include file="/web/common/footer.jsp" %>
