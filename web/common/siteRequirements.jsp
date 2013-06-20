<%--
 *  Author: Spencer Mahaffey
 *  Created: March, 2012
 *  Description:  The web page created by this file displays info on browsers supported and software required.        
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/access/include/login_vars.jsp" %>

<jsp:useBean id="myDbUtils" class="edu.ucdenver.ccp.PhenoGen.util.DbUtils"> </jsp:useBean>
<%
        extrasList.add("index.css");
%>
<%pageTitle="Browser/Software Requirements";%>

<%@ include file="/web/common/header.jsp" %>

        <div id="overview-content">
        <div id="welcome" style="height:735px; width:946px;">

                <h2>Supported Browsers</h2>
                <p>
                	Firefox 10.0+<BR />
                    Safari 5.0+<BR />
                    Chrome 17+<BR />
                    IE 9+ <BR />
				</p>
                <BR /><BR />
		<h2>Additional Software Required</h2>
        <BR />
        <ul>
        	<li>JavaScript must be enabled. (
            		<span id="noJSsite" style="color:#FF0000;display:inline-block;" >JavaScript is Currently Disabled.</span>
                    <span id="JSsite" style="color:#009900;display:none;">Your Browser Has JavaScript Enabled.</span>)
           	</li><BR /><BR />
        	<script type="text/javascript">
				$('#JSsite').show();
				$('#noJSsite').hide();
			</script>
        
            <li>Java Plugin JRE 1.6+ is required for part of the Gene View in the Detailed Genome/Transcription Information feature.<BR />
                (<span id="minJava" style="color:#009900;display:none;" >Java plugin meets the minimum requirements. <BR /></span>
                <span id="oldJava" style="color:#FF0000;display:none;">A new version may be available click the Install button for the latest version.</span>
                <span id="noJava" style="color:#FF0000;display:none;"> A newer version is required click the Install button for the latest version.</span><span id="installJava" class="button">Install Java</span>)
            </li><BR /><BR />
        	<span id="disabledJava" style="display:none;margin-left:40px;"><span style="color:#FF0000;">Java has been disabled in your browser.</span><BR />
            To enable Java in your browser or operating system, see:<BR><BR> 
            Firefox: <a href=\"http://support.mozilla.org/en-US/kb/unblocking-java-plugin\">http://support.mozilla.org/en-US/kb/unblocking-java-plugin</a><BR><BR>
            Internet Explorer: <a href=\"http://java.com/en/download/help/enable_browser.xml\">http://java.com/en/download/help/enable_browser.xml</a><BR><BR>
            Safari: <a href=\"http://docs.info.apple.com/article.html?path=Safari/5.0/en/9279.html\">http://docs.info.apple.com/article.html?path=Safari/5.0/en/9279.html</a><BR><BR>
            Chrome: <a href=\"http://java.com/en/download/faq/chrome.xml\">http://java.com/en/download/faq/chrome.xml</a><BR></span><BR /><BR />
        
		
		
		<script src="http://www.java.com/js/deployJava.js"></script>
		<script type="text/javascript">
            // check if current JRE version is greater than 1.5.0 
            if (deployJava.versionCheck('1.5.0+') == false) { 
				$('#noJava').css("display","inline-block");                  
                $('#installJava').css("display","inline-block");
            }else{
				$('#minJava').css("display","inline-block");
				if (deployJava.versionCheck('1.7.0+') == false) {                   
                	$('#oldJava').css("display","inline-block");
					$('#installJava').html("Update Java");
					$('#installJava').css("display","inline-block");
            	}else{
					$('#installJava').css("display","none");
				}
				if(!navigator.javaEnabled()){
					$('#disabledJava').css("display","inline-block");
				}
			}
			
        </script>
        
		</ul>
        
        
<script type="text/javascript">
	$(document).ready(function() {
		
		$('#installJava').click(function (){
			// Set deployJava.returnPage to make sure user comes back to 
        	// your web site after installing the JRE
            deployJava.returnPage = location.href;
                    
           	// Install latest JRE or redirect user to another page to get JRE
            deployJava.installLatestJRE(); 
		});	
	});
	
	
</script>        

<%@ include file="/web/common/footer.jsp" %>
