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
                if(userLoggedIn.getUser_name().equals("anon")){
                    selectedDataset = new Dataset().getDataset(datasetID,userLoggedIn.getUser("public",pool), pool,userFilesRoot);
                }else{
                    selectedDataset = new Dataset().getDataset(datasetID, userLoggedIn, dbConn,userFilesRoot);
                }
                log.debug("in setupDataset after calling getDataset");
%>

