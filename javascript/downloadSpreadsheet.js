/* --------------------------------------------------------------------------------
 *
 *  specific functions for downloadSpreadsheet.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/
function setupPage() {
	$("div#uploadNow").hide();
	$("div#downloadNow").show();
	$("div#downloadNow").click(function(){
		$("div#downloadNow").hide();
		$("div#uploadNow").show();
	});
}

