function IsMeMeFormComplete(formName) {
   
	if ( (jQuery.trim(formName.minWidth.value) == '') || (parseInt(formName.minWidth.value) <= 1) ) { 
		alert('You must enter a minimum width that is greater than or equal to two.')
	        formName.minWidth.focus();
		return false; 
	}
   
	if ( (jQuery.trim(formName.maxWidth.value) == '') || (parseInt(formName.maxWidth.value) >= 301) ) { 
		alert('You must enter a maximum width that is less than or equal to 300.')
	        formName.maxWidth.focus();
		return false; 
	}
   
	if (jQuery.trim(formName.maxMotifs.value) == '') { 
		alert('You must enter the Maximun number of motifs.')
	        formName.maxMotifs.focus();
		return false; 
	}
   
	if (jQuery.trim(formName.description.value) == '') { 
		alert('You must enter a description.')
	        formName.description.focus();
		return false; 
	}

	if (jQuery.trim(formName.numberOfGenes.value) <= 1) { 
            alert('MEME Analysis cannot be performed for a gene list with only ' + formName.numberOfGenes.value + ' gene(s).');
            return false; 
	}
	return true;
}
