<%--
 *  Author: Cheryl Hornbaker
 *  Created: Sep, 2007
 *  Description:  The web page created by this file displays the image generated 
 *		by statistics.Clustering.R
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/analysisHeader.jsp"  %>

<%
	log.info("in clusterImages.jsp. user =  "+ user);
	
	String imageFileName = (String) request.getParameter("imageFile");
	String imagesPath = (String) request.getParameter("path");

	log.debug("imagesPath = "+imagesPath + " and fileName = "+imageFileName);

        String [] imageFileNames = new String[1];
        imageFileNames[0] = imageFileName; 

	mySessionHandler.createDatasetActivity("Viewed clusterImages for dataset", dbConn);
%>


<%@ include file="/web/common/externalWindowHeader.jsp"%>
<!-- 
<div class="scrollable">
OBJECT
<object data="<%=imagesPath%>Heatmap.svg" type="image/svg+xml"
        width="100%" height="100%"
	codebase="http://www.adobe.com/svg/viewer/install/" />
</object>
IFRAME
<iframe src="<%=imagesPath%>Heatmap.svg" width="100%" height="100%">
</iframe>
EMBED
<embed src="<%=imagesPath%>Heatmap.svg" width="100%" height="100%"
type="image/svg+xml"
pluginspage="http://www.adobe.com/svg/viewer/install/" />
</div>
-->

<%
String imagesPathFileName = request.getScheme()+"://"+request.getServerName()+request.getContextPath()+imagesPath+imageFileNames[0];
session.setAttribute("imagesPathFileName", imagesPathFileName);

session.setAttribute("analysisPath", analysisPath);
session.setAttribute("imageFileNames", imageFileNames[0]);
String filename = selectedDataset.getName() + " v"+selectedDatasetVersion.getVersion();
%>	


<div class="externalWindow_download">
<a href="<%=datasetsDir%>downloadClusterResults.jsp?filename=<%=filename%>">
<img  src="<%= imagesDir %>/icons/download_g.png"/><br/>
Download
</a>
</div>


<img src="<%=request.getContextPath()%><%=imagesPath%><%=imageFileNames[0]%>" />
<BR>
<%	if ((imageFileNames[0].equals("Heatmap.png") || 
		imageFileNames[0].equals("Dendogram.png")) && new File(analysisPath + "SampleTable.txt").exists()) {
		if (imageFileNames[0].equals("Dendogram.png")) {
			%><div class="title">Note:  The red boxes indicate the most distinct clusters based on the '# of clusters to report' option.<BR></div><%
		}
		%>
		<center>
		<div class="title">Key to Sample Names</div>
		<table name="items" class="list_base tablesorter">
			<thead>
			<tr class="col_title">
				<th>Sample ID</th>
				<th>Sample Name</th>
			</tr>
			</thead>
			<tbody>
			<%
			String [] fileContents = myFileHandler.getFileContents(new File(analysisPath + "SampleTable.txt"));
			for (int i=0; i<fileContents.length; i++) {
				String[] columns = fileContents[i].split("[\\s]");
				%><tr><td><%=columns[0]%></td><td><%=columns[1]%></td></tr><%
			}
			%>
			</tbody>
		</table>
		</center>
		<%
	}
	%><BR><%
	if ((imageFileNames[0].equals("Heatmap.png") || 
		imageFileNames[0].equals("Dendogram.png")) && new File(analysisPath + "GeneTable.txt").exists()) {
		if (imageFileNames[0].equals("Dendogram.png")) {
			%><div class="title">Note:  The red boxes indicate the most distinct clusters based on the '# of clusters to report' option.<BR></div><%
		}
		%>
		<center>
		<div class="title">Key to Probe Names</div>
		<table name="items" class="list_base tablesorter">
			<thead>
			<tr class="col_title">
				<th>Probe Number</th>
				<th>Probe Name</th>
			</tr>
			</thead>
			<tbody>
			<%
			String [] fileContents = myFileHandler.getFileContents(new File(analysisPath + "GeneTable.txt"));
			for (int i=0; i<fileContents.length; i++) {
				String[] columns = fileContents[i].split("[\\s]");
				if(columns.length>1){
					%><tr><td><%=columns[0]%></td><td><%=columns[1]%></td></tr><%
				}
			}
			%>
			</tbody>
		</table>
		</center>
		<%
	}
	if (imageFileNames[0].startsWith("Cluster") && new File(analysisPath + "SampleTable.txt").exists()) {
		%>
		<center>
		<div class="title">Key to Sample Names</div>
		<table name="items" class="list_base tablesorter">
			<thead>
			<tr class="col_title">
				<th>Sample ID</th>
				<th>Sample Name</th>
			</tr>
			</thead>
			<tbody>
			<%
			String [] fileContents = myFileHandler.getFileContents(new File(analysisPath + "SampleTable.txt"));
			for (int i=0; i<fileContents.length; i++) {
				String[] columns = fileContents[i].split("[\\s]");
				if(columns.length>1){
					%><tr><td><%=columns[0]%></td><td><%=columns[1]%></td></tr><%
				}
			}
			%>
			</tbody>
		</table>
		</center>
		<%
	}
	%><BR><%
	if (imageFileNames[0].startsWith("Cluster") && new File(analysisPath + "GeneTable.txt").exists()) {
		%>
		<center>
		<div class="title">Key to Probe Names</div>
		<table name="items" class="list_base tablesorter">
			<thead>
			<tr class="col_title">
				<th>Probe Number</th>
				<th>Probe Name</th>
			</tr>
			</thead>
			<tbody>
			<%
			String [] fileContents = myFileHandler.getFileContents(new File(analysisPath + "GeneTable.txt"));
			for (int i=0; i<fileContents.length; i++) {
				String[] columns = fileContents[i].split("[\\s]");
				if(columns.length>1){
				%><tr><td><%=columns[0]%></td><td><%=columns[1].replaceAll("\"", "")%></td></tr><%
				}

			}
			%>
			</tbody>
		</table>
		</center>
		<%
	}
%>
<BR>

<%@ include file="/web/common/externalWindowFooter.html" %>
	
