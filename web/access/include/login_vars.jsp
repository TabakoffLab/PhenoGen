<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  This file sets variables required when a user is not logged in.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/common/common_declarations.jsp"%>

<%@ include file="/web/common/common_vars.jsp"%>

<%-- These parameters are set in the WEB-INF/web.xml file.  This section executes the setXXX methods in SessionHandler --%>

<%-- *******************NOTE:Watch the value= section when you open this file in Dreamweaver  it for some reason removes the < in between " and %=  --%>

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
        <jsp:setProperty name="mySessionHandler" property="mongoDbPropertiesFile" 
               	value="<%=application.getInitParameter(\"mongoDbPropertiesFile\") %>" />
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
   <jsp:setProperty name="mySessionHandler" property="captchaPropertiesFile" 
               	value="<%=application.getInitParameter(\"captchaPropertiesFile\") %>" />
   	<jsp:setProperty name="mySessionHandler" property="DBMain" 
               	value="<%=application.getInitParameter(\"dbMain\") %>" />
</jsp:useBean>

<%

	//
	// these 4 have the full path specified
	//
	String rFunctionDir = mySessionHandler.getR_FunctionDir(); 
	String perlDir = mySessionHandler.getPerlDir(); 
	String propertiesDir = mySessionHandler.getPropertiesDir();
	String aptDir = mySessionHandler.getAptDir(); 
	String dbExtFileDir=mySessionHandler.getDbExtFileDir();

	//
	// all others need only the context path specified
	//
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
        String ucscDbPropertiesFile = mySessionHandler.getUCSCDbPropertiesFile();
        String mongoDbPropertiesFile = mySessionHandler.getMongoDbPropertiesFile();
	String captchaPropertiesFile = mySessionHandler.getCaptchaPropertiesFile();  

	String userFilesRoot = mySessionHandler.getUserFilesRoot() + "/"; 
	String mainURL = mySessionHandler.getMainURL();
	String downloadURL = mySessionHandler.getDownloadURL();
	
	String perlEnvVar = mySessionHandler.getPerlEnvVar();
	String adminEmail = mySessionHandler.getAdminEmail();
	String maxRThreadCount= mySessionHandler.getMaxRThreadCount();
	

        if(session.getAttribute("dbPool")!=null){
		pool=(DataSource)session.getAttribute("dbPool");
		log.debug("DB POOL SETUP");
	}else{
            pool=mySessionHandler.getDBPool();
            session.setAttribute("dbPool",pool);
        }
        if(pool!=null){
            try{
                Connection test=pool.getConnection();
                myUser.getUser("public",pool);
                test.close();
            }catch(Exception e){
                dbUnavail=true;
            }
        }
%>
	


<%-- this file has to be after the logger initialization --%>
<%--<%@ include file="/web/common/dbutil.jsp"  %>--%>

<%@ include file="/web/common/alertMsgSetup.jsp" %>

