<%--
 *  Author: Cheryl Hornbaker
 *  Created: Oct, 2009
 *  Description:  The web page created by this file allows the user to download the QTL analysis results
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/qtls/include/qtlHeader.jsp"  %>

<%

	log.info("in downloadQTLResults.jsp. user =  "+ user);

        phenotypeParameterGroupID = (request.getParameter("itemID") == null ? -99 : Integer.parseInt((String) request.getParameter("itemID")));

	log.debug("phenotypeParameterGroupID = "+phenotypeParameterGroupID);
	String phenotypeName = (phenotypeParameterGroupID != -99 ? 
			myParameterValue.getPhenotypeName(phenotypeParameterGroupID, dbConn) :
			"");	
	log.debug("phenotypeName = "+phenotypeName);

        String groupingUserPhenotypeDir = selectedDatasetVersion.getGroupingUserPhenotypeDir(userName, phenotypeName);
	phenotypeName = myObjectHandler.removeBadCharacters(phenotypeName);
	log.debug("now phenotypeName = "+phenotypeName);
	String analysisOutputTxtFileName = groupingUserPhenotypeDir + "QTLAnalysisOutput.txt"; 
	File analysisOutput = new File(analysisOutputTxtFileName); 

	String analysisGraphFileName = groupingUserPhenotypeDir + "QTLAnalysisGraphic.png"; 
	File analysisGraph = new File(analysisGraphFileName);

        //extrasList.add("displayQTLResults.js");

        String[] checkedList = new String[3];

        String downloadPath = userLoggedIn.getUserMainDir();
	log.debug("downloadPath = "+downloadPath);

        if ((action != null) && action.equals("Download")) {

		mySessionHandler.createDatasetActivity("Downloaded QTL Analysis Results", dbConn);

		if (request.getParameter("fileList") != null) {
                	//
                	// checkedList will contain the values of the check boxes that were
                	// actually selected by the user
                	//

                	checkedList = request.getParameterValues("fileList");

			String zipFileName = downloadPath +
                        		phenotypeName +
                                       	"_QTLAnalysis_Download.zip";

                        for (int i=0; i<checkedList.length; i++) {
				File oldFile = new File(checkedList[i]);
				log.debug("oldFile = "+oldFile);
				//copy all the files to a new name so that files 
				//will have the phenotype name in them
				File newFile = myFileHandler.copyFile(oldFile,
                                		new File(oldFile.getParent() + "/" +
                                                		phenotypeName + "_" +
                                                                oldFile.getName()));
				log.debug("newFile = "+newFile);
				checkedList[i] = newFile.getPath();
                        }

			myFileHandler.createZipFile(checkedList, zipFileName);
			request.setAttribute("fullFileName", zipFileName);
                	myFileHandler.downloadFile(request, response);
                	// This is required to avoid the getOutputStream() has already been called for this response error
                	out.clear();
                	out = pageContext.pushBody();
		}
        }

%>


        <form   method="post" 
                action="downloadQTLAnalysisResults.jsp" 
                enctype="application/x-www-form-urlencoded" 
                name="downloadQTLAnalysisResults">

		<BR>
                <table name="items" class="list_base" cellpadding="0" cellspacing="3" >
                        <tr class="title">
                                <th colspan="100%"> QTL Analysis Result Files:</th>
                        </tr>
                        <tr class="col_title">
                                <th class="noSort"><input type="checkbox" id="checkBoxHeader" onClick="checkUncheckAll(this.id, 'fileList')"> </th>
                                <th class="noSort">Available Files:</th>
                        </tr>
                        <tr>
                                <td>
                                <center>
                                        <input type="checkbox" name="fileList" value="<%=analysisOutputTxtFileName%>">
                                </center>
                                </td>

                                <td> Text File</td>
                        </tr>
			<tr>
                        	<td>
                                <center>
                                	<input type="checkbox" name="fileList" value="<%=analysisGraphFileName%>">
				</center>
                                </td>
                                <td> LOD Plot Image </td>
			</tr>
                </table>

		<BR>
		<center><input type="submit" name="action" value="Download" onClick="return IsSomethingCheckedOnForm(downloadQTLAnalysisResults)" /></center>

                <input type="hidden" name="phenotypeParameterGroupID" value="<%=phenotypeParameterGroupID%>" />
                <input type="hidden" name="itemID" value="<%=phenotypeParameterGroupID%>" />
	</form>


	<script>
        $(document).ready(function() {
                $("input[name='action']").click(function() {
			downloadModal.dialog("close");
                });
        });
	</script>

