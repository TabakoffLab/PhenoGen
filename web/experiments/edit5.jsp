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
	log.info("in edit5.  itemId = " + itemID);

	myOriginalArray = myOriginalArray.getSampleDetailsForHybridID(itemID, dbConn);

	if (userLoggedIn.getUser_name().equals("guest")) {
		//Error - "Can't update guest's information
                session.setAttribute("errorMsg", "GST-001");
                response.sendRedirect(commonDir + "errorMsg.jsp");
	}

	log.debug("before checking action");

        if ((action != null) && action.equals("Update")) {
		log.debug("action is Update");

		//log.debug("myUpdateArray protocolID = "+myUpdatedArray.getHybrid_protocol_id());
		//log.debug("myUpdateArray scan protocolID = "+myUpdatedArray.getHybrid_scan_protocol_id());
		myUpdatedArray.setHybrid_id(itemID);
                myUpdatedArray.updateHybridizationStuff(myUpdatedArray, userLoggedIn, dbConn);

		mySessionHandler.createExperimentActivity("Updated hybridization information for  array " + itemID,  
			dbConn);

		//Success - "Array Updated"
		session.setAttribute("successMsg", "EXP-042");
		response.sendRedirect(commonDir + "successMsg.jsp");
        }

%>
	<form	method="post" 
		action="edit6.jsp"
        	enctype="multipart/form-data"
		onSubmit="return IsArrayFormComplete(this)"
		name="ArrayUpdate">
	<BR>
        <div class="list_container">
	<table class="list_base" cellpadding="0" cellspacing="10">	
			<tr>
				<td align="right"> <span style="color:red;"> * </span> Array Design Name  </td>
				<td>
					<%
					selectName = "tarray_designid";
					int designID = (myOriginalArray.getTarray_designid() != -99 ? myOriginalArray.getTarray_designid() : -99);
					log.debug("designid = " + designID); 
					selectedOption = Integer.toString(designID);
					onChange = "";
					style = "";
					optionHash = myArray.getArrayDesignTypes(dbConn);
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
			<tr>
				<td align="right"> <span style="color:red;"> * </span> Hybridization Protocol</td>
				<td>
					<%
					selectName = "hybrid_protocol_id";
					Protocol thisHybridizationProtocol = myProtocol.getProtocol(myOriginalArray.getHybrid_protocol_id(), dbConn);
					int hybridizationGlobid = thisHybridizationProtocol.getGlobid(); 
					String thisHybridizationProtocolID = Integer.toString(hybridizationGlobid != -99 ? 
									hybridizationGlobid :
									thisHybridizationProtocol.getProtocol_id()); 
					selectedOption = thisHybridizationProtocolID;
					onChange = "";
					style = "";
					optionHash = myProtocol.getAsSelectOptions(
							myProtocol.getProtocolByUserAndType(
								userLoggedIn.getUser_name(), "HYBRID_LABORATORY_PROTOCOL", dbConn));
					//log.debug("optionHash = "); myDebugger.print(optionHash);
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
			<tr>
				<td align="right"> <span style="color:red;"> * </span> Scanning Protocol</td>
				<td>
					<%
					selectName = "hybrid_scan_protocol_id";
					Protocol thisScanningProtocol = myProtocol.getProtocol(myOriginalArray.getHybrid_scan_protocol_id(), dbConn);
					int scanGlobid = thisScanningProtocol.getGlobid(); 
					String thisScanningProtocolID = Integer.toString(scanGlobid != -99 ? 
									scanGlobid :
									thisScanningProtocol.getProtocol_id()); 
					selectedOption = thisScanningProtocolID;
					onChange = "";
					style = "";
					optionHash = myProtocol.getAsSelectOptions(
							myProtocol.getProtocolByUserAndType(
								userLoggedIn.getUser_name(), "SCANNING_LABORATORY_PROTOCOL", dbConn));
					//log.debug("optionHash = "); myDebugger.print(optionHash);
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
			<tr>
				<td align="right"> <span style="color:red;"> * </span> File Name</td>
				<td>
				<!-- <input type="text" name="file_name" size="50" maxlength="255" value="<%=myOriginalArray.getFile_name()%>"> -->
				<%=myOriginalArray.getFile_name()%>
				<%=twentySpaces%>
				<input type="file" name="file_name" size="50">
				</td>
			</tr>
		<% //} %>
		<tr><td colspan="100%">&nbsp;</td></tr>
		<tr>
			<td colspan="100%" class="center">
			<input type="reset" value="Reset"><%=tenSpaces%>
			<input type="submit" name="action" value="Update">
			</td>
		</tr>
	</table>
	<input type="hidden" name="itemID" value="<%=itemID%>">
	<input type="hidden" name="hybrid_id" value="<%=myOriginalArray.getHybrid_id()%>">
	</form>
        </div> <!-- // end div_list_containter -->
	<div class="closeWindow">Close</div>

