                <div id="gene_list_div" class="showParameters">
                <table class="parameters">
                        <tr>
                                <td width="250px"><b>Keep or Remove Probes:</b>
				</td>
                                <td><%
                                        radioName = "geneListParameter2";
                                        selectedOption = "1";
                                        onClick = "";

                                        optionHash = new LinkedHashMap();
                                        optionHash.put("1", "keep" + tenSpaces);
                                        optionHash.put("2", "remove");
                                %>
                                <%@ include file="/web/common/radio.jsp" %>
				</td>
                        </tr>
			<tr> <td colspan="2">&nbsp;</td> </tr>
                        <tr>
                                <td width="250px"><b>Include All Probes(ets) Associated With Genes?: <%=twoSpaces%></b>
			                <span class="info" title="If your gene list contains probes(et) identifiers from the arrays in the 
						dataset you are analyzing,
						and you do not want to include other probes(ets) for the same genes, choose 'No'.  <BR><BR>Otherwise,
						if your gene list does not contain probes(et) identifiers, choose 'Yes' to translate
						your identifiers through the gene symbol into probes(et) identifiers used in this dataset.">
                    				<img src="<%=imagesDir%>icons/info.gif" alt="Help">
			                </span>
				</td>
                                <td><%
                                        radioName = "translateGeneList";
                                        selectedOption = "Y";
                                        onClick = "";

                                        optionHash = new LinkedHashMap();
                                        optionHash.put("Y", "Yes" + tenSpaces);
                                        optionHash.put("N", "No");
                                %>
                                <%@ include file="/web/common/radio.jsp" %>
				</td>
                        </tr>
			<tr> <td colspan="2">&nbsp;</td> </tr>
                        <tr>
                                <td width="250px"><b>Select list of genes:</b>
				</td>
                                <td><%
                                optionHash = new LinkedHashMap();
                                selectName = "geneListID";
                                selectedOption = "-99";

                                optionHash.put("-99", "---------- None selected ----------");

				log.debug("before getGeneLists");
                                GeneList[] myGeneLists =
                                        myGeneList.getGeneLists(userID,
                                        selectedDataset.getOrganism(),
                                        "All",
                                        dbConn);
				log.debug("after getGeneLists. there are " + myGeneLists.length + " gene lists");
                                for (int i=0; i<myGeneLists.length; i++) {
                                        optionHash.put(Integer.toString(myGeneLists[i].getGene_list_id()),
                                                myGeneLists[i].getGene_list_name() + " (" +
                                                myGeneLists[i].getNumber_of_genes() + " " +
                                                myGeneLists[i].getOrganism() + " genes)");
                                }
                                %>
                                <%@ include file="/web/common/selectBox.jsp" %>
				</td>

                        </tr>
                </table>
                </div> <!-- end of gene_list_div -->


