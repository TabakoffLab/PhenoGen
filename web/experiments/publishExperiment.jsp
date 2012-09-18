<%--
 *  Author: Cheryl Hornbaker
 *  Created: Jan, 2007
 *  Description:  The web page created by this file displays the experiments uploaded by the subordinates of 
 *      the user logged in and allows the user to make the arrays available to anybody registered on the website.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/experiments/include/piHeader.jsp"  %>
<%
	log.info("in publishExperiment.jsp.  user=" + user);

	log.debug("action = "+action);
        
	extrasList.add("publishExperiment.js"); 
	extrasList.add("chooseUser.js");
	extrasList.add("grantArrayAccess.js");

	formName = "publishExperiment.jsp";
	String userImage =  imagesDir + "/icons/user.png";
	String publicImage =  imagesDir + "/icons/public.png";

	Experiment[] myExperiments = null;
	String experimentTypes = "uploadedBySubordinatesNotPublic";
	String subordinates = myUser.getSubordinates(userID, dbConn);

	if (experimentTypes.equals("uploadedBySubordinates")) {
		myExperiments = myArray.getExperimentsUploadedBySubordinates(subordinates, "All", dbConn);
	} else if (experimentTypes.equals("uploadedBySubordinatesNotPublic")) {
		myExperiments = myArray.getExperimentsUploadedBySubordinatesNotPublic(subordinates, "All", dbConn);
	} else if (experimentTypes.equals("mageCompleted")) {
		myExperiments = myArray.getExperimentsUploadedBySubordinates(subordinates, "Y", dbConn);
	}

	//adding the logged-in user as part of the subordinates
	subordinates = subordinates.replace(")" , ",'"+userName+"')" );;
	
	String experimentID   = (String) request.getParameter("experimentID");

	if (experimentID != null ) {
   
		myArray.createPublicExperiment(Integer.parseInt(experimentID), dbConn);

        	mySessionHandler.createExperimentActivity(
            	"Made arrays available to registered users for experiment '" + 
            	selectedExperiment.getExpName() + "'",
            	dbConn);
    
        	//Success - "Arrays available"
        	session.setAttribute("successMsg", "CHP-008");
        	response.sendRedirect(commonDir + "successMsg.jsp");
	} 
    
%>


<%@ include file="/web/common/header.jsp" %>

<div class="page-intro">

	<p>
	Click on <img src="<%= userImage %>" width="20" height="20" /> to choose an individual for granting array access or <br/>
	Click on <img src="<%= publicImage %>" width="30" height="30" />  to grant open access to a set of arrays.
	</p>
    </div>
	
<div class="brClear"></div>
                                                                                                                  
<%
%>

<BR>
    <form   method="post"
            action="<%=formName%>"
            enctype="application/x-www-form-urlencoded"
            name="selectExperiment">

    <% if (myExperiments.length > 0 ) { %>
<table name="items" class="list_base tablesorter" id="items">
    <thead>
      <tr class="col_title">    
         <th> Experiment Name</th>
         <th> Date Created </th>
         <th class="noSort"> Experiment Details </th>
         <th class="noSort"> Grant to Individual </th>
         <th class="noSort"> Grant to Public </th>
      </tr>
    </thead>
      
       <% for (int i=0; i<myExperiments.length; i++) { %>
        <tr id="<%= myExperiments[i].getExp_id() %>">
            <td class="experimentName"><%= myExperiments[i].getExpName() %></td>
            <td><%= myExperiments[i].getExp_create_date_as_string() %></td>
            <td class="details"><center>View</center></td>
            <td class="chooseUser"><center><img src="<%= userImage %>" width="20" height="20" /></center></td>
            <td class="grantToPublic"><center><img src="<%= publicImage %>" width="30" height="30" /></center></td>
        </tr>      
       <%}%>
    <%} else { %>
        <div class="page-intro">
          <p>No Experiments available</p>
        </div>
          <div class="brClear"></div>
    <%}%>
    
</table>
    


</form>
  <div class="itemDetails"></div>
  <div class="chooseUserDetails"></div>
  <div class="confirmGrantAccessToPublic"></div>
  
<%@     include file="/web/common/footer.jsp" %>

<script type="text/javascript">
	$(document).ready(function() {
		setupPage();
		setupChooseUserPage();    
		setTimeout("setupMain()", 100); 
	});
</script>
