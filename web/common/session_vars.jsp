<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  This file establishes the session variables that are used throughout
 *	the website.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/common/common_declarations.jsp"%>

<%@ page errorPage="/web/common/errorPage.jsp" %>

<jsp:useBean id="myPropertiesConnection" class="edu.ucdenver.ccp.util.sql.PropertiesConnection" 
	scope="session"/>

<jsp:useBean id="mySessionHandler" class="edu.ucdenver.ccp.PhenoGen.web.SessionHandler"/>
	<jsp:setProperty name="mySessionHandler" property="session" value="<%=session%>" />

<jsp:useBean id="myArray" class="edu.ucdenver.ccp.PhenoGen.data.Array"/>

<%@ include file="/web/common/common_vars.jsp"%>
<%
	if((User)request.getSession(false).getAttribute("userLoggedIn")== null) {
		log.debug("Invalid session");
		response.sendRedirect(request.getContextPath() + "/index.jsp");
	} else {
		userID = Integer.parseInt((String) session.getAttribute("userID"));
		//
		// Is THIS STILL NECESSARY?  
		// These attributes are re-set here, so they will be available in browseArrays.jsp
		// after going to successMsg.jsp and back to browseArrays, which only calls login_vars.jsp
		//
		session.setAttribute("userID", Integer.toString(userID));
		session.setAttribute("user", userID + "-"+ (String) session.getAttribute("userName"));
		session.setAttribute("full_name", (String) session.getAttribute("full_name"));
		session.setAttribute("userLoggedIn", (User) session.getAttribute("userLoggedIn"));
	}
	GeneList[] geneListsForUser = ((GeneList[]) session.getAttribute("geneListsForUser") == null ? 
				null : 
				(GeneList[]) session.getAttribute("geneListsForUser"));
	Experiment[] experimentsForUser = ((Experiment[]) session.getAttribute("experimentsForUser") == null ? 
				null : 
				(Experiment[]) session.getAttribute("experimentsForUser"));
	Dataset[] publicDatasets = ((Dataset[]) session.getAttribute("publicDatasets") == null ? 
				null : 
				(Dataset[]) session.getAttribute("publicDatasets"));
	Dataset[] privateDatasetsForUser = ((Dataset[]) session.getAttribute("privateDatasetsForUser") == null ? 
				null : 
				(Dataset[]) session.getAttribute("privateDatasetsForUser"));

	Isbra.Group selectedGroup = (Isbra.Group) session.getAttribute("selectedGroup");
	String userName = (String) session.getAttribute("userName");
	String full_name = (String) session.getAttribute("full_name");
	String lab_name = (String) session.getAttribute("lab_name");

	String rFunctionDir = (String) session.getAttribute("rFunctionDir");
	String perlDir = (String) session.getAttribute("perlDir");
	String aptDir = (String) session.getAttribute("aptDir");
	String propertiesDir = (String) session.getAttribute("propertiesDir");

	String contextRoot = (String) session.getAttribute("contextRoot");
	String webDir = (String) session.getAttribute("webDir");
	String datasetsDir = (String) session.getAttribute("datasetsDir");
	String experimentsDir = (String) session.getAttribute("experimentsDir");
	String geneListsDir = (String) session.getAttribute("geneListsDir");
	String qtlsDir = (String) session.getAttribute("qtlsDir");
	String exonDir = (String) session.getAttribute("exonDir");
	String ucscDir = (String) session.getAttribute("ucscDir");
	String ucscGeneDir = (String) session.getAttribute("ucscGeneDir");
	String bedDir = (String) session.getAttribute("bedDir");
	String perlEnvVar = (String) session.getAttribute("perlEnvVar");
	String imagesDir = (String) session.getAttribute("imagesDir");
	String sysBioDir = (String) session.getAttribute("sysBioDir");
	String accessDir = (String) session.getAttribute("accessDir");
	String commonDir = (String) session.getAttribute("commonDir");
	String adminDir = (String) session.getAttribute("adminDir");
	String isbraDir = (String) session.getAttribute("isbraDir");
	String helpDir = (String) session.getAttribute("helpDir");
	String javascriptDir = (String) session.getAttribute("javascriptDir");
	String dbPropertiesFile = (String) session.getAttribute("dbPropertiesFile");
	String ensDbPropertiesFile = (String) session.getAttribute("ensDbPropertiesFile");
	String adminEmail = (String) session.getAttribute("adminEmail");

	String userFilesRoot = (String) session.getAttribute("userFilesRoot");
	String mainURL = (String) session.getAttribute("mainURL"); 
	String downloadURL = (String) session.getAttribute("downloadURL"); 


	String sessionID = (String) session.getAttribute("sessionID");
	String applicationRoot = (String) session.getAttribute("applicationRoot");
	String analysisPath = (String) session.getAttribute("analysisPath");
	String[][] qtlResult = (String[][]) session.getAttribute("qtlResult");
	
	String maxRThreadCount="1";
	if(session.getAttribute("maxRThreadCount")!=null){
		maxRThreadCount=(String)session.getAttribute("maxRThreadCount");
	}
	
	String checkMark = "<img src='" + imagesDir + "icons/" + "checkmark.gif' height=\"20\" width=\"20\" alt=\"\">";
	String resultsIcon = "<img src='" + imagesDir + "icons/" + "results.png' height=\"20\" width=\"20\" alt=\"\">";
	String downloadIcon = "<img src='" + imagesDir + "icons/" + "download_g.png' height=\"20\" width=\"20\" alt=\"\">";
	int isbraGroupID = -99;
	if (session.getAttribute("isbraGroupID") != null) {
		isbraGroupID = Integer.parseInt((String) session.getAttribute("isbraGroupID"));
	}
	int parameterGroupID = -99;
	if (session.getAttribute("parameterGroupID") != null) {
		parameterGroupID = Integer.parseInt((String) session.getAttribute("parameterGroupID"));
	}
	int phenotypeParameterGroupID = -99;
	String user = userID + "-"+ userName;
	int windowWidth=1000;
        String onClickString = "";
        action = (String)request.getParameter("action");

	// this file has to be after the logger initialization and no line breaks 
	//to avoid extra lines in the html 
%>
	<%@ include file="/web/common/dbutil.jsp"%>

<%
        if (publicDatasets == null || privateDatasetsForUser == null) {
		Dataset myDataset = new Dataset();
		Dataset[] allDatasets = myDataset.getAllDatasetsForUser(userLoggedIn, dbConn);
        	if (publicDatasets == null) {
                	log.debug("publicDatasets not set, so setting it now");
                	publicDatasets = myDataset.getDatasetsForUser(allDatasets, "public");
			session.setAttribute("publicDatasets", publicDatasets);
        	}
        	if (privateDatasetsForUser == null) {
                	log.debug("privateDatasetsForUser not set, so setting it now");
                	privateDatasetsForUser = myDataset.getDatasetsForUser(allDatasets, "private");
			session.setAttribute("privateDatasetsForUser", privateDatasetsForUser);
		}
	}
%>
<%@ include file="/web/common/alertMsgSetup.jsp" %>
