<script type="text/javascript">
	var gvtrackString="probe,coding,refseq";
	var gvminCoord=<%=min%>;
	var gvmaxCoord=<%=max%>;
	

</script>
<span style="text-align:center;width:100%;">
	
<%if(genURL!=null && genURL.size()>=1 && !genURL.get(0).startsWith("ERROR:")){%>
<%
	String tmpURL=genURL.get(0);
	int second=tmpURL.lastIndexOf("/",tmpURL.length()-2);
	String folderName=tmpURL.substring(second+1,tmpURL.length()-1);
	DecimalFormat dfC = new DecimalFormat("#,###");
	String tmpFile="ucsc."+trackDefault.replaceAll(",",".")+".png";
%>
    
    
    <div style="width:100%; text-align:center;">
    	<div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000;text-align:center; width:100%;">
    		<span class="triggerImage less" name="collapsableImage" >UCSC Genome Browser Image for <%=myGeneID%></span>
    		<div class="inpageHelp" style="display:inline-block;"><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div>
            
    		<span style="font-size:12px; font-weight:normal; float:left;"><span class="gvlegendBtn"><img src="../web/images/icons/legend_7.png"></span></span>
            
        	<span style="font-size:12px; font-weight:normal; float:right;">
        		<input name="gvimageSizeCbx" type="checkbox" id="gvimageSizeCbx" /> Scroll Image - Viewable Size:
        		<select name="gvimageSizeSelect" id="gvimageSizeSelect">
        			<option value="200" selected="selected">Smaller</option>
            		<option value="400" >Normal</option>
                	<option value="600" >Larger</option>
                	<option value="800" >Largest</option>
            	</select>
            	<span class="regionViewToolTip" title="This lets you control the viewable size of the image. In larger regions you can check this to allow simultaneous viewing of the image and table.  In smaller regions unchecking the box will allow you to view the entire image without scrolling."><img src="<%=imagesDir%>icons/info.gif"></span>
        	</span>
    </div>
        <div id="gvimgLoad" style="display:none;"><img src="<%=imagesDir%>ucsc-loading.gif" /></div>
        <div id="gvgeneImage" class="gvucscImage"  style="display:inline-block;text-align:left;">
            	<a class="fancyboxExt fancybox.iframe" href="<%=ucscURL.get(0)%>" title="UCSC Genome Browser">
            	<img src="<%= contextRoot+"tmpData/regionData/"+folderName+"/"+tmpFile%>"/></a>
            </div>
        <div class="gvgeneimageControl">
       		<div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000;text-align:center; width:100%;">
            	Image Tracks:<div class="inpageHelp" style="display:inline-block; margin-left:10px;"><img id="HelpUCSCImageControl" class="helpImage" src="../web/images/icons/help.png" /></div>
             
            </div>
            <table class="list_base" style="text-align:left; width:100%;" cellspacing="0">	
            <TR>
                <TD>
            	<input name="gvtrackcbx" type="checkbox" id="gvprobeCBX" value="probe" <%if(tmpFile.contains(".probe.")){%>checked="checked"<%}%> /> Affymetrix Exon Array Probe Sets
            	<select name="gvtrackSelect" id="gvprobeSelect">
                    <option value="1" >Dense</option>
                    <option value="3" selected="selected">Pack</option>
                    <option value="2" >Full</option>
                </select>
                <span class="regionViewToolTip" title="All the non-masked Affymetrix Exon 1.0 ST probesets."><img src="<%=imagesDir%>icons/info.gif"></span>
                </TD>
                
            	<TD colspan="2">
           			<input name="gvtrackcbx" type="checkbox" id="gvfilterprobeCBX" value="filterprobe" <%if(tmpFile.contains(".filterprobe.")){%>checked="checked"<%}%> />Affy Exon Probe Sets Detected Above Background >1% of samples
            		<select name="gvtrackSelect" id="gvfilterprobeSelect">
                    <option value="1" >Dense</option>
                    <option value="3" selected="selected">Pack</option>
                    <option value="2" >Full</option>
                </select>
                <span class="regionViewToolTip" title="The non-masked Affymetrix Exon 1.0 ST probsets detected above background in >1% of samples in each tissue available."><img src="<%=imagesDir%>icons/info.gif"></span>
                </TD>
            </TR>
            <TR>
            	<TD>
            <input name="gvtrackcbx" type="checkbox" id="gvsnpCBX" value="snp" <%if(tmpFile.contains(".snp")){%>checked="checked"<%}%> /> SNPs/Indels:
             <select name="gvtrackSelect" id="gvsnpSelect">
            	<option value="1" selected="selected">Dense</option>
                <option value="3" >Pack</option>
                <option value="2" >Full</option>
            </select>
            <span class="regionViewToolTip" title="SNPs/Indels from the DNA sequencing of the BN-Lx and the SHR inbred rat strain genome.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  SNPs/indels are in relation to the reference BN genome (rn5).  When labels are visible for the SNP/Indel features the labels are the reference sequence:strain sequence.<BR><BR> For example:<BR>T:A is a SNP where T was changed to an A in the strain specific sequence.<BR>TA:TAA - is an insertion of an A in the reference Sequence TA.<BR>TAA:TA is the deletion of an A from the reference sequence TAA.<BR><BR>Capitalization:<BR>Bases are reported in lower case if they are part of an algorithmically determined repeat region and are not altered from the reference. Reference bases that are altered (SNPs and deletions) are reported in uppercase in the reference sequence and the strain-specific sequence."><img src="<%=imagesDir%>icons/info.gif"></span>
            	</TD>
                <TD>
            	<input name="gvtrackcbx" type="checkbox" id="gvhelicosCBX" value="helicos" <%if(tmpFile.contains(".helicos")){%>checked="checked"<%}%>/> Helicos Data:
            	
	            <select name="gvtrackSelect" id="gvhelicosSelect">
            	<option value="1" selected="selected">Dense</option>
                <option value="2" >Full</option>
            </select>
            <span class="regionViewToolTip" title="Helicos Single Molecule RNA-Seq data was collected from brains of the BN-Lx and SHR inbred rat strains based on ribosomal RNA depleted RNA.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  These data were not used in the transcriptome reconstruction."><img src="<%=imagesDir%>icons/info.gif"></span>
            	</TD>
                <TD>
            		<input name="gvtrackcbx" type="checkbox" id="gvrefseqCBX" value="refseq" <%if(tmpFile.contains(".refseq.")){%>checked="checked"<%}%>/> RefSeq Transcripts
                    <span class="regionViewToolTip" title="Transcripts from the rat RefSeq database are displayed in blue."><img src="<%=imagesDir%>icons/info.gif"></span>
            	</TD>
            </TR>
            
            <TR>
                <TD>
            		<input name="gvtrackcbx" type="checkbox" id="gvcodingCBX" value="coding" <%if(tmpFile.contains(".coding.")){%>checked="checked"<%}%> /> Protein Coding/PolyA+
                    <select name="gvtrackSelect" id="gvcodingSelect">
            			<option value="1" >Dense</option>
                        <option value="3" selected="selected">Pack</option>
                        <option value="2" >Full</option>
                    </select>
                    <span class="regionViewToolTip" title="This track consists of transcripts from both the Ensembl database (Brown with Ensembl Transcript ID) and the PhenoGen de novo genome-guided transcriptome reconstruction based on paired-end RNA-Seq data generated from polyA+ selected RNA on the BN-Lx and SHR inbred rat strains (Light blue with label indicating tissue RNA was extracted from and including a unique numeric ID).  See legend for more details on color codes.  Including/excluding this track also filters related rows from the table below."><img src="<%=imagesDir%>icons/info.gif"></span>
            	</TD>
            	<TD>
                <input name="gvtrackcbx" type="checkbox" id="gvnoncodingCBX" value="noncoding" <%if(tmpFile.contains(".noncoding.")){%>checked="checked"<%}%> />Long Non-Coding/NonPolyA+
                <select name="gvtrackSelect" id="noncodingSelect">
                        <option value="1" >Dense</option>
                        <option value="3" selected="selected">Pack</option>
                        <option value="2" >Full</option>
                    </select>
                    <span class="regionViewToolTip" title="This track consists of Long Non-Coding RNAs(>350bp) from Ensembl(Purple,Ensembl ID) and PhenoGen RNA-Seq(Green,Tissue.#).  For Ensembl Transcripts this includes any biotype other than protein coding.  For PhenoGen RNA-Seq it includes any transcript detected in the Non-PolyA+ fraction."><img src="<%=imagesDir%>icons/info.gif"></span> 
                </TD>
                <TD>
            <input name="gvtrackcbx" type="checkbox" id="gvsmallncCBX" value="smallnc" <%if(tmpFile.contains(".smallnc.")){%>checked="checked"<%}%>  /> Small RNA
            <select name="gvtrackSelect" id="gvsmallncSelect">
                    <option value="1" >Dense</option>
                    <option value="3" selected="selected">Pack</option>
                    <option value="2" >Full</option>
                </select> 
                <span class="regionViewToolTip" title="This track consists of small RNAs(<350bp) from Ensembl(Yellow,Ensembl ID) and PhenoGen RNA-Seq(Green,smRNA.#)."><img src="<%=imagesDir%>icons/info.gif"></span>
                </TD>
            </TR>
          </table>
          </div><!--end imageControl div -->
    
          </div><!--end Border Div -->
         </span><!-- ends center span -->
	<div id="gvlegendDialog"  title="UCSC Image Legend" class="legendDialog" style="display:none">
    			<%region=false;%>
                <%@ include file="/web/GeneCentric/legendBox.jsp" %>
                <%region=true;%>
    </div>

<script type="text/javascript">
	$(".waitTrx").hide();	
	//Setup Fancy box for UCSC link
	$('.fancyboxExt').fancybox({
		width:$(document).width(),
		height:$(document).height(),
		scrollOutside:false,
		afterClose: function(){
			$('body.noPrint').css("margin","5px auto 60px");
			return;
		}
  });
  
  $("input[name='gvtrackcbx']").change( function(){
			gvupdateTrackString();
			gvupdateUCSCImage();
			
	 });
	 
	 $("select[name='gvtrackSelect']").change( function(){
	 	var id=$(this).attr("id");
		var cbx=id.replace("Select","CBX");
		if($("#"+cbx).is(":checked")){
			gvupdateTrackString();
			gvupdateUCSCImage();
		}
	 });
  
  $('#gvlegendDialog').dialog({
		autoOpen: false,
		dialogClass: "gvlegendDialog",
		width: 350,
		height: 350,
		zIndex: 9999
	});
 	$('.gvlegendBtn').click( function(){
		$('#gvlegendDialog').dialog( "option", "position",{ my: "left top", at: "left bottom", of: $(this) });
		$('#gvlegendDialog').dialog("open");
	});
	
	
	$('#gvimageSizeCbx').change( function(){
		if($(this).is(":checked")){
			var size=$('#gvimageSizeSelect').val()+"px";
			$('#gvgeneImage').css({"height":size,"overflow":"auto"});
			$('#gvimageSizeSelect').prop('disabled', false);
		}else{
			$('#gvgeneImage').css({"height":"","overflow":""});
			$('#gvimageSizeSelect').prop('disabled', 'disabled');
		}
		
	});
	
	$('#gvimageSizeSelect').change( function(){
		if($('#gvimageSizeCbx').is(":checked")){
			var size=$(this).val()+"px";
			$('#gvgeneImage').css({"height":size,"overflow":"auto"});
		}
	});
	
	
	$('.regionViewToolTip').tooltipster({
		position: 'top-right',
		maxWidth: 250,
		offsetX: 24,
		offsetY: 5,
		//arrow: false,
		interactive: true,
   		interactiveTolerance: 350
	});
	$('.helpImage').click( function(event){
		var id=$(this).attr('id');
		$('#'+id+'Content').dialog( "option", "position",{ my: "right top", at: "left bottom", of: $(this) });
		$('#'+id+'Content').dialog("open").css({'font-size':12});
	});
</script>



<%}else{%>
    	<div class="error"><%=genURL.get(selectedGene)%><BR />The administrator has been notified of the problem and will investigate the error.  We apologize for any inconvenience.</div><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR />
<%}%>
    






