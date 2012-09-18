
<div class="brClear"></div>
<div class="title">Identifier Types</div>
<table class="list_base">
	<tr class="col_title">
		<th class="noSort">Available Target Databases </th>
		<th class="noSort">Specific Affymetrix Arrays </th>
		<th class="noSort">Specific CodeLink Arrays </tth>
	</tr>
	<tr>
        	<td ><input type="checkbox" id="checkBoxHeader" 
			onClick="checkUncheckAll(this.id, 'iDecoderChoice')"><b>&nbsp;Check/Uncheck All</b></td>
        	<td ><input type="checkbox" id="checkBoxHeader2" 
			onClick="checkUncheckAll(this.id, 'AffymetrixArrayChoice') & checkUncheckAffyID(this.id)"><b>&nbsp;Check/Uncheck All</b></td>
        	<td ><input type="checkbox" id="checkBoxHeader3" 
			onClick="checkUncheckAll(this.id, 'CodeLinkArrayChoice') & checkUncheckCodeLinkID(this.id)"><b>&nbsp;Check/Uncheck All</b></td>
	</tr>
	<tr>
	<td style="vertical-align:top"><!-- Target databases -->
	<table>
		<tr><td> <!-- 1st column -->
		<table>
			<% for (int i=0; i<10; i++) { %>
				<% if (!(formName.equals("saveAs.jsp") && identifierTypes[i].equals("Genetic Variations"))) { %>
					<tr>
						<td> <input type='checkbox' name='iDecoderChoice' value='<%=identifierTypes[i]%>'></td>
						<td><%=identifierTypes[i]%></td>
					</tr>
				<% } %>
			<% } %>
		</table>
		</td>

		<td> <!-- 2nd column -->
		<table>
			<% for (int i=10; i<identifierTypes.length; i++) { %>
				<% if (!(formName.equals("saveAs.jsp") && identifierTypes[i].equals("Genetic Variations"))) { %>
					<tr>
						<td> <input type='checkbox' name='iDecoderChoice' value='<%=identifierTypes[i]%>'></td>
						<td><%=identifierTypes[i]%></td>
					</tr>
				<% } %>
			<% } %>
		</table>
		</td></tr>
	</table>
	</td>
	<td> <!-- Affy Arrays -->
	<table>
		<% for (int i=0; i<affyBoxes.length; i++) { %>
			<tr>
				<td> <input type='checkbox' name='AffymetrixArrayChoice' value='<%=affyBoxes[i]%>' onClick='clickAffyID()'> </td>
				<td><%=affyBoxes[i]%></td>
			</tr>
		<% } %>
	</table>
	</td>
	<td style="vertical-align:top"> <!-- CodeLink Arrays -->
	<table>
		<% for (int i=0; i<codeLinkBoxes.length; i++) { %>
			<tr>
				<td> <input type='checkbox' name='CodeLinkArrayChoice' value='<%=codeLinkBoxes[i]%>' onClick='clickCodeLinkID()'> </td>
				<td><%=codeLinkBoxes[i]%></td>
			</tr>
		<% } %>
	</table>
	</tr>
</table>

