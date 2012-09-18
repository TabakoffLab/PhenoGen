/* --------------------------------------------------------------------------------
 *
 *  specific functions for promoter.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/

var deleteModal; 

function setupPage() {

	var pathwayRows = getRowsFromNamedTable($("table[id='itemsPathway']"));

	//---> set default sort column
        $("table[id='itemsPathway']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
	stripeAndHoverTable(pathwayRows);

	// setup click for row item
	pathwayRows.each(function(){
		//---> click functionality
		$(this).find("td").slice(0,2).click( function() {
			var itemID = $(this).parent("tr").attr("id");
			var geneListID = $(this).parent("tr").attr("geneListID");
			var type = $(this).parent("tr").attr("type");
			$("input[name='itemID']").val( itemID );
			$("input[name='geneListID']").val( geneListID );
			document.chooseAnalysisPathway.submit();
		});
	});
	setupCreateNewPathwayButton();
	setupDeleteButton(contextPath + "/web/geneLists/deleteGeneListAnalysis.jsp"); 
}



/* * *
 *  sets up the create new Pathway modal
/*/
function setupCreateNewPathwayButton() {
    var newItem;
    $("div[name='createNewPathway']").click(function(){
        if ( newItem == undefined )
            newItem = 
		createDialog("div.createPathway", 
				{position:[250,150], width: 700, height: 350, 
				title: "<center>Create a New Pathway Analysis</center>"});
        $.get("pathway.jsp", function(data){
            newItem.dialog("open").html(data);
		closeDialog(newItem);
        });
    });
}

