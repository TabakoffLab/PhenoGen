/* --------------------------------------------------------------------------------
 *
 *  specific functions for resources.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/

var downloadModal; // modal used for download resources interaction box

function setupPage() {

	var itemDetails = createDialog(".itemDetails" , {width: 950, height: 800, title: "Resource Details"});

	var tableRows = getRowsFromNamedTable($("table[id='expressionFiles']"));
	stripeAndHoverTable( tableRows );

	tableRows.each(function(){
		//---> center text under description
		var rowCells = $(this).find("td");
		rowCells.slice(4,7).css({"text-align" : "center"});
		//rowCells.slice(5,6).css({"text-align" : "center"});
	});

	//---> set default sort column to date descending
	var tableRows = getRowsFromNamedTable($("table[id='markerFiles']"));
	stripeAndHoverTable( tableRows );

	tableRows.each(function(){
		//---> center text under description
		var rowCells = $(this).find("td");
		rowCells.slice(4,7).css({"text-align" : "center"});
		//rowCells.slice(5,6).css({"text-align" : "center"});
	});

	//---> set default sort column to date descending
        $("table[id='expressionFiles']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
	$("table[id='markerFiles']").find("tr.col_title").find("th").slice(1,2).addClass("headerSortDown");

	setupDownloadButtonByType(contextPath + "/web/sysbio/directDownloadFiles.jsp",contextPath + "/web/sysbio/seqFileDownload.jsp");
}
