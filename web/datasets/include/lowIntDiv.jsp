                <div id="low_int_div" class="showParameters">
                <table class="parameters">
                        <tr><th class=center colspan=2>Specify the Following Parameters:</th></tr>
                        <%
                        sectionName = "lowInt";
                        topString = (String) filterText.get("lowIntTopString");
                        bottomString = "";
                        %>
                        <%@ include file="/web/datasets/include/formatGroupParameters.jsp" %>

                        <tr>
                                <td>Threshold
                                <input name="lowIntThreshold">
                                </td>
                                <td><b>Select 'Mean' or 'Med' intensities:</b>
                                <%
                                        selectName = "parameter3";
                                        selectedOption = "mean";
                                        onChange = "";

                                        optionHash = new LinkedHashMap();
                                        optionHash.put("mean", "Mean");
                                        optionHash.put("med", "Med");
                                %>
                                <%@ include file="/web/common/selectBox.jsp" %>
                                </td>
                        </tr>
                </table>
                </div> <!-- end of low_int_div -->


