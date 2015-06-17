<%@ include file="/web/common/session_vars.jsp" %>
<jsp:useBean id="goT" class="edu.ucdenver.ccp.PhenoGen.tools.go.GOTools" scope="session"> </jsp:useBean>
<jsp:useBean id="myGeneList" class="edu.ucdenver.ccp.PhenoGen.data.GeneList"/>
<jsp:useBean id="myGeneListAnalysis" class="edu.ucdenver.ccp.PhenoGen.data.GeneListAnalysis"/>
<jsp:useBean id="myParameterValue" class="edu.ucdenver.ccp.PhenoGen.data.ParameterValue"/>

<%
       
	goT.setup(pool,session);
	String id="";
	if(request.getParameter("geneListAnalysisID")!=null){
		id=request.getParameter("geneListAnalysisID");
	}
	
	GeneListAnalysis result=myGeneListAnalysis.getGeneListAnalysis(Integer.parseInt(id), pool);
        GeneList geneList=result.getAnalysisGeneList();
	String part=userLoggedIn.getUserGeneListsDir();
        part=part.substring(part.indexOf("userFiles"));
        String fullPath= contextRoot+part+ geneList.getGene_list_name_no_spaces() +"/GO/"+result.getPath()+"/";
        String file="output.json";
	
%>
<style>
    .dataTables_filter{
        display:inline-block;
    }
    .dataTables_info{
        display:inline-block;
        float:right;
    }
</style>
<%@ include file="/web/GeneCentric/browserCSS.jsp" %>
<H1 style="color:#000000;">Results - <%=result.getName()%> </H1>

<div id="resultSummary" style="width:100%;">
<div style="text-align:center;">
    <div id="wgcnaImageControls" style="display:inline-block;width:100%;">
        <table style="width:100%;">
            <TR>
                <TD style="text-align: left;" id="imageControl"></TD>
                <TD style="text-align: center;" id="dataControl"></TD>
                <TD style="text-align: right;" id="viewControl"></TD>
            </TR>
        </table>
    </div>
    <BR>
    <div id="wgcnaMouseHelp" style="display:inline-block;width:100%;text-align:center;">
        Navigation Hints: Hold mouse over areas of the image for available actions.
    </div>
    <div id="wgcnaGeneImage" style="/*width:99%;*/border:1px solid;text-align: center;">
        <div id="waitCircos" align="center" ><img src="<%=imagesDir%>wait.gif" alt="Working..." text-align="center" ><BR>Loading...</div>
    </div>
    <div id="tableExportCtl" style="float:right;"></div>
    <div id="wgcnaGoTable" style="display:none;/*width:99%;*/border:1px solid;text-align: center;">
        <div id="waitGoTable" align="center" ><img src="<%=imagesDir%>wait.gif" alt="Loading..." text-align="center" ><BR>Loading...</div>
        <H2>Gene Ontology Terms for Genes in the <span id="GoTableName">Selected</span> Module</h2><BR>
        Click on any row to make it the root of the table and image.
        <div style="text-align:left;">
        <table  id="GoTable" width="100%">
            <thead>
                <TR class="col_title">
                    <TH>Name<span title="Expand All" id="goExpand" style="float:left;"><img src="<%=imagesDir%>icons/add.png"></span><span title="Close All" id="goClose" style="float:left;"><img src="<%=imagesDir%>icons/min.png"></span><span title="Go up a level (set root to the parent term)" id="goUp" style="float:left;"><img width="14" height="14" src="<%=imagesDir%>icons/up_flat.png"></span></TH>
                    <TH>Definition</th>
                    <TH>Genes<span title="Expand All" id="goGLExpand" style="float:left;"><img src="<%=imagesDir%>icons/add.png"></span><span title="Close All" id="goGLClose" style="float:left;"><img src="<%=imagesDir%>icons/min.png"></span></th>
                </TR>
            </thead>
            <tbody>
                
            </tbody>
        </table>
        </div>
    </div>
</div>
                
               

<script type="text/javascript">
    var contextRoot="<%=contextRoot%>";
    var goBrwsr=GOBrowser("<%=fullPath%>","<%=file%>");
    goBrwsr.setup();
</script>