<%@ include file="/web/common/session_vars.jsp" %>

<%@ include file="/web/common/mainHeadTags.jsp"%>	
<!-- This file is used by users downloading large files -->
<%
	String redirectString = (String) request.getParameter("url"); 
	log.debug("directDownloads redirectString = "+redirectString);
%>
	<meta http-equiv="refresh" content=".1;url=<%=redirectString%>">
</head>
</html>


