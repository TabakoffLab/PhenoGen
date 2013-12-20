<%@ include file="/web/common/session_vars.jsp" %>


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

    <div class="settingsLevel<%=level%>"  style="display:none;width:400px;border:solid;border-color:#000000;border-width:1px; z-index:999; position:absolute; top:50px; left:-98px; background-color:#FFFFFF; min-height:450px;">
        	<span style="color:#000000; ">Image Settings:</span>
        	<span class="closeBtn" id="close_settingsLevel<%=level%>" style="position:relative;top:3px;left:136px;"><img src="<%=imagesDir%>icons/close.png"></span>
            <div>
            	Image Area Height:
                <select name="imgSelect" id="displaySelect<%=level%>">
                	<option value="150">Small</option>
                	<option value="350" selected>Normal</option>
                    <option value="700">Large</option>
                	<option value="0">No Scrolling</option>
                </select>
                <BR />
            	<span class="reset button" id="resetImage<%=level%>" style="width:150px;">Reset Image Zoom</span>
                <%if(level==0){%>
                	<span class="reset button" id="resetTracks<%=level%>" style="width:150px;">View Default Tracks</span>
                <%}%>
          </div>
          <div style="color:#000000; text-align:left;">Image Tracks:</div>
			<div id="topAccord<%=level%>" style="height:100%; text-align:left;">
            	<H2>Genome Feature Tracks</H2>
                <div>
                	<!--<div id="genomeSub<%=level%>" style="width:100%;">-->
                    	<div class="trigger triggerEC" name="Annotation<%=level%>" style="width:342px;background-color:#CCCCCC;border:solid; border-color:#000000; border-width:1px 1px 0px 1px;">Annotations</div>
                        <div id="Annotation<%=level%>" style="width:372px;display:none;border:solid; border-color:#000000; border-width:0px 1px 1px 1px;">
                        	<input name="trackcbx" type="checkbox" id="codingCBXg<%=level%>"   checked="checked" />Ensembl Protein Coding Genes
                            <span class="Imagetooltip" title="This track consists of transcripts from Ensembl(Brown,Ensembl ID) and PhenoGen RNA-Seq reconstructed transcripts(from CuffLinks) (Light Blue, Tissue.#).  Tracks are labeled with either an Ensembl ID or a PhenoGen ID that also indicates the tissue sequenced.  See the legend for the color coding."><img src="<%=imagesDir%>icons/info.gif"></span>
                            <select name="trackSelect" class="codingDense<%=level%>Select" id="codingDense<%=level%>Selectg">
                                <option value="1" >Dense</option>
                                <option value="3" selected="selected">Pack</option>
                                <option value="2" >Full</option>
                            </select>
             				<HR />
                            <input name="trackcbx" type="checkbox" id="noncodingCBXg<%=level%>"   checked="checked" />Ensembl Long Non-Coding Genes
                            <span class="Imagetooltip" title="This track consists of Long Non-Coding RNAs(>=200bp) from Ensembl(Purple,Ensembl ID) and PhenoGen RNA-Seq(Green,Tissue.#).  For Ensembl Transcripts this includes any biotype other than protein coding.  For PhenoGen RNA-Seq it includes any transcript detected in the Non-PolyA+ fraction."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" class="noncodingDense<%=level%>Select" id="noncodingDense<%=level%>Selectg">
                                    <option value="1" >Dense</option>
                                    <option value="3" selected="selected">Pack</option>
                                    <option value="2" >Full</option>
                                </select>
                                 
                            <HR />
                        	<input name="trackcbx" type="checkbox" id="smallncCBXg<%=level%>"  checked="checked" />Ensembl Small RNA Genes
                            <span class="Imagetooltip" title="This track consists of small RNAs(<200bp) from Ensembl(Yellow,Ensembl ID) and PhenoGen RNA-Seq(Green,smRNA.#)."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" class="smallncDense<%=level%>Select" id="smallncDense<%=level%>Selectg">
                                    <option value="1" >Dense</option>
                                    <option value="3" selected="selected">Pack</option>
                                    <option value="2" >Full</option>
                                </select>
                            <HR />
                            
                           	<!--<input name="trackcbx" type="checkbox" id="smallncCBXg<%=level%>"  checked="checked" />Ref Seq Genes
                            <span class="Imagetooltip" title="This track consists of "><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" class="smallncDense<%=level%>Select" id="smallncDense<%=level%>Selectg">
                                    <option value="1" >Dense</option>
                                    <option value="3" selected="selected">Pack</option>
                                    <option value="2" >Full</option>
                                </select>-->
                                 
                        </div>
                        <%if(myOrganism.equals("Rn")){%>
                        <BR />
                    	<div class="trigger triggerEC" name="Variation<%=level%>" style="width:342px;background-color:#CCCCCC;border:solid; border-color:#000000; border-width:1px 1px 0px 1px;">Strain Variation</div>
                        <div id="Variation<%=level%>" style="width:372px;display:none;border:solid; border-color:#000000; border-width:0px 1px 1px 1px;">
                        	
                        	<input name="trackcbx" type="checkbox" id="snpSHRHCBX<%=level%>" />SHR/OlaPrin <span class="Imagetooltip" title="SNPs/Indels from the DNA sequencing of the BN-Lx and the SHR inbred rat strain genome.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  SNPs/indels are in relation to the reference BN genome (rn5).  When labels are visible for the SNP/Indel features the labels are the reference sequence:strain sequence.<BR><BR> For example:<BR>T:A is a SNP where T was changed to an A in the strain specific sequence.<BR>TA:TAA - is an insertion of an A in the reference Sequence TA.<BR>TAA:TA is the deletion of an A from the reference sequence TAA.<BR><BR>Capitalization:<BR>Bases are reported in lower case if they are part of an algorithmically determined repeat region and are not altered from the reference. Reference bases that are altered (SNPs and deletions) are reported in uppercase in the reference sequence and the strain-specific sequence."><img src="<%=imagesDir%>icons/info.gif"></span>
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
                             <input name="trackcbx" type="checkbox" id="snpBNLXCBX<%=level%>"  />BN-Lx/CubPrin <span class="Imagetooltip" title="SNPs/Indels from the DNA sequencing of the BN-Lx and the SHR inbred rat strain genome.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  SNPs/indels are in relation to the reference BN genome (rn5).  When labels are visible for the SNP/Indel features the labels are the reference sequence:strain sequence.<BR><BR> For example:<BR>T:A is a SNP where T was changed to an A in the strain specific sequence.<BR>TA:TAA - is an insertion of an A in the reference Sequence TA.<BR>TAA:TA is the deletion of an A from the reference sequence TAA.<BR><BR>Capitalization:<BR>Bases are reported in lower case if they are part of an algorithmically determined repeat region and are not altered from the reference. Reference bases that are altered (SNPs and deletions) are reported in uppercase in the reference sequence and the strain-specific sequence."><img src="<%=imagesDir%>icons/info.gif"></span>
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
                            <input name="trackcbx" type="checkbox" id="snpF344CBX<%=level%>"  />F344 <span class="Imagetooltip" title="SNPs/Indels from the DNA sequencing of the BN-Lx and the SHR inbred rat strain genome.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  SNPs/indels are in relation to the reference BN genome (rn5).  When labels are visible for the SNP/Indel features the labels are the reference sequence:strain sequence.<BR><BR> For example:<BR>T:A is a SNP where T was changed to an A in the strain specific sequence.<BR>TA:TAA - is an insertion of an A in the reference Sequence TA.<BR>TAA:TA is the deletion of an A from the reference sequence TAA.<BR><BR>Capitalization:<BR>Bases are reported in lower case if they are part of an algorithmically determined repeat region and are not altered from the reference. Reference bases that are altered (SNPs and deletions) are reported in uppercase in the reference sequence and the strain-specific sequence."><img src="<%=imagesDir%>icons/info.gif"></span>
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
                            <input name="trackcbx" type="checkbox" id="snpSHRJCBX<%=level%>" />SHR/NCrlPrin <span class="Imagetooltip" title="SNPs/Indels from the DNA sequencing of the BN-Lx and the SHR inbred rat strain genome.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  SNPs/indels are in relation to the reference BN genome (rn5).  When labels are visible for the SNP/Indel features the labels are the reference sequence:strain sequence.<BR><BR> For example:<BR>T:A is a SNP where T was changed to an A in the strain specific sequence.<BR>TA:TAA - is an insertion of an A in the reference Sequence TA.<BR>TAA:TA is the deletion of an A from the reference sequence TAA.<BR><BR>Capitalization:<BR>Bases are reported in lower case if they are part of an algorithmically determined repeat region and are not altered from the reference. Reference bases that are altered (SNPs and deletions) are reported in uppercase in the reference sequence and the strain-specific sequence."><img src="<%=imagesDir%>icons/info.gif"></span>
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
            <span class="Imagetooltip" title="This track will display the publicly available bQTLs from Rat Genome Database. Any bQTLs that overlap the region are represented by a solid black bar.  More details on each bQTL are available under the bQTL Tab."><img src="<%=imagesDir%>icons/info.gif"></span>
                        </div>
                    <!--</div>-->
                </div>
                <H2>Transcriptome Feature Tracks</H2>
                <div>
                	<!--<div id="trxomeSub<%=level%>">-->
                    	<div class="trigger triggerEC" name="AffySection<%=level%>" style="width:342px;background-color:#CCCCCC;border:solid; border-color:#000000; border-width:1px 1px 0px 1px;">Affymetrix Exon 1.0ST Data</div>
                        <div id="AffySection<%=level%>" style="width:372px;display:none; border:solid; border-color:#000000; border-width:0px 1px 1px 1px;">
                    	<input name="trackcbx" type="checkbox" id="probeCBX<%=level%>"  /> 
                        Affymetrix Exon Array Probe Sets <span class="Imagetooltip" title="All the non-masked Affymetrix Exon 1.0 ST probesets."><img src="<%=imagesDir%>icons/info.gif"></span>
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
                            <div class="trigger triggerEC" name="RNACount<%=level%>" style="width:342px;background-color:#CCCCCC;border:solid; border-color:#000000; border-width:1px 1px 0px 1px;">Brain Tissue RNA-Seq Count Data</div>
                            <div id="RNACount<%=level%>" style="width:372px;display:none;border:solid; border-color:#000000; border-width:0px 1px 1px 1px;">
                                <input name="trackcbx" type="checkbox" id="illuminaTotalCBX<%=level%>"  /> Illumina rRNA-depleted Total-RNA <span class="Imagetooltip" title="Illumina RNA-Seq data was collected from brains of the BN-Lx and SHR inbred rat strains based on ribosomal RNA depleted RNA.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  These data were not used in the transcriptome reconstruction."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" id="illuminaTotalDense<%=level%>Select">
                                    <option value="1" selected="selected">Dense</option>
                                    <option value="2" >Full</option>
                                </select>
                                <HR />
                                 
                                 <input name="trackcbx" type="checkbox" id="illuminaPolyACBX<%=level%>"  /> Illumina PolyA+ RNA <span class="Imagetooltip" title="Illumina RNA-Seq data was collected from brains of the BN-Lx and SHR inbred rat strains based on PolyA+ RNA.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  These data were used in the transcriptome reconstruction."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" id="illuminaPolyADense<%=level%>Select">
                                    <option value="1" selected="selected">Dense</option>
                                    <option value="2" >Full</option>
                                </select>
                                 
                                 <HR />
                                 
                                 <input name="trackcbx" type="checkbox" id="illuminaSmallCBX<%=level%>"  /> Illumina small RNA <span class="Imagetooltip" title="Illumina RNA-Seq data was collected from brains of the BN-Lx and SHR inbred rat strains based on small RNA.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  These data were not used in the transcriptome reconstruction."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" id="illuminaSmallDense<%=level%>Select">
                                    <option value="1" selected="selected">Dense</option>
                                    <option value="2" >Full</option>
                                </select>
                                 
                                 <HR />
                                 
                                 <input name="trackcbx" type="checkbox" id="helicosCBX<%=level%>"  /> Helicos Data <span class="Imagetooltip" title="Helicos Single Molecule RNA-Seq data was collected from brains of the BN-Lx and SHR inbred rat strains based on ribosomal RNA depleted RNA.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  These data were not used in the transcriptome reconstruction."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" id="helicosDense<%=level%>Select">
                                    <option value="1" selected="selected">Dense</option>
                                    <option value="2" >Full</option>
                                </select>
                                 
                           </div>
                           <BR />
                           <div class="trigger triggerEC" name="RNATrx<%=level%>" style="width:342px;background-color:#CCCCCC;border:solid; border-color:#000000; border-width:1px 1px 0px 1px;">Brain Tissue RNA-Seq Transcript Reconstruction</div>
                           <div id="RNATrx<%=level%>" style="width:372px;display:none;border:solid; border-color:#000000; border-width:1px 1px 1px 1px;">
                           		<input name="trackcbx" type="checkbox" id="codingCBXt<%=level%>"   checked="checked" /> Protein Coding / PolyA+
                            <span class="Imagetooltip" title="This track consists of transcripts from Ensembl(Brown,Ensembl ID) and PhenoGen RNA-Seq reconstructed transcripts(from CuffLinks) (Light Blue, Tissue.#).  Tracks are labeled with either an Ensembl ID or a PhenoGen ID that also indicates the tissue sequenced.  See the legend for the color coding."><img src="<%=imagesDir%>icons/info.gif"></span>
                            <!--<select name="trackSelect" id="codingOverlay<%=level%>Select">
                                <option value="1" >Overlay with Annotated</option>
                                    <option value="2" selected="selected">Seperate Track from Annotation</option>
                            </select>-->
                            <select name="trackSelect" class="codingDense<%=level%>Select" id="codingDense<%=level%>Selectt">
                                <option value="1" >Dense</option>
                                <option value="3" selected="selected">Pack</option>
                                <option value="2" >Full</option>
                            </select>
             				<HR />
                            <input name="trackcbx" type="checkbox" id="noncodingCBXt<%=level%>"  checked="checked" /> Long Non-Coding / NonPolyA+
                            <span class="Imagetooltip" title="This track consists of Long Non-Coding RNAs(>=200bp) from Ensembl(Purple,Ensembl ID) and PhenoGen RNA-Seq(Green,Tissue.#).  For Ensembl Transcripts this includes any biotype other than protein coding.  For PhenoGen RNA-Seq it includes any transcript detected in the Non-PolyA+ fraction."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <!--<select name="trackSelect" id="noncodingOverlay<%=level%>Select">
                                    <option value="1" >Overlay with Annotated</option>
                                    <option value="2" selected="selected">Seperate Track from Annotation</option>
                                </select>-->
                                <select name="trackSelect" class="noncodingDense<%=level%>Select" id="noncodingDense<%=level%>Selectt">
                                    <option value="1" >Dense</option>
                                    <option value="3" selected="selected">Pack</option>
                                    <option value="2" >Full</option>
                                </select>
                                 
                            <HR />
                        	<input name="trackcbx" type="checkbox" id="smallncCBXt<%=level%>"  checked="checked" /> Small RNA 
                            <span class="Imagetooltip" title="This track consists of small RNAs(<200bp) from Ensembl(Yellow,Ensembl ID) and PhenoGen RNA-Seq(Green,smRNA.#)."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <!--<select name="trackSelect" id="smallncOverlay<%=level%>Select">
                                    <option value="1" >Overlay with Annotated</option>
                                    <option value="2" selected="selected">Seperate Track from Annotation</option>
                                </select>-->
                                <select name="trackSelect" class="smallncDense<%=level%>Select" id="smallncDense<%=level%>Selectt">
                                    <option value="1" >Dense</option>
                                    <option value="3" selected="selected">Pack</option>
                                    <option value="2" >Full</option>
                                </select>
                           </div>
            		<%}%>
                    </div>
                <!--</div>-->
            </div>
            
</div>
          <script type="text/javascript">
		  	$( "#topAccord<%=level%>" ).accordion({ heightStyle: "content" });
		  </script>