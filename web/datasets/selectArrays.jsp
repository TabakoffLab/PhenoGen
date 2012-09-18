<%--
 *  Author: Cheryl Hornbaker
 *  Created: Dec, 2005
 *  Description:  The web page created by this file displays all of the arrays
 *		available to the user and allows him/her to combine them and create datasets
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>

<%
	log.info("in selectArrays.jsp." );
	request.setAttribute( "selectedStep", "1" ); 
        session.setAttribute("selectedDataset", null);

	Dataset dummyDataset = (session.getAttribute("dummyDataset") == null ?
					new Dataset(-99) : (Dataset) session.getAttribute("dummyDataset"));;
	log.debug("dummyDataset.dataset_id = "+dummyDataset.getDataset_id());
	Set hybridSet = null;
	if (dummyDataset.getDataset_id() != -99) {
                hybridSet = dummyDataset.getDatasetHybridIDsAsSet(dbConn);
		//log.debug("Array Set = "); myDebugger.print(hybridSet);
	}
	int dummyDatasetID = dummyDataset.getDataset_id();

	extrasList.add("arrayTabs.js");
	extrasList.add("selectArrays.js");
	//extrasList.add("jquery.tablesorter.pager.js");
	extrasList.add("jquery.dataTables.js");
	//extrasList.add("jquery.ColumnFilterWidgets.js");
	optionsListModal.add("addToDataset");
	optionsListModal.add("viewFinalizeDataset");

	Hashtable attributes = (Hashtable) session.getAttribute("attributes");
	//
	// Get the arrays which the user already has access to or has requested access for
	//
	Hashtable iniaArrays = myArray.getMyUniqueArrays(userID, dbConn);
	//log.debug("iniaArrays = "); myDebugger.print(iniaArrays);

        int batchSize = 1000; 
        int pageNum = 0; 

	String hybridIDList = "All";
	boolean keepGoing=true;

	HashMap piHashMap  = new HashMap();
	edu.ucdenver.ccp.PhenoGen.data.Array[] myArrays = null;
	edu.ucdenver.ccp.PhenoGen.data.Array[] publicArrays = null;

	int numRows = 0;
	log.debug("action = "+action);


        //log.debug("action = " + action);

	boolean guestFirstView = false;

	//
	// Get the principal investigators for all the users
	//
	// piHashMap stores the username and principal investigator's email 
	//

	piHashMap = myUser.getPrincipalInvestigatorsByUser(dbConn);
		
	//
	// Get the hybrid IDs of the arrays to which the user has access
	//
        hybridIDList = myUser.getMyArrays(userID, dbConn);
	//log.debug("hybridIDList = "+hybridIDList);
	if (!hybridIDList.equals("()")) {
	//	myArrays = 
	//		myArray.getArraysThatMatchCriteria(hybridIDList, attributes, dbConn);
		log.debug("number of non-public arrays that user has access to = "+numRows);
		session.setAttribute("myArrays", myArrays);
	}

	publicArrays = 
		myArray.getArraysThatMatchCriteria("All", attributes, dbConn);
	log.debug("publicArrays is "+publicArrays.length +" long");

	//
	// Add the public arrays to myArrays
	//
	if (myArrays != null) {
		List myArraysAsList = new ArrayList(Arrays.asList(myArrays));
		List publicArraysAsList = new ArrayList(Arrays.asList(publicArrays));
	
		publicArraysAsList.removeAll(myArraysAsList);
		myArraysAsList.addAll(publicArraysAsList);
		myArrays = (edu.ucdenver.ccp.PhenoGen.data.Array[]) myArraysAsList.toArray(new edu.ucdenver.ccp.PhenoGen.data.Array[myArraysAsList.size()]);
	} else {
		myArrays = publicArrays;
	}
	session.setAttribute("myArrays", myArrays);
	
// At this point we have all of the arrays

	if (myArrays == null) {
		//Error - "No arrays"
		session.setAttribute("errorMsg", "CHP-004");
		response.sendRedirect(commonDir + "errorMsg.jsp");
	} else {
		numRows = myArrays.length;
	}

	log.debug("now myArrays is "+myArrays.length +" long");

	//String arrayGroup = hybridIDList;
	String arrayGroup = "All";
	formName = "selectArrays.jsp";
	//boolean loggedIn = true;
	
// Next section describes what happens if we click Add Selected Arrays to Dataset
	
	if (action != null && action.equals("Add Selected Arrays to Dataset")) {
                String[] checkedList = null;
                //
                // Get all the arrays which the user selected
                // checkedList[i] contains the hybridID
                //
                if (request.getParameter("hybridID") != null) {
                        checkedList = request.getParameterValues("hybridID");
                        //log.debug("checkedList.length = "+checkedList.length); myDebugger.print(checkedList);
                }

                String[] hybridIDs = checkedList;
                //
                // Make sure this user has all the user_chips records
                //
		myDataset.setupArrayRecords(hybridIDs, userLoggedIn, userFilesRoot, dbConn);

		// 
                // Get all the arrays which the user selected and create dataset_chips for
                // each of them.  Also update the qc_complete flag in datasets to "N".
                //
                //
                boolean arrayAlreadyExistsInDataset=false;

		dummyDataset = (session.getAttribute("dummyDataset") == null ?
					new Dataset(-99) : (Dataset) session.getAttribute("dummyDataset"));
		log.debug("now dummyDataset.dataset_id = "+dummyDataset.getDataset_id());
                String thisDatasetOrganism = "";
                String thisDatasetPlatform = "";
                String dummyDatasetHybridIDs = "";
                String thisDatasetArrayType = "";
		if (dummyDataset != null && dummyDataset.getDataset_id() != -99) {
                	thisDatasetOrganism = dummyDataset.getOrganism();
                	thisDatasetPlatform = dummyDataset.getPlatform();
                	log.debug("thisExperientOrganism = "+thisDatasetOrganism + 
                		", thisPlatform = " + thisDatasetPlatform + 
                               	", thisDatasetArrayType = "+thisDatasetArrayType);

                	dummyDatasetHybridIDs = dummyDataset.getDatasetHybridIDs(dbConn);
                	thisDatasetArrayType = myArray.getDatasetArrayType(dummyDatasetHybridIDs, dbConn);
		}
                for (int i=0; i<checkedList.length; i++) {
			edu.ucdenver.ccp.PhenoGen.data.Array thisArray = myArray.getArrayFromMyArrays(myArrays, Integer.parseInt(checkedList[i]));
                	String organism = thisArray.getOrganism();
                        // change the organism name to it's 2-character equivalent
                        organism = new Organism().getOrganism(organism, dbConn);
                        String platform = thisArray.getPlatform();
                        String arrayType = thisArray.getArray_type();

			if (dummyDataset != null && dummyDataset.getDataset_id() != -99) {
                        	//log.debug("organism = "+organism + ", platform = "+platform + ", arrayType = "+arrayType);

                        	if (!organism.equals(thisDatasetOrganism)) {
					keepGoing=false;
                                	log.debug("organism doesnt match");
                                	//Error - "Organism doesn't match"
                                	session.setAttribute("errorMsg", "EXP-005");
				} else if (!platform.equals(thisDatasetPlatform)) {
                        		keepGoing=false;
                                	log.debug("Platform doesnt match");
                                	//Error - "Platform doesn't match"
                                	session.setAttribute("errorMsg", "EXP-006");
				} else if (!arrayType.equals(thisDatasetArrayType)) {
					keepGoing=false;
                                	log.debug("ArrayType doesnt match");
                                	//Error - "ArrayType doesn't match"
                                	session.setAttribute("errorMsg", "EXP-008");
				} 

				if (keepGoing) {
                        		try {
                                		//
                                        	// get the user_chip_id for this hybrid_id and user_id combination
                                        	//
                                        	int user_chip_id = myDataset.getUser_chip_id(
										Integer.parseInt(checkedList[i]), userID, dbConn);
                                        	dummyDataset.createDataset_chip(user_chip_id, dbConn);
					} catch (SQLException e) {
						//log.debug("array already exists in expeeriment");
                                		arrayAlreadyExistsInDataset=true;
					}
				} else {
                                	response.sendRedirect(commonDir + "errorMsg.jsp");
                                	break;
				}
			} else {

                		myDataset.setPlatform(platform);
                		myDataset.setOrganism(organism);
                		myDataset.setCreated_by_user_id(userID);

                		try {
                        		dummyDataset = myDataset.createDummyDataset(dbConn);
                			thisDatasetOrganism = organism;
                			thisDatasetPlatform = platform;
                			thisDatasetArrayType = arrayType;

                        		mySessionHandler.createDatasetActivity(session.getId(), 
                                		dummyDataset.getDataset_id(),
                                		0,
                                		"Created a new dataset called '" + dummyDataset.getName() + "'",
                                		dbConn);

                        		int user_chip_id = myDataset.getUser_chip_id(
							Integer.parseInt(checkedList[i]), userID, dbConn);
                        		dummyDataset.createDataset_chip(user_chip_id, dbConn);
                        		session.setAttribute("dummyDataset", dummyDataset);

                		} catch (Exception e) {
                        		log.debug("problems creating dataset in createDummyDataset", e);
                        		dummyDataset.deleteDataset(userLoggedIn.getUser_id(),dbConn);
                        		//Success - "Dataset created"
                        		session.setAttribute("errorMsg", "SYS-001");
                        		response.sendRedirect(commonDir + "errorMsg.jsp");
                		}
			}
		}

		dummyDataset.updateQc_complete("N", dbConn);
                mySessionHandler.createDatasetActivity(session.getId(), 
                                       dummyDataset.getDataset_id(),
                                       0,
                                       "Added "+ checkedList.length + " arrays to '" +
                                       dummyDataset.getName() +
                                       "' dataset. ", dbConn);

		log.debug("now have "+dummyDataset.getDatasetChips(dbConn).length+" arrays in dummyDataset");
		if (keepGoing) {
			if (arrayAlreadyExistsInDataset) {
				session.setAttribute("successMsg", "EXP-017");
				response.sendRedirect(commonDir + "successMsg.jsp");
			} else {
				session.setAttribute("successMsg", "EXP-018");
				response.sendRedirect(commonDir + "successMsg.jsp");
			}
		}
	}

	mySessionHandler.createActivity("Looked at arrays", dbConn);
   
	%>

	<%@ include file="/web/common/microarrayHeader.jsp" %>

<!--
	<div class="datasetButton">
		<center><img src="<%=imagesDir%>icons/genechips.gif" alt="Dataset Details" height="120px"><BR>
		View/Finalize Dataset
                	<span class="info" title="Click to view the arrays selected for your dataset and to finalize your dataset.">
                    		<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                	</span>
		<BR>Contains<input type="text" id="test" class="numArraysDisplay" size="3" onFocus="blur()" value="<%=dummyDataset.getDatasetChips(dbConn).length%>"/>arrays
		</center>
	</div>
-->

        <%@ include file="/web/datasets/include/createSteps.jsp" %>
	<% if (numRows == 0) { %> 
		<BR>
		<div class="title">No Arrays Found That Satisfy the Following Search Criteria: </div>
		<br />
		<table class="list_base">
		<%
		Enumeration e = attributes.keys();
		while(e.hasMoreElements()) {
			String searchKey = (String) e.nextElement();
			String searchValue = (String) attributes.get(searchKey);
			if (!searchValue.equalsIgnoreCase("All")) { 
				%> <tr> <td class="sideHeading"><li><%= searchKey %>:</td> <td><%= searchValue %></td> </tr><%
			}
		}
		%>
		</table>
		<br/><br/>
		<center><a href="basicQuery.jsp"> Modfy Search Criteria </a> </center>
		<% 
	} else { %>
		<script type="text/javascript">
        		var crumbs = ["Home", "Analyze Microarray Data", "Create New Dataset"]; 
		</script>
		<div class="page-intro">
			<p>
			<ul class="square"><li>
			Click one or more rows to select the arrays for your dataset. 
			</li>
			<li>
			Then click the <span class="buttonRef">Add Selected Arrays to Dataset</span> icon. 
			</li>
			<li>
			Click the <span class="buttonRef">View/Finalize Dataset</span> icon when you are ready to review and 'finalize' your dataset.
			</li>
			</ul>
			</p>
		</div> <!-- // end page-intro -->
	<div style="float:right; padding-right:14px;">(Dataset contains<input type="text" id="test" class="numArraysDisplay" size="1" onFocus="blur()" value="<%=dummyDataset.getDatasetChips(dbConn).length%>"/>arrays)</div>

		<div class="brClear"></div>
		<!--
		<div id="pager" class="pager">
			<div style="float:right">
				<select class="pagesize">
					<option selected="selected"  value="10">10</option>
					<option value="20">20</option>
					<option value="50">50</option>
					<option  value="100">100</option>
					<option  value="200">200</option>
				</select>
				&nbsp;arrays per page
			</div>
			<div style="float:left">
				<img src="<%=imagesDir%>icons/first.png" class="first"/>
				<img src="<%=imagesDir%>icons/prev.png" class="prev"/>
				<input type="text" class="pagedisplay" size="11" onFocus="blur()"/> 
				<img src="<%=imagesDir%>icons/next.png" class="next"/>
				<img src="<%=imagesDir%>icons/last.png" class="last"/>
			</div>
			<div>
				<div class="title"> <%=numRows%>&nbsp;Matching Arrays </div>
			</div>
		</div>
		-->
		<div class="brClear"></div>
		<div class="list_container">

		<form method="post"
        		action="selectArrays.jsp"
        		enctype="application/x-www-form-urlencoded"
        		name="selectArrays">
                
		<div class="scrollable" style="clear:left;">

		
		
		
		<!--  Here is the table for which we would like fixed headers -->
		
		<style type="text/css">
			table.list_base {
			    word-wrap:break-word;
				table-layout:fixed;
				
			}



		</style>

		<table id="items" name="items" class="list_base" width="100%">
		<col width=3%> <!-- Check Box -->
		<col width=9%> <!-- Availability -->
		<col width=8%> <!-- Organism -->
		<col width=9%> <!-- Category -->
		<col width=5%><!-- Sex -->
		<col width=6%> <!--Tissue -->
		<col width=8%> <!--Treatment -->
		<col width=15%> <!--Hybridization Name -->
		<col width=12%> <!-- Array Type -->
		<col width=10%> <!-- Experiment Name  -->
		<col width=9%> <!-- Principal Investigator -->
		<col width=6%> <!-- Array Details -->
			<thead>
			<tr class="col_title">
        			<th class="col1"><input type="checkbox" id="checkBoxHeader" onClick="checkUncheckAll(this.id, 'hybridID')"> </th>
        			<th class="col2">Availability</th>
        			<th class="col3">Organism</th>
        			<th class="col4">Category</th>
        			<th class="col5">Sex</th>
        			<th class="col6">Tissue</th>
        			<th class="col7">Treatment</th>
        			<th class="col8">Hybridization Name
                			<span class="info" title="Unique name for the hybridization array data file.">
                    			<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                			</span>
				</th>
        			<th class="col9">Array Type
                			<span class="info" title="Array platform type and specific version name.">
                    			<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                			</span>
				</th>
        			<th class="col10">Experiment Name</th>
        			<th class="col11">Principal Investigator</th>
        			<th class="col12">Array Details</th>
			</tr>
			</thead>

			<tbody style="overflow:auto;height:450px;">
<%
	
		/*
		log.debug("numRows = "+numRows);
		log.debug("batchSize = "+batchSize);
		log.debug("pageNum = "+pageNum);
		log.debug("min = " + Math.min(batchSize, numRows - (pageNum*batchSize)));
		*/

		for (int i=0; i<numRows; i++) {
			//int rowNumber = (batchSize * pageNum) + i;
			//if (rowNumber > numRows) break;
			int rowNumber = i;
			int hybridID = myArrays[rowNumber].getHybrid_id();
			User principalInvestigator = ((User) piHashMap.get(myArrays[rowNumber].getSubmitter()));
			String ownerUserID = "Unknown";
			String ownerName = "Unknown";
			if (principalInvestigator != null) {
				ownerUserID = Integer.toString(principalInvestigator.getUser_id());
				ownerName = principalInvestigator.getTitle() + " " +
					principalInvestigator.getFirst_name() + " " + 
					principalInvestigator.getLast_name();
			} 
			String rowClass = "approved";
			String accessType = "Public";
			if (myArrays[rowNumber].getPlatform().equals("cDNA")) {
				rowClass="noAccess";
				accessType="Not Available for Analysis";
			} else if (myArrays[rowNumber].getPublicExpID() != null && 
					!myArrays[rowNumber].getPublicExpID().equals("")) {
				rowClass="approved";
			} else if (iniaArrays.containsKey(Integer.toString(hybridID))) {
				String accessFlag = (String) iniaArrays.get(Integer.toString(hybridID));
				// 
				// if access is Pending
				//
				if (accessFlag.equals("0")) {
					rowClass="pending";
					accessType = "Access Pending";
				// 
				// if access was denied
				//
				} else if (accessFlag.equals("-1")) {
					rowClass="noAccess";
					accessType = "Access Denied";
				// 
				// if access has already been granted 
				//
				} else if (accessFlag.equals("1")) {
					rowClass="approved";
					accessType = "Access Approved";
				}
			//
			// access has not yet been requested -- permission is required
			//
			} else {
				rowClass="request";
				accessType = "Access Required";
			}
			String checked = (hybridSet != null && hybridSet.contains(Integer.toString(hybridID)) ? " checked " : "");
			//log.debug("id = "+hybridID + " and checked = "+checked);
			%>
			<tr id="<%=hybridID%>" 
				platform="<%=myArrays[rowNumber].getPlatform()%>" 
				organism="<%=myArrays[rowNumber].getOrganism()%>"
				arrayType="<%=myArrays[rowNumber].getArray_type()%>"
				class="<%=rowClass%>">
			<% if (!myArrays[rowNumber].getPlatform().equals("cDNA")) { %>
				<td class=center><input type="checkbox" id="hybridID" name="hybridID" <%=checked%> value="<%=hybridID%>"></td> 
			<% } else { %>
				<td>&nbsp;</td>
			<% } %>
                        <td class=center><%=accessType%>
				<% if (accessType.equals("Not Available for Analysis")) { %>
					<a href="http://www.longhornarraydatabase.org/" target="Longhorn Array Database">
             				<span class="info" title="To analyze this array, you may use the tools available at the Longhorn Array Database.  Click now to open that website in a new window.">
                 				<img src="<%=imagesDir%>icons/info.gif" alt="Help">
             				</span>
					</a>
				<% } %>
			</td> 
			<td> <%=myArrays[rowNumber].getOrganism()%></td>
			<td> <%=myArrays[rowNumber].getGenetic_variation()%></td>
			<td> <%=myArrays[rowNumber].getGender()%></td>
			<td> <%=myArrays[rowNumber].getOrganism_part()%></td>
			<td> <%=myArrays[rowNumber].getTreatment()%> </td> 
			<td class="wrapit"> <%=myArrays[rowNumber].getHybrid_name()%> </td> 
			<td><%=myArrays[rowNumber].getArray_type()%></td> 
			<td><%=myArrays[rowNumber].getExperiment_name()%></td> 
			<td> <%=ownerName%> </td> 
    			<td class="details">View</td>
			</tr>
			<%
		}
		%> 
		</tbody>

	</table> 
	</div><!-- div_scrollable -->

	<input type="hidden" name="dummyDatasetID" value="<%=dummyDatasetID%>">
	<input type="hidden" name="action" value="">
	</form>
	</div><!-- div_list_container -->
<%
	}
%>
	<div class="arrayDetails"></div>
	<div class="userDetails"></div>
	<div class="datasetDetails"></div>
	<script type="text/javascript">
		$(document).ready(function() {
			setupPage();
			setTimeout("setupMain()", 100); 
			
			/* 
			Trying fixed headers with scrolling using dataTable
			*/
			
			
			$('#items').dataTable({
				"bAutoWidth": false,
				"bDeferRender": true,
				"bProcessing" : true,
				"sScrollY": "450px",
				"bPaginate": false,
				"aoColumnDefs": [
					{"bSortable":false, "aTargets":[0,11]}
					],
				"aaSorting":[[7,'asc']],
				"sDom": '<"top"i>rt',
				"aoColumns": [
            		{ "sWidth": "3%" },
            		{ "sWidth": "9%" },
            		{ "sWidth": "8%" },
           			{ "sWidth": "9%" },
          			{ "sWidth": "5%" },
            		{ "sWidth": "6%" },
               		{ "sWidth": "8%" },
                  	{ "sWidth": "14.5%" },
            		{ "sWidth": "12%" },
                	{ "sWidth": "10%" },
                    { "sWidth": "9%" },
                    { "sWidth": "6.5%" }
			   ]
			});
			
/*

			$('#items').tablesorter({ 
        			headers: {0:{sorter: false}, 11:{sorter: false}} 
        		});
			$('#items').tablesorterPager({container: $("#pager")});
*/

		});
	</script>

<%@ include file="/web/common/footer.jsp" %>
