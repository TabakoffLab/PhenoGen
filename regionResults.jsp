<div id="page" style="min-height:1100px;">
<span style="text-align:center;">
<%if(genURL.get(0)!=null && !genURL.get(0).startsWith("ERROR:")){%>

<%
	String[] tissuesList1=new String[1];
	String[] tissuesList2=new String[1];
	if(myOrganism.equals("Rn")){
		tissuesList1=new String[4];
		tissuesList2=new String[4];
		tissuesList1[0]="Brain";
		tissuesList2[0]="Whole Brain";
		tissuesList1[1]="Heart";
		tissuesList2[1]="Heart";
		tissuesList1[2]="Liver";
		tissuesList2[2]="Liver";
		tissuesList1[3]="Brown Adipose";
		tissuesList2[3]="Brown Adipose";
	}else{
		tissuesList1[0]="Brain";
		tissuesList2[0]="Whole Brain";
	}
	
	
	String tmpURL=genURL.get(0);
	int second=tmpURL.lastIndexOf("/",tmpURL.length()-2);
	String folderName=tmpURL.substring(second+1,tmpURL.length()-1);
	
	
	
	//Setup Variables copied from LocusSpecificEQTL.jsp for Laura's multiselects for chromosome and tissue.
	String[] selectedChromosomes = null;
	String[] selectedTissues = null;
	String chromosomeString = null;
	String tissueString = null;
	Boolean selectedChromosomeError = null;
	Boolean selectedTissueError = null;
	
	//
	// Create chromosomeNameArray and chromosomeSelectedArray 
	// These depend on the species
	//
	
	int numberOfChromosomes;
	String[] chromosomeNameArray = new String[25];

	String[] chromosomeDisplayArray = new String[25];
	String doubleQuote = "\"";
	String isSelectedText = " selected="+doubleQuote+"true"+doubleQuote;
	String isNotSelectedText = " ";
	String chromosomeSelected = isNotSelectedText;
	String speciesGeneChromosome= myOrganism.toLowerCase()+chromosome.replace("chr","");

	if(myOrganism.equals("Mm")){
		numberOfChromosomes = 20;
		for(int i=0;i<numberOfChromosomes-1;i++){
			chromosomeNameArray[i]="mm"+Integer.toString(i+1);
			chromosomeDisplayArray[i]="Chr "+Integer.toString(i+1);
		}
		chromosomeNameArray[numberOfChromosomes-1] = "mmX";
		chromosomeDisplayArray[numberOfChromosomes-1]="Chr X";
	}else{
		numberOfChromosomes = 21;
		// assume if not mouse that it's rat
		for(int i=0;i<numberOfChromosomes-1;i++){
			chromosomeNameArray[i]="rn"+Integer.toString(i+1);
			chromosomeDisplayArray[i]="Chr "+Integer.toString(i+1);
		}
		chromosomeNameArray[numberOfChromosomes-1] = "rnX";
		chromosomeDisplayArray[numberOfChromosomes-1]="Chr X";
	}
	
	//
	// Create tissueNameArray and tissueSelectedArray
	// These are only defined for Rat
	//
	int numberOfTissues;
	String[] tissueNameArray = new String[4];
	String tissueSelected = isNotSelectedText;
	if(myOrganism.equals("Mm")){
		numberOfTissues = 1;
		tissueNameArray[0]="Brain";
	}
	else{
		numberOfTissues = 4;
		// assume if not mouse that it's rat
		tissueNameArray[0]="Brain";
		tissueNameArray[1]="Heart";
		tissueNameArray[2]="Liver";
		tissueNameArray[3]="BAT";
	}
	
	// Get information about which tissues to view -- easier for mouse
		
		if(myOrganism.equals("Mm")){
			tissueString = "Brain;";
		}
		else{
			// we assume if not mouse that it's rat
			if(request.getParameter("tissues")!=null && !request.getParameter("tissues").equals("")){			
				String tmpSelectedTissues = request.getParameter("tissues");
				selectedTissues=tmpSelectedTissues.split(",");
				log.debug("Getting selected tissues:"+selectedTissues);
				tissueString = "";
				selectedTissueError = true;
				for(int i=0; i< selectedTissues.length; i++){
					selectedTissueError = false;
					tissueString = tissueString + selectedTissues[i] + ";";
				}
				log.debug(" Selected Tissues: " + tissueString);
				//log.debug(" selectedTissueError: " + selectedTissueError);
				// We insist that the tissue string be at least one long
			}
			/*else if(request.getParameter("chromosomeSelectionAllowed")!=null){
				// We previously allowed chromosome/tissue selection, but now we got no tissues back
				// Therefore we did not include any tissues
				selectedTissueError=true;
			}*/
			else{
				//log.debug("could not get selected tissues");
				//log.debug("and we did not previously allow chromosome selection");
				//log.debug("therefore include all tissues");
				// we are not allowing chromosome/tissue selection.  Include all tissues.
				selectedTissues = new String[numberOfTissues];
				selectedTissueError=false;
				tissueString = "";
				for(int i=0; i< numberOfTissues; i++){
					tissueString = tissueString + tissueNameArray[i] + ";";
					selectedTissues[i]=tissueNameArray[i];
				}
			}
		}
		
		
		// Get information about which chromosomes to view

		if(request.getParameter("chromosomes")!=null && !request.getParameter("chromosomes").equals("")){			
			String tmpSelectedChromosomes = request.getParameter("chromosomes");
			selectedChromosomes=tmpSelectedChromosomes.split(",");
			//log.debug("selected chr count:"+selectedChromosomes.length+":"+selectedChromosomes[0].toString());
			chromosomeString = "";
			selectedChromosomeError = true;
			for(int i=0; i< selectedChromosomes.length; i++){
				chromosomeString = chromosomeString + selectedChromosomes[i] + ";";
				if(selectedChromosomes[i].equals(speciesGeneChromosome)){
					selectedChromosomeError=false;
				}
			}
			log.debug(" Selected Chromosomes: " + chromosomeString);
			//log.debug(" selectedChromosomeError: " + selectedChromosomeError);
			// We insist that the chromosome string include speciesGeneChromosome 
		}
		else if(request.getParameter("chromosomeSelectionAllowed")!=null){
			// We previously allowed chromosome selection, but now we got no chromosomes back
			// Therefore we did not include the desired chromosome
			selectedChromosomeError=true;
		}
		else{
			//log.debug("could not get selected chromosomes");
			//log.debug("and we did not previously allow chromosome selection");
			//log.debug("therefore include all chromosomes");
			// we are not allowing chromosome selection.  Include all chromosomes.
			selectedChromosomes = new String[numberOfChromosomes];
			selectedChromosomeError=false;
			chromosomeString = "";
			for(int i=0; i< numberOfChromosomes; i++){
				chromosomeString = chromosomeString + chromosomeNameArray[i] + ";";
				selectedChromosomes[i]=chromosomeNameArray[i];
			}
		}
	
%>
    
    <script>
		var tisLen=<%=tissuesList1.length%>;
		var organism="<%=myOrganism%>";
    </script>

        <div class="geneRegionControl">
      		Zoom In:
          <form id="zoomIn" name="zoomIn" method="post" action="" style="display:inline-block;">
                      <input type="submit" name="action" id="refreshBTN" value="1.5x" onClick="return displayWorking()">
                      <input type="submit" name="action" id="refreshBTN" value="3x" onClick="return displayWorking()">
                      <input type="submit" name="action" id="refreshBTN" value="10x" onClick="return displayWorking()">      
          </form>
         Zoom In:
          <form id="zoomOut" name="zoomOut" method="post" action="" style="display:inline-block;">
                      <input type="submit" name="action" id="refreshBTN" value="1.5x" onClick="return displayWorking()">
                      <input type="submit" name="action" id="refreshBTN" value="3x" onClick="return displayWorking()">
                      <input type="submit" name="action" id="refreshBTN" value="10x" onClick="return displayWorking()">      
          </form>
          </div><!--end RegionControl div -->
    
    <div style="border-color:#CCCCCC; border-width:1px; border-style:inset; width:98%; text-align:center;">
        <div class="geneimageControl">
      		
          	<form>
            Image Controls:
              <label style="color:#000000; margin-left:10px;">
                Transcripts:</label>
                <select name="transcriptSelect" id="transcriptSelect">
                	<option value="geneimageUnfiltered" selected="selected">Hide</option>
                    <option value="geneimageFiltered" >Show</option>
                </select>
              <label style="color:#000000; margin-left:10px;">Additional Track options:</label>
             	<select name="lowerTrackSelect" id="lowerTrackSelect">
                	<option value="NoArray">None</option>
                    <option value="Array" selected="selected">UCSC/Affymetrix Tissue Expression Data(Source:UCSC)</option>
                    <option value="Human">Human Proteins/Chr Mapping(Source:UCSC)</option>
                </select>
                <div class="inpageHelp" style="display:inline-block; margin-left:10px;"><img id="Help2" src="../web/images/icons/help.png" /></div>
             </form>
         
		 
          </div><!--end imageControl div -->
        <div class="geneimage" >
            <div class="inpageHelp" style="display:inline-block;position:relative;float:right;"><img id="Help1" src="../web/images/icons/help.png"  /></div>
    
            <div id="geneimageUnfilteredArray" class="ucscImage"  style="display:inline-block;"><a class="fancybox fancybox.iframe" href="<%=ucscURL.get(0)%>" title="UCSC Genome Browser"><img src="<%= contextRoot+"tmpData/regionData/"+folderName+"/region.main.png"%>"/></a></div>
            <div id="geneimageFilteredArray"  class="ucscImage" style="display:none;"><a class="fancybox fancybox.iframe" href="<%=ucscURLFiltered.get(0)%>" title="UCSC Genome Browser"><img src="<%= contextRoot+"tmpData/regionData/"+folderName+"/region.main.trans.png"%>"/></a></div>
            <%
				String ucscURL_no_array=ucscURL.get(0).replace(".main",".main.noArray");
				String ucscURLFiltered_no_array=ucscURLFiltered.get(0).replace(".main.trans",".main.trans.noArray");
			%>
            <div id="geneimageUnfilteredNoArray" class="ucscImage"  style="display:none;"><a class="fancybox fancybox.iframe" href="<%=ucscURL_no_array%>" title="UCSC Genome Browser"><img src="<%= contextRoot+"tmpData/regionData/"+folderName+"/region.main.noArray.png"%>"/></a></div>
            <div id="geneimageFilteredNoArray" class="ucscImage" style="display:none;"><a class="fancybox fancybox.iframe" href="<%=ucscURLFiltered_no_array%>" title="UCSC Genome Browser"><img src="<%= contextRoot+"tmpData/regionData/"+folderName+"/region.main.trans.noArray.png"%>"/></a></div>
            <%
				String ucscURL_human=ucscURL.get(0).replace(".main",".main.human");
				String ucscURLFiltered_human=ucscURLFiltered.get(0).replace(".main.trans",".main.trans.human");
			%>
            <div id="geneimageUnfilteredHuman" class="ucscImage" style="display:none;"><a class="fancybox fancybox.iframe" href="<%=ucscURL_human%>" title="UCSC Genome Browser"><img src="<%= contextRoot+"tmpData/regionData/"+folderName+"/region.main.human.png"%>"/></a>
            	<BR />Chromosome Color Key:<img src="<%= contextRoot+"web/images/"+myOrganism+"_colorchrom.gif"%>"></div>
            <div id="geneimageFilteredHuman" class="ucscImage" style="display:none;"><a class="fancybox fancybox.iframe" href="<%=ucscURLFiltered_human%>" title="UCSC Genome Browser"><img src="<%= contextRoot+"tmpData/regionData/"+folderName+"/region.main.trans.human.png"%>"/></a>
            	<BR /><BR />Chromosome Color Key:<img src="<%= contextRoot+"web/images/"+myOrganism+"_colorchrom.gif"%>"></div>
    
        </div><!-- end geneimage div -->
    
          </div><!--end Border Div -->

          <BR />
         </span><!-- ends center span -->
          

<div class="cssTab" style="position:relative;">
    <ul>
      <li ><a href="#geneList" title="What genes are found in this area?">Genes Physically Located in Region</a></li>
      <li ><a href="#bQTLList" title="What bQTLs occur in this area?">bQTLs<BR />Overlapping Region</a></li>
      <li ><a href="#eQTLListFromRegion" title="What does this region control?">Transcripts Controlled from Region(eQTLs)</a></li>
     </ul>
     
<div id="loadingRegion"  style="text-align:center; position:relative; top:75px; left:-200px;"><img src="<%=imagesDir%>wait.gif" alt="Loading..." /><BR />Loading Region Data...</div>


<div id="geneList" class="modalTabContent" style=" display:none; position:relative;top:56px;border-color:#CCCCCC; border-width:1px; border-style:inset;width:995px;">
            	
                <table class="geneFilter">
                	<thead>
                    	<TR>
                    	<TH style="width:50%"><span class="trigger" name="geneListFilter" style=" position:relative;text-align:left; z-index:999;">Filter List</span></TH>
                        <TH style="width:50%"><span class="trigger" name="geneListFilter" style=" position:relative;text-align:left; z-index:999;">View Columns</span></TH>
                        </TR>
                    </thead>
                	<tbody id="geneListFilter" style="display:none;">
                    	<TR>
                        	<td>
                            <%if(myOrganism.equals("Rn")){%>
                                Exclude single exon RNA-Seq Transcripts
                            	<input name="chkbox" type="checkbox" id="exclude1Exon" value="exclude1Exon" checked="checked" /><BR />
                        	<%}%>
						 eQTL P-Value Cut-off:
                        <%
							selectName = "pvalueCutoffSelect1";
							selectedOption = Double.toString(pValueCutoff);
							onChange = "";
							style = "";
							optionHash = new LinkedHashMap();
										optionHash.put("0.10", "0.10");
										optionHash.put("0.01", "0.01");
										optionHash.put("0.001", "0.001");
										optionHash.put("0.0001", "0.0001");
										optionHash.put("0.00001", "0.00001");
							%>
							<%@ include file="/web/common/selectBox.jsp" %>
                            </td>
                        	<td>
                            	<div class="columnLeft">
                                	Gene ID
                                    <input name="chkbox" type="checkbox" id="geneIDCBX" value="geneIDCBX" checked="checked" /><BR />
                                    Description
                                    <input name="chkbox" type="checkbox" id="geneDescCBX" value="geneDescCBX" checked="checked" /><BR />
                                    Location and Strand
                                    <input name="chkbox" type="checkbox" id="geneLocCBX" value="geneLocCBX" checked="checked" /><BR />
                                    Heritability
                                    <input name="chkbox" type="checkbox" id="heritCBX" value="heritCBX" checked="checked" /><BR />
                                </div>
                                <div class="columnRight">
                                	Detection Above Background
                                	<input name="chkbox" type="checkbox" id="dabgCBX" value="dabgCBX" checked="checked" /><BR />
                                    eQTLs All
                                    <input name="chkbox" type="checkbox" id="eqtlAllCBX" value="eqtlAllCBX" checked="checked" /><BR />
                                    eQTLs Tissues
                                    <input name="chkbox" type="checkbox" id="eqtlCBX" value="eqtlCBX" checked="checked" />
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
          	<TABLE name="items"  id="tblGenes" class="list_base tablesorter" cellpadding="0" cellspacing="0" >
                <THEAD>
                    <tr>
                        <th colspan="6" class="topLine noSort noBox"></th>
                        <th colspan="1" class="center noSort topLine">RNA-Seq Data</th>
                        <th colspan="<%=5+tissuesList1.length*2+tissuesList2.length*2%>"  class="center noSort topLine">Affy Exon 1.0 ST Array Data</th>
                    </tr>
                    <tr>
                        <th colspan="6"  class="topLine noSort noBox"></th>
                        <th colspan="1"  class="leftBorder rightBorder noSort"></th>
                        <th colspan="1"  class="leftBorder rightBorder noSort"></th>
                        <th colspan="<%=tissuesList1.length%>"  class="center noSort topLine">Probesets > 0.33 Heritability</th>
                        <th colspan="<%=tissuesList1.length%>" class="center noSort topLine">Probesets > 1% DABG</th>
                        <th colspan="<%=3+tissuesList2.length*2%>" class="center noSort topLine" title="eQTLs at the Gene Level.  These are calculated for Transcript Clusters which are Gene Level and not individual transcripts.">eQTLs(Gene/Transcript Cluster ID)</th>
                    </tr>
                    <tr>
                        <th colspan="6"  class="topLine noSort noBox"></th>
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
                    
                    <TH>Gene Symbol<BR />(click for detailed transcription view)</TH>
                    <TH>Gene ID</TH>
                    <TH width="10%">Gene Description</TH>
                    <TH>Location</TH>
                    <TH>Strand</TH>
                    <TH># Ensembl Transcripts</TH>
                    <TH>Transcripts (RNA-Seq)</TH>
                    <TH>Total Probesets</TH>
                    
                    <%for(int i=0;i<tissuesList1.length;i++){%>
                    	<TH><%=tissuesList1[i]%> Count<BR />(Avg)</TH>
                    <%}%>
                    <%for(int i=0;i<tissuesList1.length;i++){%>
                    	<TH><%=tissuesList1[i]%> Count<BR />(Avg)</TH>
                    <%}%>
                    <TH>Transcript Cluster ID</TH>
                    <TH>Annotation Level</TH>
                    <TH>View Genome-Wide Associations</TH>
                    <%for(int i=0;i<tissuesList2.length;i++){%>
                    	<TH>Total # Locations P-Value < <%=pValueCutoff%> </TH>
                        <TH>Minimum<BR /> P-Value<BR />Location</TH>
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
						if(!chr.startsWith("chr")){
							chr="chr"+chr;
						}
                        %>
                        <TR <%if(curGene.getSource().equals("RNA Seq")&&curGene.isSingleExon()){%>class="singleExon"<%}%>>
                            <TD title="View detailed transcription information for gene in a new window.">
							<%if(curGene.getGeneID().startsWith("ENS")){%>
                            	<a href="<%=request.getContextPath()%>/gene.jsp?geneTxt=<%=curGene.getGeneID()%>&speciesCB=<%=myOrganism%>&auto=Y&newWindow=Y" target="_blank">
                            <%}else{%>
                            	<a href="<%=request.getContextPath()%>/gene.jsp?geneTxt=<%=chr+":"+curGene.getStart()+"-"+curGene.getEnd()%>&speciesCB=<%=myOrganism%>&auto=Y&newWindow=Y" target="_blank">
                            <%}%>
                            <%if(curGene.getGeneSymbol()!=null&&!curGene.getGeneSymbol().equals("")){%>
									<%=curGene.getGeneSymbol()%>
                            <%}else{%>
                                	No Gene Symbol
                            <%}%>
                                </a>
                            </TD>
                            
                            <TD >
							<%if(curGene.getGeneID().startsWith("ENS")){%>
                            	<a href="http://www.ensembl.org/<%=fullOrg%>/Gene/Summary?g=<%=curGene.getGeneID()%>" target="_blank" title="View Ensembl Gene Details"><%=curGene.getGeneID()%></a>
                            <%}else{%>
                            	<%=curGene.getGeneID()%>
                            <%}%>
                            </TD>
                            
                            <%	String description=curGene.getDescription();
								String shortDesc=description;
        						String remain="";
								if(description.indexOf("[")>0){
            						shortDesc=description.substring(0,description.indexOf("["));
									remain=description.substring(description.indexOf("[")+1,description.indexOf("]"));
        						}
							%>
                            <TD title="<%=remain%>"><%=shortDesc%></TD>
                            <TD><%=chr+":"+curGene.getStart()+"-"+curGene.getEnd()%></TD>
                            <TD><%=curGene.getStrand()%></TD>
                            <TD><%=curGene.getTranscriptCountEns()%></TD>
                            <TD><%=curGene.getTranscriptCountRna()%></TD>
                            <TD><%=curGene.getProbeCount()%></TD>
                            <!--<TD></TD>-->
                            <%for(int j=0;j<tissuesList1.length;j++){
								Object tmpH=hCount.get(tissuesList1[j]);
								Object tmpHa=hSum.get(tissuesList1[j]);
								if(tmpH!=null){
									int count=Integer.parseInt(tmpH.toString());
									double sum=Double.parseDouble(tmpHa.toString());
									%>
                                	<TD <%if(j==0){%>class="leftBorder"<%}%>><%=count%>
                                    <%if(count>0){%><BR />(<%=df2.format(sum/count)%>)<%}%>
                                    </TD>
                                <%}else{%>
                                	<TD <%if(j==0){%>class="leftBorder"<%}%>>N/A</TD>
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
                                <a href="web/GeneCentric/setupLocusSpecificEQTL.jsp?geneSym=<%=curGene.getGeneSymbol()%>&ensID=<%=curGene.getGeneID()%>&chr=<%=tc.getChromosome()%>&start=<%=tc.getStart()%>&stop=<%=tc.getEnd()%>&level=<%=tc.getLevel()%>&tcID=<%=tc.getTranscriptClusterID()%>" 
                                	target="_blank" title="View the circos plot for transcript cluster eQTLs">
									View Location Plot
                                </a></TD>
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
                                        <!--</TD>
                                        <TD>--><BR /><a href="<%=request.getContextPath()%>/gene.jsp?geneTxt=<%="chr"+maxEQTL.getMarkerChr()+":"+maxEQTL.getMarker_start()+"-"+maxEQTL.getMarker_end()%>&speciesCB=<%=myOrganism%>&auto=Y&newWindow=Y" target="_blank" title="View Detailed Transcription Information for this region.">
                                        	chr<%=maxEQTL.getMarkerChr()+":"+maxEQTL.getMarker_start()+"-"+maxEQTL.getMarker_end()%>
                                        </a>
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

				 </tbody>
              </table>
          <%}%>

</div><!-- end GeneList-->

<div id="bQTLList" class="modalTabContent" style="display:none; position:relative;top:56px;border-color:#CCCCCC; border-width:1px; border-style:inset;width:995px;">
	
	<table class="geneFilter">
                	<thead>
                    	<TH style="width:50%"><span class="trigger" name="bqtlListFilter" style=" position:relative;text-align:left; z-index:999;">Filter List</span></TH>
                        <TH style="width:50%"><span class="trigger" name="bqtlListFilter" style=" position:relative;text-align:left; z-index:999;">View Columns</span></TH>
                    </thead>
                	<tbody id="bqtlListFilter" style="display:none;">
                    	<TR>
                        	<td></td>
                        	<td>
                            	<div class="columnLeft">
                                	<%if(myOrganism.equals("Mm")){%>
                                	RGD ID
                                    <input name="chkbox" type="checkbox" id="rgdIDCBX" value="rgdIDCBX" /><BR />
                                    Trait
                                    <input name="chkbox" type="checkbox" id="traitCBX" value="traitCBX" /><BR />
                                    <%}%>
                                	bQTL Symbol
                                    <input name="chkbox" type="checkbox" id="bqtlSymCBX" value="bqtlSymCBX" <%if(myOrganism.equals("Mm")){%>checked="checked"<%}%> /><BR />
                                    Trait Method
                                    <input name="chkbox" type="checkbox" id="traitMethodCBX" value="traitMethodCBX" /><BR />
                                    Phenotype
                                    <input name="chkbox" type="checkbox" id="phenotypeCBX" value="phenotypeCBX" checked="checked" /><BR />
                                    Diseases
                                    <input name="chkbox" type="checkbox" id="diseaseCBX" value="diseaseCBX" checked="checked" /><BR />
                                    References
                                    <input name="chkbox" type="checkbox" id="refCBX" value="refCBX" checked="checked" /><BR />
                                </div>
                                <div class="columnRight">
                                    Associated bQTLs
                                    <input name="chkbox" type="checkbox" id="assocBQTLCBX" value="assocBQTLCBX"  /><BR />
                                    Location Method
                                    <input name="chkbox" type="checkbox" id="locMethodCBX" value="locMethodCBX"  /><BR />
                                    LOD Score
                                    <input name="chkbox" type="checkbox" id="lodBQTLCBX" value="lodBQTLCBX" <%if(myOrganism.equals("Rn")){%>checked="checked"<%}%>/><BR />
                                    P-Value
                                    <input name="chkbox" type="checkbox" id="pvalBQTLCBX" value="pvalBQTLCBX"  /><BR />
                                </div>
                            	
                            </TD>
                        
                        </TR>
                        </tbody>
                  </table>


	<% ArrayList<BQTL> bqtls=gdt.getBQTLs(min,max,chromosome,myOrganism);
	if(bqtls.size()>0){
		log.debug("BQTLS >0 ");
	%>
	<TABLE name="items" id="tblBQTL" class="list_base tablesorter" cellpadding="0" cellspacing="0">
                <THEAD>
                	<TR class="col_title">
                    	<%if(myOrganism.equals("Mm")){%>
                    		<TH>MGI ID</TH>
                        <%}%>
                        <TH>RGD ID</TH>
                        <TH>QTL Symbol</TH>
                    	<TH>QTL Name</TH>
                        <TH>Trait</TH>
                        <TH>Trait Method</TH>
                        <TH>Phenotype</TH>
                        <TH>Associated Diseases</TH>
                        <TH>References<BR />RGD Ref<HR />PubMed</TH>
                        <TH>Candidate Genes</TH>
                        <TH>Related bQTL Symbols</TH>
                        <TH>Location</TH>
                        <TH>Location Method</TH>
                        <TH>LOD Score</TH>
                        <TH>P-value</TH>
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
                        	<a href="http://www.informatics.jax.org/marker/MGI:<%=curBQTL.getMGIID()%>" target="_blank">
							<%=curBQTL.getMGIID()%></a>
                        </TD>
                        <%}%>
                        <TD><a href="http://rgd.mcw.edu/rgdweb/report/qtl/main.html?id=<%=curBQTL.getRGDID()%>" target="_blank"> 
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
                        
                        <TD><%=curBQTL.getPhenotype()%></TD>
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
                                <a href="http://rgd.mcw.edu/rgdweb/report/reference/main.html?id=<%=ref1.get(j)%>" target="_blank"><%=ref1.get(j)%></a>
                        	<%}
							}%>
                        <HR />
                        
                         <%	ArrayList<String> ref2=curBQTL.getPubmedRef();
						 if(ref2!=null){
							for(int j=0;j<ref2.size();j++){
								if(j!=0){%>
                            		<BR />
                                <%}%>
                                <a href="http://www.ncbi.nlm.nih.gov/pubmed/<%=ref2.get(j)%>" target="_blank"><%=ref2.get(j)%></a>
                        <%}
						}%>
                        </TD>
                        
                        <TD>
                        <%	ArrayList<String> candidates=curBQTL.getCandidateGene();
							if(candidates!=null){
							for(int j=0;j<candidates.size();j++){%>
                            	<a href="<%=request.getContextPath()%>/gene.jsp?geneTxt=<%=candidates.get(j)%>&speciesCB=<%=myOrganism%>&auto=Y&newWindow=Y" target="_blank" title="View Detailed Transcription Information for gene."><%=candidates.get(j)%></a><BR />
                        	<%}
							}%>
                        </TD>
                        <TD><%	ArrayList<String> relQTL=curBQTL.getRelatedQTL();
							if(relQTL!=null){
							for(int j=0;j<relQTL.size();j++){%>
                            	<a href="<%=request.getContextPath()%>/gene.jsp?geneTxt=bQTL:<%=relQTL.get(j)%>&speciesCB=<%=myOrganism%>&auto=Y&newWindow=Y" target="_blank" title="Click to View bQTL Region in a new window."><%=relQTL.get(j)%></a><BR />
                        	<%}
							}%>
                        </TD>
                        <TD title="Click to view QTL region in a new window."><a href="<%=request.getContextPath()%>/gene.jsp?geneTxt=<%="chr"+curBQTL.getChromosome()+":"+curBQTL.getStart()+"-"+curBQTL.getStop()%>&speciesCB=<%=myOrganism%>&auto=Y&newWindow=Y" target="_blank">
                        chr<%=curBQTL.getChromosome()+":"+curBQTL.getStart()+"-"+curBQTL.getStop()%></a></TD>
                        <TD>
                        <%String tmpMM=curBQTL.getMapMethod();
                        if(tmpMM!=null){
                        	if(tmpMM.indexOf("by")>0){
                            	tmpMM=tmpMM.substring(tmpMM.indexOf("by"));
                            }%>
							<%=tmpMM%>
                        <%}%>
                        </TD>
                        <TD>
                        <%if(curBQTL.getLOD()==0){%>
                        	N/A
						<%}else{%>
							<%=curBQTL.getLOD()%>
                        <%}%>
                        </TD>
                        <TD>
                        <%if(curBQTL.getPValue()==0){%>
                        	N/A
						<%}else{%>
							<%=curBQTL.getPValue()%>
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
</div><!-- end bQTL List-->






<div id="eQTLListFromRegion" class="modalTabContent" style=" display:none; position:relative;top:56px;border-color:#CCCCCC; border-width:1px; border-style:inset;width:995px;">
		
        
		<table class="geneFilter">
                	<thead>
                    	<TH style="width:65%;"><span class="trigger" name="fromListFilter" style=" position:relative;text-align:left; z-index:999;">Filter List and Circos Plot</span></TH>
                        <TH><span class="trigger" name="fromListFilter" style=" position:relative;text-align:left; z-index:999;">View Columns</span></TH>
                    </thead>
                	<tbody id="fromListFilter" style="display:none;">
                    	<TR>
                        	<td>
                            	<table style="width:100%;">
                                	<tbody>
                                    	<TR>
                                        <TD colspan="2" style="text-align:center;">
                                            eQTL P-Value Cut-off:
                                        <%
                                            selectName = "pvalueCutoffSelect2";
                                            selectedOption = Double.toString(pValueCutoff).trim();
                                            onChange = "";
                                            style = "";
                                            optionHash = new LinkedHashMap();
                                                        optionHash.put("0.10", "0.10");
                                                        optionHash.put("0.01", "0.01");
                                                        optionHash.put("0.001", "0.001");
                                                        optionHash.put("0.0001", "0.0001");
                                                        optionHash.put("0.00001", "0.00001");
                                            %>
                                            <%@ include file="/web/common/selectBox.jsp" %>
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
                                                                <div class="inpageHelp" style="display:inline;">
                                                                <img id="Help9d" src="web/images/icons/help.png"/>
                                                                </div>
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
                                                            <div class="inpageHelp" style="display:inline-block;">
                                                            <img id="Help9c" src="web/images/icons/help.png"/>
                                                            </div>
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
                                        <TD colspan="2" style="text-align:center;">
                                          <input type="submit" name="filterBTN" id="filterBTN" value="Run Filter" onClick="return runFilter()">
                                        </TD>
                                	</TR>
                                   </tbody>
                                </table>
                            
                            </td>
                            	
                            <TD>
                            	<div class="columnLeft" style="width:60%;">
                                	Gene ID
                                    <input name="chkbox" type="checkbox" id="geneIDFCBX" value="geneIDFCBX"checked="checked" /><BR />
                                    Description
                                    <input name="chkbox" type="checkbox" id="geneDescFCBX" value="geneDescFCBX" checked="checked" /><BR />
                                    Transcript ID and Annot.
                                    <input name="chkbox" type="checkbox" id="transAnnotCBX" value="transAnnotCBX" checked="checked" /><BR />
                                     All Tissues P-values
                                    <input name="chkbox" type="checkbox" id="allPvalCBX" value="allPvalCBX" checked="checked" /><BR />
                                    All Tissues # Locations
                                    <input name="chkbox" type="checkbox" id="allLocCBX" value="allLocCBX"  checked="checked"/><BR />
                                </div>
                                <div class="columnRight" style="width:39%;">
                                   <h3>Specific Tissues:</h3>
                                    Whole Brain
                                    <input name="chkbox" type="checkbox" id="fromBrainCBX" value="fromBrainCBX" checked="checked" /><BR />
                                    <%if(myOrganism.equals("Rn")){%>
                                        Heart
                                        <input name="chkbox" type="checkbox" id="fromHeartCBX" value="fromHeartCBX" checked="checked" /><BR />
                                        Liver
                                        <input name="chkbox" type="checkbox" id="fromLiverCBX" value="fromLiverCBX" checked="checked" /><BR />
                                        Brown Adipose
                                        <input name="chkbox" type="checkbox" id="fromBATCBX" value="fromBATCBX"  checked="checked"/><BR />
                                    <%}%>
                                </div>
                            </TD>
                        
                        </TR>
                        </tbody>
                  </table>
   	<div style="text-align:center; width:100%;"><span class="trigger less" name="circosPlot" >Gene Location Cicos Plot</span></div>
    <div id="circosPlot" style="text-align:center;">
		<div style="display:inline-block;text-align:center; width:100%;">
        	<span id="circosMinMax"><img src="web/images/icons/magnifyingGlass_minus.png"></span>Inside of border below, the mouse wheel zooms.  Outside of the border, the mouse wheel scrolls. 
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
		}
		else
		{
			cutoffTimesTen = "50";		
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
	%>
	


          <div id="iframe_parent" align="center">
               <iframe id="circosIFrame" src=<%=iframeURL%> height=950 width=950  position=absolute scrolling="no" style="border-style:solid; border-color:rgb(139,137,137); border-radius:15px; -moz-border-radius: 15px; border-width:1px">
               </iframe>
          </div>
          <a href="http://genome.cshlp.org/content/early/2009/06/15/gr.092759.109.abstract" target="_blank" style="text-decoration: none">Circos: an Information Aesthetic for Comparative Genomics.</a>
     </div><!-- end CircosPlot -->

	<% 
		ArrayList<TranscriptCluster> transOutQTLs=gdt.getTransControllingEQTLs(min,max,chromosome,arrayTypeID,pValueCutoff,"core",myOrganism,tissueString,chromosomeString);//this region controls what genes
		log.debug("Trans Out SIZE:"+transOutQTLs.size());
		if(transOutQTLs!=null && transOutQTLs.size()>0){
			
	%>
	<TABLE name="items" id="tblFrom" class="list_base tablesorter" cellpadding="0" cellspacing="0">
                <THEAD>
               		 <tr>
                        <th colspan="7" class="topLine noSort noBox"></th>
                        <%for(int i=0;i<tissuesList2.length;i++){%>
                        	<th colspan="2" class="center noSort topLine">Tissue:<%=tissuesList2[i]%></th>
                        <%}%>
                    </tr>
                	<TR class="col_title">
                   		<TH>Gene Symbol<BR />(click for detailed transcription view)</TH>
                    	<TH>Gene ID</TH>
                    	
                        <TH>Description</TH>
                        <TH>Transcript Cluster ID</TH>
                        <TH>Annotation Level</TH>
                        <TH>Physical Location</TH>
                        <TH>View Genome-Wide Associations</TH>
                    	<%for(int i=0;i<tissuesList2.length;i++){%>
                            <TH title="Highlighted indicates a value less than or equal to the cutoff.">P-Value from region</TH>
                            <TH># other locations P-value<<%=pValueCutoff%></TH>
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
						for(int z=0;z<selectedChromosomes.length&&!include;z++){
							if(selectedChromosomes[z].equals(tcChr)){
								include=true;
							}
						}
						if(include){
                        %>
                        <TR>
                            <TD ><a href="<%=request.getContextPath()%>/gene.jsp?geneTxt=<%=tc.getGeneID()%>&speciesCB=<%=myOrganism%>&auto=Y&newWindow=Y" target="_blank" title="View Detailed Transcription Information for gene.">
							<%if(tc.getGeneSymbol().equals("")){%>
								No Gene Symbol
							<%}else{%>
								<%=tc.getGeneSymbol()%>
                            <%}%>
                            </a></TD>
                            
                            <TD ><a href="http://www.ensembl.org/<%=fullOrg%>/Gene/Summary?g=<%=tc.getGeneID()%>" target="_blank" title="View Ensembl Gene Details"><%=tc.getGeneID()%></a></TD>
                            
                            <%	String description=tc.getGeneDescription();
								String shortDesc=description;
        						String remain="";
								if(description.indexOf("[")>0){
            						shortDesc=description.substring(0,description.indexOf("["));
									remain=description.substring(description.indexOf("[")+1,description.indexOf("]"));
        						}
							%>
                            
                            <TD title="<%=remain%>"><%=shortDesc%></TD>
                            
                            <TD><%=tc.getTranscriptClusterID()%></TD>
                            <TD><%=tc.getLevel()%></TD>
                            
                            <TD >chr<%=tc.getChromosome()+":"+tc.getStart()+"-"+tc.getEnd()%></TD>
                            <TD ><a href="web/GeneCentric/setupLocusSpecificEQTL.jsp?geneSym=<%=tc.getGeneSymbol()%>&ensID=<%=tc.getGeneID()%>&chr=<%=tc.getChromosome()%>&start=<%=tc.getStart()%>&stop=<%=tc.getEnd()%>&level=<%=tc.getLevel()%>&tcID=<%=tc.getTranscriptClusterID()%>" 
                                	target="_blank" title="View the circos plot for transcript cluster eQTLs">View Location Plot</a></TD>
                            <%
							//String[] curTissues=tc.getTissueList();
							for(int j=0;j<tissuesList2.length;j++){
								//log.debug("TABLE2:"+tissuesList2[j]);
									ArrayList<EQTL> regionQTL=tc.getTissueRegionEQTL(tissuesList2[j]);
									ArrayList<EQTL> qtlList=tc.getTissueEQTL(tissuesList2[j]);
									EQTL regEQTL=null;
									if(regionQTL!=null && regionQTL.size()>0){
										regEQTL=regionQTL.get(0);
									}
									%>
                                        
                                        <%if(regEQTL==null){%>

												<TD class="leftBorder">>0.3</TD>

										<%}else if(regEQTL.getPVal()<0.0001){%>
                                        	<TD class="leftBorder" style="background-color:#6e99bc; color:#FFFFFF;">
                                        	< 0.0001
										<%}else{%>
                                        	<TD class="leftBorder"
                                            <%if(regEQTL.getPVal()<=0.01){%>
                                            	style="background-color:#6e99bc; color:#FFFFFF;"
                                            <%}%>
                                            >
											<%=df4.format(regEQTL.getPVal())%>
                                        <%}%>
                                        </TD>
                                        <TD>
                                        <%if(qtlList!=null && qtlList.size()>0){%>
                                        	<%=qtlList.size()%>
										<%}else{%>
                                        	0
                                        <%}%>
                                        </TD>
                                    
                                <%}%>
                            
                        </TR>
                    <%} //end if
					}//end for tcOutQTLs%>
                   	 
				 </tbody>
              </table>
              
      <%}else{%>
      No genes to display.  Try changing the filtering parameters.
					<%}%>
</div><!-- end eQTL List-->



       



</div><!-- ends page div -->



<%}else{%>
    	<div class="error"><%=genURL.get(selectedGene)%><BR />The administrator has been notified of the problem and will investigate the error.  We apologize for any inconvenience.</div><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR />
<%}%>
    

<div id="Help1Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>UCSC Genome Browser Image</H3>
The main image was generated by the <a target="_blank" href="http://genome.ucsc.edu/">UCSC Genome Browser</a>(click the image to open the browser at the position of the image).  There are a number of tracks which are illustrated in the image below and described in each numbered section following.
<img src="ucsc_example.jpg" />  
<ol>
<li>The first track contains all of the Affymetrix Exon Probesets for the <a target="_blank" href="http://www.affymetrix.com/estore/browse/products.jsp?productId=131474&categoryId=35765&productName=GeneChip-Mouse-Exon-ST-Array#1_1">Mouse</a> or
<a target="_blank" href="http://www.affymetrix.com/estore/browse/products.jsp?productId=131489&categoryId=35748&productName=GeneChip-Rat-Exon-ST-Array#1_1"> Rat</a> Affy Exon 1.0 ST array.  Below the image information about these probesets for a parental strains(Rat only) and <a target="_blank" href="http://www.jax.org/smsr/ristrain.html" >panels of recombinant inbred mice or rats</a> and various tissues will be displayed. </li>

<li>The next track if present contains the numbered exons for the positive strand.  If transcripts exist for the positive strand each unique exon is given a number such that the first exon is 1.  If transcripts have differing overlapping exons then the exons are numbered 1a,1b,etc.</li>
<li>Rat Only-The next track is a reconstruction of the transcriptome from RNA Sequencing.  These are the reconstructed transcripts computed by <a target="_blank" href="http://cufflinks.cbcb.umd.edu/index.html">CuffLinks</a> from RNA Sequencing data of Rat Brain.</li>
<li>This track if present contains the numbered exons for the reverse strand.  If transcripts exist for the reverse strand each unique exon is given a number such that the first exon is 1.  If transcripts have differing overlapping exons then the exons are numbered 1a,1b,etc.</li>
<li>Rat Only-CuffLinks cannot assemble all sequences.  There may be single exon "genes" from CuffLinks that in addition to being a signle gene could not be assigned to a strand.  These are numbered in this track.</li>
<li>These are standard UCSC Tracks for the RefSeq gene(top blue color) and Ensembl transcripts(bottom brown color).</li>
</ol></div></div>

<div id="Help2Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>UCSC Image Controls</H3>
This control allows you to choose between two different versions of the UCSC genome browser image.  Occasionally you may also have the option to select a different gene.  This occurs when iDecoder found more than one Ensembl Gene Identifier associated with your gene.  However the gene most closely related to the identifier you enter is selected first.<BR /><BR />
The unfiltered version of the image displays all the Affymetrix Exon probesets color coded by annotation level.<BR /><BR />
The filtered version has only probesets that were detected above background in 1% or more of the samples.  Detection Above BackGround(DABG)-Calculates the p-value that the intensities in a probeset could have been observed by chance in a background distribution. <a target="_blank" href="http://www.affymetrix.com/partners_programs/programs/developer/tools/powertools.affx">Affymetrix for more information</a>. <BR />  It also has one track per tissue where data is available (Mouse-Brain Rat-Brain,Heart,Liver,Brown Adipose).  While this is a low percentage it filters out all of the probesets that are not detected above background.
</div></div>


<div id="Help3Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>Filter/Display Controls</H3>
The filters allow you to control what probesets are displayed.  Check the box next to the filter you would like to apply.  The filter will be immediately applied, unless input is required and then it will be applied as you input a value.<BR /><BR />
The display controls allow you to make choices about how the data is displayed.  Any selections are immediately applied.<BR /><BR />
The Filter and Display controls will have different options as you navigate through different tabs, but any settings will return once you navigate back to a tab.
</div></div>




<script type="text/javascript">


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

function displayColumns(table,colStart,colLen,showOrHide){
	var colStop=colStart+colLen;
	for(var i=colStart;i<colStop;i++){
				table.dataTable().fnSetColumnVis( i, showOrHide );
	}
}

function runFilter(){
	$('#tissues').val($('#tissuesMS').val());
	$('#chromosomes').val($('#chromosomesMS').val());
	$('#pvalueCutoffInput').val($('#pvalueCutoffSelect2').val());
	$('#geneCentricForm').submit();
}

$(document).ready(function() {
	$(".multiselect").twosidedmultiselect();
    var selectedChromosomes = $("#chromosomes")[0].options;
	document.getElementById("loadingRegion").style.display = 'none';
	var bqtlTarget=[ 1,4,9,11,13 ];
	if(organism == "Mm"){
		bqtlTarget=[ 1,4,5,10,12,13,14 ];
	}
	
	$('.ucscImage').hide();
	$('#geneimageUnfilteredArray').show();
	
	/*  Removed Fixed columns because it slowed the page down too much it was always recalculating the rows.*/
	var tblGenesFixed=null;
	var tblFromFixed=null;
	var tblBQTLAdjust=false;
	
	var tblGenes=$('#tblGenes').dataTable({
	"bPaginate": false,
	"bProcessing": true,
	"sScrollX": "950px",
	"sScrollY": "650px"
	});
	
	
	var tblBQTL=$('#tblBQTL').dataTable({
	"bPaginate": false,
	"bProcessing": true,
	"sScrollX": "950px",
	"sScrollY": "650px",
	"bDeferRender": true,
	"aoColumnDefs": [
      { "bVisible": false, "aTargets": bqtlTarget }
    ]
	});
	
	var tblFrom=$('#tblFrom').dataTable({
	"bPaginate": false,
	"bProcessing": true,
	"sScrollX": "950px",
	"sScrollY": "650px",
	"bDeferRender": true
	});
	
	$('.cssTab div.modalTabContent').hide();
    $('.cssTab div.modalTabContent:first').show();
    $('.cssTab ul li a:first').addClass('selected');
	

	$('#tblGenes').dataTable().fnAdjustColumnSizing();
	tblGenesFixed=new FixedColumns( tblGenes, {
 		"iLeftColumns": 1,
		"iLeftWidth": 100
 	} );
	
	
	
	//$('#tblGenes_filter').css({position: 'relative',top: '-7px'});
	$('#tblGenes_wrapper').css({position: 'relative', top: '-56px'});
	//$('#tblBQTL_filter').css({position: 'relative',top: '-56px'});
	$('#tblBQTL_wrapper').css({position: 'relative', top: '-56px'});

	
	$('.singleExon').hide();
  
 	
	
	//Setup Help links
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
	$('#Help3').click( function(){  		
		$('#Help3Content').dialog("open").css({'height':300,'font-size':12});
		positionHelp(400);
  	});
	
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
  
  
  $('#transcriptSelect').change(function(){
  		$('.ucscImage').hide();
		var transVal=$(this).val();
		var lowerVal=$('#lowerTrackSelect').val();
		$('#'+transVal+lowerVal).show();
  });
  
   $('#lowerTrackSelect').change(function(){
  		$('.ucscImage').hide();
		var transVal=$('#transcriptSelect').val();
		var lowerVal=$(this).val();
		$('#'+transVal+lowerVal).show();
  });
  
 
  /* Setup Filtering/View Columns in tblGenes */
	  $('#heritCBX').click( function(){
			displayColumns(tblGenes, 8,tisLen,$('#heritCBX').is(":checked"));
	  });
	  $('#dabgCBX').click( function(){
			displayColumns(tblGenes, 8+tisLen,tisLen,$('#heritCBX').is(":checked"));
	  });
	  $('#eqtlAllCBX').click( function(){
			displayColumns(tblGenes, 8+tisLen*2,tisLen*2+3,$('#eqtlAllCBX').is(":checked"));
	  });
		$('#eqtlCBX').click( function(){
			displayColumns(tblGenes, 8+tisLen*2+3,tisLen*2,$('#eqtlCBX').is(":checked"));
	  });
	  
	   $('#geneIDCBX').click( function(){
			displayColumns(tblGenes,1,1,$('#geneIDCBX').is(":checked"));
	  });
	  $('#geneDescCBX').click( function(){
			displayColumns($(tblGenes).dataTable(),2,1,$('#geneDescCBX').is(":checked"));
	  });
	  
	  $('#geneLocCBX').click( function(){
			displayColumns($(tblGenes).dataTable(),3,2,$('#geneLocCBX').is(":checked"));
	  });
	  
	  $('#pvalueCutoffSelect1').change( function(){
				$('#pvalueCutoffInput').val($(this).val());
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
	
	/* Seutp Filtering/Viewing in tblFrom*/	
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
		/*$('#pvalueCutoffSelect2').change( function(){
			$('#pvalueCutoffInput').val($(this).val());
			$('#geneCentricForm').submit();
		});*/
	
	
	setupExpandCollapseTable();
	setupExpandCollapse();
	//var tableRows = getRows();
	//hoverRows(tableRows);
	
	$('#circosMinMax').click(function(){
		if($('#circosIFrame').attr("height")>400){
			$('> img',this).attr("src","web/images/icons/magnifyingGlass_plus.png");
			$('#circosIFrame').attr("height",400);
			$('#circosIFrame').attr("width",950);
		}else{
			$('> img',this).attr("src","web/images/icons/magnifyingGlass_minus.png");
			$('#circosIFrame').attr("height",950);
			$('#circosIFrame').attr("width",950);
		}
	});
	
	//Setup Tabs
    $('.cssTab ul li a').click(function() {    

            $('.cssTab ul li a').removeClass('selected');
            $(this).addClass('selected');
            var currentTab = $(this).attr('href'); 
            $('.cssTab div.modalTabContent').hide();       
            $(currentTab).show();
			
			if(currentTab == "#geneList"){
				//tblGenes.fnAdjustColumnSizing();
			}else if(currentTab == "#bQTLList" && !tblBQTLAdjust){
				tblBQTL.fnAdjustColumnSizing();
				tblBQTLAdjust=true;
			}else if(currentTab == "#eQTLListFromRegion" && tblFromFixed==null){
				tblFrom.fnAdjustColumnSizing();
				tblFromFixed=new FixedColumns( tblFrom, {
						"iLeftColumns": 1,
						"iLeftWidth": 100
				} );
			}else{
				var table = $.fn.dataTable.fnTables(false);
            	if ( table.length > 0 ) {
                	$(table).dataTable().fnAdjustColumnSizing();
            	}
			}
			
            
			
            return false;
        });
	
}); // end ready

</script>





