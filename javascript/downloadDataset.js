/* --------------------------------------------------------------------------------
 *
 *  specific functions for downloadDataset.jsp
 *
 * -------------------------------------------------------------------------------- */

function setupDownloadDatasetPage() {
	hideLoadingBox();

    var tablesorterSettings = {widgets:['zebra']};
    $("table[id='normalizedDataFiles']").tablesorter(tablesorterSettings) ;
    $("table[id='normalizedDataFiles']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
    $("table[id='phenotypeFiles']").tablesorter(tablesorterSettings) ;
    $("table[id='phenotypeFiles']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
    $("table[id='rawDataFiles']").tablesorter(tablesorterSettings) ;
    $("table[id='rawDataFiles']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
    $("input[name='action']").click(
       function() {
           downloadModal.dialog("close");  
    });

    $('#target').submit(function() {
	showLoadingBox();
    });

}
