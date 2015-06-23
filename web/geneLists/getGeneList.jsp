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
--%><%@ page language="java"
        import="org.apache.log4j.Logger"
        import="java.io.File"
        import="java.io.FileInputStream"
        import="java.util.Properties"
        import="java.sql.Connection"
        import="java.util.ArrayList"
        import="edu.ucdenver.ccp.util.sql.PropertiesConnection"
        import="edu.ucdenver.ccp.PhenoGen.web.SessionHandler"
%>
<%

        Logger log = Logger.getLogger("JSPLogger");
	String dbPropertiesFile = (String) session.getAttribute("dbPropertiesFile");
	log.info("in getGeneList.jsp."); 

%><%@ include file="/web/common/dbutil.jsp"%><%

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
