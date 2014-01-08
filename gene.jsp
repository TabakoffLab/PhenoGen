<%@ include file="/web/common/anon_session_vars.jsp" %>

<%
	

	extrasList.add("detailedTranscriptInfo.js");
	extrasList.add("jquery.dataTables.js");
	extrasList.add("jquery.cookie.js");
	extrasList.add("fancyBox/jquery.fancybox.js");
	//extrasList.add("TableTools.min.js");
	//extrasList.add("ZeroClipboard.js");
	//extrasList.add("ColReorder.min.js");
	//extrasList.add("FixedColumns.min.js");
	extrasList.add("jquery.twosidedmultiselect.js");
	extrasList.add("d3.v3.min.js");
	extrasList.add("smoothness/jquery-ui-1.10.3.min.css");
	extrasList.add("tabs.css");
	extrasList.add("tsmsselect.css");
	extrasList.add("tooltipster.css");
	extrasList.add("jquery.fancybox.css");
	//extrasList.add("ColReorder.css");
	//extrasList.add("TableTools_JUI.css");
	//extrasList.add("TableTools.css");
%>
<style>
div.testToolTip {   
  position: absolute;           
  text-align: center;
  min-width: 100px;
  max-width: 400px;
  min-height:50px;                  
  /*height: 300px;   */              
  padding: 2px;             
  font: 12px sans-serif;        
  background: #d3d3d3;   
  border: 0px;      
  border-radius: 8px;           
  pointer-events: none;    
  color:#000000;
  text-align:left;     
}
/*table.tooltipTable{
	background:#d3d3d3;
}*/

table.tooltipTable TD{
	background:#d3d3d3;
	text-align:center;
}

.axis path{
	fill:none;
	stroke:black;
	shape-rendering: crispEdges;
}

.tick{
	fill:none;
	stroke: black;
}

.grid .tick {
    stroke: lightgrey;
    opacity: 0.7;
}
/*.grid path {
      stroke-width: 0;
}*/
	div#collapsableReport li{
	color:#000000;
	cursor:pointer;
	}
	div#collapsableReport li.selected{
		background-color:#CCCCCC;
	}
	/*div#collapsableReport td.layout {
		border:1px solid #CECECE;
	}*/
	span.detailMenu,span.selectdetailMenu,span.viewMenu{
		border-color:#CCCCCC;
		border:solid;
		border-width: 1px 1px 0px 1px;
		border-radius:5px 5px 0px 0px;
		padding-top:2px;
		padding-bottom:2px;
		padding-left:15px;
		padding-right:15px;
		cursor:pointer;
	}
	span.viewMenu{
		border-color:#000000;
	}
	span.detailMenu{
		background-color:#0b61A4;
		border-color:#000000;
		
	}
	span.detailMenu.selected{
		background-color:#3f92d2;
		/*background:#86C3E2;*/
		color:#FFFFFF;
	}
	span.detailMenu:hover{
		background-color:#3f92d2;
		/*background:#86C3E2;*/
		color:#FFFFFF;
	}
	
	span.selectdetailMenu{
		background-color:#00992D;
		border-color:#000000;
		color:#FFFFFF;
	}
	span.selectdetailMenu.selected{
		background:#47c647;
	}
	span.selectdetailMenu:hover{
		background:#47c647;
	}
	
	span.viewMenu{
		background:#AEAEAE;
		color:#000000;
	}
	span.viewMenu.selected{
		background:#DEDEDE;
		color:#000000;
	}
	span.viewMenu:hover{
		background:#DEDEDE;
		color:#000000;
	}
	
	.regionSubHeader{
		background:#86C3E2;
		color:#FFFFFF;
	}
	table.geneFilter TH {
		background:#86C3E2;
		color:#FFFFFF;
	}
	rect.selected{
		fill:#00FF00;
	}
	.geneReport TD{
		vertical-align:top;
		margin-top: 10px;
	}
	.geneReport TD.header{
		background-color:#67E667;
	}
</style>

<%
String myGene="";
String myDisplayGene="";
String defView="viewGenome";
boolean popup=false;
if(request.getParameter("geneTxt")!=null){
		myGene=request.getParameter("geneTxt").trim();
		myGene=myGene.replaceAll(",","");
}
if(request.getParameter("newWindow")!=null&&request.getParameter("newWindow").equals("Y")){
	popup=true;
}

if(request.getParameter("defaultView")!=null){
	defView=request.getParameter("defaultView");
}
pageTitle="Genome/Trascriptome Browser "+myGene;
pageDescription="Genome Browser provides a vizualization of Microarray and RNA-Seq data";
%>


<%if(popup){%>
<%@ include file="/web/common/header_noBorder_noMenu.jsp" %>
<%}else{%>
<%@ include file="/web/common/header_noBorder.jsp" %>
<%}%>

<jsp:useBean id="myIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"> </jsp:useBean>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>

<% 
	
	//GeneDataTools gdt=new GeneDataTools();
    gdt.setSession(session);
	
	String myOrganism="";
	ObjectHandler oh=new ObjectHandler();
	//Files generated by calling java method ().
	ArrayList<String> ucscURL=new ArrayList<String>();
	//ArrayList<String> ucscURLFiltered=new ArrayList<String>();
	ArrayList<String> genURL=new ArrayList<String>();
	ArrayList<String> geneSymbol=new ArrayList<String>();
	ArrayList<String> firstEnsemblID=new ArrayList<String>();
	ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> fullGeneList=new ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene>();
	
	String fullImg="";
	String fullOrg="";
	String filteredImg="";
	String panel="";
	String chromosome="";
	LinkGenerator lg=new LinkGenerator(session);
	
	boolean displayNoEnsembl=false;
	boolean auto=false;
	boolean region=false;
	
	double pValueCutoff=0.0001;
	double forwardPValueCutoff=0.01;
	
	int rnaDatasetID=0;
	int arrayTypeID=0;
	int selectedGene=0;
	int min=0;
	int max=0;
	String selectedEnsemblID="";
	String regionError="";
	
	Set iDecoderAnswer;
	
	if(( myGene.toLowerCase().startsWith("chr") || myGene.toLowerCase().startsWith("ch") )&&myGene.indexOf(":")>0){
		log.debug("myGene:"+myGene);
		region=true;
		if(myGene.indexOf("-")<0 && myGene.indexOf("+")<0){
			//log.debug(myGene.indexOf("-")+"::"+myGene.indexOf("+"));
			region=false;
			regionError="You have entered an invalid region.  Please see the examples in the instructions.";
		}
	}
	if(request.getParameter("speciesCB")!=null){
		myOrganism=request.getParameter("speciesCB").trim();
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
	
	if(request.getParameter("auto")!=null){
		String tmp=request.getParameter("auto");
		if(tmp.equals("Y")){
			auto=true;
		}
	}
	log.debug("Selected Gene="+request.getParameter("geneSelect"));
	if(request.getParameter("geneSelect")!=null && !(request.getParameter("geneSelect").equals("")) ){
		selectedEnsemblID=request.getParameter("geneSelect").trim();
		//selectedGene=Integer.parseInt(request.getParameter("geneSelect").trim());
		//log.debug("Selected Gene:"+selectedGene);
	}
	
	if(request.getParameter("pvalueCutoffInput")!=null){
		pValueCutoff=Double.parseDouble(request.getParameter("pvalueCutoffInput"));
	}
	if(request.getParameter("forwardPvalueCutoffInput")!=null){
		forwardPValueCutoff=Double.parseDouble(request.getParameter("forwardPvalueCutoffInput"));
	}
	
	log.debug("ACTION="+action+"  region="+region+"   gene="+myGene+"   rev. pvalue="+pValueCutoff+"  for Pval="+forwardPValueCutoff);
	
	/*if((action != null) && action.equals("Go")){
		response.redirect(lg.getGeneLink(curGene.getGeneID(),myOrganism,true,true,false));
	}else */
	if (    (((action != null) && action.equals("Get Transcription Details")) && (!region))  || (auto && (!region))
		) {
		myDisplayGene=myGene;
		mySessionHandler.createSessionActivity(session.getId(), "GTD Browser Gene: "+myGene, dbConn);
		List homologList=null;
		

		
			if(myGene.startsWith("ENSRNOG") ||myGene.startsWith("ENSMUSG")){
				myIDecoderClient.setNum_iterations(0);
			}else{
				myIDecoderClient.setNum_iterations(1);
			}
			iDecoderAnswer = myIDecoderClient.getIdentifiersByInputIDAndTarget(myGene,myOrganism, new String[] {"Ensembl ID"},dbConn);
			myIDecoderClient.setNum_iterations(1);

			List myIdentifierList=null;
	
			if(iDecoderAnswer!=null){
					myIdentifierList = Arrays.asList(iDecoderAnswer.toArray((Identifier[]) new Identifier[iDecoderAnswer.size()]));
					for(int i=0;i<myIdentifierList.size();i++){
						log.debug("ID LIST["+i+"]:"+((Identifier)myIdentifierList.get(i)).getIdentifier());
					}
					if(myIdentifierList!=null&&myIdentifierList.size()>0){
						Identifier thisIdentifier = (Identifier)myIdentifierList.get(0);
						HashMap linksHash = thisIdentifier.getTargetHashMap();
						Set homologSet = myIDecoderClient.getIdentifiersForTargetForOneID(linksHash, new String[] {"Ensembl ID"});
						log.debug("linksHash size:"+linksHash.size());
						homologList = myObjectHandler.getAsList(homologSet);
		
					}else{
						displayNoEnsembl=true;
					}
			}else{
				displayNoEnsembl=true;
			}
	
						if(homologList!=null&&homologList.size()>0){
								int[] tmp=gdt.getOrganismSpecificIdentifiers(myOrganism,dbConn);
								if(tmp!=null&&tmp.length==2){
									rnaDatasetID=tmp[1];
									arrayTypeID=tmp[0];
								}
								
								for (int i=0; i< homologList.size(); i++) {
									Identifier homologIdentifier = (Identifier) homologList.get(i);
									if(homologIdentifier.getIdentifier().indexOf("ENSMUSG")>-1||homologIdentifier.getIdentifier().indexOf("ENSRNOG")>-1){
										//myEnsemblIDs.add(homologIdentifier.getIdentifier());	
										log.debug("RUNNING GDT for "+homologIdentifier.getIdentifier());
										ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> tmpGeneList=gdt.getGeneCentricData(myGene,homologIdentifier.getIdentifier(),panel,myOrganism,rnaDatasetID,arrayTypeID,false);
										String tmpURL =gdt.getGenURL();//(String)session.getAttribute("genURL");
										String tmpGeneSymbol=gdt.getGeneSymbol();//(String)session.getAttribute("geneSymbol");
										log.debug(tmpURL+"\n"+tmpGeneSymbol);
										String tmpUcscURL =gdt.getUCSCURL();
										if(i==0){
											min=gdt.getMinCoord();
											max=gdt.getMaxCoord();
											chromosome=gdt.getChromosome();
											fullGeneList=tmpGeneList;
										}
										//(String)session.getAttribute("ucscURL");
										//String tmpUcscURLFiltered =gdt.getUCSCURLFiltered();//(String)session.getAttribute("ucscURLFiltered");
										
										if(tmpURL!=null){
											genURL.add(tmpURL);
											if(tmpGeneSymbol==null && !tmpURL.startsWith("ERROR:")){
												geneSymbol.add("");
											}else if(tmpURL.startsWith("ERROR:")){
												geneSymbol.add("ERROR GENERATING");
											}else{
												geneSymbol.add(tmpGeneSymbol);
											}
											
											if(tmpUcscURL==null){
												ucscURL.add("");
											}else{
												ucscURL.add(tmpUcscURL);
											}
											/*if(tmpUcscURLFiltered==null){
												ucscURLFiltered.add("");
											}else{
												ucscURLFiltered.add(tmpUcscURLFiltered);
											}*/
											firstEnsemblID.add(homologIdentifier.getIdentifier());
											if(tmpGeneSymbol!=null && tmpGeneSymbol.equals(myGene)){
												selectedGene=i;
												selectedEnsemblID=homologIdentifier.getIdentifier();
												min=gdt.getMinCoord();
												max=gdt.getMaxCoord();
												chromosome=gdt.getChromosome();
												fullGeneList=tmpGeneList;
											}
										}
									}
								}
								/*session.setAttribute("genURLArray",genURL);
								session.setAttribute("ucscURLArray",geneSymbol);
								session.setAttribute("geneSymbolArray",ucscURL);
								session.setAttribute("ucscURLFilteredArray",ucscURLFiltered);
								session.setAttribute("firstEnsemblIDArray",firstEnsemblID);*/
						}else{
								//gene="No Ensembl ID";
								//heat="No Ensembl ID";
								gdt.getGeneCentricData(myGene,"",panel,myOrganism,rnaDatasetID,arrayTypeID,false);
								displayNoEnsembl=true;
						}
					
	}else if((((action != null) && action.equals("Get Transcription Details"))&& region )
			|| ( auto && region )){
			mySessionHandler.createSessionActivity(session.getId(), "GTD Browser Region: "+myGene, dbConn);
		//log.debug("RUNNING REGION");
		int[] tmp=gdt.getOrganismSpecificIdentifiers(myOrganism,dbConn);
		if(tmp!=null&&tmp.length==2){
			rnaDatasetID=tmp[1];
			arrayTypeID=tmp[0];
		}
		
		String minCoord="";
		String maxCoord="";
		if(myGene.indexOf(":")>0){
			chromosome=myGene.substring(0,myGene.indexOf(":"));
			if(myGene.indexOf("+-")>0){
				minCoord=myGene.substring(myGene.indexOf(":")+1,myGene.indexOf("+-")).trim();
				maxCoord=myGene.substring(myGene.indexOf("+-")+2).trim();
				int tmpInt=Integer.parseInt(maxCoord.trim());
				min=Integer.parseInt(minCoord)-tmpInt;
				max=Integer.parseInt(minCoord)+tmpInt;
			}else if(myGene.indexOf("-+")>0){
				minCoord=myGene.substring(myGene.indexOf(":")+1,myGene.indexOf("-+")).trim();
				maxCoord=myGene.substring(myGene.indexOf("-+")+2).trim();
				int tmpInt=Integer.parseInt(maxCoord);
				min=Integer.parseInt(minCoord)-tmpInt;
				max=Integer.parseInt(minCoord)+tmpInt;
			}else if (myGene.indexOf("+")>0){
				minCoord=myGene.substring(myGene.indexOf(":")+1,myGene.indexOf("+")).trim();
				maxCoord=myGene.substring(myGene.indexOf("+")+1).trim();
				min=Integer.parseInt(minCoord);
				max=min+Integer.parseInt(maxCoord);
			}else if(myGene.indexOf("-")>0){
				minCoord=myGene.substring(myGene.indexOf(":")+1,myGene.indexOf("-")).trim();
				maxCoord=myGene.substring(myGene.indexOf("-")+1).trim();
				min=Integer.parseInt(minCoord);
				max=Integer.parseInt(maxCoord);
			}else{
				regionError="You have entered an invalid region.  Please see the examples in the instructions.";
			}
			String chrName="";
			if(chromosome.toLowerCase().startsWith("chr")){
				if(chromosome.length()>3){
					chrName=chromosome.substring(3);
				}
			}else if(chromosome.toLowerCase().startsWith("ch")){
				if(chromosome.length()>2){
					chrName=chromosome.substring(2);
				}
			}
			chrName=chrName.trim();
			chromosome="chr"+chrName;
			
			if(chrName.equals("")){
				regionError="You are missing the name of the chromosome you wish to view.  Example: chr1:50000-1000000";
			}else{
				int part=0;
				try{
					part=Integer.parseInt(chrName);
				}catch(NumberFormatException e){
				}
				if(chrName.toLowerCase().equals("x")||(part>0 && part<22)){
					
				}else{
					regionError="You have entered an invalid chromosome name.  For the supported species the chromosome should be 1-20 or 21 or X.  Example: chr1:50000-1000000";
				}
			}
			
			//log.debug("min:"+min+"\nmax:"+max);
			if(regionError.equals("")){
				if(min<max){
					if(min<1){
						min=1;
					}
					DecimalFormat df0 = new DecimalFormat("#,###");
					myDisplayGene=chromosome+":"+df0.format(min)+"-"+df0.format(max);
					fullGeneList =gdt.getRegionData(chromosome,min,max,panel,myOrganism,rnaDatasetID,arrayTypeID,forwardPValueCutoff,false);					
					String tmpURL =gdt.getGenURL();//(String)session.getAttribute("genURL");
					String tmpGeneSymbol=gdt.getGeneSymbol();//(String)session.getAttribute("geneSymbol");
					String tmpUcscURL =gdt.getUCSCURL();//(String)session.getAttribute("ucscURL");
					//String tmpUcscURLFiltered =gdt.getUCSCURLFiltered();//(String)session.getAttribute("ucscURLFiltered");
					if(tmpURL!=null){
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
						}
						/*if(tmpUcscURLFiltered==null){
							ucscURLFiltered.add("");
						}else{
							ucscURLFiltered.add(tmpUcscURLFiltered);
						}*/
					}
				}else{
					regionError="You have entered a SNP.  Please enter a range around the snp such as chr1:50000+5000  or chr1:50000+-2500";
				}
			}
		}
		
		
		
	}
	
	
	if((action != null) && !action.equals("Go") && genURL!=null && genURL.size()>0 && genURL.get(selectedGene)!=null && genURL.get(selectedGene).startsWith("ERROR:")){
		int newSelGene=-1;
		for(int i=0;i<genURL.size() && newSelGene==-1;i++){
			if(genURL.get(i)!=null && !genURL.get(i).startsWith("ERROR:")){
				newSelGene=i;
			}
		}
		if(newSelGene>-1){
			selectedGene=newSelGene;
		}
	}
	
	if(firstEnsemblID!=null && firstEnsemblID.size()>selectedGene){
		selectedEnsemblID=firstEnsemblID.get(selectedGene);
	}
	
	//convert ArrayLists into comma sep string for submitting with form
	//Needed to remove all session variable usage
	
	
	String genURLString=oh.getAsSeparatedString(genURL,",");
	String geneSymString=oh.getAsSeparatedString(geneSymbol,",");
	String ucscURLString=oh.getAsSeparatedString(ucscURL,",");
	//String ucscFilterURLString=oh.getAsSeparatedString(ucscURLFiltered,",");
	String firstENSString=oh.getAsSeparatedString(firstEnsemblID,",");
	
%>


<div id="oldIE" style="display:none;color:#FF0000;">
	This page requires IE 10+. Your browser appears to be an older version of Internet Explorer.  To use this feature please use a different browser(see <a href="<%=commonDir%>siteRequirements.jsp">Site Requirements</a>).  We are sorry for any inconvenience this may cause.  We're working hard to provide additional features which makes it difficult to maintain compatibility with all browsers.
</div>


<%if(popup){%>
<div style="text-align:center;">
	<span class="button" onclick="window.close()" style="width:150px;">Close this Window</span>
</div>
<%}%>

<div id="inst" style="text-align:left;color:#000000;margin-left:30px;">

                1. Enter a gene identifier(e.g. gene symbol, probe set ID, ensembl ID, etc.) in the gene field.<BR />
                or<BR />
                Enter a region such as
                	<div style="padding-left:20px;">
                    "chr1:1-50000" which would be Chromosome 1 @ bp 1-50,000.<BR />
                    "chr1:5000+-2000" which would be Chromosome 1 @ bp 3,000-7,000.<BR />
                    "chr1:5000+2000" which would be Chromosome 1 @ bp 5,000-7,000.<BR />
                    </div>
                or<BR />
                Click on the Translate Region to Mouse/Rat to find regions on the Mouse/Rat genome that correspond to a region of interest in the Human/Mouse/Rat genome.<BR />
                2. Choose a species.<BR />
                3. Click Get Transcription Details.<BR /><BR />
                <BR /><BR /><BR />
</div>



<div style="text-align:center">


<%if(genURL.size()>1){%>
                <label><span style="font-weight:bold;">Multiple genes were returned please select the gene of Interest:</span>
                <select name="geneSelectCBX" id="geneSelectCBX" >
                    <%for(int i=0;i<firstEnsemblID.size();i++){
                        %>
                        <option value="<%=firstEnsemblID.get(i)%>" <%if((geneSymbol.get(i)!=null&&geneSymbol.get(i).toLowerCase().equals(myGene.toLowerCase()))){%>selected<%}%>>
                                                <%if(geneSymbol.get(i)!=null&&!geneSymbol.get(i).startsWith("ERROR")){%>
                                                        <%=geneSymbol.get(i)%> (<%=firstEnsemblID.get(i)%>) 
                                                <%}else if(geneSymbol.get(i).startsWith("ERROR")){%>
                                <%=geneSymbol.get(i)%> (<%=firstEnsemblID.get(i)%>) 
                                                <%}else{%>
                                                        <%=firstEnsemblID.get(i)%>
                                                <%}%>
                                                
                        </option>
                    <%}%>
                </select>
                </label>
            
            <input type="submit" name="action" id="selGeneBTN" value="Go" onClick="enterSelectedGene()"><BR />
            Hint: Try other synonyms if the first ID that you enter is not found.
            <BR /><BR />
<%}%>


<form method="post" 
		action="gene.jsp"
		enctype="application/x-www-form-urlencoded"
		name="geneCentricForm" id="geneCentricForm">
        <%if(!regionError.equals("")){%>
        	<div style=" color:#FF0000;"><%=regionError%></div>
        <%}%>
    	<label>Gene Identifier or Region:
  		<input type="text" name="geneTxt" id="geneTxt" size="35" value="<%= (myDisplayGene!=null)?myDisplayGene:"" %>">
  		</label>
        
       
  <label>Species:
  <select name="speciesCB" id="speciesCB">
  	<option value="Mm" <%if(myOrganism!=null && myOrganism.equals("Mm")){%>selected<%}%>>Mus musculus</option>
    <option value="Rn" <%if(myOrganism!=null && myOrganism.equals("Rn")){%>selected<%}%>>Rattus norvegicus</option>
  </select>
  </label>
  
  <label>Initial View:
  <select name="defaultView" id="defaultView">
  	<option value="viewGenome" <%if(defView.equals("viewGenome")){%>selected<%}%>>Genome</option>
    <option value="viewTrxome" <%if(defView.equals("viewTrxome")){%>selected<%}%>>Transcriptome</option>
    <option value="viewAll" <%if(defView.equals("viewAll")){%>selected<%}%>>Both</option>
  </select>
  </label>
  <span style="padding-left:10px;"> <input type="submit" name="goBTN" id="goBTN" value="Go" onClick="return displayWorking()">
 <!--<span style="padding-left:40px;"> <input type="submit" name="genomeBTN" id="getGenomeBTN" value="View Genome Features" onClick="return displayWorking('viewGenome')"></span>
 <span style="padding-left:40px;"> <input type="submit" name="transcriptomeBTN" id="getTrxBTN" value="View Transcriptome Features" onClick="return displayWorking('viewTrxome')"></span>-->
 
 	<input type="hidden" name="pvalueCutoffInput" id="pvalueCutoffInput" value="<%=pValueCutoff%>" />
    <input type="hidden" name="forwardPvalueCutoffInput" id="forwardPvalueCutoffInput" value="<%=forwardPValueCutoff%>" />
    <input type="hidden" name="tissues" id="tissues" value="" />
    <input type="hidden" name="chromosomes" id="chromosomes" value="" />
    <input type="hidden" name="levels" id="levels" value="" />
    <input type="hidden" name="action" id="action" value="Get Transcription Details" />
  	<input type="hidden" name="genURLArray" id="genURLArray" value="<%=genURLString%>" />
    <input type="hidden" name="geneSymArray" id="geneSymArray" value="<%=geneSymString%>" />
    <input type="hidden" name="ucscURLArray" id="ucscURLArray" value="<%=ucscURLString%>" />
    <input type="hidden" name="firstENSArray" id="firstENSArray" value="<%=firstENSString%>" />
    <input type="hidden" name="geneSelect" id="geneSelect" value="<%=selectedGene%>" />
    <!--<input type="hidden" name="defaultView" id="defaultView" value="<%=defView%>" />-->
</form>
<BR />
Or
<input type="button" name="translateBTN" id="translateBTN" value="Translate Region to Mouse/Rat" onClick="openTranslateRegion()"> 
</div>


<!--<script type="text/javascript" src="http://www.java.com/js/deployJava.js"></script>-->



<div class="translate">
</div>

<script type="text/javascript">
	document.getElementById("wait1").style.display = 'none';
	var translateDialog = createDialog(".translate" , {width: 700, height: 820, title: "Translate Region", zIndex: 500});
	function openTranslateRegion(){
		$('.demo').hide();
		var region=$('#geneTxt').val();
		var species=$('#speciesCB').val();
		$.get(	contextPath + "/web/GeneCentric/translateRegion.jsp", 
				{region:region, species: species},
				function(data){
                    				translateDialog.dialog("open").html(data);
									closeDialog(translateDialog);
                				}
			);
	}
	if (/MSIE (\d+\.\d+);/.test(navigator.userAgent)){ //test for MSIE x.x;
 		var ieversion=new Number(RegExp.$1) // capture x.x portion and store as a number
		if (ieversion<10){
			$("#oldIE").show();
		}
	}
</script>


<%if(genURL.size()==1){%>
	

	<%@ include file="regionResults.jsp" %>
    <%@ include file="web/GeneCentric/resultsHelp.jsp" %>


<%}else{%>

	<%if(displayNoEnsembl){ %>
    	Hint: Try other synonyms if the first ID that you enter is not found.
            <BR /><BR />
        <BR /><div class="error">ERROR:No Ensembl ID found for the ID entered.<BR /><BR />
        The Gene ID entered could not be translated to an Ensembl ID to retrieve gene information.  Please try an alternate identifier for this gene.  This gene ID has been reported to improve the translation of many Gene IDs to Ensembl Gene IDs.  <BR /><BR /><b>Note:</b> At this time if there is no annotation in Ensembl for a gene we will not be able to display information about it, however if you have found your gene of interest on Ensembl entering the Ensembl Gene ID, which begins with ENSRNOG or ENSMUSG, should work.</div><BR /><BR />
        <BR />
         
	<% }%>

	
	<div class="demo" style="width:100%;text-align:center;">
    	<table style="width:100%;text-align:center;">
        <TR>
        	<TD colspan="2" style="text-align:center;"><h2>Demonstrations</h2></TD>
        </TR>
        <TR>
        <TD style="text-align:center;">
        	<h2>Quick Navigation Demonstration</h2>
            <BR />
            <video width="400" height="270" controls="controls">
            <source src="<%=contextRoot%>web/demo/BrowserNavDemo.mp4" type="video/mp4">
            <source src="<%=contextRoot%>web/demo/BrowserNavDemo.webm" type="video/webm">
            <object data="<%=contextRoot%>web/demo/BrowserNavDemo.mp4" width="400" height="270">
                          </object>
            </video>
        </TD>
        <TD style="text-align:center;">
                        <h2>Detailed Transcription Information Demonstration</h2><BR />
						<video width="400" height="325" controls="controls">
                    		<source src="<%=contextRoot%>web/demo/detailed_transcript_fullv3.mp4" type="video/mp4">
                            <source src="<%=contextRoot%>web/demo/detailed_transcript_fullv3.webm" type="video/webm">
                          <object data="<%=contextRoot%>web/demo/detailed_transcript_fullv3.mp4" width="400" height="325">
                          </object>
                        </video>
       </TD>
       </TR>
       </table>
	</div>
<%}%>

<%if(popup){%>
	<div style="text-align:center;">
	<span class="button" onclick="window.close()" style="width:150px;">Close this Window</span>
    </div>
<%}%>

<%@ include file="/web/common/footer.jsp" %>





