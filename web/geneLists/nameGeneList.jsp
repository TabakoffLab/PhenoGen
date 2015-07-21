<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  The web page created by this file allows a user to save a gene list. 
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/geneLists/include/geneListHeader.jsp"%>

<%
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");

	log.info("in nameGeneList.jsp. user = " + user);

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-006");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }

	String geneListSource = ((String) request.getParameter("geneListSource") != null ?
				(String) request.getParameter("geneListSource") :
				"compare");

	log.debug("geneListSource = "+geneListSource);

        List resultGeneList = ((Set)session.getAttribute("geneListSet") != null ?
				new ArrayList((Set)session.getAttribute("geneListSet")) :
				null);
	//log.debug("resultGeneList = "); myDebugger.print(resultGeneList);

	String description = "";
	String parameterDescription = "";

        int numGroups = 2;
        if ((String) session.getAttribute("numGroups") != null) {
                numGroups = Integer.parseInt((String) session.getAttribute("numGroups"));
        }
	log.debug("now numGroups = "+numGroups);
        
        if ((action != null) && action.equals("Save Gene List")) {
		
		String gene_list_name = (String) request.getParameter("gene_list_name");

		if ((request.getParameterValues("descriptionParameters")) != null) {
			description = parameterDescription;
		} else {
			description = (String) request.getParameter("description");
		}

		description = description.substring(0, Math.min(description.length(), 3998)).trim();
		if (myGeneList.geneListNameExists(gene_list_name, userID, pool)) { 
			//Error - "Gene list name exists"
			session.setAttribute("errorMsg", "GL-006");
                        response.sendRedirect(commonDir + "errorMsg.jsp");
		} else {
			int geneListID = -99;
			if (resultGeneList.size() > 0) {

                        	parameterGroupID = myParameterValue.createParameterGroup(dbConn);

                        	myParameterValue.setParameter_group_id(parameterGroupID);
                        	myParameterValue.setCreate_date();

				List userList = (request.getParameterValues("userList") == null ? new ArrayList() : 
						Arrays.asList(request.getParameterValues("userList"))); 
				//log.debug("userList = "); myDebugger.print(userList);
	
				GeneList newGeneList = new GeneList();
				newGeneList.setGene_list_users(userList);

				newGeneList.setGene_list_name(gene_list_name);	
				newGeneList.setDescription(description);	
				newGeneList.setCreated_by_user_id(userID);	
				newGeneList.setParameter_group_id(parameterGroupID);	

				if (geneListSource.equals("compare")) {
					newGeneList.setGene_list_source("Gene List Compare");	
                        		newGeneList.setOrganism(selectedGeneList.getOrganism());

                                	String comparisonType = (String) session.getAttribute("comparisonType");
                                	myParameterValue.setCategory("Gene List Source");
                                	myParameterValue.setParameter("Gene List Comparison");
                                	myParameterValue.setValue(comparisonType);
                                	myParameterValue.createParameterValue(dbConn);

                        		geneListID = newGeneList.createGeneList(pool);

                        		myGeneList.loadGeneListFromList(resultGeneList, geneListID, pool);

                        		mySessionHandler.createGeneListActivity(session.getId(), 
                                		geneListID,
                                		"Created Gene List from comparison of 2 gene lists",
                                		pool);

					/*
					if (myGeneList.getGeneList(geneListID, dbConn).getNumber_of_genes() > 200) {
						additionalInfo =  "<br> <br>" +
                                                                	"NOTE:  Since your gene list contains more than 200 entries, you may "+
                                                                	"not be able to perform all the functions available on the website.";
					}
                        		session.setAttribute("additionalInfo", additionalInfo);
					*/

                        		//Success - "Gene List saved"
                        		session.setAttribute("successMsg", "GL-013");
                        		response.sendRedirect(geneListsDir + "listGeneLists.jsp");

				} else if (geneListSource.equals("QTL")) {
                                	newGeneList.setGene_list_source("QTL Analysis");
                        		newGeneList.setOrganism(selectedGeneList.getOrganism());

                                	String geneListParameters = (String) session.getAttribute("geneListParameters");
                                	myParameterValue.setCategory("Gene List Source");
                                	myParameterValue.setParameter("QTL Analysis");
                                	myParameterValue.setValue(geneListParameters);
                                	myParameterValue.createParameterValue(dbConn);

                        		geneListID = newGeneList.createGeneList(pool);

                        		myGeneList.loadGeneListFromList(resultGeneList, geneListID, pool);

                        		mySessionHandler.createGeneListActivity(session.getId(), 
                                		geneListID,
                                		"Created Gene List from QTL Analysis",
                                		pool);

					/*
					if (myGeneList.getGeneList(geneListID, dbConn).getNumber_of_genes() > 200) {
						additionalInfo =  "<br> <br>" +
                                                                	"NOTE:  Since your gene list contains more than 200 entries, you may "+
                                                                	"not be able to perform all the functions available on the website.";
					}
                        		session.setAttribute("additionalInfo", additionalInfo);
					*/

                        		//Success - "Gene List saved"
                        		session.setAttribute("successMsg", "GL-013");
                        		response.sendRedirect(geneListsDir + "listGeneLists.jsp");

				} 
			} else {
				//Error - "No genes to save"
				session.setAttribute("errorMsg", "GL-017");
				response.sendRedirect(commonDir + "errorMsg.jsp");
			}
		}
	}
%>

<% if (!geneListSource.equals("QTL")) { %>
	<%@ include file="/web/common/header.jsp" %>



        <%@ include file="/web/geneLists/include/viewingPane.jsp" %>
<% } %>
        <div class="page-intro">
                <p> Provide a name and description to save this gene list.
                </p>
        </div> <!-- // end page-intro -->

<% if (!geneListSource.equals("QTL")) { %>
        <%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>
<% } %>


	<form	name="nameGeneList" 
		method="post" 
		onSubmit="return IsNameGeneListFormComplete()"
		action="nameGeneList.jsp" 
		enctype="application/x-www-form-urlencoded"> 

		<% if (geneListSource.equals("compare")) { 
        		selectedGeneList = (GeneList) session.getAttribute("selectedGeneList");
        		GeneList selectedGeneList2 = (GeneList) session.getAttribute("selectedGeneList2");
			%><BR><div class="title">Original Gene Lists:  '<%=selectedGeneList.getGene_list_name()%>' and '<%=selectedGeneList2.getGene_list_name()%>'</div>
        	<% } %>

		<div style="clear:both;"></div>
		<table class=list_base>
			<tr>
				<td style="font-weight:bold"> Gene List Name:</td>
				<td> <input type="text" name="gene_list_name"  size="60" tabindex="1"> </td>
			</tr><tr>
				<td style="font-weight:bold;vertical-align:top"> 
					Gene List Description:
				</td>
		
				<td> <textarea  name="description" cols="60" rows="5" tabindex="2"></textarea> </td>
	
			</tr>
		</table>

	<BR>
			<input type="hidden" name="parameterDescription" value="<%=parameterDescription%>">
			<input type="hidden" name="geneListSource" value=<%=geneListSource%>>

	<center>
	<input type="reset" value="Reset"> <%=tenSpaces%>
	<input type="submit" name="action" value="Save Gene List"> 
	</center>

	<div class="load">Loading...</div>

	<script type="text/javascript">
		$(document).ready(function() {
			hideLoadingBox();
			setTimeout("setupMain()", 100); 
		});
	</script>

<% if (!geneListSource.equals("QTL")) { %>
	<%@ include file="/web/common/footer.jsp" %>
<% } %>
