                <div id="median_div" class="showParameters">

                <TABLE class="parameters">
                        <TR>
                                <TD width="250px"><b>Filter Threshold:</b>
                                </TD> <TD>
                                <%
                                        selectName = "filterThreshold";
                                        selectedOption = "99";
                                        onChange = "";

                                        optionHash = new LinkedHashMap();
                                        optionHash.put("99", "select a value");
                                %>
                                <%@ include file="/web/common/selectBox.jsp" %>
                                </TD>
                        </TR>
                </TABLE>
                </div> <!-- end of median_div -->


