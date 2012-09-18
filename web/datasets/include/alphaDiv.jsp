		<%
		String pvalue_value = ((String) fieldValues.get("pvalue") != null ? 
                	(String) fieldValues.get("pvalue") : "0.05");
		%>
                <div id="alpha_div" class="showParameters">
                <TABLE class="parameters">
                <TR>
                        <TD width="250px">
                	<div id="storeyAlpha_div">
				<b>Q-value threshold for significance:<%=twoSpaces%></b> 
			</div>
                	<div id="fdrAlpha_div">
			<b>FDR threshold for significance:<%=twoSpaces%></b> 
			</div>
                	<div id="otherAlpha_div">
			<b>p-value threshold for significance:<%=twoSpaces%></b> 
			</div>
                		<span class="info" title="Any probe(set)s with adjusted p-values 
					or FDRs that fall below this threshold will be considered 
					significant and retained for your gene list. ">
                    			<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                		</span>
			</TD>
			<TD>
                        	<input type="text" name="pvalue" value="<%=pvalue_value%>">
                        </TD>
                </TR>
                </TABLE>
                </div>


