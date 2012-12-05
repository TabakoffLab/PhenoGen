<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  This creates a web page that links the user to the experiment definition 
 *	application. 
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/experiments/include/experimentHeader.jsp"  %>

<%
	log.debug("in downloadSpreadseeht experimentID = "+(String) fieldValues.get("experimentID") + " and selected = "+selectedExperiment.getExp_id());
	log.debug("action = "+action);
	request.setAttribute( "selectedStep", "2" ); 
        extrasList.add("downloadSpreadsheet.js");
	extrasList.add("messageBars.css");
	optionsList.add("experimentDetails");
	optionsList.add("chooseNewExperiment");
        fieldValues = myHTMLHandler.getFieldValues(request, fieldNames);
	
        if ((action != null) && action.equals("Download Empty Spreadsheet")) {
                String fileName = "ExperimentTemplate.xls";
                String templateFileName = myDataset.getPublicExperimentsPath(userFilesRoot) + fileName;

		String expName = selectedExperiment.getExpName();
                String downloadFileName = userLoggedIn.getUserExperimentDir() + expName + ".xls";

                log.debug("templateFileName = " + templateFileName); 
                log.debug("downloadFileName = " + downloadFileName);
                myFileHandler.copyFile(new File(templateFileName), new File(downloadFileName));
                request.setAttribute("fullFileName", downloadFileName);
                myFileHandler.downloadFile(request, response);

                // This is required to avoid the getOutputStream() has already been called for this response error
                out.clear();
                out = pageContext.pushBody();
                
		mySessionHandler.createExperimentActivity("Downloaded Empty Spreadsheet", dbConn);
		
		// Doesn't work!
		//response.sendRedirect(experimentsDir + "microarrayMain.jsp");
	} else if ((action != null) && action.equals("Upload Completed Spreadsheet")) {
		response.sendRedirect(experimentsDir + "uploadSpreadsheet.jsp");
	}

%>

	<%@ include file="/web/common/microarrayHeader.jsp" %>
    		

		<%@ include file="/web/experiments/include/viewingPane.jsp" %>
		<%@ include file="/web/experiments/include/uploadSteps.jsp" %>
		<div class="brClear"></div>

		<BR><BR>
		<div class="title">Hybridization Definition Spreadsheet</div>
			<form	method="post" 
				action="downloadSpreadsheet.jsp" 
				enctype="application/x-www-form-urlencoded"
				name="downloadSpreadsheet">
			<div id="downloadNow">
				<div class="page-intro">
					<p> Your experiment has been created.  You must now enter the details of your arrays into a spreadsheet.
					Once you have completed that, return to PhenoGen to upload your spreadsheet.</p>
					<BR><BR>

					Click this button to download the spreadsheet for your experiment.  <%=fiveSpaces%>
					<input id="download" type="submit" name="action" value="Download Empty Spreadsheet"/>
                    <BR><BR>
					<div class="information">
						&#8226;&nbsp;When opening in Excel 2000 - 2003
						<br/><%=fiveSpaces%>This workbook contains queries to external data that refresh automatically.
						<br/>
						<br/><%=fiveSpaces%>Queries are used to import external data into Excel, but harmful queries can be used to access 
						<br/><%=fiveSpaces%>confidential information or write information back to a database. <br/>
						<br/><%=fiveSpaces%>If you trust the source of this workbook, you can enable automatic query refresh. If you disable  
						<br/><%=fiveSpaces%>automatic query refresh, you can later refresh queries manually, if you are satisfied that the
						<br/><%=fiveSpaces%>queries are safe.
						<br/><br/><br/>
						
						&#8226;&nbsp;When Opening in Excel 2007
						<br/><%=fiveSpaces%>You will have to allow the incoming data connection. There are two ways to do this:<br/>
						<br/><%=fiveSpaces%>1.Upon the security warning when you open the file, you can click options. It will ask if you would 
						<br/><%=fiveSpaces%> like to allow this content. Select "enable this content" and click ok.
						<br/>
						<br/><%=fiveSpaces%>2.The second way is to click the data tab. In this tab, click connections. Once this is open, 
						<br/><%=fiveSpaces%>click refresh and then click ok.
					</div>
					
				</div> <!-- page-intro -->
			</div> <!-- downloadNow -->
			<div class="brClear"></div>
			<div id="uploadNow">
				<div class="page-intro">
					<p> An empty spreadsheet has been successfully downloaded.  <BR><BR>
				Once you have completed the spreadsheet, click 
				this button to upload it.<%=fiveSpaces%>
				<input type="submit" name="action" value="Upload Completed Spreadsheet"/>
				</div> <!-- page-intro -->
			</div>
			<div class="brClear"></div>
			<input type="hidden" name="experimentID" value="<%=selectedExperiment.getExp_id()%>" />
		</form>

	<%@ include file="/web/common/footer.jsp" %>

        <script type="text/javascript">
                $(document).ready(function() {
			setupPage();
                        setTimeout("setupMain()", 100);
                })
        </script>
