        <div id="kmeans_div" class="showParameters">
        <TABLE class="parameters">
                <TR>
                <TD width="250px"><b>Cluster Object:</b>  </TD>
                <TD>
                <%
                        optionHash = new LinkedHashMap();
                        optionHash.put("samples", "samples");
                        optionHash.put("groups", "groups");
                        optionHash.put("genes", "probes");
                        selectName = "clusterObjectKmeans";
                        onChange = "";
                        onChange = "displayClusterObject()"; 
                        selectedOption = (String) fieldValues.get(selectName);

                	%><%@ include file="/web/common/selectBox.jsp" %>
				<span class="info" title="Genes (i.e., probes), samples, or groups of samples can be clustered (do you want
					to know which genes are similar,  which samples are similar, or which groups of samples are similar?)">
                    			<img src="<%=imagesDir%>icons/info.gif" alt="Help">
				</span>
                </TD></TR>

		<TR>
		<TD width="250px"><b>Distance Measure:</b>  </TD>
                <TD>
                        <%
			optionHash = new LinkedHashMap();
                        optionHash.put("one.minus.corr", "1 - correlation");
                        optionHash.put("euclidean", "Euclidean");
                        selectName = "distanceKmeans";
                        onChange = "";
                        selectedOption = (String) fieldValues.get(selectName);

                        %><%@ include file="/web/common/selectBox.jsp" %>
				<span class="info" title="The distance measure is how dissimilarity between cluster objects is
					calculated.  <i>1-correlation</i> is recommended because it is not dependent
					on mean intensity or variation across values.">
                    			<img src="<%=imagesDir%>icons/info.gif" alt="Help">
				</span>
                </TD></TR>

                <TR>
                <TD width="250px"><b>Use Group Means or Individual Sample Values:</b>  </TD>
                <TD>
                        <%
                        optionHash = new LinkedHashMap();
                        optionHash.put("FALSE", "sampleValues");
                        if (selectedDatasetVersion.getNumber_of_non_exclude_groups() == 2) {
                                        optionHash.put("NA", "groupMeans (Not Available)");
                        } else {
                                        optionHash.put("TRUE", "groupMeans");
                        }
                        selectName = "groupMeansKmeans";
                        onChange = "displayClusterObject()";
                        selectedOption = (String) fieldValues.get(selectName);

                        %><%@ include file="/web/common/selectBox.jsp" %>
				<span class="info" title="Clustering can be done using individual sample expression values or using
					the mean expression values across samples within a group (specified prior to normalization).
					When you have designated only two groups in your dataset, the group means option is NOT available.">
                    			<img src="<%=imagesDir%>icons/info.gif" alt="Help">
				</span>
		</TD> </TR>
                <TR>
                <TD ><b># of clusters to report:</b>  </TD>
                <TD>
                <%
                        String numClustersKmeans_value = (numClustersKmeans != null ? numClustersKmeans : "");
                %>
	                <input type="text" name="numClustersKmeans" value="<%=numClustersKmeans_value%>">
				<span class="info" title="For hierarchical clustering, the number of clusters will not affect
					the algorithm.  It will only affect how the results are displayed.">
                    			<img src="<%=imagesDir%>icons/info.gif" alt="Help">
				</span>
                </TD>
                </TR>
        </TABLE>
        </div>


