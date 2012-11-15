<%--
 *  Author: Spencer Mahaffey
 *  Created: November, 2012
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/access/include/login_vars.jsp" %>

<%
	extrasList.add("index.css"); %>
<%pageTitle="Definitions";%>

<%@ include file="/web/common/header_noMenu.jsp" %>
<a name="top"></a>
<ul>
    <li><a href="#eQTLs">eQTLs</a></li>
    <li><a href="#bQTLs">bQTLs</a></li>
    <li><a href="#heritability">Heritability</a></li>
    <li><a href="#recInbredPanel">Recombinant Inbred Panel</a></li>
</ul>

<BR /><BR />

<a name="eQTLs"><H2>eQTLs</H2></a>
<BR />
<a href="#top">Back to Top</a><BR /><span class="button" onclick="window.close()" style="width:150px;">Close this Window</span><BR />
<a name="bQTLs"><H2>bQTLs</H2></a>
<BR />
<a href="#top">Back to Top</a><BR /><span class="button" onclick="window.close()" style="width:150px;">Close this Window</span><BR />
<a name="heritability"><H2>Heritability</H2></a>
<BR />
<a href="#top">Back to Top</a><BR /><span class="button" onclick="window.close()" style="width:150px;">Close this Window</span><BR />
<a name="recInbredPanel"><H2>Recombinant Inbred Panel</H2></a>
<BR />
<a href="#top">Back to Top</a><BR /><span class="button" onclick="window.close()" style="width:150px;">Close this Window</span><BR />
<%@ include file="/web/common/footer.jsp" %>
