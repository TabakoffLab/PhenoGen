<%--
 *  Author: Cheryl Hornbaker
 *  Created: Sep, 2006
 *  Description:  The web page created by this file displays the experiments 
 *		that have been assigned an accession number by the MAGE-ML creation
 *		process and transfers the files to Array Express.  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/experiments/include/piHeader.jsp"  %>
<%
	log.info("in sendMAGEML.jsp.  user=" + user);

        log.debug("action = "+action);

	String subordinates = myUser.getSubordinates(userID, dbConn);
	log.debug("subordinates = " + subordinates);

	%><%@ include file="/web/experiments/include/selectExperiment.jsp" %><%

	if (selectedExperiment.getExp_id() != -99 && action.equals("Submit to Array Express")) {

		mySessionHandler.createExperimentActivity(
			"Sent MAGE-ML file for experiment '" + selectedExperiment.getExpName() + "'",
			dbConn);
	
		edu.ucdenver.ccp.PhenoGen.data.Array[] myArrays = myArray.getArraysForSubmission(selectedExperiment.getSubid(), dbConn); 
		log.debug("there are " + myArrays.length + " arrays");

		Thread thread = new Thread(new AsyncSendMAGE(
					selectedExperiment,
					myArrays,
                                	userLoggedIn,
					session));

                log.debug("Starting MAGE thread "+ thread.getName());

                thread.start();

		//Success - "MAGE Process completed"
		session.setAttribute("successMsg", "MGE-001");
		response.sendRedirect(commonDir + "successMsg.jsp");

	} 
	
	formName = "sendMAGEML.jsp";
	String experimentTypes = "mageCompleted";

%>

<%@ include file="/web/common/header.jsp" %>

<%@ include file="/web/experiments/include/formatSelectExperiment.jsp" %>
<%
	if (selectedExperiment.getExp_id() != -99) {
%>
			<form	method="post" 
				action="sendMAGEML.jsp" 
				enctype="application/x-www-form-urlencoded" 
				name="sendMAGEML">

			<BR><BR>
			<input type="hidden" name="experimentID" value="<%=selectedExperiment.getExp_id()%>" />
			<center>
			<input type="submit" name="action" value="Submit to Array Express" />
	
			</center> 
			</form>
<%
	}
	dbConn.close();
%>
	
<%@ 	include file="/web/common/footer.jsp" %>

