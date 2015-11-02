

<%@ include file="/web/access/include/login_vars.jsp" %>


<!-- This file is used by users downloading large files -->
<%
	int download_id = Integer.parseInt((String) request.getParameter("id"));
	String redirectString = FilterInput.getFilteredLocalURLInput(new Download().getDownload(download_id, dbConn).getURL(),mySessionHandler.getHost());
        
	log.debug("redirectString = "+redirectString);
	if(loggedIn&&!userLoggedIn.getUser_name().equals("anon")){%>
		<%@ include file="/web/common/mainHeadTags.jsp"%>	
        <meta http-equiv="refresh" content=".1;url=<%=redirectString%>">
        </head>
        </html>
    <%}else{
    	response.sendRedirect(accessDir+"loginPage.jsp?url="+redirectString);
	}%>


