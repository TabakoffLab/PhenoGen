<%--
 *  Author: Cheryl Hornbaker
 *  Created: February, 2009
 *  Description:  This file creates a web page that displays detailed information 
 *	about a dataset.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>

<%
	log.info("in datasetDetails.jsp.");  
	extrasList.add("selectArrays.js");

	Dataset dummyDataset = (session.getAttribute("dummyDataset") == null ?
					new Dataset(-99) : (Dataset) session.getAttribute("dummyDataset"));;
	log.debug("dummyDataset.dataset_id = "+dummyDataset.getDataset_id());
	int dataset_id = dummyDataset.getDataset_id();

	String hybridIDs = (dataset_id == -99 ? "" : new Dataset(dataset_id).getDatasetHybridIDs(dbConn));
	log.debug("dataset_id = " + dataset_id + ", and hybridIDs = "+hybridIDs);
	edu.ucdenver.ccp.PhenoGen.data.Array[] myDatasetArrays = ((!hybridIDs.equals("") && !hybridIDs.equals("()")) ? 
						myArray.getArraysByHybridIDs(hybridIDs, dbConn) : 
						null);

	if (action != null && action.equals("Finalize Dataset")) {
		log.debug("finalizing dataset");
        	if (userLoggedIn.getUser_name().equals("guest")) {
                	//Error - "Can't create datasets
                	session.setAttribute("errorMsg", "GST-002");
                	response.sendRedirect(commonDir + "errorMsg.jsp");
        	}
		if (myDatasetArrays.length < 3) {
			//Error - "Too few arrays"
			session.setAttribute("errorMsg", "EXP-011");
			response.sendRedirect(commonDir + "errorMsg.jsp");
		} else {
			String dataset_name = (String) request.getParameter("dataset_name");
			String description = (String) request.getParameter("description").trim();

                	if (myDataset.datasetNameExists(dataset_name, userID, dbConn)) {
                        	log.debug("dataset name already exists");
				//Error - "Dataset exists"
                        	session.setAttribute("errorMsg", "EXP-003");
                        	response.sendRedirect(commonDir + "errorMsg.jsp");
                	} else {
                        	log.debug("dataset name does not already exist");

				boolean accessRequired = false;
				try {
					myDataset.setName(dataset_name);
                        		myDataset.setDescription(description);
					myDataset.updateDummyDataset(dataset_id, dbConn); 

					// Do not want to put 'Pending' part into the file system directory name, so get 
					// the path now

					accessRequired = userLoggedIn.sendAccessRequest(hybridIDs, mainURL, dbConn);
					log.debug("accessRequired = "+accessRequired);
                                	Dataset thisDataset = 
						myDataset.getDataset(dataset_id, userLoggedIn, dbConn,userFilesRoot);
					String dirToCreate = thisDataset.getPath();
					String imagesDirToCreate = thisDataset.getImagesDir();
					log.debug("dirToCreate = "+dirToCreate);
					log.debug("imagesDirToCreate = "+imagesDirToCreate);

					if (accessRequired) {
						dataset_name = dataset_name + " (Pending)";
						myDataset.setName(dataset_name);
						myDataset.updateDummyDataset(dataset_id, dbConn); 
                                		thisDataset = myDataset.getDataset(dataset_id, userLoggedIn, dbConn,userFilesRoot);
					}

                                	mySessionHandler.createDatasetActivity(session.getId(), 
						thisDataset.getDataset_id(),	
						0, "Created a new dataset called '" +
						thisDataset.getName(), dbConn);

					if (!myFileHandler.createDir(dirToCreate) || 
						!myFileHandler.createDir(imagesDirToCreate)) {

						log.debug("error creating dataset directory in selectArrays"); 
					
						mySessionHandler.createDatasetActivity(session.getId(), 
							thisDataset.getDataset_id(), 0,
							"got error creating dataset directory in selectArrays for " +
							thisDataset.getName(),
							dbConn);
						session.setAttribute("errorMsg", "SYS-001");
                        			response.sendRedirect(commonDir + "errorMsg.jsp");
					} else {
						log.debug("no problems creating dataset directory in selectArrays"); 
						session.setAttribute("dummyDataset", null);
						session.setAttribute("privateDatasetsForUser", null);
						thisDataset.updateArrayType(thisDataset.getDataset_id(),dbConn);
						//Success - "Dataset created"
						if (accessRequired) {
							//Success - "Request array access"
							session.setAttribute("successMsg", "CHP-006");
							response.sendRedirect(datasetsDir + "listDatasets.jsp");
						} else {
							session.setAttribute("successMsg", "EXP-019");
							response.sendRedirect(datasetsDir + "listDatasets.jsp");
						}
                			} 
				} catch (javax.mail.SendFailedException e) {
	                       		log.error("error sending email with access request");
					//Error - "Error sending email requesting access"
					session.setAttribute("errorMsg", "CHP-003");
                        		response.sendRedirect(commonDir + "errorMsg.jsp");
				} catch (javax.mail.MessagingException e) {
	                       		log.error("error sending email with access request");
					//Error - "Error sending email requesting access"
					session.setAttribute("errorMsg", "CHP-003");
                        		response.sendRedirect(commonDir + "errorMsg.jsp");
				} catch (SQLException e) {
					log.debug("problems creating dataset in selectArrays", e); 
					dummyDataset.deleteDataset(userLoggedIn.getUser_id(),dbConn);
					//Success - "Dataset created"
					session.setAttribute("errorMsg", "SYS-001");
					response.sendRedirect(commonDir + "errorMsg.jsp");
				}
			}
		}
	} else if (action != null && action.equals("Delete Array")) {
		int arrayID = Integer.parseInt((String) request.getParameter("arrayID"));
		dummyDataset.deleteDataset_chip(userID, arrayID, dbConn);
		hybridIDs = dummyDataset.getDatasetHybridIDs(dbConn);
		log.debug("Deleting array. hybridIDs = XX"+hybridIDs + "XX");
		myDatasetArrays = (!hybridIDs.equals("") && !hybridIDs.equals("()") ? 
						myArray.getArraysByHybridIDs(hybridIDs, dbConn) : 
						null);
	} else {
		mySessionHandler.createDatasetActivity(session.getId(), 
			dataset_id, 0, 
			"Viewed dataset details for dataset_id " +  dataset_id,  
			dbConn);
	}

%>

  		<div id="related_links">
    		<div class="action">
			<a href="basicQuery.jsp"> Retrieve More Arrays </a><BR>
    		</div>
  		</div>

		<div class="list_container">
		<form method="post"
                       	action="datasetDetails.jsp"
                       	enctype="application/x-www-form-urlencoded"
				onSubmit="return IsNameDatasetFormComplete()"
                       	name="datasetDetails">

			<div class="page-intro">
				<p>To finalize this dataset, enter a name and a description and press the <span class="buttonRef">Finalize Dataset</span> button.
				</p>
			</div> <!-- // end page-intro -->
			<div class="brClear"></div>	
			<table class="list_base">
				<tr>
					<td>Dataset Name:</td>
					<td><input type="text" name="dataset_name" size="40"/></td>
				</tr><tr>
					<td>Description:</td>
					<td><textarea name="description" cols="40" rows="3"/></textarea></td>
				</tr><tr>
					<td colspan="2"><center><input type="submit" name="action" value="Finalize Dataset"></center> </td>
				</tr>
			</table>

			<BR><BR>
			<div class="title"> Arrays Included in Dataset </div>
			<table class="list_base">
			<tr>
				<td><b>Array Type:</b> </td><td><%=myDatasetArrays.length<=0?"":myDatasetArrays[0].getArray_type()%></td>
			</tr>
			<tr>
				<td><b>Organism:</b></td><td> <%=myDatasetArrays.length<=0?"":myDatasetArrays[0].getOrganism()%></td>
			</tr>
			</table>
			<BR>
			<table name="items" id="datasetArrays" class="list_base" >
				<thead>
				<tr class="col_title">
					<th> Array Name </th>
					<th> Category </th>
					<th> Strain </th>
					<th> Tissue </th>
					<th> Treatment </th>
					<th>Delete</th> 
				</tr>
				</thead>
				<tbody>

				<% if (dataset_id != -99) { 
					for (int i=0; i<myDatasetArrays.length; i++) {
						edu.ucdenver.ccp.PhenoGen.data.Array thisArray = myDatasetArrays[i];
						%><tr id="<%=thisArray.getHybrid_id()%>" dataset_id="<%=dataset_id%>">
						
						<td><%=thisArray.getHybrid_name()%></td>
						<td><%=thisArray.getGenetic_variation()%></td>
						<td><%=thisArray.getStrain()%></td>
						<td><%=thisArray.getOrganism_part()%></td>
						<td><%=thisArray.getTreatment()%></td>
						
						<td class="actionIcons">
							<div class="linkedImg delete"></div> 
						</td>
						</tr>
					<% } %>
				<% } %>
				</tbody>
			</table>
			<input type="hidden" name="dataset_id" value="<%=dataset_id%>">
			<input type="hidden" name="action" value="">
			<input type="hidden" name="arrayID" value="">
		</form>
		</div>
		<div class="closeWindow">Close</div>
        <script type="text/javascript">
		$(document).ready(function() {
			// delete column should not be sortable
			$('#datasetArrays').tablesorter({ 
				widgets: ['zebra'],
				headers: {5:{sorter:false}} 
        		});
		});
        </script>
