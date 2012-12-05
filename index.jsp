<%@ include file="/web/access/include/login_vars.jsp" %>
<%
	//loggedIn = false;
	extrasList.add("landing.js");
    request.setAttribute( "extras", extrasList);
%>
<%@ include file="/web/common/basicHeader.jsp" %>



<%
        String msg = "";
        String callerMsg = "";
 
        	/*
			//May need to add back this is to keep user from opening another window
			if (contextRoot.equals("/PhenoGen/") || contextRoot.equals("/PhenoGenTEST/")) {
                	if ((String) session.getAttribute("userID") != null) {
                        	log.debug("user already logged in.  Invalidating session");
                        	mySessionHandler.setSession_id(session.getId());
                        	mySessionHandler.logoutSession(dbConn);
                        	session.invalidate();
                	}
        	}
			*/

        	callerMsg = "";
        	//log.debug("caller = " + caller);
        	//log.debug("this = " + "http://" + host + contextRoot + "index.jsp");

        	if (caller == null) {
                	//log.debug("caller is null");
        	} else if (caller.equals("http://" + host + contextRoot + "index.jsp") ||
                	caller.equals("http://" + host + contextRoot) ||
                	caller.equals("http://" + host + "/")) {
                	log.debug("caller is " + caller + " - possibly typed incorrect username/password combination");
        	} else if (caller.equals("http://" + host + helpDir + "gettingStarted.jsp") ||
                        	caller.equals("http://" + host + accessDir + "registration.jsp") ||
                        	caller.equals("http://" + host + commonDir + "successMsg.jsp") ||
                        	caller.equals("http://" + host + accessDir + "loginError.jsp") ||
                        	caller.equals("http://" + host + accessDir + "emailPassword.jsp") ||
                        	caller.equals("http://" + host + webDir + "iniaHome.jsp") ||
                        	caller.equals("http://" + host + commonDir + "iniaPartners.jsp") ||
                        	caller.equals("http://" + host + commonDir + "contact.jsp") ||
                        	!caller.startsWith("http://phenogen.uchsc.edu") ||
                        	caller.equals("http://" + host + accessDir + "logout.jsp")) {
                	callerMsg = "";
        	} else {
                	log.debug("session had expired");
                	//callerMsg = "Due to inactivity, your session has expired.  Please login again.";
                	session.setAttribute("loginErrorMsg", "Expired");
                	response.sendRedirect(accessDir + "loginError.jsp");
        	}
        	log.debug("caller = "+  caller + ", and callerMsg = "+ callerMsg);        
		formName = "index.jsp";
		actionForm = "index.jsp";
        	%>
			
			

	
	<div id="index">
    	        

    	<div id="primary-content">
            	<%@ include file="/web/common/overview.jsp" %>

    	</div> <!-- // end primary-content -->
  	</div> <!-- end index -->
	<div id="footer"> &nbsp; </div>
	</div> <!-- // end site-wrap -->

    	<script type="text/javascript">
        	$(document).ready(function(){	
            		$("div.clicker").click(function(){
                		var thisHidden = $( "span#" + $(this).attr("name") ).is(":hidden");
                		var tabTriggers = $(this).parents("ul").find("span.branch").hide();
                		var baseName = $(this).attr("name");
				$("span#" + baseName).removeClass("clickerLess");
                		if ( thisHidden ) {
					$("span#" + baseName).show().addClass("clickerLess");
				}
				$("div."+baseName).removeClass("clicker");
				$("div."+baseName).addClass("clickerLess");
            		});
					
        	});
		
	</script>

	<%@ include file="/web/common/basicFooter.jsp" %>
<%
        	//dbConn.close();
        //}
%>

