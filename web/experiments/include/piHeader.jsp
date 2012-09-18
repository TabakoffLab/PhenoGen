<%--
 *  Author: Cheryl Hornbaker
 *  Created: Jan, 2009
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/common/session_vars.jsp"  %>

<%
	log.info("in piHeader.jsp. user = " + user);

	request.setAttribute( "selectedMain", "home" );
        extrasList.add("experimentMain.css");
        extrasList.add("common.js");
%>



