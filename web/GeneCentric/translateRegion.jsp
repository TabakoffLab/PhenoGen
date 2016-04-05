<%--
 *  Author: Spencer Mahaffey
 *  Created: November, 2012
 *  Description:  This file allows the user to translate a region from one species to another.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/common/anon_session_vars.jsp"  %>
<%@ include file="/web/common/javascriptLinks.jsp"  %>



<%
	String selectedRatio="0.1";
	String selectedPerc="0.1";
	String humanRegion="";
	String selectedSpecies="Mm";
	if(request.getParameter("region")!=null){
		humanRegion=request.getParameter("region");
	}
	if(request.getParameter("species")!=null){
		selectedSpecies=request.getParameter("species");
	}
%>

Fill in the form below to translate a Human/Mouse/Rat region to regions on Mouse/Rat chromosomes.<BR />
<div style=" border-color:#000000; border-style:solid; border-width:1px;">
<form method="post" 
		enctype="application/x-www-form-urlencoded"
		name="translationForm" id="translationForm">
    	<BR />
        <label>Region to translate:
  		<input type="text" name="transGeneTxt" id="transGeneTxt" size="35" value="<%=humanRegion%>">
  		</label><BR /><BR />
        
        <label>Source Species:
  			<select name="transSourceSpeciesCB" id="transSourceSpeciesCB">
           		<option value="hg19"  selected>Human (Hg19)</option> 
  				<option value="mm9">Mouse (Mm9)</option>
                <option value="mm10">Mouse (Mm10)</option>
   				<option value="rn4">Rat (Rn4)</option>
   				<option value="rn5">Rat (Rn5)</option>
  			</select>
  		</label>
        ->
        <label>Target Species:
  <select name="transSpeciesCB" id="transSpeciesCB">
  	<option value="Mm10"  <%if(selectedSpecies.equals("Mm")){%>selected<%}%>>Mouse (Mm10)</option>
    <option value="Rn5"  <%if(selectedSpecies.equals("Rn")){%>selected<%}%>>Rat (Rn5)</option>
  </select>
  </label>
        <BR /><BR />
        
        <label>Minimum ratio of bases that must map to target species region:
  <select name="transRatioCB" id="transRatioCB">
  	<option value="0.99" <%if(selectedRatio.equals("0.99")){%>selected<%}%>>>0.99</option>
    <option value="0.95" <%if(selectedRatio.equals("0.95")){%>selected<%}%>>>0.95</option>
    <option value="0.9" <%if(selectedRatio.equals("0.9")){%>selected<%}%>>>0.9</option>
    <option value="0.8" <%if(selectedRatio.equals("0.8")){%>selected<%}%>>>0.8</option>
    <option value="0.5" <%if(selectedRatio.equals("0.5")){%>selected<%}%>>>0.5</option>
    <option value="0.4" <%if(selectedRatio.equals("0.4")){%>selected<%}%>>>0.4</option>
    <option value="0.3" <%if(selectedRatio.equals("0.3")){%>selected<%}%>>>0.3</option>
    <option value="0.2" <%if(selectedRatio.equals("0.2")){%>selected<%}%>>>0.2</option>
    <option value="0.1" <%if(selectedRatio.equals("0.1")){%>selected<%}%>>>0.1</option>
    <option value="0.05" <%if(selectedRatio.equals("0.05")){%>selected<%}%>>>0.05</option>
  </select>
  </label>
  <span title="This specifies the portion of bases that must map to the target region. For large regions you may have to keep this low to get any results.  For small regions you may want to increase this so that you will get a close match if there is one."><img src="<%=imagesDir%>icons/info.gif"></span>
  
  
  <BR /><BR />
  
  <label>Min length of the target species region(% of source region length):
  <select name="transLengthCB" id="transLengthCB">
    <option value="75" <%if(selectedPerc.equals("70")){%>selected<%}%>>> 75%</option>
    <option value="50" <%if(selectedPerc.equals("50")){%>selected<%}%>>> 50%</option>
    <option value="20" <%if(selectedPerc.equals("20")){%>selected<%}%>>> 20%</option>
    <option value="10" <%if(selectedPerc.equals("10")){%>selected<%}%>>> 10%</option>
    <option value="5" <%if(selectedPerc.equals("5")){%>selected<%}%>>> 5%</option>
    <option value="1" <%if(selectedPerc.equals("1")){%>selected<%}%>>> 1%</option>
    <option value="0.1" <%if(selectedPerc.equals("0.1")){%>selected<%}%>>> 0.1%</option>
    <option value="0" <%if(selectedPerc.equals("0")){%>selected<%}%>>None</option>
  </select>
  </label>
  <span title="This filters the results based on length of the target sequence and qeury sequence matched."><img src="<%=imagesDir%>icons/info.gif"></span>

  <br /><BR />
 <div style="text-align:center; width:100%;"> <input type="button" name="translateBTN" id="translateBTN" value="Translate Region" onClick="runTranslation()">
 <span id="clearResults" style="display:none;"><input type="button" name="clearBTN" id="clearBTN" value="Clear Previous Results" onClick="clearResults()"><BR />
 	<input name="chkbox" type="checkbox" id="prevResultsCBX" value="prevResultsCBX" /> Always clear previous results
 </span>
 <BR />
 
 </div>
 

</form>
</div>
<div style="text-align:center; width:100%;"><div id="waitTranslate"  style="background:#FFFFFF; display:none;"><img class="helpImageTranslate"src="<%=imagesDir%>wait.gif" alt="Working..." /><BR />Please wait, Running Translation...</div></div>
<div id="translateResults" style="height:400px; overflow:auto;">
	
</div>

	<div class="closeWindow">Close</div>
    
    
<!--<div id="HelpTranslate1Content" class="inpageHelpContentTranslate" title="<center>Help</center>"><div class="help-content">
<H3>Minimum Ratio of bases to map to target region</H3>
This specifies the portion of bases that must map to the target region. <BR /> 
-For large regions you may have to keep this low to get any results.  <BR />
-For small regions you may want to increase this so that you will get a close match if there is one.

</div></div>
<div id="HelpTranslate2Content" class="inpageHelpContentTranslate" title="<center>Help</center>"><div class="help-content">
<H3>Minimum Length(target/source)</H3>
This filters the results based on length of the target sequence and qeury sequence matched.  Results   
</div></div>-->

<script type="text/javascript">
	$('.inpageHelpContentTranslate').hide();
	
	$('.inpageHelpContentTranslate').dialog({ 
  		autoOpen: false,
		dialogClass: "helpDialog",
		width: 400,
		maxHeight: 500,
		zIndex: 99999
	});

	$('.helpImageTranslate').click( function(){
		var id=$(this).attr('id');
		$('#'+id+'Content').dialog( "option", "position",{ my: "right top", at: "left bottom", of: $(this) });
		$('#'+id+'Content').dialog("open").css({'font-size':12});
	});
	
	 $('#transSourceSpeciesCB').change(function(){
	 		var source=$('#transSourceSpeciesCB').val();
			var dest=$('#transSpeciesCB').val().toLowerCase();
			if(source==dest){
				alert("Please change the destination or source so they are not equal.");
			}else if((source=='rn4' && dest=='mm10')){
				alert("This conversion is not supported.  Sorry for any inconvenience.  Please change the destination or source.");
			}
	 });
	 $('#transSpeciesCB').change(function(){
	 		var source=$('#transSourceSpeciesCB').val();
			var dest=$('#transSpeciesCB').val().toLowerCase();
			if(source==dest){
				alert("Please change the destination or source so they are not equal.");
			}else if((source=='rn4' && dest=='mm10')){
				alert("This conversion is not supported.  Sorry for any inconvenience.  Please change the destination or source.");
			}
	 });

		function clearResults(){
			$('#translateResults').html("");
			$('#clearResults').hide();
		}
		function runTranslation(){
			
			$('#clearResults').show();
			var regionTxt=$('#transGeneTxt').val();
			var minLen=$('#transLengthCB').val();
			var minRatio=$('#transRatioCB').val();
			var species=$('#transSpeciesCB').val();
			var srcSpecies=$('#transSourceSpeciesCB').val();
			if(species.toLowerCase()==srcSpecies.toLowerCase()){
				alert("Please change the destination or source species/genome version so they are not equal.");
			}else if((srcSpecies.toLowerCase()=='rn4' && species.toLowerCase()=='mm10')){
				alert("Rn4 -> Mm10 is not supported.  Please use Rn5 -> Mm10.  We are sorry for any inconvenience.");
			}else{
                            $('#waitTranslate').show();
                            setTimeout(function(){
                            $.get(	contextPath + "/web/GeneCentric/runTranslation.jsp", 
				{region: regionTxt, minLen: minLen, minRatio: minRatio, targetSpecies: species, sourceSpecies: srcSpecies},
				function(data){ 
									var prevData="<BR><BR>"+$('#translateResults').html();
									if($('#prevResultsCBX').is(":checked")){
										$('#translateResults').html(data);
									}else{
										$('#translateResults').html(data+prevData);
									}
									try{
                                                                            $("table.tablesorter").tablesorter({ widgets: ['zebra'],sortList: [[4,-1]]});
                                                                        }catch(err){
                                                                            
                                                                        }
									$('.translateTable').find("tr.col_title").find("th").slice(4,5).addClass("headerSortDown");
									
									
									var tableRows=$('.translateTable').find("tr").not(".title, .col_title");
									stripeAndHoverTable(tableRows);
									tableRows.each(function(){
										//---> click functionality
										$(this).find("td").slice(0,4).click( function() {
											//tableRows.find("td").removeClass('selected');
											//$(this).parent("tr").find("td").addClass('selected');
											var id = $(this).parent("tr").attr("id");
											var params=id.split(":::");
											var region=params[0];
											var species = params[1];
											$('#geneTxt').val(region);
											$('#speciesCB').val(species);
											translateDialog.dialog("close");
											$("#getTrxBTN").eq(0).trigger('click');
											return false;
										});
								
										
									});
					}
			);
                        },100);
                    }
			
			
		}
</script>