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

function setupPage() {

	var itemDetails = createDialog(".itemDetails" , {width: 700, height: 800, title: "<center>Gene List Details</center>"});

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
			var dialogSettings = {width: 800, height: 600, title: "<center>Create Gene List</center>"};
			/* browser.safari true means the browser is Safari */
			//if ($.browser.safari) $.extend(dialogSettings, {modal:false});
			newList = createDialog("div.newGeneList", dialogSettings); 
		}
        	$.get("createGeneList.jsp", function(data){
			newList.dialog("open").html(data);
        	});
	});
}
