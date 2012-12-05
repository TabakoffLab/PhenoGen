<%--
 *  Author: Cheryl Hornbaker
 *  Created: Jun, 2010
 *  Description:  The web page created by this file allows the user to 
 *		query arrays in a hierarchical fashion
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>

<%
	log.info("in basicQuery.jsp." );
	request.setAttribute( "selectedStep", "0" ); 
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

	extrasList.add("basicQuery.js");
	optionsList.add("chooseNewDataset");
	optionsList.add("upload");
	Hashtable attributes = new Hashtable(); 

	fieldNames.add("organism");
	fieldNames.add("geneticType");
	fieldNames.add("organismPart");
	fieldNames.add("strain");
	fieldNames.add("cellLine");
	fieldNames.add("genotype");
	fieldNames.add("arrayType");

        %><%@ include file="/web/common/getFieldValues.jsp" %><%

	String channel = "Single";

	List<String[]> myCombos = myArray.getQueryCombos(channel, dbConn);

	int numRows = 0;
	action = (String)request.getParameter("action");

        //log.debug("action = " + action);

	boolean guestFirstView = false;

	if ((action != null) && (action.equals("Get Arrays"))) {
	
		log.debug("GeneticType = " + (String) fieldValues.get("geneticType"));

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

<%pageTitle="Create dataset - Basic";%>

	<%@ include file="/web/common/microarrayHeader.jsp" %>
        <!-- use javascript to fill up the client-side array with saved combination values -->
        <%@ include file="/web/datasets/include/fillQueryCombos.jsp" %>
	<%@ include file="/web/datasets/include/createSteps.jsp" %>

	<% if (dummyDatasetID != -99) { %>
			<div style="float:right; clear:right; padding-right:14px;">(Dataset contains<input type="text" id="test" class="numArraysDisplay" size="1" onFocus="blur()" value="<%=dummyDataset.getDatasetChips(dbConn).length%>"/>arrays)</div>
	<% } %> 

	<div class="page-intro">
		<p> Specify criteria to search for arrays you would 
		like to include in your dataset.<%=twoSpaces%>(<b>Note that 
		the arrays retrieved will satisfy ALL the criteria chosen</b>, and you may return to this page
		to change your criteria and retrieve more arrays before finalizing your dataset.)
		</p>
	</div> <!-- // end page-intro -->
	<div class="brClear"></div>

	<form method="post"
        	action="basicQuery.jsp"
		onSubmit="return IsBasicQueryFormComplete()"
        	enctype="application/x-www-form-urlencoded"
        	name="chooseCriterion">

	<div style="width:800px">
		<div class="inlineButton" style="float:right"><a href="<%=datasetsDir%>advancedQuery.jsp">Advanced Search</a></div>
	</div>
	<center><span class=heading>Retrieve Arrays By:</span></center>
	<table class="list_base"> <!-- outer table -->
	<tr>
	<td style="vertical-align:top"> <!-- split main table into two columns.  This is the left side -->
		<div style="border:1px solid; height:250px">	
		<table> <!-- This is the left side box with the black solid border -->	
		<tr>
		<td>
			<table class="list_base">	
        			<tr class="title"> <th colspan="100%"> Array Attributes </th> </tr>
        			<tr>
					<%
					attributeName = "Organism";
					selectName = "organism";
					onChange = "showGeneticTypeField()";
                                	selectedOption = "-99";
                			myCounts = myArray.getArrayOrganisms(arrayGroup, channel, dbConn);
                                	optionHash = new LinkedHashMap();
                                	optionHash.put("-99", " -- Choose an organism -- ");

					%>

                                	<td class="columnHeading"> Organism:</td>
                                	<td>
                                	<%

                                	for (int i=0; i<myCounts.length; i++) {
                                        	optionHash.put(myCounts[i].getCountName(), myCounts[i].getCountName());
                                	}
	
					//Have to figure out query combos for All, so leave this for now
					//optionHash.put("All", "All");

                                	%> <%@ include file="/web/common/selectBox.jsp" %>
                                	</td>
				</tr>
				<tr>
					<%
					selectName = "geneticType";
					onChange= "showStrainLineGenotypeField()";
                                	//selectedOption = (String) fieldValues.get(selectName);
					%>
                                	<td class="columnHeading"> Genetic Characterization:</td>
                                	<td>

					<%@ include file="/web/common/selectBox.jsp" %>
					</td>
				</tr>
				<tr>
					<%
					selectName = "strain";
					onChange= "showTissueField()";
                                	//selectedOption = (String) fieldValues.get(selectName);
					%>
                                	<td class="columnHeading"> Strain:</td>
                                	<td>

					<%@ include file="/web/common/selectBox.jsp" %>
					</td>
				</tr>
				<tr>
					<%
					selectName = "cellLine";
					onChange= "showTissueField()";
                                	//selectedOption = (String) fieldValues.get(selectName);
					%>
                                	<td class="columnHeading">Line:</td>
                                	<td>

					<%@ include file="/web/common/selectBox.jsp" %>
					</td>
				</tr>
				<tr>
					<%
					selectName = "genotype";
					onChange= "showTissueField()";
                                	//selectedOption = (String) fieldValues.get(selectName);
					%>
                                	<td class="columnHeading"> Genotype:</td>
                                	<td>

					<%@ include file="/web/common/selectBox.jsp" %>
					</td>
				</tr>
				<tr>
					<%
					selectName = "organismPart";
					onChange= "showChipField()";
                                	//selectedOption = (String) fieldValues.get(selectName);
					%>
                                	<td class="columnHeading"> Tissue:</td>
                                	<td>

					<%@ include file="/web/common/selectBox.jsp" %>
					</td>
				</tr>
				<tr>
					<%
					selectName = "arrayType";
					onChange= "";
                                	//selectedOption = (String) fieldValues.get(selectName);
					%>
                                	<td class="columnHeading"> Platform:</td>
                                	<td>

					<%@ include file="/web/common/selectBox.jsp" %>
					</td>
				</tr>
			</table>
			</div> 
			<BR><BR>
		</td></tr></table></div> <!-- border around table in the left column -->
	</td> <!-- left column -->
        </tr>
        <tr> <td colspan="100%"> &nbsp;&nbsp;</td> </tr>
        <tr align="center">
		<td colspan="100%"> <input type="submit" name="action" value="Get Arrays" > </td>
        </tr>
        <tr> <td colspan="100%"> &nbsp;&nbsp;</td> </tr>
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
