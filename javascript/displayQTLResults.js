/* --------------------------------------------------------------------------------
 *
 *  specific functions for displayQTLResults.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/

var downloadModal; // modal used for download QTL results

function setupPage() {
	show_more_parameters();
	show_conf_parameters();
	setupDownloadPage(contextPath + "/web/qtls/downloadQTLAnalysisResults.jsp?itemID=" + 
					$("input[name='phenotypeParameterGroupID']").val());
}

function showOnlyThisNarrowDiv(thisDivName) {
	var divArray = new Array("LOD_div",
				"pvalue_div", 
				"location_div" 
				);

	for (var i=0; i<divArray.length; i++) {
		if (thisDivName == divArray[i]) {
			$("div#"+divArray[i]).show();
		} else {
			$("div#"+divArray[i]).hide();
		}
	}
}

function showOnlyThisConfDiv(thisDivName) {
	var divArray = new Array("bootstrap_div",
				"lodDrop_div",
				"bayesian_div" 
				);

	for (var i=0; i<divArray.length; i++) {
		if (thisDivName == divArray[i]) {
			$("div#"+divArray[i]).show();
		} else {
			$("div#"+divArray[i]).hide();
		}
	}
}

// show the parameter values based on the option chosen for narrowing the results 
function show_more_parameters() {
	var narrowByVal = $("select[name='narrowBy']").val();

        if (narrowByVal == '0') { 
		showOnlyThisNarrowDiv("");
        } else if (narrowByVal == 'LOD') {
		showOnlyThisNarrowDiv("LOD_div");
        } else if (narrowByVal == 'pvalue') {
		showOnlyThisNarrowDiv("pvalue_div");
        } else if (narrowByVal == 'location') {
		showOnlyThisNarrowDiv("location_div");
        }
}

// show the parameter values based on the option chosen for determining confidence intervals
function show_conf_parameters() {
	var confType = $("select[name='confType']").val();

        if (confType == '0' || confType == 'none') { 
		showOnlyThisConfDiv("");
        } else if (confType == 'bootstrap') {
		showOnlyThisConfDiv("bootstrap_div");
        } else if (confType == 'lod') {
		showOnlyThisConfDiv("lodDrop_div");
        } else if (confType == 'bayesian') {
		showOnlyThisConfDiv("bayesian_div");
        }
}

function IsRunQTLSummaryFormComplete(){
	var narrowBy = $("select[name='narrowBy']");
	var narrowByVal = narrowBy.val();
	var confType = $("select[name='confType']");
	var confTypeVal = confType.val();
	if (narrowByVal == '0') { 
		alert('You must select a criteria for narrowing the results.')
	        narrowBy.focus();
		return false; 
	}
	if (narrowByVal == 'LOD') { 
		var LOD_score = $("input[name='LOD_score']");
		if (LOD_score.val() == '') { 
			alert('You must provide a LOD score threshold value.')
			LOD_score.focus();
			return false; 
		} else if (!valIsNumeric(LOD_score.val())) {
			alert('You must provide a number for the LOD score threshold value.')
			LOD_score.focus();
			return false; 
		}
	} else if (narrowByVal == 'pvalue') { 
		var pvalue = $("input[name='pvalue']");
		if (pvalue.val() == '') { 
			alert('You must provide a p-value.')
			pvalue.focus();
			return false; 
		} else if (!valIsNumeric(pvalue.val())) {
			alert('You must provide a number for the p-value.')
			pvalue.focus();
			return false; 
		}
	} else if (narrowByVal == 'location') { 
		var chromosome = $("input[name='chromosome']");
		var minbp = $("input[name='minbp']");
		var maxbp = $("input[name='maxbp']");
		if (chromosome.val() == '') { 
			alert('You must provide a chromosome number or letter.')
			chromosome.focus();
			return false; 
		}
		if (minbp.val() == '') { 
			alert('You must provide the starting base pair location.')
			minbp.focus();
			return false; 
		} else if (!valIsNumeric(minbp.val())) {
			alert('You must provide a number for the starting base pair location.')
			minbp.focus();
			return false; 
		}
		if (maxbp.val() == '') { 
			alert('You must provide the ending base pair location.')
			maxbp.focus();
			return false; 
		} else if (!valIsNumeric(maxbp.val())) {
			alert('You must provide a number for the ending base pair location.')
			maxbp.focus();
			return false; 
		}
	}
	if (confTypeVal == '0') { 
		alert('You must select a method for calculating confidence intervals.')
	        confType.focus();
		return false; 
	}
	//CallJS('Demo(document.displayQTLResults)');
	$("form[name='displayQTLResults']").submit();
	return true;
}

