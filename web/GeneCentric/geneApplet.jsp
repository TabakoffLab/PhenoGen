<%@ include file="/web/common/session_vars.jsp" %>

<%
	extrasList.add("detailedTranscriptInfo.js");
	extrasList.add("jquery.cookie.js");
	extrasList.add("d3.v3.min.js");
	extrasList.add("smoothness/jquery-ui-1.10.3.min.css");
	extrasList.add("tabs.css");
	extrasList.add("tooltipster.css");
%>

<%@ include file="/web/common/header_adaptive_noMenu.jsp" %>
<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<jsp:useBean id="myFH" class="edu.ucdenver.ccp.util.FileHandler"/>


<%
String chromosome="",panel="",myOrganism="Rn";
int min=0,max=0,rnaDatasetID=0,arrayTypeID=0;

String selectedID="";

	if(request.getParameter("selectedID")!=null){
		selectedID=request.getParameter("selectedID");
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
	genURL=urlPrefix+ "tmpData/geneData/" +selectedID+"/";
	String regionURL=urlPrefix+"tmpData/regionData/"+folderName+"/";
	
%>

<%@ include file="/web/GeneCentric/browserCSS.jsp" %>

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
	var selectGene="<%=selectedID%>";
	var folderName="<%=folderName%>";
	var pathPrefix="";
	var dataPrefix="../../";
</script>
<div id="imageMenu"></div>
    <div style="font-size:18px; font-weight:bold; background-color:#FFFFFF; color:#000000; text-align:center; width:100%; padding-top:3px;">
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
    </div>
    <div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000; text-align:left; width:100%;">
    		<span class="trigger less" name="collapsableImage" >Transcripts Image</span>
    		<div class="inpageHelp" style="display:inline-block; "><img id="HelpRegionImage" class="helpImage" src="<%=imagesDir%>icons/help.png" /></div>
            <div id="imageHeader" style=" font-size:12px; float:right;"></div>
            <!--<span style="font-size:12px; font-weight:normal; float:right;">
            	Saved Views:
                <select name="viewSelect" id="viewSelect">
                		<option value="0" >------Login to use saved views------</option>
                </select>
            </span>-->
    </div>
<div style="border-color:#CCCCCC; border-width:1px; border-style:inset; text-align:center;">
    	<span id="mouseHelp">Navigation Hints: Hold mouse over areas of the image for available actions.</span>    
        <div id="collapsableImage" class="geneimage" >
       		<div id="imgLoad" style="display:none;"><img src="<%=imagesDir%>ucsc-loading.gif" /></div>

            <div id="geneImage" class="ucscImage"  style="display:inline-block;width:100%;">
            <script src="<%=contextRoot%>javascript/GenomeDataBrowser0.8.2.js" type="text/javascript"></script>
            <script src="<%=contextRoot%>javascript/GenomeReport0.2.1.js" type="text/javascript"></script>
				
                <script type="text/javascript">
                    var gs=new GenomeSVG(".ucscImage",$(window).width()-25,minCoord,maxCoord,0,chr,"gene");
					gs.forceDrawAs("Trx");
					loadState(0);
					gs.xMax=maxCoord;
					gs.xMin=minCoord;
					
					
					
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

<div id="unsupportedChrome" style="display:none;color:#FF0000;">A Java plug in is required to view this page.  Chrome is a 32-bit browser and requires a 32-bit plug-in which is unavailable for Mac OS X.  
            	Please try using Safari or FireFox with the Java Plug in installed.  Note: In browsers that support the 64-bit plug in you will be prompted to install Java if it is not already installed.</div>

<div id="macBugDesc" style="display:none;color:#FF0000;">The applet below is fully functional.  However, with your current combination of Mac OS X and Java plug-in the display is not optimal due to a bug.  When Oracle fixes this bug we will update the applet to provide a more optimal experience.  We are very sorry for any inconvenience.  This bug is not found in Windows, Linux, Mac OS X 10.6 or lower if you have any of them available.</div>
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
					regionURL:regionURL,
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


