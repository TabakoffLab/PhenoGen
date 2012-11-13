

<script type="text/javascript">
        if(!navigator.javaEnabled()){
                    document.write("<BR><BR><B>Error:</B>This feature requires the Java Plug-in which is either disabled or not installed.  Recent operating system and browser changes can disable java automatically.");
                    document.write("  This was done because the old versions are vulnerable to an attack which could take over your computer without your knowledge and access files or steal critical information like banking credentials.<BR><BR>Please first update or install Java from <a href=\"http://www.Java.com\">Java.com</a><BR><BR>To enable Java in your browser or operating system, see:<BR><BR> Firefox: <a href=\"http://support.mozilla.org/en-US/kb/unblocking-java-plugin\">http://support.mozilla.org/en-US/kb/unblocking-java-plugin</a><BR><BR>Internet Explorer: <a href=\"http://java.com/en/download/help/enable_browser.xml\">http://java.com/en/download/help/enable_browser.xml</a><BR><BR>Safari: <a href=\"http://docs.info.apple.com/article.html?path=Safari/5.0/en/9279.html\">http://docs.info.apple.com/article.html?path=Safari/5.0/en/9279.html</a><BR><BR>Chrome: <a href=\"http://java.com/en/download/faq/chrome.xml\">http://java.com/en/download/faq/chrome.xml</a><BR>");
        }
</script>

<% 
//ERROR SECTION: NO ENSEMBL ID

if(displayNoEnsembl){ %>
	<BR /><div> The Gene ID entered could not be translated to an Ensembl ID so that we can pull up gene information.  Please try an alternate Gene ID.  This gene ID has been reported so that we can improve the translation of many Gene IDs to Ensembl Gene IDs.  <BR /><BR /><b>Note:</b> at this time if there is no annotation in Ensembl for a gene we will not currently be able to display information about it, however if you have found your gene of interest on Ensembl and cannot enter a different Gene ID above entering the Ensembl Gene ID should work.</div>
<% } %>

<%if(genURL.size()>0){%>
	<script>
		$('.demo').hide();
	</script>

	<%if(ucscURL.get(selectedGene)!=null && !ucscURL.get(selectedGene).equals("") ){%>
        <div class="geneimage" style="text-align:center">
            <div class="inpageHelp" style="display:inline-block;position:relative;float:right;"><img id="Help1" src="../web/images/icons/help.png"  /></div>
    
            <div id="geneimageUnfiltered"  style="display:inline-block;"><a class="fancybox fancybox.iframe" href="<%=ucscURL.get(selectedGene)%>" title="UCSC Genome Browser"><img src="<%= contextRoot+"tmpData/geneData/"+selectedEnsemblID+"/"+selectedEnsemblID+".main.png"%>"/></a></div>
    
            <div id="geneimageFiltered" style="display:none;"><a class="fancybox fancybox.iframe" href="<%=ucscURLFiltered.get(selectedGene)%>" title="UCSC Genome Browser"><img src="<%= contextRoot+"tmpData/geneData/"+selectedEnsemblID+"/"+selectedEnsemblID+".main.filter.png"%>"/></a></div>
    
        </div><!-- end geneimage div -->
    
    
        <div class="geneimageControl" style="text-align:center">
      
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
      		<form id="geneSelection" name="geneSelection" method="post" action="">
            
                <label>Multiple genes were returned please select the gene of Interest:
                <select name="geneSelect" id="geneSelect" >
                    <%for(int i=0;i<firstEnsemblID.size();i++){
                        %>
                        <option value="<%=i%>" <%if(i==selectedGene){%>selected<%}%>>
						<%if(geneSymbol.get(i)!=null){%><%=geneSymbol.get(i)%> (<%=firstEnsemblID.get(i)%>) <%}else{%><%=firstEnsemblID.get(i)%> <%}%>
						<%if(genURL.get(i)!=null && genURL.get(i).startsWith("ERROR:")){%>Error<%}%>
                        </option>
                    <%}%>
                </select>
                </label>
            
            <input type="submit" name="action" id="selGeneBTN" value="Go" onClick="return displayWorking()">
            </form>
      <% }%>
	</div><!--end imageControl div -->

    <BR />
    <BR />
   
	 <% String tmpPath=applicationRoot + contextRoot+"tmpData/geneData/" +firstEnsemblID.get(selectedGene) + "/";	%>
    <div class="hidden"><a class="hiddenLink fancybox.iframe" href="web/GeneCentric/LocusSpecificEQTL.jsp?geneSymbol=<%=geneSymbol.get(selectedGene)%>&geneCentricPath=<%=tmpPath%>" title="eQTL"></a></div>
	<%if(genURL.get(selectedGene)!=null && !genURL.get(selectedGene).startsWith("ERROR:")){%>
		<script type="text/javascript">
            var ensembl="<%=selectedEnsemblID%>";
            var genURL="<%=genURL.get(selectedGene)%>";
        </script>
        <script type="text/javascript" src="http://java.com/js/deployJava.js"></script>
        <script type="text/javascript">
            var attributes = {
                code:       "genecentricviewer.GeneCentricViewer",
                archive:    "/web/GeneCentric/GeneCentricViewer.jar, /web/GeneCentric/lib/ExonCorrelationViewer2.jar, /web/GeneCentric/lib/swing-layout-1.0.4.jar",
                width:      1000,
                height:     1200
            };
            var parameters = {jnlp_href:"/web/GeneCentric/launch.jnlp",
                main_ensembl_id:ensembl,
                genURL:genURL
            }; 
            var version = "1.5"; 
            deployJava.runApplet(attributes, parameters, version);
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
	
};

function displayWorking(){
	document.getElementById("wait1").style.display = 'block';
	document.getElementById("inst").style.display= 'none';
	return true;
}

function hideWorking(){
	document.getElementById("wait1").style.display = 'none';
	document.getElementById("inst").style.display= 'none';
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

$(document).ready(function() {
	
	if(auto=="true"){
  		displayWorking();
		auto="false";
  	}
	$('#geneimageFiltered').hide();

	
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




