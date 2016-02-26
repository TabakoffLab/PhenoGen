<%@ include file="/web/common/anon_session_vars.jsp" %>
<jsp:useBean id="miRT" class="edu.ucdenver.ccp.PhenoGen.tools.mir.MiRTools" scope="session"> </jsp:useBean>
<jsp:useBean id="myGeneList" class="edu.ucdenver.ccp.PhenoGen.data.GeneList"/>
<jsp:useBean id="myGeneListAnalysis" class="edu.ucdenver.ccp.PhenoGen.data.GeneListAnalysis"/>
<jsp:useBean id="myParameterValue" class="edu.ucdenver.ccp.PhenoGen.data.ParameterValue"/>
<jsp:useBean id="anonU" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser" scope="session" />
<%
	miRT.setup(pool,session);
	if(userLoggedIn.getUser_name().equals("anon")){
            miRT.setAnonUser(anonU);
        }
	String id="";
	
	if(request.getParameter("geneListID")!=null){
		id=request.getParameter("geneListID");
	}
	
	GeneListAnalysis[] results=new GeneListAnalysis[0];
	if(userLoggedIn.getUser_name().equals("anon")){
            results=myGeneListAnalysis.getAnonGeneListAnalysisResults(-20, Integer.parseInt(id),  "multiMiR", pool);
        }else{
            results=myGeneListAnalysis.getGeneListAnalysisResults(userLoggedIn.getUser_id(), Integer.parseInt(id), "multiMiR", pool);
        }
	boolean running=false;
	
%>
<style>
	table#resultTbl tr.selected td{
		background:	#bed9ba;
	}
</style>
<BR />
<table id="resultTbl" name="items" class="list_base" style="text-align:center;width:100%;">
	<thead>
    	<TR class="col_title">
        	<TH>Name</TH>
            <TH>Date</TH>
            <TH>Status</TH>
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
			
			
			String tables="";
			
			String cutofftype="";
			
			String cutoffStr="";
			
			String disease="";
			if(results[i].getParameter_group_id()>-99){
				ParameterValue[] pv=myParameterValue.getParameterValues(results[i].getParameter_group_id(),pool);
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
		%>
        	<TR class="arid<%=results[i].getAnalysis_id()%>">
            	<TD><%=results[i].getName()%> <span class="mirResultInfo"  title="Tables Searched: <%=tables%><BR><BR>Predicted Cutoff Type/Value: <%=cutoffStr%><BR><BR>Disease/Drug Terms: <%=disease%>"><img src="<%=imagesDir%>icons/info.gif"></span></TD>
                <TD><%=results[i].getCreate_date_as_string()%></TD>
                <TD><%=results[i].getStatus()%></TD>
                <TD>
                	<%if(complete){%>
                	<span class="mirResultDetail" id="<%=results[i].getAnalysis_id()%>" style="cursor:pointer;text-decoration:underline;">View Results</span>
                    <%}%>
                </TD>
                <TD class="actionIcons"><span class="delete" id="del<%=results[i].getAnalysis_id()%>"><img src="<%=imagesDir%>icons/delete.png"></span></td>
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
	
	$(".mirResultDetail").on("click",function (){
		var id=$(this).attr('id');
		$.ajax({
				url: contextPath + "/web/geneLists/include/getMultiMiRResult.jsp",
   				type: 'GET',
				data: {geneListAnalysisID:id},
				dataType: 'html',
				beforeSend: function(){
					$('#resultLoading').show();
					$('#mirresultDetail').html("");
					$('table#resultTbl tr.selected').removeClass("selected");
					$('table#resultTbl tr.arid'+id).addClass("selected");
				},
    			success: function(data2){ 
        			
					$('#mirResult').html(data2);
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