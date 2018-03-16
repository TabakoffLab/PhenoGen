
  <div id="page_header">
    <div id="header_title"><a href="<%=contextPath%>">PhenoGen Informatics</a></div>

    <div id="header_link_container">

      <div class="header_nav">
      	<%if(loggedIn){
			if (userLoggedIn !=null && userLoggedIn.getUser_name().equals("anon")) {%>
            	<a href="<%=contextPath%>/index.jsp">Home</a> |
          <%}else{%>
        		<a href="<%=contextPath%>/web/common/startPage.jsp">Home</a> |
          <%}%>
          <a href="<%=contextPath%>/gene.jsp">Gene Summary</a> |
       <%}else{%>
        	<a href="<%=contextPath%>/web/common/startPage.jsp">Home</a> |
            <a href="<%=accessDir%>createAnnonymousSession.jsp">Gene Summary</a> |
       <%}%>
          
<%
    if ( loggedIn ) {
		if (userLoggedIn !=null && !userLoggedIn.getUser_name().equals("anon")) {
			if (userLoggedIn !=null && !userLoggedIn.getUser_name().equals("guest")) { %>
        		<a href="<%=contextPath%>/web/access/userUpdate.jsp">My Profile</a> |
			<% } %>
			<a href="<%=contextPath%>/web/common/contact.jsp">Contact Us</a> |
        	<a href="<%=contextPath%>/web/access/logout.jsp">Logout</a> |
      <%}%>
	<% }else{ %>
		<!--<a href="<%=contextPath%>/web/common/startPage.jsp">Login</a> |-->
        <a href="#" class="login_btn"><span>Login</span><span class="triangle_down"></span></a> &nbsp; |
	<%}%>
    	
        <a href="<%=rcontextPath%>/helpdocs/PhenoGen_Overview_CSH.htm#Overview.htm" target="_blank" class="site_help_link"><span>Site Help</span></a>
     
        <%@ include file="/web/access/include/loginBox.jsp" %>  <!--The website is temporarily down(<30min) to patch a bug.  Please try again soon.  Sorry for any inconvenience.-->
      </div> <!-- header_nav -->

<% if (loggedIn ) { %>

		
	<!-- 
      <div class="header_messages">
        <div>(1 new)</div>
        <div><a href="" class="message_link"><span>Messages</span></a></div>
      </div> 
	-->
<% } %>
    </div> <!-- header_link_container -->

  </div> <!-- page_header -->

  <div id="crumb_trail"></div>
  
  <script>
  	var mouse_is_inside = false;
  
  	$(document).ready(function() {
    	$(".login_btn").click(function() {
        	var loginBox = $("#login_box");
        	if (loginBox.is(":visible")){
            	loginBox.fadeOut("fast");
				$(".triangle_up").removeClass('triangle_up').addClass('triangle_down');
        	}else{
            	loginBox.fadeIn("fast");
				$(".triangle_down").removeClass('triangle_down').addClass('triangle_up');
			}
        	return false;
    	});
		$("#login_box").hover(function(){ 
       		mouse_is_inside=true; 
    	}, function(){ 
        	mouse_is_inside=false; 
    	});
		$("body").click(function(){
        	if(! mouse_is_inside) $("#login_box").fadeOut("fast");
   		 });
	});
	</script>
