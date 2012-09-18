<%--
 *  Author: Cheryl Hornbaker
 *  Created: Dec, 2005
 *  Description:  The web page created by this file allows the user to 
 *		run quality control checks on the dataset he/she has created
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/analysisHeader.jsp"  %>

<jsp:useBean id="myErrorEmail" class="edu.ucdenver.ccp.PhenoGen.web.mail.Email"> </jsp:useBean>

<%

	log.info("in qualityControl.jsp. user =  "+ user);
	request.setAttribute( "selectedStep", "1" ); 
	optionsList.add("datasetDetails");

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Can't run quality control
                session.setAttribute("errorMsg", "GST-003");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }

	action = (String)request.getParameter("action");
	String includeImages = (String)request.getParameter("includeImages");
        log.debug("action = "+action + ", includeImages = "+includeImages);
	
	edu.ucdenver.ccp.PhenoGen.data.Array[] myArrays = selectedDataset.getArrays();

	int imageGenerationTime = 0;

	// 
	// this inserts a double back-slash in front of 
	// all parentheses in the dataset's master path
	//
	String datasetMasterPathStringNoParentheses =  
		selectedDataset.getPath().replaceAll("\\(", 
				"\\\\\\\\(").replaceAll("\\)", 
					"\\\\\\\\)");
	if (myArrays.length < 3) {
		//Error - "Too few arrays"
		session.setAttribute("errorMsg", "EXP-011");
		response.sendRedirect(commonDir + "errorMsg.jsp");
	} else {
		int totalImagesToGenerate = 0;

		for (int i=0; i< myArrays.length; i++) {
			int imagesToGenerate = 0;
        		//String fileName = datasetMasterPathStringNoParentheses +
                	//		myArrays[i].getFile_name().replaceAll("\\(", "\\\\\\\\(").replaceAll("\\)", "\\\\\\\\)");
			if (myArray.EXON_ARRAY_TYPES.contains(selectedDataset.getArray_type())) {
				String[] maplotFileNames = myArray.getAffyMaplotFileNames(myArrays[i].getHybrid_name());
				for (String fileName: maplotFileNames) {
					//log.debug("file_name = "+fileName);
					if (!(new File(selectedDataset.getImagesDir() + fileName).exists())) {
						imagesToGenerate++;
					}	 
				}
			} else if (selectedDataset.getPlatform().equals(myDataset.AFFYMETRIX_PLATFORM)) {
				String[] imageFileNames = myArray.getAffyQCFileNames(myArrays[i].getHybrid_name());
				for (String fileName: imageFileNames) {
					//log.debug("file_name = "+fileName);
					if (!(new File(selectedDataset.getImagesDir() + fileName).exists())) {
						imagesToGenerate++;
					}	 
				}
			} else if (selectedDataset.getPlatform().equals(selectedDataset.CODELINK_PLATFORM)) {
        			String fileName = selectedDataset.getImagesDir() + myArrays[i].getHybrid_name();
				if (!(new File(fileName + ".png")).exists()) {
					imagesToGenerate++;
				}
			} 
			//log.debug("imagesToGenerate = "+imagesToGenerate);
			//log.debug("totalImages = "+totalImagesToGenerate);
			totalImagesToGenerate = totalImagesToGenerate + imagesToGenerate;
		}
		//
		// It takes 1 minute per image CEL file
		//
		imageGenerationTime = totalImagesToGenerate * 1;
	}
	int totalTime = myArrays.length + imageGenerationTime;

	String msg = (selectedDataset.getDatasetVersions().length != 0 ? 
				"Since the arrays in this dataset have already been grouped and normalized, "+
				"you cannot re-run the full quality control checks. "+
				"You may only generate the pseudo-images of the arrays and the MA Plots."+ 
				"<BR><BR>" + 
				"It is estimated to take approximately "+ totalTime + " minutes to generate the images." : 
				"This dataset needs to be run through the quality control checks before going further.  "+
				"As part of the quality control checks, you may generate pseudo-images of the arrays as well as MA plots."+  
				"<BR><BR>" + 
				"It is estimated to take approximately " + myArrays.length +" minutes to run the checks without generating the images,"+ 
				" or "+ totalTime + " minutes to generate the images in addition to running the checks. "); 

        if ((action != null) && (action.equals("Run Quality Control Checks") || 
        			action.equals("Generate Images"))) {

        	Thread[] threadArray = new Thread[3]; 

		if (selectedDataset.getPlatform().equals("cDNA")) {
			//Error - "Attempting to run QC on cDNA dataset"
			session.setAttribute("errorMsg", "QC-001");
			response.sendRedirect(commonDir + "errorMsg.jsp");
		} else {
			// 
			// Perform the following steps:
                	// 1. Update qc_status
                	// 2. Create the fileListing file which contains the names of the
                	// 	array files to be normalized.
                	// 3. Run the PLATFORM.Import process and the PLATFORM.QC process
                	// 4. Update qc_status and send email
			//
                	/*************************** STEP 1 ****************************/
                	// 1. Update qc_status.

                	threadArray[0] = new Thread(new AsyncUpdateQcStatus(session, "1"));

                	log.debug("starting threadArray[0] to run AsyncUpdateQcStatus.  It is named "+threadArray[0].getName());
                	threadArray[0].start();
			// 
			//
                	/*************************** STEP 2 ****************************/
                	// 2. Create the fileListing file which contains the names of the
                	// array files to be normalized.
	
			if (selectedDataset.getDatasetVersions().length == 0) {
                		if (myArray.EXON_ARRAY_TYPES.contains(selectedDataset.getArray_type())) {
                        		selectedDataset.createFileListing(userFilesRoot, true);
				} else {
					selectedDataset.createFileListing(userFilesRoot, false);
				}

                                if (selectedDataset.waitForFilesToCopy(myArrays, userFilesRoot).equals("NOT OK")) {
                                        session.setAttribute("errorMsg", "QC-002");
                                        response.sendRedirect(commonDir + "errorMsg.jsp");
                                }
			}
                	//*************************** STEP 3 ****************************/
                	// 3. Run Affymetrix.QC.R (Affy), or CodeLink.QC (CodeLink) process

			String graphics = (includeImages != null && includeImages.equals("Y") ? "TRUE" : "FALSE");
			threadArray[1] = myStatistic.callQC(graphics, threadArray[0]);

                	threadArray[1].start();
	
                	//*************************** STEP 4 ****************************/
                	// 4. Update qc_status and send email

			String qc_complete = "R"; 

                	threadArray[2] = new Thread(new AsyncUpdateQcStatus(session, qc_complete, threadArray[1]));

                	log.debug("Calling AsyncUpdateQcStatus.  " +
                			", starting threadArray[2] named "+threadArray[2].getName() + 
					", waiting on thread " + threadArray[1].getName());

	                threadArray[2].start();

			mySessionHandler.createActivity("Ran Quality Control on dataset '" + selectedDataset.getName() + "'",
				dbConn);

			session.setAttribute("privateDatasetsForUser", null);
			//Success - "QC started"
			session.setAttribute("successMsg", "QC-003");
			response.sendRedirect(datasetsDir + "listDatasets.jsp");
		}
	}
	
	//
	//
	formName = "qualityControl.jsp";

%>

	<%@ include file="/web/common/microarrayHeader.jsp" %>


	<script type="text/javascript">
		var crumbs = ["Home", "Analyze Microarray Data", "Run Quality Control Checks"];
	</script>

	<form	method="post" 
		action="qualityControl.jsp" 
		enctype="application/x-www-form-urlencoded"
		name="qualityControl">
	

		<%@ include file="/web/datasets/include/viewingPane.jsp" %>
		<div class="brClear"></div>
		<%@ include file="/web/datasets/include/qcSteps.jsp" %>

		<div class="page-intro"> 
			<p><%=msg%></p>
		</div>
		<div class="brClear"></div>
		<center>
		<% if (selectedDataset.getDatasetVersions().length == 0) { %> 
			Would you like to generate the images?<%=twoSpaces%>
			<input type="radio" name="includeImages" value="Y"/> Yes 
			<%=tenSpaces%>
			<input type="radio" name="includeImages" value="N" checked/> No
		<% } else { %>
			<input type="hidden" name="includeImages" value="Y"/> 
		<% } %>
		<BR><BR><BR>
		<% if (selectedDataset.getDatasetVersions().length == 0) { %> 
			<input type="submit" name="action" value="Run Quality Control Checks" /> 
		<% } else { %>
			<input type="submit" name="action" value="Generate Images" /> 
		<% } %>
		<input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>" /> 
		</center>	
	</form>
<script type="text/javascript">
	$(document).ready(function(){
		setTimeout("setupMain()", 100); 
	});
</script>
<%@ include file="/web/common/footer.jsp" %>

