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







<script type="text/javascript">
	
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
</script>

