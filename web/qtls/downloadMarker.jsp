<%--
 *  Author: Cheryl Hornbaker
 *  Created: Mar, 2009
 *  Description:  The web page created by this file allows the user to 
 *		download files containing the marker data used for calculating eQTLs
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/qtls/include/qtlHeader.jsp"  %>

<%
	log.info("in downloadMarker.jsp. user =  "+ user);
	
	log.debug("action = "+action);
	mySessionHandler.createDatasetActivity("Looked at download marker page", dbConn);

	String BXDRIResourcesDir = myDataset.getResourcesDir(publicDatasets, myDataset.BXDRI_DATASET_NAME);
	String HXBRIResourcesDir = myDataset.getResourcesDir(publicDatasets, myDataset.HXBRI_DATASET_NAME);
	String LXSRIResourcesDir = myDataset.getResourcesDir(publicDatasets, myDataset.LXSRI_DATASET_NAME);
	
        if ((action != null) && action.equals("Download")) {
		String[] checkedList = (request.getParameterValues("fileList") != null ?
				(String[]) request.getParameterValues("fileList") : null); 

		String zipFileName = userLoggedIn.getUserMainDir() +  
				"MarkerData.zip";

		if (checkedList != null && checkedList.length > 0) {
			myFileHandler.createZipFile(checkedList, zipFileName); 
			request.setAttribute("fullFileName", zipFileName);
			myFileHandler.downloadFile(request, response);
			// This is required to avoid the getOutputStream() has already been called for this response error
			out.clear();
			out = pageContext.pushBody(); 
                }
		
		mySessionHandler.createDatasetActivity("Downloaded Marker Data", dbConn);
        }

%>

<%pageTitle="Download QTL Markers";%>

<%@ include file="/web/common/header.jsp"  %>
	<form	method="post" 
		action="downloadMarker.jsp" 
		enctype="application/x-www-form-urlencoded"
		name="downloadMarker">
		<BR>
		<div class="brClear"></div>

		<div class="title"> Data Files Used for Calculating eQTLs</div>
		      <table name="items" class="list_base" cellpadding="0" cellspacing="3" id="marker" name="marker">
            <thead>
                               <tr class="col_title">
        				<td class="noSort"><input type="checkbox" id="checkBoxHeader" onClick="checkUncheckAll(this.id, 'fileList')"> </td>
					<th class="noSort">File Name</th>
				</tr>
			</thead>
			<tbody>
			<tr>  
				<td> <input type="checkbox" name="fileList" value="<%=BXDRIResourcesDir%>BXD_Markers.zip" /> </td>  
				<td> Marker data used in calculating eQTLs for BXD Mice</td> 
			</tr> 
			<tr>  
				<td> <input type="checkbox" name="fileList" value="<%=HXBRIResourcesDir%>HXB_BXH_Markers.txt.zip" /> </td>  
				<td> Marker data used in calculating eQTLs for HXB/BXH Rats</td> 
			</tr>
            <tr>  
				<td> <input type="checkbox" name="fileList" value="<%=LXSRIResourcesDir%>LXS.markers.mm10.txt.zip" /> </td>  
				<td> Marker data used in calculating eQTLs for ILS/ISS Mice</td> 
			</tr> 
			</tbody>
		</table> 
		<BR>
		<div class="center">
			<input type="submit" name="action" value="Download" onClick="return IsSomethingCheckedOnForm(downloadMarker)" />
		</div>
	</form>

<%@ include file="/web/common/footer.jsp"  %>
<script type="text/javascript">
	$(document).ready(function() {
        	setTimeout("setupMain()", 100);
	});
</script>

