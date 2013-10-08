/* --------------------------------------------------------------------------------
 *
 *  specific functions for geneList.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/
function setupPage() {

    //var tableRows = getRows();
    //stripeTable( tableRows );
	//---> set default sort column
    //$("table[name='items']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");

    //tableRows.each(function(){
    //    var rowCells = $(this).find("td");

        //---> center text under description
    //    rowCells.slice(2,rowCells.length).css({"text-align" : "center"});
    //});
   
	setupDownloadLink('geneList');
}

