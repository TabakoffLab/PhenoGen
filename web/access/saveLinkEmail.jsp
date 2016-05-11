<%@ include file="/web/common/anon_session_vars.jsp" %>
<%--
 *  Author: Spencer Mahaffey
 *  Created: May, 2016
 *  Description:  Provides method for user to link email to an anonymous session so they can recover session from emailed link.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%
    Properties myProperties = new Properties();
    File myPropertiesFile = new File(captchaPropertiesFile);
    myProperties.load(new FileInputStream(myPropertiesFile));
    String pub="";
    String secret="";
    pub=myProperties.getProperty("PUBLIC");
    secret=myProperties.getProperty("SECRET");
    String status="Failed please try again";
    
    String remoteIP=request.getRemoteAddr();
    String gResponse="";
    if(request.getParameter("g-recaptcha-response")!=null){
        gResponse=request.getParameter("g-recaptcha-response");
    }
    reCaptcha re=new reCaptcha();
    if (re.checkResponse(secret,gResponse,remoteIP)) {
        status="Successfully linked email address.";
    }else{
        status="Captcha response was invalid please try again.";
    }   
    
%>

{"status":"<%=status%>"}


