/* --------------------------------------------------------------------------------
 *
 *  common functions 
 *
 * -------------------------------------------------------------------------------- */
function hideLoadingBox() {
	$("div[class='load']").hide();
}

function showLoadingBox() {
	$("div[class='load']").show();
	var loading = createDialog(".load" , {draggable: false, resizable:false, width: 100, height: 100, position:[400,400]});
	loading.dialog("open");
	loading.parents(".ui-dialog").find(".ui-dialog-titlebar").remove();
	loading.parents(".ui-dialog").find(".ui-dialog-content").css({padding:"30px 20px"});
}


function IsNameGeneListFormComplete(){
        if ($("input[name='gene_list_name']").val() == '') {
                alert('You must name the gene list.')
                $("input[name='gene_list_name']").focus();
                return false;
        } else if (containsSlashes($("input[name='gene_list_name']"))) {
        	alert('A gene list name cannot contain forward slashes ("/")')
                $("input[name='gene_list_name']").focus();
                return false;
	}

        if ($("textarea[name='description']").val() == '') {
                alert('You must provide a description of the gene list.')
                $("textarea[name='description']").focus();
                return false;
        }
	showLoadingBox();
        return true;
}

function updateDescription() {
	if (document.nameGeneList.descriptionParameters.checked) {
        	document.nameGeneList.description.value = document.nameGeneList.parameterDescription.value;
	} else {
        	document.nameGeneList.description.value = "";
	}
}

