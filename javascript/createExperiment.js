/* --------------------------------------------------------------------------------
 *
 *  specific functions for createExperiment.jsp
 *
 * -------------------------------------------------------------------------------- */

/* * * *
 *  this function sets up all the functionality for this page
/*/

function setupPage() {
	var itemDetails = createDialog(".itemDetails" , {width: 400, height: 200, title: "<center>Description</center>"});
	clickCheckBoxForNamedTable($("table[id='factors']"));
	clickCheckBoxForNamedTable($("table[id='designTypes']"));

	//---> set default sort column
	$("table[id='factors']").find("tr.col_title").find("th").slice(1,2).addClass("headerSortDown");
	$("table[id='designTypes']").find("tr.col_title").find("th").slice(1,2).addClass("headerSortDown");

        var tableRows = getRowsFromNamedTable($("table[id='factors']"));
	stripeAndHoverTable( tableRows );

	// setup click for factor row item
	tableRows.each(function(){
        	$(this).find("td.details").click( function() {
            		var description = $(this).parent("tr").attr("descr");
                    	itemDetails.dialog("open").html(description);
			closeDialog(itemDetails);
        	});

        	//---> center text 
        	$(this).find("td").slice(0,1).css({"text-align" : "center"});
        	$(this).find("td").slice(2,3).css({"text-align" : "center"});
	});
        var tableRows = getRowsFromNamedTable($("table[id='designTypes']"));
	stripeAndHoverTable( tableRows );

	// setup click for design type row item
	tableRows.each(function(){
        	$(this).find("td.details").click( function() {
            		var description = $(this).parent("tr").attr("descr");
                    	itemDetails.dialog("open").html(description);
			closeDialog(itemDetails);
        	});

        	//---> center text 
        	$(this).find("td").slice(0,1).css({"text-align" : "center"});
        	$(this).find("td").slice(2,3).css({"text-align" : "center"});
	});
	$("input[name='experimentName']").focus();

}

function IsEnterExperimentFormComplete() {
	var expName = $("input[name='experimentName']");
	var description = $("textarea[name='description']");

        if (expName.val() == '') { 
        	alert('You must provide a name for the experiment.')
		expName.focus();
		return false;
	}
        if (!isValidExperimentName(expName.val())) {
                alert('The experiment name can only contain alphanumeric characters, underscores, and hyphens.')
		expName.focus();
                return false;
        }
        if (description.val() == '') { 
        	alert('You must provide a description for the experiment.')
		description.focus();
		return false;
	}
	if (IsSomethingCheckedOnTable($("table[id='designTypes']"))) { 
		if (IsSomethingCheckedOnTable($("table[id='factors']"))) { 
			if (CheckCombinations()) { 
				return true;
			} else {
				return false;
			}
		} else {
			alert('You must select at least one Experimental Factor in order to proceed.');
			return false;
		}
	} else {
		alert('You must select at least one Experiment Design Type in order to proceed.');
		return false;
	}
	return true;
}

var combinations = new Array();

function combination(designTypeID, designTypeName, factorID, factorName) {
	this.designTypeID = designTypeID;
        this.designTypeName = designTypeName;
        this.factorID = factorID;
        this.factorName = factorName;
}

function CheckCombinations() {
	
	var foundIt = true;

	$("#designTypes :checked").each(function() {
		//foundIt = false;
		var thisType = $(this).val();
//alert('thisType = '+thisType + ' and foundIt is  ' + foundIt + ' right now');
		for (var i=0; i<combinations.length; i++) {
                	if (combinations[i].designTypeID == thisType) {
				foundIt = false;
				$("#factors :checked").each(function() {
					var thisFactor = $(this).val();
                			if (combinations[i].factorID == thisFactor) {
//alert('found the factor');
						foundIt = true;
					} 
				});
				if (!foundIt) {
					alert("You must select '"+ combinations[i].factorName + "' as a factor if you choose '"+
						combinations[i].designTypeName + "' as a design type.");
					return false;
				}
                	}                               
        	}
	});
	if (!foundIt) {
		return false; 
	} else {
		return true;
	}
}

function AreYouSureToContinue(form){
	if (confirm('Are you sure you want to continue?  The experiment as it currently exists will be deleted!')) { 
		return true;
	} else {
		return false;
	}
}


