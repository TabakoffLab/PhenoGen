/* --------------------------------------------------------------------------------
 *
 *  specific functions for qualityControlResults.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/

var deleteModal; 
var arrayDetails;

function setupPage() {
	setTimeout("setupMain()", 100);
//	var arrayDetails = createDialog(".arrayDetails" , {width: 833, height: 900, title: "Array Details", scrollbars: "yes"});


	//---> set default sort columns
	if ($("input[name='qc_complete']").val() == "Y" || $("input[name='qc_complete']").val() == "I") {
		var tablesorterSettings = { widgets: ['zebra'] };
		$("table[id='arrayCompatability']").tablesorter(tablesorterSettings);
		$("table[id='codeLink']").tablesorter(tablesorterSettings);
		$("table[id='maStats']").tablesorter(tablesorterSettings);
        	$("table[id='arrayCompatability']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
        	$("table[id='codeLink']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
        	$("table[id='maStats']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
	} else {
		var tablesorterSettings = { widgets: ['zebra'], headers:{0:{sorter:false}}};
                $("table[id='arrayCompatability']").tablesorter(tablesorterSettings);
        	$("table[id='arrayCompatability']").find("tr.col_title").find("th").slice(1,2).addClass("headerSortDown");
                $("table[id='codeLink']").tablesorter(tablesorterSettings);
        	$("table[id='codeLink']").find("tr.col_title").find("th").slice(1,2).addClass("headerSortDown");
                $("table[id='maStats']").tablesorter(tablesorterSettings);
        	$("table[id='maStats']").find("tr.col_title").find("th").slice(1,2).addClass("headerSortDown");
	}

	$("div[name='approveQC']").click(function(){
		$("input[name='action']").val( "Approve Quality Control Results" );
		$("form[name='qualityControlResults']").submit();
	});

	var tableRows = getRowsFromNamedTable($("table[id='maStats']"));
	stripeTable( tableRows );

	tableRows.each( function(){
        	$(this).find("td.details").click( function() {
			setupArrayDetails($(this));
        	});
    	});

	var tableRows = getRowsFromNamedTable($("table[id='arrayCompatability']"));
	stripeTable( tableRows );

	tableRows.each( function(){
        	$(this).find("td.details").click( function() {
			setupArrayDetails($(this));
        	});
    	});

	var tableRows = getRowsFromNamedTable($("table[id='codeLink']"));
	stripeTable( tableRows );

	tableRows.each( function(){
        	$(this).find("td.details").click( function() {
			setupArrayDetails($(this));
        	});
    	});

	setupDeleteButton(contextPath + "/web/datasets/deleteArray.jsp"); 
	setupDownloadLink("qualityControlResults");
}

function setupArrayDetails(row) {
	if (arrayDetails == undefined) {
		arrayDetails = createDialog(".arrayDetails" , {width: 833, height: 900, title: "Array Details", scrollbars: "yes"});
	}
	var arrayID = row.parent("tr").attr("id");
        $.get(contextPath + "/web/datasets/arrayDetails.jsp", {arrayID: arrayID},
        	function(data){
			arrayDetails.dialog("open").html(data);
			initializeArrayDetailsTab();
			closeDialog(arrayDetails);
		});
}

