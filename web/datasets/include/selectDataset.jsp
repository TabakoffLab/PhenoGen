<%--
 *  Author: Cheryl Hornbaker
 *  Created: Jan, 2006
 *  Description:  This file performs the logic neccessary for selecting a dataset.
 *
 *  Todo:
 *  Modification Log:
 *
--%>

<%
	int datasetID = ((String) request.getParameter("datasetID") != null &&
		!((String) request.getParameter("datasetID")).equals("")  ? 
		Integer.parseInt((String)request.getParameter("datasetID")) :
		-99);

	int datasetVersion = ((String) request.getParameter("datasetVersion") != null && 
		!((String) request.getParameter("datasetVersion")).equals("")  ? 
		Integer.parseInt((String)request.getParameter("datasetVersion")) :
		-99);

	log.debug("In selectDataset. Here datasetID = " + datasetID + ", datasetVersion = " + datasetVersion); 

	if (datasetID != -99) {
		%><%@ include file="/web/datasets/include/setupDataset.jsp" %><%

		if (datasetVersion != -99) {
			selectedDatasetVersion = selectedDataset.getDatasetVersion(datasetVersion);
		} else {
			selectedDatasetVersion = new Dataset(-99).new DatasetVersion(-99);
		}
	} else { 
		selectedDataset = new Dataset(-99);
	}

	//log.debug("selectedDataset = "+selectedDataset);
	//log.debug("selectedDatasetVersion = "+selectedDatasetVersion);

       	session.setAttribute("selectedDataset", selectedDataset);
        session.setAttribute("selectedDatasetVersion", selectedDatasetVersion);
       	session.setAttribute("privateDatasetsForUser", privateDatasetsForUser);
       	session.setAttribute("publicDatasets", publicDatasets);

%>

