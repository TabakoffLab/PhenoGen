		<%
                	String pvalue_value = ((String) fieldValues.get("eaves_pvalue") != null ?
                                                (String) fieldValues.get("eaves_pvalue") : "0.05");
		%>
		<div id="eaves_div" class="showParameters">
		<TABLE class="parameters ">
		<TR>
                        <TD ><b>Alpha level threshold:</b>
			</TD><TD>
                		<span class="info" title="You may enter an alpha threshold value of '1' to see all probes.">
                    			<img src="<%=imagesDir%>icons/info.gif" alt="Help">
				</span>
                        <input type="text" name="eaves_pvalue" value="<%=pvalue_value%>">
                        </TD>
                </TR>
                </TABLE>

                </div>

