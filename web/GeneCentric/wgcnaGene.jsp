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
<div id="wgcnaImageControls" style="width:100%;">
    
</div>
<div id="wgcnaMouseHelp" style="width:100%;text-align:center;">
    Navigation Hints: Hold mouse over areas of the image for available actions.
</div>
<div id="wgcnaGeneImage" style="max-height:600px;overflow:auto;width:100%;border:1px solid;">
    
</div>
<div id="wgcnaViewControls" >
</div>
<div id="wgcnaDataControls">
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