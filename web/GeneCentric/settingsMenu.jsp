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



    <div class="settingsLevel<%=level%>"  style="display:none;width:400px;border:solid;border-color:#000000;border-width:1px; z-index:999; position:absolute; top:50px; left:-98px; background-color:#FFFFFF; min-height:450px;">
        	<span style="color:#000000;">Available Tracks/Settings:</span>
        	<span class="closeBtn" id="close_settingsLevel<%=level%>" style="position:relative;top:3px;left:104px;"><img src="<%=imagesDir%>icons/close.png"></span>
			<div id="topAccord<%=level%>" style="height:100%; text-align:left;">
            	<H2>Genome Feature Tracks</H2>
                <div>
                	<!--<div id="genomeSub<%=level%>" style="width:100%;">-->
                    	<H3>Annotations</H3>
                        <div>
                        	<input name="trackcbx" type="checkbox" id="codingCBX<%=level%>"  checked="checked" /> Protein Coding 
                            <span class="Imagetooltip" title="This track consists of transcripts from Ensembl(Brown,Ensembl ID) and PhenoGen RNA-Seq reconstructed transcripts(from CuffLinks) (Light Blue, Tissue.#).  Tracks are labeled with either an Ensembl ID or a PhenoGen ID that also indicates the tissue sequenced.  See the legend for the color coding."><img src="<%=imagesDir%>icons/info.gif"></span>
                            <select name="trackSelect" id="codingDense<%=level%>Select">
                                <option value="1" >Dense</option>
                                <option value="3" selected="selected">Pack</option>
                                <option value="2" >Full</option>
                            </select>
             				<BR />
                            <input name="trackcbx" type="checkbox" id="noncodingCBX<%=level%>"  checked="checked" /> Long Non-Coding 
                            <span class="Imagetooltip" title="This track consists of Long Non-Coding RNAs(>=200bp) from Ensembl(Purple,Ensembl ID) and PhenoGen RNA-Seq(Green,Tissue.#).  For Ensembl Transcripts this includes any biotype other than protein coding.  For PhenoGen RNA-Seq it includes any transcript detected in the Non-PolyA+ fraction."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" id="noncodingDense<%=level%>Select">
                                    <option value="1" >Dense</option>
                                    <option value="3" selected="selected">Pack</option>
                                    <option value="2" >Full</option>
                                </select>
                                 
                            <BR />
                        	<input name="trackcbx" type="checkbox" id="smallncCBX<%=level%>"  checked="checked" /> Small RNA 
                            <span class="Imagetooltip" title="This track consists of small RNAs(<200bp) from Ensembl(Yellow,Ensembl ID) and PhenoGen RNA-Seq(Green,smRNA.#)."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" id="smallncDense<%=level%>Select">
                                    <option value="1" >Dense</option>
                                    <option value="3" selected="selected">Pack</option>
                                    <option value="2" >Full</option>
                                </select>
                                 
                        </div>
                    	<H3>Strain Variation</H3>
                        <div>
                        	Strains:<BR />
                        	<input name="trackcbx" type="checkbox" id="snpSHRHCBX<%=level%>" />SHR <span class="Imagetooltip" title="SNPs/Indels from the DNA sequencing of the BN-Lx and the SHR inbred rat strain genome.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  SNPs/indels are in relation to the reference BN genome (rn5).  When labels are visible for the SNP/Indel features the labels are the reference sequence:strain sequence.<BR><BR> For example:<BR>T:A is a SNP where T was changed to an A in the strain specific sequence.<BR>TA:TAA - is an insertion of an A in the reference Sequence TA.<BR>TAA:TA is the deletion of an A from the reference sequence TAA.<BR><BR>Capitalization:<BR>Bases are reported in lower case if they are part of an algorithmically determined repeat region and are not altered from the reference. Reference bases that are altered (SNPs and deletions) are reported in uppercase in the reference sequence and the strain-specific sequence."><img src="<%=imagesDir%>icons/info.gif"></span>
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
                             
                             <BR />
                             <input name="trackcbx" type="checkbox" id="snpBNLXCBX<%=level%>"  />BN-Lx <span class="Imagetooltip" title="SNPs/Indels from the DNA sequencing of the BN-Lx and the SHR inbred rat strain genome.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  SNPs/indels are in relation to the reference BN genome (rn5).  When labels are visible for the SNP/Indel features the labels are the reference sequence:strain sequence.<BR><BR> For example:<BR>T:A is a SNP where T was changed to an A in the strain specific sequence.<BR>TA:TAA - is an insertion of an A in the reference Sequence TA.<BR>TAA:TA is the deletion of an A from the reference sequence TAA.<BR><BR>Capitalization:<BR>Bases are reported in lower case if they are part of an algorithmically determined repeat region and are not altered from the reference. Reference bases that are altered (SNPs and deletions) are reported in uppercase in the reference sequence and the strain-specific sequence."><img src="<%=imagesDir%>icons/info.gif"></span>
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
                            <BR />
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
                            <BR />
                            <input name="trackcbx" type="checkbox" id="snpSHRJCBX<%=level%>" />SHRJ:<span class="Imagetooltip" title="SNPs/Indels from the DNA sequencing of the BN-Lx and the SHR inbred rat strain genome.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  SNPs/indels are in relation to the reference BN genome (rn5).  When labels are visible for the SNP/Indel features the labels are the reference sequence:strain sequence.<BR><BR> For example:<BR>T:A is a SNP where T was changed to an A in the strain specific sequence.<BR>TA:TAA - is an insertion of an A in the reference Sequence TA.<BR>TAA:TA is the deletion of an A from the reference sequence TAA.<BR><BR>Capitalization:<BR>Bases are reported in lower case if they are part of an algorithmically determined repeat region and are not altered from the reference. Reference bases that are altered (SNPs and deletions) are reported in uppercase in the reference sequence and the strain-specific sequence."><img src="<%=imagesDir%>icons/info.gif"></span>
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
                        <H3>QTLs</H3>
                        <div>
                        	  <input name="trackcbx" type="checkbox" id="qtlCBX<%=level%>"  /> bQTLs  
            <span class="Imagetooltip" title="This track will display the publicly available bQTLs from Rat Genome Database. Any bQTLs that overlap the region are represented by a solid black bar.  More details on each bQTL are available under the bQTL Tab."><img src="<%=imagesDir%>icons/info.gif"></span>
                        </div>
                    <!--</div>-->
                </div>
                <H2>Transcriptome Feature Tracks</H2>
                <div>
                	<!--<div id="trxomeSub<%=level%>">-->
                    	<div class="trigger triggerEC" name="AffySection" style="width:100%;background-color:#CCCCCC;border:solid; border-color:#000000; border-width:1px 1px 0px 1px;">Affymetrix Exon 1.0ST Data</div>
                        <div id="AffySection" style="width:360px;display:none; border:solid; border-color:#000000; border-width:0px 1px 1px 1px;">
                    	<input name="trackcbx" type="checkbox" id="probeCBX<%=level%>"  /> 
                        Affymetrix Exon Array Probe Sets <span class="Imagetooltip" title="All the non-masked Affymetrix Exon 1.0 ST probesets."><img src="<%=imagesDir%>icons/info.gif"></span>
                        <select name="trackSelect" id="probeDense<%=level%>Select">
                            <option value="1" >Dense</option>
                            <option value="3" selected="selected">Pack</option>
                            <option value="2" >Full</option>
                        </select>
                        <BR />
                        filtered by:
                         <select name="filterSelect" id="probe<%=level%>filterSelect">
                            <option value="none" selected="selected">None</option>
                            <option value="annot" >Annotation</option>
                            <option value="dabg" >Detection Above Background</option>
                            <option value="herit" >Heritability</option>
                        </select>
                        <BR />
                        color by:
                        <select name="colorSelect" id="probe<%=level%>colorSelect">
                            <option value="annot" selected="selected">Annotation</option>
                            <option value="dabg" >Detection Above Background</option>
                            <option value="herit" >Heritability</option>
                        </select>
                        
                        </div>
                        <BR />
                        <%if(myOrganism.equals("Rn")){%>
                            <div class="trigger triggerEC" name="RNACount" style="width:100%;background-color:#CCCCCC;border:solid; border-color:#000000; border-width:1px 1px 0px 1px;">Brain Tissue RNA-Seq Count Data</div>
                            <div id="RNACount" style="width:360px;display:none;border:solid; border-color:#000000; border-width:0px 1px 1px 1px;">
                                <input name="trackcbx" type="checkbox" id="illuminaTotalCBX<%=level%>"  /> Illumina rRNA-depleted Total-RNA <span class="Imagetooltip" title="Illumina RNA-Seq data was collected from brains of the BN-Lx and SHR inbred rat strains based on ribosomal RNA depleted RNA.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  These data were not used in the transcriptome reconstruction."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" id="illuminaTotalDense<%=level%>Select">
                                    <option value="1" selected="selected">Dense</option>
                                    <option value="2" >Full</option>
                                </select>
                                <BR />
                                 
                                 <input name="trackcbx" type="checkbox" id="illuminaPolyACBX<%=level%>"  /> Illumina PolyA+ RNA <span class="Imagetooltip" title="Illumina RNA-Seq data was collected from brains of the BN-Lx and SHR inbred rat strains based on PolyA+ RNA.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  These data were used in the transcriptome reconstruction."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" id="illuminaPolyADense<%=level%>Select">
                                    <option value="1" selected="selected">Dense</option>
                                    <option value="2" >Full</option>
                                </select>
                                 
                                 <BR />
                                 
                                 <input name="trackcbx" type="checkbox" id="illuminaSmallCBX<%=level%>"  /> Illumina small RNA <span class="Imagetooltip" title="Illumina RNA-Seq data was collected from brains of the BN-Lx and SHR inbred rat strains based on small RNA.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  These data were not used in the transcriptome reconstruction."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" id="illuminaSmallDense<%=level%>Select">
                                    <option value="1" selected="selected">Dense</option>
                                    <option value="2" >Full</option>
                                </select>
                                 
                                 <BR />
                                 
                                 <input name="trackcbx" type="checkbox" id="helicosCBX<%=level%>"  /> Helicos Data <span class="Imagetooltip" title="Helicos Single Molecule RNA-Seq data was collected from brains of the BN-Lx and SHR inbred rat strains based on ribosomal RNA depleted RNA.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  These data were not used in the transcriptome reconstruction."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" id="helicosDense<%=level%>Select">
                                    <option value="1" selected="selected">Dense</option>
                                    <option value="2" >Full</option>
                                </select>
                                 
                           </div>
                           <BR />
                           <div class="trigger triggerEC" name="RNATrx" style="width:100%;background-color:#CCCCCC;border:solid; border-color:#000000; border-width:1px 1px 0px 1px;">Brain Tissue RNA-Seq Transcript Reconstruction</div>
                           <div id="RNATrx" style="width:360px;display:none;border:solid; border-color:#000000; border-width:1px 1px 1px 1px;">
                           		<input name="trackcbx" type="checkbox" id="codingCBX<%=level%>t"  checked="checked" /> Protein Coding / PolyA+
                            <span class="Imagetooltip" title="This track consists of transcripts from Ensembl(Brown,Ensembl ID) and PhenoGen RNA-Seq reconstructed transcripts(from CuffLinks) (Light Blue, Tissue.#).  Tracks are labeled with either an Ensembl ID or a PhenoGen ID that also indicates the tissue sequenced.  See the legend for the color coding."><img src="<%=imagesDir%>icons/info.gif"></span>
                            <select name="trackSelect" id="codingOverlay<%=level%>Select">
                                <option value="1" >Overlay with Annotated</option>
                                    <option value="2" selected="selected">Seperate Track from Annotation</option>
                            </select>
                            <select name="trackSelect" id="codingDense<%=level%>Select">
                                <option value="1" >Dense</option>
                                <option value="3" selected="selected">Pack</option>
                                <option value="2" >Full</option>
                            </select>
             				<BR />
                            <input name="trackcbx" type="checkbox" id="noncodingCBX<%=level%>t"  checked="checked" />Long Non-Coding / NonPolyA+
                            <span class="Imagetooltip" title="This track consists of Long Non-Coding RNAs(>=200bp) from Ensembl(Purple,Ensembl ID) and PhenoGen RNA-Seq(Green,Tissue.#).  For Ensembl Transcripts this includes any biotype other than protein coding.  For PhenoGen RNA-Seq it includes any transcript detected in the Non-PolyA+ fraction."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" id="noncodingOverlay<%=level%>Select">
                                    <option value="1" >Overlay with Annotated</option>
                                    <option value="2" selected="selected">Seperate Track from Annotation</option>
                                </select>
                                <select name="trackSelect" id="noncodingDense<%=level%>Select">
                                    <option value="1" >Dense</option>
                                    <option value="3" selected="selected">Pack</option>
                                    <option value="2" >Full</option>
                                </select>
                                 
                            <BR />
                        	<input name="trackcbx" type="checkbox" id="smallncCBX<%=level%>t"  checked="checked" />Small RNA 
                            <span class="Imagetooltip" title="This track consists of small RNAs(<200bp) from Ensembl(Yellow,Ensembl ID) and PhenoGen RNA-Seq(Green,smRNA.#)."><img src="<%=imagesDir%>icons/info.gif"></span>
                                <select name="trackSelect" id="smallncOverlay<%=level%>Select">
                                    <option value="1" >Overlay with Annotated</option>
                                    <option value="2" selected="selected">Seperate Track from Annotation</option>
                                </select>
                                <select name="trackSelect" id="smallncDense<%=level%>Select">
                                    <option value="1" >Dense</option>
                                    <option value="3" selected="selected">Pack</option>
                                    <option value="2" >Full</option>
                                </select>
                           </div>
            		<%}%>
                    </div>
                <!--</div>-->
            </div>
            <div>
            	Track Area Height:
                <select name="imgSelect" id="displaySelect<%=level%>">
                	<option value="150">Small</option>
                	<option value="350" selected>Normal</option>
                    <option value="700">Large</option>
                	<option value="0">No Scrolling</option>
                </select>
            
          </div>
</div>
          <script type="text/javascript">
		  	$( "#topAccord<%=level%>" ).accordion({ heightStyle: "fill" });
			//$( "#genomeSub<%=level%>" ).accordion({heightStyle: "content"});
			//$( "#trxomeSub<%=level%>" ).accordion({heightStyle: "content"});
		  </script>