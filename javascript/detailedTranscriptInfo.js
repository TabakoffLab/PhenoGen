function displayWorking(){
	$('#wait1').show();
	$('#inst').hide();
	$('input#action').val("Get Transcription Details");
	return true;
}

function hideWorking(){
	$('#wait1').hide();
	$('#inst').hide();
}


function displayGo(){
	$('#wait1').show();
	$('#inst').hide();
	$('input#action').val("Go");
	$('input#geneSelect').val($('#geneSelectCBX').val());
	$('form#geneCentricForm').submit();
	return true;
}

function displayColumns(table,colStart,colLen,showOrHide){
	var colStop=colStart+colLen;
	for(var i=colStart;i<colStop;i++){
				table.dataTable().fnSetColumnVis( i, showOrHide );
	}
}



function expandCollapse(baseName){
	//alert("expand collapse");
	 var thisHidden = $("tbody#" + baseName).is(":hidden");
	 $('#'+baseName+'1').toggleClass("less");
	 $('#'+baseName+'2').toggleClass("less");
		if (thisHidden) {
			//alert("hidden");
			$("tbody#" + baseName).show();
			filterExpanded=1;
		} else {
			//alert("vis");
			$("tbody#" + baseName).hide();
			filterExpanded=0;
		}
}

function setFilterTableStatus(baseName){
	 var thisHidden = $("tbody#" + baseName).is(":hidden");
		if (thisHidden&&filterExpanded==1) {
			$("tbody#" + baseName).show();
			$('#'+baseName+'1').toggleClass("less");
			$('#'+baseName+'2').toggleClass("less");
		} else if(!thisHidden && filterExpanded==0) {
			$("tbody#" + baseName).hide();
			$('#'+baseName+'1').toggleClass("less");
			$('#'+baseName+'2').toggleClass("less");
		}
}

function runFilter(){
	var chrList = "";
          $("#chromosomesMS option").each(function () {
                chrList += $(this).val() + ";";
              });
	$('#chromosomes').val(chrList);
	var tisList = "";
          $("#tissuesMS option").each(function () {
                tisList += $(this).val() + ";";
              });
	$('#tissues').val(tisList);
	var levelList = "";
          $("#trxAnnotMS option").each(function () {
                levelList += $(this).val() + ";";
              });
	$('#levels').val(levelList);
	$('#pvalueCutoffInput').val($('#pvalueCutoffSelect2').val());
	loadEQTLTableWParams(levelList,chrList,tisList,$('#pvalueCutoffSelect2').val());
}


function enterSelectedGene(){
	var ensID=$("#geneSelectCBX").val();
	$("#geneTxt").val(ensID);
	$('#geneCentricForm').submit();
}

/*function openTranscriptDialog(regionTxt,speciesTxt,geneTxt){
			$.ajax({
				url: contextPath + "/web/GeneCentric/geneRegionView.jsp",
   				type: 'GET',
				data: {region: regionTxt, species: speciesTxt,gene: geneTxt},
				dataType: 'html',
    			success: function(data2){ 
        			$('#viewTrxDialog').html(data2);
    			},
    			error: function(xhr, status, error) {
        			$('#viewTrxDialog').html("<div>An error occurred generating this page.  Please try back later.</div>");
    			}
			});
			
}*/

function openSmallNonCoding(id,name){
		var params={id: id,name: name};
		if(id.indexOf(",")>0){
			params={idList: id,name: name};
		}
			$.ajax({
				url: contextPath + "/web/GeneCentric/viewSmallNonCoding.jsp",
   				type: 'GET',
				data: params,
				dataType: 'html',
    			success: function(data2){ 
        			$('#viewTrxDialog').html(data2);
    			},
    			error: function(xhr, status, error) {
        			$('#viewTrxDialog').html("<div>An error occurred generating this page.  Please try back later.</div>");
    			}
			});
}



/*
function updateTrackString(){
	trackString="";
	$("input[name='trackcbx']").each( function (){
		if($(this).is(":checked")){
			if(trackString==""){
				trackString=$(this).val();
			}else{
				trackString=trackString+","+$(this).val();
			}
			var idStr=new String($(this).attr("id"));
			var prefix=idStr.substr(0,idStr.length-3);
			if($("#"+prefix+"Select").length==1){
				trackString=trackString+"."+$("#"+prefix+"Select").val();
			}
		}
	});
}

function updateUCSCImage(){
			$.ajax({
				url: contextPath + "/web/GeneCentric/updateUCSCImage.jsp",
   				type: 'GET',
				data: {trackList: trackString,species: organism,chromosome: chr, minCoord: minCoord, maxCoord: maxCoord, type: ucsctype, geneID: ucscgeneID},
				dataType: 'html',
				beforeSend: function(){
					$('#geneImage').hide();
					$('#imgLoad').show();
				},
				complete: function(){
					$('#imgLoad').hide();
					$('#geneImage').show();
				},
    			success: function(data2){ 
        			$('#geneImage').html(data2);
    			},
    			error: function(xhr, status, error) {
        			$('#geneImage').html("<div>An error occurred generating this image.  Please try back later.</div>");
    			}
			});
}

	function gvupdateTrackString(){
		gvtrackString="";
		$("input[name='gvtrackcbx']").each( function (){
			if($(this).is(":checked")){
				if(gvtrackString==""){
					gvtrackString=$(this).val();
				}else{
					gvtrackString=gvtrackString+","+$(this).val();
				}
				var idStr=new String($(this).attr("id"));
				var prefix=idStr.substr(0,idStr.length-3);
				if($("#"+prefix+"Select").length==1){
					gvtrackString=gvtrackString+"."+$("#"+prefix+"Select").val();
				}
			}
		});
	}

function gvupdateUCSCImage(){
			$.ajax({
				url: contextPath + "/web/GeneCentric/updateUCSCImage.jsp",
   				type: 'GET',
				data: {trackList: gvtrackString,species: organism,chromosome: chr, minCoord: gvminCoord, maxCoord: gvmaxCoord,type:"geneView"},
				dataType: 'html',
				beforeSend: function(){
					$('#gvgeneImage').hide();
					$('#gvimgLoad').show();
				},
				complete: function(){
					$('#gvimgLoad').hide();
					$('#gvgeneImage').show();
				},
    			success: function(data2){ 
        			$('#gvgeneImage').html(data2);
    			},
    			error: function(xhr, status, error) {
        			$('#gvgeneImage').html("<div>An error occurred generating this image.  Please try back later.</div>");
    			}
			});
}*/