function IsUserFormComplete(formName){
	var minLength = 6; 				// Minimum length
	
		
	if (jQuery.trim(formName.first_name.value) == '') { 
		alert('You must enter a First Name.')
	        formName.first_name.focus();
		return false; 
	} else if (jQuery.trim(formName.last_name.value) == '') { 
		alert('You must enter a Last Name.')
	        formName.last_name.focus();
		return false; 
	} else if (jQuery.trim(formName.user_name.value) == '') { 
		alert('You must enter a User Name.')
	        formName.user_name.focus();
		return false; 
	// Begin Password Validation
	} else if (jQuery.trim(formName.password.value) == '') { 
		alert('You must enter a Password.')
	        formName.password.focus();
		return false; 
	} else if (formName.password.value != formName.password2.value) { 
		alert('The two password fields do not match.  Please re-enter.')
	        formName.password.focus();
		return false; 
	} else if (formName.password.value.length < minLength) {
		alert('Your password must be at least ' +minLength + ' characters long.')
		formName.password.focus();
		return false;
	} else if (formName.password.value.indexOf(' ') > -1) {
		alert('Spaces are not allowed as part of the password');
		formName.password.focus();
		return false;
	
	} else if (jQuery.trim(formName.country.value) == '') { 
		alert('You must enter the country.');
		formName.country.focus();
		return false;

	} else if (jQuery.trim(formName.first_name.value) == jQuery.trim(formName.last_name.value)) { 
		alert('First name and Last name cannot be the same.');
		formName.last_name.focus();
		return false;
	}

	
	var specials = "~!@#$%^&*()+";			// Special characters
	var numbers = "0123456789";			// Numbers
	var specialChar = 'No';
	var numberChar = 'No';
	for (var i=0; i<formName.password.value.length; i++) {
		temp = "" + formName.password.value.substring(i, i+1);
		if (specials.indexOf(temp) != -1) {
			specialChar = 'Yes';
		} else if (numbers.indexOf(temp) != -1) {
			numberChar = 'Yes';
		}
	}
	if (specialChar == 'No') {
		alert('You must include special characters in your password.')
		formName.password.focus();
		return false;
	} else if (numberChar == 'No') {
		alert('You must include numbers in your password.')
		formName.password.focus();
		return false;
	}	
	// End Password Validation
 
	var filter  = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
	var emailValue = jQuery.trim(formName.email.value);
	if (emailValue == '') { 
		alert('You must enter an Email Address.')
	        formName.email.focus();
		return false; 
	} else if (!filter.test(emailValue)) {
		alert('You must enter a valid Email Address in the form "xxx@yyy.zzz"');
	        formName.email.focus();
		return false; 
	} else if (jQuery.trim(formName.institution.value) == '') { 
		alert('You must enter an Institution.')
	        formName.institution.focus();
		return false; 
	}
	return true;
}
