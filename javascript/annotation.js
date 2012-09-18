/* --------------------------------------------------------------------------------
 *
 *  specific functions for annotation.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/
function setupPage() {

	//---> set default sort column
        $("table[name='items']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
        $("table[name='notFoundItems']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");

    var tableRows = getRows();
    stripeTable( tableRows );

    tableRows.each(function(){
        var rowCells = $(this).find("td");

        //---> center text under description
        rowCells.slice(2,rowCells.length).css({"text-align" : "center"});
    });

    setupDownloadLink('annotation');
}

