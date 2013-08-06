<%@ include file="/web/common/session_vars.jsp" %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<%
	
    gdt.setSession(session);
	ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> fullGeneList=new ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene>();
	String selectedID="";
	if(request.getParameter("selectedID")!=null){
		selectedID=request.getParameter("selectedID");
	}
%>
<a href="web/GeneCentric/geneApplet.jsp?selectedID=<%=selectedID%>" target="_blank">View Affy Probe Set Details</a>
<BR /><BR />
<div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000; text-align:left; width:100%; ">
    <span class="trigger less" name="geneReport"  style="margin-left:30px;">Gene Details</span>
    <div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div>
</div>
<div id="geneReport" >
Add report here.
</div>
<BR /><BR />
<div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000; text-align:left; width:100%; ">
    <span class="triggerNoAction" name="geneReportEQTL"  style="margin-left:30px;">Gene EQTLs (Circos Plot)</span>
    <div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div>
</div>
<div id="geneReportEQTL" style="display:none;"></div>
            
<BR /><BR />



<script type="text/javascript">
	$("span[name='geneReportEQTL']").click(function (){
        var thisHidden = $("div#geneReportEQTL").is(":hidden");
        if (thisHidden) {
			$("div#geneReportEQTL").show();
			$(this).addClass("less");
			var jspPage="web/GeneCentric/geneEQTLAjax.jsp";
			var params={
				species: organism,
				geneSymbol: selectedGeneSymbol,
				chromosome: chr,
				id:selectedID
			};
			loadDivWithPage("div#geneReportEQTL",jspPage,params,
					"<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Laoding...</span>");
        } else {
			$("div#geneReportEQTL").hide();
			$(this).removeClass("less");
        }
		});
</script>


