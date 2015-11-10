<%@ include file="/web/access/include/login_vars.jsp" %>

        
<%

	String url=FilterInput.getFilteredLocalURLInput(request.getParameter("url"),mySessionHandler.getHost());
	if(loggedIn&&!userLoggedIn.getUser_name().equals("anon")){
		response.sendRedirect(url);
	}else{
            response.sendRedirect(accessDir+"loginPage.jsp?url="+url);
	}
                
	
%>

