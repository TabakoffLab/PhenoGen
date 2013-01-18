<%--
*  Author: Cheryl Hornbaker
*  Created: Dec, 2010
*  Description:  This file establishes the beans and imports that are common to login_vars.jsp and  
*    and session_vars.jsp
*
*  Todo:
*  Modification Log:
*
--%>
<jsp:useBean id="myObjectHandler" class="edu.ucdenver.ccp.util.ObjectHandler"/>
<jsp:useBean id="myDebugger" class="edu.ucdenver.ccp.util.Debugger"/>
<jsp:useBean id="myUser" class="edu.ucdenver.ccp.PhenoGen.data.User"/>
<jsp:useBean id="myMessage" class="edu.ucdenver.ccp.PhenoGen.data.Message"/>
<jsp:useBean id="myFileHandler" class="edu.ucdenver.ccp.util.FileHandler"/>
<jsp:useBean id="myHTMLHandler" class="edu.ucdenver.ccp.PhenoGen.web.HTMLHandler"/>
<jsp:useBean id="myToolbar" class="edu.ucdenver.ccp.PhenoGen.util.Toolbar"/>
	<jsp:setProperty name="myToolbar" property="session" value="<%=session%>" />

<%@ page language="java"
        import="java.sql.*"
        import="java.net.URL"
        import="java.io.*"
        import="java.text.*"
        import="java.util.*"
        import="java.util.zip.*"
        import="javax.imageio.*"
        import="java.awt.image.*"
        import="org.apache.log4j.Logger"
        import="edu.ucdenver.ccp.util.*"
        import="edu.ucdenver.ccp.util.sql.*"
        import="edu.ucdenver.ccp.PhenoGen.util.*"
        import="edu.ucdenver.ccp.PhenoGen.data.*"
		import="edu.ucdenver.ccp.PhenoGen.data.Bio.*"
        import="edu.ucdenver.ccp.PhenoGen.data.internal.*"
        import="edu.ucdenver.ccp.PhenoGen.driver.*"
        import="edu.ucdenver.ccp.PhenoGen.tools.oe.*"
        import="edu.ucdenver.ccp.PhenoGen.tools.promoter.*"
        import="edu.ucdenver.ccp.PhenoGen.tools.literature.*"
        import="edu.ucdenver.ccp.PhenoGen.tools.idecoder.*"
        import="edu.ucdenver.ccp.PhenoGen.tools.mage.*"
        import="edu.ucdenver.ccp.PhenoGen.tools.analysis.*"
        import="edu.ucdenver.ccp.PhenoGen.tools.pathway.*"
		import="edu.ucdenver.ccp.PhenoGen.tools.databases.*"
        import="edu.ucdenver.ccp.PhenoGen.tools.*"
        import="edu.ucdenver.ccp.PhenoGen.web.*"
        import="edu.ucdenver.ccp.PhenoGen.web.mail.*"
        import="edu.ucdenver.ccp.iDecoder.*"
        import="au.com.forward.threads.*"
        import="org.ensembl.*"
        import="org.ensembl.driver.*"
        import="org.ensembl.datamodel.*"
	import="com.itextpdf.text.pdf.*"
	import="com.itextpdf.text.Document"
	import="com.itextpdf.text.Image"
%>
<%@ page session="true" %>
<%
        //
        // Initialize the logger to log debug messages
        //
        Logger log=null;
        //log = Logger.getRootLogger();
        log = Logger.getLogger("JSPLogger");

        int userID = -99;

        String action = (String)request.getParameter("action");

        String caller = request.getHeader("referer");
        String host = request.getHeader("host");
		String pageTitle="";
	session.setAttribute("host", host);
/*
	for (Enumeration itr = request.getHeaderNames(); itr.hasMoreElements();) {
		log.debug("header Names ="+itr.nextElement());
	}
	for (Enumeration itr = request.getHeaderNames(); itr.hasMoreElements();) {
		String headerName = (String) itr.nextElement();
		log.debug("header Value for " + headerName + " is  = "+request.getHeader(headerName));
	}
	log.debug("pathInfo =" + request.getPathInfo());
	log.debug("servletPath =" + request.getServletPath());
	log.debug("contentType =" + request.getContentType());
*/
%>
