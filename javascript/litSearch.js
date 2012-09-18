/* --------------------------------------------------------------------------------
 *
 *  specific functions for litSearch.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/

var deleteModal; 

function setupPage() {

	var tableRows = getRowsFromNamedTable($("table[id='itemslitSearch']"));
	//---> set default sort column
        $("table[id='itemslitSearch']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");

	stripeAndHoverTable( tableRows );

	// setup click for Gene List row item
	//tableRows.each(function(){
		//---> click functionality
	//	$(this).find("td").slice(0,2).click( function() {
	//		var itemID = $(this).parent("tr").attr("id");
	//		var geneListID = $(this).parent("tr").attr("geneListID");
	//		$("input[name='itemID']").val( itemID );
	//		$("input[name='geneListID']").val( geneListID );
	//		document.chooseAnalysislitSearch.submit();
	//	});
	//});
	//setupCreateNewButton();
	setupDeleteButton(contextPath + "/web/geneLists/deleteGeneListAnalysis.jsp"); 
}

/* * *
 *  sets up the create new litSearch modal
/*/
function setupCreateNewButton() {
	var newItem;
	// setup create new litSearch button
	$("div[name='createNewLitSearch']").click(function(){
		if (newItem == undefined) {
			newItem = createDialog("div.createLitSearch", 
				{width: 700, height: 450, title: "<center>Create New Literature Search</center>"});
		}
		$.get("createLitSearch.jsp", function(data){
			newItem.dialog("open").html(data);
		});
	});
}
