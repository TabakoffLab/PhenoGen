/* --------------------------------------------------------------------------------
 *
 *  specific functions for advancedAnnotation.jsp
 *
 * -------------------------------------------------------------------------------- */
$(document).ready(function() {

   var itemDetails = createDialog(".itemDetails" , {width: 900, height: 500, title: "<center>Download</center>"});
   $("#downloadBtn").click(function(){
     var iDecoderChoice        = new Array();
     var AffymetrixArrayChoice = new Array();
     var CodeLinkArrayChoice   = new Array();
			   
     if (IsAdvancedAnnotationComplete()){
        $.each($("input[name='iDecoderChoice']:checked"), function() {	
            iDecoderChoice.push($(this).val());
        });
					 
        $.each($("input[name='AffymetrixArrayChoice']:checked"), function() {	
            AffymetrixArrayChoice.push($(this).val());
        });
					 
        $.each($("input[name='CodeLinkArrayChoice']:checked"), function() {	
           CodeLinkArrayChoice.push($(this).val());
        });
					 
        $.get(contextPath + "/web/geneLists/downloadAnnotationPopup.jsp?callingForm=advancedAnnotation.jsp", {'iDecoderChoice[]':iDecoderChoice, 'AffymetrixArrayChoice[]':AffymetrixArrayChoice , 'CodeLinkArrayChoice[]':CodeLinkArrayChoice},
                		function(data){							   
                    			itemDetails.dialog("open").html(data);
					            closeDialog(itemDetails);					
                		});
     }  
   });	
});



function IsAdvancedAnnotationComplete(){
	var field = document.advancedAnnotation.iDecoderChoice;
	for (i=0; i<field.length; i++) {
		if (field[i].checked) {
			return true;
		}
	}
	alert('You must select one or more target databases before proceeding.')
	return false; 
}

// check the Affymetrix ID if any of the Affy-specific chips are requested 
function clickAffyID() {
	$("input[value='Affymetrix ID']").attr('checked', true);
}

// check the CodeLink ID if any of the CodeLink-specific chips are requested 
function clickCodeLinkID() {
	$("input[value='CodeLink ID']").attr('checked', true);
}

function checkUncheckCodeLinkID(id) {
   $("input[value='CodeLink ID']").attr('checked', $('#' + id).is(':checked'));
}
function checkUncheckAffyID(id) {
   $("input[value='Affymetrix ID']").attr('checked', $('#' + id).is(':checked'));
}

