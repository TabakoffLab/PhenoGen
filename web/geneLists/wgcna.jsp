<%--
 *  Author: Spencer Mahaffey
 *  Created: December, 2011
 *  Description:  The web page created by this file allows the user to
 *              select data to compute exon to exon correlations to look by eye for alternate splicing.
 *  Todo:
 *  Modification Log:
 *
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %>

<%
        extrasList.add("d3.v3.min.js");
        extrasList.add("jquery.dataTables.1.10.9.min.js");
        extrasList.add("wgcnaBrowser1.0.9.js");
        extrasList.add("svg-pan-zoom.3.2.3.min.js");
        extrasList.add("tableExport/tableExport.js");
        extrasList.add("tableExport/jquery.base64.js");
        //extrasList.add("jquery.dataTables.min.css");

        //extrasList.add("smoothness/jquery-ui.1.11.3.min.css");

        log.info("in wgcna.jsp. user =  "+ user);
        optionsList.add("geneListDetails");
        optionsList.add("chooseNewGeneList");

	request.setAttribute( "selectedTabId", "wgcna" );

        mySessionHandler.createGeneListActivity("Looked at WGCNA a GeneList", pool);
        String myOrganism=selectedGeneList.getOrganism();
%>

<%@ include file="/web/GeneCentric/browserCSS.jsp" %>
<%@ include file="/web/common/header_adaptive_menu.jsp" %>
<%@ include file="/web/geneLists/include/viewingPane.jsp" %>

<script>
        var organism="<%=selectedGeneList.getOrganism()%>";
        var pathPrefix="../GeneCentric/";
        var contextRoot="<%=contextRoot%>";
        var tt=d3.select("body").append("div")   
	    	.attr("class", "testToolTip")
	    	.style("z-index",1001) 
	    	.attr("pointer-events", "all")              
	    	.style("opacity", 0);
        var fixedWidth=1000;
        var testChrome=/chrom(e|ium)/.test(navigator.userAgent.toLowerCase());
        var testSafari=/safari/.test(navigator.userAgent.toLowerCase());
        var testFireFox=/firefox/.test(navigator.userAgent.toLowerCase());
        var testIE=/(wow|.net|ie)/.test(navigator.userAgent.toLowerCase());
        if(testChrome && testSafari){
            testSafari=false;
        }
</script>

	<div class="page-intro">
            <p> Select modules below that contain genes from the selected Gene List to view additional details.</p>
	</div> <!-- // end page-intro -->

	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>
        <div class="leftTitle">WGCNA<span class="helpImage" id="HelpGeneListWGCNATab" ><img src="<%=imagesDir%>icons/help.png" </span></div>
    <div style="font-size:14px">
        <%@ include file="/web/GeneCentric/wgcnaGeneCommon.jsp" %>
    </div><!-- end primary content-->

    
<%@ include file="/web/GeneCentric/resultsHelp.jsp" %>
<script type="text/javascript">
    $('.helpImage').on('click', function(event){
			var id=$(this).attr('id');
			$('#'+id+'Content').dialog( "option", "position",{ my: "right top", at: "left bottom", of: $(this) });
			$('#'+id+'Content').dialog("open").css({'font-size':12});
			event.stopPropagation();
			//return false;
		}
		);
</script>

<%@ include file="/web/common/footer_adaptive.jsp" %>


