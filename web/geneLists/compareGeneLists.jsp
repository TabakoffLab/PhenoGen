<%--
 *  Author: Cheryl Hornbaker
 *  Created: Apr, 2009
 *  Description:  This file displays the page for performing a gene list comparison.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %> 

<%
	log.debug("in compareGeneLists.jsp");
	request.setAttribute( "selectedTabId", "compare" );
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
	mySessionHandler.createGeneListActivity("Looked at compare genelists tab", dbConn);
%>

<%@ include file="/web/common/header.jsp" %>

	<script type="text/javascript">
		var crumbs = ["Home", "Research Genes", "Compare"];
	</script>

	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>
	<div class="page-intro">
		<p> To compare this list with only one other gene list, click 'Compare With One Gene List' link.  To compare this gene list with all other gene lists, click the 'Compare With All Gene Lists' link.
		</p>
	</div> <!-- // end page-intro -->

	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>
	<div class="dataContainer">

	<BR>
	<div class="menuBar">
        	<div id="tabMenu">
                 <div class="left inlineButton"><a href="compareWithOneGeneList.jsp?geneListID=<%=selectedGeneList.getGene_list_id()%>" >Compare With One Gene List</a></div>
						<span>|</span>
                 <div class="left inlineButton"><a href="compareWithAllGeneLists.jsp?geneListID=<%=selectedGeneList.getGene_list_id()%>">Compare With All Gene Lists</a></div>
		</div> <!-- tabMenu -->
	</div> <!-- menuBar -->
	<BR>
	</div>
                <form name="" action="" method="post">
			<input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>" >
        	</form>
<script type="text/javascript">
	$(document).ready(function() {
		setTimeout("setupMain()", 100); 
	});
</script>

<%@ include file="/web/common/footer.jsp" %>


