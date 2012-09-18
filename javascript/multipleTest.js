// hide the multiple test parameter section 
function hide_multiple_test_parameters() {
	$("div#mt_div").hide();
	$("div#alpha_div").hide();
	$("div#storeyAlpha_div").hide();
	$("div#fdrAlpha_div").show();
	$("div#otherAlpha_div").hide();
        $("div#testType_div").hide();
        $("div#storey_div").hide();
}

// show the parameter values for the multipleTest.jsp page
function show_multiple_test_parameters() {
	var mtMethodValue = $("select[id='mt_method']").val();
	$("div#mt_div").show();
        
        // No method selected
        if (mtMethodValue == 'None') {
		$("div#alpha_div").hide();
		$("div#storeyAlpha_div").hide();
		$("div#otherAlpha_div").show();
		$("div#fdrAlpha_div").hide();
                $("div#testType_div").hide();
                $("div#storey_div").hide();
        // Storey FDR
        } else if (mtMethodValue == 'Storey') {
                $("div#testType_div").hide();
		$("div#alpha_div").show();
		$("div#storeyAlpha_div").show();
		$("div#fdrAlpha_div").hide();
		$("div#otherAlpha_div").hide();
                $("div#storey_div").show();
        // Bonferroni, Holm, Hochberg, SidakSS, SidakSD, Benjamini and Hochberg, or Benjamini and Yekutieli
        } else if ((mtMethodValue == 'Bonferroni') ||
                 (mtMethodValue == 'Holm') ||
                 (mtMethodValue == 'Hochberg') ||
                 (mtMethodValue == 'SidakSS') ||
                 (mtMethodValue == 'SidakSD') ||
                 (mtMethodValue == 'BH') ||
                 (mtMethodValue == 'BY')) {
                $("div#testType_div").hide();
		$("div#alpha_div").show();
                $("div#storey_div").hide();
        	if ((mtMethodValue == 'BH') ||
                 	(mtMethodValue == 'BY')) {
			$("div#storeyAlpha_div").hide();
			$("div#fdrAlpha_div").show();
			$("div#otherAlpha_div").hide();
        	} else if ((mtMethodValue == 'Bonferroni') ||
                 	(mtMethodValue == 'Holm') ||
                 	(mtMethodValue == 'Hochberg') ||
                 	(mtMethodValue == 'SidakSS') ||
                 	(mtMethodValue == 'SidakSD')) {
			$("div#storeyAlpha_div").hide();
			$("div#fdrAlpha_div").hide();
			$("div#otherAlpha_div").show();
		}
        // maxT or minP
        } else if ((mtMethodValue == 'maxT') ||
                 (mtMethodValue == 'minP')) {
		$("div#alpha_div").show();
		$("div#storeyAlpha_div").hide();
		$("div#fdrAlpha_div").hide();
		$("div#otherAlpha_div").show();
                $("div#testType_div").show();
                $("div#storey_div").hide();

	// No Adjustment
        } else if (mtMethodValue == 'No Adjustment') { 
		$("div#alpha_div").show();
		$("div#storeyAlpha_div").hide();
		$("div#fdrAlpha_div").hide();
		$("div#otherAlpha_div").show();
                $("div#testType_div").hide();
                $("div#storey_div").hide();
	} else {
        }

}

function displayOnLoad(){
	show_multiple_test_parameters();
}

function IsMultipleTestFormComplete(){
	if (document.multipleTest.mt_method.value == 'None') { 
		alert('You must select a MultipleTest Method.')
	        document.multipleTest.mt_method.focus();
		return false; 
	} else if (document.multipleTest.mt_method.value == 'FDR') { 
		if (document.multipleTest.fdr_parameter2.value < '0') { 
			alert('You must select a value for Multiple Correction Level.')
		        document.multipleTest.fdr_parameter2.focus();
			return false; 
		}
	} else if ((document.multipleTest.mt_method.value == 'maxT') ||
                 (document.multipleTest.mt_method.value == 'minP')) {
		if (document.multipleTest.testTypeDiv_parameter2.value == '-99') { 
			alert('You must select a value for Type of test for permutation.')
		        document.multipleTest.testTypeDiv_parameter2.focus();
			return false; 
		}
		else if (document.multipleTest.testTypeDiv_parameter3.value == '-99') { 
			alert('You must select a value for Number of permutations.')
		        document.multipleTest.testTypeDiv_parameter3.focus();
			return false; 
		}
	}

	var field = document.multipleTest.pvalue;
	if (field.value == 'None') { 
		alert('You must select a p-value');
	        field.focus();
		return false; 
	} else if (!valIsNumeric(field.value)) {
		alert('You must enter a numeric value for the significance threshold.')
		field.focus();
		return false; 
	} else if (field.value == '' ||
			field.value <= 0 || 
			field.value > 1) { 
			alert('You must enter a value between 0 and 1 for the signficance threshold.')
		        field.focus();
			return false; 
	}
	document.getElementById("param-working").style.display = 'block';
	/* Display the progress bar */
	/*CallJS('Demo(document.multipleTest)');*/
	return true;
}

