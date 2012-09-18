/* --------------------------------------------------------------------------------
 *
 *  specific functions for clusterResults.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * *
 *  Sets up the "Save" button to save gene list
/*/
function setupSaveButton() {
	$("div#saveGeneList").click(function(){
		$("input[name='action']").val("Save Gene List");
		$("form[name='clusterResults']").submit();
	});
}
