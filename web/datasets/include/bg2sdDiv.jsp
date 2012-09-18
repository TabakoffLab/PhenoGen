                <div id="bg2sd_div" class="showParameters">
                <table >
                        <tr><th class=center colspan=2>Specify the Following Parameters:</th></tr>
                        <%
                        sectionName = "bg2sd";
                        topString = (String) filterText.get("bg2sdTopString");
                        bottomString = "";
                        %>
                        <%@ include file="/web/datasets/include/formatGroupParameters.jsp" %>

                        <tr>
                                <td>Threshold
                                <%
                                        selectName = "bg2sdThreshold";
                                        selectedOption = "9";
                                        onChange = "";

                                        optionHash = new LinkedHashMap();
                                        optionHash.put("99", "select a value");
                                %>
                                <%@ include file="/web/common/selectBox.jsp" %>
                                </td>
                        </tr>
                </table>
                </div> <!-- end of bg2sd_div -->


