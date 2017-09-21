<%--
 *  Author: Spencer Mahaffey
 *  Created: April, 2013
 *  Description:  The web page created by this file displays acknowledgements for the site and data.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/access/include/login_vars.jsp" %>

<% 	extrasList.add("normalize.css");
	extrasList.add("index.css");
%>

<%pageTitle="Acknowledgements";
pageDescription="Acknowledgements for providing funding and resources";%>

<%@ include file="/web/common/header.jsp" %>

        <div id="overview-content">
        <div id="welcome" style="height:780px; width:946px; overflow:auto;">

	<%@ include file="/web/common/acknowledgement_content.jsp" %>
    
<%@ include file="/web/common/footer.jsp" %>
