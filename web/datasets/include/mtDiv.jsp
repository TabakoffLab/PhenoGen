                <div id="mt_div" class="showParameters">
                <TABLE class="parameters">
                <TR>
                        <TD width="250px"><b>Multiple Test Method:</b></TD>
                        <TD>

                        <%
                        optionHash = new LinkedHashMap();
                        optGroupHash = new LinkedHashMap();
                        selectName = "mt_method";
                        onChange = "show_multiple_test_parameters()";
                        selectedOption = (String) fieldValues.get(selectName);
                        if (numGroups == 2) {
                                if (phenotypeParameterGroupID == -99) {
                                        optionHash.put("BH", "Benjamini and Hochberg");
                                        optionHash.put("BY", "Benjamini and Yekutieli");
                                        optionHash.put("Storey","Storey");
                                        optionHash.put("Bonferroni","Bonferroni");
                                        optionHash.put("Holm","Holm");
                                        optionHash.put("Hochberg","Hochberg");
                                        optionHash.put("SidakSS","SidakSS");
                                        optionHash.put("SidakSD","SidakSD");
                                        optionHash.put("minP","minP");
                                        optionHash.put("maxT","maxT");
                                        optionHash.put("No Adjustment","No Adjustment");
                                } else {
                                        optionHash.put("BH", "Benjamini and Hochberg");
                                        optionHash.put("BY", "Benjamini and Yekutieli");
                                        optionHash.put("Storey","Storey");
                                        optionHash.put("Bonferroni","Bonferroni");
                                        optionHash.put("Holm","Holm");
                                        optionHash.put("Hochberg","Hochberg");
                                        optionHash.put("SidakSS","SidakSS");
                                        optionHash.put("SidakSD","SidakSD");
                                        optionHash.put("No Adjustment","No Adjustment");
                                }

			} else {
                                optionHash.put("BH", "Benjamini and Hochberg");
                                optionHash.put("BY", "Benjamini and Yekutieli");
                                optionHash.put("Storey","Storey");
                                optionHash.put("Bonferroni","Bonferroni");
                                optionHash.put("Holm","Holm");
                                optionHash.put("Hochberg","Hochberg");
                                optionHash.put("SidakSS","SidakSS");
                                optionHash.put("SidakSD","SidakSD");
                                optionHash.put("No Adjustment","No Adjustment");
                        }

                        if (numGroups == 2) {
                                optGroupHash.put("0", "FDR");
                                optGroupHash.put("3", "General");
                                optGroupHash.put("8", "Permutation");
                                optGroupHash.put("10", "None");
                        } else {
                                optGroupHash.put("0", "FDR");
                                optGroupHash.put("3", "General");
                                optGroupHash.put("8", "None");
                        }

                        %><%@ include file="/web/common/selectBox.jsp" %>
						<% optGroupHash.clear(); %>
            			
                        </TD>
                </TR>
                </TABLE>
                </div>

