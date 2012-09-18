<%--
 *  Author: Cheryl Hornbaker
 *  Created: Dec, 2005
 *  Description:  The web page created by this file displays the pending access requests for a PI.
 *		Once the PI approves access to a array, the CEL file for that array is copied
 *		to the user's directory.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/experiments/include/piHeader.jsp"  %>
<%
	log.info("in approveRequests.jsp.  user=" + user);
        extrasList.add("approveRequests.js");	
	edu.ucdenver.ccp.PhenoGen.data.Array[] myArrays = null;
	HashMap pendingRequests = null;

        Thread thread = null;
        Thread thread2 = null;

	// 
	// This gets the hybrid IDs and the user_ids of the requestors for 
	// the arrays owned by this PI. getPendingRequests returns the hybrid IDs in dataRow[0], 
	// and the user id in dataRow[1].
	// The results get placed into pendingRequests HashMap.
	//
	Results myResults = myUser.getPendingRequests(userID, dbConn); 
	String[] dataRow = null;
        String hybridIDs = "(" +
                        myObjectHandler.getResultsAsSeparatedString(myResults, ",", "", 0) + 
                        ")";

	if (!hybridIDs.equals("()")) {
		mySessionHandler.createSessionActivity(session.getId(), 
			"Looked at array requests.  There are " + myResults.getNumRows() + " arrays to be approved.", dbConn); 
		log.debug("length of myResults "+myResults.getNumRows());
		// pendingRequests maps the hybridIDs to a List of User objects
		pendingRequests = new HashMap();
		myResults.goToFirstRow();
	
		String hybridIDString, lastHybridID = "";

		while ((dataRow = myResults.getNextRow()) != null) {
			hybridIDString = dataRow[0]; 
			// 
			// if more than one user requested access to this array, add
			// a User object to the userArray.  Otherwise, create a 
			// new entry in the pendingRequests HashMap
			//
			User thisUser = myUser.getUser(Integer.parseInt(dataRow[1]), dbConn);
			//log.debug("thisUser title = "+thisUser.getTitle() + ", and full_name = " + thisUser.getFull_name());
			if (!hybridIDString.equals(lastHybridID)) {
				ArrayList userArray = new ArrayList();
				userArray.add(thisUser);
				pendingRequests.put(hybridIDString, userArray);
			} else {
				((ArrayList) pendingRequests.get(hybridIDString)).add(thisUser);
			}
			lastHybridID = hybridIDString; 
		}
	
		myResults.close();
		log.debug("size of pendingRequests = "+pendingRequests.size());

	
		//
		// Put the array information into an array of Array objects.  The information 
		// will be displayed for every user who has requested access to the array.
		// Had to do this because the hybrid_ids and requestor user_ids are stored in the 
		// user_chips table in the database, and the array information is in db.
		// In order to join the two, we need this structure. 
		//
		myArrays = myArray.getArraysByHybridIDs(hybridIDs, dbConn); 
		log.debug("length of myArrays = "+myArrays.length);
	
		if ((action != null) && action.equals("Submit Array Approvals")) {
		
			//
			// the requests HashMaps map a user to a list of arrays
			// whose access is either approved or denied for that user
			//
	
			HashMap requests = new HashMap();
	
			for (int i=0; i<myResults.getNumRows(); i++) {
       		         	//
		                // checkedValue contains the values of the radio buttons that were
       		         	// actually selected by the user
       	         		//
                        	String checkedValue = (String) request.getParameter(Integer.toString(i));

				if (checkedValue != null) {
					int thisUser_id = Integer.parseInt((String) request.getParameter("user_id" + i));
					User newUser = myUser.getUser(thisUser_id, dbConn);
					User thisUser = new User();
					boolean userFound = false;
					if (i==0) {
						requests.put(newUser, new ArrayList());
					} else {
						Iterator requestsIterator = requests.keySet().iterator();
						while (requestsIterator.hasNext() && !userFound) {
							thisUser = (User) requestsIterator.next();
							if (thisUser.getUser_id() == thisUser_id) {
								userFound = true;
							}
						}
						if (!userFound) {
							requests.put(newUser, new ArrayList());
						}
					}
	
					int thisHybridID = Integer.parseInt(
							(String) request.getParameter("hybrid_id" + i));

					edu.ucdenver.ccp.PhenoGen.data.Array thisArray = myArray.getArrayFromMyArrays(myArrays, thisHybridID); 
					thisArray.setAccess_approval(Integer.parseInt(checkedValue));

//					thisArray.setArray_users(new int[] {thisUser_id});

					if (userFound) {
						((List) requests.get(thisUser)).add(thisArray);
					} else {
						((List) requests.get(newUser)).add(thisArray);
					}

				} 
			}
			log.debug("number of unique users = "+requests.size());
			//log.debug("requests = "); myDebugger.print(requests);
	
			log.debug("copying CEL files and sending request emails");

			// 
			// For each user, copy the CEL files to his/her directory
			//
			Iterator requestsIterator = requests.keySet().iterator();
			while (requestsIterator.hasNext()) {

				User thisUser = (User) requestsIterator.next();

				//
				// Perform the following steps:
				//
				// 1. Create a list of the approved arrays for this user
				// 2. Create a thread to copy the files to the user's directory
				// 3. Create a thread to update the user_chips table and 
				// send an email to the user
				// 
				/*************************** STEP 1 ****************************/
				// 1. Create a list of the approved arrays for this user
				//

				List arrayList = (List) requests.get(thisUser);
				//log.debug("Here arrayList = "); myDebugger.print(arrayList);
				List approvedArrayList = new ArrayList();

				mySessionHandler.createSessionActivity(session.getId(), 
						"Granted Access to " + ((List) requests.get(thisUser)).size() + 
						" Arrays uploaded by " + ((edu.ucdenver.ccp.PhenoGen.data.Array) arrayList.get(0)).getSubmitter()+ 
						" to "+ thisUser.getFull_name(), dbConn);

				for (int i=0; i<arrayList.size(); i++) {
					edu.ucdenver.ccp.PhenoGen.data.Array thisArray = (edu.ucdenver.ccp.PhenoGen.data.Array) arrayList.get(i);
					if (thisArray.getAccess_approval() == 1) {
						approvedArrayList.add((edu.ucdenver.ccp.PhenoGen.data.Array) arrayList.get(i));
					}
				}
				log.debug("approvedArrayList = ");myDebugger.print(approvedArrayList);

                		/*************************** STEP 2 ****************************/
		                // 2. Create a thread to copy the raw data files into the user's 
				// Arrays directory from the directories.
				//

				/*  As of R2.4 (March 2011), no longer need to copy files
				String arrayDir = myArray.getArrayDataFilesLocation(userFilesRoot);

				log.debug("arrayDir = "+arrayDir);

				thread = new Thread(new AsyncCopyFiles(
					approvedArrayList, 
					userFilesRoot,
                                	arrayDir));

                        	log.debug("Starting first thread "+ thread.getName());

                        	thread.start();
				*/

		                /*************************** STEP 3 ****************************/
                		// 3. Create a thread to update the user_chips table and 
				// send an email to the user.
                		//
				User thisOwner = myUser.getUser(userID, dbConn);
                		log.debug("Starting thread2 ");
                		thread2 = new Thread(new AsyncUpdateUserArrays(
							thisUser, thisOwner, "U", arrayList, 
							//session, true, thread));
							session, true));

                		log.debug("thread2  = "+ thread2.getName());

                		thread2.start();
					
			}
			//Success - "Array access updated"
			session.setAttribute("successMsg", "CHP-007");
			response.sendRedirect(commonDir + "successMsg.jsp");
       	 	}
	} else {
		mySessionHandler.createSessionActivity(session.getId(), 
			"Looked at array requests, but there are none pending.", dbConn); 
	}
	

%>

<%@ include file="/web/common/header.jsp" %>
<div class="list_container">

<% if (!hybridIDs.equals("()")) { %>
		Choose an option for each request and then press "Submit" at the bottom of the page.
		<form	method="post" 
			action="approveRequests.jsp" 
			enctype="application/x-www-form-urlencoded" 
			name="approveRequests">

		<BR><BR>
<div align=left>
<input type="button" name="all" value="Approve All" onClick="approveAll()">
<%=fiveSpaces%>
<input type="button" name="all" value="Deny All" onClick="denyAll()">
<BR>
<BR>
</div>

<table id="requests" class="list_base" width="95%">
	<thead>
	<tr class="col_title">
	<th width="5%"> Approve
	<th width="5%"> Deny
	<th width="10%"> Organism
	<th width="10%"> Genetic Variation
	<th width="10%"> Sex
	<th width="10%"> Organism Part
	<th width="20%"> Array Name
	<th width="20%"> Experiment Name
	<th width="10%"> Requestor
	</tr>
	</thead>
	<tbody>
<% 	
	int rowNum = 0;
	//
	// go through myArrays, get the hybrid_id, then create one record
	// for each user_id linked to that hybrid_id in the pendingRequests HashMap
	//
	for (int i=0; i<myArrays.length; i++) { 
		int hybridID = myArrays[i].getHybrid_id(); 
		ArrayList thisArrayList = (ArrayList) pendingRequests.get(Integer.toString(hybridID));
		User[] users = (User[]) thisArrayList.toArray(new User[thisArrayList.size()]);
		for (int j=0; j<users.length; j++) {
			%> <tr> 
				<td class=center><input type="radio" name="<%=rowNum%>" value="1"> </td> 
				<td class=center><input type="radio" name="<%=rowNum%>" value="-1"> </td> 
				<td><%=myArrays[i].getOrganism()%></td>
				<td><%=myArrays[i].getGenetic_variation()%></td>
				<td><%=myArrays[i].getGender()%></td>
				<td><%=myArrays[i].getOrganism_part()%></td>
				<td><%=myArrays[i].getHybrid_name()%></td>
				<td><%=myArrays[i].getExperiment_name()%></td>
				<td><%=users[j].getFull_name()%>
				<input type="hidden" name="user_id<%=rowNum%>" value="<%=users[j].getUser_id()%>"> 
				<input type="hidden" name="hybrid_id<%=rowNum%>" value="<%=hybridID%>"> 
				</td>
			<%
		rowNum++;
		}
		%> </tr> <%
	}
%>

	</tbody>
</table>
		<BR> <BR>
	
		<center>
		<input type="reset" value="Reset" /><%=tenSpaces%>
		<input type="submit" name="action" value="Submit Array Approvals" />
		<BR><BR>
	
		</center> 
		</form>
<%
	} else {
		%>
		<div class="page-intro">
            <p>You have no pending access requests.</p>
        </div>
        <div class="brClear"></div>
		<%
	}
	
%>
</div>

	<script type="text/javascript">
		$(document).ready(function() {
			setupPage();
		});
	</script>

<%@ include file="/web/common/footer.jsp" %>

