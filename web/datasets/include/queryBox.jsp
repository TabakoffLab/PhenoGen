                                <td class="columnHeading"> <%=attributeName%>:</td>
                                <td>
                                <%

                                optionHash = new LinkedHashMap();
                                optionHash.put("All", "All");

                                for (int i=0; i<myCounts.length; i++) {
                                        optionHash.put(myCounts[i].getCountName(), myCounts[i].getCountName());
                                }

                                style=selectBoxStyle;
                                selectName = selectBoxName;
                                onChange = onChangeFunction;
                                selectedOption = (String) fieldValues.get(selectName);

                                %> <%@ include file="/web/common/selectBox.jsp" %>
                                </td>

