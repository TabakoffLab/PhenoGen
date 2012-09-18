/* --------------------------------------------------------------------------------
 *
 *  specific functions for createLitSearch.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/

function IsLitSearchFormComplete(form){
        var contentCellCount = 0;
        for(var i=0; i<form.elements.length; i++) {
                if (form.elements[i].type == 'text') {
                        if (form.elements[i].name.substring(0,9) == 'keyword_0') {
                                if (!(form.elements[i].value == '')) {
                                        contentCellCount++;
                                        if (document.litSearch.category0.value == 'None') {
                                                alert('You must select a category for keyword(s) in row 1.')
                                                document.litSearch.category0.focus();
                                                return false;
                                        }
                                }
                        }
                        if (form.elements[i].name.substring(0,9) == 'keyword_1') {
                                if (!(form.elements[i].value == '')) {
                                        contentCellCount++;
                                        if (document.litSearch.category1.value == 'None') {
                                                alert('You must select a category for keyword(s) in row 2.')
                                                document.litSearch.category1.focus();
                                                return false;
                                        }
                                }
                        }
                        if (form.elements[i].name.substring(0,9) == 'keyword_2') {
                                if (!(form.elements[i].value == '')) {
                                        contentCellCount++;
                                        if (document.litSearch.category2.value == 'None') {
                                                alert('You must select a category for keyword(s) in row 3.')
                                                document.litSearch.category2.focus();
                                                return false;
                                        }
                                }
                        }
                        if (form.elements[i].name.substring(0,9) == 'keyword_3') {
                                if (!(form.elements[i].value == '')) {
                                        contentCellCount++;
                                        if (document.litSearch.category3.value == 'None') {
                                                alert('You must select a category for keyword(s) in row 4.')
                                                document.litSearch.category3.focus();
                                                return false;
                                        }
                                }
                        }
                        if (form.elements[i].name.substring(0,9) == 'keyword_4') {
                                if (!(form.elements[i].value == '')) {
                                        contentCellCount++;
                                        if (document.litSearch.category4.value == 'None') {
                                                alert('You must select a category for keyword(s) in row 5.')
                                                document.litSearch.category4.focus();
                                                return false;
                                        }
                                }
                        }
                }
        }
	if (form.description.value == '') {
                alert('You must provide a descriptive name for this literature search.');
                form.description.focus();
                return false;
	}
        if (contentCellCount == 0) {
                alert('You must select a category and input one or more keyword(s) that correspond to the selected category before proceeding.')
                form.keyword_0_0.focus();
                return false;
        }
        return true;
}

function clearAllFields(form) {
        for(var i=0; i<form.elements.length; i++) {
                if (form.elements[i].type == "text" && form.elements[i].name.substring(0,7) == "keyword") {
			form.elements[i].value="";
		}
                if (form.elements[i].name.substring(0,8) == "category") {
			form.elements[i].value="None";
                }
        }
}

