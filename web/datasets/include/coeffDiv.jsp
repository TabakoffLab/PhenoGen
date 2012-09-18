                <div id="coeff_div" class="showParameters">
                <table class="parameters">

                        <tr>
                                <td width="250px"><b>Select 'and' or 'or':</b>
                                </td> 
                                <td>
                                <%
                                        radioName = "coeffParameter2";
                                        selectedOption = "1";
                                        onClick = "";

                                        optionHash = new LinkedHashMap();
                                        optionHash.put("1", "or" + tenSpaces);
                                        optionHash.put("2", "and");
                                %>
                                <%@ include file="/web/common/radio.jsp" %>
                                </td>
                        </tr>
			<tr> <td colspan="2">&nbsp;</td> </tr>
                        <%
                        if (numGroups < 3 && numGroups != 0) {
                                %><tr>
                                        <td width="250px"><b>Group 1:<%=twoSpaces%><%=groups[0].getGroup_name()%></b>
                                        </td> <td>
                                <%
                                        selectName = "coeffGroup1";
                                        selectedOption = "99";
                                        onChange = "";

                                        optionHash = new LinkedHashMap();
                                        optionHash.put("99", "select a value ");
                                %>
                                <%@ include file="/web/common/selectBox.jsp" %>
                                        </td>
                                </tr>
                                <tr>
                                        <td width="250px"><b>Group 2:<%=twoSpaces%><%=groups[1].getGroup_name()%></b>
                                        </td> <td >
                                <%
                                        selectName = "coeffGroup2";
                                        selectedOption = "99";
                                        onChange = "";

                                        optionHash = new LinkedHashMap();
                                        optionHash.put("99", "select a value ");
                                %>
                                <%@ include file="/web/common/selectBox.jsp" %>
                                        </td>
                                </tr>
                        <%
                        } else {
                                %><tr>
                                        <td width="250px"><b>For All Groups:<%=twoSpaces%></b>
                                        </td> <td >
                                <%
                                        selectName = "coeffOverall";
                                        selectedOption = "99";
                                        onChange = "";

                                        optionHash = new LinkedHashMap();
                                        optionHash.put("99", "select a value ");
                                %>
                                <%@ include file="/web/common/selectBox.jsp" %>
                                        </td>
                                </tr>
                        <%
                        }
                        %>
                </table>
                </div> <!-- end of coeff_div -->


