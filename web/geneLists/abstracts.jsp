<%--
 *  Author: Cheryl Hornbaker
 *  Created: April, 2005
 *  Description:  The web page created by this file displays the pubmed abstracts for 
 *  a particular literature search.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %> 
<%@ include file="/web/common/dbutil_medline.jsp"  %> 

<jsp:useBean id="myLitSearch" class="edu.ucdenver.ccp.PhenoGen.data.LitSearch"> </jsp:useBean>

<%
	log.info("in abstracts.jsp. user = " + user);
	int itemID = (request.getParameter("itemID") == null ? -99 : Integer.parseInt((String) request.getParameter("itemID")));
	int corefID = (request.getParameter("corefID") == null ? -99 : Integer.parseInt((String) request.getParameter("corefID")));
	session.setAttribute("itemID", Integer.toString(itemID));
	session.setAttribute("corefID", Integer.toString(corefID));
	String gene = ((String)request.getParameter("gene"));
	String category = ((String)request.getParameter("category"));

	log.debug("itemID = "+itemID + " category = "+category + ", corefID = "+corefID + ", gene = "+gene);

	String previousKey = null;
	String oracleSID = (String) session.getAttribute("oracleSID");
	String oracleUser = (String) session.getAttribute("oracleUser");
	String databaseLink = oracleUser + "_" + oracleSID + "_link";

	Results myAbstracts = (corefID == -99 ?  myAbstracts = myLitSearch.getAbstracts(itemID, gene, category, databaseLink, mdlnConn) :
						myLitSearch.getCoRefAbstracts(corefID, databaseLink, mdlnConn));

	session.setAttribute("myAbstracts", myAbstracts);
	session.setAttribute("category", category);
	int pageNum = 0;
	sortOrder = "A";

	mySessionHandler.createGeneListActivity("Viewed abstracts for category '" + category +  "' and gene '" + gene + "'", dbConn);
	th = new TableHandler("abstractsNext.jsp");

%> 
<%@ include file="/web/common/externalWindowHeader.jsp" %>

<%@ include file="/web/geneLists/include/formatAbstracts.jsp" %>

<%@ include file="/web/common/externalWindowFooter.html" %>
