/* --------------------------------------------------------------------------------
 *
 *  specific functions for pathwayResults.jsp
 *
 * -------------------------------------------------------------------------------- */

 function setupPage(){
      var itemDetails = createDialog(".itemDetails" , {width: 700, height: 800, title: "<center>Pathway Plot</center>"});
	
      $("#PathwayPlotLink").click(function(){
            
            var pathwayPlotUrl = $("#pathwayPlotUrl").val();
            $.get(contextPath + "/web/geneLists/pathwayPlot.jsp", 
                  {pathwayPlotUrl: pathwayPlotUrl},
                      function(data){
                             itemDetails.dialog("open").html(data);
                             closeDialog(itemDetails);
                      });
         
       });
	
	
       $("div#download").click(function(){
            $("input[name='action']").val("Download");
            $("form[name='pathwayResults']").submit();
       });
 }
