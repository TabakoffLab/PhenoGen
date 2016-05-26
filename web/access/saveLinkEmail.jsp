<%@ include file="/web/common/anon_session_vars.jsp" %>

<jsp:useBean id="myAnonUser" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser"> </jsp:useBean>
<jsp:useBean id="anonU" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser" scope="session" />

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
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setDateHeader("Expires", 0);
    Properties myProperties = new Properties();
    File myPropertiesFile = new File(captchaPropertiesFile);
    myProperties.load(new FileInputStream(myPropertiesFile));
    String pub="";
    String secret="";
    pub=myProperties.getProperty("PUBLIC");
    secret=myProperties.getProperty("SECRET");
    String status="Failed please try again";
   
    String uuid="";
    if(request.getParameter("uuid") != null){
        uuid=FilterInput.getFilteredInput(request.getParameter("uuid"));
    }
    String email="";
    if(request.getParameter("email") != null){
        email=FilterInput.getFilteredInputEmail(request.getParameter("email"));
    }
    log.debug(email);
    boolean match=Pattern.matches("^[a-zA-Z0-9\\.!#\\$%&'\\*\\+\\/=\\?\\^_`\\{|\\}~-]+@[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]?(?:\\.[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9])*$", email);
    //  ^[a-zA-Z0-9\\.\\-~_]+@[a-zA-Z0-9-]+([a-zA-Z0-9-\\.]+)$
    //  /^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/
    
    if(match){
        String remoteIP=request.getRemoteAddr();
        String gResponse="";
        if(request.getParameter("g-recaptcha-response")!=null){
            gResponse=request.getParameter("g-recaptcha-response");
        }
        reCaptcha re=new reCaptcha();
        if (re.checkResponse(secret,gResponse,remoteIP)) {
            AnonUser tmpU=myAnonUser.linkEmail(uuid,email,pool);
            if(tmpU.getEmail().equals(email)){
                anonU.setEmail(email);
                status="Successfully linked email address.";
            }else{
                status="Cannot update email address is already set.";
            }
        }else{
            status="Captcha response was invalid please try again.";
        }   
    }else{
        status="Invalid email address entered. Please correct and try again.";
    }
    
%>

{"status":"<%=status%>"}


