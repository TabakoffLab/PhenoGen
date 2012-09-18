                <div id="choice_div" style="margin:10px;">
                        <table class="list_base">
                        <tr>
                                <td>
                                <%
                                optionHash = new LinkedHashMap();
                                optionHash.put("upload", "Upload Phenotype Data File" + fiveSpaces);
                                optionHash.put("new", "Enter New Phenotype Data" + fiveSpaces);
                                optionHash.put("copy", "Copy Existing Phenotype Data");

                                radioName = "choice";
                                selectedOption = "new";
                                onClick = "showPhenotypeFields()";
                                %>
                                <%@ include file="/web/common/radio.jsp" %>
                                </td>
                        </tr>
                        </table>
                </div>

