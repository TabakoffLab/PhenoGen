<%--
 *  Author: Cheryl Hornbaker
 *  Created: Apr, 2009
 *  Description:  This file displays the page for performing a gene list comparison with all other gene lists.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %> 

<jsp:useBean id="anonU" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser" scope="session" />

<%
	log.debug("in compareWithAllGeneLists.jsp");
	request.setAttribute( "selectedTabId", "compare" );
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");

	GeneList.Gene[] myGenes = new GeneList.Gene[0];
        if(userLoggedIn.getUser_name().equals("anon")){
            AnonGeneList sgl=(AnonGeneList) selectedGeneList;
            myGenes = sgl.findContainingGeneLists(anonU.getUUID(), pool);
        }else{
            myGenes = selectedGeneList.findContainingGeneLists(userID, pool);
        }
	mySessionHandler.createGeneListActivity("Compared '" + selectedGeneList.getGene_list_name() + "' with all gene lists", pool);

%>

<%@ include file="/web/common/header_adaptive_menu.jsp" %>



	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>
	<div class="page-intro">
		<p> To compare this list with only one other gene list, click the 'Compare With One Gene List' link.  Otherwise, listed below are the other gene lists that contain the same identifiers in this gene list.
		</p>
	</div> <!-- // end page-intro -->

	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>

	<div class="dataContainer" style="padding-bottom:70px;">
		<div class="menuBar">
        		<div id="tabMenu">
                        	<div class="left inlineButton"><a href="compareWithOneGeneList.jsp?geneListID=<%=selectedGeneList.getGene_list_id()%>">Compare With One Gene List</a></div>
			</div> <!-- tabMenu -->
		</div> <!-- menuBar -->

                <form name="tableList" action="compareWithAllGeneLists.jsp" method="post">
                        <div class="brClear"> </div>
                        <div class="title">  Gene Lists Containing the Same Genes
                        	<span class="info" title="This displays other gene lists that contain the same genes found in this gene list.">
                        	<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        	</span>
			</div>

			<div class="scrollable">
                        <table name="items" id="geneLists" class="list_base tablesorter" cellpadding="0" cellspacing="3" width="90%">
                        <thead>
                        <tr class="col_title">
                                <th>Gene Identifier</th>
                                <th>Gene Lists Containing the Same Identifier</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                        for (int i=0; i<myGenes.length; i++) {
				GeneList.Gene thisGene = myGenes[i];
				Set containingGeneLists = thisGene.getContainingGeneLists();
				%>
                                <tr>
                                	<td><%=thisGene.getGene_id()%></td>
                                        <td>
					<% if (containingGeneLists != null && containingGeneLists.size() > 0) {
						for (Iterator itr = containingGeneLists.iterator(); itr.hasNext();) {
							GeneList thisGeneList = (GeneList) itr.next();
							%><a href="chooseGeneList.jsp?geneListID=<%=thisGeneList.getGene_list_id()%>"><%=thisGeneList.getGene_list_name()%><%=fiveSpaces%></a>
						<% } %>
					<% } else { %>
							No other gene lists contain this identifier	
					<% } %> 
					</td>
				</tr>
                                <%
                        }
                        %>
                        </tbody>
                        </table>
                	</div>

			<input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>" >
			<input type="hidden" name="action" value="" >
        	</form>
		</div>

  <div class="itemDetails"></div>

  <script type="text/javascript">
    $(document).ready(function() {
	setTimeout("setupMain()", 100); 
    });
  </script>

<%@ include file="/web/common/footer_adaptive.jsp" %>


