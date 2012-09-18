        <!-- fill up the client-side array with saved phenotype values -->
        <script language="JAVASCRIPT" type="text/javascript"><%
                int descriptionRowNum = 0;
                int meanRowNum = 0;
                int varianceRowNum = 0;
                if (myPhenotypeValues != null && myPhenotypeValues.length > 0) {
			for (int i = 0; i < myPhenotypeValues.length; i++) {
				%> phenotypeDescriptions[<%=descriptionRowNum%>] =
                                               new phenotypeDescription("<%=myPhenotypeValues[i].getParameter_group_id()%>",
                                                                       "<%=myPhenotypeValues[i].getDescription()%>");
				<%
                                descriptionRowNum++;
				if (myPhenotypeValues[i].getMeans() != null && myPhenotypeValues[i].getMeans().size() > 0) { 
					for (Iterator itr=myPhenotypeValues[i].getMeans().keySet().iterator(); itr.hasNext();) {
						Dataset.Group group = (Dataset.Group) itr.next();
						String mean = (String) myPhenotypeValues[i].getMeans().get(group).toString();
                                        	%> phenotypeMeans[<%=meanRowNum%>] = new phenotypeMean(
                                                        	"<%=myPhenotypeValues[i].getParameter_group_id()%>",
                                                        	"<%=group.getGroup_name()%>",
                                                        	"<%=mean%>");
                                        	<%
                                        	meanRowNum++;
					}
				}
				if (myPhenotypeValues[i].getVariances() != null && myPhenotypeValues[i].getVariances().size() > 0) { 
					for (Iterator itr=myPhenotypeValues[i].getVariances().keySet().iterator(); itr.hasNext();) {
						Dataset.Group group = (Dataset.Group) itr.next();
						String variance = (String) myPhenotypeValues[i].getVariances().get(group).toString();
                                        	%> phenotypeVariances[<%=varianceRowNum%>] = new phenotypeVariance(
                                                        	"<%=myPhenotypeValues[i].getParameter_group_id()%>",
                                                        	"<%=group.getGroup_name()%>",
                                                        	"<%=variance%>");
                                        	<%
                                        	varianceRowNum++;
					}
				}
			}
                } %>
                </script>


