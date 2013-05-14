
/* --------------------------------------------------------------------------------
 *
 *  specific functions for compareGeneLists.jsp
 *
 * -------------------------------------------------------------------------------- */

/* * * *
 *  this function sets up all the functionality for this page
/*/

function setupPage() {
	var itemDetails = createDialog(".itemDetails" , {width: 700, height: 800, title: "Gene List Details"});

	//---> set default sort column
	$("table[id='geneLists']").find("tr.col_title").find("th").slice(1,2).addClass("headerSortUp");

	var tableRows = getRows();
	stripeAndHoverTable( tableRows );
	clickRadioButton();

	// setup click for Gene List row item
	tableRows.each(function(){
        	//---> click functionality
        	$(this).find("td").slice(0,4).click( function() {
            		var listItemId = $(this).parent("tr").attr("id");
            		$("input[name='geneListID2']").val(listItemId);
            		$("input[name='action']").val("Select Gene List");
            		document.tableList.submit();
        	});

        	$(this).find("td.details").click( function() {
            		var geneListID = $(this).parent("tr").attr("id");
            		$.get(contextPath + "/web/common/formatParameters.jsp", 
				{geneListID: geneListID, 
				parameterType:"geneList"},
                		function(data){
                    			itemDetails.dialog("open").html(data);
					closeDialog(itemDetails);
                		});
        	});

        	//---> center text 
        	$(this).find("td").slice(1,5).css({"text-align" : "center"});
	});
}

function IsFormComplete(){
	if (document.compareGeneLists.resultGeneList.value == '') { 
		alert('There is nothing in the resulting gene list to save.')
	        document.compareGeneLists.resultGeneList.focus();
		return false; 
	}
	return true;
}

function showResults(form, value, comparisonType) {
	showNumberOfGenesResult(comparisonType);
	form.resultGeneList.value = value;
	form.comparisonType.value = comparisonType;
}


function showNumberOfGenesResult(comparisonType) {
	
	
	$("#numberOfGenes").css({'font-weight': 'bold'});
	
	if (comparisonType == 'Union') {		
	 	$("#numberOfGenes").text($("#unionTempGeneSetSize").val() + " Gene(s)");	
	}
	
	if (comparisonType == 'Intersection') {
        $("#numberOfGenes").text($("#intersectTempGeneSetSize").val() + " Gene(s)"); 
    }
	
	if (comparisonType == 'AminusB') {
        $("#numberOfGenes").text($("#AminusBTempGeneSetSize").val() + " Gene(s)"); 
    }
	
	
	if (comparisonType == 'BminusA') {
        $("#numberOfGenes").text($("#BminusATempGeneSetSize").val() + " Gene(s)"); 
    }
}


    


