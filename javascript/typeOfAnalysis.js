/* --------------------------------------------------------------------------------
 *
 *  specific functions for listDatasets.jsp
 *
 * -------------------------------------------------------------------------------- */

/* * * *
 *  this function sets up all the functionality for this page
/*/

var deleteModal; // modal used for delete dataset information/interaction box

function setupPage() {
	var itemDetails = createDialog(".itemDetails" , {width: 700, height: 800, title: "Dataset Details"});

	//---> set default sort column
	//$("table[id='publicDatasets']").find("tr.col_title").find("th").slice(1,2).addClass("headerSortUp");
	//$("table[id='privateDatasets']").find("tr.col_title").find("th").slice(1,2).addClass("headerSortUp");

	var tableRows = getRows();
	//stripeAndHoverTable( tableRows );
	stripeTable( tableRows );
	//clickRadioButton();

	$('span.specific').click(function(){
		var listItemId = $(this).parent("td").parent("tr").attr("id");
        $("input[name='dsFilterStatID']").val( listItemId );

		var step=$(this).attr("id");
		$("input[name='specificStep']").val( step );
		
		document.tableList.submit();
	});

	// setup click for Dataset row item
	/*tableRows.each(function(){
        	//---> click functionality
        	$(this).find("td").slice(0,6).click( function() {
            		var listItemId = $(this).parent("tr").attr("id");
            		$("input[name='dsFilterStatID']").val( listItemId );
            		document.tableList.submit();
        	});*/

        	/*$(this).find("td.details").click( function() {
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
        	$(this).find("td").slice(1,9).css({"text-align" : "center"});
	});*/

	setupLocalDeleteButton(contextPath + "/web/datasets/deleteFilterStat.jsp"); 
	setupExtendButton(contextPath + "/web/datasets/extendFilterStat.jsp");
	//setupDownloadButton(contextPath + "/web/datasets/downloadDataset.jsp");
}

function setupLocalDeleteButton(url) {
	var modalOptions = {height: 450, width: 750, position: [250,150], title: "Delete Item"};
	deleteModal = createDialog( ".deleteItem", modalOptions );

	$("table#prevList").find("td div.delete").click(function() {
		var theRow = $(this).parents("tr");
                var dataParams = {itemID: theRow.attr("id") };
		if (dataParams.itemID.indexOf('|||') > -1) {
			dataParams = { itemIDString: theRow.attr("id") };
		}

		// send to .jsp to handle delete
		$.ajax({
			type: "POST",
                	url: url,
                	dataType: "html",
                	data: dataParams,
                	async: false,
                	success: function( html ){
                    		deleteModal.html( html ).dialog("open");
                	},
                	error: function(XMLHttpRequest, textStatus, errorThrown) {
                    		alert( "there was an error processing this request: " + textStatus + " " + errorThrown );
                	}
		});
	});
}

function setupExtendButton(url) {
	$("table#prevList").find("td div.expiration").click(function() {
		var theRow = $(this).parents("tr");
                var dataParams = {itemID: theRow.attr("id") };
		if (dataParams.itemID.indexOf('|||') > -1) {
			dataParams = { itemIDString: theRow.attr("id") };
		}

		// send to .jsp to handle delete
		$.ajax({
			type: "POST",
                	url: url,
                	dataType: "html",
                	data: dataParams,
                	async: false,
                	success: function (html){
						window.location.reload()
					},
                	error: function(XMLHttpRequest, textStatus, errorThrown) {
                    		alert( "there was an error processing this request: " + textStatus + " " + errorThrown );
                	}
		});
	});
}
