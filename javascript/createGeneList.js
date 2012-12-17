/* --------------------------------------------------------------------------------
 *
 *  specific functions for createGeneList.jsp
 *
 * -------------------------------------------------------------------------------- */
function setupCreateGeneListPage() {
    $.ajaxSetup({cache: false});    // globally sets ajax caching to false (for this lifecycle of this page)
}
function IsCreateGeneListFormComplete(){
        if ($("input[name='gene_list_name']").val() == '') {
                alert('You must name the gene list.')
                $("input[name='gene_list_name']").focus();
                return false;
        } else if (containsSlashes($("input[name='gene_list_name']"))) {
                alert('A gene list name cannot contain forward slashes ("/")')
                $("input[name='gene_list_name']").focus();
                return false;
        }
        if ($("select[name='organism']").val() == '-99') {
                alert('You must select an organism.')
                $("select[name='organism']").focus();
                return false;
        }
        if ($("textarea[name='description']").val() == '') {
                alert('You must provide a description of the gene list.')
                $("textarea[name='description']").focus();
                return false;
        }
        if ($("input[name='filename']").val() == '' &
        	$("textarea[name='inputGeneList']").val() == '') { 
                alert('You must either specify a file to upload, or manually enter gene identifiers.');
                $("input[name='filename']").focus();
                return false;
        } else if ($("input[name='filename']").val() != '' &
        	$("textarea[name='inputGeneList']").val() != '') { 
                alert('You must either specify a file to upload, or manually enter gene identifiers, but not both.');
                $("input[name='filename']").focus();
                return false;
        }
        if ($("input[name='filename']").val() != '' &
        	!isTextFile($("input[name='filename']").val())) {
                alert('At this time, we are only able to upload text files.  You must provide a text file to upload.')
                $("input[name='filename']").focus();
                return false; 
        }
        return true;
}

function showGeneListFields() {
	var radioValue = $("input[name='choice']:checked").val(); 

        if (radioValue == 'upload') {
                $("div#upload_div").show();
                $("div#new_div").hide();
                $("div#copyGeneLists").hide();
				$("div#whatToDo").hide();
				$("div#enterList").hide();
        // Enter new
        } else if (radioValue == 'new') {
                $("div#upload_div").hide();
                $("div#new_div").show();
				$("textarea[name='inputGeneList']").val('');
				enableField($("textarea[name='inputGeneList']"));
                $("div#copyGeneLists").hide();
				$("div#whatToDo").hide();
				$("div#enterList").show();
        // Copy from existing
        } else if (radioValue == 'copy') {
                $("div#upload_div").hide();
                $("div#new_div").show();
				$("textarea[name='inputGeneList']").val('');
				enableField($("textarea[name='inputGeneList']"));
                $("div#copyGeneLists").show();
				$("div#whatToDo").hide();
				$("div#enterList").hide();
        } else {
                $("div#upload_div").hide();
                $("div#new_div").hide();
                $("div#copyGeneLists").hide();
				$("div#whatToDo").hide();
				$("div#enterList").hide();
        }

}

function displayGeneList () {
	var geneListID = $("select[name='copyFromID']").val();

	$.ajax({
        	type: "POST",
        	dataType: "html",
        	async: false,
			data: {geneListID: geneListID},
        	url:  "getGeneList.jsp",
        	success: function(html){
				var answer = jQuery.trim(html);
            	var listDiv = $("textarea[name='inputGeneList']");
				listDiv.val(answer);
				/*if ($.browser.mozilla) {
					listDiv.val(answer);
				} else {
					listDiv.html(answer);
				}*/
        	},
        	error: function(XMLHttpRequest, textStatus, errorThrown) {
       	     		alert( "error retrieving gene list " + textStatus + " " + errorThrown );
        			}
	});
	$("div#whatToDo").show();
	$("textarea[name='inputGeneList']").focus();

}
