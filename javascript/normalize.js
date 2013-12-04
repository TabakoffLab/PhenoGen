/* --------------------------------------------------------------------------------
 *
 *  specific functions for normalize.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/
function setupPage() {

	var itemDetails = createDialog(".itemDetails" , {width: 700, height: 800, title: "Grouping Details"});
	// setup view Details click

	var tableRows = getRows();
	stripeAndHoverTable( tableRows );

	//---> set default sort column
        $("table[name='items']").find("tr.col_title").find("th").slice(1,2).addClass("headerSortDown");

	clickRadioButton();

	// setup click for Grouping row item
	tableRows.each(function(){
		$(this).click(function(){
			var grouping_id = $(this).attr("id");
			$("input[name='grouping_id']").val(grouping_id); 
		});
		$(this).find("td.details").click(function(){
			var grouping_id = $(this).parent("tr").attr("id");
			$("input[name='grouping_id']").val(grouping_id); 
			var parameters = {grouping_id: grouping_id};
        		$.get(contextPath + "/web/datasets/showGroupingDetails.jsp", parameters, function(data){
            			itemDetails.dialog("open").html(data);
				closeDialog(itemDetails);
        	});
    	});

        //---> center text under description
        $(this).find("td").slice(0,1).css({"text-align" : "center"});
        $(this).find("td").slice(2,4).css({"text-align" : "center"});
    });

    setupDeleteButton();
	autoSelectNewGrouping();
}

var deleteGroupingModal; // modal used for delete grouping information/interaction box

/* * * *
 *  this function sets up the events for the DELETE button
/*/
function setupDeleteButton() {
    var modalOptions = {height: 250, width: 550, position: [250,250]};
    deleteGroupingModal = createDialog( ".deleteGrouping", modalOptions );

    $("table[name='items']").find("td div.delete").click(
        function() {
            var theRow = $(this).parents("tr");

            var listName = theRow.find("td:first").html();

                var dataParams = { groupingID: theRow.attr("id") };

            // send to .jsp to handle delete
            $.ajax({
                type: "POST",
                url: contextPath + "/web/datasets/deleteGrouping.jsp", // be sure to check security on this page!
                dataType: "html",
                data: dataParams,
                async: false,
                success: function( html ){
                    // you can call another javascript method from here, or put the code for a successful deletion here
                    deleteGroupingModal.html( html ).dialog( "open" );
			alert("Grouping deleted.");
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    alert( "there was an error processing this request: " + textStatus + " " + errorThrown );
                }
            });
        });
}

function confirmGroupingDelete() {
	if ( confirm("Please confirm your choice to delete this grouping") ) {
		return true;
	}
    	deleteGroupingModal.dialog( "close" );
	return false;
}


// show the CodeLink normalization values for the normalize.jsp page
function show_codeLink_normalization_parameters() {
	var normalize_method = $("select[name='normalize_method']").val(); 

        // No method selected
        if (normalize_method == 'none') {
                $("div#loess_div").hide();
                $("div#limma_div").hide();
        // loess
        } else if (normalize_method == 'loess') {
                $("div#loess_div").show();
                $("div#limma_div").hide();
        // vsn
        } else if (normalize_method == 'vsn') {
                $("div#loess_div").hide();
                $("div#limma_div").hide();

        // limma
        } else if (normalize_method == 'limma') {
                $("div#loess_div").hide();
                $("div#limma_div").show();
        }
}

function show_mask() {
        // No method selected
	var normalize_method = $("select[name='normalize_method']").val(); 

        if (normalize_method == 'gcrma') {
		disableField($("input[name='probeMask']"));
	} else {
		enableField($("input[name='probeMask']"));
	}
}

function IsNormalizationFormComplete() {
	var normalize_method = $("select[name='normalize_method']").val();
	var version_name = $("textarea[name='version_name']").val();

	if (normalize_method == 'None') { 
		alert('You must select a normalization method.');
	        	//normalize_method.focus();
		return false; 
	} else if (version_name == '') { 
		alert('You must name this normalized version of your dataset.');
	        //version_name.focus();
		return false; 
	} else 
	//
	//
	// If Loess is chosen, make sure the parameters are selected
	//
	if (normalize_method == 'loess') { 
		var loess_div_parameter1 = $("select[name='loess_div_parameter1']");
		if (loess_div_parameter1.val() == '0') { 
			alert('Select a value for family.loess.')
		        //loess_div_parameter1.focus();
			return false; 
		}
	} else 
	//
	// If limma is chosen, make sure the parameters are selected
	//
	if (normalize_method == 'limma') { 
		var limma_div_parameter1 = $("select[name='limma_div_parameter1']");
		if (limma_div_parameter1.val() == '0') { 
			alert('Select a value for limma method.')
		        //limma_div_parameter1.focus();
			return false; 
		}
	} else if (!IsSomethingSelected($("input[name='grp_id']"))) {
		alert('You must select the array grouping you would like to use for this version.');
		return false; 
	}
	return true;
}

function autoSelectNewGrouping(){
	var newGroupingId = $("#newGroupingID").val();
	$(":radio[value="+newGroupingId+"]").prop('checked',true);
	$("input[name='grouping_id']").val(newGroupingId);
	
	//temporarily highlight newly created grouping		
    $("table[name='items'] tr").each(function() {
       if (newGroupingId == $(this).attr("id")){
          $(this).children('td').effect("highlight", {'color': '#bbbbee'}, 4000);
       }
    });
	
}

