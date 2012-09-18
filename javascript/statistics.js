/* --------------------------------------------------------------------------------
 *
 *  specific functions for statistics.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/
function setupPage() {
	var arrayDetails = createDialog(".arrayDetails" , {width: 833, height: 900, title: "<center>Array Details</center>", scrollbars: "yes"});

	var tableRows = getRows();
	tableRows.each( function(){
		$(this).find("td.details").click( function() {
			var arrayID = $(this).parent("tr").attr("id");
			$.get(contextPath + "/web/datasets/arrayDetails.jsp", {arrayID: arrayID},
				function(data){
				   arrayDetails.dialog("open").html(data);
                   initializeArrayDetailsTab();				
				   closeDialog(arrayDetails);
				});
		});
	});
}

function showStatisticsDescription() {
	var method = $("select[name='stat_method']").val();
	
	populateDuration(method, document.statistics);
        
        if (method == 'parametric' || method == 'nonparametric' ||
        	method == 'pearson' || method == 'spearman') {
                $("div#eaves_div").hide();
                $("div#oneWayAnova_div").hide();
                $("div#twoWayAnova_div").hide();
        // eaves test
        } else if (method == 'Noise distribution t-test') {
                $("div#eaves_div").show();
                $("div#oneWayAnova_div").hide();
                $("div#twoWayAnova_div").hide();
        // one-way anova
        } else if (method == '1-Way ANOVA') {
                $("div#eaves_div").hide();
                $("div#oneWayAnova_div").show();
                $("div#twoWayAnova_div").hide();
        // two-way anova
        } else if (method == '2-Way ANOVA') {
                $("div#eaves_div").hide();
                $("div#oneWayAnova_div").hide();
                $("div#twoWayAnova_div").show();
        }

}

function showNonParametricWarning(giveWarning){
	if ((document.statistics.stat_method.value == 'nonparametric') && giveWarning) { 
		alert('Warning:  Non-parametric tests require groups with 5 or more samples each.  Smaller group sizes may give undesirable results.')
	        document.statistics.stat_method.focus();
	}
}

function displayOnLoad(){
	$("div#top_stats_div").show();
        $("div#eaves_div").hide();
        $("div#oneWayAnova_div").hide();
        $("div#twoWayAnova_div").hide();
	showStatisticsDescription();
}

function IsStatisticsFormComplete(){
	if (document.statistics.stat_method.value == 'None') { 
		alert('Select a Statistics Method.')
	        document.statistics.stat_method.focus();
		return false; 
	} else if (document.statistics.stat_method.value == '2-Way ANOVA') { 
		var factor1Option = $("select[id='factor1_criterion']");
		var factor2Option = $("select[id='factor2_criterion']");

		if (factor1Option.val() == 'None') {
			alert('Choose an option for Factor 1')
	        	factor1Option.focus();
			return false; 
		}
		if (factor2Option.val() == 'None') {
			alert('Choose an option for Factor 2')
	        	factor2Option.focus();
			return false; 
		}
		var numArrays = $("input[id='numArrays']").val();
		var factor1Type = "Numeric";
		var factor2Type = "Numeric";
		for (i=0; i<numArrays; i++) {
			var factor1Val = $("input[id='factor1_" + i + "']");
			var factor2Val = $("input[id='factor2_" + i + "']");
			if (factor1Val.val() == '') {
				alert('You must enter a value for Factor 1 for this array.')
			        factor1Val.focus();
				return false; 
			}
			if (factor2Val.val() == '') {
				alert('You must enter a value for Factor 2 for this array.')
			        factor2Val.focus();
				return false; 
			}
			if (!valIsNumeric(factor1Val.val())) {
				factor1Type = "Character";
			}
			if (!valIsNumeric(factor2Val.val())) {
				factor2Type = "Character";
			}
		} 
		var msg = '';
		if (factor1Type == 'Numeric') {
			msg = 'Since factor 1 is numeric, it will be treated as a continuous variable,';
		} else {
			msg = 'Since factor 1 contains characters, it will be treated as a categorical variable,';
		}
		if (factor2Type == 'Numeric') {
			msg = msg + ' and since factor 2 is numeric, it will be treated as a continuous variable.';
		} else {
			msg = msg + ' and since factor 2 contains characters, it will be treated as a categorical variable.';
		}
		alert(msg);
        } else if (document.statistics.stat_method.value == 'Noise distribution t-test') {
		if (document.statistics.eaves_pvalue.value < '0') { 
			alert('You must select a value for Alpha or Multiple Correction Level.')
		        document.statistics.eaves_pvalue.focus();
			return false; 
		}
		if (document.statistics.number_of_probes.value <= 1001) {
			alert('You must have at least 1000 probes in order to create a null distribution for calculating the p-value for a noise distribution t-test.  Please return to the filtering page and remove one or more filters.')
			return false; 
		} 
	}
	document.getElementById("param-working").style.display = 'block';
	/*CallJS('Demo(document.statistics)');*/
	return true;
}

// criteriaArray stores all the values for all the samples for a single criterion
// criteriaValuesArray stores all the available criteriaArrays (2-dimensional)
// criteriaNames stores the name of the criteria (e.g., Cell Line, Gender)

var criteriaValuesArray = new Array();
var criteriaNames = new Array();

function clearFactorValues(num) {
	for (var i=0; i<criteriaArray.length; i++) {
		$("input[id='factor" + num + "_" + i + "']").val(''); 
	}
}

function showFactorValues(num) {
	var selectField = $("select[id='factor" + num + "_criterion']").val(); 
	var fieldTitle = $("input[id='factor" + num + "_name']"); 
	if (selectField == 'None') {
		clearFactorValues(num);
		fieldTitle.val('Factor '+num);
	} else if (selectField == 'UserInput') {
		clearFactorValues(num);
		fieldTitle.val('Enter Factor ' + num +' Name');
	} else {
		var criterionNumber = selectField;
		var criteriaArray = criteriaValuesArray[criterionNumber]; 
		fieldTitle.val(criteriaNames[criterionNumber]);
        	for (var i=0; i<criteriaArray.length; i++) {
			var formField = $("input[id='factor" + num + "_" + i + "']"); 
			formField.val(criteriaArray[i]);
		}
	}
}

