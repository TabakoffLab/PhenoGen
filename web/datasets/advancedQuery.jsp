<%--
 *  Author: Cheryl Hornbaker
 *  Created: Jan, 2009
 *  Description:  The web page created by this file displays attributes from the arrays
 *		by which the user may query them.
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>

<%
	log.info("in advancedQuery.jsp." );
	request.setAttribute( "selectedStep", "0" ); 
	extrasList.add("advancedQuery.js");
	optionsList.add("chooseNewDataset");
	optionsList.add("upload");
	edu.ucdenver.ccp.PhenoGen.data.Array.ArrayCount[] myCounts = null;

	Dataset dummyDataset = (session.getAttribute("dummyDataset") == null ?
					new Dataset(-99) : (Dataset) session.getAttribute("dummyDataset"));;
	log.debug("dummyDataset.dataset_id = "+dummyDataset.getDataset_id());
	int dummyDatasetID = dummyDataset.getDataset_id();
	if (dummyDatasetID != -99) {
		optionsListModal.add("viewFinalizeDataset");
	} 
	String attributeName = "";
	String selectBoxName = "";
	String onChangeFunction = "";
	String columnHeadingStyle = "";
	String longSelectBoxStyle = "width:350px";
	String shortSelectBoxStyle = "width:280px";
	String selectBoxStyle = longSelectBoxStyle;

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Can't create datasets
                session.setAttribute("errorMsg", "GST-002");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }

	Hashtable attributes = new Hashtable(); 

	fieldNames.add("organism");
	fieldNames.add("geneticVariation");
	fieldNames.add("sex");
	fieldNames.add("organismPart");
	fieldNames.add("genotype");
	fieldNames.add("cellLine");
	fieldNames.add("strain");
	fieldNames.add("treatment");
	fieldNames.add("compound");
	fieldNames.add("dose");
	fieldNames.add("duration");
	fieldNames.add("arrayName");

	fieldNames.add("experimentName");
	fieldNames.add("experimentDesignType");

	fieldNames.add("channel");
	fieldNames.add("arrayType");

	fieldNames.add("publicOrPrivate");
	fieldNames.add("subordinates");

        %><%@ include file="/web/common/getFieldValues.jsp" %><%

	String channel = (fieldValues.get("channel") != null && 
			!((String) fieldValues.get("channel")).equals("") ? 
			(String) fieldValues.get("channel") : "Single");
	log.debug("channel = "+channel);

	int numRows = 0;
	action = (String)request.getParameter("action");

        //log.debug("action = " + action);

	boolean guestFirstView = false;

	List<String[]> myCompoundDoseCombos = myArray.getCompoundDoseCombos("All", channel, dbConn);
	List<String[]> myTreatmentDurationCombos = myArray.getTreatmentDurationCombos("All", channel, dbConn);

	if ((action != null) && (action.equals("Get Arrays"))) {

        	%><%@ include file="/web/datasets/include/setupQueryCriteria.jsp" %><%

		mySessionHandler.createSessionActivity(session.getId(), 
                        "Queried arrays using these attributes: " + 
			myObjectHandler.getAsSeparatedString(attributes.values(), ","),
                        dbConn);

                response.sendRedirect(datasetsDir + "selectArrays.jsp");
	}
	String arrayGroup = "All";
	//boolean loggedIn = true;

   
%>
	<%@ include file="/web/common/microarrayHeader.jsp" %>
        <!-- use javascript to fill up the client-side array with saved combination values -->
        <%@ include file="/web/datasets/include/fillCombos.jsp" %>

	<%@ include file="/web/datasets/include/createSteps.jsp" %>
	<script type="text/javascript">
        	var crumbs = ["Home", "Analyze Microarray Data", "Create New Dataset"]; 
	</script>
	<div class="page-intro">
		<p> Specify criteria to search for arrays you would 
		like to include in your dataset.<%=twoSpaces%>(<b>Note that 
		the arrays retrieved will satisfy ALL the criteria chosen</b>, and you may return to this page
		to change your criteria and retrieve more arrays before finalizing your dataset.)
		</p>
	</div> <!-- // end page-intro -->
	<div style="float:right; padding-right:14px;">(Dataset contains<input type="text" id="test" class="numArraysDisplay" size="1" onFocus="blur()" value="<%=dummyDataset.getDatasetChips(dbConn).length%>"/>arrays)</div>
	<div class="brClear"></div>


	<form method="post"
        	action="advancedQuery.jsp"
        	enctype="application/x-www-form-urlencoded"
        	name="chooseCriterion">

	<div style="width:800px">
		<div class="inlineButton" style="float:right"><a href="<%=datasetsDir%>basicQuery.jsp">Basic Search</a></div>
	</div>
	<center><span class=heading>Retrieve Arrays By:</span></center>
	<table class="list_base"> <!-- outer table -->
	<tr>
	<td style="vertical-align:top"> <!-- split main table into two columns.  This is the left side -->
		<div style="border:1px solid; height:450px">	
		<table> <!-- This is the left side box with the black solid border -->	
		<tr>
		<td>
			<table class="list_base">	
        			<tr class="title"> <th colspan="100%"> Platform Attributes </th> </tr>
        			<tr>
                			<td class=columnHeading> Single- or Two-Channel: </td>
					<td>
                			<%
					optionHash = new LinkedHashMap();
					optionHash.put("Single", "Single Channel (e.g., Affymetrix or CodeLink)");
					optionHash.put("Two", "Two Channel (e.g., cDNA)");

        				style=longSelectBoxStyle;
                			selectName = "channel";
                                	onChange = "changeAttributeValues()";
                			selectedOption = (String) fieldValues.get(selectName);

                			%> <%@ include file="/web/common/selectBox.jsp" %>
        				</td>
				</tr>
        			<tr>
					<%
					attributeName = "Array Type";
					selectBoxName = "arrayType";
                			myCounts = myArray.getArrayTypes(arrayGroup, channel, dbConn);
                			%> 
					<%@ include file="/web/datasets/include/queryBox.jsp" %>
				</tr>
			</table>
			<BR><BR>
			<table class="list_base">	
        			<tr class="title"> <th colspan="100%"> Experiment Attributes </th> </tr>
        			<tr>
					<%
					attributeName = "Experiment Name";
					selectBoxName = "experimentName";
                			myCounts = myArray.getExperimentNames(arrayGroup, channel, dbConn);
                			%> 
					<%@ include file="/web/datasets/include/queryBox.jsp" %>
				</tr>
        			<tr>
					<%
					attributeName = "Experiment Design Type";
					selectBoxName = "experimentDesignType";
                			myCounts = myArray.getExperimentDesignTypes(arrayGroup, channel, dbConn);
                			%> 
					<%@ include file="/web/datasets/include/queryBox.jsp" %>
				</tr>
			</table>
			<BR><BR>
			<table class="list_base">	
        			<tr class="title"> <th colspan="100%"> Owner Attributes </th> </tr>
				<!--
        			<tr>
                			<td class=columnHeading> Public or Private: </td>
					<td>
                			<%
					optionHash = new LinkedHashMap();
					optionHash.put("All", "All");
					optionHash.put("Public", "Public");
					optionHash.put("Private", "Private");

        				style=longSelectBoxStyle;
                			selectName = "publicOrPrivate";
                                	onChange = "";
                			selectedOption = (String) fieldValues.get(selectName);

                			%> <%@ include file="/web/common/selectBox.jsp" %>
        				</td>
				</tr>
				-->
        			<tr>
                			<td class=columnHeading> Principal Investigator: </td>
					<td>
                			<%
                			Hashtable piHash = myUser.getSubordinateListByPI(dbConn);
					Set submitters = myArray.getSubmitters(arrayGroup, channel, dbConn);

					optionHash = new LinkedHashMap();
					optionHash.put("All", "All");

					Iterator piHashItr = piHash.keySet().iterator();
					while (piHashItr.hasNext()) {
						String pi = (String) piHashItr.next();
						// Create a new Set to use for the retainAll function
						Set anySubmitters = new TreeSet(submitters);
						anySubmitters.retainAll((List) piHash.get(pi));
						if (anySubmitters.size() > 0) {
							String submitterString = "(" + 
								myObjectHandler.getAsSeparatedString(anySubmitters,",","'",999) + 
								")";
							optionHash.put(submitterString, pi);
						}
					}

        				style=longSelectBoxStyle;
                			selectName = "subordinates";
                                	onChange = "";
                			selectedOption = (String) fieldValues.get(selectName);

                			%> <%@ include file="/web/common/selectBox.jsp" %>
        				</td>
				</tr>
			</table>
		</td></tr></table></div> <!-- border around table in the left column -->
	</td> <!-- left column -->
	<td style="vertical-align:top"> <!-- right column of outer table -->
		<div style="border:1px solid; height:450px">	
		<table> <!-- This is the right side box with the black solid border -->	
		<tr>
		<td>
			<table class="list_base" width="99%">	
        			<tr class="title"> <th colspan="100%"> Array/Sample Attributes </th> </tr>
        			<tr>
					<%
					attributeName = "Organism";
					selectBoxName = "organism";
                			myCounts = myArray.getArrayOrganisms(arrayGroup, channel, dbConn);
                			%> 
					<%@ include file="/web/datasets/include/queryBox.jsp" %>
				</tr> <tr>
					<%
					attributeName = "Genetic Modification";
					selectBoxName = "geneticVariation";
                			myCounts = myArray.getGeneticVariations(arrayGroup, channel, dbConn);
                			%> 
					<%@ include file="/web/datasets/include/queryBox.jsp" %>
				</tr> <tr>
					<%
					attributeName = "Sex";
					selectBoxName = "sex";
                			myCounts = myArray.getSexes(arrayGroup, channel, dbConn);
                			%> 
					<%@ include file="/web/datasets/include/queryBox.jsp" %>
				</tr> <tr>
					<%
					attributeName = "Tissue";
					selectBoxName = "organismPart";
                			myCounts = myArray.getOrganismParts(arrayGroup, channel, dbConn);
                			%> 
					<%@ include file="/web/datasets/include/queryBox.jsp" %>
				</tr> <tr>
					<%
					attributeName = "Strain";
					selectBoxName = "strain";
                			myCounts = myArray.getStrains(arrayGroup, channel, dbConn);
                			%> 
					<%@ include file="/web/datasets/include/queryBox.jsp" %>
				</tr> <tr>
					<%
					attributeName = "Genotype";
					selectBoxName = "genotype";
                			myCounts = myArray.getGenotypes(arrayGroup, channel, dbConn);
                			%> 
					<%@ include file="/web/datasets/include/queryBox.jsp" %>
				</tr> <tr>
					<%
					attributeName = "Line";
					selectBoxName = "cellLine";
                			myCounts = myArray.getCellLines(arrayGroup, channel, dbConn);
                			%> 
					<%@ include file="/web/datasets/include/queryBox.jsp" %>
				</tr> <tr>
                			<td class=columnHeading> Hybridization Name contains: </td>
					<td>
					<%
        					String thisField = "arrayName";
        					String thisFieldValue = (fieldValues.get(thisField) != null ?
										(String) fieldValues.get(thisField) : "");
                			%> 
						<input type="text" name="<%=thisField%>" size=50 value="<%=thisFieldValue%>"> 
					</td>
				</tr>
			</table>
			<BR>
			<table class="list_base" width="99%">	
        			<tr class="title"> <th colspan="100%"> Compound Treatment Attributes </th> </tr>
				<tr>
					<%
					attributeName = "Treatment";
					selectBoxName = "treatment";
					onChangeFunction = "showDurationField()";
					columnHeadingStyle = "vertical-align:top";
					selectBoxStyle = longSelectBoxStyle;
                			myCounts = myArray.getTreatments(arrayGroup, channel, dbConn);
					%>
					<%@ include file="/web/datasets/include/queryBox.jsp" %>
				</tr><tr>
					<td>&nbsp;</td>
					<td>
						<div id="durationField">
						<table><tr>
							<%
							attributeName = "Duration";
							selectBoxName = "duration";
							onChangeFunction = "";
							columnHeadingStyle = "";
							selectBoxStyle = shortSelectBoxStyle;
                					myCounts = myArray.getDurations(arrayGroup, channel, dbConn);
							%>
							<%@ include file="/web/datasets/include/queryBox.jsp" %>
						</tr></table>
						</div> 
					</td>
				</tr> <tr>
					<%
					attributeName = "Compound";
					selectBoxName = "compound";
					onChangeFunction = "showDoseField()";
					columnHeadingStyle = "vertical-align:top";
                			myCounts = myArray.getCompounds(arrayGroup, channel, dbConn);
					%>
					<%@ include file="/web/datasets/include/queryBox.jsp" %>
				</tr><tr>
					<td>&nbsp;</td>
					<td>
						<div id="doseField">
						<table><tr>

							<%
							attributeName = "Dose";
							selectBoxName = "dose";
							onChangeFunction = "";
							columnHeadingStyle = "";
							selectBoxStyle = shortSelectBoxStyle;
                					myCounts = myArray.getDoses(arrayGroup, channel, dbConn);
							%>
							<%@ include file="/web/datasets/include/queryBox.jsp" %>
						</tr></table>
						</div> 
					</td>
				</tr> 
			</table> <!-- compound treatment attributes -->
		</td></tr></table></div> <!-- border around table in the right column -->
	</td> <!-- right column of outer table -->
        </tr>
        <tr> <td colspan="2"> &nbsp;&nbsp;</td> </tr>
        <tr align="center">
		<td colspan="2"> <input type="submit" name="action" value="Get Arrays" > </td>
        </tr>
        <tr> <td colspan="2"> &nbsp;&nbsp;</td> </tr>
        </table>
	<input type="hidden" name="dummyDatasetID" value="<%=dummyDatasetID%>">

	</form>

	<div class="datasetDetails"></div>
	<script type="text/javascript">
		$(document).ready(function() {
			setupPage();
		});
	</script>


<%@ include file="/web/common/footer.jsp" %>
