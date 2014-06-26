<%@ include file="/web/common/session_vars.jsp" %>
<jsp:useBean id="miRT" class="edu.ucdenver.ccp.PhenoGen.tools.mir.MiRTools" scope="session"> </jsp:useBean>
<jsp:useBean id="myGeneList" class="edu.ucdenver.ccp.PhenoGen.data.GeneList"/>
<jsp:useBean id="myGeneListAnalysis" class="edu.ucdenver.ccp.PhenoGen.data.GeneListAnalysis"/>
<jsp:useBean id="myParameterValue" class="edu.ucdenver.ccp.PhenoGen.data.ParameterValue"/>
<%
	miRT.setup(pool,session);
	MiRResult myMiRResult=new MiRResult();
	MiRResultSummary myMiRResultSummary=new MiRResultSummary();
	String id="";
	String selectedID="";
	
	if(request.getParameter("geneListAnalysisID")!=null){
		id=request.getParameter("geneListAnalysisID");
	}
	
	if(request.getParameter("selectedID")!=null){
		selectedID=request.getParameter("selectedID");
	}
	
	LinkGenerator lg=new LinkGenerator(session);
	
	GeneListAnalysis result=myGeneListAnalysis.getGeneListAnalysis(Integer.parseInt(id), pool);
	
	/*TODO fix the full organism*/
	String fullOrg="Mus_musculus";

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
	predicted[1][0]="eimmo";
	predicted[1][1]="EIMMo";
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
	mirList=myMiRResult.readGeneListResults(fullpath);
	
	
%>

	<%if(mirList.size()>0){
		MiRResult selected=null;
		for(int i=0;i<mirList.size()&&selected==null;i++){
			if(selectedID.equals(mirList.get(i).getAccession())){
				selected=mirList.get(i);
			}
		}
		int val=0,pred=0;
		if(selected!=null){
			Set sourceKey=selected.getSourceCount().keySet();
			for(int i=0;i<validated.length;i++){
				if(sourceKey.contains(validated[i][0])){
					val++;
				}
			}
			for(int i=0;i<predicted.length;i++){
				if(sourceKey.contains(predicted[i][0])){
					pred++;
				}
			}
		}
		%>
        <div style="width:100%;background:#66CCFF;">Selected miRNA - <%=selected.getAccession()%> ( <%=selected.getId()%>)</div>
      <div><div style="text-align:left;font-size:18px; font-weight:bold;width:100%;"> Validated Database Results</div>
          <table id="mirValTbl" name="items" class="list_base" style="text-align:center;width:100%;">
                <thead>
                    <TR class="col_title">
                    <TH style="color:#000000;">Gene</TH>
                    <TH style="color:#000000;">Database</TH>
                    <TH style="color:#000000;">Experiment</TH>
                    <TH style="color:#000000;">Support Type</TH>
                    <TH style="color:#000000;">Pubmed ID</TH>
                    </TR>
                </thead>
                <%if(val>0){%>
                    <tbody>
                        <%
                            HashMap<String, ArrayList<MiRDBResult>> dblist=selected.getDbResult();
                            for(int i=0;i<validated.length;i++){
                                if(dblist.containsKey(validated[i][0])){
                                    ArrayList<MiRDBResult> list=dblist.get(validated[i][0]);
                                    for(int j=0;j<list.size();j++){
                                    %>
                                        <TR>
                                        	<TD></TD>
                                            <TD><%=validated[i][1]%></TD>
                                            <TD><%=list.get(j).getExperiment()%></TD>
                                            <TD><%=list.get(j).getSupport()%></TD>
                                            <TD><a href="<%=lg.getPubmedRefLink(list.get(j).getPubmedID())%>" target="_blank"><%=list.get(j).getPubmedID()%></a></TD>
                                        </TR>
                                    <%
                                    }
                                }
                            }
                        %>
                    </tbody>
                <%}else{%>
                    <tbody>
                     <TR><TD colspan="4">No results to display</TD></TR>
                    </tbody>
                <%}%>
        </table>
        </div>
    

	
    <BR /><BR />
    <div><div style="text-align:left;font-size:18px; font-weight:bold;width:100%;">Predicted Database Results</div>
          <table id="mirPredTbl" name="items" class="list_base" style="text-align:center;width:100%;">
                <thead>
                    
                    <TR class="col_title">
                    <TH style="color:#000000;">Gene</TH>
                    <TH style="color:#000000;">Database</TH>
                    <TH style="color:#000000;">Score<span class="mirtooltip3"  title="Each database has its own scoring method.  Please refer to the multiMiR <a href=&quot;http://multimir.ucdenver.edu/&quot; target=&quot;_blank&quot;>site</a>/paper or each database for documentation on the scoring algorithm."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    </TR>
                </thead>
                <%if(pred>0){%>
                    <tbody>
                        <%
                            HashMap<String, ArrayList<MiRDBResult>> dblist=selected.getDbResult();
                            for(int i=0;i<predicted.length;i++){
                                if(dblist.containsKey(predicted[i][0])){
                                    ArrayList<MiRDBResult> list=dblist.get(predicted[i][0]);
                                    for(int j=0;j<list.size();j++){
                                    %>
                                        <TR>
                                        	<TD> </TD>
                                            <TD><%=predicted[i][1]%></TD>
                                            <TD><%=list.get(j).getScore()%></TD>
                                        </TR>
                                    <%
                                    }
                                }
                            }
                        %>
                    </tbody>
                <%}else{%>
                    <tbody>
                     <TR><TD colspan="2">No results to display</TD></TR>
                    </tbody>
                <%}%>
        </table>
        </div>
        <%}%>

<script type="text/javascript">

	$('#mirValTbl').dataTable({
			"bPaginate": false,
			"bDeferRender": false,
			//"sScrollX": "650px",
			//"sScrollY": "450px",
			"aaSorting": [[ 0, "desc" ]],
			"sDom": '<fr><t><i>'
	});
	
	$('#mirPredTbl').dataTable({
			"bPaginate": false,
			"bDeferRender": false,
			//"sScrollX": "650px",
			//"sScrollY": "450px",
			"aaSorting": [[ 0, "desc" ]],
			"sDom": '<fr><t><i>'
	});
	/*$(".hoverDetail").tooltipster({
				position: 'top-left',
				maxWidth: 350,
				offsetX: -230,
				offsetY: 5,
				contentAsHTML:true,
				//arrow: false,
				interactive: true,
				interactiveTolerance: 550
			});*/
	

	
</script>