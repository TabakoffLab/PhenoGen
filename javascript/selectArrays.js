/* --------------------------------------------------------------------------------
 *
 *  specific functions for selectArrays.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/
var numArrays = 0;
var deleteModal; 
function setupPage() {
	var userDetails = createDialog(".userDetails" , 
			{width: 700, height: 200, title: "Principal Investigator Details"});
	var arrayDetails = createDialog(".arrayDetails" , 
			{width: 950, height: 900, title: "<center>Array Details</center>", scrollbars: "yes"});

	clickCheckBox();
	setupFinalizeDataset();

	$("div[name='addToDataset']").click(function(){
		 if (countChecked() > 0) {
		 	$("input[name='action']").val("Add Selected Arrays to Dataset");
		 	$("form[name='selectArrays']").submit();
		 }else {
		 	alert("You must first select one or more arrays to add to the dataset.  You select an array by clicking its row.");
		 }
	});

	var tableRows = getRows();
	stripeAndHoverTable( tableRows );

	// row classes are approved, pending, noAccess, request
	var availableArrays = tableRows.not("tr.noAccess");

	// setup click for Array row item
	availableArrays.each(function(){
		//---> click functionality
		var row = $(this);

        	//---> center text under description
		//$(this).find("td").slice(11,12).css({"text-align" : "center"});
	});

	//---> set default sort column
	//Laura changed this using dataTables
	//$("table[name='items']").find("tr.col_title").find("th").slice(7,8).addClass("headerSortDown");

	tableRows.each( function(){
		$(this).find("td.details").click( function() {
			var arrayID = $(this).parent("tr").attr("id");
			$.get(contextPath + "/web/datasets/arrayDetails.jsp", {arrayID: arrayID},
				function(data){
				arrayDetails.dialog("open").html(data);
				initializeArrayDetailsTab();
				closeDialog(arrayDetails);
				});
		});
	});

}

function IsNameDatasetFormComplete() {
	var expName = $("input[name='dataset_name']");
	var description = $("textarea[name='description']");

        if (expName.val() == '') { 
        	alert('You must name the dataset.')
		expName.focus();
		return false;
	}
        if (description.val() == '') { 
        	alert('You must provide a description for the dataset.')
		description.focus();
		return false;
	}
	return true;
}

function countChecked() {
      var n = $("input:checked").length;
      return n;
}
