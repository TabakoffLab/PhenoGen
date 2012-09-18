<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  The web page created by this file allows a user to save a gene list. 
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/datasets/include/analysisHeader.jsp"%>

<jsp:useBean id="myGeneList" class="edu.ucdenver.ccp.PhenoGen.data.GeneList"> </jsp:useBean>

<%

	log.info("in nameGeneListFromAnalysis.jsp. user = " + user);

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-006");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }
	int geneListID = -99;

	request.setAttribute( "selectedStep", "6" ); 
	if (analysisType.equals("correlation")) {
		request.setAttribute( "selectedStep", "7" );
	}

	log.debug("num_arrays = "+ selectedDataset.getNumber_of_arrays()); 
	optionsList.add("datasetVersionDetails");

	String description = "";
	String parameterDescription = "";
	String geneListFileName = analysisPath + selectedDataset.getPlatform() + ".genetext.output.txt";

        int numGroups = 2;
        if ((String) session.getAttribute("numGroups") != null) {
                numGroups = Integer.parseInt((String) session.getAttribute("numGroups"));
        }
	if (phenotypeParameterGroupID != -99) {
		numGroups = myDataset.getNumStrains(phenotypeParameterGroupID, dbConn);
	}
	log.debug("now numGroups = "+numGroups);
		
	ParameterValue[] myParameterValues = myParameterValue.getGeneListParameters(parameterGroupID, dbConn); 
	for (int i=0; i<myParameterValues.length; i++) {
		parameterDescription = parameterDescription + myParameterValues[i].getCategory() + 
					(!myParameterValues[i].getValue().equals(" ") && 
					 !myParameterValues[i].getValue().equals("Null") ?
						":  " + myParameterValues[i].getParameter() + 
						" set to '" + myParameterValues[i].getValue() +"'" : 
						"") +
					(i == myParameterValues.length - 1 ? "":", ");
	}
		
        if ((action != null) && action.equals("Save Gene List")) {
		
		String gene_list_name = (String) request.getParameter("gene_list_name");

		if ((request.getParameterValues("descriptionParameters")) != null) {
			description = parameterDescription;
		} else {
			description = (String) request.getParameter("description");
		}

		description = description.substring(0, Math.min(description.length(), 3998)).trim();
		if (myGeneList.geneListNameExists(gene_list_name, userID, dbConn)) { 
			//Error - "Gene list name exists"
			session.setAttribute("errorMsg", "GL-006");
                        response.sendRedirect(commonDir + "errorMsg.jsp");
		} else {

			GeneList newGeneList = new GeneList();

			newGeneList.setGene_list_name(gene_list_name);	
			newGeneList.setDescription(description);	
			newGeneList.setCreated_by_user_id(userID);	
			newGeneList.setParameter_group_id(parameterGroupID);	

			newGeneList.setGene_list_source("Statistical Analysis");	
			newGeneList.setOrganism(selectedDataset.getOrganism());	
			newGeneList.setDataset_id(selectedDataset.getDataset_id());	
			newGeneList.setVersion(selectedDatasetVersion.getVersion());	
			newGeneList.setPath(analysisPath.substring(0, analysisPath.length() - 1));
			try {
				geneListID = newGeneList.loadFromFile(numGroups, geneListFileName, dbConn); 
				log.debug("successfully loaded system-generated gene list");
				mySessionHandler.setActivity_name("Created Gene List from Analysis of Dataset '" + 
							selectedDataset.getName() + "_v" +
							selectedDatasetVersion.getVersion() + "'");
			} catch (SQLException e) {
				log.error("did not successfully upload gene list. e.getErrorCode() = " + e.getErrorCode());

				mySessionHandler.setActivity_name("Got duplicate gene identifier error "+
						"when creating Gene List from Analysis of Dataset");
				if (e.getErrorCode() == 1) {
       		                 	log.error("got duplicate entry error trying to insert genes record.");
					//Error - "Duplicate gene identifiers from 'R' code"
					session.setAttribute("errorMsg", "GL-001");
			                response.sendRedirect(commonDir + "errorMsg.jsp");
       		         	} else {
       		                 	throw e;
       		         	}
			}

			mySessionHandler.setSession_id(session.getId());
			mySessionHandler.setGene_list_id(geneListID);
			mySessionHandler.createSessionActivity(mySessionHandler, dbConn);

			/* 
			if (myGeneList.getGeneList(geneListID, dbConn).getNumber_of_genes() > 200) {
				additionalInfo =  "<br> <br>" +
                                                               "NOTE:  Since your gene list contains more than 200 entries, you may "+
                                                               "not be able to perform all the functions available on the website.";
			}
                        session.setAttribute("additionalInfo", additionalInfo);
			*/
	
			//Success - "Gene list saved"
			session.setAttribute("successMsg", "GL-013");
			response.sendRedirect(geneListsDir + "listGeneLists.jsp");
		}
	}
%>

	<%@ include file="/web/common/microarrayHeader.jsp" %>
	<%@ include file="/web/datasets/include/viewingPane.jsp" %>
	<%@ include file="/web/datasets/include/analysisSteps.jsp" %>

	<div class="brClear"></div>
	<div class="page-intro">
		You must name this gene list
	</div>
	<div class="datasetForm">
		<form	name="nameGeneList" 
			method="post" 
			onSubmit="return IsNameGeneListFormComplete()"
			action="nameGeneListFromAnalysis.jsp" 
			enctype="application/x-www-form-urlencoded"> 

		<BR>
		<div class="brClear"></div>
		<table class="parameters">
		<tr>
			<td> <strong>Gene List Name:</strong> </td>
			<td> <input type="text" name="gene_list_name"  size="60" tabindex="1"> </td>
		</tr><tr>
			<td> <strong>Gene List Description:</strong> 
				<BR> <BR> 
				<input type="checkbox" name="descriptionParameters" 
						value="descriptionParameters" onChange="updateDescription()" tabindex="3">
						Set Description to the parameters used 
			</td>
		
			<td> <textarea  name="description" cols="60" rows="5" tabindex="2"></textarea> </td>
	
		</tr>
		</table>
                <div class="brClear"> </div>
		<div id="pageSubmit">
			<input type="reset" value="Reset"> <%=tenSpaces%>
			<input type="submit" name="action" value="Save Gene List"> 
		</div>

		<input type="hidden" name="datasetID" value=<%=selectedDataset.getDataset_id()%>>
		<input type="hidden" name="datasetVersion" value=<%=selectedDatasetVersion.getVersion()%>>
		<input type="hidden" name="analysisType" value=<%=analysisType%>>
		<input type="hidden" name="parameterDescription" value="<%=parameterDescription%>">
		<input type="hidden" name="phenotypeParameterGroupID" value=<%=phenotypeParameterGroupID%>>

		</form>
	</div>
        <div class="load">Loading...</div>
	<%@ include file="/web/common/footer.jsp"  %>

	<script type="text/javascript">
		$(document).ready(function() {
			hideLoadingBox();
			setTimeout("setupMain()", 100); 
		})
	</script>

