<%--
 *  Author: Cheryl Hornbaker
 *  Created: Feb, 2010
 *  Description:  The web page created by this file accepts the values for the user's protocol information.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/experiments/include/experimentHeader.jsp"  %>

<jsp:useBean id="myProtocol" class="edu.ucdenver.ccp.PhenoGen.data.Protocol"> </jsp:useBean>

<%
	log.debug("in createProtocol.jsp. user = " + user + ", action = "+action); 

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-004");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }

	extrasList.add("chooseProtocols.js");

        fieldNames.add("protocolType");         
        fieldNames.add("protocolName");         
        fieldNames.add("description");         

        %><%@ include file="/web/common/getFieldValues.jsp" %><%

	String displayedType = "";
	String protocolType = ((String) fieldValues.get("protocolType"));

	if (protocolType.equals("SAMPLE_GROWTH_PROTOCOL")) {
		displayedType = "New Sample Growth Conditions Protocol";
	} else if (protocolType.equals("SAMPLE_LABORATORY_PROTOCOL")) {
		displayedType = "New Sample Treatment Protocol";
	} else if (protocolType.equals("EXTRACT_LABORATORY_PROTOCOL")) {
		displayedType = "New Extraction Protocol";
	} else if (protocolType.equals("LABEL_LABORATORY_PROTOCOL")) {
		displayedType = "New Labeling Protocol";
	} else if (protocolType.equals("HYBRID_LABORATORY_PROTOCOL")) {
		displayedType = "New Hybridization Protocol";
	} else if (protocolType.equals("SCANNING_LABORATORY_PROTOCOL")) {
		displayedType = "New Scanning Protocol";
	}

	log.debug("protocolType = "+protocolType);

	if (action != null && action.equals("Save Protocol")) {
		log.debug("saving a new protocol");

		myProtocol.createProtocol(userLoggedIn, fieldValues, dbConn);
		mySessionHandler.createExperimentActivity("Created new protocol", dbConn); 
		session.setAttribute("successMsg", "EXP-036");
                response.sendRedirect(experimentsDir + "chooseProtocols.jsp");
	} 

%>

<%@ include file="/web/common/includeExtras.jsp" %>

	<div class="experimentForm">

	<form   name="createProtocol"
		method="post"
		onSubmit="return IsCreateProtocolFormComplete()"
                action="createProtocol.jsp"
		enctype="application/x-www-form-urlencoded">

		<center><h2><%=displayedType%></h2></center>
		<BR>
		<table class="list_base" id="createProtocol">
               		<tr>
                		<td><strong>Protocol Name:</strong></td>
			</tr> <tr>
                        	<td><input type="text" name="protocolName" size="30" maxlength="2000"></td>
			</tr> <tr>
                		<td><strong>Protocol Description:</strong></td>
			</tr> <tr>
                        	<td><textarea name="description" rows="3" cols="30"></textarea></td>
			</tr> 
		</table>

		<BR><BR>
		<center><input type=submit id="action" name="action" value="Save Protocol"></center>
		<input type="hidden" name="protocolType" value="<%=protocolType%>"></center>

        </form>
	</div>

	<script type="text/javascript">
		$(document).ready(function() {
		});
	</script> 
