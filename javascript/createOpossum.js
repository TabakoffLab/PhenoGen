   function IsOpossumFormComplete(formName) {
       if ( (jQuery.trim(formName.description.value) == '') ) { 
		    alert('You must enter a description and try again.')
	        formName.description.focus();
		    return false; 
	   }
	return true;
   }
