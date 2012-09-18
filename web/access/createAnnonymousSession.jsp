<%@ include file="/web/access/include/login_vars.jsp" %>


        
<%

	//uncomment following line when the site needs to be down.  This will just redirect users to the siteDownPage.jsp instead of trying to create a session.
	if(!loginEnabled){
		response.sendRedirect(accessDir+"siteDownPage.jsp");
	}else{
	
		//Comment out all code following during an update when the site is down.
		
		String url=request.getParameter("url").trim();
		if(loggedIn){
			response.sendRedirect(url);
		}else{
		   userLoggedIn = myUser.getUser("anon", "4lesw7n35h!", dbConn);
		   log.debug("last_name = "+userLoggedIn.getLast_name() + ", id = "+userLoggedIn.getUser_id());
	
							if (userLoggedIn.getUser_id() == -1) {
									log.info("anon just failed to log in.");
									//msg = "Invalid username/password combination.  Please try again.";
									session.setAttribute("loginErrorMsg", "Invalid");
									response.sendRedirect(accessDir + "loginError.jsp");
							} else {
	
											session.setAttribute("isAdministrator", "N");
											log.debug("user is NOT an Administrator");
	
											session.setAttribute("isISBRA", "N");
											log.debug("user is NOT an ISBRA");
									
	
											session.setAttribute("isPrincipalInvestigator", "N");
											log.debug("user is NOT a PI");
	
	
									mySessionHandler.setSessionVariables(session, userLoggedIn);
									mySessionHandler.setSession_id(session.getId());
									mySessionHandler.setUser_id(userLoggedIn.getUser_id());
									mySessionHandler.createSession(mySessionHandler, dbConn);
	
									userFilesRoot = (String) session.getAttribute("userFilesRoot");
	
									userLoggedIn.setUserMainDir(userFilesRoot);
									session.setAttribute("userLoggedIn", userLoggedIn);
									response.sendRedirect(url);
							}
		}
    }            
	
%>

