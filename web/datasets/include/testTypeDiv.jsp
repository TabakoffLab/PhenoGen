                <div id="testType_div" class="showParameters">
                <TABLE class="parameters">
                <TR>
                        <TD width="250px"><b>Type of test for permutation:</b> </TD>
                        <TD>
                        <%
                                optionHash = new LinkedHashMap();
                                optionHash.put("t", "T");
                                optionHash.put("t.equalvar", "T equal variance");
                                optionHash.put("wilcoxon", "Wilcoxon");
                                optionHash.put("f", "F");

                                selectName = "testTypeDiv_parameter2";
                                onChange = "";
                                selectedOption = (String) fieldValues.get(selectName);

                        %><%@ include file="/web/common/selectBox.jsp" %><%

                        %>
                        </TD>

                </TR>


                <TR>
                        <TD width="250px"><b>Number of permutations</b></TD>
                        <TD>
                                <%
                                optionHash = new LinkedHashMap();
                                optionHash.put("5000", "5000");
                                optionHash.put("10000", "10000");
                                optionHash.put("0", "Maximum");
                                selectName = "testTypeDiv_parameter3";
                                onChange = "";
                                selectedOption = (String) fieldValues.get(selectName);

                                %><%@ include file="/web/common/selectBox.jsp" %>
                        </TD>
                </TR>
                </TABLE>
                </div>


