
<script type="text/javascript">
var trackString="probe,numExonPlus,numExonMinus,refseq";
var minCoord=<%=min%>;
var maxCoord=<%=max%>;
var chr="<%=chromosome%>";
var filterExpanded=0;
var organism="<%=myOrganism%>";
var ucscgeneID="<%=selectedEnsemblID%>";
var ucsctype="Gene";
</script>


<% 
//ERROR SECTION: NO ENSEMBL ID

if(displayNoEnsembl){ %>
	<BR /><div> The Gene ID entered could not be translated to an Ensembl ID so that we can pull up gene information.  Please try an alternate Gene ID.  This gene ID has been reported so that we can improve the translation of many Gene IDs to Ensembl Gene IDs.  <BR /><BR /><b>Note:</b> at this time if there is no annotation in Ensembl for a gene we will not currently be able to display information about it, however if you have found your gene of interest on Ensembl and cannot enter a different Gene ID above entering the Ensembl Gene ID should work.</div>
<% } %>

<%if(genURL.size()>0){%>
	
	<%if(ucscURL.get(selectedGene)!=null && !ucscURL.get(selectedGene).equals("") ){%>
       <!-- <div class="geneimage" style="text-align:center;">
            <div class="inpageHelp" style="display:inline-block;position:relative;float:right;"><img id="Help1" src="../web/images/icons/help.png"  /></div>
    
            <div id="geneimageUnfiltered"  style="display:inline-block;"><a class="fancybox fancybox.iframe" href="<%=ucscURL.get(selectedGene)%>" title="UCSC Genome Browser"><img src="<%= contextRoot+"tmpData/geneData/"+selectedEnsemblID+"/"+selectedEnsemblID+".main.png"%>"/></a></div>
    
            <div id="geneimageFiltered" style="display:none;"><a class="fancybox fancybox.iframe" href="" title="UCSC Genome Browser"><img src="<%= contextRoot+"tmpData/geneData/"+selectedEnsemblID+"/"+selectedEnsemblID+".main.filter.png"%>"/></a></div>
    
        </div><!-- end geneimage div -->
    
    
       <!-- <div class="geneimageControl" style="text-align:center">
      
          <form id="form1" name="form1" method="post" action="">
              <label>
                View Image with Probesets:
                <input name="radio" type="radio" id="unfilteredRB" value="unfilteredGeneImage" checked="checked" />
                Unfiltered</label>
              <label>
              <input type="radio" name="radio" id="filteredRB" value="filteredGeneImage" />
              Filtered by Detection Above Background</label>
              <div class="inpageHelp" style="display:inline-block;"><img id="Help2" src="../web/images/icons/help.png" /></div>
          </form>
      <% } %>
	  <%if(ucscURL.size()>1){%>
      		<form id="geneSelection" name="geneSelection" method="" action="">
            
                <label>Multiple genes were returned please select the gene of Interest:
                <select name="geneSelectCBX" id="geneSelectCBX" >
                    <%for(int i=0;i<firstEnsemblID.size();i++){
                        %>
                        <option value="<%=i%>" <%if(i==selectedGene){%>selected<%}%>>
						<%if(geneSymbol.get(i)!=null){%><%=geneSymbol.get(i)%> (<%=firstEnsemblID.get(i)%>) <%}else{%><%=firstEnsemblID.get(i)%> <%}%>
						<%if(genURL.get(i)!=null && genURL.get(i).startsWith("ERROR:")){%>Error<%}%>
                        </option>
                    <%}%>
                </select>
                </label>
            
            <input type="submit" name="action" id="selGeneBTN" value="Go" onClick="return displayGo()">
            </form>
      <% }%>
	</div><!--end imageControl div -->


<div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000;text-align:center; width:100%;">
    	<span class="triggerImage less" name="collapsableImage" >UCSC Genome Browser Image</span>
    	<div class="inpageHelp" style="display:inline-block;"><img id="Help2" class="helpImage" src="../web/images/icons/help.png" /></div>
        <span style="font-size:12px; font-weight:normal;">
        <input name="imageSizeCbx" type="checkbox" id="imageSizeCbx" checked="checked" /> Scroll Image - Viewable Size:
        <select name="imageSizeSelect" id="imageSizeSelect">
        		<option value="200" >Smaller</option>
            	<option value="400" selected="selected">Normal</option>
                <option value="600" >Larger</option>
                <option value="800" >Largest</option>
            </select>
        </span>
    </div>
    <div style="border-color:#CCCCCC; border-width:1px; border-style:inset; text-align:center;">
        
        <div id="collapsableImage" class="geneimage" >
       		<div id="imgLoad" style="display:none;"><img src="<%=imagesDir%>ucsc-loading.gif" /></div>
            <div id="geneImage" class="ucscImage"  style="display:inline-block; height:400px; width:980px; overflow:auto;">
            	<a class="fancybox fancybox.iframe" href="<%=ucscURL.get(0)%>" title="UCSC Genome Browser">
            	<img src="<%= contextRoot+"tmpData/geneData/"+selectedEnsemblID+"/ucsc.probe.numExonPlus.numExonMinus.refseq.png"%>"/></a>
            </div>
        </div><!-- end geneimage div -->
    	<div class="geneimageControl">
      		
          	<form>
            Image Tracks/Table Filter:<div class="inpageHelp" style="display:inline-block; margin-left:10px;"><img id="Help1" class="helpImage" src="../web/images/icons/help.png" /></div>
            <input name="trackcbx" type="checkbox" id="probeCBX" value="probe" checked="checked" /> All Non-Masked Probesets
            <input name="trackcbx" type="checkbox" id="filterprobeCBX" value="filterprobe" />Probsets Detected Above Background >1% of samples
            <BR />
            <input name="trackcbx" type="checkbox" id="exonPlusCBX" value="numExonPlus" checked="checked" />+ Strand Protein Coding/PolyA+
            <input name="trackcbx" type="checkbox" id="exonMinusCBX" value="numExonMinus" checked="checked" />- Strand Protein Coding/PolyA+
            <input name="trackcbx" type="checkbox" id="exonUkwnCBX" value="numExonUkwn" />Unknown Strand Protein Coding/PolyA+
            <BR />
            <input name="trackcbx" type="checkbox" id="noncodingCBX" value="noncoding" />Long Non-Coding/NonPolyA+
            <input name="trackcbx" type="checkbox" id="smallncCBX" value="smallnc" /> Small RNA 
           	<input name="trackcbx" type="checkbox" id="snpCBX" value="snp" /> SNPs/Indels:
             <select name="trackSelect" id="snpSelect">
            	<option value="1" selected="selected">Dense</option>
                <option value="3" >Pack</option>
            </select>
            <input name="trackcbx" type="checkbox" id="helicosCBX" value="helicos" /> Helicos Data:
            <select name="trackSelect" id="helicosSelect">
            	<option value="1" selected="selected">Dense</option>
                <option value="2" >full</option>
            </select>
            <input name="trackcbx" type="checkbox" id="bqtlCBX" value="qtl" /> bQTLs
            <input name="trackcbx" type="checkbox" id="refseqCBX" value="refseq" checked="checked" /> RefSeq Transcripts
              <!--<label style="color:#000000; margin-left:10px;">
                Transcripts:</label>
                <select name="transcriptSelect" id="transcriptSelect">
                	<option value="geneimageUnfiltered" selected="selected">Hide</option>
                    <option value="geneimageFiltered" >Show</option>
                </select>-->
              <!--<label style="color:#000000; margin-left:10px;">Additional Track options:</label>
             	<select name="lowerTrackSelect" id="lowerTrackSelect">
                	<option value="NoArray">None</option>
                    <option value="Array" selected="selected">UCSC/Affymetrix Tissue Expression Data(Source:UCSC)</option>
                    <option value="Human">Human Proteins/Chr Mapping(Source:UCSC)</option>
                </select>-->
                
             </form>
         
		 
          </div><!--end imageControl div -->
    </div><!--end Border Div -->
    <BR />
<script type="text/javascript">
	
	//Setup Fancy box for UCSC link
	$('.fancybox').fancybox({
		width:$(document).width(),
		height:$(document).height(),
		scrollOutside:false,
		afterClose: function(){
			$('body.noPrint').css("margin","5px auto 60px");
			return;
		}
  });
  	$('#imageSizeCbx').change( function(){
		if($(this).is(":checked")){
			$('#geneImage').css({"height":"400px","overflow":"auto"});
			$('#imageSizeSelect').prop('disabled', false);
		}else{
			$('#geneImage').css({"height":"","overflow":""});
			$('#imageSizeSelect').prop('disabled', 'disabled');
		}
		
	});
	
	$('#imageSizeSelect').change( function(){
		if($('#imageSizeCbx').is(":checked")){
			var size=$(this).val()+"px";
			$('#geneImage').css({"height":size,"overflow":"auto"});
		}
	});
</script>

    <BR />
    <BR />
    
 <div id="viewTrxDialog" class="trxDialog"></div>

<div id="viewTrxDialogOriginal"  style="display:none;"><div class="waitTrx"  style="text-align:center; position:relative; top:0px; left:0px;"><img src="<%=imagesDir%>wait.gif" alt="Loading..." /><BR />Please wait loading transcript data...</div></div>

<script type="text/javascript">
	var spec="<%=myOrganism%>";
	
	$('#viewTrxDialog').dialog({
		autoOpen: false,
		dialogClass: "transcriptDialog",
		width: 960,
		height: 400,
		zIndex: 999
	});
	
	$('.viewTrx').click( function(event){
		var id=$(this).attr('id');
		var name=$(this).attr('name');
		$('.waitTrx').show();
		$('#viewTrxDialog').html($('#viewTrxDialogOriginal').html());
		$('#viewTrxDialog').dialog( "option", "position",{ my: "center bottom", at: "center top", of: $(this) });
		$('#viewTrxDialog').dialog("open").css({'font-size':12});
		openTranscriptDialog(id,spec,name);
	});
	
	$('.viewSMNC').click( function(event){
		var tmpID=$(this).attr('id');
		var id=tmpID.substr(0,tmpID.indexOf(":"));
		var name=tmpID.substr(tmpID.indexOf(":")+1);
		openSmallNonCoding(id,name);
		$('#viewTrxDialog').dialog( "option", "position",{ my: "center bottom", at: "center top", of: $(this) });
		$('#viewTrxDialog').dialog("open").css({'font-size':12});
	})
	
	/*var tblGenes=$('#tblGenes').dataTable({
	"bPaginate": false,
	"bProcessing": true,
	"bStateSave": true,
	"bAutoWidth": true,
	"sScrollX": "950px",
	"sScrollY": "650px",
	"aaSorting": [[ 5, "desc" ]],
	"sDom": '<"leftSearch"fr><t>'
	/*"oTableTools": {
			"sSwfPath": "/css/swf/copy_csv_xls_pdf.swf"
		}*/

	//});
	
	
	
	/*$('#mainTab div.modalTabContent:first').show();
	$('#mainTab ul li a:first').addClass('selected');
	$('#geneTabID').click(function() {    
			$('div#changingTabs').show(10);
				//change the tab
				$('#mainTab ul li a').removeClass('selected');
				$(this).addClass('selected');
				var currentTab = $(this).attr('href'); 
				$('#mainTab div.modalTabContent').hide();       
				$(currentTab).show();
				//adjust row and column widths if needed(only needs to be done once)
				setFilterTableStatus("geneListFilter");
				
			$('div#changingTabs').hide(10);
			return false;
        });
	$('#tblGenes').dataTable().fnAdjustColumnSizing();

	$('#tblGenes_wrapper').css({position: 'relative', top: '-56px'});
	//$('.singleExon').hide();
	
	$('#heritCBX').click( function(){
			displayColumns(tblGenes, 16,tisLen,$('#heritCBX').is(":checked"));
	  });
	  $('#dabgCBX').click( function(){
			displayColumns(tblGenes, 16+tisLen,tisLen,$('#dabgCBX').is(":checked"));
	  });
	  $('#eqtlAllCBX').click( function(){
			displayColumns(tblGenes, 16+tisLen*2,tisLen*2+3,$('#eqtlAllCBX').is(":checked"));
	  });
		$('#eqtlCBX').click( function(){
			displayColumns(tblGenes, 16+tisLen*2+3,tisLen*2,$('#eqtlCBX').is(":checked"));
	  });
	  
	   $('#geneIDCBX').click( function(){
			displayColumns(tblGenes,2,1,$('#geneIDCBX').is(":checked"));
	  });
	  $('#geneDescCBX').click( function(){
			displayColumns($(tblGenes).dataTable(),3,1,$('#geneDescCBX').is(":checked"));
	  });
	  
	  $('#geneBioTypeCBX').click( function(){
			displayColumns($(tblGenes).dataTable(),4,1,$('#geneBioTypeCBX').is(":checked"));
	  });
	  $('#geneTracksCBX').click( function(){
			displayColumns($(tblGenes).dataTable(),5,3,$('#geneTracksCBX').is(":checked"));
	  });
	  
	  $('#geneLocCBX').click( function(){
			displayColumns($(tblGenes).dataTable(),8,2,$('#geneLocCBX').is(":checked"));
	  });
	  
	  $('#pvalueCutoffSelect1').change( function(){
	  			$("#wait1").show();
				$('#forwardPvalueCutoffInput').val($(this).val());
				//alert($('#pvalueCutoffInput').val());
				//$('#geneCentricForm').attr("action","Get Transcription Details");
				$('#geneCentricForm').submit();
			});
	 $('#exclude1Exon').click( function(){
  		if($('#exclude1Exon').is(":checked")){
			$('.singleExon').hide();
		}else{
			$('.singleExon').show();
		}
 	 });*/
	 
	 $("input[name='trackcbx']").change( function(){
	 		var type=$(this).val();
			updateTrackString();
			updateUCSCImage();
			//if(type=="coding" || type=="noncoding" || type=="smallnc"){
				/*if($('#rqQTLCBX').is(":checked")){
					$('tr.'+type).hide();
					type=type+".eqtl";
				}*/
			//	if($(this).is(":checked")){
			//		$('tr.'+type).show();
			//	}else{
			//		$('tr.'+type).hide();
			//	}
			//	tblGenes.fnDraw();
			//}
			
	 });
	 
	 $("select[name='trackSelect']").change( function(){
	 	var id=$(this).attr("id");
		var cbx=id.replace("Select","CBX");
		if($("#"+cbx).is(":checked")){
			updateTrackString();
			updateUCSCImage();
		}
	 });
	 
	 /*$("span.tblTrigger").click(function(){
		var baseName = $(this).attr("name");
                var thisHidden = $("span#" + baseName).is(":hidden");
                $(this).toggleClass("less");
                if (thisHidden) {
			$("span#" + baseName).show();
                } else {
			$("span#" + baseName).hide();
                }
	}); */
</script>
   
   
	 <% String tmpPath=applicationRoot + contextRoot+"tmpData/geneData/" +firstEnsemblID.get(selectedGene) + "/";	%>
    <div class="hidden"><a class="hiddenLink fancybox.iframe" href="web/GeneCentric/LocusSpecificEQTL.jsp?hiddenGeneSymbol=<%=geneSymbol.get(selectedGene)%>&hiddenGeneCentricPath=<%=tmpPath%>" title="eQTL"></a></div>
    <div id="macBugDesc" style="display:none;color:#FF0000;">On your Mac OS X version and Java version the applet below is not being displayed correctly.  This problem is a result of the last update from Oracle and will hopefully be fixed with the next version at which point we will update the applet.  We are very sorry for any inconvenience.  If you would like to use windows or Mac OS X 10.6 the applet will be displayed correctly.  We have done what we can to improve the applets appearance until Oracle fixes this bug, and we are very sorry for any inconvenience.</div>
    
    <div id="unsupportedChrome" style="display:none;color:#FF0000;">A Java plugin is required to view this page.  Chrome is a 32-bit browser and requires a 32-bit plug-in which is unavailable for Mac OS X.  Please try using Safari or FireFox with the Java Plugin installed.  Note: In browsers that support the 64-bit plugin you will be prompted to install Java if it is not already installed.</div>
    
	<%if(genURL.get(selectedGene)!=null && !genURL.get(selectedGene).startsWith("ERROR:")){%>
    	<script type="text/javascript" src="http://www.java.com/js/deployJava.js"></script>
		<script type="text/javascript">
            var ensembl="<%=selectedEnsemblID%>";
            var genURL="<%=genURL.get(selectedGene)%>";
			var appletWidth=1000;
			var appletHeight=1200;
			var jre=deployJava.getJREs();
			var bug=0;
			var bugString='false';
			var unsupportedChrome=0;
			//
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
								$('div#macBugDesc').show();
						}
					}
			}
        </script>
        
        <script type="text/javascript">
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

        </script>
        
    <%}else{%>
    	<div class="error"><%=genURL.get(selectedGene)%><BR />The administrator has been notified of the problem and will investigate the error.  We apologize for any inconvenience.</div><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR />
    <%}%>
<%}else{%>
	<BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR />
<%}%>

<div id="Help1Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>UCSC Genome Browser Image</H3>
The main image was generated by the <a target="_blank" href="http://genome.ucsc.edu/">UCSC Genome Browser</a>(click the image to open a window in your browser at the position of the image).  The image that follows shows numbered tracks.  Below the image, each numbered section describes the associated track.
<img src="ucsc_example.jpg" />  
<ol>
<li>The first track contains all of the Affymetrix Exon Probe Sets for the <a target="_blank" href="http://www.affymetrix.com/estore/browse/products.jsp?productId=131474&categoryId=35765&productName=GeneChip-Mouse-Exon-ST-Array#1_1">Mouse</a> or
<a target="_blank" href="http://www.affymetrix.com/estore/browse/products.jsp?productId=131489&categoryId=35748&productName=GeneChip-Rat-Exon-ST-Array#1_1"> Rat</a> Affy Exon 1.0 ST array.  Below the image, information about these probe sets for parental strains and <a target="_blank" href="http://www.jax.org/smsr/ristrain.html" >panels of recombinant inbred mice or rats</a> and various tissues are displayed. </li>

<li>The second track (if present) contains the numbered exons for the positive strand.  If transcripts exist for the positive strand, each unique exon is given a number such that the first exon is 1.  If transcripts have differing, overlapping exons, then the exons are numbered 1a, 1b, etc.</li>
<li>Rat Only: The third track is a reconstruction of the transcriptome from RNA Sequencing computed by <a target="_blank" href="http://cufflinks.cbcb.umd.edu/index.html">CuffLinks</a> from RNA Sequencing data of Rat Brain.</li>
<li>This fourth track (if present) contains the numbered exons for the reverse strand.  If transcripts exist for the reverse strand, each unique exon is given a number such that the first exon is 1.  If transcripts have differing, overlapping exons, then the exons are numbered 1a, 1b, etc.</li>
<li>Rat Only: The fifth track contains single exon transcripts from CuffLinks that are numbered in the same manner as other exon number tracks.  However in addition to being single exon "genes" they were not able to be assigned to a strand.</li>
<li>The sixth track shows standard UCSC Tracks for the RefSeq gene(top, blue color) and Ensembl transcripts(bottom, brown color).</li>
</ol></div></div>

<div id="Help2Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>UCSC Image Controls</H3>
This control allows you to choose between two different versions of the UCSC genome browser image.  Occasionally you may also have the option to select a different gene.  This occurs when iDecoder found more than one Ensembl Gene Identifier associated with your gene.  However the gene most closely related to the identifier you enter is selected first.<BR /><BR />
The unfiltered version of the image displays all the Affymetrix Exon probesets color coded by annotation level.<BR /><BR />
The filtered version has only probesets that were detected above background in 1% or more of the samples.  Detection Above BackGround(DABG)-Calculates the p-value that the intensities in a probeset could have been observed by chance in a background distribution. <a target="_blank" href="http://www.affymetrix.com/partners_programs/programs/developer/tools/powertools.affx">Affymetrix for more information</a>. <BR />  It also has one track per tissue where data is available (Mouse-Brain Rat-Brain,Heart,Liver,Brown Adipose).  While this is a low percentage it filters out all of the probesets that are not detected above background.
</div></div>


<div id="Help3Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>Filter/Display Controls</H3>
The filters allow you to control the probe sets that are displayed.  Check the box next to the filter you want to apply.  The filter is immediately applied, unless input is required, and then it is applied after you input a value.<BR /><BR />
The display controls allow you to choose how the data is displayed.  Any selections are immediately applied.<BR /><BR />
The Filter and Display controls will have different options as you navigate through different tabs.  However, any selections you make on a tab will be preserved when you navigate back to a tab.
</div></div>
<div id="Help4Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>Parental Expression</H3>
This tab has heat maps for the expression and fold difference between the Parental Strains(Rat BN-Lx/SHR or Mouse ILS/ISS).  To switch between the two heatmaps use the Display: Mean Values and Fold Difference options.<BR /><BR />
Use the buttons at the top left to control the size of the rows and columns.<BR /><BR />
The legend can be found next to the column and row size buttons and provides a reference for the range of the values displayed.<BR /><BR />
The Probeset IDs along the left side are color coded to match the UCSC genome browser graphic above.<BR /><BR />

</div></div>
<div id="Help5Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>Heritability</H3>
Heritability is calculated from individual expression values in the panel of recombinant inbred rodents. The broad sense heritability is calculated from a 1-way ANOVA model comparing the within-strain variance to the between-strain variance. A higher heritability indicates more of the variance in expression and is determined by genetic factors rather than non-genetic factors in this particular RI panel. This tab allows you to view the heritability of unambiguous probesets.  For Affymetrix exon arrays, a probeset typically consist of 4 unique probes.  Prior to analysis, we eliminated (masked) individual probes if their sequence did not align uniquely to the genome or if the probe targeted a region of the genome that harbored a known single nucleotide polymorphism (SNP) between the two parental strains of the RI panel.  Entire probesets were eliminated if less than three probes within the probeset remained after masking.   Probes that target a region with a known SNP may indicate dramatic differences in expression when expression levels are similar but hybridization efficiency differ.
<BR /><BR />
If a probeset of interest is missing, adjust the filtering to allow additional probes (allow introns, opposite strand, make sure all other filters are unchecked, etc.) If it still does not display, it means that the probeset was masked and there is no heritability data because the probeset data would be inaccurate.

</div></div>

<div id="Help6Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>Panel Expression</H3>
These are the normalized log transformed expression values.  This tab shows expression values for each probeset accross all strains in the panel.  Note: Because of the normalization, do not compare normalized values between different probesets, but you can compare them accross strains.  <BR /><BR />

There are three ways to view the data.  The default produces a separate graph for each probeset.  Notice the range and size varies with each probeset.  The size varies directly with the range of values so you can quickly scan for more variable or consistent probesets. <BR /><BR />

The next method, if you view probesets grouped into one graph by tissue, shows the variability by strain in a single graph.  This allows you to look for probesets that vary significantly between strains.   Do not compare expression between probesets along the X-axis because the normalization does not allow comparison of expression values between probesets.  <BR /><BR />

The last method displays probesets in a series accross strains.  Again, it is important that you do not use this to compare expression values between probesets.  The best way to compare expression is to use the Exon Correlation Tab.<BR /><BR />

Masking: Probesets have been masked because the sequence for the probe set does not match the strain of mice or rats and as a result, the data from the probe set would be misleading or inaccurate.  If a probeset of interest is missing, adjust the filtering to allow additional probes(allow introns, opposite strand, make sure all other filters are unchecked, etc.) If it still does not display it means that the probeset was masked and there is no heritability data because the probeset data would be inaccurate.

</div></div>
<div id="Help7Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>Exon Correlation</H3>
This tab allows you to compare probeset expression, which should not be done directly in the expression tab.  This heatmap shows a selected transcript accross the top and draws exons that are represented by probesets along the top of the heatmap.  Exons that are excluded are color-coded to match the legend at the bottom of the page that shows why the exon was excluded from the heatmap.  Some exons may have multiple probesets representing them.<BR /><BR />

The heatmap is colored according to the correlation of one probeset to another across the strains in the panel.
</div></div>





<script type="text/javascript">
	var ie=false;
</script>

<!--[if IE]>
<script type="text/javascript">
	ie=true;
</script>
<![endif]-->

<script type="text/javascript">
var auto="<%=auto%>";


function openeQTL(){
	//$(".hidden").css('display','block');
	$(".hiddenLink").eq(0).trigger('click');
	
}



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

/*var READY = 2;
function registerAppletStateHandler() {
        // register onLoad handler if applet has
        // not loaded yet
	if (geneApplet.status < READY)  {                 
            geneApplet.onLoad = onLoadHandler;
	} else if (geneApplet.status >= READY) {
           	
	}
}
    
    function onLoadHandler() {
        if(geneApplet.getDownloadFinished()){
			
		}else{
		
		}
    }*/


$(document).ready(function() {
	
	if(auto=="true"){
  		displayWorking();
		auto="false";
  	}
	$('#geneimageFiltered').hide();

	//registerAppletStateHandler();
	//if(genURL!=null){
  	//	document.getElementById("inst").style.display= 'none';
		
  	//}
  
  
  
  $('.fancybox').fancybox({
		width:$(document).width(),
		height:$(document).height(),
		scrollOutside:false,
		afterClose: function(){
			$('body.noPrint').css("margin","5px auto 60px");
			return;
		}
  });
  
  $('.hiddenLink').fancybox({
		width:$(document).width(),
		height:$(document).height(),
		scrollOutside:false
  });
  
  $('#filteredRB').click( function(){
			$('#geneimageFiltered').show();
			$('#geneimageUnfiltered').hide();
  });
  
  $('#unfilteredRB').click( function(){
  			$('#geneimageFiltered').hide();
			$('#geneimageUnfiltered').show();

  });
  
  $('.inpageHelpContent').hide();
  
  $('.inpageHelpContent').dialog({ 
  		autoOpen: false,
		dialogClass: "helpDialog"
	});
  $('#Help1').click( function(){  		
		$('#Help1Content').dialog("open").css({'height':500,'font-size':12});
		positionHelp(211);
  });
  $('#Help2').click( function(){  		
		$('#Help2Content').dialog("open").css({'height':300,'font-size':12});
		positionHelp(400);
  });
  
  
  
  
	
}); // end ready

</script>




