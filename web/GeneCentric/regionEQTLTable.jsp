<%@ include file="/web/common/anon_session_vars.jsp" %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<%
	java.util.Date startDate=new java.util.Date();
	log.debug("Starting eQTL from region.");
    gdt.setSession(session);
	ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> fullGeneList=new ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene>();
	DecimalFormat dfC = new DecimalFormat("#,###");
	String myOrganism="";
	String fullOrg="";
	String panel="";
	String chromosome="";
	String folderName="";
	String type="";
	LinkGenerator lg=new LinkGenerator(session);
	double pValueCutoff=0.01;
	int rnaDatasetID=0;
	int arrayTypeID=0;
	int min=0;
	int max=0;
	if(request.getParameter("species")!=null){
		myOrganism=request.getParameter("species").trim();
		if(myOrganism.equals("Rn")){
			panel="BNLX/SHRH";
			fullOrg="Rattus_norvegicus";
		}else{
			panel="ILS/ISS";
			fullOrg="Mus_musculus";
		}
	}
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
	if(request.getParameter("pValueCutoff")!=null){
		pValueCutoff=Double.parseDouble(request.getParameter("pValueCutoff"));
	}
	if(request.getParameter("rnaDatasetID")!=null){
		rnaDatasetID=Integer.parseInt(request.getParameter("rnaDatasetID"));
	}
	if(request.getParameter("arrayTypeID")!=null){
		arrayTypeID=Integer.parseInt(request.getParameter("arrayTypeID"));
	}
	if(request.getParameter("chromosome")!=null){
		chromosome=request.getParameter("chromosome");
	}
	
	if(request.getParameter("minCoord")!=null){
		min=Integer.parseInt(request.getParameter("minCoord"));
	}
	if(request.getParameter("maxCoord")!=null){
		max=Integer.parseInt(request.getParameter("maxCoord"));
	}
	if(request.getParameter("type")!=null){
		type=request.getParameter("type");
	}
	if(request.getParameter("folderName")!=null){
		folderName=request.getParameter("folderName");
	}
	
	String[] selectedChromosomes = null;
	String[] selectedTissues = null;
	String[] selectedLevels=null;
	String chromosomeString = null;
	String tissueString = null;
	Boolean selectedChromosomeError = null;
	Boolean selectedTissueError = null;
	String levelString="core;extended;full";
	
	
	
	if(request.getParameter("levels")!=null && !request.getParameter("levels").equals("")){			
				String tmpSelectedLevels = request.getParameter("levels");
				selectedLevels=tmpSelectedLevels.split(";");
				log.debug("Getting selected levels:"+tmpSelectedLevels);
				levelString = "";
				//selectedLevelError = true;
				for(int i=0; i< selectedLevels.length; i++){
					//selectedLevelsError = false;
					levelString = levelString + selectedLevels[i] + ";";
				}
	}else{
		log.debug("Getting selected levels: NULL Using defaults.");
		selectedLevels=levelString.split(";");
	}
	
	
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
			selectedTissues=new String[1];
			selectedTissues[0]="Brain";
		}
		else{
			// we assume if not mouse that it's rat
			if(request.getParameter("tissues")!=null && !request.getParameter("tissues").equals("")){			
				String tmpSelectedTissues = request.getParameter("tissues");
				selectedTissues=tmpSelectedTissues.split(";");
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
			selectedChromosomes=tmpSelectedChromosomes.split(";");
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
		java.util.Date time=new java.util.Date();
		log.debug("Setup before finging Path:"+(time.getTime()-startDate.getTime()));
		//String tmpOutput=gdt.getImageRegionData(chromosome,min,max,panel,myOrganism,rnaDatasetID,arrayTypeID,0.01,false);
		//int startInd=tmpOutput.lastIndexOf("/",tmpOutput.length()-2);
		//folderName=tmpOutput.substring(startInd+1,tmpOutput.length()-1);
	
	/*if(min<max){
			if(min<1){
				min=1;
			}
			/fullGeneList =gdt.getRegionData(chromosome,min,max,panel,myOrganism,rnaDatasetID,arrayTypeID,forwardPValueCutoff);					
			String tmpURL =gdt.getGenURL();//(String)session.getAttribute("genURL");
			int second=tmpURL.lastIndexOf("/",tmpURL.length()-2);
			folderName=tmpURL.substring(second+1,tmpURL.length()-1);
					//String tmpGeneSymbol=gdt.getGeneSymbol();//(String)session.getAttribute("geneSymbol");
					//String tmpUcscURL =gdt.getUCSCURL();//(String)session.getAttribute("ucscURL");
					//String tmpUcscURLFiltered =gdt.getUCSCURLFiltered();//(String)session.getAttribute("ucscURLFiltered");
					/*if(tmpURL!=null){
						genURL.add(tmpURL);
						if(tmpGeneSymbol==null){
							geneSymbol.add("");
						}else{
							geneSymbol.add(tmpGeneSymbol);
						}
						if(tmpUcscURL==null){
							ucscURL.add("");
						}else{
							ucscURL.add(tmpUcscURL);
						}*/
						/*if(tmpUcscURLFiltered==null){
							ucscURLFiltered.add("");
						}else{
							ucscURLFiltered.add(tmpUcscURLFiltered);
						}*/
					//}
	//}
			
	time=new java.util.Date();
	log.debug("Setup after finging Path:"+(time.getTime()-startDate.getTime()));
%>

<style>
  #circosDiv{
    display: inline-block;
	vertical-align:text-top;
    width: 43%;
  }
  #qtlTableDiv{
    display: inline-block;
	vertical-align:text-top;
    width: 56%;
  }
  
  @media screen and (max-width:1200px){
	  #circosDiv{
		display: inline-block;
		vertical-align:text-top;
		width: 100%;
	  }
	  #qtlTableDiv{
		display: inline-block;
		vertical-align:text-top;
		width: 100%;
	  }
  }

</style>

<div id="eQTLListFromRegion"  style="width:100%;">
		
        
		<!--<table class="geneFilter">
                	<thead>
                    	<TH style="width:65%;"><span class="trigger triggerEC regionSubHeader" id="fromListFilter1" name="fromListFilter" style="position:relative;text-align:left;">Filter List and Circos Plot</span><span class="eQTLListToolTip" title="Click the + icon to view filter options."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                        <TH><span class="trigger triggerEC regionSubHeader" id="fromListFilter2" name="fromListFilter" style="position:relative;text-align:left;">View Columns</span><span class="eQTLListToolTip" title="Click the + icon to view columns available to show/hide."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    </thead>
                	<tbody id="fromListFilter" style="display:none;">
                    	<TR>
                        	<td>
                            	
                            
                            </td>
                            	
                            <TD>
                            	
                            </TD>
                        
                        </TR>
                        </tbody>
                  </table>-->
<% log.debug("before eQTL table constr");
ArrayList<TranscriptCluster> transOutQTLs=gdt.getTransControllingEQTLs(min,max,chromosome,arrayTypeID,pValueCutoff,levelString,myOrganism,tissueString,chromosomeString);//this region controls what genes
	time=new java.util.Date();
	log.debug("Setup after getcontrolling eqtls:"+(time.getTime()-startDate.getTime()));
	ArrayList<String> eQTLRegions=gdt.getEQTLRegions();
	time=new java.util.Date();
	log.debug("Setup after get eqtls regions:"+(time.getTime()-startDate.getTime()));
  if(session.getAttribute("getTransControllingEQTL")==null){
  	if(transOutQTLs!=null && transOutQTLs.size()>0){%>
            
        
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
    
    
    <div id="circosDiv">
        <div class="regionSubHeader" style="font-size:18px; font-weight:bold; text-align:center; width:100%;">
            Gene Location Circos Plot
            <div class="inpageHelp" style="display:inline-block;"><img id="HelpRevCircos" class="helpImage" src="../web/images/icons/help.png" /></div>
            <!--<span style="font-size:12px; font-weight:normal;">
            Adjust Vertical Viewable Size:
            <select name="circosSizeSelect" id="circosSizeSelect">
                    <option value="200" >Smallest</option>
                    <option value="475" >Half</option>
                    <option value="950" selected="selected">Full</option>
                    <option value="1000" >Maximized</option>
                </select>
            </span>
            <span class="eQTLListToolTip" title="To control the viewable area of the Circos Plot below simply select your prefered size."><img src="<%=imagesDir%>icons/info.gif"></span>-->
            
        </div> 
        <%if(session.getAttribute("getTransControllingEQTLCircos")==null){%>
        <div id="circosPlot" style="text-align:center;">
            <div style="display:inline-block;text-align:center; width:100%;">
                <!--<span id="circosMinMax" style="cursor:pointer;"><img src="web/images/icons/circos_min.jpg"></span>-->
                <a href="<%=svgPdfFile%>" target="_blank">
                <img src="web/images/icons/download_g.png" title:"Download Circos Image">
                </a>
                Inside of border below, the mouse wheel zooms.  Outside of the border, the mouse wheel scrolls. 
                <span id="filterBtn1" class="filter button" >Filter eQTLs</span>
            </div>
    
            
    
              <div id="iframe_parent" align="center" style="width:100%">
                   <iframe id="circosIFrame" src=<%=iframeURL%> height=950   position=absolute scrolling="no" style="border-style:solid; border-color:rgb(139,137,137); border-radius:15px; -moz-border-radius: 15px; border-width:1px">
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
    </div>
    <div id="qtlTableDiv" style="display:inline-block;">
    	<div class="regionSubHeader" style="font-size:18px; font-weight:bold; text-align:center; width:100%;">
            List of Genes
            <span class="eQTLListToolTip" title=""><img src="<%=imagesDir%>icons/info.gif"></span>
        </div> 
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
			log.debug("after outer for loop");%>
			<div style=" float:right; ">
			<%if(idListCount<=300){%>
       			<a href="http://david.abcc.ncifcrf.gov/api.jsp?type=AFFYMETRIX_EXON_GENE_ID&ids=<%=idList%>&tool=summary" target="_blank">View DAVID Functional Annotation</a><div class="inpageHelp" style="display:inline-block;"><img id="HelpDAVID" class="helpImage" src="../web/images/icons/help.png" /></div>
        	<%}else{%>
            	Too many genes to submit to DAVID automatically. Filter or copy and submit on your own <a href="http://david.abcc.ncifcrf.gov/" target="_blank">here</a>.<span class="eQTLListToolTip" title=""><img src="<%=imagesDir%>icons/info.gif"></span><div class="inpageHelp" style="display:inline-block;"><img id="HelpDAVID" class="helpImage" src="../web/images/icons/help.png" /></div>
            <%}
			log.debug("end DAVID setup");
			time=new java.util.Date();
			log.debug("before setting up tables:"+(time.getTime()-startDate.getTime()));
			%>	
            <BR />
            <span id="viewBtn1" class="view button">Edit Columns</span>
            <span id="filterBtn2" class="filter button">Filter Rows</span>
            </div>
		<BR />	

	<TABLE name="items" id="tblFrom" class="list_base" cellpadding="0" cellspacing="0" border="0" width="100%" >
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
									if(description.indexOf("]")>0){
										remain=description.substring(description.indexOf("[")+1,description.indexOf("]"));
									}else{
										remain=description.substring(description.indexOf("[")+1);
									}
									
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
					}//end for tcOutQTLs
					time=new java.util.Date();
					log.debug("Total time:"+(time.getTime()-startDate.getTime()));
					%>
                   	 
				 </tbody>
              </table>
           </div>
              <BR /><BR /><BR />
              
              <script type="text/javascript">
			  		
					var tblFrom=$('#tblFrom').dataTable({
					"bAutoWidth": false,
					"bPaginate": false,
					"bProcessing": true,
					"sScrollX": "100%",
					"sScrollY": "100%",
					"bDeferRender": false,
					"sDom": '<"leftSearch"fr><t>'
					});
					$('#geneIDFCBX').click( function(){
							if(typeof tblFrom != 'undefined'){
								displayColumns(tblFrom,1,1,$('#geneIDFCBX').is(":checked"));
							}
					  });
					  $('#geneDescFCBX').click( function(){
					  	if(typeof tblFrom != 'undefined'){
							displayColumns(tblFrom,2,1,$('#geneDescFCBX').is(":checked"));
						}
					  });
					  
					  $('#transAnnotCBX').click( function(){
					  		if(typeof tblFrom != 'undefined'){
								displayColumns(tblFrom,3,2,$('#transAnnotCBX').is(":checked"));
							}
					  });
					  $('#allPvalCBX').click( function(){
					  		if(typeof tblFrom != 'undefined'){
								for(var i=0;i<tisLen;i++){
									displayColumns(tblFrom,i*2+7,1,$('#allPvalCBX').is(":checked"));
								}
							}
					  });
					  $('#allLocCBX').click( function(){
					  		if(typeof tblFrom != 'undefined'){
								for(var i=0;i<tisLen;i++){
									displayColumns(tblFrom,i*2+8,1,$('#allLocCBX').is(":checked"));
								}
							}
					  });
					  $('#fromBrainCBX').click( function(){
					  		if(typeof tblFrom != 'undefined'){
								displayColumns(tblFrom,7,2,$('#fromBrainCBX').is(":checked"));
							}
					  });
					   $('#fromHeartCBX').click( function(){
					   		if(typeof tblFrom != 'undefined'){
								displayColumns(tblFrom,9,2,$('#fromHeartCBX').is(":checked"));
							}
					  });
					  $('#fromLiverCBX').click( function(){
					  		if(typeof tblFrom != 'undefined'){
								displayColumns(tblFrom,11,2,$('#fromLiverCBX').is(":checked"));
							}
					  });
					  $('#fromBATCBX').click( function(){
					  		if(typeof tblFrom != 'undefined'){
								displayColumns(tblFrom,13,2,$('#fromBATCBX').is(":checked"));
							}
					  });
					  
					  
						$('#circosSizeSelect').change( function(){
								var size=$(this).val();
								$('#circosIFrame').attr("height",size);
								tblFrom.fnSettings().oScroll.sY = size;
								tblFrom.fnDraw();
								/*if(size<=950){
									$('#circosIFrame').attr("width",950);
								}else{
									$('#circosIFrame').attr("width",size-2);
								}*/
						});
						$('.eQTLListToolTip').tooltipster({
							position: 'top-right',
							maxWidth: 250,
							offsetX: 8,
							offsetY: 5,
							contentAsHTML:true,
							//arrow: false,
							interactive: true,
							interactiveTolerance: 350
						});
						
					
			  </script>
      	<%}else{%>
      		No genes to display.  Try changing the filtering parameters.
		<%}%>
     <%}else{%>
     	<strong><%=session.getAttribute("getTransControllingEQTL")%></strong>
     <%}%>
     <div class="regionSubHeader" style="font-size:18px; font-weight:bold; text-align:center; width:100%;">
            	<span class="trigger less triggerEC" name="eQTLRegionNote" >EQTL Region</span>
                <span class="eQTLListToolTip" title="This section lists the regions being reported as begin associated with control of the genes following.  It is important to note that the region entered may only be close to or overlap with a defined SNP or Region between SNPs and may larger than the region selected or may only include part of the region selected."><img src="<%=imagesDir%>icons/info.gif"></span>
            </div>
            <div id="eQTLRegionNote" style="width:100%;">
            Genes controlled from and P-values reported for eQTLs from this region are not specific to the region you entered. The "P-value from region" columns correspond to the following region(s):<BR />
            <%for(int i=0;i<eQTLRegions.size();i++){%>
                <a href="<%=request.getContextPath()%>/gene.jsp?geneTxt=<%=eQTLRegions.get(i)%>&speciesCB=<%=myOrganism%>&auto=Y&newWindow=Y" target="_blank"><%=eQTLRegions.get(i)%></a><BR />
            <%}%>
            So the genes listed below could be controlled from anywhere in the region(s) above.
            </div>
</div><!-- end eQTL List-->


<div id="filterdivEQTL" class="filterdivEQTL" style=" background-color:F8F8F8;display:none;position:absolute;z-index:999; border:solid;border-color:#000000;border-width:1px;">
	<span style="color:#000000;">Filter Settings</span>
   	<span class="closeBtn" id="close_filterdivEQTL" style="position:relative;top:1px;left:215px;"><img src="<%=imagesDir%>icons/close.png"></span>
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
                                                                String tmpChromosome=chromosome;
																if(tmpChromosome.toLowerCase().startsWith("chr")){
																	tmpChromosome.substring(3);
																}
                                                                for(int i = 0; i < numberOfChromosomes; i ++){
                                                                    chromosomeSelected=isNotSelectedText;
																	
                                                                    if(chromosomeDisplayArray[i].substring(4).equals(tmpChromosome)){
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
                                          <input type="button" name="filterBTN" id="filterBTN" value="Run Filter" onClick="runFilter()">
                                        </TD>
                                	</TR>
                                   </tbody>
                                </table>
</div>

<div id="viewEQTL" class="viewEQTL" style="background-color:#FFFFFF;display:none;position:absolute;z-index:999; top:660px; left:451px; border:solid;border-color:#000000;border-width:1px; width:450px;">
	<div style=" text-align:center; background-color:#F8F8F8;">
		<span style="color:#000000;">Show/Hide Columns</span>
   		<span class="closeBtn" id="close_viewEQTL" style="position:relative;top:1px;left:150px;"><img src="<%=imagesDir%>icons/close.png"></span>
    </div>
    <div style="width:100%;">
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
   </div>
</div>



<script type="text/javascript">
	//$(document).ready(function() {
		$(".multiselect").twosidedmultiselect();
		
		if(typeof tblFrom != 'undefined'){
			tblFrom.fnAdjustColumnSizing();
			tblFrom.fnDraw();
		}
		
		var pW=$('#iframe_parent').width();
		$('#circosIFrame').attr('width',pW-25);
		console.log("parent size(init):"+pW);
		$(window).resize(function (){
			var pW=$('#iframe_parent').width();
			$('#circosIFrame').attr('width',pW-25);
			if(typeof tblFrom != 'undefined'){
				tblFrom.fnAdjustColumnSizing();
				tblFrom.fnDraw();
			}
		});
		
		$(document).on("click","span.filter",function(){
				var id=new String($(this).attr("id"));
				if(!$("div#filterdivEQTL").is(":visible")){
						var p=$(this).position();
						var left=p.left;
						if(left>$(window).width()/2){
							left=left-$("#filterdivEQTL").width()+130;
						}
						console.log("top:"+top+" left:"+left);
						$("#filterdivEQTL").css("display","inline-block");
						$("#filterdivEQTL").css("top",p.top).css("left",left);
						$("#filterdivEQTL").show();
				}else{
						//$("#filterdivEQTL").fadeOut("fast");
						var p=$(this).position();
						var left=p.left;
						if(left>$(window).width()/2){
							left=left-$("#filterdivEQTL").width()+130;
						}
						$("#filterdivEQTL").css("top",p.top).css("left",left);
				}
				return true;
			});
			
		$(document).on("click","span.view",function(){
				var id=new String($(this).attr("id"));
				if(!$("div#viewEQTL").is(":visible")){
						var p=$(this).position();
						$("#viewEQTL").css("display","inline-block");
						$("#viewEQTL").css("top",p.top).css("left",p.left-226);
						$("#viewEQTL").show();
						//$("#viewEQTL").fadeIn("fast");
				}else{
						$("#viewEQTL").fadeOut("fast");
				}
				return false;
			});
		//below fixes a bug in IE9 where some whitespace may cause an extra column in random rows in large tables.
		//simply remove all whitespace from html in a table and put it back.
		if (/MSIE (\d+\.\d+);/.test(navigator.userAgent)){ //test for MSIE x.x;
			var ieversion=new Number(RegExp.$1) // capture x.x portion and store as a number
			if (ieversion<10){
				var expr = new RegExp('>[ \t\r\n\v\f]*<', 'g');
				var tbhtml = $('#tblFrom').html();
				$('#tblFrom').html(tbhtml.replace(expr, '><'));
			}	
		}
		
	//}
</script>

