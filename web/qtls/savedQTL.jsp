<%-- 
 *  Author: Spencer Mahaffey
 *  Created: Aug, 2012
 *  Description:  The web page created by this file confirms the phenotype QTL has been saved and gives the user instructions to use it.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/qtls/include/qtlHeader.jsp"  %>

<%
	log.debug("in savedQTL.jsp. user = " + user + ", action = "+action); 

	//optionsListModal.add("createNewPhenotype");
	//optionsListModal.add("createNewQTLsList");
	String name=(String) request.getParameter("name");

%>

<%@ include file="/web/common/header.jsp" %>

		<BR />
    	<div style="text-align:center;"><h3><%=name%> QTL List successfully saved.</h3></div><BR /><BR />
        View QTL Information by:
        <ol type="1"> 
        <li><a href="<%=geneListsDir%>listGeneLists.jsp">Selecting a Gene List</a>.</li>
        <li>Going to the Location(eQTL) Tab after you select a Gene List.</li>
        </ol>
		<BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR />

<%@ include file="/web/common/footer.jsp" %>


