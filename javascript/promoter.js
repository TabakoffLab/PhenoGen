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
	$("select#promoterType").on("change",function(){
		var value=$("#promoterType").val();
		$("#createOpossum").hide();
		$("#createMeme").hide();
		$("#createUpstream").hide();
		if(value==='oPOSSUM'){
			$("#createOpossum").show();
		}else if(value==='MEME'){
			$("#createMeme").show();
		}else if(value==='Upstream'){
			$("#createUpstream").show();
		}
	});

	$("#memeForm #upstreamLength").on("change",checkSize);
	checkSize();
	runGetPromoterResults();
	setupDeleteButton(contextPath + "/web/geneLists/deleteGeneListAnalysis.jsp"); 
}
function runGetPromoterResults(){
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
}

function runPromoter(){
	var type=$("#promoterType").val();
	$('#wait2').show();
	$('#runStatus').html("");
	var params={};
	params.type=type;
	params.geneListID=id;
	if(type==='oPOSSUM'){
		params.searchRegionLevel=$("#oPOSSUMForm #searchRegionLevel").val();
		params.conservationLevel=$("#oPOSSUMForm #conservationLevel").val();
		params.thresholdLevel=$("#oPOSSUMForm #thresholdLevel").val();
		params.description=$("#oPOSSUMForm #description").val();
	}else if(type==='MEME'){
		params.upstreamLength=$("#memeForm #upstreamLength").val();
		params.upstreamSelect=$("#memeForm #upstreamSelect").val();
		params.distribution=$("#memeForm #distribution").val();
		params.minWidth=$("#memeForm #minWidth").val();
		params.maxWidth=$("#memeForm #maxWidth").val();
		params.maxMotifs=$("#memeForm #maxMotifs").val();
		params.description=$("#memeForm #description").val();
	}else if(type==='Upstream'){
		params.upstreamLength=$("#upstreamForm #upstreamLength").val();
		params.upstreamSelect=$("#upstreamForm #upstreamSelect").val();
	}
	$.ajax({
            url: contextPath + "/web/geneLists/include/runPromoter.jsp",
            type: 'GET',
            data: params,
            dataType: 'html',
            beforeSend: function(){
                    $('#runStatus').html("Submitting...");
            },
            success: function(data2){ 
                $('#runStatus').html(data2);
            },
            error: function(xhr, status, error) {
                $('#runStatus').html("An error occurred Try submitting again. Error:"+error);
            },
            complete: function(){
					$('#runStatus').show();
					setTimeout(function (){
						$('#runStatus').html("");
					},20000);
					runGetPromoterResults();
					resetForm();
			}
            });

}

function resetForm(){

}


function checkSize(){
                var select=parseFloat($("#upstreamLength").val());
                var total=geneNumber*select;
                if(total>300){
                    $("#sizeWarning").show();
                    $("#warnDetail").html(" ("+geneNumber+" genes x "+select+" Kb = "+total+" Kb ) ");
                }else{
                    $("#sizeWarning").hide();
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
