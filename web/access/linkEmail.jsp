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

<jsp:useBean id="anonU" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser" scope="session" />


<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setDateHeader("Expires", 0);
    Properties myProperties = new Properties();
    File myPropertiesFile = new File(captchaPropertiesFile);
    myProperties.load(new FileInputStream(myPropertiesFile));
    String pub="";
    pub=myProperties.getProperty("PUBLIC");

    %>
    <style>
        input:required:invalid, input:focus:invalid {
            background-image: url(<%=imagesDir%>error.png);
            background-position: right top;
            background-repeat: no-repeat;
        }
        input:required:valid {
            background-image: url(<%=imagesDir%>success.png);
            background-position: right top;
            background-repeat: no-repeat;
        }
    </style>
    
<%if(anonU.getEmail().equals("")){%>
<form method="post" 
      action="" 
        enctype="application/x-www-form-urlencoded">
    <div id="linkForm" style="text-align: left;">
        <div>
            By completing this form you will be able to request an email to recover this session on a different computer or browser.  You also will be able to receive alerts when tools that require extra time complete.
            <BR><BR>
            Email Address: <BR>
            <input type="email"  id="emailTxt" style="width:90%;height:34px;" value="<%=anonU.getObfuscatedEmail()%>" required>
        </div>
        <BR>
        <div>
        <span id="captcha"  ></span>
        </div>
        <BR>

        <input type="button" name="action" value="Link Email" onClick="saveEmail()" id="linkEmailSubmitBtn">
    </div><BR>
<span id="linkStatus"></span>
</form>
<!--<script src='https://www.google.com/recaptcha/api.js'></script>-->
<script type="text/javascript">
    
    grecaptcha.render('captcha', {
          'sitekey' : '<%=pub%>'
        });
        
    function saveEmail(){
        var email=$("#emailTxt").val();
        var gresp=$("#g-recaptcha-response").val();
        
        
        $.ajax({
                                    url: "<%=contextRoot%>/web/access/saveLinkEmail.jsp",
                                    type: 'GET',
                                    cache: false,
                                    data: { "uuid":PhenogenAnonSession.UUID, "email":email,"g-recaptcha-response":gresp },
                                    dataType: 'json',
                                    beforeSend: function(){
                                        $("#linkStatus").html("Submitting...");
                                    },
                                    success: function(data2){
                                         console.log(data2);
                                         $("#linkStatus").html(data2.status);
                                         if(data2.status==="Successfully linked email address."){
                                             $("#linkForm").hide();
                                             setTimeout(function(){
                                                    $('#linkEmailDialog').dialog("close");
                                                },5000);      
                                         }
                                    },
                                    error: function(xhr, status, error) {
                                        console.log("ERROR:"+error);
                                        $("#linkStatus").html(error);
                                    }
                                });
        
    }
</script>

<%}else{%>
    An email has already been set for this session.
<BR><BR>
     Email Address: <BR>
     <input type="email"  id="emailTxt" style="width:90%;height:34px;" value="<%=anonU.getObfuscatedEmail()%>" required>
<%}%>

