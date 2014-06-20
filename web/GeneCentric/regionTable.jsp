
<div class="cssTab" id="mainTab" >
    <ul>
      <li ><a id="geneTabID" href="#geneList" title="What genes are found in this area?">Features<BR />Physically Located in Region</a><div class="inpageHelp" style="float:right;position: relative; top: -53px; left:-2px;"><img id="HelpGenesInRegion" class="helpImage" src="../web/images/icons/help.png" /></div></li>
      <li ><a id="bqtlTabID" class="disable" href="#bQTLList" title="What bQTLs occur in this area?">bQTLs<BR />Overlapping Region</a><div class="inpageHelp" style="float:right;position: relative; top: -53px; left:-2px;"><img id="HelpbQTLInRegion" class="helpImage" src="../web/images/icons/help.png" /></div></li>
      <li><a  id="eqtlTabID" class="disable" href="#eQTLListFromRegion" title="What does this region control?">Transcripts Controlled from Region(eQTLs)</a><div class="inpageHelp" style="float:right;position: relative; top: -53px; left:-2px;"><img id="HelpeQTLTab" class="helpImage" src="../web/images/icons/help.png" /></div></li>
     </ul>
     
     
<div id="loadingRegion"  style="text-align:center; position:relative; top:0px; left:0px;"><img src="<%=imagesDir%>wait.gif" alt="Loading..." /><BR />Loading Region Data...<BR />The tabs to the left will be enabled once all the data loads.</div>

<div id="changingTabs"  style="display:none;text-align:center; position:relative; top:0px; left:-150px;"><img src="<%=imagesDir%>wait.gif" alt="Changing Tabs..." /><BR />Changing Tabs...</div>


<div id="geneList" class="modalTabContent" style=" display:none; position:relative;top:56px;border-color:#CCCCCC; border-width:1px 0px 0px 0px; border-style:inset;width:1000px;">

                <table class="geneFilter">
                	<thead>
                    	<TR>
                    	<TH style="width:50%"><span class="trigger" id="geneListFilter1" name="geneListFilter" style=" position:relative;text-align:left;">Filter List</span><span class="geneListToolTip" title="Click the + icon to view filtering Options."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                        <TH style="width:50%"><span class="trigger" id="geneListFilter2" name="geneListFilter" style=" position:relative;text-align:left;">View Columns</span><span class="geneListToolTip" title="Click the + icon to view Columns you can show/hide in the table below."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                        
                        </TR>
                        
                    </thead>
                	<tbody id="geneListFilter" style="display:none;">
                    	<TR>
                        	<td>
                            <%if(myOrganism.equals("Rn")){%>
                                
                            	<input name="chkbox" type="checkbox" id="exclude1Exon" value="exclude1Exon" /> Exclude single exon RNA-Seq Transcripts <span class="geneListToolTip" title="This will hide the single exon transcripts from the table when selected."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
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
                                            <!--<input name="chkbox" type="checkbox" id="rqQTLCBX" value="rqQTLCBX"/>Require an eQTL below cut-off<span title=""><img src="<%=imagesDir%>icons/info.gif"></span>-->
                            </td>
                        	<td>
                            	<div class="columnLeft">
                                	<%if(myOrganism.equals("Rn")){%>
                                    <input name="chkbox" type="checkbox" id="matchesCBX" value="matchesCBX" checked="checked"/> RNA-Seq Transcript Matches <span class="geneListToolTip" title="Shows/Hides a description of the reason the RNA-Seq transcript was matched to the Ensembl Gene/Transcript."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    <%}%>
                                	
                                    <input name="chkbox" type="checkbox" id="geneIDCBX" value="geneIDCBX" checked="checked" /> Gene ID <span class="geneListToolTip" title="Shows/Hides the Gene ID column containing the Ensembl Gene ID and links to external Databases when available."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="geneDescCBX" value="geneDescCBX" checked="checked" /> Description <span class="geneListToolTip" title="Shows/Hides Gene Description column whichcontains the Ensembl Description or any annotations for RNA-Seq transcripts not associated with an Ensembl Gene/Transcript"><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="geneBioTypeCBX" value="geneBioTypeCBX" checked="checked"/> BioType <span class="geneListToolTip" title="Shows/Hides Ensembl biotype or RNA-Seq category column."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="geneTracksCBX" value="geneTracksCBX" checked="checked" /> Tracks <span class="geneListToolTip" title="Shows/Hides the Image Tracks columns which contain an X when a feature appears in one of the three tracks."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                   
                                </div>
                                <div class="columnRight">
                               		
                                    <input name="chkbox" type="checkbox" id="geneLocCBX" value="geneLocCBX" checked="checked" /> Location and Strand <span class="geneListToolTip" title="Shows/Hides the Chromosome, Start base pair, End base pair, and strand columns for the feature."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                 	
                                    <input name="chkbox" type="checkbox" id="heritCBX" value="heritCBX" checked="checked" /> Heritability <span class="geneListToolTip" title="Shows/Hides all of the Affymetrix Probeset Heritability data."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                	
                                	<input name="chkbox" type="checkbox" id="dabgCBX" value="dabgCBX" checked="checked" /> Detection Above Background <span class="geneListToolTip" title="Shows/Hides all of the Affymetrix Probeset Detection Above Background data."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="eqtlAllCBX" value="eqtlAllCBX" checked="checked" /> eQTLs All <span class="geneListToolTip" title="Shows/Hides all of the eQTL columns."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="eqtlCBX" value="eqtlCBX" checked="checked" />eQTLs Tissues <span class="geneListToolTip" title="Shows/Hides all of the eQTL tissue specific columns while preserving a list of transcript clusters with a link to the circos plot."><img src="<%=imagesDir%>icons/info.gif"></span>
                                </div>

                            </TD>
                        
                        </TR>
                        </tbody>
                        
                  </table>
                  <script type="text/javascript">
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
				</script>
          
          
          <%
		  	String[] hTissues=new String[0];
			String[] dTissues=new String[0];
		  	if(fullGeneList.size()>0){
		  		edu.ucdenver.ccp.PhenoGen.data.Bio.Gene tmpGene=fullGeneList.get(0);
				/*HashMap hTis=tmpGene.getHeritCounts();
				HashMap dTis=tmpGene.getDabgCounts();
				
				if(hTis!=null && dTis!=null){
					Object[] hTisAr=hTis.keySet().toArray();
					Object[] dTisAr=dTis.keySet().toArray();
					hTissues=new String[hTisAr.length];
					dTissues=new String[dTisAr.length];
					for(int i=0;i<hTisAr.length;i++){
						hTissues[i]=hTisAr[i].toString();
					}
					for(int i=0;i<dTisAr.length;i++){
						dTissues[i]=dTisAr[i].toString();
					}
				}*/
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
                        class="topLine noSort noBox" style="text-align:left;"><span class="legendBtn"><img src="../web/images/icons/legend_7.png"><span style="position:relative;top:-7px;">Color Code Key</span></span></th>
                        <th 
                        <%if(myOrganism.equals("Rn")){%>
                        colspan="4"
                        <%}else{%>
                        colspan="2"
                        <%}%> 
                        class="center noSort topLine">Transcript Information</th>
                        <th colspan="<%=5+tissuesList1.length*2+tissuesList2.length*2%>"  class="center noSort topLine" title="Dataset is available by going to Microarray Analysis Tools -> Analyze Precompiled Dataset or Downloads.">Affy Exon 1.0 ST PhenoGen Public Dataset(
							<%if(myOrganism.equals("Mm")){%>
                            	Public ILSXISS RI Mice
                            <%}else{%>
                            	Public HXB/BXH RI Rats (Tissue, Exon Arrays)
                            <%}%>
                            )<div class="inpageHelp" style="display:inline-block; "><img id="HelpAffyExon" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                    </tr>
                    <tr style="text-align:center;">
                        <th 
                        <%if(myOrganism.equals("Rn")){%>
                        colspan="12"
                        <%}else{%>
                        colspan="10"
                        <%}%>   
                        class="topLine noSort noBox"></th>
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
                        <th colspan="<%=3+tissuesList2.length*2%>" class="center noSort topLine" >eQTLs(Gene/Transcript Cluster ID)<div class="inpageHelp" style="display:inline-block; "><img id="HelpeQTL" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                    </tr>
                    <tr style="text-align:center;">
                        <th 
                        <%if(myOrganism.equals("Rn")){%>
                        colspan="6"
                        <%}else{%>
                        colspan="5"
                        <%}%>  
                        class="topLine noSort noBox"></th>
                        <th colspan="3"  class="topLine leftBorder rightBorder noSort" >Image Tracks Represented in Table</th>
                        <th 
                        <%if(myOrganism.equals("Rn")){%>
                        colspan="3"
                        <%}else{%>
                        colspan="2"
                        <%}%>  
                        class="topLine noSort noBox"></th>
                        <th 
                        <%if(myOrganism.equals("Rn")){%>
                        colspan="2"
                        <%}else{%>
                        colspan="1"
                        <%}%>  
                        class="topLine leftBorder rightBorder noSort"># Transcripts <span class="geneListToolTip" title="The number of transcripts assigned to this gene.  Ensembl is the number of ensembl annotated transcripts.  RNA-Seq is the number of RNA-Seq transcripts assigned to this gene.  The RNA-Seq Transcript Matches column contains additional details about why transcripts were or were not matched to a particular gene."><img src="<%=imagesDir%>icons/info.gif"></span></th>
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
                    <TH>Image ID (Transcript/Feature ID) <span class="geneListToolTip" title="Feature IDs that correspond to features in the various image tracks above.<%if(myOrganism.equals("Rn")){%> In addition to Ensembl transcripts, RNA-Seq transcripts, that begin with the tissue where they were identified, will be listed in this column, when they partially or fully match to an Ensembl transcript.  If none are listed there was not a match that met our matching criteria. Please refer to the next column for a description of matching criteria.<%}%>"><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <%if(myOrganism.equals("Rn")){%>
                    <TH>RNA-Seq Transcript Matches <span class="geneListToolTip" title="Information about how a RNA-Seq transcript was matched to an Ensembl Gene/Transcript.  Click if a + icon is present to view the remaining transcripts.<BR><BR>Any partial matches first list the percentage of exons matched and the transcript that was the closest match.<BR> An exon for exon match to a transcript lists the Ensembl Transcript ID and then the # of exons matching each rule. <BR><BR> Rules:<BR>-Perfect Match-the start and stop base pairs exactly align.<BR>-Fuzzy Match-the start and stop base pairs are within 5bp.<BR>-3'/5' Extended/truncated the 3'/5' end of the RNA-Seq transcript is extended or truncated.<BR>-Internal Exon extended/shifted exons not at the begining or end of the transcript and are noted as either extended at a single end or both ends or shifted in one direction.<BR><BR>Additional Rules:<BR>Cufflinks assigns transcripts to genes and on occassion transcripts in the same Cufflinks gene will match to transcripts from different genes.  In this instance the message will reflect that the transcript was assigned to a different gene but changed assignment based on another transcript belonging to the same Cufflinks gene matching a different Ensembl gene.<BR>In other instances Cufflinks created a transcript that spans multiple genes.  It can either be assigned to a specific gene based on other transcripts in the Cufflinks gene or not assigned to a gene.  In either instance it will be noted that the transcript spans multiple genes."><img src="<%=imagesDir%>icons/info.gif"></span></th>
                    <%}%>
                    <TH>Gene Symbol<span class="geneListToolTip" title="The Gene Symbol from Ensembl if available.  Click to view detailed information for that gene."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>Gene ID</TH>
                    <TH width="10%">Gene Description <span class="geneListToolTip" title="The description from Ensembl or annotations from various sources if the feature is not found in Ensembl."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>BioType <span class="geneListToolTip" title="The Ensembl biotype or RNA-Seq fraction and size."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>Protein Coding 
                    <%if(myOrganism.equals("Rn")){%>
                    	/ PolyA+ 
                    	<span class="geneListToolTip" title="An �X� in this column indicates that this feature is from the Protein Coding track in the image above that consists of protein-coding transcripts from Ensembl and transcripts from the transcriptome reconstruction that were identified in the polyA+ fraction of RNA.">
                    <%}else{%>
                    	<span class="geneListToolTip" title="An �X� in this column indicates that this feature is from the Protein Coding track in the image above that consists of protein-coding transcripts from Ensembl and transcripts.">
                    <%}%>
                    <img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>Long Non-Coding
                    <%if(myOrganism.equals("Rn")){%>
                     / Non PolyA+ <span class="geneListToolTip" title="An �X� in this column indicates that this feature is from the track in the image above that consists of transcripts from Ensembl that are not protein coding and transcripts from the transcriptome reconstruction that were identified in only in the total RNA fraction.">
                     <%}else{%>
                     	<span class="geneListToolTip" title="An �X� in this column indicates that this feature is from the track in the image above that consists of transcripts from Ensembl that are not protein coding and greater than or equal to 350 base pairs in length.">
                     <%}%>
                     <img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>Small RNA <span class="geneListToolTip" title="An �X� in this column indicates that this feature is from the track in the image above that consists of transcripts from Ensembl that are less than 350 bp and transcribed features from the small RNA fraction (<200 bp).  This track may include protein-coding and non-protein-coding features.  See legend for details on color coding."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>Location</TH>
                    <TH>Strand</TH>
                    <%if(myOrganism.equals("Rn")){%>
                    <TH  >Exon SNPs / Indels <span class="geneListToolTip" title="A count of SNPs and indels identified in the DNA-Seq data for the BN-Lx and SHR strains that fall within an exon (including untranslated regions) of at least one transcript.  Number of SNPs is on the left side of the / number of indels is on the right.  Counts are summarized for each strain when compared to the BN reference genome (Rn5).  When the same SNP/indel occurs in both, a count of the common SNPs/indels is included.  When these common counts occur they have been subtracted from the strain specific counts."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <%}%>
                    <TH>Ensembl</TH>
                    <%if(myOrganism.equals("Rn")){%>
                    <TH>RNA-Seq</TH>
                    <TH>Total Reads
                    <HR />Read Sequences <span class="geneListToolTip" title="For Small RNAs from RNA-Seq this column includes the total number of reads for the feature and the number of unique reads."><img src="<%=imagesDir%>icons/info.gif"></span>
                    </TH>
                    <%}%>
                    <TH>View Details <span class="geneListToolTip" title="This column links to a UCSC image of the gene, with controls to view any of the available tracks in the region."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>Total Probe Sets <span class="geneListToolTip" title="The total number of non-masked probesets that overlap with any region of an Ensembl transcript<%if(myOrganism.equals("Rn")){%> or an RNA-Seq transcript<%}%>."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    
                    <%for(int i=0;i<tissuesList1.length;i++){%>
                    	<TH><%=tissuesList1[i]%> Count<HR />(Avg)</span></TH>
                    <%}%>
                    <%for(int i=0;i<tissuesList1.length;i++){%>
                    	<TH><%=tissuesList1[i]%> Count<HR />(Avg)</span></TH>
                    <%}%>
                    <TH>Transcript Cluster ID <span class="geneListToolTip" title="Transcript Cluster ID- The unique ID assigned by Affymetrix.  eQTLs are calculated for this annotation at the gene level by combining probe set data across the gene."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>Annotation Level <span class="geneListToolTip" title="The annotation level of the Transcript Cluster.  This denotes the confidence in the annotation by Affymetrix.  The confidence decreases from highest to lowest in the following order: Core,Extended,Full,Ambiguous."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>View Genome-Wide Associations<span class="geneListToolTip" title="Genome Wide Associations- Shows all the locations with a P-value below the cutoff selected.  Circos is used to create a plot of each region in each tissue associated with expression of the gene selected."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <%for(int i=0;i<tissuesList2.length;i++){%>
                    	<TH># of eQTLs with p-value < <%=forwardPValueCutoff%> <span class="geneListToolTip" title="The number of regions in the genome significantly associated with transcript cluster expression (p-value < currently selected cut-off(see Filter List)), i.e. the number of eQTL."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
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
						if(curGene.getBioType().equals("protein_coding") && curGene.getLength()>=200){%>
                        	coding
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
														tmpList=tmpList+tmpTrx.get(l).getIDwToolTip()+"<BR>";
												}else if(l==5){
													tmpList=tmpList+"</span><span id=\"fg_"+i+"\" style=\"display:none;\">"+tmpTrx.get(l).getIDwToolTip()+"<BR>";
												}else{
													tmpList=tmpList+tmpTrx.get(l).getIDwToolTip()+"<BR>";
												}
										}
										tmpList=tmpList+"</span>";
									}else{
										for(int l=0;l<tmpTrx.size();l++){
												if(l==0){
														tmpList=tmpTrx.get(l).getIDwToolTip()+"<BR>";
												}else{
														tmpList=tmpList+tmpTrx.get(l).getIDwToolTip()+"<BR>";
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
                            		Common:<BR /><%=curGene.getSnpCount("common","SNP")%> / <%=curGene.getSnpCount("common","Indel")%><BR />
                                <%}%>
                            	<%if(curGene.getSnpCount("BNLX","SNP")>0 || curGene.getSnpCount("BNLX","Indel")>0 ){%>
                            		BN-Lx:<BR /><%=curGene.getSnpCount("BNLX","SNP")%> / <%=curGene.getSnpCount("BNLX","Indel")%><BR />
                                <%}%>
                                <%if(curGene.getSnpCount("SHRH","SNP")>0 || curGene.getSnpCount("SHRH","Indel")>0){%>
                                	SHR:<BR /><%=curGene.getSnpCount("SHRH","SNP")%> / <%=curGene.getSnpCount("SHRH","Indel")%>
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
                            		BN-Lx: <%=rna.getSnpCount("BNLX","SNP")%> / <%=rna.getSnpCount("BNLX","Indel")%><BR />
                                <%}%>
                                <%if(rna.getSnpCount("SHRH","SNP")>0 || rna.getSnpCount("SHRH","Indel")>0){%>
                                	SHR: <%=rna.getSnpCount("SHRH","SNP")%> / <%=rna.getSnpCount("SHRH","Indel")%>
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

</div><!-- end GeneList-->
<div id="viewTrxDialog" class="trxDialog"></div>

<div id="viewTrxDialogOriginal"  style="display:none;"><div class="waitTrx"  style="text-align:center; position:relative; top:0px; left:0px;"><img src="<%=imagesDir%>wait.gif" alt="Loading..." /><BR />Please wait loading transcript data...</div></div>

<script type="text/javascript">
	var spec="<%=myOrganism%>";
	/*$('.legendBtn2').click( function(){
		$('#legendDialog').dialog( "option", "position",{ my: "left top", at: "left bottom", of: $(this) });
		$('#legendDialog').dialog("open");
	});*/
	
	$('#viewTrxDialog').dialog({
		autoOpen: false,
		dialogClass: "transcriptDialog",
		width: 990,
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
	
	//var geneTargets=[1];
	var sortCol=6;
	if(spec =="Mm"){
		sortCol=5;
	}
	
	var tblGenes=$('#tblGenes').dataTable({
	"bPaginate": false,
	"bProcessing": true,
	"bStateSave": false,
	"bAutoWidth": true,
	"sScrollX": "950px",
	"sScrollY": "650px",
	"aaSorting": [[ sortCol, "desc" ]],
	/*"aoColumnDefs": [
      { "bVisible": false, "aTargets": geneTargets }
    ],*/
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
				setFilterTableStatus("geneListFilter");
				
			$('div#changingTabs').hide(10);
			return false;
        });
	
	
	
	
	
	
	$('#tblGenes').dataTable().fnAdjustColumnSizing();
	//tblGenesFixed=new FixedColumns( tblGenes, {
 	//	"iLeftColumns": 1,
	//	"iLeftWidth": 100
 	//} );

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
	 
	 /*$("input[name='trackcbx']").change( function(){
	 		var type=$(this).val();
			updateTrackString();
			updateUCSCImage();
			if(type=="coding" || type=="noncoding" || type=="smallnc"){

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
	 });*/
	 
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
		maxWidth: 450,
		offsetX: 24,
		offsetY: 5,
		//arrow: false,
		interactive: true,
   		interactiveTolerance: 350
	});
	 
</script>



<div id="bQTLList" class="modalTabContent" style="display:none; position:relative;top:56px;border-color:#CCCCCC; border-width:1px 0px 0px 0px; border-style:inset;width:100%;">
	
	<table class="geneFilter">
                	<thead>
                    	<TH style="width:50%"><span class="trigger" id="bqtlListFilter1" name="bqtlListFilter" style=" position:relative;text-align:left;">Filter List</span><span class="bQTLListToolTip" title="Click the + icon to view fitlering options."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                        <TH style="width:50%"><span class="trigger" id="bqtlListFilter2" name="bqtlListFilter" style=" position:relative;text-align:left;">View Columns</span><span class="bQTLListToolTip" title="Click the + icon to view options to show or hide additional columns."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    </thead>
                	<tbody id="bqtlListFilter" style="display:none;">
                    	<TR>
                        	<td></td>
                        	<td>
                            	<div class="columnLeft">
                                	<%if(myOrganism.equals("Mm")){%>
                                	
                                    <input name="chkbox" type="checkbox" id="rgdIDCBX" value="rgdIDCBX" /> RGD ID <span class="bQTLListToolTip" title="Shows/Hides the Rat Genome Database ID and link."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="traitCBX" value="traitCBX" /> Trait <span class="bQTLListToolTip" title="Shows/Hides a breif description of the trait for the bQTL."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    <%}%>
                                	
                                    <input name="chkbox" type="checkbox" id="bqtlSymCBX" value="bqtlSymCBX" <%if(myOrganism.equals("Mm")){%>checked="checked"<%}%> /> bQTL Symbol <span class="bQTLListToolTip" title="Shows the bQTL Symbol assigned by RGD."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="traitMethodCBX" value="traitMethodCBX" /> Trait Method <span class="bQTLListToolTip" title="Shows/Hides how quantitative traits were calculated or measured."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="phenotypeCBX" value="phenotypeCBX" checked="checked" /> Phenotype <span class="bQTLListToolTip" title="Shows/Hides the phenotype associated with the bQTL."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="diseaseCBX" value="diseaseCBX" checked="checked" /> Diseases <span class="bQTLListToolTip" title="Shows/Hides diseases associated with the bQTL."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="refCBX" value="refCBX" checked="checked" /> References <span class="bQTLListToolTip" title="Shows/Hides RGD and/or PubMed references."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                </div>
                                <div class="columnRight">
                                    
                                    <input name="chkbox" type="checkbox" id="assocBQTLCBX" value="assocBQTLCBX"  /> Associated bQTLs <span class="bQTLListToolTip" title="Shows/Hides bQTL symbols for associated bQTLs. Includes a link to the bQTL region."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="locMethodCBX" value="locMethodCBX"  /> Location Method <span class="bQTLListToolTip" title="Shows/Hides the method used to determine the bQTL region."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="lodBQTLCBX" value="lodBQTLCBX" <%if(myOrganism.equals("Rn")){%>checked="checked"<%}%>/> LOD Score <span class="bQTLListToolTip" title="Shows/Hides the LOD Scores if available."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="pvalBQTLCBX" value="pvalBQTLCBX"  /> P-Value <span class="bQTLListToolTip" title="Shows/Hides the P-value for the bQTL if available."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                </div>
                            	
                            </TD>
                        
                        </TR>
                        </tbody>
                  </table>


	<% ArrayList<BQTL> bqtls=gdt.getBQTLs(min,max,chromosome,myOrganism);
	if(session.getAttribute("getBQTLsERROR")==null){
		if(bqtls.size()>0){
		//log.debug("BQTLS >0 ");
	%>
    
	<TABLE name="items" id="tblBQTL" class="list_base" cellpadding="0" cellspacing="0">
                <THEAD>
                	<TR class="col_title">
                    	<%if(myOrganism.equals("Mm")){%>
                    		<TH>MGI ID <span class="bQTLListToolTip" title="MGI ID and link to MGI."><img src="<%=imagesDir%>icons/info.gif"></TH>
                        <%}%>
                        <TH>RGD ID <span class="bQTLListToolTip" title="RGD ID and link to RGD."><img src="<%=imagesDir%>icons/info.gif"></TH>
                        <TH>QTL Symbol <span class="bQTLListToolTip" title="bQTL Symbol assigned by the databases."><img src="<%=imagesDir%>icons/info.gif"></TH>
                    	<TH>QTL Name <span class="bQTLListToolTip" title="bQTL name assigned by the databases"><img src="<%=imagesDir%>icons/info.gif"></TH>
                        <TH>Trait <span class="bQTLListToolTip" title="A breif description of the phenotype."><img src="<%=imagesDir%>icons/info.gif"></TH>
                        <TH>Trait Method <span class="bQTLListToolTip" title="The method used to quantify the trait."><img src="<%=imagesDir%>icons/info.gif"></TH>
                        <TH>Phenotype <span class="bQTLListToolTip" title="A longer description of the phenotype associated with the bQTL."><img src="<%=imagesDir%>icons/info.gif"></TH>
                        <TH>Associated Diseases <span class="bQTLListToolTip" title="Any diseases associated with the database."><img src="<%=imagesDir%>icons/info.gif"></TH>
                        <TH>References<BR />RGD Ref<HR />PubMed <span class="bQTLListToolTip" title="References for the bQTL with links to the appropriate database."><img src="<%=imagesDir%>icons/info.gif"></TH>
                        <TH>Candidate Genes <span class="bQTLListToolTip" title="Candidate Genes in the bQTL region as noted by RGD.  The link will open a Detailed Transcription Information page on PhenoGen for the gene."><img src="<%=imagesDir%>icons/info.gif"></TH>
                        <TH>Related bQTL Symbols <span class="bQTLListToolTip" title="Any additional bQTLs RGD has found to be associated with this bQTL.  The link will open that region on PhenoGen."><img src="<%=imagesDir%>icons/info.gif"></TH>
                        <TH>bQTL Region <span class="bQTLListToolTip" title="The region associated with the bQTL."><img src="<%=imagesDir%>icons/info.gif"></TH>
                        <TH>Region Determination Method <span class="bQTLListToolTip" title="The method used to determine the bQTL region."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                        <TH>LOD Score <span class="bQTLListToolTip" title="The LOD Score associated with this bQTL if available. bQTLs from RGD and MGI do not always have the LOD Score."><img src="<%=imagesDir%>icons/info.gif"></TH>
                        <TH>P-value <span class="bQTLListToolTip" title="The p-value associated with this bQTL if available.  bQTLs from RGD and MGI do not always have the p-value."><img src="<%=imagesDir%>icons/info.gif"></TH>
                    </TR>
                </thead>
                <%if(bqtls!=null&&bqtls.size()>0){%>
                <tbody style="text-align:center;">
                <%for(int i=0;i<bqtls.size();i++){
					BQTL curBQTL=bqtls.get(i);
					if(curBQTL!=null){%>
                	<tr>
                    	<%if(myOrganism.equals("Mm")){%>
                    	<TD>
                        	<a href="<%=LinkGenerator.getMGIQTLLink(curBQTL.getMGIID())%>" target="_blank">
							<%=curBQTL.getMGIID()%></a>
                        </TD>
                        <%}%>
                        <TD><a href="<%=LinkGenerator.getRGDQTLLink(curBQTL.getRGDID())%>" target="_blank"> 
							<%=curBQTL.getRGDID()%></a>
                        </TD>
                        <TD><%=curBQTL.getSymbol()%></TD>
                        <TD><%=curBQTL.getName()%></TD>
                        <TD>
						<%=curBQTL.getTrait()%>
						<%if(curBQTL.getSubTrait()!=null){%>
							<%=" - "+curBQTL.getSubTrait()%>
                        <%}%>
                        </TD>
                        
                        <TD><%if(curBQTL.getTraitMethod()!=null && !curBQTL.getTraitMethod().equals("")){%>
                        	<%=curBQTL.getTraitMethod()%>
                        <%}%></TD>
                        
                        <TD>
                        <%if(curBQTL.getPhenotype()!=null){%>
							<%=curBQTL.getPhenotype()%></TD>
                        <%}%>
                        <TD>
						<%if(curBQTL.getDiseases()!=null){%>
							<%=curBQTL.getDiseases().replaceAll(";","<HR>")%>
                        <%}%>
                        </TD>
                        <TD>
                        	<%	ArrayList<String> ref1=curBQTL.getRGDRef();
							if(ref1!=null){
							for(int j=0;j<ref1.size();j++){
								if(j!=0){%>
                            		<BR />
                                <%}%>
                                <a href="<%=LinkGenerator.getRGDRefLink(ref1.get(j))%>" target="_blank"><%=ref1.get(j)%></a>
                        	<%}
							}%>
                        <HR />
                        
                         <%	ArrayList<String> ref2=curBQTL.getPubmedRef();
						 if(ref2!=null){
							for(int j=0;j<ref2.size();j++){
								if(j!=0){%>
                            		<BR />
                                <%}%>
                                <a href="<%=LinkGenerator.getPubmedRefLink(ref2.get(j))%>" target="_blank"><%=ref2.get(j)%></a>
                        <%}
						}%>
                        </TD>
                        
                        <TD>
                        <%	ArrayList<String> candidates=curBQTL.getCandidateGene();
							if(candidates!=null){
							for(int j=0;j<candidates.size();j++){%>
                            	<a href="<%=lg.getGeneLink(candidates.get(j),myOrganism,true,true,false)%>" target="_blank" title="View Detailed Transcription Information for gene."><%=candidates.get(j)%></a><BR />
                        	<%}
							}%>
                        </TD>
                        <TD><%	ArrayList<String> relQTL=curBQTL.getRelatedQTL();
								//ArrayList<String> relQTLreason=curBQTL.getRelatedQTLReason();
							if(relQTL!=null){
							for(int j=0;j<relQTL.size();j++){
								String regionQTL=gdt.getBQTLRegionFromSymbol(relQTL.get(j),myOrganism);
                            	if(regionQTL.startsWith("chr")){
								%>
                                    <a href="<%=lg.getGeneLink(regionQTL,myOrganism,true,true,false)%>" target="_blank" title="Click to view this bQTL region in a new window.">
                                    <%=relQTL.get(j)%>
                                    </a>
                                <%}else{%>
                                	<%=relQTL.get(j)%>
                                <%}%>
                                <BR />
                        	<%}
							}%>
                        </TD>
                        <TD title="Click to view this bQTL region in a new window."><a href="<%=lg.getRegionLink(curBQTL.getChromosome(),curBQTL.getStart(),curBQTL.getStop(),myOrganism,true,true,false)%>" target="_blank">
                        chr<%=curBQTL.getChromosome()+":"+dfC.format(curBQTL.getStart())+"-"+dfC.format(curBQTL.getStop())%></a></TD>
                        <TD>
                        <%String tmpMM=curBQTL.getMapMethod();
                        if(tmpMM!=null){
                        	if(tmpMM.indexOf("by")>0){
                            	tmpMM=tmpMM.substring(tmpMM.indexOf("by"));
                            }%>
							<%=tmpMM%>
                        <%}%>
                        </TD>
                        <TD<%if(curBQTL.getLOD()==0){%>
                        	title="Not available from the MGI/RGD data.">Not Available
						<%}else{%>
							><%=curBQTL.getLOD()%>
                        <%}%>
                        </TD>
                        <TD
                        <%if(curBQTL.getPValue()==0){%>
                        	title="Not available from the MGI/RGD data.">Not Available
						<%}else{%>
							><%=curBQTL.getPValue()%>
                        <%}%>
						</TD>
                        
                    </tr>
                	<%}
				}%>
                </tbody>
                <%}else{%>
                	No bQTLs to display.
                <%}%>
    </table>
    <%}else{%>
    	No bQTLs found in region.
    <%}%>
    <%}else{%>
    	<%=session.getAttribute("getBQTLsERROR")%>
    <%}%>
</div><!-- end bQTL List-->


<script type="text/javascript">
	var bQTLSize=<%=bqtls.size()%>;
	var bqtlTarget=[ 1,4,9,11,13 ];
	if(organism == "Mm"){
		bqtlTarget=[ 1,4,5,10,12,13,14 ];
	}
	var tblBQTL=$('#tblBQTL').dataTable({
	"bPaginate": false,
	"bProcessing": true,
	"sScrollX": "950px",
	"sScrollY": "650px",
	"bDeferRender": true,
	"aoColumnDefs": [
      { "bVisible": false, "aTargets": bqtlTarget }
    ],
	"sDom": '<"leftSearch"fr><t>'
	});
	
	$('#tblBQTL_wrapper').css({position: 'relative', top: '-56px'});
	$('#bqtlTabID').removeClass('disable');
	$('#bqtlTabID').click(function() {    
			$('div#changingTabs').show(10);
				//change the tab
				$('#mainTab ul li a').removeClass('selected');
				$(this).addClass('selected');
				var currentTab = $(this).attr('href'); 
				$('#mainTab div.modalTabContent').hide();       
				$(currentTab).show();
				//adjust row and column widths if needed(only needs to be done once)
				if(!tblBQTLAdjust&&bQTLSize>0){
						tblBQTL.fnAdjustColumnSizing();
						tblBQTLAdjust=true;
				}
				setFilterTableStatus("bqtlListFilter");
				
			$('div#changingTabs').hide(10);
			return false;
        });
	/* Seutp Filtering/Viewing in tblBQTL*/
	 $('#rgdIDCBX').click( function(){
			displayColumns(tblBQTL,1,1,$('#rgdIDCBX').is(":checked"));
	  });
	  $('#bqtlSymCBX').click( function(){
	  		var col=1;
			if(organism=="Mm"){
				col=col+1;
			}
			displayColumns(tblBQTL,col,1,$('#bqtlSymCBX').is(":checked"));
	  });
	  $('#traitCBX').click( function(){
	  		var col=3;
			if(organism=="Mm"){
				col=col+1;
			}
			displayColumns(tblBQTL,col,1,$('#traitMethodCBX').is(":checked"));
	  });
	  $('#traitMethodCBX').click( function(){
	  		var col=4;
			if(organism=="Mm"){
				col=col+1;
			}
			displayColumns(tblBQTL,col,1,$('#traitMethodCBX').is(":checked"));
	  });
	  $('#assocBQTLCBX').click( function(){
	  		var col=9;
			if(organism=="Mm"){
				col=col+1;
			}
			displayColumns(tblBQTL,col,1,$('#assocBQTLCBX').is(":checked"));
	  });
	  $('#phenotypeCBX').click( function(){
	  		var col=5;
			if(organism=="Mm"){
				col=col+1;
			}
			displayColumns(tblBQTL,col,1,$('#phenotypeCBX').is(":checked"));
	  });
	  $('#diseaseCBX').click( function(){
	  		var col=6;
			if(organism=="Mm"){
				col=col+1;
			}
			displayColumns(tblBQTL,col,1,$('#diseaseCBX').is(":checked"));
	  });
	  $('#refCBX').click( function(){
	  		var col=7;
			if(organism=="Mm"){
				col=col+1;
			}
			displayColumns(tblBQTL,col,1,$('#refCBX').is(":checked"));
	  });
	  $('#locMethodCBX').click( function(){
	  		var col=11;
			if(organism=="Mm"){
				col=col+1;
			}
			displayColumns(tblBQTL,col,1,$('#locMethodCBX').is(":checked"));
	  });
	  $('#lodBQTLCBX').click( function(){
	  		var col=12;
			if(organism=="Mm"){
				col=col+1;
			}
			displayColumns(tblBQTL,col,1,$('#lodBQTLCBX').is(":checked"));
	  });
	  $('#pvalBQTLCBX').click( function(){
	  		var col=13;
			if(organism=="Mm"){
				col=col+1;
			}
			displayColumns(tblBQTL,col,1,$('#pvalBQTLCBX').is(":checked"));
	  });
	  $('.bQTLListToolTip').tooltipster({
		position: 'top-right',
		maxWidth: 250,
		offsetX: 24,
		offsetY: 5,
		//arrow: false,
		interactive: true,
   		interactiveTolerance: 350
	});	
</script>



<div id="eQTLListFromRegion" class="modalTabContent" style=" display:none; position:relative;top:56px;border-color:#CCCCCC; border-width:1px 0px 0px 0px; border-style:inset;width:100%;">
		
        
		<table class="geneFilter">
                	<thead>
                    	<TH style="width:65%;"><span class="trigger" id="fromListFilter1" name="fromListFilter" style="position:relative;text-align:left;">Filter List and Circos Plot</span><span class="eQTLListToolTip" title="Click the + icon to view filter options."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                        <TH><span class="trigger" id="fromListFilter2" name="fromListFilter" style="position:relative;text-align:left;">View Columns</span><span class="eQTLListToolTip" title="Click the + icon to view columns available to show/hide."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    </thead>
                	<tbody id="fromListFilter" style="display:none;">
                    	<TR>
                        	<td>
                            	<table style="width:100%;">
                                	<tbody>
                                    	<TR>
                                        <TD colspan="2" style="text-align:center;">
                                        	<%log.debug("Pvalue cutoff:"+Double.toString(pValueCutoff));%>
                                            eQTL P-Value Cut-off:
                                            <select name="pvalueCutoffSelect2" id="pvalueCutoffSelect2">
                                            		<!--<option value="0.1" <%if(Double.toString(pValueCutoff).equals("0.10")){%>selected<%}%>>0.1</option>-->
                                                    <!--<option value="0.01" <%if(pValueCutoff==0.01){%>selected<%}%>>0.01</option>-->
                                                    <option value="0.001" <%if(pValueCutoff==0.001){%>selected<%}%>>0.001</option>
                                                    <option value="0.0005" <%if(pValueCutoff==0.0005){%>selected<%}%>>0.0005</option>
                                                    <option value="0.0001" <%if(pValueCutoff==0.0001){%>selected<%}%>>0.0001</option>
                                                    <option value="0.00005" <%if(pValueCutoff==0.00005){%>selected<%}%>>0.00005</option>
                                                    <option value="0.00001" <%if(pValueCutoff==0.00001){%>selected<%}%>>0.00001</option>
                                            </select>
                                            <span class="eQTLListToolTip" title="Remove Genes from both the image(Circos Plot) and table which don't have P-value less than the selected cut-off in one of the included tissues."><img src="<%=imagesDir%>icons/info.gif"></span>
                                         </TD>
                                		</TR>
                                    	<TR>
                                       <%if(myOrganism.equals("Rn")){%>
                                            <TD style="text-align:left; width:50%;">
                                                <table style="width:100%;">
                                                    <tbody>
                                                        <tr>
                                                            <td style="text-align:center;">
                                                                <strong>Tissues: Include at least one tissue.</strong>
                                                                <span class="eQTLListToolTip" title="Removes excluded tissues from the image(Circos Plot), does not remove the column for the tissue in the table(see View Columns for that option), but will remove rows where only the excluded tissue met the p-value cut-off."><img src="<%=imagesDir%>icons/info.gif"></span>
                                                            </td>
                                                        </tr>
                                                        <TR>
                                                            <td style="text-align:center;">
                                                                <strong>Excluded</strong><%=tenSpaces%><%=twentyFiveSpaces%><%=twentySpaces%><strong>Included</strong>
                                                            </td>
                                                        </TR>
                                                        <tr>
                                                            <td>
                                                                
                                                                <select name="tissuesMS" id="tissuesMS" class="multiselect" size="6" multiple="true">
                                                                
                                                                    <% 
                                                                    
                                                                    for(int i = 0; i < tissueNameArray.length; i ++){
                                                                        tissueSelected=isNotSelectedText;
                                                                        if(selectedTissues != null){
                                                                            for(int j=0; j< selectedTissues.length ;j++){
                                                                                if(selectedTissues[j].equals(tissueNameArray[i])){
                                                                                    tissueSelected=isSelectedText;
                                                                                }
                                                                            }
                                                                        }
                                                
                                                
                                                                    %>
                                                                    
                                                                        <option value="<%=tissueNameArray[i]%>"<%=tissueSelected%>><%=tissuesList1[i]%></option>
                                                                    
                                                                    <%} // end of for loop
                                                                    %>
                                                
                                                                </select>
                                                
                                                            </td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                             </TD>
                                        <%} // end of checking species is Rn %>
                                        <TD style="text-align:left; width:50%;">
                                            <table style="width:100%;">
                                                <tbody>
                                                    <tr>
                                                        <td style="text-align:center;">
                                                            <strong>Chromosomes: (<%=chromosome%> must be included)</strong>
                                                           <span class="eQTLListToolTip" title="Remove/Adds Chromosomes to the image(Circos Plot) and will remove or add Genes in the table so only genes located on included chromosomes are displayed."><img src="<%=imagesDir%>icons/info.gif"></span>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td style="text-align:center;">
                                                            <strong>Excluded</strong><%=tenSpaces%><%=twentyFiveSpaces%><%=twentySpaces%><strong>Included</strong>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            
                                                            <select name="chromosomesMS" id="chromosomesMS" class="multiselect" size="6" multiple="true">
                                                            
                                                                <% 
                                                                
                                                                for(int i = 0; i < numberOfChromosomes; i ++){
                                                                    chromosomeSelected=isNotSelectedText;
                                                                    if(chromosomeDisplayArray[i].substring(4).equals(chromosome.substring(3))){
                                                                        chromosomeSelected=isSelectedText;
                                                                    }
                                                                    else {
                                                                        if(selectedChromosomes != null){
                                                                            for(int j=0; j< selectedChromosomes.length ;j++){
                                                                                //log.debug(" selectedChromosomes element "+selectedChromosomes[j]+" "+chromosomeNameArray[i]);
                                                                                if(selectedChromosomes[j].equals(chromosomeNameArray[i])){
                                                                                    chromosomeSelected=isSelectedText;
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                            
                                            
                                                                %>
                                                                
                                                                    <option value="<%=chromosomeNameArray[i]%>"<%=chromosomeSelected%>><%=chromosomeDisplayArray[i]%></option>
                                                                
                                                                <%} // end of for loop
                                                                %>
                                            
                                                            </select>
                                            
                                                        </td>
                                                    </tr>	
                                                  </tbody>
                                              </table>		
                                         </TD>
                                      </TR>
                                      <TR>
                                      	<TD colspan="2" style="text-align:left;">
                                                <table style="width:100%;">
                                                    <tbody>
                                                        <tr>
                                                            <td style="text-align:center;">
                                                                <strong>Transcript Annotation Level</strong>
                                                                <span class="eQTLListToolTip" title="Filters the genes displayed in both the image(Circos Plot) and table to only those annotated with the included annotations.  Annotations are related to confidence in the Affymetrix annotation and range from High to Low in the following order: <BR> <ul><li>-Core</li><li>-Extended</li><li>-Full</li><li>-Ambiguous</li></ul>"><img src="<%=imagesDir%>icons/info.gif"></span>
                                                            </td>
                                                        </tr>
                                                        <TR>
                                                            <td style="text-align:center;">
                                                                <strong>Excluded</strong><%=tenSpaces%><%=twentyFiveSpaces%><%=twentySpaces%><strong>Included</strong>
                                                            </td>
                                                        </TR>
                                                        <tr>
                                                            <td>
                                                                
                                                                <select name="trxAnnotMS" id="trxAnnotMS" class="multiselect" size="4" multiple="true">
                                                                  	<option value="core" <%if(levelString.contains("core")){%>selected<%}%>>Core</option>
																	<option value="extended" <%if(levelString.contains("extended")){%>selected<%}%>>Extended</option>
                                                					<option value="full" <%if(levelString.contains("full")){%>selected<%}%>>Full</option>
																	<option value="ambiguous" <%if(levelString.contains("ambiguous")){%>selected<%}%>>Ambiguous</option>
                                                                </select>
                                                
                                                            </td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                             </TD>
                                      </TR>
                                      <TR>
                                        <TD colspan="2" style="text-align:center;">
                                          <input type="submit" name="filterBTN" id="filterBTN" value="Run Filter" onClick="return runFilter()">
                                        </TD>
                                	</TR>
                                   </tbody>
                                </table>
                            
                            </td>
                            	
                            <TD>
                            	<div class="columnLeft" style="width:60%;">
                                	
                                    <input name="chkbox" type="checkbox" id="geneIDFCBX" value="geneIDFCBX"checked="checked" /> Gene ID <span class="eQTLListToolTip" title="Shows/Hides the Gene ID and links"><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="geneDescFCBX" value="geneDescFCBX" checked="checked" /> Description <span class="eQTLListToolTip" title="Shows/Hides the gene description from Ensembl."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="transAnnotCBX" value="transAnnotCBX" checked="checked" /> Transcript ID and Annot. <span class="eQTLListToolTip" title="Shows/Hides the Affymetrix transcript cluster id and annotation level."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                     
                                    <input name="chkbox" type="checkbox" id="allPvalCBX" value="allPvalCBX" checked="checked" /> All Tissues P-values <span class="eQTLListToolTip" title="Shows/Hides the P-value from the region for each tissue."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="allLocCBX" value="allLocCBX"  checked="checked"/> All Tissues # Locations <span class="eQTLListToolTip" title="Shows/Hides the count of the other eQTLs for the gene with a P-value below the cutoff."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                </div>
                                <div class="columnRight" style="width:39%;">
                                   <h3>Specific Tissues:</h3>
                                    
                                    <input name="chkbox" type="checkbox" id="fromBrainCBX" value="fromBrainCBX" checked="checked" /> Whole Brain <span class="eQTLListToolTip" title="Shows/Hides columns associated with brain tissue."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    <%if(myOrganism.equals("Rn")){%>
                                       
                                        <input name="chkbox" type="checkbox" id="fromHeartCBX" value="fromHeartCBX" checked="checked" />  Heart <span class="eQTLListToolTip" title="Shows/Hides columns associated with heart tissue."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                        
                                        <input name="chkbox" type="checkbox" id="fromLiverCBX" value="fromLiverCBX" checked="checked" /> Liver <span class="eQTLListToolTip" title="Shows/Hides columns associated with liver tissue."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                        
                                        <input name="chkbox" type="checkbox" id="fromBATCBX" value="fromBATCBX"  checked="checked"/> Brown Adipose <span class="eQTLListToolTip" title="Shows/Hides columns associated with brown adipose tissue."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    <%}%>
                                </div>
                            </TD>
                        
                        </TR>
                        </tbody>
                  </table>
<% log.debug("before eQTL table constr");
ArrayList<TranscriptCluster> transOutQTLs=gdt.getTransControllingEQTLs(min,max,chromosome,arrayTypeID,pValueCutoff,levelString,myOrganism,tissueString,chromosomeString);//this region controls what genes
	ArrayList<String> eQTLRegions=gdt.getEQTLRegions();
  if(session.getAttribute("getTransControllingEQTL")==null){
  	if(transOutQTLs!=null && transOutQTLs.size()>0){%>
            <div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000;text-align:center; width:100%; position:relative; top:-71px">
            	<span class="trigger less" name="eQTLRegionNote" >EQTL Region</span>
                <span class="eQTLListToolTip" title="This section lists the regions being reported as begin associated with control of the genes following.  It is important to note that the region entered may only be close to or overlap with a defined SNP or Region between SNPs and may larger than the region selected or may only include part of the region selected."><img src="<%=imagesDir%>icons/info.gif"></span>
            </div>
            <div id="eQTLRegionNote" style="width:100%; position:relative; top:-71px">
            Genes controlled from and P-values reported for eQTLs from this region are not specific to the region you entered. The "P-value from region" columns correspond to the following region(s):<BR />
            <%for(int i=0;i<eQTLRegions.size();i++){%>
                <a href="<%=request.getContextPath()%>/gene.jsp?geneTxt=<%=eQTLRegions.get(i)%>&speciesCB=<%=myOrganism%>&auto=Y&newWindow=Y" target="_blank"><%=eQTLRegions.get(i)%></a><BR />
            <%}%>
            So the genes listed below could be controlled from anywhere in the region(s) above.
            </div>
        
            <%
		String shortRegionCentricPath;
		String cutoffTimesTen; 
		if(pValueCutoff == 0.1){
			cutoffTimesTen = "10";
		}
		else if(pValueCutoff == 0.01){
			cutoffTimesTen = "20";
		}
		else if(pValueCutoff == 0.001){
			cutoffTimesTen = "30";
		}
		else if(pValueCutoff == 0.0001){
			cutoffTimesTen = "40";
		}else if(pValueCutoff == 0.00001){
			cutoffTimesTen = "50";
		}
		else
		{
			double tmpD=-1*Math.log10(pValueCutoff)*10;
			int tmp=(int)tmpD;
			cutoffTimesTen=Integer.toString(tmp);		
		}
		String regionCentricPath= applicationRoot+contextRoot+"tmpData/regionData/"+folderName;
		//String regionCentricPath = "/usr/share/tomcat/webapps/PhenoGen/tmpData/regionData/Rnchr19_54000000_55000000_10242012_175139";
		if(regionCentricPath.indexOf("/PhenoGen/") > 0){
			shortRegionCentricPath = regionCentricPath.substring(regionCentricPath.indexOf("/PhenoGen/"));
		}
		else{
			shortRegionCentricPath = regionCentricPath.substring(regionCentricPath.indexOf("/PhenoGenTEST/"));
		}
		String iframeURL = shortRegionCentricPath + "/circos"+cutoffTimesTen+"/svg/circos_new.svg";
		String svgPdfFile= shortRegionCentricPath + "/circos"+cutoffTimesTen+"/svg/circos_new.pdf";
	%>
                  
   	<div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000;text-align:center; width:100%;top:-62px; position:relative;">
    	<span class="trigger less" name="circosPlot" >Gene Location Circos Plot</span>
    	<div class="inpageHelp" style="display:inline-block;"><img id="HelpRevCircos" class="helpImage" src="../web/images/icons/help.png" /></div>
        <span style="font-size:12px; font-weight:normal;">
        Adjust Vertical Viewable Size:
        <select name="circosSizeSelect" id="circosSizeSelect">
        		<option value="200" >Smallest</option>
            	<option value="475" >Half</option>
                <option value="950" selected="selected">Full</option>
                <option value="1000" >Maximized</option>
            </select>
        </span>
        <span class="eQTLListToolTip" title="To control the viewable area of the Circos Plot below simply select your prefered size."><img src="<%=imagesDir%>icons/info.gif"></span>
    </div> 
    <%if(session.getAttribute("getTransControllingEQTLCircos")==null){%>
    <div id="circosPlot" style="text-align:center; top:-62px; position:relative;">
		<div style="display:inline-block;text-align:center; width:100%;">
        	<!--<span id="circosMinMax" style="cursor:pointer;"><img src="web/images/icons/circos_min.jpg"></span>-->
			<a href="<%=svgPdfFile%>" target="_blank">
			<img src="web/images/icons/download_g.png" title:"Download Circos Image">
			</a>
            Inside of border below, the mouse wheel zooms.  Outside of the border, the mouse wheel scrolls. 
     	</div>

          <div id="iframe_parent" align="center">
               <iframe id="circosIFrame" src=<%=iframeURL%> height=950 width=950  position=absolute scrolling="no" style="border-style:solid; border-color:rgb(139,137,137); border-radius:15px; -moz-border-radius: 15px; border-width:1px">
               </iframe>
          </div>
          <a href="http://genome.cshlp.org/content/early/2009/06/15/gr.092759.109.abstract" target="_blank" style="text-decoration: none">Circos: an Information Aesthetic for Comparative Genomics.</a>
     </div><!-- end CircosPlot -->
	<%}else{%>
    	<div id="circosPlot" style="text-align:center;">
    	<strong><%=session.getAttribute("getTransControllingEQTLCircos")%></strong><BR /><BR /><BR />
        </div><!-- end CircosPlot -->
	<%}
	log.debug("end circos");%>
			<%String idList="";
			int idListCount=0;
			log.debug("before outer");
			for(int i=0;i<transOutQTLs.size();i++){
				TranscriptCluster tc=transOutQTLs.get(i);
				String tcChr=myOrganism.toLowerCase()+tc.getChromosome();
				log.debug("after chr outer");
				boolean include=false;
				boolean tissueInclude=false;
				for(int z=0;z<selectedChromosomes.length&&!include;z++){
					if(selectedChromosomes[z].equals(tcChr)){
						include=true;
					}
				}
				log.debug("after chr loop");
				for(int j=0;j<tissuesList2.length&&include&&!tissueInclude;j++){
					log.debug("jTis:"+tissueNameArray[j]);
					boolean isTissueSelected=false;
					for(int k=0;k<selectedTissues.length;k++){
						log.debug("ktis:"+selectedTissues[k]);
						if(selectedTissues[k].equals(tissueNameArray[j])){
							isTissueSelected=true;
						}
					}
					if(isTissueSelected){
						ArrayList<EQTL> regionQTL=tc.getTissueRegionEQTL(tissuesList2[j]);
						if(regionQTL!=null){
							EQTL regQTL=regionQTL.get(0);
							if(regQTL.getPVal()<=pValueCutoff){
								tissueInclude=true;
							}
						}
					}
				}
				log.debug("after tissue loop");
				if(include&&tissueInclude){
					if(i==0){
						idList=tc.getTranscriptClusterID();
					}else{
						idList=idList+","+tc.getTranscriptClusterID();
					}
					idListCount++;
				}
			}
			log.debug("after outer for loop");
			if(idListCount<=300){%>
       			<div style=" float:right; position:relative; top:10px;"><a href="http://david.abcc.ncifcrf.gov/api.jsp?type=AFFYMETRIX_EXON_GENE_ID&ids=<%=idList%>&tool=summary" target="_blank">View DAVID Functional Annotation</a><div class="inpageHelp" style="display:inline-block;"><img id="HelpDAVID" class="helpImage" src="../web/images/icons/help.png" /></div></div>
        	<%}else{%>
            	<div style=" float:right; position:relative; top:10px;">Too many genes to submit to DAVID automatically. Filter or copy and submit on your own <a href="http://david.abcc.ncifcrf.gov/" target="_blank">here</a>.<span class="eQTLListToolTip" title=""><img src="<%=imagesDir%>icons/info.gif"></span><div class="inpageHelp" style="display:inline-block;"><img id="HelpDAVID" class="helpImage" src="../web/images/icons/help.png" /></div></div>
            <%}
			log.debug("end DAVID setup");%>	
		<BR />	
	
	<TABLE name="items" id="tblFrom" class="list_base" cellpadding="0" cellspacing="0">
                <THEAD>
                	<tr>
                        <th colspan="3" class="topLine noSort noBox"></th>
                        <th colspan="<%=tissuesList2.length*2+4%>" class="center noSort topLine" title="Dataset is available by going to Microarray Analysis Tools -> Analyze Precompiled Dataset or Downloads.">Affy Exon 1.0 ST PhenoGen Public Dataset(
							<%if(myOrganism.equals("Mm")){%>
                            	Public ILSXISS RI Mice
                            <%}else{%>
                            	Public HXB/BXH RI Rats (Tissue, Exon Arrays)
                            <%}%>
                            )<div class="inpageHelp" style="display:inline-block;"><img id="HelpeQTLAffy" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                    </tr>
               		 <tr>
                        <th colspan="3" class="topLine noSort noBox"></th>
                        <th colspan="4" class="leftBorder noSort noBox"></th>
                        <%for(int i=0;i<tissuesList2.length;i++){%>
                        	<th colspan="2" class="center noSort topLine">Tissue:<%=tissuesList2[i]%></th>
                        <%}%>
                    </tr>
                	<TR class="col_title">
                   		<TH>Gene Symbol<BR />(click for detailed transcription view) <span class="eQTLListToolTip" title="The Gene Symbol from Ensembl if available.  Click to view detailed information for that gene."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    	<TH>Gene ID</TH>
                    	
                        <TH>Description <span class="eQTLListToolTip" title="The description from Ensembl if available."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                        <TH>Transcript Cluster ID <span class="eQTLListToolTip" title="Transcript Cluster ID- The unique ID assigned by Affymetrix.  <a href='<%=commonDir%>definitions.jsp#eQTLs' target='_blank'>eQTLs</a> are calculated for this annotation at the gene level by combining probe set data across the gene."><img src="<%=imagesDir%>icons/info.gif"></span> </TH>
                        <TH>Annotation Level <span class="eQTLListToolTip" title="Annotation level from Affymetrix is related to the confidence of the annotation of the gene.  Core is the highest confidence and tends to correspond very closely with the Ensembl gene annotation. Extended is lower confidence and may include additional regions outside of the Ensembl annotated exons.  Full is even lower.  Ambiguous is the lowest confidence."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                        <TH>Physical Location <span class="eQTLListToolTip" title="This is the location of the gene in the genome.  It includes the chromosome and the starting basepair and end base pair for the gene."><img src="<%=imagesDir%>icons/info.gif"></span></TH> 
                        <TH>View Genome-Wide Associations <span class="eQTLListToolTip" title="Genome Wide Associations- Shows all the locations with a P-value below the cutoff selected. Circos is used to create a plot of each region in each tissue associated with expression of the gene selected."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    	<%for(int i=0;i<tissuesList2.length;i++){%>
                            <TH title="Highlighted indicates a value less than or equal to the cutoff.">P-Value from region <span class="eQTLListToolTip" title="The P-value associated with this region.  Note that this region may only partially overlap with the region this P-value refers to or may be much larger."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                            <TH title="Click on View Location Plot to see all locations below the cutoff."># other locations P-value<<%=pValueCutoff%> <span class="eQTLListToolTip" title="The number of other locations with eQTLs that have a P-value below the selected cut-off."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                            <!--<TH>Max LOD genome-wide</TH>-->
                        <%}%>
                    	
                    </TR>
                </thead>
                <tbody style="text-align:center;">
					<%DecimalFormat df4 = new DecimalFormat("#.####");
					for(int i=0;i<transOutQTLs.size();i++){
						TranscriptCluster tc=transOutQTLs.get(i);
						String tcChr=myOrganism.toLowerCase()+tc.getChromosome();
						boolean include=false;
						boolean tissueInclude=false;
						for(int z=0;z<selectedChromosomes.length&&!include;z++){
							if(selectedChromosomes[z].equals(tcChr)){
								include=true;
							}
						}
						for(int j=0;j<tissuesList2.length&&include&&!tissueInclude;j++){
							boolean isTissueSelected=false;
							for(int k=0;k<selectedTissues.length;k++){
								if(selectedTissues[k].equals(tissueNameArray[j])){
									isTissueSelected=true;
								}
							}
							if(isTissueSelected){
								ArrayList<EQTL> regionQTL=tc.getTissueRegionEQTL(tissuesList2[j]);
								if(regionQTL!=null){
									EQTL regQTL=regionQTL.get(0);
									if(regQTL.getPVal()<=pValueCutoff){
										tissueInclude=true;
									}
								}
							}
						}
						if(include && tissueInclude){
								String description=tc.getGeneDescription();
								String shortDesc=description;
        						String remain="";
								if(description.indexOf("[")>0){
            						shortDesc=description.substring(0,description.indexOf("["));
									remain=description.substring(description.indexOf("[")+1,description.indexOf("]"));
        						}
                        %>
                        <TR>
                            <TD >
                            <%if(!tc.getGeneID().equals("")){%>
                            <a href="<%=lg.getGeneLink(tc.getGeneID(),myOrganism,true,true,false)%>" target="_blank" title="View Detailed Transcription Information for gene.">
                            
							<%if(tc.getGeneSymbol().equals("")){%>
								No Gene Symbol
							<%}else{%>
								<%=tc.getGeneSymbol()%>
                            <%}%>
                            </a>
							<%}else{%>
                            	No Gene Symbol
                            <%}%>
                            </TD>
                            
                            <TD >
                            	 <%if(!tc.getGeneID().equals("")){%>
                            <a href="<%=LinkGenerator.getEnsemblLinkEnsemblID(tc.getGeneID(),fullOrg)%>" target="_blank" title="View Ensembl Gene Details"><%=tc.getGeneID()%></a><BR />	
                                <span style="font-size:10px;">
								<%String tmpGS=tc.getGeneID();
									String shortOrg="Mouse";
									String allenID="";
									if(myOrganism.equals("Rn")){
                                    	shortOrg="Rat";
									}
									if(tc.getGeneSymbol()!=null&&!tc.getGeneSymbol().equals("")){
										tmpGS=tc.getGeneSymbol();
                            			allenID=tc.getGeneSymbol();
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
                                 <%}%>
                             </TD>
                            
                            
                            
                            <TD title="<%=remain%>"><%=shortDesc%></TD>
                            
                            <TD><%=tc.getTranscriptClusterID()%></TD>
                            <TD><%=tc.getLevel()%></TD>
                            
                            <TD >chr<%=tc.getChromosome()+":"+dfC.format(tc.getStart())+"-"+dfC.format(tc.getEnd())%></TD>
                            <TD ><a href="web/GeneCentric/setupLocusSpecificEQTL.jsp?geneSym=<%=tc.getGeneSymbol()%>&ensID=<%=tc.getGeneID()%>&chr=<%=tc.getChromosome()%>&start=<%=tc.getStart()%>&stop=<%=tc.getEnd()%>&level=<%=tc.getLevel()%>&tcID=<%=tc.getTranscriptClusterID()%>&curDir=<%=folderName%>" 
                                	target="_blank" title="View the circos plot for transcript cluster eQTLs">View Location Plot</a></TD>
                            <%
							//String[] curTissues=tc.getTissueList();
							for(int j=0;j<tissuesList2.length;j++){
								//log.debug("TABLE2:"+tissuesList2[j]);
									ArrayList<EQTL> regionQTL=tc.getTissueRegionEQTL(tissuesList2[j]);
									int qtlCount=tc.getTissueEQTL(tissuesList2[j],pValueCutoff);
									EQTL regEQTL=null;
									if(regionQTL!=null && regionQTL.size()>0){
										regEQTL=regionQTL.get(0);
									}
									%>
                                        
                                        <%if(regEQTL==null){
                                        	if(myOrganism.equals("Mm")){%>
												<TD class="leftBorder">>0.3</TD>
                                            <%}else{%>
                                            	<TD class="leftBorder">>0.2</TD>
                                            <%}%>
										<%}else if(regEQTL.getPVal()<0.0001){%>
                                        	<TD class="leftBorder" style="background-color:#6e99bc; color:#FFFFFF;">
                                        	< 0.0001
										<%}else{%>
                                        	<TD class="leftBorder"
                                            <%if(regEQTL.getPVal()<=pValueCutoff){%>
                                            	style="background-color:#6e99bc; color:#FFFFFF;"
                                            <%}%>
                                            >
											<%=df4.format(regEQTL.getPVal())%>
                                        <%}%>
                                        </TD>
                                        <TD title="Click on View Location Plot to see all locations below the cutoff.">
                                        	<%=qtlCount%>
                                        </TD>
                                <%}%>
                            
                        </TR>
                    <%} //end if
					}//end for tcOutQTLs%>
                   	 
				 </tbody>
              </table>
              <BR /><BR /><BR />
              
              <script type="text/javascript">
			  	var tblFrom=$('#tblFrom').dataTable({
					"bPaginate": false,
					"bProcessing": true,
					"sScrollX": "950px",
					"sScrollY": "650px",
					"bDeferRender": true,
					"sDom": '<"leftSearch"fr><t>'
					});
	
					$('#geneIDFCBX').click( function(){
							displayColumns(tblFrom,1,1,$('#geneIDFCBX').is(":checked"));
					  });
					  $('#geneDescFCBX').click( function(){
							displayColumns(tblFrom,2,1,$('#geneDescFCBX').is(":checked"));
					  });
					  
					  $('#transAnnotCBX').click( function(){
							displayColumns(tblFrom,3,2,$('#transAnnotCBX').is(":checked"));
					  });
					  $('#allPvalCBX').click( function(){
							for(var i=0;i<tisLen;i++){
								displayColumns(tblFrom,i*2+7,1,$('#allPvalCBX').is(":checked"));
							}
					  });
					  $('#allLocCBX').click( function(){
							for(var i=0;i<tisLen;i++){
								displayColumns(tblFrom,i*2+8,1,$('#allLocCBX').is(":checked"));
							}
					  });
					  $('#fromBrainCBX').click( function(){
							displayColumns(tblFrom,7,2,$('#fromBrainCBX').is(":checked"));
					  });
					   $('#fromHeartCBX').click( function(){
							displayColumns(tblFrom,9,2,$('#fromHeartCBX').is(":checked"));
					  });
					  $('#fromLiverCBX').click( function(){
							displayColumns(tblFrom,11,2,$('#fromLiverCBX').is(":checked"));
					  });
					  $('#fromBATCBX').click( function(){
							displayColumns(tblFrom,13,2,$('#fromBATCBX').is(":checked"));
					  });
					  
					  
						$('#circosSizeSelect').change( function(){
								var size=$(this).val();
								$('#circosIFrame').attr("height",size);
								if(size<=950){
									$('#circosIFrame').attr("width",950);
								}else{
									$('#circosIFrame').attr("width",size-2);
								}
						});
						$('.eQTLListToolTip').tooltipster({
							position: 'top-right',
							maxWidth: 250,
							offsetX: 24,
							offsetY: 5,
							//arrow: false,
							interactive: true,
							interactiveTolerance: 350
						});
			  </script>
      	<%}else{%>
        	<script type="text/javascript">
				tblFromAdjust=true;
			</script>
      		No genes to display.  Try changing the filtering parameters.
		<%}%>
     <%}else{%>
    	 <script type="text/javascript">
			 tblFromAdjust=true;
			</script>
     	<strong><%=session.getAttribute("getTransControllingEQTL")%></strong>
     <%}%>
</div><!-- end eQTL List-->
</div><!--end MainTab-->


<script type="text/javascript">
	
	$('#mainTab ul li a').removeClass('disable');
	//below fixes a bug in IE9 where some whitespace may cause an extra column in random rows in large tables.
	//simply remove all whitespace from html in a table and put it back.
	if (/MSIE (\d+\.\d+);/.test(navigator.userAgent)){ //test for MSIE x.x;
 		var ieversion=new Number(RegExp.$1) // capture x.x portion and store as a number
		if (ieversion<10){
			var expr = new RegExp('>[ \t\r\n\v\f]*<', 'g');
			var tbhtml = $('#tblGenes').html();
			$('#tblGenes').html(tbhtml.replace(expr, '><'));
			tbhtml = $('#tblBQTL').html();
			$('#tblBQTL').html(tbhtml.replace(expr, '><'));
			tbhtml = $('#tblFrom').html();
			$('#tblFrom').html(tbhtml.replace(expr, '><'));
		}	
	}
	
	
	
	
	$(".multiselect").twosidedmultiselect();
    //var selectedChromosomes = $("#chromosomesMS")[0].options;
	
	
	document.getElementById("loadingRegion").style.display = 'none';
	
	
	$('#eqtlTabID').click(function() {    
			$('div#changingTabs').show(10);
				//change the tab
				$('#mainTab ul li a').removeClass('selected');
				$(this).addClass('selected');
				var currentTab = $(this).attr('href'); 
				$('#mainTab div.modalTabContent').hide();       
				$(currentTab).show();
				//adjust row and column widths if needed(only needs to be done once)
				if(!tblFromAdjust&& tblFrom!=undefined){
						tblFrom.fnAdjustColumnSizing();
						tblFromAdjust=true;
					}
					setFilterTableStatus("fromListFilter");
				
			$('div#changingTabs').hide(10);
			return false;
        });
	
	
	
	
	
	
	
	
	
	
	
	
	
	

	
	//Setup Tabs
    /*$('#mainTab ul li a').click(function() {    
			$('div#changingTabs').show(10);
				//change the tab
				$('#mainTab ul li a').removeClass('selected');
				$(this).addClass('selected');
				var currentTab = $(this).attr('href'); 
				$('#mainTab div.modalTabContent').hide();       
				$(currentTab).show();
				
				//adjust row and column widths if needed(only needs to be done once)
				if(currentTab == "#geneList"){
					//tblGenes.fnAdjustColumnSizing();
					
					setFilterTableStatus("geneListFilter");
					
				}else if(currentTab == "#bQTLList"){
					if(!tblBQTLAdjust){
						tblBQTL.fnAdjustColumnSizing();
						tblBQTLAdjust=true;
					}
					setFilterTableStatus("bqtlListFilter");
				}else if(currentTab == "#eQTLListFromRegion" ){
					if(!tblFromAdjust){
						tblFrom.fnAdjustColumnSizing();
						tblFromAdjust=true;
					}
					setFilterTableStatus("fromListFilter");
					//tblFromFixed=new FixedColumns( tblFrom, {
					//		"iLeftColumns": 1,
					//		"iLeftWidth": 100
					//} );
				}
				
			$('div#changingTabs').hide(10);
			return false;
        });*/
		
		/*$('#inRegionTab ul li a').click(function() {    
				
				//change the tab
				$('#inRegionTab ul li a').removeClass('selected');
				$(this).addClass('selected');
				var currentTab = $(this).attr('href'); 
				$('#inRegionTab div.innerTabContent').hide();       
				$(currentTab).show();
				
				//adjust row and column widths if needed(only needs to be done once)
				if(currentTab == "#codingList"){
					innerTabInd=0;
					setFilterTableStatus("geneListFilter");
					//tblGenes.fnAdjustColumnSizing();
				}else if(currentTab == "#noncodingList"){
					innerTabInd=1;
					
					setFilterTableStatus("smallnoncodeFilter");
					if(!tblSMNCAdjust){
						tblSMNonCoding.fnAdjustColumnSizing();
						tblSMNCADjust=true;
					}
				}
				$('#geneList').show();
				$('#geneTabID').addClass('selected');
			//$('div#changingTabs').hide(10);
			return false;
        });*/
	


</script>

