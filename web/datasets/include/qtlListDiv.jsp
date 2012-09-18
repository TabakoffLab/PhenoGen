                <div id="qtl_list_div" class="showParameters">
                <table class="parameters">
                        <tr>
                                <td width="250px"><b>Select QTL list:</b>
				</td>
                                <td><%
                                optionHash = new LinkedHashMap();
                                selectName = "qtlListID";
                                selectedOption = "-99";

                                optionHash.put("-99", "---------- None selected ----------");

				log.debug("before getQTLLists");
                                QTL[] myQTLLists =
                                        myQTL.getQTLLists(userID,
                                        selectedDataset.getOrganism(),
                                        dbConn);
				log.debug("after getQTLLists. there are " + myQTLLists.length + " QTL lists");
				for (QTL thisQTL : myQTLLists) {
                                        optionHash.put(Integer.toString(thisQTL.getQtl_list_id()), 
                                                thisQTL.getQtl_list_name()); 
                                }
                                %>
                                <%@ include file="/web/common/selectBox.jsp" %>
				</td>
				</tr>
				<tr><td>&nbsp;</td></tr>
                        	<tr>
                                	<td width="250px"><b>Which panel:</b>
					</td>
                                	<td><%
                                        	selectName = "tissue";
                                        	selectedOption = "";
                                        	onClick = "";

                                        	optionHash = new LinkedHashMap();
						if (selectedDataset.getPlatform().equals(selectedDataset.AFFYMETRIX_PLATFORM)) { 
							if (selectedDataset.getArray_type().equals(myArray.MOUSE_EXON_ARRAY_TYPE) || 
								selectedDataset.getArray_type().equals(myArray.RAT_EXON_ARRAY_TYPE)) {
								if (selectedDataset.getArray_type().equals(myArray.MOUSE_EXON_ARRAY_TYPE)) {
                                        				optionHash.put("Whole Brain", "Whole Brain");
								} else if (selectedDataset.getArray_type().equals(myArray.RAT_EXON_ARRAY_TYPE)) {
                                        				optionHash.put("Whole Brain", "Whole Brain");
                                        				optionHash.put("Heart", "Heart");
                                        				optionHash.put("Liver", "Liver");
                                        				optionHash.put("Brown Adipose", "Brown Adipose");
								}
							} else {
                                        			optionHash.put("Whole Brain", "Whole Brain");
							}
						} else if (selectedDataset.getPlatform().equals(selectedDataset.CODELINK_PLATFORM)) {
                                        		optionHash.put("Whole Brain", "Whole Brain");
						}
                                	%>
                                	<%@ include file="/web/common/selectBox.jsp" %>
					</td>
                        	</tr>
                </table>
                </div> <!-- end of qtl_list_div -->


