	<div id="advancedSettingsButton" class="button menu">
		<b> <b> <b>Customize This View
			 <span class="info" title="Click to open window to customize the data that is displayed.  Click again to close window.">
			<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        </span>&nbsp;&nbsp;&nbsp; 
		</b> </b> </b>
	</div>
	<div id="advancedSettingsRegions">
		<div class="menuBar dragHandle">
			<div class="title">Choose which rows <!-- and columns --> you want to display</div>
		</div>

		<div class="list_container">

			<div class="title">Rows: </div>
			<table name="options" class="list_base" cellpadding="0" cellspacing="3">
				<tr>
					<% checked = (haveEQTL.equals("Y") ? " checked " : ""); %>
					<td> <input type="radio" name="haveEQTL" value="Y"  <%=checked%> 
							onClick="blurOthers()"> Genes (and all associated probesets) from the '<i><b><%=selectedGeneList.getGene_list_name()%></i></b>' list that meet restriction criteria <%=constraintInfo%>  
                                		<span class="info" title="Show all of the probesets associated with GENES (matched on gene symbol) in the '<b><i><%=selectedGeneList.getGene_list_name()%></i></b>' list 
								when any of the probesets associated with that gene meet the specified criteria.">
                                		<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                                		</span>
					</td>
				</tr>
				<tr><td class="indent" colspan="100%"><b>Restrict Probesets: </b></td></tr>
				<tr>
					<td class="indent"> <% checked = (inGeneList ? " checked " : ""); %>
					<input type="checkbox" name="rowRestrictions" value="inGeneList" <%=checked%> 
							onClick="blurOthers()">&nbsp;Probesets that are in the '<i><b><%=selectedGeneList.getGene_list_name()%></b></i>' list 
					</td>
				</tr>
				<tr>
					<% if (eQTLPValue != -99) {  %>
						<td class="indent"> <% checked = (meetPValue ? " checked " : ""); %>
						<input type="checkbox" name="rowRestrictions" value="meetPValue" <%=checked%> 
								onClick="blurOthers()">&nbsp;Probesets that have eQTL p-value < '<i><b><%=eQTLPValue%></b></i>'
						</td>
					<% } %>
				</tr>
				<tr>
					<% if (qtlListID != -99) {  %>
						<td class="indent"> <% checked = (inRegion ? " checked " : ""); %>
						<input type="checkbox" name="rowRestrictions" value="inRegion" <%=checked%> 
								onClick="blurOthers()">&nbsp;Probesets that meet restrictions specified for '<i><b><%=qtl_list_name%></b></i>' region 
						</td>
					<% } %>
				</tr>
                        	<tr>
					<% checked = (!haveEQTL.equals("Y") ? " checked " : ""); %>
					<td> <input type="radio" name="haveEQTL" value="N" <%=checked%> 
							onClick="blurOthers()"> Genes (and all associated probesets) from the '<i><b><%=selectedGeneList.getGene_list_name()%></b></i>' list with probesets that did not meet restriction criteria or were not considered in eQTL analysis</td>  
				</tr>
			</table>

<!-- 
			<div class="title">Columns: </div>
			<table name="options" class="list_base" cellpadding="0" cellspacing="3">
				<tr>
					<td>
						<table>
						<tr>
							<td>&nbsp;</td>	
                					<th class="noSort"><input type="checkbox" id="checkBoxHeader" 
									onClick="checkUncheckAll(this.id, 'eQTLColumns')">&nbsp;<b>eQTL Values </b></th>
						</tr>
						<tr>
							<td>&nbsp;</td>	
							<td> <% checked = (displayCoefficient? " checked " : ""); %>
							<input type="checkbox" name="eQTLColumns" value="displayCoefficient" <%=checked%>>&nbsp;Correlation Coefficient
							</td>
						</tr>
						<tr>
							<td>&nbsp;</td>	
							<td> <% checked = (displayRawPValue ? " checked " : ""); %>
							<input type="checkbox" name="eQTLColumns" value="displayRawPValue" <%=checked%>>&nbsp;Raw P-Value
							</td>
						</tr>
						<tr>
							<td>&nbsp;</td>	
							<td> <% checked = (displayAdjPValue ? " checked " : ""); %>
							<input type="checkbox" name="eQTLColumns" value="displayAdjPValue" <%=checked%>>&nbsp;Adjusted P-Value
							</td>
						</tr>
						</table>
					</td>
				<% //if (correlation) { %>
					<td>
						<table>
						<tr>
							<td>&nbsp;</td>	
                					<th class="noSort"><input type="checkbox" id="checkBoxHeader" 
									onClick="checkUncheckAll(this.id, 'correlationColumns')">&nbsp;<b>Correlation Analysis Values </b></th>
						</tr>
						<tr>
							<td>&nbsp;</td>	
							<td> <% checked = (displayCoefficient? " checked " : ""); %>
							<input type="checkbox" name="correlationColumns" value="displayCoefficient" <%=checked%>>&nbsp;Correlation Coefficient
							</td>
						</tr>
						<tr>
							<td>&nbsp;</td>	
							<td> <% checked = (displayRawPValue ? " checked " : ""); %>
							<input type="checkbox" name="correlationColumns" value="displayRawPValue" <%=checked%>>&nbsp;Raw P-Value
							</td>
						</tr>
						<tr>
							<td>&nbsp;</td>	
							<td> <% checked = (displayAdjPValue ? " checked " : ""); %>
							<input type="checkbox" name="correlationColumns" value="displayAdjPValue" <%=checked%>>&nbsp;Adjusted P-Value
							</td>
						</tr>
						</table>
					</td>
				<% //} %>
				</tr>
			</table>
-->
			<BR>
			<center> <input name="action" type="submit" value="Display" /></center>
		</div> <!-- div list_container -->
		<div class="brClear"></div>
	</div> <!-- end div#advancedSettingsRegions -->
