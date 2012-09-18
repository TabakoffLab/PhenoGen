<%--
 *  Author: Cheryl Hornbaker
 *  Created: Mar, 2010
 *  Description:  This file performs the logic neccessary for selecting an experiment.
 *
 *  Todo:
 *  Modification Log:
 *
--%>

<%
	int experimentID = ((String) request.getParameter("experimentID") != null &&
		!((String) request.getParameter("experimentID")).equals("")  ? 
		Integer.parseInt((String)request.getParameter("experimentID")) :
		-99);


	log.debug("In selectExperiment. Here experimentID = " + experimentID);

	if (experimentID != -99) {
		%><%@ include file="/web/experiments/include/setupExperiment.jsp" %><%
	} else { 
		selectedExperiment = new Experiment(-99);
	}

       	session.setAttribute("selectedExperiment", selectedExperiment);
       	session.setAttribute("experimentsForUser", experimentsForUser);


%>

