<%--
 *  Author: Cheryl Hornbaker
 *  Created: April, 2007
 *  Description:  This file formats the results from running Step 3 of the quality control process. 
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<% if (selectedDataset.getDatasetVersions().length == 0) { %>
	<div class="tab-intro">
	<p>If desired, you may delete one or more of the following arrays:</p>
	</div>
<% } %>
	<div class="brClear"></div>

<% 	
	if (selectedDataset.getPlatform().equals(selectedDataset.AFFYMETRIX_PLATFORM)) { 
		String maStatsFile = selectedDataset.getImagesDir() + "MAstats.txt";
		log.debug("MAStats file = "+maStatsFile);
		String [] fileContents = null;
		if ((new File(maStatsFile)).exists()) {
			fileContents = myFileHandler.getFileContents(new File(maStatsFile));
			%>
			<div class="title"> MA Plot Statistics</div>
			<table id="maStats" class="list_base" name="items">
				<thead>
				<tr class="col_title">
                			<% if (selectedDataset.getDatasetVersions().length == 0) { %>
						<th>Delete</th>
                			<% } %>
					<th> Array Name</th>
					<th>Median</th>
					<th>IQR</th>
				</tr>
				</thead>
				<tbody> 
				<%
				for (int i=0; i<myArrays.length; i++) { 
					int arrayID = myArrays[i].getHybrid_id();
					String hybridName = myArrays[i].getHybrid_name().replaceAll("[\\s]", "_");
					%> 
					<tr id="<%=myArrays[i].getHybrid_id()%>">
						<% if (selectedDataset.getDatasetVersions().length == 0) { %>
							<td class="actionIcons">
								<div class="linkedImg delete"></div>
							</td>
						<% } %>
						<td class="details cursorPointer"><%=myArrays[i].getHybrid_name()%></td>
						<% 
						if (selectedDataset.getQc_complete().equals("Y") || 
							selectedDataset.getQc_complete().equals("R") || 
							selectedDataset.getQc_complete().equals("N") || 
							selectedDataset.getQc_complete().equals("I")) { 

							if ((new File(maStatsFile)).exists()) {
								// 
								// The first line contains column headings, so start on the 2nd line
								// 
								for (int j=1; j<fileContents.length; j++) {
									String [] columns = fileContents[j].split("\t");
									//log.debug("columns[0] = "+columns[0] + ", and file = "+hybridName);
									if (columns[0].equals(hybridName)) {
										%>
										<td><%=columns[1]%></td>
										<td><%=columns[2]%></td>
										<%
										break;
									}
								}
							} else {
								%>
								<td>MA Stats not Available</td>
								<td>MA Stats not Available</td>
								<%
							}
						} 
					%> </tr> <%
				}
			%> 
			</tbody> 
			</table> 
			<BR>
			<%
			for (int j=0; j<myArrays.length; j++) { 
				imageHeight = "200px";
				imageWidth = "200px";
				String array_name = myArrays[j].getHybrid_name().replaceAll("[\\s]", "_");
        			imageFileNames = new String[]{array_name + "_MAplot.png"};
        			%> <%@include file="/web/datasets/include/displayImages.jsp"%> <%
			}
		}
	} else if (selectedDataset.getPlatform().equals(selectedDataset.CODELINK_PLATFORM)) {
		String fileName = selectedDataset.getImagesDir() + "CodeLink.QC.table.txt";
		if (new File(fileName).exists()) {
			String[] qcResults = myFileHandler.getFileContents(new File(fileName), "withSpaces");

			%> 
			<div class="tab-intro">
			<p>Key: &nbsp; G=Good, L=Near background signal, C=Contamination, CL=Contamination & Near background signal, I=Irregular shape, M=Masked, S=Saturated, IS=Irregular shape & Saturated, CI=Contamination & Irregular shape</p>
			</div>
			<div class="brClear"></div>
			<table id="codeLink" class="list_base" name="items">
				<thead>
				<tr class="col_title">
					<% if (selectedDataset.getDatasetVersions().length == 0) { %>
						<th>&nbsp;</th>
					<% } %>
					<th colspan=1 class="noSort"> &nbsp;
					<th colspan=3 class="noSort"> Background Values
					<th colspan=9 class="noSort"> Number of Probes
				</tr>
				<tr class="col_title">
					<% if (selectedDataset.getDatasetVersions().length == 0) { %>
						<th class="noSort">Delete</th>
					<% } %>
					<th> Array Name
					<th> Mean
					<th> Max
					<th> Min
					<th> G
					<th> L
					<th> C
					<th> CL
					<th> I
					<th> M
					<th> S
					<th> IS
					<th> CI
				</tr>
				</thead>
				<tbody>

			<%

			//
			// The first line of this file is the column headers, so start reading from the second line
			//
			for (int i=1; i<qcResults.length; i++) {
				int arrayIdx = i - 1;
				String hybridName = myArrays[arrayIdx].getHybrid_name().replaceAll("[\\s]", "_");

				%> 
				<tr id="<%=myArrays[arrayIdx].getHybrid_id()%>">
					<% if (selectedDataset.getDatasetVersions().length == 0) { %>
						<td class="actionIcons">
							<div class="linkedImg delete"></div>
						</td>
					<% } %>
					<td class="details cursorPointer"><%=hybridName%></td>
					<% 
					String[] lineElements = qcResults[i].split("\t");
                			for (int j=0; j<lineElements.length; j++) {
                                		%> <td class=right> <%=new DecimalFormat("###").format(Double.parseDouble(lineElements[j]))%> </td> <%
                			}
					%>
				</tr> <%
			}
		} else {
			%><BR>Information Not Available For This Dataset<BR><%
		}
		%>
		</tbody>
		</table>
		<BR>
<%
	}
%>
