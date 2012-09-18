<%--
 *  Author: Cheryl Hornbaker
 *  Created: Mar, 2010
 *  Description:  The web page created by this file allows the user to upload the raw data files
 *		for an experiment
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/experiments/include/experimentHeader.jsp"%>
<%
	log.info("in uploadCELFiles.jsp. user = " + user);
	extrasList.add("uploadCELFiles.js");
	optionsList.add("experimentDetails");
	optionsList.add("chooseNewExperiment");
	request.setAttribute( "selectedStep", "4" ); 

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-004");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }
	edu.ucdenver.ccp.PhenoGen.data.Array[] myArrays = null;
        myArrays = myArray.getArraysForSubmission(selectedExperiment.getSubid(), dbConn);

	myArrays = myArray.sortArrays(myArrays, "hybrid_id");
	log.debug("there are "+myArrays.length + " arrays for this exp");

	for (int i=0; i<myArrays.length; i++) {
        	fieldNames.add(myArrays[i].getHybrid_name() +"_filename");
	}

	log.debug("action = "+action);

	mySessionHandler.createExperimentActivity("Uploading CEL Files", dbConn); 
	if (action != null && action.equals("Next >")) {
		log.debug("going to editHybrid");
                response.sendRedirect(experimentsDir + 
				"editHybridization.jsp?experimentID=" + 
				selectedExperiment.getExp_id());
	}

%>
	<%@ include file="/web/common/microarrayHeader.jsp" %>

    	<script type="text/javascript">
        	var crumbs = ["Home", "Analyze Microarray Data", "Upload Data"]; 
    	</script>

	<%@ include file="/web/experiments/include/viewingPane.jsp" %>
	<%@ include file="/web/experiments/include/uploadSteps.jsp" %>
        <!--  
	most of the form processing is done in uploadCELFiles2.jsp
	because this is a multi-part form 
	--> 

	<div class="page-intro">
		<p> Specify the file to upload for each array.  To ensure success, upload a maximum of 10 files at a time.</p>
	</div>
	<div class="brClear"></div>
	<form   name="uploadCELFiles" 
        	method="post"        	
        	action="uploadCELFiles2.jsp" 
        	enctype="multipart/form-data">

		<div class="title">Upload Array Files </div>
		<table class="list_base tablesorter" id="celFiles" width="95%">
			<thead>
			<tr class="col_title">
				<th>Hybridization Name</th>
				<th>Uploaded File </th>
				<th>Choose File</th>
			</tr>
			</thead>
			<tbody>
			<%
			boolean allFilesUploaded = true;
			for (int i=0; i<myArrays.length; i++) {
				%><tr><td><%=myArrays[i].getHybrid_name()%></td>
				<% if (myArrays[i].getFile_name() != null && !myArrays[i].getFile_name().equals("")) { %>
					<td><%=myArrays[i].getFile_name()%></td>
				<% } else { 
					allFilesUploaded = false;
				%>
					<td>&nbsp;</td>
				<% } %> 
				<td>
				<% if (myArrays[i].getFile_name() != null && !myArrays[i].getFile_name().equals("")) { %>
					Change Data File:<%=twoSpaces%>
				<% } else { %>
					Choose Data File To Upload:<%=twoSpaces%>
				<% } %> 
				<input type="file" name="<%=myArrays[i].getHybrid_id()%>_file" size="50"></td>
				</tr>
				<%
			}
			%>
			</tbody>
		</table>
		<BR><BR>
		<center>
		<input type="submit" name="action" value="Upload File(s)">
		<input type="hidden" name="experimentID" value="<%=selectedExperiment.getExp_id()%>">
		</center>

		<% if (allFilesUploaded) { %>
			<div class="brClear" style="padding-top:20px"></div>
				<div class="right">
        				<span class="info" title="Go to review experiment">
                        			<%@ include file="/web/common/nextButton.jsp" %>
					</span>
				</div>
			<div style="padding:20px"></div>
		<% } %>
	</form>

	<div style="margin:20px" class="itemDetails"></div>
	<%@ include file="/web/common/footer.jsp" %>
	<script type="text/javascript">
		$(document).ready(function() {
                        setTimeout("setupMain()", 100);
                        checkUploadLimit();
        		//set default sort column -- this was changed to sort by thbyrid_sysuid instead
        		//$("table[id='celFiles']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
		});
	</script> 
