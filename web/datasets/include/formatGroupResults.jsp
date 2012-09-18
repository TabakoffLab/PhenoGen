<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  This places each of the arrays in the appropriate group depending
 * 		on the criterion chosen by the user.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<jsp:useBean id="myDbUtils" class="edu.ucdenver.ccp.PhenoGen.util.DbUtils"> </jsp:useBean>

	<tr id="headerRow" class="col_title">
		<th class="noSort"> Array Name</th>
		<%
		if (numGroups > 0) {
			for (int i=0; i<numGroups + 1; i++) {
				// 
				// If user selected a previous grouping, display the label used.
				//
				String label = (previousGrouping ?  previousGroupLabels[i] : groupLabels[i]);
				//log.debug("label = "+label);
				if (label != null && !label.equals("Exclude")) { %>
					<th class="groupLabel<%=i%>"> 
						<input type="text" size="30" maxlength="30" id="groupLabel<%=i%>" name="groupLabel<%=i%>" value="<%=label%>">
					</th><%
				} else {
					%><th>Exclude <input type="hidden" id="groupLabel0" name="groupLabel0" value="Exclude"></th><%
				}
			}
		}
%> 
	</tr> 

<% 	
	String arrayDetailsLink = "<a href='"+ datasetsDir + "arrayDetails.jsp?arrayID=";

	User.UserChip[] myDatasetChips = selectedDataset.getDatasetChips(dbConn);

	User.UserChip myUserChip = new User().new UserChip();
	for (int i=0; i<myArrays.length; i++) {

		User.UserChip thisUserChip = myUserChip.getUserChipFromMyUserChips(myDatasetChips, myArrays[i].getHybrid_id());
		int user_chip_id = thisUserChip.getUser_chip_id();
		%>

			<tr id="rowNum<%=i%>" name="<%=myArrays[i].getHybrid_name()%> - <%=myArrays[i].getFile_name()%>" hybridID="<%=myArrays[i].getHybrid_id()%>">
				<td class="details cursorPointer"><%=myArrays[i].getHybrid_name()%>
					<input type="hidden" name="user_chip_id<%=i%>" value="<%=user_chip_id%>"> 
				</td>
			<%	
			// 
			// This code looks for the criterion that was selected, and then chooses the 
			// appropriate column in the database to compare the value against.
			// 
			String column = null;
			if (previousGrouping) {
				column = (String) previousResults.get(Integer.toString(myArrays[i].getHybrid_id()));
			} else {
				if (criterion.equals("organism")) {
					column = myArrays[i].getOrganism();
				} else if (criterion.equals("biosource_type")) {
					column = myArrays[i].getBiosource_type();
				} else if (criterion.equals("development_stage")) {
					column = myArrays[i].getDevelopment_stage();
				} else if (criterion.equals("age_range_min")) {
					column = Double.toString(myArrays[i].getAge_range_min());
				} else if (criterion.equals("age_range_max")) {
					column = Double.toString(myArrays[i].getAge_range_max());
				} else if (criterion.equals("time_point")) {
					column = myArrays[i].getTime_point();
				} else if (criterion.equals("organism_part")) {
					column = myArrays[i].getOrganism_part();
				} else if (criterion.equals("gender")) {
					column = myArrays[i].getGender();
				} else if (criterion.equals("genetic_variation")) {
					column = myArrays[i].getGenetic_variation();
				} else if (criterion.equals("individual_genotype")) {
					column = myArrays[i].getIndividual_genotype();
				} else if (criterion.equals("disease_state")) {
					column = myArrays[i].getDisease_state();
				} else if (criterion.equals("separation_technique")) {
					column = myArrays[i].getSeparation_technique();
				} else if (criterion.equals("target_cell_type")) {
					column = myArrays[i].getTarget_cell_type();
				} else if (criterion.equals("cell_line")) {
					column = myArrays[i].getCell_line();
				} else if (criterion.equals("strain")) {
					column = myArrays[i].getStrain();
				} else if (criterion.equals("treatment")) {
					column = myArrays[i].getTreatment();
				} else if (criterion.equals("expName")) {
					column = myArrays[i].getExperiment_name();
				} else if (criterion.equals("replicateExperiment")) {
					column = myArrays[i].getExperiment_name() + " " + 
						myArrays[i].getStrain(); 
				}
				column = myDbUtils.setToNoneIfNull(column);
			}
			// 
			// If the column's value is the same as the group label, then
			// create a radio button that is 'checked'.  Otherwise, create 
			// a blank radio button.
			//
			//log.debug("hybrid_id = " + myArrays[i].getHybrid_id() + ", and column = " + column);
	
			String[] chipValues = null;
			if (column != null) {
				//
				// If this is not based on a previously-defined grouping, then automatically create the Exclude
				// column, and start the values from 1, not 0
				//	
				int start = 1;
				if (!previousGrouping) {
					chipValues = groupLabels;
					%><td align="center"> <input type="radio" name="<%=i%>" value="0"></td><%
				//
				// If this IS based on a previously-defined grouping, then check to see if the previous
				// grouping had an exclusion.  If it did, use the values as-is.  Otherwise, create the Exclude column
				// and start the values from 1, not 0
				//	
				} else {
					chipValues = previousGroupValues;
					if (!previousExclusion) {
						%><td align="center"> <input type="radio" name="<%=i%>" value="0"></td><%
					} else {
						start = 0;
						//log.debug("chipValues = "); myDebugger.print(chipValues);
					}
				}
				for (int j=start; j<chipValues.length; j++) {
					String checked = (column.equals(chipValues[j]) ?  " checked " : ""); 
					%><td align="center" class="groupLabel<%=j%>"> <input type="radio" <%=checked%> name="<%=i%>" value="<%=(j)%>"></td><%
				}
			}
                        %> </tr> <%
		}
%>


