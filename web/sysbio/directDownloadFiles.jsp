<%--
 *  Author: Cheryl Hornbaker
 *  Created: Jan, 2011
 *  Description:  The web page created by this file allows the user to download resource files.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/sysbio/include/sysBioHeader.jsp"  %>

<%
	int resource = (request.getParameter("resource") == null ? -99 : Integer.parseInt((String) request.getParameter("resource")));
	String type = (request.getParameter("type") == null ? "" : (String) request.getParameter("type"));

	log.info("in directDownloadFiles.jsp. user = " + user + ", resource = "+resource +", type = :"+type+":");

	log.debug("action = " + action);

    	ArrayList<String> checkedList = new ArrayList<String>();
	Resource[] allResources = myResource.getAllResources();
	Resource thisResource = myResource.getResourceFromMyResources(allResources, resource);
	
	log.debug("thisResource="+thisResource.getID()+" "+thisResource.getOrganism()+" "+thisResource.getSource());

	DataFile[] dataFiles = (type.equals("eQTL") ? thisResource.getEQTLDataFiles() :
				(type.equals("expression") ? thisResource.getExpressionDataFiles() : 
				(type.equals("heritability") ? thisResource.getHeritabilityDataFiles() : 
				(type.equals("marker") ? thisResource.getMarkerDataFiles() : 
				(type.equals("rnaseq") ? thisResource.getSAMDataFiles() :
				(type.equals("genotype") ? thisResource.getGenotypeDataFiles() :
				(type.equals("mask") ? thisResource.getMaskDataFiles() :
                                (type.equals("pub") ? thisResource.getPublicationFiles() :
                                (type.equals("gtf") ? thisResource.getSAMDataFiles() :
				null)))))))));
        log.debug("array size="+dataFiles.length);
%>

	<BR>
	<form	method="post" 
		action="downloadFiles.jsp" 
		enctype="application/x-www-form-urlencoded" 
		name="downloadFiles"> 
            <% if(type.equals("pub")){%>
                <div class="leftTitle">Files That Can Be Downloaded For <%=thisResource.getDownloadHeader()%>:</div>
            <%}else{%>
                <div class="leftTitle">Files That Can Be Downloaded For <%=type%>:</div>
            <%}%>
		
		<table name="items" class="list_base" cellpadding="0" cellspacing="3" width="90%">
			<thead>
			<tr class="col_title">
        			<th class="noSort"></th>
                                <%if(type.equals("rnaseq") || type.equals("expression")|| type.equals("mask")
                                        || type.equals("heritability")|| type.equals("gtf")){%>
                                    <th class="noSort">Genome Version</th>
                                <%}%>
				<th class="noSort">File Type</th>
                                <th class="noSort">File Name</th>
			</tr>
			</thead>
			<tbody>
				<% for (DataFile dataFile : dataFiles) { 
                                    log.debug("inside For loop:"+dataFile.getFileName());
                                    %>
				<tr>  
					<td> 
					<center>
						<a href="downloadLink.jsp?url=<%=dataFile.getFileName()%>" target="_blank" > <img src="../images/icons/download_g.png" /></a>
					</center>
					</td>  
                                        <%if(type.equals("rnaseq") || type.equals("expression")|| type.equals("mask")
                                                 || type.equals("heritability") || type.equals("gtf") ){%>
                                        <TD><%=dataFile.getGenome()%></TD>
                                        <%}%>
					<td><%=dataFile.getType()%></td>
                    <td><%=dataFile.getFileName().substring(dataFile.getFileName().lastIndexOf("/")+1)%></td>
					</tr> 
				<% } %>
			</tbody>
		</table>

		<BR>
        <% if(type.equals("expression")){ %>
		<center>*For the Affymetrix Exon Arrays, expression levels are estimated on the exon level (i.e., probe set) or gene level (i.e. transcript cluster) and inclusion in the data set is determined based on confidence in annotation (core,extended, and full). For more details, see the Affymetrix GeneChip ® Exon Array whitepaper, Exon Probeset Annotations and Transcript Cluster Groupings (2005).</center>
        <% } %>
		<input type="hidden" name="resource" value=<%=resource%> />
		<input type="hidden" name="type" value=<%=type%> />
	</form>


<script>
	$(document).ready(function() {
		$("input[name='action']").click(
			function() {
				downloadModal.dialog("close");	
		});
	});
</script>
