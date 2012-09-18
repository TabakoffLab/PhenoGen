                <div id="storey_div" class="showParameters">
                <TABLE class="parameters">
                <TR>
                        <TD width="250px"><b>Method to estimate tuning:<%=twoSpaces%></b> 
                		<span class="info" title="For most cases, the <i>smoother</i>
					approach works better, but there are situations when it will fail.  
					Therefore, <i>bootstrap</i> is a safer option. ">
                    			<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                		</span>
			</TD>
                        <TD>
                        <%
                                optionHash = new LinkedHashMap();
                                optionHash.put("smoother", "smoother");
                                optionHash.put("bootstrap", "bootstrap");
                                selectName = "storey_parameter2";
                                onChange = "";
                                selectedOption = (String) fieldValues.get(selectName);

                        %>
                        <%@ include file="/web/common/selectBox.jsp" %>
                        </TD>

                </TR>

                </TABLE>
                </div>


