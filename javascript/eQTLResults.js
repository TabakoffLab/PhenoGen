/* --------------------------------------------------------------------------------
 *
 *  specific functions for eQTLResults.jsp
 *
 * -------------------------------------------------------------------------------- */

/* * * *
 *  this function sets up all the functionality for this page
/*/
function setupPage() {
	$("input[name='action']").click(function(){ 
		toggleAdvancedSettings();
	});
	setupAdvancedSettings();
	setupOptionList();
    	setupDownloadLink('eQTLResults');
	//---> set default sort column to the gene symbol
        $("table[name='items']").find("tr.col_title").find("th").slice(2,3).addClass("headerSortDown");
        //---> apply 'zebra' stripes to rows returned and also sort by gene symbol by default
	//tablesorterSettings = { widgets: ['zebra'], sortList:[[2,0]] };
        //$("table[name='items']").tablesorter(tablesorterSettings);
}


/* * *
 *  syncs up the row options
/*/
function blurOthers() {
	var radioValue = $("input[name='haveEQTL']:checked").val(); 
	if (radioValue == "N") {
		clearEQTLoptions();
	} else {
		enableEQTLoptions();
	}
}

function clearEQTLoptions() {
	$("input[name='rowRestrictions']").attr('checked', '');
	disableField($("input[name*='rowRestrictions']"));
}
function enableEQTLoptions() {
	enableField($("input[name*='rowRestrictions']"));
}


/* * *
/* * *
 *  sets up the list of options
/*/
function setupOptionList() {
    $(".expandList").click(function(){ resetOptions() })
}

/* * *
 *  sets up the advanced settings button click and attributes of the window
/*/
function setupAdvancedSettings() {
	var init = true;
	// setup click on advanced settings
	$("div#advancedSettingsButton").click(function(){
		$(this).toggleClass("current");

		if (init) {
			init = false;
		}
		toggleAdvancedSettings();
	});

	if ( $("input[name='advSettings']").attr("value") ==  "open" ) {
		$("div#advancedSettingsButton").click();
	}

	$("#advancedSettingsRegions").draggable({revert: true, handle: "div.dragHandle"});
}

/* * *
 *  show/hide advanced settings form
/*/
var toggleAdvancedSettings = function( speed ) {
        var advancedSettings = $("#advancedSettingsRegions");

        if ( advancedSettings.is(":hidden") )
            $("input[name='advSettings']").attr({value: "open"});
        else
            $("input[name='advSettings']").attr({value: "close"});

        speed = speed == undefined ? 500 : speed;

        advancedSettings.toggle(speed);
    }

/* * *
 *  resets the options list
/*/
var resetOptions = function( delay ) {

        delay = delay == undefined ? 0 : delay;

        setTimeout( "showList()", delay );
    }

var showList = function() {
        $("table[name='options'] tr").show();
        $("div.list_container").removeClass("singleItem");
    };
