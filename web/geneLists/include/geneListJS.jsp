<%--
 *  Author: Spencer Mahaffey    
 *  Created: May, 2016
 *  Description:  This file directly inserts javascript needed for anonymous sessions.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>


<%
if(userLoggedIn.getUser_name().equals("anon")){
%>

<script type="text/javascript">
    var contextRoot="<%=contextRoot%>";
    <%@ include file="/javascript/Anon_session.js" %>
    <%@ include file="/javascript/Anon_Genelists.js" %>
</script>
<%}%>