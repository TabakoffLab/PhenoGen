<%@ include file="/web/common/anon_session_vars.jsp" %>

<jsp:useBean id="myAnonUser" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser"> </jsp:useBean>
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
   
    String email="";
    if(request.getParameter("email") != null){
        email=FilterInput.getFilteredInputEmail(request.getParameter("email"));
    }
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
            ArrayList<String> list=myAnonUser.getAnonSessionListByEmail(email,pool);
            try{
                mySessionHandler.sendAnonSessionRecoveryEmail(list,email);
                status="Recovery Email has been sent.";
            }catch(MessagingException e){
                status="There was an error sending your email.  Please try again later.";
                Email myAdminEmail = new Email();
		myAdminEmail.setSubject("Exception thrown sending Session Recovery Email");
		myAdminEmail.setContent("There was an error sending Anonymous Session Recovery Email.\n"+ e.toString());
		try {
			myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
		} catch (Exception mailException) {
			log.error("error sending message", mailException);
			throw new RuntimeException();
		}
            }
        }else{
            status="Captcha response was invalid please try again.";
        }   
    }else{
        status="Invalid email address entered. Please correct and try again.";
    }
    
%>

{"status":"<%=status%>"}


