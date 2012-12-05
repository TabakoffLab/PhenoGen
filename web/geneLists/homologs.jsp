<%--
 *  Author: Cheryl Hornbaker
 *  Created: March, 2009
 *  Description:  The web page created by this file displays the homologous genes for a genelist.
 *  Todo: 
 *  Modification Log:
 *      
--%>


<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %> 

<jsp:useBean id="thisIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"> </jsp:useBean>

<%
	log.info("in homologs.jsp. user = " + user);

	request.setAttribute( "selectedTabId", "homologs" );
        extrasList.add("homologs.js");
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
	optionsList.add("download");

        List noHomologList = new ArrayList();
        Set iDecoderAnswer = null;

        int numRows = 0;
        String[] targets = {"Homologene ID",
                        "Entrez Gene ID",
                        "Gene Symbol"};

        String [] homologTargets = {
                "Homologene ID"
                };

        String [] geneSymbolTargets = {
                "Gene Symbol",
		};

        String [] entrezTargets = {
		"Entrez Gene ID",
		};

	log.debug("action = "+action);

       	if ((action != null) && action.equals("Download")) {
                iDecoderAnswer = (Set) session.getAttribute("iDecoderAnswer");
                String downloadPath = userLoggedIn.getUserGeneListsDownloadDir();
		String fullFileName = downloadPath + selectedGeneList.getGene_list_name_no_spaces() + "_Homologs.txt";

                List downloadTargetList = Arrays.asList(targets);

                myIDecoderClient.writeToFileByTarget(iDecoderAnswer, downloadTargetList, fullFileName, "oneRow");

		request.setAttribute("fullFileName", fullFileName);

		myFileHandler.downloadFile(request, response);
		// This is required to avoid the getOutputStream() has already been called for this response error
		out.clear();
		out = pageContext.pushBody(); 

		mySessionHandler.createGeneListActivity("Downloaded Homologenes for Gene List", dbConn);
       	} else {
		/*
		if (selectedGeneList.getNumber_of_genes() > 200) {
                	log.debug("trying to do homologene on list with more than 200 genes");
                        //Error - "Cannot do homologene on list with more than 200 genes"
                        session.setAttribute("errorMsg", "GL-009");
                        response.sendRedirect(commonDir + "errorMsg.jsp");
		} else {
		*/
                	// 
                        // perform these steps every time this module is called
                        //
                        GeneList.Gene[] myGeneArray = selectedGeneList.getGenesAsGeneArray(dbConn);

                        numRows = myGeneArray.length;
                        if (numRows == 0) {
				//Error - "No genes"
                                session.setAttribute("errorMsg", "GL-004");
                                response.sendRedirect(commonDir + "errorMsg.jsp");
                        } else {
                                // 
                                // create an array of all the gene IDs
                                // and pass this to iDecoder
                                //
                                String [] idvalues = new String[numRows];

                                for (int i=0; i<myGeneArray.length; i++) {
                                	idvalues[i] = myGeneArray[i].getGene_id();
                                }

                                String organism = selectedGeneList.getOrganism();
                                log.debug("organism = "+ organism);

                                // 
                                // if there are more than 200 genes, reduce the number of iterations 
                                // for iDecoder in order to try to avoid retrieving more than 1000 identifiers
                                // 
                                if (numRows > 200) {
                                	log.debug("set the number of iterations to 1");
                                        myIDecoderClient.setNum_iterations(1);
                                }
                                try {
									myIDecoderClient.setNum_iterations(2);//Required to get Human results
                                	iDecoderAnswer = myIDecoderClient.getIdentifiersByInputIDAndTarget(selectedGeneList.getGene_list_id(), targets, dbConn);

                                        session.setAttribute("iDecoderAnswer", iDecoderAnswer);
                                } catch (Exception e) {
					log.debug("iDecoder timed out when calling it for gene list home" , e);
                                        //Error - "No iDecoder");
                                        session.setAttribute("errorMsg", "GLT-001");
                                        response.sendRedirect(commonDir + "errorMsg.jsp");
                                
				}

                                if (iDecoderAnswer != null) {
					//log.debug("iDecoderAnswer = "); myDebugger.print(iDecoderAnswer);
                                        Iterator itr = iDecoderAnswer.iterator();

                                        while (itr.hasNext()) {
                                        	Identifier thisIdentifier = (Identifier) itr.next();

                                                if (thisIdentifier.getRelatedIdentifiers().size() == 0) {
                                                	noHomologList.add(thisIdentifier.getIdentifier());
                                                }
                                        }              
					log.debug("before removing, iDecoderAnswer contains "+iDecoderAnswer.size() + " items");
                                        for (int i=0; i<noHomologList.size(); i++) {
                                        	iDecoderAnswer.remove(new Identifier((String) noHomologList.get(i)));
                                        }

                                        log.debug("noHomologList now contains " + noHomologList.size() + " elements");

					mySessionHandler.createGeneListActivity("Got Homologenes for gene list", dbConn);
				} else {
					mySessionHandler.createGeneListActivity("Ran Homologenes on gene list but got no results", dbConn);
                                        log.debug("iDecoderAnswer is null");
                                        //Error - "No iDecoder"
                                        session.setAttribute("errorMsg", "GLT-001");
                                        response.sendRedirect(commonDir + "errorMsg.jsp");
				}
			}
		//}
	}

%>

<%@ include file="/web/common/header.jsp" %>



	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>
	<div class="page-intro">
		<p>Shown below are the homologs found in Entrez: </p>
	</div> <!-- // end page-intro -->

	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>

<% if (selectedGeneList.getGene_list_id() != -99) { %>

	<div class="dataContainer" >
		<form 	method="POST"
			action="homologs.jsp"
			name="homologs"
			enctype="application/x-www-form-urlencoded">

		<div class="brClear"></div>

		<%@ include file="/web/geneLists/include/formatHomologeneResults.jsp" %>

		<input type="hidden" name="action" value=""/>
		<input type="hidden" name="numRows" value="<%=numRows%>"/>
		<input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>"/>
		</form>
	</div>

<% } %>
	
<!-- 
  <div class="load">Loading...</div>
-->

	<script type="text/javascript">
		$(document).ready(function() {
			setupPage();
		});
	</script>

<%@ include file="/web/common/footer.jsp" %>
