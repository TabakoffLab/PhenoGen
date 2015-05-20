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

<jsp:useBean id="mySessionHandler" class="edu.ucdenver.ccp.PhenoGen.web.SessionHandler">
	<jsp:setProperty name="mySessionHandler" property="applicationRoot" 
        	value="<%=application.getInitParameter(\"applicationRoot\") %>" />
	<jsp:setProperty name="mySessionHandler" property="contextRoot" 
        	value="<%=application.getInitParameter(\"contextRoot\") %>" />
	<jsp:setProperty name="mySessionHandler" property="userFilesRoot" 
               	value="<%=application.getInitParameter(\"userFilesRoot\") %>" />
	<jsp:setProperty name="mySessionHandler" property="webDir" 
               	value="<%=application.getInitParameter(\"webDir\") %>" />
	<jsp:setProperty name="mySessionHandler" property="r_FunctionDir" 
               	value="<%=application.getInitParameter(\"rFunctionDir\") %>" />
	<jsp:setProperty name="mySessionHandler" property="accessDir" 
               	value="<%=application.getInitParameter(\"accessDir\") %>" />
	<jsp:setProperty name="mySessionHandler" property="aptDir" 
               	value="<%=application.getInitParameter(\"aptDir\") %>" />
	<jsp:setProperty name="mySessionHandler" property="datasetsDir" 
               	value="<%=application.getInitParameter(\"datasetsDir\") %>" />
	<jsp:setProperty name="mySessionHandler" property="experimentsDir" 
               	value="<%=application.getInitParameter(\"experimentsDir\") %>" />
	<jsp:setProperty name="mySessionHandler" property="geneListsDir" 
               	value="<%=application.getInitParameter(\"geneListsDir\") %>" />
	<jsp:setProperty name="mySessionHandler" property="qtlsDir" 
               	value="<%=application.getInitParameter(\"qtlsDir\") %>" />
	<jsp:setProperty name="mySessionHandler" property="exonDir" 
               	value="<%=application.getInitParameter(\"exonDir\") %>" />
	<jsp:setProperty name="mySessionHandler" property="ucscGeneDir" 
               	value="<%=application.getInitParameter(\"ucscGeneDir\") %>" />
    <jsp:setProperty name="mySessionHandler" property="ucscDir" 
               	value="<%=application.getInitParameter(\"ucscDir\") %>" />
    <jsp:setProperty name="mySessionHandler" property="bedDir" 
               	value="<%=application.getInitParameter(\"bedDir\") %>" />
	<jsp:setProperty name="mySessionHandler" property="sysBioDir" 
               	value="<%=application.getInitParameter(\"sysBioDir\") %>" />
	<jsp:setProperty name="mySessionHandler" property="imagesDir" 
               	value="<%=application.getInitParameter(\"imagesDir\") %>" />
	<jsp:setProperty name="mySessionHandler" property="commonDir" 
               	value="<%=application.getInitParameter(\"commonDir\") %>" />
	<jsp:setProperty name="mySessionHandler" property="propertiesDir" 
               	value="<%=application.getInitParameter(\"propertiesDir\") %>" />
	<jsp:setProperty name="mySessionHandler" property="adminDir" 
               	value="<%=application.getInitParameter(\"adminDir\") %>" />
	<jsp:setProperty name="mySessionHandler" property="isbraDir" 
               	value="<%=application.getInitParameter(\"isbraDir\") %>" />
	<jsp:setProperty name="mySessionHandler" property="helpDir" 
               	value="<%=application.getInitParameter(\"helpDir\") %>" />
	<jsp:setProperty name="mySessionHandler" property="javascriptDir" 
               	value="<%=application.getInitParameter(\"javascriptDir\") %>" />               	
	<jsp:setProperty name="mySessionHandler" property="perlDir" 
               	value="<%=application.getInitParameter(\"perlDir\") %>" />
	<jsp:setProperty name="mySessionHandler" property="dbPropertiesFile" 
               	value="<%=application.getInitParameter(\"dbPropertiesFile\") %>" />
	<jsp:setProperty name="mySessionHandler" property="ENSDbPropertiesFile" 
               	value="<%=application.getInitParameter(\"ensDbPropertiesFile\") %>" />
        <jsp:setProperty name="mySessionHandler" property="UCSCDbPropertiesFile" 
               	value="<%=application.getInitParameter(\"ucscDbPropertiesFile\") %>" />
	<jsp:setProperty name="mySessionHandler" property="host" 
               	value="<%=host%>" />
    <jsp:setProperty name="mySessionHandler" property="perlEnvVar" 
               	value="<%=application.getInitParameter(\"perlEnvVar\") %>" />    
	<jsp:setProperty name="mySessionHandler" property="adminEmail" 
               	value="<%=application.getInitParameter(\"adminEmail\") %>" />
	<jsp:setProperty name="mySessionHandler" property="maxRThreadCount" 
               	value="<%=application.getInitParameter(\"maxRThreadCount\") %>" />
    <jsp:setProperty name="mySessionHandler" property="dbExtFileDir" 
               	value="<%=application.getInitParameter(\"dbExtFileDir\") %>" />
    <jsp:setProperty name="mySessionHandler" property="session" value="<%=session%>" />
</jsp:useBean>
	

<jsp:useBean id="myArray" class="edu.ucdenver.ccp.PhenoGen.data.Array"/>

<%@ include file="/web/common/common_vars.jsp"%>

<%
	/*if((String) session.getAttribute("perlDir")==null){
		session.setAttribute("applicationRoot",application.getInitParameter("applicationRoot")+"/");
		session.setAttribute("contextRoot",application.getInitParameter("contextRoot")+"/");
		session.setAttribute("userFilesRoot",application.getInitParameter("userFilesRoot")+"/");
		session.setAttribute("webDir",application.getInitParameter("webDir")+"/");
		session.setAttribute("r_FunctionDir",application.getInitParameter("r_FunctionDir")+"/");
		session.setAttribute("accessDir",application.getInitParameter("accessDir")+"/");
		session.setAttribute("aptDir",application.getInitParameter("aptDir")+"/");
		session.setAttribute("datasetsDir",application.getInitParameter("datasetsDir")+"/");
		session.setAttribute("experimentsDir",application.getInitParameter("experimentsDir")+"/");
		session.setAttribute("geneListsDir",application.getInitParameter("geneListsDir")+"/");
		session.setAttribute("qtlsDir",application.getInitParameter("qtlsDir")+"/");
		session.setAttribute("exonDir",application.getInitParameter("exonDir")+"/");
		session.setAttribute("ucscGeneDir",application.getInitParameter("ucscGeneDir")+"/");
		session.setAttribute("ucscDir",application.getInitParameter("ucscDir")+"/");
		session.setAttribute("bedDir",application.getInitParameter("bedDir")+"/");
		session.setAttribute("sysBioDir",application.getInitParameter("sysBioDir")+"/");
		session.setAttribute("imagesDir",application.getInitParameter("imagesDir")+"/");
		session.setAttribute("commonDir",application.getInitParameter("commonDir")+"/");
		session.setAttribute("propertiesDir",application.getInitParameter("propertiesDir")+"/");
		session.setAttribute("adminDir",application.getInitParameter("adminDir")+"/");
		session.setAttribute("isbraDir",application.getInitParameter("isbraDir")+"/");
		session.setAttribute("helpDir",application.getInitParameter("helpDir")+"/");
		session.setAttribute("javascriptDir",application.getInitParameter("javascriptDir")+"/");
		session.setAttribute("perlDir",application.getInitParameter("perlDir")+"/");
		session.setAttribute("dbPropertiesFile",application.getInitParameter("propertiesDir")+"/"+application.getInitParameter("dbPropertiesFile"));
		session.setAttribute("ENSDbPropertiesFile",application.getInitParameter("propertiesDir")+"/"+application.getInitParameter("ENSDbPropertiesFile"));
		session.setAttribute("host",host);
		session.setAttribute("perlEnvVar",application.getInitParameter("perlEnvVar"));
		session.setAttribute("adminEmail",application.getInitParameter("adminEmail"));
		session.setAttribute("maxRThreadCount",application.getInitParameter("maxRThreadCount"));
		session.setAttribute("dbExtFileDir",application.getInitParameter("dbExtFileDir")+"/");
	}*/
	
	//
	// these 4 have the full path specified
	//
	String rFunctionDir = mySessionHandler.getR_FunctionDir(); 
	String perlDir = mySessionHandler.getPerlDir(); 
	String propertiesDir = mySessionHandler.getPropertiesDir();
	String aptDir = mySessionHandler.getAptDir(); 
	String dbExtFileDir=mySessionHandler.getDbExtFileDir();
	
	String contextRoot = mySessionHandler.getContextRoot();
	String webDir = mySessionHandler.getWebDir();
	String datasetsDir = mySessionHandler.getDatasetsDir();
	String experimentsDir = mySessionHandler.getExperimentsDir();
	String geneListsDir = mySessionHandler.getGeneListsDir();
	String qtlsDir = mySessionHandler.getQtlsDir();
	String exonDir = mySessionHandler.getExonDir();
	String ucscDir = mySessionHandler.getUcscDir();
	String ucscGeneDir = mySessionHandler.getUcscGeneDir();
	String bedDir = mySessionHandler.getBedDir();
	String sysBioDir = mySessionHandler.getSysBioDir();
	String imagesDir = mySessionHandler.getImagesDir();
	String accessDir = mySessionHandler.getAccessDir();
	String commonDir = mySessionHandler.getCommonDir();
	String adminDir = mySessionHandler.getAdminDir();
	String isbraDir = mySessionHandler.getIsbraDir();
	String helpDir = mySessionHandler.getHelpDir();
	String javascriptDir = mySessionHandler.getJavascriptDir();
	String dbPropertiesFile = mySessionHandler.getDbPropertiesFile();
	String ensDbPropertiesFile = mySessionHandler.getENSDbPropertiesFile();  

	String userFilesRoot = mySessionHandler.getUserFilesRoot() + "/"; 
	String mainURL = mySessionHandler.getMainURL();
	String downloadURL = mySessionHandler.getDownloadURL();
	
	String perlEnvVar = mySessionHandler.getPerlEnvVar();
	String adminEmail = mySessionHandler.getAdminEmail();
	String maxRThreadCount= mySessionHandler.getMaxRThreadCount();
	String applicationRoot = mySessionHandler.getApplicationRoot();
	
	
		String sessionID = (String) session.getAttribute("sessionID");
		String analysisPath = (String) session.getAttribute("analysisPath");
		String[][] qtlResult = (String[][]) session.getAttribute("qtlResult");

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
	
	int windowWidth=1000;
        String onClickString = "";
        action = (String)request.getParameter("action");
		
	//DataSource pool=null;
	if(session.getAttribute("dbPool")!=null){
		pool=(DataSource)session.getAttribute("dbPool");
		log.debug("DB POOL SETUP");
	}
	
	try{
		Connection test=pool.getConnection();
		test.close();
	}catch(Exception e){
		session.setAttribute("errorPageMsg","The Database is currently unavailable.  The administrator has been notified and every effort will be made to return the database as soon as possible.");
		response.sendRedirect(commonDir +"errorPage.jsp");
	}

	// this file has to be after the logger initialization and no line breaks 
	//to avoid extra lines in the html 
%>	

<%
	if(!loginEnabled){
		response.sendRedirect(accessDir +"siteDownPage.jsp");
	}else if(pool==null){
		session.setAttribute("errorPageMsg","The Database is currently unavailable.  The administrator has been notified and every effort will be made to return the database as soon as possible.");
		response.sendRedirect(commonDir +"errorPage.jsp");
	}else{
		if(!loggedIn){
			Connection conn=null;
			try{
				conn=pool.getConnection();
				userLoggedIn = myUser.getUser("anon", "4lesw7n35h!", conn);
				conn.close();
				log.debug("last_name = "+userLoggedIn.getLast_name() + ", id = "+userLoggedIn.getUser_id());
				if (userLoggedIn.getUser_id() == -1) {
						log.info("anon just failed to log in.");
						session.setAttribute("loginErrorMsg", "Invalid");
						response.sendRedirect(accessDir+ "loginError.jsp");
				} else {
						session.setAttribute("isAdministrator", "N");
						//log.debug("user is NOT an Administrator");
						session.setAttribute("isISBRA", "N");
						//log.debug("user is NOT an ISBRA");
						session.setAttribute("isPrincipalInvestigator", "N");
						//log.debug("user is NOT a PI");
						mySessionHandler.setSessionVariables(session, userLoggedIn);
						mySessionHandler.setSession_id(session.getId());
						mySessionHandler.setUser_id(userLoggedIn.getUser_id());
						conn=pool.getConnection();
						mySessionHandler.createSession(mySessionHandler, conn);
						conn.close();
						userFilesRoot = (String) session.getAttribute("userFilesRoot");
						userLoggedIn.setUserMainDir(userFilesRoot);
						session.setAttribute("userLoggedIn", userLoggedIn);
						userID = Integer.parseInt((String) session.getAttribute("userID"));
						session.setAttribute("userID", Integer.toString(userID));
						session.setAttribute("user", userID + "-"+ (String) session.getAttribute("userName"));
						session.setAttribute("full_name", (String) session.getAttribute("full_name"));
				}
			}catch(SQLException e){
			}finally{
				try{
					if(conn!=null)
						conn.close();
				}catch(SQLException er){
				}
			}
		   	
		}
		//userLoggedIn= (User) session.getAttribute("userLoggedIn");
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
	String user = userID + "-"+ userName;
	
    if (publicDatasets == null || privateDatasetsForUser == null) {
		Dataset myDataset = new Dataset();
		Dataset[] allDatasets = myDataset.getAllDatasetsForUser(userLoggedIn, pool);
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

