<%@ include file="/web/common/anon_session_vars.jsp" %>
<jsp:useBean id="miRT" class="edu.ucdenver.ccp.PhenoGen.tools.mir.MiRTools" scope="session"> </jsp:useBean>
<jsp:useBean id="myGeneList" class="edu.ucdenver.ccp.PhenoGen.data.GeneList"/>
<jsp:useBean id="myGeneListAnalysis" class="edu.ucdenver.ccp.PhenoGen.data.GeneListAnalysis"/>
<jsp:useBean id="myParameterValue" class="edu.ucdenver.ccp.PhenoGen.data.ParameterValue"/>
<jsp:useBean id="anonU" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser" scope="session" />

<style>
	table#resultSummaryMirGeneTbl tr.selected td, table#resultDetailMirGeneTbl tr.selected td{
		background:	#bed9ba;
	}
</style>

<%
	miRT.setup(pool,session);
        if(userLoggedIn.getUser_name().equals("anon")){
            miRT.setAnonUser(anonU);
        }
        
	MiRResult myMiRResult=new MiRResult();
	MiRResultSummary myMiRResultSummary=new MiRResultSummary();
	String id="";
	
	if(request.getParameter("geneListAnalysisID")!=null){
		id=request.getParameter("geneListAnalysisID");
	}
	
	GeneListAnalysis result=null;
	if(userLoggedIn.getUser_name().equals("anon")){
            result=myGeneListAnalysis.getAnonGeneListAnalysis(Integer.parseInt(id), pool);
        }else{
            result=myGeneListAnalysis.getGeneListAnalysis(Integer.parseInt(id), pool);
        }
	/*TODO fix the full organism*/
	String fullOrg="Mus_musculus";
	String tables="";		
	String cutofftype="";
	String cutoffStr="";
	String disease="";
	if(result.getParameter_group_id()>-99){
		ParameterValue[] pv=myParameterValue.getParameterValues(result.getParameter_group_id(),pool);
				if(pv!=null){
					tables=myParameterValue.getParameterValueFromMyParameterValues(pv,"Table").getValue();
					cutofftype=myParameterValue.getParameterValueFromMyParameterValues(pv,"Prediction Cutoff Type").getValue();
					cutoffStr=myParameterValue.getParameterValueFromMyParameterValues(pv,"Cutoff").getValue();
					disease=myParameterValue.getParameterValueFromMyParameterValues(pv,"Disease").getValue();
					if(cutofftype.equals("p")){
						cutoffStr="Top "+cutoffStr+"% of predicted results";
					}else if(cutofftype.equals("t")){
						cutoffStr="Top "+cutoffStr+" of predicted results";
					}
					
				}
	}
	String [][] validated=new String[3][3];
	validated[0][0]="mirecords";
	validated[0][1]="miRecords";
	validated[0][2]="http://mirecords.biolead.org/download.php";
	validated[1][0]="mirtarbase";
	validated[1][1]="miRTarBase";
	validated[1][2]="http://mirtarbase.mbc.nctu.edu.tw/php/download.php";
	validated[2][0]="tarbase";
	validated[2][1]="TarBase";
	validated[2][2]="http://diana.imis.athena-innovation.gr/DianaTools/index.php?r=tarbase/index";
	String [][] predicted=new String[8][3];
	predicted[0][0]="diana_microt";
	predicted[0][1]="DIANA-microT-CDS";
	predicted[0][2]="http://diana.cslab.ece.ntua.gr/data/public/";
	predicted[1][0]="elmmo";
	predicted[1][1]="ElMMo";
	predicted[1][2]="http://www.mirz.unibas.ch/miRNAtargetPredictionBulk.php";
	predicted[2][0]="microcosm";
	predicted[2][1]="MicroCosm";
	predicted[2][2]="http://www.ebi.ac.uk/enright-srv/microcosm/cgi-bin/targets/v5/download.pl";
	predicted[3][0]="miranda";
	predicted[3][1]="miRanda";
	predicted[3][2]="http://www.microrna.org/microrna/getDownloads.do";
	predicted[4][0]="mirdb";
	predicted[4][1]="miRDB";
	predicted[4][2]="http://mirdb.org/miRDB/";
	predicted[5][0]="pictar";
	predicted[5][1]="PicTar";
	predicted[5][2]="http://dorina.mdc-berlin.de/rbp_browser/dorina.html";
	predicted[6][0]="pita";
	predicted[6][1]="PITA";
	predicted[6][2]="http://genie.weizmann.ac.il/pubs/mir07/mir07_data.html";
	predicted[7][0]="targetscan";
	predicted[7][1]="TargetScan";
	predicted[7][2]="http://www.targetscan.org/cgi-bin/targetscan/data_download.cgi?db=vert_61";
	/*String [][] disease=new String[3][3];
	disease[0][0]="mir2disease";
	disease[0][1]="mir2disease";
	disease[0][2]="mir2disease";
	disease[1][0]="pharmaco_mir";
	disease[1][1]="pharmaco_mir";
	disease[1][2]="pharmaco_mir";
	disease[2][0]="phenomir";
	disease[2][1]="phenomir";
	disease[2][2]="phenomir";*/
	String[][] total=new String[3][2];
	total[0][0]="validated.sum";
	total[0][1]="Total Validated";
	total[1][0]="predicted.sum";
	total[1][1]="Total Predicted";
	total[2][0]="all.sum";
	total[2][1]="Total All";
	ArrayList<MiRResult> mirList=new ArrayList<MiRResult>();
	String fullpath=userLoggedIn.getUserGeneListsDir() +"/" + selectedGeneList.getGene_list_name_no_spaces() +"/multiMir/"+result.getPath()+"/";
        log.debug("\n"+fullpath);
        if(userLoggedIn.getUser_name().equals("anon")){
            fullpath= userLoggedIn.getUserGeneListsDir()+anonU.getUUID()+"/"+selectedGeneList.getGene_list_id()+"/multiMir/"+result.getPath()+"/";
        }
        log.debug("\n"+fullpath);
	mirList=myMiRResult.readGeneListResults(fullpath);
	
	ArrayList<MiRResultSummary> summaryList=new ArrayList<MiRResultSummary>();
	summaryList=myMiRResultSummary.createSummaryList(mirList);
	
%>
<H1 style="color:#000000;">Results - <%=result.getName()%> &nbsp;&nbsp;&nbsp;<span class="mirDetailResultInfo"  title="Tables Searched: <%=tables%><BR><BR>Predicted Cutoff Type/Value: <%=cutoffStr%><BR><BR>Disease/Drug Terms: <%=disease%>"><img src="<%=imagesDir%>icons/info.gif"></span></H1>
<!--<table><TR>
<TD>Tables Searched: <%=tables%></TD></TR><TR><TD>Predicted Cutoff Type/Value: <%=cutoffStr%></TD></TR><TR><TD>Disease/Drug Terms: <%=disease%></TD></TR>
</TR>
</table>-->
<span style="font-size:16px; font-weight:bold;">miRNAs Targeting Genes in Gene List</span> <span id="btnresultSummary" class="button resultViewBTN" style="display:none;width:175px;float:right;">View Short Summary</span><span id="btnresultDetail" class="button resultViewBTN" style="width:175px;float:right;">View Detailed Summary</span>
<BR><BR><BR>
<div id="resultSummary" class="resultMainTable" style="width:100%;">
Short Summary Table
<table id="resultSummaryMirGeneTbl" name="items" class="list_base" style="text-align:center;width:100%;">
	<thead>
        	<TR class="col_title">
            	<TH colspan="2" style="color:#000000;">Mature miRNA</TH>
                <TH colspan="3" style="color:#000000;"># Targeted Genes from Gene List</TH>
            </TR>
        	<TR class="col_title">
            <TH style="color:#000000;">Accession <span class="mirtooltip2"  title="Click to view miRBase page for the miRNA."><img src="<%=imagesDir%>icons/info.gif"></span><BR />(click for miRBase)</TH>
            <TH style="color:#000000;">ID <span class="mirtooltip2"  title="Click to view additional informat on validated/predicted results and all genes targeted by miRNA."><img src="<%=imagesDir%>icons/info.gif"></span><BR />(click to view details)</TH>
            <TH style="color:#000000;">Validated</TH>
            <TH style="color:#000000;">Predicted</TH>
            <TH style="color:#000000;">Total</TH>
           	</TR>
        </thead>
        <tbody>
        	<%for (int i=0;i<summaryList.size();i++){
                    MiRResultSummary tmp=summaryList.get(i);
                    String rowID=tmp.getAccession();
                    if(tmp.getAccession().equals("")){
                            rowID=tmp.getId();
                    }
                    if(tmp.getValidCount()>0 || tmp.getPredictedCount()>0 ){%>
                        <TR class="<%=rowID.replace("*","")%>">
                                <TD>
                                <%if(tmp.getAccession().equals("")){%>
                                    <a href="http://www.mirbase.org/cgi-bin/query.pl?terms=<%=tmp.getId().replace("*","")%>" target="_blank" title="Link to miRBase.">Accession # Missing</a>
                                <%}else{%>
                                    <a href="http://www.mirbase.org/cgi-bin/mature.pl?mature_acc=<%=tmp.getAccession()%>" target="_blank" title="Link to miRBase."><%=tmp.getAccession()%></a>
                                <%}%>

                            </TD>
                                <TD><span id="mirDetail<%=rowID%>" class="mirViewDetail" style="cursor:pointer; text-decoration:underline; color:#688eb3;"><%=tmp.getId()%></span></TD>
                            <TD><span class="<%if(tmp.getValidCount()>0){%>hoverDetail<%}%>" title="<%=tmp.getValidListHTML()%>"><%=tmp.getValidCount()%></span></TD>
                            <TD><span class="<%if(tmp.getPredictedCount()>0){%>hoverDetail<%}%>" title="<%=tmp.getPredictedListHTML()%>"><%=tmp.getPredictedCount()%></span></TD>
                            <TD><span class="hoverDetail" title="<%=tmp.getTotalListHTML()%>"><%=tmp.getTotalCount()%></span></TD>
                        </TR>
                <%}
            }%>
        </tbody>
</table>
</div>
<div id="resultDetail" class="resultMainTable" style="width:100%;">
Detailed Summary Table
<table id="resultDetailMirGeneTbl" name="items" class="list_base" style="text-align:center;width:100%;" >
	<%if(mirList.size()>0){
		Set sourceKey=mirList.get(0).getSourceCount().keySet();
		%>
        <thead>
        	<TR class="col_title">
            	<TH colspan="2">Mature miRNA</TH>
                <TH colspan="3">Target</TH>
                <TH colspan="3" style="color:#000000;">Validated</TH>
                <TH colspan="8" style="color:#000000;">Predicted</TH>
                <TH colspan="3" style="color:#000000;">Total</TH>
            </TR>
        	<TR class="col_title">
            <TH style="color:#000000;">Accession <span class="mirtooltip2"  title="Click to view miRBase page for the miRNA."><img src="<%=imagesDir%>icons/info.gif"></span><BR />(click for miRBase)</TH>
            <TH style="color:#000000;">ID <span class="mirtooltip2"  title="Click to view additional informat on validated/predicted results and all genes targeted by miRNA."><img src="<%=imagesDir%>icons/info.gif"></span><BR />(click to view details)</TH>
            <TH style="color:#000000;">Gene Symbol</TH>
            <TH style="color:#000000;">Entrez ID</TH>
            <TH style="color:#000000;">Ensembl ID</TH>
            
            <%for(int i=0;i<validated.length;i++){%>
            	<TH><a href="<%=validated[i][2]%>" target="_blank"><%=validated[i][1]%></a></TH>
                
            <%}%>
            <%for(int i=0;i<predicted.length;i++){%>
            	<TH><a href="<%=predicted[i][2]%>" target="_blank"><%=predicted[i][1]%></a></TH>
            <%}%>
             <%	for(int i=0;i<total.length;i++){%>
            	<TH style="color:#000000;"><%=total[i][1]%></TH>
                
            <%}%>
           	</TR>
        </thead>
        
        <tbody>
        <%for (int i=0;i<mirList.size();i++){
			MiRResult tmp=mirList.get(i);
			HashMap tmpSC=tmp.getSourceCount();
			String rowID=tmp.getAccession();
			if(tmp.getAccession().equals("")){
				rowID=tmp.getId();
			}
			%>
            <TR class="<%=rowID.replace("*","")%>">
            <TD><%if(tmp.getAccession().equals("")){%>
                	<a href="http://www.mirbase.org/cgi-bin/query.pl?terms=<%=tmp.getId().replace("*","")%>" target="_blank" title="Link to miRBase.">Accession # Missing</a>
				<%}else{%>
                	<a href="http://www.mirbase.org/cgi-bin/mature.pl?mature_acc=<%=tmp.getAccession()%>" target="_blank" title="Link to miRBase."><%=tmp.getAccession()%></a>
                <%}%>
            </TD>
            <TD><span id="mirDetail<%=rowID%>" class="mirViewDetail" style="cursor:pointer; text-decoration:underline; color:#688eb3;"><%=tmp.getId()%></span></TD>
            <TD><%=tmp.getTargetSym()%></TD>
            <TD><a href="http://www.ncbi.nlm.nih.gov/gene/?term=<%=tmp.getTargetEntrez()%>" target="_blank"><%=tmp.getTargetEntrez()%></a></TD>
            <TD><a href="<%=LinkGenerator.getEnsemblLinkEnsemblID(tmp.getTargetEnsembl(),fullOrg)%>" target="_blank" title="View Ensembl Gene Details"><%=tmp.getTargetEnsembl()%></a></TD>
            <%	for(int j=0;j<validated.length;j++){
					if(sourceKey.contains(validated[j][0])){
						String x="-";
						int count=Integer.parseInt((String) tmpSC.get(validated[j][0]));
						if(count>0){
							x="X";
						}
			%>
            			<TD><%=x%></TD>
                
            <%		}else{%>
            			<TD>-</TD>
            		<%}%>
			<%	}%>
            <%	for(int j=0;j<predicted.length;j++){
					if(sourceKey.contains(predicted[j][0])){
						String x="-";
						int count=Integer.parseInt((String) tmpSC.get(predicted[j][0]));
						if(count>0){
							x="X";
						}
			%>
            			<TD><%=x%></TD>
                
            <%		}else{%>
            			<TD>-</TD>
            		<%}%>
			<%	}%>
             <%	for(int j=0;j<total.length;j++){
					if(sourceKey.contains(total[j][0])){
						
			%>
            			<TD><%=tmpSC.get(total[j][0])%></TD>
                
            <%		}else{%>
            		<TD>0</TD>
            		<%}%>
			<%	}%>
            </TR>
        <%}%>
        </tbody>
	<%}else{%>
    	<tbody>
        <TR><TD>No results to display for this gene.</TD>
        </TR>
    	</tbody>
    <%}%>
</table>
</div>

<div id="selectedDetail">
</div>
<script type="text/javascript">

	$('.resultViewBTN').on('click',function(){
		var id=new String($(this).attr('id'));
		var divName=id.substr(3);
		$('.resultMainTable').hide();
		$('#'+divName).show();
		$('.resultViewBTN').show();
		$(this).hide();
	});
	var tblMirSummaryResult=$('#resultSummaryMirGeneTbl').dataTable({
			"bPaginate": false,
			"bDeferRender": true,
			"sScrollX": "100%",
			"sScrollY": "580px",
			"aaSorting": [[ 0, "desc" ]],
			"sDom": '<fr><t><i>'
	});
	
	var tblMirDetailResult=$('#resultDetailMirGeneTbl').dataTable({
			"bPaginate": false,
			"bDeferRender": true,
			"sScrollX": "100%",
			"sScrollY": "580px",
			"aaSorting": [[ 0, "desc" ]],
			"sDom": '<fr><t><i>'
	});
	$('#resultDetail').hide();
	
	$(".mirDetailResultInfo").tooltipster({
				position: 'top-left',
				maxWidth: 350,
				offsetX: -10,
				offsetY: -10,
				contentAsHTML:true,
				//arrow: false,
				interactive: true,
				interactiveTolerance: 350
			});
	$(".mirtooltip2").tooltipster({
				position: 'top-left',
				maxWidth: 350,
				offsetX: -10,
				offsetY: 5,
				contentAsHTML:true,
				//arrow: false,
				interactive: true,
				interactiveTolerance: 550
			});
	$(".hoverDetail").tooltipster({
				position: 'top-left',
				maxWidth: 350,
				offsetX: -10,
				offsetY: 0,
				contentAsHTML:true,
				//arrow: false,
				interactive: true,
				interactiveTolerance: 550
			});
	
	$('span.mirViewDetail').on('click',function(){
			var id="<%=id%>";
			var selectedID=(new String($(this).attr("id"))).substr(9);
			$('html, body').animate({
				scrollTop: $( '#mirresultDetail' ).offset().top
			}, 200);
			$('table#resultSummaryMirGeneTbl tr.selected').removeClass("selected");
			$('table#resultDetailMirGeneTbl tr.selected').removeClass("selected");
			$('table#resultSummaryMirGeneTbl tr.'+selectedID).addClass("selected");
			$('table#resultDetailMirGeneTbl tr.'+selectedID).addClass("selected");
			//var loadingTimer=setTimeout(function(){
			$('#detailResultLoading').show();
				//},4000);
			$.ajax({
				url: contextPath + "/web/geneLists/include/getMultiMiRDetail.jsp",
   				type: 'GET',
				data: {geneListAnalysisID:id,selectedID:selectedID},
				dataType: 'html',
				complete: function(){
					
				},
    			success: function(data2){
        			//clearTimeout(loadingTimer);
                                $('div#mirresultDetail').html(data2);
    			},
    			error: function(xhr, status, error) {
        			$('div#mirresultDetail').html("<div>An error occurred generating this image.  Please try back later.</div>");
    			}
			});
	});
	
</script>