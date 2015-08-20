<%--
 *  Author: Spencer Mahaffey
 *  Created: June, 2015
 *  Description:  This file retreives the Promotor Analyses for a gene list and is setup to be called from an ajax request not as a standalone page.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/common/session_vars.jsp" %>
<jsp:useBean id="myGeneList" class="edu.ucdenver.ccp.PhenoGen.data.GeneList"/>
<jsp:useBean id="myGeneListAnalysis" class="edu.ucdenver.ccp.PhenoGen.data.GeneListAnalysis"/>
<jsp:useBean id="myParameterValue" class="edu.ucdenver.ccp.PhenoGen.data.ParameterValue"/>
<%
        log.debug("test very begining");
	//int userID=userLoggedIn.getUser_id();
        int geneListID=-99;
        if(request.getParameter("geneListID")!=null){
		geneListID=Integer.parseInt(request.getParameter("geneListID"));
	}
	GeneListAnalysis[] results=new GeneListAnalysis[0];
        boolean running=false;
        log.debug("test begining");
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
            <TH>Type</TH>
            <TH>Description</TH>
            <TH>Date</TH>
            <TH>Status</TH>
            <TH>View Results</TH>
            <TH>Delete</TH>
        </TR>
    </thead>
    <tbody>
    	<%if(!selectedGeneList.getOrganism().equals("Rn")){
            results = myGeneListAnalysis.getGeneListAnalysisResults(userID, geneListID, "oPOSSUM", pool);
            if(results!=null){
                for(int i=0;i<results.length;i++){
                        boolean complete=false;
                        String stat="Finished";
                        if(results[i].getStatus()!=null){
                            stat=results[i].getStatus();
                            if(stat.equals("Running")){
                                            running=true;
                            }else if(stat.equals("Complete")){
                                            complete=true;
                            }
                        }else{
                            complete=true;
                        }
                    %>
                    <TR class="arid<%=results[i].getAnalysis_id()%>">
                        <TD>oPOSSUM</td>
                    <TD><%=results[i].getDescription()%> </TD>
                    <TD><%=results[i].getCreate_date_as_string()%></TD>
                    <TD><%=stat%></TD>
                    <TD>
                        <%if(complete){%>
                            <span class="promoterResultDetail" id="<%=results[i].getAnalysis_id()%>" type="oPOSSUM" style="cursor:pointer;text-decoration:underline;">View Results</span>
                        <%}%>
                    </TD>
                    <TD class="actionIcons"><span class="delete" id="del<%=results[i].getAnalysis_id()%>"><img src="<%=imagesDir%>icons/delete.png"></span></td>
                </TR>
            <%  }
            }
        }%>
        
    <%  
        results = myGeneListAnalysis.getGeneListAnalysisResults(userID, geneListID, "MEME", pool);
        if(results!=null){
            for(int i=0;i<results.length;i++){
                boolean complete=false;
                String stat="Finished";
                if(results[i].getStatus()!=null){
                    stat=results[i].getStatus();
                    if(stat.equals("Running")){
                                    running=true;
                    }else if(stat.equals("Complete")){
                                    complete=true;
                    }
                }else{
                    complete=true;
                }
                ParameterValue myPV=new ParameterValue();
                ParameterValue[] pv=myPV.getParameterValues(results[i].getParameter_group_id(),pool);
                ParameterValue gvParam=myPV.getParameterValueFromMyParameterValues(pv,"Genome Version");
                String thisGenomeVer="";
                    if(gvParam!=null){
                        thisGenomeVer="Genome Version: "+gvParam.getValue();
                    }
        %>
        	<TR class="arid<%=results[i].getAnalysis_id()%>">
                <TD>MEME</td>
            	<TD><%=results[i].getDescription()%> <%=thisGenomeVer%> </TD>
                <TD><%=results[i].getCreate_date_as_string()%></TD>
                <TD><%=stat%></TD>
                <TD>
                	<%if(complete){%>
                	<span class="promoterResultDetail" id="<%=results[i].getAnalysis_id()%>" type="MEME" style="cursor:pointer;text-decoration:underline;">View Results</span>
                    <%}%>
                </TD>
                <TD class="actionIcons"><span class="delete" id="del<%=results[i].getAnalysis_id()%>"><img src="<%=imagesDir%>icons/delete.png"></span></td>
                </TR>
        <%  }
        }
        results = myGeneListAnalysis.getGeneListAnalysisResults(userID, geneListID, "Upstream", pool);
        if(results!=null){
            for(int i=0;i<results.length;i++){
                boolean complete=false;
                String stat="Finished";
                if(results[i].getStatus()!=null){
                    stat=results[i].getStatus();
                    if(stat.equals("Running")){
                                    running=true;
                    }else if(stat.equals("Complete")){
                                    complete=true;
                    }
                }else{
                    complete=true;
                }%>
        	<TR class="arid<%=results[i].getAnalysis_id()%>">
                    <TD>Upstream</td>
            	<TD><%=results[i].getDescription()%> </TD>
                <TD><%=results[i].getCreate_date_as_string()%></TD>
                <TD><%=stat%></TD>
                <TD>
                    <%if(complete){%>
                	<span class="promoterResultDetail" id="<%=results[i].getAnalysis_id()%>" type="Upstream" style="cursor:pointer;text-decoration:underline;">View Results</span>
                    <%}%>
                </TD>
                <TD class="actionIcons"><span class="delete"  id="del<%=results[i].getAnalysis_id()%>"><img src="<%=imagesDir%>icons/delete.png"></span></td>
            </TR>
        <%  }
        }%>
        
    </tbody>
</table>
<script type="text/javascript">
        
	
	<%if(!running){%>
			stopRefresh();
	<%}else if(running){%>
			startRefresh();
	<%}%>
        (function($){
            $('#resultTbl').dataTable({
            
			"bPaginate": false,
			"bDeferRender": true,
			"aaSorting": [[ 2, "desc" ]],
			"sDom": '<r><t>'
            });
            $(".promoterResultDetail").on("click",function (){
                    var id=$(this).attr('id');
                    var type=$(this).attr('type');
                    
                    $.ajax({
                                    url: contextPath + "/web/geneLists/include/getPromoterResult.jsp",
                                    type: 'GET',
                                    data: {geneListAnalysisID:id,type:type},
                                    dataType: 'html',
                                    beforeSend: function(){
                                            $('#resultLoading').show();
                                            $('table#resultTbl tr.selected').removeClass("selected");
                                            $('table#resultTbl tr.arid'+id).addClass("selected");
                                    },
                            success: function(data2){ 
                                $('#resultLoading').hide();
                                $('#promoterResult').html(data2);
                            },
                            error: function(xhr, status, error) {
                                    $('#promoterResult').html("Error retreiving result.  Please try again.");
                                    $('#resultLoading').hide();
                            }
                            });
            });
            $(".delete").on("click",function(){
                idToDelete=$(this).attr("id").substr(3);
                $( "#dialog-delete-confirm" ).dialog("open");
            });
        })(jQuery);
        
        
        

</script>