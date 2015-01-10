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
        extrasList.add("jquery.dataTables.js");
        extrasList.add("wgcnaBrowser0.3.js");
        extrasList.add("svg-pan-zoom.min.js");
        extrasList.add("tableExport/tableExport.js");
        extrasList.add("tableExport/jquery.base64.js");
        //extrasList.add("tableExport/jspdf/libs/sprintf.js");
        //extrasList.add("tableExport/jspdf/jspdf.js");
        //extrasList.add("tableExport/jspdf/libs/base64.js");

        extrasList.add("smoothness/jquery-ui.1.11.1.min.css");

        log.info("in wgcna.jsp. user =  "+ user);
        optionsList.add("geneListDetails");
        optionsList.add("chooseNewGeneList");

	request.setAttribute( "selectedTabId", "wgcna" );

        mySessionHandler.createGeneListActivity("Looked at WGCNA a GeneList", dbConn);
%>

<%@ include file="/web/GeneCentric/browserCSS.jsp" %>
<%@ include file="/web/common/header.jsp" %>
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
</script>

	<div class="page-intro">
            <p> Select modules below that contain genes from the selected Gene List to view additional details.</p>
	</div> <!-- // end page-intro -->

	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>
    <div class="leftTitle">WGCNA</div>
    <div style="font-size:14px">
        <%@ include file="/web/GeneCentric/wgcnaGeneCommon.jsp" %>
    </div><!-- end primary content-->

    

<%@ include file="/web/common/footer.jsp" %>


