<%@ include file="/web/common/session_vars.jsp" %>

<%@ include file="/web/common/mainHeadTags.jsp"%>	
<!-- This file is used by users downloading large files -->
<%
	int download_id = Integer.parseInt((String) request.getParameter("id"));
	String redirectString = new Download().getDownload(download_id, dbConn).getURL(); 
	log.debug("redirectString = "+redirectString);
%>
	<meta http-equiv="refresh" content=".1;url=<%=redirectString%>">
</head>
</html>


