<%--
 *  Author: Spencer Mahaffey
 *  Created: March, 2014
 *  Description:  Views multiMiR data and combines it with eQTL data in circos plots.
 *  Todo: 
 *  Modification Log:
		Mar, 2006: Modified by Cheryl Hornbaker to call iDecoder instead.
 *      
--%>
<%@ include file="/web/geneLists/include/geneListHeader.jsp"%>




<jsp:useBean id="thisIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"> </jsp:useBean>
<jsp:useBean id="myQTL" class="edu.ucdenver.ccp.PhenoGen.data.QTL"> </jsp:useBean>
<jsp:useBean id="myEnsembl" class="edu.ucdenver.ccp.PhenoGen.data.external.Ensembl"> </jsp:useBean>

<%
	extrasList.add("jquery.dataTables.1.10.9.min.js");

        tall="53em";
        
	QTL.EQTL myEQTL = myQTL.new EQTL();
	log.info("in mir.jsp. user = " + user);
	log.debug("action = " +action);
	request.setAttribute( "selectedTabId", "mir" );
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
        if(userLoggedIn.getUser_name().equals("anon")){
            optionsListModal.add("linkEmail");
        }
	//optionsList.add("download");
	
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
                <p> This page contains miRNAs that target the genes in your list.  </p>
        </div> <!-- // end page-intro -->
	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>
	<style>
		.hoverDetail{ text-decoration:underline;}
	</style>

	<% if (selectedGeneList.getGene_list_id() != -99) { %>
        <div id="container">
        <div id="toolsAccord" style="text-align:left;">
                        <H2>Run New Analysis on Gene List</H2>
                        <div style="font-size:12px;min-height:175px;">
                                Save Results as: <input id="name" type="text" size="15"/>
                            <HR />
                                Validation Level: 
                                    <select name="table" id="table">
                                        <option value="all" <%if(table.equals("all")){%>selected<%}%>>All</option>
                                        <option value="validated" <%if(table.equals("validated")){%>selected<%}%>>Validated Only</option>
                                        <option value="predicted" <%if(table.equals("predicted")){%>selected<%}%>>Predicted Only</option>
                                        <option value="disease" <%if(table.equals("predicted")){%>selected<%}%>>Disease/Drug Only</option>
                                    </select>
                                    <span class="mirtooltip"  title="Limit results returned to those with any hits(All), or only validated hits(Validated Only) , or only predicted hits(Predicted Only)"><img src="<%=imagesDir%>icons/info.gif"></span>
                                    <HR />
                           Predicted Cutoff Type:
                                    <select name="predType" id="predType">
                                        <option value="p" <%if(predType.equals("p")){%>selected<%}%>>Top percentage of miRNA targets</option>
                                        <option value="n" <%if(predType.equals("n")){%>selected<%}%>>Top number of miRNA targets</option>
                                    </select>
                                    <span class="mirtooltip"  title="Limit predicted search to only the top ___% or # of predicted miRNA targets.  The default will only search the top 20% of all predicted results by default."><img src="<%=imagesDir%>icons/info.gif"></span>
                                    <HR />
                                    Predicted Cutoff: Top <input id="cutoff" type="text" size="5" value="<%=cutoff%>" /><span id="lblPerc">% of</span>  miRNA-target pairs.
                                    <span class="mirtooltip"  title="Set the cutoff for the predicted cutoff type.  Ex. If Top percentage of miRNA targets is selected and 10 is entered you are searching the top 10% of predicted targets.  If Top number of miRNA targets is selected and 30000 is entered you are searching only the top 30,000 predicted targets."><img src="<%=imagesDir%>icons/info.gif"></span>
                                    <HR />
                           <!--Disease/Drug Association: --><input id="disease" type="hidden" value="" />
                                    <!--<HR />-->
                           <input type="button" id="runBtn"  value="Run MultiMiR" onclick="runMultiMir()"/><span id="runStatus"></span>
                        </div>

                        <H2>multiMiR Results</H2>
                        <div style="min-height: 150px;">
                                <span style="font-size:10px;">Select a row below to view full results</span>
                            <div id="resultList">
                            </div>
                        </div>

                        </div>
        <div id="topResultData">
                       <div id="resultLoading" style="display:none;width:100%;text-align:center;">
                               <img src="<%=imagesDir%>wait.gif" alt="Loading Results..." text-align="center" ><BR />Loading Results...
                       </div>
                       <div id="mirResult" style="width:95%;text-align: left;">
                           <H2>Results</H2>
                          Select previous results from the multiMiR Results section at the left or enter new parameters on the left to run a multiMiR analysis.<BR />
                                       </div>
        </div>
        </div>
                       
         <div id="mirresultDetail">
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
	<% } %>
 
	<%@ include file="/web/geneLists/include/setupJS.jsp" %>
	<script type="text/javascript">
		var mirAutoRefreshHandle=0;
		var analysisPath="<%=contextRoot%>/web/geneLists/include/getMultiMiRAnalyses.jsp";
		$(document).ready(function() {
			//$( 'div#mirAccord' ).accordion({ heightStyle: "fill"  });
			
			//setupPage();
			setTimeout("setupMain()", 100); 
			setupExpandCollapse();
			runGetResults(-1);
			$(".mirtooltip").tooltipster({
				position: 'top-left',
				maxWidth: 350,
				offsetX: -10,
				offsetY: 5,
				contentAsHTML:true,
				//arrow: false,
				interactive: true,
				interactiveTolerance: 350
			});
                        $( "#dialog-delete-confirm" ).dialog({
                                  autoOpen: false,
                                  resizable: false,
                                  height:175,
                                  width:"40%",
                                  modal: true,
                                  buttons: {
                                    "Delete analysis": function() {
                                      $( this ).dialog( "close" );
                                      runDeleteGeneListAnalysis(idToDelete);
                                      idToDelete=-99;
                                    },
                                    Cancel: function() {
                                      $( this ).dialog( "close" );
                                      idToDelete=-99;
                                    }
                                  }
                        });
                        $( "#dialog-delete-error" ).dialog({
                              autoOpen: false,
                              modal: true,
                              width:"40%",
                              buttons: {
                                Ok: function() {
                                  $( this ).dialog( "close" );
                                }
                              }
                        });
                        $("#predType").change( function(){
                            if($("#predType").val()==='p'){
                                $("#lblPerc").show();
                                if($("#cutoff").val()>100){
                                    $("#cutoff").val("20");
                                }
                            }else{
                                $("#lblPerc").hide();
                                if($("#cutoff").val()<100){
                                    $("#cutoff").val("5000");
                                }
                            }
                        });
		});
		
		
		
		function runMultiMir(){
			var species="<%=myOrganism%>";
			var id=<%=selectedGeneList.getGene_list_id()%>;
			var table=$('select#table').val();
			var predType=$('select#predType').val();
			var cutoff=$('input#cutoff').val();
			var name=$('input#name').val();
			var disease=$('input#disease').val();
			$('#wait2').show();
			$('#runStatus').html("");
			$.ajax({
				url: contextPath + "/web/geneLists/include/runMultiMiR.jsp",
   				type: 'GET',
				data: {species:species,geneListID:id,table:table,predType:predType,cutoff:cutoff,disease:disease,name:name},
				dataType: 'html',
				beforeSend: function(){
					$('#runStatus').html("Submitting...");
				},
				complete: function(){
					$('#runStatus').show();
					setTimeout(function (){
						$('#runStatus').html("");
					},20000);
					runGetResults(0);
					$('select#table').val("all");
					$('select#predType').val("p");
					$('input#cutoff').val("20");
					$('input#disease').val("");
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
		
		function setupGeneLists(){
                    
                }
		
	</script>
<%@ include file="/web/geneLists/include/geneListFooter.jsp"%>
<%@ include file="/web/common/footer_adaptive.jsp" %>
