/* --------------------------------------------------------------------------------
 *
 *  specific functions for showGroupingDetails.jsp
 *
 * -------------------------------------------------------------------------------- */

function setUpShowGroupingDetailsPage() {
    var tablesorterSettings = { widgets: ['zebra'] };
    $("table[id='groupingDetails']").tablesorter(tablesorterSettings);
}
