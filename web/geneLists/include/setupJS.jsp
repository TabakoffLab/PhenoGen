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
    var resultLoaded=0;
    var wWidth=$(window).width();
    var accord;
    $(window).resize(function(){
                var newW=$(window).width();
                var tmpInd=accord.accordion( "option", "active" );
                if(newW<=1000 && wWidth>1000){
                    setTimeout(function(){
                        accord.accordion("destroy");
                        $( 'div#toolsAccord' ).removeClass('tall');
                        accord=$( 'div#toolsAccord' ).accordion();
                        $( 'div#toolsAccord' ).accordion({'active':tmpInd});
                    },300);

                }else if(newW>1000 && wWidth<=1000){
                    setTimeout(function(){
                        accord.accordion("destroy");
                        if(resultLoaded!==0){
                            $( 'div#toolsAccord' ).addClass('tall');
                        }
                        accord=$( 'div#toolsAccord' ).accordion({heightStyle: "fill"});
                        $( 'div#toolsAccord' ).accordion({'active':tmpInd});
                    },300);
                }
                wWidth=newW;
            });
    $(document).ready(function() {
        if($(window).width()<=1000){
            setTimeout(function(){
                accord=$( 'div#toolsAccord' ).accordion();
            },300);
        }else{
            setTimeout(function(){
            accord=$( 'div#toolsAccord' ).accordion({heightStyle: "fill"});
            },300);
        }
        $( 'div#toolsAccord' ).accordion({'active':1});
    });
    
    function afterDisplayResults(){
        resultLoaded=1;
        setTimeout(function(){
            var newW=$(window).width();
            var tmpInd=accord.accordion( "option", "active" );
            if(newW<=1000 ){
                    accord.accordion("destroy");
                    accord=$( 'div#toolsAccord' ).accordion();
                    $( 'div#toolsAccord' ).accordion({'active':tmpInd});
            }else if(newW>1000 ){
                    accord.accordion("destroy");
                    $( 'div#toolsAccord' ).addClass("tall");
                    accord=$( 'div#toolsAccord' ).accordion({heightStyle: "fill"});
                    $( 'div#toolsAccord' ).accordion({'active':tmpInd});
            }
        },500);
    }
</script>