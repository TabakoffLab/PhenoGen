<%--
 *  Author: Cheryl Hornbaker
 *  Created: Apr, 2008
 *  Description:  The web page created by this file displays the gene list analysis results for 
 *					a selected gene list.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%

	if (type.equals("MEME")) { 
		header = "MEME Results";
		columnHeader = "MEME Description";
		msg = "No MEME analyses have been performed";
		title = "The MEME (Multiple EM for Motif Extraction) promoter search "+
			"is based on occurrences of known motifs (transcription factor binding sites).";
	} else if (type.equals("oPOSSUM")) { 
		header = "oPOSSUM Results";
		columnHeader = "oPOSSUM Description";
		msg = "No oPOSSUM analyses have been performed";
		title = "oPOSSUM is a tool for determining the over-representation "+
			"of transcription factor binding sites within a set of (co-expressed) genes as "+
			"compared with a pre-compiled background set.";
	} else if (type.equals("Upstream")) { 
		header = "Upstream Sequence Extraction Results";
		columnHeader = "Extraction Description";
		msg = "No upstream sequence extractions have been performed";
		title = "Extract the sequences upstream of your genes.";
	} else if (type.equals("litSearch")) { 
		header = "Literature Search Results";
		columnHeader = "Literature Search Name";
		msg = "No literature searches have been performed";
		title = "Search the literature for genes in your list along with other search keywords";
	} else if (type.equals("Pathway")) { 
		header = "Pathway Results";
		columnHeader = "Pathway Name";
		msg = "No pathway analyses have been performed";
		title = "Search KEGG for genes in your list that belong to pathways";
	}
	%>
	<div class="brClear"></div>
	<div class="list_container">
    	<form name="chooseAnalysis<%=type%>" action="<%=formName%>" method="get">
		<!--
		<div class="left inlineButton" name="<%=createNew%>"><%=button%>
        		<span class="info" title="<%=title%>">
                	<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                	</span>
		</div>
		-->
		<div class="leftTitle"> <%=header%></div>
      		<table class="list_base tablesorter" name="items" id="items<%=type%>" cellpadding="0" cellspacing="3" width="99%">
			<thead>
			<tr class="col_title">
				<th> <%=columnHeader%></th>
				<th> Run Date</th>
				<th class="noSort"> Delete</th> 
			</tr>
			</thead>
			<tbody>
			<% if (myAnalysisResults != null && myAnalysisResults.length != 0) { %>
				<%
				for (int i=0; i<myAnalysisResults.length; i++) {
					%>
					<tr id="<%=myAnalysisResults[i].getAnalysis_id()%>" 
						geneListID="<%=selectedGeneList.getGene_list_id()%>"
						type="<%=type%>">
						<td><%=myAnalysisResults[i].getDescription()%></td>
                        			<td><%=myAnalysisResults[i].getCreate_date_as_string()%></td>
						<td class="actionIcons">
							<div class="linkedImg delete"></div>
						</td>
					</tr> <%
				}
			} else {
                		%> <tr id="-99"><td colspan="3" style="text-align:center"><h2><%=msg%>&nbsp;on this gene list. </h2></td></tr><%
			} %>
			</tbody>
		</table>
	<input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>">
	<input type="hidden" name="organism" value="<%=selectedGeneList.getOrganism()%>">
	<input type="hidden" name="type" value="<%=type%>">
	<input type="hidden" name="itemID" value="">
	</form>
	</div>

