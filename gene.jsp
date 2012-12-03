<%@ include file="/web/common/session_vars.jsp" %>

<%
	extrasList.add("fancyBox/jquery.fancybox.js");
	extrasList.add("jquery.dataTables.js");
	extrasList.add("FixedColumns.min.js");
	extrasList.add("jquery.twosidedmultiselect.js");
	
	extrasList.add("jquery.fancybox.css");
	extrasList.add("tabs.css");
	extrasList.add("tsmsselect.css");
%>
<%
String myGene="";
String myDisplayGene="";
boolean popup=false;
if(request.getParameter("geneTxt")!=null){
		myGene=request.getParameter("geneTxt").trim();
		myGene=myGene.replaceAll(",","");
}
if(request.getParameter("newWindow")!=null&&request.getParameter("newWindow").equals("Y")){
	popup=true;
}
pageTitle="Detailed Transcription Information "+myGene;%>


<%if(popup){%>
<%@ include file="/web/common/header_noBorder_noMenu.jsp" %>
<%}else{%>
<%@ include file="/web/common/header_noBorder.jsp" %>
<%}%>
<jsp:useBean id="myIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"> </jsp:useBean>

<% 

	GeneDataTools gdt=new GeneDataTools();
    gdt.setSession(session);
	
	String myOrganism="";
	ObjectHandler oh=new ObjectHandler();
	//Files generated by calling java method ().
	ArrayList<String> ucscURL=new ArrayList<String>();
	ArrayList<String> ucscURLFiltered=new ArrayList<String>();
	ArrayList<String> genURL=new ArrayList<String>();
	ArrayList<String> geneSymbol=new ArrayList<String>();
	ArrayList<String> firstEnsemblID=new ArrayList<String>();
	ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> fullGeneList=new ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene>();
	
	String fullImg="";
	String fullOrg="";
	String filteredImg="";
	String panel="";
	String chromosome="";
	
	boolean displayNoEnsembl=false;
	boolean auto=false;
	boolean region=false;
	
	double pValueCutoff=0.001;
	double forwardPValueCutoff=0.01;
	
	int rnaDatasetID=0;
	int arrayTypeID=0;
	int selectedGene=0;
	int min=0;
	int max=0;
	String selectedEnsemblID="";
	String regionError="";
	
	Set iDecoderAnswer;
	
	if(( myGene.toLowerCase().startsWith("chr") )&&myGene.indexOf(":")>0){
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
	
	if(request.getParameter("auto")!=null){
		String tmp=request.getParameter("auto");
		if(tmp.equals("Y")){
			auto=true;
		}
	}
	if(request.getParameter("geneSelect")!=null){
		selectedGene=Integer.parseInt(request.getParameter("geneSelect").trim());
	}
	
	if(request.getParameter("pvalueCutoffInput")!=null){
		pValueCutoff=Double.parseDouble(request.getParameter("pvalueCutoffInput"));
	}
	if(request.getParameter("forwardPvalueCutoffInput")!=null){
		forwardPValueCutoff=Double.parseDouble(request.getParameter("forwardPvalueCutoffInput"));
	}
	
	log.debug("ACTION="+action+"  region="+region+"   gene="+myGene+"   rev. pvalue="+pValueCutoff+"  for Pval="+forwardPValueCutoff);
	
	if (    (((action != null) && action.equals("Get Transcription Details"))&&(!region))
			|| (auto&&(!region))
		) {
		myDisplayGene=myGene;
		mySessionHandler.createSessionActivity(session.getId(), "Ran Transcription Details on "+myGene, dbConn);
		myIDecoderClient.setNum_iterations(2);
		iDecoderAnswer = myIDecoderClient.getIdentifiersByInputIDAndTarget(myGene,myOrganism, new String[] {"Ensembl ID"},dbConn);
		myIDecoderClient.setNum_iterations(1);
		/*session.setAttribute("iDecoderAnswer", iDecoderAnswer);
		session.setAttribute("genURL",null);
		session.setAttribute("ucscURL",null);
		session.setAttribute("geneSymbol",null);
		session.setAttribute("ucscURLFiltered",null);
		session.setAttribute("firstEnsemblID",null);
		session.setAttribute("genURLArray",null);
		session.setAttribute("ucscURLArray",null);
		session.setAttribute("geneSymbolArray",null);
		session.setAttribute("ucscURLFilteredArray",null);
		session.setAttribute("firstEnsemblIDArray",null);*/
        List myIdentifierList=null;
        //ArrayList<String> myEnsemblIDs=new ArrayList<String>();
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
					List homologList = myObjectHandler.getAsList(homologSet);
	
					/*for (int i=0; i< homologList.size(); i++) {
						Identifier homologIdentifier = (Identifier) homologList.get(i);
						if(homologIdentifier.getIdentifier().indexOf("T0")!=6){
							myEnsemblIDs.add(homologIdentifier.getIdentifier());
							if(ident.equals("")){
								ident=homologIdentifier.getIdentifier();
								firstEnsemblID=ident;
							}else{
								ident=ident+","+homologIdentifier.getIdentifier();
							}
							log.debug("IDENT:"+i+":"+ident);
	
						}
					}*/
					if(homologList.size()>0){
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
									gdt.getGeneCentricData(myGene,homologIdentifier.getIdentifier(),panel,myOrganism,rnaDatasetID,arrayTypeID);
									
									String tmpURL =gdt.getGenURL();//(String)session.getAttribute("genURL");
									String tmpGeneSymbol=gdt.getGeneSymbol();//(String)session.getAttribute("geneSymbol");
									String tmpUcscURL =gdt.getUCSCURL();//(String)session.getAttribute("ucscURL");
									String tmpUcscURLFiltered =gdt.getUCSCURLFiltered();//(String)session.getAttribute("ucscURLFiltered");
									
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
										if(tmpUcscURLFiltered==null){
											ucscURLFiltered.add("");
										}else{
											ucscURLFiltered.add(tmpUcscURLFiltered);
										}
										firstEnsemblID.add(homologIdentifier.getIdentifier());
										if(tmpGeneSymbol!=null && tmpGeneSymbol.equals(myGene)){
											selectedGene=i;
											selectedEnsemblID=homologIdentifier.getIdentifier();
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
							gdt.getGeneCentricData(myGene,"",panel,myOrganism,rnaDatasetID,arrayTypeID);
							displayNoEnsembl=true;
					}

            	}else{
					displayNoEnsembl=true;
				}
        }else{
			displayNoEnsembl=true;
		}
	}else if (((action != null) && action.equals("Go"))) {
		//iDecoderAnswer=(Set)session.getAttribute("iDecoderAnswer");
		//List myIdentifierList=null;
        //ArrayList<String> myEnsemblIDs=new ArrayList<String>();
		if(request.getParameter("genURLArray")!=null){
			String[] tmpgenURL=request.getParameter("genURLArray").trim().split(",");
			String[] tmpGeneSym=request.getParameter("geneSymArray").trim().split(",");
			String[] tmpURL=request.getParameter("ucscURLArray").trim().split(",");
			String[] tmpFilterURL=request.getParameter("ucscFilterURLArray").trim().split(",");
			String[] tmpFirstENS=request.getParameter("firstENSArray").trim().split(",");
			genURL=oh.getAsArrayList(tmpgenURL);
			geneSymbol=oh.getAsArrayList(tmpgenURL);
			ucscURL=oh.getAsArrayList(tmpgenURL);
			ucscURLFiltered=oh.getAsArrayList(tmpgenURL);
			firstEnsemblID=oh.getAsArrayList(tmpgenURL);
		}else{
			displayNoEnsembl=true;
		}
        /*if(iDecoderAnswer!=null){
               	genURL=(ArrayList<String>)session.getAttribute("genURLArray");
				geneSymbol=(ArrayList<String>)session.getAttribute("ucscURLArray");
				ucscURL=(ArrayList<String>)session.getAttribute("geneSymbolArray");
				ucscURLFiltered=(ArrayList<String>)session.getAttribute("ucscURLFilteredArray");
				firstEnsemblID=(ArrayList<String>)session.getAttribute("firstEnsemblIDArray");
        }else{
			displayNoEnsembl=true;
		}*/
	}else if(
		(((action != null) && action.equals("Get Transcription Details"))&& region )
			|| ( auto && region )
	
	){
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
				minCoord=myGene.substring(myGene.indexOf(":")+1,myGene.indexOf("+-"));
				maxCoord=myGene.substring(myGene.indexOf("+-")+2);
				int tmpInt=Integer.parseInt(maxCoord);
				min=Integer.parseInt(minCoord)-tmpInt;
				max=Integer.parseInt(minCoord)+tmpInt;
			}else if(myGene.indexOf("-+")>0){
				minCoord=myGene.substring(myGene.indexOf(":")+1,myGene.indexOf("-+"));
				maxCoord=myGene.substring(myGene.indexOf("-+")+2);
				int tmpInt=Integer.parseInt(maxCoord);
				min=Integer.parseInt(minCoord)-tmpInt;
				max=Integer.parseInt(minCoord)+tmpInt;
			}else if (myGene.indexOf("+")>0){
				minCoord=myGene.substring(myGene.indexOf(":")+1,myGene.indexOf("+"));
				maxCoord=myGene.substring(myGene.indexOf("+")+1);
				min=Integer.parseInt(minCoord);
				max=min+Integer.parseInt(maxCoord);
			}else if(myGene.indexOf("-")>0){
				minCoord=myGene.substring(myGene.indexOf(":")+1,myGene.indexOf("-"));
				maxCoord=myGene.substring(myGene.indexOf("-")+1);
				min=Integer.parseInt(minCoord);
				max=Integer.parseInt(maxCoord);
			}else{
				regionError="You have entered an invalid region.  Please see the examples in the instructions.";
			}
			//log.debug("min:"+min+"\nmax:"+max);
			if(regionError.equals("")){
				if(min<max){
					if(min<1){
						min=1;
					}
					DecimalFormat df0 = new DecimalFormat("#,###");
					myDisplayGene=chromosome+":"+df0.format(min)+"-"+df0.format(max);
					fullGeneList =gdt.getRegionData(chromosome,min,max,panel,myOrganism,rnaDatasetID,arrayTypeID,forwardPValueCutoff);					
					String tmpURL =gdt.getGenURL();//(String)session.getAttribute("genURL");
					String tmpGeneSymbol=gdt.getGeneSymbol();//(String)session.getAttribute("geneSymbol");
					String tmpUcscURL =gdt.getUCSCURL();//(String)session.getAttribute("ucscURL");
					String tmpUcscURLFiltered =gdt.getUCSCURLFiltered();//(String)session.getAttribute("ucscURLFiltered");
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
						if(tmpUcscURLFiltered==null){
							ucscURLFiltered.add("");
						}else{
							ucscURLFiltered.add(tmpUcscURLFiltered);
						}
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
	String ucscFilterURLString=oh.getAsSeparatedString(ucscURLFiltered,",");
	String firstENSString=oh.getAsSeparatedString(firstEnsemblID,",");
	
%>

<%if(!popup){%>

<div id="inst" style="text-align:left;color:#000000;margin-left:30px;">

                1. Enter a gene identifier(e.g. gene symbol, probeset ID, ensembl ID, etc.) in the gene field.<BR />
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
                Hint: Try other synonyms if the first ID that you enter is not found.<BR /><BR /><BR />
</div>


<div style="text-align:center">
<form method="post" 
		action="<%=formName%>"
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
 <span style="padding-left:40px;"> <input type="submit" name="refreshBTN" id="getTrxBTN" value="Get Transcription Details" onClick="return displayWorking()"></span>
 
 	<input type="hidden" name="pvalueCutoffInput" id="pvalueCutoffInput" value="<%=pValueCutoff%>" />
    <input type="hidden" name="forwardPvalueCutoffInput" id="forwardPvalueCutoffInput" value="<%=forwardPValueCutoff%>" />
    <input type="hidden" name="tissues" id="tissues" value="" />
    <input type="hidden" name="chromosomes" id="chromosomes" value="" />
    <input type="hidden" name="action" id="action" value="Get Transcription Details" />
    
  	<input type="hidden" name="genURLArray" id="genURLArray" value="<%=genURLString%>" />
    <input type="hidden" name="geneSymArray" id="geneSymArray" value="<%=geneSymString%>" />
    <input type="hidden" name="ucscURLArray" id="ucscURLArray" value="<%=ucscURLString%>" />
    <input type="hidden" name="ucscFilterURLArray" id="ucscFilterURLArray" value="<%=ucscFilterURLString%>" />
    <input type="hidden" name="firstENSArray" id="firstENSArray" value="<%=firstENSString%>" />
</form>
Or
<input type="submit" name="translateBTN" id="translateBTN" value="Translate Region to Mouse/Rat" onClick="openTranslateRegion()"> 
</div>
<%}else{%>
	<div style="text-align:center;">
	<span class="button" onclick="window.close()" style="width:150px;">Close this Window</span>
    </div>
    <form method="post" 
		action="<%=formName%>"
		enctype="application/x-www-form-urlencoded"
		name="geneCentricForm" id="geneCentricForm">
        
  		<input type="hidden" name="geneTxt" id="geneTxt" value="<%= (myGene!=null)?myGene:"" %>">
 		<input type="hidden" name="speciesCB" id="speciesCB" value="<%=(myOrganism!=null)?myOrganism:"" %>"> 
 	<input type="hidden" name="pvalueCutoffInput" id="pvalueCutoffInput" value="<%=pValueCutoff%>" />
    <input type="hidden" name="forwardPvalueCutoffInput" id="forwardPvalueCutoffInput" value="<%=forwardPValueCutoff%>" />
    <input type="hidden" name="tissues" id="tissues" value="" />
    <input type="hidden" name="chromosomes" id="chromosomes" value="" />
    <input type="hidden" name="action" id="action" value="Get Transcription Details" />
  	<input type="hidden" name="genURLArray" id="genURLArray" value="<%=genURLString%>" />
    <input type="hidden" name="geneSymArray" id="geneSymArray" value="<%=geneSymString%>" />
    <input type="hidden" name="ucscURLArray" id="ucscURLArray" value="<%=ucscURLString%>" />
    <input type="hidden" name="ucscFilterURLArray" id="ucscFilterURLArray" value="<%=ucscFilterURLString%>" />
    <input type="hidden" name="firstENSArray" id="firstENSArray" value="<%=firstENSString%>" />
</form>
    
<%}%>
<script type="text/javascript">
		document.getElementById("wait1").style.display = 'none';
		//document.tooltip();
</script>
<BR />
<div class="demo" style="text-align:center;">
						<BR /><BR /><BR />
                        Detailed Transcription Information Demonstration<BR />
						<video width="800" height="650" controls="controls">
                    		<source src="<%=contextRoot%>web/demo/detailed_transcript_fullv3.mp4" type="video/mp4">
                            <source src="<%=contextRoot%>web/demo/detailed_transcript_fullv3.webm" type="video/webm">
                          <object data="<%=contextRoot%>web/demo/detailed_transcript_fullv3.mp4" width="800" height="650">
                          </object>
                        </video>
</div>

<div class="translate">
</div>

<script type="text/javascript">
	var translateDialog = createDialog(".translate" , {width: 700, height: 820, title: "<center>Translate Region</center>", zIndex: 500});
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
</script>

<%if(!region){%>

	<%@ include file="geneResults.jsp" %>

<%}else{%>

	<%@ include file="regionResults.jsp" %>

<%}%>



<%if(popup){%>
	<div style="text-align:center;">
	<span class="button" onclick="window.close()" style="width:150px;">Close this Window</span>
    </div>
<%}%>
<div style="padding-top:50px;"></div>
<%@ include file="/web/common/footer.jsp" %>





