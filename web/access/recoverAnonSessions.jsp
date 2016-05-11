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

    if ((action != null) && action.equals("Link")) {
                    String remoteIP=request.getRemoteAddr();
                    String gResponse="";
                    if(request.getParameter("g-recaptcha-response")!=null){
                        gResponse=request.getParameter("g-recaptcha-response");
                    }
                    reCaptcha re=new reCaptcha();
                    if (re.checkResponse(secret,gResponse,remoteIP)) {
                        
                    }
    }
%>


<form method="post" 
		action="" 
		enctype="application/x-www-form-urlencoded"
                >
<div >
Email to use to recover session: <input type="text">
</div>
<div >
<span id="recovercaptcha"  ></span>
</span>
</div>

<input type="button" name="action" value="Link Email"  id="linkEmailSubmitBtn">
</form>
<!--<script src='https://www.google.com/recaptcha/api.js'></script>-->
<script type="text/javascript">

        grecaptcha.render('recovercaptcha', {
          'sitekey' : '<%=pub%>'
        });
</script>


