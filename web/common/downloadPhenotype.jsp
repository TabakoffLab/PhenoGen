<%--
 *  Author: Cheryl Hornbaker
 *  Created: Dec, 2009
 *  Description:  The web page created by this file allows the user to 
 *		download phenotype values
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>

<%
	log.info("in downloadPhenotype.jsp. user =  "+ user);
	log.info("dataset = "+selectedDataset.getName() + ", version = "+selectedDatasetVersion.getVersion()); 
	log.info("parameterGroupID = "+itemID);

	String phenotypeName = myParameterValue.getPhenotypeName(itemID, dbConn);
	// need to find the dataset version from the itemID, which is the parameterGroupID
	ParameterValue[] parameterValues = myParameterValue.getParameterValues(itemID, dbConn);
	selectedDatasetVersion = selectedDataset.getDatasetVersion(parameterValues[0].getVersion()); 
	log.info("here dataset = "+selectedDataset.getName() + ", version = "+selectedDatasetVersion.getVersion()); 
	log.debug("phenotypeName = "+phenotypeName);
	
        if ((action != null) && action.equals("Download")) {

		String downloadFileName = selectedDatasetVersion.getPhenotypeDownloadFileName(userLoggedIn.getUser_name(), phenotypeName);
		String path = new File(selectedDatasetVersion.getPhenotypeDownloadFileName(userLoggedIn.getUser_name(), phenotypeName)).getParent() + "/";
		String fileName = new File(selectedDatasetVersion.getPhenotypeDownloadFileName(userLoggedIn.getUser_name(), phenotypeName)).getName();
		log.debug("downloadFileName = " + downloadFileName); 
		log.debug("path = " + path); 
		log.debug("fileName = " + fileName); 
		String fullFileName = path + myObjectHandler.removeBadCharacters(phenotypeName) + "_" + fileName;
                myFileHandler.copyFile(new File(downloadFileName), new File(fullFileName));
		request.setAttribute("fullFileName", fullFileName);
		myFileHandler.downloadFile(request, response);
		// This is required to avoid the getOutputStream() has already been called for this response error
		out.clear();
		out = pageContext.pushBody(); 
		
		mySessionHandler.createDatasetActivity("Downloaded Phenotype called "+phenotypeName, dbConn);
        }

%>
	<form	method="post" 
		action="<%=commonDir%>downloadPhenotype.jsp" 
		enctype="application/x-www-form-urlencoded"
		name="downloadPhenotype">
		<BR>

		<div class="center">
		<h2>Click button to download the values for '<%=phenotypeName%>'</h2><BR>
			<input type="submit" name="action" value="Download"/>
		</div>
	
		<input type="hidden" name="itemID" value=<%=itemID%> />
	</form>

<script type="text/javascript">
	$(document).ready(function() {
		$("input[name='action']").click(
			function() {
				downloadModal.dialog("close");	
		});
	});
</script>
