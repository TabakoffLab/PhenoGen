<%--
 *  Author: Cheryl Hornbaker
 *  Created: Nov, 2009
 *  Description:  This file retrieves a gene list from the database
 *
 *  Todo: 
 *  Modification Log:
 *      
 *    **********  Formatting is bad in this file, but necessary so there are no extra 
 *    ********** spaces in the html file
 *
--%><%@ include file="/web/common/session_vars.jsp"%> 
<%
	log.info("in getGeneList.jsp."); 
%><%

        int geneListID = ((String)request.getParameter("geneListID") != null ?
			Integer.parseInt((String)request.getParameter("geneListID")) :
			-99);
	log.info("in getGeneList.jsp. geneListID = " + geneListID);

	new SessionHandler().createGeneListActivity(session.getId(), geneListID, "Copied gene list to create a new one", pool);
	edu.ucdenver.ccp.PhenoGen.data.GeneList thisGeneList = new edu.ucdenver.ccp.PhenoGen.data.GeneList().getGeneList(geneListID, pool);
	edu.ucdenver.ccp.PhenoGen.data.GeneList.Gene[] myGenes = thisGeneList.getGenesAsGeneArray(pool);
	
	for (int i=0; i<myGenes.length; i++) {

%><%=myGenes[i].getGene_id()%>
<% } %>
