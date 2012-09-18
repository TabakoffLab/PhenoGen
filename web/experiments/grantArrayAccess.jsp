<%--
 *  Author: Cheryl Hornbaker
 *  Created: Mar, 2006
 *  Description:  The web page created by this file displays the arrays owned by the user logged in
 *      and allows them to grant access to anyone.  Once access is granted, 
 *      the CEL file for that array is copied to the user's directory.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/experiments/include/piHeader.jsp"  %>

<%  
                  
String confirmGrant                             = (String) request.getParameter("confirmGrant");    
String experimentName                           = request.getParameter("experimentName");
log.debug("experimentName = "+experimentName);
edu.ucdenver.ccp.PhenoGen.data.Array[] myArrays = null;     
User thisGrantee                                = null;
Thread thread                                   = null;
Thread thread2                                  = null;
String experimentID                             = null;
String  userId                                  = null;

	log.debug("in grantArrayAccess.jsp");
              
	if (confirmGrant == null) {
		log.debug("confirmGrant is null");

                    Hashtable attributes = new Hashtable();
                  
                    experimentID = request.getParameter("experimentID");
      
                    attributes.put("ExperimentID", experimentID);
    
                    myArrays = myArray.getArraysThatMatchCriteria("All", attributes, (java.sql.Connection)session.getAttribute("dbConn")); 
                    session.setAttribute("myArrays", myArrays);    
  
                    userId = request.getParameter("userId"); 
log.debug("userId = "+userId);


                    //thisGrantee = myUser.getUser(Integer.parseInt(userId), (java.sql.Connection)session.getAttribute("dbConn"));
                    thisGrantee = myUser.getUser(Integer.parseInt(userId), dbConn);
                    session.setAttribute("thisGrantee", thisGrantee);  
 
                    Hashtable granteeArrays = new Hashtable();
 
                    Hashtable arrayAccess = myArray.getMyUniqueArrays(Integer.parseInt(userId), (java.sql.Connection)session.getAttribute("dbConn"));

                    granteeArrays.put(thisGrantee.getUser_name(), arrayAccess);

%>
<form   method="post" 
                action="grantArrayAccess.jsp" 
                enctype="application/x-www-form-urlencoded" 
                name="grantArrayAccess">
<div align=center>
   <h2>Granting Access to <%=thisGrantee.getFull_name()%> <br/>for <br/><%= experimentName %></h2>
</div>

<table name="grantAccessitems" class="list_base tablesorter" id="grantAccessitems">
            <thead>
            <tr class="col_title">
<!--<th> Grant to <%=thisGrantee.getFull_name()%></th>-->
<th><center><input type="checkbox" id="grantAll"> </center></th>
<th> Organism</th>
<th> Category</th>
<th> Sex</th>
<th> Tissue</th>
<th> Array Name</th>
<!--<th> Experiment Name</th>-->
<th> Submitter</th>
</tr>
            </thead>
<%  
    for (int i=0; i<myArrays.length; i++) {
        String hybridID = Integer.toString(myArrays[i].getHybrid_id());

        %> <tr class="clickable"> 
            <% 
            if (granteeArrays.containsKey(thisGrantee.getUser_name())) { 
                Hashtable granteeHash = (Hashtable) granteeArrays.get(thisGrantee.getUser_name());
                if (granteeHash.containsKey(hybridID)) {
                    if (((String) granteeHash.get(hybridID)).equals("1")) {
                        %> <td class=center><%= checkMark %></td> <%
                    } else {
                        %> <td class=center>Pending</td> <%
                    }
                } else { 
                    %> <td class=center><input type="checkbox" name="<%=i%>" value="-1"> </td> <%
                }
            } else { 
                %> <td class=center><input type="radio" name="<%=i%>" value="-1"> </td> <%
            } 
            %>
            <!--<td class=center>CCC<input type="checkbox" name="<%=i%>" value="0" checked> </td> -->
            <td><%=myArrays[i].getOrganism()%></td>
            <td><%=myArrays[i].getGenetic_variation()%></td>
            <td><%=myArrays[i].getGender()%></td>
            <td><%=myArrays[i].getOrganism_part()%></td>
            <td><%=myArrays[i].getHybrid_name()%></td>
            <!--<td><%=myArrays[i].getExperiment_name()%></td>-->
            <td><%=myArrays[i].getSubmitter()%><input type="hidden" name="hybrid_id<%=i%>" value="<%=hybridID%>"></td>
        </tr> <%
    }
%>

</table>


<script type="text/javascript">
    $(document).ready(function(){		   
		setupGrantAccessPage();		
		
    });
</script>
   
                    
   
<% 	} else {
		log.debug("confirmGrant is not null");
		int numRows = 0;
                myArrays = (edu.ucdenver.ccp.PhenoGen.data.Array[]) session.getAttribute("myArrays");
                numRows = myArrays.length;
  
                HashMap requests = new HashMap();
  
                ////
                thisGrantee = (User) session.getAttribute("thisGrantee");
		log.debug("thisGrantee = "+thisGrantee);
                requests.put(thisGrantee, new ArrayList());
        
                //
                // the requests HashMaps map a user to a list of arrays
                //
                for (int i=0; i<numRows; i++) {
                	//
                        // checkedValue contains the values of the radio buttons that were
                        // actually selected by the user
                        //
                        String checkedValue = (String) request.getParameter(Integer.toString(i));

                        if (checkedValue != null && !checkedValue.equals("0")) {
                        
                        	edu.ucdenver.ccp.PhenoGen.data.Array thisArray = 
                                        myArray.getArrayFromMyArrays(myArrays, 
                                        Integer.parseInt((String) request.getParameter("hybrid_id" + i)));
                            //
                            // Set the approval to '1' for all arrays
                            //
                            thisArray.setAccess_approval(1);
                        
                            ((List) requests.get(thisGrantee)).add(thisArray);
                        } 
                    }

                    mySessionHandler.createSessionActivity(session.getId(), 
                            "Granted Access to " + ((List) requests.get(thisGrantee)).size() + 
                            " Arrays in experiment " + experimentID + 
//                          " Arrays uploaded by " + submitterUserName + 
                            " to "+ thisGrantee.getFull_name(), (java.sql.Connection)session.getAttribute("dbConn"));

                    // 
                    // For each user, copy the CEL files to his/her directory
                    //
                    Iterator requestsIterator = requests.keySet().iterator();
                    while (requestsIterator.hasNext()) {

                        User thisUser = (User) requestsIterator.next();
			log.debug("thisUser = "+thisUser);
                        //
                        // Perform the following steps:
                        //
                        // 1. Create a thread to copy the files to the user's directory
                        // 2. Create a thread to update the user_chips table and 
                        // send an email to the user
                        // 
			/*************************** STEP 1 ****************************/
                        // 1. Create a thread to copy the raw data files into the user's 
                        // Arrays directory from the experiment directories.
                        //
                        List arrayList = (List) requests.get(thisUser);

                        String arrayDir = myArray.getArrayDataFilesLocation((String) session.getAttribute("userFilesRoot"));
           
                        if (arrayList.size() > 0) {

				/*  As of R2.4 (March 2011), no longer need to copy files
				try {
					thread = new Thread(new AsyncCopyFiles(
						arrayList, 
						(String) session.getAttribute("userFilesRoot"),
						arrayDir));
					thread.start();
				} catch (Throwable t) {
                                	// Error - "Error sending email notification"
                                	session.setAttribute("errorMsg", "CHP-002");
                                	response.sendRedirect((String) session.getAttribute("commonDir") + "errorMsg.jsp");
				}
				*/
				/*************************** STEP 2 ****************************/
                        	// 2. Create a thread to update the user_chips table and 
                        	// send an email to the user.
                        	//
				User thisOwner = myUser.getUser(userId, (java.sql.Connection)session.getAttribute("dbConn"));
				try {
					thread2 = new Thread(new AsyncUpdateUserArrays(
							thisUser, thisOwner, "C", arrayList, 
							//session, true, thread));
							session, true));
                                        thread2.start();
                                	// 
	                                // If thread2 throws an exception, ThreadReturn allows it to be caught
					//
					//  ThreadReturn.join(thread2);
                            	} catch (Throwable t) {
                                	// Error - "Error sending email notification"
                                	session.setAttribute("errorMsg", "CHP-002");
                                	response.sendRedirect((String) session.getAttribute("commonDir") + "errorMsg.jsp");
				}
			}
		}
  
		session.setAttribute("successMsg", "CHP-005");
		response.sendRedirect((String) session.getAttribute("commonDir") + "successMsg.jsp");
	} %>
 <input type="hidden" name = "confirmGrant"/>
 <center>
                <input type="submit" name = "action" value="Submit" />
    </center>

</form>

