<%@ include file="/web/common/anon_session_vars.jsp" %>
<%
    String geneID="";
    String org="";
    String dispType="single";
    String viewType="gene";
    String region="";
    if(request.getParameter("id")!=null){
            geneID=request.getParameter("id");
    }
    if(request.getParameter("region")!=null){
            region=request.getParameter("region");
    }
%>

<div style="text-align:center;"
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
    <div id="wgcnaGeneImage" style="width:98%;border:1px solid;text-align: center;">
        <div id="waitCircos" align="center" ><img src="<%=imagesDir%>wait.gif" alt="Working..." text-align="center" ><BR>Loading...</div>
    </div>
    <div id="wgcnaModuleTable" style="display:none;width:98%;border:1px solid;text-align: center;">
        <div id="waitModuleTable" align="center" ><img src="<%=imagesDir%>wait.gif" alt="Loading..." text-align="center" ><BR>Loading...</div>
    </div>
</div>

<script type="text/javascript">
    var disptype="<%=dispType%>";
    var viewtype="<%=viewType%>";
    var wgcnaid="<%=geneID%>";
    var wgcnaregion="<%=region%>";
    var tissue="Whole Brain";
    var modulePrefix="";
    var wgcna=WGCNABrowser(wgcnaid,wgcnaregion,disptype,viewtype,tissue);
    wgcna.setup();
</script>