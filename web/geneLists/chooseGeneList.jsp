<%--
 *  Author: Cheryl Hornbaker
 *  Created: Jan, 2006
 *  Description:  This file performs the logic necessary for selecting a gene list
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %>
<%@ include file="/web/geneLists/include/selectGeneList.jsp"  %>
<%@ include file="/web/geneLists/include/callIdecoder.jsp"  %>
<%
	log.debug("in chooseGeneList");
	
	mySessionHandler.createGeneListActivity(session.getId(), selectedGeneList.getGene_list_id(), "Chose genelist", pool);
        
        log.debug("after choose activity");
	
        if (fromQTL.equals("")) {
		response.sendRedirect("geneList.jsp");
	} else {
		response.sendRedirect("locationEQTL.jsp?fromQTL=Y");
	}
%>
