<%--
 *  Author: Spencer Mahaffey
 *  Created: June, 2015
 *  Description:  This file adds javascript to setup the result view for gene list tools
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<script>
    var wWidth=$(window).width();
    var accord=0;
    $(window).resize(function(){
        
                var newW=$(window).width();
                
                var tmpInd=1;
                if(accord!==0){
                    tmpInd=accord.accordion( "option", "active" );
                }
                if(newW<=1000 && wWidth>1000){
                        accord.accordion("destroy");
                        accord=0;
                        setTimeout(function(){
                            accord=$( 'div#toolsAccord' ).accordion({heightStyle: "fill"});
                            $( 'div#toolsAccord' ).accordion({'active':tmpInd});
                        },200);
                }else if(newW>1000 && wWidth<=1000){
                        accord.accordion("destroy");
                        accord=0;
                        setTimeout(function(){
                            accord=$( 'div#toolsAccord' ).accordion({heightStyle: "fill"});
                            $( 'div#toolsAccord' ).accordion({'active':tmpInd});
                        },200);
                }
                wWidth=newW;
            });
    $(document).ready(function() {
        setTimeout(function(){
                accord=$( 'div#toolsAccord' ).accordion({heightStyle: "fill"});
                $( 'div#toolsAccord' ).accordion({'active':1});
            },100);
    });
    
    /*
     * Generic method to delete any GeneList Analysis
    */
    function runDeleteGeneListAnalysis(id,type){
        $.ajax({
                    url: contextPath + "/web/geneLists/include/deleteAjaxGLA.jsp",
                    type: 'GET',
                    data: {geneListAnalysisID:id},
                    dataType: 'html',
                    success: function(data2){
                            if(data2.indexOf("Success")===-1){
                                $("#delete-errmsg").html(data2);
                                $( "#dialog-delete-error" ).dialog("open");
                            }
                    },
                    error: function(xhr, status, error) {
                           $("#delete-errmsg").html(error);
                           $( "#dialog-delete-error" ).dialog("open");
                    }
            });
    }
    
</script>