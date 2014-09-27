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
<%		extrasList.add("normalize.css");
        extrasList.add("index.css");
%>
<%pageTitle="Browser/Software Requirements";
pageDescription="Browser and Software Requirements for PhenoGen";
%>

<%@ include file="/web/common/header.jsp" %>

        <div id="overview-content">
        <div id="welcome" style="height:735px; width:946px;">

                <h2>Supported Browsers</h2>
                	We recommend the most current version of any browser.  Most of the javascript libraries used on the site are tested with the current and current-1 versions of popular browsers.  We have attempted to make sure all the features work as expected in current browser versions of Firefox, Safari, Chrome, and Internet Explorer.  Please let us know if you experience problems and please include your browser and version in any correspondence.  If you experience sluggish performance with the Genome/Transcriptome Browser we have found that Chrome seems to handle the grpahics better than most other browsers.
                    <BR />
                    <BR />
                <p>
                	Firefox 23.0+ (31+ is recommended)<BR />
                    Safari 6.0+ (6.1+ is recommended)<BR />
                    Chrome 25+ (36+ is recommeded)<BR />
                    IE 10+ (Most features will still work with IE 9, but the Genome/Transcriptome Data Browser will NOT work)  (11+ is recommeded)<BR />
				</p>
                <BR /><BR />
        <h2>System requirements</h2>
        	The Genome/Transcriptome Data Browser section of the site does require a higher amount of RAM than most websites.  Depending on your view/track settings the RAM required may approach 1GB for your browser.  Multicore processors are recommended.  This is due to rendering most of the data on your computer instead of generating graphics on the server and loading them over the network.  This provides a faster and more interactive experience, but does place more load on your computer than most other websites.
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
