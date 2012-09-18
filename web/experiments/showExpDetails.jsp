<%--
 *  Author: Cheryl Hornbaker
 *  Created: May, 2010
 *  Description:  This file formats details of an experiment
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/experiments/include/experimentHeader.jsp"  %>
<%
	log.info("in showExpDetails");

	%>
	<%@include file="/web/experiments/include/selectExperiment.jsp"%>
	<%
	
	extrasList.add("arrayTabs.js");
	extrasList.add("showExpDetails.js");
	
	//extrasList.add("selectArrays.js");
	

	edu.ucdenver.ccp.PhenoGen.data.Array[] myArrays = null;
	Experiment thisExperiment = new Experiment().getExperiment(selectedExperiment.getExp_id(), dbConn);
	Texprtyp[] myTypes = new Texprtyp().getAllTexprtypForExp(selectedExperiment.getExp_id(), dbConn);
	Texpfctr[] myFactors = new Texpfctr().getAllTexpfctrForExp(selectedExperiment.getExp_id(), dbConn);
log.debug("before protocols");
	Protocol[] myProtocols = thisExperiment.getUsedProtocols(dbConn);
log.debug("after protocols");

 	myArrays = myArray.getArraysForSubmission(selectedExperiment.getSubid(), dbConn);
	mySessionHandler.createExperimentActivity("Looked at experiment details", dbConn); 

%>	

<center>
	<div> 
		<p style="font-size:12px; margin:10px 0px;">
		(Click the <img src="<%=imagesDir%>icons/add.png" alt="expand"> and <img src="<%=imagesDir%>icons/min.png" alt="contract"> 
		icons next to the section titles to open and close the section details) 
		</p>
		<BR>
	</div>
		<div class="title"> 
			<span class="trigger less" name="experimentStuff">
			Experiment Details 
			</span>
		</div>
		<div id="experimentStuff">
      			<table id="experimentStuff" class="list_base" cellpadding="0" cellspacing="3" style="margin:0px 10px">
			<tr><td><b>Experiment Name:</b></td><td> <%=thisExperiment.getExpName()%></td></tr>
			<tr><td><b>Description:</b></td><td> <%=thisExperiment.getExp_description()%></td></tr>
			<tr><td><b># Arrays:</b></td><td> <%=thisExperiment.getNum_arrays()%></td></tr>
			<tr><td><b>Date Created:</b></td><td><%=thisExperiment.getExp_create_date_as_string()%></td></tr>
			</table>
		</div>
		<div class="brClear"></div>

		<div class="title"> 
			<span class="trigger less" name="types">
			Experiment Design Types	
			</span>
		</div>
		<div id="types">
      			<table class="list_base tablesorter" id="typeList" cellpadding="0" cellspacing="3" >
				<thead>
				<tr class="col_title">
					<th> Design Type </th>
				</tr>
				</thead>
			<tbody>
				<% for (int i=0; i<myTypes.length; i++) { %>
				<tr>
					<td><%=myTypes[i].getTypeName()%></td>
				</tr>
			<% } %>
			</tbody>
		</table>
		</div>
		<div class="brClear"></div>

		<div class="title"> 
			<span class="trigger less" name="types">
			Experimental Factors
			</span>
		</div>
		<div id="types">
      			<table class="list_base tablesorter" id="typeList" cellpadding="0" cellspacing="3" >
				<thead>
				<tr class="col_title">
					<th> Factor </th>
				</tr>
				</thead>
			<tbody>
				<% for (int i=0; i<myFactors.length; i++) { %>
				<tr>
					<td><%=myFactors[i].getFactorName()%></td>
				</tr>
			<% } %>
			</tbody>
		</table>
		</div>

		<div class="title"> 
			<span class="trigger less" name="types">
			Protocols Used
			</span>
		</div>
		<div id="types">
      			<table class="list_base tablesorter" id="protocolList" cellpadding="0" cellspacing="3" >
				<thead>
				<tr class="col_title">
					<th> Protocol Type </th>
					<th> Protocol Name </th>
				</tr>
				</thead>
			<tbody>
				<% for (int i=0; i<myProtocols.length; i++) { %>
				<tr>
					<td><%=myProtocols[i].getTypeName()%></td>
					<td><%=myProtocols[i].getProtocol_name()%></td>
				</tr>
				<% } %>
			</tbody>
		</table>
		</div>
		<div class="brClear"></div>

	<% if (myArrays != null && myArrays.length > 0) { %>
		<div class="title"> 
			<span class="trigger" name="arrayStuff">
			Arrays in Experiment	
			</span>
		</div>
		<div id="arrayStuff" style="display:none">
      		<table class="list_base tablesorter" id="arrayList" cellpadding="0" cellspacing="3" >
			<thead>
			<tr class="col_title">
				<th> Array Name</th>
				<th> File Name</th>
                <th> Details</th>
			</tr>
			</thead>
			<tbody>
			<% for (int i=0; i<myArrays.length; i++) { %>
				<tr id="<%=myArrays[i].getHybrid_id()%>">
					<td><b><%=myArrays[i].getHybrid_name()%></b></td>
					<td><%=myArrays[i].getFile_name()%></td>
                    <td class="details">View</td>
				</tr>
			<% } %>
			</tbody>
		</table>
		</div>
		<div class="brClear"></div>
	<% } %>
	</center>
	<script type="text/javascript">
        	$(document).ready(function(){
				setupPage();
				setupExpandCollapse();
        	})
	</script>

	<div class="closeWindow">Close</div>

