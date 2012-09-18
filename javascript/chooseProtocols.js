/* --------------------------------------------------------------------------------
 *
 *  specific functions for chooseProtocols.jsp
 *
 * -------------------------------------------------------------------------------- */

/* * * *
 *  this function sets up all the functionality for this page
/*/

var itemDetails; 
var deleteModal; // modal used for deleting information 

function setupPage() {
	itemDetails = createDialog(".itemDetails" , {width: 600, height: 400, title: "<center>Protocol Details</center>"});

	setupTable($("table[id='growth']"));
	setupTable($("table[id='treatment']"));
	setupTable($("table[id='extract']"));
	setupTable($("table[id='label']"));
	setupTable($("table[id='hybrid']"));
	setupTable($("table[id='scanning']"));

	setupCreateProtocol();
	setupDeleteButton(contextPath + "/web/experiments/deleteProtocol.jsp");
}

function setupTable(tableElement) {
        var tableRows = getRowsFromNamedTable(tableElement);
	stripeAndHoverTable( tableRows );

	// setup clicking the row
	clickCheckBoxForNamedTable(tableElement);

	// setup click for each  
	tableRows.each(function(){
        	$(this).find("td.details").click( function() {
            		var description = $(this).parent("tr").attr("descr");
                    	itemDetails.dialog("open").html(description);
			closeDialog(itemDetails);
        	});

        	$(this).find("td.publicDetails").click( function() {
            		var id = $(this).parent("tr").attr("id");
        //    		var title = $(this).parent("tr").attr("title");
			var parameters = {protocolID: id
					//, title:title
					};
        		$.get(contextPath + "/web/experiments/publicDescription.jsp", 
				parameters, 
				function(data){
					itemDetails.dialog("open").html(data);
					closeDialog(itemDetails);
        		});
        	});

        	//---> center text 
        	$(this).find("td").slice(0,1).css({"text-align" : "center"});
        	$(this).find("td").slice(2,3).css({"text-align" : "center"});
	});
}


/* * *
 *  sets up the create protocol for a modal
/*/
function setupCreateProtocol() {
	var newProtocol;
	// setup create new Protocol buttons
	$("div[name='createNewProtocol']").click(function(){
        	if ( newProtocol == undefined ) {
			newProtocol = createDialog("div.createProtocol" , {width: 600, height: 400, title: "<center>Create New Protocol</center>"});
		}
		var protocolType = $(this).attr("id");
		var parameters = {protocolType: protocolType};

		// Need to do path like this ==> otherwise ajax will log out of session
        	$.get(contextPath + "/web/experiments/createProtocol.jsp", 
			parameters, 
			function(data){
				newProtocol.dialog("open").html(data);
				closeDialog(newProtocol);
        	});
	});
}

function IsChooseProtocolsFormComplete () {
	if (!IsSomethingCheckedOnTable($("table[id='extract']"))) { 
		alert('You must select at least one Extraction Protocol in order to proceed.');
                $("input[name='EXTRACT_LABORATORY_PROTOCOL']").focus();
		return false;
	} else if (!IsSomethingCheckedOnTable($("table[id='label']"))) { 
		alert('You must select at least one Labeling Protocol in order to proceed.');
                $("input[name='LABEL_LABORATORY_PROTOCOL']").focus();
                return false;
		return false;
	} else if (!IsSomethingCheckedOnTable($("table[id='hybrid']"))) { 
		alert('You must select at least one Hybridization Protocol in order to proceed.');
                $("input[name='HYBRID_LABORATORY_PROTOCOL']").focus();
		return false;
	} else if (!IsSomethingCheckedOnTable($("table[id='scanning']"))) { 
		alert('You must select at least one Scanning Protocol in order to proceed.');
                $("input[name='SCANNING_LABORATORY_PROTOCOL']").focus();
		return false;
	}
	return true;
}

function IsCreateProtocolFormComplete() {
	var protocolName = $("input[name='protocolName']");
	var description = $("textarea[name='description']");

        if (protocolName.val() == '') { 
        	alert('You must provide a name for the protocol.')
		protocolName.focus();
		return false;
	}
        if (!isValidProtocolName(protocolName.val())) {
                alert('The protocol name can only contain alphanumeric characters or the following: ".", "_", "-", "()".')
		protocolName.focus();
                return false;
        }
        if (description.val() == '') { 
        	alert('You must provide a description for the protocol.')
		description.focus();
		return false;
	}
}


