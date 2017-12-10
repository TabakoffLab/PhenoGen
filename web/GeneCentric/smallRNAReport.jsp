<%@ include file="/web/common/anon_session_vars.jsp" %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<%
        gdt.setSession(session);
        edu.ucdenver.ccp.PhenoGen.data.Bio.Gene myGeneClass= new edu.ucdenver.ccp.PhenoGen.data.Bio.Gene();
	ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> fullGeneList=new ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene>();
	String myOrganism="";
	String id="";
	String chromosome="";
	
	String[] selectedLevels=null;
	
	String fullOrg="";
	String panel="";
	String gcPath="";
        String path="";
        String genomeVer="";
        boolean isSmall=false;
        boolean isNovel=false;
	int selectedGene=0;
	ArrayList<String>geneSymbol=new ArrayList<String>();
	LinkGenerator lg=new LinkGenerator(session);
	
	
	
	
	if(request.getParameter("species")!=null){
		myOrganism=FilterInput.getFilteredInput(request.getParameter("species").trim());
		if(myOrganism.equals("Rn")){
			panel="BNLX/SHRH";
			fullOrg="Rattus_norvegicus";
		}else{
			panel="ILS/ISS";
			fullOrg="Mus_musculus";
		}
	}
	if(request.getParameter("chromosome")!=null){
		chromosome=FilterInput.getFilteredInput(request.getParameter("chromosome"));
	}
	
		
	if(request.getParameter("geneSymbol")!=null){
		geneSymbol.add(FilterInput.getFilteredInput(request.getParameter("geneSymbol")));
	}else{
		geneSymbol.add("None");
	}
	if(request.getParameter("id")!=null){
		id=FilterInput.getFilteredInput(request.getParameter("id"));
	}
        if(request.getParameter("dataPath")!=null){
		path=FilterInput.getFilteredURLInput(request.getParameter("dataPath"));
	}
        if(id.startsWith("PRN")||id.startsWith("PMM")){
            isNovel=true;
        }
	if(request.getParameter("genomeVer")!=null){
		genomeVer=request.getParameter("genomeVer");
	}
	//gcPath=applicationRoot + contextRoot+"tmpData/browserCache/"+genomeVer+"/geneData/" +id+"/";
	
	
	int rnaDatasetID=0;
	int arrayTypeID=0;
	
	int[] tmp=gdt.getOrganismSpecificIdentifiers(myOrganism,genomeVer);
							if(tmp!=null&&tmp.length==2){
								rnaDatasetID=tmp[1];
								arrayTypeID=tmp[0];
							}
	String genURL="";
	String urlPrefix=(String)session.getAttribute("mainURL");
        if(urlPrefix.endsWith(".jsp")){
             urlPrefix=urlPrefix.substring(0,urlPrefix.lastIndexOf("/")+1);
        }
	genURL=urlPrefix+ "tmpData/browserCache/"+genomeVer+"/geneData/" +id+"/";
        log.debug("path:\n"+applicationRoot + contextRoot+path);
	ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> tmpGeneList=myGeneClass.readGenes(applicationRoot + contextRoot+path);
	edu.ucdenver.ccp.PhenoGen.data.Bio.Gene curGene=null;
	for(int i=0;i<tmpGeneList.size();i++){
		log.debug("check:"+tmpGeneList.get(i).getGeneID()+":"+id);
		if(tmpGeneList.get(i).getGeneID().equals(id)){
			log.debug("found:"+tmpGeneList.get(i).getGeneID());
			curGene=tmpGeneList.get(i);
		}
	}
        
        isSmall=true;

%>

<style>
    #psHeritTbl{
            width:100%;
    }
    #psDABGTbl{
            width:100%;
    }
    #genePart1Tbl{
            width:100%;
    }
    #genePart2Tbl{
            width:100%;
    }
    table.quant {
         border-bottom: solid 1px #000000;
         border-top: solid 1px #000000;
    }
    table.quant td{
        border-left: solid 1px #000000;
        border-right: solid 1px #000000;
    }
    table.quant tr.odd td{
        background-color: #CECECE;
    }
</style>

<div style="font-size:18px; font-weight:bold; background-color:#FFFFFF; color:#000000; text-align:center; width:100%; padding-top:3px;">
            <span class="selectdetailMenu selected" name="geneDetail">Gene Details<div class="inpageHelp" style="display:inline-block; "><img id="HelpGeneDetailTab" class="helpGeneRpt" src="<%=contextRoot%>/web/images/icons/help.png" /></div></span>
            <!--<span class="selectdetailMenu" name="miGenernaPred">Predict Genes Targeted by this miRNA(PITA)<div class="inpageHelp" style="display:inline-block; "><img id="HelpPredictGeneMirTargetTab" class="helpGeneRpt" src="<%=contextRoot%>/web/images/icons/help.png" /></div></span>
            -->
            <%//if(myOrganism.equals("Rn") && genomeVer.equals("rn6")){%>
                    <span class="selectdetailMenu" name="geneApp">Expression Data<div class="inpageHelp" style="display:inline-block; "><img id="HelpGenePSTab" class="helpGeneRpt" src="<%=contextRoot%>/web/images/icons/help.png" /></div></span>
           <%//}%>

</div>

<div style="font-size:18px; font-weight:bold; background-color:#47c647; color:#FFFFFF; text-align:left; width:100%; ">
    <span class="trigger triggerEC less" name="geneDiv"  style="margin-left:30px;">Selected Feature Summary</span>    
</div>

<div id="geneDiv" style="display:inline-block;text-align:left; width:100%;">
	<div style="display:inline-block; text-align:left;width:100%;" id="geneDetail">
    	
        <%  log.debug(" line 118");	
            DecimalFormat df2 = new DecimalFormat("#.##");
            DecimalFormat df0 = new DecimalFormat("###");
            DecimalFormat df4 = new DecimalFormat("#.####");
            DecimalFormat dfC = new DecimalFormat("#,###");
			
            String chr=curGene.getChromosome();
            if(!chr.startsWith("chr")){
                    chr="chr"+chr;
            }
            log.debug(" line 128");
            %>
            <div class="adapt2Col">
            <table id="genePart1Tbl" class="geneReport" style="display:inline-block;">
            <TR>
            <TD style="width:20%;">
             Gene Symbol: 
             </TD>
             <TD style="width:78%;">
            <%if(curGene.getGeneSymbol()!=null && !curGene.getGeneSymbol().equals("")){%>
                                        <%=curGene.getGeneSymbol()%>
            <%}else{%>
                                        No Gene Symbol Found
           	<%}%>
            </TD>
            </TR>
            <TR>
            	<TD>
            		Location:  
					</TD>
				<TD>
					<%=chr+": "+dfC.format(curGene.getStart())+"-"+dfC.format(curGene.getEnd())%>
                    </TD>
            </TR>
            <TR>
                <TD>
                	Strand:
                </TD> 
				<TD>
					<%=curGene.getStrand()%>
                    </TD>
             </TR>
                
            <TR>
            	<TD > Description:</TD>
                <TD >
                	
					<%log.debug(" line 164");
                                            String description=curGene.getDescription();
                                        String shortDesc=description;
                                        String remain="";
                                        if(description.indexOf("[")>0){
                                            shortDesc=description.substring(0,description.indexOf("["));
                                            remain=description.substring(description.indexOf("[")+1,description.indexOf("]"));
                                        }
                                %>
                                <span title="Description <%=remain%>">
                                	<%String bioType=curGene.getBioType();%>
                                        <%if(!isSmall){%>
                                            <%=shortDesc%>
                                        <%}else{%>
                                            <%=bioType%>
                                        <%}%>
                                    
                                    </span>
                                    
                                </TD>
            </TR>
            <TR></TR>
            <TR>
            	<TD> Links:</TD>
                <TD>
                	
                     <%log.debug(" line 190");
                         if(curGene.getGeneID().startsWith("ENS")){%>
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
                 
            </TR>
            <TR>
            	<TD></TD>
                <TD></TD>
            </TR>
            </table>
            <table id="genePart2Tbl" class="geneReport" style="display:inline-block;">          
                               
            <%if(myOrganism.equals("Rn")){%>
   			<TR>
            	<TD style="width:20%;">Exonic Variants:</TD>
                <TD style="width:78%;">
                                    
                                        <B>Common:</B> <%=curGene.getSnpCount("common","SNP")%> (SNPs) / <%=curGene.getSnpCount("common","Indel")%>(Insertions/Deletions)<BR />
                                    
                                        <B>BN-Lx/CubPrin:</B> <%=curGene.getSnpCount("BNLX","SNP")%> (SNPs) / <%=curGene.getSnpCount("BNLX","Indel")%>(Insertions/Deletions)<BR />
                                   
                                        <B>SHR/OlaPrin:</B> <%=curGene.getSnpCount("SHRH","SNP")%> (SNPs) / <%=curGene.getSnpCount("SHRH","Indel")%> (Insertions/Deletions)<BR />
                                    
                                        <B>SHR/NCrlPrin:</B> <%=curGene.getSnpCount("SHRJ","SNP")%> (SNPs) / <%=curGene.getSnpCount("SHRJ","Indel")%> (Insertions/Deletions)<BR />
                                    
                                        <B>F344:</B> <%=curGene.getSnpCount("F344","SNP")%> (SNPs) / <%=curGene.getSnpCount("F344","Indel")%> (Insertions/Deletions)<BR />
                                    
                                </TD>
                                
            </TR>
            <%}%>
            
            </table>
            </div>
            <div>
            <div class="geneReport header" style="width:100%;">
                Affy Probe Set Data: Overlapping Probe Set Count:<%=curGene.getProbeCount()%> 
                    <span class="reporttooltip" 
                          title="Summary of probe sets that overlap with an exon or intron of any Ensembl or RNA-Seq transcript for this gene and probe the same strand as the transcript.<BR>Note: The probe set track if displayed shows all non-masked probe sets in the region including the opposite strand.">
                        <img src="<%=contextRoot%>/web/images/icons/info.gif" /></span>
            </div>
            <BR>
            <!--<div class="geneReport header" style="width:100%;">
                RNA-Seq Read Depth Statistics for Feature 
                    <span class="reporttooltip" 
                          title="">
                        <img src="<%=contextRoot%>/web/images/icons/info.gif" /></span>
            </div>
            <BR><BR>
            <div>
                <%ArrayList<HashMap<String,String>> quantList=curGene.getQuant();
                %>
                <table name="items" class="list_base quant" cellpadding="0" cellspacing="0" style="width:50%;">
                    <tr>
                        <TD></TD>
                        <%for(int i=0;i<quantList.size();i++){%>
                        <TD><%=quantList.get(i).get("strain")%></TD>
                        <%}%>
                    </tr>
                    <tr class="odd">
                        <TD>Median Read Depth</TD>
                        <%for(int i=0;i<quantList.size();i++){%>
                        <TD><%=quantList.get(i).get("median")%></TD>
                        <%}%>
                    </tr>
                    <tr>
                        <TD>Mean Read Depth</TD>
                        <%for(int i=0;i<quantList.size();i++){%>
                        <TD><%=quantList.get(i).get("mean")%></TD>
                        <%}%>
                    </tr>
                    <tr  class="odd">
                        <TD>% Coverage</TD>
                        <%for(int i=0;i<quantList.size();i++){%>
                        <TD><%=quantList.get(i).get("cov")%></TD>
                        <%}%>
                    </tr>
                    <tr>
                        <TD>Min Read Depth</TD>
                        <%for(int i=0;i<quantList.size();i++){%>
                        <TD><%=quantList.get(i).get("min")%></TD>
                        <%}%>
                    </tr>
                    <tr  class="odd">
                        <TD>Max Read Depth</TD>
                        <%for(int i=0;i<quantList.size();i++){%>
                        <TD><%=quantList.get(i).get("max")%></TD>
                        <%}%>
                    </tr>
                </table>
                    <BR><BR>
            </div>
            -->
            
            
                                    
                  
                                
    </div>
    </div>
    
    <div style="display:none;" id="geneEQTL">
    </div>
    
    <div style="display:none;" id="geneApp">
                <div id="geneAppsrcCtrl" class="srcCtrl" style="text-align:center;"></div>
                <div class="help" style="width:100%;display:inline-block;text-align:center;"></div>
                <div class="exprCol" id="expBrain" style="display:inline-block;">
                    <div style="width:100%;text-align: center;"><H2><span id="geneAppTitleb"></span></h2></div><BR>
                    <div id="chartBrain" style="width:98%;"></div>
                    
                </div>
                <div class="exprCol" id="expLiver" style="display:inline-block;">
                    <div style="width:100%;text-align: center;"><H2><span id="geneAppTitlel"></span></h2></div><BR>
                    <div id="chartLiver" style="width:98%;"></div>
                </div>
    </di
   	
    <div style="display:none;" id="geneMIrna">
    </div>
    
    <div style="display:none;" id="miGenerna">
    </div>
    <div style="display:none;" id="geneWGCNA">
    </div>

 </div>
            
<%log.debug(" line 296");%>



<script type="text/javascript">
	var idStr="<%=id%>";
	var geneSymStr="<%=curGene.getGeneSymbol()%>";
	
	var rows=$("table#tblGeneDabg tr");
	stripeTable(rows);
	rows=$("table#tblGeneHerit tr");
	stripeTable(rows);
	rows=$("table#tblGeneEQTL tr");
	stripeTable(rows);
	
        $(".reporttooltip").tooltipster({
                position: 'top-right',
                maxWidth: 250,
                offsetX: 0,
                offsetY: 5,
                contentAsHTML:true,
                //arrow: false,
                interactive: true,
                interactiveTolerance: 350
        });
	$('.selectdetailMenu').click(function (){
		var oldID=$('.selectdetailMenu.selected').attr("name");
		$("#"+oldID).hide();
		$('.selectdetailMenu.selected').removeClass("selected");
		$(this).addClass("selected");
		var id=$(this).attr("name");
		$("#"+id).show();
		loadGeneReportTabs(id,false);
	});
        $('.helpGeneRpt').on('click', function(event){
			var id=$(this).attr('id');
			$('#'+id+'Content').dialog( "option", "position",{ my: "right top", at: "left bottom", of: $(this) });
			$('#'+id+'Content').dialog("open").css({'font-size':12});
			event.stopPropagation();
			//return false;
		}
	);

        function setSelectedTab(scrollToDiv){
            if(typeof section !== 'undefined' && section !== ""){
                var oldID=$('.selectdetailMenu.selected').attr("name");
                $("#"+oldID).hide();
                $('.selectdetailMenu.selected').removeClass("selected");
                $(".selectdetailMenu[name=\""+section+"\"]").addClass("selected");
                $("#"+section).show();
                loadGeneReportTabs(section,scrollToDiv);
            }
        }

        function loadGeneReportTabs(id,scrollToDiv){
            if(id==="geneEQTL"){
                    var jspPage=contextRoot+"web/GeneCentric/geneEQTLAjax.jsp";
                    var params={
                            species: organism,
                            geneSymbol: selectedGeneSymbol,
                            chromosome: chr,
                            id:selectedID,
                            genomeVer:genomeVer
                    };
                    loadDivWithPage("div#geneEQTL",jspPage,scrollToDiv,params,
                                    "<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Loading...</span>");
            }else if(id==="geneApp"){
                    /*$.ajax({
                                    url: contextRoot+"web/GeneCentric/callPanelExpr.jsp",
                                    type: 'GET',
                                    cache: 'false',
                                    data: {id:idStr,organism: organism,genomeVer:genomeVer,chromosome: chr,minCoord:svgList[1].xScale.domain()[0],maxCoord:svgList[1].xScale.domain()[1],rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID},
                                    dataType: 'json',
                            error: function(xhr, status, error) {console.log(error);}
                            });*/
            }else if(id==="geneMIrna"){
                    var jspPage=contextRoot+"web/GeneCentric/geneMiRnaAjax.jsp";
                    var params={
                            species: organism,
                            id:selectedID
                    };
                    loadDivWithPage("div#geneMIrna",jspPage,scrollToDiv,params,
                                    "<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Loading...</span>");
            }else if(id==="miGenerna"){
                    var jspPage=contextRoot+"web/GeneCentric/miGeneRnaAjax.jsp";
                    var params={
                            species: organism,
                            id:geneSymStr
                    };
                    loadDivWithPage("div#miGenerna",jspPage,scrollToDiv,params,
                                    "<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Loading...</span>");
            }else if(id==="geneWGCNA"){
                    $("div#regionWGCNAEQTL").html("");
                    var jspPage=contextRoot+"web/GeneCentric/wgcnaGene.jsp";
                    var params={
                            species: organism,
                            id:selectedID,
                            genomeVer:genomeVer
                    };
                    loadDivWithPage("div#geneWGCNA",jspPage,scrollToDiv,params,
                                    "<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Loading...</span>");
            }
        }
        setTimeout(function(){
            setSelectedTab(true);
            //setTimeout(function(){
            //    $("#geneDiv").scrollTop($("#geneDiv")[0].scrollHeight);
            //},500);
        },200);
        
        <%@ include file="/javascript/chart.js" %>
 
        setTimeout(function(){
                var ctrlDiv="geneApp";
               <%@ include file="include/js_addExprSrcCtrl.jsp" %>
               var bChart=chart({"data":"<%=genURL+"/Brain_sm_expr.json"%>",
                   "selector":"#chartBrain","allowResize":true,"type":"scatter","width":"46%","height":"500","displayHerit":true,
               "title":"Gene/Transcript Expression","titlePrefix":"Whole Brain"});
               var lChart=chart({"data":"<%=genURL+"/Liver_sm_expr.json"%>",
                   "selector":"#chartLiver","allowResize":true,"type":"scatter","width":"46%","height":"500","displayHerit":true,
               "title":"Gene/Transcript Expression","titlePrefix":"Liver"});
               if($(window).width()<1500){
                   bChart.setWidth("98%");
                   lChart.setWidth("98%");
               }
        },50);
        //svgList[1].updateLinks();
        $(window).resize(function (){
				if($(window).width()<1500){
                                    bChart.setWidth("98%");
                                    lChart.setWidth("98%");
                                }else{
                                    bChart.setWidth("46%");
                                    lChart.setWidth("46%");
                                }
			});
</script>

