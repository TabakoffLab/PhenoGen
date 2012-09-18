<%--
 *  Author: Cheryl Hornbaker
 *  Created: Sep, 2008
 *  Description:  This file formats the results of the array compatability step of the quality control process. 
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%
	boolean genderUnique = myArray.isUnique(myArrays, "gender");
	boolean biosource_typeUnique = myArray.isUnique(myArrays, "biosource_type");
	boolean development_stageUnique = myArray.isUnique(myArrays, "development_stage");
	boolean age_statusUnique = myArray.isUnique(myArrays, "age_status");
	boolean age_range_minUnique = myArray.isUnique(myArrays, "age_range_min");
	boolean age_range_maxUnique = myArray.isUnique(myArrays, "age_range_max");
	boolean time_pointUnique = myArray.isUnique(myArrays, "time_point");
	boolean organism_partUnique = myArray.isUnique(myArrays, "organism_part");
	boolean genetic_variationUnique = myArray.isUnique(myArrays, "genetic_variation");
	boolean individual_genotypeUnique = myArray.isUnique(myArrays, "individual_genotype");
	boolean disease_stateUnique = myArray.isUnique(myArrays, "disease_state");
	boolean separation_techniqueUnique = myArray.isUnique(myArrays, "separation_technique");
	boolean strainUnique = myArray.isUnique(myArrays, "strain");
	boolean treatmentUnique = myArray.isUnique(myArrays, "treatment");
%>

<% if (selectedDataset.getDatasetVersions().length == 0) { %>
	<div class="tab-intro">
	<p>If desired, you may delete one or more of the following arrays:</p>
	</div>
	<div class="brClear"></div>
<% } %>

	<div class="scrollable">
	<table id="arrayCompatability" name="items" class="list_base" cellpadding="0" cellspacing="3" style="margin:0px 5px">
	<thead>
	<tr class="col_title">
		<% if (selectedDataset.getDatasetVersions().length == 0) { %>
			<th>Delete</th>
		<% } %>
		<th> Array Name
		<th> Organism
		<th> Sex
		<th> Sample Type
		<th> Development Stage
		<th> Age Status
		<th> Age Range Min
		<th> Age Range Max
		<th> Initial Time Point
		<th> Organism Part
		<th> Category
		<th> Individual Genotype
		<th> Disease State
		<th> Separation Technique
		<th> Strain
		<th> Treatment
	</tr>
	</thead>
	<tbody>
<% 	
	for (int i=0; i<myArrays.length; i++) { %> 
		<tr id="<%=myArrays[i].getHybrid_id()%>"> 
			<% if (selectedDataset.getDatasetVersions().length == 0) { %>
				<td class="actionIcons">
					<div class="linkedImg delete"></div>
				</td>
			<% } %>
                        <td class="details cursorPointer"><%=myArrays[i].getHybrid_name()%></td>
			<td><%=myArrays[i].getOrganism()%></td><%

			String className = "";
			String warningClass="class='orange'";

			className = (!genderUnique ? warningClass : "");
			%><td <%=className%>><%=myArrays[i].getGender()%></td><%

			className = (!biosource_typeUnique ? warningClass : "");
			%><td <%=className%>><%=myArrays[i].getBiosource_type()%></td><%

			className = (!development_stageUnique ? warningClass : "");
			%><td <%=className%>><%=myArrays[i].getDevelopment_stage()%></td><%

			className = (!age_statusUnique ? warningClass : "");
			%><td <%=className%>><%=myArrays[i].getAge_status()%></td><%

			className = (!age_range_minUnique ? warningClass : "");
			%><td <%=className%>><%=myArrays[i].getAge_range_min()%></td><%

			className = (!age_range_maxUnique ? warningClass : "");
			%><td <%=className%>><%=myArrays[i].getAge_range_max()%></td><%

			className = (!time_pointUnique ? warningClass : "");
			%><td <%=className%>><%=myArrays[i].getTime_point()%></td><%

			className = (!organism_partUnique ? warningClass : "");
			%><td <%=className%>><%=myArrays[i].getOrganism_part()%></td><%

			className = (!genetic_variationUnique ? warningClass : "");
			%><td <%=className%>><%=myArrays[i].getGenetic_variation()%></td><%

			className = (!individual_genotypeUnique ? warningClass : "");
			%><td <%=className%>><%=myArrays[i].getIndividual_genotype()%></td><%

			className = (!disease_stateUnique ? warningClass : "");
			%><td <%=className%>><%=myArrays[i].getDisease_state()%></td><%

			className = (!separation_techniqueUnique ? warningClass : "");
			%><td <%=className%>><%=myArrays[i].getSeparation_technique()%></td><%

			className = (!strainUnique ? warningClass : "");
			%><td <%=className%>><%=myArrays[i].getStrain()%></td><%

			className = (!treatmentUnique ? warningClass : "");
			%><td <%=className%>><%=myArrays[i].getTreatment()%></td>
		</tr> <%
	}
%>

</tbody>
</table>
</div>
                <BR>

  <div class="deleteItem"></div>
