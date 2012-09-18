<%--
 *  Author: Cheryl Hornbaker
 *  Created: October, 2005
 *  Description:  The web page created by this file displays pages of pubmed abstracts.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

	<%
	String pubMedText = "<a href=\"http://view.ncbi.nlm.nih.gov/pubmed/";
	String moreLinkText = "<a href=\"" + geneListsDir + "abstractsNext.jsp?pageNum=";

	Object previousClobKey = null;
	Object[] dataRowWithClob;
	//
	// This is included so we can use /web/common/prevNextLinks.jsp file
	//
	sortColumn="";
	int batchSize = 10;
	int numRows = myAbstracts.getNumRows();
	
	String itemIdStringForNextPage =  (String) session.getAttribute("itemID");
	itemID=Integer.parseInt(itemIdStringForNextPage);
	
	String litSearchName = (String) request.getParameter("litSearchName");
	String createDate = (String) request.getParameter("createDate");
	

        %><%@ include file="/web/common/setupPageNumbers.jsp" %><%

	
	if (numRows == 0) {
		%> <h2>No Abstracts Found </h2><% 
	} else {
		%>
		<div style="data_container">
		<div style="float:right;"><font size="2">Article titles and MeSH Headings from MEDLINE&reg;/PubMed&reg;, a database
		of the U.S. National Library of Medicine.</font></div><BR>
		<div class="externalWindow_download">
			<a style="text-decoration:none" href="<%=geneListsDir%>downloadAbstracts.jsp?geneListName=<%=selectedGeneList.getGene_list_name()%>&litSearchName=<%=litSearchName%>&createDate=<%=createDate%>">
			<img src="<%=imagesDir%>/icons/download_g.png" /><br/>Download</a>
		</div>
		
		<div class="brClear"></div>
		<h2>Abstracts <%=startRowNum%> - <%=endRowNum%> of <%=numRows%> 
		</h2>
		
		<%@ include file="/web/common/prevNextLinks.jsp" %>
			
				
		<div class="brClear"></div>
		
		<TABLE class=resultsWide>
		<%

		String [] alternateIDs = null;
		String [] keywords = null;
		while (rowNum <= batchSize && 
			(dataRowWithClob = myAbstracts.getNextRowWithClobInBatches(rowNum, batchSize, pageNum)) != null) {

			if (previousClobKey == null || 
				(previousClobKey != null && !dataRowWithClob[0].equals(previousClobKey))) {
	
				//
				// If this is not a co-reference link, then split the first value returned from the 
				// query into two values based on '|||'.  If it is a co-reference link, split the first
				// value returned into a set of values based on '+' as a delimiter.
				//	
				//
				// Split the first column returned into the gene id and the category
				//
				String [] keySplit = keySplit = ((String) dataRowWithClob[0]).split("[|]+");
				%><TR>
					<TD>
					<a name="<%=dataRowWithClob[0]%>"></a>
					<h2><%=keySplit[0]%> <%=keySplit[1]%></h2>
					</TD>
				</TR><%
				if (corefID == -99) {
					//
					// Get all the alternateIDs for this gene_id, so they can be highlighted in the abstract
					//
					alternateIDs = myLitSearch.getAlternateIdentifiersUsedInLitSearch(
								keySplit[0], itemID, dbConn);
					//log.debug("keySplit[0] = xxx" + keySplit[0] + "xxx" + ", itemID = " + itemID); 
					//log.debug("alternateIDs here 4= "); myDebugger.print(alternateIDs);
					
					keywords = myLitSearch.getKeywordsUsedInLitSearch(itemID, category, dbConn);
					//log.debug("keywords  = "); myDebugger.print(keywords);
				} else {
					//
					// Split the second column returned into separate gene ids 
					//
					keySplit = ((String) keySplit[1]).split("\\+");
					//log.debug("keySplit = "); myDebugger.print(keySplit);
					//
					// Get all the alternateIDs for these gene_ids, so they 
					// can be highlighted in the abstract
					//
					List alternateIDList = Arrays.asList(
							myLitSearch.getAlternateIdentifiersUsedInCoReference(
								keySplit[0], corefID, dbConn));
					List allAlternateIDsList = new ArrayList();
					allAlternateIDsList.addAll(alternateIDList);
					//log.debug("keySplit[0] = xxx" + keySplit[0] + "xxx" + ", corefID = " + corefID); 
					//log.debug("alternateIDList here = "); myDebugger.print(alternateIDList);
					for (int i=1; i<keySplit.length; i++) {
						//
						// add all alternateIDs for all genes into the alternateIDs array
						//
						List alternateIDList2 = Arrays.asList(myLitSearch.getAlternateIdentifiersUsedInCoReference(
										keySplit[i], corefID, dbConn));
						allAlternateIDsList.addAll(alternateIDList2);
					}
					alternateIDs = (String[]) allAlternateIDsList.toArray(new String[allAlternateIDsList.size()]);
					//log.debug("alternateIDs for coref genes = "); myDebugger.print(alternateIDs);
				}
			} 
			%><TR><%
			for (int i=2; i<dataRowWithClob.length; i++) {
				if (i==3) {
					String newClobAsString = new Results().getClobAsString((Object) dataRowWithClob[3]);
					if (!newClobAsString.equals("")) {
						newClobAsString = 
								myObjectHandler.getAsHighlightedString(newClobAsString, alternateIDs, keywords);
							%><%=newClobAsString%><BR><BR></TD><%
					} else {
       	                                         %>No Abstract<BR><BR></TD><%
					}
				} else {
					//log.debug("alternateIDs here = "); myDebugger.print(alternateIDs);
					String newTitle = 
						myObjectHandler.getAsHighlightedString((String) dataRowWithClob[2], alternateIDs, keywords);
					%><TD><%=pubMedText%><%=dataRowWithClob[1]%>" target="NCBI Window"><%=newTitle%></a><%=twoSpaces%><%
				}
			}
			previousClobKey = dataRowWithClob[0];
			%></TR><%
			rowNum++;
		}
	}
%>

</TABLE>
		</div> <!-- data_container -->

	<%@ include file="/web/common/prevNextLinks.jsp" %>

