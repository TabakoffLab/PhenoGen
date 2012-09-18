<%--
 *  Author: Cheryl Hornbaker
 *  Created: Sep, 2007
 *  Description:  The web page created by this file displays the genes belonging to a certain cluster
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/analysisHeader.jsp"  %>

<jsp:useBean id="myGeneList" class="edu.ucdenver.ccp.PhenoGen.data.GeneList"> </jsp:useBean>

<%
	log.info("in saveClusterGeneList.jsp. user =  "+ user);

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-006");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }
	
	int geneListID = -99;

	String clusterNumber = ((String) request.getParameter("clusterNumber") != null ?
				(String) request.getParameter("clusterNumber") : "");		
	String clusterObject = ((String) request.getParameter("clusterObject") != null ?
				(String) request.getParameter("clusterObject") : "");		
	int numGroups = ((String) request.getParameter("numGroups") != null ?
				Integer.parseInt((String) request.getParameter("numGroups")) : -99);		
	String level = ((String) request.getParameter("level") != null ?
				(String) request.getParameter("level") : "");		
	String clusterGroupID = ((String) request.getParameter("clusterGroupID") != null ?
				(String) request.getParameter("clusterGroupID") : "");		
	analysisType = "cluster";

        analysisPath = (level.equals("all") ?  selectedDatasetVersion.getClusterDir() +
                                		userName + "/" +
                                		clusterGroupID + "/" : 
						analysisPath);
	session.setAttribute("analysisPath", analysisPath);

	log.debug("numGroups = "+numGroups + ", level = " + level + ", analysisPath = "+analysisPath);

	mySessionHandler.createDatasetActivity("Saved gene list for cluster # '" + clusterNumber +  "'", dbConn);

	// 
	// Create parameter values when saving cluster results or gene list
	//
	int newParameterGroupID = myParameterValue.copyParameters(parameterGroupID, dbConn);
	session.setAttribute("parameterGroupID", Integer.toString(newParameterGroupID));
	log.debug("newParameterGroupID = "+newParameterGroupID);
	log.debug("analysisPath = "+analysisPath);
	log.debug("platform = "+selectedDataset.getPlatform());
	log.debug("clusterNumber = "+clusterNumber);
	log.debug("queryString = "+queryString);

	String description = "";
	String parameterDescription = "";
	String geneListFileName = analysisPath + selectedDataset.getPlatform() + ".genetext.output.txt";

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
		try {
			String version="v"+selectedDatasetVersion.getVersion();
			String sampleFile=selectedDataset.getPath()+version+"_samples.txt";
			myStatistic.callOutputGeneList(selectedDataset.getPlatform(), 
							analysisPath + "Cluster" + clusterNumber + ".Rdata",
							version,
							sampleFile, 
							selectedDatasetVersion.getGroupFileName(),
							analysisPath);
			log.debug("just called outputGene list for " + analysisPath + "Cluster" + clusterNumber + ".Rdata"); 
			mySessionHandler.createDatasetActivity("Creating gene list from cluster results where cluster object is probes", dbConn);
		
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

				mySessionHandler.setSession_id(session.getId());
				try {
					geneListID = newGeneList.loadFromFile(numGroups, geneListFileName, dbConn); 
					log.debug("successfully loaded system-generated gene list");
					mySessionHandler.setActivity_name("Created Gene List from Analysis of Dataset '" + 
								selectedDataset.getName() + "_v" +
								selectedDatasetVersion.getVersion() + "'");
                			mySessionHandler.setGene_list_id(geneListID);
					mySessionHandler.createSessionActivity(mySessionHandler, dbConn);
				} catch (SQLException e) {
					log.error("did not successfully upload gene list. e.getErrorCode() = " + e.getErrorCode());

					if (e.getErrorCode() == 1) {
						mySessionHandler.setActivity_name("Got duplicate gene identifier error "+
							"when creating Gene List from Analysis of Dataset");
						mySessionHandler.createSessionActivity(mySessionHandler, dbConn);
       		                 		log.error("got duplicate entry error trying to insert genes record.");
						//Error - "Duplicate gene identifiers from 'R' code"
						session.setAttribute("errorMsg", "GL-001");
			                	response.sendRedirect(commonDir + "errorMsg.jsp");
       		         		} else {
       		                 		throw e;
       		         		}
				}


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
				response.sendRedirect(commonDir + "successMsg.jsp");
			}
		} catch (RException e) {
			log.error("an error occurred while running outputGeneList");
			rExceptionErrorMsg = e.getMessage();
			mySessionHandler.createDatasetActivity("Got Error When Running R OutputGeneList Function", dbConn);
			%><%@ include file="/web/datasets/include/rError.jsp" %><%
		}
	}
%>

	<%@ include file="/web/common/basicHeadTags.jsp" %>

	<div class="brClear"></div>
	<div class="page-intro">
		You must name this gene list
	</div>
	<div class="datasetForm">
		<form	name="nameGeneList" 
			method="post" 
			onSubmit="return IsNameGeneListFormComplete()"
			action="saveClusterGeneList.jsp" 
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
		<input type="hidden" name="clusterNumber" value="<%=clusterNumber%>">
		<input type="hidden" name="clusterObject" value="<%=clusterObject%>">
		<input type="hidden" name="numGroups" value="<%=numGroups%>">
		<input type="hidden" name="level" value="<%=level%>">
		<input type="hidden" name="clusterGroupID" value="<%=clusterGroupID%>">
		</form>
  	</div>
        <div class="load">Loading...</div>

	<script type="text/javascript">
		$(document).ready(function() {
			hideLoadingBox();
			setTimeout("setupMain()", 100); 
		});
	</script>
