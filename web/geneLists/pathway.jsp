<%--
 *  Author: Cheryl Hornbaker
 *  Created: August, 2010
 *  Description:  The web page created by this file allows the user to
 *              find pathways for a gene list derived from a 2-group comparison or from a correlation.
 *  Todo:
 *  Modification Log:
 *
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %>
<%
        log.info("in pathway.jsp. user =  "+ user);

        extrasList.add("pathway.js");

	request.setAttribute( "selectedTabId", "pathway" );

        if ((action != null) && action.equals("Run Pathway")) {

                String method = (String) request.getParameter("method");
		try {
                        mySessionHandler.createGeneListActivity("Ran Pathway Analysis on Gene List", dbConn);

			Thread thread = new Thread(new AsyncPathway(
						session,
						method));

			log.debug("Starting thread to run SPIA "+ thread.getName());

			thread.start();

			//Success - "SPIA  started"
                        session.setAttribute("successMsg", "GLT-016");
                        response.sendRedirect(commonDir + "successMsg.jsp");

		} catch (Exception e) {
			log.debug("got exception creating geneListAnalysisDir or pathway directory in pathway.jsp");
			mySessionHandler.createGeneListActivity(
                                       	"got error creating geneListAnalysisDir or pathwayDir directory in pathway.jsp for " +
                                       	selectedGeneList.getGene_list_name(), dbConn);
                	session.setAttribute("errorMsg", "SYS-001");
                	response.sendRedirect(commonDir + "errorMsg.jsp");
		}
	}
%>

	<script type="text/javascript">
		var crumbs = ["Home", "Research Genes", "Pathway"];
	</script>
	<BR><BR>

        <form   name="pathway" 
                method="post" 
                action="pathway.jsp" 
                enctype="application/x-www-form-urlencoded"   onSubmit="return IsPathwayFormComplete()">
	
                <table name="items" id="pathway" class="list_base tablesorter" cellpadding="0" cellspacing="3" >
                <tr>
                        <td>
                                <strong>When multiple probesets map to a single Entrez Gene ID, use :</strong>
                        </td><td>
                                <%
                                selectName = "method";
                                selectedOption = "average";
                                onChange = "";
                                style = "";
                                optionHash = new LinkedHashMap();
                                optionHash.put("average", "Average Absolute Value");
                                optionHash.put("maximum", "Maximum Absolute Value");
                                %>
                                <%@ include file="/web/common/selectBox.jsp" %>
                        </td>
                </tr>
        	</table>

	<BR> <BR>
        <center>
        <input type="reset" value="Reset"> <%=tenSpaces%>
        <input type="submit" name="action" value="Run Pathway">

        </center>
        <input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>"/>
	</form>

