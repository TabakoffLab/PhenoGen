/* --------------------------------------------------------------------------------
 *
 *  specific functions for uploadCELFiles.jsp
 *
 * -------------------------------------------------------------------------------- */

function checkUploadLimit() {
	var uploadLimit = 10;
   $('input[type=file]').change(function() {
        if( $(":file[value!='']").length >= uploadLimit ) {
            alert("You have reached the maximum limit of " + uploadLimit + " files to be uploaded. \nUpload the selected files to continue.");
			$.each($("input[type=file]"), function() {   
			  if ($(this).val() ==''){
			  	$(this).attr("disabled","true");
			  }            
            });			
        }
   });
}
