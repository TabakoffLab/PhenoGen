<%@ include file="/web/common/anon_session_vars.jsp" %>


<%
	int level=0;
	String type="gene";
	String myOrganism="Rn";
	if(request.getParameter("level")!=null){
		level=Integer.parseInt(request.getParameter("level"));
	}
	
	if(request.getParameter("type")!=null){
		type=request.getParameter("type");
	}
	
	if(request.getParameter("organism")!=null){
		myOrganism=request.getParameter("organism");
	}
%>


<style>
	.ui-accordion .ui-accordion-content {
		padding:1em 0.5em;
	}
</style>

    <div class="settingsLevel<%=level%>"  style="display:none;width:400px;border:solid;border-color:#000000;border-width:1px; z-index:999; position:absolute; top:50px; left:-98px; background-color:#FFFFFF; min-height:450px; text-align:center;">
        	<div style="display:block;width:100%;color:#000000; text-align:left; background:#EEEEEE; font-weight:bold;">Image Settings:<span class="closeBtn" id="close_settingsLevel<%=level%>" style="position:relative;top:2px;left:270px;"><img src="<%=imagesDir%>icons/close.png"></span></div>
        	
            <div>
            	Image Area Height:
                <select name="imgSelect" id="displaySelect<%=level%>">
                	<option value="150">Small</option>
                	<option value="350" selected>Normal</option>
                    <option value="700">Large</option>
                	<option value="0">No Scrolling</option>
                </select>
                <BR />
            	<!--<span class="reset button" id="resetImage<%=level%>" style="width:150px;">Reset Image Zoom</span>-->
                <%if(level==0){%>
                	<span class="reset button" id="resetTracks<%=level%>" style="width:150px;">View Default Tracks</span>
                    <BR />
                	<input name="imgCBX" type="checkbox" id="forceTrxCBX<%=level%>" />Force Drawing Transcripts <span class="tracktooltip<%=level%>" title="Checking this will force gene tracks to show all transcripts instead of grouping transcripts into genes.  This is instead of the default where genes are drawn as transcripts only in regions smaller than 100kbp."><img src="<%=imagesDir%>icons/info.gif"></span>
                <%}%>
                
          </div>
          <div style="color:#000000; text-align:left; background:#EEEEEE;font-weight:bold;">Image Tracks:</div>
			<div id="topAccord<%=level%>" style="height:100%; text-align:left;">
            	<H2>Genome Feature Tracks</H2>
                <div>
                	
                    	<div class="trigger triggerEC" name="Sequence<%=level%>" style="width:342px;background-color:#CCCCCC;border:solid; border-color:#000000; border-width:1px 1px 0px 1px;">Sequence</div>
                        <div id="Sequence<%=level%>" style="width:372px;display:none;border:solid; border-color:#000000; border-width:0px 1px 1px 1px;">
                        	<input name="trackcbx" type="checkbox" id="genomeSeqCBX<%=level%>"   checked="checked" />Reference Genomic Sequence
                            <span class="tracktooltip<%=level%>"  id="genomeSeqInfoDesc<%=level%>" title="This track displays the reference genomic sequence of the selected organism. It is automatically displayed when viewing <=300bp.  You can uncheck to disable displaying the track when viewing <300bp."><img src="<%=imagesDir%>icons/info.gif"></span>
                            <select name="trackSelect" class="genomeSeq<%=level%>Select" id="genomeSeq<%=level%>Select">
                                <option value="both" selected="selected">+/- strands</option>
                                <option value="+" >+ strand</option>
                                <option value="-" >- strand</option>
                            </select>
                            &nbsp;&nbsp;&nbsp;<input name="optioncbx" type="checkbox" id="genomeSeqCBX<%=level%>dispAA"   checked="checked" />w/ Amino Acid
                        </div>
                        <BR />
                	<!--<div id="genomeSub<%=level%>" style="width:100%;">-->
                    	<div class="trigger triggerEC" name="Annotation<%=level%>" style="width:342px;background-color:#CCCCCC;border:solid; border-color:#000000; border-width:1px 1px 0px 1px;">Annotations</div>
                        <div id="Annotation<%=level%>" style="width:372px;display:none;border:solid; border-color:#000000; border-width:0px 1px 1px 1px;">
                        	<%if(level==1){%>
                    			<input name="trackcbx" type="checkbox" id="trxCBX<%=level%>"   checked="checked" />Transcripts for only the selected gene.
                            <span class="tracktooltip<%=level%>" id="trxInfoDesc<%=level%>" title="This track consists of transcripts from the selected feature.  See the legend for the color coding."><img src="<%=imagesDir%>icons/info.gif"></span>
             				<HR />
                    		<%}%>
                            
                            
                            
                        	<input name="trackcbx" type="checkbox" id="ensemblcodingCBX<%=level%>"   checked="checked" />Ensembl Protein Coding <%if(level==0){%>Genes <%}else{%> Transcripts <%}%>
                            <span class="tracktooltip<%=level%>" id="ensemblcodingInfoDesc<%=level%>" title="This track consists of transcripts from Ensembl.  Features are labeled with their Ensembl ID."><img src="<%=imagesDir%>icons/info.gif"></span>
                            <select name="trackSelect" class="ensemblcodingDense<%=level%>Select" id="ensemblcodingDense<%=level%>Select">
                                <option value="1" >Dense</option>
                                <option value="3" selected="selected">Pack</option>
                                <option value="2" >Full</option>
                            </select>
             				<HR />
                            <input name="trackcbx" type="checkbox" id="ensemblnoncodingCBX<%=level%>"   checked="checked" />Ensembl Long Non-Coding <%if(level==0){%>Genes <%}else{%> Transcripts <%}%>
                            <span class="tracktooltip<%=level%>" id="ensemblnoncodingInfoDesc<%=level%>" title="This track consists of Long Non-Coding RNAs(>=200bp) from Ensembl.  This includes any biotype other than protein coding that is >=200bp."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" class="ensemblnoncodingDense<%=level%>Select" id="ensemblnoncodingDense<%=level%>Select">
                                    <option value="1" >Dense</option>
                                    <option value="3" selected="selected">Pack</option>
                                    <option value="2" >Full</option>
                                </select>
                                 
                            <HR />
                        	<input name="trackcbx" type="checkbox" id="ensemblsmallncCBX<%=level%>"  checked="checked" />Ensembl Small RNA <%if(level==0){%>Genes <%}else{%> Transcripts <%}%>
                            <span class="tracktooltip<%=level%>" id="ensemblsmallncInfoDesc<%=level%>" title="This track consists of small RNAs(<200bp) from Ensembl."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" class="ensemblsmallncDense<%=level%>Select" id="ensemblsmallncDense<%=level%>Select">
                                    <option value="1" >Dense</option>
                                    <option value="3" selected="selected">Pack</option>
                                    <option value="2" >Full</option>
                                </select>
                            <HR />
                            
                           	<input name="trackcbx" type="checkbox" id="refSeqCBX<%=level%>"  checked="checked" />Ref Seq <%if(level==0){%>Genes <%}else{%> Transcripts <%}%>
                            <span class="tracktooltip<%=level%>" id="refSeqInfoDesc<%=level%>" title="This track consists of Ref Seq Transcripts.  Features are color coded according to the refSeq status for the transcript or highest confidence status when displayed in the Gene view.  For example if one transcript had a validated status while another corresponding to the same gene had a provisional status the gene is displayed with a validated status."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" class="refSeqDense<%=level%>Select" id="refSeqDense<%=level%>Select">
                                    <option value="1" >Dense</option>
                                    <option value="3" selected="selected">Pack</option>
                                    <option value="2" >Full</option>
                                </select>
                                 
                        </div>
                        <%if(myOrganism.equals("Rn")){%>
                        <BR />
                        <div class="trigger triggerEC" name="Predicted<%=level%>" style="width:342px;background-color:#CCCCCC;border:solid; border-color:#000000; border-width:1px 1px 0px 1px;">Predicted Features</div>
                        <div id="Predicted<%=level%>" style="width:372px;display:none;border:solid; border-color:#000000; border-width:0px 1px 1px 1px;">
                        	<input name="trackcbx" type="checkbox" id="polyASiteCBX<%=level%>"   checked="checked" />PolyA sites predicted from genomic sequence (source: PhenoGen)
                            <span class="tracktooltip<%=level%>" id="polyASiteInfoDesc<%=level%>" title="This track consists of PolyA sites predicted from genomic sequence."><img src="<%=imagesDir%>icons/info.gif"></span>
             				<HR />
                        </div>
                        <BR />
                    	<div class="trigger triggerEC" name="Variation<%=level%>" style="width:342px;background-color:#CCCCCC;border:solid; border-color:#000000; border-width:1px 1px 0px 1px;">Strain Variation</div>
                        <div id="Variation<%=level%>" style="width:372px;display:none;border:solid; border-color:#000000; border-width:0px 1px 1px 1px;">
                        	
                        	<input name="trackcbx" type="checkbox" id="snpSHRHCBX<%=level%>" />SHR/OlaPrin <span class="tracktooltip<%=level%>" id="snpSHRHInfoDesc<%=level%>" title="SNPs/Indels from the DNA sequencing of the SHR inbred rat strain genome.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  SNPs/indels are in relation to the reference BN genome (rn5).  When labels are visible for the SNP/Indel features the labels are the reference sequence:strain sequence.<BR><BR> For example:<BR>T:A is a SNP where T was changed to an A in the strain specific sequence.<BR>TA:TAA - is an insertion of an A in the reference Sequence TA.<BR>TAA:TA is the deletion of an A from the reference sequence TAA.<BR><BR>Capitalization:<BR>Bases are reported in lower case if they are part of an algorithmically determined repeat region and are not altered from the reference. Reference bases that are altered (SNPs and deletions) are reported in uppercase in the reference sequence and the strain-specific sequence."><img src="<%=imagesDir%>icons/info.gif"></span>
                            <select name="trackSelect" id="snpSHRH<%=level%>Select">
                                <option value="1" selected="selected">SNPs only</option>
                                <option value="2" >Insertions only</option>
                                <option value="3" >Deletions only</option>
                                <option value="4" >All</option>
                            </select>
                             <select name="trackSelect" id="snpSHRHDense<%=level%>Select">
                                <option value="1" selected="selected">Dense</option>
                                <option value="3" >Pack</option>
                            </select>
                             
                             <HR />
                             <input name="trackcbx" type="checkbox" id="snpBNLXCBX<%=level%>"  />BN-Lx/CubPrin <span class="tracktooltip<%=level%>" id="snpBNLXInfoDesc<%=level%>" title="SNPs/Indels from the DNA sequencing of the BN-Lx inbred rat strain genome.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  SNPs/indels are in relation to the reference BN genome (rn5).  When labels are visible for the SNP/Indel features the labels are the reference sequence:strain sequence.<BR><BR> For example:<BR>T:A is a SNP where T was changed to an A in the strain specific sequence.<BR>TA:TAA - is an insertion of an A in the reference Sequence TA.<BR>TAA:TA is the deletion of an A from the reference sequence TAA.<BR><BR>Capitalization:<BR>Bases are reported in lower case if they are part of an algorithmically determined repeat region and are not altered from the reference. Reference bases that are altered (SNPs and deletions) are reported in uppercase in the reference sequence and the strain-specific sequence."><img src="<%=imagesDir%>icons/info.gif"></span>
                            <select name="trackSelect" id="snpBNLX<%=level%>Select" >
                                <option value="1" selected="selected">SNPs only</option>
                                <option value="2" >Insertions only</option>
                                <option value="3" >Deletions only</option>
                                <option value="4" >All</option>
                            </select>
                             <select name="trackSelect" id="snpBNLXDense<%=level%>Select">
                                <option value="1" selected="selected">Dense</option>
                                <option value="3" >Pack</option>
                            </select>
                            <HR />
                            <input name="trackcbx" type="checkbox" id="snpF344CBX<%=level%>"  />F344 <span class="tracktooltip<%=level%>" id="snpF344InfoDesc<%=level%>" title="SNPs/Indels from the DNA sequencing of the F344 inbred rat strain genome.  SNPs/indels are in relation to the reference BN genome (rn5).  When labels are visible for the SNP/Indel features the labels are the reference sequence:strain sequence.<BR><BR> For example:<BR>T:A is a SNP where T was changed to an A in the strain specific sequence.<BR>TA:TAA - is an insertion of an A in the reference Sequence TA.<BR>TAA:TA is the deletion of an A from the reference sequence TAA.<BR><BR>Capitalization:<BR>Bases are reported in lower case if they are part of an algorithmically determined repeat region and are not altered from the reference. Reference bases that are altered (SNPs and deletions) are reported in uppercase in the reference sequence and the strain-specific sequence."><img src="<%=imagesDir%>icons/info.gif"></span>
                            <select name="trackSelect" id="snpF344<%=level%>Select" >
                                <option value="1" selected="selected">SNPs only</option>
                                <option value="2" >Insertions only</option>
                                <option value="3" >Deletions only</option>
                                <option value="4" >All</option>
                            </select>
                             <select name="trackSelect" id="snpF344Dense<%=level%>Select" >
                                <option value="1" selected="selected">Dense</option>
                                <option value="3" >Pack</option>
                            </select>
                            <HR />
                            <input name="trackcbx" type="checkbox" id="snpSHRJCBX<%=level%>" />SHR/NCrlPrin <span class="tracktooltip<%=level%>" id="snpSHRJInfoDesc<%=level%>" title="SNPs/Indels from the DNA sequencing of the SHRJ inbred rat strain genome.  SNPs/indels are in relation to the reference BN genome (rn5).  When labels are visible for the SNP/Indel features the labels are the reference sequence:strain sequence.<BR><BR> For example:<BR>T:A is a SNP where T was changed to an A in the strain specific sequence.<BR>TA:TAA - is an insertion of an A in the reference Sequence TA.<BR>TAA:TA is the deletion of an A from the reference sequence TAA.<BR><BR>Capitalization:<BR>Bases are reported in lower case if they are part of an algorithmically determined repeat region and are not altered from the reference. Reference bases that are altered (SNPs and deletions) are reported in uppercase in the reference sequence and the strain-specific sequence."><img src="<%=imagesDir%>icons/info.gif"></span>
                            <select name="trackSelect" id="snpSHRJ<%=level%>Select" >
                                <option value="1" selected="selected">SNPs only</option>
                                <option value="2" >Insertions only</option>
                                <option value="3" >Deletions only</option>
                                <option value="4" >All</option>
                            </select>
                             <select name="trackSelect" id="snpSHRJDense<%=level%>Select">
                                <option value="1" selected="selected">Dense</option>
                                <option value="3" >Pack</option>
                            </select>
                        </div>
                        <%}%>
                        <BR />
                        <div class="trigger triggerEC" name="QTL<%=level%>" style="width:342px;background-color:#CCCCCC;border:solid; border-color:#000000; border-width:1px 1px 0px 1px;">QTLs</div>
                        <div id="QTL<%=level%>" style="width:372px;display:none;border:solid; border-color:#000000; border-width:0px 1px 1px 1px;">
                        	  <input name="trackcbx" type="checkbox" id="qtlCBX<%=level%>"  /> bQTLs  
            <span class="tracktooltip<%=level%>" id="qtlInfoDesc<%=level%>" title="This track will display the publicly available bQTLs from Rat Genome Database. Any bQTLs that overlap the region are represented by a solid black bar.  More details on each bQTL are available under the bQTL Tab."><img src="<%=imagesDir%>icons/info.gif"></span>
                        </div>
                    <!--</div>-->
                </div>
                <H2>Transcriptome Feature Tracks</H2>
                <div>
                	<!--<div id="trxomeSub<%=level%>">-->
                    	<div class="trigger triggerEC" name="AffySection<%=level%>" style="width:342px;background-color:#CCCCCC;border:solid; border-color:#000000; border-width:1px 1px 0px 1px;">Affymetrix Exon 1.0ST Data</div>
                        <div id="AffySection<%=level%>" style="width:372px;display:none; border:solid; border-color:#000000; border-width:0px 1px 1px 1px;">
                    	<input name="trackcbx" type="checkbox" id="probeCBX<%=level%>"  /> 
                        Affymetrix Exon Array Probe Sets <span class="tracktooltip<%=level%>" id="probeInfoDesc<%=level%>" title="All the non-masked Affymetrix Exon 1.0 ST probesets."><img src="<%=imagesDir%>icons/info.gif"></span>
                        <select name="trackSelect" id="probeDense<%=level%>Select">
                            <option value="1" >Dense</option>
                            <option value="3" selected="selected">Pack</option>
                            <option value="2" >Full</option>
                        </select>
                        <!--<BR />
                        filtered by:
                         <select name="filterSelect" id="probe<%=level%>filterSelect">
                            <option value="none" selected="selected">None</option>
                            <option value="annot" >Annotation</option>
                            <option value="dabg" >Detection Above Background</option>
                            <option value="herit" >Heritability</option>
                        </select>-->
                        <BR />
                        color by:
                        <select name="colorSelect" id="probe<%=level%>colorSelect">
                            <option value="annot" selected="selected">Annotation</option>
                            <option value="dabg" >Detection Above Background</option>
                            <option value="herit" >Heritability</option>
                        </select>
                        	
                        		<div id="affyTissues<%=level%>" style="display:none;">
                                	for tissues:
                                	 <input name="tissuecbx" type="checkbox" id="BrainAffyCBX<%=level%>"  checked="checked" /> Whole Brain
                                     <%if(myOrganism.equals("Rn")){%>
                                         <input name="tissuecbx" type="checkbox" id="BrownAdiposeAffyCBX<%=level%>"  checked="checked" /> Brown Adipose
                                         <BR />
                                         <input name="tissuecbx" type="checkbox" id="HeartAffyCBX<%=level%>" checked="checked"  /> Heart
                                         <input name="tissuecbx" type="checkbox" id="LiverAffyCBX<%=level%>"  checked="checked" /> Liver
                                     <%}%>
                            	</div>
                            
                        </div>
                        <BR />
                        <%if(myOrganism.equals("Rn")){%>
                            <div class="trigger triggerEC" name="RNACount<%=level%>" style="width:342px;background-color:#CCCCCC;border:solid; border-color:#000000; border-width:1px 1px 0px 1px;">RNA-Seq Count Data(Brain/Liver)</div>
                            <div id="RNACount<%=level%>" style="width:372px;display:none;border:solid; border-color:#000000; border-width:0px 1px 1px 1px;">
                            	
                                Dense View Scale Range Selector:<span class="tracktooltip<%=level%>" id="illuminaTotalInfoDesc<%=level%>" title="Adjust the dense view scales range to better view changes over the area you are interested in.  Ex. If you are viewing a transcript decrease the maximum to view differences in low read count areas while exons will remain a solid black color.  Or increase the maximum(and possibly the minimum) to view differences in read counts over the length of exons. "><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                <p>
                                  Scale Range:<input type="text" id="amount" style="border:0; color:#f6931f; font-weight:bold;">
                                </p>
 								<div >
                                    Min: <div id="slider-range-min<%=level%>" style="width:85%;display:inline-block;float:right;"></div>
                                    <BR />
                                    Max: <div id="slider-range-max<%=level%>" style="width:85%;display:inline-block;float:right;"></div>
                            	</div>
                                
                            	<HR />
                                <input name="trackcbx" type="checkbox" id="illuminaTotalCBX<%=level%>"  /> Brain Illumina rRNA-depleted Total-RNA <span class="tracktooltip<%=level%>" id="illuminaTotalInfoDesc<%=level%>" title="Illumina RNA-Seq data was collected from brains of the BN-Lx and SHR inbred rat strains based on ribosomal RNA depleted RNA.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  These data were not used in the transcriptome reconstruction."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" id="illuminaTotalDense<%=level%>Select">
                                    <option value="1" selected="selected">Dense</option>
                                    <option value="2" >Full</option>
                                </select>
                                <HR />
                                
                                 
                                 <input name="trackcbx" type="checkbox" id="illuminaPolyACBX<%=level%>"  /> Brain Illumina PolyA+ RNA <span class="tracktooltip<%=level%>" id="illuminaPolyAInfoDesc<%=level%>" title="Illumina RNA-Seq data was collected from brains of the BN-Lx and SHR inbred rat strains based on PolyA+ RNA.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  These data were used in the transcriptome reconstruction."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" id="illuminaPolyADense<%=level%>Select">
                                    <option value="1" selected="selected">Dense</option>
                                    <option value="2" >Full</option>
                                </select>
                                 
                                 <HR />
                                 
                                 <input name="trackcbx" type="checkbox" id="illuminaSmallCBX<%=level%>"  /> Brain Illumina small RNA <span class="tracktooltip<%=level%>" id="illuminaSmallInfoDesc<%=level%>" title="Illumina RNA-Seq data was collected from brains of the BN-Lx and SHR inbred rat strains based on small RNA.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  These data were not used in the transcriptome reconstruction."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" id="illuminaSmallDense<%=level%>Select">
                                    <option value="1" selected="selected">Dense</option>
                                    <option value="2" >Full</option>
                                </select>
                                 
                                 <HR />
                                 
                                 <input name="trackcbx" type="checkbox" id="helicosCBX<%=level%>"  /> Brain Helicos Data <span class="tracktooltip<%=level%>" id="helicosInfoDesc<%=level%>" title="Helicos Single Molecule RNA-Seq data was collected from brains of the BN-Lx and SHR inbred rat strains based on ribosomal RNA depleted RNA.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  These data were not used in the transcriptome reconstruction."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" id="helicosDense<%=level%>Select">
                                    <option value="1" selected="selected">Dense</option>
                                    <option value="2" >Full</option>
                                </select>
                                 <HR />
                                 <input name="trackcbx" type="checkbox" id="liverilluminaTotalPlusCBX<%=level%>"  /> Liver + Strand Total-RNA (BN-Lx only for now) <span class="tracktooltip<%=level%>" id="liverilluminaTotalPlusInfoDesc<%=level%>" title="Illumina RNA-Seq data with strandedness was collected from livers of the BN-Lx (and SHR although not currently displayed) inbred rat strains based on ribosomal RNA depleted RNA.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  These data were used in the transcriptome reconstruction."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" id="liverilluminaTotalPlusDense<%=level%>Select">
                                    <option value="1" selected="selected">Dense</option>
                                    <option value="2" >Full</option>
                                </select>
                                 <HR />
                                 <input name="trackcbx" type="checkbox" id="liverilluminaTotalMinusCBX<%=level%>"  /> Liver - Strand Total-RNA (BN-Lx only for now)<span class="tracktooltip<%=level%>" id="liverilluminaTotalMinusInfoDesc<%=level%>" title="Illumina RNA-Seq data with strandedness was collected from livers of the BN-Lx (and SHR although not currently displayed) inbred rat strains based on ribosomal RNA depleted RNA.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  These data were used in the transcriptome reconstruction."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" id="liverilluminaTotalMinusDense<%=level%>Select">
                                    <option value="1" selected="selected">Dense</option>
                                    <option value="2" >Full</option>
                                </select>
                           </div>
                           <BR />
                           <div class="trigger triggerEC" name="RNATrx<%=level%>" style="width:342px;background-color:#CCCCCC;border:solid; border-color:#000000; border-width:1px 1px 0px 1px;">RNA-Seq Transcript Reconstruction(Brain/Liver)</div>
                           <div id="RNATrx<%=level%>" style="width:372px;display:none;border:solid; border-color:#000000; border-width:1px 1px 1px 1px;">
                           		<input name="trackcbx" type="checkbox" id="braincodingCBX<%=level%>"   checked="checked" /> Brain Protein Coding / PolyA+ <%if(level==0){%>Reconstructed Genes <%}else{%>Reconstructed Transcripts <%}%>
                            <span class="tracktooltip<%=level%>" id="braincodingtInfoDesc<%=level%>" title="This track consists of transcripts from PhenoGen RNA-Seq reconstructed transcripts(from CuffLinks).  Tracks are labeled with eithera PhenoGen ID that also indicates the tissue sequenced."><img src="<%=imagesDir%>icons/info.gif"></span>
                            <!--<select name="trackSelect" id="codingOverlay<%=level%>Select">
                                <option value="1" >Overlay with Annotated</option>
                                    <option value="2" selected="selected">Seperate Track from Annotation</option>
                            </select>-->
                            <select name="trackSelect" class="braincodingDense<%=level%>Select" id="braincodingDense<%=level%>Select">
                                <option value="1" >Dense</option>
                                <option value="3" selected="selected">Pack</option>
                                <option value="2" >Full</option>
                            </select>
             				<HR />
                            <input name="trackcbx" type="checkbox" id="brainnoncodingCBX<%=level%>"  checked="checked" /> Brain Long Non-Coding / NonPolyA+ <%if(level==0){%>Reconstructed Genes <%}else{%>Reconstructed Transcripts <%}%>
                            <span class="tracktooltip<%=level%>" id="brainnoncodingInfoDesc<%=level%>" title="This track consists of Long Non-Coding RNAs(>=200bp) from PhenoGen RNA-Seq(Green,Tissue.#).  For PhenoGen RNA-Seq it includes any transcript detected in the Non-PolyA+ fraction."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <!--<select name="trackSelect" id="noncodingOverlay<%=level%>Select">
                                    <option value="1" >Overlay with Annotated</option>
                                    <option value="2" selected="selected">Seperate Track from Annotation</option>
                                </select>-->
                                <select name="trackSelect" class="brainnoncodingDense<%=level%>Select" id="brainnoncodingDense<%=level%>Select">
                                    <option value="1" >Dense</option>
                                    <option value="3" selected="selected">Pack</option>
                                    <option value="2" >Full</option>
                                </select>
                            <HR />
                        	<input name="trackcbx" type="checkbox" id="brainsmallncCBX<%=level%>"  checked="checked" /> Brain Small RNA <%if(level==0){%>Reconstructed Genes <%}else{%>Reconstructed Transcripts <%}%>
                            <span class="tracktooltip<%=level%>" id="brainsmallncInfoDesc<%=level%>" title="This track consists of small RNAs(<200bp) from PhenoGen RNA-Seq(Green,smRNA.#)."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <!--<select name="trackSelect" id="smallncOverlay<%=level%>Select">
                                    <option value="1" >Overlay with Annotated</option>
                                    <option value="2" selected="selected">Seperate Track from Annotation</option>
                                </select>-->
                                <select name="trackSelect" class="brainsmallncDense<%=level%>Select" id="brainsmallncDense<%=level%>Select">
                                    <option value="1" >Dense</option>
                                    <option value="3" selected="selected">Pack</option>
                                    <option value="2" >Full</option>
                                </select>
                           <HR />
                           <input name="trackcbx" type="checkbox" id="spliceJnctCBX<%=level%>"  checked="checked" /> Brain Splice Junction Support
                            <span class="tracktooltip<%=level%>" id="spliceJnctInfoDesc<%=level%>" title="Displays information about splice junctions in reconstructed transcripts.  Showing how much of the exons on either side of the splicing junction were covered by a continuous read that bridged the junction.  The junctions are color coded by read depth."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" class="spliceJnctDense<%=level%>Select" id="spliceJnctDense<%=level%>Select">
                                    <option value="1" >Dense</option>
                                    <option value="3" selected="selected">Pack</option>
                                    <option value="2" >Full</option>
                                </select>
                            <HR />
                           <input name="trackcbx" type="checkbox" id="liverTotalCBX<%=level%>"  checked="checked" /> Liver Total-RNA (BN-Lx only) <%if(level==0){%>Reconstructed Genes <%}else{%>Reconstructed Transcripts <%}%>
                            <span class="tracktooltip<%=level%>" id="liverTotalInfoDesc<%=level%>" title="This track consists of transcripts from reconstructed from PhenoGen rRNA-depleted Total-RNA sequencing of BN-Lx Liver.(SHR data will be merged with this track soon)"><img src="<%=imagesDir%>icons/info.gif"></span>
                                <!--<select name="trackSelect" id="smallncOverlay<%=level%>Select">
                                    <option value="1" >Overlay with Annotated</option>
                                    <option value="2" selected="selected">Seperate Track from Annotation</option>
                                </select>-->
                                <select name="trackSelect" class="liverTotalDense<%=level%>Select" id="liverTotalDense<%=level%>Select">
                                    <option value="1" >Dense</option>
                                    <option value="3" selected="selected">Pack</option>
                                    <option value="2" >Full</option>
                                </select>
                                <HR />
 						<input name="trackcbx" type="checkbox" id="liverspliceJnctCBX<%=level%>"  checked="checked" /> Liver Splice Junction Support (BN-Lx only)
                            <span class="tracktooltip<%=level%>" id="liverspliceJnctInfoDesc<%=level%>" title="Displays information about splice junctions in reconstructed transcripts from the BN-Lx Liver transcriptome reconstruction (SHR data will be merged with this track soon).  Showing how much of the exons on either side of the splicing junction were covered by a continuous read that bridged the junction.  The junctions are color coded by read depth."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" class="liverspliceJnctDense<%=level%>Select" id="liverspliceJnctDense<%=level%>Select">
                                    <option value="1" >Dense</option>
                                    <option value="3" selected="selected">Pack</option>
                                    <option value="2" >Full</option>
                                </select>
                        	
                           </div>
            		<%}%>
                    </div>
                <!--</div>-->
                <H2>Custom Feature Tracks</H2>
                <div>
                	<div class="trigger triggerEC" name="usrTrack<%=level%>" style="width:342px;background-color:#CCCCCC;border:solid; border-color:#000000; border-width:1px 1px 0px 1px;">User Defined Tracks <span class="tracktooltip<%=level%>" id="UserDefTrkInfoDesc<%=level%>" title="Any Tracks that you create by uploading .bed files will appear here.  They are saved and will be availble when you return on the same computer and browser(refer to limitation #1).  You may change the display density and coloring of the track at any time using the controls next to it. <B>Note changes are temporary.</B>  You may also delete tracks that you aren't using.  Tracks may expire after 1 year and will expire on moving to new versions of the genome.<BR><div style='text-align:left;'><B>Current Limitations:</B><ol><li>Tracks information is currently saved to cookies and are not portable between computers.</li><li>Tracks are currently limited to bed files.  Support is coming soon for additional files.</li><li>Files are limited to 20MB.  Support is coming for other file types that will allow you to use larger files hosted on your own web server.</li></ol></div>"><img src="<%=imagesDir%>icons/info.gif"></span></div>
                    <div id="usrTrack<%=level%>" class="usrTrack" style="width:372px;display:none;border:solid; border-color:#000000; border-width:1px 1px 1px 1px;">
                    	
                    </div>
                    <BR />
                    <div class="trigger triggerEC" name="addUsrTrack<%=level%>" style="width:342px;background-color:#CCCCCC;border:solid; border-color:#000000; border-width:1px 1px 0px 1px;">Add Custom Track <span class="tracktooltip<%=level%>" id="UserDefTrkInfoDesc<%=level%>" title="Use the form in this section to create your own track with your own data. Please note the limitations listed below.  We are working to remove these limitations. <BR><div style='text-align:left;'><B>Current Limitations:</B><ol><li>Tracks information is currently saved to cookies and are not portable between computers.  In the future tracks will save to your profile if logged in. This will provide portability at a future date.</li><li>Tracks are currently limited to bed files.  Support is coming soon for additional files.</li><li>Files are limited to 20MB.  Support is coming for other file types that will allow you to use larger files hosted on your own web server.</li></ol></div>"><img src="<%=imagesDir%>icons/info.gif"></span></div>
                    <div id="addUsrTrack<%=level%>" style="width:372px;display:none;border:solid; border-color:#000000; border-width:1px 1px 1px 1px;">
                    	Track Name:<input type="text" name="usrtrkNameTxt" id="usrtrkNameTxt<%=level%>" size="25" value="">
                        <BR /><BR />
                        BED File:<input type="file" id="customBedFile<%=level%>">
                        <BR /><BR />
                        Color Track by:<select name="usrtrkColor" class="usrtrkColor" id="usrtrkColorSelect<%=level%>">
                                    <option value="Score" >Score based scale</option>
                                    <option value="Color" selected="selected">Feature defined</option>
                                </select>
                        <BR /><BR />
                        <div id="usrtrkGrad<%=level%>" style="display:none;">
                        	Scale Definition:<BR />
                        	Data(min-max)*:<input type="text" name="usrtrkScoreMinTxt" id="usrtrkScoreMinTxt<%=level%>" size="5" value="0"> - <input type="text" name="usrtrkScoreMaxTxt" id="usrtrkScoreMaxTxt<%=level%>" size="5" value="1000">
                            <BR />
                            Gradient(min-max):<input class="color" id="usrtrkColorMin<%=level%>" size="5" value="#FFFFFF"> - <input class="color" id="usrtrkColorMax<%=level%>" size="5" value="#000000">
                            <BR />
                            *Data outside this range will be assigned to the corresponding min or max color.<BR /><BR />
                        </div>
  						
                        <div style="width:100%;">
                        	<div id="uploadBtn<%=level%>">
                        	<input type="button" name="uploadTrack" id="uploadTrack<%=level%>" value="Create Track" onClick="return confirmUpload(<%=level%>)">
                            </div>
                            <div id="confirmUpload<%=level%>" style="display:none;">
                            	Please Confirm that this track is for <B><%if(myOrganism.equals("Rn")){%>Rat<%}else{%>Mouse<%}%></B> and has coordinates for <B><%if(myOrganism.equals("Rn")){%>rn5<%}else{%>mm10<%}%></B>.  Coordinates must match this genome version, coordinates <B>will not</B> be converted.<BR /><BR />
                                <input type="button" name="confirmuploadTrack" id="confirmuploadTrack<%=level%>" value="Continue" onClick="return createCustomTrack(<%=level%>)">
                                <input type="button" name="canceluploadTrack" id="canceluploadTrack<%=level%>" value="Cancel" onClick="return cancelUpload(<%=level%>)">
                            </div>
                            <div id="confirmBed<%=level%>" style="display:none;">
                            	This file is missing a .bed extension.  Is this a .bed file fitting the standard format(<a href="http://genome.ucsc.edu/FAQ/FAQformat.html#format1" target="_blank">UCSC Genome BED Format</a>)?<BR /><BR />
                                <input type="button" name="confirmbedTrack" id="confirmbedTrack<%=level%>" value="Yes/Continue" onClick="return confirmBed(<%=level%>)">
                                <input type="button" name="cancelbedTrack" id="cancelbedTrack<%=level%>" value="No/Cancel" onClick="return cancelUpload(<%=level%>)">
                                <input type="hidden" id="hasconfirmBed<%=level%>" value="0" />
                            </div>
                        	<div class="progressInd" style="display:none;">
                        		<progress></progress>
                        	</div>
                            <div class="uploadStatus"></div>
                        </div>
                    </div>
                </div>
            </div>
            
            
</div>
<script type="text/javascript" src="<%=mainURL.substring(0,mainURL.length()-10)%>/javascript/jscolor/jscolor.js"></script>
          <script type="text/javascript">
		  	$("div.settingsLevel<%=level%> #usrtrkColorSelect<%=level%>").on("change",function(){
				if($("div.settingsLevel<%=level%> #usrtrkColorSelect<%=level%>").val()=="Score"){
					$("div.settingsLevel<%=level%> div#usrtrkGrad<%=level%>").show();
				}else{
					$("div.settingsLevel<%=level%> div#usrtrkGrad<%=level%>").hide();
				}
			});
		  	$( '#topAccord<%=level%>' ).accordion({ heightStyle: "content" });
			$('div.settingsLevel<%=level%> span.tracktooltip<%=level%>').each(function(){
				$(this).tooltipster({
					position: 'top-right',
					maxWidth: 250,
					offsetX: 10,
					offsetY: 5,
					contentAsHTML:true,
					//arrow: false,
					interactive: true,
					interactiveTolerance: 350
				});
			});
			
			$( "#slider-range-min<%=level%>" ).slider({
				  min: 1,
				  max: 1000,
				  step:1,
				  value:  1 ,
				  slide: function( event, ui ) {
					$( "#amount" ).val( ui.value + " - " + $( "#slider-range-max<%=level%>" ).slider( "value") );
					if(svgList!=undefined && svgList[<%=level%>] != undefined){
						svgList[<%=level%>].updateCountScales(ui.value,$( "#slider-range-max<%=level%>" ).slider( "value"));
					}
				  }
				});
			$( "#slider-range-max<%=level%>" ).slider({
				  min: 1000,
				  max: 20000,
				  step:100,
				  value: 5000 ,
				  slide: function( event, ui ) {
					$( "#amount" ).val( $( "#slider-range-min<%=level%>" ).slider( "value") + " - " + ui.value );
					if(svgList!=undefined && svgList[<%=level%>] != undefined){
						svgList[<%=level%>].updateCountScales($( "#slider-range-min<%=level%>" ).slider( "value"),ui.value);
					}
				  }
				});
			$( "#amount" ).val( $( "#slider-range-min<%=level%>" ).slider( "value" ) +
			  " - " + $( "#slider-range-max<%=level%>" ).slider( "value") );
			
		  </script>