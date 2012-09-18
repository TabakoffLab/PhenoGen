                <div id="top_cluster_div" class="showParameters">
                <TABLE class="parameters" >
                <TR>
                        <TD width="250px"> <b>Method:</b></TD>
                        <TD >
                        <%
                        optionHash = new LinkedHashMap();
			optionHash.put("hierarch", "Hierarchical");
                        optionHash.put("kmeans", "K-Means Partitioning");

                        selectName = "cluster_method";
                        onChange = "displayClusterObject()";
                        selectedOption = (String) fieldValues.get(selectName);

                        %><%@ include file="/web/common/selectBox.jsp" %>
				<span class="info" title="<i>Hierarchical</i> clustering builds a hierarchy of cluster objects and the 
					relatedness of clusters is represented in a tree or dendrogram.  <BR><BR>
					<i>K-means</i> clustering
					divides the cluster objects into 'K' clusters based on similarity between objects.">
                    			<img src="<%=imagesDir%>icons/info.gif" alt="Help">
				</span>
                        </TD>
                </TR>
                </TABLE>
                </div>


