<%@ include file="/web/access/include/login_vars.jsp" %>

        
<%

	String url=request.getParameter("url").trim();
	if(loggedIn&&!userLoggedIn.getUser_name().equals("anon")){
		response.sendRedirect(url);
	}else{
      	response.sendRedirect(accessDir+"loginPage.jsp?url="+url);
	}
                
	
%>

