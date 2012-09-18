        <div id="login_box">
                <form method="post" enctype="application/x-www-form-urlencoded" action="<%=actionForm%>" name="loginForm" id="login-form">
                        <label for="user_name">Username</label>
                        <input id="user_name" name="user_name" />
                        <label for="password">Password</label>
                        <input id="password" type="password" name="password" />
                        <input type="submit" value="Login" name="action" class="submit" title="Log In" />
			<% if (formName.endsWith("index.jsp")) { %>
                        	<a href="<%=accessDir%>emailPassword.jsp" title="Click here if you forgot your password">Forgot Password?</a>
			<% } %>
                </form>
        <script type="text/javascript">
                document.loginForm.user_name.focus();
        </script>

        </div> <!-- // end login-form -->
	<div class="brClear"></div>

