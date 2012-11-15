<%--
 *  Author: Spencer Mahaffey
 *  Created: November, 2012
 *  Description:  This file allows the user to translate a region from one species to another.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/common/session_vars.jsp"  %>


<%
	String selectedRatio="0.1";
	String selectedPerc="50";
%>


<form method="post" 
		enctype="application/x-www-form-urlencoded"
		name="translationForm" id="translationForm">
    	<label>Human Region to translate:
  		<input type="text" name="transGeneTxt" id="transGeneTxt" size="35" value="">
  		</label><BR />
        <label>Min Ratio in the target species region:
  <select name="transRatioCB" id="transRatioCB">
  	<option value="0.99" <%if(selectedRatio.equals("0.99")){%>selected<%}%>>>0.99</option>
    <option value="0.95" <%if(selectedRatio.equals("0.95")){%>selected<%}%>>>0.95</option>
    <option value="0.90" <%if(selectedRatio.equals("0.90")){%>selected<%}%>>>0.9</option>
    <option value="0.8" <%if(selectedRatio.equals("0.80")){%>selected<%}%>>>0.8</option>
    <option value="0.75" <%if(selectedRatio.equals("0.75")){%>selected<%}%>>>0.75</option>
    <option value="0.6" <%if(selectedRatio.equals("0.6")){%>selected<%}%>>>0.6</option>
    <option value="0.5" <%if(selectedRatio.equals("0.5")){%>selected<%}%>>>0.5</option>
    <option value="0.4" <%if(selectedRatio.equals("0.4")){%>selected<%}%>>>0.4</option>
    <option value="0.3" <%if(selectedRatio.equals("0.3")){%>selected<%}%>>>0.3</option>
    <option value="0.2" <%if(selectedRatio.equals("0.2")){%>selected<%}%>>>0.2</option>
    <option value="0.1" <%if(selectedRatio.equals("0.1")){%>selected<%}%>>>0.1</option>
  </select>
  </label><BR />
  <label>Min length of the target species region(% of source region length):
  <select name="transLengthCB" id="transLengthCB">
    <option value="75" <%if(selectedPerc.equals("70")){%>selected<%}%>>> 75%</option>
    <option value="50" <%if(selectedPerc.equals("50")){%>selected<%}%>>> 50%</option>
    <option value="20" <%if(selectedPerc.equals("20")){%>selected<%}%>>> 20%</option>
    <option value="10" <%if(selectedPerc.equals("10")){%>selected<%}%>>> 10%</option>
    <option value="5" <%if(selectedPerc.equals("5")){%>selected<%}%>>> 5%</option>
    <option value="1" <%if(selectedPerc.equals("1")){%>selected<%}%>>> 1%</option>
    <option value="0.1" <%if(selectedPerc.equals("0.1")){%>selected<%}%>>> 0.1%</option>
  </select>
  </label><br />
       
  <label>Target Species:
  <select name="transSpeciesCB" id="transSpeciesCB">
  	<option value="Mm" selected>Mus musculus</option>
    <option value="Rn" >Rattus norvegicus</option>
  </select>
  </label><BR />
 <div style="text-align:center; width:100%;"> <input type="button" name="refreshBTN" id="refreshBTN" value="Translate Region" onClick="runTranslation()"><BR />
 <div id="waitTranslate"  style="background:#FFFFFF; display:none;"><img src="<%=imagesDir%>wait.gif" alt="Working..." /><BR />Please wait, Running Translation...</div>
 </div>
 

</form>
<div id="translateResults">
	
</div>

	<div class="closeWindow">Close</div>

<script type="text/javascript">
		
		function runTranslation(){
			$('#waitTranslate').show();
			var regionTxt=$('#transGeneTxt').val();
			var minLen=$('#transLengthCB').val();
			var minRatio=$('#transRatioCB').val();
			var species=$('#transSpeciesCB').val();
			
			$.get(	contextPath + "/web/GeneCentric/runTranslation.jsp", 
				{region: regionTxt, minLen: minLen, minRatio: minRatio, targetSpecies: species},
				function(data){ $('#translateResults').html(data);}
			);
			
			
		}
</script>