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
    var wWidth=jQuery(window).width();
    var accord=0;
    var autoRefreshHandle=0;
    jQuery(window).resize(function(){
        
                var newW=jQuery(window).width();
                
                var tmpInd=1;
                if(accord!==0){
                    tmpInd=accord.accordion( "option", "active" );
                }
                if(newW<=1000 && wWidth>1000){
                        accord.accordion("destroy");
                        accord=0;
                        setTimeout(function(){
                            accord=jQuery( 'div#toolsAccord' ).accordion({heightStyle: "fill"});
                            jQuery( 'div#toolsAccord' ).accordion({'active':tmpInd});
                        },200);
                }else if(newW>1000 && wWidth<=1000){
                        accord.accordion("destroy");
                        accord=0;
                        setTimeout(function(){
                            accord=jQuery( 'div#toolsAccord' ).accordion({heightStyle: "fill"});
                            jQuery( 'div#toolsAccord' ).accordion({'active':tmpInd});
                        },200);
                }
                wWidth=newW;
            });
    jQuery(document).ready(function() {
        setTimeout(function(){
                accord=jQuery( 'div#toolsAccord' ).accordion({heightStyle: "fill"});
                jQuery( 'div#toolsAccord' ).accordion({'active':1});
            },100);
    });
    
    /*
     * Generic method to delete any GeneList Analysis
    */
    function runDeleteGeneListAnalysis(id,type){
        jQuery.ajax({
                    url: contextPath + "/web/geneLists/include/deleteAjaxGLA.jsp",
                    type: 'GET',
                    data: {geneListAnalysisID:id},
                    dataType: 'html',
                    success: function(data2){
                            if(data2.indexOf("Success")===-1){
                                jQuery("#delete-errmsg").html(data2);
                                jQuery( "#dialog-delete-error" ).dialog("open");
                            }
                            runGetResults(-1);
                    },
                    error: function(xhr, status, error) {
                           jQuery("#delete-errmsg").html(error);
                           jQuery( "#dialog-delete-error" ).dialog("open");
                    }
            });
    }
    
    function runGetResults(retry){
        var id=<%=selectedGeneList.getGene_list_id()%>;
        jQuery('#resultList').html("<div id=\"waitLoadResults\" align=\"center\" style=\"position:relative;top:0px;\"><img src=\"<%=imagesDir%>wait.gif\" alt=\"Loading Results...\" text-align=\"center\" ><BR />Loading Results...</div>"+jQuery('#resultList').html());
        jQuery.ajax({
                url: analysisPath,
                type: 'GET',
                data: {geneListID:id},
                dataType: 'html',
                success: function(data2){ 
                            var time=20000;
                            if(retry>100){
                                time=60000;
                            }else if(retry>200){
                                time=120000;
                            }else if(retry>500){
                                retry=-1;
                            }
                            if(retry>-1){
                                autoRefreshHandle=setTimeout(function (){
                                        runGetResults(retry+1);
                                },20000);
                            }
                            jQuery('#resultList').html(data2);
                },
                error: function(xhr, status, error) {
                        jQuery('#resultList').html("Error retreiving results.  Please try again.");
                }
        });
    }
    function stopRefresh(){
        if(autoRefreshHandle){
                clearTimeout(autoRefreshHandle);
                autoRefreshHandle=0;
        }
    }
    function startRefresh(){
        if(!autoRefreshHandle){
            autoRefreshHandle=setTimeout(function (){
                                            runGetResults(0);
                                        }
                                        ,20000);
        }
    }
    
</script>