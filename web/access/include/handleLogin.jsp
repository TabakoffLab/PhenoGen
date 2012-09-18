<%
       boolean previousAnonUser=false;
	   
	   
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
				
				if (dbConn == null || dbConn.isClosed()) {
					if (dbPropertiesFile != null) {
						try {
							dbConn = new PropertiesConnection().getConnection(dbPropertiesFile);
							/* save newly created connection in the session */
							session.setAttribute("dbConn", dbConn);
						} catch (Exception e) {
							log.error("dbConn was not successfully opened.  Sending email to phenogen.help", e);
							dbConnAvailable = false;
                        	myDbConnErrorEmail.setSubject("PhenoGen Database is Unavailable");
                        	myDbConnErrorEmail.setContent("The PhenoGen database connection is unavailable.");
                        	try {
                        		myDbConnErrorEmail.sendEmailToAdministrator();
                        	} catch (Exception error) {
                            	log.error("exception while trying to send message to phenogen.help about phenogen db connection", error);
                        	}
						}
					} else {
						log.debug("*** dbPropertiesFile is null or session must be inactive. *** ");
					}
				}
				
				if (!dbConnAvailable) {
                	response.sendRedirect("outOfService.html");
        		}else{
				
                	if (loginUserName != null && password != null) {
                        userLoggedIn = myUser.getUser(loginUserName, password, dbConn);
                         log.debug("last_name = "+userLoggedIn.getLast_name() + ", id = "+userLoggedIn.getUser_id());

                        if (userLoggedIn.getUser_id() == -1) {
                                log.info(loginUserName + " just failed to log in.");
                                //msg = "Invalid username/password combination.  Please try again.";
                                session.setAttribute("loginErrorMsg", "Invalid");
                                response.sendRedirect(accessDir + "loginError.jsp");
                        } else {
                                log.info(loginUserName + " just logged in.");

                                if (userLoggedIn.checkRole(loginUserName, password, "Administrator", dbConn)) {
                                        session.setAttribute("isAdministrator", "Y");
                                } else {
                                        session.setAttribute("isAdministrator", "N");
                                        log.debug("user is NOT an Administrator");
                                }
                                if (userLoggedIn.checkRole(loginUserName, password, "ISBRA", dbConn)) {
                                        session.setAttribute("isISBRA", "Y");
                                } else {
                                        session.setAttribute("isISBRA", "N");
                                        log.debug("user is NOT an ISBRA");
                                }
                                if (userLoggedIn.checkPI(dbConn)) {
                                        session.setAttribute("isPrincipalInvestigator", "Y");
                                } else {
                                        session.setAttribute("isPrincipalInvestigator", "N");
                                        log.debug("user is NOT a PI");
                                }

                                mySessionHandler.setSessionVariables(session, userLoggedIn);
                                mySessionHandler.setSession_id(session.getId());
                                mySessionHandler.setUser_id(userLoggedIn.getUser_id());
								if(previousAnonUser){
									mySessionHandler.updateLoginSession(mySessionHandler, dbConn);
								}else{
                                	mySessionHandler.createSession(mySessionHandler, dbConn);
								}

                                userFilesRoot = (String) session.getAttribute("userFilesRoot");

                                userLoggedIn.setUserMainDir(userFilesRoot);
                                session.setAttribute("userLoggedIn", userLoggedIn);
								
                               	response.sendRedirect(commonDir + "startPage.jsp");
								
                        }
                	}
				}
        }
	
%>

