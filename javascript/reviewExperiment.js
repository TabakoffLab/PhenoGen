/* --------------------------------------------------------------------------------
 *
 *  specific functions for reviewExperiment.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/

var editModal; // modal used for editing hybridization information 
var deleteModal; // modal used for deleting hybridization information 

var divArray = new Array("1",
			"2", 
			"3", 
			"4", 
			"5" 
			);

var currentDiv = "1";

function setupPage() {
	showOnlyThisDiv("1");
	setupShowPages();
	setupEditButton();
	setupDeleteButton(contextPath + "/web/experiments/deleteArray.jsp");
}

function showOnlyThisDiv(thisDivName) {
	var thisDivNum = parseInt(thisDivName);
	for (var i=0; i<divArray.length; i++) {
		if (thisDivName == divArray[i]) {
			$("div#"+divArray[i]).show();
			$("div#goTo_"+divArray[i]).removeClass( "notSelectedRight" );
			$("div#goTo_"+divArray[i]).removeClass( "notSelectedLeft" );
			$("div#goTo_"+divArray[i]).addClass( "selected" );
		} else {
			$("div#"+divArray[i]).hide();
			$("div#goTo_"+divArray[i]).removeClass( "selected" );
			var divNum = parseInt(divArray[i]);
			if (thisDivNum > divNum) {
				$("div#goTo_"+divArray[i]).removeClass( "notSelectedRight" );
				$("div#goTo_"+divArray[i]).addClass( "notSelectedLeft" );
			} else {
				$("div#goTo_"+divArray[i]).removeClass( "notSelectedLeft" );
				$("div#goTo_"+divArray[i]).addClass( "notSelectedRight" );
			}
		}
	}
	currentDiv = thisDivName;
	$("input[name='currentDiv']").val(thisDivName);
}

/* * *
 *  sets up the show pages buttons
/*/
function setupShowPages() {
	for (var i=0; i<divArray.length; i++) {
		$("div#goTo_" + divArray[i]).click(function(){
			var id = $(this).attr("id");
			var newId = id.substring(id.indexOf("_") + 1);
			showOnlyThisDiv(newId);
		});
	}
}

/* * * *
 *  this function sets up the events for the EDIT button
/*/
function setupEditButton() {
	var modalOptions = {height: 600, width: 750, position: [250,20], title: "Edit Hybridization Details"};
        if ( editModal == undefined ) {
		editModal = createDialog( ".editItem", modalOptions );
	}

	$("table[name='items']").find("td div.edit").click(function() {
		var theRow = $(this).parents("tr");
                var dataParams = { itemID: theRow.attr("id")};

		$.ajax({
			type: "POST",
                	url: "edit" + currentDiv + ".jsp",
                	dataType: "html",
                	data: dataParams,
                	async: false,
                	success: function( html ){
                    		editModal.html( html ).dialog("open");
				closeDialog(editModal);
                	},
                	error: function(XMLHttpRequest, textStatus, errorThrown) {
                    		alert( "there was an error processing this request: " + textStatus + " " + errorThrown );
                	}
		});
	});
}

function AreYouSureToContinue(){
	if (confirm('Are you sure you want to finalize your experiment?  '+
			'No changes will be allowed after you finalize your submission.')) { 
		return true;
	} else {
		return false;
	}
}


        function handleOtherFields() {
                handleOPField();
                handleSTField();
                handleDSField();
        }

        function handleOPField() {
                if ($("select[name='tsample_organism_part']").val() == $("input[name='otherOrganismPartValue']").val()) {
                        enableField($("input[name='otherOrganismPart']"));
                } else {
                        $("input[name='otherOrganismPart']").val('');
                        disableField($("input[name='otherOrganismPart']"));
                }
        }
        function handleSTField() {
                // If the user chooses 'other' then enable the field
                if ($("select[name='tsample_sample_type']").val() == $("input[name='otherBiosource_typeValue']").val()) {
                        enableField($("input[name='otherBiosource_type']"));
                } else {
                        $("input[name='otherBiosource_type']").val('');
                        disableField($("input[name='otherBiosource_type']"));
                }
        }
        function handleDSField() {
                // If the user chooses 'other' then enable the field
                if ($("select[name='tsample_dev_stage']").val() == $("input[name='otherDevStageValue']").val()) {
                        enableField($("input[name='otherDevStage']"));
                } else {
                        $("input[name='otherDevStage']").val('');
                        disableField($("input[name='otherDevStage']"));
                }
        }

