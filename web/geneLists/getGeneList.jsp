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
--%><%@ include file="/web/common/anon_session_vars.jsp" %>
<%
	log.info("in getGeneList.jsp."); 
%><%

        int geneListID = ((String)request.getParameter("geneListID") != null ?
			Integer.parseInt((String)request.getParameter("geneListID")) :
			-99);
	log.info("in getGeneList.jsp. geneListID = " + geneListID);

	new SessionHandler().createGeneListActivity(session.getId(), geneListID, "Copied gene list to create a new one", pool);
        log.debug("after session activity");
	edu.ucdenver.ccp.PhenoGen.data.GeneList thisGeneList = null;
        if(! userLoggedIn.getUser_name().equals("anon")){
            log.debug("logged in");
            thisGeneList = new edu.ucdenver.ccp.PhenoGen.data.GeneList().getGeneList(geneListID, pool);
        }else{
            log.debug("anon");
            thisGeneList = new edu.ucdenver.ccp.PhenoGen.data.AnonGeneList().getGeneList(geneListID, pool);
        }
	edu.ucdenver.ccp.PhenoGen.data.GeneList.Gene[] myGenes = thisGeneList.getGenesAsGeneArray(pool);
	
	for (int i=0; i<myGenes.length; i++) {

%><%=myGenes[i].getGene_id()%>
<% } %>
