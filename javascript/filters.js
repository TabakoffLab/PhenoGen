//
// show the parameter values for the CodeLink datasets on the filters.jsp page
//
function show_CodeLink_filter_parameters() {

	populateDuration(document.filters.filterMethod.value, document.filters);

	var filterMethod = $("select[name='filterMethod']").val();

        // No method or CodeLink Control Genes Filter selected
        if (filterMethod == '0' || 
            filterMethod == 'CodeLinkControlGenesFilter') { 
		showOnlyThisDiv("");
        } else if (filterMethod == 'CodeLinkCallFilter') {
		showOnlyThisDiv("codelink_call_div");
        } else if (filterMethod == 'GeneSpringCallFilter') {
		showOnlyThisDiv("abs_call_div");
        } else if (filterMethod == 'MedianFilter') {
		showOnlyThisDiv("median_div");
                for (i=1; i<20; i++) {
                        j = i/20;
                        k = j*100;
                        document.filters.filterThreshold.options[i] = new Option(j, k);
                }
		// default to 0.5
                document.filters.filterThreshold.options[10].selected = true;
        } else if (filterMethod == 'CoefficientVariationFilter') {
		showOnlyThisDiv("coeff_div");
                // This generates the list: .01, .02, .03, .04
                for (i=1; i<5; i++) {
                        j = i/100;
			if (parseInt(document.filters.numGroups.value) <= 2) {
                        	document.filters.coeffGroup1.options[i] = new Option(j, j);
                        	document.filters.coeffGroup2.options[i] = new Option(j, j);
			} else {
                        	document.filters.coeffOverall.options[i] = new Option(j, j);
			}
                }
                // This generates the list: .05, .1, .15 ... .95
                for (i=1; i<20; i++) {
                        j = i/20;
			if (parseInt(document.filters.numGroups.value) <= 2) {
                        	document.filters.coeffGroup1.options[i+4] = new Option(j, j);
                        	document.filters.coeffGroup2.options[i+4] = new Option(j, j);
			} else {
                        	document.filters.coeffOverall.options[i+4] = new Option(j, j);
			}
                }
                // This adds .99 as the final option
		if (parseInt(document.filters.numGroups.value) <= 2) {
                	document.filters.coeffGroup1.options[24] = new Option(.99, .99);
                	document.filters.coeffGroup2.options[24] = new Option(.99, .99);
		} else {
                	document.filters.coeffOverall.options[24] = new Option(.99, .99);
		}
        } else if (filterMethod == 'NegativeControlFilter') {
		showOnlyThisDiv("neg_div");
        } else if (filterMethod == 'HeritabilityFilter') {
		showOnlyThisDiv("heritability_div");
        } else if (filterMethod == 'GeneListFilter') {
		showOnlyThisDiv("gene_list_div");
        } else if (filterMethod == 'QTLFilter') {
		showOnlyThisDiv("qtl_list_div");
        } else if (filterMethod == 'VariationFilter' || 
        	filterMethod == 'FoldChangeFilter') {
		showOnlyThisDiv("cluster_filter_div");
        } else {
        }
}

function showOnlyThisDiv(thisDivName) {
	var divArray = new Array("abs_call_div", 
				"negative_control_div", 
                		"codelink_call_div",
                		"median_div",
                		"coeff_div",
                		"neg_div",
                		"flag_div",
                		"bg2sd_div",
                		"low_int_div",
                		"heritability_div",
                		"gene_list_div",
                		"qtl_list_div",
                		"cluster_filter_div");

	for (var i=0; i<divArray.length; i++) {
		if (thisDivName == divArray[i]) {
			$("div#"+divArray[i]).show();
		} else {
			$("div#"+divArray[i]).hide();
		}
	}
}


// show the parameter values for the cDNA datasets on the filters.jsp page
function show_cDNA_filter_parameters() {
	populateDuration(document.filters.filterMethod.value, document.filters);

	var filterMethod = $("select[name='filterMethod']").val();

        // No method selected or the first 3
        if ((filterMethod == '0') || 
            (filterMethod == 'KeepAI,UTDDEST,NM') || 
            (filterMethod == 'RemoveUTDDEST') || 
            (filterMethod == 'RemoveESTs')) { 
		showOnlyThisDiv("");
        // rm.flag method 
        } else if (filterMethod == 'FilterUsingFlagValues') {
		showOnlyThisDiv("flag_div");
        // BG2SD method
        } else if (filterMethod == 'PercentGreaterThanBackgroundPlus2SDFilter') {
		showOnlyThisDiv("bg2sd_div");
                // This generates the list: 10, 20, 30, 40 ... 90
                for (i=1; i<10; i++) {
                        j = i*10;
                        document.filters.bg2sdThreshold.options[i] = new Option(j, j);
                }
        // low.int method
        } else if (filterMethod == 'LowIntensityFilter') {
		showOnlyThisDiv("low_int_div");
        } else {
        }

}

// show the parameter values for the oligo datasets on the filters.jsp page
function show_oligo_filter_parameters() {
	populateDuration(document.filters.filterMethod.value, document.filters);

	var filterMethod = $("select[name='filterMethod']").val();
        if (filterMethod == '0' ||
        	filterMethod == 'AffyControlGenesFilter') {
		showOnlyThisDiv("");
        } else if (filterMethod == 'MAS5AbsoluteCallFilter' || filterMethod == 'DABGPValueFilter') {
		showOnlyThisDiv("abs_call_div");
        } else if (filterMethod == 'NegativeControlFilter') {
		showOnlyThisDiv("negative_control_div");
        } else if (filterMethod == 'MedianFilter') {
		showOnlyThisDiv("median_div");
                for (i=1; i<20; i++) {
                        j = i/20;
                        k = j*100;
                        document.filters.filterThreshold.options[i] = new Option(j, k);
                }
		// default to 0.5
                document.filters.filterThreshold.options[10].selected = true;
        } else if (filterMethod == 'CoefficientVariationFilter') {
		showOnlyThisDiv("coeff_div");
                // This generates the list: .01, .02, .03, .04
                for (i=1; i<5; i++) {
                        j = i/100;
			if (parseInt(document.filters.numGroups.value) <= 2) {
                        	document.filters.coeffGroup1.options[i] = new Option(j, j);
                        	document.filters.coeffGroup2.options[i] = new Option(j, j);
			} else {
                        	document.filters.coeffOverall.options[i] = new Option(j, j);
			}
                }
                // This generates the list: .05, .1, .15 ... .95
                for (i=1; i<20; i++) {
                        j = i/20;
			if (parseInt(document.filters.numGroups.value) <= 2) {
                        	document.filters.coeffGroup1.options[i+4] = new Option(j, j);
                        	document.filters.coeffGroup2.options[i+4] = new Option(j, j);
			} else {
                        	document.filters.coeffOverall.options[i+4] = new Option(j, j);
			}
                }
                // This adds .99 as the final option
		if (parseInt(document.filters.numGroups.value) <= 2) {
                	document.filters.coeffGroup1.options[24] = new Option(.99, .99);
                	document.filters.coeffGroup2.options[24] = new Option(.99, .99);
		} else {
                	document.filters.coeffOverall.options[24] = new Option(.99, .99);
		}
        } else if (filterMethod == 'HeritabilityFilter') {
		showOnlyThisDiv("heritability_div");
        } else if (filterMethod == 'GeneListFilter') {
		showOnlyThisDiv("gene_list_div");
        } else if (filterMethod == 'QTLFilter') {
		showOnlyThisDiv("qtl_list_div");
        } else if (filterMethod == 'VariationFilter' || 
        	filterMethod == 'FoldChangeFilter') {
		showOnlyThisDiv("cluster_filter_div");
        } else {
        }

}

function IsChooseFilterFormComplete(){

	var filterMethod = $("select[name='filterMethod']").val();
	if (filterMethod == '0') { 
		alert('You must select a Filter Method.')
	        document.filters.filterMethod.focus();
		return false; 
	}
	if (filterMethod == 'GeneListFilter') { 
		if (document.filters.geneListID.value == '-99') { 
			alert('You must select a Gene List.')
			document.filters.geneListID.focus();
			return false; 
		}
	} else if (filterMethod == 'VariationFilter' || 
		filterMethod == 'FoldChangeFilter') { 
		var keepPercentageField = document.filters.keepPercentage;
		var keepNumberField = document.filters.keepNumber;
		var keepPercentage = keepPercentageField.value;
		var keepNumber = keepNumberField.value;
		if (keepPercentage != '' && keepNumber != '') { 
			alert('You may enter either a percentage, or a number of probe sets to keep, but not both.')
			keepPercentageField.focus();
			return false; 
		}
		if (keepPercentage != '') {
			if (keepPercentage == parseFloat(keepPercentage)) {
				keepPercentage = parseFloat(keepPercentage);
				if (keepPercentage <= 0 || keepPercentage >= 100) {
					alert('You must enter a number between 0 and 100 for the percentage of probe sets to keep.')
					keepPercentageField.focus();
					return false; 
				} 
			} else {
				alert('You must enter an integer between 0 and 100 for the percentage of probe sets to keep.')
				keepPercentageField.focus();
				return false; 
			}
		}
		if (keepNumber != '') {
			if (keepNumber == parseInt(keepNumber)) {
				keepNumber = parseInt(keepNumber);
				if (keepNumber <= 0) {
					alert('You must enter an integer value for the number of probe sets to keep.')
					keepNumberField.focus();
					return false; 
				} 
			} else {
				alert('You must enter an integer value for the number of probe sets to keep.')
				keepNumberField.focus();
				return false; 
			}
		}
	//
	// If Absolute Call Filter is chosen, make sure the parameters are selected
	//
        } else if (filterMethod == 'MAS5AbsoluteCallFilter' || filterMethod == 'DABGPValueFilter') {
		if (parseInt(document.filters.numGroups.value) <= 2) {
			if (document.filters.absCallGroup1.value == '-99') { 
				alert('Select a value for group 1.')
		        	document.filters.absCallGroup1.focus();
				return false; 
			} else if (document.filters.absCallGroup2.value == '-99') { 
				alert('Select a value for group 2.')
		        	document.filters.absCallGroup2.focus();
				return false; 
			}
		} else {
			if (document.filters.absCallOverall.value == '-99') { 
				alert('Select a value for all groups.')
		        	document.filters.absCallOverall.focus();
				return false; 
			}
		}
	//
	// If Negative Control Filter is chosen, make sure the parameters are selected
	//
	} else if (filterMethod == 'NegativeControlFilter' &&
		document.filters.datasetPlatform.value == 'Affymetrix') { 
		if (parseInt(document.filters.numGroups.value) <= 2) {
			if (document.filters.negativeControlGroup1.value == '-99') { 
				alert('Select a value for group 1.')
		        	document.filters.negativeControlGroup1.focus();
				return false; 
			} else if (document.filters.negativeControlGroup2.value == '-99') { 
				alert('Select a value for group 2.')
		        	document.filters.negativeControlGroup2.focus();
				return false; 
			}
		} else {
			if (document.filters.negativeControlOverall.value == '-99') { 
				alert('Select a value for all groups.')
		        	document.filters.negativeControlOverall.focus();
				return false; 
			}
		}
	//
	// If Coefficient Variation Filter is chosen, make sure the parameters are selected
	//
	} else if (filterMethod == 'CoefficientVariationFilter') { 
		if (parseInt(document.filters.numGroups.value) <= 2) {
			if (document.filters.coeffGroup1.value == '-99') { 
				alert('Select a value for group 1.')
		        	document.filters.coeffGroup1.focus();
				return false; 
			} else if (document.filters.coeffGroup2.value == '-99') { 
				alert('Select a value for group 2.')
		        	document.filters.coeffGroup2.focus();
				return false; 
			}
		} else {
			if (document.filters.coeffOverall.value == '-99') { 
				alert('Select a value for all groups.')
		        	document.filters.coeffOverall.focus();
				return false; 
			}
		}
	//
	// If Codelink Call Filter is chosen, make sure the parameters are selected
	//
	} else if (filterMethod == 'CodeLinkCallFilter') { 
		if (parseInt(document.filters.numGroups.value) <= 2) {
			if (document.filters.codeLinkCallGroup1.value == '-99') { 
				alert('Select a value for group 1.')
		        	document.filters.codeLinkCallGroup1.focus();
				return false; 
			}
			else if (document.filters.codeLinkCallGroup2.value == '-99') { 
				alert('Select a value for group 2.')
		        	document.filters.codeLinkCallGroup2.focus();
				return false; 
			}
		} else {
			if (document.filters.codeLinkCallOverall.value == '-99') { 
				alert('Select a value for all groups.')
		        	document.filters.codeLinkCallOverall.focus();
				return false; 
			}
		}
	//
	// If GeneSpring Call Filter is chosen, make sure the parameters are selected
	//
	} else if (filterMethod == 'GeneSpringCallFilter') { 
		if (parseInt(document.filters.numGroups.value) <= 2) {
			if (document.filters.absCallGroup1.value == '-99') { 
				alert('Select a value for group 1.')
		        	document.filters.absCallGroup1.focus();
				return false; 
			} else if (document.filters.absCallGroup2.value == '-99') { 
				alert('Select a value for group 2.')
		        	document.filters.absCallGroup2.focus();
				return false; 
			}
		} else {
			if (document.filters.absCallOverall.value == '-99') { 
				alert('Select a value for all groups.')
		        	document.filters.absCallOverall.focus();
				return false; 
			}
		}
	//
	// If Negative Control Filter is chosen, make sure the parameters are selected
	//
		
	} else if (filterMethod == 'NegativeControlFilter' &&
		document.filters.datasetPlatform.value == 'CodeLink') { 
		if (parseInt(document.filters.numGroups.value) <= 2) {
			if (document.filters.codeLinkNegativeControlGroup1.value == '-99') { 
				alert('Select a value for group 1.')
		        	document.filters.codeLinkNegativeControlGroup1.focus();
				return false; 
			} else if (document.filters.codeLinkNegativeControlGroup2.value == '-99') { 
				alert('Select a value for group 2.')
		        	document.filters.codeLinkNegativeControlGroup2.focus();
				return false; 
			}
		} else {
			if (document.filters.codeLinkNegativeControlOverall.value == '-99') { 
				alert('Select a value for all groups.')
		        	document.filters.codeLinkNegativeControlOverall.focus();
				return false; 
			}
		}
	//
	// If Heritability Filter is chosen, make sure the level is entered
	//
	} else if (filterMethod == 'HeritabilityFilter') { 
		var field = document.filters.heritabilityLevel;
		var heritabilityLevelErrorMessage = 'You must enter a value greater than 0 and less than 1 for the heritability level.';
		if (!valIsNumeric(field.value)) {
			alert(heritabilityLevelErrorMessage)
			field.focus();
			return false; 
		} else if (field.value == '' ||
				field.value <= 0 || 
				field.value >= 1) { 
				alert(heritabilityLevelErrorMessage);
				field.focus();
				return false; 
		}
	//
	// If Median Filter is chosen, make sure the parameters are selected
	//
	} else if (filterMethod == 'MedianFilter') { 
		if (document.filters.filterThreshold.value == '-99') { 
			alert('Select a value for filter threshold.')
		        document.filters.filterThreshold.focus();
			return false; 
		}
	}
	document.getElementById("param-working").style.display = 'block';
	/*CallJS('Demo(document.filters)');*/
	return true;
}

function displayParameters() {
	$("div#filter_choice_div").show();
	var platform = $("input[id='datasetPlatform']").val();
	if (platform == 'Affymetrix') {
		show_oligo_filter_parameters();
	} else if (platform == 'CodeLink') {
		show_CodeLink_filter_parameters();
	} else if (platform == 'cDNA') {
		show_cDNA_filter_parameters();
	}
}

function displayWorking(){
	document.getElementById("hdf5-working").style.display = 'block';
	return true;
}

