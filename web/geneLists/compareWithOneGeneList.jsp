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
	log.debug("in compareWithOneGeneList.jsp");
	request.setAttribute( "selectedTabId", "compare" );
        extrasList.add("compareGeneLists.js");
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
	String geneList2 = "";

        if (geneListsForUser == null) {
                log.debug("geneListsForUser not set");
                geneListsForUser = myGeneList.getGeneLists(userID, "All", "All", pool);
        }

	log.debug("action = "+action);

        GeneList selectedGeneList2 = ((GeneList) session.getAttribute("selectedGeneList2") == null ?
                        new GeneList(-99) :
                        (GeneList) session.getAttribute("selectedGeneList2"));

        int geneListID2 = ((String)request.getParameter("geneListID2") != null ?
                        Integer.parseInt((String)request.getParameter("geneListID2")) :
                        -99);

	if (geneListID2 != -99) {
		selectedGeneList2 = myGeneList.getGeneList(geneListID2, pool);
	} else {
		selectedGeneList2 = new GeneList(-99);
	}

	session.setAttribute("selectedGeneList2", selectedGeneList2);

	String intersectResult = "";
	String unionResult = "";
	String AminusBResult = "";
	String BminusAResult = "";
	Set intersectTempGeneSet = new TreeSet();
	Set unionTempGeneSet = new TreeSet();
	Set AminusBTempGeneSet = new TreeSet();
	Set BminusATempGeneSet = new TreeSet();

	if ((action != null) && action.equals("Select Gene List")) {

	        Set geneSet = new TreeSet(selectedGeneList.getGenesAsSet("Original", pool));
	        Set geneSet2 = new TreeSet(selectedGeneList2.getGenesAsSet("Original", pool));

	        geneList = myObjectHandler.getAsSeparatedString(geneSet, "\n");
	        geneList2 = myObjectHandler.getAsSeparatedString(geneSet2, "\n");

		intersectTempGeneSet = new TreeSet(geneSet);
                intersectTempGeneSet.retainAll(geneSet2);
		intersectResult = myObjectHandler.getAsSeparatedString(intersectTempGeneSet, "\n");

		unionTempGeneSet = new TreeSet(geneSet);
                unionTempGeneSet.addAll(geneSet2);
		unionResult = myObjectHandler.getAsSeparatedString(unionTempGeneSet, "\n");

		AminusBTempGeneSet = new TreeSet(geneSet2);
                AminusBTempGeneSet.removeAll(geneSet);
		AminusBResult = myObjectHandler.getAsSeparatedString(AminusBTempGeneSet, "\n");

		BminusATempGeneSet = new TreeSet(geneSet);
                BminusATempGeneSet.removeAll(geneSet2);
		BminusAResult = myObjectHandler.getAsSeparatedString(BminusATempGeneSet, "\n");

	        mySessionHandler.createSessionActivity(session.getId(), 
			"Compared two gene lists: '"+selectedGeneList.getGene_list_name() + "' and '" + selectedGeneList2.getGene_list_name() + "'",
	                pool);

		session.setAttribute("intersectTempGeneSet", intersectTempGeneSet);
		session.setAttribute("unionTempGeneSet", unionTempGeneSet);
		session.setAttribute("AminusBTempGeneSet", AminusBTempGeneSet);
		session.setAttribute("BminusATempGeneSet", BminusATempGeneSet);

	} else if (action !=null && action.equals("Save Gene List")) {

		selectedGeneList = (GeneList) session.getAttribute("selectedGeneList");
		selectedGeneList.setUserIsOwner(selectedGeneList.getCreated_by_user_id() == userID ? "Y" : "N"); 
		selectedGeneList2 = (GeneList) session.getAttribute("selectedGeneList2");
		selectedGeneList2.setUserIsOwner(selectedGeneList2.getCreated_by_user_id() == userID ? "Y" : "N"); 
		intersectTempGeneSet = (Set) session.getAttribute("intersectTempGeneSet");
		unionTempGeneSet = (Set) session.getAttribute("unionTempGeneSet");
		AminusBTempGeneSet = (Set) session.getAttribute("AminusBTempGeneSet");
		BminusATempGeneSet = (Set) session.getAttribute("BminusATempGeneSet");

		String comparisonType = "";
		if ((String) request.getParameter("comparisonType") != null) {
			comparisonType = (String) request.getParameter("comparisonType");
		}
		log.debug("comparisonType = "+comparisonType);
		// 
		// You cannot save an intersection or union gene list if they are from different
		// organisms
		//
		if ((comparisonType.equals("Intersection") || 
			comparisonType.equals("Union")) && 
			(!selectedGeneList.getOrganism().equals(selectedGeneList2.getOrganism()))) {
				session.setAttribute("errorMsg", "GL-011");
				response.sendRedirect(commonDir + "errorMsg.jsp");
		} else {
			if (comparisonType.equals("Intersection")) {
				session.setAttribute("geneListSet",intersectTempGeneSet);
				session.setAttribute("selectedGeneList",selectedGeneList);
				session.setAttribute("comparisonType","Intersection between gene list '" + selectedGeneList.getGene_list_name() + 
							"' and gene list '" + selectedGeneList2.getGene_list_name() + "'");
			} else if (comparisonType.equals("Union")) {
				session.setAttribute("geneListSet",unionTempGeneSet);
				session.setAttribute("selectedGeneList",selectedGeneList);
				session.setAttribute("comparisonType","Union of gene list '" + selectedGeneList.getGene_list_name() + 
							"' and gene list '" + selectedGeneList2.getGene_list_name() + "'");
			} else if (comparisonType.equals("AminusB")) {
				session.setAttribute("geneListSet",AminusBTempGeneSet);
				session.setAttribute("selectedGeneList",selectedGeneList);
				session.setAttribute("comparisonType","Gene list '" + selectedGeneList.getGene_list_name() + 
							"' minus gene list '" + selectedGeneList2.getGene_list_name() + "'");
			} else if (comparisonType.equals("BminusA")) {
				session.setAttribute("geneListSet",BminusATempGeneSet);
				session.setAttribute("selectedGeneList",selectedGeneList2);
				session.setAttribute("comparisonType","Gene list '" + selectedGeneList2.getGene_list_name() + 
							"' minus gene list '" + selectedGeneList.getGene_list_name() + "'");
			}

	        	mySessionHandler.createSessionActivity(session.getId(), 
				"Saved results from comparing two gene lists: '"+
				selectedGeneList.getGene_list_name() + "' and '" + selectedGeneList2.getGene_list_name() + "'",
	                	pool);

	                response.sendRedirect(geneListsDir + "nameGeneList.jsp?geneListSource=compare");
		}
	}

	
%>

<%@ include file="/web/common/header_adaptive_menu.jsp" %>



	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>
	<div class="page-intro">
		<p> To compare this list with all other gene lists, click the 'Compare With All Gene Lists' link.
		</p>
	</div> <!-- // end page-intro -->

	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>

	<div class="dataContainer" style="height:580px; overflow:auto">
		<div class="menuBar">
        		<div id="tabMenu">
                        	<div class="left inlineButton"><a href="compareWithAllGeneLists.jsp?geneListID=<%=selectedGeneList.getGene_list_id()%>">Compare With All Gene Lists</a></div>
			</div> <!-- tabMenu -->
		</div> <!-- menuBar -->

        <% if (geneListID2 == -99) { %>

                <form name="tableList" action="compareWithOneGeneList.jsp" method="post">
                        <div class="brClear"> </div>
                        <div class="title">  My Gene Lists
                        <span class="info" title="This list contains the gene lists to which you have access.">
                        <img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        </span></div>
                        <table name="items" id="geneLists" class="list_base tablesorter" cellpadding="0" cellspacing="3" width="90%">
                        <thead>
                        <tr class="col_title">
                                <th>Gene List Name</th>
                                <th>Date Created</th>
                                <th>Organism</th>
                                <th>Number of Genes</th>
                                <th class="noSort">Details</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                        for (int i=0; i<geneListsForUser.length; i++) {
                                GeneList thisGeneList = (GeneList) geneListsForUser[i];
				%>
                                <tr id="<%=thisGeneList.getGene_list_id()%>">
                                	<td><%=thisGeneList.getGene_list_name()%></td>
                                        <td><%=thisGeneList.getCreate_date_as_string().substring(0, thisGeneList.getCreate_date_as_string().indexOf(" "))%></td>
                                        <td><%=thisGeneList.getOrganism()%></td>
                                        <td><%=thisGeneList.getNumber_of_genes()%></td>
                                        <td class="details">View</td>
				</tr>
                                <%
                        }
                        %>
                        </tbody>
                        </table>

		<input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>" >
		<input type="hidden" name="geneListID2" value="" >
		<input type="hidden" name="action" value="" >
        </form>

	<% } else if (selectedGeneList2.getGene_list_id() != -99) { %>
                <div id="related_links">
			<div class="action" title="Return to select a different gene list">
				<a class="linkedImg return" href="compareWithOneGeneList.jsp?geneListID2=-99"> 
				<%=fiveSpaces%>
				Select Another Gene List For Comparison</a>
			</div>
                </div>
                <div class="viewingPane">
                        <div class="viewingTitle">You are comparing:</div>
                        <div class="listName"><%=selectedGeneList2.getGene_list_name()%>
                        	<span class="details" geneListID="<%=selectedGeneList2.getGene_list_id()%>" parameterGroupID="<%=selectedGeneList2.getParameter_group_id()%>">
                                <img src="<%=imagesDir%>icons/detailsMagnifier.gif" alt="Gene List Details">
                        	</span>
			</div>
                </div>
                <div class="brClear"></div>
		<BR>
		<form   method="post"
        		action="compareWithOneGeneList.jsp"
        		enctype="application/x-www-form-urlencoded"
	        	name="compareGeneLists"> 
			<center>

			<input type="button" value="Intersect Gene Lists" 
				onClick="showResults(compareGeneLists, intersectResult.value, 'Intersection')">	
				<%=fiveSpaces%>
			<input type="button" value="Union of Gene Lists" 
				onClick="showResults(compareGeneLists, unionResult.value, 'Union')">	
				<%=fiveSpaces%>
			<input type="button" value="Subtract List 1 From List 2" 
				onClick="showResults(compareGeneLists, AminusBResult.value, 'AminusB')">	
				<%=fiveSpaces%>
			<input type="button" value="Subtract List 2 From List 1" 
				onClick="showResults(compareGeneLists, BminusAResult.value, 'BminusA')">	
				<%=fiveSpaces%>
			<BR><BR>

			<table>
				<tr><td>
					<table class=geneListVeryNarrow>
						<tr>
						<th> Gene List 1: <strong><%=selectedGeneList.getGene_list_name()%></strong> </th>
						</tr>
						<tr><td>
						<textarea name="geneList" rows="30" cols="30" onFocus="blur()"><%=geneList%></textarea>
						</td></tr>
					</table>
				</td><td><%=fiveSpaces%></td><td>
					<table class=geneListVeryNarrow>
						<tr>
						<th> Gene List 2: <strong><%=selectedGeneList2.getGene_list_name()%></strong> </th>
						</tr>
						<tr><td>
						<textarea name="geneList2" rows="30" cols="30" onFocus="blur()"><%=geneList2%></textarea>
						</td></tr>
					</table>
				</td><td><%=fiveSpaces%></td><td>
					<table class=geneListVeryNarrow>
						<tr>
						<th> <strong>Results</strong> <span id="numberOfGenes"></span> <%=fiveSpaces%><input type="submit" name="action" onClick="return IsFormComplete()" value="Save Gene List">
						</th>
						</tr>
						<tr><td>
						<textarea name="resultGeneList" rows="30" cols="30" onFocus="blur()"></textarea>
						</td></tr>
					</table>
				</td></tr>
			</table>	
		</center>
		<input type="hidden" name="intersectResult" value="<%=intersectResult%>">
		<input type="hidden" name="unionResult" value="<%=unionResult%>">
		<input type="hidden" name="AminusBResult" value="<%=AminusBResult%>">
		<input type="hidden" name="BminusAResult" value="<%=BminusAResult%>">
		<input type="hidden" name="comparisonType" value="">
		<input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>">
		<input type="hidden" name="geneListID2" value="<%=selectedGeneList2.getGene_list_id()%>">
		
		<input type="hidden" id="AminusBTempGeneSetSize"   name="AminusBTempGeneSetSize"   value="<%= AminusBTempGeneSet.size() %>">
		<input type="hidden" id="intersectTempGeneSetSize" name="intersectTempGeneSetSize" value="<%= intersectTempGeneSet.size() %>">
		<input type="hidden" id="unionTempGeneSetSize"     name="unionTempGeneSetSize"     value="<%= unionTempGeneSet.size() %>">
		<input type="hidden" id="BminusATempGeneSetSize"   name="BminusATempGeneSetSize"   value="<%= BminusATempGeneSet.size() %>">
		


		</form>
<% } %>
	</div>


  <div class="itemDetails"></div>

  <script type="text/javascript">
    $(document).ready(function() {
        setupPage();
	setTimeout("setupMain()", 100); 
    });
  </script>

<%@ include file="/web/common/footer_adaptive.jsp" %>


