/* --------------------------------------------------------------------------------
 *
 *  specific functions for promoter.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/

var idToDelete=-99; 

function setupPage() {
	jQuery("select#promoterType").on("change",function(){
		var value=jQuery("#promoterType").val();
		jQuery("#createOpossum").hide();
		jQuery("#createMeme").hide();
		jQuery("#createUpstream").hide();
		if(value==='oPOSSUM'){
			jQuery("#createOpossum").show();
		}else if(value==='MEME'){
			jQuery("#createMeme").show();
		}else if(value==='Upstream'){
			jQuery("#createUpstream").show();
		}
	});

	jQuery("#memeForm #upstreamLength").on("change",checkSize);

	jQuery( "#dialog-delete-confirm" ).dialog({
		  autoOpen: false,
	      resizable: false,
	      height:175,
	      width:"40%",
	      modal: true,
	      buttons: {
	        "Delete analysis": function() {
	          jQuery( this ).dialog( "close" );
	          runDeleteGeneListAnalysis(idToDelete);
	          idToDelete=-99;
	        },
	        Cancel: function() {
	          jQuery( this ).dialog( "close" );
	          idToDelete=-99;
	        }
	      }
    });
    jQuery( "#dialog-delete-error" ).dialog({
      autoOpen: false,
      modal: true,
      width:"40%",
      buttons: {
        Ok: function() {
          jQuery( this ).dialog( "close" );
        }
      }
    });
	checkSize();
	runGetResults(-1);
	//setupDeleteButton(contextPath + "/web/geneLists/deleteGeneListAnalysis.jsp"); 
}
/*function runGetPromoterResults(){
            $('#resultList').html("<div id=\"waitLoadResults\" align=\"center\" style=\"position:relative;top:0px;\"><img src=\""+pathImage+"wait.gif\" alt=\"Loading Results...\" text-align=\"center\" ><BR />Loading Results...</div>"+$('#resultList').html());
            $.ajax({
                    url: contextPath + "/web/geneLists/include/getPromoterAnalyses.jsp",
                    type: 'GET',
                    data: {geneListID:id},
                    dataType: 'html',
                    success: function(data2){ 
                                    goAutoRefreshHandle=setTimeout(function (){
                                            runGetPromoterResults();
                                    },20000);
                                    $('#resultList').html(data2);
                    },
                    error: function(xhr, status, error) {
                            $('#resultList').html("Error retreiving results.  Please try again.");
                    }
            });
}

function stopRefresh(){
    if(goAutoRefreshHandle){
            clearTimeout(goAutoRefreshHandle);
            goAutoRefreshHandle=0;
    }
}

function startRefresh(){
    if(!goAutoRefreshHandle){
        goAutoRefreshHandle=setTimeout(
                                    function (){
                                        runGetPromoterResults();
                                    }
                                    ,20000);
    }
}*/

function runPromoter(){
	var type=jQuery("#promoterType").val();
	jQuery('#wait2').show();
	jQuery('#runStatus').html("");
	var params={};
	params.type=type;
	params.geneListID=id;
	if(type==='oPOSSUM'){
		params.searchRegionLevel=jQuery("#oPOSSUMForm #searchRegionLevel").val();
		params.conservationLevel=jQuery("#oPOSSUMForm #conservationLevel").val();
		params.thresholdLevel=jQuery("#oPOSSUMForm #thresholdLevel").val();
		params.description=jQuery("#oPOSSUMForm #description").val();
	}else if(type==='MEME'){
		params.upstreamLength=jQuery("#memeForm #upstreamLength").val();
		params.upstreamSelect=jQuery("#memeForm #upstreamSelect").val();
		params.distribution=jQuery("#memeForm #distribution").val();
		params.minWidth=jQuery("#memeForm #minWidth").val();
		params.maxWidth=jQuery("#memeForm #maxWidth").val();
		params.maxMotifs=jQuery("#memeForm #maxMotifs").val();
		params.description=jQuery("#memeForm #description").val();
	}else if(type==='Upstream'){
		params.upstreamLength=jQuery("#upstreamForm #upstreamLength").val();
		params.upstreamSelect=jQuery("#upstreamForm #upstreamSelect").val();
	}
	jQuery.ajax({
            url: contextPath + "/web/geneLists/include/runPromoter.jsp",
            type: 'GET',
            data: params,
            dataType: 'html',
            beforeSend: function(){
                    jQuery('#runStatus').html("Submitting...");
            },
            success: function(data2){ 
                jQuery('#runStatus').html(data2);
            },
            error: function(xhr, status, error) {
                jQuery('#runStatus').html("An error occurred Try submitting again. Error:"+error);
            },
            complete: function(){
					jQuery('#runStatus').show();
					setTimeout(function (){
						jQuery('#runStatus').html("");
					},20000);
					runGetResults();
					resetForm();
			}
            });

}

function resetForm(){

}


function checkSize(){
                var select=parseFloat(jQuery("#upstreamLength").val());
                var total=geneNumber*select;
                if(total>300){
                    jQuery("#sizeWarning").show();
                    jQuery("#warnDetail").html(" ("+geneNumber+" genes x "+select+" Kb = "+total+" Kb ) ");
                }else{
                    jQuery("#sizeWarning").hide();
                }
}

function IsMeMeFormComplete(formName) {
   
	if ( (jQuery.trim(formName.minWidth.value) == '') || (parseInt(formName.minWidth.value) <= 1) ) { 
		alert('You must enter a minimum width that is greater than or equal to two.')
	        formName.minWidth.focus();
		return false; 
	}
   
	if ( (jQuery.trim(formName.maxWidth.value) == '') || (parseInt(formName.maxWidth.value) >= 301) ) { 
		alert('You must enter a maximum width that is less than or equal to 300.')
	        formName.maxWidth.focus();
		return false; 
	}
   
	if (jQuery.trim(formName.maxMotifs.value) == '') { 
		alert('You must enter the Maximun number of motifs.')
	        formName.maxMotifs.focus();
		return false; 
	}
   
	if (jQuery.trim(formName.description.value) == '') { 
		alert('You must enter a description.')
	        formName.description.focus();
		return false; 
	}

	if (jQuery.trim(formName.numberOfGenes.value) <= 1) { 
            alert('MEME Analysis cannot be performed for a gene list with only ' + formName.numberOfGenes.value + ' gene(s).');
            return false; 
	}
	return true;
}

