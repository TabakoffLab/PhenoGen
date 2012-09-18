<%--
 *  Author: Cheryl Hornbaker
 *  Created: Jan, 2010
 *  Description:  The web page created by this file allows the user to create an 
 *		experiment definition.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/experiments/include/experimentHeader.jsp"%>

<%
	log.info("in createExperiment.jsp. user = " + user);

	request.setAttribute( "selectedStep", "0" ); 
	extrasList.add("createExperiment.js");
	optionsList.add("chooseNewExperiment");
	optionsList.add("analyze");
	int otherFactorValue = myValidTerm.getSysuid("other", "EXPERIMENTAL_FACTOR", dbConn);
	int otherTypeValue = myValidTerm.getSysuid("other", "EXPERIMENT_TYPE", dbConn);
	log.debug("otherfactorvalue = "+otherFactorValue);
	log.debug("othertypevalue = "+otherTypeValue);

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-004");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }


        fieldNames.add("experimentName");
        fieldNames.add("description");
        fieldNames.add("otherType");
        fieldNames.add("otherFactor");
        multipleFieldNames.add("designTypes");
        multipleFieldNames.add("factors");
        //fieldNames.add("dateForRelease");
        //fieldNames.add("publicationStatus");

        %><%@ include file="/web/common/getFieldValues.jsp" %><%

/*
	String publicationStatus = (fieldValues.get("publicationStatus") != null &&
					!((String) fieldValues.get("publicationStatus")).equals("") ? 
					(String) fieldValues.get("publicationStatus") : 
					Integer.toString(myValidTerm.getDefaultPublicationStatus(dbConn)));

	log.debug("publicationStatus = "+publicationStatus);
*/
	Set<Integer> myFactors = null;
	Set<Integer> myTypes = null;
	String expName = (String) fieldValues.get("experimentName");
	log.debug("here expName = "+expName);
	String descr = (String) fieldValues.get("description");

	String otherFactorDisplay = "";
	String otherTypeDisplay = "";
	// If an experimentID is passed in, it's because the user wants to edit an existing experiment
	int expID = (request.getParameter("expID") != null ? Integer.parseInt((String) request.getParameter("expID")) : -99);
	log.debug("expID = "+expID);

	if (expID != -99) {
		int experimentID = expID;
		%><%@ include file="/web/experiments/include/setupExperiment.jsp"%><%
		Texpfctr[] myExprFactors = new Texpfctr().getAllTexpfctrForExp(expID, dbConn);
		myFactors = myObjectHandler.getAsSet(myExprFactors, "Texpfctr_id");
		for (int i=0; i<myExprFactors.length; i++) {
			if (myExprFactors[i].getTexpfctr_id() == otherFactorValue) {
				otherFactorDisplay = myExprFactors[i].getFactorName();				
			}
		}
		Texprtyp[] myExprTypes = new Texprtyp().getAllTexprtypForExp(expID, dbConn);
		log.debug("myExprTypes length = "+myExprTypes.length);
		myTypes = myObjectHandler.getAsSet(myExprTypes, "Texprtyp_id");
		log.debug("myTypes length = "+myTypes.size());
		for (int i=0; i<myExprTypes.length; i++) {
			if (myExprTypes[i].getTexprtyp_id() == otherTypeValue) {
				otherTypeDisplay = myExprTypes[i].getTypeName();				
			}
		}
		expName = selectedExperiment.getExpName();
		descr = selectedExperiment.getExp_description();
		mySessionHandler.createExperimentActivity(session.getId(), experimentID, "Re-defining this experiment", dbConn);
	} else {
		session.removeAttribute("selectedExperiment");
		mySessionHandler.createSessionActivity(session.getId(), "Defining a new experiment", dbConn);
	}
	if (action != null && action.equals("Next >")) {
		if (expID != -99) {
			// deleting existing version of experiment
			selectedExperiment.deleteExperiment(dbConn);
		}
		// record exists if != -99 
		if (myExperiment.checkRecordExists(userLoggedIn, (String) fieldValues.get("experimentName"), dbConn) == -99) {
			log.debug("record does not exist, so creating a new one");
			int experimentID = myExperiment.createExperiment(userLoggedIn, fieldValues, multipleFieldValues, dbConn);
			log.debug("new experient id = "+experimentID);
			%><%@ include file="/web/experiments/include/setupExperiment.jsp"%><%
			log.debug("in createExperiment now = "+selectedExperiment.getExp_id());
	       		mySessionHandler.createExperimentActivity(session.getId(), experimentID, "Just created new experiment", dbConn);
                	response.sendRedirect(experimentsDir + "chooseProtocols.jsp?experimentID=" + experimentID);
		} else {
			log.debug("record already existed?");
			expName = selectedExperiment.getExpName();
			descr = selectedExperiment.getExp_description();
	       		mySessionHandler.createExperimentActivity("Experiment already existed", dbConn);
                	session.setAttribute("errorMsg", "EXP-048");
                	response.sendRedirect(commonDir + "errorMsg.jsp");
		}
	}

	String checks = "return IsEnterExperimentFormComplete()" + (expID != -99 ? " && AreYouSureToContinue(this)" : ""); 
%>
	
	<%@ include file="/web/common/microarrayHeader.jsp" %>

        <!-- use javascript to fill up the client-side array with permitted combinations of design types and factors -->
        <%@ include file="/web/experiments/include/fillCombos.jsp" %>

    	<script type="text/javascript">
        	var crumbs = ["Home", "Analyze Microarray Data", "Upload Data"]; 
    	</script>
	<%@ include file="/web/experiments/include/viewingPane.jsp" %>
	<%@ include file="/web/experiments/include/uploadSteps.jsp" %>
	<div class="brClear"></div>

	<div class="page-intro">
		<% if (expID != -99) { %>
        		<p> This experiment already exists, so any changes you make here will invalidate the experiment as it is currently entered.  The 
			experiment will instead be defined with the new design types and factors.  
			You will need to download a new spreadsheet, define your arrays using the new factors, upload it, and finalize your submission. </p>
		<% } else { %>
        		<p> Enter the name and a description of your experiment: </p>
		<% } %>
		<BR>Fields marked with <span style='color:red; font-weight:bold; font-size:14pt'>* </span>  are required.  
	</div>
	<div class="brClear"></div>
	<form   name="createExperiment" 
        	method="post" 
        	onSubmit="<%=checks%>"
        	action="createExperiment.jsp" 
		enctype="application/x-www-form-urlencoded">

                <table class="basic" style="margin-left:40px" cellpadding="0" cellspacing="3">
			<tr>
				<td valign="top"> <strong> <span style='color:red;'> * </span> Experiment Name:</strong> </td>
				<td> <input type="text" name="experimentName" size="80" value="<%=expName%>"> </td>
			</tr> <tr>
				<td colspan="100%">&nbsp;</td>
			</tr> <tr>
				<td valign="top"> <strong> <span style='color:red;'> * </span> Experiment Description:</strong> </td>
				<td> <textarea name="description" cols="60" rows="5"><%=descr%></textarea> </td>
			</tr> 
		<!-- 
			<tr> <td colspan="100%">&nbsp;</td> </tr>
			<tr>
				<td> <strong>Date For Public Release:</strong> </td>
				<td><input type="text" id="datepicker" name="dateForRelease"></td>
			</tr> <tr> <td colspan="100%">&nbsp;</td>
			</tr> <tr> <td colspan="100%"><hr></td>
			</tr> <tr> <td colspan="100%"><h2>Publication Information</h2></td>
			</tr> <tr>
				<td> <strong>Publication Status:</strong> </td>
				<td>
				<%
				/*
				selectName = "publicationStatus";
				selectedOption = publicationStatus;
				onChange = "";

				optionHash = new LinkedHashMap();
				optionHash.putAll(new ValidTerm().getValuesAsSelectOptions("PUBLICATION_STATUS", dbConn));
				*/
				%>
                		<% //@ include file="/web/common/selectBox.jsp" %>
				</td>
			</tr>
		-->
		</table>
	<div class="page-intro">
        	<p> Choose one or more design types and experimental factors:
		</p>
	</div>
	<div style="width:900px;">
		<div style="padding:0px 0px 0px 20px;float:left;">
		<div class="title"> <span style='color:red;'> * </span> Experiment Design Types: </div>
		<div style="height:300px;overflow:auto; margin-left:40px;">
                <table id="designTypes" name="Design Types" class="list_base tablesorter" cellpadding="0" cellspacing="3">
                        <thead>
                        <tr class="col_title">
                                <th>Select</th>
                                <th>Design Type</th>
                                <th>Description</th>
                        </tr>
                        </thead>
                        <tbody>
			<%
                	ValidTerm[] designTypes = myValidTerm.getFromValidTerm("EXPERIMENT_TYPE", dbConn);
			if (designTypes != null && designTypes.length > 0) {
				log.debug("designTypes.length = "+designTypes.length);
				for (int i=0; i<designTypes.length; i++) {
					ValidTerm thisType = designTypes[i];
					//log.debug("thisType = "+thisType + ", term_id = "+thisType.getTerm_id());
					String checked = (expID != -99 && myTypes.contains(new Integer(thisType.getTerm_id())) ? " checked " : "");
					if (!thisType.getValue().equals("other")) {
						%>
                                		<tr id="<%=thisType.getTerm_id()%>" descr="<%=thisType.getDescription()%>">
                                        		<td><input type="checkbox" name="designTypes" <%=checked%> value="<%=thisType.getTerm_id()%>"></td>
                                        		<td class="left"><%=thisType.getValue()%></td>
                                        		<td class="details">View</td>
                                		</tr>
                                		<%
					}
                        	}
                	}
		%>
		</table>
		</div> 
		<BR>
		<div style="margin-left:40px;">
                <table class="list_base tablesorter" cellpadding="0" cellspacing="3">
			<tr>
				<td>if other, specify:<%=twoSpaces%>
				<input type="text" name="otherType" size="42" maxlength="100" value="<%=otherTypeDisplay%>"></td>
			</tr>
		</table>
		</div>
		</div>
		<div style="padding:0px 0px 0px 80px;float:left;">
		<div class="title"> <span style='color:red;'> * </span> Experimental Factors: </div>
		<div style="height:280px; overflow:auto;">
                <table id="factors" name="Factors" class="list_base tablesorter" cellpadding="0" cellspacing="3" >
                        <thead>
                        <tr class="col_title">
                                <th>Select</th>
                                <th>Factor</th>
                                <th>Description</th>
                        </tr>
                        </thead>
                        <tbody>
			<%
                	ValidTerm[] factors = myValidTerm.getFromValidTerm("EXPERIMENTAL_FACTOR", dbConn);
			if (factors.length > 0) {
				for (int i=0; i<factors.length; i++) {
					ValidTerm thisFactor = factors[i];
					String checked = (expID != -99 && myFactors.contains(new Integer(thisFactor.getTerm_id())) ? " checked " : "");
					if (!thisFactor.getValue().equals("other")) {
						%>
                                		<tr id="<%=thisFactor.getTerm_id()%>" descr="<%=thisFactor.getDescription()%>">
                                        		<td><input type="checkbox" name="factors" <%=checked%> value="<%=thisFactor.getTerm_id()%>"></td>
                                        		<td class="left"><%=thisFactor.getValue()%></td>
                                        		<td class="details">View</td>
                                		</tr>
                                		<%
					}
                        	}
                	}
		%>
		</table>
		</div>
                <table class="list_base tablesorter" cellpadding="0" cellspacing="3">
			<tr>
				<td>if other, specify:<%=twoSpaces%>
				<input type="text" name="otherFactor" size="25" maxlength="100" value="<%=otherFactorDisplay%>"></td>
			</tr>
		</table>
		</div>

	<div class="brClear" style="padding-top:20px"></div>
		<div class="right">
			<% if (expID != -99) { %>
        			<span class="info" title="Erase previous instance of experiment and continue with new definition.">
			<% } else { %>
        			<span class="info" title="Save and continue">
			<% } %>
                        	<%@ include file="/web/common/nextButton.jsp" %>
			</span>
		</div>
		<div style="padding:20px"></div>
	</div> <!-- experimentForm -->

	<div style="margin:20px" class="itemDetails"></div>

	<input type="hidden" name="expID" value="<%=expID%>">
<!-- only need these for javascript, right 
	<input type="hidden" name="otherFactorValue" value="<%=otherFactorValue%>">
	<input type="hidden" name="otherTypeValue" value="<%=otherTypeValue%>">
-->
	</form>

	<%@ include file="/web/common/footer.jsp" %>
	<script type="text/javascript">
		$(document).ready(function() {
			$("#datepicker").datepicker();
			setupPage();
		});
	</script> 
