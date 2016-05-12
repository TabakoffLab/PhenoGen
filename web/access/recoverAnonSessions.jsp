<%@ include file="/web/common/anon_session_vars.jsp" %>
<%--
 *  Author: Spencer Mahaffey
 *  Created: May, 2016
 *  Description:  Provides method for user to request an email to recover session.
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
    

<form method="post" 
      action="" 
        enctype="application/x-www-form-urlencoded">
    <div id="recoverLinkForm" style="text-align: left;">
        <div>
            After submitting you will receive an email with links to recover any session associated with your email address.
            <BR><BR>
            Email Address: <BR>
            <input type="email"  id="recoveremailTxt" style="width:90%;height:34px;" value="" required>
        </div>
        <BR>
        <div>
        <span id="recovercaptcha"  ></span>
        </div>
        <BR>

        <input type="button" name="action" value="Request Session Links" onClick="recoverSession()" id="recoverSessionSubmitBtn">
    </div><BR>
<span id="recoverLinkStatus"></span>
</form>
<!--<script src='https://www.google.com/recaptcha/api.js'></script>-->
<script type="text/javascript">
    
    grecaptcha.render('recovercaptcha', {
          'sitekey' : '<%=pub%>'
        });
        
    function recoverSession(){
        var email=$("#recoveremailTxt").val();
        var gresp=$("#g-recaptcha-response").val();
        
        
        $.ajax({
                                    url: "<%=contextRoot%>/web/access/recoverSession.jsp",
                                    type: 'GET',
                                    cache: false,
                                    data: { "email":email,"g-recaptcha-response":gresp },
                                    dataType: 'json',
                                    beforeSend: function(){
                                        $("#recoverLinkStatus").html("Submitting...");
                                    },
                                    success: function(data2){
                                         console.log(data2);
                                         $("#recoverLinkStatus").html(data2.status);
                                         if(data2.status==="Recovery Email has been sent."){
                                             $("#recoverLinkForm").hide();
                                             setTimeout(function(){
                                                    $('#recoverSession').dialog("close");
                                                },5000);      
                                         }
                                    },
                                    error: function(xhr, status, error) {
                                        console.log("ERROR:"+error);
                                        $("#recoverLinkStatus").html(error);
                                    }
                                });
        
    }
</script>


