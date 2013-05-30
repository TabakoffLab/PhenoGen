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

.link {
  stroke: #999;
  stroke-opacity: .6;
}

</style>

					<table class="index">
                    <tr><TD id="imageColumn" class="full">
                    
                	<div id="indexImage" >
                    	<script src="javascript/indexGraph.js">
						</script>
                    </div>
                    
                    </TD>
                    <TD  id="descColumn"  class="none">
                    <div id="indexDesc" style="display:none;border-color:#000000; border-style:solid; border-width:1px; background-color:#FFFFFF; color:#000000; height:750px;">
                            <span id="expandBTN" class="expandSect" style=" float:left; position:relative; top:9px;"><img src="web/images/icons/expand_section.jpg"></span>
                            <div id="indexDescContent" style="height:100%;">
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
								width=335;
								force.size([width, height]);
								force.start();
							}else{
								$(this).removeClass("minSect").addClass("expandSect");
								$('#descColumn').removeClass("wide").addClass("narrow");
								$('#imageColumn').removeClass("narrow").addClass("wide");
								$('#indexImage svg').attr("width","660px");
								$('#expandBTN img').attr("src","web/images/icons/expand_section.jpg");
								$('#demoVideo').attr("width","260px");
								width=660;
								force.size([width, height]);
								force.start();
							}
						});
                    </script>

    