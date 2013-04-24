/* --------------------------------------------------------------------------------
 *
 *  General utility and header methods
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  adjusts the height of the main_body div to the minimumHeight by adding padding.
 *  Padding allows the element to expand vertically, as normal vs setting an absolute height that causes overflow outside the container.
/*/
var setHeight = function( jqObjSelector, ht ) {
        var jqObj = $(jqObjSelector);
        var minimumHeight = ht == undefined ? 500 : ht;
	//alert('jqObj.height = '+jqObj.name + ' ' +jqObj.height());

        if ( jqObj.height() < minimumHeight )
		jqObj.css( { "padding-bottom" : ( minimumHeight - jqObj.height() ) } );
            //jqObj.height(minimumHeight); 
    }

function setupMain() {
    setHeight('div#main_body', 500);
}


/* * * *
 *  currently, each page should set the javascript var crumbs which is a list of strings.
        Example: crumbs = { "Home","Research Genes", "Location eQTL"};

        Explanation:  key = string value that goes between the anchor tags <a>[key]</a>
                      value = string value that will be the href, if empty just the text will be used (represents where you are NOW)
/*/
function prepareCrumbTrail( jsonTrail ) {

	/* * * 
	 * The masterJsonTrail maps the titles that will be shown on the crumb trail to the 
	 * screens that will be accessed 
	/*/
	var masterJsonTrail = {
		"Home" : contextPath + "/web/common/" + "startPage.jsp",
        	"Research Genes" : contextPath + "/web/geneLists/" + "geneListMain.jsp",
        	"Location EQTL" : contextPath + "/web/geneLists/" + "locationEQTL.jsp",
        	"Annotation" : contextPath + "/web/geneLists/" + "annotation.jsp",
        	"Analyze Microarray Data" : contextPath + "/web/datasets/" + "microarrayMain.jsp",
        	"Differential Expression Analysis" : contextPath + "/web/datasets/" + "filters.jsp?analysisType=diffExp",
        	"Cluster Analysis" : contextPath + "/web/datasets/" + "filters.jsp?analysisType=cluster",
        	"Correlation Analysis" : contextPath + "/web/datasets/" + "correlation.jsp",
        	"Investigate QTL Regions" : contextPath + "/web/geneLists/" + "locationEQTL.jsp"
	};

    if ( jsonTrail != undefined ) {
       var theTrail = $("#crumb_trail");
       for ( var i in jsonTrail ) {
		/* 
		alert('jsonTrail[i] = '+jsonTrail[i]);
		alert('masterJsonTrail[i] = '+masterJsonTrail[jsonTrail[i]]);
		*/
            theTrail.append( theTrail.text().length > 0 ? "&nbsp;&nbsp;&raquo;&nbsp;&nbsp;": "" );

		if (i < jsonTrail.length -1) {
            		if (masterJsonTrail[jsonTrail[i]].length > 0 ) {
                		theTrail.append( $("<a href='" + masterJsonTrail[jsonTrail[i]] + "'>" + jsonTrail[i] + "</a>") );
            		} else {
                		theTrail.append( jsonTrail[i] );
        		}
		} else {
                	theTrail.append( jsonTrail[i] );
		}
	}
    }
}


/* * * *
    this method does :
        a) sets the Main Tab Help text
/*/
function selectTab( ) {
    /* var hlpTxt = $("div.selected").text(); */
    var hlpTxt = "";

    $(".main_tab_help").find("a span").html( hlpTxt + " Help" );
}

/* * * *
 *  generic method to create a dialog box, with some basic settings that can be overridden by options.
 *      selector: tells what element to be used as the dialog box
/*/
function createDialog(selector, options) {
    var settings = { draggable: true,
                     modal: true,
                     autoOpen: false,
                     overlay: { opacity: .4, background: "#ccc" }
                    };
    $.extend(settings, options);
    var element = $(selector);
    var dialog = element.dialog( settings );

//commenting out this block to fix disabled dropdowns in modal windows in Safari
//modal windows can still be dragged by the window title bar with the exception of the "loading..." window.
/*
    if ( settings.draggable ) {
        dialog.parents(".ui-dialog")
            .draggable({
                handle: ".ui-dialog-titlebar",
		// browser.msie true means the browser is Internet Explorer 
                containment: $.browser.msie ? $(document) : "document" 
            });
    }
*/

    return dialog;
}

function closeWindow() {
	$("div[class='closeWindow']").click(function(){
		window.close();
	});
}

function closeDialog(dialogWindow) {
	dialogWindow.find("div.closeWindow").click(function() {
		dialogWindow.dialog("close");
	});
}

/* * * *
 *  generic method to create a popup browser window, with settings that can be overridden by options.
 *      pageURL: url of the page that will be loaded
 *      options: various attributes of the popup window
/*/
function openPopup( pageURL, options ) {
    var settings = { width      : 700,
                     height     : 650,
                     scrollbars : "no",
                     statusBar  : "no",
                     locBar     : "no",
                     screenX    : 100,
                     screenY    : 100,
                     resize     : "yes",
                     winName    : "popupName",  // names the window so that it can be referenced by this name in javascript
		     asTab      : false
                   };

    $.extend(settings, options);

    // window bars
    var windowAttr = "location=" + settings.locBar + ",status=" + settings.statusBar;
    windowAttr += ",directories=no,menubar=no,titlebar=yes,toolbar=no,dependent=yes";

    // window attributes
    windowAttr += ",width=" + settings.width + ",height=" + settings.height + ",resizable=" + settings.resize;
    windowAttr += ",screenX=" + settings.screenX + ",screenY=" + settings.screenY;

    var newWin = window.open( pageURL, settings.winName,  settings.asTab ? "" : windowAttr );
    newWin.focus();
}

/* * * *
 *  returns the rows currently in the table minus any header rows
/*/
function getRows() {
    return $("table[name='items']").find("tr").not(".title, .col_title");
}


/* * * *
 *  returns the rows currently in the table minus any header rows
/*/
function getRowsFromNamedTable(tableElement) {
    return tableElement.find("tr").not(".title, .col_title");
}


function clickRadioButton() {
	$(':radio, tr').filter(':has(:radio:selected)').end().click(function(event) {
        	//if the user didn't click on the radio button itself, check it
		if (event.target.type !== 'radio') {
			$(':radio', this).trigger('click');
		}
		$(':radio, tr').removeClass('selected');
		$(this).toggleClass('selected');
          });
}

/*
 * See if at least one radio button has been checked 
 */
function IsSomethingSelected(radio) {
	var somethingChecked = false;
	radio.each(function() { 
		if (this.checked) {
			somethingChecked = true;
		}
	});
	return somethingChecked;
}

/*
 * See if at least one checkbox on the entire form has been checked 
 */
function IsSomethingCheckedOnForm(form){
	for(var i=0; i<form.elements.length; i++) {
		if (form.elements[i].checked){
			return true;
		}
	}
	alert('You must select one or more items before proceeding.')
	return false; 
}

/*
 * See if at least one checkbox on the table has been checked 
 */
function IsSomethingCheckedOnTable(tableElement) {
	var checkBoxes = tableElement.find(":checkbox");
	var somethingIsChecked = false;
	checkBoxes.each(function() {
		if ($(this).is(':checked')) {
			somethingIsChecked = true;
		}
	});
	if (!somethingIsChecked) {
		return false; 
	} else {
		return true;
	}
}


// check the check box if user clicks anywhere on the row, restrict by table id
function clickCheckBoxForNamedTable(tableElement) {
	tableElement.find(":checkbox, tr").find("td").not(".actionIcons, .details, .publicDetails").click(
		function(event){
			//if the user didn't click on the checkbox itself, check it
			if (event.target.type != 'checkbox') {
				$(':checkbox', $(this).parents("tr") ).trigger('click');
			}

			// Not sure why these are here
			// $(':checkbox, tr').removeClass('checked');
			// $(this).toggleClass('checked');
		});
}

// check the check box if user clicks anywhere on the row
function clickCheckBox() {
	$(":checkbox, tr").find("td").not(".actionIcons, .details").click(function(event){
		//if the user didn't click on the checkbox itself, check it
		if (event.target.type != 'checkbox') {
			$(':checkbox', $(this).parents("tr") ).trigger('click');
		}

// Not sure why these are here
//        $(':checkbox, tr').removeClass('checked');
 //       $(this).toggleClass('checked');
	});
}



/* * * *
 *  this function adds the striping and the row hovering for the table
/*/
function stripeAndHoverTable(tableRows) {
	stripeTable(tableRows);
	hoverRows(tableRows);
}


/* * * *
 *  this function adds the striping for the table
/*/
function stripeTable( tableRows ) {
	tableRows.find("td.alt_stripe").removeClass("alt_stripe");
	tableRows.filter(":odd").each(function(){
		$(this).find("td").addClass( "alt_stripe" );
	});
}

/* * * *
 *  this function adds the row hovering for the table
/*/
function hoverRows( tableRows ) {
	tableRows.each(function(){
		//---> hover functionality
        	// columns that get hover EVENT
		// do not hover on description, details, delete, or download, but do get cursorPointer on details
        	var rowCells = $(this).find("td").not(".details, .publicDetails, .actionIcons, .description");

        	rowCells.hover(
                	function() { rowCells.addClass("hover"); },
                	function() { rowCells.removeClass("hover"); }
            	)
            	.addClass("cursorPointer");
        	var detailsCells = $(this).find("td.details, td.publicDetails");
        	detailsCells.addClass("cursorPointer");
	});
}

/* * * *
 *  this function sets up the events for the DELETE button
/*/
function setupDeleteButton(url) {
	var modalOptions = {height: 450, width: 750, position: [250,150], title: "<center>Delete Item</center>"};
	deleteModal = createDialog( ".deleteItem", modalOptions );

	$("table[name='items']").find("td div.delete").click(function() {
		var theRow = $(this).parents("tr");
                var dataParams = {itemID: theRow.attr("id") };
		if (dataParams.itemID.indexOf('|||') > -1) {
			dataParams = { itemIDString: theRow.attr("id") };
		}

		// send to .jsp to handle delete
		$.ajax({
			type: "POST",
                	url: url,
                	dataType: "html",
                	data: dataParams,
                	async: false,
                	success: function( html ){
                    		deleteModal.html( html ).dialog("open");
                	},
                	error: function(XMLHttpRequest, textStatus, errorThrown) {
                    		alert( "there was an error processing this request: " + textStatus + " " + errorThrown );
                	}
		});
	});
}

function cancelDelete() {
    deleteModal.dialog( "close" );
}

function confirmDelete() {
	if ( confirm("Please confirm your choice to delete this item") ) {
		return true;
	}
	cancelDelete();
	return false;
}

/* * * *
 *  this function sets up the events for the DOWNLOAD icon
/*/
function setupDownloadLink(formName) {
	$("div#download").click(function(){
		var previousAction = $("input[name='action']").val();
		$("input[name='action']").val( "Download" );
    		$("form[name=" + formName + "]").submit();
		$("input[name='action']").val(previousAction);
	});
}

/* * * *
 *  this function sets up the events for the DOWNLOAD button on each row
/*/
function setupDownloadButton(url) {
	var modalOptions = {height: 550, width: 750, position: [250,150], title: "<center>Download Item</center>"};
	downloadModal = createDialog( ".downloadItem", modalOptions );

	$("table[name='items']").find("td div.download").click(function() {
		var theRow = $(this).parents("tr");

		var dataParams = { itemID: theRow.attr("id") };
		if (dataParams.itemID.indexOf('|||') > -1) {
			dataParams = { itemIDString: theRow.attr("id") };
		}
		// send to .jsp to handle download
		$.ajax({
                	type: "POST",
                	url: url,
                	dataType: "html",
                	data: dataParams,
                	async: false,
                	success: function( html ){
                    	downloadModal.html( html ).dialog( "open" );
                	},
                	error: function(XMLHttpRequest, textStatus, errorThrown) {
				alert( "there was an error processing this request: " + textStatus + " " + errorThrown );
                	}
		});
	});
}

/* * * *
 *  this function sets up the events if there is more than one DOWNLOAD button on each row
/*/
function setupDownloadButtonByType(url) {
	var modalOptions = {height: 550, width: 750, position: [250,150], title: "<center>Download Resources</center>"};
	downloadModal = createDialog( ".downloadItem", modalOptions );

	$("table[name='items']").find("td div.download").click(function() {
		var id = $(this).parents("tr").attr("id");
		var theType = $(this).attr("type");

		var dataParams = { resource:id, type: theType };

		// send to .jsp to handle download
		$.ajax({
                	type: "POST",
                	url: url,
                	dataType: "html",
                	data: dataParams,
                	async: false,
                	success: function( html ){
                    	downloadModal.html( html ).dialog( "open" );
                	},
                	error: function(XMLHttpRequest, textStatus, errorThrown) {
				alert( "there was an error processing this request: " + textStatus + " " + errorThrown );
                	}
		});
	});
}

/*function setupDownloadButtonResourcesByType(url,url2) {
	var modalOptions = {height: 550, width: 750, position: [250,150], title: "<center>Download Resources</center>"};
	downloadModal = createDialog( ".downloadItem", modalOptions );

	$("table[name='items']").find("td div.download").click(function() {
		var id = $(this).parents("tr").attr("id");
		var theType = $(this).attr("type");

		var dataParams = { resource:id, type: theType };
		if(theType!="rnaseq"&&theType!="marker"){
			// send to .jsp to handle download
			$.ajax({
                	type: "POST",
                	url: url,
                	dataType: "html",
                	data: dataParams,
                	async: false,
                	success: function( html ){
                    	downloadModal.html( html ).dialog( "open" );
                	},
                	error: function(XMLHttpRequest, textStatus, errorThrown) {
				alert( "there was an error processing this request: " + textStatus + " " + errorThrown );
                	}
			});
		}else{
			// send to .jsp to handle download
			$.ajax({
                	type: "POST",
                	url: url2,
                	dataType: "html",
                	data: dataParams,
                	async: false,
                	success: function( html ){
                    	downloadModal.html( html ).dialog( "open" );
                	},
                	error: function(XMLHttpRequest, textStatus, errorThrown) {
				alert( "there was an error processing this request: " + textStatus + " " + errorThrown );
                	}
			});
		}
	});
}*/


/* * * *
 *  this function sets up the events for the DOWNLOAD button for the form
/*/
function setupDownloadPage(url) {
	var modalOptions = {height: 550, width: 750, position: [250,150], title: "<center>Download</center>"};
	downloadModal = createDialog( ".downloadPage", modalOptions );

	$("div#download").click(function() {
		// send to .jsp to handle download
		$.ajax({
                	type: "POST",
                	url: url,
                	dataType: "html",
                	//data: dataParams,
                	async: false,
                	success: function( html ){
                    	downloadModal.html( html ).dialog( "open" );
                	},
                	error: function(XMLHttpRequest, textStatus, errorThrown) {
				alert( "there was an error processing this request: " + textStatus + " " + errorThrown );
                	}
		});
	});
}

function checkUncheckAll( id, name ) {
   $("input[name=" + name + "][type='checkbox']").attr('checked', $('#' + id).is(':checked'));
}

function setupExpandCollapse() {
	$(document).on('click','span.trigger', function (event){
	//$("span.trigger").click(function(){
		var baseName = $(this).attr("name");
        var thisHidden = $("div#" + baseName).is(":hidden");
        $(this).toggleClass("less");
        if (thisHidden) {
			$("div#" + baseName).show();
        } else {
			$("div#" + baseName).hide();
        }
	});
}

function setupExpandCollapseTable() {
	$("span.trigger").click(function(){
		var baseName = $(this).attr("name");
                var thisHidden = $("tbody#" + baseName).is(":hidden");
                $(this).toggleClass("less");
				$('span[name='+baseName+']').toggleClass("less");
                if (thisHidden) {
					$("tbody#" + baseName).show();
                } else {
					$("tbody#" + baseName).hide();
                }
	})
}

function enableField(field) {
        // To enable the field, remove the disabled attribute 
	field.removeAttr('disabled');
}
function disableField(field) {
        // Set the disabled attribute to disabled!!!
	field.attr('disabled', 'disabled');
}

function valIsNumeric(value) {
	if (value.match(/^\d*\.?\d+$/) == null) {
        	return false; 
    	} else {
        	return true; 
	}
}
function isValidExperimentName(value) {
	// Hyphen has to be last character in a character set -- otherwise it needs escaping
	if (value.match(/^[a-zA-Z0-9_ -]*$/) == null) {
		return false;
	} else {
        	return true; 
	}
}
function isValidProtocolName(value) {
	// Hyphen has to be last character in a character set -- otherwise it needs escaping
	if (value.match(/^[\(\)a-zA-Z0-9\._ -]*$/) == null) {
		return false;
	} else {
        	return true; 
	}
}

function containsSlashes(field) {
	var regExp = new RegExp("[/]");
	return regExp.test(field.val());
}

function isTextFile(filename) {
       // Have to use parseInt in order to subtract from the value -- otherwise shows up as NaN
	var length = parseInt(filename.length);
	return (filename != '' && filename.substring(length - 4, length) == '.txt');
}

function isExcelFile(filename) {
       // Have to use parseInt in order to subtract from the value -- otherwise shows up as NaN
	var length = parseInt(filename.length);
	return (filename != '' && filename.substring(length - 4, length) == '.xls');
}

function popUp(url) {
	newWin=window.open(url, 'name', 'height=600,width=1100,scrollbars=yes');
	if (window.focus) {
		newWin.focus()
	}
	return false;
}

function AreYouSure(form){
	for(var i=0; i<form.elements.length; i++) {                 
		if (form.elements[i].checked){
			if (confirm('Are you sure you want to delete the selected items?')) { 
				return true;
			} else {
				return false;
			}
		}
	}
}


// Setup the options bar icons
function setupIcons( chosenOption ) {
	// set selected icon
	if (chosenOption != "") {
		$("div.optionIcons").find("div#" + chosenOption).addClass("selected");
	}

	// set click action for tabs
	$(".optionIcons").find("div:not('.selected')").click(function(){
	//$(".optionIcons").click(function(){
		var landingPage = $(this).attr("data-landingPage");
		//$("input[name='tab']").val( this.id );

		if ( landingPage != undefined ) {
			landingPage += ".jsp";
			if ( landingPage == "expressionValues.jsp" ) {
				landingPage += "?itemID=-99";
			}
			$("form[name='iconLink']").attr({action: landingPage});
			document.iconLink.submit();
		}
	});
}
