<%
	String stepHeader = "Steps to run quality control on a dataset: ";
        Toolbar.Option[] steps = myToolbar.getStepsForRunningQC();
%>
	<%@ include file="/web/common/showSteps.jsp"  %>
