<%--
 *  Author: Cheryl Hornbaker
 *  Created: Nov, 2006
 *  Description:  This file formats the upstream sequence files.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %> 

<% 	
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");

	int itemID = Integer.parseInt((String) request.getParameter("itemID"));
	
	log.debug("in upstreamExtractionResults. itemID = " + itemID);

	GeneListAnalysis thisGeneListAnalysis = myGeneListAnalysis.getGeneListAnalysis(itemID, dbConn);
	int upstreamLength = Integer.parseInt(thisGeneListAnalysis.getThisParameter("Sequence Length"));
			
	GeneList thisGeneList = thisGeneListAnalysis.getAnalysisGeneList();
        String upstreamDir = thisGeneList.getUpstreamDir(thisGeneList.getGeneListAnalysisDir(userLoggedIn.getUserMainDir()));
        String upstreamFileName = thisGeneList.getUpstreamFileName(upstreamDir, upstreamLength, thisGeneListAnalysis.getCreate_date_for_filename());

	log.debug("upstreamDir = "+upstreamDir);
	log.debug("upstreamFileName = "+upstreamFileName);

	String[] upstreamResults = myFileHandler.getFileContents(new File(upstreamFileName), "withSpaces");

	if ((action != null) && action.equals("Download")) {
		String downloadPath = userLoggedIn.getUserGeneListsDownloadDir();  
		String downloadFileName = downloadPath +
                         		thisGeneList.getGene_list_name_no_spaces() + 	
					"_" + upstreamLength + ".fasta.txt";
		log.debug("downloadFileName = "+downloadFileName);
		myFileHandler.copyFile(new File(upstreamFileName), new File(downloadFileName));

		request.setAttribute("fullFileName", downloadFileName);
                myFileHandler.downloadFile(request, response);
		// This is required to avoid the getOutputStream() has already been called for this response error
		out.clear();
		out = pageContext.pushBody(); 

		mySessionHandler.createGeneListActivity("Downloaded Upstream Results", dbConn);
	} else {
		mySessionHandler.createGeneListActivity("Viewed Upstream Results", dbConn);
	}


%>
<%@ include file="/web/common/header.jsp" %>


	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>

	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>

	<div class="dataContainer" >
		<div id="related_links">
			<div class="action" title="Return to select a different upstream extraction">
				<a class="linkedImg return" href="promoter.jsp">
				<%=fiveSpaces%>
				Select Another Upstream Extraction
				</a>
			</div>
		</div>
		<div class="brClear"></div>

		<div class="title">Parameters Used:</div> 
                <div class="other_actions" id="download"><img src="<%=imagesDir%>/icons/download_g.png" /><br/>Download</div>
		<table class="list_base" cellpadding="0" cellspacing="3" width="50%">
			<tr class="col_title">
				<th class="noSort">Parameter</th>
				<th class="noSort">Value</th>
			</tr>
			<tr>
				<td> Sequence Length</td>
				<td> <%=upstreamLength%></td>
			</tr>
		</table>

		<BR>
		<div class="brClear"></div>
		<table class="fastaTable">
			<%
			for (int i=0; i<upstreamResults.length; i++) {
				%> <tr><td style="font-family:courier, sans-serif; font-size:14px"> <%=upstreamResults[i]%></td></tr> <%
			}
			%>
		</table>

        	<form   method="POST"
                	action="upstreamExtractionResults.jsp"
			name="upstreamExtractionResults"
                	enctype="application/x-www-form-urlencoded">

		<input type="hidden" name="action" value="">
		<input type="hidden" name="itemID" value="<%=itemID%>">
		</form>
	</div>

	<script type="text/javascript">
		/* * *
		 *  Sets up the "Download" link click
		/*/
		$(document).ready(function() {
			$("div#download").click(function(){
				$("input[name='action']").val("Download");
				$("form[name='upstreamExtractionResults']").submit();
			});
		});
	</script>
<%@ include file="/web/common/footer.jsp" %>
