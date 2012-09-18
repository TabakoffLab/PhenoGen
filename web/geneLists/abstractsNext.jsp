<%--
 *  Author: Cheryl Hornbaker
 *  Created: October, 2005
 *  Description:  The web page created by this file displays subsequenct pages of pubmed abstracts.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/common/session_vars.jsp"  %> 
<jsp:useBean id="myLitSearch" class="edu.ucdenver.ccp.PhenoGen.data.LitSearch"> </jsp:useBean>

<%
	extrasList.add("geneListMain.css");

	log.info("in abstractsNext.jsp. user = " + user);
	
	int itemID = (request.getParameter("itemID") == null ? -99 : Integer.parseInt((String) request.getParameter("itemID")));
	int corefID = (request.getParameter("corefID") == null ? -99 : Integer.parseInt((String) request.getParameter("corefID")));

	String category = (String) session.getAttribute("category");
	
	Results myAbstracts = (Results) session.getAttribute("myAbstracts");
	int pageNum = -99;
	sortOrder = "A";
	if (request.getParameter("pageNum") != null && !((String)request.getParameter("pageNum")).equals("")) { 
		pageNum = Integer.parseInt((String)request.getParameter("pageNum"));
	}
	log.debug("pageNum = "+pageNum);
	th = new TableHandler("abstractsNext.jsp");
	mySessionHandler.createGeneListActivity("Viewed next set of abstracts for category '" + category, dbConn);

%>


<%@ include file="/web/common/externalWindowHeader.jsp" %>
<%@ include file="/web/geneLists/include/formatAbstracts.jsp" %>
<%@ include file="/web/common/externalWindowFooter.html" %>


