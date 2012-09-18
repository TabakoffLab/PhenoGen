        <!-- fill up the client-side array with saved phenotype values -->
        <script language="JAVASCRIPT" type="text/javascript"><%
                int rowNum = 0;
		//myCombos contains the following values in order:
		// 1. Design type id
		// 2. Design type name
		// 3. Factor id
		// 4. Factor name
		List<String []> myCombos = myExperiment.getCombinations(dbConn);
                if (myCombos != null && myCombos.size() > 0) {
			for (Iterator itr=myCombos.iterator(); itr.hasNext();) {
				String[] values = (String[]) itr.next();
                                       %> combinations[<%=rowNum%>] = new combination(
                                                       "<%=values[0]%>",
                                                       "<%=values[1]%>",
                                                       "<%=values[2]%>",
                                                       "<%=values[3]%>");
                                       <%
                                       rowNum++;
			}
                } %>
                </script>


