	<div id="filter_choice_div" class="showParameters">
		<table class="parameters">
                <tr>
                        <td width="250px"><b>Filtering Method:</b></td>
			<td>
            <% if (selectedDataset.getPlatform().equals(selectedDataset.AFFYMETRIX_PLATFORM)) {
                                        selectName = "filterMethod";
                                        selectedOption = "0";
                                        onChange = "show_oligo_filter_parameters()";

                                        optionHash = new LinkedHashMap();
                                        optionHash.put("0", "--- Select Filter Method ---");
                                        String analysisLevel=myParameterValue.getAnalysisLevelNormalizationParameter(selectedDataset.getDataset_id(),selectedDatasetVersion.getVersion(),dbConn);
                			if (new edu.ucdenver.ccp.PhenoGen.data.Array().EXON_ARRAY_TYPES.contains(selectedDataset.getArray_type())&&analysisLevel.equals("probeset")) {
                                        	//control probes aren't present in normalized probeset level
							} else {	
									//Need this option because control probes are still present in the transcript level						
									optionHash.put("AffyControlGenesFilter", "Affy Control Genes Filter");
											
							}
							if (new edu.ucdenver.ccp.PhenoGen.data.Array().EXON_ARRAY_TYPES.contains(selectedDataset.getArray_type())){
								optionHash.put("DABGPValueFilter", "DABG P-value Filter");
							}else{
								optionHash.put("MAS5AbsoluteCallFilter", "MAS5 Absolute Call Filter");
							}
							
                                        //optionHash.put("NegativeControlFilter", "Negative Control Filter");
                            if (selectedDataset.getArray_type().equals(new edu.ucdenver.ccp.PhenoGen.data.Array().MOUSE430V2_ARRAY_TYPE) ||
                                        	selectedDataset.getArray_type().equals(new edu.ucdenver.ccp.PhenoGen.data.Array().MOUSE_EXON_ARRAY_TYPE) ||
                                        	selectedDataset.getArray_type().equals(new edu.ucdenver.ccp.PhenoGen.data.Array().RAT_EXON_ARRAY_TYPE)) {
                                        	optionHash.put("HeritabilityFilter", "Heritability Filter");
											optionHash.put("QTLFilter", "bQTL/eQTL Filter");
							}
                            optionHash.put("GeneListFilter", "Gene List");
                            if (analysisType.equals("cluster")) {
                                                optionHash.put("VariationFilter", "Variation");
                                                optionHash.put("FoldChangeFilter", "Fold Change");
                            }
                                        %><%@ include file="/web/common/selectBox.jsp" %><%

                                } else if (selectedDataset.getPlatform().equals(selectedDataset.CODELINK_PLATFORM)) {
                                        selectName = "filterMethod";
                                        selectedOption = "0";
                                        onChange = "show_CodeLink_filter_parameters()";

                                        optionHash = new LinkedHashMap();
                                        optionHash.put("0", "--- Select Filter Method --- ");
                                        optionHash.put("CodeLinkControlGenesFilter", "CodeLink Control Genes Filter");
                                        optionHash.put("CodeLinkCallFilter", "CodeLink Call Filter");
                                        //optionHash.put("GeneSpringCallFilter", "GeneSpring Call Filter");
                                        optionHash.put("MedianFilter", "Median Filter");
                                        optionHash.put("CoefficientVariationFilter", "Coefficient Variation Filter");
					// Don't allow this filter for the eQTL version of the public rat dataset
					if ((selectedDataset.getCreator().equals("public") && 
							selectedDatasetVersion.getVersion() != 6) || 
						!selectedDataset.getCreator().equals("public")) {
                                        	optionHash.put("NegativeControlFilter", "Negative Control Filter");
					}
                                        if (selectedDataset.getArray_type().equals(new edu.ucdenver.ccp.PhenoGen.data.Array().CODELINK_RAT_ARRAY_TYPE)) {
                                        	optionHash.put("HeritabilityFilter", "Heritability Filter");
                                        	optionHash.put("QTLFilter", "bQTL/eQTL Filter");
					}
                                        optionHash.put("GeneListFilter", "Gene List");
                                        if (analysisType.equals("cluster")) {
                                                optionHash.put("VariationFilter", "Variation");
                                                optionHash.put("FoldChangeFilter", "Fold Change");
                                        }
                                        %><%@ include file="/web/common/selectBox.jsp" %> <%

                                } else if (selectedDataset.getPlatform().equals("cDNA")) {
                                        selectName = "filterMethod";
                                        selectedOption = "0";
                                        onChange = "show_cDNA_filter_parameters()";

                                        optionHash = new LinkedHashMap();
                                        optionHash.put("0", "--- Select Filter Method ---");
                                        optionHash.put("KeepAI,UTDDEST,NM", "Only Keep AI###, UTDDEST###, and NM_###");
                                        optionHash.put("RemoveUTDDEST", "Remove UTDDEST###");
                                        optionHash.put("RemoveESTs", "Remove ESTs");
                                        optionHash.put("FilterUsingFlagValues", "Filter using the 'Flag' values");
                                        optionHash.put("PercentGreaterThanBackgroundPlus2SDFilter", "% > Background + 2SD Filter");
                                        optionHash.put("LowIntensityFilter", "Low Intensity Filter");
                                        %><%@ include file="/web/common/selectBox.jsp" %><%
                                } %>
				<% if (selectedDataset.getPlatform().equals(selectedDataset.AFFYMETRIX_PLATFORM)) { 
					String infoTitle = 
						"<i>Affy Control Genes Filter</i> eliminates probesets on the Affymetrix chip "+ 
						"that are used for quality control purposes.  Most of the probesets represent "+
						"spike-in controls or "+ 
						"mRNA sequences that should NOT be present in your sample. <BR><BR> "+
						"<i>MAS5 Absolute Call Filter</i> filters probesets based on whether they are "+
						"given a present, marginal, or absent call "+
						"depending on the amount of hybridization across all probes within a set.  "+
						"The most conservative "+
						"approach would be to KEEP probesets if they are considered 'present' in all samples, "+
						"while a more liberal approach would be to REMOVE probesets that are 'absent' in all "+
						"samples.  Many people choose a compromise between these two extremes.<BR><BR> ";
						//"<i>Negative Control Filter</i> filters probesets based on a "+
						//"detection-level threshold calculated on probesets that should show no hybridization "+
						//"at all.   "+
						//"This filter is only recommended if you know for certain the spike-in controls were "+
						//not used during "+
						//"array processing.<BR><BR> "+
                                        	if (selectedDataset.getArray_type().equals(new edu.ucdenver.ccp.PhenoGen.data.Array().MOUSE430V2_ARRAY_TYPE) ||
                                        		selectedDataset.getArray_type().equals(new edu.ucdenver.ccp.PhenoGen.data.Array().MOUSE_EXON_ARRAY_TYPE) ||
                                        		selectedDataset.getArray_type().equals(new edu.ucdenver.ccp.PhenoGen.data.Array().RAT_EXON_ARRAY_TYPE)) {
							infoTitle = infoTitle + 
							"<i>Heritability Filter</i> eliminates probes/probesets based on the broad "+
							"sense heritability of their intensity in one of the public panels.<BR><BR> "; 
						}
						infoTitle = infoTitle + 
						"<i>Gene List Filter</i> can be used to look at a subset of genes, for instance "+
						"in a confirmatory  "+
						"analysis.";
                                        	if (analysisType.equals("cluster")) {
                                                	infoTitle = infoTitle + "<BR><BR>" +
								"<i>Variation Filter</i> filters probesets based on the variability of "+
								"their expression values "+
								"across samples.  <BR><BR> "+
								"<i>Fold Change Filter</i> filters probesets based on whether there is "+
								"a large difference between "+
								"the minimum and maximum sample expression values.  ";
                                        	}
					%>
					<span class="info" style="width:600px"; title="<%=infoTitle%>">
                    				<img src="<%=imagesDir%>icons/info.gif" alt="Help">
					</span>
				<% } else if (selectedDataset.getPlatform().equals(selectedDataset.CODELINK_PLATFORM)) { 
					String infoTitle = 
						"<i>CodeLink Control Genes Filter</i> eliminates probes "+ 
						"that are used for quality control purposes.  Most of the probesets represent spike-in "+
						"controls or "+ 
						"mRNA sequences that should NOT be present in your sample. <BR><BR> "+
						"<i>CodeLink Call Filter</i> filters probes based on the quality value assigned "+
						"by the CodeLink software, "+
						"with probes getting either a 'good' call or a 'low' call indicating whether the "+
						"probe signal "+
						"is near the background signal. The most conservative "+
						"approach would be to KEEP probes if they are considered 'good' in all samples, "+
						"while a more liberal approach would be to REMOVE probesets that are 'low' in all "+
						"samples.  Many people choose a compromise between these two extremes.<BR><BR> "+
						"<i>Median Filter</i> filters probes whose variation across samples is larger than the "+
						"median "+
						"variation, indicating that these probes have a higher potential of being "+
						"differentially expressed.<BR><BR> "+
						"<i>Coefficient Variation Filter</i> eliminates probes that have high variation "+
						"within your sample groupings.<BR><BR> "+
						"<i>Negative Control Filter</i> filters probes based on how many samples have "+
						"expression values above "+
						"or below a detection-level threshold that is calculated based on the negative "+
						"control probes on the array.<BR><BR> "; 
                                        	if (selectedDataset.getArray_type().equals(new edu.ucdenver.ccp.PhenoGen.data.Array().CODELINK_RAT_ARRAY_TYPE)) {
							infoTitle = infoTitle + 
							"<i>Heritability Filter</i> eliminates probes/probesets based on the broad "+
							"sense heritability of their intensity in one of the public panels.<BR><BR> "; 
						}
						infoTitle = infoTitle + 
						"<i>Gene List Filter</i> can be used to look at a subset of genes, for instance in "+
						"a confirmatory  "+
						"analysis.";
                                        	if (analysisType.equals("cluster")) {
                                                	infoTitle = infoTitle + "<BR><BR>" +
								"<i>Variation Filter</i> filters probesets based on the variability "+
								"of their expression values "+
								"across samples.  <BR><BR> "+
								"<i>Fold Change Filter</i> filters probesets based on whether there "+
								"is a large difference between "+
								"the minimum and maximum sample expression values.  ";
                                        	}
					%>
					<span class="info" title="<%=infoTitle%>">
                    				<img src="<%=imagesDir%>icons/info.gif" alt="Help">
					</span>
				<% } %>
                        </td>
                </tr>
		</table>
                </div> <!-- end of filter_choice_div -->

