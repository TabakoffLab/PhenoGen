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
	log.info("in edit1.  itemId = " + itemID);
	extrasList.add("reviewExperiment.js");

	myOriginalArray = myOriginalArray.getSampleDetailsForHybridID(itemID, dbConn);
	int otherOrganismPartValue = myValidTerm.getSysuid("other", "ORGANISM_PART", dbConn);
	int otherBiosource_typeValue = myValidTerm.getSysuid("other", "SAMPLE_TYPE", dbConn);
	int otherDevStageValue = myValidTerm.getSysuid("other", "DEVELOPMENTAL_STAGE", dbConn);
	String otherOrganismPartDisplay = (myOriginalArray.getTsample_organism_part() == otherOrganismPartValue ? 
							myOriginalArray.getOrganism_part() : ""); 
	String otherBiosource_typeDisplay = (myOriginalArray.getTsample_sample_type() == otherBiosource_typeValue ? 
							myOriginalArray.getBiosource_type() : ""); 
	String otherDevStageDisplay = (myOriginalArray.getTsample_dev_stage() == otherDevStageValue ? 
							myOriginalArray.getDevelopment_stage() : ""); 

	if (userLoggedIn.getUser_name().equals("guest")) {
		//Error - "Can't update guest's information
                session.setAttribute("errorMsg", "GST-001");
                response.sendRedirect(commonDir + "errorMsg.jsp");
	}

	log.debug("before checking action");

        if ((action != null) && action.equals("Update")) {
		log.debug("action is Update");

		myUpdatedArray.setHybrid_id(itemID);
                myUpdatedArray.updateBasicSampleStuff(myUpdatedArray, userLoggedIn, dbConn);

		mySessionHandler.createExperimentActivity("Updated basic sample information for array " + itemID + " called " + myUpdatedArray.getHybrid_name(),
			dbConn);

		//Success - "Array Updated"
		session.setAttribute("successMsg", "EXP-042");
		response.sendRedirect(commonDir + "successMsg.jsp");
        }

%>
<%@ include file="/web/common/includeExtras.jsp" %>

	<form	method="post" 
		action="edit1.jsp" 
		enctype="application/x-www-form-urlencoded" 
		onSubmit="return IsArrayFormComplete(this)"
		name="ArrayUpdate">
	<BR>
        <div class="list_container">
	<table class="list_base" cellpadding="0" cellspacing="10">	
			<tr>
				<td align="right"> <span style="color:red;"> * </span> Hybridization Name  </td>
				<td><input type="text" name="hybrid_name" size="40" maxlength="40" value="<%=myOriginalArray.getHybrid_name()%>"></td>
			</tr>
			<tr>
				<td align="right"> <span style="color:red;"> * </span> Sample Name  </td>
				<td><input type="text" name="sample_name" size="40" maxlength="40" value="<%=myOriginalArray.getSample_name()%>"></td>
			</tr>
			<tr>
				<td align="right"><span style="color:red;"> * </span> Organism</td>
				<td>
					<%
					selectName = "tsample_taxid";
					selectedOption = Integer.toString(myOriginalArray.getTsample_taxid());
					onChange = "";
					style = "";
					optionHash = new Tntxsyn().getValuesAsSelectOptions(dbConn);
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
			<tr>
				<td align="right"><span style="color:red;"> * </span> Sex</td>
				<td>
					<%
					selectName = "tsample_sex";
					selectedOption = Integer.toString(myOriginalArray.getTsample_sex());
					onChange = "";
					style = "";
					optionHash = myValidTerm.getValuesAsSelectOptions("SEX", dbConn);
					// Get rid of all values we don't use
					LinkedHashMap newOptionHash = new LinkedHashMap();
					for (Iterator itr=optionHash.keySet().iterator(); itr.hasNext();) {
						String key = (String) itr.next();
						String value = (String) optionHash.get(key);
						if (value.equals("male") ||
							value.equals("female") ||
							value.equals("not applicable") ||
							value.equals("unknown sex")) {
								log.debug("just kept "+value);
								newOptionHash.put(key, value); 
						}
					}
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
			<tr>
				<td align="right"><span style="color:red;"> * </span> Organism Part</td>
				<td>
					<%
					selectName = "tsample_organism_part";
					selectedOption = Integer.toString(myOriginalArray.getTsample_organism_part());
					onChange = "handleOPField()";
					style = "";
					optionHash = myValidTerm.getValuesAsSelectOptions("ORGANISM_PART", dbConn);
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td>if other, specify:<%=twoSpaces%>
				<input type="text" name="otherOrganismPart" size="30" maxlength="100" value="<%=otherOrganismPartDisplay%>"></td>
			</tr>
			<tr>
				<td align="right"><span style="color:red;"> * </span> Sample Type</td>
				<td>
					<%
					selectName = "tsample_sample_type";
					selectedOption = Integer.toString(myOriginalArray.getTsample_sample_type());
					onChange = "handleSTField()";
					style = "";
					optionHash = myValidTerm.getValuesAsSelectOptions("SAMPLE_TYPE", dbConn);
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td>if other, specify:<%=twoSpaces%>
				<input type="text" name="otherBiosource_type" size="30" maxlength="100" value="<%=otherBiosource_typeDisplay%>"></td>
			</tr>
			<tr>
				<td align="right"><span style="color:red;"> * </span> Development Stage</td>
				<td>
					<%
					selectName = "tsample_dev_stage";
					selectedOption = Integer.toString(myOriginalArray.getTsample_dev_stage());
					onChange = "handleDSField()";
					style = "";
					optionHash = myValidTerm.getValuesAsSelectOptions("DEVELOPMENTAL_STAGE", dbConn);
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td>if other, specify:<%=twoSpaces%>
				<input type="text" name="otherDevStage" size="30" maxlength="100" value="<%=otherDevStageDisplay%>"></td>
			</tr>
			<tr>
				<td align="right"> Minimum Age  </td>
				<td><input type="text" name="age_range_min" size="15" maxlength="15" value="<%=myOriginalArray.getAge_range_min()%>"></td>
			</tr>
			<tr>
				<td align="right"> Maximum Age  </td>
				<td><input type="text" name="age_range_max" size="15" maxlength="15" value="<%=myOriginalArray.getAge_range_max()%>"></td>
			</tr>
			<tr>
				<td align="right"> Age Units</td>
				<td>
					<%
					selectName = "tsample_time_unit";
					selectedOption = Integer.toString(myOriginalArray.getTsample_time_unit());
					onChange = "";
					style = "";
					optionHash = myValidTerm.getValuesAsSelectOptions("TIME_UNIT", dbConn);
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
			<tr>
				<td align="right">Genetic Modification</td>
				<td>
					<%
					selectName = "tsample_genetic_variation";
					selectedOption = Integer.toString(myOriginalArray.getTsample_genetic_variation());
					onChange = "";
					style = "";
					optionHash = myValidTerm.getValuesAsSelectOptions("GENETIC_VARIATION", dbConn);
					%>
					<%@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
			<tr>
				<td align="right"> Individual Identifier  </td>
				<td><input type="text" name="individual_identifier" size="50" maxlength="255" value="<%=myOriginalArray.getIndividual_identifier()%>"></td>
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
	<input type="hidden" name="otherOrganismPartValue" value="<%=otherOrganismPartValue%>">
	<input type="hidden" name="otherBiosource_typeValue" value="<%=otherBiosource_typeValue%>">
	<input type="hidden" name="otherDevStageValue" value="<%=otherDevStageValue%>">
	</form>
        </div> <!-- // end div_list_containter -->
	<div class="closeWindow">Close</div>

<script type="text/javascript">
		handleOtherFields();
</script>
