                <div id="neg_div" class="showParameters">
                <table class="parameters">
                        <tr>
                                <td width="250px"><b>Keep or Remove Probes:</b></td>
                                <td>
                                <%
                                        radioName = "codeLinkNegativeControlParameter2";
                                        selectedOption = "1";
                                        onClick = "";

                                        optionHash = new LinkedHashMap();
                                        optionHash.put("1", "keep" + tenSpaces);
                                        optionHash.put("2", "remove");
                                %>
                                <%@ include file="/web/common/radio.jsp" %>
                                </td>
                        </tr>
			<tr> <td colspan="2">&nbsp;</td> </tr>
                        <%
                        sectionName = "codeLinkNegativeControl";
                        topString = (String) filterText.get("negativeControlTopString");
                        bottomString = (String) filterText.get("negativeControlBottomString");
                        %>
                        <%@ include file="/web/datasets/include/formatGroupParameters.jsp" %>
                        <tr>
                                <td width="250px"><b>Trim Percentage:</b>
                                </td> <td>
                                <%
                                        selectName = "negParam";
                                        selectedOption = "0";
                                        onChange = "";

                                        optionHash = new LinkedHashMap();
                                        optionHash.put("0", "untrimmed");
                                        optionHash.put("0.05", "5%");
                                        optionHash.put("0.1", "10%");
                                        optionHash.put("0.2", "20%");
                                %>
                                <%@ include file="/web/common/selectBox.jsp" %>
                                </td>
                        </tr>
                </table>
                </div> <!-- end of neg_div -->



