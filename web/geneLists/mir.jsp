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
	extrasList.add("jquery.dataTables.js");
	//extrasList.add("smoothness/jquery-ui.1.11.3.min.css");

	QTL.EQTL myEQTL = myQTL.new EQTL();
	log.info("in mir.jsp. user = " + user);
	log.debug("action = " +action);
	request.setAttribute( "selectedTabId", "mir" );
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
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

<%@ include file="/web/common/header.jsp" %>


	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>

        <div class="page-intro">
                <p> This page contains miRNAs that target the genes in your list.  </p>
        </div> <!-- // end page-intro -->
	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>
	<style>
		.hoverDetail{ text-decoration:underline;}
	</style>

	<% if (selectedGeneList.getGene_list_id() != -99) { %>
    <table style="width:100%;">
    <TR><TD style="width:30%;vertical-align:top;height:100%; min-height:600px;">
    	<div style="display:inline-block;height:100%;min-height:600px;">
		  <div id="mirAccord" style="height:100%; text-align:left;">
            	<H2>Run New Analysis on Gene List</H2>
                <div style="font-size:12px;">
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
                   Predicted Cutoff: Top <input id="cutoff" type="text" size="5" value="<%=cutoff%>" /><span id="lblPerc">% of </span> miRNAs 
                            <span class="mirtooltip"  title="Set the cutoff for the predicted cutoff type.  Ex. If Top percentage of miRNA targets is selected and 10 is entered you are searching the top 10% of predicted targets.  If Top number of miRNA targets is selected and 30000 is entered you are searching only the top 30,000 predicted targets."><img src="<%=imagesDir%>icons/info.gif"></span>
                            <HR />
                   <!--Disease/Drug Association: --><input id="disease" type="hidden" value="" />
                            <!--<HR />-->
                   <input type="button" id="runBtn"  value="Run MultiMiR" onclick="runMultiMir()"/><span id="runStatus"></span>
                </div>
                
                <H2>multiMiR Results</H2>
                <div>
                	<span style="font-size:10px;">Select a row below to view full results</span>
                    <div id="resultList">
                    </div>
                </div>
                
         	</div>
         </div>

         <!-- END Side bar controls-->
         </TD>
         <TD  style="width:68%; vertical-align:top;">
         <!--data section-->
         <div style="display:inline-block;">
         	<div>
            	<div id="resultLoading" style="display:none;width:100%;text-align:center;">
                	<img src="<%=imagesDir%>wait.gif" alt="Loading Results..." text-align="center" ><BR />Loading Results...
                </div>
            	<div id="mirResult" style="width:662px;">
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
		var mirAutoRefreshHandle=0;
		
		$(document).ready(function() {
			$( 'div#mirAccord' ).accordion({ heightStyle: "fill"  });
			
			//setupPage();
			setTimeout("setupMain()", 100); 
			setupExpandCollapse();
			runGetMultiMiRResults();
			$( 'div#mirAccord' ).accordion({'active':1});
			
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
					runGetMultiMiRResults();
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
		
		function runGetMultiMiRResults(){
			var id=<%=selectedGeneList.getGene_list_id()%>;
			$('#resultList').html("<div id=\"waitLoadResults\" align=\"center\" style=\"position:relative;top:0px;\"><img src=\"<%=imagesDir%>wait.gif\" alt=\"Loading Results...\" text-align=\"center\" ><BR />Loading Results...</div>"+$('#resultList').html());
			$.ajax({
				url: contextPath + "/web/geneLists/include/getMultiMiRAnalyses.jsp",
   				type: 'GET',
				data: {geneListID:id},
				dataType: 'html',
				/*beforeSend: function(){
					
				},
				complete: function(){
					
				},*/
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
			if(mirAutoRefreshHandle){
				clearTimeout(mirAutoRefreshHandle);
				mirAutoRefreshHandle=0;
			}
		}
		function startRefresh(){
			if(!mirAutoRefreshHandle){
				mirAutoRefreshHandle=setTimeout(
												function (){
													runGetMultiMiRResults();
												},20000);
			}
		}
		
	</script>

<%@ include file="/web/common/footer.jsp" %>
