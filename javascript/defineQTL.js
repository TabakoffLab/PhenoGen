function addQTLRow() {
	var tableID = $("table[id='QTLTable']");
	var bodyID = $("table[id='QTLTableBody']");
	var nextRowNumField = $("input[id='nextRowNum']");
	var currentValue = nextRowNumField.val();
	//
        // subtracting 1 first converts the value into an integer 
        // Without this, a '1' simply gets added to the character string
	//
        var newValue = (currentValue - 1) + 2;
        nextRowNumField.val(newValue);
        var newTR = document.createElement("TR");
        var newTD1 = document.createElement("TD");
        var newTD2 = document.createElement("TD");
        var newTD3 = document.createElement("TD");
        var newTD4 = document.createElement("TD");
        var newQTLNameField = document.createElement("input");
        newQTLNameField.type = 'text';
        newQTLNameField.name = 'qtl' + newValue;
        newQTLNameField.size = 15;
        var newChromosomeField = document.createElement("input");
        newChromosomeField.type = 'text';
        newChromosomeField.name = 'chromosome' + newValue;
        newChromosomeField.size = 15;
        var newRangeStartField = document.createElement("input");
        newRangeStartField.type = 'text';
        newRangeStartField.name = 'rangeStart' + newValue;
        newRangeStartField.id = 'rangeStart' + newValue;
        newRangeStartField.size = 10;
        var newRangeEndField = document.createElement("input");
        newRangeEndField.type = 'text';
        newRangeEndField.name = 'rangeEnd' + newValue;
        newRangeEndField.id = 'rangeEnd' + newValue;
        newRangeEndField.size = 10;
	newTD1.appendChild(newQTLNameField);
	newTD2.appendChild(newChromosomeField);
	newTD3.appendChild(newRangeStartField);
	newTD4.appendChild(newRangeEndField);
	newTR.appendChild(newTD1);
	newTR.appendChild(newTD2);
	newTR.appendChild(newTD3);
	newTR.appendChild(newTD4);
	tableID.append(newTR);	
	bodyID.append(newTR);	
	newQTLNameField.focus(); 
}

function IsFormComplete(form) {
		var rowNum = 0;
		var qtlNames = new Array();
                if (form.phenotype.value == '') {
                        alert('You must enter a phenotype or a name for this QTL list.')
                        form.phenotype.focus();
                        return false;
                }
                if (form.organism.value == '-99') {
                        alert('You must select an organism for this QTL list.')
                        form.organism.focus();
                        return false;
                }

                var numRows = 1;
                for (var i=0; i<form.elements.length; i++) {
                        if (form.elements[i].name.substring(0,3) == 'qtl') {
                                if (!(form.elements[i].value == '')) {
                                        numRows++;
                                }
                        }
                }
                if (numRows == 0) {
                        alert('You must enter at least one locus by specifying the chromosome name/number, range start, and range end points.')
                        document.defineQTL.qtl0.focus();
                        return false;
                }
                for (var i=0; i<form.elements.length; i++) {
                        if (form.elements[i].name.substring(0,3) == 'qtl') {
                                if (form.elements[i].value == '') {
                                        alert('You must enter an identifier for each locus.')
                                        form.elements[i].focus();
                                        return false;
                                }
				qtlNames[rowNum] = form.elements[i].value;
				for (j=1;j<rowNum+1;j++) {
                                	if (form.elements[i].value == qtlNames[j-1]) {
                                        	alert('You must enter a unique name for each locus.')
                                        	form.elements[i].focus();
                                        	return false;
                                	}
				}
				rowNum++;
                        } else if (form.elements[i].name.substring(0,10) == 'chromosome') {
                                if (form.elements[i].value == '') {
                                        alert('You must enter a chromosome number for each locus entered.')
                                        form.elements[i].focus();
                                        return false;
                                }
                        } else if (form.elements[i].name.substring(0,10) == 'rangeStart') {
                                if (form.elements[i].value == '') {
                                        alert('You must enter a range start point for each locus entered.')
                                        form.elements[i].focus();
                                        return false;
                                }
                                if (!valIsNumeric(form.elements[i].value)) {
                                        alert("Only numbers are allowed in the Range Start fields");
                                        form.elements[i].focus();
                                        return false;
                                }
                        } else if (form.elements[i].name.substring(0,8) == 'rangeEnd') {
                                if (form.elements[i].value == '') {
                                        alert('You must enter a range end point for each locus entered.')
                                        form.elements[i].focus();
                                        return false;
                                }
                                if (!valIsNumeric(form.elements[i].value)) {
                                        alert("Only numbers are allowed in the Range End fields");
                                        form.elements[i].focus();
                                        return false;
                                }
                        }
                }
                for (var i=0; i<numRows; i++) {
			var rangeStartField = $("input[id='rangeStart" + i + "']");
			var rangeEndField = $("input[id='rangeEnd" + i + "']");
			/* Need to multiply by 1 to convert the field to an integer */
                        if (rangeStartField.val()*1 >= rangeEndField.val()*1) {
				alert('Range Start must be less than Range End.')
				rangeStartField.focus();
                                return false;
			}
		}
                return true;
}


