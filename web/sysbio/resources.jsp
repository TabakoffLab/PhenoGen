<%--
 *  Author: Cheryl Hornbaker
 *  Created: Dec, 2010
 *  Description:  The web page created by this file allows the user to 
 *		download files useful for doing systems biology
 *  Todo: 
 *  Modification Log:
 *      
--%>


<%@ include file="/web/sysbio/include/sysBioHeader.jsp"  %>
<%
	log.info("in resources.jsp. user =  "+ user);
	
	log.debug("action = "+action);
	extrasList.add("resources.js");
	mySessionHandler.createSessionActivity(session.getId(), "Looked at download systems biology resources page", dbConn);

	Resource[] myExpressionResources = myResource.getExpressionResources();
	Resource[] myMarkerResources = myResource.getMarkerResources();
	Resource[] myRNASeqResources = myResource.getRNASeqResources();
	Resource[] myGenotypeResources = myResource.getGenotypingResources();
	// Sort by organism first, dataset second (seems backwards!)
	myExpressionResources = myResource.sortResources(myResource.sortResources(myExpressionResources, "dataset"), "organism");
	ArrayList checkedList = new ArrayList();
	
%>

<%pageTitle="Download Resources";%>

<%@ include file="/web/common/header.jsp"  %>

<% if(!loggedIn||userLoggedIn.getUser_name().equals("anon")){%>
	<h2>Select the download icon(<img src="<%=imagesDir%>icons/download_g.png" />) to download data from any of the datasets below.  For some data types multiple options may be available. For these types, a window displays that allows you to choose specific files.</h2>
	
	
	
<%}%>


	<form	method="post" 
		action="resources.jsp" 
		enctype="application/x-www-form-urlencoded"
		name="resources">
		<BR>
		<div class="brClear"></div>

		<div class="title"> Expression Data Files</div>
		      <table id="expressionFiles" name="items" class="list_base tablesorter" cellpadding="0" cellspacing="3" width="98%">
            		<thead>
                               <tr class="col_title">
					<th>Organism</th>
					<th>Dataset</th>
					<th>Tissue</th>
					<th>Array</th>
					<th>Expression Values</th>
					<th>eQTL</th>
					<th>Heritability</th>
					<!-- <th>Details</th> -->
				</tr>
			</thead>
			<tbody>
			<% for (Resource resource: myExpressionResources) { 
			%> 
				<tr id="<%=resource.getID()%>">  
				<td> <%=resource.getOrganism()%> </td>
				<td> <%=resource.getDataset().getName()%></td> 
				<td> <%=resource.getTissue()%></td>
				<td> <%=resource.getArrayName()%></td>
                <% if(resource.getDataset().getVisible()){%>
				<% if (resource.getExpressionDataFiles() != null && resource.getExpressionDataFiles().length > 0) { %>
                                	<td class="actionIcons">
						<div class="linkedImg download" type="expression"><div>
					</td>
				<% } else { %>
                                	<td>&nbsp;</td>
				<% } %>
				<% if (resource.getEQTLDataFiles() != null && resource.getEQTLDataFiles().length > 0) { %>
					<td class="actionIcons">
						<div class="linkedImg download" type="eQTL"><div>
					</td>
				<% } else { %>
                                	<td>&nbsp;</td>
				<% } %>
				<% if (resource.getHeritabilityDataFiles() != null && resource.getHeritabilityDataFiles().length > 0) { %>
					<td class="actionIcons">
						<div class="linkedImg download" type="heritability"><div>
					</td>
				<% } else { %>
                                	<td>&nbsp;</td>
				<% } %>
                <%}else{%>
                           <td colspan="3"><%= resource.getDataset().getVisibleNote() %></td>    
				<% } %>	
                        </tr>
			<% } %>
			</tbody>
		</table> 
		<BR>
		<BR>
		<div class="title"> Genomic Marker Data Files</div>
		      <table id="markerFiles" class="list_base tablesorter" name="items" cellpadding="0" cellspacing="3">
            		<thead>
                               <tr class="col_title">
					<th>Organism</th>
                    <th>Panel</th>
					<th>Source</th>
					<th>Markers</th>
					<th>eQTL</th>
				</tr>
			</thead>
			<tbody>
			<% for (Resource resource: myMarkerResources) { %> 
				<tr id="<%=resource.getID()%>">  
				<td> <%=resource.getOrganism()%> </td>
                <td> <%=resource.getPanelString()%> </td>
				<td> <%=resource.getSource()%></td> 
				<% if (resource.getMarkerDataFiles() != null && resource.getMarkerDataFiles().length > 0) { %>
					<td class="actionIcons">
						<div class="linkedImg download" type="marker"><div>
					</td>
				<% } else { %>
                                	<td>&nbsp;</td>
				<% } %>
				<% if (resource.getEQTLDataFiles() != null && resource.getEQTLDataFiles().length > 0) { %>
					<td class="actionIcons">
						<div class="linkedImg download" type="eQTL"><div>
					</td>
				<% } else { %>
                                	<td>&nbsp;</td>
				<% } %>
				</tr> 
			<% } %>
			</tbody>
		</table> 
        
        <BR>
		<BR>
		<div class="title"> RNA Sequencing BED/SAM Data Files</div>
		      <table id="rnaFiles" class="list_base tablesorter" name="items" cellpadding="0" cellspacing="3">
            		<thead>
                               <tr class="col_title">
					<th>Organism</th>
					<th>Strain</th>
                    <th>Tissue</th>
                    <th>Seq. Tech.</th>
                    <th>RNA Type</th>
                    <th>Read Type</th>
					<th>.BED/.SAM Files</th>
				</tr>
			</thead>
			<tbody>
			<% for (Resource resource: myRNASeqResources) { %> 
				<tr id="<%=resource.getID()%>">  
				<td> <%=resource.getOrganism()%> </td>
				<td> <%=resource.getSource()%></td>
                <td> <%=resource.getTissue()%></td>
                <td> <%=resource.getTechType()%></td>
                <td> <%=resource.getRNAType()%></td>
                <td> <%=resource.getReadType()%></td>     
				<% if (resource.getSAMDataFiles() != null && resource.getSAMDataFiles().length > 0) { %>
					<td class="actionIcons">
						<div class="linkedImg download" type="rnaseq"><div>
					</td>
				<% } else { %>
                                	<td>&nbsp;</td>
				<% } %>
				</tr> 
			<% } %>
			</tbody>
		</table>
        
        
        <BR>
		<BR>
		<div class="title">Human Genotype Data Files</div>
		      <table id="genotypingFiles" class="list_base tablesorter" name="items" cellpadding="0" cellspacing="3" width="98%">
            	<thead>
                    <tr class="col_title">
					<th >Organism</th>
					<th >Population</th>
                    <th >Ancestry</th>
                    <th >Array Type</th>
					<th >.CEL Files</th>
					</tr>
				</thead>
			<tbody>
			<% for (Resource resource: myGenotypeResources) { %> 
				<tr id="<%=resource.getID()%>">  
				<td> <%=resource.getOrganism()%> </td>
				<td> <%=resource.getPopulation()%></td>
                <td> <%=resource.getAncestry()%></td>
                <td> <%=resource.getTechType()%></td>    
				<% if (resource.getGenotypeDataFiles() != null && resource.getGenotypeDataFiles().length > 0) { %>
					<td class="actionIcons">
						<div class="linkedImg download" type="genotype"><div>
					</td>
				<% } else { %>
                                	<td>&nbsp;</td>
				<% } %>
				</tr> 
			<% } %>
			</tbody>
		</table>
        
        
        
	</form>

	<div class="downloadItem"></div>
<%@ include file="/web/common/footer.jsp"  %>
<script type="text/javascript">
	$(document).ready(function() {
		setupPage();
        	setTimeout("setupMain()", 100);
	});
</script>

