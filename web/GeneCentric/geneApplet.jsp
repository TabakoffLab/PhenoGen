<%@ include file="/web/common/session_vars.jsp" %>

<%@ include file="/web/common/header_noBorder_noMenu.jsp" %>
<%
	String selectedID="";
	if(request.getParameter("selectedID")!=null){
		selectedID=request.getParameter("selectedID");
	}
	String genURL="";
	String urlPrefix=(String)session.getAttribute("mainURL");
    if(urlPrefix.endsWith(".jsp")){
         urlPrefix=urlPrefix.substring(0,urlPrefix.lastIndexOf("/")+1);
    }
	genURL=urlPrefix+ "tmpData/geneData/" +selectedID+"/";
%>
<script type="text/javascript">
	$('#wait1').hide();
	var selectedID="<%=selectedID%>";
	var genURL="<%=genURL%>";
</script>


<div id="unsupportedChrome" style="display:none;color:#FF0000;">A Java plug in is required to view this page.  Chrome is a 32-bit browser and requires a 32-bit plug-in which is unavailable for Mac OS X.  
            	Please try using Safari or FireFox with the Java Plug in installed.  Note: In browsers that support the 64-bit plug in you will be prompted to install Java if it is not already installed.</div>

<div id="macBugDesc" style="display:none;color:#FF0000;">The applet above is fully functional.  However, with your current combination of Mac OS X and Java plug-in the display is not optimal due to a bug.  When Oracle fixes this bug we will update the applet to provide a more optimal experience.  We are very sorry for any inconvenience.  This bug is not found in Windows, Linux, Mac OS X 10.6 or lower if you have any of them available.</div>
        <BR /><BR /><BR />
        <script type="text/javascript" src="http://www.java.com/js/deployJava.js"></script>
        <script type="text/javascript">
			var ensembl=selectedID;
			var appletWidth=1000;
			var appletHeight=1200;
			var jre=deployJava.getJREs();
			var bug=0;
			var bugString='false';
			var unsupportedChrome=0;
	
			//alert("Initial:"+jre+":"+navigator.userAgent);
			if (/Mac OS X[\/\s](\d+[_\.]\d+)/.test(navigator.userAgent)){ //test for Firefox/x.x or Firefox x.x (ignoring remaining digits);
 					//var macVersion=new Number(RegExp.$1); // capture x.x portion and store as a number
					var tmpAgent=new String(navigator.userAgent);
					//alert("Detected Mac OS X:"+tmpAgent);
					if(/Chrome/.test(tmpAgent)){
						var update=new String(jre);
						//alert("chrome update:"+update);
						if(update.length==0){
							//alert("unsupported");
							unsupportedChrome=1;
						}
					}
					else if (/10[_\.][789]/.test(tmpAgent)){
						//alert("Mac Ver >=10.7:");
						var tmpUp=new String(jre);
						var update=tmpUp.substr((tmpUp.indexOf("_")+1));
						//alert("update:"+update);
						if(update>=10){
							//alert("update >10");
								bug=1;
								appletHeight=700;
								bugString='true';
						}
					}
			}
			if(unsupportedChrome==0){
				var attributes = {
					id:			'geneApplet',
					code:       "genecentricviewer.GeneCentricViewer",
					archive:    "/web/GeneCentric/GeneCentricViewer.jar",
					width:      appletWidth,
					height:     appletHeight
				};
				var parameters = {
					java_status_events: 'true',
					jnlp_href:"/web/GeneCentric/launch.jnlp",
					main_ensembl_id:ensembl,
					genURL:genURL,
					macBug:bugString
				}; 
				var version = "1.6"; 
            	deployJava.runApplet(attributes, parameters, version);
			}else{
				$('#unsupportedChrome').show();
			}
			if(bug==1){
				$('div#macBugDesc').show();
			}
       
		</script>

<script type="text/javascript">
		
			function positionHelp(vertPos){
				if(ie){
						if(vertPos>300){
							$('.helpDialog').css({'top':300,'left':$(window).width()*0.3,'width':$(window).width()*0.3});
						}else{
							$('.helpDialog').css({'top':vertPos,'left':$(window).width()*0.3,'width':$(window).width()*0.3});
						}
				}else{
						$('.helpDialog').css({'top':vertPos,'left':$(window).width()*0.47,'width':$(window).width()*0.3});
				}
			}
			
			function openFilterDisplay(){
					$('#Help3Content').dialog("open").css({'height':300,'font-size':12});
					positionHelp(650);
			}
			
			function openParental(){
					$('#Help4Content').dialog("open").css({'height':300,'font-size':12});
					positionHelp(850);
			}
			
			function openHerit(){
					$('#Help5Content').dialog("open").css({'height':300,'font-size':12});
					positionHelp(850);
			}
			
			function openPanelExpression(){
					$('#Help6Content').dialog("open").css({'height':300,'font-size':12});
					positionHelp(850);
			}
			function openExonCorr(){
					$('#Help7Content').dialog("open").css({'height':300,'font-size':12});
					positionHelp(850);
			}
		/*$('.inpageHelpContent').hide();
  
		$('.inpageHelpContent').dialog({ 
					autoOpen: false,
					dialogClass: "helpDialog"
				});*/
</script>


