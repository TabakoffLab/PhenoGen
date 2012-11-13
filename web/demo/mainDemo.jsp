<%--
 *  Author: Spencer Mahaffey
 *  Created: August, 2012
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/access/include/login_vars.jsp" %>

<% 	//extrasList.add("jquery-ui-1.8.23.min.js");
	extrasList.add("/smoothness/jquery-ui-1.9.1.custom.css");
	extrasList.add("index.css"); %>
<%pageTitle="Overview Downloads";%>

<%@ include file="/web/common/header_noMenu.jsp" %>

	<h2>Demos</h2>
    <div id="videoDiv" style="display:inline-block;">
					<video id="video" width="640" height="480" controls="controls" autoplay="true">
                    	<source id="videoWebm" src="test.webm" type="video/webm">
  						<source id="videoMp4" src="test.mp4" type="video/mp4">
                          <object id="videoObj" data="test.mp4" width="320" height="240">
                          </object>
                        </video> 
                        <div id="description" style="width:640px; height:200px; overflow:auto;">
                        	Description of the above video.
                        </div>
	</div>
    
    <div id="accordion" style="width:350px; float:right;  display:inline-block;">
    	<h3>Overview</h3>
        <div style="text-align:left;">
        	<table name="items" class="list_base" style="border:none; text-align:left;">
            	<TR id="test">
                	<TD>Overview</TD><TD>3:22</TD><TD>A short Description of the video.</TD>
                </TR>
                <TR id="microarray">
                	<TD>Test</TD><TD>3:22</TD><TD>A short Description of the video.</TD>
                </TR>
            </table>
        </div>
        <H3>Detailed Transcription Information</H3>
        <div>
        </div>
        <H3>Downloads</H3>
        <div>
        </div>
        <H3>Microarray Analysis Tools</H3>
        <div>
        </div>
        <H3>Gene List Analysis Tools</H3>
        <div>
        </div>
    	<H3>QTL Tools</H3>
        <div>
        </div>
    </div>


<script type="text/javascript">
$(document).ready(function() {
	
	$( "#accordion" ).accordion();
	
	var tableRows = getRows();
	hoverRows(tableRows);
	tableRows.each(function(){
		//---> click functionality
		$(this).find("td").click( function() {
			var file = $(this).parent("tr").attr("id");
			//alert(file);
			//$('#videoWebm').attr("src",file+".webm");
			//$('#videoMp4').attr("src",file+".mp4");
			//$('#videoObj').attr("data",file+".mp4");
			//$('#video').remove();
			//$('#video').play();
			$('#videoDiv').html("<video id=\"video\" width=\"640\" height=\"480\" controls=\"controls\" autoplay=\"true\"><source id=\"videoWebm\" src=\""+file+".webm\" type=\"video/webm\"><source id=\"videoMp4\" src=\""+file+".mp4\" type=\"video/mp4\"><object id=\"videoObj\" data=\""+file+".mp4\" width=\"320\" height=\"240\"></object></video>");
			$('#video').load();
			return false;
		});

		
	});
});
</script>

	
<%@ include file="/web/common/footer.jsp" %>
