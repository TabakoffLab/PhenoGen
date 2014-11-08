<%@ include file="/web/common/anon_session_vars.jsp" %>
<%
    String geneID="";
    String org="";
    String dispType="single";
    String viewType="gene";
    if(request.getParameter("id")!=null){
            geneID=request.getParameter("id");
    }
%>
<div style="text-align:center;"
    <div id="wgcnaImageControls" style="display:inline-block;width:100%;">

    </div>
    <BR>
    <div id="wgcnaMouseHelp" style="display:inline-block;width:100%;text-align:center;">
        Navigation Hints: Hold mouse over areas of the image for available actions.
    </div>
    <div id="wgcnaGeneImage" style="width:98%;border:1px solid;text-align: center;">

    </div>
</div>

<script type="text/javascript">
    var disptype="<%=dispType%>";
    var viewtype="<%=viewType%>";
    var wgcnaid="<%=geneID%>";
    var tissue="Brain";
    var modulePrefix="";
    var wgcna=WGCNABrowser(wgcnaid,disptype,viewtype,tissue);
    wgcna.setup();
</script>