/* --------------------------------------------------------------------------------
 *
 *  specific functions for listExperiments.jsp
 *
 * -------------------------------------------------------------------------------- */

/* * * *
 *  this function sets up all the functionality for this page
/*/

var editModal; // modal used for editing experiment information 
var deleteModal; // modal used for delete experiment information/interaction box

function setupPage() {
	var itemDetails = createDialog(".itemDetails" , {width: 700, height: 800, title: "<center>Experiment Details</center>"});
	
	

	//---> set default sort column
	$("table[id='publicExperiments']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
	$("table[id='privateExperiments']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");

	var tableRows = getRows();
	stripeAndHoverTable( tableRows );
	clickRadioButton();

	// setup click for Experiment row item
	tableRows.each(function(){
        	//---> click functionality
        	$(this).find("td").slice(0,5).click( function() {
            		var listItemId = $(this).parent("tr").attr("id");
            		$("input[name='experimentID']").val( listItemId );
            		document.tableList.submit();
        	});

        	$(this).find("td.details").click( function() {
            		var experimentID = $(this).parent("tr").attr("id");
            		$.get(contextPath + "/web/experiments/showExpDetails.jsp", 
				{experimentID: experimentID},
                		function(data){
                    			itemDetails.dialog("open").html(data);
					closeDialog(itemDetails);
                		});
        	});

        	//---> center text 
        	$(this).find("td").slice(2,7).css({"text-align" : "center"});
	});

	setupDeleteButton(contextPath + "/web/experiments/deleteExperiment.jsp"); 
}

