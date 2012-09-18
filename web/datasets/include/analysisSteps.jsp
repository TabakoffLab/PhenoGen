	<div class="brClear"></div>
	<%
	if (formName.equals("correlation.jsp") || analysisType.equals("correlation")) {
        	%><%@ include file="/web/datasets/include/correlationSteps.jsp" %> <% 
	} else if (formName.equals("cluster.jsp") || analysisType.equals("cluster")) {
        	%><%@ include file="/web/datasets/include/clusterSteps.jsp" %> <% 
	} else { 
		%> <%@ include file="/web/datasets/include/diffExpSteps.jsp" %> <% 
	} %>
