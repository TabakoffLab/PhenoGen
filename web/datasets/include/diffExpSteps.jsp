<%
	String stepHeader = "Steps to run a differential expression analysis: ";
	Toolbar.Option[] steps = myToolbar.getStepsForDifferentialExpression();
%>
	<%@ include file="/web/common/showSteps.jsp"  %>
