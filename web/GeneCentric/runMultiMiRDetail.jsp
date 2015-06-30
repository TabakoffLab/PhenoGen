<%@ include file="/web/common/anon_session_vars.jsp" %>
<jsp:useBean id="miRT" class="edu.ucdenver.ccp.PhenoGen.tools.mir.MiRTools" scope="session"> </jsp:useBean>
<%

	String myOrganism="";
	String fullOrg="";
	String id="";
	String table="all";
	String predType="p";
	int cutoff=20;
	String selectedID="";
	
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
	
	LinkGenerator lg=new LinkGenerator(session);
	
	miRT.setup(pool,session);
	
	ArrayList<MiRResult> mirList=new ArrayList<MiRResult>();
	ArrayList<MiRResult> targetList=new ArrayList<MiRResult>();
	
	if(request.getParameter("species")!=null){
		myOrganism=request.getParameter("species").trim();
		if(myOrganism.equals("Mm")){
			fullOrg="Mus_musculus";
		}else if(myOrganism.equals("Rn")){
			fullOrg="Rattus_norvegicus";
		}
	}
	if(request.getParameter("id")!=null){
		id=request.getParameter("id");
	}
	if(request.getParameter("table")!=null){
		table=request.getParameter("table");
	}
	
	if(request.getParameter("predType")!=null){
		predType=request.getParameter("predType");
	}
	if(request.getParameter("selectedID")!=null){
		selectedID=request.getParameter("selectedID");
	}
	if(request.getParameter("cutoff")!=null){
		cutoff=Integer.parseInt(request.getParameter("cutoff"));
	}
	
	mirList=miRT.getMirTargetingGene(myOrganism,id,table,predType,cutoff);
%>
<BR /><BR />
<div style="text-align:center;">	
	<div style="font-size:18px; font-weight:bold; background-color:#47c647; color:#FFFFFF;width:100%;text-align:left;">
    	<span style=" margin-left:75px;" class="trigger less triggerEC" id="mirDetail1" name="mirDetail" ><%=selectedID%> Details <span class="mirtooltip3"  title="Detailed Information for the miRNA selected(highlighted in green above). Simply click on an miRNA ID above to view different information."><img src="<%=imagesDir%>icons/info.gif"></span></span>
		</div>
	<%if(mirList.size()>0){
		MiRResult selected=null;
		boolean useID=false;
		if(selectedID.indexOf("-")>-1){
			useID=true;
		}
		for(int i=0;i<mirList.size()&&selected==null;i++){
			if(!useID && selectedID.equals(mirList.get(i).getAccession())){
				selected=mirList.get(i);
			}else if(useID && selectedID.equals(mirList.get(i).getId())){
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
        
	  
      <BR /><BR />
      <div id="mirDetail">
      
      <div><div style="text-align:left;font-size:18px; font-weight:bold;width:100%;"> Validated Database Results</div>
          <table id="mirValTbl" name="items" class="list_base" style="text-align:center;width:100%;">
                <thead>
                    <TR class="col_title">
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
    
    	<BR /><BR />
        <div id="miTargetGenerna"><div style="text-align:left;font-size:18px; font-weight:bold;width:100%;"> All Genes Targeted by <%=selectedID%></div><BR />
              <div id="wait3" align="center" style="position:relative;top:0px;"><img src="<%=imagesDir%>wait.gif" alt="Working..." text-align="center" >
				<BR />Running multiMiR...</div>
       </div>
    
    
    
    
    <%}%>
</div>
</div>

 
<script type="text/javascript">
	var rows=$("table#mirPredTbl tr");
	stripeTable(rows);
	rows=$("table#mirValTbl tr");
	stripeTable(rows);
	/*rows=$("table#mirGeneTbl tr");
	stripeTable(rows);*/
	
	$(".mirtooltip3").tooltipster({
				position: 'top-right',
				maxWidth: 250,
				offsetX: 10,
				offsetY: 5,
				contentAsHTML:true,
				//arrow: false,
				interactive: true,
				interactiveTolerance: 350
			});
	
	function runMultiMirTargets(){
			var species="<%=myOrganism%>";
			var id="<%=id%>";
			var table=$('select#table').val();
			var predType=$('select#predType').val();
			var cutoff=$('input#cutoff').val();
			var selectID="<%=selectedID%>";
			$.ajax({
				url: contextPath + "/web/GeneCentric/runMultiMiRGeneTargets.jsp",
   				type: 'GET',
				data: {species:species,id:id,table:table,predType:predType,cutoff:cutoff,selectedID:selectID},
				dataType: 'html',
				complete: function(){
					//$('#imgLoad').hide();
					$('#wait3').hide();
					$('#miTargetGenerna').show();
				},
    			success: function(data2){ 
        			$('#miTargetGenerna').html(data2);
    			},
    			error: function(xhr, status, error) {
        			$('#miTargetGenerna').html("<div>An error occurred generating this image.  Please try back later.</div>");
    			}
			});
		}
	
	runMultiMirTargets();
	
</script>