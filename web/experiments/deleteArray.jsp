<%--
 *  Author: Cheryl Hornbaker
 *  Created: Apr, 2010
 *  Description:  The web page created by this file allows the user to  
 *  		confirm his/her desire to delete an array from an experiment.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/experiments/include/experimentHeader.jsp"  %>
<%
	log.info("in deleteArray.jsp. user = " + user + ", itemID= "+itemID);

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-005");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }

	if (action != null && action.equals("Delete Array")) {
        	try {
	 		log.debug("deleteing array = "+itemID);

        		mySessionHandler.createExperimentActivity("Deleted arrray # " + itemID, dbConn);

			new Hybridization(itemID).deleteHybridization(dbConn);

			//Success - "Hybridization deleted"
			session.setAttribute("successMsg", "EXP-051");
			response.sendRedirect(commonDir + "successMsg.jsp");
        	} catch( Exception e ) {
            		throw e;
        	}
	}
%>
        <form   method="post" 
                action="deleteArray.jsp" 
                enctype="application/x-www-form-urlencoded"
                name="deleteArray">

                <BR> <BR>
                <center> <input type="submit" name="action" value="Delete Array" onClick="return confirmDelete()"></center>
                <input type="hidden" name="itemID" value="<%=itemID%>">
                <input type="hidden" name="experimentID" value="<%=selectedExperiment.getExp_id()%>">
        </form>
	</div>

