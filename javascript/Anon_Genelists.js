function GeneLists(){
    
    var that=this;
    that.retryCount=0;
    
    this.getListGeneLists=function (draw,selector){
    	$.ajax({
            url: contextRoot+"web/geneLists/include/getGeneList.jsp",
            type: 'GET',
            cache: false,
            data: {},
            dataType: 'json',
            success: function(data2){
               	console.log(data2);
               	if(draw){
               		createTableGeneLists(data2,selector);
           		}
            },
            error: function(xhr, status, error) {
                console.log("ERROR:"+error);
                if(that.retryCount<10){
                	that.retryCount++;
                	setTimeout(that.getListGeneLists,2000*that.retryCount);
            	}
            }
        });
    };

    function createTableGeneLists(data,selector){
    	var tracktbl=d3.select(selector).select("tbody")
    		.selectAll('tr')
    		.data(data)
			.enter().append("tr")
			.style("text-align","center")
			.attr("id",function(d){return "gl"+d.id;})
			.attr("class",function(d,i){var ret="odd";if(i%2===0){ret="even";} return ret;});

			tracktbl.each(function(d,i){
						var tmpI=i;
						var id=d3.select(this).data()[0].id;
						console.log(id);
						d3.select(this).append("td").html(d.name);
						d3.select(this).append("td").html(d.created);
						d3.select(this).append("td").html(d.geneCount);
						d3.select(this).append("td").html(d.organism);
						d3.select(this).append("td").html(d.source);
						d3.select(this).append("td").attr("class","details").append("span").text("view");
						d3.select(this).append("td").attr("class","actionIcons").append("img").attr("src",contextRoot+"web/images/icons/delete.png");
						d3.select(this).append("td").attr("class","actionIcons").append("img").attr("src",contextRoot+"web/images/icons/download_g.png");
						
		
						$("tr#gl"+id).find("td").slice(0,5).click( function() {
                                       var listItemId = $(this).parent("tr").attr("id").substr(2);
                                       $("input[name='geneListID']").val( listItemId );
                                       showLoadingBox();
                                       document.chooseGeneList.submit();
                               });

                        $("tr#gl"+id).find("td.details").click( function() {
                                       var geneListID = $(this).parent("tr").attr("id").substr(2);
                                       var parameterGroupID = $(this).parent("tr").attr("parameterGroupID");
                                       $.get(contextPath + "/web/geneLists/formatParametersGL.jsp", 
                                               {geneListID: geneListID, 
                                               parameterGroupID: parameterGroupID,
                                               parameterType:"geneList"},
                                               function(data){
                                                       itemDetails.dialog("open").html(data);
                                                       closeDialog(itemDetails);
                                       });
                               });
            });
            var tableRows = getRows();
            hoverRows(tableRows);
    };
    
    /* * *
     *  sets up the create new genelist modal
    /*/
    that.setupLinkEmail=function () {
            console.log("call setupLinkEmail");
           var linkEmailDialog;
           // setup create new gene list button
           $("#linkEmail").click(function(){
                console.log("clicked linkEmail");
                   if ( linkEmailDialog == undefined ) {
                           var dialogSettings = {width: 800, height: 200, title: "Link Email to Anonymous Session"};
                           /* browser.safari true means the browser is Safari */
                           //if ($.browser.safari) $.extend(dialogSettings, {modal:false});
                           $("body").append("<div id=\"linkEmailDialog\"></div>");
                           linkEmailDialog = createDialog("div#linkEmailDialog", dialogSettings); 
                   }
                   $.get(contextPath+"/web/access/linkEmail.jsp", function(data){
                           linkEmailDialog.dialog("open").html(data);
                   });
           });
    }
    
    return that;
};

var geneListjs=GeneLists();