		<div class="brClear"></div>
                <div id="oneWayAnova_div" class="showParameters">
		<div class="brClear"></div>
                <TABLE class="list_base">
                        <TR class="title"><th colspan="2">P-value of Interest
                		<span class="info" title="
					Indicate the specific pair-wise 
					comparison in which you are interested, or the Factor Effect.  
					The Factor Effect is used to find pair-wise differences between 
					groups within the sample grouping.  When there are five or more 
					groups, you may only test for a Factor Effect.
					">
                    			<img src="<%=imagesDir%>icons/info.gif" alt="Help">
				</span>
			</th>
			</TR>
                        <TR><TD><input type="radio" checked name="pvalue" value="Model"></TD><TD>Factor Effect</TD></TR>
                        <%if (numGroups <= 4) {
                        	int start = (groups[0].getGroup_name().equals("Exclude") ? 1 : 0); 
                        	int end = (groups[0].getGroup_name().equals("Exclude") ? numGroups : numGroups - 1); 
                                for (int i=start; i<end; i++) {
                                        for (int j=start+1; j<end+1; j++) {
                                                if (i<j) {
                                                        String value = "Group "+groups[i].getGroup_number()+ " - Group "+groups[j].getGroup_number();
                                                        String text = "Group "+groups[i].getGroup_number()+" ("+
                                                                        groups[i].getGroup_name()+
                                                                        ") - Group "+groups[j].getGroup_number()+" ("+
                                                                        groups[j].getGroup_name()+")";
                                                        if ((String) fieldValues.get("pvalue") != null &&
                                                                ((String) fieldValues.get("pvalue")).equals(value)) {
                                                                %><TR><TD><input type="radio" name="pvalue" checked value="<%=value%>"></TD><TD><%=text%></TD></TR><%
                                                        } else {
                                                                %><TR><TD><input type="radio" name="pvalue" value="<%=value%>"></TD><TD><%=text%></TD></TR><%
                                                        }
                                                }
                                        }
                                }
                        } %>
                </TABLE>
                </div>


