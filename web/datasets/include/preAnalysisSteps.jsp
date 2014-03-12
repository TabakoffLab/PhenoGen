<%
	String stepHeader = "Steps to run an analysis: ";
	Toolbar.Option[] steps = myToolbar.getStepsForRunAnalysis();
%>
	<%@ include file="/web/common/showSteps.jsp"  %>

<%log.debug("end of preanalysisSteps.jsp");%>
