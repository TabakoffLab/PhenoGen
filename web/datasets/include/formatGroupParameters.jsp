                <%
                if (numGroups < 3) {
                        for (int groupNum=0; groupNum<numGroups; groupNum++) {
                                int groupID = groupNum + 1;
                                %><TR>
                                        <!-- this creates a select list based on the number of arrays in each group -->
                                        <!-- groupCount[] contains the number of arrays in the group -->

                                        <TD width="250px"><b>Group <%=groupID%>:<%=twoSpaces%><%=groups[groupNum].getGroup_name()%></b> </TD>
                                        <TD>
					<%
		                        	selectName = sectionName + "Group" + groupID;
                        			selectedOption = "-99";
                        			onChange = "";
                        			optionHash = new LinkedHashMap();
		                        	optionHash.put("-99", "select a value");
		
                                		optionHash.put("-" + groupCount[groupNum], topString.replaceAll("#", "all " + new Integer(groupCount[groupNum]).toString()));
                                                for (int i=groupCount[groupNum]-1; i>0; i--) {
                                			optionHash.put("-" + i, topString.replaceAll("#", " at least " + i));
                                                }
						if (!bottomString.equals("")) {
                                                	for (int i=1; i<groupCount[groupNum]; i++) {
                                				optionHash.put(Integer.toString(i), bottomString.replaceAll("#",  " at least " + i));
                                                	}
                                			optionHash.put(Integer.toString(groupCount[groupNum]), bottomString.replaceAll("#", "all " + new Integer(groupCount[groupNum]).toString()));
						}
					%>
                			<%@ include file="/web/common/selectBox.jsp" %>
                                        </TD>
                                </TR><%
                        }
                } else {
                        %><TR>
                                <TD width="250px"><b>Criteria:<%=twoSpaces%></b> </TD>
                                <TD>
					<%
		                        selectName = sectionName + "Overall";
                        		selectedOption = "-99";
                        		onChange = "";
                        		optionHash = new LinkedHashMap();
		                        optionHash.put("-99", "select a value");
                                	optionHash.put("-1", topString.replaceAll("#", " 100% "));
                                	optionHash.put("-.75", topString.replaceAll("#", " at least 75% "));
                                	optionHash.put("-.5", topString.replaceAll("#", " at least 50% "));
                                	optionHash.put("-.25", topString.replaceAll("#", " at least 25% "));
					if (!bottomString.equals("")) {
                                		optionHash.put(".25", bottomString.replaceAll("#", " at least 25%" ));
                                		optionHash.put(".5", bottomString.replaceAll("#", " at least 50%" ));
                                		optionHash.put(".75", bottomString.replaceAll("#", " at least 75%" ));
                                		optionHash.put("1", bottomString.replaceAll("#", " 100%" ));
					} %>
                			<%@ include file="/web/common/selectBox.jsp" %>
                                </TD>
                        </TR><%
                }
                %>


