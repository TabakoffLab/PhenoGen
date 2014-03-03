/* --------------------------------------------------------------------------------
 *
 *  specific functions for createPhenotype.jsp
 *
 * -------------------------------------------------------------------------------- */
	var somethingEntered = 0;
	var groupsWithExpressionData = 0;
	var groupsWithGenotypeData = 0;

	$("input[name*='PARENT'][type='text']").change(function() {
		var parentName = $(this).attr('name');
		var parentVal = $(this).val();
		/* multipart forms only send parameters that have values or that are hidden */
        	var kids = $("input[parent='" + parentName + "'][type='text']");
        	var kidsHidden = $("input[parent='" + parentName + "'][type='hidden']");
        	kidsHidden.each(function() {
			$(this).val(parentVal);
		});
        	kids.each(function() {
			$(this).val(parentVal);
			disableField($(this));
		});
		if (parentVal == '') {
        		kids.each(function() {
				var kidName = $(this).attr('name');
				$("input[name='" + kidName + "']").val('');
				enableField($(this));
			});
		}
	});	

	function copyToHidden(element) {
		var elementName = element.name;
		var elementVal = element.value;
        	var hiddenFields = $("input[name='" + elementName + "'][type='hidden']");
        	hiddenFields.each(function() {
			$(this).val(elementVal);
		});
	}


	function IsCreatePhenotypeFormComplete(){
		if ($("input[name='phenotypeName']").val() == '') { 
                	alert('You must provide a descriptive name for the phenotype data.')
			$("input[name='phenotypeName']").focus();
                	return false;
		} else if ($("textarea[name='description']").val() == '') { 
                	alert('You must provide a description of the phenotype data.')
			$("textarea[name='description']").focus();
                	return false;
		}
		var radioValue = $("input[name='choice']:checked").val();  
		var filename = $("input[name='filename']").val();
        	if (radioValue == 'upload' && filename == '') {
                	alert('You must choose a file to upload');
			$("input[name='filename']").focus();
                	return false;
		} else if (radioValue == 'upload' && !isTextFile(filename)) {
                	alert('At this time, we are only able to upload text files.  You must provide a text file to upload.')
			$("input[name='filename']").focus();
                	return false;
		}
		if ($("input[name='choice']:checked").val() != 'upload') { 
			if (countEnteredValues()) {
				if ($("input[name='formName']").val() == 'calculateQTLs') {
					if (groupsWithGenotypeData < 15) {
						alert('In order to calculate QTLs, you must enter data for at least 15 groups that have genotype data');
						return false;
					}
				} else if ($("input[name='formName']").val() == 'correlation') {
					if (groupsWithExpressionData < 5) {
						alert('In order to do a correlation analysis, you must enter data for at least 5 groups that have expression data');
						return false;
					}
				}
			} else {
				return false;
			}
			if (!checkUniqueValues()) {
				alert('All values entered for the groups containing genotype data cannot be the same.  You must enter at least one value that is different from the others.')
				return false;
			}
		}
	
		askToRenormalize(document.createPhenotype);
		//displayProgressBar();
		return true;
	}


	function checkUniqueValues() {
  		var groupsToCheck = 0;
        	var inputElements = $("input[name*='MEAN'][type='text']");
		// At least one value entered for the groups containing genotype data has to be different than the others
		var uniqueValuesForGroupsWithGenotypeData = false;
		var valueForGroupsWithGenotypeData = -99;

        	inputElements.each(function() {
			var elementName = $(this).attr('name');
			var groupName = elementName.substr(0,elementName.indexOf('MEAN'));
			var hasGenotypeDataField = $("input[name='"+ groupName + "has_genotype_data" + "']");
			if ($(this).val() != '') {
				if (hasGenotypeDataField.val() == 'Y') {
					if (groupsToCheck == 0) {
						valuesForGroupsWithGenotypeData = $(this).val();
					} else {
						if ($(this).val() != valuesForGroupsWithGenotypeData) {
							uniqueValuesForGroupsWithGenotypeData = true;
							return true;
						}
					}
					groupsToCheck++;
				}
			}
        	});
		if (groupsToCheck > 0 && !uniqueValuesForGroupsWithGenotypeData) {
			return false;
		} else {
			return true;
		}
	}

	function countEnteredValues() {
  		somethingEntered = 0;
  		groupsWithExpressionData = 0;
  		groupsWithGenotypeData = 0;
        	var inputElements = $("input[name*='MEAN'][type='text']");
		var noProblem = true;

        	inputElements.each(function() {
			var elementName = $(this).attr('name');
			var groupName = elementName.substr(0,elementName.indexOf('MEAN'));
			var hasExpressionDataField = $("input[name='"+ groupName + "has_expression_data" + "']");
			var hasGenotypeDataField = $("input[name='"+ groupName + "has_genotype_data" + "']");
			if ($(this).val() != '') {
				if ($(this).val() != parseFloat($(this).val())) {
					alert('You must enter a numeric value for the group mean.')
					$(this).focus();
					noProblem = false;
					return false;
				}
				somethingEntered++;
				if (hasExpressionDataField.val() == 'Y') {
					groupsWithExpressionData++;
				}
				if (hasGenotypeDataField.val() == 'Y') {
					groupsWithGenotypeData++;
				}
			}
        	});
		if (noProblem) {
        		inputElements = $("input[name*='VARIANCE'][type='text']");
        		inputElements.each(function() {
				var elementName = $(this).attr('name');
				var groupName = elementName.substr(0,elementName.indexOf('VARIANCE'));
				var meanField = $("input[name='"+ groupName + "MEAN" + "']");
				if ($(this).val() != '' && meanField.val() == '') { 
					alert('You must enter a value for the mean if you enter a value for the variance.');
					meanField.focus();
					noProblem = false;
					return false;	
				}
				if (($(this).val() != '') && $(this).val() != parseFloat($(this).val())) {
					alert('You must enter a numeric value for the variance.')
					$(this).focus();
					noProblem = false;
					return false;
				}
        		});
		}
		if (noProblem) {
			return true;
		} else {
			return false;
		}
	}
	
	function askToRenormalize(form) {
		var radioValue = $("input[name='choice']:checked").val();  
		var expName = $("input[name='expName']").val();
		var phenotypeName = $("input[name='phenotypeName']").val();
		var renormalizeVal = $("input[name='askToRenormalize']").val(); 
		var msg = "";
		if (renormalizeVal == "true") {
			var renormInfo = "If you choose to re-normalize, a new dataset will be created and normalized using only "+
				"the groups for which you "+
				"have phenotype values.\n\nIt will be named '" + expName + " Re-normalized for "+
				"correlation with " + phenotypeName + "'.\n\n"+
				"If you choose not to "+
				"re-normalize, you will use this version of the public dataset that "+
				"contains the arrays "+
				"in all the groups.";
				//\n\nClick OK, and you "+ 
				//"will be asked whether you would like to re-normalize or not.";

	        	if (radioValue != 'upload' && 
				countEnteredValues()< $("input[name='numGroups']").val()) {
                		msg = "Since you have not entered phenotype values for all of the "+
					"groups, you have the option to re-normalize the "+
                        		"dataset using only the groups for which you have "+
					"entered values.\n\n" + renormInfo;
        		} else {
                		msg = "If your file does not contain phenotype values for all of the "+
					"groups, you have the option to re-normalize the "+
                        		"dataset using only the groups for which you have entered "+
					"values.\n\n" + renormInfo;
        		}

			msg = msg + "\n\n" + "Click OK if you would like to "+
				"re-normalize.\n\nOtherwise, click Cancel to continue using the existing version.";
			//alert(msg);
			if (confirm(msg)) {
				$("input[name='goingToRenormalize']").val("true");
				alert("A new dataset will be created called '" + expName + " Re-normalized "+
				"for correlation with "+ phenotypeName + "'.\n\n"+
				"The normalization process will take some time.  You will receive an email "+
					"when it is ready.");
			} else {
				$("input[name='goingToRenormalize']").val("false");
			}
		} else {
			$("input[name='goingToRenormalize']").val("false");
		}
  	}

	var phenotypeMeans = new Array();
	var phenotypeVariances = new Array();
	var phenotypeDescriptions = new Array();

	function phenotypeMean(phenotypeParameterGroupID, groupName, mean) {
                this.phenotypeParameterGroupID = phenotypeParameterGroupID;
                this.groupName = groupName;
                this.mean = mean;
        }

	function phenotypeVariance(phenotypeParameterGroupID, groupName, variance) {
                this.phenotypeParameterGroupID = phenotypeParameterGroupID;
                this.groupName = groupName;
                this.variance = variance;
        }

        function phenotypeDescription(phenotypeParameterGroupID, description) {
                this.phenotypeParameterGroupID = phenotypeParameterGroupID;
                this.description = description;
        }

	function showPhenotypeFields() {
		var radioValue = $("input[name='choice']:checked").val(); 

        	if (radioValue == 'upload') {
                	$("div#upload_div").show();
                	$("div#new_div").show();
                	$("div#listPhenotypes").hide();
			populateDuration("Masking.Missing.Strains", document.createPhenotype);
			disableNewPhenotypeValues();
        	// Enter new
        	} else if (radioValue == 'new') {
                	$("div#upload_div").hide();
                	$("div#new_div").show();
                	$("div#listPhenotypes").hide();
			populateDuration("Masking.Missing.Strains", document.createPhenotype);
			clearNewPhenotypeValues();
        	// Copy from existing
        	} else if (radioValue == 'copy') {
			clearNewPhenotypeValues();
			document.createPhenotype.copyFromID.focus();
                	$("div#upload_div").hide();
                	$("div#new_div").show();
                	$("div#listPhenotypes").show();
			populateDuration("Masking.Missing.Strains", document.createPhenotype);
        	} else {
                	$("div#upload_div").hide();
                	$("div#new_div").hide();
                	$("div#listPhenotypes").hide();
        	}
	}

	function displayProgressBar() {
		//CallJS('Demo(document.createPhenotype)');
	}

	function clearNewPhenotypeValues() {
		$("input[name*='MEAN']").val("");
		$("input[name*='VARIANCE']").val("");
		enableField($("input[name*='MEAN']"));
		enableField($("input[name*='VARIANCE']"));
	}

	function disableNewPhenotypeValues() {
		$("input[name*='MEAN']").val("--- in uploaded file ---");
		$("input[name*='VARIANCE']").val("--- in uploaded file ---");
		disableField($("input[name*='MEAN']"));
		disableField($("input[name*='VARIANCE']"));
	}

	function displayPhenotypeValues() {
		var phenotypeParameterGroupID = $("select[name='copyFromID']").val();

		// First clear all values
		clearNewPhenotypeValues();

		// Then copy all the values
		for (var i=0; i<phenotypeMeans.length; i++) {
			if (phenotypeMeans[i].phenotypeParameterGroupID == phenotypeParameterGroupID) {
				var groupName = phenotypeMeans[i].groupName;
				var groupName = phenotypeMeans[i].groupName.replace("/", "SLASH");
				var meanField = $("input[name='"+ groupName + "_MEAN" + "']");
				meanField.val(phenotypeMeans[i].mean);
			}
		}
		for (var i=0; i<phenotypeVariances.length; i++) {
			if (phenotypeVariances[i].phenotypeParameterGroupID == phenotypeParameterGroupID) {
				var varianceField = $("input[name='"+ phenotypeVariances[i].groupName + "_VARIANCE" + "']");
				varianceField.val(phenotypeVariances[i].variance);
			}
		}
	}

	function toggleVarianceFields() {
        /*if ($("input[name='showVariance']").is(':checked')) {
			$("div#varianceDiv").show();
		} else {
			$("div#varianceDiv").hide();
		}*/
		
		if ($("input[name='showVariance']").is(':checked')) {
			$(".varianceDiv").show();
		} else {
			$(".varianceDiv").hide();
		}
	}

	function disableCopyOptionIfPhenotypeEmpty(){
		$("select[name='copyFromID']").each(function() {
			var itemCount = $('option', this).length;
			if (itemCount <= 1) {
				$("input[name='choice']:nth(2)").attr("disabled", "disabled");//change 3rd one
			}
		});
	}
