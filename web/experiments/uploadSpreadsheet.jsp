<%--
 *  Author: Cheryl Hornbaker
 *  Created: Feb, 2010
 *  Description:  The web page created by this file allows the user to upload a spreadsheet 
 *		containing array information
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/experiments/include/experimentHeader.jsp"%>
<%
	log.info("in uploadSpreadsheet.jsp. user = " + user);
	request.setAttribute( "selectedStep", "3" ); 
	extrasList.add("uploadSpreadsheet.js");
	optionsList.add("experimentDetails");
	optionsList.add("chooseNewExperiment");

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-004");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }
        fieldNames.add("filename");

	mySessionHandler.createExperimentActivity("Uploading Spreadsheet", dbConn); 

%>
	<%@ include file="/web/common/microarrayHeader.jsp" %>



	<%@ include file="/web/experiments/include/viewingPane.jsp" %>
	<%@ include file="/web/experiments/include/uploadSteps.jsp" %>

	<div class="page-intro">
		<p> Upload the completed Excel spreadsheet file called <b><i>'<%=selectedExperiment.getExpName()%>.xls'</i></b> that you downloaded earlier.  
			It should contain all the information about your arrays.
		</p>
	</div>
	<div class="brClear"></div>
        <!--  
	most of the form processing is done in uploadSpreadsheet2.jsp
	because this is a multi-part form 
	--> 
	<form   name="uploadSpreadsheet" 
        	method="post" 
        	onSubmit="return IsUploadSpreadsheetFormComplete()" 
        	action="uploadSpreadsheet2.jsp" 
        	enctype="multipart/form-data">

		<div class="title">Upload Hybridization Spreadsheet</div>
		<table class="list_base" width="75%">
			<tr><td colspan="100%">&nbsp;</td></tr>
			<tr>
				<td>
                                	<strong>File Name:</strong><%=twoSpaces%>
				</td><td>
                                	<input type="file" name="filename" size="50">
				</td>
			</tr><tr><td colspan="100%">&nbsp;</td>
		</table>
		<BR><BR>
		<center>
			<input type="submit" name="action" value="Upload File">
		</center>
		<input type="hidden" name="experimentID" value="<%=selectedExperiment.getExp_id()%>">
	</form>
	<%@ include file="/web/common/footer.jsp" %>
	<script type="text/javascript">
		$(document).ready(function() {
                        setTimeout("setupMain()", 100);
		});
	</script> 
