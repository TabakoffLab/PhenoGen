/* --------------------------------------------------------------------------------
 *
 *  specific functions for stats.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/

var downloadModal; // modal used for download gene list information/interaction box

function setupPage() {

	//---> set default sort column 
        $("table[name='items']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");

	var tableRows = getRows();
	stripeTable( tableRows );

	tableRows.each(function(){
        	var rowCells = $(this).find("td");

        	//---> center text under description
        	rowCells.slice(2,rowCells.length).css({"text-align" : "center"});
	});
	
	setupDownloadLink('stats');
}

