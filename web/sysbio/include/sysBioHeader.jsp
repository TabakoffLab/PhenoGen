<%--
 *  Author: Cheryl Hornbaker
 *  Created: Dec, 2010
 *  Description:  This file sets up the header for the system biology screens
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/common/anon_session_vars.jsp"  %>

<jsp:useBean id="myDataset" class="edu.ucdenver.ccp.PhenoGen.data.Dataset"> </jsp:useBean>
<jsp:useBean id="myResource" class="edu.ucdenver.ccp.PhenoGen.data.internal.Resource">
        <jsp:setProperty name="myResource" property="session" value="<%=session%>" />
</jsp:useBean>



<%
        //log.info("in sysBioHeader.jsp. user = " + user);
	request.setAttribute( "selectedMain", "sysbio" );

        extrasList.add("common.js");
%>



