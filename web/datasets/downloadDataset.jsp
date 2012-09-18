<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  The web page created by this file allows the user to 
 *      download files associated with the dataset. 
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>

<%
    %> <%@ include file="/web/datasets/include/splitDatasetIDAndVersion.jsp"  %> <%
    
    log.info("in downloadDataset.jsp. user =  "+ user);
    
    int numArrays = 0;
    ArrayList checkedList = new ArrayList();
    
    edu.ucdenver.ccp.PhenoGen.data.Array[] myArrays = selectedDataset.getArrays();

    numArrays = myArrays.length;
    log.debug("numArrays = "+numArrays);

        if ((action != null) && action.equals("Download")) {
        	//
        	// checkedList will contain the values of the check boxes that were
        	// actually selected by the user
        	//
        	if (request.getParameterValues("normalizedFileList") != null) {
            		checkedList.addAll(Arrays.asList(request.getParameterValues("normalizedFileList")));
        	}
        	if (request.getParameterValues("phenotypeFileList") != null) {
			String[] phenotypeList = (String[]) request.getParameterValues("phenotypeFileList");
			phenotypeList = myParameterValue.new Phenotype().renamePhenotypeFiles(phenotypeList);
            		checkedList.addAll(Arrays.asList(phenotypeList));
        	}
        	if (request.getParameterValues("dataFileList") != null) {
            		checkedList.addAll(Arrays.asList(request.getParameterValues("dataFileList")));
        	}
		
		if (request.getParameterValues("pseudoImageFile") != null || request.getParameterValues("maPlotImageFile") != null) {
        		new PdfUtil().createPdfForImages(selectedDataset, request, request.getParameterValues("pseudoImageFile"), request.getParameterValues("maPlotImageFile"));
			checkedList.add(selectedDataset.getDownloadsDir() + "ImageFiles.pdf");
		}

        	if (checkedList != null && checkedList.size() > 0){
			mySessionHandler.createDatasetActivity("Downloaded Dataset", dbConn);
			Thread thread = new Thread(new AsyncDatasetDownload(request, checkedList));
			thread.start();
			session.setAttribute("successMsg", "DST-001");
			response.sendRedirect(commonDir + "successMsg.jsp");
			// This is required to avoid the getOutputStream() has already been called for this response error
			// Still necessary?
			//out.clear();
			//out = pageContext.pushBody(); 
        	}
	}
	
%>
    <div class="scrollable">
    <form   method="post" 
        action="downloadDataset.jsp" 
        enctype="application/x-www-form-urlencoded"
        name="downloadDataset"
		id="target">
        <BR>
        <div class="center">
            <input type="submit" name="action" value="Download" onClick="return IsSomethingCheckedOnForm(downloadDataset)" />
        </div>
        <div class="brClear"></div>

        <% if (selectedDataset.getDatasetVersions().length > 0) { %>
		<div class="title"> Normalized Data File(s)</div>
		<table id="normalizedDataFiles" class="list_base" cellpadding="0" cellspacing="3" width="90%">
                <thead>
		<tr class="col_title">
                	<td class="noSort"><input type="checkbox" id="checkBoxHeader" onClick="checkUncheckAll(this.id, 'normalizedFileList')"> </td>
                        <th>File Name</th>
                    </tr>
                </thead>
                <tbody>
		<%
		boolean hdf5file=false;
		if ((new File(selectedDataset.getPath() + "Affy.NormVer.h5")).exists()) {//test for HDF5 file if exists
			hdf5file = true;
		}
		for (int i=0; i<selectedDataset.getDatasetVersions().length; i++) {
			int thisVersion = selectedDataset.getDatasetVersions()[i].getVersion();
			String versionName = selectedDataset.getDatasetVersions()[i].getVersion_name();
			String csvFilenameFull = selectedDataset.getDatasetVersions()[i].getVersion_path()+ 
                                    "v" + thisVersion + "_" + 
                                    selectedDataset.getPlatform() + ".Normalization.output.csv";
			if(hdf5file){
				csvFilenameFull = selectedDataset.getPath()+ 
                                    "v" + thisVersion + "_" + 
                                    selectedDataset.getPlatform() + ".Normalization.output.csv";
			}
			//log.debug("csvFilenameFull = "+csvFilenameFull);
			if(!hdf5file){
				if ((new File(csvFilenameFull)).exists()) { %> 
					<tr>  
						<td> <input type="checkbox" id="normalizedFileList" name="normalizedFileList" value="<%=csvFilenameFull%>" /> </td>  
						<td> Normalized File for v<%=thisVersion%> (<%=versionName%>) </a>in comma-delimited format</td>
					</tr> 
				
				<%}
			}else{%>
				<tr>  
					<td> <input type="checkbox" id="normalizedFileList" name="normalizedFileList" value="<%=csvFilenameFull%>" /> </td>  
					<td> Normalized File for v<%=thisVersion%> (<%=versionName%>) </a>in comma-delimited format</td>
				</tr> 
			<%}
		}
		%> 
                </tbody>
		</table> 
		<div class="brClear"></div><%
	} else {
		if (!selectedDataset.getCreator().equals("public")) { 
                	%> <BR> This dataset has not yet been normalized, so there are no normalized data files available for download.  <BR> <%
		}
        }
        if ((!specificVersion && selectedDataset.hasPhenotypeData(userLoggedIn.getUser_id())) ||
            (specificVersion && selectedDatasetVersion.hasPhenotypeData(userLoggedIn.getUser_id()))) { 
		%>
            <div class="title"> Phenotype Data Files</div>
            <table id="phenotypeFiles" class="list_base" cellpadding="0" cellspacing="3">
                <thead>
                <tr class="col_title">
                    <td class="noSort"><input type="checkbox" id="checkBoxHeader2" onClick="checkUncheckAll(this.id, 'phenotypeFileList')"> </td>
                    <th>File Name</th>
                </tr>
                </thead>
                <tbody>
                <%

		Dataset.Group[] groupings = selectedDataset.getGroupings(dbConn);
                for (Dataset.Group thisGroup : groupings) {
                	for (Dataset.DatasetVersion thisVersion : selectedDataset.getDatasetVersions()) {
				// if this is not a specific version, then have to set the Dataset so that the correct grouping path is set
				thisVersion.setDataset(selectedDataset);
				String[] phenotypeNames = null;
				if (thisVersion.getGrouping_id() == thisGroup.getGrouping_id()) { 
					phenotypeNames = new ParameterValue().getPhenotypeNames(userID, selectedDataset, thisVersion.getGrouping_id(), dbConn); 
					for (String thisPhenotypeName : phenotypeNames) {
						File phenotypeFile = new File(thisVersion.getPhenotypeDownloadFileName(userName, thisPhenotypeName)); 
						if (phenotypeFile.exists()) { %> 
							<tr>
								<td><center> <input type="checkbox" name="phenotypeFileList" value="<%=phenotypeFile%>"></center></td>  
								<td> Phenotype Data for '<%=thisPhenotypeName%>'</td>
							</tr> 
						<% 
						}
					}
                                	break;
				}
			}
		}
	%> 
            </tbody>
            </table> 
            <div class="brClear"></div><%
        } 
        if (!specificVersion) { %> 
		<div class="title">  Raw Data Files </div>
		<table name="rawDataFiles" class="list_base" id="rawDataFiles" cellpadding="0" cellspacing="3" >
                <thead>
                <tr class="col_title">
                    <td class="noSort"><input type="checkbox" id="checkBoxHeader3" onClick="checkUncheckAll(this.id, 'dataFileList')"> </td> 
                    <th>Array Name</th>
                    <th>File Name</th>
		<% if (selectedDataset.hasGeneratedQCImage() ) { %>
                       <th class="noSort">Pseudo Image Files <input type="checkbox" id="checkBoxHeader4" onClick="checkUncheckAll(this.id, 'pseudoImageFile')">  </th>
			<% if (selectedDataset.getPlatform().equals(new Dataset().AFFYMETRIX_PLATFORM)) { %>
                             <th class="noSort">MA Plot Files <input type="checkbox" id="checkBoxHeader5" onClick="checkUncheckAll(this.id, 'maPlotImageFile')">  </th>
			<% } %>
		<% } %>
                </tr>
                </thead>
                <tbody>
                <%
        	String arrayLocation = new edu.ucdenver.ccp.PhenoGen.data.Array().getArrayDataFilesLocation(userFilesRoot); 
                if (numArrays > 0) { 
                    for (int i=0; i<myArrays.length; i++) {
                        %> 
                        <tr> 
                            <td> 
                            <center> <input type="checkbox" name="dataFileList"
                                value="<%=arrayLocation%><%=myArrays[i].getFile_name()%>"> 
                            </center>
                            </td>
                            <td> <%=myArrays[i].getHybrid_name()%> </td>
                            <td> <%=myArrays[i].getFile_name()%> </td>
                            <% if (selectedDataset.hasGeneratedQCImage()) { %>
                                 <td class="center"> <input type="checkbox" name="pseudoImageFile" value="<%=myArrays[i].getHybrid_name()%>"/> </td>
                            <%    if (selectedDataset.getPlatform().equals(new Dataset().AFFYMETRIX_PLATFORM)) { %>
                                     <td class="center"> <input type="checkbox" name="maPlotImageFile" value="<%=myArrays[i].getHybrid_name()%>"/> </td>
                                  <% } %>
                            <% } %>
                        </tr> <%
                    }
                } else {
                    %> 
                    <tr><td colspan="3"> <h2>No array datafiles are available for this dataset. </h2></td></tr>
                    <%
                }
                %>
                </tbody>
                </table>
        <% } %>
        <div class="brClear"></div>
        <input type="hidden" name="itemIDString" value=<%=itemIDString%> />
    </form>
    </div>

 <div class="load">Loading...</div>
  <script>
    $(document).ready(function() {
	setupDownloadDatasetPage();
    });
  </script>
