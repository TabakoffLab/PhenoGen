<%--
 *  Author: Cheryl Hornbaker
 *  Created: Mar, 2010
 *  Description:  This file performs the logic necessary for selecting an experiment 
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/experiments/include/experimentHeader.jsp"  %>
<%@ include file="/web/experiments/include/selectExperiment.jsp"  %>
<%
	String goTo = (request.getParameter("goTo") != null ?
				(String) request.getParameter("goTo") : "");
	log.debug("in chooseExperiment. goTo = " + goTo);
	log.debug("numSamples = " + selectedExperiment.getNum_samples());
	if (experimentID != -99) {
		// Have to explicitly state selectedExperiment.getExp_id() because it's not in session yet
		mySessionHandler.createExperimentActivity(session.getId(), selectedExperiment.getExp_id(), "Chose experiment", dbConn); 
		if (goTo.equals("spreadsheet") || selectedExperiment.getNum_samples() == 0) {
			response.sendRedirect("uploadSpreadsheet.jsp?experimentID="+selectedExperiment.getExp_id());
		} else if (goTo.equals("files") || selectedExperiment.getNum_files() != selectedExperiment.getNum_arrays()) {
			response.sendRedirect("uploadCELFiles.jsp?experimentID="+selectedExperiment.getExp_id());
		} else if (goTo.equals("curate") || !selectedExperiment.getProc_status().equals("C")) {
			response.sendRedirect("reviewExperiment.jsp?experimentID="+selectedExperiment.getExp_id());
		} else {
			response.sendRedirect("listExperiments.jsp");
		}
	} else {
		response.sendRedirect("listExperiments.jsp");
	}
%>
