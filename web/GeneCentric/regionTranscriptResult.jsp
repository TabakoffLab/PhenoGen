<script type="text/javascript">
	var gvtrackString="probe,coding,refseq";
	var gvminCoord=<%=min%>;
	var gvmaxCoord=<%=max%>;

/*function displayWorking(){
	document.getElementById("wait1").style.display = 'block';
	document.getElementById("inst").style.display= 'none';
	return true;
}

function hideWorking(){
	document.getElementById("wait1").style.display = 'none';
	document.getElementById("inst").style.display= 'none';
}*/


function gvupdateTrackString(){
	gvtrackString="";
	$("input[name='gvtrackcbx']").each( function (){
		if($(this).is(":checked")){
			if(gvtrackString==""){
				gvtrackString=$(this).val();
			}else{
				gvtrackString=gvtrackString+","+$(this).val();
			}
			if($(this).attr("id")=="gvsnpCBX"){
				gvtrackString=gvtrackString+"."+$("#gvsnpSelect").val();
			}else if($(this).attr("id")=="gvhelicosCBX"){
				gvtrackString=gvtrackString+"."+$("#gvhelicosSelect").val();
			}
		}
		
	});
}

function gvupdateUCSCImage(){
			$.ajax({
				url: contextPath + "/web/GeneCentric/updateUCSCImage.jsp",
   				type: 'GET',
				data: {trackList: gvtrackString,species: organism,chromosome: chr, minCoord: gvminCoord, maxCoord: gvmaxCoord,type:"geneView"},
				dataType: 'html',
				beforeSend: function(){
					$('#gvgeneImage').hide();
					$('#gvimgLoad').show();
				},
				complete: function(){
					$('#gvimgLoad').hide();
					$('#gvgeneImage').show();
				},
    			success: function(data2){ 
        			$('#gvgeneImage').html(data2);
    			},
    			error: function(xhr, status, error) {
        			$('#gvgeneImage').html("<div>An error occurred generating this image.  Please try back later.</div>");
    			}
			});
}

</script>
<span style="text-align:center;width:100%;">
	
<%if(genURL!=null && genURL.size()>=1 && !genURL.get(0).startsWith("ERROR:")){%>
<%
	String tmpURL=genURL.get(0);
	int second=tmpURL.lastIndexOf("/",tmpURL.length()-2);
	String folderName=tmpURL.substring(second+1,tmpURL.length()-1);
	DecimalFormat dfC = new DecimalFormat("#,###");
	String tmpFile="ucsc."+trackDefault.replaceAll(",",".")+".png";
%>
    
    
    <div style="width:100%; text-align:center;">
    	<H2>Transcripts for <%=myGeneID%></H2>
        <div id="gvimgLoad" style="display:none;"><img src="<%=imagesDir%>ucsc-loading.gif" /></div>
        <div id="gvgeneImage" class="gvucscImage"  style="display:inline-block;">
            	<a class="fancyboxExt fancybox.iframe" href="<%=ucscURL.get(0)%>" title="UCSC Genome Browser">
            	<img src="<%= contextRoot+"tmpData/regionData/"+folderName+"/"+tmpFile%>"/></a>
            </div>
        <div class="gvgeneimageControl">
            Image Tracks:<div class="inpageHelp" style="display:inline-block; margin-left:10px;"><img id="Help1" class="helpImage" src="../web/images/icons/help.png" /></div>
            <input name="gvtrackcbx" type="checkbox" id="gvprobeCBX" value="probe" <%if(tmpFile.contains(".probe.")){%>checked="checked"<%}%> /> All Non-Masked Probesets
            <input name="gvtrackcbx" type="checkbox" id="gvfilterprobeCBX" value="filterprobe" <%if(tmpFile.contains(".filterprobe.")){%>checked="checked"<%}%> />Probsets Detected Above Background >1% of samples
            <input name="gvtrackcbx" type="checkbox" id="gvcodingCBX" value="coding" <%if(tmpFile.contains(".coding.")){%>checked="checked"<%}%> /> Protein Coding/PolyA+<BR />
            <input name="gvtrackcbx" type="checkbox" id="gvnoncodingCBX" value="noncoding" <%if(tmpFile.contains(".noncoding.")){%>checked="checked"<%}%> />Long Non-Coding/NonPolyA+ 
            <input name="gvtrackcbx" type="checkbox" id="gvsmallncCBX" value="smallnc" <%if(tmpFile.contains(".smallnc.")){%>checked="checked"<%}%>  /> Small RNA 
           	<input name="gvtrackcbx" type="checkbox" id="gvsnpCBX" value="snp" <%if(tmpFile.contains(".snp")){%>checked="checked"<%}%> /> SNPs/Indels:
             <select name="gvtrackSelect" id="gvsnpSelect">
            	<option value="1" selected="selected">Dense</option>
                <option value="3" >Pack</option>
            </select>
            <input name="gvtrackcbx" type="checkbox" id="gvhelicosCBX" value="helicos" <%if(tmpFile.contains(".helicos")){%>checked="checked"<%}%>/> Helicos Data:
            <select name="gvtrackSelect" id="gvhelicosSelect">
            	<option value="1" selected="selected">Dense</option>
                <option value="2" >full</option>
            </select>
            <input name="gvtrackcbx" type="checkbox" id="gvrefseqCBX" value="refseq" <%if(tmpFile.contains(".refseq.")){%>checked="checked"<%}%>/> RefSeq Transcripts
          </div><!--end imageControl div -->
    
          </div><!--end Border Div -->
         </span><!-- ends center span -->


<script type="text/javascript">
	$(".waitTrx").hide();	
	//Setup Fancy box for UCSC link
	$('.fancyboxExt').fancybox({
		width:$(document).width(),
		height:$(document).height(),
		scrollOutside:false,
		afterClose: function(){
			$('body.noPrint').css("margin","5px auto 60px");
			return;
		}
  });
  
  $("input[name='gvtrackcbx']").change( function(){
			gvupdateTrackString();
			gvupdateUCSCImage();
			
	 });
	 
	 $("select[name='gvtrackSelect']").change( function(){
	 	var id=$(this).attr("id");
		var cbx=id.replace("Select","CBX");
		if($("#"+cbx).is(":checked")){
			gvupdateTrackString();
			gvupdateUCSCImage();
		}
	 });
  
  
 
</script>



<%}else{%>
    	<div class="error"><%=genURL.get(selectedGene)%><BR />The administrator has been notified of the problem and will investigate the error.  We apologize for any inconvenience.</div><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR />
<%}%>
    






