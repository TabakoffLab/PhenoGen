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



    <div class="settingsLevel<%=level%>"  style="display:none;width:300px;border:solid;border-color:#000000;border-width:1px; z-index:999; position:absolute; top:50px; left:50px; background-color:#FFFFFF;">
        	<span style="color:#000000;">Settings:</span>
        	<span class="closeBtn" id="close_settingsLevel<%=level%>" style="position:relative;top:3px;left:110px;"><img src="<%=imagesDir%>icons/close.png"></span>

            <table class="list_base" style="text-align:left; width:100%;" cellspacing="0">
            <TR >
            <TD >
            <span style=" font-weight:bold;">Image Tracks</span>
            </TD>
            </TR>
            <%if(type.equals("transcript")){%>
            	 <TR><TD>
                    <input name="trackcbx" type="checkbox" id="probeCBX" value="Level<%=level%>"  /> 
                    Affymetrix Exon Array Probe Sets:
                    <select name="trackSelect" id="probeSelect">
                        <option value="1" >Dense</option>
                        <option value="3" selected="selected">Pack</option>
                        <option value="2" >Full</option>
                    </select>
            	</TD></TR>
                <TR><TD style=" padding-left:15px;">
                    color by:
                    <select name="colorSelect" id="probeSelectColor">
                        <option value="annot" selected="selected">Annotation</option>
                        <option value="dabg" >Detection Above Background</option>
                        <option value="herit" >Heritability</option>
                    </select>
                    <span class="Imagetooltip" title="All the non-masked Affymetrix Exon 1.0 ST probesets."><img src="<%=imagesDir%>icons/info.gif"></span>
               </TD></TR>
                <TR><TD>
                    <input name="trackcbx" type="checkbox" id="filterprobeCBX" value="Level<%=level%>" />
                    Affy Exon Probe Sets:
                    <select name="trackSelect" id="filterprobeSelect">
                        <option value="1" >Dense</option>
                        <option value="3" selected="selected">Pack</option>
                        <option value="2" >Full</option>
                    </select>
               </TD></TR>
            	<TR><TD style=" padding-left:15px;">
                    filtered by:
                     <select name="filterSelect" id="filterprobeSelectFilter">
                        <option value="annot" selected="selected">Annotation</option>
                        <option value="dabg" >Detection Above Background</option>
                        <option value="herit" >Heritability</option>
                    </select>
                </TD></TR>
                <TR><TD style=" padding-left:15px;">
                    color by:
                    <select name="colorSelect" id="probeSelectColor">
                        <option value="annot" selected="selected">Annotation</option>
                        <option value="dabg" >Detection Above Background</option>
                        <option value="herit" >Heritability</option>
                    </select>
                    <span class="Imagetooltip" title="The non-masked Affymetrix Exon 1.0 ST probsets detected above background in >1% of samples in each tissue available."><img src="<%=imagesDir%>icons/info.gif"></span>
                </TD></TR>
            <%}%>
            <%if(myOrganism.equals("Rn")){%>
            <TR>
            <TD>
           	<input name="trackcbx" type="checkbox" id="snpCBX" value="Level<%=level%>" /> SNPs/Indels:
             <select name="trackSelect" id="snp<%=level%>Select">
            	<option value="1" selected="selected">Dense</option>
                <option value="3" >Pack</option>
            </select>
             <span class="Imagetooltip" title="SNPs/Indels from the DNA sequencing of the BN-Lx and the SHR inbred rat strain genome.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  SNPs/indels are in relation to the reference BN genome (rn5).  When labels are visible for the SNP/Indel features the labels are the reference sequence:strain sequence.<BR><BR> For example:<BR>T:A is a SNP where T was changed to an A in the strain specific sequence.<BR>TA:TAA - is an insertion of an A in the reference Sequence TA.<BR>TAA:TA is the deletion of an A from the reference sequence TAA.<BR><BR>Capitalization:<BR>Bases are reported in lower case if they are part of an algorithmically determined repeat region and are not altered from the reference. Reference bases that are altered (SNPs and deletions) are reported in uppercase in the reference sequence and the strain-specific sequence."><img src="<%=imagesDir%>icons/info.gif"></span>
            </TD>
            </TR>
            <TR>
            <TD>
            <input name="trackcbx" type="checkbox" id="helicosCBX" value="Level<%=level%>" /> Helicos Data:
            <select name="trackSelect" id="helicos<%=level%>Select">
            	<option value="1" selected="selected">Dense</option>
                <option value="2" >Full</option>
            </select>
             <span class="Imagetooltip" title="Helicos Single Molecule RNA-Seq data was collected from brains of the BN-Lx and SHR inbred rat strains based on ribosomal RNA depleted RNA.  BN-Lx and SHR are the parental strains of the HXB/BXH recombinant inbred panel used in the microarray studies displayed on this page.  These data were not used in the transcriptome reconstruction."><img src="<%=imagesDir%>icons/info.gif"></span>
            </TD>
            </TR>
            <%}%>
            <TR>
            <TD>
            <input name="trackcbx" type="checkbox" id="qtlCBX" value="Level<%=level%>" /> bQTLs  
            <span class="Imagetooltip" title="This track will display the publicly available bQTLs from Rat Genome Database. Any bQTLs that overlap the region are represented by a solid black bar.  More details on each bQTL are available under the bQTL Tab."><img src="<%=imagesDir%>icons/info.gif"></span>
            </TD>
            </TR>
             <TR >
            <TD>
            <input name="trackcbx" type="checkbox" id="refseqCBX" value="Level<%=level%>" /> RefSeq Transcripts  
            <span class="Imagetooltip" title="Transcripts from the rat RefSeq database are displayed in blue."><img src="<%=imagesDir%>icons/info.gif"></span>
            </TD>
            </TR>
            <TR>
            <TD class="topLine">
            <span style=" font-weight:bold;">Image Tracks and Table Filters</span><span class="Imagetooltip" title="Checking or Unchecking any of these tracks to the right will include or exclude their features from the table below as well as the image above."><img src="<%=imagesDir%>icons/info.gif"></span>
            </TD>
            </TR>
            <TR>
            <TD >
            <input name="trackcbx" type="checkbox" id="codingCBX" value="Level<%=level%>" checked="checked" /> Protein Coding<%if (myOrganism.equals("Rn")){%>/PolyA+<%}%>
            <select name="trackSelect" id="coding0Select">
            	<option value="1" >Dense</option>
                <option value="3" selected="selected">Pack</option>
                <option value="2" >Full</option>
            </select>
             <span class="Imagetooltip" title=
             <%if(myOrganism.equals("Rn")){%>
             	"This track consists of transcripts from Ensembl(Brown,Ensembl ID) and PhenoGen RNA-Seq reconstructed transcripts(from CuffLinks) (Light Blue, Tissue.#).  Tracks are labeled with either an Ensembl ID or a PhenoGen ID that also indicates the tissue sequenced.  See the legend for the color coding.  Including/Excluding this track also filters these rows from the table below."
             <%}else{%>
             	""
             <%}%>
             ><img src="<%=imagesDir%>icons/info.gif"></span>
            </TD>
            </TR>
            <TR>
            <TD >
            <input name="trackcbx" type="checkbox" id="noncodingCBX" value="Level0" checked="checked" />Long Non-Coding<%if (myOrganism.equals("Rn")){%>/NonPolyA+<%}%>
            <select name="trackSelect" id="noncoding0Select">
            	<option value="1" >Dense</option>
                <option value="3" selected="selected">Pack</option>
                <option value="2" >Full</option>
            </select>
             <span class="Imagetooltip" title="This track consists of Long Non-Coding RNAs(>=200bp) from Ensembl(Purple,Ensembl ID) and PhenoGen RNA-Seq(Green,Tissue.#).  For Ensembl Transcripts this includes any biotype other than protein coding.  For PhenoGen RNA-Seq it includes any transcript detected in the Non-PolyA+ fraction."><img src="<%=imagesDir%>icons/info.gif"></span>
            </TD>
            </TR>
            <TR>
            <TD>
            <input name="trackcbx" type="checkbox" id="smallncCBX" value="Level0" checked="checked" /> Small RNA 
            <select name="trackSelect" id="smallnc0Select">
            	<option value="1" >Dense</option>
                <option value="3" selected="selected">Pack</option>
                <option value="2" >Full</option>
            </select>
             <span class="Imagetooltip" title="This track consists of small RNAs(<200bp) from Ensembl(Yellow,Ensembl ID) and PhenoGen RNA-Seq(Green,smRNA.#)."><img src="<%=imagesDir%>icons/info.gif"></span>
            </TD>
            </TR>
           	
            </table>
            <table>
            	Track Area Height:
                <select name="displaySelect" id="Level0">
                	<option value="150">Small</option>
                	<option value="350" selected>Normal</option>
                    <option value="700">Large</option>
                	<option value="0">No Scrolling</option>
                </select>
            </table>
          </div>