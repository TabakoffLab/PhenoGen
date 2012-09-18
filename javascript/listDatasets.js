/* --------------------------------------------------------------------------------
 *
 *  specific functions for listDatasets.jsp
 *
 * -------------------------------------------------------------------------------- */

/* * * *
 *  this function sets up all the functionality for this page
/*/

var downloadModal; // modal used for download dataset information/interaction box
var deleteModal; // modal used for delete dataset information/interaction box

function setupPage() {
	var itemDetails = createDialog(".itemDetails" , {width: 700, height: 800, title: "<center>Dataset Details</center>"});

	//---> set default sort column
	$("table[id='publicDatasets']").find("tr.col_title").find("th").slice(1,2).addClass("headerSortUp");
	$("table[id='privateDatasets']").find("tr.col_title").find("th").slice(1,2).addClass("headerSortUp");

	var tableRows = getRows();
	stripeAndHoverTable( tableRows );
	clickRadioButton();

	// setup click for Dataset row item
	tableRows.each(function(){
        	//---> click functionality
        	$(this).find("td").slice(0,3).click( function() {
            		var listItemId = $(this).parent("tr").attr("id");
            		$("input[name='datasetID']").val( listItemId );
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
        	$(this).find("td").slice(1,9).css({"text-align" : "center"});
	});

	setupDeleteButton(contextPath + "/web/datasets/deleteDataset.jsp"); 
	setupDownloadButton(contextPath + "/web/datasets/downloadDataset.jsp");
}

