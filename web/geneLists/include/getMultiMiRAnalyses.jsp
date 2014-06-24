<%@ include file="/web/common/session_vars.jsp" %>
<jsp:useBean id="miRT" class="edu.ucdenver.ccp.PhenoGen.tools.mir.MiRTools" scope="session"> </jsp:useBean>
<jsp:useBean id="myGeneList" class="edu.ucdenver.ccp.PhenoGen.data.GeneList"/>
<jsp:useBean id="myGeneListAnalysis" class="edu.ucdenver.ccp.PhenoGen.data.GeneListAnalysis"/>

<%
	miRT.setup(pool,session);
	
	String id="";
	
	if(request.getParameter("geneListID")!=null){
		id=request.getParameter("geneListID");
	}
	
	GeneListAnalysis[] results=myGeneListAnalysis.getGeneListAnalysisResults(userLoggedIn.getUser_id(), Integer.parseInt(id), "multiMiR", pool);
	
	boolean running=false;
%>

<table id="resultTbl" name="items" class="list_base" style="text-align:center;width:100%;">
	<thead>
    	<TR class="col_title">
        	<TH>Name</TH>
            <TH>Date</TH>
            <TH>Status</TH>
        </TR>
    </thead>
    <tbody>
    	<%for(int i=0;i<results.length;i++){
			if(results[i].getStatus().equals("Running")){
					running=true;
			}
		%>
        	<TR>
            	<TD><%=results[i].getName()%></TD>
                <TD><%=results[i].getCreate_date_as_string()%></TD>
                <TD><%=results[i].getStatus()%></TD>
            </TR>
        <%}%>
    </tbody>
</table>
<script type="text/javascript">
	var tblMir=$('#resultTbl').dataTable({
			"bPaginate": false,
			//"sScrollX": "100%",
			//"sScrollY": "350px",
			"bDeferRender": true
	});
	<%if(running){%>
			setTimeout(function (){
				runGetMultiMiRResults();
			},30000);
	<%}%>
	
</script>