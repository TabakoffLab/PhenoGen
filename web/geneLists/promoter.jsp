<%--
 *  Author: Cheryl Hornbaker
 *  Created: Apr, 2008
 *  Description:  The web page created by this file displays the analysis results for a gene list
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %> 

<%
	log.info("in promoter.jsp. user = " + user);

	formName = "promoter.jsp";
	request.setAttribute( "selectedTabId", "promoter" );
        extrasList.add("promoter.js");
        extrasList.add("meme.js");
        extrasList.add("jquery.dataTables.min.js");
    
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
	if(!selectedGeneList.getOrganism().equals("Rn")){
		extrasList.add("createOpossum.js");
		//optionsListModal.add("createNewOpossum");
	}
	//optionsListModal.add("createNewMeme");
	//optionsListModal.add("createNewUpstream");

	int itemID = (request.getParameter("itemID") != null ? Integer.parseInt((String) request.getParameter("itemID")) : -99);
        /*String type = ((String)request.getParameter("type") != null ? (String) request.getParameter("type") : "");
	if (itemID != -99) {
		if (type.equals("oPOSSUM")) {
			response.sendRedirect("promoterResults.jsp?itemID="+itemID);
		} else if (type.equals("Upstream")) {
			response.sendRedirect("upstreamExtractionResults.jsp?itemID="+itemID);
		} else {
			response.sendRedirect("memeResults.jsp?itemID="+itemID);
		}
	}

	GeneListAnalysis [] myAnalysisResults = null;
        String header = "";
        String columnHeader = "";
        String msg = "";
	String all="N";
	String title="";
	String createNew="";
	String button="";*/
	mySessionHandler.createGeneListActivity("On promoter tab", pool);

%>
<%@ include file="/web/common/header_adaptive_menu.jsp" %>


	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>
        
	<div class="page-intro">
	
	</div> <!-- // end page-intro -->

	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>
        <div id="container">
        <div id="toolsAccord" style="text-align:left;">
                            <H2>Run New Promoter Analysis on Gene List</H2>
                            <div id="newAnalysis" style="font-size:12px;">
                                <div class="createOpossum"></div>
                                <div class="createMeme"></div>
                                <div class="createUpstream"></div>
                                <HR />
                                <input type="button" id="runBtn"  value="Run GO" onclick="runGO()"/><span id="runStatus"></span>
                            </div>
                            <H2>Promoter Results</H2>
                            <div id="resultsTable">
                                <span style="font-size:10px;">Select a row below to view full results</span>
                                <div id="resultList">
                                </div>
                            </div>
                
            </div>
            <div id="topResultData">

                               <div id="resultLoading" style="display:none;width:100%;text-align:center;">
                                       <img src="<%=imagesDir%>wait.gif" alt="Loading Results..." text-align="center" ><BR />Loading Results...
                               </div>
                               <div id="promoterResult" style="width:100%;text-align: left;">
                                   <H2>Results</H2>
                                  Select previous results from the Promoter Results section at the left or enter new parameters on the left or top to run a new Promoter analysis.<BR />
                               </div>

            </div>
        </div>
	<div class="deleteItem"></div>

        <BR><BR><BR><BR><BR>
	

<%@ include file="/web/geneLists/include/setupJS.jsp" %>
<script type="text/javascript">
		$(document).ready(function() {
			setupPage();
		});
</script>
<%@ include file="/web/common/footer_adaptive.jsp" %>
  <script type="text/javascript">
      var goAutoRefreshHandle=0;
        $(document).ready(function() {
            setTimeout("setupMain()", 100);
            runGetPromoterResults();
        });
        
        function runGetPromoterResults(){
			var id=<%=selectedGeneList.getGene_list_id()%>;
			$('#resultList').html("<div id=\"waitLoadResults\" align=\"center\" style=\"position:relative;top:0px;\"><img src=\"<%=imagesDir%>wait.gif\" alt=\"Loading Results...\" text-align=\"center\" ><BR />Loading Results...</div>"+$('#resultList').html());
			$.ajax({
				url: contextPath + "/web/geneLists/include/getPromoterAnalyses.jsp",
   				type: 'GET',
				data: {geneListID:id},
				dataType: 'html',
                                success: function(data2){ 
                                                goAutoRefreshHandle=setTimeout(function (){
                                                        runGetPromoterResults();
                                                },20000);
                                                $('#resultList').html(data2);
                                },
                                error: function(xhr, status, error) {
                                        $('#resultList').html("Error retreiving results.  Please try again.");
                                }
			});
        }
        function stopRefresh(){
                if(goAutoRefreshHandle){
                        clearTimeout(goAutoRefreshHandle);
                        goAutoRefreshHandle=0;
                }
        }
        function startRefresh(){
                if(!goAutoRefreshHandle){
                    goAutoRefreshHandle=setTimeout(
                                                function (){
                                                    runGetPromoterResults();
                                                }
                                                ,20000);
                }
        }
  </script>
