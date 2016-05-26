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
<jsp:useBean id="anonU" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser" scope="session" />

<%
	int itemID = (request.getParameter("geneListAnalysisID") == null ? -99 : Integer.parseInt((String) request.getParameter("geneListAnalysisID")));

	log.info("in deleteGeneListAnalysis.jsp. user = " + user + ", itemID = "+itemID);
        GeneListAnalysis thisGLA = null;
        String gl_uuid="";
        if(userLoggedIn.getUser_name().equals("anon")){
            thisGLA=new GeneListAnalysis().getAnonGeneListAnalysis(itemID, pool);
            gl_uuid=myAnonGeneList.getGeneListOwner(thisGLA.getGene_list_id(),pool);
        }else{
            thisGLA=new GeneListAnalysis().getGeneListAnalysis(itemID, pool);
        }
        String analysisType = thisGLA.getAnalysis_type();
        log.debug("analysisType = "+analysisType);
        String result="";
        log.debug("analysis user ids="+thisGLA.getUser_id()+"  loggedin user="+userLoggedIn.getUser_id());
        log.debug("analysis uuid="+gl_uuid+"  loggedin user="+anonU.getUUID());
        if ( (thisGLA.getUser_id()!=-20 && userLoggedIn.getUser_id()!= thisGLA.getUser_id()  )  || (thisGLA.getUser_id()==-20 && ! gl_uuid.equals(anonU.getUUID()) ) ) {
                result="Error deleting Gene List Analysis: Permission Denied";
        }else{
            if (analysisType.equals("LitSearch")) {
                    try {
                            new LitSearch().deleteLitSearch(itemID, pool);
                            mySessionHandler.createGeneListActivity("Deleted Lit Search : " + itemID, pool);
                            result="Success";
                    } catch( Exception e ) {
                            throw e;
                    }
            } else if (analysisType.equals("Upstream")) {
                    try {
                        if(userLoggedIn.getUser_name().equals("anon")){
                            String dir=userLoggedIn.getUserMainDir()+"GeneLists/"+anonU.getUUID()+"/";
                            log.debug("deleteAjaxGLA.jsp\n"+dir);
                            myGeneListAnalysis.deleteAnonGeneListAnalysisFiles(dir, itemID, pool);
                            myGeneListAnalysis.deleteAnonGeneListAnalysisResult(itemID, pool);
                        }else{
                            myGeneListAnalysis.deleteGeneListAnalysisFiles(userLoggedIn.getUserMainDir(), itemID, pool);
                            myGeneListAnalysis.deleteGeneListAnalysisResult(itemID, pool);
                        }
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
                        if(userLoggedIn.getUser_name().equals("anon")){
                            String dir=userLoggedIn.getUserMainDir()+"GeneLists/"+anonU.getUUID()+"/";
                            log.debug("deleteAjaxGLA.jsp\n"+dir);
                            myGeneListAnalysis.deleteAnonGeneListAnalysisFiles(dir, itemID, pool);
                            myGeneListAnalysis.deleteAnonGeneListAnalysisResult(itemID, pool);
                        }else{
                            myGeneListAnalysis.deleteGeneListAnalysisFiles(userLoggedIn.getUserMainDir(), itemID,pool);
                            myGeneListAnalysis.deleteGeneListAnalysisResult(itemID, pool);
                        }
                        mySessionHandler.createGeneListActivity("Deleted MEME Analysis: " + itemID, pool);
                        result="Success";
                    } catch( Exception e ) {
                            throw e;
                    }
            } else if (analysisType.equals("oPOSSUM")) {
                    try {
                        if(userLoggedIn.getUser_name().equals("anon")){
                            String dir=userLoggedIn.getUserMainDir()+"GeneLists/"+anonU.getUUID()+"/";
                            log.debug("deleteAjaxGLA.jsp\n"+dir);
                            myGeneListAnalysis.deleteAnonGeneListAnalysisFiles(dir, itemID, pool);
                        }else{
                            myGeneListAnalysis.deleteGeneListAnalysisFiles(userLoggedIn.getUserMainDir(), itemID, pool);
                        }
                        new Promoter().deletePromoterResult(itemID, pool);
                        mySessionHandler.createGeneListActivity("Deleted oPOSSUM Analysis: " + itemID, pool);
                        result="Success";
                    } catch( Exception e ) {
                            throw e;
                    }
            } else if (analysisType.equals("GO")) {
                    try {
                        if(userLoggedIn.getUser_name().equals("anon")){
                            String dir=userLoggedIn.getUserMainDir()+"GeneLists/"+anonU.getUUID()+"/";
                            myGeneListAnalysis.deleteAnonGeneListAnalysisFiles(dir, itemID, pool);
                            myGeneListAnalysis.deleteAnonGeneListAnalysisResult(itemID, pool);
                        }else{
                            myGeneListAnalysis.deleteGeneListAnalysisFiles(userLoggedIn.getUserMainDir(), itemID, pool);
                            myGeneListAnalysis.deleteGeneListAnalysisResult(itemID, pool);
                        }
                        mySessionHandler.createGeneListActivity("Deleted GO Analysis: " + itemID, pool);
                        result="Success";
                    } catch( Exception e ) {
                            throw e;
                    }
            } else if (analysisType.equals("multiMiR")) {
                    try {
                        if(userLoggedIn.getUser_name().equals("anon")){
                            String dir=userLoggedIn.getUserMainDir()+"GeneLists/"+anonU.getUUID()+"/";
                            myGeneListAnalysis.deleteAnonGeneListAnalysisFiles(dir, itemID, pool);
                            myGeneListAnalysis.deleteAnonGeneListAnalysisResult(itemID, pool);
                        }else{
                            myGeneListAnalysis.deleteGeneListAnalysisFiles(userLoggedIn.getUserMainDir(), itemID, pool);
                            myGeneListAnalysis.deleteGeneListAnalysisResult(itemID, pool);
                        }
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