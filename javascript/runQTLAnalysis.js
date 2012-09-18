/* --------------------------------------------------------------------------------
 *
 *  specific functions for runQTLAnalysis.jsp
 *
 * -------------------------------------------------------------------------------- */
function IsQTLFormComplete(){
	if (isNaN($("#numPerms").val()) || $("#numPerms").val() < 0 || $("#numPerms").val() >1000000){
		alert('You must enter a number between 0 and 1,000,000 for the permutations');
		$("#numPerms").focus();
		return false;
	}
}
