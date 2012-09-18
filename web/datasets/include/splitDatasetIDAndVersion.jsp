<%
        String itemIDString = (request.getParameter("itemIDString") == null ? 
				(request.getParameter("itemID") == null ? "-99": (String) request.getParameter("itemID")) :
				(String) request.getParameter("itemIDString"));
	log.debug("in splitDatasetID and Version.  itemIDString = "+itemIDString);
	boolean specificVersion = false;
	if (itemIDString.indexOf("|||") > -1) {
		int datasetID = Integer.parseInt(itemIDString.split("[|]+")[0]);
		int datasetVersion = Integer.parseInt(itemIDString.split("[|]+")[1]);
		//selectedDataset = new Dataset().getDataset(datasetID, userLoggedIn, dbConn);
		log.debug("In split, itemID contains |||, before calling setup");
		%><%@ include file="/web/datasets/include/setupDataset.jsp" %><%
		selectedDatasetVersion = selectedDataset.getDatasetVersion(datasetVersion);
		selectedDataset.setDatasetVersions(new Dataset.DatasetVersion[] {selectedDatasetVersion});
		specificVersion = true;
	} else {
		if (!itemIDString.equals("-99")) {
			int datasetID = Integer.parseInt(itemIDString);
			//selectedDataset = new Dataset().getDataset(datasetID, userLoggedIn, dbConn);
			log.debug("In split itemID != -99, , before calling setup");
			%><%@ include file="/web/datasets/include/setupDataset.jsp" %><%
			selectedDatasetVersion = new Dataset(-99).new DatasetVersion(-99);
		} else {
			selectedDataset = new Dataset(-99);
			selectedDatasetVersion = new Dataset(-99).new DatasetVersion(-99);
		}
	}
       	session.setAttribute("selectedDataset", selectedDataset);
        session.setAttribute("selectedDatasetVersion", selectedDatasetVersion);
%>
