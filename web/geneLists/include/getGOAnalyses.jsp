<%@ include file="/web/common/anon_session_vars.jsp" %>
<jsp:useBean id="goT" class="edu.ucdenver.ccp.PhenoGen.tools.go.GOTools" scope="session"> </jsp:useBean>
<jsp:useBean id="myGeneList" class="edu.ucdenver.ccp.PhenoGen.data.GeneList"/>
<jsp:useBean id="myGeneListAnalysis" class="edu.ucdenver.ccp.PhenoGen.data.GeneListAnalysis"/>
<jsp:useBean id="myParameterValue" class="edu.ucdenver.ccp.PhenoGen.data.ParameterValue"/>
<jsp:useBean id="myFH" class="edu.ucdenver.ccp.util.FileHandler"/>
<jsp:useBean id="anonU" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser" scope="session" />
<%
	goT.setup(pool,session);
        if(userLoggedIn.getUser_name().equals("anon")){
            goT.setAnonUser(anonU);
        }
	String id="";
	if(request.getParameter("geneListID")!=null){
		id=request.getParameter("geneListID");
	}
        log.debug("before gene list analysis");
	GeneListAnalysis[] results=new GeneListAnalysis[0];
        if(userLoggedIn.getUser_name().equals("anon")){
                results=myGeneListAnalysis.getAnonGeneListAnalysisResults(-20, Integer.parseInt(id), "GO", pool);
        }else{
                results=myGeneListAnalysis.getGeneListAnalysisResults(userLoggedIn.getUser_id(), Integer.parseInt(id), "GO", pool);
        }
        log.debug("after gene list analysis. # results:"+results.length);
	boolean running=false;
%>
<BR />
<table id="resultTbl" name="items" class="list_base" style="text-align:center;width:96%;">
	<thead>
    	<TR class="col_title">
        	<TH>Name</TH>
            <TH>Date</TH>
            <TH>Status</TH>
            <TH>Ensembl Ver.</TH>
            <TH>View Results</TH>
            <TH>Delete</TH>
        </TR>
    </thead>
    <tbody>
    	<%for(int i=0;i<results.length;i++){
			boolean complete=false;
			if(results[i].getStatus().equals("Running")){
					running=true;
			}else if(results[i].getStatus().equals("Complete")){
					complete=true;
			}
                    String[] ver=new String[1];
                    ver[0]="?";
                    String verPath=userLoggedIn.getUserGeneListsDir()+ results[i].getAnalysisGeneList().getGene_list_name_no_spaces() +"/GO/"+results[i].getPath()+"/ver.txt";
                    File verFile=new File(verPath);
                    if(verFile.exists()){
                        ver=myFH.getFileContents(verFile);
                    }
		%>
        	<TR class="arid<%=results[i].getAnalysis_id()%>">
            	<TD><%=results[i].getName()%></TD>
                <TD><%=results[i].getCreate_date_as_string()%></TD>
                <TD><%=results[i].getStatus()%></TD>
                <TD>v<%=ver[0]%></TD>
                <TD>
                	<%if(complete){%>
                	<span class="goResultDetail" id="<%=results[i].getAnalysis_id()%>" style="cursor:pointer;text-decoration:underline;">View Results</span>
                    <%}%>
                </TD>
                <TD><span class="delete" id="del<%=results[i].getAnalysis_id()%>"><img src="<%=imagesDir%>icons/delete.png"></span></TD>
            </TR>
        <%}%>
    </tbody>
</table>
<script type="text/javascript">
	//var rows=$("table#mirTbl tr");
	//stripeTable(rows);

	var tblMir=$('#resultTbl').dataTable({
			"bPaginate": false,
			"bDeferRender": true,
			"aaSorting": [[ 1, "desc" ]],
			"sDom": '<r><t>'
	});
	
        
	$(".mirResultInfo").tooltipster({
				position: 'top-left',
				maxWidth: 450,
				offsetX: -10,
				offsetY: 5,
				contentAsHTML:true,
				//arrow: false,
				interactive: true,
				interactiveTolerance: 350
			});
	
	<%if(!running){%>
			stopRefresh();
	<%}else if(running){%>
			startRefresh();
	<%}%>
	
	$(".goResultDetail").on("click",function (){
		var id=$(this).attr('id');
		$.ajax({
				url: contextPath + "/web/geneLists/include/getGOResult.jsp",
   				type: 'GET',
				data: {geneListAnalysisID:id,geneListID:id},
				dataType: 'html',
				beforeSend: function(){
					$('#resultLoading').show();
					$('#goresultDetail').html("");
					$('table#resultTbl tr.selected').removeClass("selected");
					$('table#resultTbl tr.arid'+id).addClass("selected");
				},
    			success: function(data2){ 
					$('#goResult').html(data2);
					$('#resultLoading').hide();        
    			},
    			error: function(xhr, status, error) {
        			$('#mirResult').html("Error retreiving result.  Please try again.");
					$('#resultLoading').hide();
    			}
			});
	});
        $(".delete").on("click",function(){
                idToDelete=$(this).attr("id").substr(3);
                $( "#dialog-delete-confirm" ).dialog("open");
        });
</script>