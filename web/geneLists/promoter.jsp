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
        extrasList.add("promoter1.0.1.js");
        //extrasList.add("meme.js");
        extrasList.add("jquery.dataTables.min.js");
    
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
	/*if(!selectedGeneList.getOrganism().equals("Rn")){
		extrasList.add("createOpossum.js");
	}*/


	int itemID = (request.getParameter("itemID") != null ? Integer.parseInt((String) request.getParameter("itemID")) : -99);

	mySessionHandler.createGeneListActivity("On promoter tab", pool);
        java.util.Date displayTime = Calendar.getInstance().getTime();
	SimpleDateFormat displayFormat = new SimpleDateFormat("MMM dd, yyyy");
	String displayNow = displayFormat.format(displayTime);
%>
<%@ include file="/web/common/header_adaptive_menu.jsp" %>


	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>
        
	<div class="page-intro">
	
	</div> <!-- // end page-intro -->

	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>
        
        <style>
            table.form tr td{
                padding: 5px 0px 5px 0px;
                border-top: #000000 solid 1px;
            }
        </style>
        
        <div id="container">
        <div id="toolsAccord" style="text-align:left;">
                            <H2>Run New Promoter Analysis on Gene List</H2>
                            <div id="newAnalysis" style="font-size:12px;">
                                <% if (selectedGeneList.getOrganism().equals("Mm") ||
                                            selectedGeneList.getOrganism().equals("Rn") ||
                                            selectedGeneList.getOrganism().equals("Hs")) {
                                    %>
                                Type of Promoter Analysis:
                                <select id="promoterType">
                                    <%if(selectedGeneList.getOrganism().equals("Mm") || selectedGeneList.getOrganism().equals("Hs")){ %>
                                    <option value="oPOSSUM">oPOSSUM</option>
                                    <%}%>
                                    <option value="MEME" selected="selected">MEME</option>
                                    <option value="Upstream">Upstream Sequence Extraction</option>
                                </select>
                                    <BR>
                                <div id="createOpossum" style="display:none;">
                                    <form	id="oPOSSUMForm" name="promoter" 
                                            method="post" 
                                            action="createOpossum.jsp" 
                                            enctype="application/x-www-form-urlencoded"   onSubmit="return IsOpossumFormComplete(this)"> 
                                    <BR>
                                    <div class="title">oPOSSUM Parameters</div>
                                    <table class="form"  >
                                            <tr>
                                                    <td>
                                                            <strong>Search Region Level:</strong> 
                                                            <span class="info" title="Size of the region around the transcription start site which is analyzed for transcription factor binding sites.">
                                                            <img src="<%=imagesDir%>icons/info.gif" alt="Help">
                                                            </span>
                                                            <BR>
                                                            <%
                                                            selectName = "searchRegionLevel";
                                                            selectedOption = "6";
                                                            onChange = "";
                                                            style = "";
                                                            optionHash = new LinkedHashMap();
                                                            optionHash.put("1", "-10000 bp to +10000 bp");
                                                            optionHash.put("2", "-10000 bp to +5000 bp");
                                                            optionHash.put("3", "-5000 bp to +5000 bp");
                                                            optionHash.put("4", "-5000 bp to +2000 bp");
                                                            optionHash.put("5", "-2000 bp to +2000 bp");
                                                            optionHash.put("6", "-2000 bp to +0 bp");
                                                            %>
                                                            <%@ include file="/web/common/selectBox.jsp" %>
                                                    </td>
                                            </tr> 
                                            <tr>	
                                                    <td>
                                                            <strong>Conservation Level:</strong>
                                                            <span class="info" title="Conservation with the aligned orthologous mouse sequences is used as a filter such that only sites which fall within these non-coding conserved regions are kept; the most stringent level of conservation is the default.">
                                                            <img src="<%=imagesDir%>icons/info.gif" alt="Help">
                                                            </span>
                                                            <BR>
                                                            <%
                                                            selectName = "conservationLevel";
                                                            selectedOption = "3";
                                                            onChange = "";
                                                            style = "";
                                                            optionHash = new LinkedHashMap();
                                                            optionHash.put("3", "Top 10% of conserved regions (min. conservation 70%)");
                                                            optionHash.put("2", "Top 20% of conserved regions (min. conservation 65%)");
                                                            optionHash.put("1", "Top 30% of conserved regions (min. conservation 60%)");
                                                            %>
                                                            <%@ include file="/web/common/selectBox.jsp" %>
                                                    </td></tr> 
                                            <tr>
                                                    <td>
                                                            <strong>Matrix match threshold:</strong>
                                                            <span class="info" title="The minimum relative score used to report the position as a putative binding site.">
                                                            <img src="<%=imagesDir%>icons/info.gif" alt="Help">
                                                            </span>
                                                            <BR>
                                                            <%
                                                            selectName = "thresholdLevel";
                                                            selectedOption = "2";
                                                            onChange = "";
                                                            style = "";
                                                            optionHash = new LinkedHashMap();
                                                            optionHash.put("1", "75% of maximum possible PWM score for the TFBS");
                                                            optionHash.put("2", "80% of maximum possible PWM score for the TFBS");
                                                            optionHash.put("3", "85% of maximum possible PWM score for the TFBS");
                                                            %>
                                                            <%@ include file="/web/common/selectBox.jsp" %>
                                                    </td>
                                            </tr><tr>
                                                    <td>
                                                            <strong>Description:</strong>
                                                            <span class="info" title="A descriptive name for this analysis.">
                                                            <img src="<%=imagesDir%>icons/info.gif" alt="Help">
                                                            </span>
                                                            <BR>
                                                             <input id="description" type="text" size=50 name="description" value="<%=selectedGeneList.getGene_list_name()%> oPOSSUM Analysis on <%=displayNow%>">

                                                    </td>
                                            </tr> 

                                            </table>

                                    <BR>
                                    <input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>">

                                    </form>
                                           

                                    
                                </div>
                                <div id="createMeme">
                                    	<form	id="memeForm" method="post" action="meme.jsp" 
                                                    enctype="application/x-www-form-urlencoded" onSubmit="return IsMeMeFormComplete(this)"> 
                                            <BR>
                                            <div class="title">MEME Parameters</div>
                                            <table class="form"  style="width:100%;">
                                                    <tr>	
                                                            <td>
                                                                    <strong>Upstream sequence length:</strong>
                                                                    <BR>
                                                                    <%
                                                                    selectName = "upstreamLength";
                                                                    selectedOption = "2";
                                                                    //onChange = "checkSize()";
                                                                    style = "";
                                                                    optionHash = new LinkedHashMap();
                                                                    optionHash.put("0.5", "500 bp upstream region");
                                                                    optionHash.put("1", "1 Kb upstream region");
                                                                    optionHash.put("2", "2 Kb upstream region");
                                                                    optionHash.put("3", "3 Kb upstream region");
                                                                    optionHash.put("4", "4 Kb upstream region");
                                                                    optionHash.put("5", "5 Kb upstream region");
                                                                    optionHash.put("6", "6 Kb upstream region");
                                                                    optionHash.put("7", "7 Kb upstream region");
                                                                    optionHash.put("8", "8 Kb upstream region");
                                                                    optionHash.put("9", "9 Kb upstream region");
                                                                    optionHash.put("10", "10 Kb upstream region");
                                                                    %>
                                                                    <%@ include file="/web/common/selectBox.jsp" %>
                                                            </td>
                                                    </tr>
                                                    <tr id="sizeWarning" style="display:none;">	
                                                            <td colspan="1">
                                                                <span style="color:#FF0000;"><strong>Upstream fasta is too large<span id="warnDetail"></span> - limit is 300 Kb </strong></span>
                                                            </td>
                                                    </tr>
                                                    <tr>	
                                                            <td>
                                                                    <strong>Upstream sequence from:</strong>
                                                                    <BR>
                                                                    <%
                                                                    selectName = "upstreamSelect";
                                                                    selectedOption = "gene";
                                                                    onChange = "";
                                                                    style = "";
                                                                    optionHash = new LinkedHashMap();
                                                                    optionHash.put("gene", "Gene start");
                                                                    optionHash.put("trx", "Each transcript start");
                                                                    optionHash.put("trxcds", "Each transcript coding sequence start");
                                                                    %>
                                                                    <%@ include file="/web/common/selectBox.jsp" %>
                                                            </td>
                                                    </tr>
                                                    <tr>	
                                                            <td class="bottom">
                                                                    <strong>Motif distribution:</strong>
                                                                    <BR>
                                                                    <%
                                                                    selectName = "distribution";
                                                                    selectedOption = "";
                                                                    onChange = "";
                                                                    style = "";
                                                                    optionHash = new LinkedHashMap();
                                                                    optionHash.put("oops", "One per sequence");
                                                                    optionHash.put("zoops", "Zero or one per sequence");
                                                                    optionHash.put("tcm", "Any number of repetitions");
                                                                    %>
                                                                    <%@ include file="/web/common/selectBox.jsp" %>
                                                            </td>
                                                    </tr>
                                                    <tr>	
                                                            <td class="bottom">
                                                                    <strong>Optimum width of each motif: </strong>
                                                                    <BR>
                                                                Min Width (>=2) <input id="minWidth" type="text" size=3 name="minWidth" value=6><BR>
                                                                Max Width (<= 300) <input id="maxWidth" type="text" size=3 name="maxWidth" value=20>
                                                            </td>
                                                    </tr>
                                                    <tr>	
                                                            <td>
                                                                    <strong>Maximum number of motifs to find: </strong>
                                                                    <BR>
                                                                            <input id="maxMotifs" type="text" size=3 name="maxMotifs" value=3>
                                                            </td>
                                                    </tr>
                                                    <tr>
                                                                <td>
                                                                    <strong>Description:</strong>
                                                                    <BR>
                                                                     <input type="text" size=30 name="description" id="description" value="<%=selectedGeneList.getGene_list_name()%> MEME Analysis on <%=displayNow%>">

                                                            </td>

                                                    </tr>

                                            </table>

                                            <BR>

                                            <center>
                                            <!--<input type="reset" value="Reset"> <%=tenSpaces%>-->
                                            <input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>">
                                            <input type="hidden" name="numberOfGenes" value="<%=selectedGeneList.getNumber_of_genes()%>">
                                            </center>

                                            </form>
                                </div>
                                <div id="createUpstream" style="display:none;">
                                    <form	id="upstreamForm"
                                                method="post" 
                                                action="upstream.jsp" 
                                                enctype="application/x-www-form-urlencoded"> 

                                        <div class="title">Upstream Sequence Extraction Parameters</div>
                                        <table class="form" style="width:100%;" >
                                        <tr>
                                                <td>
                                                        <strong>Upstream sequence length:</strong>
                                                        <BR>
                                                        <%
                                                        selectName = "upstreamLength";
                                                        selectedOption = "2";
                                                        onChange = "";
                                                        style = "";
                                                        optionHash = new LinkedHashMap();
                                                        optionHash.put("0.5", "500 bp upstream region");
                                                        optionHash.put("1", "1 Kb upstream region");
                                                        optionHash.put("2", "2 Kb upstream region");
                                                        optionHash.put("3", "3 Kb upstream region");
                                                        optionHash.put("4", "4 Kb upstream region");
                                                        optionHash.put("5", "5 Kb upstream region");
                                                        optionHash.put("6", "6 Kb upstream region");
                                                        optionHash.put("7", "7 Kb upstream region");
                                                        optionHash.put("8", "8 Kb upstream region");
                                                        optionHash.put("9", "9 Kb upstream region");
                                                        optionHash.put("10", "10 Kb upstream region");
                                                        %>
                                                        <%@ include file="/web/common/selectBox.jsp" %>
                                                </td>
                                        </tr>
                                        <tr>	
                                                        <td>
                                                                <strong>Upstream sequence from:</strong>
                                                                <BR>
                                                                <%
                                                                selectName = "upstreamSelect";
                                                                selectedOption = "gene";
                                                                onChange = "";
                                                                style = "";
                                                                optionHash = new LinkedHashMap();
                                                                optionHash.put("gene", "Gene start");
                                                                optionHash.put("trx", "Each transcript start");
                                                                optionHash.put("trxcds", "Each transcript coding sequence start");
                                                                %>
                                                                <%@ include file="/web/common/selectBox.jsp" %>
                                                        </td>
                                        </tr>
                                        </table>

                                        <BR>

                                        <center>
                                        
                                        <input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>"> 
                                        </center>

                                        </form>
                                </div>
                                <HR />
                                <input type="button" id="runBtn"  value="Run Promoter" onclick="runPromoter()"/><span id="runStatus"></span>
                                <% } else { %>
                                            <BR>
                                            <center>
                                            <p> You can only run an upstream extraction on gene lists containing Human, Mouse, or Rat genes.</p>
                                            </center>
                                            
                                <% } %>
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
	<div id="dialog-delete-confirm" title="Permanently Delete this analysis?">
            <p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>This analysis will be permanently deleted and cannot be recovered. Are you sure?</p>
        </div>
        <div id="dialog-delete-error" title="Error">
            <p>
                The analysis was not deleted see error below.
            </p>
            <p>
                <span id="delete-errmsg" style="color:#FF0000;"></span>
            </p>
        </div>
	

<%@ include file="/web/geneLists/include/setupJS.jsp" %>
<%@ include file="/web/common/footer_adaptive.jsp" %>
  <script type="text/javascript">
    var geneNumber=<%=selectedGeneList.getNumber_of_genes()%>;
    var id=<%=selectedGeneList.getGene_list_id()%>;
    var pathImage="<%=imagesDir%>";
    var analysisPath="<%=contextRoot%>/web/geneLists/include/getPromoterAnalyses.jsp";
    $(document).ready(function() {
            setTimeout(function(){
                setupPage();
                setupMain();
                
            },50);
    });
  </script>
