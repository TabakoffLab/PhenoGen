<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %>
<%
	// Need to include this here, so that it's available on the modal
        extrasList.add("d3.v3.min.js");
	extrasList.add("createGeneList.js");
	optionsListModal.add("createGeneList");
	session.setAttribute("selectedGeneList", null);

	int datasetID = ((String) request.getParameter("datasetID") != null ? Integer.parseInt((String) request.getParameter("datasetID")) : -99);
	int datasetVersion = ((String) request.getParameter("datasetVersion") != null ? Integer.parseInt((String) request.getParameter("datasetVersion")) : -99);

        if(userLoggedIn.getUser_name().equals("anon")){
            geneListsForUser= new GeneList[0];
        }else{
            mySessionHandler.createSessionActivity(session.getId(), "Viewed all genelists", pool);
            //
            // Get the gene lists which are stored in PhenoGen
            //
            if (datasetID == -99) {
                    if (geneListsForUser == null) {
                            log.debug("getting new geneListsForUser");
                            geneListsForUser = myGeneList.getGeneLists(userID, "All", "All", pool); 
                    } else {
                            log.debug("geneListsForUser already set");
                    }
            } else {
                    geneListsForUser = myGeneList.getGeneListsForDataset(userID, datasetID, datasetVersion, pool); 
            }
        }

%>

<%pageTitle="Analyze gene list";%>

<%@ include file="/web/common/header.jsp"%>

	<div class="page-intro">
		<p>Click on a gene list to select it for further investigation.</p>
	</div> <!-- // end page-intro -->
	<div class="brClear"></div>

	<div class="list_container">
	<form name="chooseGeneList" action="chooseGeneList.jsp" method="get">

		<div class="leftTitle">Gene Lists </div>
		<table id="listGeneList" name="items" class="list_base tablesorter" cellpadding="0" cellspacing="2" width="98%">
        		<thead>
        		<tr class="col_title">
				<th>Gene List Name</th>
				<th>Date Created</th>
				<th>Number of Genes</th>
				<th>Organism</th>
				<th>List Source
                        		<span class="info" title="Either the dataset that was analyzed to create this gene list, or it's origin.">
                        		<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        		</span>
				</th>
				<th class="noSort" width="8%">Details <span class="info" title="Parameters used in creating this gene list.">
                        		<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        		</span>
				</th>
				<th class="noSort">Delete</th>
				<th class="noSort">Download</th>
        		</tr>
        		</thead>
        		<tbody>

			<%
        		for ( int i = 0; i < geneListsForUser.length; i++ ) {
                		GeneList gl = (GeneList) geneListsForUser[i];  %>
                		<tr id="<%=gl.getGene_list_id()%>" parameterGroupID="<%=gl.getParameter_group_id()%>">
                			<td><%=gl.getGene_list_name()%></td>
                			<td><%=gl.getCreate_date_as_string().substring(0, gl.getCreate_date_as_string().indexOf(" "))%></td>
                			<td><%=gl.getNumber_of_genes()%></td>
                			<td><%=gl.getOrganism()%></td>
                			<td><%=gl.getGene_list_source()%></td>
    					<td class="details"> View</td>
					<td class="actionIcons">
						<div class="linkedImg delete"></div>
					</td>
					<td class="actionIcons">
						<div class="linkedImg download"></div>
					</td>
				</tr>
			<% } %>
			</tbody>
		</table>
		<input type="hidden" name="geneListID" />
		<input type="hidden" name="action" value="" />
		<input type="hidden" name="fromQTL" value="<%=fromQTL%>" />
	</form>
	</div>
	<div class="itemDetails"></div>
	<div class="newGeneList"></div>
	<div class="deleteItem"></div>
	<div class="downloadItem"></div>
	<div class="load">Loading...</div>
	<script type="text/javascript">
                /* --------------------------------------------------------------------------------
                *
                *  specific functions for listGeneList.jsp
                *
                * -------------------------------------------------------------------------------- */
               /* * * *
                *  this function sets up all the functionality for this page
               /*/

                var downloadModal; // modal used for download gene list information/interaction box
                var deleteModal; // modal used for delete gene list information/interaction box
                var itemDetails;
                function setupPage() {
                       itemDetails = createDialog(".itemDetails" , {width: 700, height: 800, title: "Gene List Details"});

                       //---> set default sort column to date descending
                       $("table[name='items']").find("tr.col_title").find("th").slice(1,2).addClass("headerSortUp");

                       var tableRows = getRows();
                       stripeAndHoverTable( tableRows );
                       //clickRadioButton();

                       hideLoadingBox();

                       // setup click for Gene List row item
                       tableRows.each(function(){
                               //---> click functionality
                               $(this).find("td").slice(0,5).click( function() {
                                       var listItemId = $(this).parent("tr").attr("id");
                                       $("input[name='geneListID']").val( listItemId );
                                       showLoadingBox();
                                       document.chooseGeneList.submit();
                               });

                               $(this).find("td.details").click( function() {
                                       var geneListID = $(this).parent("tr").attr("id");
                                       var parameterGroupID = $(this).parent("tr").attr("parameterGroupID");
                                       $.get(contextPath + "/web/common/formatParameters.jsp", 
                                               {geneListID: geneListID, 
                                               parameterGroupID: parameterGroupID,
                                               parameterType:"geneList"},
                                               function(data){
                                                       itemDetails.dialog("open").html(data);
                                                       closeDialog(itemDetails);
                                       });
                               });


                               //---> center text under description
                               var rowCells = $(this).find("td");
                               rowCells.slice(1,4).css({"text-align" : "center"});
                               rowCells.slice(5,6).css({"text-align" : "center"});
                       });

                       setupCreateNewList();
                       setupDeleteButton(contextPath + "/web/geneLists/deleteGeneList.jsp"); 
                       setupDownloadButton(contextPath + "/web/geneLists/downloadGeneList.jsp");
                       
                }

                /* * *
                 *  sets up the create new genelist modal
                /*/
                function setupCreateNewList() {
                       var newList;
                       // setup create new gene list button
                       $("div[name='createGeneList']").click(function(){
                               if ( newList == undefined ) {
                                       var dialogSettings = {width: 800, height: 600, title: "Create Gene List"};
                                       /* browser.safari true means the browser is Safari */
                                       //if ($.browser.safari) $.extend(dialogSettings, {modal:false});
                                       newList = createDialog("div.newGeneList", dialogSettings); 
                               }
                               $.get("createGeneList.jsp", function(data){
                                       newList.dialog("open").html(data);
                               });
                       });
                }

                function setupGeneLists(){
                    
                    geneListjs.getListGeneLists(true,"#listGeneList");
                }

		$(document).ready(function() {
                        setupPage();
			setTimeout("setupMain()", 100); 
		});
	</script>
<%@ include file="/web/geneLists/include/geneListFooter.jsp"%>
<%@ include file="/web/common/footer.jsp"%>
