<%--
 *  Author: Cheryl Hornbaker
 *  Created: April, 2005
 *  Description:  The web page created by this file displays the Literature search results.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %> 
<%@ include file="/web/common/dbutil_medline.jsp"  %> 

<jsp:useBean id="myLitSearch" class="edu.ucdenver.ccp.PhenoGen.data.LitSearch"> </jsp:useBean>

<%
	log.info("in litSearchResults.jsp. user = " + user);
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
        optionsList.add("download");
	int itemID = (request.getParameter("itemID") != null ? Integer.parseInt((String) request.getParameter("itemID")) : -99);
	log.debug("itemID = "+itemID);
	GeneListAnalysis thisLitSearch = myGeneListAnalysis.getGeneListAnalysis(itemID, dbConn); 
	java.sql.Timestamp pubMedTime = myObjectHandler.subtractOneDay(thisLitSearch.getCreate_date());
	java.util.Date pubMedDate = new java.util.Date(pubMedTime.getTime());
        SimpleDateFormat dateFormat = new SimpleDateFormat("MM/dd/yyyy");
	String pubMedDateString = dateFormat.format(pubMedDate);
	log.debug("thisLitSearch create_date = "+ thisLitSearch.getCreate_date());
	log.debug("thisLitSearch create_date -1 = "+ myObjectHandler.subtractOneDay(thisLitSearch.getCreate_date()));

	request.setAttribute( "selectedTabId", "literature" );

        String [] dataRow;

        Results myCategoriesAndKeywordsResults = myLitSearch.getCategoriesAndKeywords(itemID, dbConn);

	LinkedHashMap<String, String> myCategories = myLitSearch.getCategories(itemID, dbConn);
	int numCategories = myCategories.size();

        Results myPubMedCountsByCategory = myLitSearch.getPubMedCountsByCategory(itemID, dbConn);

	String previousKey = null;

        Results myCoReferenceResults = myLitSearch.getCoReferences(itemID, dbConn);

	mySessionHandler.createGeneListActivity("Viewed Literature Search Results for Search ID: " + itemID, dbConn);

	session.setAttribute("createDate", thisLitSearch.getCreate_date_as_string());


%>

<%@ include file="/web/common/header_adaptive_menu.jsp" %>


	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>
	<div class="page-intro">
		<p> Instructions:  Click on any of the available links to see the PubMed 
	results by gene, category, or gene/category combination.  
		</p>
	</div> <!-- // end page-intro -->

	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>

	<div class="dataContainer" style="padding-bottom: 70px;" >

	<div id="related_links">
		<div class="action" title="Return to select a different literature search">
			<a class="linkedImg return" href="litSearch.jsp">
			<%=fiveSpaces%>
			Select Another Literature Search
			</a>
		</div>
	</div>
	<div class="brClear"></div>

	<div class="title">Categories and Keywords Chosen</div>
	<table class="list_base" cellpadding="0" cellspacing="3" width="50%">
		<%
		previousKey = null;
		while ((dataRow = myCategoriesAndKeywordsResults.getNextRow()) != null) {
                	if (previousKey != null && dataRow[0].equals(previousKey)) {
                        	%>,&nbsp;<%=dataRow[1]%><%
                	} else {
				%></td></tr><tr class="col_title"> <%
				for (int i=0; i<dataRow.length; i++) {
					if (i==0) {
						%> <td><strong><%=dataRow[i]%></strong><%
					} else {
						%> <td><%=dataRow[i]%><%
					}
				}
			}
			previousKey = dataRow[0];
		}
		myCategoriesAndKeywordsResults.close();
%>
		</td></tr>
	</table>

	<div class="brClear"></div>
	<div class="title"> Results Summary<br>
	       <form   method="POST"
            name="litSearchResults"
            action="downloadAllAbstracts.jsp?itemID=<%=itemID%>&amp;corefID=<%=myCoReferenceResults.getStringValueFromFirstRow()%>&amp;litSearchName=<%= thisLitSearch.getDescription() %>&amp;geneListName=<%=selectedGeneList.getGene_list_name()%>&amp;createDate=<%=thisLitSearch.getCreate_date_as_string()%>"
            enctype="application/x-www-form-urlencoded">
		<font size="2">(PubMed search valid as of <%=pubMedDateString%>)</font>
	</div>
	<table class="list_base" name="items" cellpadding="0" cellspacing="3" width="100%">
		<thead>
		<tr class="col_title">
			<th class="noSort"> Genes
			<th class="noSort"> Alternate Identifiers Used in Search
			<th class="noSort" colspan=<%=numCategories+1%>> Number of PubMed Articles By Category
		</tr>
		</thead>
		<tbody>
		<tr> 
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<%
			Iterator catItr = myCategories.keySet().iterator();
			while (catItr.hasNext()) {
				String category = (String) catItr.next();
				if (!((String) myCategories.get(category)).equals("0")) {
					%><th class=center width=12%><a href="<%=geneListsDir%>abstracts.jsp?itemID=<%=itemID%>&amp;gene=&amp;category=<%=category%>&amp;litSearchName=<%= thisLitSearch.getDescription() %>&amp;createDate=<%=thisLitSearch.getCreate_date_as_string()%>" target="<%=category%> Window"><%=category%></a><%
				} else {
					%><th class=center width=12%><%=category%><%
				}
			}

		%><th class=center width=10%>Totals<%
		previousKey = null;
		int rowTotal = 0;
		boolean firstRow = true;
		while ((dataRow = myPubMedCountsByCategory.getNextRow()) != null) {
		       String createDate = thisLitSearch.getCreate_date_as_string();
                	if (previousKey != null && dataRow[0].equals(previousKey)) {
				//
				// print the total number for all subsequent categories
				//
				if (!dataRow[3].equals("0")) {
					%></td><td align=center><a href="<%=geneListsDir%>abstracts.jsp?litSearchName=<%= thisLitSearch.getDescription() %>&itemID=<%=itemID%>&amp;gene=<%=dataRow[0]%>&amp;category=<%=dataRow[2]%>&amp;createDate=<%=thisLitSearch.getCreate_date_as_string()%>" target="<%=dataRow[0]%>&nbsp;<%=dataRow[1]%> Window"><%=dataRow[3]%></a></td><%
				} else {
					%></td><td align=center><%=dataRow[3]%><%
				}
                	} else {
				// 
				// the very first Row should not print out the rowTotal
				// dataRow[1] contains the alternate identifiers that were used in the search
				//
				if (firstRow) {
					%><tr><td><a href="<%=geneListsDir%>abstracts.jsp?itemID=<%=itemID%>&amp;gene=<%=dataRow[0]%>&amp;category=&amp;&amp;litSearchName=<%= thisLitSearch.getDescription() %>&amp;createDate=<%=thisLitSearch.getCreate_date_as_string()%>" target="<%=dataRow[0]%> Window"><%=dataRow[0]%></a></td><%
					if (dataRow[1] != null && dataRow[1].length() > 20) {
						%>
                                        	<td> 
							<span class="trigger" name="more<%=dataRow[0]%>">More </span>
							<div id="more<%=dataRow[0]%>" style="display:none">
                                                		<%=dataRow[1]%>
							</div>
						</td>
					<%
					} else {
						%><td><%=dataRow[1]%></td><%
					}
					firstRow = false;
				} else {
					%><td align=center><%=rowTotal%></td></tr>
					<tr><td><a href="<%=geneListsDir%>abstracts.jsp?itemID=<%=itemID%>&amp;gene=<%=dataRow[0]%>&amp;category=&amp;litSearchName=<%= thisLitSearch.getDescription() %>&amp;createDate=<%=thisLitSearch.getCreate_date_as_string()%>" target="<%=dataRow[0]%> Window"><%=dataRow[0]%></a></td> <%
					if (dataRow[1] != null && dataRow[1].length() > 20) {
						%>
                                        	<td> 
							<span class="trigger" name="more<%=dataRow[0]%>">More </span>
							<div id="more<%=dataRow[0]%>" style="display:none">
                                                		<%=dataRow[1]%>
							</div>
						</td>
					<%
					} else {
						%><td><%=dataRow[1]%></td><%
					}
				}
				rowTotal = 0;
				//
				// dataRow[3] contains the number of pubmed documents for this gene, category combination
				//
				if (!dataRow[3].equals("0")) {
					%><td align=center><a href="<%=geneListsDir%>abstracts.jsp?itemID=<%=itemID%>&amp;gene=<%=dataRow[0]%>&amp;category=<%=dataRow[2]%>&amp;litSearchName=<%= thisLitSearch.getDescription() %>&amp;createDate=<%=thisLitSearch.getCreate_date_as_string()%>" target="<%=dataRow[0]%>&nbsp;<%=dataRow[2]%> Window"><%=dataRow[3]%></a></td><%
				} else {
					%> <td align=center><%=dataRow[3]%></td><%
				}
			}
			rowTotal = rowTotal + Integer.parseInt(dataRow[3]);
			previousKey = dataRow[0];
		}
		myPubMedCountsByCategory.close();
		if (rowTotal==0) {%>
		</td><tr>
			<td></td>
			<td></td>
			<% for (int i=0; i<=myCategories.size(); i++) {%>
			<td align=center><%=rowTotal%></td>
			
			<% } %>
			</tr></tr><%
		} else { %>
		</td><td align=center><%=rowTotal%></td></tr>
		<% } %>
		</tbody>
	</table>

<BR><BR>
<% if (myCoReferenceResults.getNumRows() > 0) { %>
	<div class="title"> Co-reference Report</div>
	<table class="list_base" name="items" cellpadding="0" cellspacing="3" width="90%">
		<tr class="col_title">
			<th class="noSort"> Co-referenced genes 
			<th class="noSort"> Number of PubMed Articles
		</tr>

		<%
		while ((dataRow = myCoReferenceResults.getNextRow()) != null) {
			%><tr><%
			for (int i=1; i<dataRow.length; i++) {
				if (i==1) {
					%><td><a href="<%=geneListsDir%>abstracts.jsp?corefID=<%=dataRow[0]%>&amp;litSearchName=<%= thisLitSearch.getDescription() %>&amp;createDate=<%=thisLitSearch.getCreate_date_as_string()%>" target="CoReference<%=dataRow[0]%> Window"><%=dataRow[1]%></a></td><%
				} else {
					%> <td><%=dataRow[i]%></td><%
				}
			}
			%></tr><%
		}
	myCoReferenceResults.close();
	%> </table> <BR><%
	}
%>
	</div>
	</form>
	<div class="brClear"></div>
	<script type="text/javascript">
		$(document).ready(function() {
			setupExpandCollapse();
                        setupDownloadLink('litSearchResults');
		});
	</script>

<%@ include file="/web/common/footer_adaptive.jsp" %>
