<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %>
<%
    String tmpUuid="";
    if(request.getParameter("uuid") !=null){
        tmpUuid=FilterInput.getFilteredInput(request.getParameter("uuid"));
    }
	// Need to include this here, so that it's available on the modal
        extrasList.add("d3.v3.5.16.min.js");
	extrasList.add("createGeneList.js");
	optionsListModal.add("createGeneList");
        
	session.setAttribute("selectedGeneList", null);

	int datasetID = ((String) request.getParameter("datasetID") != null ? Integer.parseInt((String) request.getParameter("datasetID")) : -99);
	int datasetVersion = ((String) request.getParameter("datasetVersion") != null ? Integer.parseInt((String) request.getParameter("datasetVersion")) : -99);

        if(userLoggedIn.getUser_name().equals("anon")){
            optionsListModal.add("linkEmail");
            geneListsForUser= new GeneList[0];
        }else{
            mySessionHandler.createSessionActivity(session.getId(), "Viewed all genelists", pool);
            //
            // Get the gene lists which are stored in PhenoGen
            //
            if (datasetID == -99) {
                    if (geneListsForUser == null) {
                            log.debug("getting new geneListsForUser");
                            geneListsForUser = myGeneList.getGeneLists(userLoggedIn.getUser_id(), "All", "All", pool); 
                    } else {
                            log.debug("geneListsForUser already set");
                    }
            } else {
                    geneListsForUser = myGeneList.getGeneListsForDataset(userLoggedIn.getUser_id(), datasetID, datasetVersion, pool); 
            }
        }
        
    Properties myProperties = new Properties();
    File myPropertiesFile = new File(captchaPropertiesFile);
    myProperties.load(new FileInputStream(myPropertiesFile));
    String pub="";
    String secret="";
    pub=myProperties.getProperty("PUBLIC");

%>

<%pageTitle="Analyze gene list";%>
<%@ include file="/web/geneLists/include/geneListJS.jsp"  %>
<%@ include file="/web/common/header_adaptive_menu.jsp"%>

<script src="https://www.google.com/recaptcha/api.js" async defer></script>



<style>
    .trigger{
        cursor: pointer;
        /* needed for IE?  Don't think so */
	/* cursor: hand; */
	background: url(<%=imagesDir%>icons/add.png) center left no-repeat; 
	padding: 0 10px 0 20px;
    }
    .triggerContent{
        padding-left:25px;
    }
    .less{
            background: url(<%=imagesDir%>icons/min.png) center left no-repeat; 
    }
</style>

	<div class="page-intro" style="width: auto;margin-bottom: 0px;font-size:18px;">
		<p>Click on a gene list to select it for further investigation.</p>
	</div> <!-- // end page-intro -->
        
	<div class="brClear"></div>
        <BR><BR>
	<div class="list_container">
	<form name="chooseGeneList" action="chooseGeneList.jsp" method="get">
            <BR>
            
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
        <%if(userLoggedIn.getUser_name().equals("anon")){%>
        <div style="width:100%;text-align: center;">
            <span class="trigger" name="lostSession">Not seeing other Gene Lists that you previously created?</span>
            <div style="display:none;text-align: left;width:100%;padding:0 25 0 25;" id="lostSession"><HR><BR><BR><span class="trigger" name="register">Did you register and login previously? You may just need to login.</span>  <a href="<%=accessDir%>checkLogin.jsp?url=<%=geneListsDir%>listGeneLists.jsp"><span class="button">Login</span></a>
                    <span style="display:none;" id="register" class="triggerContent"><BR><BR>Existing gene lists will be transferred to your login once you register so you will always be able to login and access them.</span>
                    <BR><BR><BR>
                    <span class="trigger" name="recover">Did you add your email address to the session?  If so you can recover by receiving a link in your email.</span> <span class="button" id="recoverLostSession" style="width:136px;">Recover Session</span>
                    <span style="display:none;" id="recover" class="triggerContent"><BR><BR>If you use the link email address button at the top right of the page you can request that links to previous sessions be sent by email.  This allows you to recover sessions on a different computer or browser or to receive notifications for some tasks that might take longer than you want to wait for them.  </span>
                    <BR><BR><BR>
                    <span class="trigger" name="none">If none of the above apply. Try using the same computer/browser as when you created the list.</span>
            <span style="display:none;" id="none" class="triggerContent"><BR><BR>If none of the above apply clearing your browser's cache or using a different browser or computer can result in not seeing your gene lists as they are associated with a unique identifier that is stored in your browser.  If you are using a different computer or browser
                please visit the site from the computer and browser you previously used.<BR>  
            <B>Except if you cleared your browsers cache AND did not associate an email address you have lost the gene lists you created. You will have to upload/reenter the list.</b></span>
            </span>
        </div>
        <%}%>
	<div class="itemDetails"></div>
	<div class="newGeneList"></div>
	<div class="deleteItem"></div>
	<div class="downloadItem"></div>
	<div class="load">Loading...</div>
        <div id="recoverSession"></div>
	<script type="text/javascript">
                <%if(!tmpUuid.equals("")){%>
                    var tmpUUID="<%=tmpUuid%>";
                <%}%>
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
                       setupRecoverLostSessionByEmail();
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


                function setupRecoverLostSessionByEmail() {
                       var recoverDialog;
                       // setup create new gene list button
                       $("#recoverLostSession").click(function(){
                               if ( recoverDialog == undefined ) {
                                       var dialogSettings = {width: 500, height: 365, title: "Recover Lost Session by Email"};
                                       recoverDialog = createDialog("#recoverSession", dialogSettings); 
                               }
                               $.ajax({
                                    url: "<%=contextRoot%>web/access/recoverAnonSessions.jsp",
                                    type: 'GET',
                                    cache: false,
                                    data: { uuid:PhenogenAnonSession.UUID },
                                    dataType: 'html',
                                    success: function(data2){
                                         recoverDialog.dialog("open").html(data2);
                                    },
                                    error: function(xhr, status, error) {
                                        console.log("ERROR:"+error);
                                    }
                                });
                       });
                }


                function setupGeneLists(){
                    
                    geneListjs.getListGeneLists(true,"#listGeneList","full");
                }

		$(document).ready(function() {
                        setupPage();
			setTimeout("setupMain()", 100);
                        $(document).on('click','span.trigger', function (event){
                            //$("span.trigger").click(function(){
                            var baseName = $(this).attr("name");
                            var thisHidden = $("#" + baseName).is(":hidden");
                            $(this).toggleClass("less");
                            if (thisHidden) {
                                            $("#" + baseName).show();
                            } else {
                                            $("#" + baseName).hide();
                            }
                            });
		});
	</script>
<%@ include file="/web/geneLists/include/geneListFooter.jsp"%>
<%@ include file="/web/common/footer_adaptive.jsp"%>
