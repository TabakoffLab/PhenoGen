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
<jsp:useBean id="myUpdatedArray" class="edu.ucdenver.ccp.PhenoGen.data.Array">
	<jsp:setProperty name="myUpdatedArray" property="*" />
</jsp:useBean>


<%
	log.info("in edit2.  itemId = " + itemID);

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
                myUpdatedArray.updateAdditionalSampleStuff(myUpdatedArray, userLoggedIn, dbConn);

		mySessionHandler.createExperimentActivity("Updated additional sample information for array " + itemID + " called " + myUpdatedArray.getHybrid_name(),
			dbConn);

		//Success - "Array Updated"
		session.setAttribute("successMsg", "EXP-042");
		response.sendRedirect(commonDir + "successMsg.jsp");
        }

%>
<%@ include file="/web/common/includeExtras.jsp" %>

	<form	method="post" 
		action="edit2.jsp" 
		enctype="application/x-www-form-urlencoded" 
		onSubmit="return IsArrayFormComplete(this)"
		name="ArrayUpdate">
	<BR>
        <div class="list_container">
	<table class="list_base" cellpadding="0" cellspacing="10">	
			<tr>
				<td align="right"> Genotype </td>
				<td>
					<%
					selectName = "individual_genotype";
					String selectedGenotype = myOriginalArray.getIndividual_genotype();
					selectedOption = (selectedGenotype.equals("--") ? "None" : selectedGenotype);
					onChange = "";
					style = "";
					optionHash = myArray.getAsSelectOptions(myArray.getGenotypes("All", "Single", dbConn));
					optionHash.put("None", "None");
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
			<tr>
				<td align="right"> Selected Line </td>
				<td>
					<%
					selectName = "cell_line";
					String selectedLine = myOriginalArray.getCell_line();
					selectedOption = (selectedLine.equals("--") ? "None" : selectedLine);
					onChange = "";
					style = "";
					optionHash = myArray.getAsSelectOptions(myArray.getCellLines("All", "Single", dbConn));
					optionHash.put("None", "None");
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
			<tr>
				<td align="right">Strain </td>
				<td>
					<%
					selectName = "strain";
					String selectedStrain = myOriginalArray.getStrain();
					selectedOption = (selectedStrain.equals("--") ? "None" : selectedStrain);
					onChange = "";
					style = "";
					optionHash = myArray.getAsSelectOptions(myArray.getStrains("All", "Single", dbConn)); 
					optionHash.put("None", "None");
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
			<tr>
				<td align="right"> Cell Type  </td>
				<td><input type="text" name="target_cell_type" size="50" maxlength="255" value="<%=myOriginalArray.getTarget_cell_type()%>"></td>
			</tr>
			<tr>
				<td align="right"> Disease State  </td>
				<td><input type="text" name="disease_state" size="50" maxlength="255" value="<%=myOriginalArray.getDisease_state()%>"></td>
			</tr>
			<tr>
				<td align="right"> Additional Clinical Information </td>
				<td><input type="text" name="additional" size="50" maxlength="255" value="<%=myOriginalArray.getAdditional()%>"></td>
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

