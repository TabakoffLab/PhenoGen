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
				null)))))));

	/*log.debug("dataFiles = "); myDebugger.print(dataFiles);
	
        if ((action != null) && action.equals("Download")) {

        	if (request.getParameterValues("fileList") != null) {
			//
			// checkedList will contain the values of the check boxes that were
			// actually selected by the user
			//
		
            		checkedList.addAll(Arrays.asList(request.getParameterValues("fileList")));

                	if (checkedList != null && checkedList.size() > 0){
							log.debug("setting up AsyncResourceDownload:type:"+type);
							if(!type.equals("rnaseq")||!type.equals("marker")){
                        		Thread thread = new Thread(new AsyncResourceDownload(request, thisResource, type,  checkedList));
                        		thread.start();
								log.debug("AsyncResourceDownload started");
								session.setAttribute("successMsg", "DST-001");
                        		response.sendRedirect(commonDir + "successMsg.jsp");
							}else{
								//ResourceDownload rd=new ResourceDownload(request, thisResource, type,  checkedList);
								//rd.download();
								//session.setAttribute("successMsg", "DST-001");
                        		//response.sendRedirect(commonDir + "successMsg.jsp");
								String url="http://"+request.getServerName()+request.getContextPath()+checkedList.get(0);
								String redirurl="http://"+request.getServerName()+request.getContextPath()+"/directDownloads.jsp?url="+url;
								response.sendRedirect(redirurl);
							}
                        	
                        	// This is required to avoid the getOutputStream() has already been called for this response error
                        	// Still necessary?
                        	//out.clear();
                        	//out = pageContext.pushBody(); 
		
				mySessionHandler.createActivity("Downloaded files starting with this one: " + checkedList.get(0), dbConn);
			}
        	}
	}*/
%>

	<BR>
	<form	method="post" 
		action="downloadFiles.jsp" 
		enctype="application/x-www-form-urlencoded" 
		name="downloadFiles"> 
		<div class="leftTitle">Files That Can Be Downloaded For <%=type%>:</div>
		<table name="items" class="list_base" cellpadding="0" cellspacing="3" width="90%">
			<thead>
			<tr class="col_title">
        			<th class="noSort"></th>
				<th class="noSort">File Type</th>
                <th class="noSort">File Name</th>
			</tr>
			</thead>
			<tbody>
				<% for (DataFile dataFile : dataFiles) { %>
				<tr>  
					<td> 
					<center>
						<a href="downloadLink.jsp?url=<%=dataFile.getFileName()%>" target="_blank" > <img src="../images/icons/download_g.png" /></a>
					</center>
					</td>  
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
