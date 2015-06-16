<%--
 *  Author: Spencer Mahaffey
 *  Created: June, 2015
 *  Description:  Views GO term and starts an analysis pulling all GO terms from the ensembl DB.
 *  Todo: 
 *      
--%>
<%@ include file="/web/geneLists/include/geneListHeader.jsp"%>




<jsp:useBean id="thisIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"> </jsp:useBean>
<jsp:useBean id="myEnsembl" class="edu.ucdenver.ccp.PhenoGen.data.external.Ensembl"> </jsp:useBean>

<%
	extrasList.add("jquery.dataTables.min.js");
	log.info("in mir.jsp. user = " + user);
	log.debug("action = " +action);
	request.setAttribute( "selectedTabId", "go" );
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
	
	//multiMiR Defaults
	String table="all";
	String predType="p";
	int cutoff=20;
	String myOrganism=selectedGeneList.getOrganism();
	//end multiMiR Defaults

	QTL.EQTL[] eQTLList = null;



        String [] officialSymbolTargets = {"Gene Symbol"};
	String [] affyTargets = {"Affymetrix ID"};
	String [] chipTargets = {"Affymetrix ID", "CodeLink ID"};
	String [] eQTLTargets = {"Affymetrix ID", "CodeLink ID", "Gene Symbol"};

	String ucscOrganism = null;
	String snpOrganism = null;
	HashMap arrayInfo = null;
	Hashtable ensemblHash = new Hashtable();

	int numRows = 0;
	HashMap currentIDs = new HashMap();
	
        String [] entrezTargets = {
                "RefSeq RNA ID",
                "Gene Symbol",
                "Entrez Gene ID",
                "RefSeq Protein ID"};

        String [] mgiTargets = {"MGI ID"};
        String [] rgdTargets = {"RGD ID"};

        String [] ensemblTargets = {
                "Ensembl ID"};


	formName = "mir.jsp";

       	if ((action != null) && action.equals("Download")) {
			log.debug("action is Download");
			String downloadPath = userLoggedIn.getUserGeneListsDownloadDir();
			String fullFileName = downloadPath + 
					selectedGeneList.getGene_list_name_no_spaces() + 
					"_BasicAnnotation.txt";
	
			
       	} else {
			
		}
	

%>

<%@ include file="/web/common/header_adaptive_menu.jsp" %>


	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>

        <div class="page-intro">
                <p> This page allows you to retrieve all GO terms assigned to gene in the selected gene list.  You can retrieve results from previous runs.</p>
        </div> <!-- // end page-intro -->
	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>
	<style>
		.hoverDetail{ text-decoration:underline;}
	</style>

	<% if (selectedGeneList.getGene_list_id() != -99) { %>
            <table style="width:98%; padding-bottom: 70px;">
                <TR><TD style="width:30%;vertical-align:top;height:100%; min-height:600px;">
                    <div style="display:inline-block;height:100%;min-height:600px;">
                        <div id="goAccord" style="height:100%; text-align:left;">
                        <H2>Run New GO Analysis on Gene List</H2>
                        <div style="font-size:12px;">
                            Save Results as: <BR><input id="name" type="text" size="30"/>
                                <HR />
                                <input type="button" id="runBtn"  value="Run GO" onclick="runGO()"/><span id="runStatus"></span>
                </div>
                
                <H2>GO Results</H2>
                <div>
                    <span style="font-size:10px;">Select a row below to view full results</span>
                    <div id="resultList">
                    </div>
                </div>
                
         	</div>
         </div>

         <!-- END Side bar controls-->
         </TD>
         <TD  style="width:67%; vertical-align:top;">
         <!--data section-->
         <div style="display:inline-block;width:100%;">
         	<div>
            	<div id="resultLoading" style="display:none;width:100%;text-align:center;">
                	<img src="<%=imagesDir%>wait.gif" alt="Loading Results..." text-align="center" ><BR />Loading Results...
                </div>
            	<div id="mirResult" style="width:95%;text-align: left;">
                    <H2>Results</H2>
                   Select previous results from the multiMiR Results section at the left or enter new parameters on the left to run a multiMiR analysis.<BR />
				</div>
         	</div>
         </div>
         <!--END data section-->
         </TD>
         </TR>
         </table>
         <div id="mirresultDetail">
         </div>
	<% } %>
 
	
	<script type="text/javascript">
		var goAutoRefreshHandle=0;
		
		$(document).ready(function() {
			$( 'div#goAccord' ).accordion({ heightStyle: "fill"  });
			
			//setupPage();
			setTimeout("setupMain()", 100); 
			setupExpandCollapse();
			runGetGOResults();
			$( 'div#goAccord' ).accordion({'active':1});
			
			$(".gotooltip").tooltipster({
				position: 'top-left',
				maxWidth: 350,
				offsetX: -10,
				offsetY: 5,
				contentAsHTML:true,
				//arrow: false,
				interactive: true,
				interactiveTolerance: 350
			});
		});
		
		
		
		function runGO(){
			var species="<%=myOrganism%>";
			var id=<%=selectedGeneList.getGene_list_id()%>;
			var name=$('input#name').val();
			$('#wait2').show();
			$('#runStatus').html("");
			$.ajax({
				url: contextPath + "/web/geneLists/include/runGO.jsp",
   				type: 'GET',
				data: {species:species,geneListID:id,name:name},
				dataType: 'html',
				beforeSend: function(){
					$('#runStatus').html("Submitting...");
				},
				complete: function(){
					$('#runStatus').show();
					setTimeout(function (){
						$('#runStatus').html("");
					},20000);
					runGetGOResults();
					$('input#name').val("");
				},
    			success: function(data2){ 
        			$('#runStatus').html(data2);
    			},
    			error: function(xhr, status, error) {
        			$('#runStatus').html("An error occurred Try submitting again. Error:"+error);
    			}
			});
		}
		
		function runGetGOResults(){
			var id=<%=selectedGeneList.getGene_list_id()%>;
			$('#resultList').html("<div id=\"waitLoadResults\" align=\"center\" style=\"position:relative;top:0px;\"><img src=\"<%=imagesDir%>wait.gif\" alt=\"Loading Results...\" text-align=\"center\" ><BR />Loading Results...</div>"+$('#resultList').html());
			$.ajax({
				url: contextPath + "/web/geneLists/include/getGOAnalyses.jsp",
   				type: 'GET',
				data: {geneListID:id},
				dataType: 'html',
                                success: function(data2){ 
                                                mirAutoRefreshHandle=setTimeout(function (){
                                                        runGetMultiMiRResults();
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
                                                            runGetMultiMiRResults();
                                                        }
                                                        ,20000);
                        }
		}
</script>

<%@ include file="/web/common/footer_adaptive.jsp" %>
