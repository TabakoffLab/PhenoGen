/* --------------------------------------------------------------------------------
 *
 *  General utility methods for dataset screens
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up the events for deleting arrays from a dummy dataset 
/*/
function setupFinalizeDataset() {
	var datasetDetails = createDialog(".datasetDetails" , 
			{width: 800, height: 600, title: "Dataset Contents", scrollbars: "yes"});
	// setup view Dataset Details click
	$("div#viewFinalizeDataset").click(function(){
		var datasetID = $("input[name='dummyDatasetID']").val();
		var parameters = {datasetID: datasetID};
		$.get(contextPath + "/web/datasets/datasetDetails.jsp", parameters, function(data){
		  	datasetDetails.dialog("open").html(data);
            		datasetDetails.find("td.actionIcons .delete").click(function(){
            			var theRow = $(this).parents("tr");
            			if ( confirm("Please confirm your choice to delete this array") ) {
                			var itemID = theRow.attr("id");
                			var dataParams = { itemID: itemID };
                			// send to .jsp to handle delete
                			$.ajax({
                    				type: "POST",
                    				url: "deleteArrayFromDummyDataset.jsp", // be sure to check security on this page!
                    				dataType: "html",
                    				data: dataParams,
                    				async: false,
                    				success: function(msg){
                        				// you can call another javascript method from here, or put the code for a successful deletion here
                        				alert( "Array deleted");
                        				// remove item from the dom
		                        		theRow.remove();
							$("input[id='test']").val($("input[id='test']").val() - 1);
							var uncheckRow = $("#"+itemID);
            						uncheckRow.find(":checkbox").prop('checked',false);
                    				},
                    				error: function(XMLHttpRequest, textStatus, errorThrown) {
                        				alert( "there was an error processing this request: " + textStatus + " " + errorThrown );
                    				}
                			});
            			}
        		});
			closeDialog(datasetDetails);
		});
	});
}

