<%--
 *  Author: Cheryl Hornbaker
 *  Created: Mar, 2006
 *  Description:  The web page created by this file displays the experiments uploaded by the subordinates of 
 *		the user logged in and allows the user to create a MAGE-ML file for transfer to Array Express.  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/experiments/include/piHeader.jsp"  %>
<%
	log.info("in createMAGEML.jsp.  user=" + user);

        log.debug("action = "+action);

	%><%@ include file="/web/experiments/include/selectExperiment.jsp" %><%

	String subordinates = myUser.getSubordinates(userID, dbConn);
	log.debug("subordinates = " + subordinates);

	if (selectedExperiment.getExp_id() != -99 && action.equals("Create MAGE-ML File")) {

		mySessionHandler.createExperimentActivity(
			"Created MAGE-ML file for experiment '" + selectedExperiment.getExpName() + "'",
			dbConn);
	
		if (!myFileHandler.createDir(userLoggedIn.getUserExperimentDir() + 
				selectedExperiment.getExpNameNoSpaces() + "/")) {
			log.debug("error creating experiment directory in createMAGEML"); 
					
			mySessionHandler.createExperimentActivity(
				"got error creating experiment directory in createMAGEML for " +
				selectedExperiment.getExpName(),
				dbConn);
			session.setAttribute("errorMsg", "SYS-001");
                        response.sendRedirect(commonDir + "errorMsg.jsp");
		} else {
			log.debug("no problems creating experiment directory in createMAGEML"); 

			Thread thread = new Thread(new AsyncCreateMAGE(session));

                	log.debug("Starting MAGE thread "+ thread.getName());

                	thread.start();

			//Success - "MAGE file created"
			session.setAttribute("successMsg", "MGE-002");
			response.sendRedirect(commonDir + "successMsg.jsp");
		}

	} 
	
	formName = "createMAGEML.jsp";
	String experimentTypes = "uploadedBySubordinates";

%>

<%@ include file="/web/common/header.jsp" %>

<%@ include file="/web/experiments/include/formatSelectExperiment.jsp" %>
<%
	if (selectedExperiment.getExp_id() != -99) {
%>
			<form	method="post" 
				action="createMAGEML.jsp" 
				enctype="application/x-www-form-urlencoded" 
				name="createMAGEML">

			<BR><BR>
			<center>
			<input type="hidden" name="experimentID" value="<%=selectedExperiment.getExp_id()%>" />
			<input type="submit" name="action" value="Create MAGE-ML File" />
	
			</center> 
			</form>
<%
	}
	dbConn.close();
%>
	
<%@ 	include file="/web/common/footer.jsp" %>

