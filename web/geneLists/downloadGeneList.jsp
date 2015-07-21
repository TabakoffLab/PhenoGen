<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  The web page created by this file allows the user to download a genelist.	
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %>

<%
	int itemID = (request.getParameter("itemID") == null ? -99 : Integer.parseInt((String) request.getParameter("itemID")));
	String from = (request.getParameter("from") == null ? "" : (String) request.getParameter("from"));
	selectedGeneList = new GeneList().getGeneList(itemID, pool);
	selectedGeneList.setUserIsOwner(selectedGeneList.getCreated_by_user_id() == userID ? "Y" : "N"); 

	extrasList.add("listGeneList.js");

	log.info("in downloadGeneList.jsp. user = " + user + ", geneListID = "+selectedGeneList.getGene_list_id()+ 
			", geneListName = "+selectedGeneList.getGene_list_name());

	log.debug("action = " + action);

	String[] checkedList = new String[3];
	
	String probeValuesInitialFileName = "rawValues.txt"; 
	String probeValuesInitialFullFileName = selectedGeneList.getPath() + "rawValues.txt"; 
	String originalGeneListFileName = selectedGeneList.getGene_list_name_no_spaces() + "_GeneList.txt"; 
	String genesPlusValuesFileName = selectedGeneList.getGene_list_name_no_spaces() + "_GeneListPlusValues.txt";
	String genesPlusStatsFileName = selectedGeneList.getGene_list_name_no_spaces() + "_GeneListPlusStats.txt";  
	String probeValuesFileName = selectedGeneList.getGene_list_name_no_spaces() + "_" + probeValuesInitialFileName;

	String downloadPath = userLoggedIn.getUserGeneListsDownloadDir();  
	String originalGeneListFullFileName = downloadPath + originalGeneListFileName;
	String genesPlusValuesFullFileName = downloadPath + genesPlusValuesFileName;
	String probeValuesFullFileName = downloadPath + probeValuesFileName;
	String genesPlusStatsFullFileName = downloadPath + genesPlusStatsFileName;
	
        if ((action != null) && action.equals("Download")) {

		if (selectedGeneList.getNumber_of_genes() == 0) {
			//Error - "No genes"
                	session.setAttribute("errorMsg", "GL-004");
                	response.sendRedirect(commonDir + "errorMsg.jsp");
        	} else {
			if (request.getParameter("fileList") != null) {
				//
				// checkedList will contain the values of the check boxes that were
				// actually selected by the user
				//
		
				checkedList = request.getParameterValues("fileList");

				for (int i=0; i<checkedList.length; i++) {
					if (checkedList[i].equals(originalGeneListFullFileName)) {
						if (selectedGeneList.getNumber_of_genes() < 1000) {
							String originalGenes = selectedGeneList.getGenesAsString("\r\n", "Original", pool);
							myFileHandler.writeFile(originalGenes, originalGeneListFullFileName);
						} else {
							List originalGenes = selectedGeneList.getGenesAsListOfStrings("\r\n", "Original", pool);
							log.debug("originalGenes contains "+originalGenes.size() + " lists of 1000 genes");
							myFileHandler.writeFile(originalGenes, originalGeneListFullFileName);
							log.debug("after writing file");
						}
					}
					if (checkedList[i].equals(genesPlusValuesFullFileName)) {
						if (selectedGeneList.getNumber_of_genes() < 1000) {
							String genesPlusValues = selectedGeneList.getGenesPlusValuesAsString("\r\n", "Original", pool);
							myFileHandler.writeFile(genesPlusValues, genesPlusValuesFullFileName);
						} else {
							List genesPlusValues = selectedGeneList.getGenesPlusValuesAsListOfStrings("\r\n", "Original", pool);
							myFileHandler.writeFile(genesPlusValues, genesPlusValuesFullFileName);
						}
					}
					if (checkedList[i].equals(probeValuesFullFileName)) {
						if ((new File(probeValuesInitialFullFileName)).exists()) { 
							log.debug("probeValues file exists");
							myFileHandler.copyFile(new File(probeValuesInitialFullFileName), 
										new File(downloadPath + probeValuesFileName));
						} else {
							log.debug("probeValues file does not exist");
						}
					}
					if (checkedList[i].equals(genesPlusStatsFullFileName)) {
						if (selectedGeneList.getNumber_of_genes() < 1000) {
							String genesPlusStats = selectedGeneList.getGenesPlusStatsAsString("\r\n", "Original", pool);
							myFileHandler.writeFile(genesPlusStats, genesPlusStatsFullFileName);
						} else {
							List genesPlusStats = selectedGeneList.getGenesPlusStatsAsListOfStrings("\r\n", "Original", pool);
							myFileHandler.writeFile(genesPlusStats, genesPlusStatsFullFileName);
						}
					}
					
				}
				
				if (checkedList.length > 1) { //dont zip if downloading only 1 file
					String zipFileName = downloadPath +
						selectedGeneList.getGene_list_name_no_spaces() +    
						"_Download.zip";

					myFileHandler.createZipFile(checkedList, zipFileName);
					request.setAttribute("fullFileName", zipFileName);
				} else {
					request.setAttribute("fullFileName", checkedList[0]);
				}
				
				myFileHandler.downloadFile(request, response);
				// This is required to avoid the getOutputStream() has already been called for this response error
				out.clear();
				out = pageContext.pushBody(); 

				mySessionHandler.createGeneListActivity("Downloaded Gene List", pool);
        		}
		}
	}
%>

	<BR>
	<form	method="post" 
		action="downloadGeneList.jsp" 
		enctype="application/x-www-form-urlencoded" 
		name="downloadGeneList"> 
		<table name="items" class="list_base" cellpadding="0" cellspacing="3" width="90%">
			<tr class="title">
				<th colspan="100%">Files That Can Be Downloaded For Gene List '<%=selectedGeneList.getGene_list_name()%>':</th>
			</tr> 
			<tr class="col_title">
        			<th class="noSort"><input type="checkbox" id="checkBoxHeader" onClick="checkUncheckAll(this.id, 'fileList')"> </th>
				<th class="noSort">List Type</th>
				<th class="noSort">Filename</th>
			</tr>
			<% if (from.equals("")) { %>
				<tr>  
					<td> 
					<center>
						<input type="checkbox" name="fileList" value="<%=originalGeneListFullFileName%>">
					</center>
					</td>  

					<td> Gene List </td>
					<td><%=originalGeneListFileName%></td>
				</tr> 
			<% } %>
			<% 
				// 
				// If the source of the gene list is a particular dataset version,
				// display the option to download the other values and also to download the
				// expression values for the probesets in the gene list
				//
				if ((selectedGeneList.getGene_list_source()).indexOf("_v") > -1) { %> 
					<tr>  
						<td> 
						<center>
							<input type="checkbox" name="fileList" value="<%=genesPlusValuesFullFileName%>">
						</center>
						</td>  
						<td> Gene List plus Group Means and Statistics Values</td>
						<td><%=genesPlusValuesFileName%></td>
					</tr> 
                    <tr>  
						<td> 
						<center>
							<input type="checkbox" name="fileList" value="<%=genesPlusStatsFullFileName%>">
						</center>
						</td>  
						<td> Gene List plus Statistics Values</td>
						<td><%=genesPlusStatsFileName%></td>
					</tr>
					<% if (from.equals("")) { 
						if ((new File(probeValuesInitialFullFileName)).exists()) { %>
							<tr>
							<td> 
							<center>
								<input type="checkbox" name="fileList" value="<%=probeValuesFullFileName%>">
							</center>
							</td>  
							<td> Gene List plus Raw Values</td>
							<td><%=probeValuesFileName%></td>
						</tr> 
						<%
						}
					}
                    
				}%>
		</table>

		<BR>
		<center><input type="submit" name="action" value="Download" onClick="return IsSomethingCheckedOnForm(downloadGeneList)" /></center>
		<input type="hidden" name="itemID" value=<%=selectedGeneList.getGene_list_id()%> />
	</form>


<script>
	$(document).ready(function() {
		$("input[name='action']").click(
			function() {
				downloadModal.dialog("close");	
		});
	});
</script>
