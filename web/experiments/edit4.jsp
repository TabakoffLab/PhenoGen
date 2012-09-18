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
	log.info("in edit4.  itemId = " + itemID);

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
                myUpdatedArray.updateProtocolStuff(myUpdatedArray, userLoggedIn, dbConn);

		mySessionHandler.createExperimentActivity("Updated protocol information for array " + itemID + " called " + myUpdatedArray.getHybrid_name(),
			dbConn);

		//Success - "Array Updated"
		session.setAttribute("successMsg", "EXP-042");
		response.sendRedirect(commonDir + "successMsg.jsp");
        }

%>
<%@ include file="/web/common/includeExtras.jsp" %>

	<form	method="post" 
		action="edit4.jsp" 
		enctype="application/x-www-form-urlencoded" 
		onSubmit="return IsArrayFormComplete(this)"
		name="ArrayUpdate">
	<BR>
        <div class="list_container">
	<table class="list_base" cellpadding="0" cellspacing="10">	
			<tr>
				<td align="right">Growth Protocol</td>
				<td>
					<%
					selectName = "tsample_growth_protocolid";
					String thisGrowthProtocolID = Integer.toString(myOriginalArray.getTsample_growth_protocolid());
					selectedOption = (thisGrowthProtocolID.equals("") || 
								thisGrowthProtocolID.equals("--") ? 
								"0" : thisGrowthProtocolID);
					onChange = "";
					style = "";
					optionHash = myProtocol.getAsSelectOptions(
								myProtocol.getProtocolByUserAndType(
									userLoggedIn.getUser_name(), "SAMPLE_GROWTH_PROTOCOL", dbConn));
					optionHash.put("0", "None");
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
			<tr>
				<td align="right"> <span style="color:red;"> * </span> Extract Name  </td>
				<td><input type="text" name="textract_id" size="40" maxlength="40" value="<%=myOriginalArray.getTextract_id()%>"></td>
			</tr>
			<tr>
				<td align="right"> <span style="color:red;"> * </span> Extract Protocol  </td>
				<td>
					<%
					selectName = "textract_protocolid";
					Protocol thisExtractProtocol = myProtocol.getProtocol(myOriginalArray.getTextract_protocolid(), dbConn);
					int extractGlobid = thisExtractProtocol.getGlobid(); 
					String thisExtractProtocolID = Integer.toString(extractGlobid != -99 ? 
									extractGlobid :
									thisExtractProtocol.getProtocol_id()); 
					selectedOption = thisExtractProtocolID;
					onChange = "";
					style = "";
					optionHash = myProtocol.getAsSelectOptions(
								myProtocol.getProtocolByUserAndType(
									userLoggedIn.getUser_name(), "EXTRACT_LABORATORY_PROTOCOL", dbConn));
					//log.debug("optionHash = "); myDebugger.print(optionHash);
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
			<tr>
				<td align="right"> <span style="color:red;"> * </span> Labeled Extract Name  </td>
				<td><input type="text" name="tlabel_id" size="40" maxlength="40" value="<%=myOriginalArray.getTlabel_id()%>"></td>
			</tr>
			<tr>
				<td align="right"> <span style="color:red;"> * </span> Labeled Extract Protocol  </td>
				<td>
					<%
					selectName = "tlabel_protocolid";
					Protocol thisLabelProtocol = myProtocol.getProtocol(myOriginalArray.getTlabel_protocolid(), dbConn);
					int labelGlobid = thisLabelProtocol.getGlobid(); 
					String thisLabelProtocolID = Integer.toString(labelGlobid != -99 ? 
									labelGlobid :
									thisLabelProtocol.getProtocol_id()); 
					selectedOption = thisLabelProtocolID;
					onChange = "";
					style = "";
					optionHash = myProtocol.getAsSelectOptions(
								myProtocol.getProtocolByUserAndType(
									userLoggedIn.getUser_name(), "LABEL_LABORATORY_PROTOCOL", dbConn));
					//log.debug("optionHash = "); myDebugger.print(optionHash);
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
	<input type="hidden" name="textract_sysuid" value="<%=myOriginalArray.getTextract_sysuid()%>">
	<input type="hidden" name="tlabel_sysuid" value="<%=myOriginalArray.getTlabel_sysuid()%>">
	<input type="hidden" name="hybrid_id" value="<%=myOriginalArray.getHybrid_id()%>">
	</form>
        </div> <!-- // end div_list_containter -->
	<div class="closeWindow">Close</div>

