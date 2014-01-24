<%--
 *  Author: Spencer Mahaffey
 *  Created: August, 2012
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/access/include/login_vars.jsp" %>

<% 
	extrasList.add("normalize.css");
	extrasList.add("index.css"); 
%>

<% 
	String tmpUrl=request.getParameter("url");
	actionForm = "include/handleRedirectLogin.jsp";
	pageDescription="Login to analyze data";
%>
       

<%@ include file="/web/common/header.jsp" %>

<%
	//if(request.isRequestedSessionIdValid() && session.getAttribute("userLoggedIn") != null && !userLoggedIn.getUser_name().equals("anon")) {
    //         response.sendRedirect("http://" + mySessionHandler.getHost() + redirUrl);
    //}
%>

    <div id="welcome" style="height:575px; width:946px; overflow:auto;">

	
                        <%if(dbConn==null){%>
							<h2>Database is unavailable</h2>
                            <p>The database is currently unavailable.  The administrator has been notified and every effort will be made to make the database available as soon as possible.</p>
						<%} else{%>
                        	<h2>Selected Tool Requires Login</h2>
                        	<p> The tool you selected requires you to login.  Please <a href="<%=accessDir%>registration.jsp">register</a> or login below.</p>
                            <div style="width:165px; height:165px; margin-left:10px;">
                            	
                             <% if(!loginEnabled){ %>
                                <!-- Uncomment Line below when site is down.  comment out the form following to prevent logins -->
                                <%@ include file="/web/access/siteDown.jsp" %>
                            <% }else { %>
                            
                                <!-- Comment out the entire form below to prevent logins.  DON'T FORGET: also to comment out form in accountBox.jsp and createAnonymousSession.jsp -->
                                <form method="post" enctype="application/x-www-form-urlencoded" action="<%=actionForm%>" name="loginForm" id="login-form" style="background-color:#CCCCCC;">
                                <label for="user_name" style="color:#000000">Username</label>
                                <input id="user_name" name="user_name" />
                                <label for="password"style="color:#000000">Password</label>
                                <input id="password" type="password" name="password" />
                                <input type="submit" value="Login" name="action" class="submit" title="Log In" />
                                
                                <input type="hidden" name="url" value="<%=tmpUrl%>" />
                                
                                <a href="<%=accessDir%>registration.jsp" id="register-btn"><img src="<%=imagesDir%>register-btn.png" border="0" alt="Register for PhenoGen Informatics" /></a>
                                <a href="<%=accessDir%>emailPassword.jsp" title="Click here if you forgot your password">Forgot Password?</a>
                                 </form>
                             <% } %>
                         
               				 </div>
                         <%}%>
           
    </div><!-- end welcome -->

     <% if(loginEnabled){ %>
        <script type="text/javascript">
                document.loginForm.user_name.focus();
        </script>      
        <%}%>    
	
	
<%@ include file="/web/common/footer.jsp" %>
