<%--
 *  Author: Cheryl Hornbaker
 *  Created: Jan, 2006
 *  Description:  This file performs the logic necessary for selecting a gene list
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%
        int geneListID = ((String)request.getParameter("geneListID") != null ?
			Integer.parseInt((String)request.getParameter("geneListID")) :
			-99);

	log.debug("in selectGeneList. geneListID = " + geneListID);

	if (geneListID != -99) {
		selectedGeneList = new GeneList().getGeneList(geneListID, dbConn);
		selectedGeneList.setUserIsOwner(selectedGeneList.getCreated_by_user_id() == userID ? "Y" : "N"); 
		selectedGeneList.setGenes(selectedGeneList.getGenesAsArray("Original", dbConn));
		if (selectedGeneList.getGene_list_source().indexOf("_v") > -1) {
			selectedGeneList.setDatasetVersion(new Dataset().getDataset(selectedGeneList.getDataset_id(), dbConn).getDatasetVersion(selectedGeneList.getVersion()));
			log.debug("this gene list's dataset version= "+selectedGeneList.getDatasetVersion());
			log.debug("dataset chip= "+selectedGeneList.getDatasetVersion().getDataset().getArray_type());
		}
	} else {
		selectedGeneList = new GeneList(-99);
		selectedGeneList.setUserIsOwner("N");
	}
	session.setAttribute("selectedGeneList", selectedGeneList);
	session.setAttribute("geneListsForUser", geneListsForUser);
%>
