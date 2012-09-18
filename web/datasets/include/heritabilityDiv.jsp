                <div id="heritability_div" class="showParameters">
                <table class="parameters">
			<% if (selectedDataset.getPlatform().equals(selectedDataset.AFFYMETRIX_PLATFORM)) { %>
                        	<tr>
                                	<td width="250px"><b>Which panel:</b>
					</td>
                                	<td><%
                                        	selectName = "heritabilityPanel";
                                        	selectedOption = "";
                                        	onClick = "";

                                        	optionHash = new LinkedHashMap();

						if (selectedDataset.getArray_type().equals(myArray.MOUSE_EXON_ARRAY_TYPE) || 
							selectedDataset.getArray_type().equals(myArray.RAT_EXON_ARRAY_TYPE)) {
							String analysisLevel = myParameterValue.getAnalysisLevelNormalizationParameter(selectedDataset.getDataset_id(), selectedDatasetVersion.getVersion(), dbConn);
							String annotationLevel = myParameterValue.getAnnotationLevelNormalizationParameter(selectedDataset.getDataset_id(), selectedDatasetVersion.getVersion(), dbConn);
							if (selectedDataset.getArray_type().equals(myArray.MOUSE_EXON_ARRAY_TYPE)) {
								optionHash.put("LXS Brain", "LXS" + tenSpaces);
								/*if (analysisLevel.equals("transcript")) {
									if (annotationLevel.equals("core")) {
                                        					optionHash.put("LXS.coreTrans", "LXS" + tenSpaces);
									} else {
                                        					optionHash.put("LXS.fullTrans", "LXS" + tenSpaces);
									}
								}*/
							} else if (selectedDataset.getArray_type().equals(myArray.RAT_EXON_ARRAY_TYPE)) {
								optionHash.put("HXB/BXH Brain", "HXB/BXH Brain");
                                optionHash.put("HXB/BXH Heart", "HXB/BXH Heart");
                                optionHash.put("HXB/BXH Liver", "HXB/BXH Liver");
                                optionHash.put("HXB/BXH Brown Adipose", "HXB/BXH Brown Adipose");
								/* OLD METHOD for EXON ARRAYS
								if (analysisLevel.equals("transcript")) {
									if (annotationLevel.equals("core")) {
                                        					optionHash.put("HXB_BXH.brain.coreTrans", "HXB/BXH Brain");
                                        					optionHash.put("HXB_BXH.heart.coreTrans", "HXB/BXH Heart");
                                        					optionHash.put("HXB_BXH.liver.coreTrans", "HXB/BXH Liver");
                                        					optionHash.put("HXB_BXH.bat.coreTrans", "HXB/BXH Brown Adipose");
									} else {
                                        					optionHash.put("HXB_BXH.brain.fullTrans", "HXB/BXH Brain");
                                        					optionHash.put("HXB_BXH.heart.fullTrans", "HXB/BXH Heart");
                                        					optionHash.put("HXB_BXH.liver.fullTrans", "HXB/BXH Liver");
                                        					optionHash.put("HXB_BXH.bat.fullTrans", "HXB/BXH Brown Adipose");
									}
								}*/
							}
						} else {
                                        		optionHash.put("BXD", "BXD" + tenSpaces);
                                        		optionHash.put("Inbred", "Inbred");
						}
                                	%>
                                	<%@ include file="/web/common/selectBox.jsp" %>
					</td>
                        	</tr>
			<% } %>
			<tr> <td colspan="2">&nbsp;</td> </tr>
                        <tr>
                                <td width="250px"><b>Minimum Heritability Criteria:</b>
				</td>
                                <td><input type="text" name="heritabilityLevel" value="">
					<span class="info" style="width:600px"; title="All probe(set)s with a heritability below this criteria will be eliminated.  Values should be between 0 and 1.">
                    				<img src="<%=imagesDir%>icons/info.gif" alt="Help">
					</span>
				</td>
                        </tr>
                </table>
                </div> <!-- end of heritability_div -->


