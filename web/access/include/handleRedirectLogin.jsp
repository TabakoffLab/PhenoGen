<%@ include file="/web/access/include/login_vars.jsp" %>
<%
    boolean previousAnonUser=false;
    String redirUrl=FilterInput.getFilteredLocalURLInput(request.getParameter("url"),mySessionHandler.getHost());
       if(redirUrl!=null&&!redirUrl.equals("")){
                    redirUrl=redirUrl.trim();
                    log.debug(" redirURL="+redirUrl);
            }

    if(request.isRequestedSessionIdValid() && session.getAttribute("userLoggedIn") != null && !userLoggedIn.getUser_name().equals("anon")) {
         response.sendRedirect(commonDir+"startPage.jsp");
    }else if(request.isRequestedSessionIdValid() && session.getAttribute("userLoggedIn") != null){
                    //mySessionHandler.setSession_id(session.getId());
                    //mySessionHandler.logoutSession(dbConn);
                    //
                    // close the database connections
                    //
                    //log.debug("closing connection 'dbConn'");
                    dbConn.close();
                    //session.invalidate();
                    loggedIn = false;
                    previousAnonUser=true;
    }


    if (action != null && (action.equals("Login") || action.equals("Demo"))) {
                String loginUserName = null;
                String password = null;
                if (action.equals("Demo")) {
                        loginUserName = "guest";
                        password = "demo";
                } else {
                        loginUserName = (String) request.getParameter("user_name");
                        password = (String) request.getParameter("password");
                }
				
                if (dbUnavail && pool!=null) {
                        
                    try { 
                        Connection test=pool.getConnection();
                        myUser.getUser("public",pool);
                        test.close();
                        dbUnavail=false;
                    } catch (Exception e) {
                            log.error("dbConn was not successfully opened.  Sending email to phenogen.help", e);
                            //dbConnAvailable = false;
                            dbUnavail=true;
                            Email myDbConnErrorEmail=new Email();
                            myDbConnErrorEmail.setSubject("PhenoGen Database is Unavailable");
                            myDbConnErrorEmail.setContent("The PhenoGen database connection is unavailable.");
                            try {
                                    myDbConnErrorEmail.sendEmailToAdministrator(adminEmail);
                            } catch (Exception error) {
                                log.error("exception while trying to send message to phenogen.help about phenogen db connection", error);
                            }
                    }
                       
                }
				
                if (dbUnavail) {
                            response.sendRedirect("/index.jsp");
                }else{
				
                        if (loginUserName != null && password != null) {
                        userLoggedIn = myUser.getUser(loginUserName, password, pool);
                         log.debug("last_name = "+userLoggedIn.getLast_name() + ", id = "+userLoggedIn.getUser_id());

                        if (userLoggedIn.getUser_id() == -1) {
                                log.info(loginUserName + " just failed to log in.");
                                //msg = "Invalid username/password combination.  Please try again.";
                                session.setAttribute("loginErrorMsg", "Invalid");
                                response.sendRedirect(accessDir + "loginError.jsp");
                        } else {
                                log.info(loginUserName + " just logged in.");

                                if (userLoggedIn.checkRole(loginUserName, password, "Administrator", pool)) {
                                        session.setAttribute("isAdministrator", "Y");
                                } else {
                                        session.setAttribute("isAdministrator", "N");
                                        log.debug("user is NOT an Administrator");
                                }
                                if (userLoggedIn.checkRole(loginUserName, password, "ISBRA", pool)) {
                                        session.setAttribute("isISBRA", "Y");
                                } else {
                                        session.setAttribute("isISBRA", "N");
                                        log.debug("user is NOT an ISBRA");
                                }
                                if (userLoggedIn.checkPI(pool)) {
                                        session.setAttribute("isPrincipalInvestigator", "Y");
                                } else {
                                        session.setAttribute("isPrincipalInvestigator", "N");
                                        log.debug("user is NOT a PI");
                                }

                                mySessionHandler.setSessionVariables(session, userLoggedIn);
                                mySessionHandler.setSession_id(session.getId());
                                mySessionHandler.setUser_id(userLoggedIn.getUser_id());
                                if(previousAnonUser){
                                        mySessionHandler.updateLoginSession(mySessionHandler, pool);
                                }else{
                                        mySessionHandler.createSession(mySessionHandler, pool);
                                }

                                userFilesRoot = (String) session.getAttribute("userFilesRoot");

                                userLoggedIn.setUserMainDir(userFilesRoot);
                                session.setAttribute("userLoggedIn", userLoggedIn);
                                int port=request.getServerPort();
                                                                if(redirUrl!=null && !redirUrl.equals("")  && !(redirUrl.startsWith("http://" + mySessionHandler.getHost()) || redirUrl.startsWith("https://" + mySessionHandler.getHost())) ){
                                                                        log.debug("send redir:"+"http://" + mySessionHandler.getHost() +redirUrl);
                                                                        if(port==80){
                                                                            response.sendRedirect("http://" + mySessionHandler.getHost() + redirUrl);
                                                                        }else if(port==443){
                                                                            response.sendRedirect("https://" + mySessionHandler.getHost() + redirUrl);
                                                                        }
                                                                        return;

                                                                }else if(redirUrl!=null && !redirUrl.equals("")  && redirUrl.startsWith("https://" + mySessionHandler.getHost())){
                                                                        response.sendRedirect(redirUrl);
                                                                        return;
                                                                }else if(redirUrl!=null && !redirUrl.equals("")  && redirUrl.startsWith("http://" + mySessionHandler.getHost())){
                                                                        //EDIT to redirect to HTTPS when ready
                                                                        response.sendRedirect(redirUrl);
                                                                        return;
                                                                }else{
                                                                        log.debug("default redir:"+commonDir + "startPage.jsp");
                                                                        if(port==80){
                                                                            response.sendRedirect("http://" + mySessionHandler.getHost()+commonDir + "startPage.jsp");
                                                                        }else if(port==443){
                                                                            response.sendRedirect("https://" + mySessionHandler.getHost()+commonDir + "startPage.jsp");
                                                                        }
                                                                        return;
                                                                }
                        }
                        }
                                }
        }
	
%>

