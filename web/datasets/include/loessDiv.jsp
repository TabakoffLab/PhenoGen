                        <div id="loess_div" class="showParameters">
                        <table class="parameters">
                                <tr>
                        	<td width="180px"><b>Family.loess: </b></td>
                                <td>
                                        <%
                                        selectName = "loess_div_parameter1";
                                        selectedOption = "";
                                        onChange = "";
                                        style = "";
                                        optionHash = new LinkedHashMap();
                                        optionHash.put("0", "-- Select an option --");
                                        optionHash.put("gaussian", "gaussian");
                                        optionHash.put("symmetric", "symmetric");
                                        %>
                                        <%@ include file="/web/common/selectBox.jsp" %>
                			<span class="info" title="a <i>gaussian</i> cyclic loess normalization uses a less robust method for eliminating technical differences amongst arrays than the <i>symmetric</i> method."> 
                    				<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                			</span>
                                </td>
                                </tr>
                        </table>
                        </div>


