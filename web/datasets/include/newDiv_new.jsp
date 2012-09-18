                <div id="new_div" style="margin:10px 0px;">
		<table class="list_base"><tr><td>
		
			<!-- put this table in the first column of the outer table -->
                        <table class="list_base" id="groups" style="border:0px">
				<thead>
				<% if (callingForm.equals("calculateQTLs")) { %>
					<tr><td colspan = "100%" class="right">
					<input type="checkbox" name="showVariance" onclick="toggleVarianceFields()"><%=twoSpaces%>Enter Variance Values
					</td></tr>
				<% } %>
                                <tr class="col_title">
                                        <th class="noSort">Group Name</th>
                        		<% if (selectedDataset.DATASETS_WITH_GENOTYPE_DATA.contains(selectedDataset.getName())) { %>
                                        <th class="noSort">Expression Data</th>
                                        <th class="noSort">Genotype Data</th>
					<% } %>
                                        <th class="noSort">Mean Value
			                	<span class="info" title="The group mean value measured for this phenotype.">
                    					<img src="<%=imagesDir%>icons/info.gif" alt="Help">
			                	</span>
					</th>
                    			<th class="noSort varianceDiv">Variance
			                	<span class="info" title="The variance of the group value measured for this phenotype.">
                    					<img src="<%=imagesDir%>icons/info.gif" alt="Help">
			                	</span>
					</th>
                                </tr>
				</thead>
				<tbody>
                                <% 
				String checkMarkWidth="80px";
				for (Dataset.Group thisGroup : myGroups) {  
				%>
					<%

					if (thisGroup.getParent() != null && !thisGroup.getParent().equals("") && !thisGroup.getAlreadyDisplayed()) { 
						Dataset.Group[] sameParent = myDataset.new Group().getGroupsWithSameParent(myGroups, thisGroup.getParent());
						String parentName = thisGroup.getParent().replaceAll("/", "SLASH");
						thisGroup.setAlreadyDisplayed(true);
						// Need to replace slashes with underscores in group name
						if (sameParent != null && sameParent.length > 1) {
							//log.debug("sameParent length is greater than 1. it is " + sameParent.length);
							boolean parentHas_expression_data = false;
							boolean parentHas_genotype_data = false;
							for (Dataset.Group thisChild : sameParent) {
								parentHas_expression_data =  (thisChild.getHas_expression_data().equals("Y") ? true : parentHas_expression_data);
                                                        	parentHas_genotype_data = (thisChild.getHas_genotype_data().equals("Y") ? true : parentHas_genotype_data);
							}
							%>
							<tr>
							<td>
                        				<span class="trigger" name="<%=parentName%>">
                                				<%=thisGroup.getParent()%>
                        				</span>
							</td>
                        <% if (selectedDataset.DATASETS_WITH_GENOTYPE_DATA.contains(selectedDataset.getName())) { %>
								<td class="center"><%=(parentHas_expression_data ? checkMark : "-")%></td>
								<td class="center"><%=(parentHas_genotype_data ? checkMark : "-")%></td>
						<% } %>
							<td> <input type="text" name="<%=parentName%>_PARENT_MEAN" id="<%=parentName%>_PARENT_MEAN"> </td>
                            <td class="varianceDiv"><input type="text" name="<%=parentName%>_PARENT_VARIANCE" id="<%=parentName%>_PARENT_VARIANCE"></td>
							
							</tr>
							<tr><td colspan="100%">
                        				<div id="<%=parentName%>" style="display:none">

                                        		<table class="analysisParameters" cellpadding="5" style="padding:0px; margin:0px" >
							<% for (Dataset.Group thisChild : sameParent) { 
								thisChild.setAlreadyDisplayed(true);
								String childName = thisChild.getGroup_name().replaceAll("/", "SLASH");
								%> 
								<tr>
                                                			<td class="fixedWidth"> <%=thisChild.getGroup_name()%></td>
                        						<% if (selectedDataset.DATASETS_WITH_GENOTYPE_DATA.contains(selectedDataset.getName())) { %>
                                                				<td class="center" width="<%=checkMarkWidth%>"><%=(thisChild.getHas_expression_data().equals("Y") ? checkMark : "-")%></td>
                                                        			<td class="center" width="<%=checkMarkWidth%>"><%=(thisChild.getHas_genotype_data().equals("Y") ? checkMark : "-")%></td>
									<% } %>
									<td><input type="text" name="<%=childName%>_MEAN" parent="<%=parentName%>_PARENT_MEAN" id="<%=childName%>_MEAN" value="" onChange="copyToHidden(this)"></td>
                                    <td class="varianceDiv"><input type="text" name="<%=childName%>_VARIANCE" parent="<%=parentName%>_PARENT_VARIANCE" id="<%=childName%>_VARIANCE"></td>
									<input type="hidden" name="<%=childName%>_has_expression_data" value="<%=thisChild.getHas_expression_data()%>">
									<input type="hidden" name="<%=childName%>_has_genotype_data" value="<%=thisChild.getHas_genotype_data()%>">
									<input type="hidden" name="<%=childName%>_MEAN" parent="<%=parentName%>_PARENT_MEAN" value="">
                                                		</tr>
                                        		<% } %>
							</table>
							</div>
							</td>
							</tr>
						<% } else { 
							//log.debug("sameParent length is less than 1");
							thisGroup.setAlreadyDisplayed(true);
							String groupName = thisGroup.getGroup_name().replaceAll("/", "SLASH");
							if(!thisGroup.getGroup_name().equals("Exclude")){
							%>
							<tr>
							<td class="fixedWidth">  <%=thisGroup.getGroup_name()%></td>
                        				<% if (selectedDataset.DATASETS_WITH_GENOTYPE_DATA.contains(selectedDataset.getName())) { %>
                                                		<td class="center" width="<%=checkMarkWidth%>"><%=(thisGroup.getHas_expression_data().equals("Y") ? checkMark : "-")%></td>
                                                        	<td class="center" width="<%=checkMarkWidth%>"><%=(thisGroup.getHas_genotype_data().equals("Y") ? checkMark : "-")%></td>
							<% } %>
							<td><input type="text" name="<%=groupName%>_MEAN" id="<%=groupName%>_MEAN"></td>
							<td class="varianceDiv"><input type="text" name="<%=groupName%>_VARIANCE" id="<%=groupName%>_VARIANCE"></td>
							<input type="hidden" name="<%=groupName%>_has_expression_data" value="<%=thisGroup.getHas_expression_data()%>">
							<input type="hidden" name="<%=groupName%>_has_genotype_data" value="<%=thisGroup.getHas_genotype_data()%>">
							</tr>
						<%} } %>
					<% } else if (!thisGroup.getAlreadyDisplayed()) { 
						thisGroup.setAlreadyDisplayed(true);
						String groupName = thisGroup.getGroup_name().replaceAll("/", "SLASH");
						if(!thisGroup.getGroup_name().equals("Exclude")){
						%>
                        
						<tr>
						<td class="fixedWidth"> <%=thisGroup.getGroup_name()%></td>
                        			<% if (selectedDataset.DATASETS_WITH_GENOTYPE_DATA.contains(selectedDataset.getName())) { %>
                                                	<td class="center" width="<%=checkMarkWidth%>"><%=(thisGroup.getHas_expression_data().equals("Y") ? checkMark : "-")%></td>
                                                        <td class="center" width="<%=checkMarkWidth%>"><%=(thisGroup.getHas_genotype_data().equals("Y") ? checkMark : "-")%></td>
						<% } %>
						<td><input type="text" name="<%=groupName%>_MEAN" id="<%=groupName%>_MEAN"></td>
						<td class="varianceDiv"><input type="text" name="<%=groupName%>_VARIANCE" id="<%=groupName%>_VARIANCE"></td>
						<input type="hidden" name="<%=groupName%>_has_expression_data" value="<%=thisGroup.getHas_expression_data()%>">
						<input type="hidden" name="<%=groupName%>_has_genotype_data" value="<%=thisGroup.getHas_genotype_data()%>">
						</tr>
					<% }
					 } %>
                 <% }
				  %>
				</tbody>
                        </table>
			</td>
			<!-- This table is the second column of the outer table -->
			</tr></table>
                </div>  <!-- end of new_div -->

