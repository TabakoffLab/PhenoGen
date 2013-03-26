function setupPage() {
	var arrayDetails = createDialog(".arrayDetails" , {width: 833, height: 900, title: "Array Details", scrollbars: "yes"});

	var tableRows = getRows();
	stripeTable( tableRows );

	tableRows.each( function(){
        	$(this).find("td.details").click( function() {

            	var arrayID = $(this).parent("tr").attr("hybridID");
            	$.get(contextPath + "/web/datasets/arrayDetails.jsp", {arrayID: arrayID},
                	function(data){
                    		arrayDetails.dialog("open").html(data);
							initializeArrayDetailsTab();
                            closeDialog(arrayDetails);
                	});
        	});
    	});

	/* Tried implementing this in order to delete groups in middle, but too many things to change! 
	var th = $("table.list_base").find("tr.col_title").find("th");
	th.each(function() {
		if ($(this).find("input[type='text']").size() > 0 ) {
        		col = $(this).find("input[type='text']");
			col.each(function() {
        			colID = $(this).attr('id');
        			colVal = $(this).val();
    				var selectors = { thInputIdSel   : "th." + colID,
                      				tdInputValueSel: "td." + colID}
    				var rmvButton = $("<span />")
        				.addClass("removeGroup")
        				.bind( "click", selectors, deleteGroup );

    				$("th:has( input#" + colID + " )").prepend(rmvButton);
			});
		}
	});
	*/
    addTipsToRadioButtons();
}

var addedColumnWidth = 145;

function deleteGroup( e ) {
/* Need this if deleting groups from middle*/
	var numGroupsField= $("input[name='numGroups']");
	numGroupsField.val(numGroupsField.val() - 1);

    var selectors = e.data;

    var addedCols = $(this).parents("tr").find("th").size();

    var table = $(this).parents("table");

    table.css({width: (table.width() - addedColumnWidth +2) });

    for ( var key in selectors )
    {
        $( selectors[key] ).remove();
    }
}

function addTipsToRadioButtons() {
    var tooltipBody = function() {
            var trNm = $(this).parents("tr").attr( "name" );
            var colNme = "";

            var index = $(this).val();
		/*
		changed this when removed file name 
		 var th = $("table.list_base").find("tr.col_title").find("th").slice(2).eq(index);
		*/
            var th = $("table.list_base").find("tr.col_title").find("th").slice(1).eq(index);


	if ( th.find("input[type='text']").size() > 0 ) {
        	colNme = th.find("input").val();
	} else {
		colNme = th.text();
	}
            return "<b>Array</b> <i>" + trNm + "</i><br><b>Group</b><i> " + colNme + "</i>";
        }

    var grouptipSettings = { track : true,
                            delay: 200,
                            showURL: false,
                            top: -10,
                            left: 10,
                            extraClass: "extra_class",
                            bodyHandler: tooltipBody
                          };

    $("table.list_base td").find("input").not("hidden").tooltip(grouptipSettings)
}

function IsGroupArraysFormComplete() {
	// have to multiply by 1 to turn into integer
	var numGroupsVal = $("input[name='numGroups']").val() * 1;
	for (var i=0; i<numGroupsVal + 1; i++) {
		var groupNumAssigned=0;
		var groupLabelName = 'groupLabel' + i;
		var groupLabel = $("input[id='" + groupLabelName + "']");
		if (groupLabel.val() == 'Name this Group' ||
			groupLabel.val() == '') {
			alert('You must enter a name for this group.')
			groupLabel.focus();
			return false;
		}
		$("td."+groupLabelName+" input[type='radio']").each(
			function(){
				if($(this).is(":checked")){
					groupNumAssigned++;
				}
			}
		);
		if(i>0 && groupNumAssigned==0){
			if(numGroupsVal==2){
				alert("You have not assigned any arrays to Group:"+groupLabel.val()+" You cannot proceed with only one group.");
			}else{
				alert("You have not assigned any arrays to Group:"+groupLabel.val()+" You should delete this group if you do not have any arrays to assign to the group.");
			}
			return false;
		}
	}
	var groupingName = $("input[name='grouping_name']");
	if (groupingName.val() == '') {
        	alert('You must enter a descriptive name for this grouping.')
        	groupingName.focus();
        	return false;
	}
	return true;
}

function replicateWarning() {
    if (document.chooseCriterion.criterion.value == 'replicateExperiment') {
        alert("NOTE: The order of the groups should not be changed from the default when using the 'Replicate Experiment' option.  That is, they should remain in the following order:  Experiment 1/Strain 1, Experiment 1/Strain 2, Experiment 2/Strain 1, Experiment 2/Strain 2.  \n Also, you must press 'Select Criterion' after closing the box.");
        return true;
    }
}

function checkButtonUsedToSubmit(form, numRows){
	if (action != null && action.equals("Skip >")) {	
		return true;
	}else if (action != null){
 		return checkGroupRadioButtons(form, numRows);
	}else{
		return false;
 	}
}

function checkGroupRadioButtons(form, numRows){
	//
	// check that the number of radio buttons selected equals the number of rows to ensure
	// that all arrays have been placed into a group.
	//
	// also check that arrays are placed in more than one group by checking that all
	// radio buttons do not have the same value (i.e., all that are non-zero because
	// zero is Exclude)
	//
	var numberChecked=0;
	var valueChecked=0;
	var moreThanOneValueChecked=false;
	var firstValueSaved=false;

	numRows = numRows.value;
	var numGroups= $("input[name='numGroups']").val();
	var groupsChecked = new Array(numGroups);
	for(var i=0; i<numGroups; i++) {
		groupsChecked[i] = 0;
		/* Need this if deleting columns from the middle
		// If the group column has been deleted (i.e., in jquery the length will be 0), then set groupsChecked to 1 to avoid an error
		if ($("td.groupLabel" + i).length <= 0) { 
			groupsChecked[i] = 1;
		}
		*/
	}

	$("input[type='radio']").each(function() { 
		if (this.checked) {
			if (this.value > 0) {
				groupsChecked[(this.value - 1)] = 1;
			}
			if (!firstValueSaved) {
				if (this.value != 0) {
					valueChecked = this.value;
					firstValueSaved = true;
				}
			}
			if (valueChecked != this.value && this.value != 0) {
				moreThanOneValueChecked = true;
			}
			numberChecked++
		}
	});
    for (var i=0; i<numGroups; i++) {
        if (groupsChecked[i] == 0) {
            alert('To continue, you must place at least one array into each group.')
            return false;
        }
    }
    if (moreThanOneValueChecked == false) {
        alert('To continue, you must place arrays into more than one group.')
        return false;
    }
    if (numberChecked != numRows) {
        alert('To continue, you must place every array into a group.')
        return false;
    } else {
        return true;
    }
}

function addGroup(numArrays) {
	var headerID = $("tr[id='headerRow']");
	var tableID = $("table[id='groupTable']");
	var numGroupsField= $("input[name='numGroups']");
    var oldNumGroups = numGroupsField.val();
    //
        // subtracting 1 first converts the value into an integer
        // Without this, a '1' simply gets added to the character string
    //
    var newGroupsValue =  (oldNumGroups - 1) + 2;

    var tableWidth = tableID.width();

    var newWidth = tableWidth + addedColumnWidth + 'px';
    tableID.width(newWidth);
        var newTH = document.createElement("TH");
    var labelName="groupLabel" + newGroupsValue;
    var labelValue="Name this Group";
        var labelString="\<input type=\"text\" id=\"" + labelName + "\" name=\"" + labelName+ "\" value=\"" + labelValue + "\"\>";
        var newLabel = null;
    try {
            newLabel = document.createElement(labelString);
    } catch (e) {
    }
    if (!newLabel) {
            newLabel = document.createElement("input");
            newLabel.type = 'text';
            newLabel.id = labelName;
            newLabel.name = labelName;
            newLabel.value = labelValue;
            newLabel.maxLength = 30;
    }
    newTH.appendChild(newLabel);
    headerID.append(newTH);
    for (var i=0;i<numArrays;i++) {
		var rowNumName = 'rowNum' + i;
		var rowID = $("tr[id='" + rowNumName + "']");
            var newTD = document.createElement("TD");
        newTD.align="center";
            var radioString="\<input type=\"radio\" name=\"" + i + "\" value=\"" + newGroupsValue + "\"\>";
            var newRadioButton = null;
        try {
                newRadioButton = document.createElement(radioString);
        } catch(e) {
        }
            if (!newRadioButton) {
            newRadioButton = document.createElement("input");
                newRadioButton.type = 'radio';
                newRadioButton.name = i;
                newRadioButton.value = newGroupsValue;
        }
        newTD.appendChild(newRadioButton);
        rowID.append(newTD);

        $(newTD).addClass( labelName ).css({width: addedColumnWidth });
    }
    numGroupsField.val(newGroupsValue);

    $(newTH).addClass( labelName );

    var selectors = { thInputIdSel   : "th." + labelName,
                      tdInputValueSel: "td." + labelName }

    var rmvButton = $("<span />")
        .addClass("removeGroup")
        .bind( "click", selectors, deleteGroup );

    $("th:has( input#" + labelName + " )").prepend(rmvButton);

    addTipsToRadioButtons();
}