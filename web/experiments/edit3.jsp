<%--
 *  Author: Cheryl Hornbaker
 *  Created: Mar, 2010
 *  Description:  The web page created by this file allows a user to update an array record
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/experiments/include/experimentHeader.jsp"  %>

<jsp:useBean id="myOriginalArray" class="edu.ucdenver.ccp.PhenoGen.data.Array"> </jsp:useBean>
<jsp:useBean id="myProtocol" class="edu.ucdenver.ccp.PhenoGen.data.Protocol"> </jsp:useBean>
<jsp:useBean id="myUpdatedArray" class="edu.ucdenver.ccp.PhenoGen.data.Array">
	<jsp:setProperty name="myUpdatedArray" property="*" />
</jsp:useBean>


<%
	log.info("in edit3.  itemId = " + itemID);

	myOriginalArray = myOriginalArray.getSampleDetailsForHybridID(itemID, dbConn);

	if (userLoggedIn.getUser_name().equals("guest")) {
		//Error - "Can't update guest's information
                session.setAttribute("errorMsg", "GST-001");
                response.sendRedirect(commonDir + "errorMsg.jsp");
	}

	log.debug("before checking action");

        if ((action != null) && action.equals("Update")) {
		log.debug("action is Update");

		myUpdatedArray.setHybrid_id(itemID);
                myUpdatedArray.updateTreatmentStuff(myUpdatedArray, userLoggedIn, dbConn);

		mySessionHandler.createExperimentActivity("Updated treatment information for array " + itemID + " called " + myUpdatedArray.getHybrid_name(),
			dbConn);

		//Success - "Array Updated"
		session.setAttribute("successMsg", "EXP-042");
		response.sendRedirect(commonDir + "successMsg.jsp");
        }

%>
<%@ include file="/web/common/includeExtras.jsp" %>

	<form	method="post" 
		action="edit3.jsp" 
		enctype="application/x-www-form-urlencoded" 
		onSubmit="return IsArrayFormComplete(this)"
		name="ArrayUpdate">
	<BR>
        <div class="list_container">
	<table class="list_base" cellpadding="0" cellspacing="10">	
			<tr>
				<td align="right">Compound </td>
				<td>
					<%
					selectName = "compound";
					String compound = myOriginalArray.getCompound();
					selectedOption = (compound.equals("--") ? "None" : compound);
					onChange = "";
					style = "";
					optionHash = myArray.getAsSelectOptions(myArray.getCompounds("All", "Single", dbConn));
					optionHash.put("None", "None");
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
			<tr>
				<td align="right">Dose </td>
				<td>
					<%
					selectName = "dose";
					String dose = myOriginalArray.getDose();
					selectedOption = (dose.equals("--") ? "None" : dose);
					onChange = "";
					style = "";
					optionHash = myArray.getAsSelectOptions(myArray.getDoses("All", "Single", dbConn));
					optionHash.put("None", "None");
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
			<tr>
				<td align="right">Treatment </td>
				<td>
					<%
					selectName = "treatment";
					selectedOption = myOriginalArray.getTreatment();
					onChange = "";
					style = "";
					optionHash = myArray.getAsSelectOptions(myArray.getTreatments("All", "Single", dbConn));
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
			<tr>
				<td align="right">Duration </td>
				<td>
					<%
					selectName = "duration";
					String duration = myOriginalArray.getDuration();
					selectedOption = (duration.equals("--") ? "None" : duration);
					onChange = "";
					style = "";
					optionHash = myArray.getAsSelectOptions(myArray.getDurations("All", "Single", dbConn));
					optionHash.put("None", "None");
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
			<tr>
				<td align="right">Sample Treatment Protocol</td>
				<td>
					<%
					selectName = "tsample_protocolid";
					String thisTreatmentProtocolID = Integer.toString(myOriginalArray.getTsample_protocolid());
					selectedOption = (thisTreatmentProtocolID.equals("") || 
								thisTreatmentProtocolID.equals("--") ? 
								"0" : thisTreatmentProtocolID);
					onChange = "";
					style = "";
					optionHash = myProtocol.getAsSelectOptions(
							myProtocol.getProtocolByUserAndType(
								userLoggedIn.getUser_name(), "SAMPLE_LABORATORY_PROTOCOL", dbConn));
					optionHash.put("0", "None");
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
		<tr><td colspan="100%">&nbsp;</td></tr>
		<tr>
			<td colspan="100%" class="center">
			<input type="reset" value="Reset"><%=tenSpaces%>
			<input type="submit" name="action" value="Update">
			</td>
		</tr>
	</table>
	<input type="hidden" name="itemID" value="<%=itemID%>">
	<input type="hidden" name="tsample_sysuid" value="<%=myOriginalArray.getTsample_sysuid()%>">
	<input type="hidden" name="hybrid_id" value="<%=myOriginalArray.getHybrid_id()%>">
	</form>
        </div> <!-- // end div_list_containter -->
	<div class="closeWindow">Close</div>

