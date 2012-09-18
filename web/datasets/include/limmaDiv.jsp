                        <div id="limma_div" class="showParameters">
                        <table class="parameters">
                                <tr>
                        	<td width="180px"><b>Limma Method: </b>
				</td>
                                <td >
                                        <%
                                        selectName = "limma_div_parameter1";
                                        selectedOption = "";
                                        onChange = "";
                                        style = "";
                                        optionHash = new LinkedHashMap();
                                        optionHash.put("0", "-- Select an option --");
                                        optionHash.put("scale", "scale");
                                        optionHash.put("quantile", "quantile");
                                        %>
                                        <%@ include file="/web/common/selectBox.jsp" %>
                			<span class="info" title="<i>scale</i> simply scales all arrays to have the same median-absolute-deviation while the <i>quantile</i> method adjusts all arrays to have the same empirical distribution across arrays.  <i>quantile</i> is recommended over <i>scale</i>."> 
                    				<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                			</span>
                                </td>
                                </tr>
                        </table>
                        </div>


