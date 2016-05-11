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

    %>

<form method="post" 
      action="" 
        enctype="application/x-www-form-urlencoded">
    <div id="linkForm">
        <span>
        Email to use to recover session: <input type="text" id="emailTxt">
        </span>
        <span>
        <span id="captcha"  ></span>
        </span>


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
        console.log("saveEmail");
        console.log(email);
        console.log(gresp);
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
                                                    linkEmailDialog.dialog("close");
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

