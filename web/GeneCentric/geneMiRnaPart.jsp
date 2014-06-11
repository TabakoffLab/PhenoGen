
	
    
    
	<div style="text-align:center;">
		<div style="font-size:18px; font-weight:bold; background-color:#47c647; color:#FFFFFF;width:100%;text-align:left;">
    	<span class="trigger less triggerEC" id="mirOption1" name="mirOption" style=" margin-left:50px;" >multiMiR Options</span>
		</div>


      	<table id="mirOptTbl" name="items" class="list_base" cellpadding="0" cellspacing="3" style="width:100%;text-align:left;" >
        <tbody id="mirOption">
 			<TR>
            <TD>Validation Level: 
                <select name="table" id="table">
                    <option value="all" <%if(table.equals("all")){%>selected<%}%>>All</option>
                    <option value="validated" <%if(table.equals("validated")){%>selected<%}%>>Validated Only</option>
                    <option value="predicted" <%if(table.equals("predicted")){%>selected<%}%>>Predicted Only</option>
                </select>
                <span class="mirtooltip"  title="Limit results returned to those with any hits(All), or only validated hits(Validated Only) , or only predicted hits(Predicted Only)"><img src="<%=imagesDir%>icons/info.gif"></span>
            </TD>
            <TD>Predicted Cutoff Type:
                <select name="predType" id="predType">
                    <option value="p" <%if(predType.equals("p")){%>selected<%}%>>Top percentage of miRNA targets</option>
                    <option value="n" <%if(predType.equals("n")){%>selected<%}%>>Top number of miRNA targets</option>
                </select>
            	<span class="mirtooltip"  title="Limit predicted search to only the top ___% or # of predicted miRNA targets.  The default will only search the top 20% of all predicted results by default."><img src="<%=imagesDir%>icons/info.gif"></span>
            </TD>
            <TD>
            	Predicted Cutoff: Top <input id="cutoff" type="text" size="5" value="<%=cutoff%>" /><span id="lblPerc">% of </span> miRNAs 
                <span class="mirtooltip"  title="Set the cutoff for the predicted cutoff type.  Ex. If Top percentage of miRNA targets is selected and 10 is entered you are searching the top 10% of predicted targets.  If Top number of miRNA targets is selected and 30000 is entered you are searching only the top 30,000 predicted targets."><img src="<%=imagesDir%>icons/info.gif"></span>
            </TD>
            </TR>
            
            <TR>
            <TD colspan="3">
            <input type="button"  value="Run MultiMiR" onclick="runMultiMir()"/>
            </TD>
            </TR>
        </tbody>
      	</table>


<BR>



<div id="wait2" align="center" style="position:relative;top:0px;"><img src="<%=imagesDir%>wait.gif" alt="Working..." text-align="center" >
	<BR />Running multiMiR...</div>



<div id="forMultiMir" style="display:none">

</div>

<script type="text/javascript">
		$(".mirtooltip").tooltipster({
				position: 'top-right',
				maxWidth: 250,
				offsetX: 10,
				offsetY: 5,
				contentAsHTML:true,
				//arrow: false,
				interactive: true,
				interactiveTolerance: 350
			});
		function displayWorkingMultiMir(){
			document.getElementById("wait2").style.display = 'block';
		}
		function hideWorkingMultiMir(){
			document.getElementById("wait2").style.display = 'none';
		}
		function runMultiMir(){
			var species="<%=myOrganism%>";
			var id="<%=id%>";
			var table=$('select#table').val();
			var predType=$('select#predType').val();
			var cutoff=$('input#cutoff').val();
			$('#wait2').show();
			$.ajax({
				url: contextPath + "/web/GeneCentric/runMultiMiR.jsp",
   				type: 'GET',
				data: {species:species,id:id,table:table,predType:predType,cutoff:cutoff},
				dataType: 'html',
				complete: function(){
					//$('#imgLoad').hide();
					$('#wait2').hide();
					$('#forMultiMir').show();
				},
    			success: function(data2){ 
        			$('#forMultiMir').html(data2);
    			},
    			error: function(xhr, status, error) {
        			$('#forMultiMir').html("<div>An error occurred generating this image.  Please try back later.</div>");
    			}
			});
		}
	</script>
    