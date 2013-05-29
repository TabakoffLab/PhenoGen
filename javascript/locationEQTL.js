/* --------------------------------------------------------------------------------
 *
 *  specific functions for locationEQTL.jsp
 *
 * -------------------------------------------------------------------------------- */

/* * * *
 *  this function sets up all the functionality for this page
/*/
function setupPage() {
    $.ajaxSetup({cache: false});    // globally sets ajax caching to false (for this lifecycle of this page)
    setupRegionList();
    setupViewList();
    setupGraphicControls();
    setupCreateNewRegion();
    setupAdvancedSettings();
    setupSaveDisplayedGenes();
    setupDeleteButton();
    setupDrawGraph();
}

/* * *
 *  stripes the table of User Defined Regions, and sets up click functionality
/*/
function setupRegionList() {
    //var regionList = getRowsFromNamedTable($("table[name='regions']"));
    var regionList = getRows();
    stripeAndHoverTable( regionList );
    $(".expandList").click(function(){ resetList(); });
    regionList.each(function(){
        var rowCells = $(this).find("td:first");
        rowCells.filter("td:first").css({width: 200}).end();
        rowCells
            .slice(2,3).css({"text-align" : "center"}).end() // center text in column 3
            .slice(0,2).addClass("cursorPointer")
            .hover(
                function() { rowCells.slice(0,2).addClass("hover"); },
                function() { rowCells.slice(0,2).removeClass("hover"); }
            )
            .click(function() {
                if( $("div.list_container").hasClass("singleItem") )
                    resetList();
                else
                    selectFromList( rowCells );
            });
    });
}

/* * *
 *  Sets up the dialog box to display region list contents for a single User Defined Region
/*/
function setupViewList() {
    var vListBox = createDialog(".region_list", {width: 500});

    /* --- View Description click --- */
    $("span.vList").click(function(){
        var txt = $(this).attr("data-list");
        var buildText = function(data, separator)
            {
                var text;
                var list = data.split( separator );

                for ( var item in list )
                    text = (text ? text + "<br>" : "") + list[item];

                return text;
            }

        var list = buildText(txt, "|");
	$("div.region_list").show();
        vListBox.dialog("open");
        vListBox.find("div.region_content").html( list );
    });
}

/* * *
 *  sets up the create new region modal
/*/
function setupCreateNewRegion() {
    var newRegion;
    // setup create new region button
    $("div[name='createNewRegion']").click(function(){
        if ( newRegion == undefined )
            newRegion = createDialog("div.createNewRegion", {width: 900, height: 550});
        $.get(contextPath + "/web/qtls/defineQTL.jsp?fromDialog=Y", function(data){
            newRegion.dialog("open").html(data);
        });
    });
}

/* * *
 *  sets up the advanced settings button click and attributes of the window
/*/
function setupAdvancedSettings() {
    var init = true;
    // setup click on advanced settings
    $("div#advancedSettingsButton").click(function(){
        $(this).toggleClass("current");

        var reg = $("input[name='qtlListID']").attr("value");

        if ( init && reg.length == 0 && qtlListID.length > 0 ) reg = qtlListID;

        if ( reg.length > 0 && init )
        {
            $("tr#"+reg).find("td:first").click();
            init = false;
            qtlListID = "";
        }

        toggleAdvancedSettings();
    });

    if ( $("input[name='advSettings']").attr("value") ==  "open" ) {
        $("div#advancedSettingsButton").click();
	}

    //$("#advancedSettingsRegions").draggable({revert: true, handle: "div.dragHandle"});
}

/* * *
 *  Sets up the "Save displayed genes " link click
/*/
function setupSaveDisplayedGenes() {
	var nameGeneList;
	$("div#btnSaveGenes").click(function(){
        	$.get("nameGeneList.jsp?geneListSource=QTL", function(data){
            		if ( nameGeneList == undefined ) {
                		nameGeneList = createDialog("div.saveDisplayedGenes", 
					{ width: 720, height: 350, title: "Save Displayed Genes"});
			}
            		nameGeneList.dialog("open").html(data);
        	});
    	});
}

/* * * *
 *  this function sets up the events for the DELETE button
/*/
function setupDeleteButton() {
    $("table[name='items']").find("td div.delete").click(
        function() {
            var theRow = $(this).parents("tr");

            var listName = theRow.find("td:first").html();

            if ( confirm("Please confirm your choice to delete: " + listName) )
            {
                var dataParams = { itemID: theRow.attr("id") };

                // send to .jsp to handle delete
                $.ajax({
                    type: "POST",
                    url: "deleteRegion.jsp", // be sure to check security on this page!
                    dataType: "html",
                    data: dataParams,
                    async: false,
                    //success: function(msg){
                    success: function(){
                        // you can call another javascript method from here, or put the code for a successful deletion here
                        //alert( "Region(s) deleted: " + msg );
                        alert( "Region deleted ");

                        // remove item from the dom
                        theRow.remove();

                        stripeTable( getRows() );
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        alert( "there was an error processing this request: " + textStatus + " " + errorThrown );
                    }
                });

                if( $("div.list_container").hasClass("singleItem") )
                {
                    resetList();
                }
            }
        });
}

/* * *
 *  establishes when the graph is drawn and the parameters that get sent to the drawing utility
/*/
function setupDrawGraph() {
    var doEvent = function() {
            $("form#graphicSettingsForm").submit();
        }

    if ( $.browser.msie ) {
        $("div.graphicOptions input:radio, div.graphicSettingsWindow input:checkbox")
            .click( doEvent );

        $("div.graphicSettingsWindow select" )
            .change( doEvent );
    } else {
        $("div.graphicOptions input:radio, div.graphicSettingsWindow input:checkbox, div.graphicSettingsWindow select" )
            .change( doEvent );
    }
}
/* * *
 *  show/hide advanced settings form
/*/
var toggleAdvancedSettings = function( speed ) {
        var advancedSettings = $("#advancedSettingsRegions");

        if ( advancedSettings.is(":hidden") )
            $("input[name='advSettings']").attr({value: "open"});
        else
            $("input[name='advSettings']").attr({value: "close"});

        speed = speed == undefined ? 500 : speed;

        advancedSettings.toggle(speed);
    }

/* * *
 *  resets the region list
/*/
var resetList = function( delay ) {
        $("td.selected").removeClass("selected");
        $("div[name='createNewRegion']").show();
        $(".advancedSettings").hide();
        $(".expandList").hide();

        $("form#graphicSettingsForm").find("input[name='qtlListID']").attr({value: ""});

        delay = delay == undefined ? 0 : delay;

        setTimeout( "showList()", delay );
    }

/* * *
 *  selects a region from the list
/*/
var selectFromList = function( cells ) {
        cells.addClass("selected");

        $("div[name='createNewRegion']").hide();

        $(".advancedSettings").show(400);
        $(".expandList").show();

        var rowId = cells.parent("tr").attr("id");

        $("form#graphicSettingsForm").find("input[name='qtlListID']").attr({value: rowId});
	$("div.graphicOptions input:radio").change();

        hideList( rowId );
    };

var showList = function() {
        $("table[name='items'] tr").show();
        $("div.list_container").removeClass("singleItem");
    };

var hideList = function( rowId ) {
        $("div.list_container").addClass("singleItem");
        $("tr#" + rowId).siblings().hide();
    }
