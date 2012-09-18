                <div id="twoWayAnova_div" class="showParameters" style="width:550px;">
                <%
                //
                // Fill-up the client-side criteria array
                // Only do it if this isn't a correlation analysis
                //
                int rowNum=0;
                int criterionNumber=0;
                Enumeration keys = null;
                Enumeration elements = null;

                if (phenotypeParameterGroupID == -99) {
                        if (!formName.equals("cluster.jsp")) {
                                footerPosition = myArrays.length*30;
                        }
                        %><script language="JAVASCRIPT" type="text/javascript"><%
                        keys = criteriaList.keys();
                        elements = criteriaList.elements();
                        while (elements.hasMoreElements()) {
                                %>var criteriaArray = new Array();<%
                                String element = (String) elements.nextElement();
                                for (int j=0; j<myArrays.length; j++) {
                                        if (element.equals("cell_line")) {
                                                %>criteriaArray[<%=j%>] = "<%=myArrays[j].getCell_line()%>"; <%
                                                %>criteriaNames[<%=rowNum%>] = "Cell Line"; <%
                                        } else if (element.equals("gender")) {
                                                %>criteriaArray[<%=j%>] = "<%=myArrays[j].getGender()%>"; <%
                                                %>criteriaNames[<%=rowNum%>] = "Gender"; <%
                                        } else if (element.equals("biosource_type")) {
                                                %>criteriaArray[<%=j%>] = "<%=myArrays[j].getBiosource_type()%>"; <%
                                                %>criteriaNames[<%=rowNum%>] = "Biosource Type"; <%
                                        } else if (element.equals("development_stage")) {
                                                %>criteriaArray[<%=j%>] = "<%=myArrays[j].getDevelopment_stage()%>"; <%
                                                %>criteriaNames[<%=rowNum%>] = "Development Stage"; <%
                                        } else if (element.equals("age_status")) {
                                                %>criteriaArray[<%=j%>] = "<%=myArrays[j].getAge_status()%>"; <%
                                                %>criteriaNames[<%=rowNum%>] = "Age Status"; <%
                                        } else if (element.equals("age_range_min")) {
                                                %>criteriaArray[<%=j%>] = "<%=Double.toString(myArrays[j].getAge_range_min())%>"; <%;
                                                %>criteriaNames[<%=rowNum%>] = "Minimum Age"; <%
                                        } else if (element.equals("age_range_max")) {
                                                %>criteriaArray[<%=j%>] = "<%=Double.toString(myArrays[j].getAge_range_max())%>"; <%;
                                                %>criteriaNames[<%=rowNum%>] = "Maximum Age"; <%
                                        } else if (element.equals("time_point")) {
                                                %>criteriaArray[<%=j%>] = "<%=myArrays[j].getTime_point()%>"; <%
                                                %>criteriaNames[<%=rowNum%>] = "Time Point"; <%
                                        } else if (element.equals("organism_part")) {
                                                %>criteriaArray[<%=j%>] = "<%=myArrays[j].getOrganism_part()%>"; <%
                                                %>criteriaNames[<%=rowNum%>] = "Organism Part"; <%
                                        } else if (element.equals("genetic_variation")) {
                                                %>criteriaArray[<%=j%>] = "<%=myArrays[j].getGenetic_variation()%>"; <%
                                                %>criteriaNames[<%=rowNum%>] = "Genetic Modification"; <%
                                        } else if (element.equals("individual_genotype")) {
                                                %>criteriaArray[<%=j%>] = "<%=myArrays[j].getIndividual_genotype()%>"; <%
                                                %>criteriaNames[<%=rowNum%>] = "Individual Genotype"; <%
                                        } else if (element.equals("disease_state")) {
                                                %>criteriaArray[<%=j%>] = "<%=myArrays[j].getDisease_state()%>"; <%
                                                %>criteriaNames[<%=rowNum%>] = "Disease State"; <%
                                        } else if (element.equals("separation_technique")) {
                                                %>criteriaArray[<%=j%>] = "<%=myArrays[j].getSeparation_technique()%>"; <%
                                                %>criteriaNames[<%=rowNum%>] = "Separation Technique"; <%
                                        } else if (element.equals("target_cell_type")) {
                                                %>criteriaArray[<%=j%>] = "<%=myArrays[j].getTarget_cell_type()%>"; <%
                                                %>criteriaNames[<%=rowNum%>] = "Target Cell Type"; <%
                                        } else if (element.equals("strain")) {
                                                %>criteriaArray[<%=j%>] = "<%=myArrays[j].getStrain()%>"; <%
                                                %>criteriaNames[<%=rowNum%>] = "Strain"; <%
                                        } else if (element.equals("expName")) {
                                                %>criteriaArray[<%=j%>] = "<%=myArrays[j].getExperiment_name()%>"; <%
                                                %>criteriaNames[<%=rowNum%>] = "Experiment Name"; <%
                                        } else if (element.equals("treatment")) {
                                                %>criteriaArray[<%=j%>] = "<%=myArrays[j].getTreatment()%>"; <%
                                                %>criteriaNames[<%=rowNum%>] = "Treatment"; <%
                                        }
                                }
                                %>criteriaValuesArray[<%=rowNum%>] = criteriaArray; <%
                                rowNum++;
                        }
                %></script>
		<div class="brClear"></div>
                <input type="hidden" id="numArrays" value=<%=myArrays.length%>>
                <table class="list_base">
                        <tr class="title"><th colspan="2">P-value of Interest
                		<span class="info" title="
					<i>Overall model significance</i> indicates that you are interested in genes 
					that differ by either factor.<BR><BR>
					<i>Significance of Factor 1</i> indicates that you are looking for genes that differ 
					according to their value of 
					Factor 1 after accounting for the effect of Factor 2 on expression. <BR><BR> 
					<i>Significance of Interaction</i> indicates that you are interested in 
					genes whose relationship between expression and Factor 1 is 
					dependent on the value of Factor 2 and vice versa.">
                    			<img src="<%=imagesDir%>icons/info.gif" alt="Help">
				</span>
			</th>
			</tr>
                        <tr><td><input type="radio" checked name="twoWayPValue" value="Model"></td><td>Overall Model Significance</td></tr>
                        <tr><td><input type="radio" name="twoWayPValue" value="Factor1"></td><td>Significance of Factor 1</td></tr>
                        <tr><td><input type="radio" name="twoWayPValue" value="Factor2"></td><td>Significance of Factor 2</td></tr>
                        <tr><td><input type="radio" name="twoWayPValue" value="Interaction"></td><td>Significance of Interaction</td></tr>
		</table>
		<BR><BR>
		<table class="list_base" name="items">
                        <tr class="title"><th colspan="100%">2-Way ANOVA Factors
                		<span class="info" title="
					The two characteristics that you would like to include in 
					your analysis can either be chosen from the drop-down menus 
					(which are attributes entered in the database that 
					differ between samples) or manually entered.  Factors entered as 
					numbers will be treated as continuous variables and factors entered 
					as character values will be treated as categorical.
					">
                    			<img src="<%=imagesDir%>icons/info.gif" alt="Help">
				</span>
			</th>
			</tr>
                        <tr class="col_title">
                                <th class="noSort">Sample<BR>Name</th>
                                <th class="noSort">
                                        <%
                                                optionHash = new LinkedHashMap();
                                                optionHash.put("None", "-- Choose an option --");

                                                keys = criteriaList.keys();
                                                criterionNumber = 0;
                                                while (keys.hasMoreElements()) {
                                                        String key = (String) keys.nextElement();
                                                        optionHash.put(Integer.toString(criterionNumber), key);
                                                        criterionNumber++;
                                                }
                                                optionHash.put("UserInput", "- User Input -");

                                                selectName = "factor1_criterion";
                                                onChange = "showFactorValues(1)";
                                                selectedOption = (String) fieldValues.get(selectName);

                                        %><%@ include file="/web/common/selectBox.jsp" %>
                                        <BR>
                                        <%
                                                String fieldName = "factor1_name";
                                                String fieldName_value = (fieldValues.get(fieldName) == null ?
                                                                        "Factor 1" :
                                                                        (String) fieldValues.get(fieldName));
                                        %>
                                        <input type="text" name="<%=fieldName%>" id="<%=fieldName%>" value="<%=fieldName_value%>">
                                </th>

                                <th class="noSort">
                                        <%
                                                optionHash = new LinkedHashMap();
                                                optionHash.put("None", "-- Choose an option --");

                                                keys = criteriaList.keys();
                                                criterionNumber = 0;
                                                while (keys.hasMoreElements()) {
                                                        String key = (String) keys.nextElement();
                                                        optionHash.put(Integer.toString(criterionNumber), key);
                                                        criterionNumber++;
                                                }
                                                optionHash.put("UserInput", "- User Input -");

                                                selectName = "factor2_criterion";
                                                onChange = "showFactorValues(2)";
                                                selectedOption = (String) fieldValues.get(selectName);

                                        %><%@ include file="/web/common/selectBox.jsp" %>
                                        <BR>
                                        <%
                                                fieldName = "factor2_name";
                                                fieldName_value = (fieldValues.get(fieldName) == null ?
                                                                        "Factor 2" :
                                                                        (String) fieldValues.get(fieldName));
                                        %>
                                        <input type="text" name="<%=fieldName%>" id="<%=fieldName%>" value="<%=fieldName_value%>">
                                </th>
                        </tr>
                        <% for (int i=0; i<myArrays.length; i++) {
                                String factor1_value = (String) fieldValues.get("factor1_"+i);
                                String factor2_value = (String) fieldValues.get("factor2_"+i);
                                %>
                                <tr id="<%=myArrays[i].getHybrid_id()%>">
                                        <td class="details cursorPointer" tabindex=0><%=myArrays[i].getHybrid_name()%></td>
                                        <td><input type="text" id="factor1_<%=i%>" name="factor1_<%=i%>" value="<%=factor1_value%>" tabindex=1>
                                        </td>
                                        <td><input type="text" id="factor2_<%=i%>" name="factor2_<%=i%>" value="<%=factor2_value%>" tabindex=2>
                                        </td>
                                </tr>
                        <% } %>
                        </table>
                <% } %>
		<div style="clear:both"> </div>
                </div>
		<div class="arrayDetails"></div>


