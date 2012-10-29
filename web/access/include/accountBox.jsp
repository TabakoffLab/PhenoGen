     <%if(!loggedIn||userLoggedIn.getUser_name().equals("anon")){
	 	actionForm=accessDir+"include/handleRedirectLogin.jsp";
	 %>
     	
        <div id="login_box">
        		
                <% if(!loginEnabled){ %>
        			<!-- Uncomment Line below when site is down.  comment out the form following to prevent logins -->
        			<%@ include file="/web/access/siteDown.jsp" %>
                <% }else{ %>
                    <!-- Comment out the entire form below to prevent logins.  DON'T FORGET: also to comment out form in loginPage.jsp and createAnonymousSession.jsp -->
                    <form method="post" enctype="application/x-www-form-urlencoded" action="<%=actionForm%>" name="loginForm" id="login-form">
                            <label for="user_name">Username</label>
                            <input id="user_name" name="user_name" />
                            <label for="password">Password</label>
                            <input id="password" type="password" name="password" />
                            <input type="submit" value="Login" name="action" class="submit" title="Log In" />
                            
                            <input type="hidden" name="url" value="<%=commonDir%>startPage.jsp" />
                            
                            <a href="<%=accessDir%>registration.jsp" id="register-btn"><img src="<%=imagesDir%>register-btn.png" border="0" alt="Register for PhenoGen Informatics" /></a>
                            <a href="<%=accessDir%>emailPassword.jsp" title="Click here if you forgot your password">Forgot Password?</a>
                
                    </form>
                    
				<%}%>
        </div> <!-- // end login-form -->
		<div class="brClear"></div>
    <%} else {%>
    	<div id="login_box">
        <form method="post" enctype="application/x-www-form-urlencoded" action="<%=actionForm%>" name="loginForm" id="login-form">
             <a href="<%=request.getContextPath()%>/web/access/userUpdate.jsp" class="button" id="accountBtn">My Profile</a><BR />	
             <a href="<%=accessDir%>logout.jsp" class="button" id="logInOutBtn">Logout</a>
              </form>
        </div>
        <div class="brClear"></div>
    <% } %>

