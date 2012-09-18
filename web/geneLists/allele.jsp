<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  The web page created by this file displays the alleles
 *  		retrieved from the MGI database for a particular set of gene symbols PLUS
 *		the knockout information supplied by Koob PLUS the knockout information
 *		supplied by Blednov.
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"%>
<%@ include file="/web/geneLists/include/dbutil_jackson.jsp"  %>

<jsp:useBean id="myKnockOut" class="edu.ucdenver.ccp.PhenoGen.data.external.KnockOut"> </jsp:useBean>

<%
	log.info("in allele.jsp. user = " +user);
	Results myResults;
	String[] headerRow;
	String[] dataRow;

	String geneSymbol = request.getParameter("geneSymbol");
	String knockoutSource = request.getParameter("knockoutSource");

	log.debug("knockoutSource = " + knockoutSource);
	StringTokenizer tokens = new StringTokenizer(geneSymbol, "[, \t]");

	String[] geneSymbolArray = new String[tokens.countTokens()];
	int idx=0;
	while(tokens.hasMoreTokens()) {
		geneSymbolArray[idx] = tokens.nextToken(); 	
		idx++;
	}
	mySessionHandler.createGeneListActivity("Viewed knockout information", dbConn);

%>


<%@ include file="/web/common/externalWindowHeader.jsp" %>

	<% if (knockoutSource.equals("1")) { 
        	String mgiText = "<a href=\"http://www.informatics.jax.org/searches/allele.cgi?";

		myResults = myKnockOut.getPhenotypicAlleles(geneSymbolArray, jacksonConn);
		//
		// Can't check for number of rows with a Sybase db
		//
		//if (myResults.getNumRows() > 0 ) {
			%>
			<div class="title">Phenotypic Alleles of Genetically Modified Animals</div>
			<table class="list_base tablesorter" name="items" cellpadding="0" cellspacing="3" width="90%">
                		<thead>
                		<tr class="col_title">
					<th> Allele</th>
					<th> Allele Type</th>
					<th> Allele Name</th>
					<th> Allele Definition</th>
				</tr>
				</thead>
				<tbody>
					<% while ((dataRow = myResults.getNextRow()) != null) { %>
						<tr>
						<td><%=mgiText%><%=dataRow[4]%>" target="MGI Window"><%=dataRow[0]%></a></td>
						<td><%=dataRow[1]%></td>
						<td><%=dataRow[2]%></td>
						<td><%=dataRow[3]%></td>
						</tr>
					<% } %>
				</tbody>
			</table>
		<%
		myResults.close();
	} else if (knockoutSource.equals("2")) {
		myResults = myKnockOut.getIniaKnockOuts(geneSymbolArray, dbConn);
        	String crabbeText = "<a href=\"http://view.ncbi.nlm.nih.gov/pubmed/16961758\" target=\"Pubmed Window\">";
        	String pubmedText = "<a href=\"http://view.ncbi.nlm.nih.gov/pubmed/";
		if (myResults.getNumRows() > 0 ) {
			%>
			<div class="title">Alcohol Response Assays for Genetically Modified Animals <%=crabbeText%>(Crabbe et al. 2006)</a></div>
			<table class="list_base tablesorter" name="items" cellpadding="0" cellspacing="3" width="90%">
                		<thead>
                		<tr class="col_title">
					<th> Official Symbol</th>
					<th> Assay Description</th>
					<th> Pubmed ID Description</th>
				</tr>
				</thead>
				<tbody>
					<% while ((dataRow = myResults.getNextRow()) != null) { %>
						<tr>
						<td><%=dataRow[0]%></td>
						<td><%=dataRow[1]%></td>
						<td><%=pubmedText%><%=dataRow[2]%>" target="Pubmed Window"><%=dataRow[2]%></a></td>
						</tr>
					<% } %>
				</tbody>
			</table>
		<%
		}
		myResults.close();
	} else if (knockoutSource.equals("3")) {
		myResults = myKnockOut.getIniaAlcoholPreferences(geneSymbolArray, dbConn);
		if (myResults.getNumRows() > 0 ) {
		%>
			<div class="title">Alcohol Preference for Genetically Modified Animals (Univ of Texas data)</div>
			<table class="list_base tablesorter" name="items" cellpadding="0" cellspacing="3" width="90%">
                		<thead>
                		<tr class="col_title">
					<th> Official Symbol</th>
					<th> Animal</th>
					<th> Gender</th>
					<th> Wild Type or Mutant</th>
					<th class="right"> 3% ethanol</th>
					<th class="right"> 6% ethanol</th>
					<th class="right"> 9% ethanol</th>
					<th class="right"> 12% ethanol</th>
				</tr>
				</thead>
				<tbody>
					<% while ((dataRow = myResults.getNextRow()) != null) { %>
						<tr>
						<td><%=dataRow[0]%></td>
						<td><%=dataRow[1]%></td>
						<td><%=dataRow[2]%></td>
						<td><%=dataRow[3]%></td>
						<td class="right"><%=dataRow[4]%></td>
						<td class="right"><%=dataRow[5]%></td>
						<td class="right"><%=dataRow[6]%></td>
						<td class="right"><%=dataRow[7]%></td>
						</tr>
					<% } %>
				</tbody>
			</table>
		<%
		} 
		myResults.close();
	}
	%>
    
    <% if (jacksonConn != null) {
			jacksonConn.close();
		}
	%>
  <script type="text/javascript">
    $(document).ready(function() {
	//---> set default sort column
        $("table[name='items']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
    });
  </script>
<%@ include file="/web/common/externalWindowFooter.html" %>

