/* --------------------------------------------------------------------------------
 *
 *  specific functions for iDecoderResults.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/
function setupPage() {

   var tableRows = getRows();
   var itemDetails = createDialog(".itemDetails" , {width: 900, height: 500, title: "Download"});
            $("#download").click(function(){

               var iDecoderChoice        = new Array();
               var AffymetrixArrayChoice = new Array();
               var CodeLinkArrayChoice   = new Array();
   
               $.each($("input[name='iDecoderChoice']:checked"), function() { 
                          iDecoderChoice.push($(this).val());
               });
                     
               $.each($("input[name='AffymetrixArrayChoice']:checked"), function() {  
                          AffymetrixArrayChoice.push($(this).val());
               });
                     
               $.each($("input[name='CodeLinkArrayChoice']:checked"), function() {    
                          CodeLinkArrayChoice.push($(this).val());

               });
			   
               $.get(contextPath + "/web/geneLists/downloadAnnotationPopup.jsp", {'iDecoderChoice[]':iDecoderChoice, 'AffymetrixArrayChoice[]':AffymetrixArrayChoice , 'CodeLinkArrayChoice[]':CodeLinkArrayChoice},
                        function(data){                            
                                itemDetails.dialog("open").html(data);
                                closeDialog(itemDetails);
                    
               });
             
        });
}

