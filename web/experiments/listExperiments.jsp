<%--
 *  Author: Cheryl Hornbaker
 *  Created: Mar, 2010
 *  Description:  The web page created by this file displays all of the experiments
 *		available to the user 
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/experiments/include/experimentHeader.jsp"  %>
<%
	extrasList.add("listExperiments.js");
	
	optionsList.add("createExperiment");
	optionsList.add("analyze");
	session.setAttribute("selectedExperiment", null);

	//if (experimentsForUser == null) {
	//	log.debug("experimentsForUser not set");
	// Always reset experimentsForUser when on this page
		experimentsForUser = myExperiment.getAllExperimentsForUser(userLoggedIn.getUser_name(), dbConn);
		session.setAttribute("experimentsForUser", experimentsForUser);
	//}
        mySessionHandler.createSessionActivity(session.getId(), "Viewed all experiments", dbConn);

%>

<%pageTitle="Upload arrays";%>

<%@ include file="/web/common/microarrayHeader.jsp" %>

    <script type="text/javascript">
        var crumbs = ["Home", "Analyze Microarray Data", "Upload Data"]; 
    </script>

    <div class="page-intro">
	<p>Listed below are the microarray experiments that you have created in PhenoGen.&nbsp;Click on an experiment row to complete the next step in the definition process.  <BR>
Click<%=twoSpaces%><img src="<%=imagesDir%>icons/edit.png"><%=twoSpaces%>on a particular row to make changes to the experiment design type, factors, and/or protocols.  Doing so may change the type of information required, so the existing experiment will be deleted, and you will need to upload a new spreadsheet.</p>
    </div> <!-- // end page-intro -->

    <form name="tableList" action="chooseExperiment.jsp" method="get">
	<div class="brClear"> </div>
	<BR> 

		<div class="leftTitle">  My Uploaded Arrays (by Experiment)
                <span class="info" title="Expression data from biological experiments you conducted.">
                    <img src="<%=imagesDir%>icons/info.gif" alt="Help">
                </span>
		</div>
		<table name="items" id="privateExperiments" class="list_base tablesorter" cellpadding="0" cellspacing="3" width="95%">
		<thead>
		<tr class="col_title">
			</th>
			<th>Experiment Name</th>
			<th>Date Created</th>
			<th>Design Type<BR>& Factors<BR>Defined
                		<span class="info" title="Click to change experiment design type, factors, or protocols used in this experiment.">
                    		<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                		</span>
			<th>Samples Defined<BR>
                		<span class="info" title="The spreadsheet describing the samples has been uploaded for this experiment.">
                    		<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                		</span>
			</th>
			<th>Data Files Uploaded<BR>
                		<span class="info" title="The raw data files (.CEL or .txt) have been uploaded.">
                    		<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                		</span>
			</th>
			<th>Submission Completed<BR>
                		<span class="info" title="The experiment has been reviewed, and the submission has been completed.">
                    		<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                		</span>
			</th>
			<th class="noSort">Details
                		<span class="info" title="Click to view experiment details.">
                    		<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                		</span>
			</th>
			<th class="noSort">Delete
				<!--
                		<span class="info" title="Click to delete this experiment from PhenoGen.">
                    		<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                		</span> -->
			</th>
		</tr>
		</thead>
		<tbody>
<%
                if (experimentsForUser.length != 0) {
                	for (int i=0; i<experimentsForUser.length; i++) {
        			Experiment experiment = (Experiment) experimentsForUser[i];

                        	int thisExpID = experiment.getExp_id();
                        	String uploadSpreadsheet = (experiment.getNum_samples() > 0 ? checkMark :
						"<a href='"+experimentsDir + "chooseExperiment.jsp?experimentID=" + thisExpID + "&goTo=spreadsheet'>Run</a>");
                        	String hasFiles = (uploadSpreadsheet.equals(checkMark) && experiment.getNum_files() == experiment.getNum_arrays() ? checkMark :
						"<a href='"+experimentsDir + "chooseExperiment.jsp?experimentID=" + thisExpID + "&goTo=files'>Run</a>");
                        	String curated = (hasFiles.equals(checkMark) && experiment.getProc_status().equals("C") ? checkMark :
						"<a href='"+experimentsDir + "chooseExperiment.jsp?experimentID=" + thisExpID + "&goTo=curate'>Run</a>");
				%>
        			<tr id="<%=experiment.getExp_id()%>">
					<td><%=experiment.getExpName()%></td>
					<td><%=experiment.getExp_create_date_as_string()%></td>
					<% if (!curated.equals(checkMark)) { %>
						<td class="actionIcons">
							<a href="createExperiment.jsp?expID=<%=thisExpID%>"> <div class="linkedImg edit"> </div></a>
						</td>
					<% } else { %>
						<td>&nbsp;</td>
					<% } %>
					<td><%=uploadSpreadsheet%></td>
					<td><%=hasFiles%></td>
					<td><%=curated%></td>
    					<td class="details">View</td>
					<% if (!experiment.getCreated_by_login().equals("public")) { %>
						<td class="actionIcons">
							<div class="linkedImg delete"></div>
						</td>
					<% } %>
				</tr>
			<% } %>
		<% } else {%> 
			<tr id="-99"><td colspan="100%" align="center"><h2>No microarray experiments have been created.</h2></td></tr>
		<% } %>

		</tbody>
	</table>

	<input type="hidden" name="experimentID" value=""/>
	<input type="hidden" name="goTo" value="">
   </form>

  <div class="createNewExperiment"></div>
  <div class="itemDetails"></div>
  <div class="deleteItem"></div>
  <div class="editItem"></div>

  <script type="text/javascript">
    $(document).ready(function() {
        setupPage();
		setTimeout("setupMain()", 100); 
    });
  </script>

<%@ include file="/web/common/footer.jsp"%>
