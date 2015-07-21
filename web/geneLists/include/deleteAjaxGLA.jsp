<%--
 *  Author: Spencer Mahaffey
 *  Created: Jul, 2015
 *  Description:  This file handles deleting a gene list analysis result from the newer AJAX call for most GLA results but not all some will 
*   still use the regular .jsp page
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %>

<%
	int itemID = (request.getParameter("geneListAnalysisID") == null ? -99 : Integer.parseInt((String) request.getParameter("geneListAnalysisID")));

	log.info("in deleteGeneListAnalysis.jsp. user = " + user + ", itemID = "+itemID);
        GeneListAnalysis thisGLA = new GeneListAnalysis().getGeneListAnalysis(itemID, pool);
        String analysisType = thisGLA.getAnalysis_type();
        log.debug("analysisType = "+analysisType);
        String result="";
        log.debug("analysis user ids="+thisGLA.getUser_id()+"  loggedin user="+userLoggedIn.getUser_id());
        if (userLoggedIn.getUser_id()!= thisGLA.getUser_id()) {
                result="Error deleting Gene List Analysis: Permission Denied";
        }else{
            if (analysisType.equals("LitSearch")) {
                    try {
                            new LitSearch().deleteLitSearch(itemID, dbConn);
                            mySessionHandler.createGeneListActivity("Deleted Lit Search : " + itemID, pool);
                            result="Success";
                    } catch( Exception e ) {
                            throw e;
                    }
            } else if (analysisType.equals("Upstream")) {
                    try {
                            myGeneListAnalysis.deleteGeneListAnalysisFiles(userLoggedIn.getUserMainDir(), itemID, pool);
                            myGeneListAnalysis.deleteGeneListAnalysisResult(itemID, pool);

                            mySessionHandler.createGeneListActivity("Deleted Upstream Sequence Extraction: " + itemID, pool);
                            result="Success";
                    } catch( Exception e ) {
                            throw e;
                    }
            } else if (analysisType.equals("Pathway")) {
                    try {
                            myGeneListAnalysis.deleteGeneListAnalysisFiles(userLoggedIn.getUserMainDir(), itemID, pool);
                            myGeneListAnalysis.deleteGeneListAnalysisResult(itemID, pool);
                            mySessionHandler.createGeneListActivity("Deleted Pathway Analysis: " + itemID, pool);
                            result="Success";
                    } catch( Exception e ) {
                            throw e;
                    }
            } else if (analysisType.equals("MEME")) {
                    try {
                            myGeneListAnalysis.deleteGeneListAnalysisFiles(userLoggedIn.getUserMainDir(), itemID,pool);
                            myGeneListAnalysis.deleteGeneListAnalysisResult(itemID, pool);
                            mySessionHandler.createGeneListActivity("Deleted MEME Analysis: " + itemID, pool);
                            result="Success";
                    } catch( Exception e ) {
                            throw e;
                    }
            } else if (analysisType.equals("oPOSSUM")) {
                    try {
                            myGeneListAnalysis.deleteGeneListAnalysisFiles(userLoggedIn.getUserMainDir(), itemID, pool);
                            new Promoter().deletePromoterResult(itemID, dbConn);
                            mySessionHandler.createGeneListActivity("Deleted oPOSSUM Analysis: " + itemID, pool);
                            result="Success";
                    } catch( Exception e ) {
                            throw e;
                    }
            } else if (analysisType.equals("GO")) {
                    try {
                            myGeneListAnalysis.deleteGeneListAnalysisFiles(userLoggedIn.getUserMainDir(), itemID, pool);
                            myGeneListAnalysis.deleteGeneListAnalysisResult(itemID, pool);
                            mySessionHandler.createGeneListActivity("Deleted GO Analysis: " + itemID, pool);
                            result="Success";
                    } catch( Exception e ) {
                            throw e;
                    }
            } else if (analysisType.equals("multiMiR")) {
                    try {
                            myGeneListAnalysis.deleteGeneListAnalysisFiles(userLoggedIn.getUserMainDir(), itemID, pool);
                            myGeneListAnalysis.deleteGeneListAnalysisResult(itemID, pool);
                            mySessionHandler.createGeneListActivity("Deleted MultiMiR Analysis: " + itemID, pool);
                            result="Success";
                    } catch( Exception e ) {
                            throw e;
                    }
            }else {
                result="Error couldn't delete analysis unrecognized analysis type.";
            }
        }
%>

<%=result%>	