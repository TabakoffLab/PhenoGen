<%--
 *  Author: Cheryl Hornbaker
 *  Created: Aug, 2009
 *  Description:  This file performs the logic necessary for selecting a dataset 
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>
<%@ include file="/web/datasets/include/selectDataset.jsp"  %>
<%
	String goTo = (request.getParameter("goTo") != null ?
				(String) request.getParameter("goTo") : "");
	log.debug("in chooseDataset. goTo = " + goTo);
	//
	// Included in Dataset.getDataset instead 
	/*
        String hybridIDs = selectedDataset.getDatasetHybridIDs(dbConn);
        if (!hybridIDs.equals("()")) {
                selectedDataset.setArray_type(myArray.getDatasetArrayType(hybridIDs, dbConn));
        }
	*/
	log.debug("in chooseDataset. this array type = "+selectedDataset.getArray_type());	
	mySessionHandler.createDatasetActivity(session.getId(), 
			selectedDataset.getDataset_id(), 
                	selectedDatasetVersion.getVersion(),
                	(selectedDatasetVersion.getVersion() == -99 ? "Chose dataset" : "Chose version"),
			dbConn);

	if (goTo.equals("QC")) {
		response.sendRedirect("qualityControl.jsp?datasetID="+selectedDataset.getDataset_id());
	} else if (goTo.equals("versions")) {
		response.sendRedirect("listDatasetVersions.jsp?datasetID="+selectedDataset.getDataset_id());
	} else if (goTo.equals("QCResults")) {
		response.sendRedirect("qualityControlResults.jsp?datasetID="+selectedDataset.getDataset_id());
	} else if (goTo.equals("ClusterResults")) {
		response.sendRedirect("allClusterResults.jsp?datasetID=" + selectedDataset.getDataset_id() +
                                                (selectedDatasetVersion.getVersion() != -99 ?
                                                "&datasetVersion=" + selectedDatasetVersion.getVersion() : "")); 
	} else if (goTo.equals("Phenotype")) {
		response.sendRedirect("phenotypes.jsp?datasetID=" + selectedDataset.getDataset_id() +
                                                (selectedDatasetVersion.getVersion() != -99 ?
                                                "&datasetVersion=" + selectedDatasetVersion.getVersion() : "")); 
	} else if (goTo.equals("GeneList")) {
		response.sendRedirect(geneListsDir + "listGeneLists.jsp?datasetID=" + selectedDataset.getDataset_id() +
                                                (selectedDatasetVersion.getVersion() != -99 ?
                                                "&datasetVersion=" + selectedDatasetVersion.getVersion() : "")); 
	} else if (goTo.equals("geneData")) {
		response.sendRedirect("geneData.jsp?" + 
                			(selectedDatasetVersion.getVersion() == -99 ?
					"itemID=" + selectedDataset.getDataset_id() :  
                                        "itemIDString="+selectedDataset.getDataset_id() +
					"|||" + selectedDatasetVersion.getVersion()));
	} else if (selectedDatasetVersion.getVersion() == -99) {
		response.sendRedirect("listDatasetVersions.jsp?datasetID="+selectedDataset.getDataset_id());
	} else {
		response.sendRedirect("typeOfAnalysis.jsp?datasetID="+
				selectedDataset.getDataset_id()+
				"&datasetVersion="+
				selectedDatasetVersion.getVersion());
	}
%>
