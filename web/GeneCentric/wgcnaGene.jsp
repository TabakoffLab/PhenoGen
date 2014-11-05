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
<div id="wgncaImageControls">
</div>
<div id="wgncaGeneImage">
</div>
<div id="wgncaViewControls" style="display:none;">
</div>
<div id="wgncaDataControls" style="display:none;">
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