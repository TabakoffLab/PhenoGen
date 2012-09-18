                <div id="top_stats_div" class="showParameters">
                <TABLE class="parameters">
                <TR>
                        <TD width="250px"> <b>Method:</b> </TD>
                        <TD >
                        <%
                        optionHash = new LinkedHashMap();
                        if (phenotypeParameterGroupID != -99) {
                                // These are for correlation analysis
                                optionHash.put("pearson", "pearson");
                                optionHash.put("spearman", "spearman");
                        } else if (numGroups == 2) {
                                optionHash.put("parametric", "parametric");
                                optionHash.put("nonparametric", "nonparametric");
                                optionHash.put("2-Way ANOVA", "2-Way ANOVA");
                        } else {
                                //
                                // If this is a replicate experiment, add the Eaves test to the list of options
                                //
                                if (selectedDatasetVersion.getVersion_type().equals("R")) {
                                        optionHash.put("1-Way ANOVA", "1-Way ANOVA");
                                        optionHash.put("2-Way ANOVA", "2-Way ANOVA");
                                        optionHash.put("Noise distribution t-test", "Noise distribution t-test");
                                } else {
                                        optionHash.put("1-Way ANOVA", "1-Way ANOVA");
                                        optionHash.put("2-Way ANOVA", "2-Way ANOVA");
                                }
                        }

                        selectName = "stat_method";
                        onChange = "showStatisticsDescription() & showNonParametricWarning(" + giveWarning + ")";
                        selectedOption = (String) fieldValues.get(selectName);

                        %><%@ include file="/web/common/selectBox.jsp" %>

                        <% if (phenotypeParameterGroupID != -99) { %>
				<span class="info" title="<i>pearson</i> (parametric) assumes a linear relationship between your phenotype and gene expression.<BR><BR>
						<i>spearman</i> (non-parametric) does NOT assume a linear relationship.  Instead,
						it looks for a relationship of the relative order of samples (group means)
						within your phenotype compared to the relative order of samples (group means)
						within gene expression.">
                    			<img src="<%=imagesDir%>icons/info.gif" alt="Help">
				</span>
                        <% } else if (numGroups == 2) { %>
				<span class="info" title="<i>nonparametric</i> executes the Wilcoxon rank sum test using the R function 'wilcox.exact'.<BR><BR>
					<i>parametric</i> executes a two-sample t-test assuming equal variances using the R function 't.test'.<BR><BR>
					<i>2-Way ANOVA</i> is used when there are two characteristics (factors) of the samples that may affect expression.  
					These two characteristics (factors) must be indicated below for each sample.">
                    			<img src="<%=imagesDir%>icons/info.gif" alt="Help">
				</span>
                        <% } else { 
                                if (selectedDatasetVersion.getVersion_type().equals("R")) { %>
					<span class="info" title="
                        			<i>1-Way ANOVA</i> is a parametric test used when there are more than two sample groupings specified for the data set.<BR><BR>
						<i>2-Way ANOVA</i> is used when there are two characteristics (factors) of the samples that may affect expression.  
						These two characteristics (factors) must be indicated below for each sample.<BR><BR>
                        			<i>Noise distribution t-test</i> executes a t-test with noise distribution for replicate lines (Eaves et al. 2002)">
                    				<img src="<%=imagesDir%>icons/info.gif" alt="Help">
					</span>
                                <% } else { %>
					<span class="info" title="
                        			<i>1-Way ANOVA</i> is a parametric test used when there are more than two sample groupings specified for the data set.<BR><BR>
						<i>2-Way ANOVA</i> is used when there are two characteristics (factors) of the samples that may affect expression.  
						These two characteristics (factors) must be indicated below for each sample.<BR><BR>">
                    				<img src="<%=imagesDir%>icons/info.gif" alt="Help">
					</span>
				<% }
			} %>
                        </TD>
                </TR>
                </TABLE>
                </div>


