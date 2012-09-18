                <div id="listPhenotypes">
                        <div class="title">Copy values from:</div>
                        <table class="list_base">
                                <%
                                selectName = "copyFromID";
                                selectedOption = "None";
                                onChange = "displayPhenotypeValues()";

                                optionHash = new LinkedHashMap();
                                optionHash.put("None", "-- Select a phenotype --");

				for (int i=0; i<myPhenotypeValues.length; i++) {
                                	optionHash.put(Integer.toString(myPhenotypeValues[i].getParameter_group_id()),
                                        		myPhenotypeValues[i].getName());
				}
                                %>
                                <tr> <td> <%@ include file="/web/common/selectBox.jsp" %> </td></tr>
                        </table>
                </div>

