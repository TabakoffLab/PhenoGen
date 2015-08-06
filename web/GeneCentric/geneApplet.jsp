<%@ include file="/web/common/anon_session_vars.jsp" %>

<%
	extrasList.add("detailedTranscriptInfo.js");
        extrasList.add("jquery.dataTables.min.js");
	extrasList.add("jquery.cookie.js");
	extrasList.add("d3.v3.min.js");
        extrasList.add("spectrum.js");
	extrasList.add("tabs.css");
	extrasList.add("tooltipster.min.css");
        extrasList.add("spectrum.css");
        //extrasList.add("jquery.dataTables.min.css");
	
%>

<%@ include file="/web/common/header_adaptive_noMenu.jsp" %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<jsp:useBean id="myFH" class="edu.ucdenver.ccp.util.FileHandler"/>


<%
gdt.setSession(session);
String chromosome="",panel="",myOrganism="Rn",viewID="10";
int min=0,max=0,rnaDatasetID=0,arrayTypeID=0;

String selectedID="";

	if(request.getParameter("selectedID")!=null){
		selectedID=request.getParameter("selectedID");
	}
	if(request.getParameter("defaultView")!=null){
		viewID=request.getParameter("defaultView");
	}

if(request.getParameter("panel")!=null){
		panel=request.getParameter("panel").trim();
}
if(request.getParameter("myOrganism")!=null){
		myOrganism=request.getParameter("myOrganism").trim();
}
if(request.getParameter("rnaDatasetID")!=null){
	try{
		rnaDatasetID=Integer.parseInt(request.getParameter("rnaDatasetID").trim());
	}catch(NumberFormatException e){
		log.error("Number format exception:rnaDatasetID\n",e);
	}
}
if(request.getParameter("arrayTypeID")!=null){
	try{
		arrayTypeID=Integer.parseInt(request.getParameter("arrayTypeID").trim());
	}catch(NumberFormatException e){
		log.error("Number format exception:arrayTypeID\n",e);
	}
}

	String tmpoutputDir = applicationRoot+contextRoot+ "tmpData/geneData/" + selectedID + "/";
	String[] loc=null;
        try{
                loc=myFH.getFileContents(new File(tmpoutputDir+"location.txt"));
        }catch(IOException e){
                log.error("Couldn't load location for gene.",e);
        }
        if(loc!=null){
                chromosome=loc[0];
                min=Integer.parseInt(loc[1]);
                max=Integer.parseInt(loc[2]);
        }
	String tmpOutput=gdt.getImageRegionData(chromosome, min, max, panel, myOrganism, rnaDatasetID, arrayTypeID, 0.001,false);
	int startInd=tmpOutput.lastIndexOf("/",tmpOutput.length()-2);
	String folderName=tmpOutput.substring(startInd+1,tmpOutput.length()-1);
	
	String genURL="";
	String urlPrefix=(String)session.getAttribute("mainURL");
        if(urlPrefix.endsWith(".jsp")){
             urlPrefix=urlPrefix.substring(0,urlPrefix.lastIndexOf("/")+1);
        }
        if(request.getServerPort()!=80 && urlPrefix.indexOf("https")<0){
            urlPrefix=urlPrefix.replace("http","https");
        }
	genURL=urlPrefix+ "tmpData/geneData/" +selectedID+"/";
	String regionURL=urlPrefix+"tmpData/regionData/"+folderName+"/";
	
%>

<%@ include file="/web/GeneCentric/browserCSS.jsp" %>
<style>
	.ui-widget { font-size:0.8em;}
</style>
<script type="text/javascript">
	$('#wait1').hide();
	var urlprefix="<%=host+contextRoot%>";
	var selectedID="<%=selectedID%>";
	var genURL="<%=genURL%>";
	var regionURL="<%=regionURL%>";
	var minCoord=<%=min%>;
	var maxCoord=<%=max%>;
	var initMin=<%=min%>;
	var initMax=<%=max%>;
	var panel="<%=panel%>";

	var chr="<%=chromosome%>";
	var rnaDatasetID=<%=rnaDatasetID%>;
	var arrayTypeID=<%=arrayTypeID%>;
	var pValueCutoff=0.001;
	var forwardPValueCutoff=0.001;

	var organism="<%=myOrganism%>";
	var ucsctype="region";
	var ucscgeneID="";
	var defaultView="viewAll";
	var selectGene="";
	var folderName="<%=folderName%>";
	var pathPrefix="";
	var dataPrefix="../../";
	var regionfolderName="<%=folderName%>";
	var skipSetSelection=1;
	var iconPath="<%=imagesDir%>icons/";
	var trackMenu=[];
	var viewMenu=[];
	<%if(userLoggedIn.getUser_name().equals("anon")){%>
		var uid=0;
	<%}else{%>
		var uid=<%=userLoggedIn.getUser_id()%>;
	<%}%>
	//Bugsense.addExtraData('page', 'geneApplet.jsp');
	//Bugsense.addExtraData( 'region','<%=selectedID+"::"+chromosome+":"+min+"-"+max%>');
</script>
<div id="imageMenu"></div>
<div id="viewMenu"></div>
<div id="trackMenu"></div>
    <!--<div style="font-size:18px; font-weight:bold; background-color:#FFFFFF; color:#000000; text-align:center; width:100%; padding-top:3px;">
    		View:
    		<span class="viewMenu" name="viewGenome" >Genome<div class="inpageHelp" style="display:inline-block; "><img id="HelpImageGenomeView" class="helpImage" src="<%=imagesDir%>icons/help.png" /></div></span>
    		<span class="viewMenu" name="viewTrxome" >Transcriptome<div class="inpageHelp" style="display:inline-block; "><img id="HelpImageTranscriptomeView" class="helpImage" src="<%=imagesDir%>icons/help.png" /></div></span>
            <span class="viewMenu" name="viewAll" >Both<div class="inpageHelp" style="display:inline-block; "><img id="HelpImageAllView" class="helpImage" src="<%=imagesDir%>icons/help.png" /></div></span>
            <!--<span style="font-size:12px; font-weight:normal; float:right;">
            	Saved Views:
                <select name="viewSelect" id="viewSelect">
                		<option value="0" >------Login to use saved views------</option>
                </select>
            </span>-->
    <!--</div>-->
    
    
    <input type="hidden" id="defaultView" value="<%=viewID%>" />
    <div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000; text-align:left; width:100%;">
    		<table style="width:100%;" cellpadding="0" cellspacing="0">
            <tbody>
            <!--<TR>
            	<TD colspan="2" style="text-align:center; width:100%;">
                <span style="background-color:#DEDEDE;font-size:18px; font-weight:bold;padding:2px 15px 2px 15px;">
                    	<span id="viewLbl0"   >View:</span><span id="viewModifiedCtl">(Modified) <img src="../web/images/icons/save_flat.png" /></span>
                </span>
                </TD>
            </TR>-->
            	<TR>
                	<TD style="background-color:#DEDEDE;font-size:18px; font-weight:bold;">
                        <span class="trigger less" name="collapsableImage" >Transcripts Image</span>
                        <div class="inpageHelp" style="display:inline-block; "><img id="HelpRegionImage" class="helpImage" src="<%=imagesDir%>icons/help.png" /></div>
                  	</TD>
                    <TD style="background-color:#DEDEDE; text-align:center; width:50%;font-size:18px; font-weight:bold; vertical-align: middle;">
                        <span id="viewLbl0">View:</span><span id="viewModifiedCtl0" style="display:none;">(Modified <span class="Imagetooltip" title="This view has been modified.  To save this change you should use the arrow next to Select/Edit Views to Save or Save As..  Otherwise your change will persist only while this window is not refreshed and not left inactive for more than 59 minutes."><img src="<%=imagesDir%>icons/info.gif" />)</span>
                    </TD>
                    <TD style="background-color:#DEDEDE;">
                        <div id="imageHeader" style=" font-size:12px; float:right;"></div>
            		</TD>
               </TR>
               </tbody>
            </table>
    		<!--<span class="trigger less" name="collapsableImage" >Transcripts Image</span>
    		<div class="inpageHelp" style="display:inline-block; "><img id="HelpRegionImage" class="helpImage" src="<%=imagesDir%>icons/help.png" /></div>
            <div id="imageHeader" style=" font-size:12px; float:right;"></div>-->
            <!--<span style="font-size:12px; font-weight:normal; float:right;">
            	Saved Views:
                <select name="viewSelect" id="viewSelect">
                		<option value="0" >------Login to use saved views------</option>
                </select>
            </span>-->
    </div>
    <script type="text/javascript">
	//Setup View Menu
	var defviewList=[];
	var filterViewList=[];
	
	function getMainViewData(shouldUpdate){
		var tmpContext=contextPath +"/"+ pathPrefix;
		if(pathPrefix===""){
			tmpContext="";
		}	
		d3.json(tmpContext+"getBrowserViews.jsp",function (error,d){
			if(error){
				setTimeout(function(){getMainViewData(shouldUpdate);},2000);
				d3.select("#defaultView").html("<option>Error: reloading</option>");
			}else{
				console.log("getViewData()");
				defviewList=d;
				//readCookieViews();
				if(shouldUpdate===1){
					setupDefaultView();
				}
			}
		});
	};
	
	function readCookieViews(){
		console.log("readCookieViews()");
		var viewString="";
		if(isLocalStorage() === true){
			var cur=localStorage.getItem("phenogenCustomViews");
			if(cur!=undefined){
				viewString=cur;
			}
		}else{
			if($.cookie("phenogenCustomViews")!=null){
				viewString=$.cookie("phenogenCustomViews");
			}
		}
		if(viewString!=null&&viewString.indexOf("<///>")>-1){
			var viewStrings=viewString.split("<///>");
			for(var j=0;j<viewStrings.length;j++){
				var params=viewStrings[j].split("</>");
				var obj={};
				for(k=0;k<params.length;k++){
					var values=params[k].split("=");
					if(values[0]=="TrackSettingList"){
						var trList=values[1].split(";");
						obj.TrackList=[];
						for(var m=0;m<trList.length;m++){
							if(trList[m].length>0){
								var tc=trList[m].substr(0,trList[m].indexOf(","));
								var set=trList[m].substr(trList[m].indexOf(",")+1);
								var track={};
								track.TrackClass=tc;
								track.Settings=set;
								track.Order=m;
								obj.TrackList.push(track);
							}
						}
					}else if(values.length<=2){
						obj[values[0]]=values[1];
					}else if(values.length>2){
						var name=params[k].substr(0,params[k].indexOf("="));
						var value=params[k].substr(params[k].indexOf("=")+1);
						obj[name]=value;
					}
				}
				obj.Source="local";
				if(params.length>3){					
					obj.orgCount=obj.TrackList.length;
					defviewList.push(obj);
				}
			}
		}
	}
	
	
	function setupDefaultView(){
		console.log("setupDefaultView()");
		d3.select("#defaultView").html("");
		filterViewList=[];
		for(var i=0;i<defviewList.length;i++){
			if(defviewList[i].Organism=="AA"||defviewList[i].Organism.toLowerCase()==$('#speciesCB').val().toLowerCase()){
				filterViewList.push(defviewList[i]);
			}
		}
		var opt=d3.select("#defaultView").selectAll('option').data(filterViewList);
		opt.enter().append("option")
					.attr("value",function(d){return d.ViewID;})
					.text(function(d){
						var ret=d.Name;
						if(d.UserID==0){
							ret=ret+"    (Predefined)";
						}else{
							ret=ret+"   (Custom)";
						}
						if(d.Organism!="AA"){
							if(d.Organism=="RN"){
								ret=ret+"      (Rat Only)";
							}else if(d.Organism=="MM"){
								ret=ret+"     (Mouse Only)";
							}
						}
						
						return ret;
					});
		opt.exit().remove();
	}
	</script>
<div style="border-color:#CCCCCC; border-width:1px; border-style:inset; text-align:center;">
    	<span id="mouseHelp">Navigation Hints: Hold mouse over areas of the image for available actions.</span>    
        <div id="collapsableImage" class="geneimage" >
       		<div id="imgLoad" style="display:none;"><img src="<%=imagesDir%>ucsc-loading.gif" /></div>

            <div id="geneImage" class="ucscImage"  style="display:inline-block;width:100%;">
            <script src="<%=contextRoot%>javascript/GenomeDataBrowser2.3.1.js" type="text/javascript"></script>
            <script src="<%=contextRoot%>javascript/GenomeReport2.1.6.js" type="text/javascript"></script>
            <script src="<%=contextRoot%>javascript/GenomeViewMenu2.1.2.js" type="text/javascript"></script>
            <script src="<%=contextRoot%>javascript/GenomeTrackMenu2.1.0.js" type="text/javascript"></script>
				
            <script type="text/javascript">
				function isLocalStorage(){
					var test = 'test';
					try {
						localStorage.setItem(test, test);
						localStorage.removeItem(test);
						return true;
					} catch(e) {
						return false;
					}
				}
			
                    setTimeout(function(){
                        var gs=new GenomeSVG(".ucscImage",$(window).width()-25,minCoord,maxCoord,0,chr,"gene");
                        gs.forceDrawAs("Trx");
                        //loadStateFromCookie(0);
                        gs.xMax=maxCoord;
                        gs.xMin=minCoord;
                        //trackMenu[0].applyView();
                    },10);
					
					
					$("span[name='"+defaultView+"']").addClass("selected");
                    $(document).on('click','.triggerEC',function(event){
						var baseName = $(this).attr("name");
						$(this).toggleClass("less");
						if($("#"+baseName).is(":hidden")){
							$("#"+baseName).show();
						}else{
							$("#"+baseName).hide();
						}	
						
					});
					
					$(document).on('click','.helpImage', function(event){
						var id=$(this).attr('id');
						$('#'+id+'Content').dialog( "option", "position",{ my: "right top", at: "left bottom", of: $(this) });
						$('#'+id+'Content').dialog("open").css({'font-size':12});
						event.stopPropagation();
						//return false;
					}
					);
                </script>
           </div>
        </div>

</div><!--end Border Div -->
    <BR />
    <div id="newunsupportedChrome" style="display:none;color:#FF0000;">
        New versions of Chrome 42+ may not work for now with the Java Plugin.  If you can setup and activate the plugin it should work but the current Java version 1.8.0_45 does not seem to work.  Please use Firefox or Safari.
    </div>
    
    <div id="unsupportedChrome" style="display:none;color:#FF0000;"><BR /><BR />A Java plug in is required to view this page.  Older versions of Chrome are 32-bit applications and require a 32-bit plug-in which is unavailable for Mac OS X.  
            	Please try using Safari or FireFox with the Java Plug in installed.  Note: In browsers that support the 64-bit plug in you will be prompted to install Java if it is not already installed.  Chrome 39-41 is 64-bit on Mac OS X so you should be able to use chrome with the plug-in installed.</div>
                
                
			<span id="disabledJava" style="display:none;margin-left:40px;"><BR /><BR />
                <span style="color:#FF0000;">Java has been disabled in your browser.</span><BR />
                            To enable Java in your browser or operating system, see:<BR><BR> 
                            Firefox: <a href="http://support.mozilla.org/en-US/kb/unblocking-java-plugin" target="_blank">http://support.mozilla.org/en-US/kb/unblocking-java-plugin</a><BR><BR>
                            Internet Explorer: <a href="http://java.com/en/download/help/enable_browser.xml" target="_blank">http://java.com/en/download/help/enable_browser.xml</a><BR><BR>
                            Safari: <a href="http://docs.info.apple.com/article.html?path=Safari/5.0/en/9279.html" target="_blank">http://docs.info.apple.com/article.html?path=Safari/5.0/en/9279.html</a><BR><BR>
                            Chrome: <a href="http://java.com/en/download/faq/chrome.xml" target="_blank">http://java.com/en/download/faq/chrome.xml</a><BR /><BR />
            </span>
            <span id="noJava" style="color:#FF0000;display:none;"><BR /><BR /> No Java Plug-in is installed or a newer version is required click the Install button for the latest version.<BR /></span>
            <span id="oldJava" style="color:#00AA00;display:none;"><BR /><BR />A newer Java version may be available click the Install button for the latest version.(You may still use all functions even if you see this message.)<BR /></span>
            <span id="installJava" style="display:none;" class="button">Install Java</span>
                            


<div id="macBugDesc" style="display:none;color:#FF0000;"><BR /><BR />The applet below is fully functional.  However, with your current combination of Mac OS X and Java plug-in the display is not optimal due to a bug.  This bug has been fixed if you update to Java plug-in version 1.7.0_51 or higher the display will be improved.  We are very sorry for any inconvenience.  This bug is not found in Windows, Linux, Mac OS X 10.6 or lower if you have any of them available.</div>
        <BR /><BR /><BR />
        <div style="margin-left:10px;margin-right:10px;"><p><span style="color:#FF0000">Note:</span>If you don't see the applet below try adjusting security settings as directed <a href="http://java.com/en/download/help/enable_browser.xml" target="_blank">here</a>. You will be asked if you want to allow the applet to run, please select "Run" or "Yes" if prompted.  We are now providing a signed applet that will say it has been signed by the University of Colorado Denver.  We are also working to provide similar expression data that is not dependent on Java at some point in the future.</p>
            <%if(request.getServerPort()!=80){%>
            <BR><BR><p style="color:#FF0000;">Using the secure site(https), you may first be prompted with a message stating that the server cannot be verified and is not trusted.  This is due to differences between how Java and browsers handle the validation of SSL certificates used to verify the server.  If you see in your browser that the site is trusted and connection is encrypted you should click Continue.  If your browser indicates a problem then you should be very careful about clicking continue.  We are trying to find a way to prevent the additional warning and will update the page as soon as an option exists.</p>
            <%}%>
        </div>
        <BR /><BR />
        <div style="text-align:center;">
        <%if(request.getServerPort()==80){%>
            <script type="text/javascript" src="http://www.java.com/js/deployJava.js"></script>
        <%}else{%>
            <script type="text/javascript" src="https://www.java.com/js/deployJava.js"></script>
        <%}%>
        <script type="text/javascript">
			var ensembl=selectedID;
			var appletWidth=1000;
			var appletHeight=1200;
			var jre=deployJava.getJREs();
			var bug=0;
			var bugString='false';
			var unsupportedChrome=0;
                        var newUnsupportedChrome=0;
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
           
                        if(/Chrome\/(\d+)/.test(navigator.userAgent)){
                            //console.log(RegExp.$1);
                            var chromeVer=new Number(RegExp.$1);
                            if(chromeVer>=42){
                                    newUnsupportedChrome=1;
                                    $('#newunsupportedChrome').show();
                            }
			}
                        //console.log(navigator.userAgent);
			if (/Mac OS X[\/\s](\d+[_\.]\d+)/.test(navigator.userAgent)){
 					//var macVersion=new Number(RegExp.$1); // capture x.x portion and store as a number
					var tmpAgent=new String(navigator.userAgent);
					//alert("Detected Mac OS X:"+tmpAgent);
					if(/Chrome\/(\d+)/.test(tmpAgent)){
                                                //console.log(RegExp.$1);
                                                var chromeVer=new Number(RegExp.$1);
                                                //alert("chrome ver:"+chromeVer);
						var update=new String(jre);
						//alert("chrome update:"+update);
						if(chromeVer<39 && update.length==0){
							//alert("unsupported");
							unsupportedChrome=1;
						}
					}
					else if (/10[_\.](d+)/.test(tmpAgent)){
                                                var osXVer=new Number(RegExp.$1);
						//alert("Mac Ver ="+osXVer);
                                                if(oxXVer>=7){//if OS X 10.7 or higher
                                                    var tmpUp=new String(jre);
                                                    if(/^1\.7/.test(tmpUp)){//make sure we only do this for JRE 1.7_10-1.7_51
                                                        var update=tmpUp.substr((tmpUp.indexOf("_")+1));
                                                        //alert("update:"+update);
                                                        if(update>=10 && update <51){//bug occurred between update 10 and 51 of the Oracle 1.7 Mac OSX JRE.
                                                                //alert("update >10");
                                                                /*if(deployJava.versionCheck('1.7.0_51+')){//This version no longer has the bug so if newer mac OS X and JRE update 51 or higher don't actually change the applet

                                                                }else{*/
                                                                        bug=1;
                                                                        appletHeight=700;
                                                                        bugString='true';
                                                                //}
                                                        }
                                                    }
                                                }
					}
			}
			if(unsupportedChrome===0 && newUnsupportedChrome===0){
				var attributes = {
					id:	'geneApplet',
					code:       "genecentricviewer.GeneCentricViewer",
					archive:    "<%=contextRoot%>web/GeneCentric/GeneCentricViewer.jar",
					width:      appletWidth,
					height:     appletHeight
				};
				var parameters = {
					java_status_events: 'true',
					jnlp_href:"<%=contextRoot%>web/GeneCentric/launch.jnlp",
					main_ensembl_id:ensembl,
					genURL:genURL,
					regionURL:regionURL,
					macBug:bugString
				}; 
				var version = "1.7"; 
                                deployJava.runApplet(attributes, parameters, version);
			}else if(unsupportedChrome===1){
				$('#unsupportedChrome').show();
			}
			if(bug===1){
				$('div#macBugDesc').show();
			}
       
		</script>

	</div>


<div id="Help3Content" class="inpageHelpContent" title="Help"><div class="help-content">
<H3>Filter/Display Controls</H3>
The filters allow you to control the probe sets that are displayed.  Check the box next to the filter you want to apply.  The filter is immediately applied, unless input is required, and then it is applied after you input a value.<BR /><BR />
The display controls allow you to choose how the data is displayed.  Any selections are immediately applied.<BR /><BR />
The Filter and Display controls will have different options as you navigate through different tabs.  However, any selections you make on a tab will be preserved when you navigate back to a tab.
</div></div>

<div id="Help4Content" class="inpageHelpContent" title="Help"><div class="help-content">
<H3>Parental Expression</H3>
This tab has heat maps for the expression and fold difference between the Parental Strains(Rat BN-Lx/SHR or Mouse ILS/ISS).  To switch between the two heatmaps use the Display: Mean Values and Fold Difference options.<BR /><BR />
Use the buttons at the top left to control the size of the rows and columns.<BR /><BR />
The legend can be found next to the column and row size buttons and provides a reference for the range of the values displayed.<BR /><BR />
The Probe set IDs along the left side are color coded to match the UCSC genome browser graphic above.<BR /><BR />

</div></div>
<div id="Help5Content" class="inpageHelpContent" title="Help"><div class="help-content">
<H3>Heritability</H3>
Heritability is calculated from individual expression values in the panel of recombinant inbred rodents. The broad sense heritability is calculated from a 1-way ANOVA model comparing the within-strain variance to the between-strain variance. A higher heritability indicates more of the variance in expression and is determined by genetic factors rather than non-genetic factors in this particular RI panel. This tab allows you to view the heritability of unambiguous probe sets.  For Affymetrix exon arrays, a probe set typically consist of 4 unique probes.  Prior to analysis, we eliminated (masked) individual probes if their sequence did not align uniquely to the genome or if the probe targeted a region of the genome that harbored a known single nucleotide polymorphism (SNP) between the two parental strains of the RI panel.  Entire probe sets were eliminated if less than three probes within the probe set remained after masking.   Probes that target a region with a known SNP may indicate dramatic differences in expression when expression levels are similar but hybridization efficiency differ.
<BR /><BR />
If a probe set of interest is missing, adjust the filtering to allow additional probes (allow introns, opposite strand, make sure all other filters are unchecked, etc.) If it still does not display, it means that the probe set was masked and there is no heritability data because the probe set data would be inaccurate.

</div>
</div>

<div id="Help6Content" class="inpageHelpContent" title="Help"><div class="help-content">
<H3>Panel Expression</H3>
These are the normalized log transformed expression values.  This tab shows expression values for each probe set across all strains in the panel.  Note: Because of the normalization, do not compare normalized values between different probe sets, but you can compare them across strains.  <BR /><BR />

There are three ways to view the data.  The default produces a separate graph for each probe set.  Notice the range and size varies with each probe set.  The size varies directly with the range of values so you can quickly scan for more variable or consistent probe sets. <BR /><BR />

The next method, if you view probe sets grouped into one graph by tissue, shows the variability by strain in a single graph.  This allows you to look for probe sets that vary significantly between strains.   Do not compare expression between probe sets along the X-axis because the normalization does not allow comparison of expression values between probe sets.  <BR /><BR />

The last method displays probe sets in a series across strains.  Again, it is important that you do not use this to compare expression values between probe sets.  The best way to compare expression is to use the Exon Correlation Tab.<BR /><BR />

Masking: Probe sets have been masked because the sequence for the probe set does not match the strain of mice or rats and as a result, the data from the probe set would be misleading or inaccurate.  If a probe set of interest is missing, adjust the filtering to allow additional probes(allow introns, opposite strand, make sure all other filters are unchecked, etc.) If it still does not display it means that the probe set was masked and there is no heritability data because the probe set data would be inaccurate.

</div>
</div>
<div id="Help7Content" class="inpageHelpContent" title="Help"><div class="help-content">
<H3>Exon Correlation</H3>
This tab allows you to compare probe set expression, which should not be done directly in the expression tab.  This heatmap shows a selected transcript across the top and draws exons that are represented by probe sets along the top of the heatmap.  Exons that are excluded are color-coded to match the legend at the bottom of the page that shows why the exon was excluded from the heatmap.  Some exons may have multiple probe sets representing them.<BR /><BR />

The heatmap is colored according to the correlation of one probe set to another across the strains in the panel.
</div>
</div>

<script type="text/javascript">
//Setup Help links
	$('.inpageHelpContent').hide();
	
	$('.inpageHelpContent').dialog({ 
  		autoOpen: false,
		dialogClass: "helpDialog",
		width: 400,
		maxHeight: 500,
		zIndex: 9999
	});
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


