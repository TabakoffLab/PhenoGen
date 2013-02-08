<script type="text/javascript">
/*function displayWorking(){
	document.getElementById("wait1").style.display = 'block';
	document.getElementById("inst").style.display= 'none';
	return true;
}

function hideWorking(){
	document.getElementById("wait1").style.display = 'none';
	document.getElementById("inst").style.display= 'none';
}*/


</script>
<span style="text-align:center;width:100%;">
	
<%if(genURL!=null && genURL.size()>=1 && !genURL.get(0).startsWith("ERROR:")){%>
<%
	String tmpURL=genURL.get(0);
	int second=tmpURL.lastIndexOf("/",tmpURL.length()-2);
	String folderName=tmpURL.substring(second+1,tmpURL.length()-1);
	DecimalFormat dfC = new DecimalFormat("#,###");
%>
    
    <script>
		var organism="<%=myOrganism%>";
    </script>

    
    <div style="border-color:#CCCCCC; border-width:1px; border-style:inset; width:98%; text-align:center;">
    	<H2>Transcripts for <%=myGeneID%></H2>
        <label>View:</label>
                <select name="gvSelect" id="gvSelect">
                	<option value="giProbe" selected="selected">with Probesets</option>
                    <option value="gifiltered" >with Probesets Detected Above Background(DABG) in >1% samples</option>
                    <option value="snps" >with SNPs and Indels</option>
                    <option value="giNoProbe" >without Probesets or SNPs</option>
                </select>
        <div class="geneimage" >
            <div class="inpageHelp" style="display:inline-block;position:relative;float:right;"><img id="Help2" class="helpImage" src="../web/images/icons/help.png"  /></div>
    	<%if(ucscURL.size()>0){%>
            <div id="giProbe" class="ucscImage2" style="display:inline-block;"><a class="fancyboxExt fancybox.iframe" href="<%=ucscURL.get(0)%>" title="UCSC Genome Browser"><img src="<%= contextRoot+"tmpData/regionData/"+folderName+"/region.main.png"%>"/></a></div>
         <%}else{%>
         <%}%>
      	<%if(ucscURL.size()>0){%>
            <%
				String ucscURL_noProbe=ucscURL.get(0).replace(".trx",".trx.noProbe");
			%>
            <div id="giNoProbe"  class="ucscImage2" style="display:none;"><a class="fancyboxExt fancybox.iframe" href="<%=ucscURL_noProbe%>" title="UCSC Genome Browser"><img src="<%= contextRoot+"tmpData/regionData/"+folderName+"/region.main.noProbe.png"%>"/></a></div>
            <%}%>
        <%if(ucscURL.size()>0){%>
            <%
				String ucscURL_filterProbe=ucscURL.get(0).replace(".trx",".trx.filterProbe");
			%>
            <div id="gifiltered" class="ucscImage2"  style="display:none;"><a class="fancyboxExt fancybox.iframe" href="<%=ucscURL_filterProbe%>" title="UCSC Genome Browser"><img src="<%= contextRoot+"tmpData/regionData/"+folderName+"/region.main.probeFilter.png"%>"/></a></div>
            <%}%>
    	<%if(ucscURL.size()>0){%>
            <%
				String ucscURL_snp=ucscURL.get(0).replace(".trx",".trx.snp");
			%>
            <div id="snps" class="ucscImage2"  style="display:none;"><a class="fancyboxExt fancybox.iframe" href="<%=ucscURL_snp%>" title="UCSC Genome Browser"><img src="<%= contextRoot+"tmpData/regionData/"+folderName+"/region.main.snp.png"%>"/></a></div>
            <%}%>
        </div><!-- end geneimage div -->
    
          </div><!--end Border Div -->
         </span><!-- ends center span -->


<script type="text/javascript">
	$(".waitTrx").hide();
	
	$('.ucscImage2').hide();
	$('#giProbe').show();
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
  
  
  $('#gvSelect').change(function(){
  		$('.ucscImage2').hide();
		var transVal=$(this).val();
		$('#'+transVal).show();
  });
</script>



<%}else{%>
    	<div class="error"><%=genURL.get(selectedGene)%><BR />The administrator has been notified of the problem and will investigate the error.  We apologize for any inconvenience.</div><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR />
<%}%>
    






