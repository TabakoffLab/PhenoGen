/* --------------------------------------------------------------------------------
 *
 *  specific functions for promoter.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/

var deleteModal; 

function setupPage() {

	var oPOSSUMRows = getRowsFromNamedTable($("table[id='itemsoPOSSUM']"));
	var MEMERows = getRowsFromNamedTable($("table[id='itemsMEME']"));
	var upstreamRows = getRowsFromNamedTable($("table[id='itemsUpstream']"));

	//---> set default sort column
        $("table[id='itemsoPOSSUM']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
        $("table[id='itemsMEME']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
        $("table[id='itemsUpstream']").find("tr.col_title").find("th").slice(0,1).addClass("headerSortDown");
	stripeAndHoverTable(oPOSSUMRows);
	stripeAndHoverTable(MEMERows);
	stripeAndHoverTable(upstreamRows);

	// setup click for row item
	oPOSSUMRows.each(function(){
		//---> click functionality
		$(this).find("td").slice(0,2).click( function() {
			var itemID = $(this).parent("tr").attr("id");
			var geneListID = $(this).parent("tr").attr("geneListID");
			var type = $(this).parent("tr").attr("type");
			$("input[name='itemID']").val( itemID );
			$("input[name='geneListID']").val( geneListID );
			document.chooseAnalysisoPOSSUM.submit();
		});
	});
	MEMERows.each(function(){
		//---> click functionality
		$(this).find("td").slice(0,2).click( function() {
			var itemID = $(this).parent("tr").attr("id");
			var geneListID = $(this).parent("tr").attr("geneListID");
			var type = $(this).parent("tr").attr("type");
			$("input[name='itemID']").val( itemID );
			$("input[name='geneListID']").val( geneListID );
			document.chooseAnalysisMEME.submit();
		});
	});
	upstreamRows.each(function(){
		//---> click functionality
		$(this).find("td").slice(0,2).click( function() {
			var itemID = $(this).parent("tr").attr("id");
			var geneListID = $(this).parent("tr").attr("geneListID");
			var type = $(this).parent("tr").attr("type");
			$("input[name='itemID']").val( itemID );
			$("input[name='geneListID']").val( geneListID );
			document.chooseAnalysisUpstream.submit();
		});
	});
	setupCreateNewOpossumButton();
	setupCreateNewMEMEButton();
	setupCreateNewUpstreamButton();
	setupDeleteButton(contextPath + "/web/geneLists/deleteGeneListAnalysis.jsp"); 
}



/* * *
 *  sets up the create new oPOSSUM modal
/*/
function setupCreateNewOpossumButton() {
    var newItem;
    $("div[name='createNewOpossum']").click(function(){
        if (newItem == undefined) {
            newItem = createDialog("div.createOpossum", 
				{position:[250,150], width: 600, height: 350, 
				title: "<center>Create New Opossum Analysis</center>"});
	}
        $.get("createOpossum.jsp", function(data){
            newItem.dialog("open").html(data);
		closeDialog(newItem);
        });
    });
}

/* * *
 *  sets up the create new MEME modal
/*/
function setupCreateNewMEMEButton() {
    var newItem;
    // setup create new promoter button
    $("div[name='createNewMeme']").click(function(){

        if (newItem == undefined) {
            newItem = createDialog("div.createMeme", 
				{position:[250,150], width: 600, height: 350, 
				title: "<center>Create New MEME Analysis</center>"});
	}
        $.get("meme.jsp", function(data){
            newItem.dialog("open").html(data);
		closeDialog(newItem);
        });
    });
}

/* * *
 *  sets up the create new Upstream modal
/*/
function setupCreateNewUpstreamButton() {
    var newItem;
    // setup create new promoter button
    $("div[name='createNewUpstream']").click(function(){

        if ( newItem == undefined )
            newItem = createDialog("div.createUpstream", 
					{position:[250,150], width: 600, height: 350, 
					title: "<center>Create New Upstream Extraction</center>"});

        $.get("upstream.jsp", function(data){
            newItem.dialog("open").html(data);
		closeDialog(newItem);
        });
    });
}
