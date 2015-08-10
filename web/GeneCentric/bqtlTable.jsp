
<%@ include file="/web/common/anon_session_vars.jsp" %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<%
	//log.debug("top of bqtlTable.jsp");
    gdt.setSession(session);
	//ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> fullGeneList=new ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene>();
	DecimalFormat dfC = new DecimalFormat("#,###");
	String myOrganism="";
	String fullOrg="";
	String panel="";
	String chromosome="";
	String folderName="";
	String type="";
        String genomeVer="";
	LinkGenerator lg=new LinkGenerator(session);
	double forwardPValueCutoff=0.01;
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
	if(request.getParameter("forwardPvalueCutoff")!=null){
		forwardPValueCutoff=Double.parseDouble(request.getParameter("forwardPvalueCutoff"));
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
	if(request.getParameter("genomeVer")!=null){
		genomeVer=request.getParameter("genomeVer");
	}

	if(min<max){
			if(min<1){
				min=1;
			}
			String tmpOutput=gdt.getImageRegionData(chromosome,min,max,panel,myOrganism,genomeVer,rnaDatasetID,arrayTypeID,forwardPValueCutoff,false);
			int startInd=tmpOutput.lastIndexOf("/",tmpOutput.length()-2);
			folderName=tmpOutput.substring(startInd+1,tmpOutput.length()-1);
			//fullGeneList =gdt.getRegionData(chromosome,min,max,panel,myOrganism,rnaDatasetID,arrayTypeID,forwardPValueCutoff,false);					
			//String tmpURL =gdt.getGenURL();//(String)session.getAttribute("genURL");
			//int second=tmpURL.lastIndexOf("/",tmpURL.length()-2);
			//folderName=tmpURL.substring(second+1,tmpURL.length()-1);
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
	}
			
	//log.debug("after initial setup bqtlTable.jsp");
%>

<div id="bQTLList"  style="border-color:#CCCCCC; border-width:1px 0px 0px 0px; border-style:inset;width:100%;">
	
	<table class="geneFilter" style="top:0px;">
                	<thead>
                    	<!--<TH style="width:50%"><span class="trigger triggerEC" id="bqtlListFilter1" name="bqtlListFilter" style=" position:relative;text-align:left;">Filter List</span><span class="bQTLListToolTip" title="Click the + icon to view fitlering options."><img src="<%=imagesDir%>icons/info.gif"></span></TH>-->
                        <TH style="width:50%"><span class="trigger triggerEC" id="bqtlListFilter2" name="bqtlListFilter" style="text-align:left;">View Columns</span><span class="bQTLListToolTip" title="Click the + icon to view options to show or hide additional columns."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    </thead>
                	<tbody id="bqtlListFilter" style="display:none;">
                    	<TR>
                        	<!--<td></td>-->
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


	<% ArrayList<BQTL> bqtls=gdt.getBQTLs(min,max,chromosome,myOrganism,genomeVer);
		//log.debug("testing for error");
	if(session.getAttribute("getBQTLsERROR")==null){
		//log.debug("no error");
		if(bqtls.size()>0){
		//log.debug("BQTLS >0 ");
	%>
    
	<TABLE name="items" id="tblBQTL" class="list_base" cellpadding="0" cellspacing="0" >
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
								//String regionQTL=gdt.getBQTLRegionFromSymbol(relQTL.get(j),myOrganism,dbConn);
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
	"sScrollX": "100%",
	"sScrollY": "100%",
	"bDeferRender": true,
	"aoColumnDefs": [
      { "bVisible": false, "aTargets": bqtlTarget }
    ],
	"sDom": '<"leftSearch"fr><t>'
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
		offsetX: 8,
		offsetY: 5,
		contentAsHTML:true,
		//arrow: false,
		interactive: true,
   		interactiveTolerance: 350
	});	
	
	//below fixes a bug in IE9 where some whitespace may cause an extra column in random rows in large tables.
	//simply remove all whitespace from html in a table and put it back.
	if (/MSIE (\d+\.\d+);/.test(navigator.userAgent)){ //test for MSIE x.x;
 		var ieversion=new Number(RegExp.$1) // capture x.x portion and store as a number
		if (ieversion<10){
			var expr = new RegExp('>[ \t\r\n\v\f]*<', 'g');
			
			var tbhtml = $('#tblBQTL').html();
			$('#tblBQTL').html(tbhtml.replace(expr, '><'));
			
		}	
	}
	
	//$('#tblBQTL').dataTable().fnAdjustColumnSizing();
</script>

