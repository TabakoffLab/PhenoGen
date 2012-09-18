                <div id="abs_call_div" class="showParameters" >
		<table class="parameters">
                        <tr>
                                <td width="250px"><b>Keep or Remove Probes:</b></td>
                                <td>
                                <%
                                        radioName = "absCallParameter2";
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
                        String sectionName = "absCall";
                        String topString = (String) filterText.get("absCallTopString");
                        String bottomString = (String) filterText.get("absCallBottomString");
                        %>
                        <%@ include file="/web/datasets/include/formatGroupParameters.jsp" %>
		</table>
                </div> <!-- end of abs_call_div -->


