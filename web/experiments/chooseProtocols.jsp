<%--
 *  Author: Cheryl Hornbaker
 *  Created: Jan, 2010
 *  Description:  The web page created by this file allows the user to select the protocols used 
 *		in an experiment definition.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/experiments/include/experimentHeader.jsp"%>

<jsp:useBean id="myProtocol" class="edu.ucdenver.ccp.PhenoGen.data.Protocol"> </jsp:useBean>
<jsp:useBean id="myExperiment_protocol" class="edu.ucdenver.ccp.PhenoGen.data.Experiment_protocol"> </jsp:useBean>

<%
	log.info("in chooseProtocols.jsp. user = " + user);
	request.setAttribute( "selectedStep", "1" ); 

	extrasList.add("chooseProtocols.js");
	optionsList.add("experimentDetails");
	optionsList.add("chooseNewExperiment");

	String title, newProtocol, tableID, protocolType = "";
	Protocol[] myProtocols = null; 
	Protocol[] myPublicProtocols = null; 
	Protocol[] theseProtocols = null; 
	Experiment_protocol[] chosenProtocols = myExperiment_protocol.getExperiment_protocolsForExperiment(selectedExperiment.getExp_id(), dbConn); 
	Set<Integer> chosenProtocolIDs = new TreeSet<Integer>();
	if (chosenProtocols != null && chosenProtocols.length > 0) {
		for (Experiment_protocol thisProtocol : chosenProtocols) {
			chosenProtocolIDs.add(thisProtocol.getProtocol_id());
		}
	}
	log.debug("chosenProtocolIDs = "); myDebugger.print(chosenProtocolIDs);

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-004");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }
        fieldNames.add("experimentID");
        multipleFieldNames.add("SAMPLE_GROWTH_PROTOCOL");
        multipleFieldNames.add("SAMPLE_LABORATORY_PROTOCOL");
        multipleFieldNames.add("EXTRACT_LABORATORY_PROTOCOL");
        multipleFieldNames.add("LABEL_LABORATORY_PROTOCOL");
        multipleFieldNames.add("HYBRID_LABORATORY_PROTOCOL");
        multipleFieldNames.add("SCANNING_LABORATORY_PROTOCOL");

        fieldValues = myHTMLHandler.getFieldValues(request, fieldNames);
	log.debug("fieldValues = "+fieldValues);
        multipleFieldValues = myHTMLHandler.getMultipleFieldValues(request, multipleFieldNames);

	if (action != null && action.equals("Next >")) {
		myExperiment_protocol.createExperiment_protocol(userLoggedIn, fieldValues, multipleFieldValues, dbConn);
		session.setAttribute("successMsg", "EXP-037");
		log.debug("before downloadSpreadsheet now = "+selectedExperiment.getExp_id());
                response.sendRedirect(experimentsDir + "downloadSpreadsheet.jsp?experimentID=" + selectedExperiment.getExp_id());
	} else {
		myProtocols = myProtocol.getPrivateProtocols(dbConn);
		myPublicProtocols = myProtocol.getPublicProtocols(dbConn); 
	}
	mySessionHandler.createExperimentActivity("Chose protocols", dbConn); 
%>
	
	<%@ include file="/web/common/microarrayHeader.jsp" %>
	<%@ include file="/web/experiments/include/viewingPane.jsp" %>
	<%@ include file="/web/experiments/include/uploadSteps.jsp" %>
	<div class="brClear"></div>
	<div class="page-intro">
        	<p>Select the protocols used in your experiment by clicking one or more rows in each section.  
		Protocols marked with <span style='color:red; font-weight:bold; font-size:14pt'> * </span>  are required.  
</p>
	</div> <!-- // end page-intro -->

	<div class="brClear"></div>
	<form   name="chooseProtocols" 
        	method="get" 
        	onSubmit="return IsChooseProtocolsFormComplete()" 
        	action="chooseProtocols.jsp" 
		enctype="application/x-www-form-urlencoded">

		<% 
		title = "Sample Growth Conditions Protocols";  
		tableID = "growth";
		protocolType = "SAMPLE_GROWTH_PROTOCOL";
		%> <%@ include file="/web/experiments/include/displayProtocols.jsp" %> <% 

		title = "Sample Treatment Protocols";  
		tableID = "treatment";
		protocolType = "SAMPLE_LABORATORY_PROTOCOL";
		%> <%@ include file="/web/experiments/include/displayProtocols.jsp" %> <%

		title = "<span style='color:red;'> * </span> Extraction Protocols";  
		tableID = "extract";
		protocolType = "EXTRACT_LABORATORY_PROTOCOL";
		%> <%@ include file="/web/experiments/include/displayProtocols.jsp" %> <%

		title = "<span style='color:red;'> * </span> Labeling Protocols";  
		tableID = "label";
		protocolType = "LABEL_LABORATORY_PROTOCOL";
		%> <%@ include file="/web/experiments/include/displayProtocols.jsp" %> <%

		title = "<span style='color:red;'> * </span> Hybridization Protocols";  
		tableID = "hybrid";
		protocolType = "HYBRID_LABORATORY_PROTOCOL";
		%> <%@ include file="/web/experiments/include/displayProtocols.jsp" %> <%

		title = "<span style='color:red;'> * </span> Scanning Protocols";  
		tableID = "scanning";
		protocolType = "SCANNING_LABORATORY_PROTOCOL";
		%> <%@ include file="/web/experiments/include/displayProtocols.jsp" %> 

		<BR>

		<div class="right">
        		<span class="info" title="Save and continue">
                        	<%@ include file="/web/common/nextButton.jsp" %>
		</div>
		<BR><BR>
		<input type="hidden" name="experimentID" value="<%=selectedExperiment.getExp_id()%>">	
	</form>
	<div class="brClear"></div>

	<div style="margin:20px" class="itemDetails"></div>
	<div style="margin:20px" class="createProtocol"></div>
	<div style="margin:20px" class="deleteItem"></div>

	<%@ include file="/web/common/footer.jsp" %>
	<script type="text/javascript">
		$(document).ready(function() {
			setupPage();
		});
	</script> 
