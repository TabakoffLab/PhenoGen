<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2008
 *  Description:  This file creates a web page for the user to group arrays for
 *	normalization.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/datasets/include/analysisHeader.jsp" %>

<%
	selectedDatasetVersion = selectedDataset.new DatasetVersion(-99);
	session.setAttribute("selectedDatasetVersion", selectedDatasetVersion);
	request.setAttribute( "selectedStep", "1" );
	extrasList.add("arrayTabs.js");
	extrasList.add("groupArrays.js");
	optionsList.add("datasetDetails");

	log.info("in groupArrays.jsp. user = " + user);

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-004");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }

	Hashtable criteriaList = null; 
	edu.ucdenver.ccp.PhenoGen.data.Array[] myArrays = selectedDataset.getArrays();
	int numArrays = 0;
	Hashtable previousResults = new Hashtable();

        fieldNames.add("criterion");
        fieldNames.add("grouping_name");

        %><%@ include file="/web/common/getFieldValues.jsp" %><%

	String criterion = (!((String) fieldValues.get("criterion")).equals("") ? (String) fieldValues.get("criterion") : "None");	
        log.debug("action = "+action);
	//log.debug("criterion = "+criterion);
		int numGroups = 2;
		String[] groupLabels = new String[numGroups];
		String[] previousGroupLabels = null;
		String[] previousGroupValues = null;
		if ((String)request.getParameter("numGroups") != null) {
			numGroups = Integer.parseInt((String)request.getParameter("numGroups"));
			log.debug("numGroups has been set to " + numGroups);
			groupLabels = new String[numGroups + 1];
			for (int i=0; i<numGroups + 1; i++) {
				groupLabels[i] = (String) request.getParameter("groupLabel" + i);
				//log.debug("groupLabels["+i+"] here = "+groupLabels[i]);
			}
		} else {
			log.debug("numGroups has not been set, so it is now 2.  groupLabels are 3");
			groupLabels = new String[numGroups + 1];
			groupLabels[0] = "Exclude";
			for (int i=1; i<numGroups + 1; i++) {
				groupLabels[i] = "Name this Group";
				//log.debug("groupLabels["+i+"] here = "+groupLabels[i]);
			}
		}
		log.debug("numGroups here = "+numGroups);
		
		boolean previousGrouping = false;
		boolean previousExclusion = false;
		Dataset.Group[] myGroupings = null;
	
		if (selectedDataset.getDataset_id() != -99) {
	
			// 
			// get the list of non-unique values for the attributes in this set of arrays
			//
			criteriaList = myArray.getCriteriaList(myArrays);
	
			//
			// add the previously defined groupings to the list of criterion values
			//
			myGroupings = selectedDataset.getGroupings(dbConn);
			for (int i=0; i<myGroupings.length; i++) {
				criteriaList.put("Groups defined in \"" + myGroupings[i].getGrouping_name() + "\"",
						Integer.toString(myGroupings[i].getGrouping_id()));
			}
		
			//log.debug("criteriaList = "+criteriaList);
			if (criteriaList.containsKey("Strain") && criteriaList.containsKey("Experiment Name")) {
				//log.debug("criteriaList contains Strain and Experiment");
				//
				// add 'Replicate Experiment' to the list of criterion values 
				//
				criteriaList.put("Replicate Experiment", "replicateExperiment");
			}
			numArrays = myArrays.length;
	
			log.debug("numArrays = "+numArrays);
	
			//
			// If the user has chosen a particular criterion for creating groups,
			// set the group labels accordingly
			//
				if ((action != null) && action.equals("Select Criterion")) {
	
				//
				// Try to convert the string to an integer.  If this succeeds, then
				// get the values for the previous grouping.  Otherwise,
				// get the values for the criterion selected.
				//
				try {
					int previousGroupingID = Integer.parseInt(criterion);
					User.UserChip[] previousChipAssignments = 
								selectedDataset.new Group().getChipAssignments(
								previousGroupingID, dbConn);
					for (int i=0; i<previousChipAssignments.length; i++) {
						previousResults.put(Integer.toString(previousChipAssignments[i].getHybrid_id()),  
								Integer.toString(previousChipAssignments[i].getGroup().getGroup_number()));
					}
	
					Dataset.Group[] previousGroups = selectedDataset.getGroupsInGrouping(previousGroupingID, dbConn);
	
					myDataset.new Group().sortGroups(previousGroups, "groupNumber", "A");
	
					if (previousGroups[0].getGroup_name().equals("Exclude")) {
						log.debug("previousGroupLabels contains Exclude");
						previousExclusion = true;
					}
	
					numGroups = previousGroups.length;
					// If the previous grouping did not have any arrays excluded, then 
					// create a new group with label 'Exclude'
					if (!previousExclusion) {
						previousGroupLabels = new String[previousGroups.length + 1];
						previousGroupValues = new String[previousGroups.length + 1];
						previousGroupLabels[0] = "Exclude";
						previousGroupValues[0] = "0";
						for (int i=1; i<previousGroups.length + 1; i++) {
							previousGroupLabels[i] = previousGroups[i-1].getGroup_name();
							previousGroupValues[i] = Integer.toString(previousGroups[i-1].getGroup_number());
						}
					} else {
						// an 'Exclude' group was created
						previousGroupLabels = new String[previousGroups.length];
						previousGroupValues = new String[previousGroups.length];
	
						for (int i=0; i<previousGroups.length; i++) {
							previousGroupLabels[i] = previousGroups[i].getGroup_name();
							previousGroupValues[i] = Integer.toString(previousGroups[i].getGroup_number());
						}
						// don't count the 'Exclude' group as a separate group
						numGroups = numGroups - 1;
	
						/* Not sure why this is here
						if (previousGroupLabels[0].equals("")) {
							for (int i=0; i<numGroups; i++) {
								previousGroupLabels[i] = "Group " + groupLabels[i];
							}
						}
						*/
					}
					log.debug("previous numGroups = "+numGroups);
					previousGrouping = true;
					log.debug("previousGrouping = "+previousGrouping + ", and previousExclusion = " + previousExclusion);
				} catch (Exception e) {
					//
					// User did not select a previousGrouping
					//
					//log.error("error = ", e);
					String[] newGroupLabels = (!criterion.equals("Self-defined") ? 
								 myArray.getUniqueValues(myArrays, criterion):
								new String[] {"Name this Group", "Name this Group"});
					//log.error("User did not select a previousGrouping.  Instead selected criterion = "+criterion+
					//		", newGroupLabels = "); myDebugger.print(newGroupLabels);
					numGroups = newGroupLabels.length;
					groupLabels = new String[newGroupLabels.length + 1];
					groupLabels[0] = "Exclude";
					for (int i=1; i<newGroupLabels.length + 1; i++) {
						groupLabels[i] = newGroupLabels[i-1];
					}
					if (criterion.equals("replicateExperiment") && numGroups < 4) {
						groupLabels = new String[5];
						groupLabels[0] = "Exclude";
						groupLabels[1] = "Experiment 1, Line 1";
						groupLabels[2] = "Experiment 1, Line 2";
						groupLabels[3] = "Experiment 2, Line 1";
						groupLabels[4] = "Experiment 2, Line 2";
						numGroups = 4;
					}
				}
				//log.debug("groupLabels = "); myDebugger.print(groupLabels);
				//log.debug("previousGroupLabels = "); myDebugger.print(previousGroupLabels);
				//log.debug("previousGroupValues = "); myDebugger.print(previousGroupValues);
				//log.debug("previousResults = "); myDebugger.print(previousResults);
	
			} else if (action != null && action.equals("Skip >")) {
				response.sendRedirect(datasetsDir + "normalize.jsp" + datasetQueryString);
			}else if (action != null && action.equals("Next >")) {
	
				List<String> groupLabelsAsList = Arrays.asList(groupLabels);
				Set<String> groupLabelsAsSet = new TreeSet(groupLabelsAsList);
				/*
				log.debug("groupLabels = "); myDebugger.print(groupLabels);
				log.debug("groupLabelsAsList = "); myDebugger.print(groupLabelsAsList);
				log.debug("groupLabelsAsSet = "); myDebugger.print(groupLabelsAsSet);
				*/
				if (groupLabelsAsList.size() != groupLabelsAsSet.size()) {
					//Error -- Non-unique group names
					session.setAttribute("errorMsg", "EXP-035");
					response.sendRedirect(datasetsDir + "groupArrays.jsp");
				} else {
					Hashtable groupNames = new Hashtable();
					groupNames.put("0", "Exclude");
					for (int i=1; i<numGroups + 1; i++) {
						groupNames.put(Integer.toString(i), groupLabels[i]);
					}
	
					numArrays = Integer.parseInt((String) request.getParameter("numArrays"));	
					LinkedHashMap groupValues = new LinkedHashMap();
					for (int i=0; i<numArrays; i++) {
						//groupValues.put(new Integer((String) request.getParameter("user_chip_id"+i)), new Integer((String) request.getParameter(Integer.toString(i))));
						groupValues.put((String) request.getParameter("user_chip_id"+i), (String) request.getParameter(Integer.toString(i)));
					}
					int grouping_id	= selectedDataset.checkGroupingExists(groupValues, dbConn);
					if (grouping_id == -99) {
						grouping_id = selectedDataset.createNewGrouping(criterion, 
												(String) fieldValues.get("grouping_name"),
												groupValues,
												groupNames, 
												dbConn);
						response.sendRedirect(datasetsDir + "normalize.jsp" + datasetQueryString+"&newGroupingID="+grouping_id);
					} else {
						//Error -- Grouping already exists
						session.setAttribute("errorMsg", "EXP-026");
						session.setAttribute("additionalInfo", 
									"See the grouping called '"+ 
								selectedDataset.new Group().getGrouping(grouping_id, dbConn).getGrouping_name() + "'");
						response.sendRedirect(commonDir + "errorMsg.jsp");
					}
				}
				mySessionHandler.createDatasetActivity("Grouped arrays", dbConn);
			} 
		}
		formName = "groupArrays.jsp";
	
%>
	<%@ include file="/web/common/microarrayHeader.jsp" %>
	<script type="text/javascript">
		var crumbs = ["Home", "Analyze Microarray Data", "Create Groups"];
	</script>
	<%@ include file="/web/datasets/include/viewingPane.jsp" %>
	<div class="brClear"></div>
	<%@ include file="/web/datasets/include/prepSteps.jsp" %>
	<div class="brClear"></div>


	<div class="page-intro">
		<p>Place arrays into groups based on a characteristic that you would like to test 
			for association with gene expression.  Provide a name for this grouping.
	</div> <!-- // end page-intro -->

	<%
	if (selectedDataset.getDataset_id() != -99 && selectedDataset.getArrays().length > 0) {
		%>
		<div class="brClear"></div>

		<div class="datasetForm">
		<form   method="post"
			action="groupArrays.jsp?action=Select Criterion"
			enctype="application/x-www-form-urlencoded"
			name="chooseCriterion">

			Create groups based on the following attribute:
			<%
				onChange = "replicateWarning() & document.chooseCriterion.submit()";
				selectName = "criterion";
				selectedOption = (String) fieldValues.get(selectName);

				SortedSet ss = new TreeSet(criteriaList.keySet());	
				Iterator itr = ss.iterator();
				optionHash = new LinkedHashMap();
				optionHash.put("Self-defined", "--------- None ----------");
				while (itr.hasNext()) {
					String thisCriterion = (String) itr.next();
					String value = (String) criteriaList.get(thisCriterion);
					optionHash.put(value, thisCriterion);
				}
			%>

			<%@ include file="/web/common/selectBox.jsp" %>

                	<span class="info" title="You may group your arrays according to attributes defined 
				in the database by selecting an option from this list.  ">
 	                   	<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                	</span>

			<input type="hidden" name="criterion" value="<%=(String) fieldValues.get("criterion")%>" >
			<input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>" >

			<BR> <BR>

		</form>

		<form	name="groupArrays" 
			method="post" 
			action="groupArrays.jsp"
			onSubmit="return checkButtonUsedToSubmit(this, numArrays)"
			enctype="application/x-www-form-urlencoded"> 

	
<div style="border: solid 1px #bbb; overflow: auto; padding-bottom: 20px; /* height: 400px; */ position: relative;">

    <style>
        table.list_base th input { width: 100px; }
        tr#headerRow th { white-space: nowrap; }
        .removeGroup { background: url('<%=imagesDir%>icons/delete.png'); height: 16px; width: 16px; display: inline-block; margin-right: 10px;} 
    </style>

		<div class="title">  Array Groupings </div> 
		<table class="list_base" id="groupTable" name="items" cellpadding="0" cellspacing="3" width="90%">
			<tr><td colspan="100%" class=right>
				<a href="javascript:addGroup(<%=myArrays.length%>)">Create Additional Group</a>
                		<span class="info" title="You may manually create groups and assign the arrays
					to them any way you would like.  All groups must be named">
 	                   		<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                		</span>
			</td></tr>
			<%@ include file="/web/datasets/include/formatGroupResults.jsp" %>
		</table>
</div>
		<BR>
		<BR>
		<BR>

		Name this grouping:<%=twoSpaces%><input type="text" size="50" name="grouping_name" id="grouping_name" value="<%=(String) fieldValues.get("grouping_name")%>">
		<BR>
       	<div class="right"> 
        
        </div>
		<div id="prevNext">
			<div class="right">
            	<%if (myGroupings.length>0) {%>
            	<input type="submit" name="action" value="Skip >" 
					style="background:url(<%=imagesDir%>/Button.gif) no-repeat; 
						border:none; width:80px; height:28px; color:white; " alt="Skip" title="Skip Creating a new group and return to Normalizaion">
                    <% } %>
				<% onClickString="return IsGroupArraysFormComplete()"; %>
				<%@ include file="/web/common/nextButton.jsp" %>
			</div>
		</div> <!-- end div_id_prevNext -->

		<input type="hidden" name="numGroups" value="<%=numGroups%>" id="numGroups"> 
		<input type="hidden" name="criterion" value="<%=(String) fieldValues.get("criterion")%>"> 
		<input type="hidden" name="numArrays" value="<%=numArrays%>" >
		<!--  This is required in order to store the datasetID that was passed in -->
		<input type="hidden" name="datasetID" value=<%=selectedDataset.getDataset_id()%>>  

		</form>
		</div>
	<%
	}
%>
	<div class="arrayDetails"></div>
	<script type="text/javascript">
        	$(document).ready(function(){
			setupPage();
        	});
	</script>
<%@ include file="/web/common/footer.jsp" %>

