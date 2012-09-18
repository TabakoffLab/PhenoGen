/* --------------------------------------------------------------------------------
 *
 *  specific functions for expressionValues.jsp
 *
 * -------------------------------------------------------------------------------- */

/* * * *
 *  this function sets up all the functionality for this page
/*/

var downloadModal; // modal used for download dataset information/interaction box

function setupPage() {
	var itemDetails; 
	var versionDetails; 
	var detailsBox;
        if (itemDetails == undefined)
		itemDetails = createDialog(".itemDetails" , {width: 700, height: 800, title: "<center>Dataset Details</center>"});
        if (versionDetails == undefined)
		versionDetails = createDialog(".versionDetails" , {width: 700, height: 800, title: "<center>Dataset Version Details</center>"});

	//---> set default sort column
	$("table[id='datasets']").find("tr.col_title").find("th").slice(1,2).addClass("headerSortDown");
	$("table[id='versions']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
	$("table[id='groupMeans']").find("tr.col_title").find("th").slice(1,2).addClass("headerSortDown");
	$("table[id='arrayValues']").find("tr.col_title").find("th").slice(1,2).addClass("headerSortDown");

	var tableRows = getRowsFromNamedTable($("table[id='groupMeans']"));
	stripeTable( tableRows );
	tableRows = getRowsFromNamedTable($("table[id='arrayValues']"));
	stripeTable( tableRows );
	tableRows = getRowsFromNamedTable($("table[id='datasets']"));
	stripeAndHoverTable( tableRows );
	clickRadioButton();

	// setup click for Dataset row item
	tableRows.each(function(){
        	//---> click functionality
        	$(this).find("td").slice(0,2).click( function() {
            		var listItemId = $(this).parent("tr").attr("id");
            		$("input[name='itemIDString']").val( listItemId );
            		document.tableList.submit();
        	});

        	$(this).find("td.details").click( function() {
            		var datasetID = $(this).parent("tr").attr("id");
            		$.get(contextPath + "/web/common/formatParameters.jsp", 
				{datasetID: datasetID, 
				parameterType:"dataset"},
                		function(data){
                    			itemDetails.dialog("open").html(data);
					closeDialog(itemDetails);
                		});
        	});

        	//---> center text 
        	$(this).find("td").slice(1,3).css({"text-align" : "center"});
	});

	var tableRows = getRowsFromNamedTable($("table[id='versions']"));
	stripeAndHoverTable( tableRows );
	clickRadioButton();
	hideLoadingBox();

	// setup click for Version row item
	tableRows.each(function(){
        	//---> click functionality
        	$(this).find("td").slice(0,6).click( function() {
            		var listItemId = $(this).parent("tr").attr("id");
            		$("input[name='itemIDString']").val( listItemId );
            		$("input[name='action']").val("View");
			showLoadingBox();
            		document.versionList.submit();
        	});

                $(this).find("td.details").click( function() {
                        var datasetID = $(this).parent("tr").attr("id").split( "|||" )[0];
                        var version = $(this).parent("tr").attr("id").split( "|||" )[1];
                        $.get(contextPath + "/web/common/formatParameters.jsp",
                                {datasetID: datasetID,
                                datasetVersion: version,
                                parameterType:"datasetVersion"},
                                function(data){
                                        versionDetails.dialog("open").html(data);
                                        closeDialog(versionDetails);
                        });
                });


                //---> center text 
                $(this).find("td").slice(0,1).css({"text-align" : "center"});
                $(this).find("td").slice(2,7).css({"text-align" : "center"});
	});

	/* --- Group Means/Array Values click --- */
	$("div#groupValues").click(function(){
		$("div#displayGroupMeans").show();
		$("div#displayArrayValues").hide();
	});
	$("div#arrayValues").click(function(){
		$("div#displayGroupMeans").hide();
		$("div#displayArrayValues").show();
	});

    	setupDownloadLink('expressionValuesDownload');
}

