/* --------------------------------------------------------------------------------
 *
 *  specific functions for advancedQuery.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/
function setupPage() {
	setupFinalizeDataset();
	//hideDoseField();
	//hideDurationField();
}

var compoundDoseCombos = new Array();
var treatmentDurationCombos = new Array();

function compoundDoseCombo(compound, dose) {
	this.compound = compound;
        this.dose = dose;
}
function treatmentDurationCombo(treatment, duration) {
	this.treatment = treatment;
        this.duration = duration;
}

function changeAttributeValues() {
	$("input[name='action']").val("Change Values");
	$("form[name='chooseCriterion']").submit();
	$("input[name='action']").val("Get Arrays");
}

function hideDoseField() {
	$("div#doseField").hide();
}
function hideDurationField() {
	$("div#durationField").hide();
}

function showDoseField() {
	//$("div#doseField").show();
	var compound = $("select[name='compound']").val();
	var dose_options = '<option value="All">All</option>';
	for (var i=0; i<compoundDoseCombos.length; i++) {
		if (compoundDoseCombos[i].compound == compound && compoundDoseCombos[i].dose != '') {
	        	dose_options += '<option value="' + compoundDoseCombos[i].dose + '">' + compoundDoseCombos[i].dose + '</option>';
		}
	}
	$("select[name='dose']").html(dose_options);
}
function showDurationField() {
	//$("div#durationField").show();
	var treatment = $("select[name='treatment']").val();
	var duration_options = '<option value="All">All</option>';
	for (var i=0; i<treatmentDurationCombos.length; i++) {
		if (treatmentDurationCombos[i].treatment == treatment && treatmentDurationCombos[i].duration != '') {
	        	duration_options += '<option value="' + treatmentDurationCombos[i].duration + '">' + treatmentDurationCombos[i].duration + '</option>';
		}
	}
	$("select[name='duration']").html(duration_options);
}

