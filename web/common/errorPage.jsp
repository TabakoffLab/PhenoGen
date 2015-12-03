<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  The web page created by this file displays error information. 
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/access/include/login_vars.jsp" %> 
<%@ page isErrorPage="true" %>
<%@ page language="java"
        import="org.apache.log4j.Logger" 
        import="edu.ucdenver.ccp.PhenoGen.data.Experiment" 
        import="edu.ucdenver.ccp.PhenoGen.data.GeneList" 
        import="edu.ucdenver.ccp.PhenoGen.data.Dataset" 
%> 
<jsp:useBean id="myEmail" class="edu.ucdenver.ccp.PhenoGen.web.mail.Email"/> 
<%


        //
        // Initialize the logger to log debug messages
        //
	log.info("in errorPage.jsp");
	
	String errorPageMsg="";
        String userName = "";
        String analysisPath = ""; 
        String content = ""; 

	String sessionAlive = (String) request.getSession(false).getAttribute("userID");
	if(session.getAttribute("errorPageMsg")!=null){
		errorPageMsg=(String)session.getAttribute("errorPageMsg");
	}
	if (sessionAlive != null && !sessionAlive.equals("")) {
        	host = request.getHeader("host");
        	userName = (String) session.getAttribute("userName");
        	analysisPath = (String) session.getAttribute("analysisPath");
	        selectedExperiment = 
				((Experiment) session.getAttribute("selectedExperiment") == null ? 
				new Experiment() :
                                (Experiment) session.getAttribute("selectedExperiment"));
	        selectedGeneList = 
				((GeneList) session.getAttribute("selectedGeneList") == null ? 
				new GeneList() :
                                (GeneList) session.getAttribute("selectedGeneList"));
	        selectedDataset = 
				((Dataset) session.getAttribute("selectedDataset") == null ? 
				new Dataset() :
                                (Dataset) session.getAttribute("selectedDataset"));
		selectedDatasetVersion = 
				((Dataset.DatasetVersion) session.getAttribute("selectedDatasetVersion") == null ? 
				new Dataset().new DatasetVersion(-99) :
				(Dataset.DatasetVersion) session.getAttribute("selectedDatasetVersion"));

        	myEmail.setSubject("User '"+ userName + 
				"' encountered '" + request.getAttribute("javax.servlet.error.exception") + 
				"' error on PhenoGen website"); 

		caller = request.getHeader("referer");

		content = "Host:  "+ host + "\n" +
			"Gene List:  " + selectedGeneList.getGene_list_name() + "\n" +
			"Analysis Path:  " + analysisPath + "\n" +
			"Experiment:  " + selectedExperiment.getExp_name() + "\n" +
			"Dataset:  " + selectedDataset.getName() + "\n" +
			"Dataset Path:  " + selectedDatasetVersion.getVersion_path() + "\n" +
			"Type of error:  " + request.getAttribute("javax.servlet.error.exception") + "\n" + 
			"Name of program:  " + request.getAttribute("javax.servlet.error.request_uri") + "\n" +
			"Status Code:  " + request.getAttribute("javax.servlet.error.status_code") + "\n" + 
			"Error Message:  " + request.getAttribute("javax.servlet.error.message") + "\n" + 
                        "Browser Info: " + caller.getAttribute("geneTxt")+"\n"+ 
			"Location of Error:  \n"; 

		Throwable error = (Throwable)request.getAttribute("javax.servlet.error.exception");
		StackTraceElement[] stack = null;
		 if (error.getStackTrace() != null) {
                        stack = error.getStackTrace();
                        for(int n = 0; n < Math.min(10, stack.length); n++) {
                                content = content + "\n" + stack[n].toString();
                        }
                }

		Throwable servletExceptionCause = null; 
		if(error instanceof ServletException) {
			servletExceptionCause = ((ServletException)error).getRootCause();
		} else {
			servletExceptionCause = error.getCause();
		}
	 
		if(servletExceptionCause != null) { 
			stack = servletExceptionCause.getStackTrace();
			for(int n = 0; n < Math.min(10, stack.length); n++) { 
				content = content + "\n" + stack[n].toString(); 
			}
		} 
		myEmail.setContent(content);
		log.debug("Sending an email message notifying phenogen.help that an error has occurred.");
        	try {
        		myEmail.sendEmailToAdministrator(adminEmail);
			mySessionHandler.createSessionActivity(session.getId(), "Got error:  " + content, pool);
        	} catch (Exception e) {
                	log.error("exception while trying to send message to phenogen.help about an error on website", e);
        	}
	} else {
		log.debug("session is not alive");
/*
		caller = request.getHeader("referer");
		content =
			"Session is not alive" + "\n\n" + 
			"Type of error:  " + request.getAttribute("javax.servlet.error.exception") + "\n" +
			"Name of program:  " + request.getAttribute("javax.servlet.error.request_uri") + "\n" +
			"Status Code:  " + request.getAttribute("javax.servlet.error.status_code") + "\n" +
		"Error Message:  " + request.getAttribute("javax.servlet.error.message") + "\n";
		Throwable error = (Throwable)request.getAttribute("javax.servlet.error.exception");
		StackTraceElement[] stack = null;
		if (error != null && error.getStackTrace() != null) {
			stack = error.getStackTrace();
			for(int n = 0; n < Math.min(10, stack.length); n++) {
				content = content + "\n" + stack[n].toString();
			}
		}
		log.debug("content = "+content);
*/
	}

%>
<%@ include file="/web/common/basicHeader.jsp" %>
<div id="site-wrap">
<%if(!errorPageMsg.equals("")){
	if(errorPageMsg.contains("Database")&&errorPageMsg.contains("unavailable")){%>
    	<h2>Database currently unavailable</h2>
	<%}%>
	<strong><%=errorPageMsg%></strong>
<%}else{%>
	<h2>Sorry, but an error has occurred.</h2>
    <strong> 
    	The system administrator has been notified and will investigate the problem.  Please check back later.
    </strong>
<%}%>
 
<br>
<br>
<%if(request.getAttribute("javax.servlet.error.exception")!=null){%>
    Type of error:  <%=request.getAttribute("javax.servlet.error.exception") %>
    <br>
<%}%>
<%if(request.getAttribute("javax.servlet.error.request_uri")!=null){%>
Name of program:  <%=request.getAttribute("javax.servlet.error.request_uri")%>
<br>
<%}%>
<%if(request.getAttribute("javax.servlet.error.message")!=null){%>
Error Message:  <%=request.getAttribute("javax.servlet.error.message") %>
<BR>
<%}%>
<%if(content!=null){%>
Content: <%=content%> 
<BR>
<%}%>
<a href="<%=caller%>">Previous Page</a>
<BR>
</div>
<%@ include file="/web/common/basicFooter.jsp"  %>

