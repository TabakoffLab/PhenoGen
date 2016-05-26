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
        log.debug("in selectGeneList.");
        int geneListID = ((String)request.getParameter("geneListID") != null ?
			Integer.parseInt((String)request.getParameter("geneListID")) :
			-99);

	log.debug("in selectGeneList. geneListID = " + geneListID);

	if (geneListID != -99) {
            if(userLoggedIn.getUser_name().equals("anon")){
                selectedGeneList = new AnonGeneList().getGeneList(geneListID, pool);
		selectedGeneList.setUserIsOwner("Y"); 
		selectedGeneList.setGenes(selectedGeneList.getGenesAsArray("Original", pool));
                
            }else{
		selectedGeneList = new GeneList().getGeneList(geneListID, pool);
		selectedGeneList.setUserIsOwner(selectedGeneList.getCreated_by_user_id() == userID ? "Y" : "N"); 
		selectedGeneList.setGenes(selectedGeneList.getGenesAsArray("Original", pool));
		if (selectedGeneList.getGene_list_source().indexOf("_v") > -1) {
			selectedGeneList.setDatasetVersion(new Dataset().getDataset(selectedGeneList.getDataset_id(), dbConn,userFilesRoot).getDatasetVersion(selectedGeneList.getVersion()));
			log.debug("this gene list's dataset version= "+selectedGeneList.getDatasetVersion());
			log.debug("dataset chip= "+selectedGeneList.getDatasetVersion().getDataset().getArray_type());
		}
            }
	} else {
		selectedGeneList = new GeneList(-99);
		selectedGeneList.setUserIsOwner("N");
	}
	session.setAttribute("selectedGeneList", selectedGeneList);
	session.setAttribute("geneListsForUser", geneListsForUser);
%>
