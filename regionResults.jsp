<script type="text/javascript">
var trackString="coding,noncoding,snp,smallnc";
var minCoord=<%=min%>;
var maxCoord=<%=max%>;
var chr="<%=chromosome%>";
var filterExpanded=0;
var tblBQTLAdjust=false;
var tblFromAdjust=false;

var organism="<%=myOrganism%>";
var ucsctype="region";
var ucscgeneID="";


</script>


<%if(genURL.get(0)!=null && !genURL.get(0).startsWith("ERROR:")){%>


<%
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
	
	String tmpURL=genURL.get(0);
	int second=tmpURL.lastIndexOf("/",tmpURL.length()-2);
	String folderName=tmpURL.substring(second+1,tmpURL.length()-1);
	DecimalFormat dfC = new DecimalFormat("#,###");
	
	
	
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
%>
    
    <script>
		var tisLen=<%=tissuesList1.length%>;
    </script>
<div id="page" style="min-height:1050px;text-align:center;">

        <!--<div class="geneRegionControl">
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
          </div>--><!--end RegionControl div -->
    <div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000;text-align:center; width:100%;">
    	<span class="triggerImage less" name="collapsableImage" >UCSC Genome Browser Image</span>
    	<div class="inpageHelp" style="display:inline-block;"><img id="Help2" class="helpImage" src="../web/images/icons/help.png" /></div>
        <span style="font-size:12px; font-weight:normal;">
        <input name="imageSizeCbx" type="checkbox" id="imageSizeCbx" checked="checked" /> Scroll Image - Viewable Size:
        <select name="imageSizeSelect" id="imageSizeSelect">
        		<option value="200" >Smaller</option>
            	<option value="400" selected="selected">Normal</option>
                <option value="600" >Larger</option>
                <option value="800" >Largest</option>
            </select>
        </span>
    </div>
    <div style="border-color:#CCCCCC; border-width:1px; border-style:inset; text-align:center;">
        
        <div id="collapsableImage" class="geneimage" >
       		<div id="imgLoad" style="display:none;"><img src="<%=imagesDir%>ucsc-loading.gif" /></div>
            <div id="geneImage" class="ucscImage"  style="display:inline-block; height:400px; width:980px; overflow:auto;">
            	<a class="fancybox fancybox.iframe" href="<%=ucscURL.get(0)%>" title="UCSC Genome Browser">
            	<img src="<%= contextRoot+"tmpData/regionData/"+folderName+"/ucsc.coding.noncoding.smallnc.png"%>"/></a>
            </div>
        </div><!-- end geneimage div -->
    	<div class="geneimageControl">
      		
          	<form>
            <table style="text-align:left; width:100%;">
            	<TR><TD colspan="4">
            Image Tracks/Table Filter:<div class="inpageHelp" style="display:inline-block; margin-left:10px;"><img id="Help1" class="helpImage" src="../web/images/icons/help.png" /></div>
            </TD>
            </TR>
            <TR><TD>
            <input name="trackcbx" type="checkbox" id="codingCBX" value="coding" checked="checked" /> Protein Coding/PolyA+
            <select name="trackSelect" id="codingSelect">
            	<option value="1" >Dense</option>
                <option value="3" selected="selected">Pack</option>
                <option value="2" >full</option>
            </select>
            </TD>
            <TD>
            <input name="trackcbx" type="checkbox" id="noncodingCBX" value="noncoding" checked="checked" />Long Non-Coding/NonPolyA+
            <select name="trackSelect" id="noncodingSelect">
            	<option value="1" >Dense</option>
                <option value="3" selected="selected">Pack</option>
                <option value="2" >full</option>
            </select>
            </TD>
            <TD>
            <input name="trackcbx" type="checkbox" id="smallncCBX" value="smallnc" checked="checked" /> Small RNA 
            <select name="trackSelect" id="smallncSelect">
            	<option value="1" >Dense</option>
                <option value="3" selected="selected">Pack</option>
                <option value="2" >full</option>
            </select>
            </TD>
            <TD></TD>
            </TR>
           	<TR>
            <TD>
           	<input name="trackcbx" type="checkbox" id="snpCBX" value="snp" /> SNPs/Indels:
             <select name="trackSelect" id="snpSelect">
            	<option value="1" selected="selected">Dense</option>
                <option value="3" >Pack</option>
            </select>
            </TD>
            <TD>
            <input name="trackcbx" type="checkbox" id="helicosCBX" value="helicos" /> Helicos Data:
            <select name="trackSelect" id="helicosSelect">
            	<option value="1" selected="selected">Dense</option>
                <option value="2" >full</option>
            </select>
            </TD>
            <TD>
            <input name="trackcbx" type="checkbox" id="bqtlCBX" value="qtl" /> bQTLs
            </TD>
            <TD>
            <input name="trackcbx" type="checkbox" id="refseqCBX" value="refseq" /> RefSeq Transcripts
            </TD>
            </TR>
            </table>
              <!--<label style="color:#000000; margin-left:10px;">
                Transcripts:</label>
                <select name="transcriptSelect" id="transcriptSelect">
                	<option value="geneimageUnfiltered" selected="selected">Hide</option>
                    <option value="geneimageFiltered" >Show</option>
                </select>-->
              <!--<label style="color:#000000; margin-left:10px;">Additional Track options:</label>
             	<select name="lowerTrackSelect" id="lowerTrackSelect">
                	<option value="NoArray">None</option>
                    <option value="Array" selected="selected">UCSC/Affymetrix Tissue Expression Data(Source:UCSC)</option>
                    <option value="Human">Human Proteins/Chr Mapping(Source:UCSC)</option>
                </select>-->
                
             </form>
         
		 
          </div><!--end imageControl div -->
    </div><!--end Border Div -->
    <BR />
<script type="text/javascript">
	
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
</script>          

<div class="cssTab" id="mainTab" >
    <ul>
      <li ><a id="geneTabID" href="#geneList" title="What genes are found in this area?">Features Physically Located in Region</a><div class="inpageHelp" style="float:right;position: relative; top: -53px; left:-2px;"><img id="Help3" class="helpImage" src="../web/images/icons/help.png" /></div></li>
      <li ><a id="bqtlTabID" class="disable" href="#bQTLList" title="What bQTLs occur in this area?">bQTLs<BR />Overlapping Region</a><div class="inpageHelp" style="float:right;position: relative; top: -53px; left:-2px;"><img id="Help7" class="helpImage" src="../web/images/icons/help.png" /></div></li>
      <li><a  id="eqtlTabID" class="disable" href="#eQTLListFromRegion" title="What does this region control?">Transcripts Controlled from Region(eQTLs)</a><div class="inpageHelp" style="float:right;position: relative; top: -53px; left:-2px;"><img id="Help10" class="helpImage" src="../web/images/icons/help.png" /></div></li>
     </ul>
     
     
<div id="loadingRegion"  style="text-align:center; position:relative; top:0px; left:0px;"><img src="<%=imagesDir%>wait.gif" alt="Loading..." /><BR />Loading Region Data...<BR />The tabs to the left will be enabled once all the data loads.</div>

<div id="changingTabs"  style="display:none;text-align:center; position:relative; top:0px; left:-150px;"><img src="<%=imagesDir%>wait.gif" alt="Changing Tabs..." /><BR />Changing Tabs...</div>


<div id="geneList" class="modalTabContent" style=" display:none; position:relative;top:56px;border-color:#CCCCCC; border-width:1px 0px 0px 0px; border-style:inset;width:1000px;">

                <table class="geneFilter">
                	<thead>
                    	<TR>
                    	<TH style="width:50%"><span class="trigger" id="geneListFilter1" name="geneListFilter" style=" position:relative;text-align:left; z-index:100;">Filter List</span></TH>
                        <TH style="width:50%"><span class="trigger" id="geneListFilter2" name="geneListFilter" style=" position:relative;text-align:left; z-index:100;">View Columns</span></TH>
                        <div class="inpageHelp" style="display:inline-block; position:relative;float:right; z-index:999; top:4px; left:-3px;"><img id="Help4" class="helpImage" src="../web/images/icons/help.png" /></div>
                        </TR>
                        
                    </thead>
                	<tbody id="geneListFilter" style="display:none;">
                    	<TR>
                        	<td>
                            <%if(myOrganism.equals("Rn")){%>
                                Exclude single exon RNA-Seq Transcripts
                            	<input name="chkbox" type="checkbox" id="exclude1Exon" value="exclude1Exon" /><BR />
                        	<%}%>
                        
                            eQTL P-Value Cut-off:
                                             <select name="pvalueCutoffSelect1" id="pvalueCutoffSelect1">
                                            		<option value="0.1" <%if(forwardPValueCutoff==0.1){%>selected<%}%>>0.1</option>
                                                    <option value="0.01" <%if(forwardPValueCutoff==0.01){%>selected<%}%>>0.01</option>
                                                    <option value="0.001" <%if(forwardPValueCutoff==0.001){%>selected<%}%>>0.001</option>
                                                    <option value="0.0001" <%if(forwardPValueCutoff==0.0001){%>selected<%}%>>0.0001</option>
                                                    <option value="0.00001" <%if(forwardPValueCutoff==0.00001){%>selected<%}%>>0.00001</option>
                                            </select>
                                            Require an eQTL below cut-off<input name="chkbox" type="checkbox" id="rqQTLCBX" value="rqQTLCBX"/>
                            </td>
                        	<td>
                            	<div class="columnLeft">
                                	Gene ID
                                    <input name="chkbox" type="checkbox" id="geneIDCBX" value="geneIDCBX" checked="checked" /><BR />
                                    Description
                                    <input name="chkbox" type="checkbox" id="geneDescCBX" value="geneDescCBX" checked="checked" /><BR />
                                    BioType
                                    <input name="chkbox" type="checkbox" id="geneBioTypeCBX" value="geneBioTypeCBX" checked="checked" /><BR />
                                    Tracks
                                    <input name="chkbox" type="checkbox" id="geneTracksCBX" value="geneTracksCBX" checked="checked" /><BR />
                                    Location and Strand
                                    <input name="chkbox" type="checkbox" id="geneLocCBX" value="geneLocCBX" checked="checked" /><BR />
                                   
                                </div>
                                <div class="columnRight">
                                 	Heritability
                                    <input name="chkbox" type="checkbox" id="heritCBX" value="heritCBX" checked="checked" /><BR />
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
                        <th colspan="11" class="topLine noSort noBox"></th>
                        <th colspan="4" class="center noSort topLine">Transcript Information</th>
                        <th colspan="<%=5+tissuesList1.length*2+tissuesList2.length*2%>"  class="center noSort topLine" title="Dataset is available by going to Microarray Analysis Tools -> Analyze Precompiled Dataset or Downloads.">Affy Exon 1.0 ST PhenoGen Public Dataset(
							<%if(myOrganism.equals("Mm")){%>
                            	Public ILSXISS RI Mice
                            <%}else{%>
                            	Public HXB/BXH RI Rats (Tissue, Exon Arrays)
                            <%}%>
                            )<div class="inpageHelp" style="display:inline-block; "><img id="Help5b" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                    </tr>
                    <tr style="text-align:center;">
                        <th colspan="11"  class="topLine noSort noBox"></th>
                        <th colspan="1"  class="leftBorder rightBorder noSort"></th>
                        <th colspan="2"  class="leftBorder rightBorder topLine noSort">RNA-Seq<div class="inpageHelp" style="display:inline-block;"><img id="Help5a" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                        <th colspan="1"  class="leftBorder rightBorder noSort"></th>
                        <th colspan="1"  class="leftBorder rightBorder noSort"></th>
                        <th colspan="<%=tissuesList1.length%>"  class="center noSort topLine">Probesets > 0.33 Heritability<div class="inpageHelp" style="display:inline-block; "><img id="Help5c" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                        <th colspan="<%=tissuesList1.length%>" class="center noSort topLine">Probesets > 1% DABG<div class="inpageHelp" style="display:inline-block; "><img id="Help5d" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                        <th colspan="<%=3+tissuesList2.length*2%>" class="center noSort topLine" title="eQTLs at the Gene Level.  These are calculated for Transcript Clusters which are Gene Level and not individual transcripts.">eQTLs(Gene/Transcript Cluster ID)<div class="inpageHelp" style="display:inline-block; "><img id="Help5e" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                    </tr>
                    <tr style="text-align:center;">
                        <th colspan="5"  class="topLine noSort noBox"></th>
                        <th colspan="3"  class="topLine leftBorder rightBorder noSort" title="The tracks in the image above that are represented in this table.  Each item is in one of the 4 tracks.">Image Tracks Represented in Table</th>
                        <th colspan="3"  class="topLine noSort noBox"></th>
                        <th colspan="2"  class="topLine leftBorder rightBorder noSort"># Transcripts</th>
                        <th colspan="1"  class="leftBorder rightBorder noSort"></th>
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
                    <TH>Image ID (Transcript/Feature ID)</TH>
                    <TH>Gene Symbol<BR />(click for detailed transcription view)</TH>
                    <TH>Gene ID</TH>
                    <TH width="10%">Gene Description</TH>
                    <TH>BioType</TH>
                    <TH>Protein Coding / PolyA+</TH>
                    <TH>Long Non-Coding / Non PolyA+</TH>
                    <TH>Small RNA</TH>
                    <TH>Location</TH>
                    <TH>Strand</TH>
                    <TH title="SNPs and Indels that fall in an exon of at least one transcript." >Exon SNPs / Indels</TH>
                    <TH>Ensembl</TH>
                    <TH>RNA-Seq</TH>
                    <TH>Total Reads<HR />Read Sequences</TH>
                    <TH>View Details</TH>
                    <TH>Total Probesets</TH>
                    
                    <%for(int i=0;i<tissuesList1.length;i++){%>
                    	<TH><%=tissuesList1[i]%> Count<HR />(Avg)</TH>
                    <%}%>
                    <%for(int i=0;i<tissuesList1.length;i++){%>
                    	<TH><%=tissuesList1[i]%> Count<HR />(Avg)</TH>
                    <%}%>
                    <TH>Transcript Cluster ID <div class="inpageHelp" style="display:inline-block; "><img id="Help5f" class="helpImage" src="../web/images/icons/help.png" /></div></TH>
                    <TH>Annotation Level</TH>
                    <TH>View Genome-Wide Associations<div class="inpageHelp" style="display:inline-block; "><img id="Help5g" class="helpImage" src="../web/images/icons/help.png" /></div></TH>
                    <%for(int i=0;i<tissuesList2.length;i++){%>
                    	<TH>Total # Locations P-Value < <%=forwardPValueCutoff%> </TH>
                        <TH>Minimum<BR /> P-Value<HR />Location</TH>
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
						if(curGene.getBioType().equals("protein_coding")){%>
                        	coding
						<%}else{
							if(curGene.getLength()>=350){
								viewClass="longRNA";%>
                        		noncoding
                            <%}else{
								viewClass="smallRNA";%>
                            	smallnc
                            <%}%>
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
									String tmpTitle="Based on detection in PolyA+";
									if(!bioType.equals("protein_coding")){
										tmpTitle="Based on detection in Non-PolyA+";
									}%>
                                	<span title="<%=tmpTitle%>">
                                	<%=bioType%>*
                                    </span>
                                <%}else{%>
									<%=bioType%>
                            	<%}%>
                            </TD>
                            <%if(bioType.equals("protein_coding")){%>
                                <TD class="leftBorder">X</TD>
                                <TD class="leftBorder"></TD>
                                <TD class="leftBorder rightBorder"></TD>
                            <%}else{
								if(curGene.getLength()>=350){%>
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
                            <TD>
                            	<%if(curGene.getSnpCount("common","SNP")>0 || curGene.getSnpCount("common","Indel")>0 ){%>
                            		Common: <%=curGene.getSnpCount("common","SNP")%> / <%=curGene.getSnpCount("common","Indel")%><BR />
                                <%}%>
                            	<%if(curGene.getSnpCount("BNLX","SNP")>0 || curGene.getSnpCount("BNLX","Indel")>0 ){%>
                            		BNLX: <%=curGene.getSnpCount("BNLX","SNP")%> / <%=curGene.getSnpCount("BNLX","Indel")%><BR />
                                <%}%>
                                <%if(curGene.getSnpCount("SHRH","SNP")>0 || curGene.getSnpCount("SHRH","Indel")>0){%>
                                	SHRH: <%=curGene.getSnpCount("SHRH","SNP")%> / <%=curGene.getSnpCount("SHRH","Indel")%>
                                <%}%>
                            </TD>
                            <TD class="leftBorder"><%=curGene.getTranscriptCountEns()%></TD>
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
                                <TD><span title="<350bp includes Coding and Non-Coding RNA">Small RNA*</span></TD>
                                <TD class="leftBorder"></TD>
                                <TD class="leftBorder"></TD>
                                <TD class="leftBorder rightBorder">X</TD>
                                <TD>chr<%=rna.getChromosome()+":"+dfC.format(rna.getStart())+"-"+dfC.format(rna.getStop())%></TD>
                                <TD><%=rna.getStrand()%></TD>
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
                                <TD class="leftBorder"></TD>
                                <TD></TD>

                                
                                <TD>
									<%=rna.getTotalReads()%><BR />
									<%=rna.getSeq().size()%><BR />
                                    <span id="<%=rna.getNumberID()+":"+rna.getID()%>" class="viewSMNC">View RNA-Seq</span>
                                </TD>
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
	})
	
	var tblGenes=$('#tblGenes').dataTable({
	"bPaginate": false,
	"bProcessing": true,
	"bStateSave": true,
	"bAutoWidth": true,
	"sScrollX": "950px",
	"sScrollY": "650px",
	"aaSorting": [[ 5, "desc" ]],
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
			displayColumns(tblGenes, 16,tisLen,$('#heritCBX').is(":checked"));
	  });
	  $('#dabgCBX').click( function(){
			displayColumns(tblGenes, 16+tisLen,tisLen,$('#dabgCBX').is(":checked"));
	  });
	  $('#eqtlAllCBX').click( function(){
			displayColumns(tblGenes, 16+tisLen*2,tisLen*2+3,$('#eqtlAllCBX').is(":checked"));
	  });
		$('#eqtlCBX').click( function(){
			displayColumns(tblGenes, 16+tisLen*2+3,tisLen*2,$('#eqtlCBX').is(":checked"));
	  });
	  
	   $('#geneIDCBX').click( function(){
			displayColumns(tblGenes,2,1,$('#geneIDCBX').is(":checked"));
	  });
	  $('#geneDescCBX').click( function(){
			displayColumns($(tblGenes).dataTable(),3,1,$('#geneDescCBX').is(":checked"));
	  });
	  
	  $('#geneBioTypeCBX').click( function(){
			displayColumns($(tblGenes).dataTable(),4,1,$('#geneBioTypeCBX').is(":checked"));
	  });
	  $('#geneTracksCBX').click( function(){
			displayColumns($(tblGenes).dataTable(),5,3,$('#geneTracksCBX').is(":checked"));
	  });
	  
	  $('#geneLocCBX').click( function(){
			displayColumns($(tblGenes).dataTable(),8,2,$('#geneLocCBX').is(":checked"));
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
			if(type=="coding" || type=="noncoding" || type=="smallnc"){
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
	
	
	 
</script>



<div id="bQTLList" class="modalTabContent" style="display:none; position:relative;top:56px;border-color:#CCCCCC; border-width:1px 0px 0px 0px; border-style:inset;width:100%;">
	
	<table class="geneFilter">
                	<thead>
                    	<TH style="width:50%"><span class="trigger" id="bqtlListFilter1" name="bqtlListFilter" style=" position:relative;text-align:left; z-index:100;">Filter List</span></TH>
                        <TH style="width:50%"><span class="trigger" id="bqtlListFilter2" name="bqtlListFilter" style=" position:relative;text-align:left; z-index:100;">View Columns</span></TH>
                        <div class="inpageHelp" style="display:inline-block; position:relative;float:right; z-index:999;top:4px; left:-3px;"><img id="Help6" class="helpImage" src="../web/images/icons/help.png" /></div>
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
	if(session.getAttribute("getBQTLsERROR")==null){
		if(bqtls.size()>0){
		//log.debug("BQTLS >0 ");
	%>
    
	<TABLE name="items" id="tblBQTL" class="list_base" cellpadding="0" cellspacing="0">
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
                        <TH>bQTL Region</TH>
                        <TH>Region Determination Method<div class="inpageHelp" style="display:inline-block; "><img id="Help8" class="helpImage" src="../web/images/icons/help.png" /></div></TH>
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
								String regionQTL=gdt.getBQTLRegionFromSymbol(relQTL.get(j),myOrganism,dbConn);
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
				if(!tblBQTLAdjust){
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
</script>



<div id="eQTLListFromRegion" class="modalTabContent" style=" display:none; position:relative;top:56px;border-color:#CCCCCC; border-width:1px 0px 0px 0px; border-style:inset;width:100%;">
		
        
		<table class="geneFilter">
                	<thead>
                    	<TH style="width:65%;"><span class="trigger" id="fromListFilter1" name="fromListFilter" style="position:relative;text-align:left; z-index:100;">Filter List and Circos Plot</span></TH>
                        <TH><span class="trigger" id="fromListFilter2" name="fromListFilter" style="position:relative;text-align:left; z-index:100;">View Columns</span></TH>
                        <div class="inpageHelp" style="display:inline-block; position:relative;float:right; z-index:100;top:4px; left:-3px;"><img id="Help9" class="helpImage" src="../web/images/icons/help.png" /></div>
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
                                                    <option value="0.01" <%if(pValueCutoff==0.01){%>selected<%}%>>0.01</option>
                                                    <option value="0.001" <%if(pValueCutoff==0.001){%>selected<%}%>>0.001</option>
                                                    <option value="0.0001" <%if(pValueCutoff==0.0001){%>selected<%}%>>0.0001</option>
                                                    <option value="0.00001" <%if(pValueCutoff==0.00001){%>selected<%}%>>0.00001</option>
                                            </select>
                                            
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
<% ArrayList<TranscriptCluster> transOutQTLs=gdt.getTransControllingEQTLs(min,max,chromosome,arrayTypeID,pValueCutoff,"All",myOrganism,tissueString,chromosomeString);//this region controls what genes
		ArrayList<String> eQTLRegions=gdt.getEQTLRegions();
        if(session.getAttribute("getTransControllingEQTL")==null){%>
            <div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000;text-align:center; width:100%; position:relative; top:-71px"><span class="trigger less" name="eQTLRegionNote" >EQTL Region</span></div>
            <div id="eQTLRegionNote" style="width:100%; position:relative; top:-71px">
            Genes controlled from and P-values reported for eQTLs from this region are not specific to the region you entered. The "P-value from region" columns correspond to the folowing region(s):<BR />
            <%for(int i=0;i<eQTLRegions.size();i++){%>
                <a href="<%=request.getContextPath()%>/gene.jsp?geneTxt=<%=eQTLRegions.get(i)%>&speciesCB=<%=myOrganism%>&auto=Y&newWindow=Y" target="_blank"><%=eQTLRegions.get(i)%></a><BR />
            <%}%>
            So the genes listed below could be controled from anywhere in the region(s) above.
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
		String svgPdfFile= shortRegionCentricPath + "/circos"+cutoffTimesTen+"/svg/circos_new.pdf";
	%>
                  
   	<div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000;text-align:center; width:100%;top:-62px; position:relative;">
    	<span class="trigger less" name="circosPlot" >Gene Location Circos Plot</span>
    	<div class="inpageHelp" style="display:inline-block;"><img id="Help11" class="helpImage" src="../web/images/icons/help.png" /></div>
        <span style="font-size:12px; font-weight:normal;">
        Adjust Vertical Viewable Size:
        <select name="circosSizeSelect" id="circosSizeSelect">
        		<option value="200" >Smallest</option>
            	<option value="475" >Half</option>
                <option value="950" selected="selected">Full</option>
                <option value="1000" >Maximized</option>
            </select>
        </span>
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
	<%}%>
		
		<%if(transOutQTLs!=null && transOutQTLs.size()>0){
			//if(transOutQTLs.size()<=300){
			String idList="";
			int idListCount=0;
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
				if(include&&tissueInclude){
					if(i==0){
						idList=tc.getTranscriptClusterID();
					}else{
						idList=idList+","+tc.getTranscriptClusterID();
					}
					idListCount++;
				}
			}
			if(idListCount<=300){%>
       			<div style=" float:right; position:relative; top:10px;"><a href="http://david.abcc.ncifcrf.gov/api.jsp?type=AFFYMETRIX_EXON_GENE_ID&ids=<%=idList%>&tool=summary" target="_blank">View DAVID Functional Annotation</a><div class="inpageHelp" style="display:inline-block;"><img id="Help14" class="helpImage" src="../web/images/icons/help.png" /></div></div>
        	<%}else{%>
            	<div style=" float:right; position:relative; top:10px;">Too many genes to submit to DAVID automatically. Filter or copy and submit on your own.<div class="inpageHelp" style="display:inline-block;"><img id="Help14" class="helpImage" src="../web/images/icons/help.png" /></div></div>
            <%}%>	
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
                            )<div class="inpageHelp" style="display:inline-block;"><img id="Help12c" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                    </tr>
               		 <tr>
                        <th colspan="3" class="topLine noSort noBox"></th>
                        <th colspan="4" class="leftBorder noSort noBox"></th>
                        <%for(int i=0;i<tissuesList2.length;i++){%>
                        	<th colspan="2" class="center noSort topLine">Tissue:<%=tissuesList2[i]%></th>
                        <%}%>
                    </tr>
                	<TR class="col_title">
                   		<TH>Gene Symbol<BR />(click for detailed transcription view)</TH>
                    	<TH>Gene ID</TH>
                    	
                        <TH>Description</TH>
                        <TH>Transcript Cluster ID<div class="inpageHelp" style="display:inline-block;"><img id="Help12a" class="helpImage" src="../web/images/icons/help.png" /></div></TH>
                        <TH>Annotation Level<div class="inpageHelp" style="display:inline-block;"><img id="Help12b" class="helpImage" src="../web/images/icons/help.png" /></div></TH>
                        <TH>Physical Location</TH> 
                        <TH>View Genome-Wide Associations<div class="inpageHelp" style="display:inline-block;"><img id="Help5g" class="helpImage" src="../web/images/icons/help.png" /></div></TH>
                    	<%for(int i=0;i<tissuesList2.length;i++){%>
                            <TH title="Highlighted indicates a value less than or equal to the cutoff.">P-Value from region</TH>
                            <TH title="Click on View Location Plot to see all locations below the cutoff."># other locations P-value<<%=pValueCutoff%></TH>
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
                            <TD ><a href="<%=lg.getGeneLink(tc.getGeneID(),myOrganism,true,true,false)%>" target="_blank" title="View Detailed Transcription Information for gene.">
							<%if(tc.getGeneSymbol().equals("")){%>
								No Gene Symbol
							<%}else{%>
								<%=tc.getGeneSymbol()%>
                            <%}%>
                            </a></TD>
                            
                            <TD ><a href="<%=LinkGenerator.getEnsemblLinkEnsemblID(tc.getGeneID(),fullOrg)%>" target="_blank" title="View Ensembl Gene Details"><%=tc.getGeneID()%></a><BR />	
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
                                        
                                        <%if(regEQTL==null){%>
											<TD class="leftBorder">>0.3</TD>
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
      <%}else{%>
      No genes to display.  Try changing the filtering parameters.
					<%}%>
     <%}else{%>
     	<strong><%=session.getAttribute("getTransControllingEQTL")%></strong>
     <%}%>
</div><!-- end eQTL List-->
</div><!--end MainTab-->
</div><!-- ends page div -->



<%}else{%>
    	<div class="error"><%=genURL.get(selectedGene)%><BR />The administrator has been notified of the problem and will investigate the error.  We apologize for any inconvenience.</div><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR />
<%}%>
    
    
<div id="Help1Content" class="inpageHelpContent" title="<center>Help-Image Controls</center>"><div class="help-content">
<H3>UCSC Image Controls</H3>
The controls above the UCSC image allow you to modify the information displayed in the image.<BR /><BR />
<ol style="padding-left:25px; list-style-type:upper-alpha;">
<li> The first control toggles the transcript data track, which contains Ensembl transcripts(Brown: IDs begin with ENS) and in rat also contains reconstructed transcripts from RNA-Seq of Whole Brain( Blue: multi-exon transcripts, Black: single exon transcripts, IDs begin with the tissue they are from, followed by a unique gene ID)<BR />
	<p>RNA-Seq Transcriptome Information<BR>
		Transcripts were reconstructed from sequencing BN-Lx and SHRH parental strains using CuffLinks software. The raw read data is available for download in the Downloads section under RNA Sequencing BED/SAM Data Files.</p><BR />
</li>
<li> The second control selects the track displayed on the lower part of the image.  There are three options:<BR />
	<ol style="padding-left:35px; list-style-type:decimal;">
    <li> None, which hides all the lower tracks.</li>
	<li> UCSC/Affymetrix Tissue Expression Data, which displays the Affy Exon tissue data provided by UCSC and Affymetrix.</li>
	<li> Human Chromosome/Protein Mappings, which displays the general regions of the current organism that map to a chromosome in the human genome based on the chromosome color key below the image. In mouse, the lower track includes homologous proteins in Humans.</li>
    </ul>
</li><BR />

</div></div>

<div id="Help2Content" class="inpageHelpContent" title="<center>Help-UCSC Image</center>"><div class="help-content">
<H3>UCSC Image</H3>
The image that displays is generated by the UCSC Genome Browser, which displays different information in different lines moving horizontally across the image.
<BR />
This image was constructed based on data from PhenoGen and UCSC and has multiple tracks, not all of which can be displayed simultaneously.  Although some tracks not marked as optional are always displayed.
<BR />
Starting at the top:<BR />
<ul style=" padding-left:25px; list-style:circle;">
<li>Track 1(Optional, Default: Hidden) Transcripts
This track contains Ensembl transcripts(Brown, ID begins with ENS) and in rat also contains reconstructed transcripts from RNA-Seq of Whole Brain( Blue – multi-exon transcripts, Black - single exon transcripts, begin with the tissue they are from, followed by a unique gene ID)</li><BR />
<li>Track 2-<a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTLs</a>
		Behavioral Quantitative Trait Loci.  This track shows the <a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTLs</a> located in the region entered.  bQTLs indicate that some feature in this region is statistically associated with the observed Phenotype or Behavior.  For additional details about the phenotypes, click the bQTLs tab below the image to view the detailed table with a complete list of  <a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTLs</a>.</li><BR />
<li>Track 3- RefSeq Genes
		This track shows the Ref-Seq annotated genes in the region, with the highest level of confidence. The tables in the tabs below may display additional genes from Ensembl that do not show up in this track.</li><BR />
<li>Track 4(Optional, Default: Displayed) Affy Exon Array Expression Levels
		This track shows the data generated by Affymetrix/UCSC generated data for multiple tissues.  It povides a quick view of where a gene might be expressed. More detailed data for the tissues available on PhenoGen displays in the tables below or when you select a particular gene to view Detailed Transcription Information.</li><BR />
<li>Track 5(Optional, Default: Hidden) Human Chromosome Mapping
		This track along with the color coded image below, shows the human chromosomes to which a region might correspond.  In mouse, this also shows a Ref-Seq-like track(track#3) with human gene identifiers listed.</li>
</ul>

</div></div>

<div id="Help3Content" class="inpageHelpContent" title="<center>Help-Gene in Region Tab</center>"><div class="help-content">
<H3>Gene Physically Located in Region Tab</H3>
This tab will display all the Ensembl genes located in the chosen region, as well as any RNA-Seq genes that do not correspond to an Ensembl gene.<BR /><BR />
Data Summary:<BR /><BR />
<ol style=" list-style-type:decimal; padding-left:25px;">
<li>Gene Information(Ensembl ID, Gene Symbol, Location, description, # transcripts, # transcripts from RNA-Seq)</li>
	<span style="margin-left:35px;">Click on a Gene Symbol to view detailed transcript and probe set data for a particular gene.</span><BR /><BR />
<li>Probe Set detail (# Probe Sets, # whose expression is heritable(allows you to focus on expression differences controlled by genetics),# detected above background(DABG),(Avg % of samples DABG).</li><BR />
<li>Transcript Cluster Expression Quantitative Trait Loci (at the gene level)\   At the gene level, this indicates regions of the genome that are statistically associated with expression of the gene.  The table displays the p-value and location with the minimum p-value for each tissue available.  Click the view location plot link to view all of the locations across tissues.
</li>
</ol>
</div></div>

<div id="Help4Content" class="inpageHelpContent" title="<center>Help-Filter List/View Columns</center>"><div class="help-content">
<H3>Filter List/View Columns</H3>
Click on the + sign beside Filter List or View Coloumns to change the table display.<BR /><BR />
You can filter the table based on:<BR />
<ol style="list-style-type:decimal; padding-left:25px;">
	<li>eQTL P-value cut-off: This changes the number of locations and possibly will remove or add to the number of minimum p-value locations, but does not filter the list of genes in the region.</li><BR />
	<li>Single Exon RNA-Seq transcripts: This either displays or hides all the RNA-Seq transcripts that are a single exon.</li><BR />
	<li>Search text in the table: Provides a text-based search of every column in the table.  For example, to view a single gene start entering the symbol into the text box.  The table is filtered as you type.  If you eliminate everything begin deleting a character at a time, and rows will display.  You might also use this to find proteins that have a particular keyword in the description.</li>
</ol>
</div></div>

<div id="Help5aContent" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>RNA-Seq Column</H3>
This column displays the number of transcripts reconstructed from the RNA-Seq data that match to this gene.  Click the gene symbol to view a more detailed view of the transcription information for just that gene.
</div></div>

<div id="Help5bContent" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>Affy Exon Data Columns</H3>
The Affy Exon PhenoGen data displays data calculated from public datasets.  For mouse, data is from the Public ILSXISS RI Mice
For rat, data is from 4 datasets(one per tissue)Public HXB/BXH RI Rats (Tissue, Exon Arrays)<BR /><BR />

These datasets are available for analysis or downloading.  To perform an analysis on PhenoGen go to Mircoarray Analysis Tools -> Analyze precompiled datasets. A free login is required, which allows you to save your progress and come back after lengthy processing steps.  <BR /><BR />

Columns:<BR />
<ul style="padding-left:25px; list-style-type:square;">
	<li>Total number of non-masked probe sets</li><BR /> 
	<li>Number with a heritability of >0.33 (Avg heritability for probesets >0.33)</li><BR />
	<li>Number detected above background (DABG) (Avg % of samples DABG)</li><BR />
	<li>Transcript Cluster ID corresponding to the gene with Annotation level</li><BR />
	<li>Circos Plot to show all <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> across tissues.</li><BR />
	<li>eQTL for the transcript cluster in each tissue</li>
    	<ul style="padding-left:35px; list-style-type:disc;">
    	<li>minimum P-value and location</li>
		<li>total locations with a P-value < cut-off</li>
        </ul>
        </li>
</ul>

</div></div>

<div id="Help5cContent" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>Heritablity</H3>
For each probe set on the Affymetrix Exon 1.0 ST Array (mouse or rat), we calculated a broad-sense heritability using an ANOVA model and expression data from the ILSXISS panel (mouse) or the HXB/BXH panel (rat).  The heritability threshold of 0.33 was chosen arbitrarily to represent an expression estimate with at least modest heritability. In the rat, we include the number of probesets at least modestly heritable in the four available tissues (brain, heart, liver, and brown adipose).   Higher heritability indicates that expression of a probe set is influenced more by genetics than unknown environmental factors.
</div></div>

<div id="Help5dContent" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>Detection Above Background(DABG)</H3>
For each probe set on the Affymetrix Exon 1.0 ST Array (mouse or rat) and each sample, we calculated a p-value associated with the expression of the probe set above background (DABG – detection above background).  Using a p-value threshold of 0.0001, we calculated the proportion of samples from the ILSXISS panel (mouse) or HXB/BXH panel (rat) that had expression values significantly different from background for a given probeset.  In the table, we report the number of probesets whose expression values were detected above background in more than 1% of samples and the average percentage of samples where the probesets were detected above background.
</div></div>

<div id="Help5eContent" class="inpageHelpContent" title="<center>Help-eQTLs</center>"><div class="help-content">
<H3>eQTLs</H3>
The eQTL columns provide a general idea of where a gene, in the region you have entered, is controlled from.  Currently, <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> are currently only available at the gene (transcript cluster) level instead of the probe set level, which means the first columns give you information about the transcript cluster.  <BR /><BR />

Columns:<BR />
	Transcript Cluster ID- The unique ID assigned by Affymetrix.  <BR />
	Location-The chromosomes and base-pair coordinates where the gene is located. <BR />
	Annotation level- Related to the confidence in the gene.  Core is the highest confidence.  This level tends to correspond very closely with the Ensembl gene annotation. Extended is lower confidence and may include additional regions outside of the Ensembl annotated exons.  Full is even lower confidence and includes additional regions beyond the Ensembl annotations.<BR />
	Genome Wide Associations- A way to view all the locations with a P-value below the cutoff selected.  Circos is used to create a plot of each region in each tissue associated with expression of the gene selected.<BR />
<BR />
Tissue Columns<BR />
	These columns summarize the data for each tissue.<BR />
	Total # of locations with a P-value < (Selected Cutoff)- The number of locations associated with expression below a cutoff selected in the Filter List section above the table.<BR />
	Minimum P-Value Location- The P-value and location of the minimum P-Value for the given tissue.  P-Value is in black, above the location in blue.  Click the location to open a Detailed Transcription Information window for that location.<BR />

</div></div>

<div id="Help5fContent" class="inpageHelpContent" title="<center>Help-Transcript Cluster ID</center>"><div class="help-content">
<H3>Transcript Cluster ID</H3>
Transcript Cluster ID- The unique ID assigned by Affymetrix.  <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> are calculated for this annotation at the gene level by combining probe set data across the gene.
</div></div>

<div id="Help5gContent" class="inpageHelpContent" title="<center>Help-Genome Wide Associations</center>"><div class="help-content">
<H3>Genome Wide Associations</H3>
Genome Wide Associations- Shows all the locations with a P-value below the cutoff selected.  Circos is used to create a plot of each region in each tissue associated with expression of the gene selected.
</div></div>

<div id="Help6Content" class="inpageHelpContent" title="<center>Help-Filter/Display-bQTLs</center>"><div class="help-content">
<H3>Filter List/View Columns</H3>
For this section you may only filter based on text in the table.  To search for a keyword, start typing, and results are filtered based on your entry.<BR />
For the View Columns section you may choose which columns are displayed.<BR /><BR />The options to view/hide are:<BR />
<ul style=" padding-left:25px; list-style-type:square;">
	<li><a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTL</a> Symbol-Looks much like a gene symbol, but has been assigned to a bQTL by RGD or MGI.</li>
	<li>Trait Method-A description of the method used to measure a particular phenotype.</li>
	<li>Phenotype- A description or phrase to describe the characteristics measured.</li>
	<li>Diseases-Diseases associated with the phenotype.</li>
	<li>References-Both Pubmed and RGD/MGI-curated references related to the <a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTL</a>.</li>
	<li>Associated bQTLs-<a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTLs</a> that are related to the displayed <a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTL</a>.</li>
	<li>Location Method-A brief description of the method used to determine the location of the <a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTL</a>.</li>
    	<ul style="padding-left:35px; list-style-type:disc;">
			<li> by peak only</li>
			<li> by peak w adj size</li>
			<li> by one flank and peak markers</li>
			<li> by one flank marker only</li>
			<li> by flanking markers</li>
			<li> imported from external source</li>
        </ul>
    </li>
	<li>LOD Score/P-value-When available(many are not reported directly by RGD/MGI) indicates the level of confidence the region contributes to the Phenotype.  Higher LOD Scores/Lower P-values indicate higher confidence in the association.</li>
</ul>

</div></div>

<div id="Help7Content" class="inpageHelpContent" title="<center>Help-bQTL Tab</center>"><div class="help-content">
<H3><a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTL</a> Tab</H3>
	The <a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTL</a> tab allows you to view <a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTLs</a> that overlap with the region.  <BR /><BR />
What is a bQTL?(<a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">View detailed bQTL information</a>) 
	A Behavioral Quantitative Trait Loci or bQTL is a region that is associated with a particular phenotype or behavior (thus <a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTL</a>).  <BR /><BR />
How is it calculated?
	<a href="<%=commonDir%>definitions.jsp#bQTLs" target="_blank">bQTLs</a> can be found for Recombinant Inbred Panels by measuring a trait/behavior across strains in the panel and then correlating the values to the genotype of each strain between markers.  Based on that correlation regions can be found that are correlated with a particular phenotype.  These are the regions listed in the table under this tab.  They may indicate that a gene or other feature is somehow influencing the phenotype.

</div></div>

<div id="Help8Content" class="inpageHelpContent" title="<center>Help-Region Determination Method</center>"><div class="help-content">
<H3>Region Determination Method</H3>
This column is the method used to determine the location.<BR />
	- by peak only<BR />
	- by peak w adj size<BR />
	- by one flank and peak markers<BR />
	- by one flank marker only<BR />
	- by flanking markers<BR />
	- imported from external source<BR />
</div></div>

<div id="Help9Content" class="inpageHelpContent" title="<center>Help-Filter/View Columns-eQTLs</center>"><div class="help-content">
<H3>Filter Circos Plot and Table/View Columns</H3><BR />
Filter Circos Plot/Table<BR />
You may filter the Ciros plot and table by tissues, <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> P-value, and chromosome.  Change the parameters by which you want to filter and click Run Filter.<BR />
<ul style=" padding-left:25px; list-style-type:square;">
	<li>eQTL P-value- The cutoff to limit genes displayed to those that have a P-value for the selected region less than, or equal to, the cutoff.</li>
	<li>Tissues(Rat Only)- Move tissues to the excluded column to keep only genes that have significant <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> in one of the included tissues.</li>
	<li>Chromosomes- Move chromosomes to exclude into the Exclude column to filter out genes that are located on that chromosome.</li>
</ul>
<BR /><BR />
View Columns<BR />
Use the checkboxes below View Columns to show and hide columns.<br />
<ul style="padding-left:25px; list-style-type:square;">
	<li>Gene ID- The Ensembl gene ID that links directly to Ensembl.</li>
	<li>Description- The Ensembl description of the gene.</li>
	<li>Transcript ID and Annot.- The Transcript Cluster ID and Annotation Level, which is the Affymetrix transcript cluster that corresponds to the gene and the level of confidence.</li>.
	<li>All Tissues P-values- Controls the P-values from the region column, across tissues.</li>
	<li>All Tissues # Locations- Controls the # other locations column across all tissues.</li>
	<li>Specific Tissues- Controls both columns for a specific tissue.</li>
</ul>

</div></div>

<div id="Help10Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>eQTL Tab</H3>
This tab shows the genes that might be controlled by a feature in the choosen region.  There is at least an <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> with a P-value below the cutoff in the highlighted(Blue) for the selected region in one or more tissues.  However, the actual region may just overlap with the current region, so the <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> region associated with the P-value may be a different than the current region. 
<BR />
The Circos plot shows where the genes with <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> in this region are physically located.  
<BR />
The table below the Circos plot lists all the genes and <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> for each gene in each tissue.  Use the View Location Plot link to view all the <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> for a gene in a Circos plot that shows each <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> for the selected gene.
<BR />
Finally, to view detailed transcript and probe set data, click on a Gene Symbol to display a summary specific to that gene.
<BR /><BR />
What is an eQTL? (<a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">View detailed eQTL information</a>)   
An eQTL is a region that is correlated across recombinant inbred strains to expression of a gene(or in the case of our Affy data displayed, Transcript Cluster) or probeset.  This may indicate some feature in this region is influencing expression of the gene with a significant <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> in the region.
<BR /><BR />
How is it calculated? 
<a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> can be found for Recombinant Inbred Panels by measuring expression across strains in the panel and then correlating the values to the genotype of each strain between markers.  Based on that correlation, regions can be found that are correlated with expression.   In the table, the region overlaps with one of the regions that is assigned a P-value below the cutoff you selected.  This may indicate that a gene or other feature in this region, or one of the other regions with a significant P-value, is somehow influencing the expression of the gene.
<BR /><BR />
What does an <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> for a transcript cluster mean? 
At the transcript cluster level, this is an <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> for a gene and not individual probe sets.  For now, this is the only level available.

</div></div>

<div id="Help11Content" class="inpageHelpContent" title="<center>Help-Circos eQTL Plot</center>"><div class="help-content">
<H3>Circos Plot eQTL Gene Locations</H3>
This plot shows all of the genes that have an <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> in the region entered.  These genes correspond to the genes listed in the table below.  If a higher number of genes are located in nearly the same region only the first 2-3 may be displayed.
<BR /><BR />
The plot can be hidden using the +/- button.  The size of the plot can also be controlled using the button next to the directions.
<BR /><BR />
When your mouse is inside the border below, you can zoom in/out on the plot.  When your mouse is outside the border you can scroll normally.  The controls inside the image can be used to zoom in and out and reset the image.  You can also click-and-drag to reposition the image.
<BR /><BR />
You can download a PDF of the image by clicking on the download icon(<img src="web/images/icons/download_g.png">).
<BR /><BR />
You can reduce or restore the verticle space used for the graphic by clicking on the <img src="web/images/icons/circos_min.jpg"> or <img src="web/images/icons/circos_max.jpg"> icons.
</div></div>

<div id="Help12aContent" class="inpageHelpContent" title="<center>Help-Transcript Cluster ID</center>"><div class="help-content">
<H3>Transcript Cluster ID</H3>
Transcript Cluster ID- The unique ID assigned by Affymetrix.  <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> are calculated for this annotation at the gene level by combining probe set data across the gene.
</div></div>


<div id="Help12bContent" class="inpageHelpContent" title="<center>Help-Annotation Level</center>"><div class="help-content">
<H3>Annotation level</H3>
Annotation level- Related to the confidence in the gene.  Core is the highest confidence and tends to correspond very closely with the Ensembl gene annotation. Extended is lower confidence and may include additional regions outside of the Ensembl annotated exons.  Full is even lower and includes additional regions beyond the Ensembl annotations.
</div></div>

<div id="Help12cContent" class="inpageHelpContent" title="<center>Help-Affy Exon Data</center>"><div class="help-content">
<H3>Affy Exon Data-eQTLs</H3>
The Affy Exon PhenoGen data displays data calculated from public datasets.  For mouse, data is from the Public ILSXISS RI Mice
For rat, data is from four datasets(one per tissue)Public HXB/BXH RI Rats (Tissue, Exon Arrays).
<BR /><BR />
These datasets are available for analysis or downloading.  To perform an analysis on PhenoGen go to Mircoarray Analysis Tools -> Analyze precompiled datasets.  A free login is required, which allows you to save your progress and come back after lengthy processing steps.  
<BR /><BR />
Columns:<BR />
<ul style="list-style-type:square; padding-left:25px;">
	<li>Transcript Cluster ID- The unique Affymetrix-assigned id that corresponds to a gene. </li>
	<li>Annotation Level- Confidence in the transcript cluster annotation</li>
	<li>Circos Plot- Shows all <a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTLs</a> for a specific gene across tissues.</li>
	<li><a href="<%=commonDir%>definitions.jsp#eQTLs" target="_blank">eQTL</a> for the transcript cluster in each tissue</li>
		<ul style="list-style-type:disc; padding-left:35px;">
		<li>P-value from this region</li>
		<li>total other locations with a P-value < cut-off</li>
        </ul>
</ul>
</div></div>

<div id="Help13Content" class="inpageHelpContent" title="<center>Help</center>">
<div class="help-content">
<H3>Human Chromosome Color Key</H3>
The human/Net and Human/Chain tracks displayed indicate which chromosome in Humans maps to a particular colored region in the image.  This will only help to identify the chromosome where a gene that aligns to a particular color might reside.  In Mouse this also adds Human proteins that are homologous to the proteins in this region and by comparing the human homologs to the alignment track it is possible to see the chromosome that gene is on.  To better be able to zoom and manipulate the image you may always click on the image to open the UCSC Genome Browser which will enable you to zoom in/out and shift the region more easily to look at a gene/region of interest.
</div></div>

<div id="Help14Content" class="inpageHelpContent" title="<center>Help</center>">
<div class="help-content">
<H3>DAVID</H3>
A list of genes can be imported into the DAVID website for additional information about function and also to look for a significant enrichment in pathways, which might imply some biological meaning.  The link, when available, will open the summany page where you can explore the different DAVID tools.
<BR /><BR />
Currently only lists of 300 genes are less are supported.  This is a limit of the method used to submit genes to the DAVID website.  We will either be replacing the site or supporting a different method to allow longer lists.  If you perform filtering to get the list below 300 you will be able to click a link and immediately analyze data on the site, Otherwise you can copy one of the ID columns such as Gene IDs(Ensembl IDs) and submit them on your own.
</div></div>




<script type="text/javascript">
$(document).ready(function() {
	
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
	
	//Setup Help links
	$('.inpageHelpContent').hide();
	
	$('.inpageHelpContent').dialog({ 
  		autoOpen: false,
		dialogClass: "helpDialog",
		width: 400,
		maxHeight: 500,
		zIndex: 9999
	});
	
	
	$(".multiselect").twosidedmultiselect();
    //var selectedChromosomes = $("#chromosomesMS")[0].options;
	
	
	document.getElementById("loadingRegion").style.display = 'none';
	
	
	
	
	
	var tblFrom=$('#tblFrom').dataTable({
	"bPaginate": false,
	"bProcessing": true,
	"sScrollX": "950px",
	"sScrollY": "650px",
	"bDeferRender": true,
	"sDom": '<"leftSearch"fr><t>'
	});
	
	
	$('#eqtlTabID').click(function() {    
			$('div#changingTabs').show(10);
				//change the tab
				$('#mainTab ul li a').removeClass('selected');
				$(this).addClass('selected');
				var currentTab = $(this).attr('href'); 
				$('#mainTab div.modalTabContent').hide();       
				$(currentTab).show();
				//adjust row and column widths if needed(only needs to be done once)
				if(!tblFromAdjust){
						tblFrom.fnAdjustColumnSizing();
						tblFromAdjust=true;
					}
					setFilterTableStatus("fromListFilter");
				
			$('div#changingTabs').hide(10);
			return false;
        });
	
	
	

	
	
	
	$('.helpImage').click( function(event){
		var id=$(this).attr('id');
		$('#'+id+'Content').dialog( "option", "position",{ my: "right top", at: "left bottom", of: $(this) });
		$('#'+id+'Content').dialog("open").css({'font-size':12});
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
	
	
	//setupExpandCollapseTable();
	/*$("span[name='bqtlListFilter']").click(function(){
		var baseName = $(this).attr("name");
        expandCollapse(baseName);
	});
	$("span[name='fromListFilter']").click(function(){
		var baseName = $(this).attr("name");
        expandCollapse(baseName);
	});*/
	
	$(".trigger").click(function(){
		var baseName = $(this).attr("name");
		$(this).toggleClass("less");
        expandCollapse(baseName);      
	});
	
	setupExpandCollapse();
	//var tableRows = getRows();
	//hoverRows(tableRows);
	$('#circosSizeSelect').change( function(){
			var size=$(this).val();
			$('#circosIFrame').attr("height",size);
			if(size<=950){
				$('#circosIFrame').attr("width",950);
			}else{
				$('#circosIFrame').attr("width",size-2);
			}
	});
	/*$('#circosMinMax').click(function(){
		if($('#circosIFrame').attr("height")>400){
			$('> img',this).attr("src","web/images/icons/circos_max.jpg");
			$('#circosIFrame').attr("height",400);
			$('#circosIFrame').attr("width",950);
		}else{
			$('> img',this).attr("src","web/images/icons/circos_min.jpg");
			$('#circosIFrame').attr("height",950);
			$('#circosIFrame').attr("width",950);
		}
	});*/
	
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
	
}); // end ready

</script>





