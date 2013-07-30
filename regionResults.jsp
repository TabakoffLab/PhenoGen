<script type="text/javascript">
var trackString="coding,noncoding,snp,smallnc";
var minCoord=<%=min%>;
var maxCoord=<%=max%>;
var chr="<%=chromosome%>";
var rnaDatasetID=<%=rnaDatasetID%>;
var arrayTypeID=<%=arrayTypeID%>;
var panel="<%=panel%>";
var forwardPValueCutoff=<%=forwardPValueCutoff%>;
var filterExpanded=0;
var tblBQTLAdjust=false;
var tblFromAdjust=false;

var organism="<%=myOrganism%>";
var ucsctype="region";
var ucscgeneID="";
</script>

<style>
	div#collaspableReport li{
	color:#000000;
	cursor:pointer;
	}
	div#collaspableReport li.selected{
		background-color:#CCCCCC;
	}
</style>

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
%>
    
    <script>
		var tisLen=<%=tissuesList1.length%>;
		var folderName="<%=folderName%>";
		
		/*$(".trigger").click(function(){
			var baseName = $(this).attr("name");
			$(this).toggleClass("less");
			expandCollapse(baseName);      
		});*/
		$('#inst').hide();
		$(document).on('click','.trigger',function(event){
			var baseName = $(this).attr("name");
			$(this).toggleClass("less");
			expandCollapse(baseName);
		});
		
		$(document).on('click','.helpImage', function(event){
			var id=$(this).attr('id');
			$('#'+id+'Content').dialog( "option", "position",{ my: "right top", at: "left bottom", of: $(this) });
			$('#'+id+'Content').dialog("open").css({'font-size':12});
		}
		);
		
		$(document).on('click','.legendBtn', function(event){
			$('#legendDialog').dialog( "option", "position",{ my: "left top", at: "left bottom", of: $(this) });
			$('#legendDialog').dialog("open");
		});
		
		
    </script>
<div id="page" style="min-height:1050px;text-align:center;">
	<div id="imageMenu"></div>
    <div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000; text-align:left; width:100%;">
    		<span class="trigger less" name="collapsableImage" >Genome Image</span>
    		<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div>
            
    		<!--<span style="font-size:12px; font-weight:normal; float:left;"><span class="legendBtn"><img title="Click to view the color key." src="../web/images/icons/legend_7.png"> <span style="position:relative;top:-7px;">Color Code Key</span> </span></span>-->
            <span style="font-size:12px; font-weight:normal; float:right;">
            	Saved Views:
                <select name="viewSelect" id="viewSelect">
                		<option value="0" >------Login to use saved views------</option>
                </select>
            </span>
    </div>
    
    <div style="border-color:#CCCCCC; border-width:1px; border-style:inset; text-align:center;">    
        <div id="collapsableImage" class="geneimage" >
       		<div id="imgLoad" style="display:none;"><img src="<%=imagesDir%>ucsc-loading.gif" /></div>
            <div id="geneImage" class="ucscImage"  style="display:inline-block;width:980px;">
            	<script src="javascript/GenomeReport0.1.js" type="text/javascript"></script>
				<script src="javascript/test.js" type="text/javascript"></script>
                <script type="text/javascript">
                    var gs=new GenomeSVG(".ucscImage",960,minCoord,maxCoord,0,chr,"gene");
                    svgList[0].addTrack("coding",3);
                    svgList[0].addTrack("noncoding",3);
                    svgList[0].addTrack("smallnc",3);
					
                    $( "ul, li" ).disableSelection();
                </script>
           </div>
        </div>
    </div><!--end Border Div -->
    <BR />
    
<script type="text/javascript">
  $('#legendDialog').dialog({
		autoOpen: false,
		dialogClass: "legendDialog",
		width: 350,
		height: 380,
		zIndex: 999
	});
  	
	
	/*$('.legendBtn').click( function(){
		$('#legendDialog').dialog( "option", "position",{ my: "left top", at: "left bottom", of: $(this) });
		$('#legendDialog').dialog("open");
	});*/
	
	/*$('.Imagetooltip').tooltipster({
		position: 'top-right',
		maxWidth: 250,
		offsetX: 24,
		offsetY: 5,
		//arrow: false,
		interactive: true,
   		interactiveTolerance: 350
	});*/
	
	
	/*$('.helpImage').click( function(event){
		var id=$(this).attr('id');
		$('#'+id+'Content').dialog( "option", "position",{ my: "right top", at: "left bottom", of: $(this) });
		$('#'+id+'Content').dialog("open").css({'font-size':12});
	});*/
</script>          

<div id="legendDialog"  title="UCSC Image/Table Rows Color Code Key" class="legendDialog" style="display:none">
                <%@ include file="/web/GeneCentric/legendBox.jsp" %>
    </div>
    <div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000; text-align:left; width:100%;">
    		<span class="trigger less" name="collapsableReport" >Region Summary</span>
    		<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div>
            
            
    </div>
    <div id="collaspableReport">
    	<div id="list" style=" text-align:left; border:thin;">
        <span style="color:#000000; font-weight:bold;">Track Information:</span>
    	<UL id="collaspableReportList">
        </UL>
        </div>
        <div id="content">
        </div>
    </div>
	

</div><!-- ends page div -->

<script type="text/javascript">
	setupExpandCollapse();
</script>


<%}else{%>
    	<div class="error"><%=genURL.get(selectedGene)%><BR />The administrator has been notified of the problem and will investigate the error.  We apologize for any inconvenience.</div><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR />
<%}%>
    
  






