/* --------------------------------------------------------------------------------
 *
 *  specific functions for correlation.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/
var deleteModal; 
var downloadModal; // modal used for download dataset information/interaction box

function setupPage() {

	var itemDetails = createDialog(".itemDetails" , {width: 700, height: 400, title: "Phenotype Details", position:[200,100]});

	//---> set default sort column to phenotype name ascending
        $("table[name='items']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");

	var tableRows = getRows();

	stripeAndHoverTable( tableRows );

	// when calculating QTLS, display the Loading window
	hideLoadingBox();

	// setup click for Phenotype row item
	tableRows.each(function(){
		if ($("input[name='formName']").val() != "phenotypes") {
		//---> click functionality
        		$(this).find("td").slice(0,2).click( function() {
				var rowID = $(this).parent("tr").attr("id");
				if (rowID != null && rowID != '') {
					// have to attach the datasetID to the form's action in case errorMsg is called
					// But this gives an error in jquery on IE, so commenting it out
            				var chosenDatasetID = $("input[name='chosenDatasetID']:checked").val(); 
            				var chosenDatasetVersion = $("input[name='datasetVersion']").val(); 
            				if (chosenDatasetID != null && chosenDatasetID != -99) {
						$("input[name='datasetID']").val(chosenDatasetID); 
					}

					showLoadingBox();
            				$("input[name='action']").val("Run");
            				$("input[name='phenotypeParameterGroupID']").val( rowID );
					$("form[name='listPhenotypes']").submit();
				}
        		});
		}

		$(this).find("td.details").click( function() {
			var parameterGroupID = $(this).parent("tr").attr("id");
			var datasetID = $("input[name='datasetID']").val();
			var datasetVersion = $("input[name='datasetVersion']").val();
			var formName = $("input[name='formName']").val();
			var parameters = {parameterGroupID: parameterGroupID, 
				parameterType: "phenotype",
				formName: formName,
				datasetID: datasetID,
				datasetVersion: datasetVersion};
			$.get(contextPath + "/web/common/formatParameters.jsp", 
				parameters,
				function(data){
					itemDetails.dialog("open").html(data);
					closeDialog(itemDetails);
			});
		});

        	//---> hover functionality
        	var rowCells = $(this).find("td");

        	//---> center text under description
        	rowCells.slice(1,5).css({"text-align" : "center"});
	});

	var changeDataset = function() {
		// have to attach the datasetID to the form's action in case errorMsg is called
		// But this gives an error in jquery on IE, so commented it out
            	var chosenDatasetID = $("input[name='chosenDatasetID']:checked").val(); 
            	$("input[name='datasetID']").val(chosenDatasetID);
            	$("input[name='action']").val("");
		$("input[name='phenotypeParameterGroupID']").val("");
		showLoadingBox();
		$("form[name='listPhenotypes']").submit();
        }
	if ( $.browser.msie ) {
		$("input:radio").click(changeDataset);
	} else {
		$("input:radio").change(changeDataset);
	}

	setupDownloadButton(contextPath + "/web/common/downloadPhenotype.jsp");
	setupDeleteButton(contextPath + "/web/datasets/deletePhenotypeData.jsp"); 
	setupCreatePhenotypeData();
}



/* * *
 *  sets up the create new phenotype modal
/*/
function setupCreatePhenotypeData() {
	var newData;
	// setup create new phenotype button
	$("div[id='createNewPhenotype']").click(function(){
        	if ( newData == undefined ) {
			var dialogSettings = {width: 800, height: 800, title: "Create Phenotype Data"};
			/* browser.safari true means the browser is Safari */
			//if ($.browser.safari) $.extend(dialogSettings, {modal:false});
			newData = createDialog("div.createPhenotypeData", dialogSettings); 
		}
		var parameters = {datasetID: $("input[name='datasetID']").val(), 
				datasetVersion: $("input[name='datasetVersion']").val(),
				formName: $("input[name='formName']").val()};
        	$.get(contextPath + "/web/datasets/createPhenotype.jsp", 
				parameters,
				function(data){
				newData.dialog("open").html(data);
        	});
	});
}
