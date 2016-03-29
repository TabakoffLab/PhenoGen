<%--
 *  Author: Cheryl Hornbaker
 *  Created: Jul, 2009
 *  Description:  This file performs the logic neccessary for setting up a dataset.
 *
 *  Todo:
 *  Modification Log:
 *
--%>

<%
		log.debug("in setupDataset right before calling getDataset");
                if(dbConn==null){
                    selectedDataset = new Dataset().getDataset(datasetID, pool,userFilesRoot);
                }else{
                    selectedDataset = new Dataset().getDataset(datasetID, userLoggedIn, dbConn,userFilesRoot);
                }
                log.debug("in setupDataset after calling getDataset");
%>

