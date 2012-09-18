<%--
 *  Author: Cheryl Hornbaker
 *  Created: Mar, 2010
 *  Description:  This file performs the logic neccessary for setting up an experiment.
 *
 *  Todo:
 *  Modification Log:
 *
--%>

<%
		log.debug("in setupExperiment right before calling getExperiment");
		selectedExperiment = new Experiment().getExperiment(experimentID, dbConn);

       		session.setAttribute("selectedExperiment", selectedExperiment);
%>

