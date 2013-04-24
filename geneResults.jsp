
<script type="text/javascript">
var trackString="probe,numExonPlus,numExonMinus,noncoding,smallnc,refseq";
var minCoord=<%=min%>;
var maxCoord=<%=max%>;
var chr="<%=chromosome%>";
var filterExpanded=0;
var organism="<%=myOrganism%>";
var ucscgeneID="<%=firstEnsemblID.get(selectedGene)%>";
var ucsctype="Gene";
var tisLen=<%=tissuesList1.length%>;
</script>


<% 
//ERROR SECTION: NO ENSEMBL ID
	HashMap skipSMRNA=new HashMap();
	ArrayList<SmallNonCodingRNA> smncRNA=gdt.getSmallNonCodingRNA(min,max,chromosome,rnaDatasetID,myOrganism);
	
	//Match smncRNA to ensembl based on annotations
	
	for(int m=0;m<smncRNA.size();m++){
		SmallNonCodingRNA tmpRNA=smncRNA.get(m);
		ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Annotation> tmpAnnot=tmpRNA.getAnnotationBySource("Ensembl");
		if(tmpAnnot!=null&&tmpAnnot.size()>0){
			boolean found=false;
			String smncEnsID=tmpAnnot.get(0).getEnsemblGeneID();
			for(int n=0;n<fullGeneList.size()&&!found;n++){
				if(fullGeneList.get(n).getGeneID().equals(smncEnsID)){
					fullGeneList.get(n).addTranscript(tmpRNA);
					//smncRNA.remove(m);
					skipSMRNA.put(tmpRNA.getID(),1);
					found=true;
					//m--;
				}
			}
		}
	}
	
	String tmpURL=genURL.get(selectedGene);
	int second=tmpURL.lastIndexOf("/",tmpURL.length()-2);
	String folderName=tmpURL.substring(second+1,tmpURL.length()-1);
	DecimalFormat dfC = new DecimalFormat("#,###");
	String gcPath=applicationRoot + contextRoot+"tmpData/geneData/" +firstEnsemblID.get(selectedGene) + "/";
if(displayNoEnsembl){ %>
	<BR /><div> The Gene ID entered could not be translated to an Ensembl ID so that we can pull up gene information.  Please try an alternate Gene ID.  This gene ID has been reported so that we can improve the translation of many Gene IDs to Ensembl Gene IDs.  <BR /><BR /><b>Note:</b> at this time if there is no annotation in Ensembl for a gene we will not currently be able to display information about it, however if you have found your gene of interest on Ensembl and cannot enter a different Gene ID above entering the Ensembl Gene ID should work.</div>
<% } %>

<%if(genURL.size()>0){%>
<script type="text/javascript">
	$(document).on('click','.trigger',function(event){
			var baseName = $(this).attr("name");
			//alert(baseName);
			//$(this).toggleClass("less");
			expandCollapse(baseName);
	});
	$(document).on('click','.helpImage', function(event){
		var id=$(this).attr('id');
		$('#'+id+'Content').dialog( "option", "position",{ my: "right top", at: "left bottom", of: $(this) });
		$('#'+id+'Content').dialog("open").css({'font-size':12});
	}
	);
	$(document).on('click', '.legendBtn', function(event){
		$('#legendDialog').dialog( "option", "position",{ my: "left top", at: "left bottom", of: $(this) });
		$('#legendDialog').dialog("open");
	});
	//setupExpandCollapse();
</script>
<%if(genURL.size()>1){%>
<BR /><BR />
      		
            
                <label><span style="font-weight:bold;">Multiple genes were returned please select the gene of Interest:</span>
                <select name="geneSelectCBX" id="geneSelectCBX" >
                    <%for(int i=0;i<firstEnsemblID.size();i++){
                        %>
                        <option value="<%=firstEnsemblID.get(i)%>" <%if(i==selectedGene){%>selected<%}%>>
						<%if(geneSymbol.get(i)!=null){%><%="chr"+geneSymbol.get(i)%> (<%=firstEnsemblID.get(i)%>) <%}else{%><%=firstEnsemblID.get(i)%> <%}%>
						<%if(genURL.get(i)!=null && genURL.get(i).startsWith("ERROR:")){%>Error<%}%>
                        </option>
                    <%}%>
                </select>
                </label>
            
            <input type="submit" name="action" id="selGeneBTN" value="Go" onClick="enterSelectedGene()">
            
      <% }%>
<div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000;text-align:center; width:100%;">
    		<span class="triggerImage less" name="collapsableImage" >UCSC Genome Browser Image</span>
    		<div class="inpageHelp" style="display:inline-block;"><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div>
            
    		<span style="font-size:12px; font-weight:normal; float:left;"><span class="legendBtn"><img title="Click to view the legend." src="../web/images/icons/legend_7.png"></span></span>
            
        	<span style="font-size:12px; font-weight:normal; float:right;">
        		<input name="imageSizeCbx" type="checkbox" id="imageSizeCbx" checked="checked" /> Scroll Image - Viewable Size:
        		<select name="imageSizeSelect" id="imageSizeSelect">
        			<option value="200" >Smaller</option>
            		<option value="400" selected="selected">Normal</option>
                	<option value="600" >Larger</option>
                	<option value="800" >Largest</option>
            	</select>
            	<span class="Imagetooltip" title="This lets you control the viewable size of the image. In larger regions you can check this to allow simultaneous viewing of the image and table.  In smaller regions unchecking the box will allow you to view the entire image without scrolling."><img src="<%=imagesDir%>icons/info.gif"></span>
        	</span>
    </div>
    
        <div style="border-color:#CCCCCC; border-width:1px; border-style:inset; text-align:center;">
        <div id="collapsableImage" class="geneimage" >
       		<div id="imgLoad" style="display:none;"><img src="<%=imagesDir%>ucsc-loading.gif" /></div>
            <div id="geneImage" class="ucscImage"  style="display:inline-block; height:400px; width:980px; overflow:auto;">
            	<a class="fancybox fancybox.iframe" href="<%=ucscURL.get(0)%>" title="UCSC Genome Browser">
            	<img src="<%= contextRoot+"tmpData/geneData/"+firstEnsemblID.get(selectedGene)+"/ucsc.probe.numExonPlus.numExonMinus.noncoding.smallnc.refseq.png"%>"/></a>
            </div>
        </div><!-- end geneimage div -->
    	<div class="geneimageControl">
      		<div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000;text-align:center; width:100%;">
             Image Tracks/Table Filter:<div class="inpageHelp" style="display:inline-block; margin-left:10px;"><img id="HelpUCSCImageControl" class="helpImage" src="../web/images/icons/help.png" /></div>
             
            </div>
          	<form>
            <table class="list_base" style="text-align:left; width:100%;" cellspacing="0">	
            <TR>
				<TD class="rightBorder">
            		<span style=" font-weight:bold;">Image Tracks</span>
            	</TD>
                <TD>
                <input name="trackcbx" type="checkbox" id="probeCBX" value="probe" checked="checked" /> 
                Affymetrix Exon Array Probe Sets
                <select name="trackSelect" id="probeSelect">
                    <option value="1" >Dense</option>
                    <option value="3" selected="selected">Pack</option>
                    <option value="2" >Full</option>
                </select>
                <span class="Imagetooltip" title="All the non-masked Affymetrix Exon 1.0 ST probesets."><img src="<%=imagesDir%>icons/info.gif"></span>
                </TD>
                <TD>
                <input name="trackcbx" type="checkbox" id="filterprobeCBX" value="filterprobe" />
                Affy Exon Probe Sets Detected Above Background >1% of samples
                <select name="trackSelect" id="filterprobeSelect">
                    <option value="1" >Dense</option>
                    <option value="3" selected="selected">Pack</option>
                    <option value="2" >Full</option>
                </select>
                <span class="Imagetooltip" title="The non-masked Affymetrix Exon 1.0 ST probsets detected above background in >1% of samples in each tissue available."><img src="<%=imagesDir%>icons/info.gif"></span>
                </TD>
            </TR>
            <%if(myOrganism.equals("Rn")){%>
            <TR>
            	<TD class="rightBorder"></TD>
            	<TD>
                <input name="trackcbx" type="checkbox" id="snpCBX" value="snp" /> SNPs/Indels:
                 <select name="trackSelect" id="snpSelect">
                    <option value="1" selected="selected">Dense</option>
                    <option value="3" >Pack</option>
                    <option value="2" >Full</option>
                </select>
                <span class="Imagetooltip" title="SNPs/Indels from the DNA sequencing of the BN-Lx and the SHR inbred rat strain genome.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  SNPs/indels are in relation to the reference BN genome (rn5).  When labels are visible for the SNP/Indel features the labels are the reference sequence:strain sequence.<BR><BR> For example:<BR>T:A is a SNP where T was changed to an A in the strain specific Sequence.<BR>TA:TAA - is an insertion of an A in the reference Sequence TA.<BR>TAA:TA is the deletion of an A from the reference sequence TAA.<BR><BR>Capitalization<BR>Bases are reported in lower case if they are part of an algorithmically determined repeat region and are not altered from the reference. Reference bases that are altered (SNPs and deletions) are reported in uppercase in the reference field, and alternate bases (SNPs and insertions) are reported in uppercase."><img src="<%=imagesDir%>icons/info.gif"></span>
                </TD>
                <TD>
                <input name="trackcbx" type="checkbox" id="helicosCBX" value="helicos" /> Helicos Data:
                <select name="trackSelect" id="helicosSelect">
                    <option value="1" selected="selected">Dense</option>
                    <option value="2" >Full</option>
                </select>
                <span class="Imagetooltip" title="Helicos Single Molecule RNA-Seq data was collected from brains of the BN-Lx and SHR inbred rat strains based on ribosomal RNA depleted RNA.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  These data were not used in the transcriptome reconstruction."><img src="<%=imagesDir%>icons/info.gif"></span>
                </TD>
             </TR>
             <%}%>
             <TR>
            	<TD class="rightBorder"></TD>
                <TD>
                <input name="trackcbx" type="checkbox" id="bqtlCBX" value="qtl" /> bQTLs <span class="Imagetooltip" title="This track will display the publicly available bQTLs from Rat Genome Database. Any bQTLs that overlap the region are represented by a solid black bar.  More details on each bQTL are avaialbe in the region view."><img src="<%=imagesDir%>icons/info.gif"></span>
                </TD>
                <TD>
                <input name="trackcbx" type="checkbox" id="refseqCBX" value="refseq" checked="checked" /> RefSeq Transcripts <span class="Imagetooltip" title="Transcripts from the rat RefSeq database are displayed in blue."><img src="<%=imagesDir%>icons/info.gif"></span>
                 </TD>
             </TR>
            <TR>
            	<TD class="rightBorder topLine">
            		<span style=" font-weight:bold;">Image Tracks and Table Filters</span>
                    <span class="Imagetooltip" title="Checking or Unchecking any of these tracks to the right will include or exclude their features from the table below as well as the image above.">
                    	<img src="<%=imagesDir%>icons/info.gif"></span>
            	</TD>
                <TD  class="topLine">
                <input name="trackcbx" type="checkbox" id="exonPlusCBX" value="numExonPlus" checked="checked" />+ Strand Protein Coding<%if(myOrganism.equals("Rn")){%>/ PolyA+<%}%>
                <select name="trackSelect" id="exonPlusSelect">
                    <option value="1" >Dense</option>
                    <option value="3" selected="selected">Pack</option>
                    <option value="2" >Full</option>
                </select>
                <span class="Imagetooltip" title="This track consists of + strand transcripts from both the Ensembl database (Brown with Ensembl Transcript ID) and the PhenoGen de novo genome-guided transcriptome reconstruction based on paired-end RNA-Seq data generated from polyA+ selected RNA on the BN-Lx and SHR inbred rat strains (Light blue with label indicating tissue RNA was extracted from and including a unique numeric ID).  See legend for more details on color codes.  Including/excluding this track also filters related rows from the table below."><img src="<%=imagesDir%>icons/info.gif"></span>
                </TD>
                <TD  class="topLine">
                <input name="trackcbx" type="checkbox" id="exonMinusCBX" value="numExonMinus" checked="checked" />- Strand Protein Coding<%if(myOrganism.equals("Rn")){%> / PolyA+<%}%>
                <select name="trackSelect" id="exonMinusSelect">
                    <option value="1" >Dense</option>
                    <option value="3" selected="selected">Pack</option>
                    <option value="2" >Full</option>
                </select>
                <span class="Imagetooltip" title="This track consists of &ndash; strand transcripts from both the Ensembl database (Brown with Ensembl Transcript ID) and the PhenoGen de novo genome-guided transcriptome reconstruction based on paired-end RNA-Seq data generated from polyA+ selected RNA on the BN-Lx and SHR inbred rat strains (Light blue with label indicating tissue RNA was extracted from and including a unique numeric ID).  See legend for more details on color codes.  Including/excluding this track also filters related rows from the table below."><img src="<%=imagesDir%>icons/info.gif"></span>
                </TD>
                
            </TR>
            <TR>
            	<TD class="rightBorder"></TD>
            	<TD >
                <input name="trackcbx" type="checkbox" id="exonUkwnCBX" value="numExonUkwn" />Unknown Strand Protein Coding<%if(myOrganism.equals("Rn")){%>/ PolyA+<%}%>
                <select name="trackSelect" id="exonUkwnSelect">
                    <option value="1" >Dense</option>
                    <option value="3" selected="selected">Pack</option>
                    <option value="2" >Full</option>
                </select>
                <span class="Imagetooltip" title="This track consists of single exon transcripts from the de novo genome-guided transcriptome reconstruction based on polyA+ selected RNA from the BN-Lx and SHR inbred rat strains, where strand could not be determined."><img src="<%=imagesDir%>icons/info.gif"></span>
                </TD>
                <TD>
                <input name="trackcbx" type="checkbox" id="noncodingCBX" value="noncoding" checked="checked" />Long Non-Coding <%if(myOrganism.equals("Rn")){%>/ NonPolyA+<%}%>
                <select name="trackSelect" id="noncodingSelect">
                    <option value="1" >Dense</option>
                    <option value="3" selected="selected">Pack</option>
                    <option value="2" >Full</option>
                </select>
                <span class="Imagetooltip" title="This track consists of Long Non-Coding RNAs(>=200bp) from Ensembl(Purple,Ensembl ID) and PhenoGen RNA-Seq(Green,Tissue.#).  For Ensembl Transcripts this includes any biotype other than protein coding.  For PhenoGen RNA-Seq it includes any transcript detected in the Non-PolyA+ fraction."><img src="<%=imagesDir%>icons/info.gif"></span>
                </TD>
                
            </TR>
            <TR>
            	<TD class="rightBorder"></TD>
                <TD>
                <input name="trackcbx" type="checkbox" id="smallncCBX" value="smallnc" checked="checked" /> Small RNA
                <select name="trackSelect" id="smallncSelect">
                    <option value="1" >Dense</option>
                    <option value="3" selected="selected">Pack</option>
                    <option value="2" >Full</option>
                </select> 
                <span class="Imagetooltip" title="This track consists of small RNAs(<200bp) from Ensembl(Yellow,Ensembl ID) and PhenoGen RNA-Seq(Green,smRNA.#)."><img src="<%=imagesDir%>icons/info.gif"></span>
                </TD>
                <TD></TD>
            </TR>
            
             </table>   
             </form>
         
		 
          </div><!--end imageControl div -->
    </div><!--end Border Div -->
    <BR />
    <div id="legendDialog"  title="UCSC Image/Table Rows Legend" class="legendDialog" style="display:none">
                <%@ include file="/web/GeneCentric/legendBox.jsp" %>
    </div>
<script type="text/javascript">
	hideWorking();
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
	
	$("span.triggerImage").click(function(){
							var baseName = $(this).attr("name");
									var thisHidden = $("div#" + baseName).is(":hidden");
									$(this).toggleClass("less");
									if (thisHidden) {
								$("div#" + baseName).show();
									} else {
								$("div#" + baseName).hide();
									}
							});
							
	$('#legendDialog').dialog({
		autoOpen: false,
		dialogClass: "legendDialog",
		width: 350,
		height: 350,
		zIndex: 999
	});
	
	/*$('.legendBtn').click( function(){
		$('#legendDialog').dialog( "option", "position",{ my: "left top", at: "left bottom", of: $(this) });
		$('#legendDialog').dialog("open");
	});*/
	$('.Imagetooltip').tooltipster({
		position: 'top-right',
		maxWidth: 250,
		offsetX: 24,
		offsetY: 5,
		//arrow: false,
		interactive: true,
   		interactiveTolerance: 350
	});
	
</script>

    <BR />

<div class="cssTab" id="mainTab" >
    <ul>
      <li ><a id="geneTabID" href="#geneList" title="What genes are found in this area?" style="top:-30px;">Features<BR />Physically Located Gene Region</a><div class="inpageHelp" style="float:right;position: relative; top: -84px; left:-2px;"><img id="HelpGenesInRegion" class="helpImage" src="../web/images/icons/help.png" /></div></li>
      <li ><a id="qtlTabID" href="#qtlList" title="" style="top:-30px;width:75px;">eQTL</a><div class="inpageHelp" style="float:right;position: relative; top: -84px; left:-2px;"><img id="HelpForwardeQTLTab" class="helpImage" src="../web/images/icons/help.png" /></div></li>
      <li ><a id="affyTabID" href="#affyExon" title="" style="top:-30px;">Affy Exon<BR />
      Probe Set Details</a>
        <div class="inpageHelp" style="float:right;position: relative; top: -84px; left:-2px;"><img id="HelpAffyJavaData" class="helpImage" src="../web/images/icons/help.png" /></div></li>
      
     </ul>
<div id="geneList" class="modalTabContent" style=" display:none; position:relative;top:27px;border-color:#CCCCCC; border-width:1px 0px 0px 0px; border-style:inset;width:1000px;">
 <table class="geneFilter">
                	<thead>
                    	<TR>
                    	<TH style="width:50%"><span class="trigger" id="geneListFilter1" name="geneListFilter" style="position:relative;text-align:left;">Filter List</span><span class="geneListToolTip" title="Click the + icon to view filtering Options."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                        <TH style="width:50%"><span class="trigger" id="geneListFilter2" name="geneListFilter" style=" position:relative;text-align:left;">View Columns</span><span class="geneListToolTip" title="Click the + icon to view Columns you can show/hide in the table below."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                        <div class="inpageHelp" style="display:inline-block; position:relative;float:right; top:4px; left:-3px;"><img id="Help4" class="helpImage" src="../web/images/icons/help.png" /></div>
                        </TR>
                        
                    </thead>
                	<tbody id="geneListFilter" style="display:none;">
                    	<TR>
                        	<td>
                            <%if(myOrganism.equals("Rn")){%>
                                Exclude single exon RNA-Seq Transcripts
                            	<input name="chkbox" type="checkbox" id="exclude1Exon" value="exclude1Exon" />
                                <span class="geneListToolTip" title="This will hide the single exon transcripts from the table when selected."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <BR />
                        	<%}%>
                        
                            eQTL P-Value Cut-off:
                                             <select name="pvalueCutoffSelect1" id="pvalueCutoffSelect1">
                                            		<option value="0.1" <%if(forwardPValueCutoff==0.1){%>selected<%}%>>0.1</option>
                                                    <option value="0.01" <%if(forwardPValueCutoff==0.01){%>selected<%}%>>0.01</option>
                                                    <option value="0.001" <%if(forwardPValueCutoff==0.001){%>selected<%}%>>0.001</option>
                                                    <option value="0.0001" <%if(forwardPValueCutoff==0.0001){%>selected<%}%>>0.0001</option>
                                                    <option value="0.00001" <%if(forwardPValueCutoff==0.00001){%>selected<%}%>>0.00001</option>
                                            </select>
                                            <span class="geneListToolTip" title="This will filter out eQTL with lower confidence than the selected threshold.(will not remove rows from the table just the entries in the eQTL columns)"><img src="<%=imagesDir%>icons/info.gif"></span>
                                            <!--Require an eQTL below cut-off<input name="chkbox" type="checkbox" id="rqQTLCBX" value="rqQTLCBX"/>-->
                            </td>
                        	<td>
                            	<div class="columnLeft">
                                	<%if(myOrganism.equals("Rn")){%>
                                	<input name="chkbox" type="checkbox" id="matchesCBX" value="matchesCBX" checked="checked"/> RNA-Seq Transcript Matches <span class="geneListToolTip" title="Shows/Hides a description of the reason the RNA-Seq transcript was matched to the Ensembl Gene/Transcript."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    <%}%>
                                	
                                    <input name="chkbox" type="checkbox" id="geneIDCBX" value="geneIDCBX" checked="checked" /> Gene ID <span class="geneListToolTip" title="Shows/Hides the Gene ID column containing the Ensembl Gene ID and links to external Databases when available."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                   
                                    <input name="chkbox" type="checkbox" id="geneDescCBX" value="geneDescCBX" checked="checked" /> Description <span class="geneListToolTip" title="Shows/Hides Gene Description column whichcontains the Ensembl Description or any annotations for RNA-Seq transcripts not associated with an Ensembl Gene/Transcript"><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="geneBioTypeCBX" value="geneBioTypeCBX" checked="checked" /> BioType <span class="geneListToolTip" title="Shows/Hides Ensembl biotype or RNA-Seq category column."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="geneTracksCBX" value="geneTracksCBX" checked="checked" /> Tracks <span class="geneListToolTip" title="Shows/Hides the Image Tracks columns which contain an X when a feature appears in one of the three tracks."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    
                                   
                                </div>
                                <div class="columnRight">
                                	<input name="chkbox" type="checkbox" id="geneLocCBX" value="geneLocCBX" checked="checked" /> Location and Strand <span class="geneListToolTip" title="Shows/Hides the Chromosome, Start base pair, End base pair, and strand columns for the feature."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                 	
                                    <input name="chkbox" type="checkbox" id="heritCBX" value="heritCBX" checked="checked" /> Heritability <span class="geneListToolTip" title="Shows/Hides all of the Affymetrix Probeset Heritability data."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                	
                                	<input name="chkbox" type="checkbox" id="dabgCBX" value="dabgCBX" checked="checked" /> Detection Above Background <span class="geneListToolTip" title="Shows/Hides all of the Affymetrix Probeset Detection Above Background data."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="eqtlAllCBX" value="eqtlAllCBX" checked="checked" /> eQTLs All <span class="geneListToolTip" title="Shows/Hides all of the eQTL columns."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="eqtlCBX" value="eqtlCBX" checked="checked" /> eQTLs Tissues <span class="geneListToolTip" title="Shows/Hides all of the eQTL tissue specific columns while preserving a list of transcript clusters with a link to the circos plot."><img src="<%=imagesDir%>icons/info.gif"></span>
                                </div>

                            </TD>
                        
                        </TR>
                        </tbody>
                        
                  </table>
          
          
          <%
		  	String[] hTissues=new String[0];
			String[] dTissues=new String[0];
		  	if(fullGeneList.size()>0){
				edu.ucdenver.ccp.PhenoGen.data.Bio.Gene tmpGene=fullGeneList.get(0);
				log.debug("check:tmpGene:"+tmpGene.getGeneID()+"::"+firstEnsemblID.get(selectedGene));
					if(!tmpGene.getGeneID().equals(firstEnsemblID.get(selectedGene))){
						boolean found=false;
						for(int i=1;i<fullGeneList.size()&&!found;i++){
							log.debug("check:tmpGene:"+fullGeneList.get(i).getGeneID()+"::"+firstEnsemblID.get(selectedGene));
		  					if(fullGeneList.get(i).getGeneID().equals(firstEnsemblID.get(selectedGene))){
								tmpGene=fullGeneList.get(i);
								found=true;
							}
						}
					}
				%>
		 
          	<TABLE name="items"  id="tblGenes" class="list_base" cellpadding="0" cellspacing="0"  >
                <THEAD>
                    <tr>
                        <th 
						<%if(myOrganism.equals("Rn")){%>
                        colspan="12"
                        <%}else{%>
                        colspan="10"
                        <%}%> 
                        class="topLine noSort noBox"><span class="legendBtn"><img src="../web/images/icons/legend_7.png"></span></th>
                        <th <%if(myOrganism.equals("Rn")){%>
                        colspan="4"
                        <%}else{%>
                        colspan="2"
                        <%}%>  class="center noSort topLine">Transcript Information</th>
                        <th colspan="<%=4+tissuesList1.length*2+tissuesList2.length*2%>"  class="center noSort topLine" title="Dataset is available by going to Microarray Analysis Tools -> Analyze Precompiled Dataset or Downloads.">Affy Exon 1.0 ST PhenoGen Public Dataset(
							<%if(myOrganism.equals("Mm")){%>
                            	Public ILSXISS RI Mice
                            <%}else{%>
                            	Public HXB/BXH RI Rats (Tissue, Exon Arrays)
                            <%}%>
                            )<div class="inpageHelp" style="display:inline-block; "><img id="HelpAffyExon" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                    </tr>
                    <tr style="text-align:center;">
                        <th <%if(myOrganism.equals("Rn")){%>
                        colspan="12"
                        <%}else{%>
                        colspan="10"
                        <%}%>  class="topLine noSort noBox"></th>
                        <th colspan="1"  class="leftBorder rightBorder noSort"></th>
                        <%if(myOrganism.equals("Rn")){%>
                        <th colspan="2"  class="leftBorder rightBorder topLine noSort">RNA-Seq <span class="geneListToolTip" title="These columns summarize the # of transcripts reconstructed from the RNA-Seq data that match to this gene.  When read level data is available, the total reads for a feature and # of unique sequence reads is available in the next column.  The view RNA-Seq(currently it is only available for the small RNA fraction) and view(under View Details) links can provide more detail on read sequences and reconstructed transcripts respectively."><img src="<%=imagesDir%>icons/info.gif"></span></th>
                        <%}%>
                        <th colspan="1"  class="leftBorder rightBorder noSort"></th>
                        <th colspan="1"  class="leftBorder rightBorder noSort"></th>
                        <th colspan="<%=tissuesList1.length%>"  class="center noSort topLine">Probe Sets > 0.33 Heritability
                          <div class="inpageHelp" style="display:inline-block; "><img id="HelpProbeHerit" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                        <th colspan="<%=tissuesList1.length%>" class="center noSort topLine">Probe Sets > 1% DABG
                          <div class="inpageHelp" style="display:inline-block; "><img id="HelpProbeDABG" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                        <th colspan="<%=3+tissuesList2.length*2%>" class="center noSort topLine" title="eQTLs at the Gene Level.  These are calculated for Transcript Clusters which are Gene Level and not individual transcripts.">eQTLs(Gene/Transcript Cluster ID)<div class="inpageHelp" style="display:inline-block; "><img id="HelpeQTL" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                    </tr>
                    <tr style="text-align:center;">
                        <th <%if(myOrganism.equals("Rn")){%>
                        colspan="6"
                        <%}else{%>
                        colspan="5"
                        <%}%>  class="topLine noSort noBox"></th>
                        <th colspan="3"  class="topLine leftBorder rightBorder noSort">Image Tracks Represented in Table</th>
                        <th <%if(myOrganism.equals("Rn")){%>
                        colspan="3"
                        <%}else{%>
                        colspan="2"
                        <%}%>  class="topLine noSort noBox"></th>
                        <th <%if(myOrganism.equals("Rn")){%>
                        colspan="2"
                        <%}else{%>
                        colspan="1"
                        <%}%>  class="topLine leftBorder rightBorder noSort"># Transcripts <span class="geneListToolTip" title="The number of transcripts assigned to this gene.  Ensembl is the number of ensembl annotated transcripts.  RNA-Seq is the number of RNA-Seq transcripts assigned to this gene.  The RNA-Seq Transcript Matches column contains additional details about why transcripts were or were not matched to a particular gene."><img src="<%=imagesDir%>icons/info.gif"></span></th>
                        <%if(myOrganism.equals("Rn")){%>
                        	<th colspan="1"  class="leftBorder rightBorder noSort"></th>
                        <%}%>
                        <th colspan="1"  class="leftBorder rightBorder noSort"></th>
                        <th colspan="1"  class="leftBorder rightBorder noSort"></th>
                        <th colspan="<%=tissuesList1.length%>"  class="leftBorder rightBorder noSort noBox"></th>
                        <th colspan="<%=tissuesList1.length%>"  class="leftBorder rightBorder noSort noBox"></th>
                        <th colspan="1"  class="leftBorder noSort"></th>
                        <th colspan="2"  class="noBox noSort"></th>
                        <%for(int i=0;i<tissuesList2.length;i++){%>
                    		<TH colspan="2" class="center noSort topLine"><%=tissuesList2[i]%></TH>
                    	<%}%>
                    </tr>
                    <tr class="col_title">
                    <TH>Image ID (Transcript/Feature ID) <span class="geneListToolTip" title="Feature IDs that correspond to features in the various image tracks above."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <%if(myOrganism.equals("Rn")){%>
                    <TH>RNA-Seq Transcript Matches <span class="geneListToolTip" title="Information about how a RNA-Seq transcript was matched to an Ensembl Gene/Transcript.  Click if a + icon is present to view the remaining transcripts."><img src="<%=imagesDir%>icons/info.gif"></span></th>
                    <%}%>
                    <TH>Gene Symbol <span class="geneListToolTip" title="The Gene Symbol from Ensembl if available.  Click to view detailed information for that gene."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>Gene ID</TH>
                    <TH width="10%">Gene Description <span class="geneListToolTip" title="The description from Ensembl or annotations from various sources if the feature is not found in Ensembl."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>BioType <span class="geneListToolTip" title="The Ensembl biotype or RNA-Seq fraction and size."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>Protein Coding 
					<%if(myOrganism.equals("Rn")){%>
                    	/ PolyA+ 
                    	<span class="geneListToolTip" title="An &quot;X&quot; in this column indicates that this feature is from one of the 3 tracks in the image above that consists of protein-coding transcripts from Ensembl and transcripts from the transcriptome reconstruction that were identified in the polyA+ fraction of RNA.">
                    <%}else{%>
                    	<span class="geneListToolTip" title="An &quot;X&quot; in this column indicates that this feature is from one of the 3 tracks in the image above that consists of protein-coding transcripts from Ensembl.">
                    <%}%>
                    <img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>Long Non-Coding
					<%if(myOrganism.equals("Rn")){%>
                     / Non PolyA+ <span class="geneListToolTip" title="An &quot;X&quot; in this column indicates that this feature is from the track in the image above that consists of transcripts from Ensembl that are not protein coding and transcripts from the transcriptome reconstruction that were identified in only in the total RNA fraction.">
                     <%}else{%>
                     	<span class="geneListToolTip" title="An &quot;X&quot; in this column indicates that this feature is from the track in the image above that consists of transcripts from Ensembl that are not protein coding and greater than or equal to 200 base pairs in length.">
                     <%}%>
                     <img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>Small RNA <span class="geneListToolTip" title="An &quot;X&quot; in this column indicates that this feature is from the track in the image above that consists of transcripts from Ensembl that are less than 350 bp and transcribed features from the small RNA fraction (<200 bp).  This track may include protein-coding and non-protein-coding features.  See legend for details on color coding."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>Location</TH>
                    <TH>Strand</TH>
                    <%if(myOrganism.equals("Rn")){%>
                    <TH >Exon SNPs / Indels <span class="geneListToolTip" title="A count of SNPs and indels identified in the DNA-Seq data for the BN-Lx and SHR strains that fall within an exon (including untranslated regions) of at least one transcript.  Number of SNPs is on the left side of the / number of indels is on the right.  Counts are summarized for each strain when compared to the BN reference genome (Rn5).  When the same SNP/indel occurs in both, a count of the common SNPs/indels is included.  When these common counts occur they have been subtracted from the strain specific counts."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <%}%>
                    <TH>Ensembl</TH>
                    <%if(myOrganism.equals("Rn")){%>
                    <TH>RNA-Seq</TH>
                    <TH>Total Reads<HR />Read Sequences<span class="geneListToolTip" title="For Small RNAs from RNA-Seq this column includes the total number of reads for the feature and the number of unique reads."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <%}%>
                    <TH>View Details <span class="geneListToolTip" title="This column links to a UCSC image of the gene, with controls to view any of the available tracks in the region."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>Total Probe Sets <span class="geneListToolTip" title="The total number of non-masked probesets that overlap the region."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    
                    <%for(int i=0;i<tissuesList1.length;i++){%>
                    	<TH><%=tissuesList1[i]%> Count<HR />(Avg)</TH>
                    <%}%>
                    <%for(int i=0;i<tissuesList1.length;i++){%>
                    	<TH><%=tissuesList1[i]%> Count<HR />(Avg)</TH>
                    <%}%>
                    <TH>Transcript Cluster ID <span class="geneListToolTip" title="Transcript Cluster ID- The unique ID assigned by Affymetrix.  eQTLs are calculated for this annotation at the gene level by combining probe set data across the gene."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>Annotation Level <span class="geneListToolTip" title="The annotation level of the Transcript Cluster.  This denotes the confidence in the annotation by Affymetrix.  The confidence decreases from highest to lowest in the following order: Core,Extended,Full,Ambiguous."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>View Genome-Wide Associations <span class="geneListToolTip" title="Genome Wide Associations- Shows all the locations with a P-value below the cutoff selected.  Circos is used to create a plot of each region in each tissue associated with expression of the gene selected."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <%for(int i=0;i<tissuesList2.length;i++){%>
                    	<TH># of eQTLs with p-value <  <%=forwardPValueCutoff%> <span class="geneListToolTip" title="The number of regions in the genome significantly associated with transcript cluster expression (p-value < currently selected cut-off(see Filter List)), i.e. the number of eQTL."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                        <TH>Minimum<BR /> P-Value<HR />Location <span class="geneListToolTip" title="The genomic location of the most significant eQTL for this transcript clusters.  Click the location to view that region."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <%}%>
                    </tr>
                </thead>
                
                <tbody style="text-align:center;">
					<%DecimalFormat df2 = new DecimalFormat("#.##");
					DecimalFormat df0 = new DecimalFormat("###");
					DecimalFormat df4 = new DecimalFormat("#.####");
						
					for(int i=0;i<fullGeneList.size();i++){
                        edu.ucdenver.ccp.PhenoGen.data.Bio.Gene curGene=fullGeneList.get(i);
						TranscriptCluster tc=curGene.getTranscriptCluster();
                        HashMap hCount=curGene.getHeritCounts();
                        HashMap dCount=curGene.getDabgCounts();
						HashMap hSum=curGene.getHeritAvg();
                        HashMap dSum=curGene.getDabgAvg();
						String chr=curGene.getChromosome();
						String viewClass="codingRNA";
						ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Transcript> tmpTrx=curGene.getTranscripts();
						if(!chr.startsWith("chr")){
							chr="chr"+chr;
						}
                        %>
                        <TR class="
						<% String geneID="";
						if(curGene.getSource().equals("RNA Seq")&&curGene.isSingleExon()){%>
                        	singleExon
						<%}
						if(tc!=null){%>
                        	eqtl
                        <%}
						if(curGene.getBioType().equals("protein_coding") && curGene.getLength()>=200){
							if(curGene.getStrand().equals("+")){%>
                        		numExonPlus
                            <%}else if(curGene.getStrand().equals("-")){%>
                            	numExonMinus
                            <%}else{%>
                            	numExonUkwn
							<%}%>
						<%}else if(!curGene.getBioType().equals("protein_coding") && curGene.getLength()>=200){
								viewClass="longRNA";%>
                        		noncoding
                        <%}else if(curGene.getLength()<200){
								viewClass="smallRNA";%>
                            	smallnc
						<%}%>
                        <%if(curGene.getGeneID().startsWith("ENS")){%>
                        	ensembl
                        <%}%>
                        ">
                        	<TD>
                            	<%	String tmpList="";
									if((curGene.getTranscriptCountRna()+curGene.getTranscriptCountEns()) > 5){
										tmpList="<span class=\"tblTrigger\" name=\"fg_"+i+"\">";
										for(int l=0;l<tmpTrx.size();l++){
												if(l<5){
														tmpList=tmpList+tmpTrx.get(l).getID()+"<BR>";
												}else if(l==5){
													tmpList=tmpList+"</span><span id=\"fg_"+i+"\" style=\"display:none;\">"+tmpTrx.get(l).getID()+"<BR>";
												}else{
													tmpList=tmpList+tmpTrx.get(l).getID()+"<BR>";
												}
										}
										tmpList=tmpList+"</span>";
									}else{
										for(int l=0;l<tmpTrx.size();l++){
												if(l==0){
														tmpList=tmpTrx.get(l).getID()+"<BR>";
												}else{
														tmpList=tmpList+tmpTrx.get(l).getID()+"<BR>";
												}
										}
									}%>
                                	<%=tmpList%>
                            </TD>
                            <%if(myOrganism.equals("Rn")){%>
                                <TD>
                                    <%	String tmpList2="";
                                            if(curGene.getGeneID().startsWith("ENS")){
                                                    tmpList2="";
                                                    int idx=0;
                                                    for(int l=0;l<tmpTrx.size();l++){
                                                        if(!tmpTrx.get(l).getID().startsWith("ENS")){
                                                            tmpList2=tmpList2+"<B>"+tmpTrx.get(l).getID()+"</B> - <BR>"+tmpTrx.get(l).getMatchReason()+"<BR>";
                                                            idx++;
                                                        }
                                                    }
                                                    if(idx>1){
                                                        tmpList2="<span class=\"tblTrigger\" name=\"rg_"+i+"\">"+tmpList2;
                                                        int ind1=tmpList2.indexOf("<BR>");
                                                        int ind2=tmpList2.indexOf("<BR>",ind1+4);
                                                        String newTmp=tmpList2.substring(0,ind2);
                                                        newTmp=newTmp+"</span><BR><span id=\"rg_"+i+"\" style=\"display:none;\">"+tmpList2.substring(ind2+4);
                                                        tmpList2=newTmp;
                                                        tmpList2=tmpList2+"</span>";
                                                    }
                                                
                                            }
                                        %>
                                        <%=tmpList2%>
                                </TD>
                            <%}%>
                            <TD title="View detailed transcription information for gene in a new window.">
							<%if(curGene.getGeneID().startsWith("ENS")){%>
                            	<a href="<%=lg.getGeneLink(curGene.getGeneID(),myOrganism,true,true,false)%>" target="_blank">
                            <%}else{%>
                            	<a href="<%=lg.getRegionLink(chr,curGene.getStart(),curGene.getEnd(),myOrganism,true,true,false)%>" target="_blank">
                            <%}%>
                            <%if(curGene.getGeneSymbol()!=null&&!curGene.getGeneSymbol().equals("")){
								geneID=curGene.getGeneSymbol();%>
									<%=curGene.getGeneSymbol()%>
                            <%}else{
								geneID=curGene.getGeneID();%>
                                	No Gene Symbol
                            <%}%>
                                </a>
                            </TD>
                            <%String description=curGene.getDescription();
									String shortDesc=description;
									String remain="";
									if(description.indexOf("[")>0){
										shortDesc=description.substring(0,description.indexOf("["));
										remain=description.substring(description.indexOf("[")+1,description.indexOf("]"));
									}
							%>
                            <TD >
                           
							<%if(curGene.getGeneID().startsWith("ENS")){%>
                            	<a href="<%=LinkGenerator.getEnsemblLinkEnsemblID(curGene.getGeneID(),fullOrg)%>" target="_blank" title="View Ensembl Gene Details"><%=curGene.getGeneID()%></a><BR />	
                                <span style="font-size:10px;">
								<%
																
									String tmpGS=curGene.getGeneID();
									String shortOrg="Mouse";
									String allenID="";
									if(myOrganism.equals("Rn")){
                                    	shortOrg="Rat";
									}
									if(curGene.getGeneSymbol()!=null&&!curGene.getGeneSymbol().equals("")){
										tmpGS=curGene.getGeneSymbol();
										allenID=curGene.getGeneSymbol();
                            		}
									if(allenID.equals("")&&!shortDesc.equals("")){
										allenID=shortDesc;
									}%>
                                    All Organisms:<a href="<%=LinkGenerator.getNCBILink(tmpGS)%>" target="_blank">NCBI</a> |
                                    <a href="<%=LinkGenerator.getUniProtLinkGene(tmpGS)%>" target="_blank">UniProt</a> <BR />
                                   <%=shortOrg%>: <a href="<%=LinkGenerator.getNCBILink(tmpGS,myOrganism)%>" target="_blank">NCBI</a> | <a href="<%=LinkGenerator.getUniProtLinkGene(tmpGS,myOrganism)%>" target="_blank">UniProt</a> | 
                                    <%if(myOrganism.equals("Mm")){%>
                                        <a href="<%=LinkGenerator.getMGILink(tmpGS)%>" target="_blank">MGI</a> 
                                        <%if(!allenID.equals("")){%>
                                        	| <a href="<%=LinkGenerator.getBrainAtlasLink(allenID)%>" target="_blank">Allen Brain Atlas</a>
                                        <%}%>
                                    <%}else{%>
                                        <a href="<%=LinkGenerator.getRGDLink(tmpGS,myOrganism)%>" target="_blank">RGD</a>
                                    <%}%>
                                 </span>
                            <%}else{%>
                            	<%=curGene.getGeneID()%>
                            <%}%>
                            </TD>
                             
                            <%String bioType=curGene.getBioType();
							  
							%>
                            <TD title="<%=remain%>">
								<%=shortDesc%>
                                <% HashMap displayed=new HashMap();
								HashMap bySource=new HashMap();
								for(int k=0;k<tmpTrx.size();k++){
                                	ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Annotation> annot=tmpTrx.get(k).getAnnotation();
									if(annot!=null&&annot.size()>0){
										for(int j=0;j<annot.size();j++){
											if(!annot.get(j).getSource().equals("AKA")&&!annot.get(j).getSource().equals("AlignedSequences")){
												String tmpHTML=annot.get(j).getDisplayHTMLString(true);
												if(!displayed.containsKey(tmpHTML)){
													displayed.put(tmpHTML,1);
													if(bySource.containsKey(annot.get(j).getSource())){
														String list=bySource.get(annot.get(j).getSource()).toString();
														list=list+", "+tmpHTML;
														bySource.put(annot.get(j).getSource(),list);
													}else{
														bySource.put(annot.get(j).getSource(),tmpHTML);
													}
                                            		
                                                }
                                        	}
                                    	}
                                	}
								}
								Set keys=bySource.keySet();
                				Iterator itr=keys.iterator();
								while(itr.hasNext()){
									String source=itr.next().toString();
									String values=bySource.get(source).toString();
								%>
                                	<%="<BR>"+source+":"+values%>
                                <%}%>
                            </TD>
                            
                            <TD>
                            	<%if(!curGene.getGeneID().startsWith("ENS")){
									String tmpTitle="Based on detection in PolyA+ fraction";
									if(!bioType.equals("protein_coding")){
										tmpTitle="Based on detection only in TotalRNA fraction";
									}%>
                                	<span title="<%=tmpTitle%>">
                                	<%=bioType%>
                                    </span>
                                <%}else{%>
									<%=bioType%>
                            	<%}%>
                            </TD>
                            <%if(bioType.equals("protein_coding")&& curGene.getLength()>=200){%>
                                <TD class="leftBorder">X</TD>
                                <TD class="leftBorder"></TD>
                                <TD class="leftBorder rightBorder"></TD>
                            <%}else{
								if(curGene.getLength()>=200){%>
                                    <TD class="leftBorder"></TD>
                                    <TD class="leftBorder">X</TD>
                                    <TD class="leftBorder rightBorder"></TD>
                                <%}else{%>
                                	<TD class="leftBorder"></TD>
                                    <TD class="leftBorder"></TD>
                                    <TD class="leftBorder rightBorder">X</TD>
                                <%}%>
                            <%}%>
                            
                            <TD><%=chr+": "+dfC.format(curGene.getStart())+"-"+dfC.format(curGene.getEnd())%></TD>
                            <TD><%=curGene.getStrand()%></TD>
                            <%if(myOrganism.equals("Rn")){%>
                            <TD>
                            	<%if(curGene.getSnpCount("common","SNP")>0 || curGene.getSnpCount("common","Indel")>0 ){%>
                            		Common: <%=curGene.getSnpCount("common","SNP")%> / <%=curGene.getSnpCount("common","Indel")%><BR />
                                <%}%>
                            	<%if(curGene.getSnpCount("BNLX","SNP")>0 || curGene.getSnpCount("BNLX","Indel")>0 ){%>
                            		BN-Lx: <%=curGene.getSnpCount("BNLX","SNP")%> / <%=curGene.getSnpCount("BNLX","Indel")%><BR />
                                <%}%>
                                <%if(curGene.getSnpCount("SHRH","SNP")>0 || curGene.getSnpCount("SHRH","Indel")>0){%>
                                	SHR: <%=curGene.getSnpCount("SHRH","SNP")%> / <%=curGene.getSnpCount("SHRH","Indel")%>
                                <%}%>
                            </TD>
                            <%}%>
                            <TD class="leftBorder"><%=curGene.getTranscriptCountEns()%></TD>
                            <%if(myOrganism.equals("Rn")){%>
                            <TD>
								<%=curGene.getTranscriptCountRna()%>
                            </TD>
                            <TD>
                            	<%if(curGene.getTranscriptCountRna()>0 && !bioType.equals("protein_coding") && curGene.getLength()<350 ){
									ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Transcript> smRNAList=curGene.getSMNCTranscripts();
									String tmpIDList="";
									String tmpNameList="";
									for(int n=0;n<smRNAList.size();n++){
										SmallNonCodingRNA tmpRNA=(SmallNonCodingRNA)smRNAList.get(n);
										if(n==0){
											tmpIDList=Integer.toString(tmpRNA.getNumberID());
											tmpNameList=tmpRNA.getID();
										}else{
											tmpIDList=tmpIDList+","+tmpRNA.getNumberID();
											tmpNameList=tmpNameList+","+tmpRNA.getID();
										}
									}%>
                            		<span id="<%=tmpIDList+":"+tmpNameList%>" class="viewSMNC">View RNA-Seq</span>
                                <%}%>
                            </TD>
                            <%}%>
                            <TD><span id="<%=chr+":"+(curGene.getMinMaxCoord()[0]-500)+"-"+(curGene.getMinMaxCoord()[1]+500)%>" name="<%=viewClass%>:<%=geneID%>" class="viewTrx">View</span></TD>
                            <TD class="leftBorder"><%=curGene.getProbeCount()%></TD>
                            
                            <%for(int j=0;j<tissuesList1.length;j++){
								Object tmpH=hCount.get(tissuesList1[j]);
								Object tmpHa=hSum.get(tissuesList1[j]);
								if(tmpH!=null){
									int count=Integer.parseInt(tmpH.toString());
									double sum=Double.parseDouble(tmpHa.toString());
									%>
                                	<TD <%if(j==0){%>class="leftBorder"<%}%>>
										<%=count%>
                                    	<%if(count>0){%>
                                        	<BR />
                                            (<%=df2.format(sum/count)%>)
										<%}%>
                                    </TD>
                                <%}else{%>
                                	<TD <%if(j==0){%>class="leftBorder"<%}%>>
                                    N/A
                                    </TD>
                                <%}%>
                            <%}%>
                            <%for(int j=0;j<tissuesList1.length;j++){
								Object tmpD=dCount.get(tissuesList1[j]);
								Object tmpDa=dSum.get(tissuesList1[j]);
								if(tmpD!=null){
									int count=Integer.parseInt(tmpD.toString());
									double sum=Double.parseDouble(tmpDa.toString());
								%>
                                	<TD <%if(j==0){%>class="leftBorder"<%}%>><%=count%>
                                    <%if(count>0){%><BR />(<%=df0.format(sum/count)%>%)<%}%>
                                    </TD>
                                <%}else{%>
                                	<TD <%if(j==0){%>class="leftBorder"<%}%>>N/A</TD>
                                <%}%>
                            <%}%>
                            <%	if(tc!=null){	
								//String[] curTissues=tc.getTissueList();%>
                            	
                                <TD class="leftBorder"><%=tc.getTranscriptClusterID()%></TD>
                            	
                                <TD><%=tc.getLevel()%></TD>
                                <TD>
                                	<a href="web/GeneCentric/setupLocusSpecificEQTL.jsp?geneSym=<%=curGene.getGeneSymbol()%>&ensID=<%=curGene.getGeneID()%>&chr=<%=tc.getChromosome()%>&start=<%=tc.getStart()%>&stop=<%=tc.getEnd()%>&level=<%=tc.getLevel()%>&tcID=<%=tc.getTranscriptClusterID()%>&curDir=<%=folderName%>" 
                                	target="_blank" title="View the circos plot for transcript cluster eQTLs">
										View Location Plot
                                	</a>
                                </TD>
                                <%for(int j=0;j<tissuesList2.length;j++){
									//log.debug("TABLE1:"+tissuesList2[j]);
									ArrayList<EQTL> qtlList=tc.getTissueEQTL(tissuesList2[j]);
									if(qtlList!=null){
										EQTL maxEQTL=qtlList.get(0);
									%>
                                        <TD class="leftBorder"><%=qtlList.size()%></TD>
                                        <TD>
                                        	<%if(maxEQTL.getPVal()<0.0001){%>
                                        		< 0.0001
											<%}else{%>
												<%=df4.format(maxEQTL.getPVal())%>
                                        	<%}%>
                                        	<BR />
                                        	<%if(maxEQTL.getMarker_start()!=maxEQTL.getMarker_end()){%>
                                                <a href="<%=lg.getRegionLink(maxEQTL.getMarkerChr(),maxEQTL.getMarker_start(),maxEQTL.getMarker_end(),myOrganism,true,true,false)%>" target="_blank" title="View Detailed Transcription Information for this region.">
                                                    chr<%=maxEQTL.getMarkerChr()+":"+dfC.format(maxEQTL.getMarker_start())+"-"+dfC.format(maxEQTL.getMarker_end())%>
                                                </a>
                                            <%}else{
												long start=maxEQTL.getMarker_start()-500000;
												long stop=maxEQTL.getMarker_start()+500000;
												if(start<1){
													start=1;
												}%>
                                            	<a href="<%=lg.getRegionLink(maxEQTL.getMarkerChr(),start,stop,myOrganism,true,true,false)%>" target="_blank" title="View Detailed Transcription Information for a region +- 500,000bp around the SNP location.">
                                            		chr<%=maxEQTL.getMarkerChr()+":"+dfC.format(maxEQTL.getMarker_start())%>
                                                 </a>
                                            <%}%>
                                        </TD>
                                    <%}else{%>
                                        <TD class="leftBorder"></TD>
                                        <TD></TD>
                                    <%}%>
                                <%}%>
                             <%}else{%>
                             	<TD class="leftBorder"></TD><TD></TD><TD></TD>
                                <%for(int j=0;j<tissuesList2.length;j++){%>
                                	<TD class="leftBorder"></TD><TD></TD>
                                <%}%>
                             <%}%>
                        </TR>
                    <%}%>
					<%if(smncRNA!=null){
						for(int i=0;i<smncRNA.size();i++){
							SmallNonCodingRNA rna=smncRNA.get(i);
							if(!skipSMRNA.containsKey(rna.getID())){
							%>
                        	<tr class="smallnc">
                            	<TD><%=rna.getID()%></TD>
                                <%if(myOrganism.equals("Rn")){%>
                                	<TD></TD>
                                <%}%>
                                <TD></TD>
                                <TD><% ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Annotation> ens=rna.getAnnotationBySource("Ensembl");
									if(ens!=null&&ens.size()>0){
										for(int k=0;k<ens.size();k++){%>
											<%=ens.get(k).getEnsemblLink()%>
                                        <%}%>
                                        <BR />	
                                		<span style="font-size:10px;">
											<%                
                                                String tmpGS=ens.get(0).getDisplayHTMLString(false);
												if(tmpGS.indexOf("-")>0){
													tmpGS=tmpGS.substring(0,tmpGS.indexOf("-"));
												}
                                                String shortOrg="Mouse";
                                                String allenID="";
                                                if(myOrganism.equals("Rn")){
                                                    shortOrg="Rat";
                                                }
                                                %>
                                                All Organisms:<a href="<%=LinkGenerator.getNCBILink(tmpGS)%>" target="_blank">NCBI</a> |
                                                <a href="<%=LinkGenerator.getUniProtLinkGene(tmpGS)%>" target="_blank">UniProt</a> <BR />
                                               <%=shortOrg%>: <a href="<%=LinkGenerator.getNCBILink(tmpGS,myOrganism)%>" target="_blank">NCBI</a> | <a href="<%=LinkGenerator.getUniProtLinkGene(tmpGS,myOrganism)%>" target="_blank">UniProt</a> | 
                                                <%if(myOrganism.equals("Mm")){%>
                                                    <a href="<%=LinkGenerator.getMGILink(tmpGS)%>" target="_blank">MGI</a> 
                                                    <%if(!allenID.equals("")){%>
                                                        | <a href="<%=LinkGenerator.getBrainAtlasLink(allenID)%>" target="_blank">Allen Brain Atlas</a>
                                                    <%}%>
                                                <%}else{%>
                                                    <a href="<%=LinkGenerator.getRGDLink(tmpGS,myOrganism)%>" target="_blank">RGD</a>
                                                <%}%>
                                             </span>
									<%}%>
                                </TD>
                                <TD>
									<% HashMap displayed=new HashMap();
                                    HashMap bySource=new HashMap();
									ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Annotation> annot=rna.getAnnotations();
									if(annot!=null&&annot.size()>0){
										for(int j=0;j<annot.size();j++){
											
												String tmpHTML=annot.get(j).getDisplayHTMLString(true);
												if(!displayed.containsKey(tmpHTML)){
													displayed.put(tmpHTML,1);
													if(bySource.containsKey(annot.get(j).getSource())){
														String list=bySource.get(annot.get(j).getSource()).toString();
														list=list+", "+tmpHTML;
														bySource.put(annot.get(j).getSource(),list);
													}else{
														bySource.put(annot.get(j).getSource(),tmpHTML);
													}
													
												}
										}
									}
                                    
                                    Set keys=bySource.keySet();
                                    Iterator itr=keys.iterator();
                                    while(itr.hasNext()){
                                        String source=itr.next().toString();
                                        String values=bySource.get(source).toString();
                                    %>
                                        <%="<BR>"+source+":"+values%>
                                    <%}%>
                                </TD>
                                <TD><span title="<200bp includes Coding and Non-Coding RNA">Small RNA</span></TD>
                                <TD class="leftBorder"></TD>
                                <TD class="leftBorder"></TD>
                                <TD class="leftBorder rightBorder">X</TD>
                                <TD>chr<%=rna.getChromosome()+":"+dfC.format(rna.getStart())+"-"+dfC.format(rna.getStop())%></TD>
                                <TD><%=rna.getStrand()%></TD>
                                <%if(myOrganism.equals("Rn")){%>
                                    <TD>
                                    
                                    <%if(rna.getSnpCount("common","SNP")>0 || rna.getSnpCount("common","Indel")>0 ){%>
                                        Common: <%=rna.getSnpCount("common","SNP")%> / <%=rna.getSnpCount("common","Indel")%><BR />
                                    <%}%>
                                    <%if(rna.getSnpCount("BNLX","SNP")>0 || rna.getSnpCount("BNLX","Indel")>0 ){%>
                                        BNLX: <%=rna.getSnpCount("BNLX","SNP")%> / <%=rna.getSnpCount("BNLX","Indel")%><BR />
                                    <%}%>
                                    <%if(rna.getSnpCount("SHRH","SNP")>0 || rna.getSnpCount("SHRH","Indel")>0){%>
                                        SHRH: <%=rna.getSnpCount("SHRH","SNP")%> / <%=rna.getSnpCount("SHRH","Indel")%>
                                    <%}%>
                                    </TD>
                                <%}%>
                                <TD class="leftBorder"></TD>
                                <%if(myOrganism.equals("Rn")){%>
                                    <TD></TD>
    
                                    
                                    <TD>
                                        <%=rna.getTotalReads()%><BR />
                                        <%=rna.getSeq().size()%><BR />
                                        <span id="<%=rna.getNumberID()+":"+rna.getID()%>" class="viewSMNC">View RNA-Seq</span>
                                    </TD>
                                <%}%>
                                <TD>
                                    <span id="chr<%=rna.getChromosome()+":"+(rna.getStart()-20)+"-"+(rna.getStop()+20)%>" name="smallRNA:<%=rna.getID()%>" class="viewTrx">View</span>                               
                                 </TD>
                                <TD class="leftBorder"></TD>
                                
                                <%for(int j=0;j<tissuesList1.length;j++){%>
                                   <TD <%if(j==0){%>class="leftBorder"<%}%>></TD>
                                <%}%>
                                <%for(int j=0;j<tissuesList1.length;j++){%>
                                    <TD <%if(j==0){%>class="leftBorder"<%}%>></TD>
                                <%}%>
                                <TD class="leftBorder"></TD>
                                <TD></TD>
                                <TD></TD>
                                <%for(int j=0;j<tissuesList2.length;j++){%>
                                    <TD class="leftBorder"></TD>
                                    <TD></TD>
                                <%}%>
                        </tr>
                    <%}
					}
					}%>
				 </tbody>
              </table>
          <%}else{%>
          	No genes found in this region.  Please expand the region and try again.
          <%}%>
 <div id="viewTrxDialog" class="trxDialog"></div>

<div id="viewTrxDialogOriginal"  style="display:none;"><div class="waitTrx"  style="text-align:center; position:relative; top:0px; left:0px;"><img src="<%=imagesDir%>wait.gif" alt="Loading..." /><BR />Please wait loading transcript data...</div></div>
</div>

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
	});
	
	
	var sortCol=<%=myOrganism.equals("Rn")?6:5%>;
	
	var tblGenes=$('#tblGenes').dataTable({
	"bPaginate": false,
	"bProcessing": true,
	"bStateSave": true,
	"bAutoWidth": true,
	"sScrollX": "950px",
	"sScrollY": "650px",
	"aaSorting": [[ sortCol, "desc" ]],
	"sDom": '<"leftSearch"fr><t>'
	/*"oTableTools": {
			"sSwfPath": "/css/swf/copy_csv_xls_pdf.swf"
		}*/

	});
	
	
	
	$('#mainTab div.modalTabContent:first').show();
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
				//setFilterTableStatus("geneListFilter");
				$('div#changingTabs').hide(10);
			return false;
        });
	$('#tblGenes').dataTable().fnAdjustColumnSizing();

	$('#tblGenes_wrapper').css({position: 'relative', top: '-56px'});
	//$('.singleExon').hide();
	
	$('#heritCBX').click( function(){
			var tmpCol=17;
			if(spec=="Mm"){
				tmpCol=13;
			}
			displayColumns(tblGenes, tmpCol,tisLen,$('#heritCBX').is(":checked"));
	  });
	  $('#dabgCBX').click( function(){
	  		var tmpCol=17+tisLen;
			if(spec=="Mm"){
				tmpCol=13+tisLen;
			}
			displayColumns(tblGenes, tmpCol ,tisLen,$('#dabgCBX').is(":checked"));
	  });
	  $('#eqtlAllCBX').click( function(){
	  		var tmpCol=17+tisLen*2;
			if(spec=="Mm"){
				tmpCol=13+tisLen*2;
			}
			displayColumns(tblGenes, tmpCol,tisLen*2+3,$('#eqtlAllCBX').is(":checked"));
	  });
		$('#eqtlCBX').click( function(){
			var tmpCol=17+tisLen*2+3;
			if(spec=="Mm"){
				tmpCol=13+tisLen*2+3;
			}
			displayColumns(tblGenes, tmpCol,tisLen*2,$('#eqtlCBX').is(":checked"));
	  });
	  $('#matchesCBX').click( function(){
			displayColumns(tblGenes,1,1,$('#matchesCBX').is(":checked"));
	  });
	   $('#geneIDCBX').click( function(){
	   		var tmpCol=3;
			if(spec=="Mm"){
				tmpCol=2;
			}
			displayColumns(tblGenes,tmpCol,1,$('#geneIDCBX').is(":checked"));
	  });
	  $('#geneDescCBX').click( function(){
	  		var tmpCol=4;
			if(spec=="Mm"){
				tmpCol=3;
			}
			displayColumns($(tblGenes).dataTable(),tmpCol,1,$('#geneDescCBX').is(":checked"));
	  });
	  
	  $('#geneBioTypeCBX').click( function(){
	  		var tmpCol=5;
			if(spec=="Mm"){
				tmpCol=4;
			}
			displayColumns($(tblGenes).dataTable(),tmpCol,1,$('#geneBioTypeCBX').is(":checked"));
	  });
	  $('#geneTracksCBX').click( function(){
	  		var tmpCol=6;
			if(spec=="Mm"){
				tmpCol=5;
			}
			displayColumns($(tblGenes).dataTable(),tmpCol,3,$('#geneTracksCBX').is(":checked"));
	  });
	  
	  $('#geneLocCBX').click( function(){
	  		var tmpCol=9;
			if(spec=="Mm"){
				tmpCol=8;
			}
			displayColumns($(tblGenes).dataTable(),tmpCol,2,$('#geneLocCBX').is(":checked"));
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
 	 });
	 
	 $("input[name='trackcbx']").change( function(){
	 		var type=$(this).val();
			updateTrackString();
			updateUCSCImage();
			if(type=="numExonUkwn" || type=="numExonPlus" || type=="numExonMinus" || type=="noncoding" || type=="smallnc"){
				/*if($('#rqQTLCBX').is(":checked")){
					$('tr.'+type).hide();
					type=type+".eqtl";
				}*/
				if($(this).is(":checked")){
					$('tr.'+type).show();
				}else{
					$('tr.'+type).hide();
				}
				tblGenes.fnDraw();
			}
			
	 });
	 
	 $("select[name='trackSelect']").change( function(){
	 	var id=$(this).attr("id");
		var cbx=id.replace("Select","CBX");
		if($("#"+cbx).is(":checked")){
			updateTrackString();
			updateUCSCImage();
		}
	 });
	 
	 $("span.tblTrigger").click(function(){
		var baseName = $(this).attr("name");
                var thisHidden = $("span#" + baseName).is(":hidden");
                $(this).toggleClass("less");
                if (thisHidden) {
			$("span#" + baseName).show();
                } else {
			$("span#" + baseName).hide();
                }
	});
	$('.geneListToolTip').tooltipster({
		position: 'top-right',
		maxWidth: 250,
		offsetX: 24,
		offsetY: 5,
		//arrow: false,
		interactive: true,
   		interactiveTolerance: 350
	});
</script>
<div id="qtlList" class="modalTabContent" style=" display:none; position:relative;top:27px;border-color:#CCCCCC; border-width:1px 0px 0px 0px; border-style:inset;width:1000px;">
	<%@ include file="/web/GeneCentric/geneEQTLPart.jsp" %>
</div>

<script type="text/javascript">
	$('#qtlTabID').click(function() {    
			$('div#changingTabs').show(10);
				//change the tab
				$('#mainTab ul li a').removeClass('selected');
				$(this).addClass('selected');
				var currentTab = $(this).attr('href'); 
				$('#mainTab div.modalTabContent').hide();       
				$(currentTab).show();
				$('div#changingTabs').hide(10);
			return false;
        });
</script>

<div id="affyExon" class="modalTabContent" style="display:none; position:relative;top:27px;border-color:#CCCCCC; border-width:1px 0px 0px 0px; border-style:inset;width:100%;">   
	 
    <div class="hidden"><a class="hiddenLink fancybox.iframe" href="web/GeneCentric/LocusSpecificEQTL.jsp?hiddenGeneSymbol=<%=geneSymbol.get(selectedGene)%>&hiddenGeneCentricPath=<%=gcPath%>" title="eQTL"></a></div>
    
    
    <div id="unsupportedChrome" style="display:none;color:#FF0000;">A Java plug in is required to view this page.  Chrome is a 32-bit browser and requires a 32-bit plug-in which is unavailable for Mac OS X.  Please try using Safari or FireFox with the Java Plug in installed.  Note: In browsers that support the 64-bit plug in you will be prompted to install Java if it is not already installed.</div>
    
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
						}
					}
			}
        </script>
        <div >
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
        
        </div>
        <div id="macBugDesc" style="display:none;color:#FF0000;">The applet above is fully functional.  However, with your current combination of Mac OS X and Java plug-in the display is not optimal due to a bug.  When Oracle fixes this bug we will update the applet to provide a more optimal experience.  We are very sorry for any inconvenience.  This bug is not found in Windows, Linux, Mac OS X 10.6 or lower if you have any of them available.</div>
        <BR /><BR /><BR />
        
        <script type="text/javascript">
			if(bug==1){
				$('div#macBugDesc').show();
			}
		</script>
    <%}else{%>
    	<div class="error"><%=genURL.get(selectedGene)%><BR />The administrator has been notified of the problem and will investigate the error.  We apologize for any inconvenience.</div><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR />
    <%}%>
<%}else{%>
	<BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR />
<%}%>
</div><!-- end affyExon-->
<script type="text/javascript">
	$('#affyTabID').click(function() {    
			//$('div#changingTabs').show(10);
				//change the tab
				$('#mainTab ul li a').removeClass('selected');
				$(this).addClass('selected');
				var currentTab = $(this).attr('href'); 
				$('#mainTab div.modalTabContent').hide();       
				$(currentTab).show();
				//adjust row and column widths if needed(only needs to be done once)
			
				//setFilterTableStatus("bqtlListFilter");
				
			//$('div#changingTabs').hide(10);
			return false;
        });
</script>

</div><!-- end MainTab-->







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
	
	/*if(auto=="true"){
  		displayWorking();
		auto="false";
  	}*/
	//$('#geneimageFiltered').hide();

	//registerAppletStateHandler();
  
  
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
  
  /*$('#filteredRB').click( function(){
			$('#geneimageFiltered').show();
			$('#geneimageUnfiltered').hide();
  });
  
  $('#unfilteredRB').click( function(){
  			$('#geneimageFiltered').hide();
			$('#geneimageUnfiltered').show();

  });*/
  
  $('.inpageHelpContent').hide();
  
  $('.inpageHelpContent').dialog({ 
  		autoOpen: false,
		dialogClass: "helpDialog"
	});
	
}); // end ready

</script>




