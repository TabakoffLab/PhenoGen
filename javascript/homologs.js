/* --------------------------------------------------------------------------------
 *
 *  specific functions for homologs.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/
function setupPage() {

	//---> set default sort column
        $("table[name='items']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");

 	var tableRows = getRows();
	 stripeTable( tableRows );
	hideLoadingBox();
	//$("div[class='load']").hide();
/*
	var loading = createDialog(".load" , {draggable: false, resizable:false, width: 100, height: 100});
	loading.dialog("open");
	loading.parents(".ui-dialog").find(".ui-dialog-titlebar").remove();
	loading.parents(".ui-dialog").find(".ui-dialog-content").css({padding:"30px 20px"});
*/

	/*
	 tableRows.each(function(){
	 	var rowCells = $(this).find("td");

	 	---> center text under description
	 	rowCells.slice(2,rowCells.length).css({"text-align" : "center"});
	 });
	*/

    	setupDownloadLink('homologs');
}

