/* --------------------------------------------------------------------------------
 *
 *  specific functions for allClusterResults.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/

var deleteModal; 

function setupPage() {

	var tableRows = getRows();

	//---> set default sort column
	if ($("input[name='datasetVersion']").val() == "-99") {
        	$("table[name='items']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
	} else {
        	$("table[name='items']").find("tr.col_title").find("th").slice(7,8).addClass("headerSortDown");
	}
	stripeAndHoverTable(tableRows);

	// setup click for row item
	tableRows.each(function(){
		//---> click functionality
		$(this).find("td").slice(0,8).click( function() {
			var clusterGroupID = $(this).parent("tr").attr("id");
			$("input[name='clusterGroupID']").val(clusterGroupID);
			document.allClusterResults.submit();
		});
	});
	setupDeleteButton(contextPath + "/web/datasets/deleteClusterResults.jsp"); 
}
