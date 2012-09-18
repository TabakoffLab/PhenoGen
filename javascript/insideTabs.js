/* --------------------------------------------------------------------------------
 *
 *  specific functions for geneListToolsTabs.jsp and qcResultsTabs.jsp
 *
 * -------------------------------------------------------------------------------- */

function setupTabs( selectedTabId ) {
	// set selected tab
	$("div.action_tabs").find("div#" + selectedTabId).addClass("selected");

	// set click action for tabs
	$(".action_tabs").find("div:not('.selected')").click(function(){
		var landingPage = $(this).attr("data-landingPage");
		$("input[name='tab']").val( this.id );

		if ( landingPage != undefined ) {
			landingPage += ".jsp";
			if ( landingPage == "expressionValues.jsp" ) {
				landingPage += "?itemID=-99";
			}
			$("form[name='tabLink']").attr({action: landingPage});
			document.tabLink.submit();
		}
	});
}

