<%@ include file="/web/common/session_vars.jsp" %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<%
	
    gdt.setSession(session);
	ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> fullGeneList=new ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene>();
	String myOrganism="";
	String id="";
	String chromosome="";
	
	String[] selectedLevels=null;
	String levelString="core;extended;full";
	String fullOrg="";
		String panel="";
	String gcPath="";
	int selectedGene=0;
	ArrayList<String>geneSymbol=new ArrayList<String>();
	LinkGenerator lg=new LinkGenerator(session);
	
	
	
	if(request.getParameter("levels")!=null && !request.getParameter("levels").equals("")){			
				String tmpSelectedLevels = request.getParameter("levels");
				selectedLevels=tmpSelectedLevels.split(";");
				log.debug("Getting selected levels:"+tmpSelectedLevels);
				levelString = "";
				//selectedLevelError = true;
				for(int i=0; i< selectedLevels.length; i++){
					//selectedLevelsError = false;
					levelString = levelString + selectedLevels[i] + ";";
				}
	}else{
		log.debug("Getting selected levels: NULL Using defaults.");
		selectedLevels=levelString.split(";");
	}
	if(request.getParameter("species")!=null){
		myOrganism=request.getParameter("species").trim();
		if(myOrganism.equals("Rn")){
			panel="BNLX/SHRH";
			fullOrg="Rattus_norvegicus";
		}else{
			panel="ILS/ISS";
			fullOrg="Mus_musculus";
		}
	}
	if(request.getParameter("chromosome")!=null){
		chromosome=request.getParameter("chromosome");
	}
	
		
	if(request.getParameter("geneSymbol")!=null){
		geneSymbol.add(request.getParameter("geneSymbol"));
	}else{
		geneSymbol.add("None");
	}
	if(request.getParameter("id")!=null){
		id=request.getParameter("id");
	}
	
	gcPath=applicationRoot + contextRoot+"tmpData/geneData/" +id+"/";
	
	String[] tissuesList1=new String[1];
	String[] tissuesList2=new String[1];
	if(myOrganism.equals("Rn")){
		tissuesList1=new String[4];
		tissuesList2=new String[4];
		tissuesList1[0]="Brain";
		tissuesList2[0]="Whole Brain";
		tissuesList1[1]="Heart";
		tissuesList2[1]="Heart";
		tissuesList1[2]="Liver";
		tissuesList2[2]="Liver";
		tissuesList1[3]="Brown Adipose";
		tissuesList2[3]="Brown Adipose";
	}else{
		tissuesList1[0]="Brain";
		tissuesList2[0]="Whole Brain";
	}
	int rnaDatasetID=0;
	int arrayTypeID=0;
	
	int[] tmp=gdt.getOrganismSpecificIdentifiers(myOrganism,dbConn);
							if(tmp!=null&&tmp.length==2){
								rnaDatasetID=tmp[1];
								arrayTypeID=tmp[0];
							}
	String genURL="";
	String urlPrefix=(String)session.getAttribute("mainURL");
    if(urlPrefix.endsWith(".jsp")){
         urlPrefix=urlPrefix.substring(0,urlPrefix.lastIndexOf("/")+1);
    }
	genURL=urlPrefix+ "tmpData/geneData/" +id+"/";
	ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> tmpGeneList=gdt.getGeneCentricData(id,id,panel,myOrganism,rnaDatasetID,arrayTypeID);
	edu.ucdenver.ccp.PhenoGen.data.Bio.Gene curGene=null;
	for(int i=0;i<tmpGeneList.size();i++){
		log.debug("check:"+tmpGeneList.get(i).getGeneID()+":"+id);
		if(tmpGeneList.get(i).getGeneID().equals(id)){
			curGene=tmpGeneList.get(i);
		}
	}
%>


<!--<a href="web/GeneCentric/geneApplet.jsp?selectedID=<%=id%>" target="_blank">View Affy Probe Set Details</a>
<BR /><BR />
<div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000; text-align:left; width:100%; ">
    <span class="trigger less" name="geneReport"  style="margin-left:30px;">Gene Details</span>
    <div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div>
</div>
<div id="geneReport" >
Add report here.
</div>
<BR /><BR />
<div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000; text-align:left; width:100%; ">
    <span class="triggerNoAction" name="geneReportEQTL"  style="margin-left:30px;">Gene EQTLs (Circos Plot)</span>
    <div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div>
</div>
<div id="geneReportEQTL" style="display:none;"></div>
            
<BR /><BR />-->

<!--<script type="text/javascript">
	$("span[name='geneReportEQTL']").click(function (){
        var thisHidden = $("div#geneReportEQTL").is(":hidden");
        if (thisHidden) {
			$("div#geneReportEQTL").show();
			$(this).addClass("less");
			var jspPage="web/GeneCentric/geneEQTLAjax.jsp";
			var params={
				species: organism,
				geneSymbol: selectedGeneSymbol,
				chromosome: chr,
				id:selectedID
			};
			loadDivWithPage("div#geneReportEQTL",jspPage,params,
					"<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Laoding...</span>");
        } else {
			$("div#geneReportEQTL").hide();
			$(this).removeClass("less");
        }
		});
</script>-->

<div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000; text-align:left; width:100%; ">
    <span class="trigger less" name="geneDiv"  style="margin-left:30px;"></span>
    <span class="detailMenu selected" name="geneDetail">Gene Details<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div></span>
    <span class="detailMenu" name="geneEQTL">Gene EQTLs<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div></span>
    <span class="detailMenu" name="geneApp">Probe Set Level Data<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div></span>
</div>
<div id="geneDiv" style="display:inline-block;">
	<div style="display:inline-block;" id="geneDetail">
     
    </div>
    <div style="display:none;" id="geneEQTL">
    </div>
    <div style="display:none;" id="geneApp">
    		<div style="text-align:center;">
                <div id="javaError" style="display:none;">
                    <BR /><BR /><br />
                    <span style="color:#FF0000;">Error:</span>Java is required for the Detailed Transcription Information results for this page.  Please correct the error listed below.  <BR />
                    <BR />
                </div>
        		<div id="unsupportedChrome" style="display:none;color:#FF0000;">A Java plug in is required to view this page.  Chrome is a 32-bit browser and requires a 32-bit plug-in which is unavailable for Mac OS X.  
            	Please try using Safari or FireFox with the Java Plug in installed.  Note: In browsers that support the 64-bit plug in you will be prompted to install Java if it is not already installed.</div>
                <span id="disabledJava" style="display:none;margin-left:40px;">
                <span style="color:#FF0000;">Java has been disabled in your browser.</span><BR />
                            To enable Java in your browser or operating system, see:<BR><BR> 
                            Firefox: <a href="http://support.mozilla.org/en-US/kb/unblocking-java-plugin" target="_blank">http://support.mozilla.org/en-US/kb/unblocking-java-plugin</a><BR><BR>
                            Internet Explorer: <a href="http://java.com/en/download/help/enable_browser.xml" target="_blank">http://java.com/en/download/help/enable_browser.xml</a><BR><BR>
                            Safari: <a href="http://docs.info.apple.com/article.html?path=Safari/5.0/en/9279.html" target="_blank">http://docs.info.apple.com/article.html?path=Safari/5.0/en/9279.html</a><BR><BR>
                            Chrome: <a href="http://java.com/en/download/faq/chrome.xml" target="_blank">http://java.com/en/download/faq/chrome.xml</a><BR /><BR /></span>
                
                <span id="noJava" style="color:#FF0000;display:none;"> No Java Plug-in is installed or a newer version is required click the Install button for the latest version.<BR /></span>
                <span id="oldJava" style="color:#00AA00;display:none;">A newer Java version may be available click the Install button for the latest version.(You may still use all functions even if you see this message.)<BR /></span>
                <span id="installJava" style="display:none;" class="button">Install Java</span>
			</div>


	
            <!--<script>
                
    </script>-->


            
                <script type="text/javascript">
				var bug=0;
				var jre=deployJava.getJREs();
				var unsupportedChrome=0;
				// check if current JRE version is greater than 1.6.0 
                if(!navigator.javaEnabled()){
                        $('#javaError').css("display","inline-block");
                        $('#disabledJava').css("display","inline-block");
                }else if (deployJava.versionCheck('1.6.0+') == false) {
                     $('#javaError').css("display","inline-block");
                    $('#noJava').css("display","inline-block");                  
                    $('#installJava').css("display","inline-block");
                }else{
                    if (deployJava.versionCheck('1.7.0+') == false) {                   
                        $('#oldJava').css("display","inline-block");
                        $('#installJava').html("Update Java");
                        $('#installJava').css("display","inline-block");
                    }
                }
                $('#installJava').click(function (){
                    // Set deployJava.returnPage to make sure user comes back to 
                    // your web site after installing the JRE
                    deployJava.returnPage = location.href;
                            
                    // Install latest JRE or redirect user to another page to get JRE
                    deployJava.installLatestJRE(); 
                });	
				//alert("Initial:"+jre+":"+navigator.userAgent);
				if (/Mac OS X[\/\s](\d+[_\.]\d+)/.test(navigator.userAgent)){ //test for Firefox/x.x or Firefox x.x (ignoring remaining digits);
						//var macVersion=new Number(RegExp.$1); // capture x.x portion and store as a number
						var tmpAgent=new String(navigator.userAgent);
						//alert("Detected Mac OS X:"+tmpAgent);
						if(/Chrome/.test(tmpAgent) && /10[_\.][789]/.test(tmpAgent)){
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
							if(update>=10){
									bug=1;
							}
						}
				}
				if(unsupportedChrome==0){
					
				}else{
					$('#unsupportedChrome').show();
				}
				if(bug==1){
					$('div#macBugDesc').show();
				}
				</script>
        <div >
                        This feature requires Java which will open in a seperate window, when you click the button below.  If any problems were detected with your version of Java instructions would appear above.  Please continue if you do not see an error with instructions for fixing the error.<BR /><BR />
                        <span class="button" style="width:200px;"><a href="web/GeneCentric/geneApplet.jsp?selectedID=<%=id%>" target="_blank">View Affy Probe Set Details</a></span>
        </div>
 	</div>
 </div>
            




<script type="text/javascript">
	
	
	$('.detailMenu').click(function (){
		var oldID=$('.detailMenu.selected').attr("name");
		$("#"+oldID).hide();
		$('.detailMenu.selected').removeClass("selected");
		$(this).addClass("selected");
		var id=$(this).attr("name");
		$("#"+id).show();
		if(id=="geneEQTL"){
			var jspPage="web/GeneCentric/geneEQTLAjax.jsp";
			var params={
				species: organism,
				geneSymbol: selectedGeneSymbol,
				chromosome: chr,
				id:selectedID
			};
			loadDivWithPage("div#geneEQTL",jspPage,params,
					"<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Laoding...</span>");
		}
		
	});
</script>

