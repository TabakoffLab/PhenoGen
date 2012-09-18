<%--
 *  Author: Cheryl Hornbaker
 *  Created: Dec, 2005
 *  Description:  The web page created by this file displays the results of the quality control process
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/analysisHeader.jsp"  %>
<jsp:useBean id="myPdfUtil" class="edu.ucdenver.ccp.PhenoGen.util.PdfUtil"> </jsp:useBean>

<%

	log.info("in qualityControlResults.jsp. user =  "+ user);
	String tab = ((String) request.getParameter("tab") != null ? 
			(String) request.getParameter("tab") : "array"); 
	request.setAttribute( "selectedStep", "2" ); 
	extrasList.add("arrayTabs.js");
	extrasList.add("qualityControlResults.js");
	optionsList.add("datasetDetails");
	if (selectedDataset.getQc_complete().equals("R")) {
		optionsListModal.add("approveQC");
	}
	if ((!tab.equals("pseudo") && !tab.equals("maplot") && !tab.equals("array")) || 
		((tab.equals("pseudo") || tab.equals("maplot"))  && selectedDataset.hasGeneratedQCImage())) {
		optionsList.add("download");
	}

	edu.ucdenver.ccp.PhenoGen.data.Array[] myArrays = selectedDataset.getArrays();
	request.setAttribute( "selectedQCTabId", tab );
	
	String[] imageFileNames = null;
	if (tab.equals("winarray")) { 
		imageFileNames = new String[]{"Summary.Figure.png"}; 
	} else if (tab.equals("model")) { 
        	if (!myArray.EXON_ARRAY_TYPES.contains(selectedDataset.getArray_type())) {
                	imageFileNames = new String[] {"RLE.Figure.png", "NUSE.Figure.png"};
        	} else {
                	imageFileNames = new String[] {"RLE.Figure.png", "MAD.resid.Figure.png"};
        	}
	} else if (tab.equals("rle")) { 
		imageFileNames = new String[] {"CodeLink.BoxPlot.png"}; 
	} else if (tab.equals("cv")) { 
		imageFileNames = new String[]{"CodeLink.CV.png"}; 
	}
	mySessionHandler.createDatasetActivity("Viewed Quality Control Results ", dbConn);

	if (action != null && action.equals("Approve Quality Control Results")) {
		selectedDataset.updateQc_complete("Y", dbConn);
		mySessionHandler.createDatasetActivity("Approved Quality Control Results ", dbConn);
		
		session.setAttribute("privateDatasetsForUser", null);
		//Success - "QC Reviewed"
		session.setAttribute("successMsg", "QC-005");
		response.sendRedirect(datasetsDir + "listDatasets.jsp");
	} else if (action != null && action.equals("Download")) {
		log.debug("action is Download");
		log.debug("tab = " + tab);

		Document document = new Document();

		String filename = "";
		String imagePath = new FileHandler().getPathFromUserFiles(selectedDataset.getImagesDir());
		log.debug("imagePath = "+imagePath);
		PdfPTable clusterTable = null;
		List<Image> images = null;

		if (tab.equals("winarray")) { 
			filename = selectedDataset.getName() + " WithinArrayChecks";
		} else if (tab.equals("model")) { 
			filename = selectedDataset.getName() + " ModelBasedChecksImages";
		} else if (tab.equals("pseudo") ||  tab.equals("maplot")) { 
			List<String> hybridNames = new ArrayList<String>();
			for (edu.ucdenver.ccp.PhenoGen.data.Array thisArray : selectedDataset.getArrays()) {
				hybridNames.add(thisArray.getHybrid_name().replaceAll("[\\s]", "_"));
			}
			String[] strArray = myObjectHandler.getAsArray(hybridNames, String.class);

			if (tab.equals("pseudo")) { 
				filename = selectedDataset.getName() + " PseudoImages";
				clusterTable = myPdfUtil.getPseudoImages(selectedDataset, request,  strArray);
			} else if (tab.equals("maplot")) { 
				filename = selectedDataset.getName() + " MAPlots";
    				images = myPdfUtil.getMAPlotImages(selectedDataset, request, strArray);
			}
		} else if (tab.equals("rle")) { 
			filename = selectedDataset.getName() + " RelativeLogExpressions";
		} else if (tab.equals("cv")) { 
			filename = selectedDataset.getName() + " CoefficientOfVariation";
		}

		response.setContentType("application/pdf");
		response.setHeader("Content-Disposition", "attachment; filename=\""+filename+".pdf\"");

		PdfWriter.getInstance(document, response.getOutputStream());
		out.clear();
		out = pageContext.pushBody();
		document.open();
		if (imageFileNames != null) {
			for (String thisFileName : imageFileNames) {
				Image image1 = Image.getInstance(request.getScheme()+"://"+request.getServerName()+request.getContextPath()+imagePath+thisFileName);
                		image1.scaleToFit(450f, 450f);
                		document.add(image1);
			}
		}
		if (clusterTable != null) {
			document.add(clusterTable);
		}
		if (images != null) {
			for (Image image : images) {
				document.add(image);
			}
		}
		document.close();
	}


	//
	//
	String imageHeight = "900px";
	String imageWidth = "900px";
        formName = "qualityControlResults.jsp";


%>


	<%@ include file="/web/common/microarrayHeader.jsp" %>
	<script type="text/javascript">
		var crumbs = ["Home", "Analyze Microarray Data", "Quality Control Results"];
	</script>
	<%@ include file="/web/datasets/include/viewingPane.jsp" %>

	<div class="brClear"></div>
	<%@ include file="/web/datasets/include/qcSteps.jsp" %>
	<div class="page-intro">
		<p>The results of the quality control process are shown below.  
		<% if (selectedDataset.getQc_complete().equals("R")) { %>
			Once you have reviewed them, click the <span class="buttonRef">Approve Quality Control Results</span> icon.  
		<% } else { %>
			The results have already been reviewed and finalized.
		<% } %>
		</p>
	</div> <!-- // end page-intro -->

	<div class="brClear"></div>

	<%@ include file="/web/datasets/include/qcResultsTabs.jsp" %>

	<form	method="post" 
		action="qualityControlResults.jsp"
		enctype="application/x-www-form-urlencoded"
		name="qualityControlResults">
	<%
	String imagesPath = selectedDataset.getImagesDir();
	String relativePath = myFileHandler.getPathFromUserFiles(imagesPath);
	log.debug("relativePath = "+relativePath);

	if (tab.equals("array")) { %>
		<div class="tab-intro">
			<p> This page ensures that the attributes entered for each array are compatible.  </p>
			<p> Attributes where more than one value exists are shown in <font color="#E47833">orange</font>. </p>
		</div>
		<div class="brClear"></div>
		<%@ include file="/web/datasets/include/arrayCompatability.jsp" %>

	<% } else if (tab.equals("winarray")) { %>
		<div class="tab-intro">
			<p>
			This page displays information to help you determine the integrity of the arrays in your dataset. 
			<br/> </p>
		</div>
		<div class="brClear"></div>
		<div class="scrollable">
        	<% 
			if (selectedDataset.getCreator().equals("public")) {
				imageHeight = "6000px";
				imageWidth = "900px";
			}
		%>
        	<%@include file="/web/datasets/include/displayImages.jsp"%>
		</div>
	<% } else if (tab.equals("model")) { %>
		<div class="tab-intro">
			<p>
			This page displays information to help you determine the integrity of the arrays in your dataset.
			<br/>
			</p>
		</div>
		<div class="brClear"></div>
		<div class="scrollable">
        	<% 
			if (selectedDataset.getCreator().equals("public")) {
				imageHeight = "900px";
				imageWidth = "4000px";
			}
		%>
        	<%@include file="/web/datasets/include/displayImages.jsp"%>
		</div>
	<% } else if (tab.equals("pseudo")) { %>
		<div class="tab-intro">
			<p> This page displays the pseudo-images generated as part of the quality control process.  
			If you decided not to generate images, this page will be blank.</p>
		</div>
		<%
		if (selectedDataset.getPlatform().equals(myDataset.AFFYMETRIX_PLATFORM)) { 
			if (selectedDataset.getQc_complete().equals("Y") || 
				selectedDataset.getQc_complete().equals("I") ||
				selectedDataset.getQc_complete().equals("N") ||
				selectedDataset.getQc_complete().equals("R")) {
				if (selectedDataset.getName().equals(selectedDataset.BXDRI_INBRED_DATASET_NAME)) {
					%> <div style="margin:20px;"><h2>Unfortunately, there are too many images to display simultaneously for this dataset.  You may 
					view the images separately in the other two public datasets: <i>Public BXD RI Mice</i> and <i>Public Inbred Mice.</i> </h2></div><%
				} else { 

                                	if (selectedDataset.hasGeneratedQCImage()) { %>
						<div class="brClear"></div>
						<table name="items" rules="all" class="list_base">
						<tr>
						<% if (selectedDataset.getDatasetVersions().length == 0) { %>
							<th>Delete</th>
						<% } %>
						<th style="text-align:center">Image(s)</th>
						</tr>
						<% for (edu.ucdenver.ccp.PhenoGen.data.Array thisArray : selectedDataset.getArrays()) { %>
							<tr id="<%=thisArray.getHybrid_id()%>"> 
							<% if (selectedDataset.getDatasetVersions().length == 0) { %>
								<td class="actionIcons">
									<div class="linkedImg delete"></div>
								</td>
							<% } %>
							<td>
							<%
							imageHeight = "180px";
							imageWidth = "180px";
        						imageFileNames = myArray.getAffyImageFileNames(thisArray.getHybrid_name());
        						%> <%@include file="/web/datasets/include/displayImages.jsp"%> 
						<%
						}
						%>
						</td></tr>
					</table><%
					} else {
						log.debug("qc image does not exist: ");
					}
				}
			}
		} else if (selectedDataset.getPlatform().equals(selectedDataset.CODELINK_PLATFORM)) { 
			if (selectedDataset.getQc_complete().equals("Y") || 
				selectedDataset.getQc_complete().equals("I") ||
				selectedDataset.getQc_complete().equals("N") ||
				selectedDataset.getQc_complete().equals("R")) { 
                                 if (selectedDataset.hasGeneratedQCImage()) {  %>
							
					<table rules="all" class="list_base" name="items">
					<tr>
					<% if (selectedDataset.getDatasetVersions().length == 0) { %>
						<th>Delete</th>
					<% } %>
					

					<th style="text-align:center">Image(s)</th>
					</tr>
					<% for (edu.ucdenver.ccp.PhenoGen.data.Array thisArray : selectedDataset.getArrays()) { %>
						<tr id="<%=thisArray.getHybrid_id()%>"> 
						<% if (selectedDataset.getDatasetVersions().length == 0) { %>
							<td class="actionIcons">
								<div class="linkedImg delete"></div>
							</td>
						<% } %>
						<td>
						<%
						imageHeight = "400px";
						imageWidth = "400px";
						String array_name = thisArray.getHybrid_name().replaceAll("[\\s]", "_");
						log.debug("array_name = "+array_name);
        					imageFileNames = new String[]{array_name + ".png"};
        					%> <%@include file="/web/datasets/include/displayImages.jsp"%> 
						</td></tr>
					<% } %>
				</table><%
				} else {
					log.debug("dataset does not have qc images");
				}
			}
		} %>
		<BR>
	<% } else if (tab.equals("maplot")) { %>
		<div class="tab-intro">
			<p> This page displays the MA plots and the MA plot statistics generated as part of the quality control process.  </p>
		</div>
		<%@ include file="/web/datasets/include/formatStep3Results.jsp" %>
	<% } else if (tab.equals("rle")) { %>
		<div class="tab-intro"> <p> This page displays the relative log expressions. </p> </div>
		<div class="brClear"></div>
		<div class="scrollable">
        	<% 
			if (selectedDataset.getCreator().equals("public")) {
				imageHeight = "900px";
				imageWidth = "4000px";
			}
		%>
        	<%@include file="/web/datasets/include/displayImages.jsp"%>
		</div>
	<% } else if (tab.equals("cv")) { %>
		<div class="tab-intro">
			<p> This page displays the coefficient of variation.  </p>
		</div>
		<div class="brClear"></div>
		<div class="scrollable">
        	<% 
			if (selectedDataset.getCreator().equals("public")) {
				imageHeight = "900px";
				imageWidth = "4000px";
			}
		%>
        	<%@include file="/web/datasets/include/displayImages.jsp"%>
		</div>
	<% } else if (tab.equals("clsoft")) { %>
		<div class="tab-intro">
			<p>
			This page displays the quality control flags that show the integrity of each array.
			</p>
		</div>
		<%@ include file="/web/datasets/include/formatStep3Results.jsp" %>
	<% } %>

	<input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>">
	<input type="hidden" name="qc_complete" value="<%=selectedDataset.getQc_complete()%>">
	<input type="hidden" name="tab" value="<%=tab%>">
	<input type="hidden" name="action" value="">

	</form>
	<div class="arrayDetails"></div>
  	<div class="deleteItem"></div>
	<script type="text/javascript">
		$(document).ready(function() {
			setupPage();
		});
	</script>


<%@ include file="/web/common/footer.jsp" %>
