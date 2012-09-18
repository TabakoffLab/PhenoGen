/* --------------------------------------------------------------------------------
 *
 *  specific functions for approveRequests.jsp
 *
 * -------------------------------------------------------------------------------- */

/* * * *
 *  this function sets up all the functionality for this page
/*/

function setupPage() {
    setTimeout("setupMain()", 100);
	stripeTable(getRowsFromNamedTable($("table[id='requests']")));
	  $("table[id='requests']").tablesorter({headers:{0:{sorter:false}, 1:{sorter:false}}});
}

function denyAll(){
	//
	// set all radio button values to -1
	//
	$("input[type='radio']").each(function() { 
		if (this.value == -1) { 
			this.checked = true;
		}
	});
}

function approveAll(){
	//
	// set all radio button values to 1
	//
	$("input[type='radio']").each(function() { 
		if (this.value == 1) { 
			this.checked = true;
		}
	});
}

