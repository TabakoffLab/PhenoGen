<%--
 *  Author: Spencer Mahaffey
 *  Created: August, 2012
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<style>

.node circle {
  stroke: #fff;
  stroke-width: 1.5px;
}

.link, .desclink {
  stroke: #999;
  stroke-opacity: .6;
}

</style>


					<table class="index" cellspacing="0" cellpadding="0">
                    <tr><TD id="imageColumn" class="wide">
                    <h3>Hover over or click on functions to view additional information.</h3>
                    <script type="text/javascript">
						var selectedSection=0;
                    </script>
                	<div id="indexImage" >
                    	<script src="javascript/indexGraph1.js">
						</script>
                    </div>
                    
                    </TD>
                    <TD  id="descColumn"  class="narrow">
                    <div id="indexDesc" style="display:none;border-color:#000000; border-style:solid; border-width:1px; background-color:#FFFFFF; color:#000000;">
                            <span id="expandBTN" class="expandSect" style=" float:left; position:relative; top:9px; cursor:pointer;"><img src="web/images/icons/expand_section.jpg"></span>
                            <div id="indexDescContent" style="height:650px;">
                            </div>
                            
        			</div>
                    </TD>
                    </tr>
                    </table>
                    
                    <script type="text/javascript">
						$('#expandBTN').click( function () {
							if($(this).attr("class")=="expandSect"){
								$(this).removeClass("expandSect").addClass("minSect");
								$('#indexImage svg').attr("width","335px");
								$('#imageColumn').removeClass("wide").addClass("narrow");
								$('#descColumn').removeClass("narrow").addClass("wide");
								$('#expandBTN img').attr("src","web/images/icons/minimize_section.jpg");
								$('#demoVideo').attr("width","580px");
								//shiftLeft();
								width=335;
								setXSpacing(180);
								redraw();
								
							}else{
								$(this).removeClass("minSect").addClass("expandSect");
								$('#descColumn').removeClass("wide").addClass("narrow");
								$('#imageColumn').removeClass("narrow").addClass("wide");
								$('#indexImage svg').attr("width","660px");
								$('#expandBTN img').attr("src","web/images/icons/expand_section.jpg");
								$('#demoVideo').attr("width","260px");
								//shiftRight();
								width=660;
								setXSpacing(240);
								redraw();
							}
						});
                    </script>

    